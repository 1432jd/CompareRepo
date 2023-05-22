@IsTest
public class FeeReceiptControllerTest {
    @TestSetup
    public static void testSetup(){

        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;

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
        
        User userObj = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            Username = 'ajay111@techmatrixconsulting.com.losdev',
            LastName = 'Kumar',
            FirstName = 'Ajay',
            Department = 'L2',
            Email = 'ajay.k@techmatrixconsulting.com',
            EmailPreferencesAutoBcc = true,
            EmailPreferencesStayInTouchReminder = true,
            Alias = 'akuma',
            CommunityNickname = 'User1647318829892921131',
            IsActive = true,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            ReceivesInfoEmails = true,
            ReceivesAdminInfoEmails = true,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            EmployeeNumber = 'EMP-001',
            UserPreferencesActivityRemindersPopup = true,
            UserPreferencesEventRemindersCheckboxDefault = true,
            UserPreferencesTaskRemindersCheckboxDefault = true,
            UserPreferencesDisableLikeEmail = true,
            UserPreferencesSortFeedByComment = true,
            UserPreferencesShowTitleToExternalUsers = true,
            UserPreferencesHideS1BrowserUI = true,
            UserPreferencesLightningExperiencePreferred = true,
            UserPreferencesHideSfxWelcomeMat = true,
            DigestFrequency = 'D',
            DefaultGroupNotificationFrequency = 'N',
            Employee_Id__c = '149149',
            Designation__c = 'Cashier',
            Approval_Level__c = 'L5');
         insert userObj;
        Fee_Type_Master__c fee_type_masterObj = new Fee_Type_Master__c(
            Name = 'Usr-LegaL',
        //    Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'User',
            Event__c = 'Application Login',
            Applicable_For__c = 'Application',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Exclusive',
            Amount__c = 'Percentage',
            Value__c = 'Loan Amount',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'No',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        insert fee_type_masterObj;
        
        Fee_Value_Master__c fee_value_masterObj = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
        insert fee_value_masterObj;
        
        Fee_Creation__c fee_creationObj = new Fee_Creation__c(
            recordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByName().get('Insurance').getRecordTypeId(),
            Type__c = 'User',
            Stage_Due__c = 'Pre Login',
            Receipt_Created__c = true,
            Application__c = app.Id,
            Applicable_on_Loan_Amount_Asset_Value__c = 'Asset Value',
            Fee_Code__c = 'Usr-LegaL',
            Repayment_Type_2__c = 'Direct Receipt', Fee_Type_Master__c = fee_type_masterObj.Id, Fee_Value_Master__c = fee_value_masterObj.Id);
         insert fee_creationObj;
        
        Fee_Creation__c fee_creationObj1 = new Fee_Creation__c(
            recordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId(),
            Type__c = 'User',
            Stage_Due__c = 'Pre Login',
            Receipt_Created__c = true,
            Application__c = app.Id,
            Applicable_on_Loan_Amount_Asset_Value__c = 'Asset Value',
            Fee_Code__c = 'Usr-LegaL',
            Repayment_Type_2__c = 'Direct Receipt');
         insert fee_creationObj1;
        
        Receipt__c receiptObj = new Receipt__c(
            Receipt_Date__c = Date.valueOf('2022-09-20'),
            Mode_of_payment__c = 'Cash',
            Approval_Status__c = 'Submitted',
            Customer_name__c = 'Parag Goyal',
            Cashier__c = userObj.Id,
            Fee_Code__c = fee_creationObj.Id,
            Application__c = app.Id,
            Pre_Login__c = preLogin.Id,
            Loan_Purpose__c = 'fgfh');
         insert receiptObj;
        
        Receipt__c receiptObj1 = new Receipt__c(
            Receipt_Date__c = Date.valueOf('2022-09-20'),
            Mode_of_payment__c = 'Cash',
            Approval_Status__c = 'Submitted',
            Customer_name__c = 'Parag Goyal',
            Cashier__c = userObj.Id,
            Fee_Code__c = fee_creationObj1.Id,
            Application__c = app.Id,
            Pre_Login__c = preLogin.Id,
            Loan_Purpose__c = 'fgfh');
         insert receiptObj1;
    }

    @IsTest
    public static void test(){
        Application__c app = [SELECT Id, Stage__c FROM Application__c limit 1];
        Receipt__c receipt = [SELECT Id, Name, Fee_Code__r.Repayment_Type_2__c,Approval_Status__c FROM Receipt__c limit 1];
        User ur = [SELECT Id FROM User limit 1];
        Fee_Creation__c fee = [SELECT Id FROM Fee_Creation__c limit 1];
        Pre_Login__c prelogin = [SELECT Id FROM Pre_Login__c limit 1];
        
        Test.startTest();
        FeeReceiptController.getReceiptData(app.Id, 'Lead Detail');
        FeeReceiptController.getReceiptData(app.Id, 'Process Credit');
        FeeReceiptController.getReceiptData(app.Id, 'Pre Login');
        FeeReceiptController.getCashiers();
        FeeReceiptController.submitReceiptForApproval(receipt.Id, ur.Id);
        FeeReceiptController.getExistingFeeCode(app.Id);
        FeeReceiptController.getExistingFeeCodeIns(app.Id);
        FeeReceiptController.getExistingFeeCodeRec(app.Id, 'Process Credit');
        FeeReceiptController.getExistingFeeCodeRec(app.Id, 'Pre Login');
        FeeReceiptController.getExistingFeeCodeRec(app.Id, 'Lead Detail');
        FeeReceiptController.updateReceiptFee(receipt.Id, fee.Id, 'Process Credit');
        receipt.Approval_Status__c = 'Rejected';
        update receipt;
        FeeReceiptController.getRecFeeRepayment(receipt.Id);
        FeeReceiptController.getApplicationBranchCode(app.Id);
        FeeReceiptController.getReceiptFeeStage(new List<String>{receipt.Name}, 'Process Credit');
        FeeReceiptController.getReceiptFeeStage(new List<String>{receipt.Name}, 'Pre Login');
        FeeReceiptController.getReceiptFeeStage(new List<String>{receipt.Name}, 'Disbursal Author');
        FeeReceiptController.getReceiptFeeStage(new List<String>{receipt.Name}, 'Agreement Execution');
        FeeReceiptController.getApplicationPrimaryApplicantName(app.Id);
        FeeReceiptController.pendingFeeAndReceiptForDA(app.Id);
        app.Stage__c = 'Disbursal Author';
        update app;
        FeeReceiptController.pendingFeeAndReceiptForDA(app.Id);
        Test.stopTest();
    }
}