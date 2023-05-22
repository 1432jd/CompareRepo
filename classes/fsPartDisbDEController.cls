public without sharing class fsPartDisbDEController {

    @AuraEnabled
    public static String updateApptStageFromDE( String apptId){
        String msg = 'Success';
        try{

            List<Deferral_Document__c> listDeffDoc =  [SELECT Id,Name,Document_Name__c,Is_Deferral_Document__c,Deferral_Stage__c,Deferred_From__c FROM Deferral_Document__c WHERE Status__c = 'Deferred' AND Application__c =: apptId LIMIT 1];

            Application__c objAppt = new Application__c();
            objAppt.Id = apptId;
            objAppt.Stage__c = listDeffDoc.isEmpty() ? 'File Inward' : 'Document Deferral';
            objAppt.Disbursal_Author_Completion_Date__c = Date.today();
            update objAppt;
            
            msg = 'Success';

        }catch (Exception e) {
            msg = e.getMessage();
        }
        return msg;
    }
}