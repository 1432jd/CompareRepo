/*
		Date : 22/08/2022
		Author : Mo Arslan
		Description : This class is used to get all the Notes of an Application
*/

public class fsSendBackGridCtrl {
    @AuraEnabled
    public static List<SendBackWrapper> getNotes(String appId){

        List<SendBackWrapper> sendBackWrapperList = new List<SendBackWrapper>();

        for(Note noteObj: [SELECT Id, ParentId, Title, Body, CreatedDate FROM NOTE WHERE ParentId =:appId ORDER BY CreatedDate DESC]){
            SendBackWrapper sendBackWrapperObj = new SendBackWrapper();
            sendBackWrapperObj.noteObj = noteObj;
            if(noteObj.title.contains('FIV-C') || noteObj.title.contains('FIV-B') || noteObj.title.contains('Online EC'))
                sendBackWrapperObj.sourceType = 'Retrigger';
            else{
                sendBackWrapperObj.sourceType = 'Send Back';
            }
            sendBackWrapperList.add(sendBackWrapperObj);
        }
        return sendBackWrapperList;
    }

    public class SendBackWrapper{
        @AuraEnabled
        public Note noteObj;
        @AuraEnabled
        public String sourceType;
    }
    
     @AuraEnabled
    public static String updateStage(String appId, String stage){
        try {
            Application__c app = new Application__c(Id=appId,Stage__c=stage);
            update app;
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     @AuraEnabled
    public static String updateStageSubStage(String appId, String stage, String subStage){
        try {
            Application__c app = new Application__c(Id=appId,Stage__c=stage,Sub_Stage__c=subStage);
            update app;
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}