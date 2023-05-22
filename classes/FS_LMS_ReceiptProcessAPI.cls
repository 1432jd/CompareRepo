/**
 * @author            : Ashish Sharma/Navin Soni
 * @group             : TechMatrix Consulting
 * @description       :
 * @created on        :
 * @last modified on  : 27-09-2022
 * @last modified by  : Ashish Sharma
**/
public without sharing class FS_LMS_ReceiptProcessAPI {

    // FS_LMS_ReceiptProcessAPI.receiptProcessCallout(new List<String>{'a0M0w000003FvVpEAK'});
    /**  
    @author           : Ashish Sharma
    @description      :	Method to make receiptProcess Callout and update Receipt_Id based on API response on Receipt
    */
    @InvocableMethod(Label = 'Receipt Process Callout')
    public static void receiptProcessCallout(List<String> listOfReceiptIds) {

        List<Receipt__c> receiptRecords = new List<Receipt__c>();
        String applicationId = '';
        List< Sobject > listSobject = new List< Sobject >();
        String payload = '';
        String receiptId = listOfReceiptIds[0];

        if (String.isNotBlank(receiptId)) {
            payload = generateRequestJson(receiptId);
            if (String.isNotBlank(payload)) {
                try {
                    receiptRecords = [SELECT Id, Application__c FROM Receipt__c WHERE Id =: receiptId];
                    if(receiptRecords.size() > 0) {
                        applicationId = receiptRecords[0].Application__c != null ? receiptRecords[0].Application__c : '';
                    }
                    API_Handler__mdt objLMS_ReceiptProcessAPI = API_Handler__mdt.getInstance('LMS_ReceiptProcess');
                    if(objLMS_ReceiptProcessAPI.isActive__c) {
                        RequestHeader objRequestHeader = parseRequestHeader(objLMS_ReceiptProcessAPI.HeaderParameters__c);
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(objLMS_ReceiptProcessAPI.Endpoint__c);
                        request.setMethod(objLMS_ReceiptProcessAPI.Method__c);
                        request.setHeader('Authorization', objRequestHeader.Authorization);
                        request.setHeader('CORRELATION-ID', objRequestHeader.CORRELATIONID);
                        request.setHeader('CLIENT-ID', objRequestHeader.CLIENTID);
                        request.setHeader('CLIENT-SECRET', objRequestHeader.CLIENTSECRET);
                        request.setHeader('Content-Type', objRequestHeader.ContentType);
                        request.setTimeout(120000);
                        request.setBody(payload);
                        //System.debug(payload);

                        HttpResponse response = new HttpResponse();
                        if(!Test.isRunningTest()) {
                            response = http.send(request); 
                        }else{
                            response.setBody(objLMS_ReceiptProcessAPI.Mock_Response__c);
                            response.setStatusCode(200);
                        }
                        
                        System.debug('URL : ' + request.getEndpoint());
                        System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
                        //System.debug(response.getBody());

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {'ashish2.s@techmatrixconsulting.com'});
                        mail.setSubject('QA ReceiptProcessAPI');
                        mail.setPlainTextBody('Response Body '+response.getBody() + '\nRequest Body '+payload);
                        //mail.setPlainTextBody('Request Body '+payload);
                        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                        if (response != null && response.getStatusCode() == 201) {

                            FS_LMS_ReceiptProcessAPI objWrapResponse = parse(response.getbody());
                            system.debug('@@## objRegResponse '+objWrapResponse);
                            if(objWrapResponse != null) {
                                String responseReceiptId = objWrapResponse.Payload.receiptId != null ? 
                                                            String.valueOf(objWrapResponse.Payload.receiptId) : '';
                                Receipt__c receipt = new Receipt__c(Id = receiptId);
                                receipt.Sync_Error__c = '';
                                receipt.Receipt_Id__c = responseReceiptId;
                                receipt.Approval_Status__c = 'Approved';
                                receipt.isError__c = false;
                                if(receipt != null) {
                                    upsert receipt;
                                    /*@Description: To update Application History of receipt
                                      @Dated: 5/1/23
                                      @Author: Sangeeta Yadav
                                    */
                                    Application_User_Tracking__c receiptTrac = [SELECT Id, Status__c, End_Date__c FROM Application_User_Tracking__c WHERE Receipt__c =: receiptId];
                                    if(receiptTrac != null){
                                        receiptTrac.Status__c = 'Completed';
                                        receiptTrac.End_Date__c = System.now();
                                        update receiptTrac;
                                    }
                                }
                            }
                        }
                        else {
                            Receipt__c receipt = new Receipt__c(Id = receiptId,isApproved__c = false);
                            receipt.Sync_Error__c = response.getbody().length() > 130068 ? response.getbody().substring(0, 130068) : response.getbody();
                            receipt.isError__c = true;
                            if(receipt != null) {
                                upsert receipt;
                            }
                            system.debug('API exception '+response);
                            system.debug('API exception getStatusCode '+response.getStatusCode());
                            Error_Logger__c objErrorLog = new Error_Logger__c();
                            objErrorLog.Name = 'FS_LMS_ReceiptProcessAPI';
                            objErrorLog.Description__c = response.getbody().length() > 30068 ? response.getbody().substring(0, 30068) : response.getbody();
                            listSobject.add( objErrorLog );
                        }
                        API_Logger__c objAPILogger = new API_Logger__c();
                        objAPILogger.Name = 'FS_LMS_ReceiptProcessAPI';
                        objAPILogger.API_Name__c = 'FS_LMS_ReceiptProcessAPI';
                        objAPILogger.Application__c = applicationId;
                        objAPILogger.Status__c = response.getStatus();
                        objAPILogger.Request__c = request.getBody();
                        objAPILogger.Response__c = response.getBody().length() > 130068 ? response.getBody().substring(0, 130068) : response.getBody();
                        objAPILogger.EndPoint__c = request.getEndpoint();
                        listSobject.add(objAPILogger);
                    }
                }
                catch(Exception e) {
                    system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
                    Error_Logger__c objErrorLog = new Error_Logger__c();
                    //objErrorLog.Exception_Message__c = e.getMessage();
                    objErrorLog.Name = 'FS_LMS_ReceiptProcessAPI';
                    objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
                    objErrorLog.Description__c = e.getMessage().length() > 30068 ? e.getMessage().substring(0, 30068) : e.getMessage();
                    listSobject.add( objErrorLog );
                }
            }
        }
        if( !listSobject.isEmpty() ) {
            upsert  listSobject;
        }
    }

    // Created by Ashish Sharma 27/09/2022
    public static String generateRequestJson( String receiptId ) {
    
        String requestJson = '';
        Receipt__c receiptRecord;
        List<Receipt__c> receiptRecords = new List<Receipt__c>();
        receiptRecords = [SELECT Id, Application__r.Name, Application__r.Sourcing_Branch__r.Lms_Branch_Code__c, Mode_of_payment__c, Amount__c, 
                            Approval_Date__c, Loan_Purpose__c
                            FROM Receipt__c WHERE Id =:receiptId];
        if ( receiptRecords != null && receiptRecords.size() > 0) {
            receiptRecord = receiptRecords[0];
        }

        if(receiptRecord != null) {
            Map<String,String> LMSDefaultValuesMap = new Map<String,String>();
            
            for (Drop_Down_Code__mdt LMSValue : [SELECT Id, Name__c, Value__c FROM Drop_Down_Code__mdt WHERE API_Name__c = 'ReceiptProcess']) {
                LMSDefaultValuesMap.put(LMSValue.Name__c,LMSValue.Value__c);
            }
            try {
                String loanAppId = receiptRecord.Application__r != null ? String.isNotBlank(receiptRecord.Application__r.Name) ?
                                    receiptRecord.Application__r.Name.replace(' - ', 'T') : '' : '';
                String receiptNo = System.now().Year()+''+System.now().Month()+''+System.now().day()+''+System.now().hour()+''+System.now().Minute()+''+System.now().Second();
                requestJson += '{';
                    requestJson += '"applicationFormNumber":"'+ loanAppId +'",';
                    requestJson += '"autoAllocation": "';
                    requestJson += LMSDefaultValuesMap.get('autoAllocation') == null ? '': LMSDefaultValuesMap.get('autoAllocation');
                    requestJson += '",';
                    requestJson += '"receiptRemarks":"';
                    requestJson += String.isNotBlank(receiptRecord.Loan_Purpose__c) ? receiptRecord.Loan_Purpose__c : '';
                    requestJson += '",';
                    requestJson += '"receiptNo":"' + receiptNo + '",';
                    requestJson += '"processTillMaker": '+ false + ',';
                    requestJson += '"receiptAgainst":"';
                    requestJson += String.isNotBlank(LMSDefaultValuesMap.get('receiptAgainst')) ? LMSDefaultValuesMap.get('receiptAgainst'):'';
                    requestJson += '",';
                    requestJson += '"receiptOrPayoutAmount":"';
                    requestJson += receiptRecord.Amount__c == null ? '0': String.valueOf(receiptRecord.Amount__c);
                    requestJson += '",';
                    requestJson += '"receiptPayOutMode": "';
                    requestJson += String.isNotBlank(receiptRecord.Mode_of_payment__c) ? receiptRecord.Mode_of_payment__c.toUpperCase() : '';
                    requestJson += '",';
                    requestJson += '"receiptPayoutChannel": "';
                    requestJson += LMSDefaultValuesMap.get('receiptPayoutChannel') == null ? '': LMSDefaultValuesMap.get('receiptPayoutChannel');
                    requestJson += '",';
                    requestJson += '"receiptPurpose": "';
                    requestJson += LMSDefaultValuesMap.get('receiptPurpose') == null ? '': LMSDefaultValuesMap.get('receiptPurpose');
                    requestJson += '",';
                    requestJson += '"receiptTransactionStatus":"';
                    //requestJson += String.isNotBlank(receiptRecord.Mode_of_payment__c) ? receiptRecord.Mode_of_payment__c == 'Cash'? 'R': 'C': '';
                    requestJson += LMSDefaultValuesMap.get('receiptTransactionStatus') == null ? '': LMSDefaultValuesMap.get('receiptTransactionStatus');
                    requestJson += '",';
                    requestJson += '"representFlag": "';
                    requestJson += LMSDefaultValuesMap.get('representFlag') == null ? '': LMSDefaultValuesMap.get('representFlag');
                    requestJson += '",';
                    requestJson += '"requestChannel": "';
                    requestJson += LMSDefaultValuesMap.get('requestChannel') == null ? '': LMSDefaultValuesMap.get('requestChannel');
                    requestJson += '",';
                    requestJson += '"depositBankAccountNumber": "';
                    requestJson += LMSDefaultValuesMap.get('depositBankAccountNumber') == null ? '': LMSDefaultValuesMap.get('depositBankAccountNumber');
                    requestJson += '",';
                    requestJson += '"requestHeader":{';
                    requestJson += '"tenantId": ';
                    requestJson += LMSDefaultValuesMap.get('tenantId');
                    requestJson += ',';
                    requestJson += '"userDetail":{';
                    String branchIdValue = receiptRecord.Application__r != null ? receiptRecord.Application__r.Sourcing_Branch__r != null ?
                                            String.isNotBlank(receiptRecord.Application__r.Sourcing_Branch__r.Lms_Branch_Code__c) ?
                                            receiptRecord.Application__r.Sourcing_Branch__r.Lms_Branch_Code__c: '0': '0' : '0';
                        requestJson += '"branchId":'+ branchIdValue +',';
                        requestJson += '"userCode": "';
                        requestJson += LMSDefaultValuesMap.get('userCode') == null ? '': LMSDefaultValuesMap.get('userCode');
                        //requestJson += LMSDefaultValuesMap.get('RPuserCode') == null ? '': LMSDefaultValuesMap.get('RPuserCode');
                        requestJson += '"';
                    requestJson += '}';
                    requestJson += '},';
                    requestJson += '"transactionCurrencyCode": "';
                    requestJson += LMSDefaultValuesMap.get('transactionCurrencyCode') == null ? '': LMSDefaultValuesMap.get('transactionCurrencyCode');
                    requestJson += '",';
                    requestJson += '"transactionValueDate":"';
                    String approvalDate = receiptRecord.Approval_Date__c != null ?
                                            receiptRecord.Approval_Date__c.Day() + '/' +
                                            receiptRecord.Approval_Date__c.Month() + '/' +
                                            receiptRecord.Approval_Date__c.Year() : '';
                    //requestJson += approvalDate;//Todo :Uncomment after discuss with anand
                    //requestJson += '24/04/2022';
                    String businessDate = System.Label.Business_Date;
                    requestJson += String.isNotBlank(businessDate) ? businessDate : '';
                    requestJson += '"';
                requestJson += '}';
            } catch(Exception e) {
                System.debug( e.getMessage() +' Line No. : '+ e.getLineNumber() );
                throw new CalloutException( e.getMessage() +' Line No. : '+ e.getLineNumber() );
            }
        }
        return requestJson;
    }

    public class Messages {
		public String i18nCode;
		public List<String> messageArguments;
		public String type;
		public Boolean isParent;
		public String value;
	}

	public Object acknowledgement;
	public String responseCode;
	public Object responseString;
	public Payload payload;

	public class Payload {
		public Object payinSlipReferencNumber;
		public Integer receiptId;
		public List<Messages> messages;
	}

	
	public static FS_LMS_ReceiptProcessAPI parse(String json) {
		return (FS_LMS_ReceiptProcessAPI) System.JSON.deserialize(json, FS_LMS_ReceiptProcessAPI.class);
	}
    public class RequestHeader {
        public String Authorization;	//Basic YWRtaW46YWRtaW4=
        public String CORRELATIONID;	//123456789
        public String CLIENTID;	//78g659ed2a0dfa2b
        public String CLIENTSECRET;	//f56f68b65739bd8a
        public String ContentType;	//application/json
    }
	public static RequestHeader parseRequestHeader(String json) {
		return (RequestHeader) System.JSON.deserialize(json, RequestHeader.class);
	}
}