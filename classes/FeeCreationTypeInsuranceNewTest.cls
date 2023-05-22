/**
* @Class Name         : FeeCreationTypeInsuranceNewTest.apxc
* @Description        : Test Class for FeeCreationTypeInsuranceNewController 

* @Author             : Sangeeta Yadv
* @Created On         : 12/09/2022
*========================================================================================
* Ver         Date                     Author                       Modification
*========================================================================================
* 1.0      12/09/2022               Sangeeta Yadav                  Initial Version
**/
@isTest
public class FeeCreationTypeInsuranceNewTest {
    @TestSetup 
    static void createTestData() {
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Loan_Amount__c = 100000;
        app.Requested_Loan_Amount__c = 100000;
        insert app;
        
        //Application for if fee already exist 
        Application__c app1 = new Application__c();
        app1.Pre_Login__c = preLogin.Id;
        app1.Loan_Amount__c = 100000;
        
        insert app1;
        // application if there is no fee and requested loan amount is null
        Application__c app2 = new Application__c();
        app2.Pre_Login__c = preLogin.Id;
        app2.Loan_Amount__c = 100000;
        
        insert app2;
        
        Account acc = new Account();
        //acc.Pre_Login__c = preLogin.Id;
        acc.Name = 'test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance Agency').getRecordTypeId();
        insert acc;
        
        Property__c pro = new Property__c();
        pro.Application__c = app.Id;
        pro.Login__c = preLogin.Id;
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.Application__c = app.Id;
        pro1.Login__c = preLogin.Id;
        insert pro1;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        
        insert loanApp;
        Verification__c objVerification = new Verification__c();
        //objVerification.Name = 'FIV-B';
        objVerification.Application__c = app.Id;
        insert objVerification;    
        
        Fee_Type_Master__c feeMaster = new Fee_Type_Master__c();
        feeMaster.Name = 'Ins-Cersai';
       // feeMaster.Fee_Type_Code__c = feeMaster.Name;
        feeMaster.Fee_Type__c = 'User';
        feeMaster.Active__c = 'Yes';
        feeMaster.Applicable_For__c = 'Application';
        feeMaster.Tax__c = 'Inclusive';
        feeMaster.Amount__c = 'Percentage';
        feeMaster.Value__c = 'Loan Amount';
        feeMaster.Stage_Due__c = 'Pre Login';
        feeMaster.Calculation_Basis__c = 'Flat';
        feeMaster.Description__c = 'Test Case';
        feeMaster.Modifiable_at_run_Time__c = 'No';
        feeMaster.Waivable__c = 'No';
        feeMaster.Repayment_of_Fee__c = 'Direct Receipt';
        feeMaster.Type__c = 'Insurance';
        feeMaster.GL_Code__c = '001';
        feeMaster.Fee_Category__c = 'Processing Fees'; 
        insert feeMaster;
        
        
        Fee_Value_Master__c feeValueMaster = new Fee_Value_Master__c();
        feeValueMaster.Fee_Type_Master__c = feeMaster.Id;
        feeValueMaster.Description__c = 'Test Case Description';
        feeValueMaster.Amount__c = 20000 ;
        feeValueMaster.Floor__c = 5000;
        feeValueMaster.Cap__c = 40000;
        feeValueMaster.Max_waiver_amount_without_Approval__c = 20;
        feeValueMaster.Range__c = '10';
        feeValueMaster.Active__c = 'Yes';
        insert feeValueMaster;
        
        //Insert External Agency Master
        
        /*External_Agency_Master__c exAgency = new External_Agency_Master__c();
        exAgency.Name = 'Test Agency 1';*/
        
        //insert exAgency;
        String errObj='{'+
        '"error": {'+
        '"source": "Portal",'+
        '"target": "Kotak",'+
        '"errorCode": "401",'+
        '"message": "Response Failed Due to IFundery Exception",'+
        '"description": "Error Occurred. Please try again later",'+
        '"timestamp": "2023-01-17 09:28:29+0000"'+
        '}'+
        '}';
        //Insert Fee creation
        Fee_Creation__c feeCreation = new Fee_Creation__c();
        feeCreation.Application__c = app1.Id;
        feeCreation.Fee_Code__c = feeMaster.Fee_Type_Code__c;
        feeCreation.Type__c = feeMaster.Fee_Type__c;
        feeCreation.Description__c = feeMaster.Description__c;
        feeCreation.Stage_Due__c = feeMaster.Stage_Due__c;
        feeCreation.Fee_Type_Master__c = feeMaster.Id;
        feeCreation.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation.Repayment_Type_2__c = 'Deduct from Disbursement';
        feeCreation.Sync_Error__c = errObj;
        // fetch record type Id for insurance to create records for insurance.
        feeCreation.Fee_Code__c = 'Ins-Cersai';
        feeCreation.Applicable_For__c = 'Application';
        feeCreation.Fee_Value_Master__c = feeValueMaster.Id;
        feeCreation.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        insert feeCreation;
        
