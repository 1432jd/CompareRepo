@isTest
public class EmandateBankListAPITest {
    
    
    @TestSetup
    static void createTestData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        User u1 = new User(Alias = 'AUser', Email='standar1duser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='AUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standar1duser@testorg.com');
        insert u1;
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        insert preLogin;
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd');
        insert appObj;
        
        Application__c appObj2 = new Application__c(
            LMS_Response_Reference__c='xyz',application_status__c='Active',
            EMI__c=442, Loan_Amount__c =123,
            Nach_Party__c='xyc', Nach_Party_2__c='abc');
        insert appObj2;
        
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
        
        Bank_List__c bkl = new Bank_List__c();
        bkl.name = 'bklist';
        bkl.Bank_Id__c = '12345';
        insert bkl;
        
        Bank_Detail__c bankDetailObj2 = new Bank_Detail__c();
        bankDetailObj2.Application__c = appObj2.Id;
        bankDetailObj2.Name ='failed';
        bankDetailObj2.Customer_Information__c = ci.Id;
        bankDetailObj2.MS_IFSC_Code__c = ifscCodeMaster.Id;
        bankDetailObj2.Loan_Applicant__c = loanList.get(0).id;
        bankDetailObj2.Bank_Code__c = '123';
        insert bankDetailObj2;
        
        Bank_List__c bkl2 = new Bank_List__c();
        bkl2.name = 'bklist2';
        bkl2.Bank_Id__c = '12345231';
        insert bkl2;
        
    }
    
    
    @isTest
    public static void testEmandateBankListAPI1(){
        Bank_Detail__c bankDetailRecord = new Bank_Detail__c();
        bankDetailRecord = [SELECT Id FROM Bank_Detail__c LIMIT 1];
        Bank_List__c objBank = [SELECT ID, Name, Bank_Id__c FROM Bank_List__c LIMIT 1];
        EmandateBankListAPI.callEmandateBankListAPI(bankDetailRecord.Id);
    }
    
    @isTest
    public static void testEmandateBankListAPI2(){
        Bank_Detail__c bankDetailRecord = new Bank_Detail__c();
        bankDetailRecord = [SELECT Id FROM Bank_Detail__c  where name = 'failed' LIMIT 1];
        //  Bank_List__c objBank = [SELECT ID, Name, Bank_Id__c FROM Bank_List__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE alias = 'AUser' Limit 1];
        test.startTest();
        System.runAs(testUser){
            try{
                EmandateBankListAPI.callEmandateBankListAPI(bankDetailRecord.Id);
            } catch (DmlException ex) {
                System.assertEquals('expected text', ex.getMessage());
            }  
            test.stopTest();
            
        }
    }
    
}