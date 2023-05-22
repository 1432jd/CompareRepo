@IsTest
public class fsHighmarkObligationsScreenTest {
    @TestSetup
    public static void testSetup(){
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Login';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;
        
        Verification__c verifi = new Verification__c();
        verifi.Name__c = 'Test';
        verifi.Status__c = 'Completed';
        verifi.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verifi.Application__c = app.Id;
        insert verifi;

        Character__c characterObj = new Character__c(
            Living_Standard_Remarks__c = 'test',
            RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId(),
            Application__c = app.Id,
            Lifestyle__c = 'Average',
            Verification__c = verifi.Id,
            Section_Type__c = 'Repayment Behaviour Detail',
            Consumer_Durables__c = 'Flat TV');
        insert characterObj;
        
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
        
        Loan_Applicant__c loanApp1 = new Loan_Applicant__c();
        loanApp1.Application__c = app.Id;
        loanApp1.Customer_Type__c = 'Co-Applicant';
        loanApp1.Customer_Information__c = agency.Id;
        insert loanApp1;
        
        Bureau_Highmark__c bureau_highmarkObj = new Bureau_Highmark__c(
            Name = 'CHITRA T',
            DOB__c = Date.valueOf('1975-07-06'),
            Loan_Applicant__c = loanApp.Id,
            Address__c = 'NO: 25 NORTH STREET , MEALATHIRUPAMTHIRUTHI, THIRUVAIYARU , THANJAVUR THANJAVUR 613103 TN',
            MbrId__c = 'M12345',
            CreditInqPurpsType__c = 'ACCT-ORIG',
            creditInqPurpsTypDesc__c = 'Others',
            CreditInquiryStage__c = 'PRE-SCREEN',
            CreditRptId__c = 'CR12345',
            CreditReqType__c = 'INDV',
            CreditRptTrnDtTm__c = 'M12345');
         insert bureau_highmarkObj;

         Account_Summary__c account_summaryObj = new Account_Summary__c(
            Bureau_Highmark__c = bureau_highmarkObj.ID,
            Type__c = 'Bureau');
        insert account_summaryObj;
        
        Loan_Details__c loan_detailsObj = new Loan_Details__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId(),
            Bureau_Highmark__c = bureau_highmarkObj.Id,
            Account_Status__c = 'Savings',
            Type_Of_Loan__c = 'Property',
            Ownership__c = 'Self',
            Credit_Guarantor__c = 'Self',
            Inquiries_In_Last_Six_Months__c = 6);
            loan_detailsObj.Stage__c ='PC';
         insert loan_detailsObj;
    }

    @IsTest
    public static void test(){
        Verification__c verifi = [SELECT Id FROM Verification__c limit 1];
        Application__c app = [SELECT Id, Stage__c FROM Application__c limit 1];
        Test.startTest();
        fsHighmarkObligationsScreenController.getcharacterRepayment(verifi.Id, 'FIV-C Character');
        fsHighmarkObligationsScreenController.getRecordTypeId('Character__c', 'FIV-C Character');
        fsHighmarkObligationsScreenController.getHighmarkObligations(app.Id, 'PC');
        delete new Loan_details__c(Id=[SELECT Id FROM Loan_Details__c WHERE Account_Status__c ='Savings' LIMIT 1].Id);
        fsHighmarkObligationsScreenController.getHighmarkObligations(app.Id, 'PC');
        Test.stopTest();
    }
    
    @isTest
    public static void saveObligationsTest(){
        Loan_Applicant__c loanApp = [SELECT Id FROM Loan_Applicant__c limit 1];
        List<HighmarkObligationsWrapper> objList = new List<HighmarkObligationsWrapper>();
        HighmarkObligationsWrapper obj = new HighmarkObligationsWrapper();
        obj.srNo = 1;
        obj.isChanged = true;
        obj.IsSelfType = true;
        obj.loanApplicantId = loanApp.Id;
        objList.add(obj);
        Test.startTest();
        fsHighmarkObligationsScreenController.saveObligations(JSON.serialize(objList));
        Test.stopTest();
    }
    
    @isTest
    public static void saveObligationsTest1(){
        Loan_Applicant__c loanApp = [SELECT Id FROM Loan_Applicant__c WHERE Customer_Type__c = 'Co-Applicant' limit 1];
        List<HighmarkObligationsWrapper> objList = new List<HighmarkObligationsWrapper>();
        HighmarkObligationsWrapper obj = new HighmarkObligationsWrapper();
        obj.srNo = 1;
        obj.isChanged = true;
        obj.IsSelfType = true;
        obj.loanApplicantId = loanApp.Id;
        objList.add(obj);
        Test.startTest();
        fsHighmarkObligationsScreenController.saveObligations(JSON.serialize(objList));
        Test.stopTest();
    }
    
    @isTest
    public static void saveObligationsTest2(){
        Loan_Applicant__c loanApp = [SELECT Id FROM Loan_Applicant__c WHERE Customer_Type__c = 'Co-Applicant' limit 1];
        List<HighmarkObligationsWrapper> objList = new List<HighmarkObligationsWrapper>();
        HighmarkObligationsWrapper obj = new HighmarkObligationsWrapper();
        obj.srNo = 1;
        obj.isChanged = true;
        obj.IsSelfType = false;
        obj.loanApplicantId = loanApp.Id;
        objList.add(obj);
        Test.startTest();
        fsHighmarkObligationsScreenController.saveObligations(JSON.serialize(objList));
        Test.stopTest();
    }
        
    public class HighmarkObligationsWrapper{
        public Integer srNo;
        public Boolean isChanged;
        public Boolean IsSelfType;
        public String loanApplicantId;
    }
}