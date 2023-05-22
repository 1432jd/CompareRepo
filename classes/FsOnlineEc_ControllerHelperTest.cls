@isTest
public class FsOnlineEc_ControllerHelperTest {
    
    @isTest
    public static void testMethod1(){
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        insert preLogin;
        
        FsOnlineEc_ControllerHelper.getEditPageContent('1231231','abc');
        FsOnlineEc_ControllerHelper.saveRecord(preLogin);
        
    }
}