@isTest
public class DecisionedDeviationsControllerTest {
    
    @TestSetup
    static void createTestData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        insert preLogin;
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd');
        insert appObj;
        
        MS_Deviation__c msDevObj = new MS_Deviation__c(Deviation_Description__c='DBR above 50% upto 55% - OTHERS', Stage__c='Credit',Code__c='123');
        insert msDevObj;
        
        String userInfo = UserInfo.getUserId();
        User u3 = [SELECT Id, name,username FROM User WHERE Id =:userInfo];
        TR_Deviation__c trDevObj = new 	TR_Deviation__c();
        system.debug('User '+u3);
        system.runAs(u3){
            
            trDevObj = new TR_Deviation__c(Applicable_for__c='Asset',MS_Deviation__c = msDevObj.ID,Approval_Level__c='L5', Approval_Authority__c=u3.Id, Application__c=appObj.ID, Decistion__c='Approved',is_Deviation_Active__c=true, Is_Deviation_Raised__c=true);
            insert trDevObj;
        }
    }
    
    @isTest
    public static void testDevApprovalMethod1(){
        Application__c application = [select id from Application__c Limit 1];
        
        DecisionedDeviationsController.getDecisionedRecords(application.Id,'Process Credit');
    }
    
}