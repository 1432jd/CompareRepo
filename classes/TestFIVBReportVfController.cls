/**
* @File Name          : TestFivBLwcController.cls
* @Description        : Service Class For FivBLwcController
* @Author             : Yogendra Degra
* @Created On         : 27/04/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         27/04/2022              Yogendra Degra       Initial Version
*/
@isTest
private class TestFIVBReportVfController {
    @TestSetup
    static void createTestData() {
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Branch_Master__c br = new Branch_Master__c();
        br.Name = 'ss';
        insert br;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.AC_Remarks__c = 'test';
        app.Requested_Loan_Amount__c = 2323;
        app.Branch__c = 'dd';
        app.Sourcing_Branch__c = br.Id;
        insert app;

        Account acc = new Account();
        acc.Pre_Login__c = preLogin.Id;
        acc.LastName = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Property__c pro = new Property__c();
        pro.Application__c = app.Id;
        pro.Login__c = preLogin.Id;
        pro.Customer_Information__c = acc.Id;
        pro.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-B Property Detail').getRecordTypeId();
        pro.Address_Line_2__c = 'test';
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.Application__c = app.Id;
        pro1.Login__c = preLogin.Id;
        pro1.Customer_Information__c = acc.Id;
        pro1.Address_Line_2__c = 'test1';
        insert pro1;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        loanApp.Business_City__c = 'xx';
        loanApp.Customer_Type__c = 'Primary Applicant';
        insert loanApp;
        
        Verification__c objVerification = new Verification__c();
        //objVerification.Name = 'FIV-B';
        objVerification.Application__c = app.Id; 
        objVerification.Customer_Request_Amount__c = 22;
        objVerification.BM_Recommended_Amount__c = 22;
        objVerification.Tenor__c = '24';
        objVerification.Purpose__c = 'BT';
        objVerification.Inspection_Date__c = Date.today();
        objVerification.Tier__c = 'ee';
        insert objVerification;
        
        Verification__c ver = new Verification__c();
        ver.Id = objVerification.Id;
        ver.Application__c = app.Id; 
        ver.Customer_Request_Amount__c = 24;
        ver.BM_Recommended_Amount__c = 22;
        ver.Tenor__c = '24';
        ver.Purpose__c = 'BT';
        ver.Inspection_Date__c = Date.today();
        ver.Tier__c = 'ee';
        insert ver; 
        
        
        Cashflow__c cash = new Cashflow__c();
        cash.Application__c = app.Id;
        cash.Loan_Applicant__c = loanApp.Id;
        cash.BM_Comments_for_Cashflow__c = 'testing';
        insert cash;
        
        Character__c charac = new Character__c();
        charac.Application__c = app.Id;
        charac.Loan_Applicant__c = loanApp.Id;
        charac.Affiliation_Name__c = 'dd';
        insert charac;
    }	
    @isTest
    static void testAllMethod() {
        Test.StartTest(); 
        List<Verification__c> listOfApplication = [SELECT Id, Application__c FROM Verification__c WHERE Customer_Request_Amount__c=24];
        List<Application__c> appList = [SELECT Id,AC_Remarks__c FROM Application__c WHERE AC_Remarks__c='test'];
        Loan_Applicant__c loanApp = [SELECT ID,Business_City__c FROM Loan_Applicant__c WHERE Business_City__c='xx'];
        Property__c pro = [SELECT ID,Address_Line_2__c FROM Property__C WHERE Address_Line_2__c='test'];
        Cashflow__c cash = [SELECT ID,BM_Comments_for_Cashflow__c FROM Cashflow__c WHERE BM_Comments_for_Cashflow__c='testing'];
        Character__c charac = [SELECT ID,Affiliation_Name__c FROM Character__c WHERE Affiliation_Name__c='dd'];
        PageReference pageRef = Page.FIVBReportVf; // Add your VF page Name here
        pageRef.getParameters().put('applicationId', String.valueOf(appList[0].Id));
        Test.setCurrentPage(pageRef);
        FSFIVBReportVfController.generateFIVBPdf(listOfApplication[0].Id, listOfApplication[0].Application__c);
        /*try{
            FSFIVBReportVfController obj = new FSFIVBReportVfController();
            obj.applicationId = appList[0].Id;
            obj.verificationId = listOfApplication[0].Id;
            obj.propertyList.add(pro);
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        */
         FSFIVBReportVfController obj = new FSFIVBReportVfController();
        Test.stopTest();
    } 
}