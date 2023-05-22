/**
* @Class Name         : FeeValueMaster_THTest.apxc
* @Description        : Test Class for FeeValueMaster_TH 

* @Author             : Sangeeta Yadv
* @Created On         : 23/01/2023
*========================================================================================
* Ver         Date                     Author                       Modification
*========================================================================================
* 1.0      23/01/2023               Sangeeta Yadav                  Initial Version
**/
@IsTest
public class FeeValueMaster_THTest {
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
        
        insert feeValueList;
    }
    
    @IsTest
    public static void deleteFeeTypeMaster(){
        List<Fee_Type_Master__C> feeMasterCode = [SELECT Id, Fee_Type_Code__c,Applicable_For__c FROM Fee_Type_Master__c];
        List<Fee_Value_Master__c> feeValue = [SELECT Id, Name, Fee_Type_Code__c, Amount__c, Cap__c, Floor__c, Amount_Flat__c,
                                                        Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,Fee_Type_Master__r.Fee_Type__c,
                                                        Fee_Type_Master__r.Tax__c,Fee_Type_Master__r.Value__c,Fee_Type_Master__r.Type__c,Fee_Type_Master__r.Event__c,Fee_Type_Master__r.Applicable_For__c  
                                                        FROM Fee_Value_Master__c ];
        //delete feeMasterCode[0];
        System.debug('feeValue in test'+feeValue);
        List<Fee_Value_Master__c> feeTypeMasterId = new List<Fee_Value_Master__c>();
        Map<Id,Fee_Value_Master__c> feeTypeMasterMap = new Map<Id,Fee_Value_Master__c>();
        for(Fee_Value_Master__c feeType: feeValue){
            feeTypeMasterId.add(feeType);
            feeTypeMasterMap.put(feeType.Id, feeType);
        }
        FeeValueMaster_TH.showErrorForDelete(feeValue);
        FeeValueMaster_TH feeMaster = new FeeValueMaster_TH();
        feeMaster.beforeDelete(feeTypeMasterId, feeTypeMasterMap);
    }

}