public with sharing class FeeCreationInsuranceType {
    public FeeCreationInsuranceType() {

    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getFeeCreationDataTable(String applicationId){ 
        System.debug('appId #### '+applicationId);
        /* fetch data from fee */ 
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Fee_Creation_Insurance_Type';  
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(applicationId);
       // String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
       // genericDTObj.IDS_SET.add(rcId);
       //genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET';
       genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
       System.debug('result >>>>> '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getFeeCreationDataIns(List<String> allLoanApplicant){
        System.debug('allLoanApplicant >>>> '+allLoanApplicant);
        /* fetch data from cashflow */ 
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Fee_Creation_Insurance_Type';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE=' Application__c IN : IDS_SET';
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getAllFeeMeta(String applicationId){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Fee_Creation_Insurance_Type';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(applicationId);
        genericDTObj.WHERE_CLAUSE='Id IN : IDS_SET';
        return genericDTObj.getTable(); 
    }
}