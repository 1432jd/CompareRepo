@isTest public class FS_PreLoginController_Test {
    @Testsetup
    public static void testsetup(){
        Account acc = new Account(Name='Test');
        
        RecordType rt = new RecordType(DeveloperName = 'New login',Name = 'New login',SObjectType = 'Pre_Login__c');
      
        Pre_Login__c listlogin = new Pre_Login__c();
        Pre_Login__c login1= new Pre_Login__c(Status__c='Active',RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId());
        Pre_Login__c login2= new Pre_Login__c(Status__c='Rejected',RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId());
        insert login1;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = login1.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;
       
        
        Property__c prp = new Property__c();
        prp.Login__c= login1.Id;
        prp.Customer_Information__c= acc.Id;
        insert prp;
     
    } 
    @isTest
    public static void testMethod1(){
      Pre_Login__c  PreLogin= [Select id,RecordTypeId from Pre_Login__c limit 1];
        Test.startTest();
        FS_PreLoginController.getApplicationId(PreLogin.Id);
        Test.stopTest();
    }
    
}