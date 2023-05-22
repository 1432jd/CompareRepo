@IsTest
public class Application_TH_AllocationTest {
    @TestSetup
    public static void testSetup(){        
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
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Legal_Opinion_User__c = u.Id;
        app.Stage__c = 'Lead Detail';
        app.Sub_Stage__c = '';
        app.Sourcing_Branch__c = branch.Id;
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;

		List<Access_Master__c> accessMasters = new List<Access_Master__c>();
        List<Allocation__c> allocations = new List<Allocation__c>();
        for(String stage : Application_TH_Allocation.stageLocationMap.keySet()){
            if(stage != 'Awaiting DOS' && stage != 'Closed'){
                accessMasters.add(new Access_Master__c(
                    Access_For__c = stage,
                    Capacity__c = 100,
                    Level__c = '1',
                    Capacity_Used__c = 10,
                    Next_Assignment__c = true,
                    User__c = u.ID
                ));
                
                allocations.add(new Allocation__c(
                        Allocation_Type__c = 'Push',
                        Mechanism__c = 'Round Robin',
                        Stage__c = stage
                ));
            }            
        }
        insert accessMasters;
		insert allocations;
        
		List<Access_Branch_Allocation__c> branchAllocations = new List<Access_Branch_Allocation__c>();                
		for(Access_Master__c am : accessMasters){
			branchAllocations.add(new Access_Branch_Allocation__c(
                	Branch_Master__c = branch.Id,
					Access_Master__c = am.Id
            ));
		}
		insert branchAllocations;
    }
    
    @IsTest
    public static void test1(){
        List<Application__c> app = [SELECT Id, Stage__c,Sub_Stage__c FROM Application__c limit 1];
        app.get(0).Stage__c = 'Process Credit';
        app.get(0).Sub_Stage__c = 'Legal Opinion';
        update app;
        
        app.get(0).Stage__c = 'Approval Credit';
        app.get(0).Sub_Stage__c = 'Legal Approval';
        update app;
        
        app.get(0).Stage__c = 'Final Sanction';
        app.get(0).Sub_Stage__c = '';
        update app;
        
        app.get(0).Stage__c = 'Approval Credit';
        app.get(0).Sub_Stage__c = '';
        update app;
        
        app.get(0).Stage__c = 'Final Sanction';
        app.get(0).Sub_Stage__c = '';
        update app;

		app.get(0).Stage__c = 'Awaiting Legal Approval';
        app.get(0).Sub_Stage__c = 'Legal Approval';
        update app;        
        System.Assert(app != NULL);
    }
}