/**
* @File Name          : fsGenericUploadDocumentsController_Test.cls
* @Description        : Service Class For fsGenericUploadDocuments Lightning Component
* @Author             : Mo Arslan
* @Created On         : 16-01-2023
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         16-01-2023              Mo Arslan               Initial Version
*/
@isTest
public with sharing class FsDeferalDocumentTest {
    @TestSetup
    static void testData(){
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        Application__c app1 = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',LMS_Response_Reference__c='asds',application_status__c='Active', EMI__c=23443, Loan_Amount__c =2334, Nach_Party__c='sdssd', Nach_Party_2__c='sdssd'); 
        insert app1;
        
        ContentVersion cv1 = new ContentVersion(Title = 'Pdf', Is_Additional_Document__c = false, Parent_Id__c = app1.id, ContentUrl ='www.test.com', Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = false, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Application');
        insert cv1;
        ContentVersion cv2 = new ContentVersion(Title = 'Pdf', Is_Additional_Document__c = True, Parent_Id__c = app1.id, ContentUrl ='www.test.com',Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = true, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Applicant');
        insert cv2;
        ContentVersion cv3 = new ContentVersion(Title = 'Pdf', Is_Additional_Document__c = True, Parent_Id__c = app1.id, ContentUrl ='www.test.com',Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = true, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Asset');
        insert cv3;

        Document_Master__c dm1 = new Document_Master__c(Name='Test1', Active__c = 'Yes', Description__c='Test1', Family__c = 'Address Proof', Type__c ='Application');
        insert dm1;

        Document_Set_Code__c dsc1 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Application', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm1.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Family__c='Address Proof');
        insert dsc1;

        Deferral_Document__c dd1 = New Deferral_Document__c(Document_Set_Code__c = dsc1.id , Is_Document_Master_Record__c = true, Is_Deferral_Document__c= true, Deferral_Stage__c ='Lead Detail', Application__c= app1.id, Type__c='Application' );
        insert dd1;
        Deferral_Document__c dd2 = New Deferral_Document__c(Document_Set_Code__c = dsc1.id , Is_Document_Master_Record__c = false, Is_Deferral_Document__c= true, Deferral_Stage__c ='Lead Detail', Application__c= app1.id, Type__c='Applicant' );
        insert dd2;
        Deferral_Document__c dd3 = New Deferral_Document__c(Document_Set_Code__c = dsc1.id , Is_Document_Master_Record__c = true, Is_Deferral_Document__c= true, Deferral_Stage__c ='Lead Detail', Application__c= app1.id, Type__c='Asset' );
        insert dd3;
    }

    @isTest
    public static void getDeferalDocumentTest(){
        Application__c app1 = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        fsDeferalDocument.getDeferalDocument(app1.Id);
        Test.stopTest();
    }

    @isTest
    public static void getAllDefferalDocumentsTest(){
        Application__c app1 = [SELECT Id FROM Application__c limit 1];
        Deferral_Document__c dd1 =  [SELECT Id, Document_Set_Code__c, Is_Document_Master_Record__c, Is_Deferral_Document__c, Deferral_Stage__c, Application__c, Type__c FROM Deferral_Document__c limit 1];
        Test.startTest();
        fsDeferalDocument.getAllDefferalDocuments(app1.Id);
        fsDeferalDocument.updateDeferralRecord(JSON.serialize(dd1));
        Test.stopTest();
    }

    @isTest
    public static void uploadFileTest(){
        Application__c app1 = [SELECT Id FROM Application__c limit 1];
        Deferral_Document__c dd1 =  [SELECT Id, Document_Set_Code__c, Is_Document_Master_Record__c, Is_Deferral_Document__c, Deferral_Stage__c, Application__c, Type__c FROM Deferral_Document__c limit 1];
        Wrapper obj = new Wrapper();
        obj.applicationId = app1.Id;
        obj.documentDefId = dd1.Id;
        obj.documentName = 'Test';
        obj.status = 'Received';
        obj.receivedDate = System.today();
        obj.noOfPages = '2';
        obj.remarks = 'Test';
        Test.startTest();
        fsDeferalDocument.uploadFile('base64', 'Test', JSON.serialize(obj));
        Test.stopTest();
    }

    public class Wrapper{
        @AuraEnabled public String applicationId;   
        @AuraEnabled public String documentDefId;   
        @AuraEnabled public String documentName;   
        @AuraEnabled public String documentFamily;   
        @AuraEnabled public String status;   
        @AuraEnabled public Date receivedDate;   
        @AuraEnabled public String noOfPages;
        @AuraEnabled public String remarks;   
    }
}