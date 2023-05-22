@isTest
public class Staging_BatchTest {
    @TestSetup
    public static void testSetup(){
        Staging_Loan__c staging_loanObj = new Staging_Loan__c(
            Name = 'a1T0w000000kJJ0',
            Ltv__c = 30.86,
            Application_Type__c = 'Normal',
            Branch_Code__c = 'TS003A',
            Business_Income__c = 15000,
            Loan_Account_No__c = 'FSTSLALONS000005220501',
            Loan_Purpose__c = 'Outside credit',
            Loan_Purpose_Code__c = 'OC',
            Customer_Requested_Loan_Amount__c = 400000,
            Customer_Disbursal_Amount__c = 400000,
            Field_Officer_Name__c = 'jangam sangameshwar 9010884464',
            Field_Officer_Id__c = '16374',
            Account_Number__c = 'APPL00240683',
            Emi__c = 9807,
            Principal_OS__c = '356009.52',
            Total_Tenor__c = 84,
            Applicant_Name__c = 'M LAVANYA KUMARI',
            Dbr__c = 0.4562,
            Branch_Name__c = 'Hyderabad 12',
            Old_Loan_Obligations__c = '0',
            Old_Collateral_Value__c = '500000',
            Old_Loan_Gross_Income__c = 360000,
            Old_Loan_Net_Income__c = 258000,
            Neo_Cif_Id__c = 'GLBCUST00000708792',
            Loan_Amount__c = 400000,
            Channel__c = 'ALTERNATE_CHANNEL',
            Sanction_Loan_Amount__c = 400000,
            Alternate_Channel_Mode__c = 'Direct Marketing',
            Tenure_Requested__c = 12,
            Total_Income__c = 15000
        );
        insert staging_loanObj;
        
        Staging_Customer__c staging_customerObj = new Staging_Customer__c(
            Name = 'a1S0w000000jU5C',
            Application_Number__c = 'APPL00241425',
            Applicant_Name__c = 'SHAIK MAHABOOB BASHA',
            Applicant_Type__c = 'PRIMARY',
            Salutation__c = 'Mr',
            First_Name__c = 'SHAIK',
            Last_Name__c = 'BASHA',
            Full_Name__c = 'SHAIK MAHABOOB BASHA',
            Mother_s_Name__c = 'AKBAR HUSSAIN',
            Age__c = 43,
            Applicant_s_Gender__c = 'Male',
            Marital_Status__c = 'Married',
            Nationality__c = 'Indian',
            Resident_Type__c = 'Resident Indian',
            Category__c = 'General',
            Occupation__c = 'Others',
            Voters_Id__c = 'ZGF2456896',
            PAN__c = 'EYEPS6319N',
            Applicant_Type_Code__c = '0',
            Salutation_Code__c = 'MR',
            Applicants_Gender_Code__c = 'MALE',
            Marital_Status_Code__c = 'Married',
            Residence_Type_Code__c = 'Resident',
            Category_Code__c = '2001',
            Religion_Code__c = 'Muslim',
            Occupation_Code__c = 'others',
            Nationality_Code__c = '12501',
            Religion__c = 'Muslim',
            Date_of_Birth__c = Date.valueOf('1977-01-31'),
            Loan_Account_No__c = 'FSTSLALONS000005220501',
            Neo_Cif_Id__c = 'GLBCUST00000708792',
            Relationship_With_Applicant__c = 'Main_applicant',
            Place_Of_Birth__c = 'KURNOOL',
            Aadhar_No__c = '53763839463'
        );
        insert staging_customerObj;
        
        Staging_Address__c staging_addressObj = new Staging_Address__c(
            Name = 'a160w000002b8pf',
            Application_Number__c = 'APPL00240340',
            Loan_Account_No__c = 'FSTNLALONS000005198578',
            Flat_Plot_Number__c = 'NO 7/87, KUNNU MEDU COLONY, CHETTIKULAM PERAMBALUR',
            City__c = 'Thrissur',
            State__c = 'Kerala',
            Pincode__c = '621104',
            Country__c = 'India',
            Address_Type__c = 'PermanentAddress',
            City_Code__c = '613',
            State_Code__c = 'KL',
            Country_Code__c = 'IND',
            Neo_Cif_Id__c = 'GLBCUST00000708792',
            Full_Address__c = 'NO 7/87, KUNNU MEDU COLONY, CHETTIKULAM PERAMBALUR'
        );
        insert staging_addressObj;
        
        Staging_Property__c staging_propertyObj = new Staging_Property__c(
            Name = 'a1R0w000000zTj8',
            Application_Number__c = 'APPL00240649',
            Loan_Account_No__c = 'FSTSLALONS000005220501',
            Property_Purchased_Type__c = 'Existing / Resale',
            Property_Type__c = 'FLAT',
            Nature_Of_Property__c = 'Residential',
            Property_Location_Classification__c = 'Rural',
            Building_Area__c = 465.4,
            Carpet_Area__c = 465.4,
            Proposed_Area__c = 'SELF_OCCUPIED',
            Property_Purpose__c = 'SELF_OCCUPIED',
            Property_Ownership__c = 'FreeHold',
            Age_Of_Property__c = '20',
            Residual_Age_of_property__c = 'LESS_THAN_5_YEARS',
            Market_Value__c = 588033.6,
            Add_Copy_From_an_Existing_Address__c = '1‐91, SAMUDRAPALLI, PALAMANER 5',
            Flat_Plot_Number__c = '1‐91, SAMUDRAPALLI, PALAMANER 5',
            City__c = 'Chittoor',
            State__c = 'Andhra Pradesh',
            Property_Type_Code__c = 'FLAT',
            Property_Purchased_Type_Code__c = 'Resale',
            Nature_Of_Property_Code__c = 'RESIDENTIAL',
            Property_Location_Classification_Code__c = 'Rural',
            City_Code__c = '138',
            State_Code__c = 'AP',
            Property_Purpose_Code__c = 'SELF_OCCUPIED',
            Title_Deed_Number__c = '6871',
            Collateral_Id__c = 'COLL00425533',
            Title_Deed_Type__c = 'Gift Deed',
            Northby__c = 'house of dorababu',
            Eastby__c = 'house of subramanyam',
            Westby__c = 'CC ROAD',
            Southby__c = 'CC ROAD',
            Northby1__c = '29',
            Southby1__c = '29',
            Eastby1__c = '31',
            Westby1__c = '31'
        );
        insert staging_propertyObj;
    }

    @IsTest
    public static void test(){
        Test.startTest();
        Database.executeBatch(new Staging_Batch(), 200);
        Database.executeBatch(new Staging_Batch(), 200);
        Test.stopTest();
    }
}