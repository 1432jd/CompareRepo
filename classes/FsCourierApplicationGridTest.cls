@IsTest
public class FsCourierApplicationGridTest {
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
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Dispatch Pending';
        insert app;


        Courier_Control__c courierCnt = new Courier_Control__c();
        courierCnt.Address__c = 'Test';
        courierCnt.Branch_Name__c = branch.Name;
        courierCnt.Branch__c = branch.Id;
        courierCnt.Courier_POD_No__c = '8343HMU73H';
        courierCnt.From_Date__c = System.today();
        courierCnt.To_Date__c = System.today();
        insert courierCnt;


        Courier_Application__c courApp = new Courier_Application__c();
        courApp.Courier_Control__c = courierCnt.Id;
        courApp.Application__c = app.Id;
        courApp.Status__c = 'Received';
        insert courApp;
    }

    @IsTest
    public static void test(){
        Courier_Control__c courierControl = [SELECT Id FROM Courier_Control__c limit 1];
        List<Courier_Application__c> courApp = [SELECT Id, Courier_Control__c, Application__c, Status__c FROM Courier_Application__c];
        Test.startTest();
        FsCourierApplicationGrid.getCourierApplications(courierControl.Id);
        FsCourierApplicationGrid.getStatusValues();
        FsCourierApplicationGrid.updatedCourierApplications(JSON.serialize(courApp));
        FsCourierApplicationGrid.getIconName('Courier_Application__c');
        FsCourierApplicationGrid.getIconName('Account');
        Test.stopTest();
    }
}