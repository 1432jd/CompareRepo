/**
* @File Name          : TestFivBLwcController.cls
* @Description        : Service Class For FivBLwcController
* @Author             : Yogendra Degra 
* @Created On         : 26/04/2022
* @last modified on   : 10/09/2022
* @last modified by   : Arnav Chaudhary
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         26/04/2022              Yogendra Degra       Initial Version
*/
@isTest
private class TestFivBLwcController {
    @TestSetup
    static void createTestData() {
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Applicant_Name__c = 'App1';
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
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.Application__c = app.Id;
        pro1.Login__c = preLogin.Id;
        pro1.Customer_Information__c = acc.Id;
        insert pro1;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        insert loanApp;
        
        Id fivbRecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - B').getRecordTypeId();
        
        List<Verification__c> verList = new List<Verification__c>();
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
     //   ver.Name__c = 'verify';
        ver.FIV_B_Position__c = 'FIV_B_Table_Caseflow';
        verList.add(ver);
        
        Verification__c ver1 = new Verification__c();
        ver1.Application__c = app.Id;
        ver1.Name__c = 'verify1';
        ver1.FIV_B_Position__c = 'FIV_B_Table_Collateral';
        ver1.RecordTypeId = fivbRecordTypeId; 
        verList.add(ver1);
        insert verList;
        
        GenericFormBuilderController gen = new GenericFormBuilderController();
        gen.METADATA_NAME = 'abc';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Image';
        cv.PathOnClient = 'Test_Image.jpg';
        cv.VersionData = Blob.valueOf('Test Image Data');
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = cv.id;
        cd.Name = cv.Title;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;
        
    }	
    @isTest
    static void testAllMethod() {
        List<Application__c> listOfApplication = [SELECT Id FROM Application__c];
        List<Account> listOfApplicant = [SELECT Id FROM Account];
        List<Property__c> listOfProperty = [SELECT Id FROM Property__c];
        Application__c application = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c =: 'App1'];
        Verification__c verification = [SELECT Id,Name__c FROM Verification__c WHERE Name__c = 'verify1'];
        ContentVersion cv = [SELECT Id,Title,PathOnClient FROM ContentVersion WHERE Title = 'Test Image' AND PathOnClient = 'Test_Image.jpg'];
        FSFivBLwcController.getApplicantData(listOfApplication[0].Id);
        FSFivBLwcController.getCashflowData(new List<String> {listOfApplicant[0].Id});
        FSFivBLwcController.getCharacterData(new List<String> {listOfApplicant[0].Id});
        FSFivBLwcController.saveRecord(application);
        FSFivBLwcController.getSectionContent(application.Id, 'abc');
        FSFivBLwcController.getAllApplicantMeta(application.Id);
        FSFivBLwcController.getVerificationRecord(verification.Id);
        FSFivBLwcController.getPropertyData(application.Id);
        FSFivBLwcController.getROIRecord(application.Id,true);
        FSFivBLwcController.getAllCalculationRecords(application.Id);
        FSFivBLwcController.getVerificationData(application.Id);
        FSFivBLwcController.createVerificationRecord(application.Id, 'FIV_B_Table_Caseflow');
        FSFivBLwcController.createVerificationRecord(application.Id, 'FIV_B_Table_Collateral');
        FSFivBLwcController.generatePublicLink(cv.Id);
    } 
}