public with sharing class LwcLookupController {
    
    private static final Map<String,String> WHERE_CLAUSE_MAP = new Map<String,String>{
        'User'=>'IsActive',
            'User__x'=>'IsActive__c'
            };
                
                @AuraEnabled(cacheable=true)  
                public static List<sobject> getAllRecords(String objectName, String column, String keyFieldAPI, String selectedRecordId) {  
                    String query = 'SELECT ' + column + ',' + keyFieldAPI + ' FROM ' + objectName;
                    Set<Id> branchIds = new Set<Id>();
                    if(String.isNotBlank(objectName) && objectName.equalsIgnoreCase('Branch_Master__c')){
                        branchIds = FsDocumentDisptachCtrl.getBranchIdsFromBranchUserAllocation();
                    }
                    if(String.isNotBlank(selectedRecordId)){
                        query += ' WHERE Id =: selectedRecordId';                
                        if(branchIds != NULL && objectName.equalsIgnoreCase('Branch_Master__c')){
                            query += ' AND Id IN : branchIds';
                        } 
                    } else if(branchIds != NULL && objectName.equalsIgnoreCase('Branch_Master__c')){
                        query += ' WHERE Id IN : branchIds';
                    } 
                    if(WHERE_CLAUSE_MAP.containsKey(objectName)){
                        if(String.isNotBlank(selectedRecordId)){
                            query += ' AND ' + WHERE_CLAUSE_MAP.get(objectName) + ' = true';
                        } else if(branchIds != NULL && objectName.equalsIgnoreCase('Branch_Master__c')){
                            query += ' AND ' + WHERE_CLAUSE_MAP.get(objectName) + ' = true';
                        } else{
                            query += ' WHERE ' + WHERE_CLAUSE_MAP.get(objectName) + ' = true';
                        }
                    }
                    query += ' LIMIT 100';
                    return Database.query(String.escapeSingleQuotes(query));
                }
    
    @AuraEnabled(cacheable=true)  
    public static List<sobject> getFilterRecords(String objectName, String column, String keyFieldAPI, String searchKey) {  
        String searchText = '%'+searchKey+'%'; //NOSONAR
        String query;
        if(String.isNotBlank(objectName) && objectName.equalsIgnoreCase('User')){
            query = 'SELECT ' + column + ',' + keyFieldAPI + ' FROM ' + objectName + ' WHERE ('+ column +' LIKE : searchText OR EmployeeNumber LIKE : searchText)';
        } else if(String.isNotBlank(objectName) && objectName.equalsIgnoreCase('Branch_Master__c')){
            Set<Id> branchIds = new Set<Id>();
            branchIds = FsDocumentDisptachCtrl.getBranchIdsFromBranchUserAllocation();
            System.debug('branchIds= '+branchIds);
            if(branchIds != NULL){
                query = 'SELECT ' + column + ',' + keyFieldAPI + ' FROM ' + objectName + ' WHERE '+ column +' LIKE : searchText AND Id IN : branchIds';
            }
        } else{
            query = 'SELECT ' + column + ',' + keyFieldAPI + ' FROM ' + objectName + ' WHERE '+ column +' LIKE : searchText';
        }
        
        if(WHERE_CLAUSE_MAP.containsKey(objectName)){
            query += ' AND ' + WHERE_CLAUSE_MAP.get(objectName) + ' = true';
        }
        query += ' LIMIT 1000';
        System.debug('query = '+query);
        System.debug('query result= '+Database.query(String.escapeSingleQuotes(query)));
        return Database.query(String.escapeSingleQuotes(query));
    }
}