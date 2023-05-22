@isTest
public class ApplicantDocumentGeneratorControllerTest {
    
    @TestSetup
    public static void testSetup(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Account acc = new Account();
        acc.LastName = 'testacc';
        acc.PersonBirthdate = system.today();
        insert acc;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Login';
        app.application_status__c = 'Active';
        app.Requested_Loan_Amount__c = 300000;
        app.Loan_Amount__c = 100000;
        app.EMI__c = 10000;
        insert app;
        
        Loan_Applicant__c loan1 = new Loan_Applicant__c();
        loan1.Application__c = app.Id;
        loan1.Customer_Information__c = acc.Id;
        loan1.Residence_Address_Line_1__c = 'testaddress1';
        loan1.Application__c = app.Id;
        insert loan1;
        
        Id agreRecordTypeId = Schema.SObjectType.Agreement_Execution_Document_Generation__c.getRecordTypeInfosByName().get('Schedule A').getRecordTypeId();
        Agreement_Execution_Document_Generation__c ag = new Agreement_Execution_Document_Generation__c();
        ag.Application__c = app.Id;
        ag.RecordTypeId = agreRecordTypeId;
        ag.Document_Type__c = 'MOD';
        insert ag;
        
        Id agreRecordTypeId2 = Schema.SObjectType.Agreement_Execution_Document_Generation__c.getRecordTypeInfosByName().get('Vernacular / LTI Declaration').getRecordTypeId();
        Agreement_Execution_Document_Generation__c ag2 = new Agreement_Execution_Document_Generation__c();
        ag2.Application__c = app.Id;
        ag2.RecordTypeId = agreRecordTypeId2;
        ag2.Document_Type__c = 'Property Document';
        insert ag2;
        
        Capability__c capObj = new Capability__c();
        capObj.Application__c = app.Id;
        capObj.Loan_Applicant__c = loan1.Id;
        capObj.Nature_of_Job__c = 'Engineer';
        capObj.Income_segment__c = 'Eateries';
        capObj.Income_per_day__c = 600;
        capObj.Number_of_days__c = 14;
        capObj.Day_Margin_Basis__c = 'Margin Basis';
        capObj.Electricity__c = 300;
        capObj.Salary__c = 320;
        capObj.Rent__c = 300;
        capObj.Others__c = 450;
        //  capObj.Verification__c = verifi1.Id;
        capObj.RecordTypeId = Schema.SObjectType.Capability__c.getRecordTypeInfosByName().get('AC Capability').getRecordTypeId();
        insert capObj;
    }
    
    @isTest
    public static void testMethod1() {
        Loan_Applicant__c loan = [Select ID from Loan_Applicant__c Limit 1];
        Agreement_Execution_Document_Generation__c agree = [SELECT ID,Document_Type__c FROM Agreement_Execution_Document_Generation__c WHERE Document_Type__c = 'MOD'];
        Capability__c capObj = [Select Id from Capability__c Limit 1];
        Application__c applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('recordId', String.valueOf(loan.Id));
        ApplicantDocumentGeneratorController  testAccPlan = new ApplicantDocumentGeneratorController();
        ApplicantDocumentGeneratorController.generateApplicantAgreementExecutionDocs(applicationRecord.ID);
        Test.StopTest();
    }
    
    @isTest
    public static void testMethod2() {
        Loan_Applicant__c loan = [Select ID from Loan_Applicant__c Limit 1];
        Agreement_Execution_Document_Generation__c agree = [SELECT ID,Document_Type__c FROM Agreement_Execution_Document_Generation__c WHERE Document_Type__c = 'Property Document'];
        Capability__c capObj = [Select Id from Capability__c Limit 1];
        Application__c applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('recordId', String.valueOf(loan.Id));
        ApplicantDocumentGeneratorController  testAccPlan = new ApplicantDocumentGeneratorController();
        testAccPlan.getWitness(applicationRecord.ID);
        Test.StopTest();
    }
}