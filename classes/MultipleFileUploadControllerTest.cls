@isTest
public with sharing class MultipleFileUploadControllerTest {

    @TestSetup
    public static void makeData(){
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
        
        insert new Contentversion(Title = 'ABC', PathOnClient = 'test', VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
    }

    @isTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Contentversion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        Test.startTest();
        MultipleFileUploadController.doUploadAttachment(app.Id, 'base64', 'Test', null, 'FIV - C', UserInfo.getUserId());
        MultipleFileUploadController.doUploadAttachment(app.Id, 'base64', 'Test', cv.Id, 'FIV - C', UserInfo.getUserId());
        Test.stopTest();
    }
}