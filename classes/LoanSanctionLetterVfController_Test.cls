@isTest
public class LoanSanctionLetterVfController_Test {
    @TestSetup
    public static void testSetup(){
        Application__c app = new Application__c();
        app.Sub_Stage__c = 'Legal Approval';
        app.Any_Approval_to_be_Obtained__c = 'Yes';
        app.EMI__c = 100;
        app.Legal_Summary_Remarks__c = 'test';
        insert app;
        
        Property__c propObj = new Property__c();
        propObj.Applicant__c = app.Id;
        propObj.Village__c ='testing';
        propObj.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        insert propObj;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = app.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        loanList.add(l);
        
        Loan_Applicant__c l1 = new Loan_Applicant__c();
        l1.Application__c = app.Id;
        l1.Customer_Type__c ='Co-Applicant';
        l1.Constitution__c ='Individual';
        l1.Customer_Information__c = ci.id; 
        loanList.add(l1);
        
        Loan_Applicant__c l2 = new Loan_Applicant__c();
        l2.Application__c = app.Id;
        l2.Customer_Type__c ='Guarantor';
        l2.Constitution__c ='Individual';
        l2.Customer_Information__c = ci.id; 
        loanList.add(l2);
        insert loanList;
        
        Id acId = [Select Id From RecordType Where SobjectType = 'Character__c' and Name = 'AC Character'].Id;
        
        List<Character__c> listChar = new List<Character__c>();
        Character__c c= new Character__c();
        c.RecordTypeId = acId;
        c.Application__c= app.Id;
        c.Loan_Applicant__c =l1.Id;
        c.Section_Type__c = 'Family Detail';
        c.Customer_Type__c = 'Co-Applicant';
        c.Family_Member_Name__c = 'ee';
        c.Relationship__c ='Mother of'; 
        listChar.add(c);
        
        Character__c c1= new Character__c();
        c1.RecordTypeId = acId;
        c1.Application__c= app.Id;
        c1.Loan_Applicant__c =l2.Id;
        c1.Section_Type__c = 'Family Detail';
        c1.Customer_Type__c ='Guarantor';
        c1.Relationship__c ='Father of';
        c1.Family_Member_Name__c = 'ww';
        listChar.add(c1);
        insert listChar;
        
        List<Sanction_Condition__c> sancList = new List<Sanction_Condition__c>();
        Sanction_Condition__c sc = new Sanction_Condition__c();
        sc.Application__c = app.Id;
        sc.Other_Condition__c = 'Yes';
        sc.Print_In_Sanction_Letter__c = 'Yes';
        sc.Remark__c = 'Test';
        sc.MsSanctionCondition__c = 'Test34';
        sancList.add(sc);
        
        Sanction_Condition__c sc1 = new Sanction_Condition__c();
        sc1.Application__c = app.Id;
        sc1.Other_Condition__c = 'No';
        sc1.Print_In_Sanction_Letter__c = 'Yes';
        sc1.Remark__c = 'Test12';
        sc1.MsSanctionCondition__c = 'Test2';
        sancList.add(sc1);
        insert sancList;
    }
    
    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Property__c prop = [SELECT Id,Village__c FROM Property__c WHERE Village__c ='testing'];
        Character__c char2 = [SELECT Id,Relationship__c FROM Character__c WHERE Relationship__c = 'Mother of'];
        Character__c char1 = [SELECT Id,Relationship__c FROM Character__c WHERE Relationship__c = 'Father of'];
        Test.startTest();
        PageReference pageRef = Page.LoanSanctionLetterVf;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(app.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(app);
        LoanSanctionLetterVfController obj = new LoanSanctionLetterVfController();
        Test.stopTest();
    }
}