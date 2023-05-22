/*
* Author : Arnav Chaudhary
* Date : 30-01-2023
* Description : Test Class Of FS_DisbursalMemoController
*/

@isTest
public class FS_DisbursalMemoControllerTest {
    
    @testSetup
    public static void testSetup(){
        
        // For inserting Application
        Application__c applObj = new Application__c();
        applObj.Applicant_Name__c = 'Test';
        applObj.Branch__c = 'Test Branch';
        applObj.Loan_Purpose_1__c = 'Test Loan purpose 1';
        applObj.AC_Remarks__c = 'Testing Remarks';
        applObj.Loan_Purpose_2__c = 'Personal Use';
        applObj.Legal_Sanction_Condition__c = 'Testing Legal Sanction Condition';
        applObj.Borrower_s_Risk_Rating__c = 'Medium';
        applObj.LTV__c = 16.22;
        applObj.DBR__c = 17.01;
        applObj.Amount_Recommended__c = 100.00;
        applObj.BM_Recommended_Amount__c = 200.00;
        applObj.Requested_Loan_Amount__c = 220.00;
        insert applObj;
        
        // For inserting Account
        Account accObj = new Account();
        accObj.Name = 'Test account name';
        insert accObj;
        
        // For inserting Loan Applicant
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Customer_Type__c = 'Primary Applicant';
        loanAppObj.Applicant_Type__c = 'Property Holder';
        loanAppObj.Application__c = applObj.Id;
        loanAppObj.Customer_Information__c = accObj.Id;
        insert loanAppObj;
        
        // For getting Record Type Id
        Id RecordTypeIdVerification = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('AC').getRecordTypeId();
        
        // For inserting Verification
        Verification__c verObj = new Verification__c();
        verObj.DBR__c = 180.00;
        verObj.LTV__c = 22.40;
        verObj.Total_Income__c = 14000;
        verObj.BM_Recommended_Amount__c = 1200;
        verObj.RecordTypeId= RecordTypeIdVerification;
        verObj.Application__c = applObj.Id;
        insert verObj;
        
        // For inserting Record Type
        String RecordTypeIdProperty = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('PC Property Detail').getRecordTypeId();
        
        // For inserting Property
        Property__c propObj = new Property__c();
        propObj.Land_Area_Sq_Ft__c = 333.21;
        propObj.Building_Area_Sq_Ft__c = 231.11;
        propObj.Valuation_Market_Value_Per_SqFt__c = 12000;
        propObj.Building_Area_Sq_Ft__c  = 1244;
        propObj.Building_Value_per_Sq_ft__c = 17000;
        propObj.Living_property_Distance_from_Branch__c = 6;
        propObj.Mortgage_property_distance_from_branch__c = 11;
        propObj.Application__c = applObj.Id;
        propObj.RecordTypeId = RecordTypeIdProperty;
        insert propObj;
        
        // For inserting Capability
        Capability__c capObj = new Capability__c();
        capObj.Loan_Applicant__c = loanAppObj.Id;
        capObj.Nature_of_Job__c = 'Engineer';
        capObj.Income_segment__c = 'Eateries';
        capObj.Income_per_day__c = 600;
        capObj.Number_of_days__c = 14;
        capObj.Day_Margin_Basis__c = 'Day Basis';
        capObj.Electricity__c = 300;
        capObj.Salary__c = 320;
        capObj.Rent__c = 300;
        capObj.Others__c = 450;
        capObj.Verification__c = verObj.Id;
        insert capObj;
        
        
        // For inserting Bureau_Highmark__c
        Bureau_Highmark__c bh = new Bureau_Highmark__c();
        bh.Highmark_Score__c = '50';
        bh.Loan_Applicant__c = loanAppObj.Id;
        insert bh;  
        
        // For inserting Loan Details
        Loan_details__c loanObj = new Loan_details__c();
        loanObj.Obligations__c = 5;
        loanObj.To_be_considerd_for_DBR__c = 'Yes';
        loanObj.Bureau_Highmark__c = bh.id;
        insert loanObj;
        
    }
    
