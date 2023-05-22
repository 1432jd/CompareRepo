@IsTest
public class WelcomeLetterVfControllerTest {
    @TestSetup
    public static void testSetup(){
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        app.Number_of_advance_EMI__c = '1';
        app.EMI__c = 100;
        insert app;
        
        Account agency = new Account();
        //agency.Pre_Login__c = preLogin.Id;
        agency.Name = 'test';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Courier Agency').getRecordTypeId();
        insert agency;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Type__c = 'Primary Applicant';
        loanApp.Customer_Information__c = agency.Id;
        insert loanApp;
        
        Loan_Applicant__c loanApp1 = new Loan_Applicant__c();
        loanApp1.Application__c = app.Id;
        loanApp1.Customer_Type__c = 'Co-Applicant';
        loanApp1.Customer_Information__c = agency.Id;
        insert loanApp1;
        
        Disbursal__c disObj = new Disbursal__c();
        disObj.Application__c=app.id;
        disObj.Due_Date__c= date.today();
        disObj.First_Installment_Date__c=date.today();
        disObj.Interest_Start_Date__c=date.today();
        disObj.Loan_Amount_Sanctioned__c = 20000;
        insert disObj;
        
        List<Fee_Creation__c> FeeList = new List<Fee_Creation__c>();
        Fee_Creation__c fee_creationObj = new Fee_Creation__c(
            Premium__c = 6655,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 7852.9,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Fee_Code__c = 'Legal',
            Tax_Amount__c = 1197.9,
            Repayment_Type_2__c = 'Direct Receipt',
            Applicable_For__c = 'Application');
        FeeList.add(fee_creationObj);
        
        Fee_Creation__c fee_creationObj1 = new Fee_Creation__c(
            Premium__c = 6655,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 7852.9,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Fee_Code__c = 'PRC_FEE_Type',
            Tax_Amount__c = 1197.9,
            Repayment_Type_2__c = 'Direct Receipt',
            Applicable_For__c = 'Application');
        FeeList.add(fee_creationObj1);
        
        Fee_Creation__c fee_creationObj2 = new Fee_Creation__c(
            Premium__c = 6655,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 7852.9,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Fee_Code__c = 'LegaL',
            Tax_Amount__c = 1197.9,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Applicable_For__c = 'Application');
        FeeList.add(fee_creationObj2);
        
        Fee_Creation__c fee_creationObj3 = new Fee_Creation__c(
            Premium__c = 6655,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 7852.9,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Fee_Code__c = 'PRC_FEE_Type',
            Tax_Amount__c = 1197.9,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Applicable_For__c = 'Application');
        FeeList.add(fee_creationObj3);
        
        Fee_Creation__c fee_creationObj4 = new Fee_Creation__c(
            Premium__c = 6655,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 7852.9,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Fee_Code__c = 'Cersai',
            Tax_Amount__c = 1197.9,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Applicable_For__c = 'Application');
        FeeList.add(fee_creationObj4);
        
        Fee_Creation__c fee_creationObj5 = new Fee_Creation__c(
            Premium__c = 6655,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 7852.9,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Fee_Code__c = 'Technical',
            Tax_Amount__c = 1197.9,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Applicable_For__c = 'Application');
        FeeList.add(fee_creationObj5);
        
        Fee_Creation__c fee_creationObj6 = new Fee_Creation__c(
            Premium__c = 6655,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 7852.9,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Tax_Amount__c = 1197.9,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Applicable_For__c = 'Application');
        FeeList.add(fee_creationObj6);
        insert FeeList;
        
        Receipt__c receiptObj = new Receipt__c(
            Receipt_Date__c = Date.valueOf('2022-08-05'),
            Amount__c = 250,
            Mode_of_payment__c = 'Cash',
            Pre_Login__c = preLogin.Id,
            Application__c = app.Id,
            Approval_Status__c = 'Submitted',
            Customer_name__c = 'Ankur Sharma',
            Loan_Purpose__c = 'test');
        insert receiptObj;
    }
    
    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        PageReference pageRef = Page.Welcome_Letter;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(app.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(app);
        WelcomeLetterVfController obj = new WelcomeLetterVfController();
        //CourierControlSheetVfCtrl.guarantorContactRole(opp.Id);
        Test.stopTest();
    }
}