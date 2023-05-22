@isTest
public class fsGenerateDisbMemo_Test {
	@TestSetup
    public static void testSetup(){
        Application__c app = new Application__c();
        app.Any_Approval_to_be_Obtained__c = 'Yes';
        app.EMI__c = 100;
        app.Legal_Summary_Remarks__c = 'test';
        insert app;
        
                
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        List<Fee_Type_Master__c> feeMasterList = new List<Fee_Type_Master__c>();
        Fee_Type_Master__c fee_type_masterObj = new Fee_Type_Master__c(
            Name = 'PRC_FEE_Type',
        //    Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Application Login',
            Applicable_For__c = 'Application',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Exclusive',
            Amount__c = 'Percentage',
            Value__c = 'Loan Amount',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'No',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        feeMasterList.add(fee_type_masterObj);
        insert feeMasterList;
        
        List<Fee_Value_Master__c> feeValueList = new List<Fee_Value_Master__c>();
        Fee_Value_Master__c fee_value_masterObj = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj);
        insert feeValueList;
        
        List<Fee_Creation__c> fee_creationObjList = new List<Fee_Creation__c>();
        Fee_Creation__c fee_creationObj = new Fee_Creation__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Fee_Creation__c').getDescribe().getRecordTypeInfosByName().get('Fee').getRecordTypeId(),
            Description__c = '212',
            Type__c = 'System',
            Fee_Amount__c = 423.73,
            Total_Fee__c = 500,
            Stage_Due__c = 'Pre Login',
            Application__c = app.Id,
            Applicable_on_Loan_Amount_Asset_Value__c = 'Loan Amount',
            Fee_Code__c = 'Cersai',
            Tax_Amount__c = 76.27,
            Repayment_Type_2__c = 'Direct Receipt',
            Applicable_For__c = 'Applicant',
         //   Loan_Applicant__c = Loan.Id,
            Tax__c = 'Inclusive'
        );
         //insert fee_creationObj;
        fee_creationObjList.add(fee_creationObj);
        insert fee_creationObjList;
        

        
        
        
        
        
        
        
        List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
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
        
        MOD_Registration__c mod = new MOD_Registration__c();
        mod.MOD_Amount__c = 232;
        mod.Application__c = app.Id;
        insert mod;
        
        Disbursal__c disb = new Disbursal__c();
        disb.Application__c = app.Id;
        insert disb;
        
        Disbursal_Payee__c dp = new Disbursal_Payee__c();
        dp.Application__c = app.Id;
        dp.Payment_Type__c = 'DD';
        dp.Beneficiary_Amount__c = 111;
        dp.Beneficiary_Name__c ='wwww';
        dp.Disbursal__c = disb.Id;
        dp.Beneficiary_Bank_Account_Number__c = '12212';
        dp.Beneficiary_Bank_Name__c ='qwe';
        dp.Beneficiary_Branch_Name__c='dss';
        insert dp;
    }
    @IsTest
    public static void test(){
        Application__c app = [SELECT Id FROM Application__c limit 1];
        Test.startTest();
        PageReference pageRef = Page.Disbursement_MemoVfPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(app.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(app);
        fsGenerateDisbMemo obj = new fsGenerateDisbMemo();
        Test.stopTest();
    }
}