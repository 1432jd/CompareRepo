public class ContentVerisonTriggerHandler extends AbstractTriggerContext{
    
    public override void afterInsert(List<sobject> newList, Map<Id,sObject> newMap){
        createDocumentLink((List<ContentVersion>)newList);
    }
    
    public static void createDocumentLink(List<ContentVersion> newList){
        Set<String> cvIds = new Set<String>();
        for(ContentVersion cv : newList){
            cvIds.add(cv.Id);
        }
        
        Map<String, String> cvIdWithCdIdMap = new Map<String, String>();
        for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id In :cvIds]){
            cvIdWithCdIdMap.put(cv.Id, cv.ContentDocumentId);
        }
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(ContentVersion cv : newList){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = UserInfo.getOrganizationId();
            cdl.ContentDocumentId = cvIdWithCdIdMap.get(cv.Id);
            cdl.ShareType = 'V';
            cdlList.add(cdl);
        }
        
        if(!cdlList.isEmpty()){
            INSERT cdlList;
        }
    }
}