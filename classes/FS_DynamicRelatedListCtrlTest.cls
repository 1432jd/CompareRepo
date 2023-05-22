@isTest
public class FS_DynamicRelatedListCtrlTest {

    @isTest
    public static void testDynamicRelatedListCtrl(){
        Branch_Master__c bm =new Branch_Master__c();
		bm.Name = 'Rajasthan';
		bm.State__c = 'RJ';
		insert bm;
        
        Application__c app = new Application__C();
        app.Sourcing_Branch__c = bm.Id;
        app.Stage__c='Login';
        app.Requested_Loan_Amount__c = 100000;
        insert app;
        
        Property__c pro = new Property__c();
        pro.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId();
        pro.Application__c = app.Id;
        pro.Title_Deed_Number__c = '2321';
        pro.Title_Deed_Date__c = Date.today();     
        insert pro;
        
        Property__c pro1 = new Property__c();
        pro1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        pro1.Application__c = app.Id;
        pro1.Property__c = pro.Id;
        pro1.Title_Deed_Number__c = '2321';
        pro1.Title_Deed_Date__c = Date.today();     
        insert pro1;
        List<String> paramList = new List<String>{'FIV-C Property Detail'};
        GenericDataTableController.DataTableResponse res = FS_DynamicRelatedListCtrl.returnRelatedRecords(app.Id,'FIV_C_Property',' RecordType.Name IN : IDS_SET',JSON.serialize(paramList));
   		System.Assert(res != NULL);
    }
}