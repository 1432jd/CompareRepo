@isTest
public class MobileVerificationControllerTest {
    
    @TestSetup
    public static void createTestData(){
        Application__c app = new Application__c();
        app.Applicant_Name__c = 'test';
        insert app;
        
        Account acc = new Account();
        acc.LastName = 'test1';
        acc.PersonBirthdate = date.today()-15;
        acc.Gender__c = 'Male';
        insert acc;
        
        MS_Pincode__c ms = new MS_Pincode__c();
        ms.Name = '1233';
        insert ms;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Business_Address_Line_1__c = 'loanadd';
        loanApp.Is_KYC_Verified__c = true;
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = acc.Id;
        loanApp.Residence_Pincode__c = ms.Id;
        loanApp.Residence_Address_Line_1__c = 'testaddress';
        loanApp.Residence_City__c = 'Testcity';
        loanApp.Mobile__c = '9988776655';
        loanApp.KYC_ID_Type_1__c = 'Driving License';
        loanApp.KYC_ID_Type_2__c = 'Aadhaar Card';
        loanApp.KYC_Id_1__c = '123456789';
        loanApp.KYC_Id_2__c = '998877665544';
        insert loanApp;
    }
    
    @isTest
    public static void doSendOTPTest(){
        Loan_Applicant__c loanApp = [SELECT Id,Mobile__c FROM Loan_Applicant__c WHERE Mobile__c = '9988776655'];
        String body = '{\"result\":{\"message\":\"Otphasbeensenttoyourmobilenumber\"},\"requestId\":\"1ec766d9-03e6-482d-a4a4-c1ab7557ec0f\",\"statusCode\":\"101\",\"description\":\"ValidAuthentication\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body,200));
        test.startTest();
        MobileVerificationController.SendOTP(loanApp.Id, loanApp.Mobile__c);
        test.stopTest();
    }
    
     @isTest
    public static void doSendOTPTestFail(){
        Loan_Applicant__c loanApp = [SELECT Id,Mobile__c FROM Loan_Applicant__c WHERE Mobile__c = '9988776655'];
        String body = '{\"Error\":{\"message\":\"Error\",\"description\":\"Error\"},\"requestId\":\"1ec766d9-03e6-482d-a4a4-c1ab7557ec0f\",\"statusCode\":\"101\",\"description\":\"ValidAuthentication\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body,101));
        test.startTest();
        MobileVerificationController.SendOTP(loanApp.Id, loanApp.Mobile__c);
        test.stopTest();
    }
    
    @isTest
    public static void doValidateOTPTest(){
        Loan_Applicant__c loanApp = [SELECT Id,Mobile__c FROM Loan_Applicant__c WHERE Mobile__c = '9988776655'];
        String body = '{\"requestId\":\"25d75650-c023-45ef-a2b6-d691a7c7edfb\",\"result\":{\"contact\":{\"address\":\"172MALAIMAGALSTREETZAMINPALLAVARAM\",\"altContact\":\"8072431160\",\"emailId\":null,\"workEmail\":null},\"device\":{\"3gSupport\":\"yes\",\"deviceActivationDate\":\"01-01-2023\",\"imei\":null,\"model\":\"XiaomiRedmiNote7\"},\"history\":null,\"identity\":{\"dateOfBirth\":\"19-12-1996\",\"gender\":null,\"name\":\"KSathishkumar\"},\"profile\":{\"education\":null,\"language\":null,\"maritalStatus\":null,\"occupation\":null,\"relationships\":null,\"workplace\":null},\"simDetails\":{\"activationDate\":\"22-12-2022\",\"lastActivityDate\":null,\"otpValidated\":true,\"provider\":\"Airtel\",\"type\":\"PREPAID\"}},\"statusCode\":\"101\",\"description\":\"ValidAuthentication\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body,200));
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body,101));
        test.startTest();
        MobileVerificationController.ValidateOTP(loanApp.Id, '25d75650-c023-45ef-a2b6-d691a7c7edfb', '1234');
        test.stopTest();
    }
    
    @isTest
    public static void doValidateOTPTestFail(){
        Loan_Applicant__c loanApp = [SELECT Id,Mobile__c FROM Loan_Applicant__c WHERE Mobile__c = '9988776655'];
        String body = '{\"Error\":{\"message\":\"Error\",\"description\":\"Error\"},\"requestId\":\"1ec766d9-03e6-482d-a4a4-c1ab7557ec0f\",\"statusCode\":\"101\",\"description\":\"ValidAuthentication\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body,101));
        test.startTest();
        MobileVerificationController.ValidateOTP(loanApp.Id, '25d75650-c023-45ef-a2b6-d691a7c7edfb', '1234');
        test.stopTest();
    }
    
    @isTest
    public static void doMobileVerification(){
        Loan_Applicant__c loanApp = [SELECT Id,Mobile__c FROM Loan_Applicant__c WHERE Mobile__c = '9988776655'];
        test.startTest();
        MobileVerificationController.loanAppMobileVerification(loanApp.Id);
        test.stopTest();
    }


}