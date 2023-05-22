/*
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Mudit Saxena
* @modifiedBy       Mudit Saxena
* @created          2022-08-02
* @modified         2022-08-02
* @TestClassName    
* @Description      This clas is used as trigger handler on application for allocation.
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class Application_TH_Allocation extends AbstractTriggerContext {
    
    public static Map<String, Integer> stageLocationMap = new Map<String, Integer> {'Login' => 1,
        'FIV - B' => 2,
        'FIV - C' => 3,
        'Online EC' => 4,
        'Legal Opinion' => 5,
        'Lead Detail Maker' => 6,
        'Legal Approval' => 7,
        'Lead Detail Checker' => 8,
        'In Principle Sanction' => 9,
        'Awaiting Lead Details Completion' => 10,
        'Process Credit' => 11,
        'Approval Credit' => 12,
        'Awaiting Legal Approval' => 13,
        'Final Sanction' => 14,
        'Post Approval' => 15,
        'MOD Registration' => 16,
        'Agreement Execution' => 17,
        'Dispatch Pending' => 18,
        'DOS' => 19,
        'Document Receipt' => 20,
        'Awaiting DOS' => 21,
        'Disbursal Maker' => 22,
        'Disbursal Author' => 23,
        'Document Deferral' => 24,
        'File Inward' => 25,
        'VDC Maker' => 26,
        'VDC Checker' => 27,
        'Vendor Handoff' => 28,
        'Closed' => 29};
        
    public static final String UNASSIGNED_USER_ID = System.Label.Pull_Queue_User;
    
    public static Map<String,Boolean> sendBackCheckMap = new Map<String,Boolean>();
	public static Map<String,Map<String,String>> applicationStageOwnerMap = new Map<String,Map<String,String>>();
    public override void beforeUpdate(List<sobject> newList, List<sObject> oldList, Map<Id,sObject> newMap, Map<Id, sObject> oldMap){
       // List<Application__c> filteredRecord = filter((List<Application__c>)newList,(Map<Id,Application__c>)oldMap);
        sendBackCheckMap = new Map<String,Boolean>();
        applicationStageOwnerMap = new Map<String,Map<String,String>>();
        getApplicationUserAllocation((List<Application__c>)newList, (Map<Id,Application__c>)oldMap);
    }
    @TestVisible
    private static void getApplicationUserAllocation(List<Application__c> newRecords, Map<Id, Application__c> oldRecords){    
		System.debug('getApplicationUserAllocation called');
        Set<String> applicationIds = new Set<String>();
        Set<String> stages = new Set<String>();
        Set<String> subStages = new Set<String>();
        Set<String> subFlowStages = new Set<String>();
        Set<String> oldKeySet = new Set<String>();
        
        Map<Id,String> applicationStageMap = new Map<Id,String>();
        Map<Id,Map<String,String>> applicationStageMapNew = new Map<Id,Map<String,String>>();
        
        for(Application__c app : newRecords){
            Application__c oldApplication = oldRecords.get(app.Id);
            if(!app.Created_From_Batch__c && (String.isNotBlank(app.Stage__c) && !app.Stage__c.equalsIgnoreCase('Verification') && !app.Stage__c.equalsIgnoreCase('Pre Login Dedupe Exception') && !app.Stage__c.equalsIgnoreCase('Awaiting DOS') && 
                !app.Stage__c.equalsIgnoreCase('Awaiting Legal Approval') && !app.Stage__c.equalsIgnoreCase('Awaiting Lead Details Completion') && app.Stage__c != oldApplication.Stage__c)){
                if(!((app.Stage__c.equalsIgnoreCase('Approval Credit') && oldApplication.Stage__c.equalsIgnoreCase('Process Credit')))){ // || (app.Stage__c.equalsIgnoreCase('Disbursal Author') && oldApplication.Stage__c.equalsIgnoreCase('Disbursal Maker'))
             		stages.add(app.Stage__c);
                    applicationIds.add(app.Id);
                    oldKeySet.add(app.ownerId + '-' + app.Sourcing_Branch__c + '-' + oldApplication.Stage__c);       
                }
            }
            
            if(!app.Created_From_Batch__c && (String.isNotBlank(app.Stage__c) && !oldApplication.Stage__c.equalsIgnoreCase('Login') 
                && !oldApplication.Stage__c.equalsIgnoreCase('Verification') && app.Stage__c != oldApplication.Stage__c)){
                if(!applicationStageMapNew.containsKey(app.Id)){
                    applicationStageMapNew.put(app.Id, new Map<String,String>());  
                }
                if(stageLocationMap.get(oldApplication.Stage__c) < stageLocationMap.get(app.Stage__c)){
                    applicationStageMapNew.get(app.Id).put(oldApplication.Stage__c,'Completed');      
                }else{
                    applicationStageMapNew.get(app.Id).put(oldApplication.Stage__c,'Send Back');
                }
				oldKeySet.add(app.ownerId + '-' + app.Sourcing_Branch__c + '-' + oldApplication.Stage__c);     
            }
                       
            if(!app.Created_From_Batch__c && (String.isNotBlank(app.Sub_Stage__c) && String.isNotBlank(oldApplication.Sub_Stage__c) && app.Sub_Stage__c != oldApplication.Sub_Stage__c)){
				subStages.add(app.Sub_Stage__c);
                applicationIds.add(app.Id);                
                String subStageOwner = '';
                if(oldApplication.Sub_Stage__c.equalsIgnoreCase('Legal Opinion')){
                    subStageOwner = oldApplication.Legal_Opinion_User__c;
                }
				
				if(String.isNotBlank(subStageOwner)){
                    oldKeySet.add(subStageOwner + '-' + app.Sourcing_Branch__c + '-' + oldApplication.Sub_Stage__c);
                } 
				
				if(!applicationStageMapNew.containsKey(app.Id)){
                    applicationStageMapNew.put(app.Id, new Map<String,String>());  
                }
                if(stageLocationMap.get(oldApplication.Sub_Stage__c) < stageLocationMap.get(app.Sub_Stage__c)){
                    applicationStageMapNew.get(app.Id).put(oldApplication.Sub_Stage__c,'Completed');      
                }else{
                    applicationStageMapNew.get(app.Id).put(oldApplication.Sub_Stage__c,'Send Back');
                }
			} else if(!app.Created_From_Batch__c  && (String.isNotBlank(app.Sub_Stage__c) && String.isBlank(oldApplication.Sub_Stage__c) && app.Sub_Stage__c != oldApplication.Sub_Stage__c)){
				subStages.add(app.Sub_Stage__c);
                applicationIds.add(app.Id);    
			} else if(!app.Created_From_Batch__c && (String.isBlank(app.Sub_Stage__c) && String.isNotBlank(oldApplication.Sub_Stage__c) && app.Sub_Stage__c != oldApplication.Sub_Stage__c)){
				String subStageOwner = '';
                if(oldApplication.Sub_Stage__c.equalsIgnoreCase('Legal Approval')){
                    subStageOwner = oldApplication.Legal_Approval_User__c;
                }else if(oldApplication.Sub_Stage__c.equalsIgnoreCase('DOS')){
                    subStageOwner = oldApplication.DOS_User__c;
                }
                if(String.isNotBlank(subStageOwner)){
                    oldKeySet.add(subStageOwner + '-' + app.Sourcing_Branch__c + '-' + oldApplication.Sub_Stage__c);
                }    
                
                if(!applicationStageMapNew.containsKey(app.Id)){
                    applicationStageMapNew.put(app.Id, new Map<String,String>());  
                }
                if(oldApplication.Sub_Stage__c.equalsIgnoreCase('DOS') || oldApplication.Sub_Stage__c.equalsIgnoreCase('Legal Approval')){
                    applicationStageMapNew.get(app.Id).put(oldApplication.Sub_Stage__c,'Completed');      
                }else{
                    applicationStageMapNew.get(app.Id).put(oldApplication.Sub_Stage__c,'Send Back');
                }
			}	
			
			if(!app.Created_From_Batch__c && (String.isNotBlank(app.Sub_Flow__c) && String.isNotBlank(oldApplication.Sub_Flow__c) && app.Sub_Flow__c != oldApplication.Sub_Flow__c)){
				subFlowStages.add(app.Sub_Flow__c);
                applicationIds.add(app.Id);       
                String subStageOwner = '';
                if(oldApplication.Sub_Flow__c.equalsIgnoreCase('Lead Detail Maker')){
                    subStageOwner = oldApplication.Lead_Detail_Maker_User__c;
                }   
                if(String.isNotBlank(subStageOwner)){
                    oldKeySet.add(subStageOwner + '-' + app.Sourcing_Branch__c + '-' + oldApplication.Sub_Flow__c);
                } 
				
				if(!applicationStageMapNew.containsKey(app.Id)){
                    applicationStageMapNew.put(app.Id, new Map<String,String>());  
                }
                if(stageLocationMap.get(oldApplication.Sub_Flow__c) < stageLocationMap.get(app.Sub_Flow__c)){
                    applicationStageMapNew.get(app.Id).put(oldApplication.Sub_Flow__c,'Completed');      
                }else{
                    applicationStageMapNew.get(app.Id).put(oldApplication.Sub_Flow__c,'Send Back');
                }
			} else if(!app.Created_From_Batch__c  && (String.isNotBlank(app.Sub_Flow__c) && String.isBlank(oldApplication.Sub_Flow__c) && app.Sub_Flow__c != oldApplication.Sub_Flow__c)){
				subFlowStages.add(app.Sub_Flow__c);
                applicationIds.add(app.Id);    
			} else if(!app.Created_From_Batch__c && (String.isBlank(app.Sub_Flow__c) && String.isNotBlank(oldApplication.Sub_Flow__c) && app.Sub_Flow__c != oldApplication.Sub_Flow__c)){
				String subStageOwner = '';
                if(oldApplication.Sub_Flow__c.equalsIgnoreCase('Lead Detail Checker')){
                    subStageOwner = oldApplication.Lead_Detail_Checker_User__c;
                }
			
                if(String.isNotBlank(subStageOwner)){
                    oldKeySet.add(subStageOwner + '-' + app.Sourcing_Branch__c + '-' + oldApplication.Sub_Flow__c);
                }    
				applicationStageMapNew.put(app.Id,new Map<String,String>{oldApplication.Sub_Flow__c=>'Completed'}); 
			}	
        }
        System.debug('oldKeySet = '+oldKeySet);
                
        if(!oldKeySet.isEmpty()){
            updateAccessMaster(oldKeySet, 'deduct');
        }
        
        System.debug('applicationStageMap = '+applicationStageMap);
        System.debug('applicationStageMapNew = '+applicationStageMapNew);
        if(!applicationStageMapNew.isEmpty()){
            updateApplicationTracking(applicationStageMapNew);
        }
        
        System.debug('stages = '+stages);
        System.debug('subStages = '+subStages);
        System.debug('subFlowStages = '+subFlowStages);
        if(!stages.isEmpty()){
            Map<String, String> previousallocation = new Map<String, String>();
            checkPreviousAllocation(applicationIds,stages);
            System.debug('IN stages previousallocation = '+previousallocation);
            Map<String, String> allocation = new Map<String,String>();
            List<Application__c> finalAppList = new List<Application__c>();
            System.debug('applicationStageOwnerMap.isEmpty() = '+applicationStageOwnerMap.isEmpty());            
            for(Application__c app : newRecords){
                System.debug('applicationStageOwnerMap.containsKey(app.Id) = '+applicationStageOwnerMap.containsKey(app.Id));
                System.debug('applicationStageOwnerMap.get(app.Id) = '+applicationStageOwnerMap.get(app.Id));
                if(applicationStageOwnerMap == NULL || applicationStageOwnerMap.isEmpty() || !applicationStageOwnerMap.containsKey(app.Id) || !applicationStageOwnerMap.get(app.Id).containsKey(app.Stage__C)){
                    finalAppList.add(app);
                }
            }
            System.debug('IN stages finalAppList = '+finalAppList);
            if(!finalAppList.isEmpty()){
                allocation = AllocationHandler.getApplicationUserAllocation(finalAppList, 'Stage__c');
            }
            System.debug('IN stages allocation = '+allocation);
            Set<String> accessToUpdate = new Set<String>();
            List<Application_User_Tracking__c> userTracking = new List<Application_User_Tracking__c>();
            for(Application__c app : newRecords){
                Application__c oldApp = oldRecords.get(app.Id);
                if(applicationStageOwnerMap != NULL && !applicationStageOwnerMap.isEmpty() && applicationStageOwnerMap.containsKey(app.Id) && applicationStageOwnerMap.get(app.Id).containsKey(app.Stage__c)){                    
                    app.OwnerId = applicationStageOwnerMap.get(app.Id).get(app.Stage__c);
                    String status = (app.OwnerId == System.Label.Pull_Queue_User) ? 'Unassigned' : 'Pending';
                    userTracking.add(
                        new Application_User_Tracking__c(
                            Application__c=app.Id,
                            Stage__c=app.Stage__c,
                            Owner__c=app.OwnerId,
                            Start_Date__c = System.now(),
                            Status__c = status,
                            Previous_Stage__c= oldApp.Stage__c
                        )
                    );
                    accessToUpdate.add(app.OwnerId + '-' + app.Sourcing_Branch__c + '-' + app.Stage__c);
                }else if(!allocation.isEmpty() && allocation.containsKey(app.Id)){                
                    app.OwnerId = allocation.get(app.Id);
                    String status = app.OwnerId == System.Label.Pull_Queue_User ? 'Unassigned' : 'Pending';
                    userTracking.add(
                        new Application_User_Tracking__c(
                            Application__c=app.Id,
                            Stage__c=app.Stage__c,
                            Owner__c=app.OwnerId,
                            Start_Date__c = System.now(),
                            Status__c = 'Pending',
                            Previous_Stage__c= oldApp.Stage__c
                        )
                    );
                } else {
                    app.OwnerId = UNASSIGNED_USER_ID;
                    userTracking.add(
                        new Application_User_Tracking__c(
                            Application__c=app.Id,
                            Stage__c=app.Stage__c,
                            Owner__c=app.OwnerId,
                            Start_Date__c = System.now(),
                            Status__c = 'Unassigned',
                            Previous_Stage__c= oldApp.Stage__c
                        )
                    );
                }           
            }
            System.debug('IN stages userTracking = '+userTracking);
            
            if(!userTracking.isEmpty()){
                insert userTracking;
            }
            
            if(!accessToUpdate.isEmpty()){
                updateAccessMaster(accessToUpdate,'add');
            }
        }     
        if(!subStages.isEmpty()){
            Map<String, String> previousallocation = new Map<String, String>();
            checkPreviousAllocation(applicationIds,subStages);
            System.debug('IN subStages previousallocation = '+previousallocation);
            Map<String, String> allocation = new Map<String,String>();
            List<Application__c> finalAppList = new List<Application__c>();
            for(Application__c app : newRecords){
                if(applicationStageOwnerMap == NULL || applicationStageOwnerMap.isEmpty() || !applicationStageOwnerMap.containsKey(app.Id) || !applicationStageOwnerMap.get(app.Id).containsKey(app.Sub_Stage__C)){
                    finalAppList.add(app);
                }
            }
            System.debug('IN subStages finalAppList = '+finalAppList);
            if(!finalAppList.isEmpty()){
                allocation = AllocationHandler.getApplicationUserAllocation(finalAppList, 'Sub_Stage__c');
            }
            System.debug('IN subStages allocation = '+allocation);
            List<Application_User_Tracking__c> userTracking = new List<Application_User_Tracking__c>();
            Set<String> accessToUpdate = new Set<String>();
            for(Application__c app : newRecords){
                Application__c oldApp = oldRecords.get(app.Id);
                String newOwner;
                if(applicationStageOwnerMap != NULL && !applicationStageOwnerMap.isEmpty() && applicationStageOwnerMap.containsKey(app.Id) && applicationStageOwnerMap.get(app.Id).containsKey(app.Sub_Stage__c)){
                    newOwner = allocation.get(app.Id);
                    newOwner = applicationStageOwnerMap.get(app.Id).get(app.Sub_Stage__c);
                    accessToUpdate.add(newOwner + '-' + app.Sourcing_Branch__c + '-' + app.Sub_Stage__c);
                }else if(!allocation.isEmpty() && allocation.containsKey(app.Id)){                
                    newOwner = allocation.get(app.Id);
                    if(app.Sub_Stage__c.equalsIgnoreCase('Legal Opinion')){
                        app.Legal_Opinion_User__c = newOwner;
                    }else if(app.Sub_Stage__c.equalsIgnoreCase('Legal Approval')){
                        app.Legal_Approval_User__c = newOwner;
                    }else if(app.Sub_Stage__c.equalsIgnoreCase('DOS')){
                        app.DOS_User__c = newOwner;
                    }
                }      
                if(newOwner != NULL){
                    String status = newOwner == System.Label.Pull_Queue_User ? 'Unassigned' : 'Pending';
                    userTracking.add(
                        new Application_User_Tracking__c(
                            Application__c=app.Id,
                            Stage__c=app.Sub_Stage__c,
                            Owner__c=newOwner,
                            Start_Date__c = System.now(),
                            Status__c = status,
                            Previous_Stage__c = (String.isNotBlank(oldApp.Sub_Stage__c) ? oldApp.Sub_Stage__c : oldApp.Stage__c)
                        )
                    );
                }
            }
            System.debug('IN subStages userTracking = '+userTracking);
            if(!userTracking.isEmpty()){
                insert userTracking;
            }
            
            if(!accessToUpdate.isEmpty()){
                updateAccessMaster(accessToUpdate, 'add');
            }
        } 
        if(!subFlowStages.isEmpty()){
            Map<String, String> previousallocation = new Map<String, String>();
            checkPreviousAllocation(applicationIds, subFlowStages);
            System.debug('IN subStages previousallocation = '+previousallocation);
            Map<String, String> allocation = new Map<String,String>();
            List<Application__c> finalAppList = new List<Application__c>();
            for(Application__c app : newRecords){
                if(applicationStageOwnerMap == NULL || applicationStageOwnerMap.isEmpty() || !applicationStageOwnerMap.containsKey(app.Id) || !applicationStageOwnerMap.get(app.Id).containsKey(app.Sub_Flow__c)){
                    finalAppList.add(app);
                }
            }
            System.debug('IN subStages finalAppList = '+finalAppList);
            if(!finalAppList.isEmpty()){
                allocation = AllocationHandler.getApplicationUserAllocation(finalAppList, 'Sub_Flow__c');
            }
            System.debug('IN subStages allocation = '+allocation);
            List<Application_User_Tracking__c> userTracking = new List<Application_User_Tracking__c>();
            Set<String> accessToUpdate = new Set<String>();

            for(Application__c app : newRecords){
                Application__c oldApp = oldRecords.get(app.Id);
                String newOwner;
                if(applicationStageOwnerMap != NULL && !applicationStageOwnerMap.isEmpty() && applicationStageOwnerMap.containsKey(app.Id) && applicationStageOwnerMap.get(app.Id).containsKey(app.Sub_Flow__c)){
                    newOwner = allocation.get(app.Id);
                    newOwner = applicationStageOwnerMap.get(app.Id).get(app.Sub_Flow__c);
                    accessToUpdate.add(newOwner + '-' + app.Sourcing_Branch__c + '-' + app.Sub_Flow__c);
                }else if(!allocation.isEmpty() && allocation.containsKey(app.Id)){                
                    newOwner = allocation.get(app.Id);
                    if(app.Sub_Flow__c.equalsIgnoreCase('Lead Detail Maker')){
                        app.Lead_Detail_Maker_User__c = newOwner;
                    }else if(app.Sub_Flow__c.equalsIgnoreCase('Lead Detail Checker')){
                        app.Lead_Detail_Checker_User__c = newOwner;
                    }
                }      
                if(newOwner != NULL){
                    String status = newOwner == System.Label.Pull_Queue_User ? 'Unassigned' : 'Pending';
                    userTracking.add(
                        new Application_User_Tracking__c(
                            Application__c = app.Id,
                            Stage__c = app.Sub_Flow__c,
                            Owner__c = newOwner,
                            Start_Date__c = System.now(),
                            Status__c = status,
                            Previous_Stage__c = (String.isNotBlank(oldApp.Sub_Flow__c) ? oldApp.Sub_Flow__c : oldApp.Stage__c)
                        )
                    );
                }
            }
            System.debug('IN subStages userTracking = '+userTracking);
            if(!userTracking.isEmpty()){
                insert userTracking;
            }
            
            if(!accessToUpdate.isEmpty()){
                updateAccessMaster(accessToUpdate, 'add');
            }
        }
    }
    
    private static void updateApplicationTracking(Map<Id,Map<String,String>> applicationStageMap){
        List<Application_User_Tracking__c> historyList = new List<Application_User_Tracking__c>();
        historyList = [SELECT Id, End_Date__c, Stage__c, Status__c,Application__c FROM Application_User_Tracking__c WHERE Application__c = :applicationStageMap.keySet() AND Status__c = 'Pending' AND End_Date__c = NULL];
    	
        System.debug('historyList ='+historyList);
        for(Application_User_Tracking__c aut : historyList){
            if(aut.Application__c != NULL && applicationStageMap.containsKey(aut.Application__c) && 
               applicationStageMap.get(aut.Application__c).containsKey(aut.Stage__c)){
                   System.debug('Application Status = '+applicationStageMap.get(aut.Application__c).get(aut.Stage__c));
                   aut.End_Date__c = System.now();
                   aut.Status__c = applicationStageMap.get(aut.Application__c).get(aut.Stage__c);
               }
        }      
        if(!historyList.isEmpty()){
            update historyList;
        }
    }
    
    @TestVisible
    private static void checkPreviousAllocation(Set<String> appIds, Set<String> stages){
        applicationStageOwnerMap = new Map<String,Map<String,String>>();
        for(Application_User_Tracking__c aut : [SELECT Id, Application__c, Stage__c, Owner__c FROM Application_User_Tracking__c WHERE Application__c IN : appIds AND Stage__c IN : stages ORDER BY createdDate ASC]){
            if(applicationStageOwnerMap.containsKey(aut.Application__c)){
                applicationStageOwnerMap.get(aut.Application__c).put(aut.Stage__c,aut.Owner__c);
            }else{
                applicationStageOwnerMap.put(aut.Application__c,new Map<String,String>{aut.Stage__c => aut.Owner__c});
            }
        }
    }
    
    private static void updateAccessMaster(Set<String>keySet, String operation){
        Set<String> stages = new Set<String>();
        Set<String> Branches = new Set<String>();
        Set<String> owners = new Set<String>();
        for(String key : keySet){
            owners.add(key.split('-').get(0));
            Branches.add(key.split('-').get(1));
            stages.add(key.split('-').get(2));
        }
        
        if(!keySet.isEmpty()){
            List<Access_Branch_Allocation__c> accessOnBranch = new List<Access_Branch_Allocation__c>();
            accessOnBranch = [SELECT 
                              Id, Access_Master__c, Branch_Master__c, Branch_Master__r.Name, Access_Master__r.Access_For__c, 
                              Access_Master__r.User__c, Access_Master__r.Capacity__c, Access_Master__r.Capacity_Used__c, 
                              Access_Master__r.Level__c, Access_Master__r.Sequence__c, Access_Master__r.Next_Assignment__c
                              FROM Access_Branch_Allocation__c 
                              WHERE 
                              Access_Master__r.User__c IN : owners
                              AND Branch_Master__c IN : Branches
                              AND Access_Master__r.Access_For__c IN : stages
                              AND Access_Master__r.User__r.Profile.Name != 'System Administrator'
                              ORDER BY Access_Master__r.Sequence__c ASC];
            List<Access_Master__c> accessMasterToUpdate = new List<Access_Master__c>();
            Map<Id,Access_Master__c> accessMasterToUpdateMap = new Map<Id,Access_Master__c>();
            System.debug('updateAccessMaster accessOnBranch = '+accessOnBranch);                
            for(Access_Branch_Allocation__c abaObj : accessOnBranch){
                String key = abaObj.Access_Master__r.User__c+'-'+abaObj.Branch_Master__c+'-'+abaObj.Access_Master__r.Access_For__c;
                if(keySet.contains(key)){
                    Access_Master__c accessObj = new Access_Master__c();
                    if(accessMasterToUpdateMap.containsKey(abaObj.Access_Master__c)){
                        accessObj = accessMasterToUpdateMap.get(abaObj.Access_Master__c);
                    } else {
                        accessObj = abaObj.Access_Master__r;
                    }
                    
                    if (operation == 'add') {
                        accessObj.Capacity_Used__c = accessObj.Capacity_Used__c + 1;
                    } else {
                        accessObj.Capacity_Used__c = accessObj.Capacity_Used__c - 1;
                    }
                    
                    accessMasterToUpdateMap.put(accessObj.Id, accessObj);
                }
            }
            System.debug('updateAccessMaster accessMasterToUpdate = '+accessMasterToUpdate);
            if(!accessMasterToUpdateMap.isEmpty()){
                update accessMasterToUpdateMap.values();
            }
        }
    }
}