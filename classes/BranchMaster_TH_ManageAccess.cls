public without sharing class BranchMaster_TH_ManageAccess extends AbstractTriggerContext {
    
    public override void afterInsert(List<sobject> newList, Map<Id,sObject> newMap){   
        createBranchAccess((List<Branch_Master__c>)newList);
    }

    public override void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap){   
        removeBranchAccess((List<Branch_Master__c>) oldList);
    }

    public static void createBranchAccess(List<Branch_Master__c> newList){
        Set<Id> branches = new Set<Id>();
        Map<Id,Set<Id>> parentChildBranchMap = new Map<Id,Set<Id>>();
        for(Branch_Master__c bm : newList){
            if(bm.Master_Branch__c != NULL){
                branches.add(bm.Master_Branch__c);

                if(!parentChildBranchMap.containsKey(bm.Master_Branch__c)){
                    parentChildBranchMap.put(bm.Master_Branch__c,new Set<Id>());
                }
                parentChildBranchMap.get(bm.Master_Branch__c).add(bm.Id);
            }
        }
    
        if(!branches.isEmpty()){
            List<Access_Branch_Allocation__c> BranchAccessToInsert = new List<Access_Branch_Allocation__c>();
            for(Access_Branch_Allocation__c acaObj : [SELECT Id, Access_Master__c, Branch_Master__c FROM Access_Branch_Allocation__c WHERE Branch_Master__c IN : branches]){
                if(parentChildBranchMap.containsKey(acaObj.Branch_Master__c)){
                    for(String newBranchId : parentChildBranchMap.get(acaObj.Branch_Master__c)){
                        Access_Branch_Allocation__c acaObjNew = new  Access_Branch_Allocation__c();
                        acaObjNew.Branch_Master__c = newBranchId;
                        acaObjNew.Access_Master__c = acaObj.Access_Master__c;
                        BranchAccessToInsert.add(acaObjNew);
                    }
                }
            }

            if(!BranchAccessToInsert.isEmpty()){
                Database.insert(BranchAccessToInsert, false);
            }
        }
    }

    public static void removeBranchAccess(List<Branch_Master__c> newList){
        Set<Id> branches = new Set<Id>();
        Map<Id,Set<Id>> parentChildBranchMap = new Map<Id,Set<Id>>();
        for(Branch_Master__c bm : newList){
            branches.add(bm.Id);
        }

        List<Access_Branch_Allocation__c> BranchAccessToDelete = new List<Access_Branch_Allocation__c>();
        BranchAccessToDelete = [SELECT 
                                Id 
                                FROM Access_Branch_Allocation__c 
                                WHERE Branch_Master__r.Master_Branch__c IN : branches 
                                OR Branch_Master__c IN : branches];
        if(!BranchAccessToDelete.isEmpty()){
            Database.delete(BranchAccessToDelete, false);
        }                                
    }
}