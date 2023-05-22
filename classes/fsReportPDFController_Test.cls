@isTest
public class fsReportPDFController_Test {
	@TestSetup
    static void createTestData() {
        Application__c app = new Application__c();
        app.AC_Remarks__c = 'ww';
        insert app;
   
    }
     @isTest
    static void testAllMethod(){
        List<Application__c> listOfApplication = [SELECT Id FROM Application__c];
        Application__c app = [SELECT Id,AC_Remarks__c FROM Application__c WHERE AC_Remarks__c='ww'];
        test.startTest();
        fsReportPDFController.getData(app.Id,'Login');
		fsReportPDFController.createDataForVF(null, app.Id);
		PageReference pageRef = Page.fsReportsPDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(app.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(app);
        fsReportPDFController obj = new fsReportPDFController();
        test.stopTest();
    }
}