@IsTest
public class DocumentGenerationVFControllerTest {
    @TestSetup
    public static void testSetup(){

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        List<Branch_Master__c> branchList = new List<Branch_Master__c>();
        Branch_Master__c br = new Branch_Master__c();
        br.Branch_Address_Line_2__c = 'ww';
        br.Branch_City__c = 'ee';
        br.State__c = 'wwe';
        br.Branch_Pincode__c = '21ew';
        branchList.add(br);
        
        Branch_Master__c br1 = new Branch_Master__c();
        br1.Branch_Address_Line_1__c = 'ww';
        br1.Branch_City__c = 'ee';
        br1.State__c = 'wwe';
        br1.Branch_Pincode__c = '21ew';
        branchList.add(br1);
        
        Branch_Master__c br2 = new Branch_Master__c();
        br2.Branch_Address_Line_3__c = 'ww';
        br2.Branch_City__c = 'ee';
        br2.State__c = 'wwe';
        br2.Branch_Pincode__c = '21ew';
        branchList.add(br2);
        
        Branch_Master__c br3 = new Branch_Master__c();
        br3.Branch_Address_Line_3__c = 'ww';
        br3.Branch_City__c = 'ee';
        br3.State__c = 'wewwe';
        br3.Branch_Pincode__c = '21ew';
        branchList.add(br3);
        insert branchList;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        app.Balance_Transfer__c ='Institution';
        app.Tranche_Disbursal__c = 'II';
        app.Sourcing_Branch__c = br.Id;
        app.Sourcing_Branch__c = br1.Id;
        app.Sourcing_Branch__c = br2.Id;
        app.Sourcing_Branch__c = br3.Id;
        app.AC_Remarks__c = 'a';
        app.AC_Submission_Date__c = date.today();
        insert app;
        
        Account accountObj = new Account(
            //Name = 'simi Mishra',
            LastName = 'Mishra',
            FirstName = 'simi',
            Salutation = 'Ms.',
            RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            PersonBirthdate = Date.valueOf('2012-07-31'),
            Father_s_Name__c = 'Test Father',
            Gender__c = 'Female');
        insert accountObj;
		
        Property__c propObj = new Property__c();
        propObj.Application__c = app.Id;
        propObj.Village__c ='testing';
        propObj.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        insert propObj;
        
        MS_Pincode__c ms = new MS_Pincode__c();
        ms.City__c = 'ss';
        insert ms;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Type__c = 'Primary Applicant';
        loanApp.Customer_Information__c = accountObj.Id;
        loanApp.Residence_Pincode__c = ms.id;
        loanApp.Residence_Address_Line_1__c = 'eadade';
        loanApp.Residence_City__c = 'sdf';
        loanApp.Residence_State__c = 'ssfesdf';
        insert loanApp;
        
        Agreement_Execution_Document_Generation__c objAG = new Agreement_Execution_Document_Generation__c();
        objAg.Application__c = app.Id;
        objAg.Borrower__c = 'ss';
        objAg.RecordTypeId = Schema.SObjectType.Agreement_Execution_Document_Generation__c.getRecordTypeInfosByName().get('Schedule A').getRecordTypeId();
        insert objAg; 
    }

    @IsTest
    public static void test(){
        Application__c app = [SELECT Id,AC_Remarks__c FROM Application__c WHERE AC_Remarks__c = 'a'];
        Property__c prop = [SELECT Id,Village__c FROM Property__c WHERE Village__c ='testing'];
        Loan_Applicant__c loan = [SELECT Id,Customer_Type__c FROM Loan_Applicant__c WHERE Customer_Type__c = 'Primary Applicant'];
        Agreement_Execution_Document_Generation__c ag = [SELECT Id,Borrower__c FROM Agreement_Execution_Document_Generation__c WHERE Borrower__c = 'ss'];
        Test.startTest();
		DocumentGenerationVFController.generateAgreementExecutionDocs(app.Id);
        PageReference pageRef = Page.DPN;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('recordId', String.valueOf(app.Id));
        DocumentGenerationVFController ape = new DocumentGenerationVFController();
        ape.getPrimaryApplicant(app.Id);
        ape.getPropertyDetails(app.Id);
       	ape.getTitleDeedNumber(prop.Id);
        Test.stopTest();
    }
}