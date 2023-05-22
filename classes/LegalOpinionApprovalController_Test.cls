@isTest
public class LegalOpinionApprovalController_Test {
	@TestSetup
    static void testData(){
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.AC_Submission_Date__c = date.today()-10;
        app.AC_Decision__c = 'Approve';
        app.AC_Remarks__c = 'Test';
        app.Stage__c = 'Final Sanction';
        app.Applicant_Name__c = 'testapp';
        insert app;  
        
        Id legalRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        Id onlineECRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Online EC Property Detail').getRecordTypeId();
        Id FIVCRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId(); 
        
        List<Property__c> propList = new List<Property__c>();
        Property__c prop = new Property__c();
        prop.Application__c = app.Id; 
        prop.RecordTypeId = legalRecordTypeId; 
        prop.Is_Legal_Updated__c = true;
        prop.Title_Document_in_Name_of__c = 'test';
        prop.Title_Deed_Number__c = '233432';
        prop.Title_Deed_Date__c = date.today() - 10;
        prop.Document_Type__c = 'Sale Deed';
        prop.Survey_Number__c = '12313';
        prop.Plot_No__c = '1231';
        propList.add(prop);
        
        Property__c prop1 = new Property__c();
        prop1.Application__c =app.Id;
        prop1.RecordTypeId = onlineECRecordTypeId;
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        propList.add(prop1);
        
        Property__c prop2 = new Property__c();
        prop2.Application__c = app.Id;
        prop2.RecordTypeId = FIVCRecordTypeId;
        prop2.Title_Deed_Number__c = '2424324';
        prop2.Document_Type__c = 'Sale Deed';
        prop2.Extent_Sqft__c = 32964;
        propList.add(prop2);
        insert propList;
        String st = Json.serialize(propList);
       
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Image';
        cv.PathOnClient = 'Test_Image.jpg';
        cv.File_Type__c = 'Legal Approval Cam Report';
        cv.VersionData = Blob.valueOf('Test Image Data');
        cv.FirstPublishLocationId = app.Id;
        cv.IsMajorVersion = true;
        insert cv;
        
        Legal_Approval__c legal = new Legal_Approval__c();
        legal.Application__c = app.Id;
        legal.Status__c = 'Completed';
        insert legal;
        
 		Id acRecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('AC').getRecordTypeId(); 
        
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
        ver.RecordTypeId = acRecordTypeId;
        ver.Status__c = 'Completed';
        insert ver;
    }
    @isTest
    static void legalTest(){
        Application__c app = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'testapp'];
		Property__c prop = [SELECT Id,Is_Legal_Updated__c FROM Property__c WHERE Is_Legal_Updated__c = true];
		Property__c prop1 = [SELECT Id,District__c FROM Property__c WHERE District__c = 'Agra'];
		Property__c prop2 = [SELECT Id,Extent_Sqft__c FROM Property__c WHERE Extent_Sqft__c = 32964];
		ContentVersion cv = [SELECT Id,Title,PathOnClient,FirstPublishLocationId FROM ContentVersion WHERE Title = 'Test Image' AND PathOnClient = 'Test_Image.jpg'];
        List<Property__c> propList = new List<Property__c>([SELECT Id FROM Property__c LIMIT 1]);
        Legal_Approval__c legal = [SELECT Id,Status__c FROM Legal_Approval__c WHERE Status__c = 'Completed'];
        test.startTest();
        LegalOpinionApprovalController.getPropertyTableData(app.Id);
        LegalOpinionApprovalController.getExternalLawyerTableData();
        LegalOpinionApprovalController.moveToNextStage(app.Id);
        LegalOpinionApprovalController.getExternalLawyer();
        LegalOpinionApprovalController.getPropertyDetails(prop.Id);
        LegalOpinionApprovalController.getPropertyDetails(prop1.Id);
        LegalOpinionApprovalController.getPropertyDetails(prop2.Id);
        LegalOpinionApprovalController.getProperties(app.Id);
        LegalOpinionApprovalController.handleLegalApprovalSubmit(app.Id, legal.Id);
        LegalOpinionApprovalController.updateProperties(Json.serialize(propList));
        LegalOpinionApprovalController.saveLegalApprovalProperty(Json.serialize(legal));
        LegalOpinionApprovalController.generateLegalCamReport(app.Id);
        test.stopTest();
    }
}