@isTest
public class FS_MODRegistrationController_Test {
	@isTest
    static void modTest(){
        Application__c app = new Application__c();
        app.Employee_ID__c = userInfo.getUserId();
        app.Customer_Visit_date__c = date.today()-15;
        app.Field_Officer_Emp_Id__c = userInfo.getUserId();
        app.Requested_Loan_Amount__c = 10000;
        app.Channel__c = 'Common';
        app.Alternate_Channel_Mode__c = 'Brokers';
        insert app;
        
        Account acc = new Account();
        acc.Name = 'testacc'; 
        insert acc;
        
        Loan_Applicant__c loan = new Loan_Applicant__c();
        loan.Customer_Information__c = acc.Id;
        loan.Application__c = app.Id; 
        insert loan;
        
        FS_MODRegistrationController.getExistingMODRegistraton(app.Id);
        FS_MODRegistrationController.getLoanApplicantRecords(app.Id);
        FS_MODRegistrationController.updateStage(app.Id,'Post Approval');
    }
}