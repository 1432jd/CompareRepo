@IsTest
public class FsOnlineECControllerTest {
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
        
        Verification__c verifi = new Verification__c();
        verifi.Name__c = 'Test';
        verifi.Status__c = 'Completed';
        verifi.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('Online EC').getRecordTypeId();
        verifi.Application__c = app.Id;
        insert verifi;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=app.id;
        contentlink.ShareType= 'I';
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
    }

    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Verification__c vf = [SELECT Id FROM Verification__c limit 1];
        Test.startTest();
        FsOnlineECController.getCollateralDetails(app.Id);
        FsOnlineECController.getAllApplicantMeta(app.Id);
        FsOnlineECController.getVerification(vf.Id);
        //FsOnlineECController.getDocs(app.Id);
        Test.stopTest();
    }
}