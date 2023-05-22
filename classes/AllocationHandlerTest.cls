@IsTest
public class AllocationHandlerTest {
    @TestSetup
    public static void testSetup(){
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.Id;
        app.Stage__c = 'Dispatch Pending';
        insert app;
        
        Allocation__c allocation = new Allocation__c();
        allocation.Allocation_Type__c = 'Push';
        allocation.Stage__c = 'Dispatch Pending';
        insert allocation;
        
        Branch_Master__c bm = new Branch_Master__c();
        bm.Name = 'test';
        insert bm;
    }

    @IsTest
    public static void getApplicationUserAllocationTest(){
        List<Application__c> records = [SELECT Id, Stage__c, Sourcing_Branch__c FROM Application__c];
        Branch_Master__c bm = [Select Id from Branch_Master__c Limit 1];
        
        Test.startTest();
        AllocationHandler.getApplicationUserAllocation(records, 'Stage__c');
        AllocationHandler.getUserList('FIV - B', bm.Id);
        Test.stopTest();
    }
}