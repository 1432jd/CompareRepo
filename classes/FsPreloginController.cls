public class FsPreloginController extends GenericFormBuilderController{
    
    @AuraEnabled
    public static String getRecordTypeName(String recTypeId){
        return Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosById().get(recTypeId).getName();
    }
    
    @AuraEnabled
    public static Boolean checkBureauVerification(String appId) {
        String label = System.Label.Is_Bureau_Mandatory;
        if (label == 'YES'){
            List<Loan_Applicant__c> pendingBureauLoanApplicants = [SELECT Id FROM Loan_Applicant__c WHERE Application__c=: appId AND Is_Bureau_Verified__c = False];
            return pendingBureauLoanApplicants!= null && pendingBureauLoanApplicants.size() > 0 ? false : true;          
        }
        return true;
    }

    @AuraEnabled
    public static List<String> checkBureauVerification2(String appId) {
        String label = System.Label.Is_Bureau_Mandatory;
        if (label == 'YES'){
            List<Loan_Applicant__c> pendingBureauLoanApplicants = [SELECT Id,Applicant_Name__c FROM Loan_Applicant__c WHERE Application__c=: appId AND Is_Bureau_Verified__c = False];
            List<String> applicantNames = new LIst<String>();
            for(Loan_Applicant__c applicant: pendingBureauLoanApplicants){
                applicantNames.add(applicant.Applicant_Name__c);
            }
            return applicantNames;          
        }
        return null;
    }

    @AuraEnabled
    public static AppWrapper getApplicationId(String recordId){
        System.debug('prelogin Id '+recordId);
        if(String.isNotBlank(recordId) && String.isNotEmpty(recordId)){
            String appId = '';
            Application__c objApp = [SELECT Id,Name,Pre_Login__r.RecordTypeId,Pre_Login__r.RecordType.Name FROM Application__c WHERE Pre_Login__c  = : recordId AND Pre_Login__c  != null];
            appId = objApp.Id;
            AppWrapper appWrap = new AppWrapper();
            appWrap.appId = objApp.Id;
            appWrap.appName = objApp.Name;
            appWrap.recTypeId = objApp.Pre_Login__r.RecordTypeId;
            appWrap.recTypeName = objApp.Pre_Login__r.RecordType.Name;
            System.debug('Application Wrapper '+appWrap);
            return appWrap;  
        }
        else
            return null;
    }
    
    //Getting Input Fields From Metadata
    @AuraEnabled
    public static GenericFormBuilderController.InitWrapper getMetadtaInfoForm(String recordIds, String metaDetaName){
        System.debug('recIds & mdt '+recordIds+' :: '+metaDetaName);
        FsPreloginController obj = new FsPreloginController();
        obj.METADATA_NAME = metaDetaName;
        obj.IDS_SET = new Set<String>();
        if(String.isNotEmpty(recordIds)){
            //obj.IDS_SET = new Set<String>();
            obj.IDS_SET.addAll(recordIds.split('_'));
            obj.WHERE_CLAUSE = ' Id IN : IDS_SET';
            obj.RECORD_LIMIT = '1';    
        }
        return obj.initialize();
    }  
    
    //Save Account and Loan Applicant
    @AuraEnabled
    public static String saveRecord(sobject dataToInsert){
        System.debug(dataToInsert);
        System.debug(dataToInsert.getSObjectType());
        try{
            system.debug(':::dataToInsert:::' + dataToInsert);
            upsert dataToInsert; 
            return  dataToInsert.Id;
        } catch(Exception ex){
            System.debug('exception ::: '+ex);
            System.debug('exception ::: '+ex.getMessage());
            System.debug('exception ::: '+ex.getLineNumber());
            return null;
        }
    }
    
    //Pre Login Insertion
    @auraEnabled
    public static String insertPreLogin(){     
        Id devRecordTypeId = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        Pre_Login__c preLog = new Pre_Login__c(RecordTypeId=devRecordTypeId,Status__c='Active');
        INSERT preLog; 
        System.debug(preLog.Id);
        return preLog.Id; 
    }  
    
    //Application Insertion For Pre Login
    @auraEnabled
    public static AppWrapper insertApplications(String preLogInId){
        System.debug('Prelogin Id '+preLogInId);
        AppWrapper appWrap = new AppWrapper();
        List<Application__c> appId = [SELECT Id,Name FROM Application__c WHERE Pre_Login__c = :preLogInId AND Pre_Login__c != null];
        if(appId.size() > 0){
            System.debug('Yes');
            appWrap.appId = appId.get(0).Id;
            appWrap.appName = appId.get(0).Name;
        }
        else{ 
            Application__c objApp = new Application__c(Pre_Login__c = preLogInId,application_status__c = 'Active');
            INSERT objApp;
            Application__c app = [SELECT Id,Name FROM Application__c WHERE Id = :objApp.Id];
            Application_User_Tracking__c autObj = new Application_User_Tracking__c();
            autObj.Application__c = app.Id;
            autObj.Stage__c = 'Login';
            autObj.Owner__c = UserInfo.getUserId();
            autObj.Start_Date__c = System.now();
            autObj.Status__c = 'Pending';
            insert autObj;
            appWrap.appId = app.Id;
            appWrap.appName = app.Name;
            FS_DocumentUploadController.refreshRecords(app.Id);
        } 
        Pre_Login__c objPre = new Pre_Login__c();
        objPre.Id = preLogInId;
        objPre.Application__c = appWrap.appId;
        UPDATE objPre;
        System.debug('appWrap '+appWrap);
        return appWrap;
    }

    //Application Insertion For Pre Login
    @auraEnabled
    public static AppWrapper insertDirectApplications(String preLogInId,String branchId){
        System.debug('Prelogin Id '+preLogInId);
        AppWrapper appWrap = new AppWrapper();
        List<Application__c> appId = [SELECT Id,Name FROM Application__c WHERE Pre_Login__c = :preLogInId AND Pre_Login__c != null];
        if(appId.size() > 0){
            System.debug('Yes');
            appWrap.appId = appId.get(0).Id;
            appWrap.appName = appId.get(0).Name;
        }
        else{ 
            Application__c objApp = new Application__c(Pre_Login__c = preLogInId,application_status__c = 'Active',Sourcing_Branch__c = branchId);
            INSERT objApp;
            Application__c app = [SELECT Id,Name FROM Application__c WHERE Id = :objApp.Id];
            Application_User_Tracking__c autObj = new Application_User_Tracking__c();
            autObj.Application__c = app.Id;
            autObj.Stage__c = 'Login';
            autObj.Owner__c = UserInfo.getUserId();
            autObj.Start_Date__c = System.now();
            autObj.Status__c = 'Pending';
            insert autObj;
            appWrap.appId = app.Id;
            appWrap.appName = app.Name; 
            FS_DocumentUploadController.refreshRecords(app.Id);
        } 
        Pre_Login__c objPre = new Pre_Login__c();
        objPre.Id = preLogInId;
        objPre.Application__c = appWrap.appId;
        UPDATE objPre;
        System.debug('appWrap '+appWrap);
        return appWrap;
    }

    @AuraEnabled
    public static String insertApplicant(String salutation,String fName,String lName,String appId){
        System.debug(salutation+fName+lName+appId);
        Account objAcc = new Account();
        objAcc.RecordTypeId = DatabaseUtililty.getRecordTypeId('Account','Person Account');
        objAcc.FirstName = fName;
        objAcc.LastName = lName;
        objAcc.Salutation = salutation; 
        INSERT objAcc;
        Loan_Applicant__c objLoan = new Loan_Applicant__c();
        objLoan.Application__c = appId;
        objLoan.Customer_Information__c = objAcc.Id;
        objLoan.Customer_Type__c = 'Primary Applicant';
        INSERT objLoan;
        FS_DocumentUploadController.refreshRecords(appId);
        return objLoan.Id;
    }
    
    @AuraEnabled
    public static List<String> insertKYCDocuments(List<String> base64,List<String> fileName,String appId, String loanAppId){
        System.debug('Base64 '+ base64.size());
        System.debug('fileName '+fileName);
        System.debug('appId '+appId);
        System.debug('loanAppId '+loanAppId);
        integer count = 0;
        List<String> contentId = new List<String>();
        if(base64.size() > 0 && fileName.size() > 0 && base64.size() == fileName.size()){
            for(String img : base64){
                if(String.isNotBlank(img) && String.isNotEmpty(img)){
                    System.debug('img '+img);
                    String kycFileName = fileName.get(count);
                    System.debug('fileName '+kycFileName);
                    contentId.add(FileUploaderClass.uploadFile(img,kycFileName,appId,'OCR',loanAppId));
                    count = count + 1;
                    System.debug('count front '+count);
                }                
            }
        }
        return contentId;
    }
    
    //Update KYCOCR
    @AuraEnabled
    public static String updateKYCOR(String loanAppId, String recId){
        if(String.isNotEmpty(loanAppId) && String.isNotBlank(loanAppId) && String.isNotEmpty(recId) && String.isNotBlank(recId)){
            KYC__c objKYC = [SELECT Id,Loan_Applicant__c FROM KYC__c WHERE Id = :recId];
            objKYC.Loan_Applicant__c = loanAppId;
            UPDATE objKYC;
            return 'Success';
        }
        return 'Error';
    }
    
    
    //Getting All Fields Of Application Tab
    @AuraEnabled
    public static Application__c getApplicationRecord(String applicationId){
        System.debug('Application ID '+applicationId);
        Application__c objApp = [SELECT Id, Name, Geo_tagging_pin_for_the_user__c, Staff_Loan__c, Field_Officer_Emp_Id__c, Customer_Visit_date__c,
                                 Requested_Loan_Amount__c, Channel__c, Alternate_Channel_Mode__c, Employee_ID__c 
                                 FROM Application__c
                                 WHERE Id =: applicationId];
        System.debug(objApp);
        if(objApp != null)
            return objApp;
        else
            return null;
    }
    
    //Getting Branch Name Of Sales User
    @AuraEnabled
    public static String getBranchName(){
        Account objAccount = new Account();
        try{
            objAccount = [SELECT Branch_Master__r.Name
                          From Account
                          WHERE User__c = :userinfo.getuserid()];
            System.debug('ObjAcc '+objAccount);
            System.debug('branch '+objAccount.Branch_Master__r.Name);
        }
        catch(Exception e){
            return null;
        }
        return objAccount.Branch_Master__r.Name;
    }
    
    // Creating Property Owners
    @AuraEnabled
    public static String createPropertyOwners(String propertyId,List<String> loanAppList){
        if(String.isNotEmpty(propertyId) && !loanAppList.isEmpty()){
            List<Property_Owners__c> listPropOwner = new List<Property_Owners__c>();
            List<Property_Owners__c> listExistPropOwner = new List<Property_Owners__c>();
            listExistPropOwner = [SELECT Id,Property__c,Loan_Applicant__c FROM Property_Owners__c WHERE Property__c = :propertyId];
            if(!listExistPropOwner.isEmpty())
                DELETE listExistPropOwner;
            for(String loanAppId : loanAppList){
                Property_Owners__c objPropOwner = new Property_Owners__c();
                objPropOwner.Property__c = propertyId;
                objPropOwner.Loan_Applicant__c = loanAppId;
                listPropOwner.add(objPropOwner);               
            }
            if(!listPropOwner.isEmpty()){
                INSERT listPropOwner;
                return 'Success '+listPropOwner.size();
            }
        }
        return 'Fail';
    }
    
    //Cloning newly created property from pre-login for Property_RecordTypes_To_Clone Custom Label
    @AuraEnabled
    public static String clonePropertyNew(String appId){
        String recordTypesToCreate = System.Label.Property_RecordTypes_To_Clone;
        List<String> recordTypeNames = recordTypesToCreate.split(',');
        
        List<Property__c> newPropList = new List<Property__c>();
        List<Property__c> oldPropList = new List<Property__c>();
        List<Property__c> listOfProp = [SELECT Id, Name,Loan_Applicant__c,Nature_Of_Property__c,Login__c,Old_Property_Id__c ,
                                               hasRelatedRecords__c,Application__c,Property_Type__c ,Title_Deed_Type__c,
                                               Title_Deed_Number__c,Title_Deed_Date__c,Property_Address__c,Pincode__c 
                                        FROM Property__c
                                        WHERE Application__c = :appId AND RecordType.Name = 'Pre Login Property Detail' AND Old_Property_Id__c = NULL];
        if(listOfProp != NULL && !listOfProp.isEmpty()){
            for(Property__c objProp : listOfProp){
                if(!objProp.hasRelatedRecords__c){
                    for(String rcName : recordTypeNames){
                        Property__c newProperty = objProp.clone(false,false,false,true);
                        newProperty.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get(rcName).getRecordTypeId();
                        newProperty.Application__c = objProp.Application__c;
                        newProperty.Property__c = objProp.Id;
                        if(rcName == 'FIV-B Property Detail' || rcName == 'Online EC Property Detail'){
                            newProperty.Title_Deed_Type__c = null;
                            if(rcName == 'FIV-B Property Detail'){
                                newProperty.Property_Type__c = null;
                                newProperty.Nature_Of_Property__c = null;
                                //newProperty.Title_Deed_Number__c = null;
                            	newProperty.Title_Deed_Date__c = null;
                            }
                            //newProperty.Property_Address__c = null;
                        }
                            if(rcName == 'PC Property Detail')
                            newProperty.Title_Deed_Number__c = null;
                        newPropList.add(newProperty);
                    }
                    objProp.hasRelatedRecords__c = true;
                    oldPropList.add(objProp);  
                }
            }
            
            if(newPropList.size() > 0){
                INSERT newPropList; 
                UPDATE oldPropList;
                return 'Success';
            }
        }
        return 'Failed';
    }
    
    @AuraEnabled
    public static void updateHistory(String appId){
        Application__c app = [SELECT Id,Pre_Login__r.RecordType.Name,hasVerificationRecords__c,IsExceptionRaised__c FROM Application__c WHERE Id = :appId];
        List<Application_User_Tracking__c> historyList = new List<Application_User_Tracking__c>();
        historyList = [SELECT Id, End_Date__c, Status__c FROM Application_User_Tracking__c WHERE Application__c = :appId ORDER BY CreatedDate ASC LIMIT 1];
        if(historyList != NULL && !historyList.isEmpty()){
            Application_User_Tracking__c autObj = historyList.get(0);
            autObj.End_Date__c = System.now();
            autObj.Status__c = 'Completed';
            update autObj;
        }        
        if(app.Pre_Login__r.RecordType.Name != '1. New login' && !app.IsExceptionRaised__c){
            if(!app.hasVerificationRecords__c){
                FS_CloningController.cloneVerificationData(appId);
            }
        }
        else if(app.Pre_Login__r.RecordType.Name != '1. New login' && app.IsExceptionRaised__c){
            VerificationRecordCreator.createDedupeApplicationHistory(appId);
        }
    }

    @AuraEnabled
    public static Map<String,List<String>> getPropertyOwners(String applicationId){
        Map<String,List<String>> returnMap = new Map<String,List<String>>();
        for(Property_Owners__c prop : [SELECT Id,Property__c,Loan_Applicant__r.Customer_Information__r.Name FROM Property_Owners__c WHERE Property__r.Application__c = : applicationId AND Property__r.RecordType.Name = 'Pre Login Property Detail']){
            if(returnMap.containsKey(prop.Property__c)){
                System.debug(prop.Property__c);
                returnMap.get(prop.Property__c).add(prop.Loan_Applicant__r.Customer_Information__r.Name);
            }
            else{
                System.debug(prop.Loan_Applicant__r.Customer_Information__r.Name);
                returnMap.put(prop.Property__c,new List<String>{prop.Loan_Applicant__r.Customer_Information__r.Name});   
            }
        }
        System.debug('returnMAp '+returnMap);
        return returnMap;
    }
    
    @AuraEnabled
    public static String getPinId(String pin){
        String pinId = '';
        pinId = [SELECT Id FROM Ms_Pincode__c WHERE Name =: pin OR Pincode__c =: pin LIMIT 1].Id;
        return pinId;
    }
    
    @AuraEnabled
    public static String getApplicationName(String applicationId){
        return [SELECT Name FROM Application__c WHERE Id = :applicationId].Name;
    }
    
    @AuraEnabled
    public static Boolean checkKYCIdExist(String kycId1, String kycId2,String appId,String loanAppId){
        if((String.isNotBlank(kycId1) && String.isNotEmpty(kycId1)) || String.isNotBlank(kycId2) && String.isNotEmpty(kycId2)){
            String query = 'SELECT Id FROM Loan_Applicant__c WHERE Application__c = :appId ';
            query += 'AND (';
            if(String.isNotBlank(kycId1) && String.isNotEmpty(kycId1))
                query += 'KYC_ID_1__c = :kycId1 OR KYC_ID_2__c = :kycId1 OR ';
            if(String.isNotBlank(kycId2) && String.isNotEmpty(kycId2))
                query += 'KYC_ID_1__c = :kycId2 OR KYC_ID_2__c = :kycId2 '; 
            query = query.removeEnd('OR ');
            query += ')';
            System.debug(query);
            List<Loan_Applicant__c> listLoan = Database.query(query);
            System.debug(listLoan);
            System.debug(listLoan.size());
            if(listLoan.size() > 0){
                if(String.isNotBlank(loanAppId) && String.isNotEmpty(loanAppId) && listLoan.size() == 1 && listLoan.get(0).Id == loanAppId)
                    return false;
                else
                    return true;
            }
        }
        return false;
    }

    @AuraEnabled
    public static List<ContentVersion> getDocumentPublicList(String appId,String loanAppId){
        List<ContentVersion> docList = new List<ContentVersion>();
        String category = 'OCR';
        String query= 'SELECT Id, Uploaded_From__c,ContentDocumentId, Title, File_Type__c, FileExtension, ContentSize FROM ContentVersion WHERE Parent_Id__c =:appId AND Loan_Applicant__c =:loanAppId AND Category__c =:category';
        docList = Database.query(query);
        system.debug('imgList ##'+docList);
        if(!docList.isEmpty())
            return docList;
        else
            return null;
    }
    
    @AuraEnabled
    public static Boolean checkTitleDeedNumber(String applicationId,String titleDeedNo){
        System.debug('titleDeedNo '+titleDeedNo);
        List<Property__c> listProp = [SELECT Id,Title_Deed_Number__c
                                      FROM Property__c
                                      WHERE Application__c = :applicationId
                                      AND Title_Deed_Number__c = :titleDeedNo
                                      AND RecordType.Name = 'Pre Login Property Detail' 
                                      AND Application__c != NULL ];
        System.debug(listProp);
        System.debug(listProp.size());
        if(listProp.size() > 0)
            return true;
        else
            return false;
    }
    
    @AuraEnabled
    public static List<String> checkPropertyOnSubmit(String applicationId){
        List<String> errorList = new List<String>();
        for(Property__c pro : [SELECT Id,Name,Nature_Of_Property__c,Pincode__c,Property_Type__c,Title_Deed_Type__c,Title_Deed_Number__c,Title_Deed_Date__c,Property_Address__c,(SELECT Id FROM Property_Owners__r) FROM Property__c WHERE Application__c = :applicationId AND RecordType.Name = 'Pre Login Property Detail']){
            if(pro.Nature_Of_Property__c == null || pro.Property_Type__c == null || pro.Title_Deed_Type__c == null
               || pro.Title_Deed_Number__c == null || pro.Title_Deed_Date__c == null || pro.Property_Address__c == null || pro.Pincode__c == null ){
                errorList.add(pro.Name);
            } 
            if(pro.Property_Owners__r == Null || pro.Property_Owners__r.isEmpty()){
                if(!errorList.contains(pro.Name))
                	errorList.add(pro.Name);
            }    
        }
        return errorList;
    }
    
    public class AppWrapper{
        @AuraEnabled public String appId;
        @AuraEnabled public String appName;
        @AuraEnabled public String recTypeId;
        @AuraEnabled public String recTypeName;
    }
    
}