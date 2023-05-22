public without sharing class ReloginTopupController {

    //Start from 273 to 355
    // Added by Mo Arslan
    //Retreive Application for Topup //List<TopupWrapper>
    @AuraEnabled 
    public static List<TopupWrapper> getApplications(String appNumber,String kycNumber, String loanAppNo, String recType){
        List<TopupWrapper> topupList = new List<TopupWrapper>();
        Map<String, Loan_Applicant__c> loanApplicantMap = new Map<String, Loan_Applicant__c>();
        List<Disbursal__c> disbursalList = new List<Disbursal__c>();
        List<Loan_Applicant__c> loanApplicants = new List<Loan_Applicant__c>();
        String query = 'SELECT Id, Application__c, Application__r.Current_DPD__c, Application__r.Current_Outstanding__c, Application__r.Tranche_Disbursal__c, Application__r.application_status__c, Application__r.Stage__c, Application__r.Name, Customer_Information__r.Name, Application__r.LMS_Response_Reference__c FROM Loan_Applicant__c ';
               query+= 'WHERE Application__c != NULL ';
               //query+= 'AND NOT Name LIKE  \'APPT%\' ';
        if(recType == '2. Re-login'){
               query+= 'AND (Application__r.Pre_Login__r.Status__c =  \'Rejected\' ';
               query+= 'OR Application__r.Pre_Login__r.Status__c = \'Cancelled\' '; 
               query+= 'OR Application__r.Pre_Login__r.Status__c = \'Active\') ';
               query+= 'AND Application__r.Pre_Login__r.RecordType.Name = \'1. New login\' ';
               query+= 'AND Application__r.LMS_Response_Reference__c = NULL ';
        }
        if(recType == '3. Top-up loan'){
            query+= 'AND Application__r.Pre_Login__r.Status__c = \'Active\' ';
            query+= 'AND Application__r.LMS_Response_Reference__c != NULL ';
        }
        if(String.isNotBlank(appNumber) && String.isNotEmpty(appNumber)){
            query+= 'AND Application__r.Name = :appNumber '; 
            query+= 'AND Application__r.Name != null '; 
            query+= 'AND Customer_Type__c = \'Primary Applicant\' ';
        }
        else if(String.isNotBlank(kycNumber) && String.isNotEmpty(kycNumber)){
            query+= 'AND (KYC_Id_1__c = :kycNumber OR KYC_Id_2__c = :kycNumber) ';
        }
        else if(String.isNotBlank(loanAppNo) && String.isNotEmpty(loanAppNo) && recType == '3. Top-up loan'){
            query+= 'AND Customer_Type__c = \'Primary Applicant\' ';
            query+= 'AND Application__r.LMS_Response_Reference__c =:loanAppNo ';
        }
        System.debug('query '+query);
        loanApplicants = Database.query(query);
        if(loanApplicants.size()>0){
            for(Loan_Applicant__c loanApp : loanApplicants){
                if(loanApp.Application__c!=null){
                    loanApplicantMap.put(loanApp.Application__c, loanApp);
                }
            }
        }
        System.debug('loanApplicantMap '+loanApplicantMap);
        if(!loanApplicantMap.isEmpty()){
            disbursalList = [SELECT Id, Final_Disbursal_Amount__c, Loan_Amount_Sanctioned__c,  Application__c FROM Disbursal__c  WHERE Application__c IN :loanApplicantMap.keySet() ORDER BY Sanction_Date__c DESC LIMIT 1];
        }
        System.debug('disbursalList '+disbursalList);
        if(disbursalList.size()>0){
            for(Disbursal__c dis : disbursalList){
                TopupWrapper wrap = new TopupWrapper();
                wrap.applicationNo = loanApplicantMap.get(dis.Application__c).Application__r.Name;
                wrap.applicantName = loanApplicantMap.get(dis.Application__c).Customer_Information__r.Name;
                wrap.lan = loanApplicantMap.get(dis.Application__c).Application__r.LMS_Response_Reference__c;
                wrap.stage = loanApplicantMap.get(dis.Application__c).Application__r.Stage__c;
                wrap.status = loanApplicantMap.get(dis.Application__c).Application__r.application_status__c;
                wrap.trancheNumber = loanApplicantMap.get(dis.Application__c).Application__r.Tranche_Disbursal__c;
                wrap.disbursedLoanAmount = dis.Final_Disbursal_Amount__c;
                wrap.sanctionedLoanAmount = dis.Loan_Amount_Sanctioned__c;
                wrap.currentPDP = loanApplicantMap.get(dis.Application__c).Application__r.Current_DPD__c;
                wrap.currentOutstanding = loanApplicantMap.get(dis.Application__c).Application__r.Current_Outstanding__c;
                wrap.appId = dis.Application__c;
                topupList.add(wrap);
            }
        }
        return topupList;
    }

    public class TopupWrapper{
        @AuraEnabled public String appId;
        @AuraEnabled public String applicationNo;
        @AuraEnabled public String applicantName;
        @AuraEnabled public String lan;
        @AuraEnabled public Decimal disbursedLoanAmount;
        @AuraEnabled public String trancheNumber;
        @AuraEnabled public Decimal currentPDP;
        @AuraEnabled public Decimal currentOutstanding;
        @AuraEnabled public String stage;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal sanctionedLoanAmount;
    }

    //End 
}