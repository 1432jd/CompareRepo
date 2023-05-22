@IsTest
public class FetchDataTableRecordsControllerTest {
    @TestSetup
    public static void testSetup(){


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
            recordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId(),
            Title_Deed_Number__c = '123',
            Application__c = app.Id,
            Login__c = preLogin.Id,
            Building_Value_per_Sq_ft__c = 12,
            Land_Area_Sq_Ft__c = 56,
            Building_Area_Sq_Ft__c = 32,
            Pathway_Available__c = 'Yes',
            Valuation_Market_Value_Per_SqFt__c = 32,
            Document_Type__c = 'Gift Deed',
            Month__c = '12',
            Title_Deed_Year__c = '1201',
            Mortgage_Property_Area__c = 'Positive',
            Building_Constructed_with_Remarks__c = 'test',
            Building_Type__c = 'Others',
            Mortgage_property_distance_from_branch__c = 212,
            Land_area_valuation_remarks__c = 'ok test',
            Land_Ownership__c = 'Ancestral property',
            Building_Ownership__c = 'Vacant',
            Mortgage_property_Living_property_are__c = 'Yes',
            Property_Surrounding__c = '123',
            Overall_Land_Remarks__c = 'ok',
            Building_Floor__c = 'GF',
            Boundaries_As_Per_Inspection_Are_Same__c = 'Yes',
            Building_Age__c = 12,
            Type_Of_Property__c = 'Residential');
         insert propertyObj;
    }

    @IsTest
    public static void test(){
        Application__c app = [SELECT Id, Name FROM Application__c limit 1];
        Loan_Applicant__c loanApp = [SELECT Id FROM Loan_Applicant__c limit 1];
        List<String> loanApplcantId = new List<String>{loanApp.Id};

        Test.startTest();
        FetchDataTableRecordsController.getAccData(app.Id);
        FetchDataTableRecordsController.getPropertyData(app.Id, 'Pre Login Property Detail');
        FetchDataTableRecordsController.getPropertyOwners(loanApplcantId);
        FetchDataTableRecordsController.searchApplication(app.Name, '', '', '2. Re-login');
        FetchDataTableRecordsController.searchApplication(app.Name, '', '', '3. Top-up loan');
        FetchDataTableRecordsController.getFeeCreationDataTable(app.Id);
        Test.stopTest();
    }
}