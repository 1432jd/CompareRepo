@IsTest
public class AcknowledgementSlipControllerTest {
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
        
        Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.Parent_Id__c = app.Id;
        cv.Document_Name__c = 'Test';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;
        
        Agreement_Execution_Acknowledgement_Slip__c slip = new Agreement_Execution_Acknowledgement_Slip__c();
        slip.Name = 'Test';
        slip.Application__c = app.Id;
        insert slip; 
    }
    
    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Agreement_Execution_Acknowledgement_Slip__c slip = [Select Id from Agreement_Execution_Acknowledgement_Slip__c Limit 1];
        
        Test.startTest();
        PageReference pageRef = Page.AcknowledgementSlipVf;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('applicationId', String.valueOf(app.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(app);
        AcknowledgementSlipController ape = new AcknowledgementSlipController();
        AcknowledgementSlipController.generateAcknowledgementSlip(app.Id);
        AcknowledgementSlipController.deleteSlipRecord(slip.ID);
        AcknowledgementSlipController.ListOfDocWrapper docWrap  = new AcknowledgementSlipController.ListOfDocWrapper();
        String json = '[{"Name":"Test1"}]';
        AcknowledgementSlipController.insertAcknowledgementSlipRecords(json);
        Test.stopTest();
    }
}