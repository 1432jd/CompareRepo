public class FsOnlineECController extends GenericDataTableController {
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCollateralDetails(String applicationId){      
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Online_EC_collateral';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(applicationId);
        String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Online EC Property Detail').getRecordTypeId();
        genericDTObj.IDS_SET.add(rcId); 
        genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId =: IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable();
    }
    
    
     @AuraEnabled
    public static GenericDataTableController.DataTableResponse getAllApplicantMeta(String applicationId){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'FS_All_Applicant';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(applicationId);
        genericDTObj.WHERE_CLAUSE='Application__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() #### '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    
    @AuraEnabled
    public static String getVerification(String recordId){
        System.debug('record id'+recordId);
        List<Verification__c> listOfVerification= [SELECT Id, Status__c, RecordType.Name FROM Verification__c WHERE Id =: recordId AND RecordType.Name = 'Online EC'];
        System.debug('listOfVerification'+listOfVerification);
        return listOfVerification[0].Status__c;
    }
  
    @AuraEnabled
    public static boolean getDocs(String applicationId){
        list<id> lstConDocs = new list<id>();
        System.debug('appId= '+applicationId);
        if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId)){
            for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =: applicationId]) {
                lstConDocs.add(cntLink.ContentDocumentId);    
            } 
            System.debug(lstConDocs.size());
            if(!lstConDocs.isEmpty()) {
                List<ContentVersion> lstCV = [SELECT Id, Uploaded_From__c, ContentDocumentId    
                                              FROM ContentVersion WHERE ContentDocumentId IN :lstConDocs And Uploaded_From__c='Online EC' ];
                System.debug('lstCV= '+lstCV);  
                    if(lstCV.size()> 0){
                        return true; 
                      }   
                    return false;  
            }             
        }return false;
        
    }
   
   
}