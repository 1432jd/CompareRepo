@isTest
public class EmandateStatusAPITest {
 
    @TestSetup
    static void createTestData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        insert preLogin;
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd', Mandate_Req_ID__c = 'APItest0123457791010116');
        insert appObj;
        
        Application__c appObj2 = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Process Credit',
                                                   LMS_Response_Reference__c='xyz',application_status__c='Active',
                                                   EMI__c=234, Loan_Amount__c =214,
                                                   Nach_Party__c='abd', Nach_Party_2__c='abc');
        //insert appObj2;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = appObj.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        loanList.add(l);
        
        Loan_Applicant__c l1 = new Loan_Applicant__c();
        l1.Application__c = appObj.Id;
        l1.Customer_Type__c ='Co-Applicant';
        l1.Constitution__c ='Individual';
        l1.Customer_Information__c = ci.id;
        l1.Residence_District__c = 'Delhi';
        l1.Mobile__c = '1234567891';
        loanList.add(l1);
        
        Loan_Applicant__c l2 = new Loan_Applicant__c();
        l2.Application__c = appObj.Id;
        l2.Customer_Type__c ='Guarantor';
        l2.Constitution__c ='Individual';
        l2.Customer_Information__c = ci.id;
        l2.Residence_District__c = 'Delhi';
        l1.Mobile__c = '1234567890';
        loanList.add(l2);
        insert loanList;
        
        IFSC_Code_Master__c ifscCodeMaster = new IFSC_Code_Master__c();
        ifscCodeMaster.Name='isfcCode';
        insert ifscCodeMaster;
        
        Bank_Detail__c bankDetailObj = new Bank_Detail__c();
        bankDetailObj.Application__c = appObj.Id;
        bankDetailObj.Customer_Information__c = ci.Id;
        bankDetailObj.MS_IFSC_Code__c = ifscCodeMaster.Id;
        bankDetailObj.Loan_Applicant__c = loanList.get(0).id;
        insert bankDetailObj;
        
           Bank_Detail__c bankDetailObj2 = new Bank_Detail__c();
        bankDetailObj2.Name = 'failed';
        bankDetailObj2.Application__c = appObj2.Id;
        bankDetailObj2.Customer_Information__c = ci.Id;
        bankDetailObj2.MS_IFSC_Code__c = ifscCodeMaster.Id;
        bankDetailObj2.Loan_Applicant__c = loanList.get(0).id;
        insert bankDetailObj2;
        
    }
    
    
    @isTest
    public static void testEmandateStatusAPI1(){
        Bank_Detail__c bankDetailRecord = new Bank_Detail__c();
        bankDetailRecord = [SELECT Id FROM Bank_Detail__c LIMIT 1];
        EmandateStatusAPI.callEmandateStatusAPI(bankDetailRecord.Id);
        
    }
    
        @isTest
    public static void testEmandateStatusAPI2(){
        Bank_Detail__c bankDetailRecord = new Bank_Detail__c();
        bankDetailRecord = [SELECT Id FROM Bank_Detail__c where name ='failed' LIMIT 1];
        EmandateStatusAPI.callEmandateStatusAPI(bankDetailRecord.Id);
        
    }
    
}