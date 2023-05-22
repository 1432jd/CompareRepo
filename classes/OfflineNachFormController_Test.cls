@isTest
public class OfflineNachFormController_Test {
    @isTest
    static void offFormTest(){
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        app.EMI__c = 48;
        insert app;
        
        Bank_Detail__c bank = new Bank_Detail__c();
        bank.Application__c = app.Id;
        bank.Name = 'Abc';
        bank.Account_Number__c = '3282738';
        bank.Branch_Name__c = 'xyz';
        bank.Bank_Account_Holder_Name__c = 'qwe'; 
        insert bank;
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(bank.Id));
        OfflineNachFormVfController a= new OfflineNachFormVfController();
        a.amountInWords(12232420.2345);
        a.amountInWords(1234487871);
        OfflineNachFormVfController.cls_request cls = new OfflineNachFormVfController.cls_request();
        cls.startDate ='05-08-2022';
        cls.endDate = String.valueOf(date.today());
        cls.destinationBank= 'UTIB';
        cls.utilityCode='RATN00005000010550';
        
        OfflineNachFormVfController.requestParse(json.serialize(cls));
        test.stopTest();
    }
    
}