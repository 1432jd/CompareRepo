public without sharing class AccessBranchAllocation_TH_DoSharing extends AbstractTriggerContext {
    public override void beforeUpdate(List<sobject> newList, List<sObject> oldList, Map<Id,sObject> newMap, Map<Id, sObject> oldMap){                
        assignApplications((List<Access_Branch_Allocation__c>)newList, (Map<Id,Access_Branch_Allocation__c>)oldMap, true);
    }

    public override void beforeInsert(List<sobject> newList){   
        assignApplications((List<Access_Branch_Allocation__c>)newList, null, false);
    }

    public override void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap){   
        manageOldPermissions((List<Access_Branch_Allocation__c>)oldList);
    }

    public static void assignApplications(List<Access_Branch_Allocation__c> newList, Map<Id,Access_Branch_Allocation__c> oldMap, Boolean isUpdate){
        Set<String> branches = new Set<String>();
        Set<String> accesses = new Set<String>();

        Set<String> oldBranches = new Set<String>();
        for(Access_Branch_Allocation__c accessBranch : newList){
            if(isUpdate){
                Access_Branch_Allocation__c oldRecord = oldMap.get(accessBranch.Id);
                if(accessBranch.Access_Master__c != NULL && accessBranch.Branch_Master__c != NULL && accessBranch.Branch_Master__c != oldRecord.Branch_Master__c){
                    accesses.add(accessBranch.Access_Master__c);
                    branches.add(accessBranch.Branch_Master__c);
                    oldBranches.add(oldRecord.Branch_Master__c);
                }
            }else if(accessBranch.Access_Master__c != NULL && accessBranch.Branch_Master__c != NULL){
                accesses.add(accessBranch.Access_Master__c);
                branches.add(accessBranch.Branch_Master__c);
            }
        }

        Map<Id,Set<Id>> branchApplicationMap = new Map<Id,Set<Id>>();
        System.debug('oldBranches= '+oldBranches);
        if(!oldBranches.isEmpty()){
            deletePermissions(oldMap.values(), new List<String>(oldBranches), new List<String>(accesses));
        }
        System.debug('branches= '+branches);
        if(!branches.isEmpty()){
            Map<Id, Access_Master__c> accessMap = new Map<Id, Access_Master__c>([SELECT Id, User__c FROM Access_Master__c WHERE Id IN : accesses]);
            System.debug('accessMap= '+accessMap);
            branchApplicationMap = getApplications(new List<String>(branches));
            System.debug('branchApplicationMap= '+branchApplicationMap);
            List<Application__Share> applicationSharingList = new List<Application__Share>();
            for(Access_Branch_Allocation__c accessBranch : newList){
                if(accessMap.containsKey(accessBranch.Access_Master__c) && branchApplicationMap.containsKey(accessBranch.Branch_Master__c) && !branchApplicationMap.get(accessBranch.Branch_Master__c).isEmpty()){
                    String userId = accessMap.get(accessBranch.Access_Master__c).User__c;
                    for(String appId : branchApplicationMap.get(accessBranch.Branch_Master__c)){
                        Application__Share share = new Application__Share();
                        share.ParentId = appId;
                        share.UserOrGroupId = userId;                                              
                        share.AccessLevel = 'edit';
                        applicationSharingList.add(share);
                    }
                }
            }

            System.debug('applicationSharingList= '+applicationSharingList);
            if(!applicationSharingList.isEmpty()){
                Database.insert(applicationSharingList,false);
            }
        }
    }

    public static void manageOldPermissions(List<Access_Branch_Allocation__c> oldList){
        Set<String> branches = new Set<String>();
        Set<String> accesses = new Set<String>();
        for(Access_Branch_Allocation__c accessBranch : oldList){
            if(accessBranch.Access_Master__c != NULL && accessBranch.Branch_Master__c != NULL){
                accesses.add(accessBranch.Access_Master__c);
                branches.add(accessBranch.Branch_Master__c);
            }
        }

        System.debug('accesses= '+accesses);
        if(!accesses.isEmpty()){
            deletePermissions(oldList, new List<String>(branches), new List<String>(accesses));
        }
    }
	
    @TestVisible
    private static void deletePermissions(List<Access_Branch_Allocation__c> newList, List<String> branches, List<String> accesses){
        Map<Id, Access_Master__c> accessMap = new Map<Id, Access_Master__c>([SELECT Id, User__c FROM Access_Master__c WHERE Id IN : accesses]);
        Map<Id,Set<Id>> branchApplicationMap = new Map<Id,Set<Id>>();
        branchApplicationMap = getApplications(new List<String>(branches));
        Set<String> records = new Set<String>();
        Set<String> users = new Set<String>();
        Set<String> keys = new Set<String>();
        for(Access_Branch_Allocation__c accessBranch : newList){
            if(accessMap.containsKey(accessBranch.Access_Master__c) && branchApplicationMap.containsKey(accessBranch.Branch_Master__c) && !branchApplicationMap.get(accessBranch.Branch_Master__c).isEmpty()){
                String userId = accessMap.get(accessBranch.Access_Master__c).User__c;
                for(String appId : branchApplicationMap.get(accessBranch.Branch_Master__c)){
                    records.add(appId);
                    users.add(userId);
                    keys.add(appId + '-' + userId);
                }
            }
        }

        if(!users.isEmpty()){
            List<Application__Share> applicationSharingList = new List<Application__Share>();            
            for(Application__Share sharing : [SELECT Id, UserOrGroupId, ParentId FROM Application__Share WHERE ParentId IN : records AND UserOrGroupId IN : users]){
                String key = sharing.ParentId + '-' + sharing.UserOrGroupId;
                if(keys.contains(key)){
                    applicationSharingList.add(sharing);
                }
            }

            System.debug('applicationSharingList= '+applicationSharingList);
            if(!applicationSharingList.isEmpty()){
                Database.delete(applicationSharingList,false);
            }
        }
    }

    private static Map<Id,Set<Id>> getApplications(List<String> branches){
        Map<Id,Set<Id>> userBranchMap = new Map<Id,Set<Id>>();        
        for(Application__c application : [SELECT Id, Sourcing_Branch__c FROM Application__c WHERE Sourcing_Branch__c IN : branches AND Created_From_Batch__c=false]){
            if(!userBranchMap.containsKey(application.Sourcing_Branch__c)){
                userBranchMap.put(application.Sourcing_Branch__c, new Set<Id>());
            }
            userBranchMap.get(application.Sourcing_Branch__c).add(application.Id);
        }
        return userBranchMap;
    }
}