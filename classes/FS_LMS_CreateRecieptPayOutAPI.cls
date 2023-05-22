/**
 * @author            :
 * @group             : TechMatrix Consulting
 * @description       :
 * @created on        :
 * @last modified on  : 17-07-2022
 * @last modified by  : Karan Singh Soni
**/
public without sharing class FS_LMS_CreateRecieptPayOutAPI {

    public static void createRecieptPayOut(){

        List< Sobject > listSobject = new List< Sobject >();

        //receiptNo should be unique
        String payload = '{ "requestHeader": { "tenantId": 505, "userDetail": { "userCode": "cas_it2", "branchId": 5000400 } }, "receiptPayOutMode": 2668, "receiptAgainst": 51130, "transactionValueDate": "25/04/2021", "receiptOrPayoutAmount": 10010, "autoAllocation": "Y", "receiptNo": "638699", "receiptPurpose": 51160, "allocatedAmount": "1", "applicationId": 147896, "applicationFormNumber": "846531" }';
try{

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://uat-api.fsbl.in/api/1.0/ux/receipt');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Basic YWRtaW46YWRtaW4=');
        request.setHeader('CORRELATION-ID', 'HFGKDHN');
        request.setHeader('CLIENT-ID','78g659ed2a0dfa2b');
        request.setHeader('CLIENT-SECRET','f56f68b65739bd8a');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' +EncodingUtil.base64Encode(Blob.valueOf('admin:admin')));
        request.setBody(payload);
        request.setTimeout(120000);
        System.debug(payload);

        request.setBody(payload);
        HttpResponse response = http.send(request);
        System.debug('URL : ' + request.getEndpoint());
        System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
        System.debug(response.getBody());
        if (response != null && response.getStatusCode() == 201) {

            FS_LMS_CreateRecieptPayOutAPI objWrapResponse = parse(response.getbody());
            system.debug('@@## objRegResponse '+objWrapResponse);


            API_Logger__c objAPILogger = new API_Logger__c();
            objAPILogger.Name = 'FS_LMS_CreateRecieptPayOutAPI';
            objAPILogger.API_Name__c = 'FS_LMS_CreateRecieptPayOutAPI';
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
            objErrorLog.Name = 'FS_LMS_CreateRecieptPayOutAPI';
            //listSobject.add( objErrorLog ) ;
        }
    }
    catch(System.CalloutException e) {
        system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
        Error_Logger__c objErrorLog = new Error_Logger__c();
        objErrorLog.Exception_Message__c = e.getMessage();
        objErrorLog.Name = 'FS_LMS_CreateRecieptPayOutAPI';
        objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
        //listSobject.add( objErrorLog );
    }
    catch(Exception e){
        system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
        Error_Logger__c objErrorLog = new Error_Logger__c();
        objErrorLog.Exception_Message__c = e.getMessage();
        objErrorLog.Name = 'FS_LMS_CreateRecieptPayOutAPI';
        objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
        //listSobject.add( objErrorLog );
    }

    if( !listSobject.isEmpty() ){
        upsert  listSobject;
    }
    }

    public List<Success> success;

	public class Success {
		public String i18nCode;
		public List<String> messageArguments;
		public String type;
		public Boolean isParent;
		public String value;
	}

	
	public static FS_LMS_CreateRecieptPayOutAPI parse(String json) {
		return (FS_LMS_CreateRecieptPayOutAPI) System.JSON.deserialize(json, FS_LMS_CreateRecieptPayOutAPI.class);
	}
    
}