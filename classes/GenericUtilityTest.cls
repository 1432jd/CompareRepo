@isTest
public class GenericUtilityTest {

     @TestSetup
    static void createTestData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        insert preLogin;
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd', Mandate_Req_ID__c = 'APItest0123457791010116');
        insert appObj;
        
        Property__c prop1 = new Property__c();
        prop1.Application__c =appObj.Id;
        prop1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('AC Property Detail').getRecordTypeId(); 
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        insert prop1;
    }
    
    @isTest
    public static void testMainMethod(){
       
        Property__c applicationRecord = new Property__c();
        applicationRecord = [SELECT Id FROM Property__c LIMIT 1];
    
    GenericUtility.deleteSelectedRecord('Prelogin',applicationRecord.ID,'Property__c');

    }
    
       @isTest
    public static void testMainMethod2(){
       
        Property__c applicationRecord = new Property__c();
        applicationRecord = [SELECT Id FROM Property__c LIMIT 1];
    
    GenericUtility.deleteSelectedRecord('Prelogin',applicationRecord.ID,'asd');

    }
    
        @isTest
    public static void testMainMethod3(){
       
        Property__c applicationRecord = new Property__c();
        applicationRecord = [SELECT Id FROM Property__c LIMIT 1];
    
    GenericUtility.deleteSelectedRecord('Prelog',applicationRecord.ID,'asd');

    }
}