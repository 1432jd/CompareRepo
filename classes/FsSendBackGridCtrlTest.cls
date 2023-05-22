@isTest
public class FsSendBackGridCtrlTest {
    @testSetup
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
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Verification';
        insert app;

        Note noteObj = new Note(
            Title = 'FIV_C - Approval Credit',
            Body = 'Test',
            ParentId = app.Id);
        insert noteObj;
    }
    
    @isTest
    public static void getNotesTest(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        fsSendBackGridCtrl.getNotes(app.Id);
        fsSendBackGridCtrl.updateStage(app.Id, 'In Principle Sanction');
        fsSendBackGridCtrl.updateStageSubStage(app.Id, 'In Principle Sanction', 'Legal Opinion');
        Test.stopTest();
    }
}