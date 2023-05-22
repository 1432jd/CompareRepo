@isTest
public class FIV_C_ControllerNewTest {

     @TestSetup
    static void createTestData() {
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Loan_Amount__c = 100000;
        app.Requested_Loan_Amount__c = 100000;
        insert app;
        
        //Application for if fee already exist 
        Application__c app1 = new Application__c();
        app1.Pre_Login__c = preLogin.Id;
        app1.Loan_Amount__c = 100000;
        
        insert app1;
        // application if there is no fee and requested loan amount is null
        Application__c app2 = new Application__c();
        app2.Pre_Login__c = preLogin.Id;
        app2.Loan_Amount__c = 100000;
        
        insert app2;
        
        Account acc = new Account();
        acc.Pre_Login__c = preLogin.Id;
        acc.LastName = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Property__c pro = new Property__c();
        pro.Application__c = app.Id;
        pro.Login__c = preLogin.Id;
        pro.Customer_Information__c = acc.Id;
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.Application__c = app.Id;
        pro1.Login__c = preLogin.Id;
        pro1.Customer_Information__c = acc.Id;
        insert pro1;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        
        insert loanApp;
        Verification__c objVerification = new Verification__c();
        //objVerification.Name = 'FIV-B';
        objVerification.Application__c = app.Id;
        insert objVerification;    
    }
    
    @isTest
    public static void methodOne(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c Limit 1];
        FIV_C_ControllerNew.getSectionContent('12123', '123');
        FIV_C_ControllerNew.getCharacterTabRecords('123','123','123');
        FIV_C_ControllerNew.saveRecord(loanApp);
    }
    
}