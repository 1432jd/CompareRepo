public without sharing class AccessBranchAllocation_TH_ManageBranch extends AbstractTriggerContext {
    public override void afterInsert(List<sobject> newList, Map<Id,sObject> newMap){   
        createBranchAccess((List<Access_Branch_Allocation__c>) newList);
    }

    public override void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap){   
        removeBranchAccess((List<Access_Branch_Allocation__c>) oldList);
    }

    public static void createBranchAccess(List<Access_Branch_Allocation__c> newList){
        Set<Id> branches = new Set<Id>();
        for(Access_Branch_Allocation__c acaObj : newList){
            if(acaObj.Branch_Master__c != NULL){
                branches.add(acaObj.Branch_Master__c);
            }
        }

        if(!branches.isEmpty()){
            Map<Id,Set<Id>> parentChildBranchMap = new Map<Id,Set<Id>>();
            for(Branch_Master__c bm : [SELECT Id, Master_Branch__c FROM Branch_Master__c WHERE Master_Branch__c IN : branches]){
                if(!parentChildBranchMap.containsKey(bm.Master_Branch__c)){
                    parentChildBranchMap.put(bm.Master_Branch__c,new Set<Id>());
                }
                parentChildBranchMap.get(bm.Master_Branch__c).add(bm.Id);
            }

            List<Access_Branch_Allocation__c> BranchAccessToInsert = new List<Access_Branch_Allocation__c>();
            for(Access_Branch_Allocation__c acaObj : newList){
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
                System.debug('BranchAccessToInsert.size() = '+BranchAccessToInsert.size());
                Database.insert(BranchAccessToInsert, false);
            }
        }
    }    

    public static void removeBranchAccess(List<Access_Branch_Allocation__c> newList){
        Set<Id> branches = new Set<Id>();
        Map<Id,Set<Id>> accessBranchMap = new Map<Id,Set<Id>>();
        for(Access_Branch_Allocation__c acaObj : newList){
            if(acaObj.Branch_Master__c != NULL && acaObj.Access_Master__c != NULL){
                branches.add(acaObj.Branch_Master__c);
                if(!accessBranchMap.containsKey(acaObj.Access_Master__c)){
                    accessBranchMap.put(acaObj.Access_Master__c, new Set<Id>());
                }
                accessBranchMap.get(acaObj.Access_Master__c).add(acaObj.Branch_Master__c);
            }
        }
        if(!accessBranchMap.isEmpty()){            
            List<Access_Branch_Allocation__c> BranchAccessToDelete = new List<Access_Branch_Allocation__c>();
            Set<Id> recordsToDelete = new Set<Id>();
            for(Access_Branch_Allocation__c acaObj : [SELECT 
                                                    Id, Access_Master__c, Branch_Master__c, Branch_Master__r.Master_Branch__c 
                                                    FROM Access_Branch_Allocation__c
                                                    WHERE Access_Master__c IN : accessBranchMap.keySet()
                                                    AND Branch_Master__r.Master_Branch__c IN : branches]){
                if(accessBranchMap.containsKey(acaObj.Access_Master__c) && accessBranchMap.get(acaObj.Access_Master__c).contains(acaObj.Branch_Master__r.Master_Branch__c)){
                    recordsToDelete.add(acaObj.Id);
                }                
            }

            if(!recordsToDelete.isEmpty()){
                Database.delete(new List<Id>(recordsToDelete),false);
            }
        }
    }
}