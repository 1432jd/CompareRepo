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
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        Account ci2 = new account();
        ci2.Name = 'Testname';
        insert ci2;
        
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd', Mandate_Req_ID__c = 'APItest0123457791010116');
        insert appObj;
        
        Property__c prop2 = new Property__c();
        prop2.Application__c =appObj.Id;
        prop2.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId(); 
        prop2.Survey_Number__c = '233432';
        prop2.Plot_No__c = '234324';
        prop2.Property_Number__c = '234232';
        prop2.Village__c = 'Testing';
        prop2.District__c = 'Agra';
        insert prop2;
        
        Property__c prop1 = new Property__c();
        prop1.Application__c =appObj.Id;
        prop1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('AC Property Detail').getRecordTypeId(); 
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        prop1.Property__c = prop2.Id;
        insert prop1;
        
        
        
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = appObj.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        insert l;
        
         Loan_Applicant__c l1 = new Loan_Applicant__c();
        l1.Application__c = appObj.Id;
        l1.Customer_Type__c ='Guarantor';
        l1.Residence_Address_Line_1__c = 'wewe';
        l1.Customer_Information__c = ci2.id; 
        insert l1;
        
        Property_Owners__c po = new Property_Owners__c();
        po.Property__c = prop2.Id;
        insert po;
        
        Character__c charObj1 = new Character__c();
        charObj1.Name_of_party__c = 'Family Detail';
        insert charObj1;
        Character__c charObj2 = new Character__c();
        charObj2.Name_of_party__c = 'Neighbour Detail';
        charObj2.PC_Record_Id__c = charObj1.Id;
        insert charObj2;
    }
    
    @isTest
    public static void testMainMethod(){
        Loan_Applicant__c la = [Select Id from Loan_Applicant__c Limit 1];
        Property__c propRecord = new Property__c();
        propRecord = [SELECT Id FROM Property__c  LIMIT 1 ];
        Property_Owners__c po = [ Select Id from Property_Owners__c  Limit 1];
        
        GenericUtility.deleteSelectedRecord('Prelogin',propRecord.ID,'Property__c');
        
    }
    
    @isTest
    public static void testMainMethod2(){
        Loan_Applicant__c la = [Select Id from Loan_Applicant__c WHERE Customer_Type__c ='Primary Applicant' Limit 1];
        Application__c applicationRecord = new Application__c();
        applicationRecord = [SELECT Id, NACH_Party_1_ID__c FROM Application__c LIMIT 1];
         Property__c propRecord = new Property__c();
        propRecord = [SELECT Id FROM Property__c  LIMIT 1];
        applicationRecord.NACH_Party_1_ID__c = la.ID;
        applicationRecord.NACH_Party_2_ID__c = 'la.Id';
        update applicationRecord;
        GenericUtility.deleteSelectedRecord('Prelogin',la.ID,'Loan_Applicant__c');
    }
    
    @isTest
    public static void testMainMethod3(){
        Loan_Applicant__c la = [Select Id from Loan_Applicant__c Limit 1];
        Application__c applicationRecord = new Application__c();
        applicationRecord = [SELECT Id,NACH_Party_2_ID__c FROM Application__c LIMIT 1];
        Character__c charObj = [Select id from Character__c WHERE Name_of_party__c = 'Family Detail' Limit 1];
        
        applicationRecord.NACH_Party_2_ID__c = la.Id;
        GenericUtility.deleteSelectedRecord('Process Credit',charObj.ID,'Character__c');
        
    }
    
    @isTest
    public static void testMainMethod4(){
        List<Loan_Applicant__c> la = [Select Id from Loan_Applicant__c  Limit 2];
        Application__c applicationRecord = new Application__c();
        applicationRecord = [SELECT Id, NACH_Party_1_ID__c FROM Application__c LIMIT 1];
         Property__c propRecord = new Property__c();
        propRecord = [SELECT Id FROM Property__c  LIMIT 1];
        applicationRecord.NACH_Party_1_ID__c = la[0].ID;
        applicationRecord.NACH_Party_2_ID__c = la[1].Id;
        update applicationRecord;
        GenericUtility.deleteSelectedRecord('Prelogin',la[1].Id,'Loan_Applicant__c');
        GenericUtility.deleteSelectedRecord('Approval Credit',la[1].Id,'');
    }
}