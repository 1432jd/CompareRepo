/**
* @File Name          : GenericUtility.cls
* @Description        : GenericUtility Class
* @Author             : Ajay Kumar
* @Created On         : 22/06/2022
* @Modified On        : 10/11/2022 - Parag Goyal
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        22/06/2022              Ajay Kumar             Initial Version
*                                                           Created One method for Generic Deletion
*            10/11/2022				 Parag Goyal            Added code to update application nach parties on applicant deletion.
*/

public class GenericUtility {
    @AuraEnabled
    public static String deleteSelectedRecord(String deletedFrom, String recordId, String objApiName){
        System.debug('delete callled'+deletedFrom+' :::: '+recordId+'  ::::: '+objApiName);
        Map<String,String> mapOfRecordIdAppId = new Map<String,String>(); // To store all recId with AppId
        List<Id> recordsToDelete = new List<Id>();
        if(deletedFrom != null && recordId != null && objApiName !=null){ 
            if(objApiName == 'Loan_Applicant__c'){
                Loan_Applicant__c la = [SELECT Id,Application__c,Application__r.NACH_Party_1_ID__c, Application__r.NACH_Party_2_ID__c
                                        FROM Loan_Applicant__c 
                                        WHERE Id = :recordId];
                mapOfRecordIdAppId.put(la.Id,la.Application__c);
                if(String.isNotBlank(la.Application__r.NACH_Party_1_ID__c) && String.isNotBlank(la.Application__r.NACH_Party_2_ID__c)){
                    Application__c app = new Application__c();
                    app.Id = la.Application__c;
                    if(String.isNotBlank(la.Application__r.NACH_Party_1_ID__c) && la.Application__r.NACH_Party_1_ID__c == la.Id){
                        app.NACH_Party_1_ID__c = null;
                        app.Nach_Party__c = null;
                        UPDATE app;
                    }
                    else if(String.isNotBlank(la.Application__r.NACH_Party_2_ID__c) && la.Application__r.NACH_Party_2_ID__c == la.Id){
                        app.NACH_Party_2_ID__c = null;
                        app.Nach_Party_2__c = null;
                        UPDATE app;
                    }     
                }
            }
            if(objApiName == 'Property__c'){
                Property__c objProp = [SELECT Id,Application__c,RecordType.Name From Property__c Where Id=:recordId ];
                if(objProp.RecordType.Name == 'Pre Login Property Detail')
                    mapOfRecordIdAppId.put(objProp.Id,objProp.Application__c);
            }
            if(deletedFrom=='Prelogin'){  
                if(objApiName=='Property__c'){   
                    recordsToDelete.add(recordId);
                    for(Property__c proObj : [SELECT Id FROM Property__c WHERE Property__c=:recordId]){ 
                        recordsToDelete.add(proObj.Id);
                    }  
                    for(Property_Owners__c proOwn : [SELECT Id FROM Property_Owners__c WHERE Property__c=:recordId]){
                        recordsToDelete.add(proOwn.Id);
                    }
                }
                else {  
                    recordsToDelete.add(recordId);  
                }
            }
            else if(deletedFrom=='Process Credit'){
                if(objApiName=='Character__c' || objApiName == 'Capability__c'){
                    recordsToDelete.add(recordId);
                    String mQuery = 'SELECT Id FROM '+objApiName+' WHERE PC_Record_Id__c=:recordId';
                    List<sObject> listofIds = Database.Query(mQuery);
                    if(listofIds != null && listofIds.size()>0){ 
                        for(sObject sobj :listofIds ){ 
                            recordsToDelete.add(sobj.Id); 
                        }
                    }
                }
            }
            else{  
                recordsToDelete.add(recordId);
            }
            system.debug('property List>>>> '+recordsToDelete);
        }
        Database.DeleteResult[] drList;
        if(recordsToDelete.size()>0){  
            drList = Database.delete(recordsToDelete, false);
        }
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + dr.getId());
                if(mapOfRecordIdAppId.containsKey(dr.getId()))
                    FS_DocumentUploadController.refreshRecords(mapOfRecordIdAppId.get(dr.getId()));
                return 'success';
            }
            else {     // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                    return 'error';
                } 
            }
        }
        return null;
    }
}