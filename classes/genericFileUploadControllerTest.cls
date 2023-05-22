@isTest
public class genericFileUploadControllerTest {
    
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
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            Category__c = 'OCR',
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = appObj.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    @isTest
    public static void testMethod1(){
        Application__c loanApp = [Select ID from Application__c Limit 1];
        ContentDocument cd = [Select id,Title from ContentDocument Limit 1];
        Account account = [Select ID from Account Limit 1];
        genericFileUploadController.getDocumentNames(loanApp.ID);
        genericFileUploadController.updateDocumentName(cd.Title, cd.Id, 'Category__c', account.Id);
    }
}