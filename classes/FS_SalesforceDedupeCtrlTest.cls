@isTest
public class FS_SalesforceDedupeCtrlTest {

    @isTest
    public static void TestSalesforceDedupeCtrl(){
        Branch_Master__c bm =new Branch_Master__c();
		bm.Name = 'Rajasthan';
		bm.State__c = 'RJ';
		insert bm;
        
        Pre_Login__c login = new Pre_Login__c();
        login.RecordTypeId = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        login.Status__c = 'Active';
        insert login;
        
        Application__c app1 = new Application__C();
        app1.Sourcing_Branch__c = bm.Id;
        app1.Pre_Login__c = login.Id;
        app1.Stage__c='Login';
        app1.Requested_Loan_Amount__c = 100000;
        insert app1;
        
        Application__c app2 = new Application__C();
        app2.Sourcing_Branch__c = bm.Id;
        app2.Pre_Login__c = login.Id;
        app2.Stage__c = 'Approval Credit';
        app2.application_status__c = 'Rejected';
        app2.Requested_Loan_Amount__c = 100000;
        insert app2;
        
        Application__c app3 = new Application__C();
        app3.Sourcing_Branch__c = bm.Id;
        app3.Pre_Login__c = login.Id;
        app3.Stage__c = 'Disbursal Author';
        app3.application_status__c = 'Rejected';
        app3.Requested_Loan_Amount__c = 100000;
        insert app3;
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.FirstName='ram';
        acc.LastName='kumar';
        accList.add(acc);
        insert accList;
        
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        Loan_Applicant__c loanAppObj1 = new Loan_Applicant__c();
        loanAppObj1.Application__c = app1.Id;
        loanAppObj1.KYC_Id_1__c = 'HQD4572046';
        loanAppObj1.KYC_ID_Type_1__c = 'Voter Id';
        loanAppObj1.Customer_Information__c = accList[0].Id;
        loanAppObj1.LMS_Customer_Info_File_Number__c = 'test1234';
        loanAppList.add(loanAppObj1);
        
        Loan_Applicant__c loanAppObj2 = new Loan_Applicant__c();
        loanAppObj2.Application__c = app2.Id;
        loanAppObj2.KYC_Id_1__c = 'HQD4572046';
        loanAppObj2.KYC_Id_2__c = 'HQD4572046'; 
        loanAppObj2.KYC_ID_Type_1__c  = 'Aadhaar Card';
        loanAppObj2.KYC_ID_Type_2__c = 'Voter Id';
        loanAppObj2.Customer_Information__c = accList[0].Id;
        loanAppObj2.LMS_Customer_Info_File_Number__c = 'test1234';
        loanAppList.add(loanAppObj2);
        
        Loan_Applicant__c loanAppObj3 = new Loan_Applicant__c();
        loanAppObj3.Application__c = app3.Id;
        loanAppObj3.KYC_Id_1__c = 'HQD4572046';
        loanAppObj3.KYC_Id_2__c = 'HQD4572046'; 
        loanAppObj3.KYC_ID_Type_1__c  = 'Driving License';
        loanAppObj3.KYC_ID_Type_2__c = 'Pan Card';
        loanAppObj3.Customer_Information__c = accList[0].Id;
        loanAppObj3.LMS_Customer_Info_File_Number__c = 'test1234';
        loanAppList.add(loanAppObj3);
        
        INSERT loanAppList;
        List<FS_SalesforceDedupeCtrl.CustomerWrapper> customerList = FS_SalesforceDedupeCtrl.getApplicantData(loanAppObj1.LMS_Customer_Info_File_Number__c, loanAppObj1.Id);
        customerList = FS_SalesforceDedupeCtrl.getApplicantData(loanAppObj2.LMS_Customer_Info_File_Number__c, loanAppObj2.Id);
        customerList = FS_SalesforceDedupeCtrl.getApplicantData(loanAppObj3.LMS_Customer_Info_File_Number__c, loanAppObj3.Id);
        loanAppList = new List<Loan_Applicant__c>();
        
        List<FS_SalesforceDedupeCtrl.DedupeWrapper> dedupeList = FS_SalesforceDedupeCtrl.getDedupeRecords(loanAppObj1.Id);
        
 
        loanAppObj1.KYC_Id_1__c = 'HQD4572046';
        loanAppObj1.KYC_Id_2__c = 'HQD4572046';
        loanAppObj1.KYC_ID_Type_1__c = 'Aadhaar Card';
        loanAppObj1.KYC_ID_Type_2__c = 'Voter Id';
        loanAppList.add(loanAppObj1);
        
        loanAppObj2.KYC_Id_1__c = 'HQD4572046';
        loanAppObj2.KYC_Id_2__c = 'HQD4572046'; 
        loanAppObj2.KYC_ID_Type_1__c  = 'Aadhaar Card';
        loanAppObj2.KYC_ID_Type_2__c = 'Voter Id';
        loanAppList.add(loanAppObj2);
        UPDATE loanAppList;
        
        dedupeList = FS_SalesforceDedupeCtrl.getDedupeRecords(loanAppObj1.Id);        
    }
}