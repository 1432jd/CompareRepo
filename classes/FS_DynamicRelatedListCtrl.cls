public without sharing class FS_DynamicRelatedListCtrl extends GenericDataTableController {
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse returnRelatedRecords(String applicationId, String metadataName, String query, String queryParameters){
        System.debug('applicationId=  '+applicationId);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = metadataName; 
        genericDTObj.IDS_SET = new Set<String>();

        if(String.isNotBlank(queryParameters)){
            genericDTObj.IDS_SET.addAll(queryParameters.split(';'));
        }
        genericDTObj.IDS_SET.add(applicationId);
        // genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET';
        System.debug('IDS_SET is = '+genericDTObj.IDS_SET);
        System.debug('Query is = '+query);
        genericDTObj.WHERE_CLAUSE = query;
        return genericDTObj.getTable();     
    }
}