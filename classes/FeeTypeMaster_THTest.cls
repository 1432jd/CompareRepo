/**
* @Class Name         : FeeTypeMaster_THTest.apxc
* @Description        : Test Class for FeeTypeMaster_TH 

* @Author             : Sangeeta Yadv
* @Created On         : 23/01/2023
*========================================================================================
* Ver         Date                     Author                       Modification
*========================================================================================
* 1.0      23/01/2023               Sangeeta Yadav                  Initial Version
**/
@IsTest
public class FeeTypeMaster_THTest {
	@TestSetup
    public static void testSetup(){
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
        insert feeMasterList;
    }
    
    @IsTest
    public static void deleteFeeTypeMaster(){
        List<Fee_Type_Master__C> feeMasterCode = [SELECT Id, Fee_Type_Code__c,Applicable_For__c FROM Fee_Type_Master__c];
        //delete feeMasterCode[0];
        List<Fee_Type_Master__C> feeTypeMasterId = new List<Fee_Type_Master__C>();
        Map<Id,Fee_Type_Master__C> feeTypeMasterMap = new Map<Id,Fee_Type_Master__C>();
        for(Fee_Type_Master__C feeType: feeMasterCode){
            feeTypeMasterId.add(feeType);
            feeTypeMasterMap.put(feeType.Id, feeType);
        }
        FeeTypeMaster_TH.showErrorForDelete(feeMasterCode);
        FeeTypeMaster_TH feeMaster = new FeeTypeMaster_TH();
        feeMaster.beforeDelete(feeTypeMasterId, feeTypeMasterMap);
    }
}