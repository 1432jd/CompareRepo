public class FS_PendingReasonController {
    @AuraEnabled
    public static List<Pending_Reason__c> getPendingReasonRecords(String applicationId, String stage){
        return [SELECT 
                Id, CreatedById, CreatedBy.Name, Pending_Reason__c, Pending_Remarks__c, 
                Query_Raised_Date__c, CreatedDate__c, Pending_Stage__c, Pending_Status__c
                FROM Pending_Reason__c 
                WHERE Application__c =:applicationId AND Pending_Stage__c =:stage];
    }

    @AuraEnabled
    public static Boolean getPendingReasonValidation(String applicationId, String stage){
        List<Pending_Reason__c> pendingReasons = [SELECT 
                                                Id, CreatedById, CreatedBy.Name, Pending_Reason__c, Pending_Remarks__c, 
                                                Query_Raised_Date__c, CreatedDate__c, Pending_Stage__c, Pending_Status__c
                                                FROM Pending_Reason__c 
                                                WHERE Application__c =:applicationId
                                                AND Pending_Stage__c =:stage
                                                AND Pending_Status__c = 'Not Resolved'];
        if(pendingReasons != NULL && !pendingReasons.isEmpty()){
            return true;
        }else {
            return false;
        }                                        
    }   

    //@12May2023 use to show the readonly data on pending reason grid
    @AuraEnabled
    public static List<Pending_Reason__c> getPendingReasonExceptAppCurrentStage(String applicationId, String stage){
        try{
            List<Pending_Reason__c> pendingReasons = new List<Pending_Reason__c>();
            pendingReasons = [SELECT 
            Id, CreatedById, CreatedBy.Name, Pending_Reason__c, Pending_Remarks__c, 
            Query_Raised_Date__c, CreatedDate__c, Pending_Stage__c, Pending_Status__c
            FROM Pending_Reason__c 
            WHERE Application__c =:applicationId
            AND Pending_Stage__c <> :stage]; 
            return pendingReasons;
        }catch( Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }                             
    }

    @AuraEnabled
    public static string savePendingReasonRecords(String jsonData){
        try {
            List<Pending_Reason__c> pendingReasons = new List<Pending_Reason__c>();
            pendingReasons =  (List<Pending_Reason__c>) System.JSON.deserialize(jsonData, List<Pending_Reason__c>.class);
            upsert pendingReasons;
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}