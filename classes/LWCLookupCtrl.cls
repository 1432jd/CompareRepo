public without sharing class LWCLookupCtrl {
    @AuraEnabled
    public static List<LookupSearchResult> searchLookupRecords(String searchTerm, List<String> selectedIds,String sObjectName, String field, String subField,Integer maxResults, String criteria, String applicationId) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Set<String> userIds = new Set<String>();
        String branch;
        String userType;
        try{
            System.debug('searchTerm '+searchTerm+' '+'sObjectName '+sObjectName+' '+'field '+field);        
            String strQuery = 'SELECT Id, '+field + (String.isNotBlank(subField) ? ' ,'+subField : '')+' FROM '+sObjectName;
            
            String rcName = '';
            if(criteria == 'Account-CourierAgency'){
                rcName = 'Courier Agency';            
                strQuery += ' WHERE '+field+' LIKE \'' + searchTerm + '%\' AND RecordType.Name =: rcName ';  
            } 
            else if(criteria == 'Account-Broker'){
                rcName = 'Broker'; 
                strQuery += ' WHERE '+field+' LIKE \'' + searchTerm + '%\' AND RecordType.Name =: rcName '; 
            }
            else if(criteria == 'NAME_EMP'){
                List<Application__c> appList = new List<Application__c>();
                if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId)){
                    appList = [SELECT Id,Sourcing_Branch__c,Sourcing_Branch__r.Master_Branch__c FROM Application__c WHERE Id = :applicationId];
                }                
                System.debug('appList = '+appList);
                if(!appList.isEmpty() && appList.get(0).Sourcing_Branch__c != NULL){
                    branch = appList[0].Sourcing_Branch__c;
                }
                userType='Fo';
                strQuery += ' WHERE ('+field+' LIKE \'%' + searchTerm + '%\' OR '+subField+' LIKE \'%' + searchTerm + '%\') AND Final_Dept__c =:userType';   
                if(String.isNotBlank(branch)){
                    strQuery += ' AND Branch_Name__c =:branch';
                }
            }
            else if(criteria == 'SUP_EMP'){
                List<Application__c> appList = new List<Application__c>();
                if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId)){
                    appList = [SELECT Id,Sourcing_Branch__c,Sourcing_Branch__r.Master_Branch__c FROM Application__c WHERE Id = :applicationId];
                }                
                userType='BSup';
                System.debug('appList = '+appList);
                if(!appList.isEmpty() && appList.get(0).Sourcing_Branch__c != NULL && appList.get(0).Sourcing_Branch__r.Master_Branch__c != NULL){
                    branch = appList[0].Sourcing_Branch__r.Master_Branch__c;
                    strQuery += ' WHERE ('+field+' LIKE \'%' + searchTerm + '%\' OR '+subField+' LIKE \'%' + searchTerm + '%\') AND Branch_Name__r.Master_Branch__c =:branch AND Final_Dept__c =:userType';   
                } else if(!appList.isEmpty() && appList.get(0).Sourcing_Branch__c != NULL){
                    strQuery += ' WHERE ('+field+' LIKE \'%' + searchTerm + '%\' OR '+subField+' LIKE \'%' + searchTerm + '%\') AND Branch_Name__c =:branch AND Final_Dept__c =:userType';   
                    branch = appList[0].Sourcing_Branch__c;
                }                                
            }
            else if(criteria != NULL && criteria.contains('NAME_DM')){
                String str = criteria;
                List<String> res = str.split('/');
                System.debug('res of split is >>>'+res);
                String branchId = res[1];
                System.debug('branchId of split is >>>'+branchId);
                List<Access_Branch_Allocation__c> acb = new List<Access_Branch_Allocation__c>();
                acb = [SELECT Id, Access_Master__r.User__c FROM Access_Branch_Allocation__c WHERE Access_Master__r.Access_For__c = 'Disbursal Author' AND Branch_Master__c =: branchId];
                //Set<String> userIds = new Set<String>();
                System.debug('acb is >>>'+acb);
                for(Access_Branch_Allocation__c acObj : acb){
                    userIds.add(acObj.Access_Master__r.User__c);
                }
                System.debug('userIds of split is >>>'+userIds);
                strQuery += ' WHERE ('+field+' LIKE \'%' + searchTerm + '%\' OR '+subField+' LIKE \'%' + searchTerm + '%\') AND Id IN :userIds ';   
                System.debug('strQuery n>>>>'+strQuery);
            }else if(criteria != NULL && criteria.contains('NAME_DC')){
                String str = criteria;
                List<String> res = str.split('/');
                System.debug('res of split is >>>'+res);
                String branchId = res[1];
                System.debug('branchId of split is >>>'+branchId);
                List<Access_Branch_Allocation__c> acb = new List<Access_Branch_Allocation__c>();
                acb = [SELECT Id, Access_Master__r.User__c FROM Access_Branch_Allocation__c WHERE Access_Master__r.Access_For__c = 'VDC Checker' AND Branch_Master__c =: branchId];
                //Set<String> userIds = new Set<String>();
                System.debug('acb is >>>'+acb);
                for(Access_Branch_Allocation__c acObj : acb){
                    userIds.add(acObj.Access_Master__r.User__c);
                }
                System.debug('userIds of split is >>>'+userIds);
                strQuery += ' WHERE ('+field+' LIKE \'%' + searchTerm + '%\' OR '+subField+' LIKE \'%' + searchTerm + '%\') AND Id IN :userIds ';   
                System.debug('strQuery n>>>>'+strQuery);
            }else if(criteria != NULL && criteria.contains('DocMaker')){
                String str = criteria;
                List<User> acb = new List<User>();
                acb = [select Id,Name from User where Id =:UserInfo.getUserId()];
                //Set<String> userIds = new Set<String>();
                System.debug('acb is >>>'+acb);
                for(User acObj : acb){
                    userIds.add(acObj.Id);
                }
                System.debug('userIds of split is >>>'+userIds);
                strQuery += ' WHERE ('+field+' LIKE \'%' + searchTerm + '%\' OR '+subField+' LIKE \'%' + searchTerm + '%\') AND Id IN :userIds ';   
                System.debug('strQuery n>>>>'+strQuery);
            } 
            else if(criteria != NULL && criteria.contains('FIVC-User')){
                
                /*List<Access_Master__c> accesses = [SELECT Id, User__c FROM Access_Master__c WHERE Access_For__c = 'FIV - C'];
                for(Access_Master__c accessObj : accesses){
                    userIds.add(accessObj.User__c);
                }*/
                String stageUser = 'FIV - C';
                String query = 'SELECT Id, Access_Master__r.User__c FROM Access_Branch_Allocation__c WHERE Access_Master__r.Access_For__c = :stageUser';
                List<Application__c> appList = new List<Application__c>();
                List<Access_Branch_Allocation__c> acb = new List<Access_Branch_Allocation__c>();
                if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId)){
                    appList = [SELECT Id,Sourcing_Branch__c,Sourcing_Branch__r.Master_Branch__c FROM Application__c WHERE Id = :applicationId];
                }
                System.debug('appList = '+appList);
                if(!appList.isEmpty() && appList.get(0).Sourcing_Branch__r.Master_Branch__c != NULL){
                    branch = appList[0].Sourcing_Branch__r.Master_Branch__c;
                    query += ' AND Branch_Master__r.Master_Branch__c = :branch';
                } else if(!appList.isEmpty() && appList.get(0).Sourcing_Branch__c != NULL){
                    branch = appList[0].Sourcing_Branch__c;
                    query += ' AND Branch_Master__c = :branch';
                }
                System.debug('query '+query);
                acb = Database.query(query);
                for(Access_Branch_Allocation__c acObj : acb){
                    userIds.add(acObj.Access_Master__r.User__c);
                }
                System.debug('userIds of split is >>> '+userIds);
                strQuery += ' WHERE ('+field+' LIKE \'%' + searchTerm + '%\' OR '+subField+' LIKE \'%' + searchTerm + '%\') AND Id IN :userIds ';  
            } 
            else {
                strQuery += ' WHERE '+field+' LIKE \'%' + searchTerm + '%\' ';  
            }
            System.debug('rcName= '+rcName);
            System.debug('selectedIds= '+selectedIds);
            
            if(selectedIds!=NULL && !selectedIds.isEmpty()){
                strQuery += 'AND Id NOT IN :selectedIds ORDER BY '+field+' LIMIT :maxResults';
            } else {
                strQuery += ' ORDER BY '+field+' LIMIT :maxResults';
            }
            System.debug('strQuery '+strQuery);
            System.debug('QUERY RUN= '+Database.query(strQuery));
            List<sObject> searchResults = Database.query(strQuery);   
            System.debug('searchResults '+searchResults);
            if(searchResults != NUll && !searchResults.isEmpty()){
                for(sObject sObj : searchResults){
                    LookupSearchResult res = new LookupSearchResult();
                    res.Id = sObj.Id;
                    res.title = String.valueOf(sObj.get(field));
                    if(String.isNotBlank(subField) && sObj.get(subField) != NULL){
                        res.subtitle = String.valueOf(sObj.get(subField));
                    }else{
                        res.subtitle = sObjectName;
                    }
                    results.add(res);
                } 
            }
            System.debug('results '+results);
            
        }
        catch(Exception exe){
            System.debug('Exception Occurs '+exe.getLineNumber()+' :: '+exe.getMessage());
        }
        return results;  
    }
    
    @AuraEnabled
    public static LookupSearchResult getSelectedRecord(String sObjectName, String field, String subField,Integer maxResults, String selectedRecordId) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String strQuery = 'SELECT Id, '+field + (String.isNotBlank(subField) ? ' ,'+subField : '')+' FROM '+sObjectName;
        strQuery += ' WHERE Id =:selectedRecordId ORDER BY '+field+' LIMIT :maxResults'; 
        List<sObject> searchResults = Database.query(strQuery);   
        if(searchResults != NUll && !searchResults.isEmpty()){
            for(sObject sObj : searchResults){
                LookupSearchResult res = new LookupSearchResult();
                res.Id = sObj.Id;
                res.title = String.valueOf(sObj.get(field));
                if(String.isNotBlank(subField) && sObj.get(subField) != NULL){
                    res.subtitle = String.valueOf(sObj.get(subField));
                }else{
                    res.subtitle = sObjectName;
                }
                results.add(res);
            } 
        }
        return results.get(0);        
    }
    
    @AuraEnabled
    public static LookupSearchResult getRecentlyCreatedRecord(String sObjectName, String recordId, String field, String subField) {
        LookupSearchResult result = new LookupSearchResult();
        String strQuery = 'SELECT Id, '+field + (String.isNotBlank(subField) ? ' ,'+subField : '')+' FROM '+sObjectName +' WHERE Id =:recordId LIMIT 1';
        List<sObject> searchResults = Database.query(strQuery);   
        if(searchResults != NUll && !searchResults.isEmpty()){
            sObject sObj = searchResults.get(0);
            LookupSearchResult res = new LookupSearchResult();
            result.Id = sObj.Id;
            result.title = String.valueOf(sObj.get(field));
            if(String.isNotBlank(subField) && sObj.get(subField) != NULL){
                result.subtitle = String.valueOf(sObj.get(subField));
            }else{
                result.subtitle = sObjectName;
            }
        }
        return result;        
    }
    
    public class LookupSearchResult {
        @AuraEnabled public Id id{get;set;}
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String subtitle{get;set;}
    }
}