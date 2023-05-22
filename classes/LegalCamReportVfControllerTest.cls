@isTest
public class LegalCamReportVfControllerTest {
	@TestSetup
    public static void testSetup(){
        Application__c app = new Application__c();
        app.Sub_Stage__c = 'Legal Approval';
        app.Any_Approval_to_be_Obtained__c = 'Yes';
        app.EMI__c = 100;
        app.Legal_Summary_Remarks__c = 'test';
        insert app;
        
        Property__c propObj = new Property__c();
        propObj.Applicant__c = app.Id;
        propObj.Village__c ='testing';
        propObj.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        insert propObj;
    }
    
    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Property__c prop = [SELECT Id,Village__c FROM Property__c WHERE Village__c ='testing'];
        Test.startTest();
        PageReference pageRef = Page.LegalCamReport_VfPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(app.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(app);
        LegalCamReportVfController obj = new LegalCamReportVfController();
        Test.stopTest();
    }
}