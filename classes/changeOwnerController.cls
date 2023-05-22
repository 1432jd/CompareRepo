public with sharing class changeOwnerController {
    
    @AuraEnabled
    public static List<Application_User_tracking__c> getPendingItems(String applicationId){
        return [SELECT Id, Owner__c, Stage__c, Type__c FROM Application_User_tracking__c WHERE Application__c =: applicationId AND Status__c =: 'Pending'];
    }

    @AuraEnabled
    public static List<User> getUsers(String applicationId, String stageName){
        List<User> returnList = new List<User>();
        if(stageName == 'Deviation'){
            stageName = 'Deviation Approval';
        }
        List<Application__c> applicationList = new List<Application__c>([SELECT Sourcing_Branch__c FROM Application__c WHERE Id =: applicationId]);
        if(!applicationList.isEmpty()){
            String sourcingBranch = applicationList[0].Sourcing_Branch__c;
            if(String.isNotEmpty(sourcingBranch)){
                Set<String> userIds = new Set<String>();
                for(Access_Branch_Allocation__c accuser : [SELECT Access_Master__r.User__c 
                                                            FROM Access_Branch_Allocation__c
                                                            WHERE Branch_Master__c =: sourcingBranch
                                                            AND Access_Master__r.Access_For__c =: stageName ]){
                    userIds.add(accuser.Access_Master__r.User__c);
                }
                if(!userIds.isEmpty()){
                    returnList = [SELECT Id, Name FROM User WHERE Id IN : userIds];
                }
            }
        }
        return returnList;
    }
    
    @AuraEnabled
    public static String changeOwner(sObject applicationRecord, sObject historyRecord){
        try{
            update applicationRecord;
            update historyRecord;    
            return 'Owner Updated Successfully!';
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}