@isTest
public class PennyDropAPITest {
    @isTest
    public static void test(){
        Bank_Detail__c bank_detailObj = new Bank_Detail__c(
            Name = 'Test Bank test f',
            Bank_Account_Holder_Name__c = 'Tests',
            Account_Number__c = 'sdf',
            Account_Number_with_masking_digits__c = 'sfsdf',
            Account_Type__c = 'Current',
            Account_Opening_Date__c = Date.valueOf('2022-05-03'),
            Sample_Cheque_Taken__c = 'Yes',
            Branch_Name__c = 'sdf');
         insert bank_detailObj;
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;
        
        Disbursal__c disbursalObj = new Disbursal__c(
            Due_Date__c = Date.valueOf('2022-07-15'),
            Application__c = app.Id,
            Interest_Start_Date__c = Date.valueOf('2022-07-15'),
            First_Installment_Date__c = Date.valueOf('2022-08-15'),
            Loan_Amount_Sanctioned__c = 500,
            Sanctioned_Loan_Amount__c = 50,
            Final_Disbursal_Amount__c = 500,
            Disbursal_Beneficiary_Type__c = 'Multiple',
            Disbursal_Type__c = 'Part Disb',
            CKYC_ID_Number__c = '222',
            Disbursal_Maker_ID__c = 'EMP-001',
            First_Time_Right_FTR__c = 'Yes');
         insert disbursalObj;
        
        IFSC_Code_Master__c ifsc_code_masterObj = new IFSC_Code_Master__c(
            Name = 'SBIN0041059',
            Bank_Name__c = 'SBIN',
            Bank_Branch_Name__c = 'Chennai');
         insert ifsc_code_masterObj;
        
        Disbursal_Payee__c disbursal_payeeObj = new Disbursal_Payee__c(
            Payment_Type__c = 'Cheque',
            Disbursal__c = disbursalObj.Id,
            Beneficiary_Amount__c = 2222,
            Beneficiary_Name__c = 'Karan',
            Beneficiary_Bank_Account_Number__c = 'Test',
            Beneficiary_IFSC_Code__c = ifsc_code_masterObj.Id,
            Beneficiary_Bank_Name__c = 'SBI',
            Beneficiary_Branch_Name__c = 'SBI',
            Beneficiary_Type__c = 'Disbursement Party Name');
         insert disbursal_payeeObj;
        
        Test.startTest();
        PennyDropAPI.callPennyDropAPI(String.valueOf(bank_detailObj.Id));
        PennyDropAPI.callPennyDropAPI(String.valueOf(disbursal_payeeObj.Id));
        Test.stopTest();
    }
}