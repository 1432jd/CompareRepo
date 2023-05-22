@isTest
public class FinalSanctionController_Test {
    @isTest
    static void unitTest(){
        List<String> appList = new List<String>();
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.Stage__c = 'Final Sanction';
        
        insert app;
        
        Id legalRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        Id acRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('AC Property Detail').getRecordTypeId();
        
        Property__c prop = new Property__c();
        prop.Application__c = app.Id;
        prop.Title_Deed_Number__c = '12414';
        prop.Land_Area_Sq_Ft__c = 2433;
        prop.Title_Deed_Date__c = date.today() - 14;
        prop.Document_Type__c = 'Sale Deed';
        prop.Risk_Document__c = 'Orange';
        insert prop;
        
        Property__c prop1 = new Property__c();
        prop1.Application__c = app.Id;
        prop1.RecordTypeId = acRecordTypeId;
        prop1.Title_Deed_Number__c = '12414';
        prop1.Land_Area_Sq_Ft__c = 2433;
        prop1.Title_Deed_Date__c = date.today() - 14;
        prop1.Document_Type__c = 'Sale Deed';
        prop.Risk_Document__c = 'Orange';
        prop1.Property__c = prop.Id;
        insert prop1;
        
        Property__c prop2 = new Property__c();
        prop2.Application__c = app.Id;
        prop2.RecordTypeId = legalRecordTypeId;
        prop2.Title_Deed_Number__c = '12414';
        prop2.Land_Area_Sq_Ft__c = 2433;
        prop2.Title_Deed_Date__c = date.today() - 14;
        prop2.Document_Type__c = 'Sale Deed';
        prop.Risk_Document__c = 'Orange';
        prop2.Property__c = prop.Id;
        insert prop2;
        
        Legal_Approval__c legal = new Legal_Approval__c();
        legal.Application__c = app.Id;
        legal.Status__c = 'Pending';
        insert legal; 
        
        Verification__c ver = new Verification__c();
        ver.Application__c = app.Id;
        ver.Status__c = 'Pending';
        insert ver;
        
        // FinalSanctionController.SectionContent sec = new FinalSanctionController.SectionContent();
        Decimal order= 23.00;
        String field = 'Test';
        String acVal = 'wek';
        String laVal = 'ww';
        String validation = 'Okay';
        
        Decimal order1= 2333.00;
        String field1 = 'Approved Loan Amount';
        Decimal acVal1 = 123.00;
        Decimal laVal1 = 3232.00;
        
        Decimal order2= 21333.00;
        String field2= 'Land Area Extent';
        Decimal acVal2 = 233.23;
        Decimal laVal2 = 3452.22;
        
        test.startTest();
        new FinalSanctionController.SectionContent(order,field,acVal,laVal);
        new FinalSanctionController.SectionContent(order1,field1,acVal1,laVal1);
        new FinalSanctionController.SectionContent(order2,field2,acVal2,laVal2);
        FinalSanctionController.checkSendBackVaidation(app.Id);
        FinalSanctionController.getValidationTableData(app.Id);
        app.Stage__c = 'Post Approval';
        Update  app;
        appList.add(app.Id);
        FinalSanctionController.passStage(appList);
        FinalSanctionController.moveStage(app.Id);
        FinalSanctionController.sendBackAprovalCredit(app.Id);
        FinalSanctionController.sendBackLegalApproval(app.Id);
        Application__c app1 = new Application__c();
        app1.Employee_ID__c = userInfo.getUserId();
        app1.Customer_Visit_date__c = date.today()-15;
        app1.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app1.Requested_Loan_Amount__c = 10000;
        app1.Channel__c = 'Common';
        app1.Alternate_Channel_Mode__c = 'Brokers';
        FinalSanctionController.doSendBack(app1);
        test.stopTest();
    }
}