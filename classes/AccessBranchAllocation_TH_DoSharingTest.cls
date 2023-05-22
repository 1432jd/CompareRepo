@isTest
public with sharing class AccessBranchAllocation_TH_DoSharingTest {
    
    @TestSetup
    public static void testSetup(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;
        
        Access_Master__c accessMaster = new Access_Master__c();
        accessMaster.Access_For__c = 'Login';
        accessMaster.Capacity__c = 100;
        accessMaster.Level__c = '1';
        accessMaster.Capacity_Used__c = 10;
        accessMaster.Next_Assignment__c = true;
        accessMaster.User__c = u.ID;
        insert accessMaster;
        
        Access_Branch_Allocation__c accessBranch = new Access_Branch_Allocation__c();
        accessBranch.Branch_Master__c = branch.Id;
        accessBranch.Access_Master__c = accessMaster.Id;
        insert accessBranch;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.Id;
        app.Stage__c = 'Dispatch Pending';
        insert app;
               
    }
    
    @isTest
    public static void testMethod1() {
        Application__c applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        Access_Branch_Allocation__c accBranhcAll = [Select Id,Access_Master__c,Branch_Master__c from Access_Branch_Allocation__c Limit 1];
        Map<Id,Access_Branch_Allocation__c> oldMap = new Map<Id,Access_Branch_Allocation__c>();
        oldMap.put(accBranhcAll.ID,accBranhcAll);
        Boolean isUpdate = true;
        Access_Master__c accessMaster = [ Select ID from Access_Master__c Limit 1];
        Branch_Master__c branch2 = new Branch_Master__c();
        branch2.Name = 'Chennai';
        insert branch2;
        List<String> branches = new List<String>{'Noida','Chennai'};
            List<String> accesses = new List<String>();
        accesses.add(accessMaster.ID);
        List<Access_Branch_Allocation__c> newList = [Select Id,Branch_Master__c,Access_Master__c from Access_Branch_Allocation__c Limit 1];
        Application__Share sharing = [SELECT Id, UserOrGroupId, ParentId FROM Application__Share where ParentId =: applicationRecord.Id Limit 1];
        
        for(Access_Branch_Allocation__c accbl : newList){
            accbl.Branch_Master__c = branch2.ID;
        }
        update newList;
        AccessBranchAllocation_TH_DoSharing.assignApplications(newList,oldMap,isUpdate);
        AccessBranchAllocation_TH_DoSharing.manageOldPermissions(newList);
        AccessBranchAllocation_TH_DoSharing.deletePermissions(newList,branches,accesses);
    }
}