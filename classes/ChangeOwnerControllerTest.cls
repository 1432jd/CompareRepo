@isTest
public class ChangeOwnerControllerTest {
	@isTest
    public static void checkChangeOwnerController(){
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
        acm.Access_For__c = 'Login';
        acm.Capacity__c = 50;
        acm.Capacity_Used__c = 0;
        acm.User__c = u.Id;
        acm.Level__c = '7';
        acm.Name = 'Login';
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
        app.OwnerId = UserInfo.getUserId();
        insert app;
        
        Application_User_Tracking__c aut = new Application_User_Tracking__c();
        aut.Application__c = app.Id;
        aut.Stage__c = 'Login';
        aut.Status__c = 'Pending';
        aut.Start_Date__c = System.now();
        aut.Owner__c = UserInfo.getUserId();
        insert aut;
            
        changeOwnerController.getPendingItems(app.Id);
        changeOwnerController.getUsers(app.Id, 'Login');
        changeOwnerController.changeOwner(app, aut);
        
    }
}