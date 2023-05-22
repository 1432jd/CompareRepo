@IsTest
public class ReceiptGenerationVFControllerTest {
    @TestSetup
    public static void testSetup(){
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;
		
		Fee_Creation__c fee = new Fee_Creation__c();
        fee.Fee_Code__c = 'we';
        insert fee;
	        
        Receipt__c receiptObj = new Receipt__c(
            Receipt_Date__c = Date.valueOf('2022-08-05'),
            Amount__c = 250545556.688,
            Pre_Login__c = preLogin.Id,
            Application__c = app.Id,
            Mode_of_payment__c = 'Cash',
            Approval_Status__c = 'Submitted',
            Customer_name__c = 'Ankur Sharma',
            Loan_Purpose__c = 'test',
        	Customer_Information__c = ci.Id,
        	Fee_Code__c = fee.id);
        insert receiptObj;
        
        Receipt__c receiptObj1 = new Receipt__c(
            Receipt_Date__c = Date.valueOf('2022-08-05'),
            Amount__c = 250545550.688,
            Pre_Login__c = preLogin.Id,
            Application__c = app.Id,
            //Mode_of_payment__c = 'Cash',
            Approval_Status__c = 'Submitted',
            Customer_name__c = 'Ankur Sharma',
            Loan_Purpose__c = 'test');
        insert receiptObj1;
        
        List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = app.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        insert l;
    }
    
    @isTest
    public static void test(){
        Receipt__c rece = [SELECT Id,Mode_of_payment__c FROM Receipt__c WHERE Mode_of_payment__c='Cash'];
        
        Test.startTest();
        PageReference pageRef = Page.ReceiptGenerationVF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('recId', String.valueOf(rece.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(rece);
        ReceiptGenerationVFController obj = new ReceiptGenerationVFController();
        //CourierControlSheetVfCtrl.guarantorContactRole(opp.Id);
        Test.stopTest();
    }
}