        Fee_Creation__c feeCreation1 = new Fee_Creation__c();
        feeCreation1.Application__c = app2.Id;
        feeCreation1.Fee_Code__c = feeMaster.Fee_Type_Code__c;
        feeCreation1.Type__c = feeMaster.Fee_Type__c;
        feeCreation1.Description__c = feeMaster.Description__c;
        feeCreation1.Stage_Due__c = feeMaster.Stage_Due__c;
        feeCreation1.Fee_Type_Master__c = feeMaster.Id;
        feeCreation1.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation1.Repayment_Type_2__c = 'Deduct from Disbursement';
        feeCreation1.Sync_Error__c = errObj;
        // fetch record type Id for insurance to create records for insurance.
        feeCreation1.Fee_Code__c = 'Ins-Cersai';
        feeCreation1.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation1.External_Agency_Master__c = acc.Id;
        feeCreation1.Applicable_For__c = 'Applicant';
        feeCreation1.Loan_Applicant__c = loanApp.Id;
        feeCreation1.Fee_Value_Master__c = feeValueMaster.Id;
        insert feeCreation1;
        
        Fee_Creation__c feeCreation2 = new Fee_Creation__c();
        feeCreation2.Application__c = app2.Id;
        feeCreation2.Fee_Code__c = feeMaster.Fee_Type_Code__c;
        feeCreation2.Type__c = feeMaster.Fee_Type__c;
        feeCreation2.Description__c = feeMaster.Description__c;
        feeCreation2.Stage_Due__c = feeMaster.Stage_Due__c;
        feeCreation2.Fee_Type_Master__c = feeMaster.Id;
        feeCreation2.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation2.Repayment_Type_2__c = 'Deduct from Disbursement';
        feeCreation2.Sync_Error__c = errObj;
        // fetch record type Id for insurance to create records for insurance.
        feeCreation2.Fee_Code__c = 'Ins-Cersai';
        feeCreation2.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation2.External_Agency_Master__c = acc.Id;
        feeCreation2.Applicable_For__c = 'Applicant';
        feeCreation2.Fee_Value_Master__c = feeValueMaster.Id;
        //feeCreation2.Loan_Applicant__c = loanApp.Id;
        insert feeCreation2;
        
        Fee_Creation__c feeCreation3 = new Fee_Creation__c();
        feeCreation3.Application__c = app2.Id;
        feeCreation3.Fee_Code__c = feeMaster.Fee_Type_Code__c;
        feeCreation3.Type__c = feeMaster.Fee_Type__c;
        feeCreation3.Description__c = feeMaster.Description__c;
        feeCreation3.Stage_Due__c = feeMaster.Stage_Due__c;
        feeCreation3.Fee_Type_Master__c = feeMaster.Id;
        feeCreation3.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation3.Repayment_Type_2__c = 'Deduct from Disbursement';
        feeCreation3.Sync_Error__c = errObj;
        // fetch record type Id for insurance to create records for insurance.
        feeCreation3.Fee_Code__c = 'Ins-Cersai';
        feeCreation3.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation3.External_Agency_Master__c = acc.Id;
        feeCreation3.Applicable_For__c = 'Asset';
        feeCreation3.Property__c = pro.Id;
        feeCreation3.Fee_Value_Master__c = feeValueMaster.Id;
        insert feeCreation3;
        
