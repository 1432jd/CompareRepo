@isTest
public class FsTrancheControllerTest {
    @testSetup
    public static void testSetup(){
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
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
        
        Disbursal__c disObj = new Disbursal__c();
        disObj.Application__c=app.id;
        disObj.Due_Date__c= date.today();
        disObj.First_Installment_Date__c=date.today();
        disObj.Interest_Start_Date__c=date.today();
        insert disObj;
    }
    
    @isTest
    public static void test(){
        Application__c app = [SELECT Name FROM Application__c limit 1];
        Test.startTest();
        FsTrancheController.getApplications(app.Name, '', '');
        FsTrancheController.getApplications('', '739923222', '');
        FsTrancheController.getApplications('', '', '739923222');
        Test.stopTest();
    }
}