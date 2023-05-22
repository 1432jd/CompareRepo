@IsTest
public class Verification_TH_AllocationHanderTest {
    @TestSetup
    public static void testData(){
                
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Branch_Master__c bm = new Branch_Master__c();
        bm.Branch_City__c = 'qq';
        bm.Name = 'branches';
    	insert bm;
        
        Access_Master__c am = new Access_Master__c();
        am.Capacity__c = 33.22;
        am.Access_For__c = 'FIV - B';
        am.Level__c = '2';
        insert am;
        
        Access_Branch_Allocation__c aba = new Access_Branch_Allocation__c();
        aba.Access_Master__c = am.Id;
        aba.Branch_Master__c = bm.Id;
        insert aba;

        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        app.Sourcing_Branch__c = bm.Id;
        insert app;
        
        Verification__c verifi1 = new Verification__c();
        verifi1.Application__c = app.Id;
        verifi1.Name__c = 'Test1';
        verifi1.Status__c = 'Pending';
        verifi1.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verifi1.Application__c = app.Id;
        verifi1.OwnerId = UserInfo.getUserId();
        verifi1.Initiate_From__c = 'Pre Login';
        insert verifi1;
        
        Verification__c verifi2 = new Verification__c();
        verifi2.Application__c = app.Id;
        verifi2.Name__c = 'Test';
        verifi2.Status__c = 'Pending';
        verifi2.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - B').getRecordTypeId();
        verifi2.Application__c = app.Id;
        verifi2.OwnerId = UserInfo.getUserId();
        verifi2.Initiate_From__c = 'Approval Credit';
        insert verifi2;
        
        Verification__c verifi3 = new Verification__c();
        verifi3.Application__c = app.Id;
        verifi3.Name__c = 'Test';
        verifi3.Status__c = 'Completed';
        verifi3.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('Online EC').getRecordTypeId();
        verifi3.Application__c = app.Id;
        verifi3.OwnerId = UserInfo.getUserId();
        verifi3.Initiate_From__c = 'Lead Details';
        insert verifi3;
        
    }
    @isTest
    public static void testCase(){
        List<Verification__c> verifi = new List<Verification__c>([SELECT Id, Status__c, Application__c, RecordTypeId, Initiate_From__c FROM Verification__c WHERE Status__c = 'Pending']);
        List<Verification__c> verifi1 = new List<Verification__c>([SELECT Id, Status__c, Application__c, RecordTypeId, Initiate_From__c,Name__c FROM Verification__c WHERE Name__c = 'Test1']);
        List<Verification__c> verifi2 = new List<Verification__c>([SELECT Id, Status__c, Application__c, RecordTypeId, Initiate_From__c FROM Verification__c WHERE Initiate_From__c = 'Lead Details']);
        Access_Master__c am = [SELECT Id,Level__c FROM Access_Master__c WHERE Level__c = '2'];
        Test.startTest();
        Verification_TH_AllocationHander.getVerificationUserAllocation(verifi);
        Verification_TH_AllocationHander.getVerificationUserAllocation(verifi1);
        Verification_TH_AllocationHander.getVerificationUserAllocation(verifi2);
        Verification_TH_AllocationHander vr = new Verification_TH_AllocationHander();
        vr.afterInsert(verifi,null);
        Test.stopTest();
    }
}