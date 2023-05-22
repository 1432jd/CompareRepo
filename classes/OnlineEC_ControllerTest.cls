@isTest 
public class OnlineEC_ControllerTest {
    @TestSetup
    static void testdata(){
        Account acc = new Account();
        acc.LastName = 'test1';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Id NewLoginRecordType = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        Pre_Login__c listlogin = new Pre_Login__c();
        Pre_Login__c login1= new Pre_Login__c(Status__c='Active',RecordTypeId= NewLoginRecordType);
        Pre_Login__c login2= new Pre_Login__c(Status__c='Rejected',RecordTypeId = NewLoginRecordType);
        
        Property__c prp = new Property__c();
        prp.Login__c= login1.Id;
        prp.Customer_Information__c= acc.Id;
        prp.Address_Line_2__c = 'Testing';
        insert prp;
        
        Application__c app= new Application__c();
  //    app.External_Lawyer__c = acc.Id;
        app.Applicant_Name__c = 'Application';
        app.Pre_Login__c = login1.Id;
        insert app;
        
        Loan_Applicant__c loanAppObj =  new Loan_Applicant__c();
        loanAppObj.Application__c=app.Id;
        loanAppObj.Business_Landmark__c = 'abc';
        loanAppObj.Customer_Information__c = acc.Id;
        insert loanAppObj;
        
        Verification__c verObj= new Verification__c();
        Id OnlineECRecordType = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('Online EC').getRecordTypeId();
        verObj.RecordTypeId = OnlineECRecordType;
        verObj.Application__c= app.Id;
        verObj.Status__c = 'Pending';
        insert verObj;
        
       // ContentVersion cv = [SELECT Id, ContentDocumentId, Title, FileType, FileExtension, ContentSize FROM ContentVersion WHERE FileExtension = 'jpg' And Title = 'abc' Limit 1];
      /*  ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'abc';
        cv1.VersionData = blob.valueOf('2');
        cv1.PathOnClient ='www.jpg';
        insert cv1;*/
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Image';
        cv.PathOnClient = 'Test_Image.jpg';
        cv.VersionData = Blob.valueOf('Test Image Data');
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test1 Image';
        cv1.PathOnClient = 'Test1_Image.jpeg';
        cv1.VersionData = Blob.valueOf('Test1 Image Data');
        cv1.IsMajorVersion = true;
        insert cv1;
        
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = cv.id;
        cd.Name = cv.Title;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;
        
        ContentDistribution cd1 = new ContentDistribution();
        cd1.ContentVersionId = cv1.id;
        cd1.Name = cv1.Title;
        cd1.PreferencesAllowViewInBrowser = true;
        cd1.PreferencesLinkLatestVersion = true;
        cd1.PreferencesNotifyOnVisit = false;
        cd1.PreferencesPasswordRequired = false;
        cd1.PreferencesAllowOriginalDownload = true;
        insert cd1;

    }
    @isTest
    static void testAllMethod(){
        Account account = [SELECT Id,LastName FROM Account WHERE LastName = 'test1'];
        Application__c application = [SELECT Id FROM Application__c WHERE Applicant_Name__c= 'Application'];
        Verification__c verification =  [SELECT Id,RecordType.Name FROM Verification__c WHERE RecordType.Name =:'Online EC'];
        ContentVersion cv = [SELECT Id,Title,PathOnClient FROM ContentVersion WHERE Title = 'Test Image' AND PathOnClient = 'Test_Image.jpg'];
        ContentVersion cv1 = [SELECT Id,Title,PathOnClient FROM ContentVersion WHERE Title = 'Test1 Image' AND PathOnClient = 'Test1_Image.jpeg'];
        Loan_Applicant__c loan = [SELECT Id,Application__c,Business_Landmark__c FROM Loan_Applicant__c WHERE Business_Landmark__c = 'abc'];
        Property__c prop = [SELECT Id ,Address_Line_2__c FROM Property__c WHERE Address_Line_2__c =: 'Testing'];
        
        Test.startTest();
        OnlineEC_Controller.getCollateralDetails(application.Id);
        OnlineEC_Controller.getApplicantRecords(application.Id);
        OnlineEC_Controller.getLoanApplicantRecords(application.Id);
        OnlineEC_Controller.getVerification(verification.Id);
        OnlineEC_Controller.getOnline_EC_Data(application.Id);
        OnlineEC_Controller.getApplicantData(application.Id);
        OnlineEC_Controller.getPropertyRec(prop.Id);
        OnlineEC_Controller.getOnlineECRecordTypeId();
        OnlineEC_Controller.getPropertyRecords(application.Id,loan.Id);
        OnlineEC_Controller.saveRecord(application);
        OnlineEC_Controller.generatePublicLink(cv.id);
        OnlineEC_Controller.generatePublicLink(cv1.id);
        Test.stopTest();    
    }
}