public class VerificationRecordCreator {
    @AuraEnabled
    public static void createVerificationRecords(String applicationId){
        try{
            Boolean allCreated = false;
            Application__c objApp = [SELECT Id, Name, Pre_Login__c,Stage__c, hasVerificationRecords__c, IsExceptionRaised__c
                                     FROM Application__c 
                                     WHERE Id =:applicationId
                                    ];
        
            if(objApp.IsExceptionRaised__c){     
                objApp.Stage__c = 'Pre Login Dedupe Exception';
                update objApp;
                createDedupeApplicationHistory(objApp.Id);  
            }
            
            if(!objApp.hasVerificationRecords__c && !objApp.IsExceptionRaised__c){
                
                list<Verification__c> VerificationList=new list<Verification__c>();
                //list<id> bmID=new list<id>();
                //list<id> cmID=new list<id>();
                Id FIVBRecordTypeId = Utility.VERIFICATION_FIV_B_RECORD_TYPE_ID;
                Id FIVCRecordTypeId = Utility.VERIFICATION_FIV_C_RECORD_TYPE_ID;
                Id OnlineECRecordTypeId = Utility.VERIFICATION_FIV_EC_RECORD_TYPE_ID;
                //list<account> acclist=[select id ,Branch_Master__c,Branch_Master__r.Name from account where User__c=:userinfo.getuserid()];
                //bmId.add(userinfo.getuserid());
                //cmId.add(userinfo.getuserid());
                //if(bmID!=null && cmID!=null){   
                Verification__c verificationFIVB=new Verification__c();
                verificationFIVB.RecordTypeId=FIVBRecordTypeId;
                verificationFIVB.Application__c=applicationId;
                verificationFIVB.OwnerId= userinfo.getuserid();
                verificationFIVB.status__c='Pending';
                verificationFIVB.Initiate_From__c = 'Pre Login';
                VerificationList.add(verificationFIVB);
                
                Verification__c OnlineEC=new Verification__c();
                OnlineEC.Application__c=applicationId;
                OnlineEC.OwnerId= userinfo.getuserid();
                OnlineEC.RecordTypeId=OnlineECRecordTypeId;
                OnlineEC.Status__c='Pending';
                OnlineEC.Initiate_From__c = 'Pre Login';
                System.debug('OnlineECRecordTypeId :: '+OnlineECRecordTypeId);
                VerificationList.add(OnlineEC);
                
                Verification__c verificationFIVC=new Verification__c();
                verificationFIVC.Application__c=applicationId;
                verificationFIVC.OwnerId= userinfo.getuserid();
                verificationFIVC.RecordTypeId=FIVCRecordTypeId;
                System.debug('OnlineECRecordTypeId :: '+OnlineECRecordTypeId);
                verificationFIVC.Status__c='Pending';
                verificationFIVC.Initiate_From__c = 'Pre Login';
                VerificationList.add(verificationFIVC);
                
                objApp.hasVerificationRecords__c=true;
                objApp.Stage__c = 'Verification';
                objApp.Sub_Flow__c = 'Lead Detail Maker';
                objApp.Sub_Stage__c = 'Legal Opinion';
                
                if(VerificationList.size()>0){
                    insert VerificationList;
                    update objApp;    
                }
                //}      
            }

        }
        catch(Exception e){
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage().length() > 255 ? e.getMessage().substring(0, 255) : e.getMessage();
            objErrorLog.Description__c = e.getMessage().length() > 30000 ? e.getMessage().substring(0, 30000) : e.getMessage(); 
            objErrorLog.Name = 'Verification Record Creator';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            objErrorLog.Application__c = applicationId;
            insert objErrorLog;
        }
    }
    
    @AuraEnabled  
    public static String getDedupeUserId(String appId){
        List<Application__c> appList = [SELECT Id, Dedupe_Exception_User__c FROM Application__c WHERE Id=: appId];
        if( appList != null && appList[0].Id != null && appList.get(0).Dedupe_Exception_User__c != NULL) {
            return appList.get(0).Dedupe_Exception_User__c ; 
        }else {
            return AllocationHandler.roundRobinByStage(appId ,'Dedupe Exception');
        }
    }

    public static void createDedupeApplicationHistory(String applicationId){
        List<sObject> sObjList = new List<sObject>();
        Integer countLoanApp =0;
        String dedupeUserId = getDedupeUserId(applicationId);
        for(Loan_Applicant__c applicant : [SELECT Id, Application__c, LMS_Customer_Info_File_Number__c, 
                                            (select Id, Archive__c,Active__c from Dedupe_Details__r where Archive__c = false 
                                            AND OwnerId !=: dedupeUserId) 
                                            FROM Loan_Applicant__c
                                            WHERE Application__c =: applicationId  
                                            AND IsDedupeExecuted__c=true]) 
        {
                                                    // assign dedupe records to Dedupe Exception User
            if(applicant.Dedupe_Details__r.size() > 1) {
                ++countLoanApp;
                for(Dedupe_Detail__c dedupe : applicant.Dedupe_Details__r) {
                    dedupe.Id = dedupe.Id ;
                    if(String.isNotBlank( dedupeUserId )) {
                        dedupe.ownerId = dedupeUserId ;
                    }
                    sObjList.add(dedupe);
                }
            }else{
                for(Dedupe_Detail__c dedupe : applicant.Dedupe_Details__r) {
                    if(dedupe.Active__c	== 'No'){
                        ++countLoanApp;
                        dedupe.Id = dedupe.Id ;
                        if(String.isNotBlank( dedupeUserId )) {
                            dedupe.ownerId = dedupeUserId ;
                        }
                        sObjList.add(dedupe);
                    } 
                }
            }
            System.debug('inside method');
        }
            
        if(!sObjList.isEmpty()){                
            List<Application__c> appList = [select Id,OwnerId,Stage__c,Owner.Name from Application__c where Id=:applicationId];                
            for(Integer i=0; i<countLoanApp;i++){
                String status = (dedupeUserId == System.Label.Pull_Queue_User) ? 'Unassigned' : 'Pending';
                Application_User_Tracking__c appUtObj = new Application_User_Tracking__c();
                appUtObj.Application__c=applicationId;
                appUtObj.Stage__c=appList[0].Stage__c;
                appUtObj.Start_Date__c=System.now();
                appUtObj.Type__c='Dedupe';
                appUtObj.Status__c=status;
                appUtObj.Owner__c=dedupeUserId;
                sObjList.add(appUtObj);
            }
            if(!sObjList.isEmpty())
                upsert  sObjList;
        }
    }   
}