    @isTest
    public static void FS_DisbursalMemoControllerTestMethod1(){
        
        List<Application__c> appList = [Select Id, Name, Applicant_Name__c, Branch__c, Loan_Purpose_1__c,LTV_PCAC__c,DBR_PC_AC__c,AC_Remarks__c,
                                        Loan_Purpose_2__c , Legal_Sanction_Condition__c, Emi_PcAc__c,
                                        Borrower_s_Risk_Rating__c, LTV__c, DBR__c, Amount_Recommended__c,
                                        BM_Recommended_Amount__c, Requested_Loan_Amount__c, Total_Amount_Recommended_PcAc__c FROM Application__c];
        
        Test.StartTest(); 
        PageReference pageRef = Page.fs_disbursalMemo; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(appList[0].Id));
        Test.setCurrentPage(pageRef);
        FS_DisbursalMemoController controllerObj = new FS_DisbursalMemoController();
        FS_DisbursalMemoController.saveDisbursalMemoPDF(appList[0].Id, 'Process Credit');
        FS_DisbursalMemoController.checkDisbursalMemoPdf(appList[0].Id, 'Process Credit');
        Test.StopTest();
    }
    
    @isTest
    public static void FS_DisbursalMemoControllerTestMethod2(){
        
        List<Application__c> appList = [Select Id, Name, Applicant_Name__c, Branch__c, Loan_Purpose_1__c,LTV_PCAC__c,DBR_PC_AC__c,AC_Remarks__c,
                                        Loan_Purpose_2__c , Legal_Sanction_Condition__c, Emi_PcAc__c,
                                        Borrower_s_Risk_Rating__c, LTV__c, DBR__c, Amount_Recommended__c,
                                        BM_Recommended_Amount__c, Requested_Loan_Amount__c, Total_Amount_Recommended_PcAc__c FROM Application__c];
        
        String RecordTypeIdProperty = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        
        
        // For insert Property
        Property__c propObj = new Property__c();
        propObj.Land_Area_Sq_Ft__c = 333.21;
        propObj.Building_Area_Sq_Ft__c = 231.11;
        propObj.Valuation_Market_Value_Per_SqFt__c = 12000;
        propObj.Building_Area_Sq_Ft__c  = 1244;
        propObj.Building_Value_per_Sq_ft__c = 17000;
        propObj.Living_property_Distance_from_Branch__c = 6;
        propObj.Mortgage_property_distance_from_branch__c = 11;
        propObj.Application__c = appList[0].Id;
        System.debug('RecordTypeIdProperty '+ RecordTypeIdProperty);
        propObj.RecordTypeId = RecordTypeIdProperty;
        insert propObj;
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.fs_disbursalMemo; // Add your VF page Name here
        
        pageRef.getParameters().put('Id', String.valueOf(appList[0].Id));
        Test.setCurrentPage(pageRef);
        
        FS_DisbursalMemoController controllerObj = new FS_DisbursalMemoController();
        
        Test.StopTest();
        
        
        
        
    }
    
    @isTest
    public static void FS_DisbursalMemoControllerTestMethod3(){
        
        List<Application__c> appList = [Select Id, Name, Applicant_Name__c, Branch__c, Loan_Purpose_1__c,LTV_PCAC__c,DBR_PC_AC__c,AC_Remarks__c,
                                        Loan_Purpose_2__c , Legal_Sanction_Condition__c, Emi_PcAc__c,
                                        Borrower_s_Risk_Rating__c, LTV__c, DBR__c, Amount_Recommended__c,
                                        BM_Recommended_Amount__c, Requested_Loan_Amount__c, Total_Amount_Recommended_PcAc__c FROM Application__c];
        
        List<Loan_Applicant__c> loanApplicantList = [SELECT Id FROM Loan_Applicant__c];
        
        //Code for insert Bureau_Highmark__c
        Bureau_Highmark__c bh = new Bureau_Highmark__c();
        bh.Highmark_Score__c = '50';
        bh.Loan_Applicant__c = loanApplicantList[0].Id;
        insert bh;      
        
        String RecordTypeIdProperty = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-B Property Detail').getRecordTypeId();
        
        // For insert Property
        Property__c propObj = new Property__c();
        propObj.Land_Area_Sq_Ft__c = 333.21;
        propObj.Building_Area_Sq_Ft__c = 231.11;
        propObj.Valuation_Market_Value_Per_SqFt__c = 12000;
        propObj.Building_Area_Sq_Ft__c  = 1244;
        propObj.Building_Value_per_Sq_ft__c = 17000;
        propObj.Living_property_Distance_from_Branch__c = 6;
        propObj.Mortgage_property_distance_from_branch__c = 11;
        propObj.Application__c = appList[0].Id;
        
        propObj.RecordTypeId = RecordTypeIdProperty;
        insert propObj;
        
        
        
        Test.StartTest(); 
        
        PageReference pageRef = Page.fs_disbursalMemo; // Add your VF page Name here
        
        pageRef.getParameters().put('Id', String.valueOf(appList[0].Id));
        Test.setCurrentPage(pageRef);
        
        FS_DisbursalMemoController controllerObj = new FS_DisbursalMemoController();
        
        
        Test.StopTest();
        
        
        
    }
    
    @isTest
    public static void FS_DisbursalMemoControllerTestMethod4(){
        
        List<Application__c> appList = [Select Id, Name, Applicant_Name__c, Branch__c, Loan_Purpose_1__c,LTV_PCAC__c,DBR_PC_AC__c,AC_Remarks__c,
                                        Loan_Purpose_2__c , Legal_Sanction_Condition__c, Emi_PcAc__c,
                                        Borrower_s_Risk_Rating__c, LTV__c, DBR__c, Amount_Recommended__c,
                                        BM_Recommended_Amount__c, Requested_Loan_Amount__c, Total_Amount_Recommended_PcAc__c FROM Application__c ];
        
        appList[0].Loan_Purpose_2__c = 'Null';
        // For getting Record Type Id
        Id RecordTypeIdVerification = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        
        // For inserting Verification
        Verification__c verObj = new Verification__c();
        verObj.DBR__c = 180.00;
        verObj.LTV__c = 22.40;
        verObj.Total_Income__c = 14000;
        verObj.BM_Recommended_Amount__c = 1200;
        verObj.RecordTypeId= RecordTypeIdVerification;
        verObj.Application__c = appList[0].Id;
        insert verObj;
        
        Test.StartTest(); 
        PageReference pageRef = Page.fs_disbursalMemo; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(appList[0].Id));
        Test.setCurrentPage(pageRef);
        FS_DisbursalMemoController controllerObj = new FS_DisbursalMemoController();
        
        Test.StopTest();
    }
    
    @isTest
    public static void FS_DisbursalMemoControllerTestMethod5(){
        
        List<Application__c> appList = [Select Id, Name, Applicant_Name__c, Branch__c, Loan_Purpose_1__c,LTV_PCAC__c,DBR_PC_AC__c,AC_Remarks__c,
                                        Loan_Purpose_2__c , Legal_Sanction_Condition__c, Emi_PcAc__c,
                                        Borrower_s_Risk_Rating__c, LTV__c, DBR__c, Amount_Recommended__c,
                                        BM_Recommended_Amount__c, Requested_Loan_Amount__c, Total_Amount_Recommended_PcAc__c FROM Application__c ];
        
        appList[0].Loan_Purpose_2__c = Null;
        update appList;
        
        // For getting Record Type Id
        Id RecordTypeIdVerification = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - B').getRecordTypeId();
        
        // For inserting Verification
        Verification__c verObj = new Verification__c();
        verObj.DBR__c = 180.00;
        verObj.LTV__c = 22.40;
        verObj.Total_Income__c = 14000;
        verObj.BM_Recommended_Amount__c = 1200;
        verObj.RecordTypeId= RecordTypeIdVerification;
        verObj.Application__c = appList[0].Id;
        insert verObj;
        
        
        Test.StartTest(); 
        PageReference pageRef = Page.fs_disbursalMemo; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(appList[0].Id));
        Test.setCurrentPage(pageRef);
        FS_DisbursalMemoController controllerObj = new FS_DisbursalMemoController();
        
        Test.StopTest();
    }
    
    @isTest
    public static void FS_DisbursalMemoControllerTestMethod6(){
        
        List<Application__c> appList = [Select Id, Name, Applicant_Name__c, Branch__c, Loan_Purpose_1__c,LTV_PCAC__c,DBR_PC_AC__c,AC_Remarks__c,
                                        Loan_Purpose_2__c , Legal_Sanction_Condition__c, Emi_PcAc__c,
                                        Borrower_s_Risk_Rating__c, LTV__c, DBR__c, Amount_Recommended__c,
                                        BM_Recommended_Amount__c, Requested_Loan_Amount__c, Total_Amount_Recommended_PcAc__c FROM Application__c ];
        
        appList[0].Loan_Purpose_1__c = Null;
        update appList;
        
        
        Test.StartTest(); 
        PageReference pageRef = Page.fs_disbursalMemo; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(appList[0].Id));
        Test.setCurrentPage(pageRef);
        FS_DisbursalMemoController controllerObj = new FS_DisbursalMemoController();
        
        Test.StopTest();
    }   
}