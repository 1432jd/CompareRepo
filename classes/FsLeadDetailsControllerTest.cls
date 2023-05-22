@IsTest
public class FsLeadDetailsControllerTest {
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
        insert app;

        Account acc = new Account();
        //acc.Pre_Login__c = preLogin.Id;
        acc.LastName = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;

        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Type__c = 'Primary Applicant';
        loanApp.Customer_Information__c = acc.Id;
        insert loanApp;
    }

    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        FsLeadDetailsController.getAllLoanApplicant(app.Id);
        FsLeadDetailsController.getSectionContent(app.Id, 'FIV_C_Customer_Information');
        FsLeadDetailsController.saveRecord(app);
		FsLeadDetailsController.getApplicants(app.Id);
        Test.stopTest();
    }
}