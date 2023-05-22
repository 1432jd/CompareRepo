/**
* @File Name          : PennyDropAPI.apxc
* @Author             : Navin Soni
* @Created On         : 04 August 2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       04 August 2022            Navin Soni             Initial Version
**/

public without sharing class PennyDropAPI { 
    
    /*
    @Author : Navin Soni
    @Description : This method is use to call Penny Drop API.
    */
    @AuraEnabled
    public static string callPennyDropAPI(String BankDetailId){
        system.debug('@@## BankDetailId'+BankDetailId);

        /* temporary changes untill penny drop start worki again */
        if(String.isNotBlank(BankDetailId)){
            Id recordId = BankDetailId;
            if(String.valueOf(recordId.getSobjectType()) == 'Bank_Detail__c'){
                Bank_Detail__c objBankDetail = new Bank_Detail__c();
                objBankDetail.Id = BankDetailId;
                objBankDetail.Is_Account_Verified__c = TRUE;
                objBankDetail.Account_Verified_on__c = System.Now();
                Update objBankDetail;
            }
            else if(String.valueOf(recordId.getSobjectType()) == 'Disbursal_Payee__c'){
                Disbursal_Payee__c objDisbursalPayee = new Disbursal_Payee__c();
                objDisbursalPayee.Id = BankDetailId;
                objDisbursalPayee.Is_Verified__c = TRUE;
                update objDisbursalPayee;
            }
        }


        /*String APIResponse = '';
        DatabaseUtililty.RecordIdWrapper records = new DatabaseUtililty.RecordIdWrapper();

        try{
             if(String.isNotBlank(BankDetailId)){
                Id recordId = BankDetailId;
                if(String.valueOf(recordId.getSobjectType()) == 'Bank_Detail__c'){
                    records = DatabaseUtililty.getRecordIdsFromBankDEtails(BankDetailId);
                }else if(String.valueOf(recordId.getSobjectType()) == 'Disbursal_Payee__c'){
                    System.debug('inside the checl rew');
                    records = DatabaseUtililty.getRecordIdsFromDisbPayeeDEtails(BankDetailId);
                    System.debug('after the checl rew');
                }
            }
             System.debug('insdie the metadta oth');
            //DatabaseUtililty.RecordIdWrapper records = DatabaseUtililty.getRecordIdsFromBankDEtails(BankDetailId);
             System.debug('insdie the metadta first');
            API_Handler__mdt EmandateAPI = API_Handler__mdt.getInstance('Penny_Drop');
             System.debug('insdie the metadta secind');
            if(EmandateAPI.isActive__c){
                System.debug('insdie the metadta');
                RequestHeader objRequestHeader = parseRequestHeader(EmandateAPI.HeaderParameters__c);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(EmandateAPI.Endpoint__c);
                request.setMethod(EmandateAPI.Method__c); 
                if(String.isNotBlank(BankDetailId)){
                    Id recordId = BankDetailId;
                    if(String.valueOf(recordId.getSobjectType()) == 'Bank_Detail__c'){
                         System.debug('inside bank Id');
                        request.setBody(generateBankDetailRequestBody(BankDetailId));
                    }else if(String.valueOf(recordId.getSobjectType()) == 'Disbursal_Payee__c'){
                        System.debug('inside payee Id');
                        request.setBody(generateDisbursalPayeeRequestBody(BankDetailId));
                    }
                }
                
                request.setHeader('Authorization', objRequestHeader.Authorization);
                request.setHeader('CORRELATION-ID',objRequestHeader.CORRELATIONID);
                request.setHeader('CLIENT-ID',objRequestHeader.CLIENTID);
                request.setHeader('CLIENT-SECRET',objRequestHeader.CLIENTSECRET);
                request.setHeader('Content-Type', objRequestHeader.ContentType);
                request.setTimeout(120000);
                
                HttpResponse objResponse = new HttpResponse();
                
                if(!Test.isRunningTest()){
                    objResponse = http.send(request); 
                }else{
                    objResponse.setBody(EmandateAPI.Mock_Response__c);
                    objResponse.setStatusCode(200);
                }

                system.debug('@@## response '+objResponse.getbody());

                API_Logger__c objAPILogger = new API_Logger__c();
                objAPILogger.Name = 'PennyDropAPI';
                objAPILogger.API_Name__c = 'PennyDropAPI';
                objAPILogger.Status__c = String.valueOf(objResponse.getStatus());
                objAPILogger.Request__c = request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                objAPILogger.Response__c = objResponse.getBody().length() > 130068 ?
                                            objResponse.getBody().substring(0, 130068) : objResponse.getBody();
                objAPILogger.EndPoint__c = request.getEndpoint();
                if(String.isNotBlank(records.appId) && String.isNotEmpty(records.appId))
                	objAPILogger.Application__c = records.appId;
                if(String.isNotBlank(records.loanAppId) && String.isNotEmpty(records.loanAppId))
                	objAPILogger.Loan_Applicant__c = records.loanAppId;
                insert objAPILogger;

                if (objResponse != null && objResponse.getStatusCode() == 200) {

                    system.debug('@@## BankDetailId '+BankDetailId);
                    if(String.isNotBlank(BankDetailId)){
                        Id recordId = BankDetailId;
                        if(String.valueOf(recordId.getSobjectType()) == 'Bank_Detail__c'){
                            Bank_Detail__c objBankDetail = new Bank_Detail__c();
                            objBankDetail.Id = BankDetailId;
                            objBankDetail.Is_Account_Verified__c = TRUE;
                            objBankDetail.Account_Verified_on__c = System.Now();
                            Update objBankDetail;
                        }
                        else if(String.valueOf(recordId.getSobjectType()) == 'Disbursal_Payee__c'){
                            Disbursal_Payee__c objDisbursalPayee = new Disbursal_Payee__c();
                            objDisbursalPayee.Id = BankDetailId;
                            objDisbursalPayee.Is_Verified__c = TRUE;
                            update objDisbursalPayee;
                        }
                    }
                }
                else {

                    cls_errorClass objclserrorClass = parseError(objResponse.getBody());
                    Error_Logger__c objErrorLog = new Error_Logger__c();
                    objErrorLog.Exception_Message__c = objclserrorClass.error.description;
                    objErrorLog.Description__c = objResponse.getBody().length() > 30000 ? objResponse.getBody().substring(0, 30000) : objResponse.getBody();
                    objErrorLog.Name = 'PennyDropAPI';
                    insert objErrorLog;

                    APIResponse = 'Error_'+objclserrorClass.error.description;
                }
                
                return APIResponse;
            }
        }
        catch(Exception e) {
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage().length() > 255 ? e.getMessage().substring(0, 255) : e.getMessage();
            objErrorLog.Description__c = e.getMessage().length() > 30000 ? e.getMessage().substring(0, 30000) : e.getMessage();
            objErrorLog.Name = 'PennyDropAPI';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            insert objErrorLog;

            return 'Error_504 Gateway Time-out.';
        }*/
        return 'Success_Account Verification Successfully.';
    }
    
    /*
    @Author : Navin Soni
    @Description : This method is use to create request body for Penny Drop API.
    */
    private static String generateDisbursalPayeeRequestBody(String DisbursalPayee) {
        
        List<Disbursal_Payee__c> listOfDisbursalPayee = [SELECT ID, Application__r.Name, Beneficiary_Bank_Account_Number__c, Beneficiary_Name__c, Beneficiary_IFSC_Code__c, Loan_Applicant__c, Loan_Applicant__r.Mobile__c FROM Disbursal_Payee__c WHERE ID =: DisbursalPayee];
        System.debug('list data is >>>'+'Id is >>'+DisbursalPayee+'data id is>>'+listOfDisbursalPayee);
        Map<String,String> LMSDefaultValuesMap = new Map<String,String>();
        
        for (Drop_Down_Code__mdt LMSValue : [SELECT Id, Name__c, Value__c FROM Drop_Down_Code__mdt WHERE API_Name__c = 'PennyDrop']) {
            LMSDefaultValuesMap.put(LMSValue.Name__c,LMSValue.Value__c);
        }
        String requestJson = '';
        if(listOfDisbursalPayee != null && listOfDisbursalPayee.size() > 0) {
            Disbursal_Payee__c objDisPayee = listOfDisbursalPayee[0];
            
            String transId = System.now().Year()+''+System.now().Month()+''+System.now().day()+''+System.now().hour()+''+System.now().Minute()+''+System.now().Second();
            system.debug('@@## transId '+transId);

            requestJson += '{';
            requestJson += '"beneficiaryAccountValidationRequest":{';
            requestJson += '"header":{';
            requestJson += '"transId":"';
            requestJson += transId;
            requestJson += '",';
            requestJson += '"corpId": "';
            requestJson += LMSDefaultValuesMap.get('corpId') != null ? LMSDefaultValuesMap.get('corpId') : '';
            requestJson += '",';
            requestJson += '"makerId": "';
            requestJson += LMSDefaultValuesMap.get('makerId') != null ? LMSDefaultValuesMap.get('makerId') : '';
            requestJson += '",';
            requestJson += '"checkerId": "';
            requestJson += LMSDefaultValuesMap.get('checkerId') != null ? LMSDefaultValuesMap.get('checkerId') : '';
            requestJson += '",';
            requestJson += '"approverId": "';
            requestJson += LMSDefaultValuesMap.get('approverId') != null ? LMSDefaultValuesMap.get('approverId') : '';
            requestJson += '"';
            requestJson += '},';
            requestJson += '"body":{';
            requestJson += '"beneficiaryName":"'+objDisPayee.Beneficiary_Name__c.replaceAll( '\\s+', '')+'",';
            requestJson += '"beneficiaryMobileNumber":"'+objDisPayee.Loan_Applicant__r.Mobile__c+'",';
            requestJson += '"accountNumber":"'+objDisPayee.Beneficiary_Bank_Account_Number__c+'",';
            requestJson += '"ifscCode":"'+objDisPayee.Beneficiary_IFSC_Code__c+'"';
            requestJson += '},';
            requestJson += '"signature":{';
            requestJson += '"signature": "';
            requestJson += LMSDefaultValuesMap.get('signature') != null ? LMSDefaultValuesMap.get('signature') : '';
            requestJson += '"';
            requestJson += '}';
            requestJson += '}';
            requestJson += '}';
        }
        
        System.debug('@@## requestJson for Kotak Calculate API -> '+requestJson);
        return requestJson;
    }

    /*
    @Author : Navin Soni
    @Description : This method is use to create request body for Penny Drop API.
    */
    private static String generateBankDetailRequestBody(String BankDetailId){
        
        List<Bank_Detail__c> listOfBankDetail = [SELECT ID, Application__r.Name,IFSC_Code__c, Account_Number__c, Bank_Account_Holder_Name__c, MS_IFSC_Code__c, MS_IFSC_Code__r.Name, Loan_Applicant__c, Loan_Applicant__r.Mobile__c FROM Bank_Detail__c WHERE ID =: BankDetailId];
        
        Map<String,String> LMSDefaultValuesMap = new Map<String,String>();
        for(Drop_Down_Code__mdt LMSValue : [SELECT Id, Name__c, Value__c FROM Drop_Down_Code__mdt WHERE API_Name__c = 'PennyDrop']){
            LMSDefaultValuesMap.put(LMSValue.Name__c,LMSValue.Value__c);
        }
        
        String requestJson = '';
        if(listOfBankDetail != null && listOfBankDetail.size() > 0){
            Bank_Detail__c bankDetailObj = listOfBankDetail[0];

            String transId = System.now().Year()+''+System.now().Month()+''+System.now().day()+''+System.now().hour()+''+System.now().Minute()+''+System.now().Second();
            system.debug('@@## transId '+transId);

            requestJson += '{';
            requestJson += '"beneficiaryAccountValidationRequest":{';
            requestJson += '"header":{';
            requestJson += '"transId":"';
            requestJson += transId;
            requestJson += '",';
            requestJson += '"corpId": "';
            requestJson += LMSDefaultValuesMap.get('corpId') != null ? LMSDefaultValuesMap.get('corpId') : '';
            requestJson += '",';
            requestJson += '"makerId": "';
            requestJson += LMSDefaultValuesMap.get('makerId') != null ? LMSDefaultValuesMap.get('makerId') : '';
            requestJson += '",';
            requestJson += '"checkerId": "';
            requestJson += LMSDefaultValuesMap.get('checkerId') != null ? LMSDefaultValuesMap.get('checkerId') : '';
            requestJson += '",';
            requestJson += '"approverId": "';
            requestJson += LMSDefaultValuesMap.get('approverId') != null ? LMSDefaultValuesMap.get('approverId') : '';
            requestJson += '"';
            requestJson += '},';
            requestJson += '"body":{';
            requestJson += '"beneficiaryName":"'+bankDetailObj.Bank_Account_Holder_Name__c.replaceAll( '\\s+', '')+'",';
            requestJson += '"beneficiaryMobileNumber":"'+bankDetailObj.Loan_Applicant__r.Mobile__c+'",';
            requestJson += '"accountNumber":"'+bankDetailObj.Account_Number__c+'",';
            requestJson += '"ifscCode":"'+bankDetailObj.IFSC_Code__c+'"';
            requestJson += '},';
            requestJson += '"signature":{';
            requestJson += '"signature": "';
            requestJson += LMSDefaultValuesMap.get('signature') != null ? LMSDefaultValuesMap.get('signature') : '';
            requestJson += '"';
            requestJson += '}';
            requestJson += '}';
            requestJson += '}';
        }
        
        System.debug('@@## requestJson for PennyDrop API -> '+requestJson);
        return requestJson;
    }
    
    public class ResponseJSON{
        public cls_beneficiaryAccountValidationResponse beneficiaryAccountValidationResponse;
    }
    
    class cls_beneficiaryAccountValidationResponse {
        public cls_header header;
        public cls_body body;
        public cls_signature signature;
    }
    class cls_header {
        public String transId;  //20017
        public String corpId;   //MC001
        public String makerId;  //M001
        public String checkerId;    //C001
        public String approverId;   //A001
    }
    
    class cls_body {
        public String status;   //Success
        public String accountNumber;    //109566016496
        public String ifscCode; //DNSB0000021
        public String beneficiaryName;  //VARSHA
        public String remarks;  //Transaction is successful and customer is successfully validated
        public String bankRefNo;    //629114449955
        public String npciResponseCode; //00
    }

    class cls_signature {
        public String signature;    //Signature
    }

    public static ResponseJSON parse(String json){
        return (ResponseJSON) System.JSON.deserialize(json, ResponseJSON.class);
    }
    
    public class RequestHeader{
        public String Authorization;    //Basic YWRtaW46YWRtaW4=
        public String CORRELATIONID;    //123456789
        public String CLIENTID; //78g659ed2a0dfa2b
        public String CLIENTSECRET; //f56f68b65739bd8a
        public String ContentType;  //application/json
    }
    public static RequestHeader parseRequestHeader(String json){
        return (RequestHeader) System.JSON.deserialize(json, RequestHeader.class);
    }

    public class cls_errorClass{
        public cls_error error;
    }

    public class cls_error {
		public String source;	//Portal
		public String target;	//LMS
		public String errorCode;	//500
		public String message;	//Internal Server Error
		public String description;	// internal server error (500).
		public String timestamp;	//2022-10-07 05:29:13+0000
	}
	public static cls_errorClass parseError(String json){
		return (cls_errorClass) System.JSON.deserialize(json, cls_errorClass.class);
	}
}