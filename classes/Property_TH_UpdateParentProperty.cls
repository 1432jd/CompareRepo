public without sharing class Property_TH_UpdateParentProperty extends AbstractTriggerContext{
	public override void afterUpdate(List<sobject> newList, List<sobject> oldList, Map<Id,sObject> newMap, Map<Id,sObject> oldMap){
       updateParentProperties((List<Property__c>)newList);
    }
    
    public static void updateParentProperties(List<Property__c> newList){
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Property__c']);
        List<Property__c> selectedProperties = new List<Property__c>();
        Set<Id> applicationIds = new Set<Id>(); 
        for(Property__c propertyObj : newList){
            applicationIds.add(propertyObj.application__c);
        }
        Map<Id,Application__c> applicationMap = new Map<Id,Application__c>([SELECT Id,Created_From_Batch__c FROM Application__c WHERE Id IN : applicationIds]);
        for(Property__c propertyObj : newList){
            Boolean isCreatedFromBatch = false;
            if(applicationMap != NULL && applicationMap.containsKey(propertyObj.application__c)){
                isCreatedFromBatch = applicationMap.get(propertyObj.application__c).Created_From_Batch__c;
            }
            
            if(!isCreatedFromBatch && propertyObj.Property__c != NULL && recordTypeMap.get(propertyObj.RecordTypeId).Name != 'Pre Login Property Detail'){
                selectedProperties.add(propertyObj);
            }
        }

        if(!selectedProperties.isEmpty()){
            Map<Id, Property__c> propertyMapToUpdate = new Map<Id, Property__c>();
            for(Property__c propertyObj : selectedProperties){
                String rcName = recordTypeMap.get(propertyObj.RecordTypeId).DeveloperName;
                Schema.FieldSet fieldSet = Schema.SObjectType.Property__c.fieldSets.getMap().get(rcName);
                if(fieldSet != NULL){
                    Property__c parentProperty = new Property__c();
                    if(propertyObj.Property__c != NULL && propertyMapToUpdate.containsKey(propertyObj.Property__c)){
                        parentProperty = propertyMapToUpdate.get(propertyObj.Property__c);
                    }else{
                        parentProperty = new Property__c(Id = propertyObj.Property__c);                        
                    }
                    for(Schema.FieldSetMember field : fieldSet.getFields()) {
                        String fieldName = field.getFieldPath();                        
                        if(propertyObj.get(fieldName) != NULL && propertyObj.get(fieldName) != ''){
                            parentProperty.put(fieldName, propertyObj.get(fieldName));
                        }
                    }
                    propertyMapToUpdate.put(propertyObj.Property__c, parentProperty);
                }
            }

            if(!propertyMapToUpdate.isEmpty()){
                update propertyMapToUpdate.values();
            }
        }
    }
}