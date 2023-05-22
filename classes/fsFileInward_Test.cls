@isTest
public class fsFileInward_Test {
    @TestSetup
    static void createTestData(){      
        Application__c app1 = new Application__c();
        app1.Applicant_Name__c = 'App2';
        app1.File_Inward_Status__c = 'Pending';
        app1.Remarks__c = 'ss';
        app1.Stage__c ='File Inward';
        insert app1;
        
        Disbursal__c disbObj = new Disbursal__c();
        disbObj.Application__c = app1.Id;
        disbObj.Disbursal_Type__c = 'Full Disb';
        insert disbObj;
    }
    @isTest
    static void testAllMethod(){
        List<Application__c> appList = [SELECT Id,Applicant_Name__c FROM Application__c WHERE Applicant_Name__c = 'App2'];
        List<Disbursal__c> disbList = [Select Id,Disbursal_Type__c,Application__c FROM Disbursal__c WHERE Disbursal_Type__c ='Full Disb'];
        test.startTest();
        fsFileInward.getApplicationData(Date.today(),Date.today()+5,'app','22');
        fsFileInward.getApplicationData(Date.today(),null,'app','22');
        fsFileInward.getApplicationData(null,Date.today()+6,'app','22');
        fsFileInward.getApplicationData(Date.today(),Date.today()+6,'','');
        fsFileInward.getApplicationData(null,Date.today()+3,'','');
        fsFileInward.getApplicationData(Date.today()+6,null,'','');
        fsFileInward.getApplicationData(null,null,'222','rfr');
        fsFileInward.getApplicationData(null,null,'','rfeer');
        fsFileInward.getApplicationData(null,null,'red','');
        fsFileInward.getApplicationData(null,null,'','');
        List<fsFileInward.FileInwardWrapper> wrapList = new List<fsFileInward.FileInwardWrapper>();
        fsFileInward.FileInwardWrapper testWrap = new fsFileInward.FileInwardWrapper();
        Application__c app = new Application__c(); 
        testWrap.applicationNo = app.Name;
        testWrap.appType =app.Pre_Login__r.recordtype.name;
        testWrap.customerName ='wddw';
        testWrap.disbursalId =disbLIst[0].Id;
        testWrap.disbursalType ='Full Disb';
        testWrap.disbursalTypeChnaged =true;
        testWrap.stageInDate = 'ad';
        testWrap.serialNumber =11;
        testWrap.stage ='File Inward';
        testWrap.oldApplicationNo = 'NA';
        testWrap.sourcingBranchName = 'Noida';
        testWrap.sourcingBranchState = 'Assam';
        testWrap.loanNo = '22';
        testWrap.fileInwardStatus = 'Pending';
        testWrap.remarks = 'asdas';
        testWrap.appType = 'as';
        testWrap.disbursementDate = 'ascdas';
        testWrap.stageInDate = 'sdcds';
        testWrap.isError = false;
        testWrap.isChanged = true;
        testWrap.Id = app.Id;
        wrapList.add(testWrap);
        fsFileInward.saveApplications(json.serialize(wrapList));
        fsFileInward.submitApplications(json.serialize(wrapList));
        test.stopTest();
    }
}