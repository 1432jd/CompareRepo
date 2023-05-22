@isTest
public class OnlineEcReportControllerTest {
    
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
        
        Property__c prp = new Property__c();
        prp.Login__c= login1.Id;
        prp.Customer_Information__c= acc.Id;
        prp.Address_Line_2__c = 'Testing';
        insert prp;
        
        Application__c app= new Application__c();
        //    app.External_Lawyer__c = acc.Id;
        app.Applicant_Name__c = 'Application';
        app.Pre_Login__c = login1.Id;
        insert app;
        
    }
    @isTest
    static void testAllMethod(){
        Application__c application = [SELECT Id FROM Application__c WHERE Applicant_Name__c= 'Application'];
        
       /* Test.StartTest(); 
        PageReference pageRef = Page.success;
    Test.setCurrentPage(pageRef);
pageRef.getParameters().put('Id',Org_Info__c.id);
        //ApexPages.StandardController sc = new ApexPages.StandardController(application);
        OnlineEcReportController oerc = new OnlineEcReportController();			*/
        
        Test.StopTest();
    }
    
}