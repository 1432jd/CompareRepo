@IsTest
public class GenericEditPagesControllerHelperTest {
    
    @TestSetup
    static void createTestData(){
        Application__c appObj = new Application__c( Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,Tranche_Disbursal__c='I',
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd', Mandate_Req_ID__c = 'APItest0123457791010116');
        insert appObj;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = appObj.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        insert l; 
    }
    @isTest
    public static void testMethod1(){
        Loan_Applicant__c loanApp = [Select ID from Loan_Applicant__c Limit 1];
        
        GenericEditPagesControllerHelper gepch = new GenericEditPagesControllerHelper();
        GenericEditPagesControllerHelper.getSectionContent(loanApp.Id, 'Lead_Details_Personal_Informat');
        GenericEditPagesControllerHelper.saveRecord(loanApp);
    }
}