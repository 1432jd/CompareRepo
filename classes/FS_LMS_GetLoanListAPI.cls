/**
 * @author            :
 * @group             : TechMatrix Consulting
 * @description       :
 * @created on        :
 * @last modified on  : 17-07-2022
 * @last modified by  : Karan Singh Soni
**/
public without sharing class FS_LMS_GetLoanListAPI {

    public static void getLoanList(){

        List< Sobject > listSobject = new List< Sobject >();
        try{
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://uat-api.fsbl.in/api/1.0/ux/loan?branchId=5&applicationId=5001526');
        request.setMethod('GET');
        request.setHeader('Authorization', 'Basic YWRtaW46YWRtaW4=');
        request.setHeader('CORRELATION-ID', 'HFGKDHN');
        request.setHeader('CLIENT-ID','78g659ed2a0dfa2b');
        request.setHeader('CLIENT-SECRET','f56f68b65739bd8a');

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' +EncodingUtil.base64Encode(Blob.valueOf('admin:admin')));
        request.setHeader('CustomerNumber','CjZmZm7ifLHVdbhi6+b7F5hIT51oGMPgeLDnC9wVi9o=.rIwqqHpfNJzOi/zKtE0jgg==');
        request.setTimeout(120000);
        
        HttpResponse response = http.send(request);
        System.debug('URL : ' + request.getEndpoint());
        System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
        System.debug(response.getBody());
        if (response != null && response.getStatusCode() == 200) {

            FS_LMS_GetLoanListAPI objWrapResponse = parse(response.getbody());
            system.debug('@@## objRegResponse '+objWrapResponse);


            API_Logger__c objAPILogger = new API_Logger__c();
            objAPILogger.Name = 'FS_LMS_GetLoanListAPI';
            objAPILogger.API_Name__c = 'FS_LMS_GetLoanListAPI';
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
            objErrorLog.Name = 'FS_LMS_GetLoanListAPI';
            //listSobject.add( objErrorLog ) ;
        }
    }
    catch(System.CalloutException e) {
        system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
        Error_Logger__c objErrorLog = new Error_Logger__c();
        objErrorLog.Exception_Message__c = e.getMessage();
        objErrorLog.Name = 'FS_LMS_GetLoanListAPI';
        objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
        //listSobject.add( objErrorLog );
    }
    catch(Exception e){
        system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
        Error_Logger__c objErrorLog = new Error_Logger__c();
        objErrorLog.Exception_Message__c = e.getMessage();
        objErrorLog.Name = 'FS_LMS_GetLoanListAPI';
        objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
        //listSobject.add( objErrorLog );
    }

    if( !listSobject.isEmpty() ){
        upsert  listSobject;
    }
    }

    public Object acknowledgement;
	public String responseCode;
	public Object responseString;
	public List<Payload> payload;

	public class Payload {
		public String loanAccountNumber;
		public String applicationId;
		public String currencyIsoCode;
		public String customerNumber;
		public String applicationFileNumber;
		public Object hostCifNumber;
		public String productCode;
		public String schemeCode;
		public String disbursalDate;
		public Integer financedAmount;
		public Integer tenure;
		public Integer finalSanctionedAmount;
		public String maturityDate;
		public String loanStatus;
	}

	
	public static FS_LMS_GetLoanListAPI parse(String json) {
		return (FS_LMS_GetLoanListAPI) System.JSON.deserialize(json, FS_LMS_GetLoanListAPI.class);
	}
}