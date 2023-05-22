@IsTest
public class AllocationHandlerHelperTest {
    @TestSetup
    public static void testSetup(){
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;

        Access_Master__c accessMaster = new Access_Master__c();
        accessMaster.Access_For__c = 'Login';
        accessMaster.Capacity__c = 100;
        accessMaster.Level__c = '1';
        accessMaster.Capacity_Used__c = 10;
        accessMaster.Next_Assignment__c = true;
        insert accessMaster;
        
        Access_Branch_Allocation__c accessBranch = new Access_Branch_Allocation__c();
        accessBranch.Branch_Master__c = branch.Id;
        accessBranch.Access_Master__c = accessMaster.Id;
        insert accessBranch;
    }

    @IsTest
    public static void getUsersNewTest(){
        Branch_Master__c branch = [SELECT Id, Name FROM Branch_Master__c limit 1];
        Map<String,String> branches = new Map<String, String>();
        branches.put(branch.Id, branch.Name);

        Map<String,String> stages = new Map<String, String>();
        stages.put(branch.Id, 'Login');

        Test.startTest();
        AllocationHandlerHelper.getUsersNew(branches, stages, 'Capacity');
        AllocationHandlerHelper.getUsersNew(branches, stages, 'Round Robin');
        Test.stopTest();
        
    }
}