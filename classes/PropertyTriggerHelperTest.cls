@IsTest
public class PropertyTriggerHelperTest {
    
    @IsTest
    public static void testSetup(){

        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c oldApp = new Application__c();
        oldApp.Pre_Login__c = preLogin.Id;
        oldApp.Sourcing_Branch__c = branch.ID;
        oldApp.Stage__c = 'Login';
        oldApp.application_status__c = 'Active';
        oldApp.Requested_Loan_Amount__c = 300000;
        oldApp.Loan_Amount__c = 100000;
        oldApp.LMS_Response_Reference__c = '8984734334';
        oldApp.EMI__c = 10000;
        oldApp.Tranche_Disbursal__c = 'I';
        insert oldApp;
        
        Application__c app = new Application__c();
        app.Old_Application__c = oldApp.Id;
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Login';
        app.application_status__c = 'Active';
        app.Requested_Loan_Amount__c = 300000;
        app.Loan_Amount__c = 100000;
        app.Created_From_Batch__c = true;
        //app.LMS_Response_Reference__c = '8984734334';
        app.EMI__c = 10000;
        insert app;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FS Platform User Profile'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert u;
        
        Property__c pro = new Property__c();
        pro.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId();
        pro.Application__c = app.Id;
        pro.Title_Deed_Number__c = '2321';
        pro.Title_Deed_Date__c = Date.today();     
        insert pro;
    }
}