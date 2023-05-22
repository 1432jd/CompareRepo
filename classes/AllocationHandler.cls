public with sharing class AllocationHandler {
    
    public static final String UNASSIGNED_QUEUE_ID = System.Label.Pull_Queue_User; 

    public static Map<String,String> getApplicationUserAllocation(List<Application__c> records, String fieldName){
        Map<String,String> returnMap = new Map<String,String>();
        Set<String> stages = new Set<String>();
        Set<String> subStages = new Set<String>();
        Map<String, String> applicationStageMap = new Map<String, String>();
        Map<String, String> applicationSubStageMap = new Map<String, String>();
        Map<String, String> applicationBranchMap = new Map<String, String>();
        
        Set<String> branches = new Set<String>();
        for(Application__c app : records){
            if((app.Sourcing_Branch__c != NULL)){
                branches.add(app.Sourcing_Branch__c);
            }
        }        
        Map<Id,Branch_Master__c> branchMap = new Map<Id,Branch_Master__c>();
        
        if(!branches.isEmpty()){
            branchMap = new Map<Id,Branch_Master__c>([SELECT Id,Name FROM Branch_Master__c WHERE Id IN : branches]);
        }
        
        for(Application__c app : records){
            System.debug('Application Stage = '+ app.get(fieldName));
            stages.add((String)app.get(fieldName));
            applicationStageMap.put(app.Id, (String)app.get(fieldName));       
            if(app.Sourcing_Branch__c != NULL && branchMap.containsKey(app.Sourcing_Branch__c)){
                applicationBranchMap.put(app.Id, branchMap.get(app.Sourcing_Branch__c).Name);   
            }               
        }
        Map<String,Allocation__c> allocationMap = new Map<String,Allocation__c>();
        allocationMap = getAllocations(stages);   
        if(!allocationMap.isEmpty()){
            Map<String, String> applicationBranchMap_FINAL = new Map<String, String>();
            Map<String, String> applicationStageMap_FINAL = new Map<String, String>();

            for(String appId : applicationStageMap.keySet()){
                if(allocationMap.containsKey(applicationStageMap.get(appId))){
                    Allocation__c ac = allocationMap.get(applicationStageMap.get(appId));
                    if(ac.Allocation_Type__c == 'Push'){
                        applicationStageMap_FINAL.put(appId,applicationStageMap.get(appId));
                        applicationBranchMap_FINAL.put(appId,applicationBranchMap.get(appId));
                    } else {
                        returnMap.put(appId,UNASSIGNED_QUEUE_ID);
                    }
                }else{
                    returnMap.put(appId,UNASSIGNED_QUEUE_ID);
                }
            }

            //KULDEEP METHOD
            Map<String,String> applicationUserMap = AllocationHandlerHelper.getUsersNew(applicationBranchMap_FINAL, applicationStageMap_FINAL, 'Round Robin');
            if(applicationUserMap != NULL && !applicationUserMap.isEmpty()){
                returnMap.putAll(applicationUserMap);
            }
        }
        return returnMap;
    }
    
    public static Map<String,Allocation__c> getAllocations(Set<String> stages){
        Map<String,Allocation__c> stageWiseAllocationMap = new Map<String,Allocation__c>();      
        for(Allocation__c all : [SELECT Allocation_Type__c, Mechanism__c, Stage__c FROM Allocation__c WHERE Stage__c IN : stages]){
            stageWiseAllocationMap.put(all.Stage__c, all);
        }
        return stageWiseAllocationMap;
    }    
    
    public static List<User> getUserList(String Stage, String branchId){
        Set<String> userIds = new Set<String>();

        for(Access_Branch_Allocation__c aba : [SELECT Id, Access_Master__r.User__c 
                                                FROM Access_Branch_Allocation__c 
                                                WHERE Access_Master__r.Access_For__c =: Stage 
                                                AND Branch_Master__c =: branchId])
        {
            userIds.add(aba.Access_Master__r.User__c);
        }
        if(!userIds.isEmpty()){
            return [SELECT Id, Name FROM User WHERE Id IN : userIds];
        }
        return null;
    }

    public static Set<Id> getUserListByStage(String applicationId, String stage){  
        Set<Id> userIds = new Set<Id>();
        Application__c appObj = [SELECT Id, Sourcing_Branch__c FROM Application__c WHERE Id =: applicationId];
        Map<String,String> applicationStageOwnerMap = getApplicationHistoryMap(applicationId);
        Set<Id> accessMasterIds = new Set<Id>();
        for(Access_Branch_Allocation__c aba : [SELECT Id, Access_Master__c, Access_Master__r.User__c 
                                                FROM Access_Branch_Allocation__c 
                                                WHERE Access_Master__r.Access_For__c =: stage 
                                                AND Branch_Master__c =: appObj.Sourcing_Branch__c])
        {
            userIds.add(aba.Access_Master__r.User__c);
        }
        return userIds;
    }

    @AuraEnabled
    public static String roundRobinByStage(String applicationId, String stage){  
        List<Allocation__c> allocationType = [SELECT Allocation_Type__c, Exclude_For__c, Include_For__c, Mechanism__c, Stage__c FROM Allocation__c WHERE Stage__c =: stage];
        String UNASSIGNED_USER_ID = System.Label.FS_Admin;
        if(allocationType == NULL && !allocationType.isEmpty()){
            if(allocationType.get(0).Stage__c == stage && allocationType.get(0).Allocation_Type__c == 'Pull'){
                return UNASSIGNED_USER_ID;
            }else if(allocationType.get(0).Stage__c == stage && allocationType.get(0).Allocation_Type__c == 'Push'){
                Application__c appObj = [SELECT Id, Sourcing_Branch__c FROM Application__c WHERE Id =: applicationId];
                Map<String,String> applicationStageOwnerMap = getApplicationHistoryMap(applicationId);
                Set<Id> accessMasterIds = new Set<Id>();
                for(Access_Branch_Allocation__c aba : [SELECT Id, Access_Master__c 
                                                        FROM Access_Branch_Allocation__c 
                                                        WHERE Access_Master__r.Access_For__c =: stage 
                                                        AND Branch_Master__c =: appObj.Sourcing_Branch__c])
                {
                    accessMasterIds.add(aba.Access_Master__c);
                }

                if(!accessMasterIds.isEmpty()){
                    List<Access_Master__c> accessMasterList = new List<Access_Master__c>();
                    accessMasterList = [SELECT 
                                        Id, Next_Assignment__c, Capacity_Used__c, User__c
                                        FROM Access_Master__c WHERE Id IN : accessMasterIds];
                    
                    Boolean allFalse = false;
                    for(Access_Master__c acmMaster : accessMasterList){
                        if(acmMaster.Next_Assignment__c){
                            allFalse = true;
                        }
                    }       
                    if(!allFalse){
                        accessMasterList.get(0).Next_Assignment__c = true;
                    }     

                    String userId = '';
                    Map<Id, Access_Master__c> updateableRecords = new Map<Id, Access_Master__c>();
                    Integer nextAssignmentIndex;
                    for(Integer index = 0; index < accessMasterList.size(); index++){     
                        Access_Master__c accessObj = accessMasterList.get(index);
                        if(allocationType.get(0).Include_For__c != NULL && applicationStageOwnerMap != NULL && applicationStageOwnerMap.containsKey(allocationType.get(0).Include_For__c)) {
                            return applicationStageOwnerMap.get(allocationType.get(0).Include_For__c);
                        } else if(allocationType.get(0).Exclude_For__c != NULL) {
                            if(accessObj.Next_Assignment__c){
                                accessObj.Next_Assignment__c = false;
                                if(applicationStageOwnerMap == NULL || !applicationStageOwnerMap.containsKey(allocationType.get(0).Include_For__c) || applicationStageOwnerMap.get(allocationType.get(0).Include_For__c) != accessObj.User__c){                                                                
                                    accessObj.Capacity_Used__c = accessObj.Capacity_Used__c + 1;
                                    userId = accessObj.User__c;                    
                                }
                                nextAssignmentIndex = index+1;
                                if(accessMasterList.size() == nextAssignmentIndex){                                        
                                    nextAssignmentIndex = 0;
                                    index = -1;
                                }
                                if(index == nextAssignmentIndex){                                    
                                    accessObj.Next_Assignment__c = true;
                                }
                                updateableRecords.put(accessObj.Id, accessObj);
                            }
                        } else {
                            if(accessObj.Next_Assignment__c){                                    
                                accessObj.Next_Assignment__c = false;
                                accessObj.Capacity_Used__c = accessObj.Capacity_Used__c + 1;
                                userId = accessObj.User__c;
                                nextAssignmentIndex = index+1;
                                if(accessMasterList.size() == nextAssignmentIndex){                                        
                                    nextAssignmentIndex = 0;
                                    index = -1;
                                }
                            }
                            if(index == nextAssignmentIndex){                                    
                                accessObj.Next_Assignment__c = true;
                            }
                            updateableRecords.put(accessObj.Id, accessObj);
                        }                        
                    }
                    update updateableRecords.values();
                    return userId;
                }                              
            }             
            return UNASSIGNED_USER_ID; 
        }else {
            return UNASSIGNED_USER_ID;
        }        
    }

    public static Map<String,String> getApplicationHistoryMap(String appId){
        Map<String,String> applicationStageOwnerMap = new Map<String,String>();
        for(Application_User_Tracking__c aut : [SELECT Id, Stage__c, Owner__c FROM Application_User_Tracking__c WHERE Application__c =: appId ORDER BY CreatedDate ASC]){
            applicationStageOwnerMap.put(aut.Stage__c, aut.Owner__c);
        }
        return applicationStageOwnerMap;
    }
}