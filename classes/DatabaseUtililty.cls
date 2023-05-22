public without sharing class DatabaseUtililty {
    
    /******************** GENERATE REPORT METHODS STARTS ***************************/
    
    @AuraEnabled    
    public static ContentWrapper generateFIVCPdf(String verificationId, String applicationId){
        ContentWrapper wrap = new ContentWrapper();
        try{
            PageReference pdf = Page.FIVCReportVf;
            pdf.getParameters().put('applicationId',applicationId);
            Blob body;
            
            //List<ContentVersion> fivCReport = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: applicationId AND File_Type__c='FIV - C Report'];
            String title = 'FIV-C Report'; // + (fivCReport != NULL && !fivCReport.isEmpty() ? (fivCReport.size() + 1)+'' : '1');
                if(Test.isRunningTest()) { 
                    body = blob.valueOf('Unit.Test');
                } else {
                    body = pdf.getContentAsPDF();
                }   
            System.debug('Body '+body);
            ContentVersion cv = new ContentVersion(Title = title ,File_Type__c='FIV - C Report', PathOnClient ='FIV-C Report.PDF', VersionData = body, FirstPublishLocationId = applicationId, Is_Additional_Document__c = true, Uploaded_From__c = 'FIV - C', Parent_Id__c = applicationId);
            System.debug('CV '+cv);
            insert cv;
            wrap = generateDownloadURL(cv.Id);
        }
        catch(Exception e){
            System.debug(e.getLineNumber()+' '+e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Description__c =  e.getMessage(); 
            objErrorLog.Name = 'FIV-C Report Generate Document';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            objErrorLog.Application__c = applicationId;
            insert objErrorLog;
            wrap.contentDocId = null;
            wrap.downloadURL = null;
            wrap.message = e.getMessage();
        }
        return wrap;
    }
    
    @AuraEnabled    
    public static ContentWrapper generateDisbMemoPdf(String applicationId){
        ContentWrapper wrap = new ContentWrapper();
        try{
            PageReference pdf = Page.Disbursement_MemoVfPage;
            pdf.getParameters().put('Id',applicationId);
            Blob body;
            
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }   
            System.debug('Body '+body);
            ContentVersion cv = new ContentVersion(Title = 'Disbursal Memo', PathOnClient ='Disbursal Memo.PDF', VersionData = body, FirstPublishLocationId = applicationId, Is_Additional_Document__c = true, Uploaded_From__c = 'Disbursal Maker', Parent_Id__c = applicationId);
            System.debug('CV '+cv);
            insert cv;
            wrap = generateDownloadURL(cv.Id);
        }
        catch(Exception e){
            System.debug(e.getLineNumber()+' '+e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Description__c =  e.getMessage(); 
            objErrorLog.Name = 'Disbursal Memo Generate Document';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            objErrorLog.Application__c = applicationId;
            insert objErrorLog;
            wrap.contentDocId = null;
            wrap.downloadURL = null;
            wrap.message = e.getMessage();
        }
        return wrap;
    }
    
    @AuraEnabled 
    public static ContentWrapper generateCamReport(String currentApplicationId, String stage){
        ContentWrapper wrap = new ContentWrapper();
        try{
            PageReference pdf = Page.CAMReportVf;
            pdf.getParameters().put('id',currentApplicationId);
            Blob body;
            if(stage == 'Process Credit'){
                pdf.getParameters().put('Generated_From','PC');
            }else {
                pdf.getParameters().put('Generated_From','AC');
            }
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }    
            ContentVersion cv = new ContentVersion(File_Type__c='CAM Report', PathOnClient ='CAM Report.PDF', VersionData = body, FirstPublishLocationId = currentApplicationId,Is_Additional_Document__c=true,Uploaded_From__c = stage);
            
            if(stage == 'Process Credit'){
                cv.Title = 'PC CAM Report';            
            }
            else if(stage == 'Approval Credit'){
                cv.Title = 'AC CAM Report';
            }
            insert cv;
            wrap = generateDownloadURL(cv.Id);
        }
        catch(Exception e){
            System.debug(e.getLineNumber()+' '+e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Description__c =  e.getMessage(); 
            objErrorLog.Name = stage+' CAM Report Generate Document';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            objErrorLog.Application__c = currentApplicationId;
            insert objErrorLog;
            wrap.contentDocId = null;
            wrap.downloadURL = null;
            wrap.message = e.getMessage();
        }
        return wrap;
    }    
    
    @AuraEnabled 
    public static ContentWrapper generateLegalCamReport(String applicationId){
        ContentWrapper wrap = new ContentWrapper();
        try{
            PageReference pdf = Page.LegalCamReport_VfPage;
            pdf.getParameters().put('id',applicationId);
            Blob body;
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }  
            ContentVersion cv = new ContentVersion(Title = 'Legal Approval Cam Report',File_Type__c='Legal Approval Cam Report', PathOnClient ='Legal Cam Report.PDF',Is_Additional_Document__c = true,Uploaded_From__c='Legal Approval', VersionData = body, FirstPublishLocationId = applicationId);
            INSERT cv; 
            wrap = generateDownloadURL(cv.Id);
        }
        catch(Exception e){
            System.debug(e.getLineNumber()+' '+e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Description__c =  e.getMessage(); 
            objErrorLog.Name = 'Legal Approval Cam Report Generate Document';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            objErrorLog.Application__c = applicationId;
            insert objErrorLog;
            wrap.contentDocId = null;
            wrap.downloadURL = null;
            wrap.message = e.getMessage();
        }
        return wrap;
    }
    
    @AuraEnabled
    public static ContentWrapper generateAcknowledgementSlip(String recordId){
        ContentWrapper wrap = new ContentWrapper();
        try{
            PageReference pdf;
            pdf = Page.AcknowledgementSlipVf; 
            pdf.getParameters().put('applicationId',recordId);
            Blob body;   
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }    
            ContentVersion cv = new ContentVersion(Title = 'Acknowledgement_Slip', PathOnClient ='Acknowledgement_Slip.PDF', VersionData = body, FirstPublishLocationId = recordId, Uploaded_From__c = 'Agreement Execution',Is_Additional_Document__c  = true);
            INSERT cv;
            wrap = generateDownloadURL(cv.Id);
        }
        catch(Exception e){
            System.debug(e.getLineNumber()+' '+e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Description__c =  e.getMessage(); 
            objErrorLog.Name = 'Acknowledgement Slip Generate Document';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            objErrorLog.Application__c = recordId;
            insert objErrorLog;
            wrap.contentDocId = null;
            wrap.downloadURL = null;
            wrap.message = e.getMessage();
        }
        return wrap;
        
    }
    
    @AuraEnabled    
    public static ContentWrapper generateFIVBPdf(String verificationId, String applicationId){  
        ContentWrapper wrap = new ContentWrapper();
        try{
            PageReference pdf = Page.FIVBReportVf;
            pdf.getParameters().put('applicationId',applicationId);
            pdf.getParameters().put('verificationId',verificationId);
            Blob body;
            
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }    
            
            ContentVersion cv = new ContentVersion(Title = 'FIV-B Report', PathOnClient ='FIV-B Report.PDF', VersionData = body, FirstPublishLocationId = applicationId,Is_Additional_Document__c = true,Uploaded_From__c='FIV - B');
            Insert cv;
            wrap = generateDownloadURL(cv.Id);
        }
        catch(Exception e){
            System.debug(e.getLineNumber()+' '+e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Description__c =  e.getMessage(); 
            objErrorLog.Name = 'FIV-B Report Generate Document';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            objErrorLog.Application__c = applicationId;
            insert objErrorLog;
            wrap.contentDocId = null;
            wrap.downloadURL = null;
            wrap.message = e.getMessage();
        }
        return wrap;
        
    }
    
    @AuraEnabled
    public static void deleteContentDocument(String recId){
        DELETE [SELECT Id FROM ContentDocument WHERE Id=:recId];
    }
    
    public static ContentWrapper generateDownloadURL(String conVerId){
        ContentVersion cVer = [Select Id,Title,ContentDocumentId From ContentVersion WHERE Id = :conVerId];
        ContentDistribution cDist = new ContentDistribution();
        cDist.ContentVersionId = conVerId;
        cDist.Name = cVer.Title;
        cDist.PreferencesAllowViewInBrowser= true;
        cDist.PreferencesLinkLatestVersion=true;
        cDist.PreferencesNotifyOnVisit=false;
        cDist.PreferencesPasswordRequired=false;
        cDist.PreferencesAllowOriginalDownload= true;
        INSERT cDist;
        ContentDistribution conDist = [Select Id,ContentDownloadUrl From ContentDistribution WHERE Id = :cDist.Id];
        ContentWrapper wrap = new ContentWrapper();
        wrap.contentDocId = cVer.ContentDocumentId;
        wrap.downloadURL = conDist.ContentDownloadUrl;
        wrap.message = null;
        return wrap;
    }
    
    public class ContentWrapper{
        @AuraEnabled public String contentDocId;
        @AuraEnabled public String downloadURL;
        @AuraEnabled public String message;
    }
    
    /******************** GENERATE REPORT METHODS ENDS ***************************/
    
    
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document_Visibility__c.Visible_Reports__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static String getApplicationId(String recId){
        Loan_Applicant__c loanApp = [SELECT Application__c FROM Loan_Applicant__c WHERE Id = :recId];
        return loanApp.Application__c;
    }
    
    @AuraEnabled
    public static List<String> getDocumentRoles(){
        String userId = UserInfo.getUserId();
        Set<String> documentRoles = new Set<String>();
        List<Access_Master__c> accesses = [SELECT Id, Access_For__c FROM Access_Master__c WHERE User__c =: userId];
        if(accesses != NULL && !accesses.isEmpty()){
            Set<String> userRoles = new Set<String>();
            for(Access_Master__c accessObj : accesses){
                if(String.isNotBlank(accessObj.Access_For__c)){
                    userRoles.add(accessObj.Access_For__c);
                }
            }
            
            if(!userRoles.isEmpty()){                
                List<Document_Visibility__c> documentVisibility = [SELECT Id, Role__c, Visible_Documents__c FROM Document_Visibility__c WHERE Role__c IN : userRoles];
                for(Document_Visibility__c dvObj : documentVisibility ){
                    if(String.isNotBlank(dvObj.Visible_Documents__c)){
                        documentRoles.addAll(dvObj.Visible_Documents__c.split(';'));
                    }
                }
            }
        }
        
        if(!documentRoles.isEmpty()){
            return new List<String>(documentRoles);
        }
        return null;
    }
    
    @AuraEnabled
    public static String userProfile(){
        return [SELECT Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
    }
    
    @AuraEnabled
    public static List<String> getUserReports(){
        String userId = UserInfo.getUserId();
        String userProfile = userProfile();
        Set<String> visibleReports = new Set<String>();
        List<Access_Master__c> accesses = [SELECT Id, Access_For__c FROM Access_Master__c WHERE User__c =: userId];
        if(accesses != NULL && !accesses.isEmpty()){
            Set<String> userRoles = new Set<String>();
            for(Access_Master__c accessObj : accesses){
                if(String.isNotBlank(accessObj.Access_For__c)){
                    userRoles.add(accessObj.Access_For__c);
                }
            }
            
            if(!userRoles.isEmpty()){                
                List<Document_Visibility__c> documentVisibility = [SELECT Id, Role__c, Visible_Reports__c FROM Document_Visibility__c WHERE Role__c IN : userRoles];
                for(Document_Visibility__c dvObj : documentVisibility ){
                    if(String.isNotBlank(dvObj.Visible_Reports__c)){
                        visibleReports.addAll(dvObj.Visible_Reports__c.split(';'));
                    }
                }
            }
        }
        if(userProfile == 'System Administrator'){
            return new List<String>(getPickListValuesIntoList());
        }
        if(!visibleReports.isEmpty()){
            return new List<String>(visibleReports);
        }
        return null;
    }
    
    @AuraEnabled
    public static RecordIdWrapper getRecordIdsFromBankDEtails(String recId){
        Bank_Detail__c bank = [SELECT Application__c,Loan_Applicant__c FROM Bank_Detail__c WHERE Id = :recId];
        RecordIdWrapper records = new RecordIdWrapper();
        records.appId = bank.Application__c;
        records.loanAppId = bank.Loan_Applicant__c;
        return records;
    }
    
    @AuraEnabled
    public static RecordIdWrapper getRecordIdsFromDisbPayeeDEtails(String recId){
        Disbursal_Payee__c bank = [SELECT Id,Application__c FROM Disbursal_Payee__c WHERE Id = :recId];
        RecordIdWrapper records = new RecordIdWrapper();
        records.appId = bank.Application__c;
        return records;
    }
    
    @AuraEnabled
    public static String getRecordTypeId(String sObjectName, String recordTypeName){
        return Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    
    @AuraEnabled
    public static List<Application__c> getApplicationDetails(String appId){
        return [SELECT Id, Name, Pre_Login__c, Total_Amount_Recommended_PcAc__c FROM Application__c WHERE Id =: appId LIMIT 1];
    }
    
    @AuraEnabled
    public static List<Verification__c> getVerification(String recordId){
        return [SELECT Id, Application__c FROM Verification__c WHERE Id =: recordId AND RecordType.Name = 'FIV - C'];
    }
    
    @AuraEnabled
    public static Map<Id,Account> getApplicantRecords(String appId){
        Set<String> applicantIds = new Set<String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: appId]){
            applicantIds.add(loanApplicant.Customer_Information__c);
        }
        return new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN : applicantIds]);
    }
    
    @AuraEnabled
    public static Map<Id,Loan_Applicant__c> getLoanApplicantRecords(String appId){
        Map<Id,Loan_Applicant__c> loanApplicantMap = new Map<Id,Loan_Applicant__c>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Application__c, Customer_Information__c, mobile__c, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =: appId]){
            loanApplicantMap.put(loanApplicant.Customer_Information__c, loanApplicant);
        }
        return loanApplicantMap;
    }
    
    @AuraEnabled
    public static Map<Id, Property__c> getPropertyRecords(String appId, String loanApplicationId){
        return new Map<Id, Property__c>([SELECT Id, Name, Login__c FROM Property__c WHERE Application__c =: appId AND Loan_Applicant__c =: loanApplicationId AND RecordType.Name = 'Pre Login Property Detail']);
    }
    
    @AuraEnabled
    public static Verification__c getVerificationWithType(String applicationId, String recordTypeName){
        return [SELECT Id, RecordType.Name, Application__c,Application__r.Staff_Loan__c,Application__r.Risk_Document__c,Application__r.Pre_Login__c,Application__r.Pre_Login__r.OwnerId,Application__r.Pre_Login__r.Owner.Name FROM Verification__c WHERE Application__c =:applicationId AND RecordType.Name =:recordTypeName Order By CreatedDate DESC limit 1];
    }
    
    @AuraEnabled
    public static Legal_Approval__c getLegalApproval(String applicationId){
        return [SELECT Id FROM Legal_Approval__c WHERE Application__c =:applicationId ORDER By CreatedDate DESC limit 1];
    }
    
    @AuraEnabled
    public static string generatePublicLink(String contentVersionId, String uploadedFrom){
        try{
            ContentVersion cv = [SELECT Id, ContentDocumentId, Title, FileType, FileExtension, ContentSize FROM ContentVersion WHERE Id =:contentVersionId AND FileExtension IN ('jpg','jpeg','png','tiff','tif') LIMIT 1];
            cv.Uploaded_From__c = uploadedFrom;
            update cv;
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            return 'success';
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String,Boolean> checkRequiredDocs(String appId, List<String> docList){
        list<id> lstConDocs = new list<id>();
        System.debug('appId= '+appId);
        for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =: appId]) {
            lstConDocs.add(cntLink.ContentDocumentId);    
        }
        Map<String,Boolean> docExistanceMap = new Map<String,Boolean>();
        System.debug('docList= '+docList);
        System.debug('lstConDocs= '+lstConDocs);
        if(!lstConDocs.isEmpty()) {
            List<ContentVersion> lstCV = [SELECT Id, Title, FileExtension, Category__c, ContentDocumentId,Description,CreatedDate     
                                          FROM ContentVersion WHERE ContentDocumentId IN :lstConDocs ORDER BY CREATEDDATE DESC];
            System.debug('lstCV= '+lstCV);
            for(ContentVersion cv : lstCV){
                if(String.isNotBlank(cv.Category__c) && !docExistanceMap.containsKey(cv.Category__c)){
                    docExistanceMap.put(cv.Category__c, docList.contains(cv.Category__c));
                }
            }
        }
        
        return docExistanceMap;
    }
    
    //To get lastlogindate of current user
    @AuraEnabled
    public static String getLastLoginDate(){
        List<LoginHistory> loginDateList = [SELECT LoginTime 
                                            FROM LoginHistory
                                            WHERE UserId = :UserInfo.getUserId()
                                            ORDER BY LoginTime DESC   
                                            LIMIT 2 
                                           ];
        System.debug(loginDateList.size());
        Date lastLoginDate = System.today();
        if(!loginDateList.isEmpty()){
            if(loginDateList.size() == 2)
                lastLoginDate = date.newinstance(loginDateList.get(1).LoginTime.year(), loginDateList.get(1).LoginTime.month(), loginDateList.get(1).LoginTime.day());
            else if(loginDateList.size() == 1)
                lastLoginDate = date.newinstance(loginDateList.get(0).LoginTime.year(), loginDateList.get(0).LoginTime.month(), loginDateList.get(0).LoginTime.day());
            System.debug(lastLoginDate.format());
        }
        return lastLoginDate.format();
    }
    
    //Retreive Pincode
    @AuraEnabled
    public static PincodeWrapper getPincodeDetails(String pinId){
        System.debug('PIN ID '+pinId);
        if(String.isNotBlank(pinId) && String.isNotEmpty(pinId)){
            MS_Pincode__c objPin = [SELECT Id, Name, DistrictName__c, StateName__c,City__c,Village_Locality_Name__c FROM MS_Pincode__c WHERE Id = : pinId];
            if(objPin != null){
                PincodeWrapper pinWrap = new PincodeWrapper();
                pinWrap.pinCode = objPin.Name;
                pinWrap.city = objPin.City__c;
                pinWrap.state = objPin.StateName__c;
                pinwrap.taluka = objPin.Village_Locality_Name__c; 
                pinWrap.district = objPin.DistrictName__c;
                return pinWrap;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }
    
    //getting Field API Names Of Objects
    @AuraEnabled
    public static String getFields(String selectedObject){
        SObjectType objType = Schema.getGlobalDescribe().get(selectedObject);
        Map<String,Schema.SObjectField> MapofField = objType.getDescribe().fields.getMap();
        List<String> reqFields = new List<String>();
        String fieldNames = '';
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            if(F.isCustom()){
                fieldNames = fieldNames + field +',';
            }
            
        }
        System.debug(fieldNames);
        return fieldNames;
    }
    
    @AuraEnabled
    public static IFSC_Code_Master__c getBankIFSCDetails(String masterId){
        return [SELECT Id, Name, Bank_Name__c, Bank_Branch_Name__c FROM IFSC_Code_Master__c WHERE Id =: masterId];
    }   
    
    public static String amountInWords(Decimal num) {
        System.debug('Inside amountInWords');
        if(num == null){
            return '';
        }
        Decimal junkVal = num;
        Decimal junkValPaisa = junkVal - Math.floor(junkVal);
        junkVal = Math.floor(junkVal);
        
        String obStr = junkVal.toPlainString();
        String[] numReversed = obStr.split('');
        String[] actnumber = reverse(numReversed);
        String firstHalf = convertInWords(numReversed, actnumber);
        
        Integer tmp = Math.round(junkValPaisa * 100);
        junkValPaisa = (Decimal)tmp / 100; System.debug('jj :' + junkValPaisa);
        String paisaStr = junkValPaisa.toPlainString();
        String secondHalf;
        if (paisaStr == '0') {
            secondHalf = '';
        } else if (paisaStr.length() != 4) {
            paisaStr = paisaStr + '0';
            paisaStr = paisaStr.substring(2);
            String [] numReversedPaisa = paisaStr.split('');
            String[] actnumberPaisa = reverse(numReversedPaisa);
            secondHalf = convertInWords(numReversedPaisa, actnumberPaisa);
        } else {
            paisaStr = paisaStr.substring(2);
            String [] numReversedPaisa = paisaStr.split('');
            String[] actnumberPaisa = reverse(numReversedPaisa);
            secondHalf = convertInWords(numReversedPaisa, actnumberPaisa);
        }
        
        String SumOFHalves = '';
        
        if (secondHalf.length() > 4) {
            firstHalf = firstHalf.replace('Only',  'And ');
            secondHalf = secondHalf.replace('Only',  'Only');
            SumOFHalves = firstHalf + secondHalf;
        } else {
            firstHalf = firstHalf.replace('Only',  'Only');
            SumOFHalves = firstHalf;
        }
        
        // IF amount has any value
        if (SumOFHalves.length() > 5) {
            return SumOFHalves;
        } else {
            return '';
        }
    }
    // Method reverse the number
    public static List<String> reverse(List<String> strToRev) {
        List<String> revList = new List<String>();
        for (Integer i = strToRev.size() - 1; i >= 0; i--) {
            revList.add(strToRev.get(i));
        }
        revList.add('');
        return revList;
    }
    
    public static String convertInWords(String[] numRev, String[] actnum) {
        List<String> iWords = new List<String> {'Zero', ' One', ' Two', ' Three', ' Four', ' Five', ' Six', ' Seven', ' Eight', ' Nine'};
            List<String> ePlace = new List<String> {' Ten', ' Eleven', ' Twelve', ' Thirteen', ' Fourteen', ' Fifteen', ' Sixteen', ' Seventeen', ' Eighteen', ' Nineteen'};
                List<String> tensPlace = new List<String> {'dummy', ' Ten', ' Twenty', ' Thirty', ' Forty', ' Fifty', ' Sixty', ' Seventy', ' Eighty', ' Ninety' };
                    
                    Integer iWordsLength = numRev.size();
        String totalWords = '';
        List<String> inWords = new List<String>();
        for (Integer k = 0; k < iWordsLength; k++) {
            inWords.add('');
        }
        String finalWord = '';
        Integer j = 0;
        
        // Main For loop
        for (Integer i = 0; i < iWordsLength; i++) {
            
            if (i == 0) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Only';
            } else if (i == 1) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
            } else if (i == 2) {
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i - 1] != '0' && actnum[i - 2] != '0') {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred and';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred';
                }
            } else if (i == 3) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Thousand';
                }
            } else if (i == 4) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            } else if (i == 5) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Lakh';
                }
            } else if (i == 6) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            } else if (i == 7) {
                if (actnum[i] == '0' || actnum[i + 1] == '1' ) {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Crore';
            } else if (i == 8) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            }
            
            j++;
        }
        // End of For loop
        
        // Reverse the List
        inWords = reverse(inWords);
        
        for (Integer i = 0; i < inWords.size(); i++) {
            finalWord += inWords[i];
        }
        
        return finalWord;
    }
    
    public class PincodeWrapper{
        @auraEnabled public String pinCode;
        @auraEnabled public String district;
        @auraEnabled public String city;
        @auraEnabled public String state;
        @auraEnabled public String taluka;
        public PincodeWrapper(){
            district = '';   
            city = '';
            state = '';
            taluka = '';
        }
    } 
    
    public class RecordIdWrapper{
        @auraEnabled public String appId;
        @auraEnabled public String loanAppId;
    }
    
}