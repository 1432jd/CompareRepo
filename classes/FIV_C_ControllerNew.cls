public without sharing class FIV_C_ControllerNew extends GenericFormBuilderController{
    
    @AuraEnabled
    public static GenericFormBuilderController.InitWrapper getSectionContent(String recordIds, String metaDetaName){
        FIV_C_ControllerNew obj = new FIV_C_ControllerNew();
        obj.METADATA_NAME = metaDetaName;
        obj.IDS_SET = new Set<String>();
        if(String.isNotEmpty(recordIds)){
            obj.IDS_SET = new Set<String>();
            obj.IDS_SET.addAll(recordIds.split('_'));
            obj.WHERE_CLAUSE = ' Id IN : IDS_SET';
            obj.RECORD_LIMIT = '1';    
        }
        return obj.initialize();//getSectionContent();
    }  

    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCharacterTabRecords(String appId, String metadataName ,String sectionName){
        String rcId = Schema.getGlobalDescribe().get('Character__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = metadataName;
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(appId);
        genericDTObj.IDS_SET.add(rcId);
        genericDTObj.IDS_SET.add(sectionName);
        genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET AND Section_Type__c IN : IDS_SET';
        return genericDTObj.getTable();
    }

    @AuraEnabled
    public static String saveRecord(sobject dataToInsert){
        try{
            system.debug(':::dataToInsert:::' + dataToInsert);
            upsert dataToInsert;
            return 'success';
        } catch(Exception ex){
        	System.debug('exception ::: '+ex);
            return JSON.serialize(ex);
        }
    }
}