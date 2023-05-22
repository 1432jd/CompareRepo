@IsTest
public class LoanApplicantTriggerHelperTest {

    @IsTest
    public static void setupDedupeData() {

        List<Application__c> appList = new List<Application__c>();
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        List<Dedupe_Loan_Detail__c> dedupeLoanList = new List<Dedupe_Loan_Detail__c>();
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        List<Account> accList = new List<Account>();

        Account acc = new Account();
        acc.FirstName='ram';
        acc.LastName='kumar';
        acc.PersonBirthdate = System.today();
        accList.add(acc);
        insert accList;
        
        Application__c app = new Application__c();
        app.Stage__c ='Login';
        insert app;

        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Application__c= app.Id;
        loanAppObj.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj.KYC_Id_1__c='xyz';
        loanAppObj.KYC_Id_2__c ='dwd';
        loanAppObj.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj.IsDedupeExecuted__c=true;
        loanAppObj.Customer_Information__c=acc.Id;
        loanAppObj.LMS_Customer_Info_File_Number__c='GLBCUST00000668385';
        loanAppObj.Override__c ='Override';
        insert loanAppObj;
        
        Dedupe_Detail__c dedupeObj = new Dedupe_Detail__c();
        dedupeObj.CIF_Id__c ='xyz123';
        dedupeObj.Dedupe_Invoke_From__c='Pc';
        dedupeObj.Button_Name__c='Check Dedupe';
        dedupeObj.Loan_Applicant__c=loanAppObj.Id;
        dedupeObj.Active__c='No';
        dedupeObj.Archive__c=false;
        dedupeObj.Application__c = app.Id;
        dedupeObj.Source__c ='LMS';
        insert dedupeObj;

        Dedupe_Loan_Detail__c dedupeLoanObj = new Dedupe_Loan_Detail__c();
        dedupeLoanObj.Lan__c='abc123xyz';
        dedupeLoanObj.Dedupe_Detail__c=dedupeObj.Id;
        dedupeLoanList.add(dedupeLoanObj);
        insert dedupeLoanList;

        loanAppObj.KYC_Id_1__c='hjik';
        update loanAppObj;
        loanAppObj.KYC_Id_2__c='whjik';
        update loanAppObj;
        loanAppObj.KYC_ID_Type_1__c='Voter Id';
        update loanAppObj;
        loanAppObj.KYC_ID_Type_2__c='Pan Card';
        update loanAppObj;
        
        accList[0].FirstName='ramu';
        update accList;
        accList[0].PersonBirthdate = System.today().addDays(-50);
        update accList;


    }
}