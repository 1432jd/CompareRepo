@IsTest
public class Verification_TH_StageMovementTest {
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

        Verification__c verifi1 = new Verification__c();
        verifi1.Name__c = 'Test';
        verifi1.Status__c = 'Completed';
        verifi1.Initiate_From__c = 'Pre Login';
        verifi1.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verifi1.Application__c = app.Id;
        insert verifi1;
        
        Verification__c verifi2 = new Verification__c();
        verifi2.Name__c = 'Test';
        verifi2.Status__c = 'Completed';
        verifi2.Initiate_From__c = 'Pre Login';
        verifi2.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verifi2.Application__c = app.Id;
        insert verifi2;
        
        Verification__c verifi3 = new Verification__c();
        verifi3.Name__c = 'Test';
        verifi3.Status__c = 'Pending';
        verifi3.Initiate_From__c = 'Pre Login';
        verifi3.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verifi3.Application__c = app.Id;
        insert verifi3;
    }

    @IsTest
    public static void test(){
        Verification__c verifi = [SELECT Id, Status__c FROM Verification__c WHERE Status__c = 'Pending' limit 1];
        verifi.Status__c = 'Completed';
        Test.startTest();
        update verifi;
        Test.stopTest();
    }
}