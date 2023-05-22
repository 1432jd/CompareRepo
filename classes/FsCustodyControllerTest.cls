@isTest
public class FsCustodyControllerTest {
    
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
        
        ContentVersion cv1 = new ContentVersion(Title = 'Pdf',Document_Name__c = 'TestDoc', Is_Additional_Document__c = false, Parent_Id__c = appObj.id, ContentUrl ='www.test.com', Uploaded_From__c= 'Lead Detail', Is_Document_Master_Record__c = false, Document_Set_Code_Id__c='Test1', Document_Type__c = 'Application');
        insert cv1;
        Document_Master__c dm1 = new Document_Master__c(Name='Test1', Active__c = 'Yes', Description__c='Test1', Family__c = 'Address Proof', Type__c ='Application');
        insert dm1;  
        Document_Set_Code__c dsc1 = new Document_Set_Code__c(Name = 'Test1', Type__c = 'Application', Description__c = 'Test1', Active__c='Yes', Document_Master__c= dm1.Id, Mandatory__c='Yes', Stage__c='Lead Detail', Family__c='Address Proof');
        insert dsc1;
    }
    
    @isTest
    public static void testMethod1(){
        Application__c applicationRecord = new Application__c();        
        applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        ContentVersion cvList = [SELECT Id FROM ContentVersion Limit 1];
        Document_Set_Code__c dmSetCode = [Select ID from Document_Set_Code__c Limit 1];
        String wrapAppObj = '{"Id":"'+applicationRecord.ID+'","Name":"ABC"}';
        String wrapDocObj = '[{"Id":"'+cvList.ID+'","Name":"ABC"}]';
        FsCustodyController.createRecords(wrapAppObj);
        FsCustodyController.getAccess();
        FsCustodyController.updateDocuments(wrapDocObj);
        FsCustodyController.getAdditionalRecords(applicationRecord.ID);
        FsCustodyController.getContentVersionRecordsNew(applicationRecord.ID);
        FsCustodyController.getExistingRecord(applicationRecord.ID);
        FsCustodyController.getRepaymentDoc(applicationRecord.ID);
        FsCustodyController.getSource(applicationRecord.ID);
        FsCustodyController.getUsers();
        FsCustodyController.checkAccess(applicationRecord.Id);
        FsCustodyController.submitApp(wrapAppObj, True);
        FsCustodyController.submitApplications(wrapAppObj, True);
        FsCustodyController.getVDCDocuments(applicationRecord.Id);
                //FsCustodyController.createRecords('');

    }
}