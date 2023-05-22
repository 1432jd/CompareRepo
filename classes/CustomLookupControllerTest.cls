@IsTest
public class CustomLookupControllerTest {
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
    }

    @IsTest
    public static void test(){
        Application__c app = [SELECT Id, Name FROM Application__c limit 1];
        Test.startTest();
        CustomLookupController.search('ARB', 'Application__c','');
        CustomLookupController.search('', 'Application__c','');
        Test.stopTest();
    }
}