/**
* @author            : Ashish Sharma
* @group             : TechMatrix Consulting
* @description       : This class will cover test coverage FS_LMS_CreateCustomerAPI.
* @created on        : 08-09-2022
* @last modified on  : 08-09-2022
* @last modified by  : Ashish Sharma
**/
@IsTest
public class FS_LMS_CreateCustomerAPITest {
    
    @TestSetup
    public static void setupCustomerData() {
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.EMI__c = 48;
        app.Customer_Communicated__c = 24;
        app.Effective_IRR__c = 23;
        app.Number_of_advance_EMI__c = '1';
        app.Tenor_In_Months__c = '24';
        app.Loan_Purpose_1__c = 'Personal Loan';
        app.Nach_Party__c = 'www';
        app.Customer_Visit_date__c = date.today();
        insert app;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = app.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        loanList.add(l);
        
        Loan_Applicant__c l1 = new Loan_Applicant__c();
        l1.Application__c = app.Id;
        l1.Customer_Type__c ='Co-Applicant';
        l1.Constitution__c ='Individual';
        l1.Customer_Information__c = ci.id;
        l1.Residence_District__c = 'Delhi';
        l1.Mobile__c = '1234567891';
        loanList.add(l1);
        
        Loan_Applicant__c l2 = new Loan_Applicant__c();
        l2.Application__c = app.Id;
        l2.Customer_Type__c ='Guarantor';
        l2.Constitution__c ='Individual';
        l2.Customer_Information__c = ci.id;
        l2.Residence_District__c = 'Delhi';
        l1.Mobile__c = '1234567890';
        loanList.add(l2);
        
        MS_Pincode__c ms_pincodeObj = new MS_Pincode__c(
            Name = '796001',
            City_Code__c = '007',
            City__c = 'Aizwal',
            Pincode__c = '796001',
            StateName__c = 'Mizoram',
            State_Code__c = 'MZ',
            Place_Name__c = 'Aizwal-796001',
            LMS_State_Code__c = '5000019',
            LMS_Zip_Code__c = '5086772',
            LMS_City_Code__c = '5000007');
        insert ms_pincodeObj;
        
        Loan_Applicant__c loan_applicantObj = new Loan_Applicant__c(
            Application__c = app.Id,
            Customer_Information__c = ci.id,
            Applicant_Type__c = 'Property Holder',
            Business_Address_Line_1__c = 'EAST STREET VIRUGAVUR 606203',
            Business_Address_Line_2__c = 'APPL00469602',
            Business_City__c = 'Aizwal',
            Business_Country__c = 'India',
            Business_Flat_Plot_Number__c = '234',
            Business_Pincode__c = ms_pincodeObj.Id,
            Business_State__c = 'Mizoram',
            Business_Taluka__c = 'VIRUGAVUR',
            Business_Village__c = 'VIRUGAVUR',
            CKYC_ID_Number__c = '12345678',
            Communication_Address__c = 'Residence',
            Constitution__c = 'Individual',
            Created_From__c = 'Pre Login',
            Customer_Type__c = 'Primary Applicant',
            Income_Considered__c = 'Yes',
            Initiate_From__c = 'Prelogin',
            Is_Bureau_Verified__c = true,
            Is_KYC_Verified__c = true,
            Is_Lead_Detail_Done__c = true,
            KYC_ID_Type_1__c = 'Voter Id',
            KYC_ID_Type_2__c = 'Aadhaar Card',
            KYC_Id_1__c = 'NSY1703412',
            KYC_Id_2__c = '287111460005',
            LMS_Customer_Info_File_Number__c = 'GLBCUST00001056188',
            Marital_Status__c = 'Married',
            Married__c = 'Yes',
            Mobile_Verified__c = true,
            Mobile__c = '9940254526',
            Permanent_Address_Line_1__c = 'EAST STREET VIRUGAVUR 606203',
            Permanent_Address_Line_2__c = 'APPL00469602',
            Permanent_City__c = 'Aizwal',
            Permanent_Country__c = 'India',
            Permanent_Flat_Plot_Number__c = '234',
            Permanent_Pincode__c = ms_pincodeObj.Id,
            Permanent_State__c = 'Mizoram',
            Permanent_Taluka__c = 'VIRUGAVUR',
            Permanent_Village__c = 'VIRUGAVUR',
            Residence_Address_Line_1__c = 'EAST STREET VIRUGAVUR 606203',
            Residence_Address_Line_2__c = 'APPL00469602',
            Residence_City__c = 'Aizwal',
            Residence_Country__c = 'India',
            Residence_Flat_Plot_Number__c = '234',
            Residence_Pincode__c = ms_pincodeObj.Id,
            Residence_State__c = 'Mizoram',
            Residence_Taluka__c = 'VIRUGAVUR',
            Residence_Village__c = 'VIRUGAVUR',
            Resident_Type__c = 'Resident',
            Same_As_Address_Business__c = 'Residence Address',
            Same_As_Address_Pernament__c = 'Residence Address',
            Verification_Type__c = 'OCR',
            Relationship_With_Main_Applicant__c = 'Self',
            IsDedupeExecuted__c = true,
            Disbursal_CKYC_ID_Number_History__c = '12345678',
            Disbursal_CKYC_ID__c = '12345678',
            Business_Country_Code__c = 'IND',
            Marital_Status_Code__c = 'Married',
            Permanent_Country_Code__c = 'IND',
            Residence_Country_Code__c = 'IND');
        insert loan_applicantObj;
        
        
        //insert loanList;
        
        IFSC_Code_Master__c ifscCodeMaster = new IFSC_Code_Master__c();
        ifscCodeMaster.Name='isfcCode';
        insert ifscCodeMaster;
        
        Bank_Detail__c bankDetailObj = new Bank_Detail__c();
        bankDetailObj.Application__c = app.Id;
        bankDetailObj.Customer_Information__c = ci.Id;
        bankDetailObj.MS_IFSC_Code__c = ifscCodeMaster.Id;
        bankDetailObj.Loan_Applicant__c = loanList.get(0).id;
        insert bankDetailObj;
    }
    
    @IsTest
    public static void testFS_LMS_CreateCustomerAPI() {
        Loan_Applicant__c loanApplicantRecord = new Loan_Applicant__c();
        loanApplicantRecord = [SELECT Id,Application__r.Name FROM Loan_Applicant__c LIMIT 1];
        
        FS_LMS_CreateCustomerAPI.createCustomer(loanApplicantRecord.Id,'','');
        String responseData = getResponseData();
        List<String> responseDataList = new List<String>();
        responseDataList.add(responseData);
        FS_LMS_CreateCustomerAPI.mailResponse(responseDataList);
    }
    
    public static String getResponseData() {
        String responseData = '';
		responseData = '"requestBody":"test","responseBody":"test","endPointUrl":"test","StatusCode":"200","Status":"Success","userName":"test","userId":"0055j000004FcYtAAK","apiName":"Customer","lmsCustomerNumber":"GLBCUST00001056629","errorDescription":"","exceptionMessage":"","exceptionLineNo":"","custmerId":"GLBCUST00001056629","appId":"test"';
		return responseData;
    }
}