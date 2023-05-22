@isTest
public class FsPreloginControllerTest {
    
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
        
        Pre_Login__c preLogin2 = new Pre_Login__c();
        preLogin2.Status__c = 'Rejected';
        insert preLogin2;
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd', Mandate_Req_ID__c = 'APItest0123457791010116');
        insert appObj;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = appObj.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        insert l;  
        
        KYC__c kyc = new KYC__c();
        kyc.Loan_Applicant__c = l.ID;
        insert kyc;
        
        
        Property__c prop1 = new Property__c();
        prop1.Application__c =appObj.Id;
        prop1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId(); 
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        insert prop1;
        
        MS_Pincode__c ms_pincodeObj = new MS_Pincode__c(
            Name = '444001',
            Pincode__c = '444001');
        insert ms_pincodeObj;
        
        Application_User_Tracking__c aut = new Application_User_Tracking__c();
        aut.Application__c  = appObj.Id;
        insert aut;
    }
    
    @isTest
    public static void testMethod1(){
        String RecordTy = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        Application__c applicationRecord = new Application__c();        
        applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        Pre_Login__c preLogin = [Select ID from Pre_Login__c Limit 1];
        Pre_Login__c preLogin2 = [Select ID from Pre_Login__c Where Status__c='Rejected' Limit 1];
        KYC__c kyc = [Select Id from  KYC__c Limit 1];
        Application_User_Tracking__c aut = [Select id from Application_User_Tracking__c Limit 1];
        List<String> strList = new List<String>();
        strList.add('hello');    
        Loan_Applicant__c objLoan = [Select Id From Loan_Applicant__c Limit 1];
        List<String> loaAppList = new List<String>();
        loaAppList.add(objLoan.Id);    
        property__c prop = [Select Id from property__c Limit 1];
        MS_Pincode__c ms_pincodeObj = [Select ID,Pincode__c from MS_Pincode__c Limit 1];
        
        FsPreloginController.getRecordTypeName(RecordTy);
        FsPreloginController.getApplicationId(preLogin.Id);
        FsPreloginController.getMetadtaInfoForm('1231231','abc');
        FsPreloginController.saveRecord(preLogin);
        FsPreloginController.insertPreLogin();
        FsPreloginController.insertApplications(preLogin.Id); 
        FsPreloginController.insertApplications(preLogin2.Id);    
        FsPreloginController.insertKYCDocuments(strList,strList,applicationRecord.Id,objLoan.Id);
        FsPreloginController.updateKYCOR(objLoan.Id, kyc.ID);
        FsPreloginController.getApplicationRecord(applicationRecord.Id);
        FsPreloginController.getBranchName();
        FsPreloginController.createPropertyOwners(prop.ID,loaAppList);
        FsPreloginController.clonePropertyNew(applicationRecord.Id);
        FsPreloginController.getPropertyOwners(applicationRecord.Id);
        FsPreloginController.getPinId(ms_pincodeObj.Pincode__c);
        FsPreloginController.getApplicationName(applicationRecord.Id);
        FsPreloginController.checkTitleDeedNumber(applicationRecord.Id,'121');
        FsPreloginController.updateHistory(applicationRecord.ID);
        FsPreloginController.checkKYCIdExist('123asd', 'xyz', applicationRecord.ID,objLoan.Id);
        FsPreloginController.getDocumentPublicList(applicationRecord.Id, objLoan.Id);
        FsPreloginController.checkPropertyOnSubmit(applicationRecord.Id);
    }
}