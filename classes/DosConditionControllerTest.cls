@IsTest
public class DosConditionControllerTest {
    @TestSetup
    public static void testSetup(){
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        branch.State__c = 'TN';
        insert branch;
        
        Branch_Master__c branch1 = new Branch_Master__c();
        branch1.Name = 'Noida';
        branch1.State__c = 'MP';
        insert branch1;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '89847343342';
        insert app;
        
        Application__c app1 = new Application__c();
        app1.Pre_Login__c = preLogin.Id;
        app1.Sourcing_Branch__c = branch1.Id;
        app1.Stage__c = 'Dispatch Pending';
        app1.application_status__c = 'Active';
        app1.LMS_Response_Reference__c = '8984734334';
        insert app1;
    }

    @IsTest
    public static void test(){
        Application__c app = [SELECT ID FROM Application__c limit 1];
        Application__c app1 = [SELECT ID FROM Application__c WHERE Sourcing_Branch__r.State__c = 'MP' limit 1];
        Test.startTest();
        DosConditionController.dosConditionData(app.Id);
        DosConditionController.dosConditionData(app1.Id);
        DosConditionController.checkDOSCondition(app.Id);
        DosConditionController.checkDOSCondition(app1.Id);
        Test.stopTest();
    }
}