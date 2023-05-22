public without sharing class FS_ApplicationPullAssignmentHandler{
	
	@AuraEnabled
	public static List<ApplicationAssignmentWrapper> getUnassignedApplications(){
		List<ApplicationAssignmentWrapper> historyList = new List<ApplicationAssignmentWrapper>();
		String userId = UserInfo.getUserId();
		List<Access_Branch_Allocation__c> allocationRecords = new List<Access_Branch_Allocation__c>();
		allocationRecords = [SELECT 
							Id, Access_Master__c, Access_Master__r.User__c, Access_Master__r.Access_For__c, Branch_Master__c 
							FROM Access_Branch_Allocation__c 
							WHERE Access_Master__r.User__c =: userId];
		
		Set<String> branchIds = new Set<String>();
		Set<String> stageNames = new Set<String>();
		Set<String> branchAccess = new Set<String>();
		for(Access_Branch_Allocation__c abaObj : allocationRecords){
			branchIds.add(abaObj.Branch_Master__c);
			stageNames.add(abaObj.Access_Master__r.Access_For__c);
			branchAccess.add(abaObj.Branch_Master__c + '-' + abaObj.Access_Master__r.Access_For__c);			
		}
		branchIds.add('abaObj.Branch_Master__c');
		if(!branchIds.isEmpty()){
			List<Application_User_Tracking__c> applicationHistory = new List<Application_User_Tracking__c>();
			applicationHistory = [SELECT 
								Id, Name, Stage__c, Status__c, Owner__c, Owner__r.Name, Application__c, Previous_Stage__c,
								Start_Date__c, Total_TAT_In_Days__c, Type__c, Application__r.Sourcing_Branch__c,
								Application__r.Sourcing_Branch__r.Name, Application__r.Name
								FROM Application_User_Tracking__c 
								WHERE Application__r.Sourcing_Branch__c IN : branchIds
								AND Stage__c IN: stageNames
                                AND Status__c = 'Unassigned'
                                AND Owner__c =: System.Label.Pull_Queue_User];

            // applicationHistory = [SELECT 
            //                     Id, Name, Stage__c, Status__c, Owner__c, Owner__r.Name, Application__c, Previous_Stage__c,
			//  					Start_Date__c, Total_TAT_In_Days__c, Type__c, Application__r.Sourcing_Branch__c,
			//  					Application__r.Sourcing_Branch__r.Name, Application__r.Name
            //                     FROM Application_User_Tracking__c 
            //                     WHERE Application__c = 'a030w000008HwIQAA0' 
            //                     AND Status__c = 'Pending'];
			for(Application_User_Tracking__c autObj : applicationHistory){
				String key = autObj.Application__r.Sourcing_Branch__c + '-' + autObj.Stage__c;
				if(branchAccess.contains(key)){
					ApplicationAssignmentWrapper historyObj = new ApplicationAssignmentWrapper();
					historyObj.recordId = autObj.Id;
					historyObj.applicationNumber = autObj.Application__r.Name;
					historyObj.applicationId = autObj.Application__c;
					historyObj.stage = autObj.Stage__c;
					historyObj.branchName = autObj.Application__r.Sourcing_Branch__r.Name;
					historyObj.oldStage = autObj.Previous_Stage__c;
					historyObj.startDate = autObj.Start_Date__c;
					historyObj.timeInQueue = autObj.Total_TAT_In_Days__c;
					historyObj.historyType = autObj.Type__c;
					historyObj.ownerName = autObj.Owner__r.Name;
					historyObj.ownerId = autObj.Owner__c;
                    historyList.add(historyObj);
				}
			}					
		}
		return historyList;
	}
	
	@AuraEnabled
    public static String handleApplicationReassignment(String updatedListStr){
        try{
            List<ApplicationAssignmentWrapper> updatedList = (List<ApplicationAssignmentWrapper>) JSON.deserialize(updatedListStr, List<ApplicationAssignmentWrapper>.class);
			String userId = UserInfo.getUserId();
			
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
			
            Map<Id,Receipt__c> receipts = new Map<Id,Receipt__c>();
			for(ApplicationAssignmentWrapper historyObj: updatedList){
                Application__c app = new Application__c();
                if(!applicationMap.containsKey(historyObj.applicationId)){
                    app.Id = historyObj.applicationId;
                }else{
                    app = applicationMap.get(historyObj.applicationId);
                }
                
                if(historyObj.stage == 'FIV - C'){
                    app.FIV_C_User__c = userId;
                } else if(historyObj.stage == 'FIV - B'){
                    app.FIV_B_User__c = userId;
                } else if(historyObj.stage == 'Online EC'){
                    app.Online_EC_User__c = userId;
                } else if(historyObj.stage == 'Legal Opinion'){
                    app.Legal_Opinion_User__c = userId;
                } else if(historyObj.stage == 'Legal Approval'){
                    app.Legal_Approval_User__c = userId;
                } else if(historyObj.stage == 'DOS'){
                    app.DOS_User__c = userId;
                } else if(historyObj.stage == 'Lead Detail Maker'){
                    app.Lead_Detail_Maker_User__c = userId;
                } else if(historyObj.stage == 'Lead Detail Checker'){
                    app.Lead_Detail_Checker_User__c = userId;
                } else if(historyMap.get(historyObj.recordId).Type__c == 'Application'){
                    app.OwnerId = userId;
                } else if(historyMap.get(historyObj.recordId).Type__c == 'Dedupe'){
                    app.Dedupe_Exception_User__c = userId;
                } else if(historyMap.get(historyObj.recordId).Type__c == 'Deviation'){
                    app.Current_Deviation_Approval__c = userId;
                } else if(historyMap.get(historyObj.recordId).Type__c == 'Receipt'){
                    String receiptId = historyMap.get(historyObj.recordId).Receipt__c;
                    receipts.put(receiptId, new Receipt__c(Id=receiptId, Cashier__c= userId));
                }
                applicationMap.put(app.Id, app);
				
				Application_User_Tracking__c oldRecord = new Application_User_Tracking__c(Id=historyObj.recordId);
                oldRecord.Status__c = 'Assigned';
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
                newRecord.Owner__c = userId;
                newRecord.Previous_Stage__c = historyObj.oldStage;
                applicationTracking.add(newRecord);
			}
			
            if(receipts != NULL && !receipts.isEmpty()){
                update receipts.values();
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
        }
    }
}