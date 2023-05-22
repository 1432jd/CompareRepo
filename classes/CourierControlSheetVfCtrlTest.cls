@isTest
public class CourierControlSheetVfCtrlTest {
    @TestSetup
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

        Courier_Control__c courierCnt = new Courier_Control__c();
        courierCnt.Address__c = 'Test';
        courierCnt.Branch_Name__c = branch.Name;
        courierCnt.Branch__c = branch.Id;
        //courierCnt.Courier_Agency__c = agency.Id;
        courierCnt.Courier_POD_No__c = '8343HMU73H';
        courierCnt.From_Date__c = System.today();
        courierCnt.To_Date__c = System.today();
        insert courierCnt;

        Courier_Application__c courApp = new Courier_Application__c();
        courApp.Courier_Control__c = courierCnt.Id;
        courApp.Application__c = app.Id;
        insert courApp;
    }

    @IsTest
    public static void test(){
        Courier_Control__c courCon = [SELECT Id FROM Courier_Control__c limit 1];
        Test.startTest();
        PageReference pageRef = Page.courierControlSheetVf;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('recordId', String.valueOf(courCon.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(courCon);
        CourierControlSheetVfCtrl ape = new CourierControlSheetVfCtrl(sc);
        //CourierControlSheetVfCtrl.guarantorContactRole(opp.Id);
        Test.stopTest();
    }
}