@isTest
public class OwnerChnageControllerTest {
  
    @TestSetup
    static void testdata(){
        Account acc = new Account();
        acc.LastName = 'test1';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Id NewLoginRecordType = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        Pre_Login__c listlogin = new Pre_Login__c();
        Pre_Login__c login1= new Pre_Login__c(Status__c='Active',RecordTypeId= NewLoginRecordType);
        Pre_Login__c login2= new Pre_Login__c(Status__c='Rejected',RecordTypeId = NewLoginRecordType);
        insert login1;
        
        Property__c prp = new Property__c();
        prp.Login__c= login1.Id;
        prp.Customer_Information__c= acc.Id;
        prp.Address_Line_2__c = 'Testing';
        insert prp;
        
        Application__c app= new Application__c();
        app.Applicant_Name__c = 'Application';
        app.Pre_Login__c = login1.Id;
        insert app;
        
        Verification__c verObj= new Verification__c();
        Id OnlineECRecordType = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verObj.RecordTypeId = OnlineECRecordType;
        verObj.Application__c= app.Id;
        verObj.Status__c = 'Pending';
        insert verObj;
    }
    
    @isTest
    static void testAllMethod(){
        Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
  		ChangeOwner__mdt changeOwnerMdt = [SELECT Id, sObject_Name__c, User_Designation__c, RecordType_Stage__c FROM ChangeOwner__mdt 
                                           where sObject_Name__c !=null AND RecordType_Stage__c != null Limit 1];
        Test.startTest();
        OwnerChnageController.getRecordTypeNameOfRecord('Pre_Login__c', preLogin.id);
        OwnerChnageController.getUserDesignation(changeOwnerMdt.RecordType_Stage__c,changeOwnerMdt.sObject_Name__c);
        OwnerChnageController.searchOwner('Ajay', 'Pre_Login__c', preLogin.id);
        OwnerChnageController.updateRecord(preLogin.id, UserInfo.getUserId());
        OwnerChnageController.updateRecordOwner(preLogin.id, UserInfo.getUserId(), 'Pre_Login__c', true);
        Test.stopTest();    
    }
    
    @isTest
    static void testAllMethod2(){
        Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
  		ChangeOwner__mdt changeOwnerMdt = [SELECT Id, sObject_Name__c, User_Designation__c, RecordType_Stage__c FROM ChangeOwner__mdt 
                                           where sObject_Name__c !=null AND RecordType_Stage__c != null Limit 1];
        Verification__c verification =  [SELECT Id,RecordType.Name FROM Verification__c WHERE RecordType.Name =:'FIV - C'];

        Test.startTest();
        OwnerChnageController.searchOwner('Ajay', 'Verification__c', verification.id);
        OwnerChnageController.updateRecord(verification.id, UserInfo.getUserId());
        OwnerChnageController.updateRecordOwner(preLogin.id, UserInfo.getUserId(), 'Pre_Login__c', false);
        Test.stopTest();
    }
}