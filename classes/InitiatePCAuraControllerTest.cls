@isTest
public class InitiatePCAuraControllerTest {

 @TestSetup
    static void testdata(){
	 // Pre Login Creation
        Pre_Login__c login1= new Pre_Login__c(Status__c='Active',RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId());
        insert login1;
        
        // Application Creation
        Application__c app = new Application__c();
        app.Name = 'APP - 0001';
        app.Pre_Login__c = login1.Id;
        insert app;
		
		 // Verification Creation PC
        Verification__c verObj = new verification__c();
        verObj.Application__c = app.Id;
        verObj.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('PC').getRecordTypeId();
        verObj.Status__c = 'Completed';
        insert verObj;
		
	
   }
   
   @isTest
    public static void mytestmethod(){
      string verId;
	  Application__c appObj = [SELECT Id,Name,(SELECT Id,RecordType.Name FROM Verifications__r) FROM Application__c  LIMIT 1];
      verId = appObj.Verifications__r[0].Id;
      InitiatePCAuraController.initiaize(appObj.Id,'PC');
      delete new Verification__c(Id = verId);
      InitiatePCAuraController.initiaize(appObj.Id,'PC');
      
      

	}
}