        Fee_Creation__c feeCreation4 = new Fee_Creation__c();
        feeCreation4.Application__c = app2.Id;
        feeCreation4.Fee_Code__c = feeMaster.Fee_Type_Code__c;
        feeCreation4.Type__c = feeMaster.Fee_Type__c;
        feeCreation4.Description__c = feeMaster.Description__c;
        feeCreation4.Stage_Due__c = feeMaster.Stage_Due__c;
        feeCreation4.Fee_Type_Master__c = feeMaster.Id;
        feeCreation4.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation4.Repayment_Type_2__c = 'Deduct from Disbursement';
        feeCreation4.Sync_Error__c = errObj;
        // fetch record type Id for insurance to create records for insurance.
        feeCreation4.Fee_Code__c = 'Ins-Cersai';
        feeCreation4.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        feeCreation4.External_Agency_Master__c = acc.Id;
        feeCreation4.Applicable_For__c = 'Asset';
        feeCreation4.Fee_Value_Master__c = feeValueMaster.Id;
        //feeCreation1.Loan_Applicant__c = loanApp.Id;
        insert feeCreation4;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName='uniquestandarduser@testorg.com');
        insert u;
        
    }
    @isTest
    static void feeCreation() {
        List<User> u = [SELECT Id, Email, Name, IsActive FROM User WHERE UserName = 'uniquestandarduser@testorg.com' LIMIT 1];
        List<Application__c> loginApplication = [SELECT Id, Requested_Loan_Amount__c FROM Application__c ];
        List<Fee_Creation__c> feeToUpdate = [SELECT Id,Application__c,Fee_Type_Master__c,Fee_Value_Master__c,Sync_Error__c, Name,RecordTypeId, Fee_Code__c,RecordType.DeveloperName FROM Fee_Creation__c ];
        for(Fee_Creation__c fee: feeToUpdate){
            fee.Application__c = loginApplication[0].Id;
        }
        update feeToUpdate;
        System.debug('test' + feeToUpdate);
        Account exAgencyForFee = [SELECT Id, Name FROM Account LIMIT 1];
        Loan_Applicant__c loanApplicant = [SELECT Id, Name FROM Loan_Applicant__c LIMIT 1];
        Fee_Type_Master__c fms = [Select Id from Fee_Type_Master__c Limit 1]; 
        System.runAs(u[0]){
        test.startTest();
        //for(AppLication__c application : loginApplication){
           // FeeCreationTypeInsuranceNewController.createFeeCreationInsuranceRecords(application.Id);
        //}
        
        //Get fee creation records
        if(!loginApplication.isEmpty()){
           // FeeCreationTypeInsuranceNewController.getFeeTypeInsurance(loginApplication[0].Id);
            // For add new Row
            FeeCreationTypeInsuranceNewController.addRow(loginApplication[0].Id, 'Ins-Cersai', '2', 'Pre Login');
            FeeCreationTypeInsuranceNewController.addRow(loginApplication[0].Id, 'Ins-Cersai', '2', null);  
            loginApplication[0].Requested_Loan_Amount__c = null;
        }
        update loginApplication;
        FeeCreationTypeInsuranceNewController.addRow(loginApplication[0].Id, 'Ins-Cersai', '2', null);
        FeeCreationTypeInsuranceNewController.picklistValues('Fee_Type_Master__c','Applicable_For__c');
        FeeCreationTypeInsuranceNewController.getLoanApplicant(loginApplication[0].Id,'Applicant');
        FeeCreationTypeInsuranceNewController.getLoanApplicant(loginApplication[0].Id,'Asset');
        FeeCreationTypeInsuranceNewController.getLoanApplicant(loginApplication[0].Id,'Application');
        FeeCreationTypeInsuranceNewController.getAgencyPicklist();
       // FeeCreationTypeInsuranceNewController.updateFeeCreationInsuranceRecordsSumAssured(feeToUpdate.ID,222,22,22,222,null,'xyz','Applicant',null,true);
        //FeeCreationTypeInsuranceNewController.createNewFee(feeToUpdate,loginApplication[0].Id,exAgencyForFee.Id, loanApplicant.ID, 'Applicant', true);
    //        FeeCreationTypeInsuranceNewController.createNewFeeCreationNewRowRecord('feeCreation');
        FeeCreationTypeInsuranceNewController.callKotakCalculateAPI(feeToUpdate[0].Id,222);
        FeeCreationTypeInsuranceNewController.getInsuranceRecords(loginApplication[0].Id,'Pre Login');
        FeeCreationTypeInsuranceNewController.isApiActive();
        FeeCreationTypeInsuranceNewController.getSyncError(feeToUpdate[0].ID);
        FeeCreationTypeInsuranceNewController.getNewRow(loginApplication[0].Id, 'Pre Login');
        FeeCreationTypeInsuranceNewController.getFeeCodeFromMaster(loginApplication[0].Id);
        FeeCreationTypeInsuranceNewController.repaymentTypeFromMaster('Insurance');
        FeeCreationTypeInsuranceNewController.isApiActive();
        FeeCreationTypeInsuranceNewController.getSyncError(feeToUpdate[0].ID);
            //"Fee_Value_Master__C":"'+feeToUpdate[0].Fee_Value_Master__C+'",
        String insWrapperList = '[{"applicantAsset":false,"feeList":{"Fee_Type_Master__C":"'+feeToUpdate[0].Fee_Type_Master__c+'","Fee_Value_Master__C":"'+feeToUpdate[0].Fee_Value_Master__C+'","Total_Fee__c":0,"Type__c":"User","Stage_Due__c":"Lead Detail","Tax_Amount__c":0,"Premium__c":0,"Applicable_For__c":"Application","Fetch_Premium__c":false,"Pending_Premium_Calculation__c":true,"RecordTypeId":"'+feeToUpdate[0].RecordTypeId+'","Sum_Assured__c":5200000,"Application__c":"'+loginApplication[0].Id+'","Receipt_Created__c":false,"Repayment_Type_2__c":"Deduct from Disbursement","Fee_Code__c":"Ins-Cersai","External_Agency_Master__c":"'+exAgencyForFee.Id+'"},"isApplication":false,"isChange":true,"isNewRow":true,"repaymentDetail":[{"label":"Direct Receipt","value":"Direct Receipt"},{"label":"Deduct from Disbursement","value":"Deduct from Disbursement"}],"rowNumber":10}]';
        FeeCreationTypeInsuranceNewController.saveInsFeeRecords(insWrapperList);
        FeeCreationTypeInsuranceNewController.deleteFee(insWrapperList);
         test.stopTest();
        }
    } 
    
    //To update fee Insurance records 
    @isTest
    static void updateFeeCreation() {    
        List<Application__c> loginApplication = [SELECT Id, Requested_Loan_Amount__c FROM Application__c];
        Account exAgencyForFee = [SELECT Id, Name FROM Account LIMIT 1];
        Loan_Applicant__c loanApplicant = [SELECT Id, Name FROM Loan_Applicant__c LIMIT 1];
        Property__c property = [SELECT Id, Name FROM Property__c LIMIT 1];
        Fee_Creation__c feeToUpdate = [SELECT Id, Name, Fee_Code__c FROM Fee_Creation__c LIMIT 1];
        Fee_Type_Master__c feeMaster = [SELECT Id, Name, Repayment_of_Fee__c FROM Fee_Type_Master__c LIMIT 1];
        Fee_Creation__c newFee = new Fee_Creation__c();
        test.startTest();
        //Applicable for application
        //  FeeCreationTypeInsuranceNewController.updateFeeCreationInsuranceRecordsSumAssured(feeToUpdate.Id, 20000, 10000, 1800, 
        //                                              11800, 'Direct Receipt', 'Application','', exAgencyForFee.Id);
        //Applicable for applicant
        //    FeeCreationTypeInsuranceNewController.updateFeeCreationInsuranceRecordsSumAssured(feeToUpdate.Id, 20000, 10000, 1800, 
        //                                              11800, 'Direct Receipt', 'Applicant',loanApplicant.Id, exAgencyForFee.Id);
        //Applicable for Asset
        //   FeeCreationTypeInsuranceNewController.updateFeeCreationInsuranceRecordsSumAssured(feeToUpdate.Id, 20000, 10000, 1800, 
        //                                              11800, 'Direct Receipt', 'Asset',property.Id, exAgencyForFee.Id);
        
        //To get Repayment picklist values
        //FeeCreationTypeInsuranceNewController.getRepaymentPicklist(feeToUpdate.Fee_Code__c);
        //feeMaster.Repayment_of_Fee__c = 'Direct Receipt; Deduct from Disbursement';
        //update feeMaster;
        //FeeCreationTypeInsuranceNewController.getRepaymentPicklist(feeToUpdate.Fee_Code__c);
        // For add new Row
        newFee = FeeCreationTypeInsuranceNewController.addRow(loginApplication[0].Id, 'Ins-Cersai', '2', 'Pre Login');
        //   FeeCreationTypeInsuranceNewController.createNewFee(newFee, loginApplication[0].Id, exAgencyForFee.Id, loanApplicant.Id, 'Applicant');
        //   FeeCreationTypeInsuranceNewController.createNewFee(newFee, loginApplication[0].Id, exAgencyForFee.Id, property.Id, 'Asset');
        
        test.stopTest();
    }
}