/**
* @File Name          : DynamicFeeMasterCreationControllerTest.cls
* @Description        : Service Class For DynamicFeeMasterCreationController
* @Author             : Mo Arslan
* @Created On         : 12/09/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         12/09/2022               Mo Arslan               Initial Version
*/
@IsTest
public class DynamicFeeMasterCreationControllerTest {
    @TestSetup
    public static void testSetup(){
        Fee_Type_Master__c fee_type_masterObj = new Fee_Type_Master__c(
            Name = 'Cersai',
         //   Fee_Type_Code__c = 'Cersai',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Application Login',
            Applicable_For__c = 'Application',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Inclusive',
            Amount__c = 'Amount',
            Value__c = 'Asset Cost',
            Calculation_Basis__c = 'Range (Floor + Cap)',
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
            Active__c = 'Yes');
        insert fee_type_masterObj;
        
        Fee_Value_Master__c fee_value_masterObj = new Fee_Value_Master__c(
            Description__c = 'test',
            Amount__c = 66,
            Floor__c = 8,
            Cap__c = 9,
            Max_waiver_amount_without_Approval__c = 87,
            Fee_Type_Master__c = fee_type_masterObj.Id,
            Range__c = '45');
        insert fee_value_masterObj;
    }
    
    @IsTest
    public static void test(){
        
        Fee_Type_Master__c fee_type_masterObj = new Fee_Type_Master__c(
            Name = 'Cersai',
         //   Fee_Type_Code__c = 'Cersai',
            GL_Code__c = '001',
            Fee_Type__c = 'System',
            Event__c = 'Application Login',
            Applicable_For__c = 'Application',
            Stage_Due__c = 'Pre Login',
            Description__c = 'Test Description',
            Tax__c = 'Inclusive',
            Amount__c = 'Amount',
            Value__c = 'Asset Cost',
            Calculation_Basis__c = 'Range (Floor + Cap)',
            Modifiable_at_run_Time__c = 'Yes',
            Waivable__c = 'Yes',
            Repayment_of_Fee__c = 'Direct Receipt;Deduct from Disbursement',
            Type__c = 'Fee',
            Active__c = 'Yes');
        insert fee_type_masterObj;
        
        Fee_Value_Master__c fee_value_masterObj = new Fee_Value_Master__c(
            Description__c = 'test',
            Amount__c = 66,
            Floor__c = 8,
            Cap__c = 9,
            Max_waiver_amount_without_Approval__c = 87,
            Fee_Type_Master__c = fee_type_masterObj.Id,
            Range__c = '45');
        
        List<Fee_Value_Master__c> feeValueList = new List<Fee_Value_Master__c>();
        feeValueList.add(fee_value_masterObj);
        
        Test.startTest();
        DynamicFeeMasterCreationController obj = new DynamicFeeMasterCreationController();
        DynamicFeeMasterCreationController.getExistingFeeTypeMaster();
        DynamicFeeMasterCreationController.getExistingFeeValueMaster();
        DynamicFeeMasterCreationController.insertFeeValueMaster(JSON.serialize(feeValueList));
        DynamicFeeMasterCreationController.parser();
        Test.stopTest();
    }
}