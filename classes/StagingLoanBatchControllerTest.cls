/**
* @File Name          : StagingLoanBatchControllerTest.cls
* @Description        : Service Class For StagingLoanBatchController class
* @Author             : Mo Arslan
* @Created On         : 24/01/2023
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        24/01/2023              Mo Arslan       Initial Version
*/
@isTest
public class StagingLoanBatchControllerTest {
    
    @testSetup
    public static void testSetup(){
        Staging_Loan__c staging_loanObj = new Staging_Loan__c(
            Name = 'a1DC20000001WnD',
            Account_Number__c = 'APPL00166868',
            Alternate_Channel_Mode__c = 'Customer Refferal',
            Applicant_Name__c = 'KAMALA P',
            Application_Number__c = 'APPL00166868',
            Application_Type__c = '0',
            Branch_Code__c = 'AP017',
            Branch_Name__c = 'Chittoor',
            Channel__c = 'ALTERNATE_CHANNEL',
            Customer_Disbursal_Amount__c = 100000,
            Customer_Requested_Loan_Amount__c = 300000,
            Dbr__c = 0.1635,
            Dpd__c = 47,
            Emi__c = 2452,
            Field_Officer_Id__c = '14840',
            Field_Officer_Name__c = 'R.YUGANDHAR PH NO : 7810023240',
            Loan_Account_No__c = 'FSAPLALONS000005157376',
            Loan_Amount__c = 100000,
            Loan_Purpose_Code__c = 'LAP_RE_IM',
            Loan_Purpose__c = 'Home Renovation / Improvement',
            Ltv__c = 20.82,
            Neo_Cif_Id__c = 'GLBCUST00000510807',
            Old_Loan_Gross_Income__c = 180000,
            Old_Loan_Net_Income__c = 180000,
            Old_Loan_Obligations__c = '0',
            Other_Expected_Income__c = 9000,
            Other_Income__c = 9000,
            Principal_OS__c = '80619.49',
            Sanction_Loan_Amount__c = 100000,
            Tenure_Requested__c = 84,
            Total_Income__c = 9000,
            Total_Tenor__c = 83,
            Mule_External_Id__c = 'FSAPLALONS000005157376');
        insert staging_loanObj;
        
        Staging_Customer__c staging_customerObj = new Staging_Customer__c(
            Name = 'a1H0w000000ybEa',
            Age__c = 34,
            Applicant_Name__c = 'TALARI VANNUR',
            Applicant_Type__c = 'Primary Applicant',
            Applicant_s_Gender__c = 'Male',
            Applicants_Gender_Code__c = 'MALE',
            Application_Number__c = 'APPL00170929',
            Category_Code__c = '2001',
            Category__c = 'General',
            First_Name__c = 'TALARI',
            Full_Name__c = 'TALARI VANNUR',
            Last_Name__c = 'VANNUR',
            Loan_Account_No__c = 'FSAPLALONS000005157376',
            Marital_Status_Code__c = 'Married',
            Marital_Status__c = 'Married',
            Mother_s_Name__c = 'TALARI MOULALI',
            Nationality_Code__c = '12501',
            Nationality__c = 'Indian',
            Neo_Cif_Id__c = 'GLBCUST00000510807',
            Occupation_Code__c = 'others',
            Occupation__c = 'Others',
            Phone_Residence__c = '8106829631',
            Relationship_With_Applicant_Code__c = 'Son',
            Relationship_With_Applicant__c = 'Son',
            Residence_Type_Code__c = 'Resident',
            Resident_Type__c = 'Resident Indian',
            Salutation_Code__c = 'MR',
            Salutation__c = 'Mr',
            Voters_Id__c = 'IGQ0456533',
            Mule_External_Id__c = 'FSAPLALONS000005161277GLBCUST00000532648Resident Indian');
        insert staging_customerObj;
        
        Staging_Address__c staging_addressObj = new Staging_Address__c(
            Name = 'a1G0w0000017gia',
            Address_Line_2__c = 'OLD CHINBRAHMADARAM',
            Address_Type__c = 'PermanentAddress',
            Application_Number__c = 'APPL00125808',
            City_Code__c = '199',
            City__c = 'East Godavari',
            Country_Code__c = 'IND',
            Country__c = 'India',
            Flat_Plot_Number__c = 'D NO 3-77/3',
            Full_Address__c = 'D NO 3-77/3OLD CHINBRAHMADARAM',
            Loan_Account_No__c = 'FSAPLALONS000005157376',
            Neo_Cif_Id__c = 'GLBCUST00000510807',
            Ownership_Type_Residence_Address_Code__c = 'ROWHOUSE',
            Ownership_Type__c = 'Row House',
            Pincode__c = '860311',
            State_Code__c = 'AP',
            State__c = 'Andhra Pradesh',
            Mule_External_Id__c = 'FSAPLALONS000005121035GLBCUST00000371546PermanentAddress');
        insert staging_addressObj;
        
        Staging_Address__c staging_addressObj1 = new Staging_Address__c(
            Name = 'a1G0w0000017gia',
            Address_Line_2__c = 'OLD CHINBRAHMADARAM',
            Address_Type__c = 'ResidentialAddress',
            Application_Number__c = 'APPL00125808',
            City_Code__c = '199',
            City__c = 'East Godavari',
            Country_Code__c = 'IND',
            Country__c = 'India',
            Flat_Plot_Number__c = 'D NO 3-77/3',
            Full_Address__c = 'D NO 3-77/3OLD CHINBRAHMADARAM',
            Loan_Account_No__c = 'FSAPLALONS000005157376',
            Neo_Cif_Id__c = 'GLBCUST00000510807',
            Ownership_Type_Residence_Address_Code__c = 'ROWHOUSE',
            Ownership_Type__c = 'Row House',
            Pincode__c = '860311',
            State_Code__c = 'AP',
            State__c = 'Andhra Pradesh',
            Mule_External_Id__c = 'FSAPLALONS000005121035GLBCUST00000371546PermanentAddress');
        insert staging_addressObj1;
        
        Staging_Address__c staging_addressObj2 = new Staging_Address__c(
            Name = 'a1G0w0000017gia',
            Address_Line_2__c = 'OLD CHINBRAHMADARAM',
            Address_Type__c = 'BusinessAddress',
            Application_Number__c = 'APPL00125808',
            City_Code__c = '199',
            City__c = 'East Godavari',
            Country_Code__c = 'IND',
            Country__c = 'India',
            Flat_Plot_Number__c = 'D NO 3-77/3',
            Full_Address__c = 'D NO 3-77/3OLD CHINBRAHMADARAM',
            Loan_Account_No__c = 'FSAPLALONS000005157376',
            Neo_Cif_Id__c = 'GLBCUST00000510807',
            Ownership_Type_Residence_Address_Code__c = 'ROWHOUSE',
            Ownership_Type__c = 'Row House',
            Pincode__c = '860311',
            State_Code__c = 'AP',
            State__c = 'Andhra Pradesh',
            Mule_External_Id__c = 'FSAPLALONS000005121035GLBCUST00000371546PermanentAddress');
        insert staging_addressObj2;
        
        Staging_Property__c staging_propertyObj = new Staging_Property__c(
            Name = 'a1I0w000001qB7d',
            Add_Copy_From_an_Existing_Address__c = 'GRAM BHOMA TOLA WARD NO 06 BHOMA TOLA BHOMA SEONI MP SEONI',
            Address_Line_2__c = 'TOLA BHOMA SEONI MP SEONI',
            Age_Of_Property__c = '1',
            Application_Number__c = 'APPL00299343',
            Building_Area__c = 1450,
            Carpet_Area__c = 1450,
            City_Code__c = '552',
            City__c = 'Seoni',
            Collateral_Id__c = 'COLL00493825',
            Eastby1__c = '25',
            Eastby__c = 'Village boundary',
            Flat_Plot_Number__c = 'GRAM BHOMA TOLA WARD NO 06 BHOMA',
            Loan_Account_No__c = 'FSAPLALONS000005157376',
            Market_Value__c = 2052000,
            Nature_Of_Property_Code__c = 'RESIDENTIAL',
            Nature_Of_Property__c = 'Residential',
            Northby1__c = '92.4',
            Northby__c = 'Land of saller',
            Property_Location_Classification_Code__c = 'Urban',
            Property_Location_Classification__c = 'Urban',
            Property_Ownership__c = 'FreeHold',
            Property_Purchased_Type_Code__c = 'New',
            Property_Purchased_Type__c = 'New',
            Property_Purpose_Code__c = 'SELF_OCCUPIED',
            Property_Purpose__c = 'SELF_OCCUPIED',
            Property_Type_Code__c = 'ROWHOUSE',
            Property_Type__c = 'ROW HOUSE',
            Proposed_Area__c = 'SELF_OCCUPIED',
            Residual_Age_of_property__c = 'LESS_THAN_5_YEARS',
            Southby1__c = '92.4',
            Southby__c = 'Land of saller',
            State_Code__c = 'MP',
            State__c = 'Failed',
            Title_Deed_Number__c = '1061691',
            Title_Deed_Type__c = 'Sale Deed',
            Westby1__c = '25',
            Westby__c = 'Road',
            Error_Reason__c = 'Title Deed Number: data value too large: 1061691.0 (max length=8)',
            Mule_External_Id__c = 'FSMPLALONS000005240861COLL00493825');
        insert staging_propertyObj;
    }
       
    @IsTest
    public static void test(){
        Test.startTest();
        Database.executeBatch(new StagingLoanBatchController(false), 200);
        Database.executeBatch(new StagingLoanBatchController(false), 200);
        Test.stopTest();
    }
}