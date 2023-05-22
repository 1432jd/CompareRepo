@IsTest
public class ReloginTopupControllerTest {
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
 //       agency.Pre_Login__c = preLogin.Id;
        agency.Name = 'test';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Courier Agency').getRecordTypeId();
        insert agency;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Type__c = 'Primary Applicant';
        loanApp.Customer_Information__c = agency.Id;
        loanApp.KYC_Id_1__c = 'ss';
        loanApp.KYC_Id_2__c = 'dsa';
        insert loanApp;
        
        Property__c propertyObj = new Property__c(
            Property_Type__c = 'Office',
            Title_Deed_Type__c = 'Settlement or Gift or Consent Deed',
            Title_Deed_Number__c = '12345',
            Title_Deed_Date__c = Date.valueOf('2022-07-05'),
            Property_Address__c = 'test address',
            Application__c = app.Id,
            hasRelatedRecords__c = true,
            Taluka__c = 'SGPGI',
            District__c = 'Lucknow',
            State__c = 'Uttar Pradesh',
            isPrimaryOwner__c = true);
        insert propertyObj;
        
        Property_Owners__c property_ownersObj = new Property_Owners__c(
            Loan_Applicant__c = loanApp.Id ,
            Property__c = propertyObj.Id);
        insert property_ownersObj;
        
        Property__c propertyObj1 = new Property__c(
            Property_Type__c = 'Office',
            Title_Deed_Type__c = 'Settlement or Gift or Consent Deed',
            Title_Deed_Number__c = '12345',
            Title_Deed_Date__c = Date.valueOf('2022-07-05'),
            Property_Address__c = 'test address',
            Application__c = app.Id,
            hasRelatedRecords__c = true,
            Property__c = propertyObj.Id,
            Taluka__c = 'SGPGI',
            District__c = 'Lucknow',
            State__c = 'Uttar Pradesh',
            isPrimaryOwner__c = true);
        insert propertyObj1;
        
        Disbursal__c disObj = new Disbursal__c();
        disObj.Application__c=app.id;
        disObj.Due_Date__c= date.today();
        disObj.First_Installment_Date__c=date.today();
        disObj.Interest_Start_Date__c=date.today();
        insert disObj;
        
    }
    
    @IsTest
    public static void test(){
        Application__c app = [SELECT Id, Name FROM Application__c limit 1];
        Test.startTest();
        ReloginTopupController.getApplications(app.Name, 'dsa', '', '3. Top-up loan');
        Test.stopTest();
    }
    
}