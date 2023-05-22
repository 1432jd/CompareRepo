public class FsDocumentDefferal extends GenericFormBuilderController {
 @AuraEnabled
    public static GenericFormBuilderController.InitWrapper getSectionContent(String recordIds, String metaDetaName){
        FsDocumentDefferal obj = new FsDocumentDefferal();
        obj.METADATA_NAME = metaDetaName;
        obj.IDS_SET = new Set<String>();
        if(String.isNotEmpty(recordIds)){
            obj.IDS_SET = new Set<String>();
            obj.IDS_SET.addAll(recordIds.split('_'));
                obj.WHERE_CLAUSE = ' Id IN : IDS_SET';
            obj.RECORD_LIMIT = '1';    
        }
        return obj.initialize();
    }  
    
    @AuraEnabled
    public static String saveRecord(sobject dataToInsert){
        try{
            system.debug(':::dataToInsert:::' + dataToInsert);
            upsert dataToInsert;
          
        } catch(Exception ex){
        	System.debug('exception ::: '+ex);
            return JSON.serialize(ex);
        }
        return 'Data Saved Successfully.';
    }
}