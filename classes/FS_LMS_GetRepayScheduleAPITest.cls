/**
* @author            : Ashish Sharma
* @group             : TechMatrix Consulting
* @description       : This class will cover test coverage FS_LMS_BookLoanAPI.
* @created on        : 25-01-2023
* @last modified on  : 25-01-2023
* @last modified by  : Ashish Sharma
**/
@IsTest
public class FS_LMS_GetRepayScheduleAPITest {
    
    @TestSetup
    public static void setupApplicationData() {
        Id legalRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        Id onlineECRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Online EC Property Detail').getRecordTypeId();
        Id FIVCRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId(); 
        Id PreloginRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId(); 
        
        Branch_Master__c branch_masterObj = new Branch_Master__c(
            Name = 'Aminjikarai',
            Branch_Code__c = 'TN001',
            Branch_category__c = 'NB',
            Region__c = 'Poonamallee',
            State__c = 'TN',
            Lms_Branch_Code__c = '5000633');
        insert branch_masterObj;
        
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User standardUser = new User(Alias = 'standt', Email='test@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserdeviationtest@testorg.com');
        insert standardUser;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c applicationObj = new Application__c(
            Pre_Login__c = preLogin.Id,
            Name = 'APP - 0625',
            AC_Decision__c = 'Approve',
            AC_Remarks__c = 'LOAN AMOUNT :  450LAKHS',
            AC_Submission_Date__c = Date.valueOf('2023-01-18'),
            Agreement_Execution_Status__c = 'Completed',
            Alternate_Channel_Mode__c = 'Brokers',
            Amount_Recommended__c = 440000,
            Balance_Transfer_Amount__c = 100000,
            Balance_Transfer__c = 'Individual',
            Borrower_s_Risk_Rating__c = 'Low',
            Channel__c = 'Alternate_Channel',
            Disbursal_Date__c = Date.valueOf('2022-06-01'),
            Comment_Remarks__c = '] No affiliations with persons as detailed in credit policy',
            Constitution__c = 'Individual',
            Customer_Communicated__c = 23.75,
            Customer_Segment__c = 'Salaried',
            Customer_Visit_date__c = Date.valueOf('2023-01-10'),
            DBR_PC__c = 49.03,
            DOS_Decision_Remarks__c = 'OK',
            DOS_Decision__c = 'Approved',
            DOS_Report_Finding_Observations__c = 'OK',
            DOS_Required__c = true,
            Date_of_legal_opinion__c = Date.valueOf('2021-01-01'),
            Disbursal_Author_Decision__c = 'Approve',
            Disbursement_Party_Name__c = 'ESAKKIMUTHU K',
            Disbursement_party__c = 'Disbursement Party Name',
            Discussion_done_with__c = 'TL',
            Effective_IRR__c = 24.54,
            File_Category__c = 'Normal',
            File_Type__c = 'Normal',
            Group_Valuation__c = 948840,
            HM__c = '500',
            Insurance_Premium__c = 4423,
            Job_Id__c = '1673262',
            KYC_Risk_Rating__c = 'Low',
            LMS_Response_Reference__c = 'FSTNLALONS000005001121',
            Legal_Decision__c = 'Approved',
            Legal_Sanction_Condition__c = 'Original Doc No. 1685 / 2022 has to be collected.',
            Living_style__c = 'Good',
            Loan_Categorisation__c = 'Business',
            Loan_Purpose_2__c = 'Home Renovation /Improvement',
            MODT_Schedule__c = 'All that piece and parcel of land and building (if any) measuring an extent of 55 Sq.Mtr., bearing house no Old No.3/146, New No.3/291',
            MODT_Template__c = 'Normal',
            MODT_to_be_done_in_name_of__c = 'P',
            Mandate_Req_ID__c = 'APIAPP06252023118161418',
            Mortgage_property_Collateral_Value__c = 948840,
            Nach_Party_2__c = 'ISAISELVI E',
            Nach_Party__c = 'ESAKKIMUTHU K',
            Name__c = 'ESAKKIMUTHU K',
            Neighbour_feedback__c = 'Positive',
            Nominee_Party__c = 'ISAISELVI E',
            Nominee__c = 'Yes',
            Number_of_advance_EMI__c = '1',
            PC_Decision__c = 'Recommend',
            PC_Remarks__c = 'OK',
            //Primary_Applicant__c = 'a0qC20000009UIDIA2',
            Product_Type__c = 'LAP',
            //Recommended_AC_User__c = '005C2000000xG8nIAE',
            Registration_District__c = 'Tenkasi Joint I',
            Registration_URL__c = 'https://emandateuat.rblbank.com/enach/emandateuploadpage.aspx?ref=6wRfsmynaber9VIg%2FkAsNA%3D%3D&Mandatereqid=APIAPP06252023118161418',
            Requested_Loan_Amount__c = 450000,
            Risk_Document_Color__c = 'Green',
            Risk_Document__c = 'Green',
            SRO_Office__c = 'Tenkasi',
            Sanction_Amount_Restriction__c = 'No',
            Sanction_amount_restriction_upto__c = 450000,
            Scheme__c = 'FSBL Mortgage Loan',
            Sourcing_Branch__c = branch_masterObj.Id,
            Stage__c = 'Document Deferral',
            Take_Over__c = 'No',
            Tenor_In_Months__c = '84',
            Tenure_Requested__c = 84,
            Total_Net_Income__c = 22506,
            Tranche_Disbursal__c = 'Normal',
            Upload_date__c = Date.valueOf('2023-01-17'),
            application_status__c = 'Active',
            hasVerificationRecords__c = true,
            PC_Submission_Date__c = Date.valueOf('2023-01-18'),
            Disbursal_Author_Completion_Date__c = Date.valueOf('2023-01-18'),
            Disbursal_Maker_Completion_Date__c = Date.valueOf('2023-01-18'),
            Decision_Date_Time__c = DateTime.now(),
            Net_Income_Considered_Financial_Calc__c = 28886,
            Loan_Purpose__c = 'Personal Use',
            Customer_Disbursal_amount__c = 400000,
            GetRepayScheduleCalled__c = true,
            Nominee_Party_Relationship_with_Insured__c = 'Wife of',
            Loan_Type__c = 'FSBL Mortgage Loan',
            Loan_Purpose_1__c = 'Balance Transfer',
            Any_Approval_to_be_Obtained__c = 'No',
            Legal_Pending__c = 'No',
            Verified_UN_sanctions_list_and_no_match__c = true,
            Nominee_Relationship_Type__c = 'Blood Relative',
            Insurance_Requirement__c = 'DOGH',
            Insurance_Medical_Test_Result__c = 'Standard');
        insert applicationObj;
    }
    
    @IsTest
    public static void testFS_LMS_BookLoanAPI() {
        Application__c applicationRecord = new Application__c();
        applicationRecord = [SELECT Id FROM Application__c LIMIT 1];
        String errorMsg = '{"error": {"source": "Portal","target": "LMS","errorCode": "403","message": "Request is Forbidden","description": " forbidden (403).","timestamp": "2022-12-20 12:16:57+0000"}}';
        Test.startTest();
        FS_LMS_GetRepayScheduleAPI.getRepaySchedule(applicationRecord.Id);
        FS_LMS_GetRepayScheduleAPI.parseError(errorMsg);
        Test.stopTest();
    }
}