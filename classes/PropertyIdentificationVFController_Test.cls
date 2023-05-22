@isTest
public class PropertyIdentificationVFController_Test {
    @TestSetup
    public static void testSetup(){
        Account accObj = new Account();
        accObj.Name = 'Test account name';
        insert accObj;
        
        Application__c app = new Application__c();
        app.Stage__c = 'Agreement Execution';
        insert app;
        
        Property__c propObj = new Property__c();
        propObj.Application__c = app.Id;
        propObj.Village__c ='testing';
        propObj.East_by_land_measurements__c =565656;
        propObj.West_by_land_measurements__c =32176;
        propObj.North_by_land_measurements__c =32421;
        propObj.South_by_land_measurements__c =234821;
        propObj.East_By_Land_Physical__c =321468;
        propObj.West_By_Land_Physical__c =324243;
        propObj.North_By_Land_Physical__c =32487;
        propObj.South_By_Land_Physical__c =32847;
        propObj.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        insert propObj;
        
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Mobile__c = '9836726762';
        loanAppObj.Mobile_Verified__c = True;
        loanAppObj.Application__c = app.Id;
        loanAppObj.Customer_Information__c = accObj.Id;
        insert loanAppObj;
        
    }
    
    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Property__c prop = [SELECT Id,Village__c FROM Property__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.PropertyIdentificationUndertakingVF;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getParameters().put('recordId',prop.Id);
        PropertyIdentificationVFController obj = new PropertyIdentificationVFController();
        Test.stopTest();
    }
}