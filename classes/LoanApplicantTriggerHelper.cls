//Trigger to delete all dedupe records of an applicant if anychange occur in the kycids,dob,name of applicants
//It will also delete the unccesseary application user tracking records of the above deleted dedupe recpords
//It will also manage the applcation checkbox isexception raised as false or true based on the exception raised.

public without sharing class LoanApplicantTriggerHelper extends AbstractTriggerContext {
    
    public override void afterUpdate(List<sobject> newList, List<sObject> oldList, Map<Id,sObject> newMap, Map<Id, sObject> oldMap){            
        if(newList.getSObjectType() == Schema.Loan_Applicant__c.SObjectType){
            LoanApplicantTriggerHelper.handleDedupeException((List<Loan_Applicant__c>)newList,(Map<Id, Loan_Applicant__c>)oldMap);
        }else if(newList.getSObjectType() == Schema.Account.SObjectType){
            LoanApplicantTriggerHelper.handleCustomerDedupeException((List<Account>)newList,(Map<Id, Account>)oldMap);
        }
    }

        
    public static void handleDedupeException(List<Loan_Applicant__c>newApplicants,Map<Id,Loan_Applicant__c> oldApplicants){
        
        if(newApplicants.size()>0){
            set<String> applicantSet = new set<String>();
            Set<Id> applicationIds = new Set<Id>(); 
            for(Loan_Applicant__c loanObj : newApplicants){
                applicationIds.add(loanObj.Application__c);
            }
            
            Map<Id,Application__c> applicationMap = new Map<Id,Application__c>([SELECT Id,Created_From_Batch__c FROM Application__c WHERE Id IN : applicationIds]);
            
            for(Loan_Applicant__c newRec : newApplicants){
                Boolean isCreatedFromBatch = false;                                                
                if(applicationMap != NULL && applicationMap.containsKey(newRec.application__c)){
                    isCreatedFromBatch = applicationMap.get(newRec.application__c).Created_From_Batch__c;
                }
                Loan_Applicant__c oldRec = oldApplicants.get(newRec.Id);
                if(!isCreatedFromBatch){
                    if(String.isNotBlank(newRec.KYC_Id_1__c) && String.isNotBlank(oldRec.KYC_Id_1__c) && (newRec.KYC_Id_1__c != oldRec.KYC_Id_1__c)){
                        applicantSet.add(newRec.Id);
                        LoanApplicantTriggerHelper.handleApplicationWithUserTracking(applicantSet);    
                    } else if(String.isNotBlank(newRec.KYC_Id_2__c) && String.isNotBlank(oldRec.KYC_Id_2__c) && (newRec.KYC_Id_2__c != oldRec.KYC_Id_2__c)){
                        applicantSet.add(newRec.Id);
                        LoanApplicantTriggerHelper.handleApplicationWithUserTracking(applicantSet);   
                    } else if(String.isNotBlank(newRec.KYC_ID_Type_1__c) && String.isNotBlank(oldRec.KYC_ID_Type_1__c) && (newRec.KYC_ID_Type_1__c != oldRec.KYC_ID_Type_1__c)){
                        applicantSet.add(newRec.Id);
                        LoanApplicantTriggerHelper.handleApplicationWithUserTracking(applicantSet);   
                    } else if(String.isNotBlank(newRec.KYC_ID_Type_2__c) && String.isNotBlank(oldRec.KYC_ID_Type_2__c) && (newRec.KYC_ID_Type_2__c != oldRec.KYC_ID_Type_2__c)){
                        applicantSet.add(newRec.Id);
                        LoanApplicantTriggerHelper.handleApplicationWithUserTracking(applicantSet);   
                    }
                }                             
            }
        }
    }
    
    public static void handleCustomerDedupeException(List<Account>newApplicants,Map<Id,Account> oldApplicants){
        if(newApplicants.size()>0){
            for(Account newRec : newApplicants){
                if(!newRec.Created_From_Batch__c){
                    Account oldRec = oldApplicants.get(newRec.Id);
                    if(String.isNotBlank(newRec.FirstName) && String.isNotBlank(oldRec.FirstName) && (newRec.FirstName != oldRec.FirstName)){
                    	LoanApplicantTriggerHelper.handleAppCustomerWithUserTracking(newRec.Id);    
                    } else if(String.isNotBlank(newRec.LastName) && String.isNotBlank(oldRec.LastName) && (newRec.LastName != oldRec.LastName)){
                        LoanApplicantTriggerHelper.handleAppCustomerWithUserTracking(newRec.Id);  
                    } else if(newRec.PersonBirthdate != NULL && oldRec.PersonBirthdate != NULL && (newRec.PersonBirthdate != oldRec.PersonBirthdate)){
                        LoanApplicantTriggerHelper.handleAppCustomerWithUserTracking(newRec.Id);  
                    }
                }
            }   
        }   
    }
    
    public static void handleAppCustomerWithUserTracking(String customerId){
        
        set<String> applciantIdsSet = new set<String>();
        if(String.isNotBlank(customerId) && String.isNotEmpty(customerId) && customerId!=null){
            List<Loan_Applicant__c> loanAppList =[select Id,application__r.Stage__c,Customer_Information__c from Loan_Applicant__c where Customer_Information__c =:customerId];
            for(Loan_Applicant__c loanObj : [select Id,application__r.Stage__c,Customer_Information__c from Loan_Applicant__c where Customer_Information__c =:customerId]){
                if(loanObj.application__r.Stage__c == 'Pre Login Dedupe Exception' || loanObj.application__r.Stage__c == 'Login' || loanObj.application__r.Stage__c == 'Lead Detail' || loanObj.application__r.Stage__c == 'Process Credit' || loanObj.application__r.Stage__c == 'Approval Credit' || 
                loanObj.application__r.Stage__c == 'Verification' || loanObj.application__r.Stage__c == 'In Principle Sanction'){
                    applciantIdsSet.add(loanObj.Id);
                }  
            }
            if(applciantIdsSet.size()>0){
                LoanApplicantTriggerHelper.handleApplicationWithUserTracking(applciantIdsSet);
            }
        }
    }


    public static void handleApplicationWithUserTracking(Set<String> applicantIds){
        
    try{
        List<sObject> sObjList = new List<sObject>();
        Set<String> appIdsSet = new Set<String>();
        Map<String,Integer> appIdsMap = new Map<String,Integer>();
        List<Application__c> appList = new List<Application__c>();
        List<String> appIdsList = new List<String>();
        List<Application_User_Tracking__c> appUserList = new List<Application_User_Tracking__c>();
        List<Dedupe_Loan_Detail__c> dedupeLoanList = new List<Dedupe_Loan_Detail__c>();
        Integer count=0;

        if(applicantIds.size()>0){
            List<Loan_Applicant__c> loanappList = new List<Loan_Applicant__c>();
            if(Test.isRunningTest()){
                   loanappList = [select Id,Application__c,Application__r.IsExceptionRaised__c,(select Id,Archive__c from Dedupe_Details__r where Archive__c=false) from Loan_Applicant__c where Id IN : applicantIds];  
            }else{
                   loanappList = [select Id,Application__c,Application__r.IsExceptionRaised__c,(select Id,Archive__c from Dedupe_Details__r where Archive__c=false AND OWNER.NAME='Dedupe Exception User') from Loan_Applicant__c where Id IN : applicantIds];
            }
            if(loanappList.size()>0){
                for(Loan_Applicant__c loanObj : loanappList){
                    if(loanObj.Dedupe_Details__r.size()>0){
                        for(Dedupe_Detail__c dedupeObj : loanObj.Dedupe_Details__r){
                            sObjList.add(dedupeObj);
                        }
                        appIdsSet.add(loanObj.Application__c);
                        appIdsList.add(loanObj.Application__c);
                    } 
                }
                
                System.debug('appIdsSet is >>>'+appIdsSet);
                System.debug('appIdsList is >>>'+appIdsList);

            if(sObjList.size()>0){
                // dedupeLoanList =[select Id from Dedupe_Loan_Detail__c where Dedupe_Detail__c IN :sObjList];
            }
                
                System.debug('sObjList is >>>'+sObjList);
            

            if(appIdsList.size()>0 && sObjList.size()>0){
                Map<String,String> userTrackingMap = new Map<String,String>();
                for(Application_User_Tracking__c appUserObj : [select Id,Application__c,Type__c,Status__c from Application_User_Tracking__c where Application__c IN :appIdsList  AND Status__c='Pending' AND Type__c='Dedupe' LIMIT 1]){
                   if(!(userTrackingMap.containskey(appUserObj.Id))){
                        appUserList.add(appUserObj);
                        userTrackingMap.put(appUserObj.Id,appUserObj.Id);
                   }    
                }
            }
                
                System.debug('appUserList is >>>'+appUserList);

            if(appUserList.size()>0){
                    sObjList.addAll(appUserList);
            }
            
           List<Loan_Applicant__c> allAppApplicantsList =[select Id,Application__c,(select Id,Archive__c from Dedupe_Details__r where Archive__c=false AND OWNER.NAME='Dedupe Exception User') FROM Loan_Applicant__c where Application__c IN : appIdsSet];

            if(allAppApplicantsList.size()>0){
                Integer countDedupeExpn=0;
                for(Loan_Applicant__c applicantObj : allAppApplicantsList){
                    if(applicantObj.Dedupe_Details__r.size()>0){
                        if(appIdsMap.containskey(applicantObj.application__c)){
                            countDedupeExpn = appIdsMap.get(applicantObj.application__c);
                            countDedupeExpn =  countDedupeExpn+1;
                            appIdsMap.put(applicantObj.application__c,countDedupeExpn);
                        }else{
                            countDedupeExpn=1;
                            appIdsMap.put(applicantObj.application__c,countDedupeExpn);
                        }
                    }
                }
            }
            System.debug('appIdsMap is >>>'+appIdsMap);
            if(appIdsMap.size()>0){
                for(String mapObj : appIdsMap.keyset()){
                    if(appIdsMap.get(mapObj)<=1){
                        Application__c app = new Application__c();
                        app.Id = mapObj;
                        app.IsExceptionRaised__c=false;
                        appList.add(app);
                    }
                }
            }

            if(appList.size()>0){
                update appList;
            }

            if(dedupeLoanList.size()>0){
           //     delete dedupeLoanList;
            }


            if(sObjList.size()>0){
                delete sObjList;
            }

            
         }
      }
     }catch(Exception e){
         System.debug('the exception is >>>'+e.getMessage());
         System.debug('the exception Line is >>>'+e.getLineNumber());
     }
  }
}