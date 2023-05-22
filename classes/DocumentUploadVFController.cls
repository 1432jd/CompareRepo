public without sharing class DocumentUploadVFController {
    
    public static String docSetCodeId{get;set;}
    public static String currentStageName{get;set;}
    public static String prntId{get;set;}
    public static String cvType{get;set;}
    public static String deferalRecordId{get;set;}
    public static String documentName{get;set;}
    public static String data{get;set;}
    public static String cvId{get;set;}
    public static String versionNumber{get;set;}

    public static void deleteRecord(){   
        System.debug('docSetCodeId '+docSetCodeId +' currentStageName '+currentStageName +' prntId '+prntId +' cvType '+cvType);
        if(cvType == 'Applicant'){
            Delete [SELECT Id FROM Deferral_Document__c where Document_Set_Code__c =:docSetCodeId AND Uploaded_From__c =:currentStageName AND Current_Record_Id__c =:prntId];
        }
        if(cvType == 'Asset'){
            Delete [SELECT Id FROM Deferral_Document__c where Document_Set_Code__c =:docSetCodeId AND Uploaded_From__c =:currentStageName AND Current_Record_Id__c =:prntId];
        }
        if(cvType == 'Application'){
            Delete [SELECT Id FROM Deferral_Document__c where Document_Set_Code__c =:docSetCodeId AND Uploaded_From__c =:currentStageName AND Application__c =:prntId];
        }
    }
    
    public static void updateDefferalDocument(){
        
        System.debug('deferalRecordId '+deferalRecordId);
        Deferral_Document__c objDef = new Deferral_Document__c();
        objDef.Id = deferalRecordId;
        objDef.Is_Deferral_Document__c = false;
        objDef.Is_Document_Received__c = true;
        update objDef;
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
            update defRecord;
        }
    }
}