@IsTest
public class PropertyScheduleControllerTest {
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
        
        Account agency = new Account();
        //agency.Pre_Login__c = preLogin.Id;
        agency.Name = 'test';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Courier Agency').getRecordTypeId();
        insert agency;

        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Type__c = 'Primary Applicant';
        loanApp.Customer_Information__c = agency.Id;
        insert loanApp;
        
        Property__c propertyObj = new Property__c(
            Property_Type__c = 'Flat',
            Title_Deed_Type__c = 'Sale Deed',
            Title_Deed_Number__c = '12345',
            Title_Deed_Date__c = Date.valueOf('2022-08-01'),
            Property_Address__c = 'Agra',
            Application__c = app.Id,
            Collateral_Type__c = 'Commercial',
            Collateral_Sub_Type_Property_Details__c = 'Ready Property',
            Property_Location_Classification__c = 'Rural',
            Taluka__c = 'Kamlanagar',
            City__c = 'Agra',
            State__c = 'Uttar Pradesh'
        );
        insert propertyObj;
    }
    
    @isTest
    public static void test(){
        Property__c pro = [SELECT Id FROM Property__c limit 1];
        Test.startTest();
        PageReference pageRef = Page.PropertySchedulemismatchletter;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('recordId', String.valueOf(pro.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(pro);
        PropertyScheduleController ape = new PropertyScheduleController();
        //CourierControlSheetVfCtrl.guarantorContactRole(opp.Id);
        Test.stopTest();
    }
}