public class FS_BuildingFloorController {
	@AuraEnabled
    public static List<CommonObject__c> getBuildingFloorRecords(String propertyId){
        return [SELECT 
                Id, Application__c, Object_Type__c, Property__c, Building_Floor__c, Length_ft__c, 
                Width_ft__c, Area_Extent_Sq_ft__c, Value_per_Sq_ft__c ,Total_Value__c 
                FROM CommonObject__c 
                WHERE Property__c =:propertyId 
                AND Object_Type__c = 'Building Floors'];
    }

    @AuraEnabled
    public static string saveBuildingRecords(String jsonData){
        try {
            List<CommonObject__c> buldingValues = new List<CommonObject__c>();
            buldingValues =  (List<CommonObject__c>) System.JSON.deserialize(jsonData, List<CommonObject__c>.class);
            upsert buldingValues;
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteBuildingRecord(String recordToDelete){
        try {
            CommonObject__c buldingValueToDelete = new CommonObject__c(Id=recordToDelete);
            delete buldingValueToDelete;
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteRelatedFloors(String propertyId){
        try {
            List<CommonObject__c> buldingValues = new List<CommonObject__c>();
            buldingValues = [SELECT 
                            Id
                            FROM CommonObject__c 
                            WHERE Property__c =:propertyId 
                            AND Object_Type__c = 'Building Floors'];
            if(buldingValues != NULL && !buldingValues.isEmpty()){
                delete buldingValues;
            }                        

            List<Property__c> property = new List<Property__c>();
            property = [SELECT 
                        Id, Total_Floor_Area__c, Avg_Floor_Value_Per_Sq_Ft__c, Total_Floor_Value__c,
                        Building_Age__c, Building_Type__c, Building_Constructed_with_Remarks__c 
                        FROM Property__c 
                        WHERE Id =: propertyId LIMIT 1];
            if(property != NULL && !property.isEmpty()){
                property[0].Total_Floor_Area__c = 0;
                property[0].Avg_Floor_Value_Per_Sq_Ft__c = 0;
                property[0].Total_Floor_Value__c = 0;
                property[0].Building_Age__c = null;
                property[0].Building_Type__c = '';
                property[0].Building_Constructed_with_Remarks__c = '';

                update property;
            }  
            return 'success';    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}