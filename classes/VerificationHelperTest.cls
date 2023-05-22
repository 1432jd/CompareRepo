@IsTest
public class VerificationHelperTest {
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
        
        Verification__c verifi = new Verification__c();
        verifi.Name__c = 'Test';
        verifi.Status__c = 'Completed';
        verifi.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - B').getRecordTypeId();
        verifi.Application__c = app.Id;
        insert verifi;
        
        Verification__c verifi1 = new Verification__c();
        verifi1.Name__c = 'Test';
        verifi1.Status__c = 'Completed';
        verifi1.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verifi1.Application__c = app.Id;
        insert verifi1;
    }
    
    @IsTest
    public static void UpdateStageLogicTest(){
        List<Verification__c> verificationList = [SELECT Id, Application__c, recordTypeId FROM Verification__c];
        Test.startTest();
        VerificationHelper.UpdateStageLogic(verificationList);
        Test.stopTest();
    }
}