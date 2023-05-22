@IsTest
public without sharing class DatabaseUtililtyTest {
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
        verifi.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verifi.Application__c = app.Id;
        insert verifi;
        
        Account agency = new Account();
        //agency.Pre_Login__c = preLogin.Id;
        agency.Name = 'test';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Courier Agency').getRecordTypeId();
        insert agency;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Type__c = 'Primary Applicant';
        loanApp.Customer_Information__c = agency.Id;
        insert loanApp;
        
        Property__c propertyObj = new Property__c(
            RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId(),
            Property_Type__c = 'Office',
            Loan_Applicant__c = loanApp.Id,
            Title_Deed_Type__c = 'Settlement or Gift or Consent Deed',
            Title_Deed_Number__c = '12345',
            Title_Deed_Date__c = Date.valueOf('2022-07-05'),
            Property_Address__c = 'Post Padali thangaon',
            Application__c = app.Id,
            Land_Area_Sq_Ft__c = 500,
            Building_Area_Sq_Ft__c = 500,
            Collateral_Sub_Type_Property_Details__c = 'Ready Property',
            Nature_Of_Property__c = 'Commercial',
            Property_Location_Classification__c = 'Rural',
            Age_Of_Property__c = 10,
            Property_Purpose__c = 'Self Occupied',
            Ownership_Status__c = 'Joint',
            Current_Owner_Name__c = 'TN_Agency',
            Percent_Share__c = 100,
            hasRelatedRecords__c = true,
            Residual_Age_Of_Property__c = 'More than 40 Years',
            Address_Line_2__c = 'tal sinnar',
            Taluka__c = 'SGPGI',
            City__c = 'NDL',
            District__c = 'Lucknow',
            State__c = 'NDL',
            isPrimaryOwner__c = true,
            Ownership_Date__c = Date.valueOf('2010-04-21'),
            Address_Type__c = 'Property Address');
        insert propertyObj;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test.jpg';
        cv.Category__c = 'Legal Opinion Report';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=app.id;
        contentlink.ShareType= 'I';
        contentlink.Visibility = 'AllUsers'; 
        contentlink.ContentDocumentId = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1].Id;
        insert contentlink;
        
        MS_Pincode__c ms_pincodeObj = new MS_Pincode__c(
            Name = '444001',
            Pincode__c = '444001');
        insert ms_pincodeObj;
        
        IFSC_Code_Master__c ifsc_code_masterObj = new IFSC_Code_Master__c(
            Name = 'SBIN0041059',
            Bank_Name__c = 'SBIN',
            Bank_Branch_Name__c = 'Chennai');
        insert ifsc_code_masterObj;
        
        Access_Master__c accessMaster = new Access_Master__c();
		accessMaster.Access_For__c = 'Login';
        accessMaster.Capacity__c = 100;
        accessMaster.User__c = UserInfo.getUserId();
        accessMaster.Level__c = '1';
        accessMaster.Capacity_Used__c = 10;
        accessMaster.Next_Assignment__c = true;
        insert accessMaster;
        
        Document_Visibility__c document_visibilityObj = new Document_Visibility__c(
            Role__c = 'Login',
            Visible_Documents__c = 'Login;FIV - C;Online EC',
            Visible_Reports__c = 'FIV - C Report');
         insert document_visibilityObj;
    }
    
    @IsTest
    public static void test(){
        
        Verification__c verifi = [SELECT Id FROM Verification__c limit 1];
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Loan_Applicant__c loanApp = [SELECT Id FROM Loan_Applicant__c limit 1];
        ContentVersion cv = [SELECT Id FROM ContentVersion limit 1];
        MS_Pincode__c msCode = [SELECT Id, Name, Pincode__c FROM MS_Pincode__c limit 1];
        IFSC_Code_Master__c codeMaster = [SELECT Id FROM IFSC_Code_Master__c limit 1];
        
        Bank_Detail__c bank = new Bank_Detail__c();
        bank.Application__c = app.Id;
        bank.Loan_Applicant__c = loanApp.Id;
        insert bank;
        
        Disbursal__c disbursalObj = new Disbursal__c(
            Application__c = app.Id,
            CKYC_ID_Number__c = '22',
            Disbursal_Beneficiary_Type__c = 'Multiple',
            Disbursal_Maker_ID__c = '222222',
            Disbursal_Type__c = 'Part Disb',
            Due_Date__c = Date.valueOf('2022-08-13'),
            First_Installment_Date__c = Date.valueOf('2022-08-12'),
            First_Time_Right_FTR__c = 'Yes',
            Interest_Start_Date__c = Date.valueOf('2022-08-12'),
            FTR_Remarks_by_Author_OO_Responsibility__c = 'Na',
            FTR_Remarks_by_Maker_OO_Responsibility__c = 'Na',
            Ops_Comment__c = 'YEs');
         insert disbursalObj;
        
        Disbursal_Payee__c disbursal_payeeObj = new Disbursal_Payee__c(
            Disbursal__c = disbursalObj.Id,
            Beneficiary_Amount__c = 22,
            Beneficiary_Name__c = 'Test',
            Application__c = app.Id,
            Payment_Type__c = 'Electronic Fund Transfer',
            Beneficiary_Bank_Account_Number__c = 'tEST',
            Beneficiary_Bank_Name__c = 'test bank',
            Beneficiary_Branch_Name__c = 'test bank',
            Beneficiary_Type__c = 'Disbursement Party Name');
         insert disbursal_payeeObj;
        
        List<String> docList = new List<String>{'Legal Opinion Report'};
            
        Test.startTest();
        DatabaseUtililty.getRecordTypeId('Pre_Login__c', '1. New login');
        DatabaseUtililty.getApplicationDetails(app.Id);
        DatabaseUtililty.getVerification(verifi.Id);
        DatabaseUtililty.getApplicantRecords(app.Id);
        DatabaseUtililty.getLoanApplicantRecords(app.Id);
        DatabaseUtililty.getPropertyRecords(app.Id, loanApp.Id);
        DatabaseUtililty.generatePublicLink(cv.Id, 'FIV - C');
        DatabaseUtililty.checkRequiredDocs(app.Id, docList);
        DatabaseUtililty.getLastLoginDate();
        DatabaseUtililty.getPincodeDetails(msCode.Id);
        DatabaseUtililty.getFields('Application__c');
        DatabaseUtililty.getBankIFSCDetails(codeMaster.Id);
        DatabaseUtililty.amountInWords(9870235768.5670);
        DatabaseUtililty.getVerificationWithType(app.Id, 'FIV - C');
        DatabaseUtililty.getUserReports();
        DatabaseUtililty.getDocumentRoles();
        DatabaseUtililty.getPickListValuesIntoList();
        DatabaseUtililty.getRecordIdsFromBankDEtails(bank.Id);
        DatabaseUtililty.getRecordIdsFromDisbPayeeDEtails(disbursal_payeeObj.Id);
        DatabaseUtililty.getApplicationId(loanApp.Id);
        
        DatabaseUtililty.generateFIVCPdf('', app.Id);
        DatabaseUtililty.generateDisbMemoPdf( app.Id);
        DatabaseUtililty.generateCamReport( app.Id,'Process Credit');
        DatabaseUtililty.generateCamReport( app.Id,'Approval Credit');
        DatabaseUtililty.generateLegalCamReport( app.Id);
        DatabaseUtililty.generateAcknowledgementSlip(app.Id);
        Test.stopTest();
        
    }
}