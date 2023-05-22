@isTest
public class Application_TH_DoSharingTest {
	@isTest
    public static void testApplicationSharing(){
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
        
        Branch_Master__c bm2 =new Branch_Master__c();
		bm2.Name = 'Chennai';
		bm2.State__c = 'TN';
		insert bm2;
		
		Access_Branch_Allocation__c abm = new Access_Branch_Allocation__c();
		abm.Branch_Master__c = bm.Id;
		abm.Access_Master__c = acm.Id;
		insert abm;
        
        Application__c app = new Application__C();
        app.Sourcing_Branch__c = bm.Id;
        app.Stage__c='Login';
        app.Requested_Loan_Amount__c = 100000;
        insert app;
        
        app.Sourcing_Branch__c = bm2.Id;
        update app;
    }
}