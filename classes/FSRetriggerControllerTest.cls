@isTest
public class FSRetriggerControllerTest {
    
    @testSetup
    public static void testSetup(){
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.Applicant_Name__c = 'Testapp';
        app.Stage__c = 'Process Credit';
        insert app;
        
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
        ver.Name__c = 'verify1';
        ver.OwnerId = userInfo.getUserId();
        ver.Initiate_From__c = 'Process Credit';
        ver.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('Online EC').getRecordTypeId();
        insert ver;
    }
    
    @isTest
    public static void testMethod1(){
        Application__c application = [SELECT Id ,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'Testapp'];
        Verification__c ver = [Select Id, OwnerId,Application__c,Initiate_From__c ,RecordType.DeveloperName from Verification__c Limit 1];
        
        FSRetriggerController.createVerification(application.Id, ver.Initiate_From__c,  ver.RecordType.DeveloperName);
        FSRetriggerController.getPreviousVerificationOwner(application.Id, ver.RecordType.DeveloperName);
    }
        @isTest
    public static void testMethod2(){
        Application__c application = [SELECT Id ,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'Testapp'];
        Verification__c ver = [Select Id, OwnerId,Application__c,Initiate_From__c ,RecordType.DeveloperName from Verification__c Limit 1];
        ver.Status__c = 'Completed';
        update ver;
        FSRetriggerController.createVerification(application.Id, ver.Initiate_From__c,  ver.RecordType.DeveloperName);
        FSRetriggerController.getPreviousVerificationOwner(application.Id, ver.RecordType.DeveloperName);
    }
    
}