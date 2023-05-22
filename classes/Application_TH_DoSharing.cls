public without sharing class Application_TH_DoSharing extends AbstractTriggerContext {
    public override void afterUpdate(List<sobject> newList, List<sObject> oldList, Map<Id,sObject> newMap, Map<Id, sObject> oldMap){                
        assignApplications((List<Application__c>)newList, (Map<Id,Application__c>)oldMap, true);
    }

    public override void afterInsert(List<sobject> newList, Map<Id,sObject> newMap){   
        List<Application__c> selectedApplications = new List<Application__c>();
        for(Application__c app : (List<Application__c>)newList){
            if(!app.Created_From_Batch__c){
                selectedApplications.add(app); 
            }
        }
        if(!selectedApplications.isEMpty()){
            assignApplications((List<Application__c>)newList, null, false);
        }		        
    }

    public static void assignApplications(List<Application__c> newList, Map<Id, Application__c> oldMap, Boolean isUpdate){
        List<Application__c> selectedApplications = new List<Application__c>();
        Map<String, String> oldBrancheApplicationMap = new Map<String, String>();
        Map<String, String> newBrancheApplicationMap = new Map<String, String>();
        for(Application__c application : newList){
            if(!application.Created_From_Batch__c && isUpdate && application.Sourcing_Branch__c != NULL && (oldMap.get(application.Id).Sourcing_Branch__c != application.Sourcing_Branch__c || oldMap.get(application.Id).OwnerId != application.OwnerId)){
                oldBrancheApplicationMap.put(application.Id, oldMap.get(application.Id).Sourcing_Branch__c);
                newBrancheApplicationMap.put(application.Id, application.Sourcing_Branch__c);
            } else if(!application.Created_From_Batch__c && !isUpdate && application.Sourcing_Branch__c != NULL){
                newBrancheApplicationMap.put(application.Id, application.Sourcing_Branch__c);
            }
        }

        if(!oldBrancheApplicationMap.isEmpty()){
            deletePermissions(oldBrancheApplicationMap);
        }
        System.debug('newBrancheApplicationMap= '+newBrancheApplicationMap);
        if(!newBrancheApplicationMap.isEmpty()){
            insertPermissions(newBrancheApplicationMap);
        }
    }

    public static void insertPermissions(Map<String, String> newBrancheApplicationMap){
        
        Map<Id,Set<Id>> userBranchMap = getUsers(newBrancheApplicationMap.values());
        List<Application__Share> applicationSharingList = new List<Application__Share>();
        for(String appId : newBrancheApplicationMap.keySet()){
            String branchId = newBrancheApplicationMap.get(appId);
            if(userBranchMap.containsKey(branchId) && !userBranchMap.get(branchId).isEmpty()){
                for(Id userId : userBranchMap.get(branchId)){
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
            Database.Insert(applicationSharingList,false);
        }
    }

    public static void deletePermissions(Map<String, String> oldBrancheApplicationMap){
        List<Application__Share> applicationSharingList = new List<Application__Share>();
        applicationSharingList = [SELECT Id FROM Application__Share WHERE ParentId IN : oldBrancheApplicationMap.keySet()];
        if(applicationSharingList != NULL && !applicationSharingList.isEmpty()){
            Database.delete(applicationSharingList,false);
        }
    }

    private static Map<Id,Set<Id>> getUsers(List<String> branches){
        Map<Id,Set<Id>> userBranchMap = new Map<Id,Set<Id>>();
        for(Access_Branch_Allocation__c access : [SELECT Id, Branch_Master__c, Access_Master__r.User__c, Access_Master__r.Level__c FROM Access_Branch_Allocation__c WHERE Branch_Master__c IN : branches]){
            if(!userBranchMap.containsKey(access.Branch_Master__c)){
                userBranchMap.put(access.Branch_Master__c, new Set<Id>());
            }
            userBranchMap.get(access.Branch_Master__c).add(access.Access_Master__r.User__c);
        }
        return userBranchMap;
    }
}