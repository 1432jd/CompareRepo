@isTest
public class AgreementExecutionController_Test {
    @TestSetup
    static void agrTest(){
            
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.Nach_Party__c = 'ew';
        app.NACH_Party_1_ID__c = 'ewew';
        app.Nach_Party_2__c = 'wdw';
        app.NACH_Party_2_ID__c = 'eew';
        app.Applicant_Name__c = 'ww';
        insert app;
        
        Account acc = new Account();
        acc.LastName = 'testacc';
        insert acc;
        
        Loan_Applicant__c loan = new Loan_Applicant__c();
        loan.Application__c = app.Id;
        loan.Customer_Type__c = 'Primary Applicant';
        loan.Customer_Information__c = acc.Id;
        loan.Residence_Address_Line_1__c = 'testaddress';
        insert loan;
        
        Loan_Applicant__c loan1 = new Loan_Applicant__c();
        loan1.Application__c = app.Id;
        loan1.Customer_Information__c = acc.Id;
        loan1.Residence_Address_Line_1__c = 'testaddress1';
        insert loan1;
        
        List<Bank_Detail__c> bankList = new List<Bank_Detail__c>();
        Bank_Detail__c bank = new Bank_Detail__c();
        bank.Name = 'SBI';
        bank.Application__c = app.Id; 
        bank.Loan_Applicant__c = loan.Id;
        bankList.add(bank);
        insert bankList;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'abc';
        cv1.VersionData = blob.valueOf('2');
        cv1.PathOnClient ='www';
        cv1.Parent_Id__c = '12';
        cv1.Uploaded_From__c = 'ag';
        cv1.Document_Set_Code_Id__c = 'qq';
        cv1.Document_Name__c = 'test11';
        insert cv1;
        
        Legal_Approval__c legal = new Legal_Approval__c();
        legal.Application__c = app.Id;
        legal.Status__c = 'Pending';
        insert legal; 
        
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
        ver.Status__c = 'Pending';
        insert ver;
        
        Id agreRecordTypeId = Schema.SObjectType.Agreement_Execution_Document_Generation__c.getRecordTypeInfosByName().get('Vernacular / LTI Declaration').getRecordTypeId();
        Agreement_Execution_Document_Generation__c ag = new Agreement_Execution_Document_Generation__c();
        ag.Application__c = app.Id;
        ag.RecordTypeId = agreRecordTypeId;
        ag.Document_Type__c = 'MOD';
        insert ag;
        
        GenericDataTableController gen = new GenericDataTableController();
        gen.METADATA_NAME = 'abc';
    }
    @isTest
    static void runTest(){ 
        Application__c application = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'ww'];
        Account acc = [SELECT Id,LastName FROM Account WHERE LastName = 'testacc'];
        List<Loan_Applicant__c> loanApp = [SELECT Id,Residence_Address_Line_1__c FROM Loan_Applicant__c WHERE Residence_Address_Line_1__c = 'testaddress'];
        Loan_Applicant__c loanApp1 = [SELECT Id,Residence_Address_Line_1__c FROM Loan_Applicant__c WHERE Residence_Address_Line_1__c = 'testaddress1'];
        List<Bank_Detail__c> bankDetail = new List<Bank_Detail__c>([SELECT Id,Name FROM Bank_Detail__c WHERE Name = 'SBI']);
        List<ContentVersion> cv1 = new List<ContentVersion>([SELECT Id,Title FROM ContentVersion WHERE Title = 'abc']);
        Legal_Approval__c legalApp = [SELECT Id,Status__c FROM Legal_Approval__c WHERE Status__c = 'Pending'];
        Verification__c verification = [SELECT Id,Status__c FROM Verification__c WHERE Status__c = 'Pending'];
        Agreement_Execution_Document_Generation__c agree = [SELECT ID,Document_Type__c FROM Agreement_Execution_Document_Generation__c WHERE Document_Type__c = 'MOD'];
        
        test.startTest();
        AgreementExecutionController.checkBankDetailsExist(application.Id);
        AgreementExecutionController.checkCKYCId(application.Id);
        AgreementExecutionController.checkDecision(application.Id);
        AgreementExecutionController.checkDocGenerated(application.Id);
        AgreementExecutionController.checkPennyDrop(application.Id);
        AgreementExecutionController.checkSendBackVaidation(application.Id);
        AgreementExecutionController.getApplicants(application.Id);
        AgreementExecutionController.getNACHApplicants(application.Id);
        AgreementExecutionController.getPrimaryApplicant(application.Id);
        AgreementExecutionController.getProperties(application.Id,'');
        AgreementExecutionController.getDGRecordId(application.Id, 'recTypeName');
        AgreementExecutionController.moveApplicationStage(application.Id);
        AgreementExecutionController.sendBackAprovalCredit(application.Id);
        AgreementExecutionController.sendBackLegalApproval(application.Id);
       //sAgreementExecutionController.checkDOSCondition(application.Id);
        AgreementExecutionController.getContentVersionRecords('12', 'ag');
        AgreementExecutionController.getApplicantAddress(loanApp1.Id);
        AgreementExecutionController.getEditPageContent(application.Id, 'abc');
        AgreementExecutionController.getAgDataTable(application.Id, 'abc', 'CKYC');
        AgreementExecutionController.getAgDataTable(application.Id, 'abc', 'NACH');
        AgreementExecutionController.getAgDataTable(application.Id, 'abc', 'Doc_Gen');
        AgreementExecutionController.saveRecord(application);
        AgreementExecutionController.checkRecordExist(new List<String> {loanApp[0].Id}, 'recTypeId');
        AgreementExecutionController.updateDocuments(JSON.serialize(cv1));
        AgreementExecutionController.getContentVersionRecordsNew('12', 'ag');
        test.stopTest();
    }
}