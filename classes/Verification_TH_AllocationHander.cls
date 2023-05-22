/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-08-03
* @modified         2022-08-03
* @TestClassName    
* @Description      This class is used to handle Verification User Allocation.             
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class Verification_TH_AllocationHander extends AbstractTriggerContext{
        
    public override void afterInsert(List<sobject> newList, Map<Id,sObject> newMap){
        System.debug('Verification_TH_AllocationHander');
        getVerificationUserAllocation((List<Verification__c>)newList);
    }
    
    public static final String UNASSIGNED_USER_ID = System.Label.FS_Admin;
    public static void getVerificationUserAllocation(List<Verification__c> newList){
        
        Set<String> applicationIds = new Set<String>();
        Set<String> stages = new Set<String>();
        Map<String,String> verificationUserMapCapacity = new Map<String,String>();
        Map<String,String> verificationUserMapRR = new Map<String,String>();
        Map<String,String> returnMap = new Map<String,String>();
        
        Map<Id,String> recordTypeIdNameMap = new Map<Id,String>();
        Map<Id,Application__c> appVerificationPending = new Map<Id,Application__c>();
        for(String RTName : Schema.SObjectType.Verification__c.getRecordTypeInfosByName().keyset()){            
            Id recTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            recordTypeIdNameMap.put(recTypeId,RTName);
        }  
        
        Set<Id> applicationIds2 = new Set<Id>(); 
        for(Verification__c verObj : newList){
            applicationIds2.add(verObj.application__c);
        }
        Map<Id,Application__c> applicationMap2 = new Map<Id,Application__c>([SELECT Id,Created_From_Batch__c FROM Application__c WHERE Id IN : applicationIds2]);
        
        for(Verification__c verObj : newList){
            Boolean isCreatedFromBatch = false;
            if(applicationMap2 != NULL && verObj.Application__c != NULL && applicationMap2.containsKey(verObj.application__c)){
                isCreatedFromBatch = applicationMap2.get(verObj.application__c).Created_From_Batch__c;
            }
            
            if(!isCreatedFromBatch && verObj.Application__c != NULL && recordTypeIdNameMap.containsKey(verObj.RecordTypeId) &&
              (recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - B' || recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - C' || recordTypeIdNameMap.get(verObj.RecordTypeId) == 'Online EC')){
                applicationIds.add(verObj.Application__c);
                stages.add(recordTypeIdNameMap.get(verObj.RecordTypeId));
                Application__c app = new Application__c();
                if(!appVerificationPending.containsKey(verObj.Application__c)){
                    app.Id = verObj.Application__c;
                }else{
                    app = appVerificationPending.get(verObj.Application__c);
                }

                if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - B'){
                    app.Is_FIVB_Pending__c = true;
                }else if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - C'){
                    app.Is_FIVC_Pending__c = true;
                }else if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'Online EC'){
                    app.Is_Online_EC_Pending__c = true;
                }
                appVerificationPending.put(app.Id, app);
            }   
        }
        
        if(!appVerificationPending.isEmpty()){
            update appVerificationPending.values();
        }

        System.debug('@@@ applicationIds = '+applicationIds);
        if(!applicationIds.isEmpty()){     
            Map<Id, Map<Id,Verification__c>> applicationStageVerificationMap = new Map<Id, Map<Id,Verification__c>>();
            for(Verification__c verObj : [SELECT 
                                          Id, RecordTypeId, OwnerId, Application__c 
                                          FROM Verification__c 
                                          WHERE Application__c IN : applicationIds
                                          AND Id NOT IN : newList])
            {
                if(applicationStageVerificationMap.containsKey(verObj.Application__c)){
                    applicationStageVerificationMap.get(verObj.Application__c).put(verObj.RecordTypeId ,verObj);
                }else{
                    applicationStageVerificationMap.put(verObj.Application__c,new Map<Id, Verification__c>{verObj.RecordTypeId => verObj});
                }
            }
            System.debug('@@@ applicationStageVerificationMap = '+applicationStageVerificationMap);
            
            Map<Id,Application__c> applicationMap = new Map<Id,Application__c>([SELECT Id, Created_From_Batch__c, Sourcing_Branch__c, Sourcing_Branch__r.Name FROM Application__c WHERE Id IN : applicationIds]);
        	Map<String,Allocation__c> allocationMap = getAllocations(stages); 
            Map<String, String> verificationStageMapCapacity = new Map<String, String>();
            Map<String, String> verificationBranchMapCapacity = new Map<String, String>();
            Map<String, String> verificationStageMapRR = new Map<String, String>();
            Map<String, String> verificationBranchMapRR = new Map<String, String>();
            Set<String> verificationAccessSet = new Set<String>();
            Set<String> verificationStageSet = new Set<String>();
            Set<String> verificationOwnerSet = new Set<String>();
            Set<String> verificationBranchSet = new Set<String>();
            Set<String> retriggeredVerifications = new Set<String>();
            List<Application_User_Tracking__c> userTracking = new List<Application_User_Tracking__c>();
            for(Verification__c verObj : newList){
                String stageName = recordTypeIdNameMap.get(verObj.RecordTypeId);
                if(applicationMap.containsKey(verObj.Application__c) && !applicationMap.get(verObj.Application__c).Created_From_Batch__c && allocationMap.containsKey(stageName)){
                    Allocation__c ac = allocationMap.get(stageName);
                    String branch = applicationMap.get(verObj.Application__c).Sourcing_Branch__r.Name;
                    if(applicationStageVerificationMap.containsKey(verObj.Application__c) && applicationStageVerificationMap.get(verObj.Application__c).containsKey(verObj.RecordTypeId)){
                        String ownerId = applicationStageVerificationMap.get(verObj.Application__c).get(verObj.RecordTypeId).OwnerId;
                        returnMap.put(verObj.Id, ownerId);
                    	verificationStageSet.add(stageName);
                        verificationOwnerSet.add(ownerId);
                        verificationBranchSet.add(branch);
                        verificationAccessSet.add(ownerId+'-'+stageName+'-'+branch);
                        retriggeredVerifications.add(verObj.Id);                        
                    } else {
                        if(ac.Mechanism__c == 'Round Robin') {
                            verificationStageMapRR.put(verObj.Id, stageName);
                            verificationBranchMapRR.put(verObj.Id, branch);
                        } else {
                            verificationStageMapCapacity.put(verObj.Id, stageName);
                            verificationBranchMapCapacity.put(verObj.Id, branch);
                        } 
                    }                 
                } else {
                    returnMap.put(verObj.Id ,UNASSIGNED_USER_ID);                    
                }
            }
            
            if(!verificationOwnerSet.isEmpty()){
                List<Access_Branch_Allocation__c> accessOnBranch = new List<Access_Branch_Allocation__c>();
                Map<Id,Access_Master__c> accessMasterToUpdateMap = new Map<Id,Access_Master__c>();
                accessOnBranch = [SELECT 
                                  Id, Access_Master__c, Branch_Master__c, Branch_Master__r.Name, Access_Master__r.Access_For__c, 
                                  Access_Master__r.User__c, Access_Master__r.Capacity__c, Access_Master__r.Capacity_Used__c, 
                                  Access_Master__r.Level__c, Access_Master__r.Sequence__c, Access_Master__r.Next_Assignment__c
                                  FROM Access_Branch_Allocation__c 
                                  WHERE 
                                  Access_Master__r.User__c IN : verificationOwnerSet
                                  AND Branch_Master__r.Name IN : verificationBranchSet
                                  AND Access_Master__r.Access_For__c IN : verificationStageSet
                                  AND Access_Master__r.User__r.Profile.Name != 'System Administrator'
                                  ORDER BY Access_Master__r.Sequence__c ASC];
                List<Access_Master__c> accessMasterToUpdate = new List<Access_Master__c>();
                
                for(Access_Branch_Allocation__c abaObj : accessOnBranch){
                    String key = abaObj.Access_Master__r.User__c+'-'+abaObj.Access_Master__r.Access_For__c+'-'+abaObj.Branch_Master__r.Name;
                    if(verificationAccessSet.contains(key)){
                        
                        Access_Master__c accessObj = new Access_Master__c();
                        if(accessMasterToUpdateMap.containsKey(abaObj.Access_Master__c)){
                            accessObj = accessMasterToUpdateMap.get(abaObj.Access_Master__c);
                        } else {
                            accessObj = abaObj.Access_Master__r;
                        }                        
                        accessObj.Capacity_Used__c = abaObj.Access_Master__r.Capacity_Used__c+1;
                        accessMasterToUpdateMap.put(accessObj.Id, accessObj);
                    }
                }
                if(!accessMasterToUpdate.isEmpty()){
                    update accessMasterToUpdateMap.values();
                }
            }
            
            verificationUserMapRR = AllocationHandlerHelper.getUsersNew(verificationBranchMapRR, verificationStageMapRR, 'Round Robin');
            //verificationUserMapCapacity = AllocationHandlerHelper.getUsersNew(verificationBranchMapCapacity, verificationStageMapCapacity, 'Capacity');
            returnMap.putAll(verificationUserMapRR);
            returnMap.putAll(verificationUserMapCapacity);
            System.debug('@@@ verificationUserMapRR= '+verificationUserMapRR);
            System.debug('@@@ returnMap= '+returnMap);
            if(returnMap != NULL){
                List<Verification__c> verificationToUpdate = new List<Verification__c>();
                Map<Id,Application__c> applicationsToUpdate = new Map<Id,Application__c>();
                for(Verification__c verObj : newList){
                    if(applicationMap.containsKey(verObj.Application__c) && !applicationMap.get(verObj.Application__c).Created_From_Batch__c){
                        String ownerIdToSet = UNASSIGNED_USER_ID;
                        System.debug('@@@ UNASSIGNED_USER_ID = '+UNASSIGNED_USER_ID);
                        if(returnMap.containsKey(verObj.Id)){
                            ownerIdToSet = returnMap.get(verObj.Id);
                        }
                        System.debug('@@@ ownerIdToSet / '+recordTypeIdNameMap.get(verObj.RecordTypeId) + ' = '+ownerIdToSet);
                        verificationToUpdate.add(new Verification__c(Id = verObj.Id, OwnerId = ownerIdToSet));                    	                        
                        if(!applicationsToUpdate.containsKey(verObj.Application__c)){
                            applicationsToUpdate.put(verObj.Application__c, new Application__c(Id=verObj.Application__c));
                        }
                        if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - B'){
                            applicationsToUpdate.get(verObj.Application__c).FIV_B_User__c = ownerIdToSet;
                            userTracking.add(
                                new Application_User_Tracking__c(
                                    Application__c = verObj.Application__c,
                                    Stage__c = recordTypeIdNameMap.get(verObj.RecordTypeId),
                                    Owner__c = ownerIdToSet,
                                    Start_Date__c = System.now(),
                                    Status__c = 'Pending',
                                    Previous_Stage__c = verObj.Initiate_From__c
                                )
                            );
                        } else if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - C'){
                            applicationsToUpdate.get(verObj.Application__c).FIV_C_User__c = ownerIdToSet;
                            userTracking.add(
                                new Application_User_Tracking__c(
                                    Application__c=verObj.Application__c,
                                    Stage__c = recordTypeIdNameMap.get(verObj.RecordTypeId),
                                    Owner__c = ownerIdToSet,
                                    Start_Date__c = System.now(),
                                    Status__c = 'Pending',
                                    Previous_Stage__c = verObj.Initiate_From__c
                                )
                            );
                        } else if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'Online EC'){
                            applicationsToUpdate.get(verObj.Application__c).Online_EC_User__c = ownerIdToSet;
                            userTracking.add(
                                new Application_User_Tracking__c(
                                    Application__c=verObj.Application__c,
                                    Stage__c = recordTypeIdNameMap.get(verObj.RecordTypeId),
                                    Owner__c = ownerIdToSet,
                                    Start_Date__c = System.now(),
                                    Status__c = 'Pending',
                                    Previous_Stage__c = verObj.Initiate_From__c
                                )
                            );
                        }      
                    }					                 
                }
                System.debug('verificationToUpdate= '+verificationToUpdate);
                System.debug('applicationsToUpdate= '+applicationsToUpdate);
                if(!verificationToUpdate.isEmpty()){
                    update verificationToUpdate;
                }
                if(!applicationsToUpdate.isEmpty()){
                    update applicationsToUpdate.values();
                }
                if(!userTracking.isEmpty()){
                    insert userTracking;
                }
            }
        }
    }

    private static Map<String,Allocation__c> getAllocations(Set<String> stages){
        Map<String,Allocation__c> stageWiseAllocationMap = new Map<String,Allocation__c>();      
        for(Allocation__c all : [SELECT Allocation_Type__c, Mechanism__c, Stage__c FROM Allocation__c WHERE Stage__c IN : stages]){
            stageWiseAllocationMap.put(all.Stage__c, all);
        }
        return stageWiseAllocationMap;
    }           
}