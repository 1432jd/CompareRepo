/**
* @File Name          : FsTrancheController.apxc
* @Author             : Mo Arslan	
* @Description		  : This is a controller for FsTrancheApplication LWC Component
* @Created On         : 31 August 2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       31 August 2022            Mo Arslan             Initial Version
**/

public without sharing class FsTrancheController extends GenericDataTableController {

    //Retreive Application for Tranch //List<TrancheWrapper>
    @AuraEnabled 
    public static List<TrancheWrapper> getApplications(String appNumber,String loanAccountNo,String kycNumber){
        List<TrancheWrapper> trancheList = new List<TrancheWrapper>();
        Map<String, Loan_Applicant__c> loanApplicantMap = new Map<String, Loan_Applicant__c>();
        List<Disbursal__c> disbursalList = new List<Disbursal__c>();
        List<Loan_Applicant__c> loanApplicants = new List<Loan_Applicant__c>();
        String query = 'SELECT Id, Application__c, Application__r.Current_DPD__c, Application__r.Current_Outstanding__c, Application__r.Tranche_Disbursal__c, Application__r.application_status__c, Application__r.Stage__c, Application__r.Name, Customer_Information__r.Name, Application__r.LMS_Response_Reference__c FROM Loan_Applicant__c ';
               //query+= 'WHERE (Application__r.Pre_Login__r.Status__c =  \'Rejected\' ';
               //query+= 'OR Application__r.Pre_Login__r.Status__c = \'Cancelled\' '; 
               query+= 'WHERE (Application__r.Pre_Login__r.Status__c = \'Active\') ';
               //query+= 'AND NOT Name LIKE  \'APPT%\' ';

        if(String.isNotBlank(appNumber) && String.isNotEmpty(appNumber)){
            query+= 'AND Application__r.Name = :appNumber '; 
            query+= 'AND Application__r.Name != null '; 
            query+= 'AND Application__r.application_status__c = \'Active\' ';
            query+= 'AND Customer_Type__c = \'Primary Applicant\' ';
            query+= 'AND Application__r.LMS_Response_Reference__c != null';
        }
        else if(String.isNotBlank(loanAccountNo) && String.isNotEmpty(loanAccountNo)){
            query+= 'AND Customer_Type__c = \'Primary Applicant\' ';
            query+= 'AND Application__r.LMS_Response_Reference__c =:loanAccountNo ';
        }
        else if(String.isNotBlank(kycNumber) && String.isNotEmpty(kycNumber)){
            query+= 'AND (KYC_Id_1__c = :kycNumber OR KYC_Id_2__c = :kycNumber) ';
        }
        System.debug('query '+ query);
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
            disbursalList = [SELECT Id, Final_Disbursal_Amount__c, Loan_Amount_Sanctioned__c,  Application__c FROM Disbursal__c  WHERE Application__c IN :loanApplicantMap.keySet() ORDER BY Sanction_Date__c DESC];
        }
        System.debug('disbursalList '+disbursalList);
        if(disbursalList.size()>0){
            for(Disbursal__c dis : disbursalList){
                TrancheWrapper wrap = new TrancheWrapper();
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
                trancheList.add(wrap);
            }
        }
        return trancheList;
    }

    public class TrancheWrapper{
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
        
        public TrancheWrapper(){
            appId = '';
            applicationNo = '';
            applicantName = '';
            lan = '';
            disbursedLoanAmount = 0;
            trancheNumber = '';
            currentPDP = 0;
            currentOutstanding = 0;
            stage = '';
            status = '';
            sanctionedLoanAmount = 0;
        }
    }
}