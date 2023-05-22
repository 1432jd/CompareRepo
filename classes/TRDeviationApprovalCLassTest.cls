@isTest
public class TRDeviationApprovalCLassTest {
    
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
        
        MS_Deviation__c msDevObj = new MS_Deviation__c(Deviation_Description__c='DBR above 50% upto 55% - OTHERS', Stage__c='Operations', Code__c = 'DEV_101');
        insert msDevObj;
        
        String userInfo = UserInfo.getUserId();
        User u3 = [SELECT Id, name,username FROM User WHERE Id =:userInfo];
        TR_Deviation__c trDevObj = new 	TR_Deviation__c();
        system.debug('User '+u3);
        system.runAs(u3){
            
            trDevObj = new TR_Deviation__c(MS_Deviation__c = msDevObj.ID,Approval_Level__c='L5', Approval_Authority__c=u3.Id, Application__c=appObj.ID, Decistion__c='Approval for Pending',is_Deviation_Active__c=true, Is_Deviation_Raised__c=true);
            insert trDevObj;
        }
        
    }
    
    @isTest
    public static void testDevApprovalMethod1(){
        Application__c application = [select id from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id,Approval_Level__c from TR_Deviation__c Limit 1];
        String userInfo = UserInfo.getUserId();
        User u3 = [SELECT Id, name,username FROM User WHERE Id =:userInfo];
        
        List<TRDeviationApprovalCLass.deviationApprovalWrapper> devList = TRDeviationApprovalCLass.getTRDeviationRecord(application.ID);
        //TRDeviationApprovalCLass.getLowestLevPendingTRDev(application.ID);
        
        
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L3","approvalStatus":"Approved","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw"}]';
        TRDeviationApprovalCLass.updateDecisions(devListJson);
        
        List<String> subList = new List<String>();
        subList.add('Ajay subject');
        Map<String, List<String>> userEmailMap = new Map<String, List<String>>();
        userEmailMap.put(u3.Id,subList);
    }
    @isTest
    public static void testDevApprovalMethod2(){
        Application__c application = [select id from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id from TR_Deviation__c Limit 1];
        String userInfo = UserInfo.getUserId();
        User u3 = [SELECT Id, name,username FROM User WHERE Id =:userInfo];
        
        List<TRDeviationApprovalCLass.deviationApprovalWrapper> devList = TRDeviationApprovalCLass.getTRDeviationRecord(application.ID);
      //  TRDeviationApprovalCLass.getLowestLevPendingTRDev(application.ID);
        
        
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L3","approvalStatus":"Rejected","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw"}]';
        TRDeviationApprovalCLass.updateDecisions(devListJson);
        
        List<String> subList = new List<String>();
        subList.add('Ajay subject');
        Map<String, List<String>> userEmailMap = new Map<String, List<String>>();
        userEmailMap.put(u3.Id,subList);
    }
}