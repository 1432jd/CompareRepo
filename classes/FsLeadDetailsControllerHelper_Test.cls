@isTest
public class FsLeadDetailsControllerHelper_Test {
    @TestSetup
    static void testMethod1(){
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.Applicant_Name__c = 'Testapp';
        app.Stage__c = 'Process Credit';
        insert app;
        
        Verification__c objVer = new Verification__c();
        objVer.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('PC').getRecordTypeId();
        objVer.Application__c = app.Id;
        objVer.Status__c = 'Pending';
        objVer.OwnerId = userInfo.getUserId();
        objVer.Initiate_From__c = 'Lead Details';
        insert objVer;
         
        Account acc = new Account();
        acc.LastName = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        loanApp.Business_Address_Line_1__c = 'loanadd';
        loanApp.Customer_Type__c = 'Primary Applicant';
        insert loanApp;
        
        IFSC_Code_Master__c ifsc = new IFSC_Code_Master__c();
        ifsc.Bank_Name__c = 'SBI';
        insert ifsc;
        
        MS_Pincode__c ms = new MS_Pincode__c();
        ms.Name = '1234';
        insert ms;
        
        GenericDataTableController gen = new GenericDataTableController();
        gen.METADATA_NAME = 'abc';
    }
    @isTest
    static void runTest(){
        Account acc = [SELECT Id,LastName FROM Account WHERE LastName = 'test'];
        Application__c application = [SELECT Id ,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'Testapp'];
        Verification__c verification1 = [SELECT Id ,Status__c,OwnerId  FROM Verification__c WHERE Status__c = 'Pending'];
        IFSC_Code_Master__c ifsc = [SELECT Id, Bank_Name__c FROM IFSC_Code_Master__c WHERE Bank_Name__c = 'SBI'];
        Loan_Applicant__c loanApplicant = [SELECT Id,Business_Address_Line_1__c FROM Loan_Applicant__c WHERE Business_Address_Line_1__c = 'loanadd'];
        MS_Pincode__c ms =  [SELECT Id, Name, DistrictName__c, StateName__c, City__c FROM MS_Pincode__c WHERE Name = '1234'];
        List<String> genList = new List<String>();
        genList.add(application.Id);
        
        test.startTest();
        FsLeadDetailsControllerHelper.getChildData(application.Id);
        FsLeadDetailsControllerHelper.getPrimaryApplicantData(application.Id);
        FsLeadDetailsControllerHelper.getBankIFSCDetails(ifsc.Id);
        FsLeadDetailsControllerHelper.getAllApplicantMeta(genList);
        FsLeadDetailsControllerHelper.getPersonalInformationData(genList);
        FsLeadDetailsControllerHelper.getEducationData(genList);
        FsLeadDetailsControllerHelper.getFamilyData(genList);
        FsLeadDetailsControllerHelper.getEmploymentDetailsData(genList);
        FsLeadDetailsControllerHelper.getIncomeDetailsData(genList);
        FsLeadDetailsControllerHelper.getBankDetailsData(genList);
        FsLeadDetailsControllerHelper.getReferenceData(genList);
        FsLeadDetailsControllerHelper.getReceiptData(genList);
        FsLeadDetailsControllerHelper.getPropertyDetailsData(application.Id);
        FsLeadDetailsControllerHelper.getLoanDetailsData(genList);
        FsLeadDetailsControllerHelper.initiatFivC(application.Id,verification1.OwnerId);
        FsLeadDetailsControllerHelper.isAllVerificationCompleted(application.Id);
        FsLeadDetailsControllerHelper.getlAllUser();
        FsLeadDetailsControllerHelper.getPincodeMaster(ms.Id);
        FsLeadDetailsControllerHelper.saveCustomerData(Json.serialize(acc));
       // FsLeadDetailsControllerHelper.getPreLoginRecType(application.Id);
        FsLeadDetailsControllerHelper.getApplicantAddress(application.Id);
        FsLeadDetailsControllerHelper.getApplicantNames(application.Id);
        //FsLeadDetailsControllerHelper.getApplicationName(application.Id);
        FsLeadDetailsControllerHelper.checkKYCIdExist('kycId1', 'kycId2', application.Id, loanApplicant.Id);
        test.stopTest();
        
    }
}