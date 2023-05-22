@isTest
public class UtilityTest {
    @TestSetup
    public static void testSetup(){
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Stage__c = 'Dispatch Pending';
        app.application_status__c = 'Active';
        app.LMS_Response_Reference__c = '8984734334';
        insert app;
        
        Group grp = new Group();
        grp.Name = 'Test';
        grp.Type = 'Queue';
        grp.DeveloperName = 'Reject_Case_Queue';
        insert grp;
    }
    
    @IsTest
    public static void createTaskTest(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        insert u;
        Test.startTest();
        Utility.createTask('Subject', null, null, u.Id, System.today(), '', true);
        Test.stopTest();
    }
    
    @isTest
    public static void sendNotificationTest(){
        Utility.sendNotification('Test', 'Test', '7397393','TestName', '7371281021');
    }
    
    @isTest
    public static void deleteRecordTest(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        Utility.deleteRecord(app.Id);
        //Utility.deleteRecord('');
        Test.stopTest();
    }
    
    @isTest
    public static void createErrorLoggerTest(){
        Test.startTest();
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(Exception e){
            Utility.createErrorLogger(e, 'Test');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void createErrorLoggerApplicationWiseTest(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(Exception e){
            Utility.createErrorLoggerApplicationWise(e, 'Test', app.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testQueue(){
        Test.startTest();
        Utility.getUnAssignedQueueId();
        Utility.getRejectQueueId();
        Test.stopTest();
    }
    
    @isTest
    public static void doCloneTest(){
        Pre_Login__c app = [SELECT Id FROM Pre_Login__c limit 1];
        Set<String> applicationId = new Set<String>{app.Id};
        Test.startTest();
        Utility.doClone(applicationId, 'Pre_Login__c', true);
        Test.stopTest();
    }
    
    @isTest
    public static void createSendBackHistoryTest(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        Utility.createSendBackHistory(app.Id, 'Test', 'Test');
        Test.stopTest();
    }
    
    @isTest
    public static void createTask(){
        Test.startTest();
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Utility.createTask('Test', app.Id, app.Id, UserInfo.getUserId(), System.today(), 'Test', false);
        Utility.getFieldAPINames('Application__c');
        Test.stopTest();
    }
}