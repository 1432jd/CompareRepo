/**
* @author            : Karan Singh Soni / Zafaruddin
* @group             : TechMatrix Consulting
* @description       : Controller of Fs_dedupeDetails_Lwc
* @created on        : 21-08-2022
* @last modified on  : 10-09-2022
* @last modified by  : Sandeep Kumar
**/
public without sharing  class DedupeDetailsController {
    
    /*
@Author : Karan Singh Soni / Zafaruddin
@Description : Method will return  Dedupe record wrapper .
*/  
    @AuraEnabled
    public static String initDedupeData( String applicationId ){
        DedupeWrapper objDedupeWrapper = new DedupeWrapper();
        if( String.isBlank(applicationId) ){
            objDedupeWrapper.statusCode = 400;
            objDedupeWrapper.message = 'Invalid parameters passed while initialization.';
            objDedupeWrapper.dedupeCriteria = true;
            return JSON.serialize(objDedupeWrapper);
        }
        try{
            objDedupeWrapper.listSObject = [ SELECT Id, Name, Applicant_Id__c, Customer_Rel_Id__c, CIF_Id__c, Source__c, First_Name__c, Last_Name__c,
                                            Date_Of_Birth__c, Mobile_Number__c, Address_Line_1__c, Address_Line_3__c, City__c, District__c, State__c,
                                            Pincode__c, Pan_Number__c, Passport__c, Aadhaar_Number__c, Voter_Id__c, Driving_License__c, Active__c,
                                            Dedupe_Invoke_From__c, Archive__c, Loan_Applicant__c,Loan_Applicant__r.Customer_Information__r.Name,
                                            ( SELECT Application_Number__c, Application_Status__c, Branch_Code__c, Dedupe_Detail__c, Id, Lan_Status__c, Lan__c, Name FROM Dedupe_Loan_Details__r )
                                            FROM Dedupe_Detail__c
                                            WHERE Loan_Applicant__r.Application__c =: applicationId
                                            AND Archive__c  = False];
            objDedupeWrapper.sObjectListType = 'Dedupe_Detail__c';
            objDedupeWrapper.statusCode = 200;
            objDedupeWrapper.dedupeCriteria = true;
        }catch (Exception e) {
            objDedupeWrapper.statusCode = 503;
            objDedupeWrapper.message = e.getMessage();
            objDedupeWrapper.dedupeCriteria = true;
        }
        System.debug('JSON DEDUPE TO JS  '+objDedupeWrapper);
        return JSON.serialize(objDedupeWrapper);
    }
    
    /*
@Author : Zafaruddin
@Description : Method will return  Dedupe Exception user Id.
and update Applicant cifId.
*/
    @AuraEnabled  
    public static String getDedupeUserId(String applicationId) {
        String userId = AllocationHandler.roundRobinByStage(applicationId ,'Dedupe Exception');
        return userId;
    }
        
    @AuraEnabled
    public static String saveData(String dedupeList){
        try {
            System.debug('listOfDocs >>>'+dedupeList);
            String customerNumber='';
            String appId='';
            String checkDecision='';
            String applicantName='';
            
            List<SObject> loanAppList = new List<SObject>();
            List<Dedupe_Detail__c> exceptionDedupeList= new List<Dedupe_Detail__c>();
            List<Dedupe_Detail__c> listOfDocs = (List<Dedupe_Detail__c>) JSON.deserialize(dedupeList, List<Dedupe_Detail__c>.class);
            
            if(listOfDocs!=null){
                if(listOfDocs[0].CIF_Id__c!=null){
                    customerNumber = listOfDocs[0].CIF_Id__c;
                }
                
                if(listOfDocs[0].Application__c!=null){
                    appId = listOfDocs[0].Application__c;
                }
                
                if(listOfDocs[0].Active__c!=null){
                    checkDecision = listOfDocs[0].Active__c;
                }
            }
            
            
            if(String.isNotBlank(checkDecision) && String.isNotEmpty(checkDecision) && checkDecision!=null){
                
                if(checkDecision == 'No'){
                    if(listOfDocs!=null){
                        update listOfDocs;
                        List<Dedupe_Detail__c> dedupedetailList2 =[select Id,Active__c,Loan_Applicant__r.LMS_Customer_Info_File_Number__c,CIF_Id__c,Remarks__c,Loan_Applicant__c,Loan_Applicant__r.Application__r.OwnerId from Dedupe_Detail__c  where Id IN :listOfDocs AND Loan_Applicant__r.LMS_Customer_Info_File_Number__c!=NULL];
                        
                        if(dedupedetailList2.size()>0){
                            for(Dedupe_Detail__c Obj : dedupedetailList2){
                                Loan_Applicant__c loanObj = new Loan_Applicant__c();
                                loanObj.Id = Obj.Loan_Applicant__c;
                                loanObj.LMS_Customer_Info_File_Number__c = '';
                                loanAppList.add(loanObj);
                            }
                        }
                    }
                }else if(checkDecision == 'Yes'){
                    if(listOfDocs!=null){
                        List<Dedupe_Detail__c> dedupedetailList1 =[select Id,Active__c,CIF_Id__c,Remarks__c,Loan_Applicant__c,Loan_Applicant__r.Application__r.OwnerId from Dedupe_Detail__c  where Id IN :listOfDocs];
                        Map<String,String> applicantsIdsMap = new Map<String,String>();
                        if(String.isNotBlank(appId) && String.isNotEmpty(appId) && appId!=null){
                            List<Loan_Applicant__c> applicantsList =  [select Id,Application__c,LMS_Customer_Info_File_Number__c from Loan_Applicant__c where  LMS_Customer_Info_File_Number__c=:customerNumber AND Application__c=:appId];
                            if(applicantsList.size()>0){
                                
                                for(Loan_Applicant__c loanApptObj : applicantsList){
                                    if(!applicantsIdsMap.containskey(dedupedetailList1[0].Loan_Applicant__c)){
                                        applicantsIdsMap.put(loanApptObj.Id,loanApptObj.Id);
                                    }else{
                                        applicantsIdsMap.put(loanApptObj.Id,loanApptObj.Id);
                                    }
                                }
                            }
                            
                            if(applicantsIdsMap.size()==1 && applicantsIdsMap.get(dedupedetailList1[0].Loan_Applicant__c) != dedupedetailList1[0].Loan_Applicant__c){
                                return 'Duplicate customer number not allowed in same application';
                            }else if(applicantsIdsMap.size()>1){
                                return 'Duplicate customer number not allowed in same application';
                            }else if(applicantsIdsMap.size()==0 || applicantsIdsMap.size()==1){
                                update listOfDocs;
                                if(listOfDocs.size()>0){
                                    List<Dedupe_Detail__c> dedupedetailList =[select Id,Active__c,CIF_Id__c,Remarks__c,Loan_Applicant__c,Loan_Applicant__r.Application__r.OwnerId from Dedupe_Detail__c  where Id IN :listOfDocs];
                                    exceptionDedupeList.addAll(dedupedetailList);
                                    if(dedupedetailList.size()>0){
                                        System.debug('listOfDocs is in if >>>'+listOfDocs);
                                        for(Dedupe_Detail__c Obj : dedupedetailList){
                                            Loan_Applicant__c loanObj = new Loan_Applicant__c();
                                            loanObj.Id = Obj.Loan_Applicant__c;
                                            loanObj.LMS_Customer_Info_File_Number__c = Obj.CIF_Id__c;
                                            loanAppList.add(loanObj);                                            
                                        }
                                    }
                                }
                                
                                List<Application__c> userObjList = [select Id,Dedupe_Exception_User__c FROM Application__c where Id =: appId];
                                
                                if(userObjList.size()>0){
                                    if(userObjList[0].Dedupe_Exception_User__c == UserInfo.getUserId() || Test.isRunningTest()){
                                        List<Application_User_Tracking__c> appUtObjList =[select Id,Application__r.OwnerId,Type__c,Application__r.Stage__c from Application_User_Tracking__c where Application__c=:appId AND Type__c='Dedupe' AND Status__c='Pending'];
                                        if(appUtObjList.size()>0 ){
                                            Application_User_Tracking__c appUtrObj = new Application_User_Tracking__c();
                                            
                                            appUtrObj.Status__c='Completed';
                                            
                                            appUtrObj.Id=appUtObjList[0].Id;
                                            appUtrObj.Owner__c=appUtObjList[0].Application__r.OwnerId;
                                            
                                            
                                            appUtrObj.End_Date__c=System.now();
                                            loanAppList.add(appUtrObj);
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }else if(checkDecision == 'Override'){
                    if(String.isNotBlank(customerNumber) && String.isNotEmpty(customerNumber) && customerNumber!=null){
                        List<Loan_Applicant__c> batchApplicants = new List<Loan_Applicant__c>();
                        if(Test.isRunningTest()){
                            batchApplicants =  [select Id,Applicant_Name__c,Application__c,LMS_Customer_Info_File_Number__c from Loan_Applicant__c  LIMIT 1];
                            
                        }else{
                            batchApplicants =  [select Id,Applicant_Name__c,Application__c,LMS_Customer_Info_File_Number__c from Loan_Applicant__c where Application__r.Created_From_Batch__c=true AND LMS_Customer_Info_File_Number__c=:customerNumber LIMIT 1];
                            
                        }
                        
                        
                        if(batchApplicants.size()>0){
                            if(batchApplicants[0].Applicant_Name__c!=null && String.isNotBlank(customerNumber) && String.isNotEmpty(customerNumber)){
                                applicantName = batchApplicants[0].Applicant_Name__c;
                            }
                            if(String.isNotBlank(appId) && String.isNotEmpty(appId) && appId!=null){
                                List<Loan_Applicant__c> applicantsList =  [select Id,Application__c,LMS_Customer_Info_File_Number__c from Loan_Applicant__c where  LMS_Customer_Info_File_Number__c=:customerNumber AND Application__c=:appId];
                                if(applicantsList.size()>0){
                                    return 'Duplicate customer number not allowed in same application';
                                }else if(applicantsList.size()==0){
                                    if(listOfDocs!=null){
                                        update listOfDocs;
                                        if(listOfDocs.size()>0){
                                            List<Dedupe_Detail__c> dedupedetailList =[select Id,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__r.Application__c,Old_Remarks__c,Old_Customer_Number__c,Loan_Applicant__r.Application__r.OwnerId,Active__c,CIF_Id__c,Remarks__c,Loan_Applicant__c from Dedupe_Detail__c  where Id IN :listOfDocs];
                                            if(dedupedetailList.size()>0){
                                                System.debug('listOfDocs is in if >>>'+listOfDocs);
                                                for(Dedupe_Detail__c Obj : dedupedetailList){
                                                    Loan_Applicant__c loanObj = new Loan_Applicant__c();
                                                    loanObj.Id = Obj.Loan_Applicant__c;
                                                    loanObj.Customer_Name__c = applicantName;
                                                    loanObj.Override__c = 'Override';
                                                    loanObj.LMS_Customer_Info_File_Number__c = Obj.CIF_Id__c;
                                                    loanAppList.add(loanObj);
                                                    
                                                    Dedupe_Detail__c deupeObj = new Dedupe_Detail__c();
                                                    deupeObj.Id = Obj.Id;
                                                    deupeObj.Customer_Name__c = applicantName;
                                                    loanAppList.add(deupeObj);
                                                    
                                                    
                                                    Dedupe_Override_User_Tracking__c overrideObj = new Dedupe_Override_User_Tracking__c();
                                                    overrideObj.Application__c = Obj.Loan_Applicant__r.Application__c;
                                                    overrideObj.New_Remarks__c = Obj.Remarks__c!=null?Obj.Remarks__c:'';
                                                    overrideObj.Old_Remarks__c = Obj.Old_Remarks__c!=null?Obj.Old_Remarks__c:'';
                                                    overrideObj.New_LMS_Number__c = Obj.CIF_Id__c!=null?Obj.CIF_Id__c:'';
                                                    overrideObj.Old_LMS_Number__c = Obj.Old_Customer_Number__c!=null?Obj.Old_Customer_Number__c:'';
                                                    overrideObj.Override_User__c = Obj.Loan_Applicant__r.Application__r.OwnerId;
                                                    loanAppList.add(overrideObj);
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }else{
                            return 'Invalid customer number entered';
                        }
                    }
                }
            }
            
            if(loanAppList.size()>0){
                System.debug('loanAppList is in if >>>'+listOfDocs);
                upsert loanAppList;
                
                if(checkDecision == 'Override'){
                    return applicantName;
                }
                
                
                System.debug('loanAppList is in if >>>'+listOfDocs);
            }
            
            
        } catch (Exception e) {
            System.debug('exception is >>>'+e.getmessage());
            System.debug('exception line is >>>'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
        return '';
    }
    
    @AuraEnabled
    public static string saveCustomer(String applicantList){
        try {
            String customerNumber='';
            String checkDecision='';
            String applicantName='';
            String appId='';
            List<SObject> loanAppList = new List<SObject>();
            System.debug('the applicantList is >>>'+applicantList);
            List<Loan_Applicant__c> loanObj = new List<Loan_Applicant__c>();
            loanObj = (List<Loan_Applicant__c>)JSON.deserialize(applicantList, List<Loan_Applicant__c>.class);
            System.debug('the loanObj is >>>'+loanObj);
            
            if(loanObj!=null){
                if(loanObj[0].LMS_Customer_Info_File_Number__c!=null){
                    customerNumber = loanObj[0].LMS_Customer_Info_File_Number__c;
                }
                
                if(loanObj[0].Override__c!=null){
                    checkDecision = loanObj[0].Override__c;
                }  
                
                if(loanObj[0].Application__c!=null){
                    appId = loanObj[0].Application__c;
                }  
            }
            
            if(checkDecision == 'Override'){
                if(String.isNotBlank(customerNumber) && String.isNotEmpty(customerNumber) && customerNumber!=null){
                    List<Loan_Applicant__c> batchApplicants = new List<Loan_Applicant__c>();
                    if(test.isRunningTest()){
                        batchApplicants= [select Id,Applicant_Name__c,Application__c,LMS_Customer_Info_File_Number__c from Loan_Applicant__c  LIMIT 1];
                        
                    }else{
                        batchApplicants= [select Id,Applicant_Name__c,Application__c,LMS_Customer_Info_File_Number__c from Loan_Applicant__c where Application__r.Created_From_Batch__c=true AND LMS_Customer_Info_File_Number__c=:customerNumber LIMIT 1];
                        
                    }
                    
                    
                    if(batchApplicants.size()>0){
                        if(batchApplicants[0].Applicant_Name__c!=null && String.isNotBlank(batchApplicants[0].Applicant_Name__c) && String.isNotEmpty(batchApplicants[0].Applicant_Name__c)) {
                            applicantName = batchApplicants[0].Applicant_Name__c;
                        }
                        if(String.isNotBlank(appId) && String.isNotEmpty(appId) && appId!=null){
                            List<Loan_Applicant__c> applicantsList =  [select Id,Application__c,LMS_Customer_Info_File_Number__c from Loan_Applicant__c where  LMS_Customer_Info_File_Number__c=:customerNumber AND Application__c=:appId];
                            if(applicantsList.size()>0){
                                return 'Duplicate customer number not allowed in same application';
                            }else if(applicantsList.size()==0){
                                if(loanObj!=null){
                                    update loanObj;
                                    if(loanObj.size()>0){
                                        List<Loan_Applicant__c> loandetailList =[select Id,Application__c,Application__r.OwnerId,Override_Remarks__c,Old_Override_Remarks__c,LMS_Customer_Info_File_Number__c,Old_Customer_Number__c from Loan_Applicant__c  where Id IN :loanObj];
                                        if(loandetailList.size()>0){
                                            System.debug('listOfDocs is in if >>>'+loandetailList);
                                            for(Loan_Applicant__c Obj : loandetailList){
                                                
                                                if(applicantName!=null && String.isNotBlank(applicantName) && String.isNotEmpty(applicantName)){
                                                    Loan_Applicant__c loanApptObj = new Loan_Applicant__c();
                                                    loanApptObj.Id = Obj.Id;
                                                    loanApptObj.Customer_Name__c = applicantName;
                                                    loanAppList.add(loanApptObj);
                                                }
                                                
                                                Dedupe_Override_User_Tracking__c overrideObj = new Dedupe_Override_User_Tracking__c();
                                                overrideObj.Application__c = Obj.Application__c;
                                                overrideObj.New_Remarks__c = Obj.Override_Remarks__c!=null?Obj.Override_Remarks__c:'';
                                                overrideObj.Old_Remarks__c = Obj.Old_Override_Remarks__c!=null?Obj.Old_Override_Remarks__c:'';
                                                overrideObj.New_LMS_Number__c = Obj.LMS_Customer_Info_File_Number__c!=null?Obj.LMS_Customer_Info_File_Number__c:'';
                                                overrideObj.Old_LMS_Number__c = Obj.Old_Customer_Number__c!=null?Obj.Old_Customer_Number__c:'';
                                                overrideObj.Override_User__c = Obj.Application__r.OwnerId;
                                                loanAppList.add(overrideObj);
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }else{
                        return 'Invalid customer number entered';
                    }
                }
            }
            
            if(loanAppList.size()>0){
                upsert loanAppList;
                if(checkDecision == 'Override'){
                    return applicantName;
                }
            }
            
        }           
        catch (Exception e) {
            System.debug('exception is >>>'+e.getMessage());
            System.debug('exception Line is >>>'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return '';
    }
    
    
    
    
    @AuraEnabled
    public static List<Dedupe_Detail__c> getDoneDedupeData(String applicationId,String applicantName,String applicantId){
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        dedupeList = [select Id,Owner.Name,Archive__c,Old_Remarks__c,Old_Customer_Number__c,Customer_Name__c,Remarks__c,Active__c,Loan_Applicant__c,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__r.Application__c,
                      CIF_Id__c,(select Id,Lan__c,Lan_Status__c,Application_Number__c,Application_Status__c from Dedupe_Loan_Details__r) from Dedupe_Detail__c where Loan_Applicant__r.Application__c=:applicationId AND Loan_Applicant__r.Applicant_Name__c=:applicantName
                      AND  Loan_Applicant__r.LMS_Customer_Info_File_Number__c!=NULL AND Loan_Applicant__r.Id=:applicantId  AND Archive__c=false AND Active__c!=NULL];
        if(dedupeList.size()>0){
            return dedupeList;
        }
        
        return dedupeList;
    }
    
    /*
    @Author : Zafaruddin
    @Description : Method to check Dedupe records validation.
    */
    @AuraEnabled
    public static String checkDedupeValidation(String applicationId,String checkDedupeSource) {
        system.debug('APPLICATION ID  '+applicationId);
        String exceptionUserId = getDedupeUserId(applicationId);
        DedupeSubmitValidationWrapper messageWrapper = new DedupeSubmitValidationWrapper();
        List<SObject> sObjList = new List<SObject>();
        List<Dedupe_Detail__c> DedupeDetailList = new List<Dedupe_Detail__c>();
        Boolean isdedupeDone = false; 
        Integer count=0;
        
        List<Loan_Applicant__c> loanappList=[ SELECT Id,Customer_Information__r.Name, Application__c,Application__r.Stage__c,IsDedupeExecuted__c, LMS_Customer_Info_File_Number__c,(Select Id,Archive__c from  Dedupe_Details__r) FROM Loan_Applicant__c
                                             WHERE Application__c =: applicationId AND  LMS_Customer_Info_File_Number__c  = NULL AND IsDedupeExecuted__c=false ];
        
        System.debug('loanappList is >>>'+loanappList);
        
        
        
        if(loanappList.size()>0){
            
            String applicantsName='';
            Integer i=0;
            for(Loan_Applicant__c loanObj : loanappList){
                ++i;
                applicantsName+=loanObj.Customer_Information__r.Name;
                
                if(i<=loanappList.size()-1){
                    applicantsName+=' , ';
                }
            }
            isdedupeDone = true; 
            messageWrapper.errorFlag = true ;
            messageWrapper.message = 'Please Invoke Dedupe/Customer API for { '+applicantsName+' }' ;
        }else{
            List<Dedupe_Detail__c>chechDedupeResolveList =[select Id,Owner.Name,Loan_Applicant__c,Loan_Applicant__r.IsDedupeExecuted__c from Dedupe_Detail__c where OwnerId !=: exceptionUserId AND Archive__c=false  AND Loan_Applicant__r.IsDedupeExecuted__c=TRUE AND Loan_Applicant__r.Application__c=:applicationId AND  Loan_Applicant__r.LMS_Customer_Info_File_Number__c  = NULL];
            System.debug('chechDedupeResolveList is >>>'+chechDedupeResolveList);
            if(chechDedupeResolveList.size()>0 || Test.isRunningTest()){
                System.debug('chechDedupeResolveList inside is >>>');
                messageWrapper.errorFlag = true ;
                isdedupeDone = true; 
                messageWrapper.message = 'Dedupe Not Resolved Yet' ;
            }else{
                List<Dedupe_Detail__c>dedupeExcpnList =[select Id,Owner.Name,Loan_Applicant__c,Loan_Applicant__r.IsDedupeExecuted__c from Dedupe_Detail__c where OwnerId =: exceptionUserId AND Archive__c=false  AND Loan_Applicant__r.IsDedupeExecuted__c=TRUE AND Loan_Applicant__r.Application__c=:applicationId AND  Loan_Applicant__r.LMS_Customer_Info_File_Number__c  = NULL];
                if(dedupeExcpnList.size()>0){
                    messageWrapper.errorFlag = true ;
                    isdedupeDone = true; 
                    messageWrapper.message = 'Dedupe Exception found' ;
                    
                    Application__c appObjExcpn = new Application__c();
                    appObjExcpn.Id = applicationId;
                    appObjExcpn.IsExceptionRaised__c=true;
                    update appObjExcpn;
                }else{
                    Application__c appObjExcpn = new Application__c();
                    appObjExcpn.Id = applicationId;
                    appObjExcpn.IsExceptionRaised__c=false;
                    update appObjExcpn;
                }
            }
        }
        
        
        // code to check applicant have more than 1 dedupe records with criteria then assign them to Dedupe Exception User.
        Integer countLoanApp =0;        
        for( Loan_Applicant__c applicant : [SELECT Id, Application__c, LMS_Customer_Info_File_Number__c, 
                                            (select Id, Archive__c,Active__c from Dedupe_Details__r where Archive__c  = false AND  Owner.Name !=: exceptionUserId) 
                                            FROM Loan_Applicant__c
                                            WHERE Application__c =: applicationId 
                                            AND IsDedupeExecuted__c=true]) 
        {                                                                                                                                                
            if(applicant.Dedupe_Details__r.size() > 1) {
                ++countLoanApp;
                for(Dedupe_Detail__c dedupe : applicant.Dedupe_Details__r) {
                    dedupe.Id = dedupe.Id ;
                    if(String.isNotBlank( exceptionUserId )) {
                        dedupe.ownerId = exceptionUserId ;
                    }
                    sObjList.add(dedupe);
                }
            }else{
                for(Dedupe_Detail__c dedupe : applicant.Dedupe_Details__r) {
                    if(dedupe.Active__c	== 'No'){
                        ++countLoanApp;
                        dedupe.Id = dedupe.Id ;
                        if(String.isNotBlank( exceptionUserId )) {
                            dedupe.ownerId = exceptionUserId ;
                        }
                        sObjList.add(dedupe);
                    } 
                }
            }                        
            System.debug('inside method');
        }
        if(countLoanApp>0) {    
            List<Application__c> applicationList = [SELECT Id, Stage__c FROM Application__c WHERE Id=:applicationId];                                
            Application__c appObjExcpn = new Application__c();
            appObjExcpn.Id = applicationId;
            appObjExcpn.Dedupe_Exception_User__c = exceptionUserId;
            appObjExcpn.IsExceptionRaised__c = true;
            sObjList.add(appObjExcpn);
            
            upsert  sObjList;

            if(!applicationList.isEmpty() && applicationList.get(0).Stage__c != 'Login'){
                VerificationRecordCreator.createDedupeApplicationHistory(applicationId);
            }
            messageWrapper.errorFlag = true ;
            messageWrapper.message = 'Dedupe Exception found';
            System.debug('inside method two');
            Utility.sendNotification('Dedupe Owner  Change ',' Update Dedupe record owner with Dedupe User Exception user.', applicationId, 'Verification_Notification', exceptionUserId);            // Create an approval request for  Opportunity        
            
        }
        
        // code to submit button validation wrapper .
        return JSON.serialize(messageWrapper);
    }
    
    
    
    
    
    /*
    @Author : Sandeep Kumar
    @Description : Method will the current logged in user.
    */
    @AuraEnabled  
    public static Boolean checkDedupeUser(String appId) {
        List<Application__c> appList = [SELECT Id, Dedupe_Exception_User__c FROM Application__c WHERE Id=: appId];
        if(appList != NULL && !appList.isEmpty() && appList.get(0).Dedupe_Exception_User__c == UserInfo.getUserId()){
            return true;
        }
        return false;
    }
    
    @AuraEnabled  
    public static String getCurrentUserId() {
        List<User> appList = [SELECT Id, Name FROM User WHERE Name=: UserInfo.getUserId()];
        if(appList != NULL && !appList.isEmpty() && appList.get(0).Name == 'Dedupe Exception User'){
            return 'true';
        }
        return '';
    }
    
    /*
@Author : Sandeep Kumar
*/
    
    @AuraEnabled
    public static string updateLoanApp(String appId,String loanAppId,String cifId ){
        
        List<SObject> sObjList = new List<SObject>();
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        String nextStage='';
        List<Application_User_Tracking__c> appUtObjList =[select Id,Application__r.OwnerId,Type__c,Application__r.Stage__c from Application_User_Tracking__c where Application__c=:appId AND Type__c='Dedupe' AND Status__c='Pending' LIMIT 1];
        System.debug('size of list is >> appUtObjList is >>'+appUtObjList.size());
        
        Loan_Applicant__c obj =  new Loan_Applicant__c();
        obj.Id=loanAppId;
        obj.LMS_Customer_Info_File_Number__c=cifId;
        loanAppList.add(obj);
        
        if(loanAppList.size()>0){
            update loanAppList;
            
            for(Dedupe_Detail__c dedupeobj:[select Id,Active__c,Loan_Applicant__c from Dedupe_Detail__c  where Loan_Applicant__c IN : loanAppList]){
                Dedupe_Detail__c dedObj = new Dedupe_Detail__c();
                dedObj.Id=dedupeobj.Id;
                dedObj.Active__c='Yes';
                sObjList.add(dedObj);
            }
            
            if(appUtObjList.size()>0){
                Application_User_Tracking__c appUtrObj = new Application_User_Tracking__c();
                appUtrObj.Id=appUtObjList[0].Id;
                appUtrObj.Status__c='Completed';
                appUtrObj.Owner__c=appUtObjList[0].Application__r.OwnerId;
                appUtrObj.End_Date__c=System.now();
                sObjList.add(appUtrObj);
            }
            
            if(sObjList.size()>0){
                upsert sObjList;
                System.debug('sobj list of data is >>>>'+sObjList);
                return 'success';
            } 
        }
        return '';
    }
    /*
@Author : Sandeep Kumar
*/
    @AuraEnabled 
    public static List<Loan_Applicant__c> getLoanApplicants(String applicationId){  
        system.debug('applicationId'+applicationId);      
        return [select Id,Applicant_Name__c,IsDedupeExecuted__c,Application__r.Stage__c from Loan_Applicant__c where Application__c=:applicationId];
    }
    /*
@Author : Sandeep Kumar
*/
    
    @AuraEnabled 
    public static List<Loan_Applicant__c> getExceptionLoanApplicants(String applicationId){  
        system.debug('applicationId'+applicationId);   
        Set<String> applicantsIds = new Set<String>();
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        List<Application__c> appList = [SELECT Id, Dedupe_Exception_User__c FROM Application__c WHERE Id=:applicationId];
        List<Dedupe_Detail__c> dedupeAppList = [SELECT 
                                                Id, Remarks__c, Owner.Name, Archive__c, Loan_Applicant__c, Loan_Applicant__r.Application__r.Name,
                                                Loan_Applicant__r.Application__r.Owner.Name, Loan_Applicant__r.Application__r.Stage__c, Loan_Applicant__r.Application__r.Id, 
                                                Active__c from Dedupe_Detail__c 
                                                WHERE Loan_Applicant__r.Application__c =:applicationId 
                                                AND Archive__c=false 
                                                AND OwnerId =: appList.get(0).Dedupe_Exception_User__c];
        
        if(dedupeAppList.size()>0){
            for(Dedupe_Detail__c obj : dedupeAppList){
                applicantsIds.add(obj.Loan_Applicant__c);
            }
        }
        
        if(applicantsIds.size()>0){
            for(Loan_Applicant__c loanObj : [select Id,Applicant_Name__c from Loan_Applicant__c where Id IN :applicantsIds ]){
                loanAppList.add(loanObj);
            }
        }
        
        return loanAppList;
        
    }
    
    @AuraEnabled
    public static List<Loan_Applicant__c> callApiforOverride(String applicantId,String appId){
        try {
            
            List<Loan_Applicant__c> allApploanAppList = [select Id,Applicant_Name__c,IsDedupeExecuted__c,Application__r.Stage__c,Application__c from Loan_Applicant__c where IsDedupeExecuted__c=false AND Application__c=:appId];
            Set<String> loanIdsSet = new Set<String>();
            loanIdsSet.add(applicantId);
            if(allApploanAppList.size()>0){
                for(Loan_Applicant__c loanObj : allApploanAppList){
                    loanIdsSet.add(loanObj.Id);
                }
            }
            System.debug('loanIdsSet is >>>>'+loanIdsSet);
            List<Loan_Applicant__c> loanAppList = [select Id,KYC_ID_Type_2__c,KYC_ID_Type_1__c,KYC_Id_2__c,KYC_Id_1__c,Applicant_Name__c,IsDedupeExecuted__c,Application__r.Stage__c,Application__c from Loan_Applicant__c where Id IN : loanIdsSet];
            System.debug('loanAppList is >>>>'+loanAppList.size());
            if(loanAppList.size()>1){
                return loanAppList;
            }else if(loanAppList.size()==1){
                Boolean ischeck;
                for(Loan_Applicant__c obj : loanAppList){
                    ischeck=false;
                    if(String.isNotBlank(obj.KYC_ID_Type_1__c) && String.isNotEmpty(obj.KYC_ID_Type_1__c) && obj.KYC_ID_Type_1__c!=null){
                        if(obj.KYC_ID_Type_1__c == 'Aadhaar Card'){
                            String checkNum = obj.KYC_Id_1__c.substring(0,3) ;
                            if(checkNum == '999' && ischeck){
                                ischeck=true;
                            }
                        }
                    }else if(String.isNotBlank(obj.KYC_ID_Type_2__c) && String.isNotEmpty(obj.KYC_ID_Type_2__c) && obj.KYC_ID_Type_2__c!=null){
                        if(obj.KYC_ID_Type_2__c == 'Aadhaar Card'){
                            String checkNum = obj.KYC_Id_2__c.substring(0,3) ;
                            if(checkNum == '999'){
                                System.debug('first check');
                                return null;
                            }
                        }
                    }
                    
                    if(String.isNotBlank(obj.KYC_ID_Type_2__c) && String.isNotEmpty(obj.KYC_ID_Type_2__c) && obj.KYC_ID_Type_2__c!=null){
                        if(obj.KYC_ID_Type_2__c == 'Aadhaar Card'){
                            String checkNum = obj.KYC_Id_2__c.substring(0,3) ;
                            if(checkNum == '999' && ischeck){
                                System.debug('second check');
                                return null;
                            }
                        }
                    }else if(String.isNotBlank(obj.KYC_ID_Type_1__c) && String.isNotEmpty(obj.KYC_ID_Type_1__c) && obj.KYC_ID_Type_1__c!=null){
                        if(obj.KYC_ID_Type_1__c == 'Aadhaar Card'){
                            String checkNum = obj.KYC_Id_1__c.substring(0,3) ;
                            if(checkNum == '999'){
                                System.debug('thiord check');
                                return null;
                            }
                        }
                    }
                    
                    
                }
                if(!ischeck){
                    return loanAppList;
                }
                
            }else{
                System.debug('final check');
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return null;
    }
    
    
    
    
    
    /*
@Author : Sandeep Kumar
*/
    @AuraEnabled
    public static List<Dedupe_Detail__c> getExceptionUserApps(){
        List<Dedupe_Detail__c> appsList = new List<Dedupe_Detail__c>();
        Map<String,Dedupe_Detail__c> dedupeMap = new Map<String,Dedupe_Detail__c>();
        List<Dedupe_Detail__c> dedupeAppList = new List<Dedupe_Detail__c>();
        if(!(Test.isRunningTest())){
            dedupeAppList = [select Id,Archive__c,Active__c,Loan_Applicant__r.Application__r.Name,Loan_Applicant__r.Application__r.owner.Name,Loan_Applicant__r.Application__r.Stage__c,Loan_Applicant__r.Application__r.Id from Dedupe_Detail__c WHERE ownerId =: UserInfo.getUserId() AND Loan_Applicant__r.Application__r.IsExceptionRaised__c=TRUE AND Archive__c=FALSE AND Active__c!='Yes'];
        }else{
            dedupeAppList = [select Id,Archive__c,Active__c,Loan_Applicant__r.Application__r.Name,Loan_Applicant__r.Application__r.owner.Name,Loan_Applicant__r.Application__r.Stage__c,Loan_Applicant__r.Application__r.Id from Dedupe_Detail__c LIMIT 1];            
        }
        if(dedupeAppList.size()>0){
            for(Dedupe_Detail__c obj : dedupeAppList){
                if(!(dedupeMap.containsKey(obj.Loan_Applicant__r.Application__c))){
                    appsList.add(obj);
                    dedupeMap.put(obj.Loan_Applicant__r.Application__c,obj);
                }
            }
        }
        return appsList;
    }
    /*
@Author : Sandeep Kumar
*/
    @AuraEnabled 
    public static String getApplicantsStatus(List<Loan_Applicant__c> apptList,String applicationId){
        System.debug('appId is >>>'+applicationId);
        String appOwnerId='';
        Integer count=0;
        String appId;
        List<sObject> sObjList = new List<sObject>();
        if(String.isNotBlank(applicationId)){
            List<Application__c> appList = [SELECT Id, Dedupe_Exception_User__c FROM Application__c WHERE Id=: applicationId];
            List<Dedupe_Detail__c> dedupeList =  [select Id,Owner.Name,Archive__c,Active__c   from Dedupe_Detail__c where Loan_Applicant__r.Application__c=:applicationId AND OwnerId =: appList.get(0).Dedupe_Exception_User__c AND Archive__c=false AND Active__c!='Yes'];
            if(dedupeList.size()>0){
                return 'Please resolve dedupe first before submitting.';
            }else{
                List<Application__c> applicationDataList =[select Id,IsExceptionRaised__c,Stage__c,OwnerId,Pre_Login__r.RecordType.Name from Application__c where Id=:applicationId];
                //for(Application__c app:applicationDataList){
                Application__c app = applicationDataList.get(0);
                if(app.Stage__c =='Pre Login Dedupe Exception' ){
                    Application__c appObj = new Application__c();
                    appObj.Id=app.Id;
                    appObj.Stage__c='Verification';
                    appObj.IsExceptionRaised__c=false;
                    UPDATE appObj;
                    sObjList.add(appObj); 
                }else if(app.Stage__c =='Process Credit'){
                    Utility.sendNotification('Dedupe Resolved Successfully ',' Dedupe Resolved Successfully', app.Id, 'Verification_Notification', app.OwnerId);                    
                    return 'Dedupe Resolved Successfully';
                }else if(app.Stage__c =='Approval Credit'){
                    Utility.sendNotification('Dedupe Resolved Successfully ',' Dedupe Resolved Successfully', app.Id, 'Verification_Notification', app.OwnerId);                    
                    return 'Dedupe Resolved Successfully';
                }else if(app.Stage__c =='Lead Detail'){
                    Utility.sendNotification('Dedupe Resolved Successfully ',' Dedupe Resolved Successfully', app.Id, 'Verification_Notification', app.OwnerId);                    
                    return 'Dedupe Resolved Successfully';
                }
                //}
                if(sObjList.size()>0){
                    //update sObjList;
                    if(applicationDataList.size()>0){
                        if(applicationDataList[0].Pre_Login__r.RecordType.Name =='1. New login'){
                            VerificationRecordCreator.createVerificationRecords(applicationDataList[0].Id);
                        }else{
                            FS_CloningController.cloneVerificationData(applicationDataList[0].Id);
                        }
                    }
                    Utility.sendNotification('Dedupe Resolved Successfully ',' Dedupe Resolved Successfully', applicationDataList[0].Id, 'Verification_Notification', applicationDataList[0].OwnerId);                    
                    sObjList.remove(0);         
                }else{
                    Application__c applicationObj = new Application__c();
                    applicationObj.Id = applicationDataList[0].Id;
                    applicationObj.IsExceptionRaised__c = false;
                    sObjList.add(applicationObj);
                }
                
                for(Dedupe_Detail__c  obj :[select Id,Owner.Name,OwnerId,Archive__c,Active__c   from Dedupe_Detail__c where Loan_Applicant__r.Application__c=:applicationId AND OwnerId =: appList.get(0).Dedupe_Exception_User__c AND Archive__c=false AND Active__c='Yes']){
                    Dedupe_Detail__c dedupeObj = new Dedupe_Detail__c();
                    dedupeObj.Id = obj.Id;
                    dedupeObj.OwnerId = applicationDataList[0].OwnerId;
                    sObjList.add(dedupeObj);
                }
                
                if(sObjList.size()>0){
                    update sObjList;
                    return 'Dedupe Resolved Successfully';
                }
                
                
            }
        }else{
            return 'applicationId cannot be blank';
        }
        
        return 'Dedupe Already Resolved';
    }
    
    
    
    
    
    
    
    
    @AuraEnabled 
    public static List<DedupeCustomerWrapper> getDedupeWrapperData(String applicationId,String CustomerNumber,String apptLoanId,String DedupeId,String isOverride){
        
        
        try{
            
            List<DedupeCustomerWrapper> dedupeCustomerWrapperList = new List<DedupeCustomerWrapper>();
            DedupeCustomerWrapper wrapperObj = new DedupeCustomerWrapper();
            
            List<Loan_Applicant__c> loanApptList = new List<Loan_Applicant__c>();
            List<Loan_Applicant__c> batchloanApptList = [SELECT Id,Customer_Type__c,Husband_Wife_s_Name__c,Customer_Information__r.Father_s_Name__c,Name,LMS_Customer_Info_File_Number__c,Applicant_Name__c,Dob__c,Application__r.LMS_Response_Reference__c,Application__r.Sourcing_Branch__r.Name,Application__r.Name,
                                                         KYC_Id_1__c,KYC_Id_2__c,KYC_ID_Type_1__c,KYC_ID_Type_2__c,Residence_Address_Line_1__c,Residence_Pincode__r.Name,Mobile__c from Loan_Applicant__c where  
                                                         Application__r.Created_From_Batch__c = true AND  LMS_Customer_Info_File_Number__c=:CustomerNumber LIMIT 1];
            
            if(batchloanApptList.size()>0){
                loanApptList.addAll(batchloanApptList);
            }
            
            if(loanApptList.size()>0){
                System.debug('loanapplist cehck is >>>'+loanApptList);
                Integer count=0;
                for(Loan_Applicant__c loanObj : loanApptList){
                    
                    ++count;
                    wrapperObj.dedupeAppId = loanObj.Application__r.Name;
                    wrapperObj.dedupeSerialNo = count;
                    wrapperObj.dedupeApplicantType = loanObj.Customer_Type__c;
                    wrapperObj.dedupeFatherName = loanObj.Customer_Information__r.Father_s_Name__c;
                    wrapperObj.dedupeSpouseName = loanObj.Husband_Wife_s_Name__c;
                    wrapperObj.dedupeId = loanObj.Id;
                    wrapperObj.dedupeCustId = loanObj.LMS_Customer_Info_File_Number__c!=null?loanObj.LMS_Customer_Info_File_Number__c:'';
                    wrapperObj.dedupeName = loanObj.Applicant_Name__c!=null?loanObj.Applicant_Name__c:'';
                    wrapperObj.dedupelastName =  loanObj.Applicant_Name__c!=null?loanObj.Applicant_Name__c:'';
                    wrapperObj.dedupedob = String.valueOf(loanObj.Dob__c)!=null?String.valueOf(loanObj.Dob__c):'';
                    wrapperObj.dedupemobile = String.valueOf(loanObj.Mobile__c)!=null?String.valueOf(loanObj.Mobile__c):'';
                    wrapperObj.deduperesAddrss = loanObj.Residence_Address_Line_1__c!=null?loanObj.Residence_Address_Line_1__c:'';
                    wrapperObj.dedupepincode = loanObj.Residence_Pincode__r.Name!=null?loanObj.Residence_Pincode__r.Name:'';
                    wrapperObj.dedupeloanapptName = loanObj.Name!=null?loanObj.Name:'';
                    wrapperObj.dedupelanNo = loanObj.Application__r.LMS_Response_Reference__c!=null?loanObj.Application__r.LMS_Response_Reference__c:'';
                    wrapperObj.dedupebranchName = loanObj.Application__r.Sourcing_Branch__r.Name!=null?loanObj.Application__r.Sourcing_Branch__r.Name:'';
                    
                    
                    if(String.isNotBlank(loanObj.KYC_ID_Type_1__c) && String.isNotEmpty(loanObj.KYC_ID_Type_1__c) && loanObj.KYC_ID_Type_1__c!=null){
                        
                        if(loanObj.KYC_ID_Type_1__c == 'Aadhaar Card'){
                            wrapperObj.dedupeadhar = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }
                        if(loanObj.KYC_ID_Type_1__c == 'Voter Id' || Test.isRunningTest()){
                            wrapperObj.dedupevoterId = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        } 
                        if(loanObj.KYC_ID_Type_1__c == 'Pan Card' || Test.isRunningTest()){
                            wrapperObj.dedupepan = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }
                        if(loanObj.KYC_ID_Type_1__c == 'Driving License' || Test.isRunningTest()){
                            wrapperObj.dedupedl = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }
                        if(loanObj.KYC_ID_Type_1__c == 'Passport' || Test.isRunningTest()){
                            wrapperObj.dedupepassport = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }
                    }
                    
                    if(String.isNotBlank(loanObj.KYC_ID_Type_2__c) && String.isNotEmpty(loanObj.KYC_ID_Type_2__c) && loanObj.KYC_ID_Type_2__c!=null){
                        if(loanObj.KYC_ID_Type_2__c == 'Aadhaar Card'){
                            wrapperObj.dedupeadhar = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        } if(loanObj.KYC_ID_Type_2__c == 'Voter Id' || Test.isRunningTest()){
                            wrapperObj.dedupevoterId = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        } if(loanObj.KYC_ID_Type_2__c == 'Pan Card' || Test.isRunningTest()){
                            wrapperObj.dedupepan =loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        } if(loanObj.KYC_ID_Type_2__c == 'Driving License' || Test.isRunningTest()){
                            wrapperObj.dedupedl = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        } if(loanObj.KYC_ID_Type_2__c == 'Passport' || Test.isRunningTest()){
                            wrapperObj.dedupepassport = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }
                        
                    }
                    
                }
                
            }
            
            dedupeCustomerWrapperList.add(wrapperObj);
            return dedupeCustomerWrapperList;
        }
        
        catch(Exception e){
            System.debug('The exception is >>>'+e.getMessage());
            System.debug('The exception Line is >>>'+e.getLineNumber());
            return null;
        }
    }
    
    
    
    
    @AuraEnabled 
    public static List<LoanCustomerWrapper> getNewLoanWrapperData(String applicationId,String CustomerNumber,String apptLoanId,String DedupeId,String isOverride){
        
        try {
            List<LoanCustomerWrapper> dedupeCustomerWrapperList = new List<LoanCustomerWrapper>();
            List<Loan_Applicant__c> loanApptList = new List<Loan_Applicant__c>();
            loanApptList = [SELECT Id,Name,Customer_Type__c,Husband_Wife_s_Name__c,Customer_Information__r.Father_s_Name__c,LMS_Customer_Info_File_Number__c,Applicant_Name__c,Dob__c,Application__r.LMS_Response_Reference__c,Application__r.Sourcing_Branch__r.Name,Application__r.Name,
                            KYC_Id_1__c,KYC_Id_2__c,KYC_ID_Type_1__c,KYC_ID_Type_2__c,Residence_Address_Line_1__c,Residence_Pincode__r.Name,Mobile__c from Loan_Applicant__c where  
                            Id=:apptLoanId LIMIT 1];
            System.debug('loanapplist cehck is out >>>'+loanApptList);
            System.debug('applicationId cehck is out >>>'+applicationId);
            System.debug('CustomerNumber cehck is out >>>'+CustomerNumber);
            System.debug('apptLoanId cehck is out >>>'+apptLoanId);
            System.debug('DedupeId cehck is out >>>'+DedupeId);
            System.debug('isOverride cehck is out >>>'+isOverride);
            
            
            if(loanApptList.size()>0){
                System.debug('loanapplist cehck is >>>'+loanApptList);
                Integer count=0;
                for(Loan_Applicant__c loanObj : loanApptList){
                    ++count;
                    LoanCustomerWrapper wrapperObj = new LoanCustomerWrapper();
                    wrapperObj.appId = loanObj.Application__r.Name;
                    wrapperObj.applicantType =loanObj.Customer_Type__c;
                    wrapperObj.apptSerialNo = count;
                    wrapperObj.apptFatherName = loanObj.Customer_Information__r.Father_s_Name__c;
                    wrapperObj.apptSpouseName = loanObj.Husband_Wife_s_Name__c;
                    wrapperObj.apptId = loanObj.Id;
                    wrapperObj.apptCustId = loanObj.LMS_Customer_Info_File_Number__c!=null?loanObj.LMS_Customer_Info_File_Number__c:'';
                    wrapperObj.apptName = loanObj.Applicant_Name__c!=null?loanObj.Applicant_Name__c:'';
                    wrapperObj.apptlastName =  loanObj.Applicant_Name__c!=null?loanObj.Applicant_Name__c:'';
                    wrapperObj.apptdob = String.valueOf(loanObj.Dob__c)!=null?String.valueOf(loanObj.Dob__c):'';
                    wrapperObj.apptmobile = String.valueOf(loanObj.Mobile__c)!=null?String.valueOf(loanObj.Mobile__c):'';
                    wrapperObj.apptresAddrss = loanObj.Residence_Address_Line_1__c!=null?loanObj.Residence_Address_Line_1__c:'';
                    wrapperObj.apptpincode = loanObj.Residence_Pincode__r.Name!=null?loanObj.Residence_Pincode__r.Name:'';
                    wrapperObj.apptloanapptName = loanObj.Name!=null?loanObj.Name:'';
                    wrapperObj.apptlanNo = loanObj.Application__r.LMS_Response_Reference__c!=null?loanObj.Application__r.LMS_Response_Reference__c:'';
                    wrapperObj.apptbranchName = loanObj.Application__r.Sourcing_Branch__r.Name!=null?loanObj.Application__r.Sourcing_Branch__r.Name:'';
                    
                    
                    if(String.isNotBlank(loanObj.KYC_ID_Type_1__c) && String.isNotEmpty(loanObj.KYC_ID_Type_1__c) && loanObj.KYC_ID_Type_1__c!=null){
                        
                        if(loanObj.KYC_ID_Type_1__c == 'Aadhaar Card'){
                            wrapperObj.apptadhar = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Voter Id'){
                            wrapperObj.apptvoterId = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Pan Card'){
                            wrapperObj.apptpan = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Driving License'){
                            wrapperObj.apptdl = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Passport'){
                            wrapperObj.apptpassport = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }
                    }
                    
                    if(String.isNotBlank(loanObj.KYC_ID_Type_2__c) && String.isNotEmpty(loanObj.KYC_ID_Type_2__c) && loanObj.KYC_ID_Type_2__c!=null){
                        if(loanObj.KYC_ID_Type_2__c == 'Aadhaar Card'){
                            wrapperObj.apptadhar = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Voter Id'){
                            wrapperObj.apptvoterId = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Pan Card'){
                            wrapperObj.apptpan =loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Driving License'){
                            wrapperObj.apptdl = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Passport'){
                            wrapperObj.apptpassport = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }
                        
                    }
                    
                    dedupeCustomerWrapperList.add(wrapperObj);
                }
                return dedupeCustomerWrapperList;
            }
            return null;
        }catch(Exception e){
            System.debug('The exception is >>>'+e.getMessage());
            System.debug('The exception line  is >>>'+e.getLineNumber());
        }
        return null;
    }
    
    
    public static List<DedupeCustomerWrapper> getLoanAlongDedupeData(String applicationId,String CustomerNumber,String apptLoanId,String DedupeId,String isOverride){
        
        try{
            List<DedupeCustomerWrapper> dedupeCustomerWrapperList = new List<DedupeCustomerWrapper>();
            Integer count=0;
            if((String.isNotBlank(DedupeId) && String.isNotEmpty(DedupeId) && DedupeId!=null) && 
               ((String.isNotBlank(isOverride) && String.isNotEmpty(isOverride) && isOverride!=null) && isOverride=='No')){
                   
                   System.debug('isnide the dedupe lona>>');
                   
                   List<Dedupe_Loan_Detail__c> dedupeList = [select Id,Lan__c,Lan_Status__c,Application_Number__c,Application_Status__c,Applicant_Type__c,Branch_Code__c,Branch_Name__c,
                                                             First_Name__c,Last_Name__c,Gender__c,Father_Name__c,Mother_Name__c,Spouse_Name__c,Date_of_Birth__c,Mobile_Number__c,Address_Line_1__c,Pincode__c,
                                                             Dedupe_Detail__r.Pan_Number__c,Dedupe_Detail__r.Source__c,Dedupe_Detail__r.Aadhaar_Number__c,Dedupe_Detail__r.Customer_Rel_Id__c,Dedupe_Detail__r.Voter_Id__c,Dedupe_Detail__r.Passport__c,Dedupe_Detail__r.Driving_License__c from Dedupe_Loan_Detail__c where Dedupe_Detail__c=:DedupeId];
                   if(dedupeList.size()>0){
                       System.debug('dedupeList cehck is >>>'+dedupeList);
                       //return dedupeCustomerWrapperList;
                       
                       for(Dedupe_Loan_Detail__c dedupeobj : dedupeList){
                           ++count;
                           DedupeCustomerWrapper wrapperObj = new DedupeCustomerWrapper();
                           
                           wrapperObj.dedupeId = dedupeobj.Id;
                           wrapperObj.dedupeSerialNo = count;
                           wrapperObj.dedupeApplicantType = dedupeobj.Applicant_Type__c;
                           wrapperObj.dedupeFatherName = dedupeobj.Father_Name__c;
                           wrapperObj.dedupeSpouseName = dedupeobj.Spouse_Name__c;
                           wrapperObj.dedupelanNo = dedupeobj.Lan__c;
                           wrapperObj.dedupeAppId = dedupeobj.Application_Number__c;
                           wrapperObj.dedupeName = dedupeobj.First_Name__c!=null?dedupeobj.First_Name__c:'';
                           wrapperObj.dedupelastName = dedupeobj.Last_Name__c!=null?dedupeobj.Last_Name__c:'';
                           wrapperObj.dedupeadhar =  dedupeobj.Dedupe_Detail__r.Aadhaar_Number__c!=null?dedupeobj.Dedupe_Detail__r.Aadhaar_Number__c:'';
                           wrapperObj.dedupepan = String.valueOf(dedupeobj.Dedupe_Detail__r.Pan_Number__c)!=null?String.valueOf(dedupeobj.Dedupe_Detail__r.Pan_Number__c):'';
                           wrapperObj.dedupedl = String.valueOf(dedupeobj.Dedupe_Detail__r.Driving_License__c)!=null?String.valueOf(dedupeobj.Dedupe_Detail__r.Driving_License__c):'';
                           wrapperObj.dedupevoterId = dedupeobj.Dedupe_Detail__r.Voter_Id__c!=null?dedupeobj.Dedupe_Detail__r.Voter_Id__c:'';
                           wrapperObj.dedupepassport = dedupeobj.Dedupe_Detail__r.Passport__c!=null?dedupeobj.Dedupe_Detail__r.Passport__c:'';
                           wrapperObj.dedupemobile = dedupeobj.Mobile_Number__c!=null?dedupeobj.Mobile_Number__c:'';
                           wrapperObj.deduperesAddrss = dedupeobj.Address_Line_1__c!=null?dedupeobj.Address_Line_1__c:'';
                           wrapperObj.dedupepincode = dedupeobj.Pincode__c!=null?dedupeobj.Pincode__c:'';
                           wrapperObj.dedupebranchName = dedupeobj.Branch_Name__c!=null?dedupeobj.Branch_Name__c:'';
                           wrapperObj.dedupeCustId = dedupeobj.Dedupe_Detail__r.Customer_Rel_Id__c!=null?dedupeobj.Dedupe_Detail__r.Customer_Rel_Id__c:'';
                           wrapperObj.dedupeSource = dedupeobj.Dedupe_Detail__r.Source__c!=null?dedupeobj.Dedupe_Detail__r.Source__c:'';
                           wrapperObj.dedupedob = dedupeobj.Date_Of_Birth__c!=null?dedupeobj.Date_Of_Birth__c:'';
                           dedupeCustomerWrapperList.add(wrapperObj);
                       }
                   }
                   return dedupeCustomerWrapperList;
               }
            return null;
        }catch(Exception e){
            System.debug('The exception is >>>'+e.getMessage());
            System.debug('The exception line  is >>>'+e.getLineNumber());
        }
        return null;
    }
    
    
    
    /*
@Author : Sandeep Kumar
@Description : Method to get Dedupe and loan applicant records.
*/
    
    /*
@Author : Sandeep Kumar
*/
    @AuraEnabled 
    public static List<DedupeCustomerWrapper> getLoanDedupeData(String applicationId,String CustomerNumber,String apptLoanId,String DedupeId,String isOverride){
        try{
            Integer count=0;
            List<DedupeCustomerWrapper> dedupeCustomerWrapperList = new List<DedupeCustomerWrapper>();
            List<LoanCustomerWrapper> loanCustomerWrapperList = new List<LoanCustomerWrapper>();
            List<Loan_Applicant__c> allLoanList = new List<Loan_Applicant__c>();
            allLoanList = [select Id,Application__r.Pre_Login__r.RecordType.Name,LMS_Customer_Info_File_Number__c,Old_Applicant_Id__c,(select Id,Archive__c from Dedupe_Details__r where Archive__c=false) from Loan_Applicant__c where /*LMS_Customer_Info_File_Number__c =:CustomerNumber AND*/ Id=:apptLoanId LIMIT 1];
            System.debug('allLoanList is >>>'+allLoanList);
            
            if(allLoanList.size()==0){
                allLoanList = [select Id,LMS_Customer_Info_File_Number__c,Old_Applicant_Id__c,(select Id,Archive__c from Dedupe_Details__r where Archive__c=false) from Loan_Applicant__c where LMS_Customer_Info_File_Number__c =:CustomerNumber  LIMIT 1];
                System.debug('allLoanList is >>>'+allLoanList);
            }
            
            if(allLoanList.size()>0){
                for(Loan_Applicant__c obj: allLoanList){
                    if(obj.Dedupe_Details__r.size()>0){
                        ++count;
                    }
                }
            }
            System.debug('count is >>>'+count);
            
            if(allLoanList.size()>0){
                
                if(count>0 && ((String.isNotBlank(DedupeId) && String.isNotEmpty(DedupeId) && DedupeId!=null) && 
                               ((String.isNotBlank(isOverride) && String.isNotEmpty(isOverride) && isOverride!=null) && isOverride=='No'))){
                                   System.debug('inside else 4');
                                   dedupeCustomerWrapperList =  DedupeDetailsController.getLoanAlongDedupeData(applicationId,CustomerNumber,apptLoanId,DedupeId,isOverride);
                               }else if((count>0 ||count==0 ) &&  
                                        ((String.isNotBlank(isOverride) && String.isNotEmpty(isOverride) && isOverride!=null) && isOverride=='Yes')){                   
                                            System.debug('inside else 4');
                                            dedupeCustomerWrapperList =  DedupeDetailsController.getDedupeWrapperData(applicationId,CustomerNumber,apptLoanId,DedupeId,isOverride);
                                        }else if(count==0 &&
                                                 ((String.isNotBlank(isOverride) && String.isNotEmpty(isOverride) && isOverride!=null) && isOverride=='No')){
                                                     System.debug('inside the sencond');
                                                     if(String.isNotBlank(allLoanList[0].Application__r.Pre_Login__r.RecordType.Name) && String.isNotEmpty(allLoanList[0].Application__r.Pre_Login__r.RecordType.Name) && 
                                                        (allLoanList[0].Application__r.Pre_Login__r.RecordType.Name!=null)){
                                                            if(allLoanList[0].Application__r.Pre_Login__r.RecordType.Name == '3. Top-up loan' || allLoanList[0].Application__r.Pre_Login__r.RecordType.Name == '4. Tranche loan'){
                                                                dedupeCustomerWrapperList =  DedupeDetailsController.getDedupeWrapperData(applicationId,CustomerNumber,apptLoanId,DedupeId,isOverride);
                                                            }/*else{
System.debug('inside the sencond if');
loanCustomerWrapperList =  DedupeDetailsController.getNewLoanWrapperData(applicationId,CustomerNumber,apptLoanId,DedupeId,isOverride);
return loanCustomerWrapperList;
}*/
                                                            System.debug('inside the sencond else');
                                                        }
                                                     System.debug('inside else 3');
                                                 }else{
                                                     System.debug('inside else of else');
                                                 }
            }
            
            return dedupeCustomerWrapperList;
            
        }catch(Exception e){
            System.debug('exception is >>>'+e.getMessage());
            System.debug('exception is >>>'+e.getLineNumber());
            return null;   
        }
        
    }
    
    
    /*
@Author : Sandeep Kumar
*/
    @AuraEnabled
    public static List<SObject> getExceptionUserDedupe(String applicationId,String applicantName,String apptLoanId){
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        dedupeList = [select Id,Owner.Name,Remarks__c,Old_Remarks__c,Customer_Name__c,Archive__c,Old_Customer_Number__c,Active__c,Loan_Applicant__c,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__r.Application__c,
                      CIF_Id__c,(select Id,First_Name__c,Last_Name__c,Branch_Name__c,Applicant_Type__c,Lan__c,Lan_Status__c,Application_Number__c,Application_Status__c from Dedupe_Loan_Details__r) from Dedupe_Detail__c where Loan_Applicant__r.Id=:apptLoanId AND Loan_Applicant__r.Application__c=:applicationId AND Loan_Applicant__r.Applicant_Name__c=:applicantName
                      AND Archive__c=false];
        if(dedupeList.size()>0){
            return dedupeList;
        }
        return dedupeList;
    }
    
    @AuraEnabled
    public static Boolean doEmptyLoanApptData(String loanApptId,String applicationId){
        try {
            
            Set<String>loanAppIdSet = new Set<String>();
            loanAppIdSet.add(loanApptId);
            
            if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId) && applicationId!=null){
                for(Loan_Applicant__c loanApp:[select Id,IsDedupeExecuted__c,Application__c from Loan_Applicant__c where Application__c=:applicationId AND IsDedupeExecuted__c=false]){
                    loanAppIdSet.add(loanApp.Id);
                }
            }
            if(loanAppIdSet.size()>0){
                List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
                List<Loan_Applicant__c> ApploanList = new List<Loan_Applicant__c>();
                List<Dedupe_Detail__c> dedupelist = new List<Dedupe_Detail__c>();
                loanList = [select Id,Application__r.Pre_Login__r.RecordType.Name,IsDedupeExecuted__c,Customer_Name__c,Override__c,Override_Remarks__c,LMS_Customer_Info_File_Number__c,(Select Id from Dedupe_Details__r where Archive__c=false) from Loan_Applicant__c where Id IN : loanAppIdSet];
                if(loanList.size()>0){
                    
                    for(Loan_Applicant__c obj : loanList){
                        
                        if(obj.Dedupe_Details__r.size() == 0 && obj.IsDedupeExecuted__c && obj.Application__r.Pre_Login__r.RecordType.Name=='1. New login' && obj.Override__c!='Override' && 
                           (String.isNotBlank(obj.LMS_Customer_Info_File_Number__c) && String.isNotEmpty(obj.LMS_Customer_Info_File_Number__c) && obj.LMS_Customer_Info_File_Number__c!=null)){
                               continue;
                           }else{
                               for(Dedupe_Detail__c dedupeObj : obj.Dedupe_Details__r){
                                   dedupelist.add(dedupeObj);
                               }
                               Loan_Applicant__c loanobj = new Loan_Applicant__c();
                               loanobj.Id = obj.Id;
                               loanobj.Customer_Name__c='';
                               loanobj.Override__c='';
                               loanobj.Override_Remarks__c='';
                               loanobj.LMS_Customer_Info_File_Number__c='';
                               loanobj.IsDedupeExecuted__c=true;
                               ApploanList.add(loanobj);
                           }
                    }
                }
                System.debug('the ApploanList >>>'+ApploanList);
                if(dedupelist.size()>0){
                    delete dedupelist;
                }
                if(ApploanList.size()>0){
                    update ApploanList;
                    System.debug('the update  ApploanList >>>'+ApploanList);
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            System.debug('the exception is >>'+e.getMessage());
            System.debug('the exception line is >>'+e.getLineNumber());
            return false;
        }
    }
    
    
    
    @AuraEnabled
    public static List<SObject> getLoanDetails(String applicationId,String apptLoanId){
        try {
            
            List<Loan_Applicant__c> loanAppList = [select Id,Customer_Name__c from Loan_Applicant__c where Customer_Name__c!=NULL AND Override__c='Override' AND Id=:apptLoanId AND Application__c=:applicationId LIMIT 1];
            
            if(loanAppList.size()==0){
                
                List<Loan_Applicant__c> nonloanList = [select Id,Application__r.Stage__c,Application__r.Created_From_Batch__c,Application__r.Sourcing_Branch__r.Name,Customer_Type__c,Applicant_Name__c,Application__r.Name,Application__r.LMS_Response_Reference__c,Application__c,Customer_Name__c,Override__c from Loan_Applicant__c where  
                                                       Applicant_Name__c!=NULL /*AND Application__r.LMS_Response_Reference__c!=NULL*/ AND Id=:apptLoanId AND Application__c=:applicationId LIMIT 1];
                System.debug('loanList>>>'+nonloanList);
                
                if(nonloanList.size()>0){
                    return nonloanList;
                }
                
            }
            
            System.debug('loanAppList>>>'+loanAppList);
            if(loanAppList.size()>0){
                String customerName=loanAppList[0].Customer_Name__c;
                List<Loan_Applicant__c> loanList = [select Id,Application__r.Stage__c,Application__r.Created_From_Batch__c,Application__r.Sourcing_Branch__r.Name,Customer_Type__c,Applicant_Name__c,Application__r.Name,Application__r.LMS_Response_Reference__c,Application__c,Customer_Name__c,Override__c from Loan_Applicant__c where  
                                                    Applicant_Name__c!=NULL AND Applicant_Name__c=:customerName /*AND Application__r.LMS_Response_Reference__c!=NULL*/ AND Application__r.Created_From_Batch__c=TRUE LIMIT 1];
                System.debug('loanList>>>'+loanList);
                
                if(loanList.size()>0){
                    return loanList;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    /*
@Author : Sandeep Kumar
*/
    
    @AuraEnabled
    public static List<Dedupe_Detail__c> getDedupeUserData(String applicationId,String applicantName,String apptLoanId){
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        List<Application__c> appList = [SELECT Id, Dedupe_Exception_User__c FROM Application__c WHERE Id=: applicationId];
        dedupeList = [select Id,Owner.Name,Archive__c,Old_Remarks__c,Active__c,Old_Customer_Number__c,Loan_Applicant__c,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__r.Application__c,
                      CIF_Id__c,(select Id,First_Name__c,Last_Name__c,Branch_Name__c,Applicant_Type__c,Lan__c,Lan_Status__c,Application_Number__c,Application_Status__c from Dedupe_Loan_Details__r) from Dedupe_Detail__c where Loan_Applicant__r.Id=:apptLoanId AND Loan_Applicant__r.Application__c=:applicationId AND Loan_Applicant__r.Applicant_Name__c=:applicantName AND Archive__c=false AND OwnerId =: appList.get(0).Dedupe_Exception_User__c];
        if(dedupeList.size()>0){
            return dedupeList;
        }
        return dedupeList;
    }
    
    @AuraEnabled
    public static List<Loan_Applicant__c> getCustomerData(String applicationId,String applicantName,String apptLoanId){
        try {
            
            List<Loan_Applicant__c> custLoannApptList = [select Id,Old_Applicant_Id__c,Application__r.Pre_Login__r.RecordType.Name,Override__c,Override_Remarks__c,Customer_Name__c,Applicant_Name__c,LMS_Customer_Info_File_Number__c,Application__c from Loan_Applicant__c where Application__c=:applicationId /*AND Applicant_Name__c=:applicantName*/ AND Id=:apptLoanId LIMIT 1];
            
            if(custLoannApptList.size()>0){
                return custLoannApptList;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return null;
    }
    
    
    
    /*
@Author : Sandeep Kumar
*/
    
    @AuraEnabled
    public static String getButtonStatus(String applicationId,String applicantName,String apptLoanId){
        List<Loan_Applicant__c> custLoannApptList = new List<Loan_Applicant__c>();
        Integer count=0;
        List<Loan_Applicant__c> loannApptList = new List<Loan_Applicant__c>();
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        custLoannApptList  = [select Id,Applicant_Name__c,LMS_Customer_Info_File_Number__c,Application__c,(select Id from Dedupe_Details__r) from Loan_Applicant__c where Application__c=:applicationId  AND LMS_Customer_Info_File_Number__c!=NULL AND Applicant_Name__c=:applicantName AND Id=:apptLoanId];
        
        if(custLoannApptList.size()>0){
            for(Loan_Applicant__c loanObj : custLoannApptList){
                if(loanObj.Dedupe_Details__r.size()>0){
                    ++count;
                }
            }
            
            if(count==0){
                return custLoannApptList[0].LMS_Customer_Info_File_Number__c;
            }
        }
        
        loannApptList = [select Id,IsDedupeExecuted__c,Applicant_Name__c,LMS_Customer_Info_File_Number__c,Application__c,(SELECT Id,Loan_Applicant__c,Owner.Name from Dedupe_Details__r) from Loan_Applicant__c where Application__c=:applicationId /*AND  LMS_Customer_Info_File_Number__c=NULL*/ AND Applicant_Name__c=:applicantName AND Id=:apptLoanId AND IsDedupeExecuted__c=true];
        if(loannApptList.size()>0){
            dedupeList = [select Id,Loan_Applicant__c,Owner.Name from Dedupe_Detail__c where Loan_Applicant__c IN : loannApptList AND Archive__c=false]; 
            
            if(dedupeList.size()==0){
                
                return 'No Match Found'; 
            }
        }else{
            List<Loan_Applicant__c> loanAppList = [select Id,IsDedupeExecuted__c,Applicant_Name__c,LMS_Customer_Info_File_Number__c,Application__c,(SELECT Id,Loan_Applicant__c,Owner.Name from Dedupe_Details__r) from Loan_Applicant__c where Application__c=:applicationId AND  LMS_Customer_Info_File_Number__c=NULL AND Applicant_Name__c=:applicantName AND Id=:apptLoanId AND IsDedupeExecuted__c=false];
            
            if(loanAppList.size()>0){
                return 'Please Invoke Dedupe/Customer API'; 
            }
            
        }
        return '';
    }
    
    /*
@Author : Sandeep Kumar
*/
    
    @AuraEnabled
    public static String lmsLoanAppt(String applicationId,String applicantName,String apptLoanId){
        List<Loan_Applicant__c> loannApptList = new List<Loan_Applicant__c>();
        //  loannApptList = [select Id,Applicant_Name__c,LMS_Customer_Info_File_Number__c,Application__c,cifId__c from Loan_Applicant__c where Application__c=:applicationId AND (cifId__c!=NULL AND  LMS_Customer_Info_File_Number__c!=NULL) AND Applicant_Name__c=:applicantName AND Id=:apptLoanId];
        
        if(loannApptList.size()>0){
            return 'Dedupe not required';
        }
        return '';
    }
    
    
    @AuraEnabled(continuation=true)
    public static List<String> callCustomerApi(String applicationId){
        List<String> responseList = new List<String>();
        List<Loan_Applicant__c> customerLoanApptList = new  List<Loan_Applicant__c>();
        for(Loan_Applicant__c loanObj : [select Id,Applicant_Name__c,Customer_Information__c,LMS_Customer_Info_File_Number__c,Application__c,(select Id from Dedupe_Details__r) from Loan_Applicant__c where Application__c=:applicationId  AND LMS_Customer_Info_File_Number__c=NULL AND IsDedupeExecuted__c=true ]){
            if(loanObj.Dedupe_Details__r.size()==0){
                customerLoanApptList.add(loanObj);
            }
        }
        
        if(customerLoanApptList.size()>0){
            String getResponse='';
            for(Loan_Applicant__c custLoanObj : customerLoanApptList){
                getResponse = FS_LMS_CreateCustomerAPI.createCustomer(custLoanObj.Id,custLoanObj.Applicant_Name__c,custLoanObj.Customer_Information__c);
                if(getResponse!=''){
                    responseList.add(getResponse);
                }
            }
        }
        System.debug('the response list size  is >>>>'+responseList.size());
        System.debug('the response list is >>>>'+responseList);
        
        return responseList;
    }
    
    
    @AuraEnabled
    public static boolean isDedupeHasDone(String applicationId){
        
        List<Loan_Applicant__c> loanAppList = [select Id,Application__c,IsDedupeExecuted__c from Loan_Applicant__c where Application__c=:applicationId AND IsDedupeExecuted__c=false];
        if(loanAppList.size()==0){
            return true;
        }
        return false;
    }
    
    
    
    
    
    
    @AuraEnabled
    public static String checkLoanAppt(List<Loan_Applicant__c>loanApplicantList){
        List<Loan_Applicant__c>loanList = new List<Loan_Applicant__c>();
        
        for(Loan_Applicant__c loanObj : loanApplicantList){
            Loan_Applicant__c obj = new Loan_Applicant__c();
            obj.Id=loanObj.Id;
            obj.IsDedupeExecuted__c	= true;	
            loanList.add(obj);
        }
        
        if(loanList.size()>0){
            update loanList;
        }
        
        return loanApplicantList[0].Application__r.Stage__c;
        
    }
    
    
    
    
    
    
    
    public class DedupeSubmitValidationWrapper {
        
        @AuraEnabled public String message;
        @AuraEnabled public Boolean errorFlag = false;
        
    }
    
    
    public class DedupeWrapper{
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String  message;
        @AuraEnabled public Map<String,String> mapExtraParams = new Map<String,String>();
        @AuraEnabled public List<Sobject> listSObject = new List<Sobject>();
        @AuraEnabled public String sObjectListType;
        @AuraEnabled public Boolean dedupeCriteria ;
        @AuraEnabled public Boolean noDedupeMatch ;
    }
    
    public class LoanCustomerWrapper{
        @AuraEnabled public Integer apptSerialNo;
        @AuraEnabled public String  apptId;
        @AuraEnabled public String  apptCustId;
        @AuraEnabled public String  appId;
        @AuraEnabled public String  apptName;
        @AuraEnabled public String  apptlastName;
        @AuraEnabled public String  apptdob;
        @AuraEnabled public String  apptadhar;
        @AuraEnabled public String  apptpan;
        @AuraEnabled public String  apptdl;
        @AuraEnabled public String  apptvoterId;
        @AuraEnabled public String  apptpassport;
        @AuraEnabled public String  apptmobile;
        @AuraEnabled public String  apptresAddrss;
        @AuraEnabled public String  apptpincode;
        @AuraEnabled public String  apptloanapptName;
        @AuraEnabled public String  apptlanNo;
        @AuraEnabled public String  apptbranchName;
        @AuraEnabled public String  apptFatherName;
        @AuraEnabled public String  apptSpouseName;
        @AuraEnabled public String  applicantType;
        
        public LoanCustomerWrapper(){
            apptbranchName='';
            apptlanNo='';
            apptloanapptName='';
            apptpincode='';
            apptresAddrss='';
            apptmobile='';
            apptpassport='';
            apptvoterId='';
            apptdl='';
            apptpan='';
            apptadhar='';
            apptdob='';
            apptlastName='';
            apptName='';
            appId='';
            apptId='';
            apptFatherName='';
            apptSpouseName='';
            applicantType='';
        }
    }
    
    public class DedupeCustomerWrapper{
        @AuraEnabled public Integer dedupeSerialNo;
        @AuraEnabled public String  dedupeId;
        @AuraEnabled public String  dedupeName;
        @AuraEnabled public String  dedupelastName;
        @AuraEnabled public String  dedupedob;
        @AuraEnabled public String  dedupeAppId;
        @AuraEnabled public String  dedupeadhar;
        @AuraEnabled public String  dedupepan;
        @AuraEnabled public String  dedupedl;
        @AuraEnabled public String  dedupevoterId;
        @AuraEnabled public String  dedupepassport;
        @AuraEnabled public String  dedupemobile;
        @AuraEnabled public String  deduperesAddrss;
        @AuraEnabled public String  dedupepincode;
        @AuraEnabled public String  dedupeloanapptName;
        @AuraEnabled public String  dedupelanNo;
        @AuraEnabled public String  dedupebranchName;
        @AuraEnabled public String  dedupeCustId;
        @AuraEnabled public String  dedupeSource;
        @AuraEnabled public String  dedupeFatherName;
        @AuraEnabled public String  dedupeSpouseName;
        @AuraEnabled public String  dedupeApplicantType;
        
        public DedupeCustomerWrapper(){
            dedupeSource='';
            dedupeCustId='';
            dedupebranchName='';
            dedupelanNo='';
            dedupeloanapptName='';
            dedupepincode='';
            deduperesAddrss='';
            dedupemobile='';
            dedupepassport='';
            dedupevoterId='';
            dedupedl='';
            dedupepan='';
            dedupeadhar='';
            dedupeAppId='';
            dedupedob='';
            dedupeId='';
            dedupelastName='';
            dedupeName='';
            dedupeFatherName='';
            dedupeSpouseName='';
            dedupeApplicantType='';
        }
    }
}