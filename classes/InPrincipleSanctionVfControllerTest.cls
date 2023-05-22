@isTest
public without sharing class InPrincipleSanctionVfControllerTest {
    @Testsetup
    public static void testsetup(){
        
        // Pre Login Creation
        Pre_Login__c login1= new Pre_Login__c(Status__c='Active',RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId());
        insert login1;
        
        // Application Creation
        Application__c app = new Application__c();
        app.Name = 'APP - 0001';
        app.Pre_Login__c = login1.Id;
        insert app;
        
        // Verification Creation FIV - B
        Verification__c verObjfb = new verification__c();
        verObjfb.Application__c = app.Id;
        verObjfb.RecordTypeId = Utility.VERIFICATION_FIV_B_RECORD_TYPE_ID;
        verObjfb.Status__c = 'Completed';
        verObjfb.BM_Recommended_Amount__c = 100000;
        verObjfb.ROI__c = 26.75;
        verObjfb.Tenor__c = '36';
        insert verObjfb;
        
        // Customer Information Creation
        Account acc = new Account();
        acc.FirstName='Ajay';
        acc.LastName='kumar';
        insert acc;
        
        // Loan Applicant Creation
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Application__c=app.Id;
        loanAppObj.KYC_Id_1__c='HQD4572046';
        loanAppObj.KYC_Id_2__c='HQD4572046';
        loanAppObj.KYC_ID_Type_1__c	='Aadhaar Card';
        loanAppObj.KYC_ID_Type_2__c='Voter Id';
        loanAppObj.Customer_Information__c=acc.Id;
        loanAppObj.Customer_Type__c = 'Primary Applicant';
        insert loanAppObj;
        
        // Bureau Highmark Record Creation
        Bureau_Highmark__c bObj = new Bureau_Highmark__c();
        bObj.Loan_Applicant__c = loanAppObj.Id;
        insert bObj;
        
        // Loan Details Creation
        Loan_Details__c lObj = new Loan_Details__c();
        lObj.Bureau_Highmark__c = bObj.Id;
        lObj.Obligations__c = 123;
        lObj.To_be_considerd_for_DBR__c = 'Yes';
        lObj.Stage__c = 'FIV - C';
        insert lObj;
        
        // account for app1
        Account acc2 = new Account();
        acc2.FirstName='Avinash Thakur';
        acc2.LastName='Dsouza';
        insert acc2;
        
        // Loan Applicant Creation for app2
        Loan_Applicant__c loanAppObj3 = new Loan_Applicant__c();
        loanAppObj3.Application__c=app.Id;
        loanAppObj3.KYC_Id_1__c='HQD4572046';
        loanAppObj3.KYC_Id_2__c='HQD4572046';
        loanAppObj3.KYC_ID_Type_1__c	='Aadhaar Card';
        loanAppObj3.KYC_ID_Type_2__c='Voter Id';
        loanAppObj3.Customer_Information__c=acc2.Id;
        loanAppObj3.cifId__c=NULL;
        loanAppObj3.Customer_Type__c = 'Guarantor';
        insert loanAppObj3;
        
        // ms scheme generation
        MS_Scheme__c msschemeObj = new MS_Scheme__c();
        msschemeObj.Applicable_FOIR__c = 50;
        msschemeObj.Applicable_LTV__c = 50;
        insert msschemeObj;
        
        // Verification Creation FIV - C
        Verification__c verObjfc = new verification__c();
        verObjfc.Application__c = app.Id;
        verObjfc.RecordTypeId = Utility.VERIFICATION_FIV_C_RECORD_TYPE_ID;
        verObjfc.Status__c = 'Completed';
        verObjfc.Total_Income__c = 1200;
        insert verObjfc;
        
    }
    
    @isTest static void inPrincipleSanctionTestMethod(){    
        Application__c appObj = [SELECT Id,Name,(SELECT Id,RecordType.Name,Created_From__c FROM Properties__r),(SELECT Id,RecordType.Name FROM Verifications__r),(SELECT Id FROM Loan_Applicants__r WHERE Created_From__c ='Pre Login' LIMIT 1) FROM Application__c WHERE Name='APP - 0001'  LIMIT 1];
        system.debug('app Name'+appObj.Name);
        
        PageReference testPage = Page.InPrincipleSanctionVf; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('recId', appObj.Id);
        
        InPrincipleSanctionVfController testObj = new InPrincipleSanctionVfController();         
        InPrincipleSanctionVfController.SavePdfAsFile(appObj.Id);
    }
}