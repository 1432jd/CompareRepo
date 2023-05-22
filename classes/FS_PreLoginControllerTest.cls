@isTest
public class FS_PreLoginControllerTest {
	@isTest
    public static void testPreLoginController(){
        Branch_Master__c bm =new Branch_Master__c();
		bm.Name = 'Rajasthan';
		bm.State__c = 'RJ';
		insert bm;
        
        Pre_Login__c login = new Pre_Login__c();
        login.RecordTypeId = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        login.Status__c = 'Active';
        insert login;
        
        Application__c app = new Application__C();
        app.Sourcing_Branch__c = bm.Id;
        app.Pre_Login__c = login.Id;
        app.Stage__c='Login';
        app.Requested_Loan_Amount__c = 100000;
        insert app;
        
        FS_PreLoginController clsObj = new FS_PreLoginController();
        FS_PreLoginController.ApplicationWrapper wrap = FS_PreLoginController.getApplicationId(login.Id);
        System.Assert(wrap != NULL);
    }
}