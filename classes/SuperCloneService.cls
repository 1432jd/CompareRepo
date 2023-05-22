public class SuperCloneService {
    public static List<SObject> doClone(String recordId, String objectApiName, Boolean hasRecordType){
        //objectApiName = 'Application__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiName).getDescribe().fields.getMap();
        List<String> objectFields = new List<String>();
		objectFields.add('Name');
        if(hasRecordType){
        	objectFields.add('RecordTypeId');
        }
        for(String fieldName : fieldMap.keyset()){
            if(fieldName.contains('__c')){
                objectFields.add(fieldName);    
            }
        }
        String query = 'SELECT ' + String.join(objectFields, ',') + ' FROM ' + objectAPIName + ' WHERE Id = \'' + recordId + '\'';
        System.debug('query ### '+query);
        return Database.query(query);
    }
}