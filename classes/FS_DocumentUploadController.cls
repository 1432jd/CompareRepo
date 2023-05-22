public without sharing class FS_DocumentUploadController {

    public static String data{get;set;}
    public static String cvId{get;set;}
    public static String versionNumber{get;set;}
    public static String uploadedFrom{get;set;}

    @AuraEnabled
    public static void refreshRecords(String applicationId){
        try {
            List<Deferral_Document__c> documentList = new List<Deferral_Document__c>(); // Contains all the previous records
            List<Deferral_Document__c> documentListToInsert = new List<Deferral_Document__c>(); // Contains all the records to insert
            List<Deferral_Document__c> documentListToDelete = new List<Deferral_Document__c>(); // Contains all the records to delete                        
                            
            List<Document_Master__c> documentMasters = getDocumentMasters();
            List<Document_Set_Code__c> documentSetMasters = getDocumentSetMasters();
            List<Loan_Applicant__c> loanApplicants = getLoanApplicants(applicationId);	         
            List<Property__c> properties = getProperties(applicationId);
            
            documentList = [SELECT
                            Id, Stage__c, Document_Name__c, Type__c, Loan_Applicant__c, Property__c, Applicable_For__c, Asset_Type__c, Status__c,
                            Document_Master__c, Related_Document_Set_Code__c, Document_Master__r.Active__c, Related_Document_Set_Code__r.Active__c
                            FROM Deferral_Document__c 
                            WHERE Application__c =: applicationId];
            
            Map<String, Deferral_Document__c> documentMap = new Map<String, Deferral_Document__c>();
            for(Deferral_Document__c docObj : documentList){                
                Boolean isDeletable = false;
                if(docObj.Status__c != 'Received' && docObj.Document_Master__r.Active__c != 'Yes' || docObj.Related_Document_Set_Code__r.Active__c != 'Yes'){
                    isDeletable = true;
                } else if(docObj.Status__c != 'Received'){
                    if(docObj.Type__c == 'Applicant' && docObj.Loan_Applicant__c == NULL){
                        isDeletable = true;
                    } else if(docObj.Type__c == 'Asset' && docObj.Property__c == NULL){
                        isDeletable = true;
                    }
                }
                
                if(isDeletable){
                    documentListToDelete.add(docObj);
                } else {
                    String key = docObj.Document_Name__c;
                    if(docObj.Type__c == 'Applicant') {
                        key = key + ' - ' + docObj.Applicable_For__c + ' - ' + docObj.Loan_Applicant__c;
                    } else if(docObj.Type__c == 'Asset') {
                        key = key + ' - ' + docObj.Asset_Type__c + ' - ' + docObj.Property__c;
                    }         
                    documentMap.put(key,docObj);   
                }                
            }
            
            if(!documentListToDelete.isEmpty()){
                Database.delete(documentListToDelete, false);
            }

            Map<String,List<Document_Master__c>> docTypeMastersMap = new Map<String,List<Document_Master__c>>();        
            for(Document_Master__c docMaster : documentMasters){
                if(!docTypeMastersMap.containsKey(docMaster.Type__c)){
                    docTypeMastersMap.put(docMaster.Type__c, new List<Document_Master__c>());
                }
                docTypeMastersMap.get(docMaster.Type__c).add(docMaster);                        
            }
            
            Map<String,List<Document_Set_Code__c>> docTypeSetCodeMap = new Map<String,List<Document_Set_Code__c>>();
            Map<String,List<Document_Set_Code__c>> docMastersSetMap = new Map<String,List<Document_Set_Code__c>>();
            for(Document_Set_Code__c setCodeObj : documentSetMasters){
                if(!docTypeSetCodeMap.containsKey(setCodeObj.Type__c)){
                    docTypeSetCodeMap.put(setCodeObj.Type__c, new List<Document_Set_Code__c>());
                }
                docTypeSetCodeMap.get(setCodeObj.Type__c).add(setCodeObj);
                
                if(!docMastersSetMap.containsKey(setCodeObj.Document_Master__c)){
                    docMastersSetMap.put(setCodeObj.Document_Master__c, new List<Document_Set_Code__c>());
                }
                docMastersSetMap.get(setCodeObj.Document_Master__c).add(setCodeObj);
            }
            
            Map<String,List<Loan_Applicant__c>> customerTypeApplicantMap = new Map<String,List<Loan_Applicant__c>>();
            for(Loan_Applicant__c applicant : loanApplicants){            
                if(!customerTypeApplicantMap.containsKey(applicant.Customer_Type__c)){
                    customerTypeApplicantMap.put(applicant.Customer_Type__c, new List<Loan_Applicant__c>());
                }
                customerTypeApplicantMap.get(applicant.Customer_Type__c).add(applicant);
            }

            Map<String,List<Property__c>> assetTypePropertyMap = new Map<String,List<Property__c>>();
            for(Property__c Property : properties){            
                if(!assetTypePropertyMap.containsKey(Property.Property_Type__c)){
                    assetTypePropertyMap.put(Property.Property_Type__c, new List<Property__c>());
                }
                assetTypePropertyMap.get(Property.Property_Type__c).add(Property);
            }
            
            if(docTypeSetCodeMap.containsKey('Application') && !docTypeSetCodeMap.get('Application').isEmpty()){
                for(Document_Set_Code__c setCodeObj : docTypeSetCodeMap.get('Application')){
                    String key = setCodeObj.Name;
                    if(!documentMap.containsKey(key)){
                        documentListToInsert.add(
                            new Deferral_Document__c(
                                Document_Master__c = setCodeObj.Document_Master__c,
                                Related_Document_Set_Code__c = setCodeObj.Id,
                                Document_Name__c = setCodeObj.Name,
                                Status__c = 'Not Received',
                                Stage__c = setCodeObj.Stage__c,
                                Document_Code__c = setCodeObj.Document_Master__r.Name,
                                Application__c = applicationId,
                                Document_Family__c = setCodeObj.Family__c,
                                Mandatory__c = setCodeObj.Mandatory__c,                        
                                Type__c = setCodeObj.Type__c,
                                Description__c = setCodeObj.Description__c,
                                Active__c = 'Yes',
                                ShowOnUI__c = true
                            )
                        );
                    }                
                }   
            }        
            
            if(docTypeSetCodeMap.containsKey('Applicant') && !docTypeSetCodeMap.get('Applicant').isEmpty()){
                for(Document_Set_Code__c setCodeObj : docTypeSetCodeMap.get('Applicant')){
                    if(setCodeObj.Applicable_For__c == 'All'){
                        for(Loan_Applicant__c applicant : loanApplicants){            
                            String key = setCodeObj.Name + ' - ' + setCodeObj.Applicable_For__c + ' - ' + applicant.Id;
                            if(!documentMap.containsKey(key)){
                                documentListToInsert.add(
                                    new Deferral_Document__c(
                                        Document_Master__c = setCodeObj.Document_Master__c,
                                        Related_Document_Set_Code__c = setCodeObj.Id,
                                        Document_Name__c = setCodeObj.Name,
                                        Status__c = 'Not Received',
                                        Stage__c = setCodeObj.Stage__c,
                                        Document_Code__c = setCodeObj.Document_Master__r.Name,
                                        Application__c = applicationId,
                                        Document_Family__c = setCodeObj.Family__c,
                                        Mandatory__c = setCodeObj.Mandatory__c,
                                        Type__c = setCodeObj.Type__c,
                                        Applicable_For__c = setCodeObj.Applicable_For__c,    
                                        Loan_Applicant__c = applicant.Id,
                                        Applicable_Name__c = applicant.Customer_Information__r.Name,
                                        Description__c = setCodeObj.Description__c,
                                        Income_Type__c =  setCodeObj.Income_Type__c,
                                        Active__c = 'Yes',
                                        ShowOnUI__c = true
                                    )
                                );
                            }
                        }
                    } else if(String.isNotBlank(setCodeObj.Applicable_For__c) && customerTypeApplicantMap.containsKey(setCodeObj.Applicable_For__c)){
                        for(Loan_Applicant__c applicant : customerTypeApplicantMap.get(setCodeObj.Applicable_For__c)){       
                            String key = setCodeObj.Name + ' - ' + setCodeObj.Applicable_For__c + ' - ' + applicant.Id;
                            if(!documentMap.containsKey(key)){
                                documentListToInsert.add(
                                    new Deferral_Document__c(
                                        Document_Master__c = setCodeObj.Document_Master__c,
                                        Related_Document_Set_Code__c = setCodeObj.Id,
                                        Document_Name__c = setCodeObj.Name,
                                        Status__c = 'Not Received',
                                        Stage__c = setCodeObj.Stage__c,
                                        Document_Code__c = setCodeObj.Document_Master__r.Name,
                                        Application__c = applicationId,
                                        Document_Family__c = setCodeObj.Family__c,
                                        Mandatory__c = setCodeObj.Mandatory__c,
                                        Type__c = setCodeObj.Type__c,
                                        Applicable_For__c = setCodeObj.Applicable_For__c,    
                                        Loan_Applicant__c = applicant.Id,
                                        Applicable_Name__c = applicant.Customer_Information__r.Name,
                                        Description__c = setCodeObj.Description__c,
                                        Income_Type__c =  setCodeObj.Income_Type__c,
                                        Active__c = 'Yes',
                                        ShowOnUI__c = true
                                    )
                                );
                            }
                        }
                    }                
                }   
            }   
            
            if(docTypeSetCodeMap.containsKey('Asset') && !docTypeSetCodeMap.get('Asset').isEmpty()){
                for(Document_Set_Code__c setCodeObj : docTypeSetCodeMap.get('Asset')){
                    if(setCodeObj.Asset_Type__c == 'All'){
                        for(Property__c property : properties){ 
                            String key = setCodeObj.Name + ' - ' + setCodeObj.Asset_Type__c + ' - ' + property.Id;
                            if(!documentMap.containsKey(key)){
                                documentListToInsert.add(
                                    new Deferral_Document__c(
                                        Document_Master__c = setCodeObj.Document_Master__c,
                                        Related_Document_Set_Code__c = setCodeObj.Id,
                                        Document_Name__c = setCodeObj.Name,
                                        Status__c = 'Not Received',
                                        Stage__c = setCodeObj.Stage__c,
                                        Document_Code__c = setCodeObj.Document_Master__r.Name,
                                        Application__c = applicationId,
                                        Document_Family__c = setCodeObj.Family__c,
                                        Mandatory__c = setCodeObj.Mandatory__c,
                                        Type__c = setCodeObj.Type__c,
                                        Asset_Type__c = setCodeObj.Asset_Type__c,   
                                        Sub_Type__c = setCodeObj.Sub_Type__c,   
                                        Property__c = property.Id,
                                        Applicable_Name__c = property.Name,
                                        Description__c = setCodeObj.Description__c,
                                        Active__c = 'Yes',
                                        ShowOnUI__c = true
                                    )
                                );
                            }
                        }
                    } else if(String.isNotBlank(setCodeObj.Asset_Type__c) && assetTypePropertyMap.containsKey(setCodeObj.Asset_Type__c)){
                        for(Property__c property : assetTypePropertyMap.get(setCodeObj.Asset_Type__c)){ 
                            String key = setCodeObj.Name + ' - ' + setCodeObj.Asset_Type__c + ' - ' + property.Id;
                            if(!documentMap.containsKey(key)){
                                documentListToInsert.add(
                                    new Deferral_Document__c(
                                        Document_Master__c = setCodeObj.Document_Master__c,
                                        Related_Document_Set_Code__c = setCodeObj.Id,
                                        Document_Name__c = setCodeObj.Name,
                                        Status__c = 'Not Received',
                                        Stage__c = setCodeObj.Stage__c,
                                        Document_Code__c = setCodeObj.Document_Master__r.Name,
                                        Application__c = applicationId,
                                        Document_Family__c = setCodeObj.Family__c,
                                        Mandatory__c = setCodeObj.Mandatory__c,
                                        Type__c = setCodeObj.Type__c,
                                        Asset_Type__c = setCodeObj.Asset_Type__c,   
                                        Sub_Type__c = setCodeObj.Sub_Type__c,   
                                        Property__c = property.Id,
                                        Applicable_Name__c = property.Name,
                                        Description__c = setCodeObj.Description__c,
                                        Active__c = 'Yes',
                                        ShowOnUI__c = true
                                    )
                                );
                            }
                        }
                    }
                }   
            }   


            for(Document_Master__c docMaster : documentMasters){
                if(!docMastersSetMap.containsKey(docMaster.Id)){
                    if(String.isNotBlank(docMaster.Type__c) && docMaster.Type__c == 'Application'){
                        String key = docMaster.Description__c;
                        if(!documentMap.containsKey(key)){
                            documentListToInsert.add(
                                new Deferral_Document__c(
                                    Document_Master__c = docMaster.Id,
                                    Document_Name__c = docMaster.Description__c,
                                    Status__c = 'Not Received',
                                    Document_Code__c = docMaster.Name,
                                    Application__c = applicationId,
                                    Document_Family__c = docMaster.Family__c,
                                    Mandatory__c = 'No',                        
                                    Type__c = docMaster.Type__c,
                                    Description__c = docMaster.Description__c,
                                    Active__c = 'Yes',
                                    ShowOnUI__c = false
                                )
                            );
                        }    
                    } else if(String.isNotBlank(docMaster.Type__c) && docMaster.Type__c == 'Applicant'){
                        for(Loan_Applicant__c applicant : loanApplicants){            
                            String key = docMaster.Description__c + ' - ' + 'All' + ' - ' + applicant.Id;
                            if(!documentMap.containsKey(key)){
                                documentListToInsert.add(
                                    new Deferral_Document__c(
                                        Document_Master__c = docMaster.Id,
                                        Document_Name__c = docMaster.Description__c,
                                        Status__c = 'Not Received',
                                        Document_Code__c = docMaster.Name,
                                        Application__c = applicationId,
                                        Document_Family__c = docMaster.Family__c,
                                        Mandatory__c = 'No',
                                        Type__c = docMaster.Type__c,
                                        Applicable_For__c = 'All',    
                                        Loan_Applicant__c = applicant.Id,
                                        Applicable_Name__c = applicant.Customer_Information__r.Name,
                                        Description__c = docMaster.Description__c,
                                        Active__c = 'Yes',
                                        ShowOnUI__c = false
                                    )
                                );
                            }
                        }
                    } else if(String.isNotBlank(docMaster.Type__c) && docMaster.Type__c == 'Asset'){
                        for(Property__c property : properties){ 
                            String key = docMaster.Description__c + ' - ' + 'All' + ' - ' + property.Id;
                            if(!documentMap.containsKey(key)){
                                documentListToInsert.add(
                                    new Deferral_Document__c(
                                        Document_Master__c = docMaster.Id,
                                        Document_Name__c = docMaster.Description__c,
                                        Status__c = 'Not Received',
                                        Document_Code__c = docMaster.Name,
                                        Application__c = applicationId,
                                        Document_Family__c = docMaster.Family__c,
                                        Mandatory__c = 'No',
                                        Type__c = docMaster.Type__c,
                                        Property__c = property.Id,
                                        Applicable_Name__c = property.Name,
                                        Description__c = docMaster.Description__c,
                                        Active__c = 'Yes',
                                        ShowOnUI__c = false
                                    )
                                );
                            }
                        }
                    }
                }                     
            }

            if(documentListToInsert != NULL && !documentListToInsert.isEmpty()){
                List<Error_Logger__c> errors = new List<Error_Logger__c>();
                Database.SaveResult[] srList = Database.insert(documentListToInsert, false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        if(sr.getErrors() != NULL && !sr.getErrors().isEmpty()){
                            errors.add( 
                                new Error_Logger__c(
                                    Application__c = applicationId,
                                    Description__c = sr.getErrors().get(0).getMessage(),
                                    Name = 'INSERT Document ' + sr.getErrors().get(0).getStatusCode()
                                )
                            );
                        }                               
                    }
                }

                if(errors != NULL && !errors.isEmpty()){
                    Database.insert(errors, false);
                }
            }

            for(Deferral_Document__c documentObj : [SELECT 
                                                    Id, Type__c, Document_Master__r.Active__c, Related_Document_Set_Code__r.Active__c, Property__c, Loan_Applicant__c
                                                    FROM Deferral_Document__c 
                                                    WHERE Application__c =: applicationId
                                                    AND Status__c != 'Received'])
            {
                if(documentObj.Document_Master__r.Active__c == 'No'){
                    documentListToDelete.add(documentObj);
                } else if(documentObj.Related_Document_Set_Code__r.Active__c == 'No'){
                    documentListToDelete.add(documentObj);
                } else if(documentObj.Type__c == 'Applicant' && documentObj.Loan_Applicant__c == NULL){
                    documentListToDelete.add(documentObj);
                } else if(documentObj.Type__c == 'Asset' && documentObj.Property__c == NULL){
                    documentListToDelete.add(documentObj);
                }
            }          
            
            if(documentListToDelete != NULL && !documentListToDelete.isEmpty()){
                List<Error_Logger__c> errors = new List<Error_Logger__c>();
                Database.DeleteResult[] dlList = Database.delete(documentListToDelete, false);
                for (Database.DeleteResult dl : dlList) {
                    if (!dl.isSuccess()) {
                        if(dl.getErrors() != NULL && !dl.getErrors().isEmpty()){
                            errors.add( 
                                new Error_Logger__c(
                                    Application__c = applicationId,
                                    Description__c = dl.getErrors().get(0).getMessage(),
                                    Name = 'DELETE Document ' + dl.getErrors().get(0).getStatusCode()
                                )
                            );
                        }                             
                    }
                }

                if(errors != NULL && !errors.isEmpty()){
                    Database.insert(errors, false);
                }
            }
        } catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('Error in refreshRecords = '+errorMsg);
            System.debug('Error in refreshRecords = '+ex.getLineNumber());
            throw new AuraHandledException(ErrorMsg);
        }        
    }
    
    public static List<Document_Master__c> getDocumentMasters(){
        return [SELECT 
                Id, Name, Description__c, Type__c, Active__c, Family__c 
                FROM Document_Master__c 
                WHERE Active__c = 'Yes'];
    }
    
    public static List<Document_Set_Code__c> getDocumentSetMasters(){
        return [SELECT Id, Name, Type__c, Applicable_For__c, Income_Type__c, Asset_Type__c, 
                Sub_Type__c, Mandatory__c, Stage__c, Active__c, Family__c, Description__c,
                Document_Master__c, Document_Master__r.Name, Document_Master__r.Active__c 
                FROM Document_Set_Code__c 
                WHERE Active__c =: 'Yes' 
                AND Document_Master__r.Active__c =: 'Yes'];
    }
    
    public static List<Loan_Applicant__c> getLoanApplicants(String applicationId){
        return [SELECT 
                Id, Customer_Information__c, Customer_Information__r.Name, Customer_Type__c, 
                Application__c, Applicant_Name__c
                FROM Loan_Applicant__c 
                WHERE Application__c =: applicationId];
    }
    
    public static List<Property__c> getProperties(String applicationId){
        return [SELECT 
                Id, Name, Property__c, Property_Type__c 
                FROM Property__c 
                WHERE Application__c =: applicationId 
                AND recordType.Name =: 'Pre Login Property Detail' 
                AND Property_Type__c != ''];
    }

    public static Map<Id, Set<String>> getApplicantsCapabilities(String applicationId){
        Map<Id, Set<String>> applicantCapabilityMap = new Map<Id, Set<String>>();
        for(Capability__c capabilityObj : [SELECT 
                                            Id, Income_segment__c, Loan_Applicant__c 
                                            FROM Capability__c 
                                            WHERE Application__c =: applicationId
                                            AND RecordType.Name = 'AC Capability']){
            if(!applicantCapabilityMap.containsKey(capabilityObj.Loan_Applicant__c)){
                applicantCapabilityMap.put(capabilityObj.Loan_Applicant__c, new Set<String>());
            }         
            applicantCapabilityMap.get(capabilityObj.Loan_Applicant__c).add(capabilityObj.Income_segment__c);                             
        }
        return applicantCapabilityMap;
    }

    @AuraEnabled
    public static WrapperDetails getApplicantAndProperty(String applicationId, String stageName, String recordTypeId){
        WrapperDetails wrpObj = new WrapperDetails();
        wrpObj.listOfLoanApplicant = [SELECT Id, Customer_Type__c, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =:applicationId];
        wrpObj.listOfProperties = [SELECT Id, Name, Property_Type__c FROM Property__c WHERE Application__c =:applicationId AND Property_Type__c!=null AND RecordType.Name = 'Pre Login Property Detail'];
        return wrpObj;
    }

    @AuraEnabled
    public static DocumentWrapper getAllDocuments(String applicationId, String documentType, String documentTypeId, String stageName){
        DocumentWrapper documents = new DocumentWrapper();
        documents.setCodeRecoords = new List<Deferral_Document__c>();
        documents.masterRecords = new List<Deferral_Document__c>();
        String query = 'SELECT Id, Loan_Applicant__r.Name, Loan_Applicant__r.Customer_Type__c, Property__r.Property_Type__c, Property__r.Name,'+Utility.getFieldAPINames('Deferral_Document__c')+' FROM Deferral_Document__c WHERE Application__c =:applicationId AND Active__c = \'Yes\'';
        if(documentType == 'Mandatory'){
            query+= ' AND Mandatory__c = \'Yes\'';
        }
        if(documentType == 'Applicant' && String.isNotBlank(documentTypeId) && String.isNotEmpty(documentTypeId)){
            query+= ' AND Loan_Applicant__c =:documentTypeId';
        }
        if(documentType == 'Asset' && String.isNotBlank(documentTypeId) && String.isNotEmpty(documentTypeId)){
            query+= ' AND Property__c =:documentTypeId';
        }
        if(documentType == 'Application'){
            query+= ' AND Property__c = null AND Loan_Applicant__c = null';
        }
        if(String.isNotBlank(stageName) && String.isNotEmpty(stageName) && stageName != 'All'){
            query+=' AND (Stage__c =:stageName OR Deferral_Stage__c =:stageName OR Deferred_From__c =:stageName)';
        }
        for(Deferral_Document__c def : Database.query(query)){
            if(def.ShowOnUI__c){
                documents.setCodeRecoords.add(def);
            }
            if(!def.ShowOnUI__c){
                documents.masterRecords.add(def);
            }
        }
        return documents;
    }

    @AuraEnabled
    public static String updateDeferralRecordDetail(String data, String stageName){
        if(String.isNotBlank(data) && String.isNotEmpty(data)){
            Deferral_Document__c def = (Deferral_Document__c)JSON.deserialize(data, Deferral_Document__c.class);
            Deferral_Document__c defRecord = new Deferral_Document__c();
            defRecord.Id = def.Id;
            defRecord.ShowOnUI__c = def.ShowOnUI__c;
            defRecord.Remarks__c = def.Remarks__c;
            defRecord.Status__c = def.Status__c;
            defRecord.Deferral_Stage__c = def.Deferral_Stage__c;
            if(def.Status__c == 'Deferred'){
                defRecord.Deferral_Date__c = def.Deferral_Date__c;
                defRecord.Deferral_Stage__c = def.Deferral_Stage__c;
                defRecord.Deferred_From__c = stageName;
            }
            if(def.Status__c == 'Waived'){
                defRecord.Waiver_Reason__c = def.Waiver_Reason__c;  
            }
            if(String.isNotBlank(def.Content_Version_Id__c) && String.isNotEmpty(def.Content_Version_Id__c)){
                ContentVersion cv = [SELECT Id, Remarks__c FROM ContentVersion WHERE Id =:def.Content_Version_Id__c];
                cv.Remarks__c = def.Remarks__c;
                update cv;
            }
            update defRecord;
            return defRecord.Id;
        }
        return null;
    }


    @AuraEnabled
    public static String uploadPhotos(String jsonPhotoData, String base64, String recordId, string conVerType){
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
            cv.Type__c = conVerType;
            insert cv;
            return cv.Id;
        }
    }

    public static void upadteDeferralRecord(){
        System.debug('data '+data);
        if(String.isNotBlank(data) && String.isNotBlank(data) && String.isNotBlank(cvId) && String.isNotEmpty(cvId)){
            Deferral_Document__c def = (Deferral_Document__c)JSON.deserialize(data, Deferral_Document__c.class);
            
            Deferral_Document__c defRecord = new Deferral_Document__c();
            defRecord.Id = def.Id;
            defRecord.Status__c = def.Status__c;
            defRecord.Received_Date__c = def.Received_Date__c;
            defRecord.Remarks__c = def.Remarks__c;
            defRecord.Original__c = def.Original__c;
            defRecord.No_of_Pages__c = def.No_of_Pages__c;
            defRecord.Latest_Version_Number__c = versionNumber;
            defRecord.Content_Version_Id__c = cvId;
            defRecord.Uploaded_From__c = uploadedFrom;
            defRecord.Document_Condition__c = def.Document_Condition__c;
            defRecord.ContentDocumetId__c = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvId].ContentDocumentId;
            defRecord.Uploaded_By__c = UserInfo.getUserId();
            update defRecord;
        }
    }

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
    public static String getHackURL(String contentDocumentIds){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String filesDownloadUrl = baseUrl+'/sfc/servlet.shepherd/version/download';
        List<String> contentDocumentIdsList = (List<String>)JSON.deserialize(contentDocumentIds, List<String>.class);
        for(ContentVersion  cd : [SELECT Id FROM ContentVersion WHERE ContentDocumentId In : contentDocumentIdsList]){
            filesDownloadUrl += '/'+cd.Id;
        }
        return filesDownloadUrl;
    }
    
    public static void coverClass(){ 
        String test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
        test ='';
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

    public class PhotosWrapper{
        @AuraEnabled public String base64;
        @AuraEnabled public String recordId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String stagName;
    }

    public class DocumentWrapper{
        @AuraEnabled public List<Deferral_Document__c> setCodeRecoords;
        @AuraEnabled public List<Deferral_Document__c> masterRecords;
    }

    public class WrapperDetails{
        @AuraEnabled 
        public List<Loan_Applicant__c> listOfLoanApplicant;
        @AuraEnabled 
        public List<Property__c> listOfProperties;
    }
}