/**
* @File Name          : EmandateRegistrationAPI.apxc
* @Author             : Navin Soni
* @Created On         : 10 July 2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       10 July 2022              Navin Soni             Initial Version
**/

public class EmandateRegistrationAPI { 
    
    /*
@Author : Navin Soni
@Description : This method is use to call Emandate Registration API.
*/
    @AuraEnabled
    public static string callEmandateRegistrationAPI(String BankDetailId){
        String applicationId = '';
        system.debug('@@## BankDetailId'+BankDetailId);
        List<Bank_Detail__c> listOfBankDetail = [SELECT ID, Name, Account_Type__c, Account_Number__c, Application__c, Application__r.Name, Application__r.Total_Amount_Recommended_PcAc__c, Loan_Applicant__r.Applicant_Name__c, Loan_Applicant__r.Mobile__c FROM Bank_Detail__c WHERE ID =: BankDetailId];
        System.debug('@@## listOfBankDetail -> '+listOfBankDetail);

        if(listOfBankDetail != null && listOfBankDetail.size() > 0){
            try{
                applicationId = listOfBankDetail[0].Application__c != null ? listOfBankDetail[0].Application__c : '';
                // API_Handler__mdt EmandateAPI = API_Handler__mdt.getInstance('Emandate_Registration');
                API_Handler__mdt EmandateAPI = [SELECT Id, Body__c, Endpoint__c, Method__c, Mock_Response__c, isActive__c, HeaderParameters__c FROM API_Handler__mdt WHERE DeveloperName = 'Emandate_Registration'];
                
                if(EmandateAPI.isActive__c){
                    RequestHeader objRequestHeader = parseRequestHeader(EmandateAPI.HeaderParameters__c);
                    
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(EmandateAPI.Endpoint__c);
                    request.setMethod(EmandateAPI.Method__c); 
                    request.setBody(generateRequestBody(listOfBankDetail[0]));
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
                    objAPILogger.Name = 'EmandateRegistrationAPI';
                    objAPILogger.API_Name__c = 'EmandateRegistrationAPI';
                    objAPILogger.Application__c = applicationId;
                    objAPILogger.Status__c = objResponse.getStatus();
                    objAPILogger.Request__c = request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                    objAPILogger.Response__c = objResponse.getBody().length() > 130068 ? objResponse.getBody().substring(0, 130068) : objResponse.getBody();
                    objAPILogger.EndPoint__c = request.getEndpoint();
                    insert objAPILogger;

                    if (objResponse != null && objResponse.getStatusCode() == 200) {
                        ResponseJSON objRegResponse = parse(objResponse.getbody());
                        system.debug('@@## objRegResponse '+objRegResponse);
                        
                        if(objRegResponse != null && String.isNotBlank(objRegResponse.mandateReqID)){
                            Application__c objApp = new Application__c();
                            objApp.Id = listOfBankDetail[0].Application__c;
                            objApp.Mandate_Req_ID__c = objRegResponse.mandateReqID;
                            objApp.Registration_URL__c = objRegResponse.url;
                            system.debug('@@## Mandate_Req_ID__c '+objApp.Mandate_Req_ID__c);
                            
                            system.debug('@@## objApp '+objApp);
                            update objApp;
                            
                            return objRegResponse.url;
                        }
                        
                    }else{
                        system.debug('API exception '+objResponse);
                        system.debug('API exception getStatusCode '+objResponse.getStatusCode());
                        Error_Logger__c objErrorLog = new Error_Logger__c();
                        objErrorLog.Exception_Message__c = objResponse.getBody().length() > 255 ? objResponse.getBody().substring(0, 255) : objResponse.getBody();
                        objErrorLog.Description__c = objResponse.getBody().length() > 30000 ? objResponse.getBody().substring(0, 30000) : objResponse.getBody();                        objErrorLog.Name = 'EmandateRegistrationAPI';
                        objErrorLog.Name = 'EmandateRegistrationAPI';
                        
                        insert objErrorLog;
                    }
                }
            }
            catch(Exception e){
                system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
                Error_Logger__c objErrorLog = new Error_Logger__c();
                objErrorLog.Exception_Message__c = e.getMessage().length() > 255 ? e.getMessage().substring(0, 255) : e.getMessage();
                objErrorLog.Description__c = e.getMessage().length() > 30000 ? e.getMessage().substring(0, 30000) : e.getMessage();            
                objErrorLog.Name = 'EmandateRegistrationAPI';
                objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());                
                insert objErrorLog;
            }
        }
        return '';
    }
    
    /*
@Author : Navin Soni
@Description : This method is use to create request body for Emandate Registration API.
*/
    private static String generateRequestBody(Bank_Detail__c objBankDetail){
        
        // This is use to mapped dynamic values in request.
        //API_Handler__mdt objEmandateAPI = [SELECT Id, Body__c FROM API_Handler__mdt WHERE DeveloperName = 'Emandate_Registration'];
        List<Emandate_Default_Values__mdt> objEmandateAPI = [SELECT Id, DeveloperName, API_Name__c,Value__c FROM Emandate_Default_Values__mdt WHERE API_Name__c = 'Registration'];
        map<String,String> fieldMap = new map<String,String>();
        
        for(Emandate_Default_Values__mdt mdtObj : objEmandateAPI){
            fieldMap.put(mdtObj.DeveloperName,mdtObj.Value__c );
        }
        cls_request objEmandateReq = new cls_request();
        DateTime dt = System.now();
        
        String requestJson = '';
        requestJson += '{';
        requestJson += '"title": "Mrs",';
        requestJson += '"name": "' + objBankDetail.Loan_Applicant__r.Applicant_Name__c + '",';
        requestJson += '"mobileNumber": ' + objBankDetail.Loan_Applicant__r.Mobile__c + ',';
        requestJson += '"stdCode": "022",';
        requestJson += '"telephoneNumber": 11234543,';
        requestJson += '"emailId": "veneetia@gmail.com",';
        requestJson += '"pan": "PPAZM1234M",';
        //requestJson += '"accountType": "' + objBankDetail.Account_Type__c + '",';
        requestJson += '"accountType": "' + fieldMap.get('accountType') + '",';
        requestJson += '"accountNumber": "' + objBankDetail.Account_Number__c + '",';
        requestJson += '"amountType": "' + fieldMap.get('amountType') + '",';
        requestJson += '"amount": '+ objBankDetail.Application__r.Total_Amount_Recommended_PcAc__c + ',';//Loan_Amount__c Change by Umair
        requestJson += '"frequency": "' + fieldMap.get('frequency') + '",';  
        requestJson += '"startDate": "' + Datetime.now().format('dd-MM-yyyy')  +'",';
        requestJson += '"endDate": "' + fieldMap.get('endDate') + '",';
        requestJson += '"destinationBank": "' + fieldMap.get('destinationBank') + '",';
        String ApplicationName = objBankDetail.Application__r.Name.replace(' - ','');
        requestJson += '"mandateReqId": "' + 'API' + ApplicationName + dt.year() + dt.month() + dt.day() + dt.hour() + dt.minute() + dt.second() +'",';
        requestJson += '"utilityCode": "' + fieldMap.get('utilityCode') + '",';
        requestJson += '"categoryCode": "' + fieldMap.get('categoryCode') + '",';
        requestJson += '"freeText1": "a",';
        requestJson += '"freeText2": "b",';
        requestJson += '"freeText3": "c",';
        requestJson += '"freeText4": "c"';
        requestJson += '}';    
        
        System.debug('@@## requestJson for Kotak Calculate API -> '+requestJson);
        return requestJson;
    }
    
    public class cls_request{
        public String title;    //Mrs
        public String name; //veeta nair
        public String stdCode;  //022
        public Integer telephoneNumber; //11234543
        public String emailId;  //veneetiaaaaaabcedfghijklknopqurstuvwdxyz@gmail.com
        public String pan;  //PPAZM1234M
        public String accountType;  //Saving Account
        public String accountNumber;    //11111
        public String amountType;   //Fixed
        public Integer amount;  //128
        public String frequency;    //Bi-Monthly
        public String startDate;    //05-08-2022
        public String endDate;  //07-08-2023
        public String destinationBank;  //UTIB
        public String mandateReqId; //API3488678901123457891014015
        public String utilityCode;  //RATN00005000010550
        public String categoryCode; //B001
        public String freeText1;    //a
        public String freeText2;    //b
        public String freeText3;    //c
        public String freeText4;    //c
    }
    
    public class ResponseJSON{
        public String status;   //1
        public String url;  
        public String mandateReqID; //API3488678901123457891014015
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
}