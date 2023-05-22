@isTest
public class BureauHighmartAPICalloutController_Test {
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
        insert loanApp4;
        
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
        insert kyc;
    }
    @isTest
    static void testAllData(){
        Application__c application = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'test'];
        Account acc = [SELECT Id,LastName FROM Account WHERE LastName = 'test1'];
        Loan_Applicant__c loan = [SELECT Id,Business_Address_Line_1__c,Is_KYC_Verified__c,Application__c,KYC_ID_Type_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'loanadd'];
        Loan_Applicant__c loan1 = [SELECT Id,KYC_ID_Type_1__c,Business_Address_Line_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'testadd'];
        Loan_Applicant__c loan2 = [SELECT Id,KYC_ID_Type_1__c,Business_Address_Line_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'testadd1']; 
        Loan_Applicant__c loan3 = [SELECT Id,KYC_ID_Type_1__c,Business_Address_Line_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'testadd2'];
        Loan_Applicant__c loan4 = [SELECT Id,KYC_ID_Type_1__c,Business_Address_Line_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'testadd3'];
        Bureau_Highmark__c bureau = [SELECT Id,LoanAmount__c,Address__c,Name,Loan_Applicant__c,Highmark_Score__c FROM Bureau_Highmark__c WHERE Name = 'bh'];
        List<Loan_Applicant__c> loanApp = [SELECT Id,Business_Address_Line_1__c,Is_KYC_Verified__c,Application__c,KYC_ID_Type_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'loanadd'];
		List<ID> loanAppID = new List<Id>();
        for(Loan_Applicant__c loanAppObj : loanApp){
            loanAppID.add(loanAppObj.ID);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BureauHighmartAPICalloutControTestMock());
        BureauHighmartAPICalloutController.initiateBureau(loan.Id);
        BureauHighmartAPICalloutController.initiateBureau(loan1.Id);
        BureauHighmartAPICalloutController.initiateBureau(loan2.Id);
        BureauHighmartAPICalloutController.initiateBureau(loan3.Id);
        BureauHighmartAPICalloutController.initiateBureau(loan4.Id);
        BureauHighmartAPICalloutController.doHighmarkCallout(loanAppID);
        Test.stopTest();
    }
}