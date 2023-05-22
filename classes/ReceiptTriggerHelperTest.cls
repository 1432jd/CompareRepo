@isTest
public class ReceiptTriggerHelperTest {
    @isTest
    public static void test(){
        
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
        
        Fee_Creation__c fee_creationObj = new Fee_Creation__c(
            Premium__c = 1010,
            Sum_Assured__c = 200000,
            Type__c = 'User',
            Total_Fee__c = 1192,
            Stage_Due__c = 'Process Credit',
            Application__c = app.Id,
            Fee_Code__c = 'Ins-Cersai2',
            Tax_Amount__c = 182,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Loan_Applicant__c = loanApp.Id,
            Applicable_For__c = 'Applicant');
        insert fee_creationObj;
        
        Receipt__c receiptObj1 = new Receipt__c(
            Receipt_Date__c = Date.valueOf('2022-09-20'),
            Mode_of_payment__c = 'Cash',
            Approval_Status__c = 'Rejected',
            Customer_name__c = 'Parag Goyal',
            Cashier__c = userObj.Id,
            Fee_Code__c = fee_creationObj.Id,
            Application__c = app.Id,
            Pre_Login__c = preLogin.Id,
            Loan_Purpose__c = 'fgfh');
         insert receiptObj1;
        Application_User_Tracking__c recTracking = new Application_User_Tracking__c();
        //To create Application_User_Tracking__c record for Deviation : 12-11-22
          recTracking.Stage__c = 'Approval Credit';
          
          recTracking.Application__c = app.Id;
          recTracking.Status__c = 'Pending';
          recTracking.Type__c = 'Receipt';
          recTracking.Receipt__c = receiptObj1.Id;
          recTracking.Owner__c = userObj.Id;
          recTracking.Start_Date__c = System.now();
        insert recTracking;
        List<Receipt__c> recList = new List<Receipt__c>();
        recList.add(receiptObj1);
        List<Fee_Creation__c> feeList = new List<Fee_Creation__c>();
        feeList.add(fee_creationObj);
        
        
        Test.startTest();
        ReceiptTriggerHelper.ReceiptMaker(JSON.serialize(recList));
        ReceiptTriggerHelper.rejectedReceiptsFee(New List<String>{fee_creationObj.Id}, New List<String>{receiptObj1.Id});
        Test.stopTest();
    }
}