/**
 * @author            :
 * @group             : TechMatrix Consulting
 * @description       :
 * @created on        :
 * @last modified on  : 17-07-2022
 * @last modified by  : Karan Singh Soni
**/
public without sharing class FS_LMS_GetRecieptStatusAPI {

    public static void getRecieptStatus(){

        List< Sobject > listSobject = new List< Sobject >();

        try{

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://uat-api.fsbl.in/api/1.0/ux/receipt/status?branchId=5&id=6664913');
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic YWRtaW46YWRtaW4=');
        request.setHeader('CORRELATION-ID', 'HFGKDHN');
        request.setHeader('CLIENT-ID','78g659ed2a0dfa2b');
        request.setHeader('CLIENT-SECRET','f56f68b65739bd8a');
        request.setHeader('loanId','9y2CHeuxDJwAgBMRwzoVNA==.0U0dHeIcxiJ74xCDuOh6ow==');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' +EncodingUtil.base64Encode(Blob.valueOf('admin:admin')));
        //request.setBody(payload);
        request.setTimeout(120000);


        //request.setBody(payload);
        HttpResponse response = http.send(request);
        System.debug('URL : ' + request.getEndpoint());
        System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
        System.debug(response.getBody());

            if (response != null && response.getStatusCode() == 200) {

                FS_LMS_GetRecieptStatusAPI objWrapResponse = parse(response.getbody());
                system.debug('@@## objRegResponse '+objWrapResponse);


                API_Logger__c objAPILogger = new API_Logger__c();
                objAPILogger.Name = 'FS_LMS_GetRecieptStatusAPI';
                objAPILogger.API_Name__c = 'FS_LMS_GetRecieptStatusAPI';
                objAPILogger.Status__c = 'Success';
                objAPILogger.Request__c = request.getBody();
                objAPILogger.Response__c = response.getBody().length() > 130068 ? response.getBody().substring(0, 130068) : response.getBody();
                objAPILogger.EndPoint__c = request.getEndpoint();
                listSobject.add(objAPILogger);

                if(objWrapResponse != null){

                }

            }else{
                system.debug('API exception '+response);
                system.debug('API exception getStatusCode '+response.getStatusCode());
                Error_Logger__c objErrorLog = new Error_Logger__c();
                objErrorLog.Exception_Message__c = response.getbody();
                objErrorLog.Name = 'FS_LMS_GetRecieptStatusAPI';
                //listSobject.add( objErrorLog ) ;
            }
        }
        catch(System.CalloutException e) {
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Name = 'FS_LMS_GetRecieptStatusAPI';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            //listSobject.add( objErrorLog );
        }
        catch(Exception e){
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Name = 'FS_LMS_GetRecieptStatusAPI';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            //listSobject.add( objErrorLog );
        }

        if( !listSobject.isEmpty() ){
            upsert  listSobject;
        }
    }

    //-------------------------------------------------------------------------
    public List<Success> success;

	public class Success {
		public Integer id;
		public Object transactionDate;
		public Object receiptPayOutType;
		public Object receiptPayOutMode;
		public Object paymentSubMode;
		public Integer loanId;
		public Object paymentBatchId;
		public String accountNumber;
		public Object productId;
		public Object bpTypeId;
		public Object businessPartnerId;
		public Object currencyCode;
		public Object transactionCurrencyCode;
		public Object loanBranch;
		public Object transactionBranch;
		public Object instrumentReferenceNumber;
		public Object instrumentDate;
		public Integer receiptOrPayoutAmount;
		public Object drawnOn;
		public Object transactionValueDate;
		public String status;
		public Object autoAllocation;
		public Object manuallyAllocated;
		public Object finalAllocationDone;
		public Object reversalAllowed;
		public String receiptNo;
		public Object receiptPayoutChannel;
		public Object receiptPurpose;
		public Object holdDate;
		public Object unholdDate;
		public Object bounceCancelReasonCode;
		public Object bounceCancelReasonId;
		public Object payInSlipReference;
		public Object beneficiaryAccountType;
		public Object beneficiaryAccountNumber;
		public Object sourceAccountNumber;
		public Object clearingHouseId;
		public String makeAuthorizeStatus;
		public Object bulkClearanceAmount;
		public Object pmdFlag;
		public Object allocationLevel;
		public Object actionDate;
		public Object cityId;
		public Object bankId;
		public Object bankBranchId;
		public Object micrCode;
		public Object micrNonMICR;
		public Object bulkClearanceReference;
		public Object bulkClearanceReferenceDate;
		public Object rejectCancelDeleteIndicator;
		public Object transactionReferenceId;
		public Object stage;
		public Object receiptAgainst;
		public Object fileNumber;
		public Object applicationId;
		public Object drawerName;
		public Object requestHeader;
		public String statusDescription;
		public Object creditDebitCard;
		public Object cardApprovalReferenceNumber;
		public Object allocationBreakUpDetails;
	}

	
	public static FS_LMS_GetRecieptStatusAPI parse(String json) {
		return (FS_LMS_GetRecieptStatusAPI) System.JSON.deserialize(json, FS_LMS_GetRecieptStatusAPI.class);
	}
}