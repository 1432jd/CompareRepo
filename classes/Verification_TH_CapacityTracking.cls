/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-08-03
* @modified         2022-08-03
* @TestClassName    
* @Description      This class is used to handle Verification User Capacity.             
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class Verification_TH_CapacityTracking extends AbstractTriggerContext{
    public override void afterUpdate(List<sobject> newList, List<sobject> oldList, Map<Id,sObject> newMap, Map<Id,sObject> oldMap){
		System.debug('Verification_TH_CapacityTracking');
        updateCapacityOnComplete((List<Verification__c>)newList,(Map<Id,Verification__c>) oldMap);
    }
    
    public static void updateCapacityOnComplete(List<Verification__c> newList, Map<Id,Verification__c> oldMap){
        Map<Id,String> recordTypeIdNameMap = new Map<Id,String>();
        for(String RTName : Schema.SObjectType.Verification__c.getRecordTypeInfosByName().keyset()){            
            Id recTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
            recordTypeIdNameMap.put(recTypeId,RTName);
        }  
		System.debug('recordTypeIdNameMap ='+recordTypeIdNameMap);
        Set<String> applicationIds = new Set<String>();
        Set<String> verificationApplicationIds = new Set<String>();
        Map<Id,Application__c> appVerificationPending = new Map<Id,Application__c>();
        Map<String,Set<String>> applicationVerificationMap = new Map<String,Set<String>>();
        for(Verification__c verObj : newList){
            Verification__c oldObj = oldMap.get(verObj.Id);
            if(String.isNotBlank(verObj.Status__c) && verObj.Status__c.equalsIgnoreCase('Completed') && verObj.Status__c != oldObj.Status__c) {
                applicationIds.add(verObj.Application__c);
            }
            if(String.isNotBlank(verObj.Status__c) && verObj.Status__c.equalsIgnoreCase('Completed') && verObj.Status__c != oldObj.Status__c && 
                (recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - B' || recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - C' || recordTypeIdNameMap.get(verObj.RecordTypeId) == 'Online EC')) {
                //verificationApplicationIds.add(verObj.Application__c);
                if(!applicationVerificationMap.containsKey(verObj.Application__c)){
                    applicationVerificationMap.put(verObj.Application__c, new Set<String>());
                }
                applicationVerificationMap.get(verObj.Application__c).add(recordTypeIdNameMap.get(verObj.RecordTypeId));


                Application__c app = new Application__c();
                if(!appVerificationPending.containsKey(verObj.Application__c)){
                    app.Id = verObj.Application__c;
                }else{
                    app = appVerificationPending.get(verObj.Application__c);
                }
                if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - B'){
                    app.Is_FIVB_Pending__c = false;
                }else if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'FIV - C'){
                    app.Is_FIVC_Pending__c = false;
                }else if(recordTypeIdNameMap.get(verObj.RecordTypeId) == 'Online EC'){
                    app.Is_Online_EC_Pending__c = false;
                }
                appVerificationPending.put(app.Id, app);
            }
        }

        if(!appVerificationPending.isEmpty()){
            update appVerificationPending.values();
        }

        System.debug('applicationVerificationMap ='+applicationVerificationMap);
        if(!applicationVerificationMap.isEmpty()){
            List<Application_User_Tracking__c> historyList = new List<Application_User_Tracking__c>();
            historyList = [SELECT Id, End_Date__c, Stage__c, Status__c,Application__c FROM Application_User_Tracking__c WHERE Application__c = :applicationVerificationMap.keySet() AND Status__c = 'Pending' AND End_Date__c = NULL];
            System.debug('historyList ='+historyList);
            for(Application_User_Tracking__c aut : historyList){
                if(aut.Application__c != NULL && applicationVerificationMap.containsKey(aut.Application__c) && 
                    applicationVerificationMap.get(aut.Application__c).contains(aut.Stage__c)){
                    aut.End_Date__c = System.now();
                    aut.Status__c = 'Completed';
                }
            }
            
            if(!historyList.isEmpty()){
                update historyList;
            }
        }

		System.debug('applicationIds ='+applicationIds);
        if(!applicationIds.isEmpty()){
            System.debug('INSIDE applicationIds ='+applicationIds);
            Map<Id,Application__c> applicationMap = new Map<Id,Application__c>([SELECT Id, Created_From_BAtch__c, Sourcing_Branch__c FROM Application__c WHERE Id IN : applicationIds]);
           	System.debug('applicationMap ='+applicationMap);
            Set<String> branches = new Set<String>();
            Set<String> stages = new Set<String>();
            Set<String> owners = new Set<String>();
            Set<String> masterkeys = new Set<String>();
            for(Verification__c verObj : newList){
                String key = '';
                if(applicationMap.containsKey(verObj.Application__c) && !applicationMap.get(verObj.Application__c).Created_From_BAtch__c){
                    stages.add(recordTypeIdNameMap.get(verObj.RecordTypeId));
                    branches.add(applicationMap.get(verObj.Application__c).Sourcing_Branch__c);
                    owners.add(verObj.OwnerId);
                    key = recordTypeIdNameMap.get(verObj.RecordTypeId) + '-' + applicationMap.get(verObj.Application__c).Sourcing_Branch__c + '-' + verObj.OwnerId;
                    masterkeys.add(key);
                }
            }
			System.debug('branches ='+branches);
            if(!branches.isEmpty()){
                System.debug('INSIDE branches ='+branches);
                List<Access_Master__c> accessMasterToUpdate = new List<Access_Master__c>();
                Map<Id,Access_Master__c> accessMasterToUpdateMap = new Map<Id,Access_Master__c>();

                for(Access_Branch_Allocation__c abaObj : [SELECT 
                                                            Id, Access_Master__c, Branch_Master__c, Access_Master__r.Access_For__c, 
                                                            Access_Master__r.User__c, Access_Master__r.Capacity__c, Access_Master__r.Capacity_Used__c, 
                                                            Access_Master__r.Level__c, Access_Master__r.Sequence__c, Access_Master__r.Next_Assignment__c
                                                            FROM Access_Branch_Allocation__c 
                                                            WHERE 
                                                            Branch_Master__c IN : branches
                                                            AND Access_Master__r.Access_For__c IN : stages
                                                            AND Access_Master__r.User__c IN : owners
                                                            ORDER BY Access_Master__r.Sequence__c DESC])
                {
                    String key = abaObj.Access_Master__r.Access_For__c + '-' + abaObj.Branch_Master__c + '-' + abaObj.Access_Master__r.User__c;
                    if(masterkeys.contains(key)){
                        Access_Master__c accessObj = new Access_Master__c();
                        if(accessMasterToUpdateMap.containsKey(abaObj.Access_Master__c)){
                            accessObj = accessMasterToUpdateMap.get(abaObj.Access_Master__c);
                        } else {
                            accessObj = abaObj.Access_Master__r;
                        }
                        
                        accessObj.Capacity_Used__c = accessObj.Capacity_Used__c - 1;
                        accessMasterToUpdateMap.put(accessObj.Id, accessObj);
                    }
                }
				System.debug('accessMasterToUpdate ='+accessMasterToUpdate);
                if(!accessMasterToUpdateMap.isEmpty()){
                    update accessMasterToUpdateMap.values();
                }
            }
        }
    }
}