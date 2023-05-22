/**
 * @author            : Ashish Sharma/Navin Soni
 * @group             : TechMatrix Consulting
 * @description       :
 * @created on        :
 * @last modified on  : 17-07-2022
 * @last modified by  : Ashish Sharma
**/
public without sharing class FS_LMS_GetRepayScheduleAPI {

    //FS_LMS_GetRepayScheduleAPI.getRepaySchedule('a030w000009j0dUAAQ');
    // SELECT ID, Name, Sourcing_Branch__c, Sourcing_Branch__r.Branch_Code__c, Sourcing_Branch__r.Lms_Branch_Code__c, LMS_Response_Reference__c FROM Application__c WHERE LMS_Response_Reference__c !=''
    /**  
    @author           : Ashish Sharma
    @description      :	Method to make Callout and get Repay file from API response.
    */
    @AuraEnabled
    public static String getRepaySchedule( String apptId) {
        String APIResponse = '';
        List< Sobject > listSobject = new List< Sobject >();
        if(String.isNotBlank(apptId)) {
            try{
                API_Handler__mdt objLMS_GetRepaySchedule = API_Handler__mdt.getInstance('LMS_GetRepaySchedule');
                if(objLMS_GetRepaySchedule.isActive__c) {

                    Application__c objApp = [SELECT ID, Name, Sourcing_Branch__c, Sourcing_Branch__r.Branch_Code__c, Sourcing_Branch__r.Lms_Branch_Code__c, LMS_Response_Reference__c 
                                                FROM Application__c WHERE Id =: apptId LIMIT 1];
                    String apptName = objApp.Name;
                    String loanId = String.isNotBlank(objApp.LMS_Response_Reference__c) ?
                                    objApp.LMS_Response_Reference__c.replaceAll('[^0-9]+', '').replaceFirst('^0+', '') : '';
                                    
                    RequestHeader objRequestHeader = parseRequestHeader(objLMS_GetRepaySchedule.HeaderParameters__c);
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();

                    request.setEndpoint(objLMS_GetRepaySchedule.Endpoint__c);
                    request.setMethod(objLMS_GetRepaySchedule.Method__c);
                    request.setHeader('Authorization', objRequestHeader.Authorization);
                    request.setHeader('CORRELATION-ID', objRequestHeader.CORRELATIONID);
                    request.setHeader('CLIENT-ID', objRequestHeader.CLIENTID);
                    request.setHeader('CLIENT-SECRET', objRequestHeader.CLIENTSECRET);
                    request.setHeader('Content-Type', objRequestHeader.ContentType);
                    request.setTimeout(120000);
                    //request.setHeader('loanId', CryptoClass.perfromEncrypt(objApp.Sourcing_Branch__r.Lms_Branch_Code__c));
                    request.setHeader('loanId', CryptoClass.perfromEncrypt(loanId));
                    request.setHeader('loanAccountNumber', CryptoClass.perfromEncrypt(objApp.LMS_Response_Reference__c));

                    //request.setHeader('loanId', CryptoClass.perfromEncrypt('05277735'));
                    //request.setHeader('loanAccountNumber', CryptoClass.perfromEncrypt('FSTNLALONS000005277735'));
                    //request.setHeader('loanId', CryptoClass.perfromEncrypt('5001526'));
                    //request.setHeader('loanAccountNumber', CryptoClass.perfromEncrypt('FSTNLALONS000005001121'));

                    //request.setHeader('loanId','4Rk+lCAYd/3UrP/AfdhrsQ==.g/gdsPMAFfA00KRPY9JusQ==');
                    //request.setHeader('loanAccountNumber','6+AQdUmSiXbngeDfhNoGighgCqKZKuAXbjf/L7DmIjA=.oqCqddpgnoDGZQdntI+aOw==');

                    HttpResponse response = new HttpResponse();
                    if(!Test.isRunningTest()) {
                        response = http.send(request);
                    } else {
                        response.setBody(objLMS_GetRepaySchedule.Mock_Response__c);System.debug(objLMS_GetRepaySchedule.Mock_Response__c);
                        response.setStatusCode(200);
                    }
                    System.debug('URL : ' + request.getEndpoint());
                    System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
                    //System.debug(response.getBody());
                                        
                    API_Logger__c objAPILogger = new API_Logger__c();
                    objAPILogger.Name = 'FS_LMS_GetRepayScheduleAPI';
                    objAPILogger.API_Name__c = 'FS_LMS_GetRepayScheduleAPI';
                    objAPILogger.Application__c = apptId;
                    objAPILogger.Status__c = String.valueOf(response.getStatus());
                    objAPILogger.Request__c = request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                    objAPILogger.Response__c = response.getBody().length() > 130068 ? response.getBody().substring(0, 130068) : response.getBody();
                    objAPILogger.EndPoint__c = request.getEndpoint();
                    listSobject.add(objAPILogger);

                    if (response != null && response.getStatusCode() == 200) {
                        

                        FS_LMS_GetRepayScheduleAPI objWrapResponse = parse(response.getbody());
                        system.debug('@@## objRegResponse '+objWrapResponse);

                        if(objWrapResponse != null && String.isNotBlank(objWrapResponse.pdfData)) {
                            listSobject.add( new Application__c( Id = apptId, GetRepayScheduleCalled__c = true ));
                            ContentVersion cv = new ContentVersion();
                            cv.VersionData = EncodingUtil.base64Decode(objWrapResponse.pdfData);
                            cv.FirstPublishLocationId = apptId;
                            cv.Is_Additional_Document__c = true;
                            cv.Uploaded_From__c = 'Disbursal Author';
                            cv.Title = 'RepaySchedule - ' + apptName + '.pdf';
                            cv.PathOnClient = 'RepaySchedule - ' + apptName + '.pdf';
                            listSobject.add(cv);
                            APIResponse = 'Success_For ' + apptName + ' Repay Schedule API Executed Successfully.!';
                            // Update the Application Stage once GEt Repay Schedule API Succeed.
                            //listSobject.add( new Application__c( Id = apptId, Stage__c = 'Document Deferral' ));
                        }
                    }
                    else {
                        system.debug('API exception '+response);
                        system.debug('API exception getStatusCode '+response.getStatusCode());
                        Error_Logger__c objErrorLog = new Error_Logger__c();
                        objErrorLog.Description__c = response.getbody().length() > 30068 ? response.getbody().substring(0, 30068) : response.getbody();
                        objErrorLog.Name = 'FS_LMS_GetRepayScheduleAPI';
                        listSobject.add( objErrorLog ) ;
                        cls_errorClass objclserrorClass = parseError(response.getBody());
                        APIResponse = 'Error_For ' +objclserrorClass.error.description;
                    }
                }
            }
            catch(Exception e) {
                system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
                Error_Logger__c objErrorLog = new Error_Logger__c();
                objErrorLog.Description__c = e.getMessage().length() > 30068 ? e.getMessage().substring(0, 30068) : e.getMessage();
                objErrorLog.Name = 'FS_LMS_GetRepayScheduleAPI';
                objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
                listSobject.add( objErrorLog );
                APIResponse = 'Error_For '+ e.getMessage();
            }
            if(!listSobject.isEmpty()) {
                upsert listSobject;
            }
        }
        return APIResponse;
    }

    public String pdfData;
	
	public static FS_LMS_GetRepayScheduleAPI parse(String json) {
		return (FS_LMS_GetRepayScheduleAPI) System.JSON.deserialize(json, FS_LMS_GetRepayScheduleAPI.class);
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