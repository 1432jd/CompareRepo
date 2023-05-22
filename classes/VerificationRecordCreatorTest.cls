@IsTest
public class VerificationRecordCreatorTest {
    @testSetup
    public static void testSetup(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='FS Platform User Profile']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8',FirstName= 'Dedupe Exception',LastName='User', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='dedupe@testorg.com');
        Insert u;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8',FirstName= 'Dedupe Admin',LastName='User', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='dedupeAdm@testorg.com');
        Insert u1;

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin; 
        
        Pre_Login__c preLogin1 = new Pre_Login__c();
        preLogin1.Status__c = 'Active';
        preLogin1.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin1;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Login';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        app.Name = 'APP-0001';
        insert app;
        
        Application__c app1 = new Application__c();
        app1.Pre_Login__c = preLogin1.Id;
        app1.Stage__c = 'Login';
        app1.application_status__c = 'Active';
        app1.LMS_Response_Reference__c = '8984734335';
        app1.IsExceptionRaised__c = true;
        app1.Name = 'APP-0002';
        insert app1;
        
        Account acc = new Account();
        acc.FirstName='ram';
        acc.LastName='kumar';
        insert acc;
        
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Application__c= app1.Id;
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
        dedupeObj.CIF_Id__c	='xyz123';
        dedupeObj.Dedupe_Invoke_From__c='Pc';
        dedupeObj.Button_Name__c='Check Dedupe';
        dedupeObj.Loan_Applicant__c=loanAppObj.Id;
        dedupeObj.Active__c='No';
        dedupeObj.Archive__c=false;
        dedupeObj.Application__c = app.Id;
        dedupeObj.Source__c ='LMS';
        dedupeObj.OwnerId = u1.Id;
        insert dedupeObj;
        //dedupeList.add(dedupeObj);
        
        Dedupe_Detail__c dedupeObj1 = new Dedupe_Detail__c();
        dedupeObj1.CIF_Id__c	='xyz1234';
        dedupeObj1.Dedupe_Invoke_From__c='Pc';
        dedupeObj1.Button_Name__c='Check Dedupe';
        dedupeObj1.Loan_Applicant__c=loanAppObj.Id;
        dedupeObj1.Active__c='Yes';
        dedupeObj1.Archive__c=false;
        dedupeObj1.Application__c = app.Id;
        dedupeObj1.Source__c ='LMS';
        dedupeObj1.OwnerId = u1.Id;
        insert dedupeObj1;
        
        Dedupe_Detail__c dedupeObj2 = new Dedupe_Detail__c();
        dedupeObj2.CIF_Id__c	='xyz12345';
        dedupeObj2.Dedupe_Invoke_From__c='Pc';
        dedupeObj2.Button_Name__c='Check Dedupe';
        dedupeObj2.Loan_Applicant__c=loanAppObj.Id;
        dedupeObj2.Active__c='Override';
        dedupeObj2.Archive__c=false;
        dedupeObj2.Application__c = app.Id;
        dedupeObj2.Source__c ='LMS';
        dedupeObj2.OwnerId = u1.Id;
        insert dedupeObj2;
        
        Dedupe_Loan_Detail__c dedupeLoanObj = new Dedupe_Loan_Detail__c();
        dedupeLoanObj.Lan__c='abc123xyz';
        dedupeLoanObj.Dedupe_Detail__c=dedupeObj.Id;
        insert dedupeLoanObj;
    }

    @IsTest
    public static void createVerificationRecordsTest(){
        Application__c app = [SELECT Id FROM Application__c where LMS_Response_Reference__c = '8984734334'];
        Application__c app1 = [SELECT Id FROM Application__c where LMS_Response_Reference__c = '8984734335'];
        List<Loan_Applicant__c> loan = [ SELECT Id, Application__c, LMS_Customer_Info_File_Number__c, 
                                        (select Id, Archive__c,Active__c from Dedupe_Details__r where Archive__c  = false 
                                         AND  Owner.Name != 'Dedupe Exception User') 
                                        FROM Loan_Applicant__c
                                        WHERE Application__c =: app1.Id  AND IsDedupeExecuted__c=true];
        List<Dedupe_Detail__c> ded = [select Id, Archive__c,Active__c from Dedupe_Detail__c where Archive__c  = false 
                                         AND  Owner.Name != 'Dedupe Exception User'];
        System.debug('1 '+loan.size());
        System.debug('2 '+loan[0].Dedupe_Details__r.size());
        System.debug('3 '+ded.size());
        Test.startTest();
        VerificationRecordCreator.createVerificationRecords(app.Id);
        VerificationRecordCreator.createVerificationRecords(app1.Id);
        Test.stopTest();
    }
}