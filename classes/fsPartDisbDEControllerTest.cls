@isTest
public with sharing class fsPartDisbDEControllerTest {
    
    @TestSetup
    static void createTestData() {
        Application__c app1 = new Application__c();
        app1.Applicant_Name__c = 'JD_1';
        app1.File_Inward_Status__c = 'Pending';
        app1.Remarks__c = 'ss';
        app1.Stage__c ='File Inward';
        insert app1;
        
        Deferral_Document__c objDefDoc = new Deferral_Document__c();
        objDefDoc.Document_Name__c = 'TestDocument Name';
        objDefDoc.Status__c = 'Deferred';
        insert objDefDoc;

    }

    @isTest
    static void testAllMethod(){

        List<Application__c> appList = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'JD_1'];
        test.startTest();
        fsPartDisbDEController.updateApptStageFromDE(appList[0].id);
        fsPartDisbDEController.updateApptStageFromDE('');
        test.stopTest();

    }
}