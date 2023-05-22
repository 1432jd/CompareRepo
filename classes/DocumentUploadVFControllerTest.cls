@isTest
public with sharing class DocumentUploadVFControllerTest {
    
    @TestSetup
    public static void makeData(){
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        Application__c app1 = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',LMS_Response_Reference__c='asds',application_status__c='Active', EMI__c=23443, Loan_Amount__c =2334, Nach_Party__c='sdssd', Nach_Party_2__c='sdssd'); 
        insert app1;
        
        ContentVersion cv1 = new ContentVersion(Title = 'Pdf', Is_Additional_Document__c = false, Parent_Id__c = app1.id, ContentUrl ='www.test.com', Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = false, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Application', Current_Record_Id__c = '1234567');
        insert cv1;
    }
    
    @isTest
    public static void deleteRecordTest(){
        Deferral_Document__c deferral_documentObj = new Deferral_Document__c(
            Deferral_Stage__c = 'FIV - B',
            Document_Name__c = 'Login Fee Receipt',
            Mandatory__c = 'Yes',
            Type__c = 'Application',
            Deferral_Date__c = Date.valueOf('2023-03-01'),
            Deferred_From__c = 'Login',
            Is_Document_Received__c = true,
            Remarks__c = 'ok',
            Status__c = 'Deferred',
            Uploaded_From__c = 'Login',
            isDeferred__c = true);
        insert deferral_documentObj;
        DocumentUploadVFController.cvType = 'Application';
		DocumentUploadVFController.deferalRecordId = deferral_documentObj.Id;        
        DocumentUploadVFController.deleteRecord();
        DocumentUploadVFController.updateDefferalDocument();
    }
}