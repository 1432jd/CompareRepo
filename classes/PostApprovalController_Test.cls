/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Arnav Chaudhary 
* @modifiedBy       Arnav Chaudhary  
* @created          2022-09-6
* @modified         2022-09-6
* @Description      Test class for Post Approval Controller class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
public class PostApprovalController_Test {
    @isTest
    static void unitTest1(){
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.Stage__c = 'Approval Credit';
        app.AC_Submission_Date__c = date.today()-10;
        app.AC_Decision__c = 'Approve';
        app.AC_Remarks__c = 'Test';
        insert app;  
        
        Id acRecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('AC').getRecordTypeId();
        Id pcRecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('PC').getRecordTypeId(); 
        
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
        ver.RecordTypeId = acRecordTypeId;
        insert ver;
        
        Verification__c ver1 = new Verification__c();
        ver1.Application__c = app.Id;
        ver1.RecordTypeId = pcRecordTypeId;
        insert ver1;
        
        Test.startTest();
        PostApprovalController.postApprovalData(app.Id);
        PostApprovalController.generateFinalSanctionLetter(app.Id);
        PostApprovalController.checkFinalSanctionLetter(app.Id);
        PostApprovalController.sendBackAprovalCredit(app.Id);
        PostApprovalController.updateStage(app.Id, 'Post Approval');
        Test.stopTest();
    }
}