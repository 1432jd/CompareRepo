public without sharing class FsGenericDocumentUploadLWCController {
    @AuraEnabled
    public static WrapperDetails getApplicantAndProperty(String applicationId, String stageName, String recordTypeId){
        WrapperDetails wrpObj = new WrapperDetails();
        wrpObj.listOfLoanApplicant = [SELECT Id, Customer_Type__c, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =:applicationId];
        wrpObj.listOfProperties = [SELECT Id, Name, Property_Type__c FROM Property__c WHERE Application__c =:applicationId AND Property_Type__c!=null AND RecordTypeId =:recordTypeId];
        return wrpObj;
    }

    @AuraEnabled
    public static DocumentWrapper getAllDocuments(String applicationId, String documentType, String documentTypeId, String stageName){
        DocumentWrapper documents = new DocumentWrapper();
        documents.setCodeRecoords = new List<Deferral_Document__c>();
        documents.masterRecords = new List<Deferral_Document__c>();
        String query = 'SELECT Id, Loan_Applicant__r.Name, Loan_Applicant__r.Customer_Type__c, Property__r.Property_Type__c,'+Utility.getFieldAPINames('Deferral_Document__c')+' FROM Deferral_Document__c WHERE Application__c =:applicationId AND Active__c = \'Yes\'';
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
        if(String.isNotBlank(stageName) && String.isNotEmpty(stageName)){
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

    public class WrapperDetails{
        @AuraEnabled 
        public List<Loan_Applicant__c> listOfLoanApplicant;
        @AuraEnabled 
        public List<Property__c> listOfProperties;
    }

    public class DocumentWrapper{
        @AuraEnabled public List<Deferral_Document__c> setCodeRecoords;
        @AuraEnabled public List<Deferral_Document__c> masterRecords;
    }
}