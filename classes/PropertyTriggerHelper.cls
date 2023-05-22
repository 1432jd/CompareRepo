public class PropertyTriggerHelper extends AbstractTriggerContext{
    
    public override void afterInsert(List<sobject> newList, Map<Id,sObject> newMap){
        System.debug('PropertyTriggerHelper');
        addFeeForProperty((List<Property__c>)newList);
    }
    
    public static void addFeeForProperty(List<Property__c> propList){
        Map<String, List<Property__c>> mapOfProperty = new Map<String, List<Property__c>>();
        // To create Fee for Asset in respective application
        
        Set<String> applicationIds = new Set<String>();
        for(Property__c objPro : propList){
            if(objPro.Application__c != null){
                applicationIds.add(objPro.Application__c);
            }
        }

        if(!applicationIds.isEmpty()){
            Map<Id,Application__c> applicationMap;
            applicationMap = new Map<Id,Application__c>([SELECT Id, Created_From_Batch__c FROM Application__c WHERE Id IN : applicationIds]);

            for(Property__c objPro : propList){
                if(objPro.Application__c != null && applicationMap.containsKey(objPro.Application__c) && !applicationMap.get(objPro.Application__c).Created_From_Batch__c && objPro.Record_Type_Name__c == 'Pre_Login_Property_Detail'){
                    if(mapOfProperty != null && mapOfProperty.containsKey(objPro.Application__c)){
                        List<Property__c> listOfProperty = mapOfProperty.get(objPro.Application__c);                        
                        listOfProperty.add(objPro);
                        mapOfProperty.put(objPro.Application__c, listOfProperty);
                    }else{
                        mapOfProperty.put(objPro.Application__c, new List<Property__c>{objPro});
                    }
                }
            }
        }        

        if(mapOfProperty != null && mapOfProperty.size() > 0){
            for(String applicationid : mapOfProperty.keySet()){
                System.debug('RecordType.name = Pre Login Property Detail' + mapOfProperty.get(applicationid));
                FeeCreationComponentHelper.createFeeCreationRecords (applicationid, 'Asset Entry', mapOfProperty.get(applicationid));
            }
        }
    }

}