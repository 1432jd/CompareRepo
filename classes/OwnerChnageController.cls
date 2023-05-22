public class OwnerChnageController {
    
    //To get recordTypeName from record id
    @AuraEnabled
    public static String getRecordTypeNameOfRecord(String objectAPIName,Id recordId){
        if(String.isNotBlank(objectAPIName) && String.isNotEmpty(objectAPIName)){
            String query = 'SELECT RecordTypeId,RecordType.Name,Name FROM '+objectAPIName+' WHERE Id = '+'\''+recordId+'\' ';
            System.debug('query '+query);
            SObject obj =  Database.query(query); 
            System.debug('obj '+obj);
            Id recTypeId = String.valueOf(obj.get('RecordTypeId'));
            String recTypeName = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getRecordTypeInfosById().get(recTypeId).getName();
            System.debug('recTypeName '+recTypeName);
            return recTypeName;
        }
        else
            return null;
    }
    
    //To get userDesignation from metadata 
    @AuraEnabled
    public Static String getUserDesignation(String recTypeName,String objectAPIName){
        String query = 'SELECT Id, sObject_Name__c, User_Designation__c, RecordType_Stage__c ';
               query+= 'FROM ChangeOwner__mdt WHERE sObject_Name__c = '+'\''+objectAPIName+'\' ';
        	   query+= 'AND RecordType_Stage__c = '+'\''+recTypeName+'\' ';
        ChangeOwner__mdt cOwner = Database.query(query); 
        if(String.isNotBlank(cOwner.User_Designation__c) && String.isNotEmpty(cOwner.User_Designation__c)){
            String userDesignation = cOwner.User_Designation__c;
            System.debug('userDesignation '+userDesignation); 
            return userDesignation;
        }
        else
            return null;
    } 
    
    //To get Users of returned designation from metadata
    @AuraEnabled(cacheable=true)  
    public Static List<User> searchOwner(String searchKey,String objectAPIName,Id recordId) {  
        System.debug('Parameters '+searchKey+' :: '+objectAPIName+' :: '+recordId);
        if(String.isNotBlank(searchKey) && String.isNotEmpty(searchKey)){
            if(objectAPIName == 'Pre_Login__c'){
                String query = 'SELECT Id,Name,Designation__c FROM User ';
                query+= 'WHERE Name Like '+'\'%'+searchKey+'%\' ';
                List<User> listOfUsers = Database.query(query); 
                System.debug('listOfUsers '+listOfUsers);
                if(listOfUsers.size() > 0)
                    return listOfUsers;
            }
            else{
                String recTypeName = '';
                if(objectAPIName != 'Receipt__c')
                    recTypeName = getRecordTypeNameOfRecord(objectAPIName,recordId);
                System.debug('recTypeName '+recTypeName);
                String userDesignation = getUserDesignation(recTypeName,objectAPIName);
                System.debug('userDesignation '+userDesignation);
                if(String.isNotEmpty(userDesignation) && String.isNotBlank(userDesignation)){
                    String query = 'SELECT Id,Name,Designation__c FROM User ';
                    query+= 'WHERE Designation__c = '+'\''+userDesignation+'\' ';
                    query+= 'AND Name Like '+'\'%'+searchKey+'%\' ';
                    List<User> listOfUsers = Database.query(query); 
                    System.debug('listOfUsers '+listOfUsers);
                    if(listOfUsers.size() > 0)
                        return listOfUsers;
                }
            }
        }
        return null;  
    }
    
    //To Update Owner
    @AuraEnabled
    public Static String updateRecordOwner(String recordId,String userId,String objectAPIName,Boolean sendNotification){
        
        System.debug('recordId,userId :: '+recordId+' :: '+userId+' :: '+objectAPIName);
        if(String.isNotBlank(recordId) && String.isNotBlank(userId) && String.isNotEmpty(recordId) && String.isNotEmpty(userId)){
            String query = 'SELECT Id,OwnerId FROM '+objectAPIName+' ';
            	   query+= 'WHERE Id = '+'\''+recordId+'\' ';
            System.debug('query '+query);
            SObject sObj = Database.query(query);
            System.debug('sObj '+sObj);
            if(sObj != null){
                Map <String, Schema.SObjectField> fieldMap = sObj.getSobjectType().getDescribe().fields.getMap();
                if(fieldMap.containsKey('OwnerId')){
                    sObj.put('OwnerId', userId);
                }
                UPDATE sObj;
                if(sendNotification){
                system.debug('UserInfo.getUserId()'+ UserInfo.getUserId());
                Utility.sendNotification(UserInfo.getName()+' Change Owner','test',recordId,'Verification_Notification',UserInfo.getUserId());            // Create an approval request for  Opportunity        
                }
                return 'Success';
            }
        }
        return 'Failed';
    }
    
    /*if(String.isNotBlank(objectAPIName) && String.isNotEmpty(objectAPIName)){
                String query = 'SELECT OwnerId FROM '+objectAPIName+' WHERE ID = '+'\''+recordId+'\'';
                System.debug('query '+query);
                SObject sObj = Database.query(query);
                String ownerId = String.valueOf(sObj.get('OwnerId'));
                System.debug('ownerId '+ownerId);
                if(String.isNotBlank(ownerId) && String.isNotEmpty(ownerId)){
                    String branchId = [SELECT Branch_Master__c
                                       FROM Account
                                       WHERE User__c = :OwnerId AND Branch_Master__c != null].Branch_Master__c;  
                    System.debug('BranchId '+branchId);
                    query = 'SELECT Id, Name FROM User ';
                    query+= 'WHERE Id IN (SELECT User__c FROM Account WHERE Branch_Master__C ='+'\''+BranchId+'\' ';
                    query+= 'AND User__c != null) AND  Name LIKE '+'\''+searchKey+'\' ';
					List<User> listOfOwner = Database.query(query);
                    System.debug('listOfOwner '+listOfOwner);
                    if(listOfOwner.size() > 0)
                        return listOfOwner;
                    else
                        return null;
                }  
            }*/
    
    /*@AuraEnabled(cacheable=true)  
    public static List<User> findRecords(String searchKey, String objectName,Id recordId) {  
        String BranchId;
        Schema.SObjectType objType= recordId.getSobjectType();  
        System.debug('recordId'+objType);
        if( String.valueOf(objType)=='Verification__c'){    
            String OwnerId=[SELECT OwnerId FROM Verification__c WHERE ID=:recordId].OwnerId;
              System.debug('OwnerId'+OwnerId);
            BranchId=[SELECT Branch_Master__c FROM Account Where User__C=:OwnerId AND Branch_Master__c<>null].Branch_Master__c;
             System.debug('BranchId'+BranchId);
        }
        
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
        string query = 'SELECT Id, Name FROM User ';
        
        if( String.valueOf(objType)=='Verification__c')
            query+=' WHERE Id IN (Select User__c FROM Account WHERE Branch_Master__C =:BranchId AND User__c<>null) AND  Name LIKE '+searchText+' LIMIT 6';
        else if(  String.valueOf(objType)=='Pre_Login__c')
            query+='WHERE Name LIKE '+searchText+' LIMIT 6';
        System.debug('query'+query);
       
        return Database.query(query);  
    }*/
    
    
    @AuraEnabled
    public static void updateRecord(Id recordId, String userId){
        System.debug('userId>>>'+userId);
        System.debug('recordId>>>>'+recordId);
        Pre_Login__c pObj=new Pre_Login__c();
        Verification__c vObj=new Verification__c();
        User userObj=new User();
        Schema.SObjectType objType= recordId.getSobjectType();  
        if( String.valueOf(objType)=='Pre_Login__c')
        {   
            Pre_Login__c plObj = [Select Id,OwnerId from Pre_Login__c Where Id =:recordId];
            userObj = [Select Id, FirstName, LastName from User Where Id =:userId];
            pObj.Id=plObj.Id;
            pObj.OwnerId=userObj.Id;
        }
        else if(String.valueOf(objType)=='Verification__c')
        {
            Verification__c verObj = [Select Id,OwnerId from Verification__c Where Id =:recordId];
            userObj = [Select Id, FirstName, LastName from User Where Id =:userId];
            vObj.Id=verObj.Id;
            vObj.OwnerId=userObj.Id;
        }
        System.debug('pObj>>>'+pObj);
        System.debug('vObj>>>>'+vObj);
        if(pObj.Id!=null)
        update pObj;
        if(vObj.Id!=null)
        update vObj;
    }
}