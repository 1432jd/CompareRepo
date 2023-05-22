@isTest
public class FS_DocumentUploadControllerTest {
	@isTest 
    public static void checkDocuments(){
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
        Account acc = new Account(Name ='Test1', Type = 'Customer');
        insert acc;
        Document_Master__c dm1 = new Document_Master__c(Name='Test1', Active__c = 'Yes', Description__c='Test1', Family__c = 'Address Proof', Type__c ='Application');
        insert dm1;
        Document_Master__c dm2 = new Document_Master__c(Name='Test2',Active__c = 'Yes', Description__c='Test2', Family__c = 'Address Proof', Type__c ='Applicant');
        insert dm2;
        Document_Master__c dm3 = new Document_Master__c(Name='Test3',Active__c = 'Yes', Description__c='Test3', Family__c = 'Address Proof', Type__c ='Asset');
        insert dm3;
        
        Document_Set_Code__c dsc1 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Application', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm1.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Family__c='Address Proof');
        insert dsc1;
        Document_Set_Code__c dsc2 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Applicant', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm2.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Applicable_For__c = 'All', Income_Type__c = 'All');
        insert dsc2;
        Document_Set_Code__c dsc3 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Asset', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm3.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Asset_Type__c = 'All', Sub_Type__c = 'All');
        insert dsc3;
        
        Document_Set_Code__c dsc4 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Applicant', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm2.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Applicable_For__c = 'Primary Applicant', Income_Type__c = 'All');
        insert dsc4;
        Document_Set_Code__c dsc5 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Asset', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm3.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Asset_Type__c = 'Flat', Sub_Type__c = 'All');
        insert dsc5;
        
        Property__c pro = new Property__c();
        pro.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId();
        pro.Application__c = app1.Id;
        pro.Title_Deed_Number__c = '2321';
        pro.Property_Type__c = 'Flat';
        pro.Title_Deed_Date__c = Date.today();     
        insert pro;
        
        Loan_Applicant__c la = new Loan_Applicant__c();
        la.Application__c = app1.Id;
        la.Customer_Information__c = acc.ID;
        la.Customer_Type__c = 'Primary Applicant';
        insert la;        
        
        FS_DocumentUploadController.refreshRecords(app1.Id);  
        FS_DocumentUploadController.refreshRecords(app1.Id);  
        
        FS_DocumentUploadController.getAllDocuments(app1.Id, 'Application', '', 'Lead Detail');
        FS_DocumentUploadController.getAllDocuments(app1.Id, 'Applicant', la.Id, 'Lead Detail');
        FS_DocumentUploadController.getAllDocuments(app1.Id, 'Asset',pro.Id, 'Lead Detail');
        
        List<Deferral_Document__c> deferralDocument = [SELECT Id, Stage__c, Document_Name__c, Type__c, Loan_Applicant__c, Property__c, Applicable_For__c, Asset_Type__c, Status__c,
                                                       Document_Master__c, Related_Document_Set_Code__c, Document_Master__r.Active__c, Related_Document_Set_Code__r.Active__c
                                                       FROM Deferral_Document__c 
                                                       WHERE Application__c =: app1.Id];
        
        FS_DocumentUploadController.updateDeferralRecordDetail(JSON.serialize(deferralDocument.get(0)),'Lead Detail');
        FS_DocumentUploadController.getUploadedRecords(app1.Id, 'Lead Detail');
        List<ContentVersion> cv = [SELECT Id,ContentDocumentId FROM ContentVersion];
        FS_DocumentUploadController.coverClass();
    }
}