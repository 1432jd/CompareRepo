@IsTest
public class FeeCreationComponentHelperTest {
    @TestSetup
    public static void testSetup(){

        Branch_Master__c branch = new Branch_Master__c();
        branch.Name = 'Noida';
        insert branch;

        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Application__c oldApp = new Application__c();
        oldApp.Pre_Login__c = preLogin.Id;
        oldApp.Sourcing_Branch__c = branch.ID;
        oldApp.Stage__c = 'Login';
        oldApp.application_status__c = 'Active';
        oldApp.Requested_Loan_Amount__c = 300000;
        oldApp.Loan_Amount__c = 100000;
        oldApp.LMS_Response_Reference__c = '8984734334';
        oldApp.EMI__c = 10000;
        oldApp.Tranche_Disbursal__c = 'I';
        insert oldApp;
        
        Application__c app = new Application__c();
        app.Old_Application__c = oldApp.Id;
        app.Pre_Login__c = preLogin.Id;
        app.Sourcing_Branch__c = branch.ID;
        app.Stage__c = 'Login';
        app.application_status__c = 'Active';
        app.Requested_Loan_Amount__c = 300000;
        app.Loan_Amount__c = 100000;
        //app.LMS_Response_Reference__c = '8984734334';
        app.EMI__c = 10000;
        insert app;
        Account acc = new Account();
        acc.LastName = 'testacc';
        insert acc;
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        Loan_Applicant__c loan = new Loan_Applicant__c();
        loan.Application__c = app.Id;
        loan.Customer_Type__c = 'Primary Applicant';
        loan.Customer_Information__c = acc.Id;
        loan.Residence_Address_Line_1__c = 'testaddress';
        loan.Application__c = app.Id;
        //insert loan;
        loanAppList.add(loan);
        
        Loan_Applicant__c loan1 = new Loan_Applicant__c();
        loan1.Application__c = app.Id;
        loan1.Customer_Information__c = acc.Id;
        loan1.Residence_Address_Line_1__c = 'testaddress1';
        loan1.Application__c = app.Id;
        //insert loan1;
        loanAppList.add(loan1);
        insert loanAppList;
        
        Property__c prop1 = new Property__c();
        prop1.Application__c =app.Id;
        prop1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId(); 
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        //prop1.Final_Land_Value__c = 1000;
        insert prop1;
        
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
        //insert fee_type_masterObj;
        
         Fee_Type_Master__c fee_type_masterObj1 = new Fee_Type_Master__c(
            Name = 'PRC_FEE_Type',
          //  Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'User',
            Event__c = 'Application Login',
            Applicable_For__c = 'Applicant',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Exclusive',
            Amount__c = 'Percentage',
            Value__c = 'Installment Amount',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        //insert fee_type_masterObj1;
        feeMasterList.add(fee_type_masterObj1);
        
        Fee_Type_Master__c fee_type_masterObj2 = new Fee_Type_Master__c(
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
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        feeMasterList.add(fee_type_masterObj2);
        
        Fee_Type_Master__c fee_type_masterObj3 = new Fee_Type_Master__c(
            Name = 'PRC_FEE_Type',
        //    Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Asset Entry',
            Applicable_For__c = 'Asset',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Inclusive',
            Amount__c = 'Percentage',
            Value__c = 'Asset Cost',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        feeMasterList.add(fee_type_masterObj3);
        
        Fee_Type_Master__c fee_type_masterObj4 = new Fee_Type_Master__c(
            Name = 'PRC_FEE_Type',
        //    Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Application Login',
            Applicable_For__c = 'Application',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'No',
            Amount__c = 'Percentage',
            Value__c = 'Loan Amount',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        feeMasterList.add(fee_type_masterObj4);
        
        Fee_Type_Master__c fee_type_masterObj5 = new Fee_Type_Master__c(
            Name = 'PRC_FEE_Type',
          //  Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Application Login',
            Applicable_For__c = 'Applicant',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Exclusive',
            Amount__c = 'Amount',
            Value__c = 'Installment Amount',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'No',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        //insert fee_type_masterObj1;
        feeMasterList.add(fee_type_masterObj5);
        
        Fee_Type_Master__c fee_type_masterObj6 = new Fee_Type_Master__c(
            Name = 'PRC_FEE_Type',
        //    Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Asset Entry',
            Applicable_For__c = 'Asset',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Inclusive',
            Amount__c = 'Percentage',
            Value__c = 'Loan Amount',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        feeMasterList.add(fee_type_masterObj6);
        
        Fee_Type_Master__c fee_type_masterObj7 = new Fee_Type_Master__c(
            Name = 'PRC_FEE_Type',
        //    Fee_Type_Code__c = 'PRC_FEE_Type',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Asset Entry',
            Applicable_For__c = 'Application',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Inclusive',
            Amount__c = 'Percentage',
            Value__c = 'Asset Cost',
            Calculation_Basis__c = 'Flat',
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
        	Active__c = 'Yes', Fee_Category__c = 'Processing Fees');
        feeMasterList.add(fee_type_masterObj7);
        
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
        
        Fee_Value_Master__c fee_value_masterObj1 = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj1.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj1);
        
        Fee_Value_Master__c fee_value_masterObj2 = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj2.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj2);
        
        Fee_Value_Master__c fee_value_masterObj3 = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj3.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj3);
        
        Fee_Value_Master__c fee_value_masterObj4 = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj4.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj4);
        
        Fee_Value_Master__c fee_value_masterObj5 = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj5.Id,
            //Amount__c = 2000,
            Amount_Flat__c = 20,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj5);
        
        Fee_Value_Master__c fee_value_masterObj6 = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj6.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj6);
        
        Fee_Value_Master__c fee_value_masterObj7 = new Fee_Value_Master__c(
            Description__c = 'Test Fee Value Master',
            Fee_Type_Master__c = fee_type_masterObj6.Id,
            Amount__c = 2000,
            Floor__c = 500,
            Cap__c = 20000,
            Max_waiver_amount_without_Approval__c = 70,
            Range__c = 'Test Range', Active__c = 'Yes');
         //insert fee_value_masterObj;
        feeValueList.add(fee_value_masterObj7);
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
            Loan_Applicant__c = Loan.Id,
            Tax__c = 'Inclusive'
        );
         //insert fee_creationObj;
        fee_creationObjList.add(fee_creationObj);
        
        
        Fee_Creation__c fee_creationObj1 = new Fee_Creation__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Fee_Creation__c').getDescribe().getRecordTypeInfosByName().get('Fee').getRecordTypeId(),
            Description__c = '212',
            Type__c = 'User',
            Fee_Amount__c = 423.73,
            Total_Fee__c = 500,
            Stage_Due__c = 'Pre Login',
            Application__c = app.Id,
            Applicable_on_Loan_Amount_Asset_Value__c = 'Loan Amount',
            Fee_Code__c = 'Cersai',
            Tax_Amount__c = 76.27,
            Applicable_For__c = 'Applicant',
            Repayment_Type_2__c = 'Direct Receipt', Fee_Type_Master__c = fee_type_masterObj1.Id,
            Fee_Value_Master__c = fee_value_masterObj1.Id, Tax__c = 'Inclusive');
        	
         //insert fee_creationObj1;
         fee_creationObjList.add(fee_creationObj1);
        
        Fee_Creation__c fee_creationObj2 = new Fee_Creation__c(
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
            Applicable_For__c = 'Asset',
            Property__c = prop1.Id,
            Fee_Type_Master__c = fee_type_masterObj4.Id,
            Fee_Value_Master__c = fee_value_masterObj4.Id
        );
        fee_creationObjList.add(fee_creationObj2);
        
        Fee_Creation__c fee_creationObj3 = new Fee_Creation__c(
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
            Applicable_For__c = 'Asset',
            Receipt_Created__c = true
            
            
        );
         //insert fee_creationObj;
        fee_creationObjList.add(fee_creationObj3);
        insert fee_creationObjList;
    }

    @IsTest
    public static void test(){
        List<FeeCreationWrapper> wrpObj = new List<FeeCreationWrapper>();
        List<Fee_Creation__c> fee = [SELECT Id, Fee_Code__c FROM Fee_Creation__c];
        List<Fee_Value_Master__c> feeValue = [SELECT Id, Name, Fee_Type_Code__c, Amount__c, Cap__c, Floor__c, Amount_Flat__c,
                                                        Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,Fee_Type_Master__r.Fee_Type__c,
                                                        Fee_Type_Master__r.Tax__c,Fee_Type_Master__r.Value__c,Fee_Type_Master__r.Type__c,Fee_Type_Master__r.Event__c,Fee_Type_Master__r.Applicable_For__c  
                                                        FROM Fee_Value_Master__c ];
        
        Application__c app = [SELECT Id, EMI__c, (SELECT Id, Applicant_Name__c FROM Loan_Applicants__r) FROM Application__c WHERE Tranche_Disbursal__c = null limit 1];
        List<Property__c> propertyList = [SELECT Id, Name, Final_Land_Value__c, Application__c FROM Property__c WHERE RecordType.name = 'Pre Login Property Detail'];
        //List<Loan_Applicant__c> applicantList = [SELECT Id, Applicant_Name__c, Application__c FROM Loan_Applicant__c];
        List<Loan_Applicant__c> applicantList = app.Loan_Applicants__r;
        System.debug('applicantList '+ applicantList.size() );
        List<Fee_Type_Master__C> feeMasterCode = [SELECT Id, Fee_Type_Code__c,Applicable_For__c FROM Fee_Type_Master__c 
                                                      WHERE Fee_Type__c = 'User' AND Type__c ='Fee' AND Active__c = 'Yes' ];
        String feeValId;
        for(Fee_Value_Master__c feeV: feeValue){
            System.debug('Fee_Type_Master__r.Applicable_For__c '+ feeV.Fee_Type_Master__r.Applicable_For__c );
            if(feeV.Fee_Type_Master__c == feeMasterCode[0].Id){
                feeValId = feeV.Id;
            }
        }
        
        FeeCreationWrapper obj = new FeeCreationWrapper();
        obj.Id = fee[0].Id;
        obj.sRNumnber = 1;
        obj.type = 'User';
        obj.feeCode = feeMasterCode[0].Fee_Type_Code__c;
        obj.masterId = feeValId;
        obj.applicantAssetId = applicantList[0].Id;
        wrpObj.add(obj);
        FeeCreationWrapper obj1 = new FeeCreationWrapper();
        obj1.Id = fee[0].Id;
        obj1.sRNumnber = 2;
        wrpObj.add(obj1);
        Test.startTest();
        FeeCreationComponentHelper.createFeeCreationRecords(app.Id, 'Application Login', null);
        
        FeeCreationComponentHelper.getFeeCreationRecords(app.Id);
        FeeCreationComponentHelper.addRow(JSON.serialize(wrpObj), 'add', '', '');
        FeeCreationComponentHelper.addRow(JSON.serialize(wrpObj), 'delete', '6', '');
        FeeCreationComponentHelper.addRow(JSON.serialize(wrpObj), 'delete', '2', '');
        FeeCreationComponentHelper.saveRecords(JSON.serialize(wrpObj), app.Id);
        //FeeCreationComponentHelper.getRepaymentPicklist_2('PRC_FEE_Type');
        FeeCreationComponentHelper.getFeeCodeFromMaster(app.Id);
        FeeCreationComponentHelper.getApplicationDetail(app.Id);
        FeeCreationComponentHelper.getFeeWithoutRepayment(app.Id);
        FeeCreationComponentHelper.getZeroFee(app.Id);
        FeeCreationComponentHelper.calculationUserFee(app.Id, feeValue[0].Id,propertyList[0].Id );
        app.Old_Application__c = null;
        //app.EMI__c = null;
        update app;
        FeeCreationComponentHelper.createFeeCreationRecords(app.Id, 'Asset Entry', propertyList);
        FeeCreationComponentHelper.createFeeCreationRecords(app.Id, 'PC Completion', null);
        
        feeMasterCode[0].Applicable_For__c = 'Applicant';
        update feeMasterCode;
        FeeCreationComponentHelper.saveRecords(JSON.serialize(wrpObj), app.Id);
        feeMasterCode[0].Applicable_For__c = 'Asset';
        update feeMasterCode;
        obj.applicantAssetId = propertyList[0].Id;
        FeeCreationComponentHelper.saveRecords(JSON.serialize(wrpObj), app.Id);
        FeeCreationComponentHelper.calculation(app.Id, propertyList, 'Asset Entry');
        Test.stopTest();
    }
    
    public class FeeCreationWrapper{
        public String Id;
        public Integer sRNumnber;
        public String type;
        public String feeCode;
        public String masterId;
        public String applicantAssetId;
    }
}