/**
* @Class Name         : PcDeviationContollerTest.apxc
* @Description        : Test Class for pcDeviationController 

* @Author             : Sangeeta Yadav
* @Created On         : 21/09/2022
*========================================================================================
* Ver         Date                     Author                       Modification
*========================================================================================
* 1.0        21/09/2022               Sangeeta Yadav                Initial Version
**/
@isTest
public class PcDeviationContollerTest {
    
    @TestSetup
    static void createTestData() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='test@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserdeviationtest@testorg.com');
        insert u;
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        List<Access_Master__c> accessMasterList = new List<Access_Master__c>();
        Access_Master__c accessMaster = new Access_Master__c(Access_For__c = 'Deviation Approval', Name = 'Deviation', Capacity__c = 50, Capacity_Used__c = 20,
                                                            Level__c = '1', User__c = u.Id);
        accessMasterList.add(accessMaster);
        Access_Master__c accessMaster1 = new Access_Master__c(Access_For__c = 'Deviation Approval', Name = 'Deviation', Capacity__c = 50, Capacity_Used__c = 20,
                                                            Level__c = '2', User__c = u.Id);
        accessMasterList.add(accessMaster1);
        
        Access_Master__c accessMaster2 = new Access_Master__c(Access_For__c = 'Deviation Approval', Name = 'Deviation', Capacity__c = 50, Capacity_Used__c = 20,
                                                            Level__c = '3', User__c = u.Id);
        accessMasterList.add(accessMaster2);
        
        Access_Master__c accessMaster3 = new Access_Master__c(Access_For__c = 'Deviation Approval', Name = 'Deviation', Capacity__c = 50, Capacity_Used__c = 20,
                                                            Level__c = '4', User__c = u.Id);
        accessMasterList.add(accessMaster3);
        
        Access_Master__c accessMaster4 = new Access_Master__c(Access_For__c = 'Deviation Approval', Name = 'Deviation', Capacity__c = 50, Capacity_Used__c = 20,
                                                            Level__c = '5', User__c = u.Id);
        accessMasterList.add(accessMaster4);
        
        Access_Master__c accessMaster5 = new Access_Master__c(Access_For__c = 'Deviation Approval', Name = 'Deviation', Capacity__c = 50, Capacity_Used__c = 20,
                                                            Level__c = '5', User__c = u.Id);
        accessMasterList.add(accessMaster5);

        
        insert accessMasterList;
               
        Branch_Master__c branch = new Branch_Master__c(Name = 'Delhi');
        insert branch;
        
        List<Access_Branch_Allocation__c> accessBranchList = new List<Access_Branch_Allocation__c>();
        
        Access_Branch_Allocation__c accessBranch = new Access_Branch_Allocation__c(Access_Master__c = accessMaster.Id, Branch_Master__c = branch.Id);
        accessBranchList.add(accessBranch);
        
        Access_Branch_Allocation__c accessBranch1 = new Access_Branch_Allocation__c(Access_Master__c = accessMaster1.Id, Branch_Master__c = branch.Id);
        accessBranchList.add(accessBranch1);
        
        Access_Branch_Allocation__c accessBranch2 = new Access_Branch_Allocation__c(Access_Master__c = accessMaster2.Id, Branch_Master__c = branch.Id);
        accessBranchList.add(accessBranch2);
        
        Access_Branch_Allocation__c accessBranch3 = new Access_Branch_Allocation__c(Access_Master__c = accessMaster3.Id, Branch_Master__c = branch.Id);
        accessBranchList.add(accessBranch3);
        
        Access_Branch_Allocation__c accessBranch4 = new Access_Branch_Allocation__c(Access_Master__c = accessMaster4.Id, Branch_Master__c = branch.Id);
        accessBranchList.add(accessBranch4);
        
        Access_Branch_Allocation__c accessBranch5 = new Access_Branch_Allocation__c(Access_Master__c = accessMaster5.Id, Branch_Master__c = branch.Id);
        accessBranchList.add(accessBranch5);
        
        insert accessBranchList;
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLogin.Id;
        app.Loan_Amount__c = 100000;
        app.Requested_Loan_Amount__c = 100000;
        app.Stage__c = 'Process Credit';//Approval Credit
        app.Sourcing_Branch__c = branch.Id;
        //app.Group_Total_Exposure_PcAc__c = 5000000;
        insert app;
        
        //Application for if fee already exist 
        Application__c app1 = new Application__c();
        app1.Pre_Login__c = preLogin.Id;
        app1.Loan_Amount__c = 100000;
        app.Stage__c = 'Disbursal Maker';//Disbursal Author
        insert app1;
        
        
        Account acc = new Account();
        //acc.Pre_Login__c = preLogin.Id;
        acc.LastName = 'test';
        acc.PersonBirthdate = Date.newInstance(2009,7,7);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Property__c pro = new Property__c();
        pro.Application__c = app.Id;
        pro.Login__c = preLogin.Id;
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.Application__c = app.Id;
        pro1.Login__c = preLogin.Id;
        insert pro1;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        
        insert loanApp;
        Verification__c objVerification = new Verification__c();
        //objVerification.Name = 'FIV-B';
        objVerification.Application__c = app.Id;
        insert objVerification;    
       // SELECT ID, Application__c, Application__r.Is_Deviation_Raised__c, Application__r.Is_Deviation_Approval_User__c 
            				
        List<MS_Deviation__c> listMsDeviation = new List<MS_Deviation__c>();
        MS_Deviation__c msDeviation = new MS_Deviation__c();
        
        msDeviation.Code__c = 'DEV_101';
        msDeviation.Deviation_Level__c = 'Applicant';
        msDeviation.Deviation_Type__c = 'System'; //Manual
        msDeviation.Approval_Authority__c = 'L5';
        msDeviation.Stage__c = 'Credit'; //Operations
        msDeviation.Is_Active__c = 'Yes';
        msDeviation.Deviation_Description__c = 'Applicant age less than 18 years';
        listMsDeviation.add(msDeviation);
        
        MS_Deviation__c msDeviation1 = new MS_Deviation__c();
        
        msDeviation1.Code__c = 'DEV_102';
        msDeviation1.Deviation_Level__c = 'Applicant';
        msDeviation1.Deviation_Type__c = 'Manual'; 
        msDeviation1.Approval_Authority__c = 'L5';
        msDeviation1.Stage__c = 'Credit'; //Operations
        msDeviation1.Is_Active__c = 'Yes';
        msDeviation1.Deviation_Description__c = 'Applicant age less than 18 years';
        listMsDeviation.add(msDeviation1);
        
        MS_Deviation__c msDeviation2 = new MS_Deviation__c();
        
        msDeviation2.Code__c = 'DEV_103';
        msDeviation2.Deviation_Level__c = 'Applicant';
        msDeviation2.Deviation_Type__c = 'Manual'; //Manual
        msDeviation2.Approval_Authority__c = 'L5';
        msDeviation2.Stage__c = 'Operations'; 
        msDeviation2.Is_Active__c = 'Yes';
        msDeviation2.Deviation_Description__c = 'Applicant age less than 18 years';
        listMsDeviation.add(msDeviation2);
        
        MS_Deviation__c msDeviation3 = new MS_Deviation__c();
        
        msDeviation3.Code__c = 'DEV_104';
        msDeviation3.Deviation_Level__c = 'Asset';
        msDeviation3.Deviation_Type__c = 'System'; 
        msDeviation3.Approval_Authority__c = 'L7';
        msDeviation3.Stage__c = 'Credit'; 
        msDeviation3.Is_Active__c = 'Yes';
        msDeviation3.Deviation_Description__c = 'Vacant Land';
        listMsDeviation.add(msDeviation3);
        
        MS_Deviation__c msDeviation4 = new MS_Deviation__c();
        
        msDeviation4.Code__c = 'DEV_105';
        msDeviation4.Deviation_Level__c = 'Application';
        msDeviation4.Deviation_Type__c = 'System'; 
        msDeviation4.Approval_Authority__c = 'L6';
        msDeviation4.Stage__c = 'Credit'; 
        msDeviation4.Is_Active__c = 'Yes';
        msDeviation4.Deviation_Description__c = 'Exposure above 50L for Credit Committee level 6 approval';
        listMsDeviation.add(msDeviation4);
        
        insert listMsDeviation;
        
        List<Tr_Deviation__c> listTrDeviation = new List<Tr_Deviation__c>();
        Tr_Deviation__c trDeviation = new Tr_Deviation__c();
        trDeviation.Applicable_for__c = 'Application';
        trDeviation.Application__c = app.Id;
        trDeviation.Approval_Level__c = 'L1';
        trDeviation.Decistion__c = 'Approval for Pending';
        trDeviation.Deviation_Code__c = 'DEV_105';
        trDeviation.Deviation_Description__c = 'Exposure above 50L for Credit Committee level 6 approval';
        trDeviation.Deviation_Type__c = 'System';
        trDeviation.Is_Deviation_Active__c = true;
        trDeviation.Is_Deviation_Raised__c = false;
        trDeviation.Is_Send_Email__c = false;
        trDeviation.Loan_Applicant__c = null;
        trDeviation.Property__c = null;
        trDeviation.MS_Deviation__c = msDeviation4.Id;
        trDeviation.Approval_Authority__c = u.Id;
        listTrDeviation.add(trDeviation);
        
        Tr_Deviation__c trDeviation1 = new Tr_Deviation__c();
        trDeviation1.Applicable_for__c = 'Applicant';
        trDeviation1.Application__c = app.Id;
        trDeviation1.Approval_Level__c = 'L6';
        trDeviation1.Decistion__c = 'Approval for Pending';
        trDeviation1.Deviation_Code__c = 'DEV_101';
        trDeviation1.Deviation_Description__c = 'Applicant age less than 18 years';
        trDeviation1.Deviation_Type__c = 'System';
        trDeviation1.Is_Deviation_Active__c = true;
        trDeviation1.Is_Deviation_Raised__c = false;
        trDeviation1.Is_Send_Email__c = false;
        trDeviation1.Loan_Applicant__c = loanApp.Id;
        trDeviation1.Property__c = null;
        trDeviation1.MS_Deviation__c = msDeviation.Id;
        trDeviation1.Approval_Authority__c = u.Id;
        listTrDeviation.add(trDeviation1);
        
        Tr_Deviation__c trDeviation2 = new Tr_Deviation__c();
        trDeviation2.Applicable_for__c = 'Applicant';
        trDeviation2.Application__c = app.Id;
        trDeviation2.Approval_Level__c = 'L6';
        trDeviation2.Decistion__c = 'Approval for Pending';
        trDeviation2.Deviation_Code__c = 'DEV_102';
        trDeviation2.Deviation_Description__c = 'Applicant age less than 18 years';
        trDeviation2.Deviation_Type__c = 'Manual';
        trDeviation2.Is_Deviation_Active__c = true;
        trDeviation2.Is_Deviation_Raised__c = false;
        trDeviation2.Is_Send_Email__c = false;
        trDeviation2.Loan_Applicant__c = null;
        trDeviation2.Property__c = null;
        trDeviation2.MS_Deviation__c = msDeviation1.Id;
        trDeviation2.Approval_Authority__c = u.Id;
        listTrDeviation.add(trDeviation2);
        
        Tr_Deviation__c trDeviation3 = new Tr_Deviation__c();
        trDeviation3.Applicable_for__c = 'Asset';
        trDeviation3.Application__c = app.Id;
        trDeviation3.Approval_Level__c = 'L6';
        trDeviation3.Decistion__c = 'Approval for Pending';
        trDeviation3.Deviation_Code__c = 'DEV_104';
        trDeviation3.Deviation_Description__c = 'Vacant Land';
        trDeviation3.Deviation_Type__c = 'System';
        trDeviation3.Is_Deviation_Active__c = true;
        trDeviation3.Is_Deviation_Raised__c = false;
        trDeviation3.Is_Send_Email__c = false;
        trDeviation3.Loan_Applicant__c = null;
        trDeviation3.Property__c = null;
        trDeviation3.MS_Deviation__c = msDeviation3.Id;
        trDeviation3.Approval_Authority__c = u.Id;
        listTrDeviation.add(trDeviation3);
        
        Tr_Deviation__c trDeviation4 = new Tr_Deviation__c();
        trDeviation4.Applicable_for__c = 'Asset';
        trDeviation4.Application__c = app.Id;
        trDeviation4.Approval_Level__c = 'L6';
        trDeviation4.Decistion__c = 'Approval for Pending';
        trDeviation4.Deviation_Code__c = 'DEV_104';
        trDeviation4.Deviation_Description__c = 'Vacant Land';
        trDeviation4.Deviation_Type__c = 'System';
        trDeviation4.Is_Deviation_Active__c = true;
        trDeviation4.Is_Deviation_Raised__c = false;
        trDeviation4.Is_Send_Email__c = false;
        trDeviation4.Loan_Applicant__c = null;
        trDeviation4.Property__c = pro.Id;
        trDeviation4.MS_Deviation__c = msDeviation3.Id;
        //trDeviation4.Approval_Authority__c = u.Id;
        listTrDeviation.add(trDeviation4);
        
        Tr_Deviation__c trDeviation5 = new Tr_Deviation__c();
        trDeviation5.Applicable_for__c = 'Applicant';
        trDeviation5.Application__c = app1.Id;
        trDeviation5.Approval_Level__c = 'L6';
        trDeviation5.Decistion__c = 'Approval for Pending';
        trDeviation5.Deviation_Code__c = 'DEV_103';
        trDeviation5.Deviation_Description__c = 'Applicant age less than 18 years';
        trDeviation5.Deviation_Type__c = 'Manual';
        trDeviation5.Is_Deviation_Active__c = true;
        trDeviation5.Is_Deviation_Raised__c = false;
        trDeviation5.Is_Send_Email__c = false;
        trDeviation5.Loan_Applicant__c = null;
        trDeviation5.Property__c = null;
        trDeviation5.MS_Deviation__c = msDeviation2.Id;
        trDeviation5.Approval_Authority__c = u.Id;
        listTrDeviation.add(trDeviation5);
        
        insert listTrDeviation;
    }
    
    @isTest
    static void getTrDeviation() {
        List<Application__c> loginApplication = [SELECT Id, Stage__c,Name, Current_Deviation_Approval__c FROM Application__c];
        List<Verification__c> verificationApp = [SELECT ID, Application__c, Application__r.Is_Deviation_Raised__c, Application__r.Is_Deviation_Approval_User__c 
            				FROM Verification__c LIMIT 1];
        String app1;
        String app2 ;
        List<User> u = [SELECT Id, Email, Name, IsActive FROM User WHERE Email = 'test@test.com'];
        if(loginApplication.size() >0){
            for(Application__c app :loginApplication){
                if(app.Stage__c == 'Process Credit'){
                    app1 = app.Id;
                    app.Stage__c = 'Approval Credit';
                    
                }
                if(app.Stage__c == 'Disbursal Maker'){
                    app2 = app.Id;
                    app.Stage__c = 'Disbursal Author';
                    
                }
            }
        }
        String devId;
        List<Tr_Deviation__c> trDevList = [SELECT Id, Approval_Authority__c FROM Tr_Deviation__c];
        for(Tr_Deviation__c devAppAuthNull : trDevList){
            if(devAppAuthNull.Approval_Authority__c == null){
                devId = devAppAuthNull.Id;
            }
        }
        Map<String,String> appTrac = new Map<String,String>();
        appTrac.put(loginApplication[0].Id,'L6');
        system.debug('trDevList' + trDevList);
        test.startTest();
        if(loginApplication != null && loginApplication.size() > 0){
        	pcDeviationController.getTrDeviationData(loginApplication[0].Id, 'Approval Credit');
        	pcDeviationController.getNewRow(loginApplication[0].Id);
        	if(u != null && u.size() > 0)
        		pcDeviationController.saveDeviation(devId,u[0].Id);
        	pcDeviationController.getDevCodeFromMaster(loginApplication[0].Id);
        	//pcDeviationController.getDevCodeFromMaster(app1);
        	pcDeviationController.getDevCodeFromMaster(loginApplication[1].Id);
            pcDeviationController.getLowestLevelePendingTRDevRecords(loginApplication[0].Id);
            loginApplication[0].Stage__c = 'Disbursal Maker';
            update loginApplication[0];
            pcDeviationController.getTrDeviationData(loginApplication[0].Id, 'Approval Credit');
            pcDeviationController.getTrDeviationData(loginApplication[0].Id, 'Disbursal Author');
            Map<String, MS_Deviation__c> msDev = pcDeviationController.getDevCodeFromMaster(loginApplication[0].Id);
            List<string> msDevId = new List<string>();
            msDevId.addAll(msDev.KeySet());
            pcDeviationController.getLowestLevelePendingTRDevRecords(loginApplication[0].Id);
            pcDeviationController.StringmapOfMsDevWithUser(loginApplication[0].Id, 'Approval Credit');
            pcDeviationController.StringmapOfMsDevWithUser(loginApplication[0].Id, 'Disbursal Author');
            pcDeviationController.isDeviationApprovalStage(verificationApp[0].Id);
            pcDeviationController.getAllPendingDeviatons(loginApplication[0].Id, 'Credit');
            pcDeviationController.getCurrentLoginUser(loginApplication[0].Id);
            System.runAs(u[0]){
                pcDeviationController.getCurrentLoginUser(loginApplication[0].Id);
            } 
            pcDeviationController.sendNotificationToL5User(loginApplication[0]);
            pcDeviationController.getApprovedDev(loginApplication[0].Id, 'Approval Credit');
            pcDeviationController.getApprovedDev(loginApplication[0].Id, 'Disbursal Author');
            pcDeviationController.sendEmailToApprovalUser(u[0].Id, loginApplication[0].Id);
            pcDeviationController.devApplicationTracking(appTrac);
            //pcDeviationController.saveNewDeviation('[{"Application__c":"'+loginApplication[0].Id+'","Decistion__c":"Approval for Pending","Remark__c":"","Deviation_Type__c":"Manual","Approval_Level__c":"L7","Is_Deviation_Active__c":true,"Deviation_Description__c":"Exposure above 20L upto 50L - OTHERS","Mitigants__c":"","Is_Deviation_Raised__c":false,"Deviation_Code__c":"DEV_050","Applicable_for__c":"Application"}]', u[0].Id, 'Application', null, 'L1',msDevId[0],'Test Class');
        }
        test.stopTest();
        
    }
    
    @isTest
    Static void updateDecisionApproved(){
        List<Application__c> loginApplication = [SELECT Id, Stage__c FROM Application__c];
        List<Tr_Deviation__c> trDevList = [SELECT Id, Approval_Authority__c,Approval_Level__c, Decistion__c FROM Tr_Deviation__c ORDER BY Approval_Level__c];
        List<Tr_Deviation__c> updateDeviation = new List<Tr_Deviation__c>();
        for(Tr_Deviation__c devAppAuthNull : trDevList){
            if(devAppAuthNull.Decistion__c == 'Approval for Pending'){
                
                devAppAuthNull.Decistion__c = 'Approved';
                updateDeviation.add(devAppAuthNull);
                break;
            }
        }
        if(updateDeviation != null && updateDeviation.size() > 0){
            update updateDeviation;
        }
        test.startTest();
        pcDeviationController.getLowestLevelePendingTRDevRecords(loginApplication[0].Id);
        pcDeviationController.getApprovedDev(loginApplication[0].Id, 'Approval Credit');
        pcDeviationController.appIsRaise(loginApplication[0].Id);
        test.stopTest();
    }
    
    @isTest
    Static void updateDecisionNotApproved(){
        List<Application__c> loginApplication = [SELECT Id, Stage__c FROM Application__c];
        List<Tr_Deviation__c> trDevList = [SELECT Id, Approval_Authority__c,Approval_Level__c, Decistion__c FROM Tr_Deviation__c ORDER BY Approval_Level__c];
        List<Tr_Deviation__c> updateDeviation = new List<Tr_Deviation__c>();
        for(Tr_Deviation__c devAppAuthNull : trDevList){
            if(devAppAuthNull.Decistion__c == 'Approval for Pending'){
                
                devAppAuthNull.Decistion__c = 'Not Approved';
                updateDeviation.add(devAppAuthNull);
                break;
            }
        }
        if(updateDeviation != null && updateDeviation.size() > 0){
            update updateDeviation;
        }
        
        test.startTest();
        pcDeviationController.getLowestLevelePendingTRDevRecords(loginApplication[0].Id);
        pcDeviationController.saveTrDeviationRecords('[{"applicantOrAssetName":"","devList":{"Application__c":"'+loginApplication[0].Id+'","Decistion__c":"Approval for Pending","Remark__c":"","Deviation_Type__c":"Manual","Approval_Level__c":"L7","Is_Deviation_Active__c":true,"Deviation_Description__c":"Exposure above 20L upto 50L - OTHERS","Mitigants__c":"","Is_Deviation_Raised__c":false,"Deviation_Code__c":"DEV_050","Applicable_for__c":"Application","Approval_Authority__c":null},"iscurrentUser":false,"isNewRow":true,"sendEmail":false,"userName":"","rowNumber":1}]');
        pcDeviationController.getAllPendingDeviatons(loginApplication[0].Id, 'Credit');
        
        test.stopTest();
    }
    //[{"applicantOrAssetName":"","devList":{"Application__c":"a030w000008HwIQAA0","Decistion__c":"Approval for Pending","Remark__c":"","Deviation_Type__c":"Manual","Approval_Level__c":"L7","Is_Deviation_Active__c":true,"Deviation_Description__c":"Exposure above 20L upto 50L - OTHERS","Mitigants__c":"","Is_Deviation_Raised__c":false,"Deviation_Code__c":"DEV_050","MS_Deviation__c":"a100w000000iuMmAAI","Applicable_for__c":"Application","Approval_Authority__c":null},"iscurrentUser":false,"isNewRow":true,"sendEmail":false,"userDetail":[{"label":"Custody Inward","value":"0050w000004LbQ5AAK"},{"label":"Custody Storage","value":"0050w000004LbQKAA0"}],"userName":"","rowNumber":1}]
}