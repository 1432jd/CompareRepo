/**
* @File Name          : fsGenericUploadDocumentsController.cls
* @Description        : Service Class For fsGenericUploadDocuments Lightning Component
* @Author             : Mo Arslan
* @Created On         : 20/07/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         20/07/2022              Mo Arslan             Initial Version
*/
public Without Sharing class fsGenericUploadDocumentsController {

    @AuraEnabled
    public static ViewDocumentWrapper getUploadedRecords(String parentId, String stageName){
        ViewDocumentWrapper viewDocumentObj = new ViewDocumentWrapper();
        viewDocumentObj.uploadedDocuments = new List<DocumentView>();
        viewDocumentObj.additionalDocuments = new List<DocumentView>();
        Set<String> cdIds = new Set<String>();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
        String query = 'SELECT Id, Uploaded_By__c, Applicable_For__c, Version_Number__c , Document_Name__c, Is_Additional_Document__c, Title, ContentDocumentId, OwnerId, Owner.Name, Number_of_Pages__c, Remarks__c, Uploaded_From__c FROM ContentVersion WHERE Parent_Id__c =: parentId';
        if(stageName==null){
            for(ContentDocumentLink cdl : [Select Id,ContentDocument.title,  LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:parentId]){
                cdIds.add(cdl.ContentDocumentId);
            }
            query+=' OR ContentDocumentId In :cdIds';
        }
        List<String> documentRoles = DatabaseUtililty.getDocumentRoles();
        for(ContentVersion cv : Database.Query(query)){
            DocumentView obj = new DocumentView();
            obj.documentName = cv.Document_Name__c;
            obj.remarks = cv.Remarks__c;
            if(cv.Uploaded_By__c!=null && String.isNotBlank(cv.Uploaded_By__c) && String.isNotEmpty(cv.Uploaded_By__c)){
                obj.ownerName = cv.Uploaded_By__c;
            }
            else{
                obj.ownerName = cv.Owner.Name;
            }
            obj.contentDocumentId = cv.ContentDocumentId;
            obj.versionNumber = String.valueOf(cv.Version_Number__c);
            obj.numberOfPages = String.valueOf(cv.Number_Of_Pages__c);
            obj.uploadedFrom = cv.Uploaded_From__c;
            obj.title = cv.Title;
            obj.applicableFor = cv.Applicable_For__c;
            if(documentRoles == null){
                obj.isDocumentView = true;
                obj.isCheckboxDisabled = false;
            }
            else if(documentRoles!=null && !documentRoles.isEmpty() && profileName == 'System Administrator'){
                obj.isDocumentView = true;
                obj.isCheckboxDisabled = false;
            }
            else{
                if(documentRoles!=null && !documentRoles.isEmpty() && documentRoles.contains(cv.Uploaded_From__c)){
                    obj.isDocumentView = true;
                    obj.isCheckboxDisabled = false;
                }
                else{
                    obj.isDocumentView = false;
                    obj.isCheckboxDisabled = true;
                }
            }
            if(cv.Is_Additional_Document__c == false){
                viewDocumentObj.uploadedDocuments.add(obj);
            }
            if(cv.Is_Additional_Document__c == true){
                viewDocumentObj.additionalDocuments.add(obj);
            }
        }
        return viewDocumentObj;
    }
    
    @AuraEnabled
    public static WrapperData getAllRequiredDocument(String stageName, String filter ){
        return null;
    }
    
    @AuraEnabled
    public static WrapperData getAllAssetData(String applicationId, String recordTypeId ){
        return null;
    }
    
    @AuraEnabled
    public static WrapperData getAllApplicantData(String applicationId ){
        return null;
    }
    
    @AuraEnabled
    public static void uploadFile(String base64, String filename, String recordId, String cvDocData ){
        //return null;
    }
    
    @AuraEnabled
    public static WrapperData getAllRequiredData(String stageName, String applicationId, String recordTypeId){
        WrapperData wrapper = new WrapperData();
        Set<String> setCodeIds = new Set<String>();
        Map<String, String> mapOfDeferalIds = new Map<String, String>();
        /**
         * Get Master Records
         * Get Applicant Records
         * Get Asset Records
         */
        wrapper.listOfDocumentMaster = [SELECT Id, Name, Description__c, Type__c, Active__c, Family__c FROM Document_Master__c WHERE Active__c = 'Yes'];
        wrapper.listOfDocumentSetCode = [SELECT Id, Name, Type__c, Applicable_For__c, Income_Type__c, Asset_Type__c, Sub_Type__c, Mandatory__c, Stage__c, Active__c, Family__c, Document_Master__c, Document_Master__r.Name, Document_Master__r.Active__c FROM Document_Set_Code__c WHERE Active__c =: 'Yes' AND Document_Master__r.Active__c =: 'Yes'];
        wrapper.listOfLoanApplicant = [SELECT Id, Customer_Information__c,Customer_Information__r.Name, Customer_Type__c, Application__c, Applicant_Name__c FROM Loan_Applicant__c WHERE Application__c =: applicationId];
        wrapper.listOfProperty = [SELECT Id, Name, Property__c, Property_Type__c  FROM Property__c WHERE Application__c =: applicationId AND recordTypeId =:recordTypeId AND Property_Type__c != ''];

        /**
         * Get Document Deferral Uploaded Records
         */

        for(Deferral_Document__c def : [SELECT Id,isDeferred__c, Applicable_Name__c, Deferred_From__c, Document_Family__c, Is_Document_Received__c, Document_Name__c, Mandatory__c, Type__c, Current_Record_Id__c, Document_Set_Code__c, Deferral_Stage__c, Status__c, Deferral_Date__c, Remarks__c, Waiver_Reason__c, Uploaded_From__c, Is_Deferral_Document__c, Is_Document_Master_Record__c, Parent_Property_Id__c, Applicable_For__c, Applicant_Name__c, Applicant_Type__c FROM Deferral_Document__c WHERE Document_Set_Code__c != null AND Application__c =: applicationId]){
            if((def.Deferral_Stage__c == stageName && def.Is_Deferral_Document__c && !def.Is_Document_Master_Record__c)){
                mapOfDeferalIds.put(def.Document_Set_Code__c, def.Id);
            }
            if(def.Is_Document_Master_Record__c){
                System.debug('Document Type '+def.Type__c);
                wrapper.listOfDeferralMasterDocumentDocument.add(def);
            }
            if(def.Type__c == 'Application'){
                wrapper.mapOfDeferralDocument.put(def.Document_Set_Code__c, def);
            } else if(def.Type__c == 'Applicant'){
                String uniqueId = def.Document_Set_Code__c + '-' + def.Current_Record_Id__c;
                wrapper.mapOfDeferralDocument.put(uniqueId, def);
            } else if(def.Type__c == 'Asset'){
                String setCodeWithPropertyId = def.Document_Set_Code__c + def.Current_Record_Id__c;
                String setCodeWithParentProperty = def.Document_Set_Code__c + def.Parent_Property_Id__c;
                wrapper.mapOfDeferralDocument.put(setCodeWithPropertyId + '-' + setCodeWithParentProperty, def);
            }
        }
        for(Document_Set_Code__c objSet : [SELECT Id, Name, Type__c, Applicable_For__c, Income_Type__c, Asset_Type__c, Sub_Type__c, Mandatory__c, Stage__c, Active__c, Family__c, Document_Master__c, Document_Master__r.Active__c FROM Document_Set_Code__c WHERE Id IN :mapOfDeferalIds.keySet()]){
            String defId = mapOfDeferalIds.get(objSet.Id);
            wrapper.mapOfDeferralSetCode.put(defId, objSet);    
        }
        
        /**
         * Get CV Uploaded Records
         */
        for(ContentVersion cv : [SELECT Id, Status__c,Document_Family__c,Applicable_For__c, Version_Number__c, Parent_Property_Id__c, Current_Stage__c, Deferred_From__c, Parent_Id__c, Document_Name__c, Is_Document_Master_Record__c, ContentDocumentId, Mandatory__c, Uploaded_From__c, Current_Record_Id__c, Document_Type__c, Document_Set_Code_Id__c, Received_Date__c, Remarks__c, Number_of_Pages__c, Original__c FROM ContentVersion WHERE Parent_Id__c =: applicationId AND (Document_Set_Code_Id__c != '' OR Is_Document_Master_Record__c = True) ORDER BY Version_Number__c ASC]){
            if(cv.Document_Type__c == 'Application'){
                wrapper.mapOfContentVersion.put(cv.Document_Set_Code_Id__c, cv);
            }else if(cv.Document_Type__c == 'Applicant'){
                wrapper.mapOfContentVersion.put(cv.Document_Set_Code_Id__c + '-' + cv.Current_Record_Id__c, cv);
            } else if(cv.Document_Type__c == 'Asset'){
                String setCodeWithPropertyId = cv.Document_Set_Code_Id__c + cv.Current_Record_Id__c;
                String setCodeWithParentProperty = cv.Document_Set_Code_Id__c + cv.Parent_Property_Id__c;
                wrapper.mapOfContentVersion.put(setCodeWithPropertyId + '-' + setCodeWithParentProperty, cv);
            }   
        }
        /**
         * Get All Employment Records
         */
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
        objWrapper.listOfDeferralDocument = [SELECT Id, Application__c, Is_Deferral_Document__c, Current_Record_Id__c, Type__c, Status__c, Document_Set_Code__c FROM Deferral_Document__c  WHERE Application__c =: applicationId AND Uploaded_From__c =: stageName];
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
        public List<Document_Master__c> listOfDocumentMaster; 
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
        @AuraEnabled
        public Map<String, ContentVersion> mapOfContentVersion; 
        @AuraEnabled
        public Map<String, Deferral_Document__c> mapOfDeferralDocument; 
        @AuraEnabled
        public List<Deferral_Document__c> listOfDeferralMasterDocumentDocument; 

        public WrapperData(){
            listOfDocumentMaster = new List<Document_Master__c>();
            mapOfDeferralSetCode = new Map<String, Document_Set_Code__c>();
            listOfDocumentSetCode = new List<Document_Set_Code__c>(); 
            listOfLoanApplicant = new List<Loan_Applicant__c>(); 
            listOfProperty = new List<Property__c>(); 
            listOfEmpoymentDetails = new List<Employment_Details__c>();
            mapOfContentVersion = new Map<String, ContentVersion>();
            mapOfDeferralDocument = new Map<String, Deferral_Document__c>();
            listOfDeferralMasterDocumentDocument = new List<Deferral_Document__c>();
        }
    }
    
    //Documents Save Process
    @AuraEnabled
    public static ResponseWrapper createCVRecord(String data, String currentStageName){
        System.debug('data :: '+data);

        WrapperCV jsonWrapper =  (WrapperCV)JSON.deserialize(data, WrapperCV.class);
        Set<String> setOfDefDelRecords = new Set<String>();
        ContentVersion cv = new ContentVersion();
        cv.Title = jsonWrapper.fileData.filename;
        cv.Version_Number__c = jsonWrapper.versionNumber;
        cv.VersionData = EncodingUtil.base64Decode(jsonWrapper.fileData.base64);
        cv.PathOnClient = jsonWrapper.fileData.filename;
        if(String.isNotBlank(jsonWrapper.deferalRecordId)){
            setOfDefDelRecords.add(jsonWrapper.deferalRecordId);
        } else{
            cv.Current_Stage__c = currentStageName;
            cv.Deferred_From__c = currentStageName;
        }
        if(!jsonWrapper.isNewRowAdded && !jsonWrapper.isDocumentMaster){
            cv.Document_Set_Code_Id__c = jsonWrapper.docSetCodeId; 
        } else{
            cv.Is_Document_Master_Record__c = true;
            cv.Document_Set_Code_Id__c = jsonWrapper.docSetCodeId;
        }
        if(String.isNotBlank(jsonWrapper.parentPropertyId)){
            cv.Parent_Property_Id__c = jsonWrapper.parentPropertyId;
        }
        
        cv.Document_Name__c = jsonWrapper.documentName;
        cv.Document_Family__c = jsonWrapper.documentFamily;
        cv.Document_Type__c = jsonWrapper.documentType;
        cv.Document_Number__c = jsonWrapper.documentCode;
        cv.Applicable_For__c = jsonWrapper.applicableName;
        if(cv.Document_Type__c == 'Applicant'){
            cv.Current_Record_Id__c = jsonWrapper.applicantId;
        }
        if(cv.Document_Type__c == 'Asset'){
            cv.Current_Record_Id__c = jsonWrapper.propertyId;
        }
        cv.Document_Condition__c = jsonWrapper.documentCondition;
        cv.Agreement_Document_Type__c = jsonWrapper.agreementDocumentType;
        cv.Mandatory__c = jsonWrapper.mandatory;
        cv.Status__c = jsonWrapper.status;
        cv.Uploaded_From__c = currentStageName;
        cv.Original__c = jsonWrapper.original;
        cv.Remarks__c = jsonWrapper.remarks;
        cv.Received_Date__c = jsonWrapper.receivedDate;
        cv.Parent_Id__c = jsonWrapper.fileData.recordId;
        cv.OwnerId = UserInfo.getUserId();
        cv.Number_of_Pages__c = jsonWrapper.noOfPages;
        cv.IsMajorVersion = false;
        System.debug(':: cv :: '+cv);
        insert cv;
        //createContentLink(cv.Id, jsonWrapper.fileData.recordId);
        //ContentDocumentLink cdl = createContentLink(cv.Id, jsonWrapper.fileData.recordId);
		if(jsonWrapper.isDeferalRecord && String.isNotBlank(jsonWrapper.deferalRecordId)){
            Deferral_Document__c objDef = new Deferral_Document__c();
            objDef.Id = jsonWrapper.deferalRecordId;
            objDef.Is_Deferral_Document__c = false;
            objDef.Is_Document_Received__c = true;
            update objDef;
        }
        /*if(setOfDefDelRecords != null && setOfDefDelRecords.size() > 0){
            DELETE [SELECT Id FROM Deferral_Document__c WHERE Id IN: setOfDefDelRecords];
        }*/
        // DELERE Deferred Record when It get Received on same Stage
        if(String.isNotBlank(jsonWrapper.docSetCodeId) && String.isNotEmpty(jsonWrapper.docSetCodeId) && jsonWrapper.status == 'Received'){
            if(cv.Document_Type__c == 'Applicant'){
                Delete [SELECT Id FROM Deferral_Document__c where Document_Set_Code__c =:jsonWrapper.docSetCodeId AND Uploaded_From__c =:currentStageName AND Current_Record_Id__c =:jsonWrapper.applicantId];
            }
            if(cv.Document_Type__c == 'Asset'){
                Delete [SELECT Id FROM Deferral_Document__c where Document_Set_Code__c =:jsonWrapper.docSetCodeId AND Uploaded_From__c =:currentStageName AND Current_Record_Id__c =:jsonWrapper.propertyId];
            }
            if(cv.Document_Type__c == 'Application'){
                Delete [SELECT Id FROM Deferral_Document__c where Document_Set_Code__c =:jsonWrapper.docSetCodeId AND Uploaded_From__c =:currentStageName AND Application__c =:jsonWrapper.fileData.recordId];
            }
        }
        ResponseWrapper response = new ResponseWrapper();
        response.deferalRecordId = '';
        response.contentVersionId = cv.Id;
        response.contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        return response;
    }

    @AuraEnabled
    public static Map<String, ContentVersion> uploadedDocuments(String recordId){
        Map<String, ContentVersion> uploadedDocs = new Map<String, ContentVersion>();
        for(ContentVersion cv : [SELECT Id, Version_Number__c, Document_Set_Code_Id__c , Document_Name__c FROM ContentVersion WHERE Parent_Id__c =:recordId]){
            uploadedDocs.put(cv.Document_Set_Code_Id__c+'-'+cv.Version_Number__c+'-'+cv.Document_Name__c, cv);
        }
        return uploadedDocs;
    }

    @AuraEnabled
    public static String updateContentVersion(String contentDocumentId, String remarks){
        if(String.isNotBlank(contentDocumentId) && String.isNotEmpty(contentDocumentId)){
            ContentVersion cv = [SELECT Id, Remarks__c FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
            cv.Remarks__c = remarks;
            update cv;
            return 'Success';
        }
        return null;
    }


    // @AuraEnabled
    // public static String uploadChunk(String cdId, String base64, String stageName){
    //     if(String.isNotBlank(cdId) && String.isNotEmpty(cdId)){
    //         ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :cdId];
    //         cv.VersionData = EncodingUtil.base64Decode((EncodingUtil.base64Encode(cv.VersionData) + (( String ) JSON.deserialize( base64, String.class )))); 
    //         update cv;
    //         return cv.Id;
    //     }
    //     return null;
    // }

    @AuraEnabled
    public static ResponseWrapper createDeferralRecord(String data, String currentStageName, String recordId){
        System.debug('recordId ##### '+recordId);
        DeferralWrapper jsonWrapper = new DeferralWrapper();
        try{
            jsonWrapper = (DeferralWrapper)JSON.deserialize(data, DeferralWrapper.class);
        } 
        catch(Exception e){
            System.debug('Error ' +e.getMessage() +' '+e.getLineNumber());
        }
        System.debug('jsonWrapper'+jsonWrapper); 
        Set<String> setOfDefSetCodeRecords = new Set<String>();
        Deferral_Document__c objDef = new Deferral_Document__c();
        if(String.isNotBlank(jsonWrapper.deferalRecordId)){
            objDef.Id = jsonWrapper.deferalRecordId;
        }else{
            objDef.Deferred_From__c = currentStageName;
        }
        objDef.Application__c = recordId; 
        objDef.Document_Name__c = jsonWrapper.documentName; 
        objDef.Document_Family__c = jsonWrapper.documentFamily; 
        objDef.Status__c = jsonWrapper.status;
        objDef.Mandatory__c = jsonWrapper.mandatory; 
        objDef.Type__c = jsonWrapper.documentType; 
        objDef.Applicable_Name__c = jsonWrapper.applicableName;
        objDef.Uploaded_From__c = currentStageName;
        objDef.isDeferred__c = jsonWrapper.isDeferred;
        if(String.isNotBlank(jsonWrapper.docSetCodeId)){
            setOfDefSetCodeRecords.add(jsonWrapper.docSetCodeId);
        }
        /*if(jsonWrapper.isNewRowAdded){
            objDef.Deferred_From__c = currentStageName;
        }*/
        objDef.Applicable_For__c = jsonWrapper.applicableFor;
        objDef.Applicant_Name__c = jsonWrapper.customerName;
        objDef.Applicant_Type__c = jsonWrapper.customerType;
        if(String.isNotBlank(jsonWrapper.parentPropertyId)){
            objDef.Parent_Property_Id__c = jsonWrapper.parentPropertyId;
        }
        if(!jsonWrapper.isNewRowAdded && !jsonWrapper.isDocumentMaster){
            objDef.Document_Set_Code__c = jsonWrapper.docSetCodeId; 
        } else{
            objDef.Is_Document_Master_Record__c = true;
            objDef.Document_Set_Code__c = jsonWrapper.docSetCodeId;
        }
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
        System.debug('objDef ##### '+objDef);
        upsert objDef;
        ResponseWrapper response = new ResponseWrapper();
        response.deferalRecordId = objDef.Id;

        if(setOfDefSetCodeRecords != null && setOfDefSetCodeRecords.size() > 0){
            Set<String> setOfContentDocument = new Set<String>();
            if(jsonWrapper.documentType == 'Application'){
                for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Document_Set_Code_Id__c IN: setOfDefSetCodeRecords]){
                    setOfContentDocument.add(cv.ContentDocumentId);
                }
            } else{
                for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Document_Set_Code_Id__c IN: setOfDefSetCodeRecords AND Current_Record_Id__c =: objDef.Current_Record_Id__c]){
                    setOfContentDocument.add(cv.ContentDocumentId);
                }
            }

            if(setOfContentDocument != null && setOfContentDocument.size() > 0) {
                DELETE [SELECT Id FROM ContentDocument WHERE Id IN: setOfContentDocument];
            }
            
        }
        return response;
    }
    
    
    /*private static void createContentLink(String cvId, String recordId) {
        //if (cvId == null || recordId == null) { return null; }
        List<ContentDocumentLink> listOfCDL = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'C';
        //listOfCDL.add(cdl);
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvId].ContentDocumentId;
        cdl2.LinkedEntityId = UserInfo.getOrganizationId();
        cdl2.ShareType = 'C';
        cdl2.Visibility = 'AllUsers';
        listOfCDL.add(cdl2);
        insert listOfCDL;
    }*/
    public class ResponseWrapper{
        @AuraEnabled public String deferalRecordId;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String contentVersionId;
        public ResponseWrapper(){
            deferalRecordId = '';
            contentDocumentId = '';
            contentVersionId = '';
        }
    }
    public class WrapperCV{
        @AuraEnabled public String documentCode;
        @AuraEnabled public String docSetCodeId;
        @AuraEnabled public String serialNumber;
        @AuraEnabled public String parentPropertyId;
        @AuraEnabled public String applicantId;
        @AuraEnabled public String applicableFor;
        @AuraEnabled public String customerType;
        @AuraEnabled public String customerName;
        @AuraEnabled public String documentName;
        @AuraEnabled public String documentFamily;
        @AuraEnabled public String documentType;
        @AuraEnabled public String agreementDocumentType;
        @AuraEnabled public String documentCondition;
        @AuraEnabled public String mandatory;
        @AuraEnabled public String status;
        @AuraEnabled public String stage;
        @AuraEnabled public Date deferredDate;
        @AuraEnabled public Integer versionNumber;
        @AuraEnabled public String waiverReason;
        @AuraEnabled public Date receivedDate;
        @AuraEnabled public String noOfPages;
        @AuraEnabled public String remarks;
        @AuraEnabled public Boolean isNewRowAdded;
        @AuraEnabled public String fileName;
        @AuraEnabled public String original;
        @AuraEnabled public String propertyId;
        @AuraEnabled public Boolean isDeferalRecord;
        @AuraEnabled public String deferalRecordId;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public Boolean isDocumentMaster;
        @AuraEnabled public fileData fileData;
        @AuraEnabled public String applicableName;
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
        @AuraEnabled public String parentPropertyId; 
        @AuraEnabled public String applicableFor;
        @AuraEnabled public String customerType;
        @AuraEnabled public String customerName;
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
        @AuraEnabled public Boolean isNewRowAdded;  
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
        @AuraEnabled public Boolean isDeferalRecord;
        @AuraEnabled public String deferalRecordId;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public Boolean isDocumentMaster;
        @AuraEnabled public String applicableName;
        @AuraEnabled public Boolean isDeferred;
    }
    //Additional Document Functionality
    @AuraEnabled
    public static void uploadAddtionalDocument(String base64, String filename, String recordId, String description, String uploadedFrom) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.Document_Name__c = filename;
        cv.Remarks__c = description;
        cv.Parent_Id__c = recordId;
        cv.OwnerId = UserInfo.getUserId();
        cv.Is_Additional_Document__c = true;
        cv.Uploaded_From__c = uploadedFrom;
        insert cv;
		//createContentLink(cv.Id, recordId);
        //ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
    }
    
    @AuraEnabled
    public static String uploadPhotos(String jsonPhotoData, String base64, String recordId){
        if(String.isNotBlank(recordId) && String.isNotEmpty(recordId)){
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :recordId];
            cv.VersionData = EncodingUtil.base64Decode((EncodingUtil.base64Encode(cv.VersionData) + (( String ) JSON.deserialize( base64, String.class )))); 
            update cv;
            return cv.Id;
        }
        else{
            PhotosWrapper photoObj = (PhotosWrapper)JSON.deserialize(jsonphotoData, PhotosWrapper.class);
            System.debug('photoObj '+photoObj);
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(photoObj.base64);
            cv.Title = photoObj.fileName;
            cv.PathOnClient = photoObj.fileName;
            cv.Document_Name__c = photoObj.fileName;
            cv.Parent_Id__c = photoObj.recordId;
            cv.OwnerId = UserInfo.getUserId();
            cv.Is_Additional_Document__c = true;
            cv.Uploaded_From__c = photoObj.stagName;
            cv.File_Type__c = photoObj.stagName+' Photo';
            cv.IsMajorVersion = false;
            insert cv;
            return cv.Id;
        }
    }

    /*@AuraEnabled
    public static void contentLinks(List<ContentVersion> cvList){
        Map<String, ContentVersion> cvContentDocIdMap = new Map<String, ContentVersion>();
        List<ContentDocumentLink> listOfCDL = new List<ContentDocumentLink>();
        if(!cvList.isEmpty())
        for(ContentVersion cv : [SELECT ContentDocumentId, Parent_Id__c FROM ContentVersion WHERE Id In : cvList]){
            cvContentDocIdMap.put(cv.Id, cv);
        }
        for(ContentVersion cv : cvList){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cvContentDocIdMap.get(cv.Id).ContentDocumentId;
            cdl.LinkedEntityId = cv.Parent_Id__c;
            cdl.ShareType = 'I';
            //listOfCDL.add(cdl);
            
            ContentDocumentLink cdl2 = new ContentDocumentLink();
            cdl2.ContentDocumentId = cvContentDocIdMap.get(cv.Id).ContentDocumentId;
            cdl2.LinkedEntityId = UserInfo.getOrganizationId();
            cdl2.ShareType = 'V';
            listOfCDL.add(cdl2);
        }
        if(!listOfCDL.isEmpty()){
            insert listOfCDL;
        }
    }*/

    @AuraEnabled
    public static String getHackURL(String contentDocumentIds){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String filesDownloadUrl = baseUrl+'/sfc/servlet.shepherd/version/download';
        List<String> contentDocumentIdsList = (List<String>)JSON.deserialize(contentDocumentIds, List<String>.class);
        for(ContentVersion  cd : [SELECT Id FROM ContentVersion WHERE ContentDocumentId In : contentDocumentIdsList]){
            filesDownloadUrl += '/'+cd.Id;
        }
        return filesDownloadUrl;
    }

    public class PhotosWrapper{
        @AuraEnabled public String base64;
        @AuraEnabled public String recordId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String stagName;
    }

    public class ViewDocumentWrapper{
        @AuraEnabled public List<DocumentView> uploadedDocuments;
        @AuraEnabled public List<DocumentView> additionalDocuments;
    }

    public class DocumentView{
        @AuraEnabled public String documentName;
        @AuraEnabled public String versionNumber;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String numberOfPages;
        @AuraEnabled public String remarks;
        @AuraEnabled public String uploadedFrom;
        @AuraEnabled public String title;
        @AuraEnabled public Boolean isDocumentView;
        @AuraEnabled public Boolean isCheckboxDisabled;
        @AuraEnabled public String applicableFor;
    }
}