/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-07-30
* @modified         2022-08-01
* @TestClassName    public without sharing class AllocationHandlerHelper {
Test
* @Description      This class is used to handle allocation logic as per branch, access and etc.s            
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class AllocationHandlerHelper {
    public static Map<String,Map<String,String>> applicationStageOwnerMap = new Map<String,Map<String,String>>();
    public static Map<String,String> getUsersNew(Map<String,String> branches, Map<String,String> stages, String mechanism){
        System.debug('branches = '+branches);
        System.debug('stages = '+stages);
        checkPreviousAllocation(stages.keySet());
        Map<String,String> userAssignmentMap = new Map<String,String>();
        Set<String> accessMasterIds = new Set<String>();
        Map<String,List<Access_Master__c>> accessMasterMap = new Map<String,List<Access_Master__c>>();
        List<Access_Branch_Allocation__c> accessOnBranch = new List<Access_Branch_Allocation__c>();
        accessOnBranch = [SELECT 
                        Id, Access_Master__c, Branch_Master__c, Branch_Master__r.Name, Access_Master__r.Access_For__c, 
                        Access_Master__r.User__c, Access_Master__r.Capacity__c, Access_Master__r.Capacity_Used__c, 
                        Access_Master__r.Level__c, Access_Master__r.Sequence__c, Access_Master__r.Next_Assignment__c
                        FROM Access_Branch_Allocation__c 
                        WHERE 
                        Branch_Master__r.Name IN : branches.values() 
                        AND Access_Master__r.User__r.Profile.Name != 'System Administrator'
                        AND Access_Master__r.Access_For__c IN : stages.values()
                        ORDER BY Access_Master__r.Sequence__c ASC];
        System.debug('accessOnBranch = '+accessOnBranch);
        Map<Id, Access_Master__c> userAccessMap = new Map<Id, Access_Master__c>();
        for(Access_Branch_Allocation__c abaObj : accessOnBranch){
            accessMasterIds.add(abaObj.Access_Master__c);
            String key = abaObj.Access_Master__r.Access_For__c + '-' + abaObj.Branch_Master__r.Name;
            System.debug('key = '+key);
            if(!accessMasterMap.containsKey(key)){
                accessMasterMap.put(key, new List<Access_Master__c>());
            }
            accessMasterMap.get(key).add(abaObj.Access_Master__r);
            userAccessMap.put(abaObj.Access_Master__r.User__c, abaObj.Access_Master__r);
        }
        System.debug('accessMasterMap = '+accessMasterMap);
        System.debug('userAccessMap = '+userAccessMap);
        // Above code will retrieve particural access on Branch for particular Users.
        for(String key : accessMasterMap.keyset()){
            Boolean allFalse = true;
            for(Access_Master__c am : accessMasterMap.get(key)){
                if(am.Next_ASsignment__c){
                    allFalse = false;
                }
            }
            if(allFalse && !accessMasterMap.get(key).isEmpty()){
                accessMasterMap.get(key).get(0).Next_ASsignment__c = true;
            }
        }
        System.debug('accessMasterMap 22= '+accessMasterMap);
        if(String.isNotBlank(mechanism) && mechanism.equalsIgnoreCase('Capacity')){
            userAssignmentMap = capacityBaseAssignment(branches, stages, accessMasterMap);
        } else if(String.isNotBlank(mechanism) && mechanism.equalsIgnoreCase('Round Robin')){
            userAssignmentMap = roundRobinAssignment(branches, stages, accessMasterMap);
        }
        System.debug('userAssignmentMap = '+userAssignmentMap);
        return userAssignmentMap;
    }

    public static Map<String,String> roundRobinAssignment(Map<String,String> branches, Map<String,String> stages, Map<String,List<Access_Master__c>> accessMasterMap){        
        Map<String,String> userAssignmentMap = new Map<String,String>();
        Map<Id, Access_Master__c> updateableRecords = new Map<Id, Access_Master__c>();
        Map<String,Allocation__c> stageWiseAllocationMap = getAllocations();      
        for(String appId : branches.keyset()){
            String appStage = stages.get(appId);
            String key = stages.get(appId) + '-' + branches.get(appId);
            Allocation__c allocationObj = stageWiseAllocationMap.get(appStage);
            System.debug('key = '+key);            

            System.debug('Contains key = '+accessMasterMap.containsKey(key));
            List<Access_Master__c> accessMasters = new List<Access_Master__c>();
            if(accessMasterMap.containsKey(key)){
                accessMasters = accessMasterMap.get(key);
            }
            System.debug('accessMasters records = '+accessMasters);
            Integer nextAssignmentIndex; 
            for(Integer index = 0; index < accessMasters.size(); index++){     
                Access_Master__c accessObj = accessMasters.get(index);
                if(allocationObj.Include_For__c != NULL && String.isNotBlank(appStage)) {
                    if(applicationStageOwnerMap != NULL && applicationStageOwnerMap.containsKey(appId) && applicationStageOwnerMap.get(appId).containsKey(appStage)){
                        String userId = applicationStageOwnerMap.get(appId).get(appStage);
                        userAssignmentMap.put(appId, userId);
                    }
                } else if(allocationObj.Exclude_For__c != NULL) {
                    if(accessObj.Next_Assignment__c){  
                        accessObj.Next_Assignment__c = false;
                        if(applicationStageOwnerMap == NULL || !applicationStageOwnerMap.containsKey(appId) || !applicationStageOwnerMap.get(appId).containsKey(appStage) || applicationStageOwnerMap.get(appId).get(appStage) != accessObj.User__c){                                                                
                            accessObj.Capacity_Used__c = accessObj.Capacity_Used__c + 1;
                            userAssignmentMap.put(appId,accessObj.User__c);                            
                        }
                        nextAssignmentIndex = index+1;
                        if(accessMasters.size() == nextAssignmentIndex){                                        
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
                        userAssignmentMap.put(appId,accessObj.User__c);
                        nextAssignmentIndex = index+1;
                        if(accessMasters.size() == nextAssignmentIndex){                                        
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
        }
        update updateableRecords.values();
        return userAssignmentMap;
    }

    public static Map<String,String> capacityBaseAssignment(Map<String,String> branches, Map<String,String> stages, Map<String,List<Access_Master__c>> accessMasterMap){
        Map<String,String> userAssignmentMap = new Map<String,String>();
        Map<Id, Access_Master__c> updateableRecords = new Map<Id, Access_Master__c>();
        for(String appId : branches.keyset()){
            String key = stages.get(appId) + '-' + branches.get(appId);
            List<Access_Master__c> accessMasters = new List<Access_Master__c>();
            if(accessMasterMap.containsKey(key)){
                accessMasters = accessMasterMap.get(key);
            }
            Integer nextAssignmentIndex;
            for(Integer index = 0; index < accessMasters.size(); index++){     
                Access_Master__c accessObj = accessMasters.get(index);
                if(accessObj.Next_Assignment__c && accessObj.Capacity_Used__c < accessObj.Capacity__c){                                    
                    accessObj.Next_Assignment__c = false;
                    accessObj.Capacity_Used__c = accessObj.Capacity_Used__c + 1;
                    userAssignmentMap.put(appId,accessObj.User__c);
                    nextAssignmentIndex = index+1;
                    if(accessMasters.size() == nextAssignmentIndex){                                        
                        nextAssignmentIndex = 0;
                        index = -1;
                    }
                } else if(accessObj.Next_Assignment__c && accessObj.Capacity_Used__c >= accessObj.Capacity__c){       
                    accessObj.Next_Assignment__c = false;   
                    if(accessMasters.size() == index+1){
                        Access_Master__c nextUserAccessObj = accessMasters.get(0);    
                        nextUserAccessObj.Next_Assignment__c = true;  
                        index = -1;
                    } else{
                        Access_Master__c nextUserAccessObj = accessMasters.get(index+1);    
                        nextUserAccessObj.Next_Assignment__c = true;  
                    }
                }
    
                if(index == nextAssignmentIndex){                                    
                    accessObj.Next_Assignment__c = true;
                }

                updateableRecords.put(accessObj.Id, accessObj);
            }
        }
        update updateableRecords.values();
        return userAssignmentMap;
    }

    public static void checkPreviousAllocation(Set<String> appIds){
        applicationStageOwnerMap = new Map<String,Map<String,String>>();
        for(Application_User_Tracking__c aut : [SELECT Id, Application__c, Stage__c, Owner__c FROM Application_User_Tracking__c WHERE Application__c IN : appIds ORDER BY createdDate ASC]){
            if(applicationStageOwnerMap.containsKey(aut.Application__c)){
                applicationStageOwnerMap.get(aut.Application__c).put(aut.Stage__c,aut.Owner__c);
            }else{
                applicationStageOwnerMap.put(aut.Application__c,new Map<String,String>{aut.Stage__c => aut.Owner__c});
            }
        }
    }

    public static Map<String,Allocation__c> getAllocations(){
        Map<String,Allocation__c> stageWiseAllocationMap = new Map<String,Allocation__c>();      
        for(Allocation__c all : [SELECT Allocation_Type__c, Exclude_For__c, Include_For__c, Mechanism__c, Stage__c FROM Allocation__c]){
            stageWiseAllocationMap.put(all.Stage__c, all);
        }
        return stageWiseAllocationMap;
    }  
}