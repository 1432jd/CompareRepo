/**
* @author            : Ashish Sharma
* @group             : TechMatrix Consulting
* @description       : This class will cover test coverage FS_LMS_CreateColletralAPI.
* @created on        : 08-09-2022
* @last modified on  : 08-09-2022
* @last modified by  : Ashish Sharma
**/
@IsTest
public class FS_LMS_CreateColletralAPITest {
    
	@TestSetup
    public static void setupPropertyData() {
        
        Id legalRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        Id onlineECRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Online EC Property Detail').getRecordTypeId();
        Id FIVCRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId(); 
        
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.Stage__c = 'Approval Credit';
        app.AC_Submission_Date__c = date.today()-10;
        app.AC_Decision__c = 'Approve';
        app.AC_Remarks__c = 'Test';
        app.Stage__c = 'Final Sanction';
        insert app;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        Loan_Applicant__c loanApplicant = new Loan_Applicant__c();
        loanApplicant.Application__c = app.Id;
        loanApplicant.Customer_Type__c ='Primary Applicant';
        loanApplicant.Residence_Address_Line_1__c = 'wewe';
        loanApplicant.Customer_Information__c = ci.id;
        insert loanApplicant;
        
        List<Property__c> propList = new List<Property__c>();
        Property__c prop = new Property__c();
        prop.Application__c = app.Id;
        prop.Current_Owner_Name__c = loanApplicant.Id;
        prop.Property_Location_Classification__c = 'Rural';
        prop.Property_Type__c = 'Flat';
        prop.Nature_Of_Property__c = 'Residential';
        prop.Address_Type__c = 'Property Address';
        prop.Property_Purpose__c = 'Self Occupied';
        prop.Residual_Age_Of_Property__c = 'Less than 5 Years';        
        prop.Ownership_Status__c = 'Joint';
        prop.Percent_Share__c = 100;
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
        prop1.Current_Owner_Name__c = loanApplicant.Id;
        prop1.Property_Location_Classification__c = 'Rural';
        prop1.Property_Type__c = 'Flat';
        prop1.Nature_Of_Property__c = 'Residential';
        prop1.Address_Type__c = 'Property Address';
        prop1.Property_Purpose__c = 'Self Occupied';
        prop1.Residual_Age_Of_Property__c = 'Less than 5 Years';
        prop1.Ownership_Status__c = 'Joint';
        prop1.Percent_Share__c = 100;
        prop1.RecordTypeId = onlineECRecordTypeId;
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        propList.add(prop1);
        
        Property__c prop2 = new Property__c();
        prop2.Application__c = app.Id;
        prop2.Current_Owner_Name__c = loanApplicant.Id;
        prop2.Property_Location_Classification__c = 'Rural';
        prop2.Property_Type__c = 'Flat';
        prop2.Nature_Of_Property__c = 'Residential';
        prop2.Address_Type__c = 'Property Address';
        prop2.Property_Purpose__c = 'Self Occupied';
        prop2.Residual_Age_Of_Property__c = 'Less than 5 Years';
        prop2.Ownership_Status__c = 'Joint';
        prop2.Percent_Share__c = 100;
        prop2.RecordTypeId = FIVCRecordTypeId;
        prop2.Title_Deed_Number__c = '2424324';
        prop2.Document_Type__c = 'Sale Deed';
        prop2.Extent_Sqft__c = 32964;
        propList.add(prop2);
        insert propList;
    }
    
    @IsTest
    public static void testFS_LMS_CreateColletralAPI() {
        Property__c prop1 = new Property__c();
        prop1 = [SELECT Id, Application__r.Name FROM Property__c LIMIT 1];
        FS_LMS_CreateColletralAPI.getPropertyRecords(prop1.Application__r.Name);
        FS_LMS_CreateColletralAPI.createColletral(prop1.Id);
    }
}