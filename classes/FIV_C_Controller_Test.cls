@isTest
public class FIV_C_Controller_Test {
    @TestSetup
    static void createTestData() {
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Applicant_Name__c = 'App1';
        insert app;
        
        Account acc = new Account();
        //acc.p = preLogin.Id;
        acc.LastName = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Property__c pro = new Property__c();
        pro.Application__c = app.Id;
        pro.Login__c = preLogin.Id;
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.Application__c = app.Id;
        pro1.Login__c = preLogin.Id;
        pro1.Address_Line_2__c = 'TestAdd';
        pro1.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        insert pro1;
        
        CommonObject__c co = new CommonObject__c();
        co.Property__c = pro1.Id;
        co.Application__c = app.Id;
        co.Object_Type__c ='Enquiry';
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        loanApp.Business_Address_Line_1__c = 'loanadd';
        insert loanApp;
        
        Id fivcRecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        
        List<Verification__c> verList = new List<Verification__c>();
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
        //   ver.Name__c = 'verify';
       // ver.FIV_B_Position__c = 'FIV_B_Table_Caseflow';
        verList.add(ver);
        
        Verification__c ver1 = new Verification__c();
        ver1.Application__c = app.Id;
        ver1.Name__c = 'verify1';
       //ver1.FIV_B_Position__c = 'FIV_B_Table_Collateral';
        ver1.RecordTypeId = fivcRecordTypeId; 
        verList.add(ver1);
        insert verList;
        
        List<Capability__c> capList = new List<Capability__c>();
        Capability__c cap = new Capability__c();
        cap.Application__c = app.Id;
        cap.Verification__c = ver1.Id;
        cap.Income_segment__c = 'Salaried';
        capList.add(cap);
        
        Capability__c cap1 = new Capability__c();
        cap1.Application__c = app.Id;
        cap1.Verification__c = ver1.Id;
        cap1.Income_segment__c = 'Rental Income';
        capList.add(cap1);
        
        Capability__c cap2 = new Capability__c();
        cap2.Application__c = app.Id;
        cap2.Verification__c = ver1.Id;
        cap2.Income_segment__c = 'Daily wages';
        capList.add(cap2);
        
        Capability__c cap3 = new Capability__c();
        cap3.Application__c = app.Id;
        cap3.Verification__c = ver1.Id;
        cap3.Income_segment__c = 'Eateries';
        capList.add(cap3);
        
        Capability__c cap4 = new Capability__c();
        cap4.Application__c = app.Id;
        cap4.Verification__c = ver1.Id;
        cap4.Income_segment__c = 'Pension';
        capList.add(cap4);
        
        Capability__c cap5 = new Capability__c();
        cap5.Application__c = app.Id;
        cap5.Verification__c = ver1.Id;
        cap5.Day_Margin_Basis__c = 'Day Basis';
        cap5.Income_per_day__c = 22;
        cap5.Number_of_days__c = 23;
        capList.add(cap5);
        
        Capability__c cap6 = new Capability__c();
        cap6.Application__c = app.Id;
        cap6.Verification__c = ver1.Id;
        cap6.Day_Margin_Basis__c = 'Margin Basis';
        cap6.Income_per_day__c = 52;
        cap6.Number_of_days__c = 13;
        capList.add(cap6);
        insert capList;
        
        GenericFormBuilderController gen = new GenericFormBuilderController();
        gen.METADATA_NAME = 'abc';
  //      gen.IDS_SET = new set();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Image';
        cv.PathOnClient = 'Test_Image.jpg';
        cv.VersionData = Blob.valueOf('Test Image Data');
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = cv.id;
        cd.Name = cv.Title;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;
    }
    @isTest
    static void testAllMethod(){
        Application__c application = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'App1'];
        Verification__c verification = [SELECT Id,Name__c FROM Verification__c WHERE Name__c = 'verify1'];
        Property__c property = [SELECT Id,Address_Line_2__c FROM Property__c WHERE Address_Line_2__c = 'TestAdd'];
        Loan_Applicant__c loanApplicant = [SELECT Id,Business_Address_Line_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'loanadd'];
        ContentVersion cv = [SELECT Id,Title,PathOnClient,Uploaded_From__c FROM ContentVersion WHERE Title = 'Test Image' AND PathOnClient = 'Test_Image.jpg'];
        
        test.startTest();
        FIV_C_Controller.checkFIVCReport(application.Id);
        FIV_C_Controller.getApplicantList(application.Id);
        FIV_C_Controller.getApplicantRecords(application.Id);
        FIV_C_Controller.getCollateralSummary(application.Id);
        FIV_C_Controller.getEnquiryMap(application.Id);
        FIV_C_Controller.getCollateralTabRecords(application.Id, 'abc');
        FIV_C_Controller.getCapabiltyData(application.Id);
        FIV_C_Controller.getVerification(verification.Id);
        FIV_C_Controller.getLoanApplicantRecords(application.Id);
        FIV_C_Controller.getPendingAccounts(application.Id);
        FIV_C_Controller.getCharacterTabRecords(application.Id, 'abc',null);
        FIV_C_Controller.getFIV_CRecordTypeId();
        FIV_C_Controller.getPropertyRecords(application.Id,loanApplicant.Id);
        FIV_C_Controller.getCollateralEnquiryRecords(application.Id, property.Id);
        FIV_C_Controller.getIncomeSummary(application.Id, verification.Id);
        FIV_C_Controller.getRevisitData(application.Id, 'abc', null);
        FIV_C_Controller.generatePublicLink(cv.Id);
        testMethod2();
   		test.stopTest();   
    }
    @isTest
    static void testMethod2(){
        Integer i = 0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;  
    }
}