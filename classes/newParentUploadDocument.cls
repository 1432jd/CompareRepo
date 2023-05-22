public class newParentUploadDocument {
    /*@AuraEnabled
    public static WrapperData getAllRequiredData(String stageName, String applicationId, String recordTypeId){
        WrapperData wrapper = new WrapperData();
        Set<String> setCodeIds = new Set<String>();
        Map<String, String> mapOfDeferalIds = new Map<String, String>();
        /*for(Deferral_Document__c def : [SELECT Id, Document_Set_Code__c, Deferral_Stage__c FROM Deferral_Document__c WHERE Document_Set_Code__c != null AND Application__c =: applicationId AND Is_Deferral_Document__c = TRUE]){
            if(def.Deferral_Stage__c == stageName){
                mapOfDeferalIds.put(def.Document_Set_Code__c, def.Id);
            }
        }
        for(Document_Set_Code__c objSet : [SELECT Id, Name, Type__c, Applicable_For__c, Income_Type__c, Asset_Type__c, Sub_Type__c, Mandatory__c, Stage__c, Active__c, Family__c, Document_Master__c, Document_Master__r.Active__c FROM Document_Set_Code__c WHERE Id IN :mapOfDeferalIds.keySet()]){
            String defId = mapOfDeferalIds.get(objSet.Id);
            wrapper.mapOfDeferralSetCode.put(defId, objSet);    
        }
        
        wrapper.listOfDocumentSetCode = [SELECT Id, Name, Type__c, Applicable_For__c, Income_Type__c, Asset_Type__c, Sub_Type__c, Mandatory__c, Stage__c, Active__c, Family__c, Document_Master__c, Document_Master__r.Active__c FROM Document_Set_Code__c WHERE Stage__c =: stageName AND Active__c =: 'Yes' AND Document_Master__r.Active__c =: 'Yes'];
        wrapper.listOfLoanApplicant = [SELECT Id, Customer_Information__c, Customer_Type__c, Application__c, Applicant_Name__c FROM Loan_Applicant__c WHERE Application__c =: applicationId];
        wrapper.listOfProperty = [SELECT Id, Name, Property_Type__c  FROM Property__c WHERE Application__c =: applicationId AND recordTypeId =:recordTypeId AND Property_Type__c != ''];
        Set<String> setOfLoanApplicantId = new Set<String>();
        for(Loan_Applicant__c objLoan : wrapper.listOfLoanApplicant){
            if(String.isNotBlank(objLoan.Customer_Information__c)){
                setOfLoanApplicantId.add(objLoan.Id);    
            }
        }
        wrapper.listOfEmpoymentDetails = [SELECT Id, Name, Application__c, Occupation__c, Customer_Information__c, Loan_Applicant__c FROM Employment_Details__c WHERE Loan_Applicant__c =: setOfLoanApplicantId];
        return wrapper;
    }
    @AuraEnabled
    public static WrapperUploadedDocument getUploadedData(String stageName, String applicationId){
        WrapperUploadedDocument objWrapper = new WrapperUploadedDocument();
        objWrapper.listOfContentVersion = [SELECT Id,  Uploaded_From__c, Parent_Id__c, Document_Name__c, Current_Record_Id__c, Document_Type__c FROM ContentVersion WHERE Parent_Id__c =: applicationId AND Uploaded_From__c =: stageName];
        objWrapper.listOfDeferralDocument = [SELECT Id, Application__c, Is_Deferral_Document__c, Current_Record_Id__c, Type__c, Status__c FROM Deferral_Document__c  WHERE Application__c =: applicationId AND Uploaded_From__c =: stageName];
        return objWrapper;
    }
    public class WrapperUploadedDocument{
        @AuraEnabled
        public List<ContentVersion> listOfContentVersion;
        @AuraEnabled
        public List<Deferral_Document__c> listOfDeferralDocument;
        public WrapperUploadedDocument(){
            listOfContentVersion = new List<ContentVersion>();
            listOfDeferralDocument = new List<Deferral_Document__c>();
        }
    }
    public class WrapperData{
        @AuraEnabled
        public Map<String, Document_Set_Code__c> mapOfDeferralSetCode; 
        @AuraEnabled
        public List<Document_Set_Code__c> listOfDocumentSetCode; 
        @AuraEnabled
        public List<Loan_Applicant__c> listOfLoanApplicant; 
        @AuraEnabled
        public List<Property__c> listOfProperty; 
        @AuraEnabled
        public List<Employment_Details__c> listOfEmpoymentDetails; 
        public WrapperData(){
            mapOfDeferralSetCode = new Map<String, Document_Set_Code__c>();
            listOfDocumentSetCode = new List<Document_Set_Code__c>(); 
            listOfLoanApplicant = new List<Loan_Applicant__c>(); 
            listOfProperty = new List<Property__c>(); 
            listOfEmpoymentDetails = new List<Employment_Details__c>();
        }
    }
    
    //Documents Save Process
    @AuraEnabled
    public static void createCVRecord(String data, String currentStageName){
        System.debug('data :: '+data);
        WrapperCV jsonWrapper = (WrapperCV)JSON.deserialize(data, WrapperCV.class);
        System.debug('jsonWrapper :: '+jsonWrapper);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = jsonWrapper.fileData.filename;
        cv.VersionData = EncodingUtil.base64Decode(jsonWrapper.fileData.base64);
        cv.PathOnClient = jsonWrapper.filename;
        cv.Document_Name__c = jsonWrapper.documentName;
        cv.Document_Family__c = jsonWrapper.documentFamily;
        cv.Document_Type__c = jsonWrapper.documentType;
        if(cv.Document_Type__c == 'Applicant'){
            cv.Current_Record_Id__c = jsonWrapper.applicantId;
        }
        if(cv.Document_Type__c == 'Asset'){
            cv.Current_Record_Id__c = jsonWrapper.propertyId;
        }
        cv.Document_Condition__c = jsonWrapper.documentCondition;
        cv.Mandatory__c = jsonWrapper.mandatory;
        cv.Status__c = jsonWrapper.status;
        cv.Uploaded_From__c = currentStageName;
        cv.Original__c = jsonWrapper.original;
        cv.Remarks__c = jsonWrapper.remarks;
        cv.Received_Date__c = jsonWrapper.receivedDate;
        cv.Parent_Id__c = jsonWrapper.fileData.recordId;
        cv.OwnerId = UserInfo.getUserId();
        cv.Number_of_Pages__c = jsonWrapper.noOfPages;
        insert cv;   
        ContentDocumentLink cdl = createContentLink(cv.Id, jsonWrapper.fileData.recordId);
    }
    @AuraEnabled
    public static void createDeferralRecord(String data, String currentStageName, String recordId){
        DeferralWrapper jsonWrapper = (DeferralWrapper)JSON.deserialize(data, DeferralWrapper.class);  
        Deferral_Document__c objDef = new Deferral_Document__c();
        objDef.application__c = recordId; 
        objDef.Document_Name__c = jsonWrapper.documentName; 
        objDef.Document_Family__c = jsonWrapper.documentFamily; 
        objDef.Status__c = jsonWrapper.status;
        objDef.Mandatory__c = jsonWrapper.mandatory; 
        objDef.Type__c = jsonWrapper.documentType; 
        objDef.Uploaded_From__c = currentStageName;
        objDef.Document_Set_Code__c = jsonWrapper.docSetCodeId; 
        if(jsonWrapper.documentType == 'Applicant'){
            objDef.Current_Record_Id__c = jsonWrapper.applicantId;
        }
        if(jsonWrapper.documentType == 'Asset'){
            objDef.Current_Record_Id__c = jsonWrapper.propertyId;
        }
        if(jsonWrapper.status == 'Waived'){
            objDef.Waiver_Reason__c = jsonWrapper.waiverReason;
            objDef.Remarks__c = jsonWrapper.remarks;
        }
        if(jsonWrapper.status == 'Deferred'){
            objDef.Is_Deferral_Document__c = true;    
            objDef.Deferral_Stage__c = jsonWrapper.stage;
            objDef.Deferral_Date__c = jsonWrapper.deferredDate;
            objDef.Remarks__c = jsonWrapper.remarks;
        }
        insert objDef;
    }
    
    
    private static ContentDocumentLink createContentLink(String cvId, String recordId) {
        if (cvId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cvId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    public class WrapperCV{
        @AuraEnabled public String docSetCodeId;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public String applicantId;
        @AuraEnabled public String applicableFor;
        @AuraEnabled public String customerType;
        @AuraEnabled public String customerName;
        @AuraEnabled public String documentName;
        @AuraEnabled public String documentFamily;
        @AuraEnabled public String documentType;
        @AuraEnabled public String documentCondition;
        @AuraEnabled public String mandatory;
        @AuraEnabled public String status;
        @AuraEnabled public String stage;
        @AuraEnabled public Date deferredDate;
        @AuraEnabled public String waiverReason;
        @AuraEnabled public Date receivedDate;
        @AuraEnabled public String noOfPages;
        @AuraEnabled public String remarks;
        @AuraEnabled public String isNewRowAdded;
        @AuraEnabled public String fileName;
        @AuraEnabled public String original;
        @AuraEnabled public String propertyId;
        
        @AuraEnabled public fileData fileData;
    }
    public class fileData {
        @AuraEnabled
        public String filename; 
        @AuraEnabled
        public String base64;   
        @AuraEnabled
        public String recordId;
    }
    public class DeferralWrapper{
        @AuraEnabled public Integer serialNumber;   
        @AuraEnabled public string docSetCodeId;
        @AuraEnabled public String documentName;    
        @AuraEnabled public String documentFamily;  
        @AuraEnabled public String mandatory;   
        @AuraEnabled public String documentType;
        @AuraEnabled public String status;  
        @AuraEnabled public String stage;   
        @AuraEnabled public boolean deferredStageDisable;
        @AuraEnabled public boolean deferredRequired;
        @AuraEnabled public date deferredDate;
        @AuraEnabled public date receivedDate;
        @AuraEnabled public boolean isReceivedDateRequired;
        @AuraEnabled public boolean receivedDateDisable;
        @AuraEnabled public String noOfPages;   
        @AuraEnabled public String waiverReason;
        @AuraEnabled public boolean isWaiverRequired;
        @AuraEnabled public boolean waiverReasonDisable;
        @AuraEnabled public String remarks; 
        @AuraEnabled public String isNewRowAdded;   
        @AuraEnabled public String fileName;    
        @AuraEnabled public boolean isFileUploadDisabled;
        @AuraEnabled public boolean isFileUploadRequired;
        @AuraEnabled public String original;    
        @AuraEnabled public boolean isoriginalDisabled;
        @AuraEnabled public String fileData;    
        @AuraEnabled public boolean isAgreementExecution;
        @AuraEnabled public String applicationId;
        @AuraEnabled public String applicantId;
        @AuraEnabled public String propertyId;
        
    }*/
}