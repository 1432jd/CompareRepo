@isTest
public class FS_DOS_ControllerTest {
	@isTest
    public static void testDOSController(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FS Platform User Profile'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert u;
        
        Access_Master__c acm = new Access_Master__c();
        acm.Access_For__c = 'FIV - C';
        acm.Capacity__c = 50;
        acm.Capacity_Used__c = 0;
        acm.User__c = u.Id;
        acm.Level__c = '7';
        acm.Name = 'FIV - C';
        insert acm;
        
        Branch_Master__c bm =new Branch_Master__c();
		bm.Name = 'Rajasthan';
		bm.State__c = 'RJ';
		insert bm;
		
		Access_Branch_Allocation__c abm = new Access_Branch_Allocation__c();
		abm.Branch_Master__c = bm.Id;
		abm.Access_Master__c = acm.Id;
		insert abm;
        
        Application__c app = new Application__C();
        app.Sourcing_Branch__c = bm.Id;
        app.Stage__c='Login';
        app.Requested_Loan_Amount__c = 100000;
        insert app;
        
        Document_Checklist_Value_Master__c dosMaster = new Document_Checklist_Value_Master__c();
        dosMaster.Document_Type__c = 'Test 1';
        dosMaster.Active__c = True;
        dosMaster.Guidance__c = 'this is my test guidance.';
        dosMaster.Sequence__c = 1;
        dosMaster.Check_Point__c = 'check 1';
        insert dosMaster;
        
        DOS__c dosObj = new DOS__c();
        dosObj.Application__c = app.Id;
        dosObj.Document_Checklist_Value_Master__c = dosMaster.Id;
        dosObj.Status__c = 'Ok';
        dosObj.Verification__c = 'Yes';
        dosObj.Verification_Remarks_Observations__c = 'testing fine';
        insert dosObj;
        
        List<FS_DOS_Controller.DOSParentWrapper> wrapperList = new List<FS_DOS_Controller.DOSParentWrapper>();
        wrapperList = FS_DOS_Controller.getDOSDataNew(app.Id);
        
        FS_DOS_Controller.saveDOSData(app.Id, JSON.serialize(wrapperList));
    }
}