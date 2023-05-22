public without sharing class FS_ApplicationReassignmentController {

    @AuraEnabled
    public static List<ApplicationAssignmentWrapper> getPendingApplicationTasks(String applicationId){
        List<Application__c> applications = [SELECT 
                                            Id, Name, Sourcing_Branch__c, Sourcing_Branch__r.Name 
                                            FROM Application__c 
                                            WHERE Id =:applicationId LIMIT 1];

        List<Application_User_Tracking__c> autList = [SELECT 
                                                        Id, Name, Stage__c, Status__c, Owner__c, Owner__r.Name, Application__c, Previous_Stage__c,
                                                        Start_Date__c, Total_TAT_In_Days__c, Type__c 
                                                        FROM Application_User_Tracking__c 
                                                        WHERE Application__c =: applicationId 
                                                        AND Status__c = 'Pending'];
        List<ApplicationAssignmentWrapper> historyList = new List<ApplicationAssignmentWrapper>();
        if(autList != NULL && !autList.isEmpty()){
            Set<String> stages = new Set<String>();
            for(Application_User_Tracking__c autObj : autList){
                stages.add(autObj.Stage__c);
            }

            Map<String, List<DropdownValues>> userStageMap = new Map<String, List<DropdownValues>>();
            userStageMap = getUserMap(applications.get(0).Sourcing_Branch__c , stages);

            for(Application_User_Tracking__c autObj : autList){
                ApplicationAssignmentWrapper historyObj = new ApplicationAssignmentWrapper();
                historyObj.recordId = autObj.Id;
                historyObj.applicationNumber = applications.get(0).Name;
                historyObj.applicationId = autObj.Application__c;
                historyObj.stage = autObj.Stage__c;
                historyObj.branchName = applications.get(0).Sourcing_Branch__r.Name;
                historyObj.oldStage = autObj.Previous_Stage__c;
                historyObj.startDate = autObj.Start_Date__c;
                historyObj.timeInQueue = autObj.Total_TAT_In_Days__c;
                historyObj.historyType = autObj.Type__c;
                historyObj.ownerName = autObj.Owner__r.Name;
                historyObj.ownerId = autObj.Owner__c;

                if(userStageMap.containsKey(autObj.Stage__c)){
                    historyObj.userList = userStageMap.get(autObj.Stage__c);
                }
                historyList.add(historyObj);                
            }
        }        
        return historyList;        
    }

    @AuraEnabled
    public static String handleApplicationReassignment(String updatedListStr){
        try{
            List<ApplicationAssignmentWrapper> updatedList = (List<ApplicationAssignmentWrapper>) JSON.deserialize(updatedListStr, List<ApplicationAssignmentWrapper>.class);

            Map<Id,Application__c> applicationMap = new Map<Id,Application__c>();
            List<Application_User_Tracking__c> applicationTracking = new List<Application_User_Tracking__c>();

            Set<Id> applicationUserTrackingIds = new Set<Id>();
            for(ApplicationAssignmentWrapper historyObj: updatedList){
                applicationUserTrackingIds.add(historyObj.recordId);
            }

            Map<Id,Application_User_Tracking__c> historyMap = new Map<Id,Application_User_Tracking__c>([SELECT 
                                                                                                        Id, Application__c, Stage__c, 
                                                                                                        End_Date__c, Sub_Type__c, Owner__c, 
                                                                                                        Previous_Stage__c, Receipt__c, 
                                                                                                        Start_Date__c, Status__c, Type__c 
                                                                                                        FROM Application_User_Tracking__c 
                                                                                                        WHERE Id IN : applicationUserTrackingIds]);

            for(ApplicationAssignmentWrapper historyObj: updatedList){
                Application__c app = new Application__c();
                if(!applicationMap.containsKey(historyObj.applicationId)){
                    app.Id = historyObj.applicationId;
                }else{
                    app = applicationMap.get(historyObj.applicationId);
                }
                
                if(historyObj.stage == 'FIV - C'){
                    app.FIV_C_User__c = historyObj.ownerId;
                } else if(historyObj.stage == 'FIV - B'){
                    app.FIV_B_User__c = historyObj.ownerId;
                } else if(historyObj.stage == 'Online EC'){
                    app.Online_EC_User__c = historyObj.ownerId;
                } else if(historyObj.stage == 'Legal Opinion'){
                    app.Legal_Opinion_User__c = historyObj.ownerId;
                } else if(historyObj.stage == 'Legal Approval'){
                    app.Legal_Approval_User__c = historyObj.ownerId;
                } else if(historyObj.stage == 'DOS'){
                    app.DOS_User__c = historyObj.ownerId;
                } else if(historyObj.stage == 'Lead Detail Maker'){
                    app.Lead_Detail_Maker_User__c = historyObj.ownerId;
                } else if(historyObj.stage == 'Lead Detail Checker'){
                    app.Lead_Detail_Checker_User__c = historyObj.ownerId;
                }else {
                    app.OwnerId = historyObj.ownerId;
                }
                applicationMap.put(app.Id, app);

                Application_User_Tracking__c oldRecord = new Application_User_Tracking__c(Id=historyObj.recordId);
                oldRecord.Status__c = 'ReAssigned';
                oldRecord.End_Date__c = System.now();
                applicationTracking.add(oldRecord);

                Application_User_Tracking__c newRecord = new Application_User_Tracking__c();
                newRecord.Status__c = 'Pending';
                newRecord.Stage__c = historyObj.stage;
                newRecord.Start_Date__c = System.now();
                newRecord.Sub_Type__c = historyMap.get(historyObj.recordId).Sub_Type__c;
                newRecord.Application__c = historyMap.get(historyObj.recordId).Application__c;
                newRecord.Receipt__c = historyMap.get(historyObj.recordId).Receipt__c;
                newRecord.Type__c = historyMap.get(historyObj.recordId).Type__c;
                newRecord.Owner__c = historyObj.ownerId;
                newRecord.Previous_Stage__c = historyObj.oldStage;
                applicationTracking.add(newRecord);
            }

            if(applicationTracking != NULL && !applicationTracking.isEmpty()){
                upsert applicationTracking;
            }
            if(applicationMap != NULL && !applicationMap.isEmpty()){
                update applicationMap.values();
            }

            return 'SUCCESS';
        }catch(Exception ex){
            System.debug('Error in handleApplicationReassignment ='+ex.getMessage()+' - '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }        
    } 

    public static Map<String, List<DropdownValues>> getUserMap(String branchId, Set<String> stages){
        Map<String, List<DropdownValues>> userStageMap = new Map<String, List<DropdownValues>>();

        for(Access_Branch_Allocation__c accuser:[SELECT Id, Access_Master__r.User__c, Access_Master__r.User__r.Name, Access_Master__r.Access_For__c 
                                                 FROM Access_Branch_Allocation__c 
                                                 WHERE Access_Master__r.Access_For__c IN : stages
                                                 AND Branch_Master__c =: branchId
                                                 AND Access_Master__r.User__r.isActive = true])
        {
            if(!userStageMap.containsKey(accuser.Access_Master__r.Access_For__c)){
                userStageMap.put(accuser.Access_Master__r.Access_For__c, new List<DropdownValues>());
            }
            DropdownValues dpObj = new DropdownValues();
            dpObj.label = accuser.Access_Master__r.User__r.Name;
            dpObj.value = accuser.Access_Master__r.User__c;
            userStageMap.get(accuser.Access_Master__r.Access_For__c).add(dpObj);
        }
        return userStageMap;
    }

    public class ApplicationAssignmentWrapper{
        @AuraEnabled public String recordId;
        @AuraEnabled public String applicationNumber;
        @AuraEnabled public String applicationId;
        @AuraEnabled public String branchName;
        @AuraEnabled public String stage;
        @AuraEnabled public String oldStage;
        @AuraEnabled public Datetime startDate;
        @AuraEnabled public Decimal timeInQueue;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String ownerId;
        @AuraEnabled public String historyType;
        @AuraEnabled public List<DropdownValues> userList;

        public ApplicationAssignmentWrapper(){
            recordId = '';
            stage = '';
            oldStage = '';
            ownerName = '';
            branchName = '';
            ownerId = '';
            historyType = '';
            applicationNumber = '';
            applicationId = '';
            userList = new List<DropdownValues>();
        }
    }

    public class DropdownValues{
        @AuraEnabled public String label;
        @AuraEnabled public String value;        
    }
}