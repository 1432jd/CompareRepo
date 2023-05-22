@isTest
public class DropDownCode_BatchTest {
    @testSetup()
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
        app.Stage__c = 'Login';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;
        
        Account accountObj = new Account(
            RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            LastName = 'THANGADURAJ',
            FirstName = 'ANISHA',
            Salutation = 'Ms.',
            PersonBirthdate = Date.valueOf('1994-07-05'),
            Father_s_Name__c = 'ORIGINAL SEENR VERIFIL',
            Gender__c = 'Female',
            Mother_s_Name__c = 'GANGA',
            Nationality__c = 'Indian',
            Gender_Code__c = 'FEMALE',
            Nationality_Code__c = 'Indian',
            Salutation_Code__c = 'MS');
         insert accountObj;
        
        Loan_Applicant__c loan_applicantObj = new Loan_Applicant__c(
            Applicant_Type__c = 'None Of The Above',
            Customer_Information__c = accountObj.Id,
            Application__c = app.Id,
            Business_Country__c = 'India',
            Constitution__c = 'Individual',
            Created_From__c = 'Pre Login',
            Customer_Type__c = 'Co-Applicant',
            Income_Considered__c = 'Yes',
            Initiate_From__c = 'Prelogin',
            Is_Bureau_Verified__c = true,
            Is_KYC_Verified__c = true,
            KYC_ID_Type_1__c = 'Pan Card',
            KYC_Id_1__c = 'CHIPA2562C',
            Married__c = 'Yes',
            Mobile_Verified__c = true,
            Mobile__c = '8072431160',
            Permanent_Country__c = 'India',
            Residence_Address_Line_1__c = '10/127B, PALA VILAI, KANDANVILAI NAGERCOIL',
            Residence_City__c = 'Kanyakumari',
            Residence_Country__c = 'India',
            //Residence_Pincode__c = 'a08C20000020Ag7IAE',
            Residence_State__c = 'Tamil Nadu',
            Verification_Type__c = 'OCR',
            Relationship_With_Main_Applicant__c = 'Spouse',
            IsDedupeExecuted__c = true,
            Business_Country_Code__c = 'IND',
            Permanent_Country_Code__c = 'IND',
            Residence_Country_Code__c = 'IND');
         insert loan_applicantObj;
    }
    
    @isTest
    public static void test(){
        Loan_Applicant__c loanAPP = [SELECT Id, Business_City__c FROM Loan_Applicant__c];
        loanAPP.Business_City__c = 'Jaipur';
        update loanAPP;
        Test.startTest();
        Database.executeBatch(new DropDownCode_Batch(), 200);
        Test.stopTest();
    }
}