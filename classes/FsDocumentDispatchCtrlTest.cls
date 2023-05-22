@isTest
public class FsDocumentDispatchCtrlTest {
    @testSetup
    public static void testSetup(){
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;
        
        Access_Master__c access_masterObj = new Access_Master__c(
            Name = 'Disbursal Author',
            Access_For__c = 'Disbursal Author',
            Capacity_Used__c = 1,
            Capacity__c = 50,
            Level__c = '1',
            Sequence__c = 2,
            User__c = UserInfo.getUserId());
         insert access_masterObj;
        
        Access_Branch_Allocation__c abl = new Access_Branch_Allocation__c();
        abl.Branch_Master__c = branch.Id;
        abl.Access_Master__c = access_masterObj.Id;
        insert abl;        

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Dispatch Pending';
        insert app;

        /*Account acc = new Account();
        acc.Pre_Login__c = preLogin.Id;
        //acc.Name = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;*/

        Account agency = new Account();
        agency.Pre_Login__c = preLogin.Id;
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
    @isTest
    public static void getBranchTest(){
        Test.startTest();
        FsDocumentDisptachCtrl.getBranch();
        FsDocumentDisptachCtrl.getHoHubs();
        test.stopTest();
    }
    @isTest
    public static void getApplicationsWithDateTest(){
        Branch_Master__c branchMaster = [SELECT Id FROM Branch_Master__c limit 1];
        FsDocumentDisptachCtrl.getApplicationsWithDate(branchMaster.Id, System.today(), System.today());
    }
    @isTest
    public static void getApplicationsWithoutDateTest(){
        Branch_Master__c branchMaster = [SELECT Id FROM Branch_Master__c limit 1];
        FsDocumentDisptachCtrl.getApplicationsWithoutDate(branchMaster.Id);
    }
    /*@IsTest
    public static void getExistingRecordTest(){
        Courier_Control__c CourApp = [SELECT Id FROM Courier_Control__c limit 1];
        FsDocumentDisptachCtrl.getApplicationsWithoutDate(CourApp.Id);
    }*/

    @isTest
    public static void createRecordsTest(){
        Courier_Control__c CourApp = [SELECT Id FROM Courier_Control__c limit 1];
        List<Application__c> app = [SELECT Id FROM Application__c limit 1];
        List<String> applicationId = new List<String>{app[0].Id};
        Test.startTest();
        FsDocumentDisptachCtrl.createRecords(JSON.serialize(CourApp), applicationId, JSON.serialize(app));
        FsDocumentDisptachCtrl.getExistingRecord(courApp.Id);
        FsDocumentDisptachCtrl.downloadPDF(courApp.Id);
        Test.stopTest();
    }
    @IsTest
    public static void updateCourierApplicationsTest(){
        Courier_Control__c CourApp = [SELECT Id FROM Courier_Control__c limit 1];
        Test.startTest();
        FsDocumentDisptachCtrl.updateCourierApplications(CourApp.Id);
        FsDocumentDisptachCtrl.getHoHubs();
        Test.stopTest();
    }
}