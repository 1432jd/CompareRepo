@isTest
public class KotakCalculateAPITest {
    

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
        
        Fee_Creation__c fee = new Fee_Creation__c();
        fee.Application__c = appObj.Id;
        fee.Fee_Code__c = 'Cersai';
        insert fee;
    }

 @isTest
    public static void testKotakCalculate1(){
        Application__c applicationRecord = new Application__c();
        applicationRecord = [SELECT Id FROM Application__c LIMIT 1];
        Fee_Creation__c fc = [Select Id From Fee_Creation__c Limit 1];
        Test.startTest();
        KotakCalculateAPI.callKotakCalculateAPI(fc.Id,200);
        Test.stopTest();
        
    }    
    
     @isTest
    public static void testKotakCalculate2(){
        Application__c applicationRecord = new Application__c();
        applicationRecord = [SELECT Id FROM Application__c LIMIT 1];
        Fee_Creation__c fc = [Select Id From Fee_Creation__c Limit 1];

        Test.startTest();
        KotakCalculateAPI.callKotakCalculateAPI(fc.Id+'123asds',200);
        Test.stopTest();
        
    }  

}