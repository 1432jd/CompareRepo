public without sharing class KYCAPIController  {
    
    @AuraEnabled
    public static String kycVerifyAPICallout(String kycType,String kycId,String applicantName,String dob,String loanAppId){
        Boolean isKYCVerified = false;
        List<API_Handler__mdt> listAPI = [SELECT DeveloperName,Sub_Type__c FROM API_Handler__mdt WHERE API_Type__r.DeveloperName = 'KYCAPIs'];
        Map<String,String> mdtNameMap = new Map<String,String>();
        for(API_Handler__mdt api : listAPI){
            mdtNameMap.put(api.Sub_Type__c,api.DeveloperName);
        }
        System.debug('mdtNameMap '+mdtNameMap);
        //Temporary Changes
        //isKYCVerified = true;
        if(kycType != 'Pan Card' && kycType != 'Aadhaar Card')
            isKYCVerified = false;
        else
            isKYCVerified = true;
        System.debug('Str '+kycType);
        if(kycType != null && kycType != 'Pan Card' && !isKYCVerified){ 
            Date dateOfBirth =  Date.valueOf(dob);
            HttpCalloutHelper http = new HttpCalloutHelper(mdtNameMap.get(kycType),null,getRequest(kycType,loanAppId,dateOfBirth,kycId,applicantName));
            http.className = 'KYCAPIController';
            HttpCalloutHelper.applicationId = DatabaseUtililty.getApplicationId(loanAppId);
            HttpCalloutHelper.loanAppId = loanAppId;
            HttpCalloutHelper.ResponseWrapper resWrap = http.doCallout();
            System.debug('KYC RESPWRAP '+resWrap.response.getBody());
            try{
                if(kycType == 'Aadhaar Card'){
                DLWrapper dlWrap = DLWrapper.parse(resWrap.response.getBody());
                if(string.valueof(dlWrap.statusCode) == '101'){
                    isKYCVerified = true;
                }  
            }
            if(kycType == 'Driving License'){
                DLWrapper dlWrap = DLWrapper.parse(resWrap.response.getBody());
                if(string.valueof(dlWrap.statusCode) == '101'){
                    isKYCVerified = true;
                }  
            }
            if(kycType == 'Voter Id'){
                VoterIdWrapper voterWrap = VoterIdWrapper.parse(resWrap.response.getBody());
                if(voterWrap.statusCode!=null && string.valueof(voterWrap.statusCode)=='101'){
                    isKYCVerified = true;
                }  
            }
            if(kycType == 'Passport'){
                PassportWrapper paspWrap = PassportWrapper.parse(resWrap.response.getBody());
                System.debug('STATUS CODE PASSPORT '+string.valueof(paspWrap.statusCode));
                if(paspWrap.statusCode!=null && string.valueof(paspWrap.statusCode) == '101'){
                    isKYCVerified = true;
                }  
            }
            }
            catch(Exception exe){
                isKYCVerified = false;
            }
        }
        if(isKYCVerified){
            return 'Success'+'_'+kycType;
        }
        else
            return 'Fail'+'_'+kycType;
    }

    @AuraEnabled
    public static String updateLoanApplicant(String loanAppId, Boolean isKYCVerified){      //04 may 2023 : added isKYCVerified parameter
        Loan_Applicant__c objLoan =  new Loan_Applicant__c();
        objLoan.Id = loanAppId;
        objLoan.Is_KYC_Verified__c = isKYCVerified;
        objLoan.Is_KYC_executed__c = true;
        objLoan.Verified_by__c = 'System Verified';             //System verified via API and BM  verified vai UI
        UPDATE objLoan;
        return objLoan.Id;
    }

    //04 May 2023 : get all loan applicant with KYC executed and KYC verified details
    @AuraEnabled
    public static List<String> getKYCStatusOfLoanApplicant(String applicationId){
        List<Loan_Applicant__c> listOfLoanApplicant = new List<Loan_Applicant__c>();
        List<String> ListOfIdOfLoanApptwithKYCNotExecuted = new List<String>();          //to store not KYC executed
        Boolean isSourceNull = false;
        String BMID = '';
        List<Loan_Applicant__c> listOfIdOfLoanApptwithKYCExecuted = new List<Loan_Applicant__c>();             //to store  KYC executed
        try {
            if(String.isNotBlank(applicationId))
            listOfLoanApplicant = [ SELECT id,Application__c,Applicant_Name__c,BM__c,Name, Application__r.Name,Application__r.Sourcing_Branch__c, Is_KYC_Verified__c, Is_KYC_executed__c,Verified_by__c,Application__r.Stage__C
                                    FROM Loan_Applicant__c
                                    WHERE Application__c =: applicationId];            
            if(!listOfLoanApplicant.isEmpty()){
                if(listOfLoanApplicant[0].Application__r.Sourcing_Branch__c == null){
                    isSourceNull = true;
                    return new List<String>{'Sourcing Branch is Empty'};
                }
                BMID = AllocationHandler.roundRobinByStage(applicationId, 'BM User');
                if(String.isBlank(BMID))
                    return new List<String>{'Branch Manager Not Exist'};
                for(Loan_Applicant__c itrLoanAppt : listOfLoanApplicant){
                    if(itrLoanAppt.Is_KYC_executed__c == true && itrLoanAppt.Is_KYC_Verified__c == false){
                        itrLoanAppt.BM__c = BMID;                   //assgin BM
                        listOfIdOfLoanApptwithKYCExecuted.add(itrLoanAppt);
                    }else if(itrLoanAppt.Is_KYC_executed__c == false){
                        ListOfIdOfLoanApptwithKYCNotExecuted.add(itrLoanAppt.Applicant_Name__c);    //show error
                    }
                }
            }

            if(!ListOfIdOfLoanApptwithKYCNotExecuted.isEmpty()){
                return ListOfIdOfLoanApptwithKYCNotExecuted;
            }else if(!listOfIdOfLoanApptwithKYCExecuted.isEmpty()) {
                UPDATE listOfIdOfLoanApptwithKYCExecuted;
                Application_User_Tracking__c appUtObj = new Application_User_Tracking__c();
                appUtObj.Application__c=applicationId;
                appUtObj.Stage__c=listOfLoanApplicant[0].Application__r.Stage__C;
                appUtObj.Start_Date__c=System.now();
                appUtObj.Type__c='KYC Verification';
                appUtObj.Status__c=(BMID == System.Label.Pull_Queue_User) ? 'Unassigned' : 'Pending';
                appUtObj.Owner__c=BMID;
                INSERT appUtObj;
                return new List<String>{'Sent to BM'};
            }else{
                return new List<String>{'KCY Already Verified'};
            }
        } catch (Exception e) {
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void insertApplicationHistory(String applicationId){
        List<Application_User_Tracking__c> listAppUtObj = [SELECT Id,Type__c,Status__c,End_Date__c FROM Application_User_Tracking__c WHERE Application__c =: applicationId AND Type__c = 'KYC Verification' AND Status__c= 'Pending'];
        if(!listAppUtObj.isEmpty()){
            listAppUtObj[0].Status__c='Completed';
            listAppUtObj[0].End_Date__c=System.today();
            UPDATE listAppUtObj[0];
        }
    }
    
    private static String getRequest(String kycType , String loanAppId, Date dob, String kycId, String applicantFullName){
        String ocrRequest = '';
        if(kycType=='Aadhaar Card'){
            ocrRequest = '{ "aadhaarNo": "'+kycId+'", "accessKey": "f63c7f8f-1443-4be0-9aa0-c05e24719ddc", "consent": "Y", "clientData": {"caseId": "123456"} }';
        }
        if(kycType=='Driving License'){
            ocrRequest = '{ "dlNo": "'+kycId+'", "dob": "'+converDate(dob,'-')+'", "consent": "Y" }';
        }
        if(kycType=='Voter Id'){
            ocrRequest ='{ "epicNo": "'+kycId+'", "consent": "Y" }';
        }
        if(kycType=='Passport'){
            Loan_Applicant__c objLoan = [SELECT Id, KYC_ID_Type_1__c, KYC_ID_Type_2__c,Issue_Date__c, Expiry_Date__c, Passport_File_Number__c 
                                    	 FROM Loan_Applicant__c
                                    	 WHERE Id = : loanAppId];
            /*KYC__c objKYC = [SELECT Id,Passport_FileNo__c,DOB__c,DateOfIssue__c
                             FROM KYC__c
                             WHERE Loan_Applicant__c =:loanAppId AND Name!='Aadhar_Card' AND Name!='Pan_Card'];*/
            
            ocrRequest = '{ "consent": "y", "fileNo": "'+objLoan.Passport_File_Number__c+'", "dob": "'+converDate(dob,'/')+'", "passportNo": "'+kycId+'", "doi": "'+converDate(objLoan.Issue_Date__c,'/')+'", "name": "'+applicantFullName+'" }'; 
        }
        return ocrRequest;
    }
    
    private static String converDate(Date dob,String delimeter){
        String str = string.valueof(dob);
         system.debug('str dateeee2111>> '+str);
        string day=str.SubStringBefore('-');
        string month=str.SubStringafter('-');
        string year=month.SubStringafter('-');
        month=month.SubStringBefore('-');
        return year+delimeter+month+delimeter+day; 
    }
    
    //Discarded.
    @AuraEnabled
    public static String kycAPICallout(String loanAppId){
        Boolean isKYCVerified = false;
        Loan_Applicant__c objLoan = [SELECT Id, KYC_ID_Type_1__c, KYC_ID_Type_2__c, KYC_Id_1__c, KYC_Id_2__c,Is_KYC_Verified__c	, Customer_Information__r.PersonBirthDate,Applicant_Name__c 
                                     FROM Loan_Applicant__c
                                     WHERE Id = : loanAppId];
        if(objLoan.KYC_ID_Type_1__c == 'Pan Card' || objLoan.KYC_ID_Type_2__c == 'Pan Card'){
            isKYCVerified = true;
        }
        Map<String,String> kycTypeMap = new Map<String,String>{objLoan.KYC_ID_Type_1__c => objLoan.KYC_ID_1__c};            
            if(String.isNotBlank(objLoan.KYC_ID_Type_2__c) && String.isNotBlank(objLoan.KYC_Id_2__c)){
                kycTypeMap.put(objLoan.KYC_ID_Type_2__c,objLoan.KYC_Id_2__c);
            }
        System.debug('kycTypeMap '+kycTypeMap);
        List<API_Handler__mdt> listAPI = [SELECT DeveloperName,Sub_Type__c FROM API_Handler__mdt WHERE API_Type__r.DeveloperName = 'KYCAPIs'];
        
        Map<String,String> mdtNameMap = new Map<String,String>();
        for(API_Handler__mdt api : listAPI){
            mdtNameMap.put(api.Sub_Type__c,api.DeveloperName);
        }
        System.debug('mdtNameMap '+mdtNameMap);
        for(String str : kycTypeMap.keySet()){
            if(str != 'Pan Card')
                isKYCVerified = false;
            System.debug('Str '+str);
            System.debug('kycMapStr '+kycTypeMap.get(str));
            if(str != null && str != 'Pan Card'){ 
                HttpCalloutHelper http = new HttpCalloutHelper(mdtNameMap.get(str),null,getRequest(str,loanAppId,objLoan.Customer_Information__r.PersonBirthDate,kycTypeMap.get(str),objLoan.Applicant_Name__c));
                http.className = 'KYCAPIController';
                HttpCalloutHelper.applicationId = DatabaseUtililty.getApplicationId(loanAppId);
                HttpCalloutHelper.loanAppId = loanAppId;
                HttpCalloutHelper.ResponseWrapper resWrap = http.doCallout();
                System.debug('KYC RESPWRAP '+resWrap.response.getBody());
                if(str == 'Aadhaar Card'){
                    DLWrapper dlWrap = DLWrapper.parse(resWrap.response.getBody());
                    if(string.valueof(dlWrap.statusCode) == '101'){
                        isKYCVerified = true;
                    }  
                }
                if(str == 'Driving License'){
                    DLWrapper dlWrap = DLWrapper.parse(resWrap.response.getBody());
                    if(string.valueof(dlWrap.statusCode) == '101'){
                        isKYCVerified = true;
                    }  
                }
                if(str == 'Voter Id'){
                    VoterIdWrapper voterWrap = VoterIdWrapper.parse(resWrap.response.getBody());
                    if(voterWrap.statusCode!=null && string.valueof(voterWrap.statusCode)=='101'){
                        isKYCVerified = true;
                    }  
                }
                if(str == 'Passport'){
                    PassportWrapper paspWrap = PassportWrapper.parse(resWrap.response.getBody());
                    if(paspWrap.statusCode!=null && string.valueof(paspWrap.statusCode) == '101'){
                        isKYCVerified = true;
                    }  
                }
            }
        }
        if(isKYCVerified){
            objLoan.Is_KYC_Verified__c = isKYCVerified;
            UPDATE objLoan;
            return 'Success';
        }
        else
            return 'Fail';
        
    }
}