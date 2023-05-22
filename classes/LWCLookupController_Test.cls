@IsTest
public class LWCLookupController_Test {
    @testSetup
    public static void testSetup(){
        
        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        branch.Branch_City__c ='ww';
        insert branch;
        
        Branch_Master__c branch1 = new Branch_Master__c();
        branch1.Name = 'Delhi';
        branch1.Branch_City__c ='aa';
        insert branch1;
        
        Application__c app = new Application__c();
        app.Sourcing_Branch__c = branch.Id;
        app.AC_Remarks__c = 'ww';
        app.Legal_Pending_Remarks__c ='wewe';
        insert app;
        
        Account accountObj = new Account(
            Name = 'Same Day Delivery',
            AccountNumber ='22',
            RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Courier Agency').getRecordTypeId());
        insert accountObj;
        
        Access_Master__c access_masterObj = new Access_Master__c();
        access_masterObj.Name = 'Disbursal Author';
        access_masterObj.Access_For__c = 'VDC Checker';
        access_masterObj.Capacity__c =50;
        access_masterObj.Capacity_Used__c =1;
        access_masterObj.Level__c = '1';
        access_masterObj.User__c = UserInfo.getUserId();
        access_masterObj.Sequence__c =2;
        insert access_masterObj;
        
        Access_Branch_Allocation__c abl = new Access_Branch_Allocation__c();
        abl.Branch_Master__c = branch.Id;
        abl.Access_Master__c = access_masterObj.Id;
        insert abl;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.dd@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US' ,
                           EmployeeNumber = '11' 
                           );
        			insert usr;
    }
    
    @IsTest
    public static void searchLookupRecordsTest(){
        Application__c app1 = [Select Id,AC_Remarks__c FROM Application__c WHERE AC_Remarks__c='ww'];
        Account agency = [SELECT Id FROM Account limit 1];
        Branch_Master__c branch = [SELECT Id,Name FROM Branch_Master__c WHERE Name='Noida'];
        Branch_Master__c branch1= [SELECT Id,Name,Branch_City__c FROM Branch_Master__c WHERE Branch_City__c='aa'];
        Access_Master__c acc = [SELECT Id,Name FROM Access_Master__c WHERE Name = 'Disbursal Author'];
        Test.startTest();
        LwcLookupController.getAllRecords('Branch_Master__c', 'Name', 'Branch_City__c', branch.Id);
        LwcLookupController.getAllRecords('Branch_Master__c', 'Name', 'Branch_City__c', null);
        LwcLookupController.getAllRecords('Branch_Master__c', 'Name', 'Branch_City__c', null);
        LwcLookupController.getFilterRecords('Branch_Master__c', 'Name', 'Branch_City__c', 'searchKey');
        Test.stopTest();
    } 
}