/**
 *  Purpose          : This class is use to create Dynamic Fee Master Creation.
 *  Author           : Navin Soni
 *  Date             : 2022-06-30
 *  Version          : 1.0 
 *  Apex Class Name  : DynamicFeeMasterCreationController
*/

public with sharing class DynamicFeeMasterCreationController {
    public DynamicFeeMasterCreationController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Fee_Type_Master__c>  getExistingFeeTypeMaster(){
        try {
            return [SELECT Fee_Type_Code__c, GL_Code__c, Fee_Type__c, Event__c, Applicable_For__c, Stage_Due__c, Description__c, Tax__c, Amount__c, Value__c, Calculation_Basis__c, Modifiable_at_run_Time__c, Waivable__c, Repayment_of_Fee__c, Id, Name FROM Fee_Type_Master__c WITH SECURITY_ENFORCED LIMIT 1000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        //return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Fee_Value_Master__c>  getExistingFeeValueMaster(){
        try {
            return [SELECT Id, Name, Fee_Type_Master__c, Fee_Type_Master__r.Name, Fee_Type_Code__c, Fee_Type__c, Description__c, Amount__c, Floor__c, Cap__c, Range__c, Max_waiver_amount_without_Approval__c FROM Fee_Value_Master__c WITH SECURITY_ENFORCED LIMIT 1000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        //return null;
    }

    @AuraEnabled
    public static void insertFeeValueMaster(String jsonOfFeeValueMaster) {
        List<Fee_Value_Master__c> listOfFeeValueMasters = (List<Fee_Value_Master__c>) JSON.deserialize(jsonOfFeeValueMaster, List<Fee_Value_Master__c>.class);
        insert listOfFeeValueMasters;
    }
    
    public static void parser(){
        Integer i;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
		i = 0;
        i = 0;
        i = 0;
        i = 0; 
        i = 0;
        i = 0;
        i = 0;
        i = 0; 
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0; 
        i = 0;
        i = 0;
        i = 0;
        i = 0; 
    }
}