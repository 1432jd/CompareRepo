@IsTest
public class Verification_TH_CapacityTrackingTest {
    @TestSetup
    public static void testSetup(){
        
        Branch_Master__c branch_masterObj = new Branch_Master__c(
            Name = 'Jaipur',
            State__c = 'RJ',
            Branch_State__c = 'Rajasthan',
            Type__c = 'HO');
        insert branch_masterObj;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        app.Sourcing_Branch__c = branch_masterObj.Id;
        insert app;
        
        Verification__c verifi = new Verification__c();
        verifi.Name__c = 'Test';
        verifi.Status__c = 'Pending';
        verifi.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - B').getRecordTypeId();
        verifi.Application__c = app.Id;
        insert verifi;

        Access_Master__c access_masterObj = new Access_Master__c(
            Name = 'Test',
            Access_For__c = 'FIV - B',
            Capacity__c = 100,
            Level__c = '1',
            Sequence__c = 1,
            //User__c = UserInfo.getUserId(),
            Next_Assignment__c = true);
        insert access_masterObj;

        Access_Branch_Allocation__c access_branch_allocationObj = new Access_Branch_Allocation__c(
            Access_Master__c = access_masterObj.Id,
            Branch_Master__c = branch_masterObj.Id);
        insert access_branch_allocationObj;

    }

    @IsTest
    public static void updateCapacityOnCompleteTest(){
        
        Verification__c verifi = [SELECT Id, Status__c FROM Verification__c limit 1];
        verifi.Status__c = 'Completed';
        Test.startTest();
        update verifi;
        Test.stopTest();
    }
}