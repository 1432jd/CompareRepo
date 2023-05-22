@isTest
public without sharing class KYCAPIControlleTest {
    
    @TestSetup
    static void createTestData(){
        Application__c app = new Application__c();
        app.Applicant_Name__c = 'test';
        insert app;
        
        Account acc = new Account();
        //  acc.Name = 'Testname';
        acc.LastName = 'test1';
        acc.PersonBirthdate = date.today()-15;
        acc.Gender__c = 'Male';
        insert acc;
        
        MS_Pincode__c ms = new MS_Pincode__c();
        ms.Name = '1233';
        insert ms;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Business_Address_Line_1__c = 'loanadd';
        loanApp.Is_KYC_Verified__c = true;
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        loanApp.Residence_Pincode__c = ms.Id;
        loanApp.Residence_Address_Line_1__c = 'testaddress';
        loanApp.Residence_City__c = 'Testcity';
        loanApp.Mobile__c = '2047323313';
        loanApp.KYC_ID_Type_1__c = 'Driving License';
        loanApp.KYC_ID_Type_2__c = 'Driving License';
        loanApp.KYC_Id_1__c = 'kyc1';
        loanApp.KYC_Id_2__c = 'kyc2';
        loanApp.Passport_File_Number__c = '12345';
        loanApp.Issue_Date__c = System.today();
        insert loanApp;
        
        Loan_Applicant__c loanApp1 = new Loan_Applicant__c();
        loanApp1.Business_Address_Line_1__c = 'testadd';
        loanApp1.Is_KYC_Verified__c = true;
        loanApp1.Application__c = app.Id;
        loanApp1.Customer_Information__c = acc.Id;
        loanApp1.Residence_Pincode__c = ms.Id;
        loanApp1.Residence_Address_Line_1__c = 'testaddress';
        loanApp1.Residence_City__c = 'Testcity';
        loanApp1.Mobile__c = '2047323313';
        loanApp1.KYC_ID_Type_1__c = 'Passport';
        loanApp1.KYC_ID_Type_2__c = 'Passport';
        loanApp1.KYC_Id_1__c = 'kyc1';
        loanApp1.KYC_Id_2__c = 'kyc2';
        loanApp1.Passport_File_Number__c = '12345';
        loanApp1.Issue_Date__c = System.today();
        insert loanApp1;
        
        Loan_Applicant__c loanApp2 = new Loan_Applicant__c();
        loanApp2.Business_Address_Line_1__c = 'testadd1';
        loanApp2.Is_KYC_Verified__c = true;
        loanApp2.Application__c = app.Id;
        loanApp2.Customer_Information__c = acc.Id;
        loanApp2.Residence_Pincode__c = ms.Id;
        loanApp2.Residence_Address_Line_1__c = 'testaddress';
        loanApp2.Residence_City__c = 'Testcity';
        loanApp2.Mobile__c = '2047323313';
        loanApp2.KYC_ID_Type_1__c = 'Voter Id';
        loanApp2.KYC_ID_Type_2__c = 'Voter Id';
        loanApp2.KYC_Id_1__c = 'kyc1';
        loanApp2.KYC_Id_2__c = 'kyc2';
        loanApp2.Passport_File_Number__c = '12345';
        loanApp2.Issue_Date__c = System.today();
        insert loanApp2;
        
        Loan_Applicant__c loanApp3 = new Loan_Applicant__c();
        loanApp3.Business_Address_Line_1__c = 'testadd2';
        loanApp3.Is_KYC_Verified__c = true;
        loanApp3.Application__c = app.Id;
        loanApp3.Customer_Information__c = acc.Id;
        loanApp3.Residence_Pincode__c = ms.Id;
        loanApp3.Residence_Address_Line_1__c = 'testaddress';
        loanApp3.Residence_City__c = 'Testcity';
        loanApp3.Mobile__c = '2047323313';
        loanApp3.KYC_ID_Type_1__c = 'Aadhaar Card';
        loanApp3.KYC_ID_Type_2__c = 'Aadhaar Card';
        loanApp3.KYC_Id_1__c = 'kyc1';
        loanApp3.KYC_Id_2__c = 'kyc2';
        loanApp3.Passport_File_Number__c = '12345';  
        loanApp3.Issue_Date__c = System.today();
        insert loanApp3;
        
        Loan_Applicant__c loanApp4 = new Loan_Applicant__c();
        loanApp4.Business_Address_Line_1__c = 'testadd3';
        loanApp4.Is_KYC_Verified__c = true;
        loanApp4.Application__c = app.Id;
        loanApp4.Customer_Information__c = acc.Id;
        loanApp4.Residence_Pincode__c = ms.Id;
        loanApp4.Residence_Address_Line_1__c = 'testaddress';
        loanApp4.Residence_City__c = 'Testcity';
        loanApp4.Mobile__c = '2047323313';
        loanApp4.KYC_ID_Type_1__c = 'Pan Card';
        loanApp4.KYC_ID_Type_2__c = 'Pan Card';
        loanApp4.KYC_Id_1__c = 'kyc1';
        loanApp4.KYC_Id_2__c = 'kyc2';
        loanApp4.Passport_File_Number__c = '12345';
        loanApp4.Issue_Date__c = System.today();
        insert loanApp4;
        
        Loan_Applicant__c loanApp5 = new Loan_Applicant__c();
        loanApp5.Business_Address_Line_1__c = 'testadd3';
        loanApp5.Is_KYC_Verified__c = true;
        loanApp5.Application__c = app.Id;
        loanApp5.Customer_Information__c = acc.Id;
        loanApp5.Residence_Pincode__c = ms.Id;
        loanApp5.Residence_Address_Line_1__c = 'testaddress';
        loanApp5.Residence_City__c = 'Testcity';
        loanApp5.Mobile__c = '2047323313';
        loanApp5.KYC_ID_Type_1__c = 'Passport';
        loanApp5.KYC_ID_Type_2__c = 'Passport';
        loanApp5.KYC_Id_1__c = 'kyc1';
        loanApp5.KYC_Id_2__c = 'kyc2';
        loanApp5.Passport_File_Number__c = '12345';
        loanApp5.Issue_Date__c = System.today();
        insert loanApp5;
        
        Bureau_Highmark__c bh = new Bureau_Highmark__c();
        bh.Loan_Applicant__c = loanApp.Id;
        bh.LoanAmount__c = 2000;
        bh.Address__c = 'bhaddress';
        bh.Name = 'bh';
        bh.Highmark_Score__c = '22';
        bh.creditInqPurpsTypDesc__c = 'a';
        bh.CreditInqPurpsType__c = 'b';
        bh.CreditInquiryStage__c = 'h';
        bh.CreditReqType__c ='g';
        bh.CreditRptId__c = 'f';
        bh.CreditRptTrnDtTm__c = 'v';
        bh.DOB__c = date.today() -100;
        bh.LosAppId__c = 'gg';
        bh.MbrId__c = 'dd';
        insert bh;
        
        Kyc__c kyc = new Kyc__c();
        kyc.Loan_Applicant__c = loanApp.Id;
        kyc.Type__c = 'Passport';
        kyc.DOB__c = system.today();
        kyc.Passport_FileNo__c = 'PO123445';
        kyc.DateOfIssue__c = system.today();
        kyc.DateOfExpiry__c = system.today();
        insert kyc;
    }
    @isTest
    static void testAllData1(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c Limit 1];
        Test.setMock(HttpCalloutMock.class, new BureauHighmartAPICalloutControTestMock());
        
        Test.startTest();        
        KYCAPIController.kycVerifyAPICallout('Aadhaar Card','234567890123','Sunil','30-11-11',loanApp.ID);
        KYCAPIController.updateLoanApplicant(loanApp.ID);
        Test.stopTest();
    }
    @isTest
    static void testAllData2(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c Limit 1];
        Test.setMock(HttpCalloutMock.class, new BureauHighmartAPICalloutControTestMock());
        
        Test.startTest();        
        KYCAPIController.kycVerifyAPICallout('Voter Id','abc1234567','Sunil','30-11-11',loanApp.ID); 
        Test.stopTest();
    }
    @isTest
    static void testAllData3(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c Limit 1];
        Kyc__c kyc = [Select Id,Passport_FileNo__c,DOB__c,DateOfIssue__c
                             FROM KYC__c Limit 1];
        Test.setMock(HttpCalloutMock.class, new BureauHighmartAPICalloutControTestMock());
        
        Test.startTest();     
        //KYCAPIController.kycAPICallout(loanApp.ID);
        KYCAPIController.kycVerifyAPICallout('Passport','A1234567','Sunil','30-11-11',loanApp.ID);        
        Test.stopTest();
    }
    @isTest
    static void testAllData4(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c Limit 1];
        Test.setMock(HttpCalloutMock.class, new BureauHighmartAPICalloutControTestMock());
        
        Test.startTest();        
        KYCAPIController.kycVerifyAPICallout('Driving License','RJ1320120123456','Sunil','30-11-11',loanApp.ID);  
        Test.stopTest();
    }
    
    @isTest
    static void testData5(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c WHERE KYC_ID_Type_1__c = 'Aadhaar Card' Limit 1];
        
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new BureauHighmartAPICalloutControTestMock());
        KYCAPIController.kycAPICallout(loanApp.ID);
        Test.stopTest();
    } 
    @isTest
    static void testData6(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c WHERE KYC_ID_Type_1__c = 'Voter Id' Limit 1];
        
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new BureauHighmartAPICalloutControTestMock());
        KYCAPIController.kycAPICallout(loanApp.ID);
        Test.stopTest();
    }	
}