@isTest
public class FsRepaymentScheduleController_Test {
    @TestSetup
    static void createTestData(){
        Application__c app = new Application__c();
        app.Applicant_Name__c = 'Test';
        app.Tenor_In_Months__c = '84';
        app.Customer_Communicated__c = 20.00; 
        app.Number_of_advance_EMI__c = '0';
        insert app;
        
        Application__c app1 = new Application__c();
        app1.Applicant_Name__c = 'ww';
        app1.Tenor_In_Months__c = '36';
        app1.Customer_Communicated__c = 22.00; 
        app1.Number_of_advance_EMI__c = '1';
        insert app1;
        
        MS_Scheme__c ms = new MS_Scheme__c();
        ms.Scheme_Code__c = 'LAP_BL';
        ms.Cycle_Date_Type__c = 'Range';
        insert ms;  
        
        MS_Scheme__c ms1 = new MS_Scheme__c();
        ms1.Scheme_Code__c = 'aa';
        ms1.Cycle_Date_Type__c = 'EOM';
        insert ms1;  
    }
    @isTest
    static void testMethod2(){
        Application__c application = [SELECT Id,Applicant_Name__c,Name,Tenor_In_Months__c ,Total_Amount_Recommended_PcAc__c,Customer_Communicated__c,Number_of_advance_EMI__c FROM Application__c WHERE Applicant_Name__c = 'ww'];
        Application__c application1 = [SELECT Id,Applicant_Name__c,Name,Tenor_In_Months__c ,Total_Amount_Recommended_PcAc__c,Customer_Communicated__c,Number_of_advance_EMI__c FROM Application__c WHERE Applicant_Name__c = 'Test'];
        Test.startTest();
        FsRepaymentScheduleController.generateRepaymentSchedule(application.Id);
        FsRepaymentScheduleController.generateRepaymentSchedule(application1.Id);
        Test.stopTest();
    }  
}