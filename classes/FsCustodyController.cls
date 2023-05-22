public without sharing class  FsCustodyController {
    
  /*  @AuraEnabled
    public static String createRecords(String wrpObject){
        System.debug('wrpObject'+ wrpObject);
        Custody__c custodyObj = new Custody__c();
        custodyObj = (Custody__c)JSON.deserialize(wrpObject, Custody__c.class);
        upsert custodyObj;
        return custodyObj.Id;
    }*/

    //updated for application : Sangeeta yadav : 21 dec 22
    @AuraEnabled
    public static String createRecords(String wrpObject){
        System.debug('wrpObject'+ wrpObject);
        Application__c custodyObj = new Application__c();
        custodyObj = (Application__c)JSON.deserialize(wrpObject, Application__c.class);
        upsert custodyObj;
        return custodyObj.Id;
    }
    
    @AuraEnabled
    public static List<ContentVersion> getAdditionalRecords(String applicationId){
        return [SELECT Id, CreatedDate, ContentDocumentId, Remarks__c, Title, Uploaded_From__c, Document_Name__c, Parent_Id__c, Current_Record_Id__c,
                                Agreement_Document_Type__c, Owner.Name, Document_Number__c, Document_Date__c, Number_of_Pages__c, Document_Condition__c
                                FROM ContentVersion WHERE Is_Additional_Document__c = true AND Parent_Id__c =: applicationId];
    }
    
   @AuraEnabled
   public static void updateDocuments(String updatedDocument){
       List<ContentVersion> cvList = (List<ContentVersion>)JSON.deserialize(updatedDocument, List<ContentVersion>.class);
        update cvList;
   }

    @AuraEnabled
    public static Application__c getExistingRecord(String recordId){
        Application__c appObj;
        //Added by sangeeta: 19 dec 22 for replicating custody fields on application
        //List<Custody__c> csobjList = [SELECT Id,Old_Application_Number__c, Name, Stage_in_Date__c, Application_Number__c,Application_Number__r.Name, Loan_Account_Number__c, Disbursement_Date__c, Branch_Name__c, State__c, Application_Type__c, File_Inward_Status__c, Remarks__c, Handoff_Date__c, File__c, Box_Bar_Code__c, Storage_Vendor_Name__c, File_Status__c, Maker_Id__c, Checker_Id__c, Maker__c, Checker_Remarks__c, Customer_Name__c FROM Custody__c WHERE Application_Number__c =:recordId LIMIT 1];
        List<Application__c> appobjList = [SELECT Id,Name,Sourcing_Branch__c, Stage_in_Date__c, Stage__c, LMS_Response_Reference__c, Disbursal_Date__c, Sourcing_Branch__r.Name, Sourcing_Branch__r.State__c, Type__c, File_Inward_Status__c, Remarks__c, Handoff_Date__c, File_Bar_Code__c, Box_Bar_Code__c, Storage_Vendor_Name__c, File_Status__c, VDC_Maker_Id__c, VDC_Checker_Id__c, VDC_Maker_Remarks__c, VDC_Checker_Remarks__c, Primary_Applicant__c FROM Application__c WHERE id =:recordId LIMIT 1];
        if(appobjList.size()>0){
            appObj=appobjList[0];
            //  csObj.ApplicationExternalId = csobjList[0].Application_Number__r.Name;
            return appObj;
        }
        return null;
    }

    @AuraEnabled
    public static Boolean checkAccess(String recordId){
        System.debug('recordId is >>'+recordId);
         List<User>userList = [select Id,profile.name,Name from User where Id =:UserInfo.getUserId()];
         System.debug('userList is >>'+userList[0].profile.name);
         List<Application__c> appobjList = [SELECT Id, VDC_Checker_Id__c FROM Application__c WHERE id =:recordId AND VDC_Checker_Id__c!=null  LIMIT 1];
         System.debug('appobjList is >>'+appobjList);
         if(appobjList.size()>0){
            System.debug('inside checker is >>'+appobjList[0].VDC_Checker_Id__c);
            System.debug('inside userList[0].Id is >>'+userList[0].Id);
            if(appobjList[0].VDC_Checker_Id__c == userList[0].Id || userList[0].profile.name =='System Administrator'){
                System.debug('inside true is >>');
                return true;
            }
        }else{
            if(userList[0].profile.name =='System Administrator'){
                 return true;
            }
        }
    
        return false;

    }
 
    
    @AuraEnabled
    public static String getSource(String recordId){
        
        String appval='';
        List<Application__c> appList= [SELECT Id,LMS_Response_Reference__c,Pre_Login__r.recordtype.name,Sourcing_Branch__r.State__c,Sourcing_Branch__c,(select Id,Customer_Type__c,Applicant_Name__c from Loan_Applicants__r where Customer_Type__c=:'Primary Applicant' LIMIT 1) FROM Application__c WHERE Id =:recordId LIMIT 1];
        
        if(appList.size()>0){
            for(Application__c appObj : appList){
                appval+=appObj.Sourcing_Branch__c;
                appval+='#';
                appval+=appObj.Sourcing_Branch__r.State__c;
                appval+='#';
                appval+=appObj.Pre_Login__r.recordtype.name;
                appval+='#';
                appval+=appObj.LMS_Response_Reference__c;
                appval+='#';
                for(Loan_Applicant__c loanAppObj : appObj.Loan_Applicants__r){
                    appval+=loanAppObj.Id;
                }
            }
        }
        
        return appval;   
    }
    
    @AuraEnabled
    public static String getAccess(){
        
        List<PermissionSetAssignment> permissionSetList =  [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId()];
        if(permissionSetList.size()>0){
            for(PermissionSetAssignment psObj : permissionSetList){
              /*  if(psObj.PermissionSet.Name=='File_Inward_Permission_Set'){
                    return 'fileInward';
                }else*/ if(psObj.PermissionSet.Name=='Vendor_Handoff_permission_Set'){
                    return 'custodyStorage';
                }else if(psObj.PermissionSet.Name=='Document_Checker_Permission_Set'){
                    return 'vdc';
                }else if(psObj.PermissionSet.Name=='Document_Maker_Permission_Set'){
                    return 'doc';
                }
            }
        }
        
        User userObj = new User();
        userObj = [select Id,profile.name,Name from User where Id =:UserInfo.getUserId()];
        if(userObj.profile.name == 'System Administrator' ){
            return 'admin';
        }
        
        return '';
    }
    
    @AuraEnabled
    public static String getRepaymentDoc(String recordId){
        
        List<Application__c> appList= [select id,(Select Id,ContentDocument.title, LinkedEntityId, ContentDocumentId FROM ContentDocumentLinks) from Application__c where Id=:recordId];
        
        if(appList.size()>0){
            
            for(Application__c appObj : appList){
                for(ContentDocumentLink obj : appObj.ContentDocumentLinks){
                    if(obj.ContentDocument.title=='RepaySchedule'){
                        return obj.ContentDocumentId;
                    }
                }
            }
        }
        
        return '';
        
    }
    
    
    @AuraEnabled
    public static string getUsers(){
        
        String chckerId='';
        String makerId='';
        String userIds='';
        
        for(User userObj : [select Id,Name from User where Id =:UserInfo.getUserId()]){
            //if(userObj.Name=='Custody Document Checker'){
                //chckerIduserObj.Id;
           // }/*else{
                makerId=userObj.Id;
           // }*/
        }
        userIds = makerId;
        //userIds = chckerId+'#'+makerId;
        
        return userIds;
        
    }

    @AuraEnabled
    public static List<Deferral_Document__c> getVDCDocuments(String applicationId){
        return [SELECT
                Id, CreatedDate, Content_Version_Id__c, Remarks__c, Document_Name__c, Uploaded_From__c, Application__c,
                Document_Code__c, Document_Condition__c, Document_Type__c, Owner_Name__c, ContentDocumetId__c,
                No_of_Pages__c
                FROM Deferral_Document__c
                WHERE Application__c =: applicationId AND Status__c = 'Received'];
    }

    @AuraEnabled
    public static String updateDeferralDocument(String data){
        if(String.isNotBlank(data) && String.isNotEmpty(data)){
            Deferral_Document__c def = (Deferral_Document__c)JSON.deserialize(data, Deferral_Document__c.class);

            Deferral_Document__c defRecord = new Deferral_Document__c();
            defRecord.Id = def.Id;
            defRecord.Document_Condition__c = def.Document_Condition__c;
            defRecord.Document_Type__c = def.Document_Type__c;
            update defRecord;

            ContentVersion cv = new ContentVersion();
            cv.Id = def.Content_Version_Id__c;
            cv.Document_Condition__c = def.Document_Condition__c;
            cv.Agreement_Document_Type__c = def.Document_Type__c;
            update cv;

            return defRecord.Id;
        }
        return null;
    }

    @AuraEnabled
    public static List<DocWrapper> getContentVersionRecordsNew(String parentId){
        List<ContentVersion> listOfContentVersion = new List<ContentVersion>();
        List<DocWrapper> wrapperList = new List<DocWrapper>();
        Map<String,String> mapOfDocSetCode = new Map<String,String>();
        Set<String> docNames = new Set<String>();
        listOfContentVersion = [SELECT Id, CreatedDate, ContentDocumentId, Remarks__c, Title, Uploaded_From__c, Document_Name__c, Parent_Id__c, Current_Record_Id__c,
                                Agreement_Document_Type__c, Owner.Name, Document_Number__c, Document_Date__c, Number_of_Pages__c, Document_Condition__c
                                FROM ContentVersion 
                                WHERE Parent_Id__c =:parentId AND Is_Additional_Document__c = false];
        
        for(ContentVersion cv : listOfContentVersion){
            if(String.isNotBlank(cv.Document_Name__c)){
                docNames.add(cv.Document_Name__c);
            }
        }
        
        if(!docNames.isEmpty()){
            for(Document_Set_Code__c docSetCode : [SELECT Id, Document_Set_Code__c FROM Document_Set_Code__c WHERE Id IN: docNames]){
                mapOfDocSetCode.put(docSetCode.Id, docSetCode.Document_Set_Code__c);
            }
            
            for(ContentVersion cv : listOfContentVersion){
                DocWrapper docWrapObj = new DocWrapper();
                docWrapObj.cv = cv;
                if(String.isNotBlank(cv.Document_Name__c) && mapOfDocSetCode.containsKey(cv.Document_Name__c)){
                    docWrapObj.docNumber = mapOfDocSetCode.get(cv.Document_Name__c);
                }
                wrapperList.add(docWrapObj);
            }
            
        }
        return wrapperList;
    }
    
    public class DocWrapper{
        @AuraEnabled public ContentVersion cv;
        @AuraEnabled public String docNumber;
        
        public DocWrapper(){
            cv = new ContentVersion();
            docNumber = '';
        }
    }

     @AuraEnabled
    public static string submitApp(String dataWrapper, Boolean DocChecker){
        try {
            DocChecker = Boolean.valueOf(label.Custody_Document_Checker_Required);
            System.debug('dataWrapper'+ dataWrapper);
            List<Application__c> appList = new List<Application__c>();
            Application__c wrapperList = (Application__c) JSON.deserialize(dataWrapper, Application__c.class);
    
            if(wrapperList != null && wrapperList.Id != null){
                
              //  if (wrapperList.Stage__c =='VDC Maker' && (DocChecker == true || DocChecker == True)) { 

                    Application__c appObj = new Application__c();
                    appObj.Id = wrapperList.Id;
                    appObj.Stage__c = 'Vendor Handoff';
                    appList.add(appObj);
              //  }
            /*    else if(wrapperList.Stage__c =='VDC Maker' && (DocChecker == false || DocChecker == False)){
                    Application__c appObj = new Application__c();
                    appObj.Id = wrapperList.Id;
                    appObj.Stage__c = 'Vendor Handoff';
                    appList.add(appObj);
                }
                else if(wrapperList.Stage__c =='VDC Checker'){
                    Application__c appObj = new Application__c();
                    appObj.Id = wrapperList.Id;
                    appObj.Stage__c = 'Vendor Handoff';
                    appList.add(appObj);
                }*/
            }
    
            if(appList.size()>0){
                update appList;
                return 'success';
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'error';
    }

    //Added by Sangeeta to submit application in case of Document maker or checker: 21/12/22
    @AuraEnabled
    public static string submitApplications(String dataWrapper, Boolean DocChecker){
        try {
            DocChecker = Boolean.valueOf(label.Custody_Document_Checker_Required);
            System.debug('dataWrapper'+ dataWrapper);
            List<Application__c> appList = new List<Application__c>();
            Application__c wrapperList = (Application__c) JSON.deserialize(dataWrapper, Application__c.class);
    
            if(wrapperList != null && wrapperList.Id != null){
                
              //  if (wrapperList.Stage__c =='VDC Maker' && (DocChecker == true || DocChecker == True)) { 

                    Application__c appObj = new Application__c();
                    appObj.Id = wrapperList.Id;
                    appObj.Stage__c = 'VDC Checker';
                    appList.add(appObj);
              //  }
            /*    else if(wrapperList.Stage__c =='VDC Maker' && (DocChecker == false || DocChecker == False)){
                    Application__c appObj = new Application__c();
                    appObj.Id = wrapperList.Id;
                    appObj.Stage__c = 'Vendor Handoff';
                    appList.add(appObj);
                }
                else if(wrapperList.Stage__c =='VDC Checker'){
                    Application__c appObj = new Application__c();
                    appObj.Id = wrapperList.Id;
                    appObj.Stage__c = 'Vendor Handoff';
                    appList.add(appObj);
                }*/
            }
    
            if(appList.size()>0){
                update appList;
                return 'success';
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'error';
    }
}