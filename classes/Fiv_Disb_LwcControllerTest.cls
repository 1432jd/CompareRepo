/**
* @File Name          : Fiv_Disb_LwcControllerTest.cls
* @Description        : Service Class For Fiv_Disb_LwcController class
* @Author             : Mo Arslan
* @Created On         : 27/01/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         27/01/2022              Mo Arslan               Initial Version
*/

@isTest
public class Fiv_Disb_LwcControllerTest {
    @TestSetup
    public static void makeData(){

        Branch_Master__c branch_masterObj = new Branch_Master__c(
            Name = 'Dhone',
            Branch_Code__c = 'AP036',
            Branch_category__c = 'SB',
            Collection_Branch__c = 'CB',
            Region__c = 'India Region',
            State__c = 'AP',
            Lms_Branch_Code__c = '5001279');
        insert branch_masterObj;

        Pre_Login__c pre_loginObj = new Pre_Login__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId(),
            Status__c = 'Active');
        insert pre_loginObj;

        Application__c applicationObj = new Application__c(
            Pre_Login__c = pre_loginObj.Id,
            Name__c = 'Manjhi Rahul',
            Alternate_Channel_Mode__c = 'Brokers',
            Channel__c = 'Common',
            Customer_Visit_date__c = Date.valueOf('2022-08-01'),
            Field_Officer_Employee_ID__c = 'Pre Login 1-FS-101',
            Requested_Loan_Amount__c = 99999,
            Stage__c = 'Disbursal Author',
            application_status__c = 'Active',
            hasVerificationRecords__c = true,
            Sourcing_Branch__c = branch_masterObj.Id,
            Amount_Recommended__c = 20000,
            Number_of_advance_EMI__c = '1',
            Nominee_Party__c = 'Manjhi Rahul',
            Nominee__c = 'Yes',
            Scheme__c = 'FSBL Business Loan');
        insert applicationObj;

