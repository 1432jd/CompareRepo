@IsTest
public class LWCLookupCtrlTest {
    @testSetup
    public static void testSetup(){
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;
        
        Application__c app = new Application__c();
        app.Sourcing_Branch__c = branch.Id;
        insert app;
        
        Account accountObj = new Account(
	    Name = 'Same Day Delivery',
	    RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Courier Agency').getRecordTypeId());
        insert accountObj;
        
        List<Access_Master__c> accessMasterList = new List<Access_Master__c>();
        Access_Master__c access_masterObj = new Access_Master__c();
        access_masterObj.Name = 'Disbursal Author';
       	access_masterObj.Access_For__c = 'VDC Checker';
       	access_masterObj.Capacity__c =50;
        access_masterObj.Capacity_Used__c =1;
        access_masterObj.Level__c = '1';
        access_masterObj.User__c = UserInfo.getUserId();
        access_masterObj.Sequence__c =2;
        insert access_masterObj;
           /* (
            Name = 'Disbursal Author',
            Access_For__c = 'Disbursal Author',
            Capacity_Used__c = 1,
            Capacity__c = 50,
            Level__c = '1',
            Sequence__c = 2,
            User__c = UserInfo.getUserId());
        	Access_For__c = 'VDC Checker';
         insert access_masterObj;*/
        
        Access_Branch_Allocation__c abl = new Access_Branch_Allocation__c();
        abl.Branch_Master__c = branch.Id;
        abl.Access_Master__c = access_masterObj.Id;
        insert abl;
    }

    @IsTest
    public static void searchLookupRecordsTest(){
        Application__c app = [Select Id FROM Application__c LIMIT 1];
        Test.startTest();
        List<String> selectedIds = new List<String>();
        LWCLookupCtrl.searchLookupRecords('Same Day Delivery', selectedIds, 'Account', 'Name', '', 5, 'Account-CourierAgency', app.Id);
        LWCLookupCtrl.searchLookupRecords('Same Day Delivery', selectedIds, 'Account', 'Name', '', 5, 'Account-Broker', '');
        LWCLookupCtrl.searchLookupRecords('Same Day Delivery', selectedIds, 'Account', 'Name', '', 5, 'NAME_EMP', '');
        LWCLookupCtrl.searchLookupRecords('Same Day Delivery', selectedIds, 'Account', 'Name', '', 5, 'NAME_DM', '');
        LWCLookupCtrl.searchLookupRecords('Same Day Delivery', selectedIds, 'Account', 'Name', '', 5, 'NAME_DC', '');
        LWCLookupCtrl.searchLookupRecords('Same Day Delivery', selectedIds, 'Account', 'Name', '', 5, 'DocMaker', '');
        LWCLookupCtrl.searchLookupRecords('Same Day Delivery', selectedIds, 'Account', 'Name', '', 5, 'FIVC-User', '');
        Test.stopTest();
    }
    
    @isTest
    public static void getSelectedRecordTest(){
        Account agency = [SELECT Id FROM Account limit 1];
        Test.startTest();
        LWCLookupCtrl.getSelectedRecord('Account', 'Name', '', 5, agency.Id);
        LWCLookupCtrl.getRecentlyCreatedRecord('Account', agency.Id, 'Name', '');
        Test.stopTest();
    }
}