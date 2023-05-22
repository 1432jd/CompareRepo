@isTest
public class TRDeviationApprovalCLassTest {
    
    @TestSetup
    static void createTestData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='prod@testUser.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='prod@testUser.com');
        insert u;
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        insert preLogin;
        
        Branch_Master__c branch_masterObj = new Branch_Master__c(
            Name = 'Jaipur',
            State__c = 'RJ',
            Branch_State__c = 'Rajasthan',
            Type__c = 'HO');
        insert branch_masterObj;
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',Sourcing_Branch__c=branch_masterObj.ID,
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,Is_Deviation_Raised__c=true,
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
        
        
        Access_Master__c accessMaster = new Access_Master__c(Access_For__c = 'Deviation Approval', Name = 'Deviation', Capacity__c = 50, Capacity_Used__c = 20,
                                                             Level__c = '5', User__c = u.Id);
        insert accessMaster;
        
        Access_Branch_Allocation__c access_branch_allocationObj = new Access_Branch_Allocation__c(
            Access_Master__c = accessMaster.Id,
            Branch_Master__c = appObj.Sourcing_Branch__c);
        insert access_branch_allocationObj;
        
        MS_Deviation__c msDeviation1 = new MS_Deviation__c();
        
        msDeviation1.Code__c = 'DEV_102';
        msDeviation1.Deviation_Level__c = 'Applicant';
        msDeviation1.Deviation_Type__c = 'Manual'; 
        msDeviation1.Approval_Authority__c = 'L5';
        msDeviation1.Stage__c = 'Credit'; //Operations
        msDeviation1.Is_Active__c = 'Yes';
        msDeviation1.Deviation_Description__c = 'Applicant age less than 18 years';
        insert msDeviation1;
    }
    
    @isTest
    public static void testDevApprovalMethod1(){
        Application__c application = [select id,Stage__c,Is_Deviation_Raised__c from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id,Approval_Level__c from TR_Deviation__c Limit 1];
        User u3 = [SELECT Id, name,username FROM User WHERE Email='prod@testUser.com'];
        Access_Master__c am = [Select id from Access_Master__c Limit 1];
        Branch_Master__c bm = [Select id from Branch_Master__c Limit 1];
        Access_Branch_Allocation__c aba = [Select id, Access_Master__c,Branch_Master__c from Access_Branch_Allocation__c Limit 1];
        System.runAs(u3){
            List<TRDeviationApprovalCLass.deviationApprovalWrapper> devList = TRDeviationApprovalCLass.getTRDeviationRecord(application.ID,application.Stage__c);
            
        }
        trDevObj.Approval_Level__c = 'L6';
        trDevObj.Is_Deviation_Raised__c = false;
        trDevObj.Is_Send_Email__c = false;
        update trDevObj;
        
        application.Is_Deviation_Raised__c = false;
        application.Current_Deviation_Approval__c = null;
        update application;
        TRDeviationApprovalCLass.getLowestLevPendingTRDev(application.ID,'Approval for Pending');
        
        trDevObj.Approval_Level__c = 'L6';
        trDevObj.Is_Deviation_Raised__c = true;
        trDevObj.Is_Send_Email__c = true;
        update trDevObj;
        
        application.Is_Deviation_Raised__c = true;
        application.Current_Deviation_Approval__c = u3.ID;
        update application;
        TRDeviationApprovalCLass.getLowestLevPendingTRDev(application.ID,'Approval for Pending');
        
        trDevObj.Approval_Level__c = 'L5';
        update trDevObj;
        TRDeviationApprovalCLass.getLowestLevPendingTRDev(application.ID,'Approval for Pending');
        
        TRDeviationApprovalCLass.getLowestLevPendingTRDev(application.ID,'Not Approved');
        
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L3","approvalStatus":"Approved","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw","isSendEmail":false}]';
        System.runAs(u3){
            TRDeviationApprovalCLass.updateDecisions(devListJson);
        }        
        List<String> subList = new List<String>();
        subList.add('Ajay subject');
        Map<String, List<String>> userEmailMap = new Map<String, List<String>>();
        userEmailMap.put(u3.Id,subList);
    }
    @isTest
    public static void testDevApprovalMethod2(){
        Application__c application = [select id,Stage__c from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id from TR_Deviation__c Limit 1];
        User u3 = [SELECT Id, name,username FROM User WHERE Email='prod@testUser.com'];
        
        List<TRDeviationApprovalCLass.deviationApprovalWrapper> devList = TRDeviationApprovalCLass.getTRDeviationRecord(application.ID,application.Stage__c);
        //  TRDeviationApprovalCLass.getLowestLevPendingTRDev(application.ID);
        
        
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L5","approvalStatus":"Rejected","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw","isSendEmail":false}]';
        System.runAs(u3){
            TRDeviationApprovalCLass.updateDecisions(devListJson);        
        }
        List<String> subList = new List<String>();
        subList.add('Ajay subject');
        Map<String, List<String>> userEmailMap = new Map<String, List<String>>();
        userEmailMap.put(u3.Id,subList);
    }
    @isTest
    public static void testDevApprovalMethod3(){
        User u3 = [SELECT Id, name,username FROM User WHERE Email='prod@testUser.com'];
        Application__c application = [select id,Stage__c from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id from TR_Deviation__c Limit 1];
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L5","approvalStatus":"Approved","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw","isSendEmail":false}]';
        System.runAs(u3){
            TRDeviationApprovalCLass.updateDecisions(devListJson);        
        }
    }
    @isTest
    public static void testDevApprovalMethod4(){
        User u3 = [SELECT Id, name,username FROM User WHERE Email='prod@testUser.com'];
        Application__c application = [select id,Stage__c from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id from TR_Deviation__c Limit 1];
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L6","approvalStatus":"Send Email","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw","isSendEmail":false}]';
        System.runAs(u3){
            TRDeviationApprovalCLass.updateDecisions(devListJson);        
        }
    }
        @isTest
    public static void testDevApprovalMethod5(){
        User u3 = [SELECT Id, name,username FROM User WHERE Email='prod@testUser.com'];
        Application__c application = [select id,Stage__c from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id from TR_Deviation__c Limit 1];
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L6","approvalStatus":"Rejected","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw","isSendEmail":false}]';
        System.runAs(u3){
            TRDeviationApprovalCLass.updateDecisions(devListJson);        
        }
    }
     @isTest
    public static void testDevApprovalMethod6(){
        User u3 = [SELECT Id, name,username FROM User WHERE Email='prod@testUser.com'];
        Application__c application = [select id,Stage__c from Application__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id from TR_Deviation__c Limit 1];
        String devListJson = '[{"applicableFor":"Application","approvalLevel":"L3","approvalStatus":"Rejected","ConditionallyDecisionWrapList":[{"label":"Approved","value":"Approved"},{"label":"Rejected","value":"Rejected"}],"currentApprovalLevelList":[{"label":"L4","value":"L4"}],"decision":"Approval for Pending","decisionType":"Manual","deviationDescription":"Exposure upto 8L - OTHERS","devId":"'+trDevObj.Id+'","isChanged":true,"isDisabled":false,"msDeviationName":"DEV-00038","nextapprovallevel":"L4","nextapprovalUser":"'+u3.Id +'","srNo":1,"applicationId":"'+application.ID+'","remarks":"asd","mitigants":"adw","isSendEmail":false}]';
        System.runAs(u3){
            TRDeviationApprovalCLass.updateDecisions(devListJson);        
        }
    }
}