        Disbursal__c disbursalObj = new Disbursal__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Disbursal__c').getDescribe().getRecordTypeInfosByName().get('Disbursal Maker').getRecordTypeId(),
            Application__c = applicationObj.Id,
            CKYC_ID_Number__c = '22',
            Disbursal_Beneficiary_Type__c = 'Multiple',
            Disbursal_Maker_ID__c = '222222',
            Disbursal_Type__c = 'Part Disb',
            Due_Date__c = Date.valueOf('2022-08-13'),
            First_Installment_Date__c = Date.valueOf('2022-08-12'),
            First_Time_Right_FTR__c = 'Yes',
            Interest_Start_Date__c = Date.valueOf('2022-08-12'),
            Final_Disbursal_Amount__c = 50000,
            Disbursal_Author_ID__c = UserInfo.getUserId(),
            FTR_Remarks_by_Author_OO_Responsibility__c = 'Na',
            FTR_Remarks_by_Maker_OO_Responsibility__c = 'Na',
            Ops_Comment__c = 'YEs');
        insert disbursalObj;

        Insurance_Details__c insurance_detailsObj = new Insurance_Details__c(
            Application__c = applicationObj.Id,
            Insurance_Medical_Test_Result__c = 'Standard',
            Insurance_Requirement__c = 'DOGH',
            Insurance_Waiver__c = 'Yes',
            Disbursal__c = disbursalObj.Id,
            Insured_Person_Name__c = 'Test',
            Insured_Person_Date_of_Birth__c = Date.valueOf('2022-08-23'),
            Nominee_DOB_as_per_KYC__c = Date.valueOf('2022-08-25'),
            Nominee_KYC_ID_Type__c = 'Aadhaar Card',
            Nominee_Type__c = 'Not Part of Loan',
            Nominee_Relationship_Type__c = 'Blood Relative',
            Nominee_KYC_ID_No__c = 'Ttest');
        insert insurance_detailsObj;

        Account accountObj = new Account(
            LastName = 'Manjhi',
            FirstName = 'Rahul',
            Salutation = 'Mr.',
            RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            PersonBirthdate = Date.valueOf('1971-07-09'),
            Father_s_Name__c = 'Sanjay',
            Gender__c = 'Male',
            Mother_s_Name__c = 'Sanjana',
            Nationality__c = 'Indian');
        insert accountObj;

        Loan_Applicant__c loan_applicantObj = new Loan_Applicant__c(
            Applicant_Type__c = 'Property Holder',
            Constitution__c = 'Individual',
            Customer_Type__c = 'Primary Applicant',
            Income_Considered__c = 'Yes',
            Initiate_From__c = 'Prelogin',
            KYC_ID_Type_1__c = 'Voter Id',
            KYC_Id_1__c = 'fdc45656662424134134',
            Married__c = 'No',
            Mobile_Verified__c = true,
            Mobile__c = '9898989898',
            Phone_Residence__c = '9898989898',
            Residence_Address_Line_1__c = 'Kalka Nagar',
            Residence_City__c = 'Agra',
            Residence_Country__c = 'India',
            Residence_District__c = 'Agra',
            Residence_State__c = 'Uttar Pradesh',
            Verification_Type__c = 'Self',
            Permanent_Country__c = 'India',
            Application__c = applicationObj.Id,
            Customer_Information__c = accountObj.Id,
            Business_Country__c = 'India');
        insert loan_applicantObj;

        MS_Scheme__c ms_schemeObj = new MS_Scheme__c(
            Applicable_FOIR__c = 50,
            Applicable_LTV__c = 50,
            Product_Name__c = 'FSBL LAP Business Loan',
            Due_Date__c = Date.valueOf('2022-09-02'),
            First_Installment_Date__c = Date.valueOf('2022-09-04'),
            Interest_Start_Date__c = Date.valueOf('2022-09-03'),
            Cycle_Date_Type__c = 'Range',
            Scheme_Code__c = 'LAP_BL',
            Scheme_Description__c = 'FSBL LAP Business Loan',
            Scheme_Id__c = '5000020',
            Type_Of_Interest__c = 'Fixed');
        insert ms_schemeObj;

        Disbursal_Payee__c disbursal_payeeObj = new Disbursal_Payee__c(
            Disbursal__c = disbursalObj.Id,
            Beneficiary_Amount__c = 22,
            Beneficiary_Name__c = 'Test',
            Payment_Type__c = 'Electronic Fund Transfer',
            Beneficiary_Bank_Account_Number__c = 'tEST',
            Beneficiary_Bank_Name__c = 'test bank',
            Beneficiary_Branch_Name__c = 'test bank',
            Beneficiary_Type__c = 'Disbursement Party Name');
        insert disbursal_payeeObj;

        IFSC_Code_Master__c ifsc_code_masterObj = new IFSC_Code_Master__c(
            Name = 'Test00000',
            Bank_Branch_Name__c = 'test branch',
            Bank_Name__c = 'test bank');
        insert ifsc_code_masterObj;

        Bank_Detail__c bank_detailObj = new Bank_Detail__c(
            Name = 'test bank',
            Account_Number__c = '000011112222',
            Account_Number_with_masking_digits__c = '000011112222',
            Account_Opening_Date__c = Date.valueOf('2022-08-01'),
            Account_Type__c = 'Savings',
            Branch_Name__c = 'test branch',
            Customer_Information__c = accountObj.Id,
            Loan_Applicant__c = loan_applicantObj.Id,
            Sample_Cheque_Taken__c = 'Yes',
            Branch_Location__c = 'Noida',
            Is_Account_Verified__c = true,
            MS_IFSC_Code__c = ifsc_code_masterObj.Id);
        insert bank_detailObj;

        MS_Pincode__c ms_pincodeObj = new MS_Pincode__c(
            Name = '282005',
            City__c = 'Agra',
            DistrictName__c = 'Agra',
            OfficeName_BO_SO_HO__c = 'Dayalbagh',
            Pincode__c = '282005',
            StateName__c = 'Uttar Pradesh',
            State_Code__c = 'UP',
            Sub_distname__c = 'Agra',
            Village_Locality_Name__c = 'Agra');
        insert ms_pincodeObj;

        Property__c propertyObj = new Property__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-B Property Detail').getRecordTypeId(),
            Application__c = applicationObj.Id,
            BM_Comments_for_Collateral__c = 'fd',
            Building_Area_Sq_Ft__c = 65,
            Building_Value_per_Sq_ft__c = 76,
            Collateral_Type__c = 'Rented Residential',
            Customers_Residing__c = 'Yes',
            Distance_from_Branch__c = 45,
            Doc_Seen_Original_with__c = 'Customer',
            Is_Fiv_B_Completed__c = true,
            Land_Area_Sq_Ft__c = 34,
            Pathway_Available__c = 'Yes',
            Pincode__c = ms_pincodeObj.Id,
            Property_Address__c = 'dffffff',
            Property_Type__c = 'Flat',
            Risk_Document__c = 'Orange',
            Title_Deed_Date__c = Date.valueOf('2023-01-10'),
            Title_Deed_Number__c = '12',
            Title_Deed_Type__c = 'Settlement or Gift or Consent Deed',
            Value_per_sq_ft__c = 4,
            Nature_Of_Property__c = 'Residential');
        insert propertyObj;

        Fee_Type_Master__c fee_type_masterObj = new Fee_Type_Master__c(
            Name = 'Cersai',
            Amount__c = 'Amount',
            Applicable_For__c = 'Application',
            Calculation_Basis__c = 'Flat',
            Description__c = 'Test',
            Event__c = 'Application Login',
            Fee_Type__c = 'System',
            GL_Code__c = '876',
            Modifiable_at_run_Time__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Stage_Due__c = 'Pre Login',
            Tax__c = 'Inclusive',
            Type__c = 'Fee',
            Value__c = 'Loan Amount',
            Waivable__c = 'Yes',
            Active__c = 'Yes',
            Fee_Category__c = 'Advance EMI');
        insert fee_type_masterObj;

        Fee_Value_Master__c fee_value_masterObj = new Fee_Value_Master__c(
            Cap__c = 11,
            Description__c = 'Cersai',
            Floor__c = 11,
            Max_waiver_amount_without_Approval__c = 231,
            Active__c = 'Yes',
            Fee_Type_Master__c = fee_type_masterObj.Id,
            Amount_Flat__c = 11);
        insert fee_value_masterObj;

        Fee_Creation__c fee_creationObj = new Fee_Creation__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Fee_Creation__c').getDescribe().getRecordTypeInfosByName().get('Fee').getRecordTypeId(),
            Applicable_on_Loan_Amount_Asset_Value__c = 'Loan Amount',
            Application__c = applicationObj.Id,
            Description__c = 'Cersai',
            Fee_Amount__c = 11,
            Fee_Value_Master__c = fee_value_masterObj.Id,
            Fee_Collection__c = 13,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Stage_Due__c = 'Login',
            Tax_Amount__c = 1.98,
            Total_Fee__c = 13,
            Type__c = 'System',
            Applicable_For__c = 'Application',
            Fee_Type_Master__c = fee_type_masterObj.Id,
            Amount__c = 'Amount',
            Calculation_Basis__c = 'Flat',
            Event__c = 'Application Login',
            GL_Code__c = '876',
            Receipt_Created__c = true,
            Stage__c = 'Pre Login',
            Tax__c = 'Exclusive',
            Value__c = 'Loan Amount',
            Waivable__c = 'Yes',
            Fee_Code__c = 'Cersai',
            Property__c = propertyObj.Id,
            Fee_Value_Amount__c = 11);
        insert fee_creationObj;

        Fee_Creation__c fee_creationObj1 = new Fee_Creation__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Fee_Creation__c').getDescribe().getRecordTypeInfosByName().get('Insurance').getRecordTypeId(),
            Applicable_on_Loan_Amount_Asset_Value__c = 'Loan Amount',
            Application__c = applicationObj.Id,
            Description__c = 'Cersai',
            Fee_Amount__c = 11,
            Fee_Value_Master__c = fee_value_masterObj.Id,
            Fee_Collection__c = 13,
            Repayment_Type_2__c = 'Deduct from Disbursement',
            Stage_Due__c = 'Login',
            Tax_Amount__c = 1.98,
            Total_Fee__c = 13,
            Type__c = 'System',
            Applicable_For__c = 'Application',
            Fee_Type_Master__c = fee_type_masterObj.Id,
            Amount__c = 'Amount',
            Calculation_Basis__c = 'Flat',
            Event__c = 'Application Login',
            GL_Code__c = '876',
            Receipt_Created__c = true,
            Stage__c = 'Pre Login',
            Tax__c = 'Exclusive',
            Value__c = 'Loan Amount',
            Waivable__c = 'Yes',
            Fee_Code__c = 'Cersai',
            Property__c = propertyObj.Id,
            Fee_Value_Amount__c = 11);
        insert fee_creationObj1;

        Application_User_Tracking__c application_user_trackingObj = new Application_User_Tracking__c(
            Owner__c = UserInfo.getUserId(),
            Stage__c = 'Disbursal Maker',
            Type__c = 'Application',
            Previous_Stage__c = 'Process Credit',
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Application__c = applicationObj.Id,
            Status__c = 'Pending');
        insert application_user_trackingObj;

        MS_Deviation__c ms_deviationObj = new MS_Deviation__c(
            Approval_Authority__c = 'L5',
            Code__c = 'DEV_080',
            Deviation_Description__c = 'Advance EMI is 0 or 2 or 3',
            Deviation_Level__c = 'Application',
            Deviation_Type__c = 'System',
            Is_Active__c = 'Yes',
            Stage__c = 'Operations');
        insert ms_deviationObj;

        TR_Deviation__c tr_deviationObj = new TR_Deviation__c(
            Applicable_for__c = 'Application',
            Application__c = applicationObj.Id,
            Decistion__c = 'Approval for Pending',
            Deviation_Code__c = 'DEV_080',
            Deviation_Type__c = 'System',
            Approval_Level__c = 'L5',
            Is_Deviation_Active__c = true,
            Deviation_Description__c = 'Advance EMI is 0 or 2 or 3',
            MS_Deviation__c = ms_deviationObj.Id);
        insert tr_deviationObj;
    }

    @isTest
    public static void getInsuranceDetailRecordsTest(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Test.startTest();
        Fiv_Disb_LwcController.getInsuranceDetailRecords(app.Id);
        Test.stopTest();
    }

    @isTest
    public static void test1(){
        Application__c app = [SELECT Id, Stage__c FROM Application__c LIMIT 1];
        Loan_Applicant__c loanAPP = [SELECT Id, Applicant_Name__c FROM Loan_Applicant__c LIMIT 1];
        Disbursal__c disb = [SELECT Id, RecordType.Name FROM Disbursal__c LIMIT 1];
        Disbursal_Payee__c disbPayee = [SELECT Id FROM Disbursal_Payee__c LIMIT 1];
        Loan_Applicant__c loanAPP1 = [SELECT Customer_Type__c FROM Loan_Applicant__c LIMIT 1];
        Pre_Login__c prelogin = [SELECT Id FROM Pre_Login__c LIMIT 1];
        loanAPP1.Customer_Type__c = 'C';
        Test.startTest();
        Fiv_Disb_LwcController.getLoanApplicantnames(app.Id);
        Fiv_Disb_LwcController.getLoanApplicantDOB(app.Id);
        Fiv_Disb_LwcController.getNominee(app.Id);
        Fiv_Disb_LwcController.getAppStage(app.Id);
        Fiv_Disb_LwcController.getAppStage(String.valueOf('--'));
        Fiv_Disb_LwcController.checkLoggedInUser();
        Fiv_Disb_LwcController.getApplicantsAcData(app.Id, loanAPP.Applicant_Name__c);
        Fiv_Disb_LwcController.getDueDateError(app.Id);
        Fiv_Disb_LwcController.getMetaDataFields(app.Id, 'Disbusal');
        Fiv_Disb_LwcController.getDisbursalData(app.Id);
        Fiv_Disb_LwcController.getfeeData(app.Id);
        Fiv_Disb_LwcController.getRelatedRecords(new List<String>{disb.Id}, 'DISBM_Insurance_Details');
        Fiv_Disb_LwcController.getIfscDetails('SBINOO31307');
        Fiv_Disb_LwcController.getIfscDetails('');
        Fiv_Disb_LwcController.initCKyc('');
        Fiv_Disb_LwcController.initCKyc(JSON.serialize(new Map<String, Object>{'apptId'=>app.Id}));
        Fiv_Disb_LwcController.callPennyDropAPI(disbPayee.Id);
        Fiv_Disb_LwcController.getDocumentId(app.Id, 'Test');
        Fiv_Disb_LwcController.allocateUser('Disbursal Maker', app.Id);
        Fiv_Disb_LwcController.allocateUser('Disbursal Author', app.Id);
        Fiv_Disb_LwcController.allocateUser('File Inward', app.Id);
        Fiv_Disb_LwcController.updateApptStageFromDA(app.Id, 'Approved','test');
        Fiv_Disb_LwcController.getAllocatedUser(app.Id);
        Fiv_Disb_LwcController.trackUser(app.Stage__c, app.Id);
        Fiv_Disb_LwcController.chechExistDeviaitons(app.Id);
        Fiv_Disb_LwcController.chechExistDeviaitons('');
        Fiv_Disb_LwcController.changeDisbursalRecTypeId(JSON.serialize(new Map<String, Object>{'disbId'=>disb.Id, 'disbRecTypeName'=>disb.RecordType.Name}));
        Fiv_Disb_LwcController.changeDisbursalRecTypeId(JSON.serialize(new List<String>{disb.Id,disb.RecordType.Name}));
        Fiv_Disb_LwcController.saveSobjectLists(new List<SObject>{app});
        Fiv_Disb_LwcController.saveSobjectLists(new List<SObject>{loanAPP1});
        Fiv_Disb_LwcController.deleteRecords(new List<SObject>{app});
        Fiv_Disb_LwcController.deleteRecords(new List<SObject>{prelogin});
        Fiv_Disb_LwcController.getNomineeData(app.Id, 'Test');
        Fiv_Disb_LwcController.getPennyDropStatus(disbPayee.Id, 'false');
        Fiv_Disb_LwcController.getPennyDropStatus(disbPayee.Id, 'false=');
        Fiv_Disb_LwcController.setDisbursalDate(app.Id);
        Fiv_Disb_LwcController.checkDisbursalMemo(app.Id);
        Test.stopTest();
    }

    @isTest
    public static void getInsuranceDetailsDataTest(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Test.startTest();
        Fiv_Disb_LwcController.getInsuranceDetailsData(app.Id);
        

        app.Nominee__c = 'No';
        update app;
        Fiv_Disb_LwcController.getInsuranceDetailsData(app.Id);
        Test.stopTest();
    }

    @isTest
    public static void getParentAndRelatedDataTest1(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        List<String> parentCondition = new List<String>{'Name = APP - 0673--Id = 00000000000'};
        List<String> childCondition = new List<String>{'WHERE Name = APP - 0673--Id = 00000000000'};
        Test.startTest();
        Fiv_Disb_LwcController.getParentAndRelatedData(app.Id, '', '', '', new List<String>(), new List<String>());
        Fiv_Disb_LwcController.getParentAndRelatedData('', '', '', '', new List<String>(), new List<String>());
        Fiv_Disb_LwcController.getParentAndRelatedData(app.Id, 'Application__c', 'Disbursal_Repayment_Details__r', '',parentCondition, parentCondition);
        Fiv_Disb_LwcController.getParentAndRelatedData(app.Id, 'Application__c', 'Disbursal_Repayment_Details__r', '',parentCondition, childCondition);
        Test.stopTest();
    }

    @isTest
    public static void getParentAndRelatedDataTest2(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        MS_Scheme__c ms_schemeObj = [SELECT Cycle_Date_Type__c FROM MS_Scheme__c LIMIT 1];
        ms_schemeObj.Cycle_Date_Type__c = 'EOM';
        update ms_schemeObj;
        List<String> parentCondition = new List<String>();
        List<String> childCondition = new List<String>();
        Test.startTest();
        Fiv_Disb_LwcController.getParentAndRelatedData(app.Id, '', '', '', parentCondition, childCondition);
        Test.stopTest();
    }

    @isTest
    public static void initDisbursalPayeeTest(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Disbursal__c disb = [SELECT Id FROM Disbursal__c LIMIT 1];
        Test.startTest();
        Fiv_Disb_LwcController.initDisbursalPayee(JSON.serialize(new Map<String, Object>{'apptId'=>app.Id, 'existDisbId'=>disb.Id}));
        Fiv_Disb_LwcController.initDisbursalPayee('');
        Test.stopTest();
    }

    @isTest
    public static void getDeductionAmountTest(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Test.startTest();
        Fiv_Disb_LwcController.getDeductionAmount(app.Id);
        Test.stopTest();
    }

    @isTest
    public static void saveDisbursalCompDataTest(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Insurance_Details__c disbObj = [SELECT Id,Nominee_Name__c, Insured_Person_Name__c,Application__c,Insurance_Medical_Test_Result__c,Insurance_Requirement__c,Insurance_Waiver__c,Disbursal__c,Insured_Person_Date_of_Birth__c,
                                        Nominee_DOB_as_per_KYC__c,Nominee_KYC_ID_Type__c,Nominee_Relationship_Type__c,Nominee_KYC_ID_No__c, Nominee_Relationship_with_Insured_Person__c, Nominee_Type__c FROM Insurance_Details__c LIMIT 1];

        Disbursal__c disbursal = [SELECT Id, Application__c,CKYC_ID_Number__c,Disbursal_Beneficiary_Type__c,Disbursal_Maker_ID__c,Disbursal_Type__c,Due_Date__c,
                                First_Installment_Date__c,First_Time_Right_FTR__c,Interest_Start_Date__c,Final_Disbursal_Amount__c,Disbursal_Author_ID__c,FTR_Remarks_by_Author_OO_Responsibility__c,
                                FTR_Remarks_by_Maker_OO_Responsibility__c,Ops_Comment__c FROM Disbursal__c LIMIT 1];

        Insurance_Details__c disbObj1 = [SELECT Id,Nominee_Name__c, Insured_Person_Name__c,Application__c,Insurance_Medical_Test_Result__c,Insurance_Requirement__c,Insurance_Waiver__c,Disbursal__c,Insured_Person_Date_of_Birth__c,
                                        Nominee_DOB_as_per_KYC__c,Nominee_KYC_ID_Type__c,Nominee_Relationship_Type__c,Nominee_KYC_ID_No__c, Nominee_Relationship_with_Insured_Person__c FROM Insurance_Details__c LIMIT 1];
        Test.startTest();
        Fiv_Disb_LwcController.saveDisbursalCompData(disbObj, 'base64', 'Test',app.Id);
        Fiv_Disb_LwcController.saveDisbursalCompData(disbObj1, 'base64', 'Test',app.Id);
        Fiv_Disb_LwcController.saveDisbursalCompData(disbursal, 'base64', 'Test',app.Id);
        Test.stopTest();
    }

    @isTest
    public static void saveDisbursalPayeeDataTest(){
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];
        Disbursal_Payee__c disbPayee = [SELECT Id, Disbursal__c,Beneficiary_Amount__c,Beneficiary_Name__c,Payment_Type__c ,Beneficiary_Bank_Account_Number__c,
                                        Beneficiary_Bank_Name__c,Beneficiary_Branch_Name__c,Beneficiary_Type__c,IsDisbIdCheck__c, Adjusted_Beneficiary_Amount__c,
                                        Application__c, Beneficiary_Account_Type__c,Beneficiary_IFSC_Code__c, Loan_Applicant__c FROM Disbursal_Payee__c LIMIT 1];

        Disbursal_Payee__c disbPayee1 = [SELECT Id, Disbursal__c,Beneficiary_Amount__c,Beneficiary_Name__c,Payment_Type__c ,Beneficiary_Bank_Account_Number__c,
                                        Beneficiary_Bank_Name__c,Beneficiary_Branch_Name__c,Beneficiary_Type__c,IsDisbIdCheck__c, Adjusted_Beneficiary_Amount__c,
                                        Application__c, Beneficiary_Account_Type__c, Loan_Applicant__c FROM Disbursal_Payee__c LIMIT 1];
        Test.startTest();
        Fiv_Disb_LwcController.saveDisbursalPayeeData(disbPayee, 'base64', 'Test', app.Id);
        Fiv_Disb_LwcController.saveDisbursalPayeeData(disbPayee1, 'base64', 'Test', app.Id);
        Test.stopTest();

        
    }
}