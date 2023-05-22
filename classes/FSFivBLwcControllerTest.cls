@isTest
public class FSFivBLwcControllerTest {
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
        //acc.Pre_Login__c = preLogin.Id;
        acc.LastName = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Property__c pro = new Property__c();
        pro.Application__c = app.Id;
        pro.Login__c = preLogin.Id;
        pro.Risk_Document__c = 'Orange';
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.Application__c = app.Id;
        pro1.Login__c = preLogin.Id;
        pro1.Address_Line_2__c = 'TestAdd';
        pro1.Risk_Document__c = 'Red';
        pro1.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-B Property Detail').getRecordTypeId();
        insert pro1;
        
        CommonObject__c co = new CommonObject__c();
        co.Property__c = pro1.Id;
        co.Application__c = app.Id;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        loanApp.Business_Address_Line_1__c = 'loanadd';
        insert loanApp;
        
        Character__c charObj = new Character__c();
        charObj.Loan_Applicant__c = loanApp.Id;
        charObj.Application__c = app.Id;
        charObj.Customer_Type__c = 'Guarantor';
        charObj.Family_Member_Name__c = 'Family member';
        charObj.Relationship__c = 'Self';
        charObj.Living_with_Applicant__c = 'Yes';
        charObj.Overall_Remarks__c = 'Test overall remarks';
        charObj.Neighbour_Name__c = 'Test Neighbour';
        charObj.Neighbour_Number__c = '9656726778';
        charObj.FeedBack__c = 'Positive';
        charObj.Remarks__c = 'Test remarks';
        charObj.Is_Involved__c = 'No';
        charObj.Applicant_Type__c = 'Both';
        charObj.Affiliation_Name__c = 'TestAffiliation';
        charObj.Affiliation_with__c = 'Police';
        charObj.Current_position_Position_held_in_Past__c = 'Current Position';
        charObj.Name_of_party__c = 'Test party name';
        charObj.No_of_years_in_politics__c = 11.22;
        charObj.Present_Political_Status__c = 'Active';
        charObj.Character_Of_Affiliated_Person__c = 'Positive';
        charObj.Lifestyle__c = 'Good';
        charObj.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c = 'Good';
        charObj.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c = 'Average';
        charObj.Lifestyle_Loan_Amount_8Lakhs__c = 'Below Average';
        charObj.Consumer_Durables__c = 'Cooler';
        charObj.Living_Standard_Remarks__c = 'Test living standard remarks';
        charObj.RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('FIV-B Character').getRecordTypeId();
		insert charObj;

        String fivbRecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('FIV - B').getRecordTypeId();

        List<Verification__c> verList = new List<Verification__c>();
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
        verList.add(ver);
        
        Verification__c ver1 = new Verification__c();
        ver1.Application__c = app.Id;
        ver1.Name__c = 'verify1';
        ver1.RecordTypeId = fivbRecordTypeId; 
        ver1.FIV_B_Position__c = 'FIV_B_Table_Collateral';
        verList.add(ver1);
        insert verList;

        GenericFormBuilderController gen = new GenericFormBuilderController();
        gen.METADATA_NAME = 'abc';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Image';
        cv.PathOnClient = 'Test_Image.jpg';
        cv.VersionData = Blob.valueOf('Test Image Data');
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = cv.id;
        cd.Name = cv.Title;
        cv.Uploaded_From__c = 'FIV-B';
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
        Verification__c verification = [SELECT Id,Name__c,FIV_B_Position__c FROM Verification__c WHERE Name__c = 'verify1'];
        Property__c property = [SELECT Id,Address_Line_2__c FROM Property__c WHERE Address_Line_2__c = 'TestAdd'];
        Loan_Applicant__c loanApplicant = [SELECT Id,Business_Address_Line_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'loanadd'];
        ContentVersion cv = [SELECT Id,Title,PathOnClient,Uploaded_From__c FROM ContentVersion WHERE Title = 'Test Image' AND PathOnClient = 'Test_Image.jpg'];
        Character__c charObj = [SELECT Id,Remarks__c,Is_Involved__c FROM  Character__c WHERE Is_Involved__c= 'No'];
        List<String> charList = new List<String>();
        charList.add('charObj.Id');
        
        test.startTest();
        FSFivBLwcController.createVerificationRecord(application.Id,'');
        FSFivBLwcController.getAllApplicantMeta(application.Id);
        FSFivBLwcController.getAllCalculationRecords(application.Id);
        FSFivBLwcController.getPropertyData(application.Id);
        FSFivBLwcController.getROIRecord(application.Id, true);
        FSFivBLwcController.getVerificationData(application.Id);
        FSFivBLwcController.getVerificationRecord(verification.Id);
        FSFivBLwcController.getApplicantData(application.Id);
        FSFivBLwcController.getCashflowData(charList);
        FSFivBLwcController.getCharacterData(charList);
        FSFivBLwcController.getSectionContent('recordIds', 'metaDetaName');
        Application__c app1 = new Application__c();
        app1.Employee_ID__c = userInfo.getUserId();
        app1.Customer_Visit_date__c = date.today()-15;
        app1.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app1.Requested_Loan_Amount__c = 10000;
        app1.Channel__c = 'Common';
        app1.Alternate_Channel_Mode__c = 'Brokers';
        FSFivBLwcController.saveRecord(app1);
        FSFivBLwcController.generatePublicLink(cv.Id);
   		test.stopTest();   
    }
}