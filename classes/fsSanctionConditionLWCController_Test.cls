@isTest
public class fsSanctionConditionLWCController_Test {
    @TestSetup
    static void testData(){
        Application__c app = new Application__c();
        app.Applicant_Name__c = 'testApp';
        insert app;
        
        Ms_Sanction_Condition__c ms = new Ms_Sanction_Condition__c();
        ms.Is_Active__c = true;
        ms.Type__c = 'Sanction';
        insert ms;
        
        Sanction_Condition__c sanc = new Sanction_Condition__c();
        sanc.Application__c = app.Id;
        sanc.MsSanctionCondition__c = 'ok';
        sanc.Created_From__c = 'Approval Credit';
        sanc.Print_In_Sanction_Letter__c = 'Yes';
        sanc.Other_Condition__c = 'No';
        sanc.Remark__c = 'ww';
        sanc.Added_By__c = UserInfo.getUserId();
        insert sanc;
        
        GenericDataTableController gen = new GenericDataTableController();
        gen.METADATA_NAME = 'abc';
    }
    @isTest
    static void createTest(){
        Application__c application = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'testApp'];
        Ms_Sanction_Condition__c msSanction = [SELECT Is_Active__c FROM Ms_Sanction_Condition__c WHERE Is_Active__c = true];
        List<Sanction_Condition__c> sancList = [SELECT MsSanctionCondition__c,Created_From__c,Print_In_Sanction_Letter__c,Other_Condition__c,Remark__c,Added_By__c
                                                FROM Sanction_Condition__c WHERE MsSanctionCondition__c = 'ok'];
        
        test.startTest();
        List<fsSanctionConditionLWCController.SanctionConditionWrapper> wrapList = new List<fsSanctionConditionLWCController.SanctionConditionWrapper>();
        fsSanctionConditionLWCController.SanctionConditionWrapper testWrap = new fsSanctionConditionLWCController.SanctionConditionWrapper();
        testWrap.SrNo = 1;
        testWrap.source = 'Process Credit';
        testWrap.isChanged = true;
        testWrap.isPCSanction = true;
        testwrap.otherCondition = 'No';
        testWrap.printInSanctionLetter = 'Yes';
        testWrap.remarks = 'ww';
        testWrap.sanctionCondition = 'ok';
        wrapList.add(testWrap);
        fsSanctionConditionLWCController.getSanctionConditionTableData(application.Id,'Process Credit');
        fsSanctionConditionLWCController.saveSanctionConditions(application.Id, json.serialize(wrapList));
        test.stopTest();
    }
}