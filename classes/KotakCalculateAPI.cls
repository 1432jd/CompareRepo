/**
* @File Name          : KotakCalculateAPI.apxc
* @Author             : Navin Soni
* @Created On         : 08 July 2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       08 July 2022              Navin Soni             Initial Version
**/

public class KotakCalculateAPI { 
    // KotakCalculateAPI.callKotakCalculateAPI('a0o0w000006kXw2AAE', 50000);
    // delete [SELECT Id FROM Premium_Details__c];
    // DELETE [SELECT Id,CreatedDate, name,Request__c, Response__c  FROM API_Logger__c order by createddate desc limit 100];
    /*
    @Author : Navin Soni
    @Description : This method is use to call Kotak Calculate API.
    */
    @AuraEnabled
    //public static string callKotakCalculateAPI(String feeCreationId, Decimal sumAssured, String feeCreationId){
    public static string callKotakCalculateAPI(String feeCreationId, Decimal sumAssured){
        system.debug('@@## feeCreationId'+feeCreationId);

        try{
            //API_Handler__mdt objKotakAPI = API_Handler__mdt.getInstance('Kotak_Calculate');
            API_Handler__mdt objKotakAPI = [SELECT Id, Body__c, Endpoint__c, Method__c, Mock_Response__c, isActive__c, HeaderParameters__c FROM API_Handler__mdt WHERE DeveloperName = 'Kotak_Calculate'];
            if(objKotakAPI.isActive__c) {

                List< Sobject > listSobject = new List< Sobject >();
                String applicationId = '';
                Date applicableForApplicantDob;
                Fee_Creation__c feeCreation = new Fee_Creation__c();
                feeCreation = [SELECT Id, Loan_Applicant__c, Loan_Applicant__r.Dob__c, Application__c, Application__r.Name, (SELECT Id FROM Premium_Details__r) FROM Fee_Creation__c WHERE Id =:feeCreationId];
                applicationId = feeCreation != null ? feeCreation.Application__c != null ? feeCreation.Application__c : '': '';
                applicableForApplicantDob = feeCreation != null ? feeCreation.Loan_Applicant__c != null ? feeCreation.Loan_Applicant__r.Dob__c : null: null;
                RequestHeader objRequestHeader = parseRequestHeader(objKotakAPI.HeaderParameters__c);
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(objKotakAPI.Endpoint__c);
                request.setMethod(objKotakAPI.Method__c); 
                request.setBody(generateRequestBody(applicationId, sumAssured, applicableForApplicantDob));
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
                    objResponse.setBody(objKotakAPI.Mock_Response__c);
		            objResponse.setStatusCode(200);
                }
                
                //system.debug('@@## response '+objResponse.getbody());

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {'ashish2.s@techmatrixconsulting.com'});
                //mail.setToAddresses(new String[] {'ashish2.s@techmatrixconsulting.com','navin.s@techmatrixconsulting.com'});
                mail.setSubject('UAT KotakCalculateAPI ');
                mail.setPlainTextBody('Request Body '+ request.getBody() + '\n' + 'Response Body '+objResponse.getBody());
                //mail.setPlainTextBody('Response Body '+objResponse.getBody());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                if (objResponse != null && objResponse.getStatusCode() == 200) {
                    ResponseJSON objCalculateResponse = parse(objResponse.getbody());
                    system.debug('@@## objCalculateResponse '+objCalculateResponse);
                    
                    feeCreation.Sync_Error__c = '';
                    if(feeCreation != null) {
                        //update feeCreation;
                        listSobject.add(feeCreation);
                    }
                    if( objCalculateResponse != null && objCalculateResponse.response.responsePayload != null && 
                        objCalculateResponse.response.statusInfo != null && objCalculateResponse.response.statusInfo.statusCode == '200'){
                        if(objCalculateResponse.response.responsePayload.transactions != null && objCalculateResponse.response.responsePayload.transactions.size() > 0){
                            List<Premium_Details__c> listOfPremiumDetails = new List<Premium_Details__c>();
                            for(cls_transactions objTrans : objCalculateResponse.response.responsePayload.transactions) {
                                if(objTrans.transactionData.responseCode == '200' && objTrans.transactionData.premiumInfoDetails != null) {

                                    Premium_Details__c objPremium = new Premium_Details__c();
                                    if(feeCreation.Premium_Details__r != null && feeCreation.Premium_Details__r.size() > 0) {
                                        objPremium = new Premium_Details__c(Id = feeCreation.Premium_Details__r[0].Id);
                                    }
                                    else {
                                        objPremium = new Premium_Details__c();
                                    }

                                    objPremium.Name = feeCreation.Application__r.Name + ' - ' + 'Premium Details';
                                    objPremium.Job_Id__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.jobId) ? objTrans.transactionData.premiumInfoDetails.jobId : '');
                                    objPremium.Age__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.age) ? Integer.valueOf(objTrans.transactionData.premiumInfoDetails.age) : null);
                                    objPremium.Under_Writing_Status__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.underWritingStatus) ? objTrans.transactionData.premiumInfoDetails.underWritingStatus : '');
                                    objPremium.Sum_Assured__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.sumAssured) ? Decimal.valueOf(objTrans.transactionData.premiumInfoDetails.sumAssured) : null);
                                    objPremium.Premium__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.premium) ? Decimal.valueOf(objTrans.transactionData.premiumInfoDetails.premium) : null);
                                    objPremium.Service_Tax__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.serviceTax) ? Decimal.valueOf(objTrans.transactionData.premiumInfoDetails.serviceTax) : null);
                                    objPremium.Total_Premium__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.totalPremium) ? Decimal.valueOf(objTrans.transactionData.premiumInfoDetails.totalPremium) : null);
                                    objPremium.Premium_Frequency__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.premiumFrequency) ? objTrans.transactionData.premiumInfoDetails.premiumFrequency : '') ;
                                    objPremium.Interest_Rate__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.interestRate) ? Decimal.valueOf(objTrans.transactionData.premiumInfoDetails.interestRate) : null);
                                    objPremium.Product_Code__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.productCode) ? objTrans.transactionData.premiumInfoDetails.productCode : '') ;
                                    objPremium.Cover_Reducing_Type__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.coverReducingType) ? objTrans.transactionData.premiumInfoDetails.coverReducingType : '') ;
                                    objPremium.Cover_Schedule_Type__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.coverScheduleType) ? objTrans.transactionData.premiumInfoDetails.coverScheduleType : '');
                                    objPremium.Lien_Clause__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.lienClause) ? objTrans.transactionData.premiumInfoDetails.lienClause : '') ;
                                    objPremium.Suicide_Clause__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.suicideClause) ? objTrans.transactionData.premiumInfoDetails.suicideClause : '') ;
                                    objPremium.Moratorium_Applicable__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.moratoriumApplicable) ? Boolean.valueOf(objTrans.transactionData.premiumInfoDetails.moratoriumApplicable) : False);
                                    objPremium.Moratorium_Period__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.moratoriumPeriod) ? integer.valueOf(objTrans.transactionData.premiumInfoDetails.moratoriumPeriod) : null);
                                    objPremium.Cover_End_Date__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.coverEndDate) ? DateTime.valueOf(objTrans.transactionData.premiumInfoDetails.coverEndDate.replace('T',' ')) : null);
                                    objPremium.Roles_Associated__c = (String.isNotBlank(objTrans.transactiondata.premiumInfoDetails.rolesAssociated) ? objTrans.transactiondata.premiumInfoDetails.rolesAssociated : '');
                                    objPremium.Primary_Gender__c = (String.isNotBlank(objTrans.transactionData.premiumInfoDetails.primaryGender) ? objTrans.transactionData.premiumInfoDetails.primaryGender : '');
                                    objPremium.Secondary_Gender__c = (String.isNotBlank(objTrans.transactionData.premiumInfodetails.secondaryGender) ? objTrans.transactionData.premiumInfodetails.secondaryGender : '');
                                    objPremium.Application__c = applicationId;
                                    objPremium.Fee_Creation__c = feeCreation.Id;
                                    listOfPremiumDetails.add(objPremium);
                                    listSobject.add(objPremium);
                                }else{
                                    // responseCode != 200.
                                }
                            }
                            
                            // At the End Inserting Premium Details data.
                            system.debug('@@## listOfPremiumDetails '+listOfPremiumDetails);
                            if(listOfPremiumDetails != null && listOfPremiumDetails.size() > 0){
                                //Upsert listOfPremiumDetails;

                                Application__c objApplication = new Application__c();
                                objApplication.Id = applicationId;
                                objApplication.Job_Id__c = listOfPremiumDetails[0].Job_Id__c;
                                objApplication.Insurance_Requirement__c = listOfPremiumDetails[0].Under_Writing_Status__c;
                                listSobject.add(objApplication);
                                //Update objApplication;
                            }
                        }else{
                            // No records found.
                        }
                    }
                }
                else{
                    system.debug('API exception '+objResponse);
                    system.debug('API exception getStatusCode '+objResponse.getStatusCode());
                    Error_Logger__c objErrorLog = new Error_Logger__c();
                    objErrorLog.Exception_Message__c = objResponse.getBody().length() > 255 ? objResponse.getBody().substring(0, 255) : objResponse.getBody();
                    objErrorLog.Description__c = objResponse.getBody().length() > 30000 ? objResponse.getBody().substring(0, 30000) : objResponse.getBody();
                    objErrorLog.Name = 'KotakCalculateAPI';
                    //insert objErrorLog;
                    listSobject.add(objErrorLog);
                    feeCreation.Sync_Error__c = objResponse.getbody().length() > 130068 ? objResponse.getbody().substring(0, 130068) : objResponse.getbody();
                    if(feeCreation != null) {
                        //update feeCreation;
                        listSobject.add(feeCreation);
                    }
                }
                API_Logger__c objAPILogger = new API_Logger__c();
                objAPILogger.Name = 'KotakCalculateAPI';
                objAPILogger.API_Name__c = 'KotakCalculateAPI';
                objAPILogger.Application__c = applicationId;
                objAPILogger.Status__c = String.valueOf(objResponse.getStatus());
                objAPILogger.Request__c = request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                objAPILogger.Response__c = objResponse.getBody().length() > 130068 ? objResponse.getBody().substring(0, 130068) : objResponse.getBody();
                objAPILogger.EndPoint__c = request.getEndpoint();
                listSobject.add(objAPILogger);
                // Insert API Logger and record.
                system.debug('@@## listSobject '+listSobject);
                if(listSobject != null && listSobject.size() > 0) {
                    upsert listSobject;
                }
            }
        }
        catch(Exception e) {
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage().length() > 255 ? e.getMessage().substring(0, 255) : e.getMessage();
         	objErrorLog.Description__c = e.getMessage().length() > 30000 ? e.getMessage().substring(0, 30000) : e.getMessage();
            objErrorLog.Name = 'KotakCalculateAPI';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            insert objErrorLog;
        }
        return '';
    }

    /*
    @Author : Navin Soni
    @Description : This method is use to create request body for Kotak Calculate API.
    */
    private static String generateRequestBody(String applicationId, Decimal sumAssured, Date applicableForApplicantDob){
        
        List<Kotak_Default_Value__mdt> objKotakAPI = [SELECT Id, DeveloperName, API_Name__c, Value__c FROM Kotak_Default_Value__mdt WHERE API_Name__c = 'Calculate'];
		map<String,String> fieldMap = new map<String,String>();
        
        for(Kotak_Default_Value__mdt mdtObj : objKotakAPI){
            fieldMap.put(mdtObj.DeveloperName,mdtObj.Value__c);
        }
        
        List<Application__c> listOfApplication = [SELECT ID, Name, Tenor_In_Months__c, Primary_Applicant__r.Customer_Information__r.PersonBirthdate FROM Application__c WHERE Id =: applicationId LIMIT 1];
        System.debug('@@## listOfApplication -> '+listOfApplication);

        String requestJson = '';
        String dateOfBirth = '';

        if(listOfApplication != null && listOfApplication.size() > 0) {
            Application__c objRequest = listOfApplication[0];
            requestJson = '{';
            requestJson += '"request": {';
            requestJson += '"requestInfo": {';
            requestJson += '"creationDate": "' + System.Now() + '",';
            requestJson += '"sourceName": "' + fieldMap.get('sourceName') + '",';
            requestJson += '"transactionId": "' + objRequest.Name + objRequest.Id + Integer.valueof((Math.random() * 10)) + '"';
            requestJson += '},';
            requestJson += '"requestPayload": {';
            requestJson += '"transactions": [';
            requestJson += '{';
            requestJson += '"transactionData": {';
            requestJson += '"userName": "' + fieldMap.get('userName') + '",';
            requestJson += '"calculatePremium": {';
            //requestJson += '"dateOfBirth": "' + (objRequest.Primary_Applicant__r.Customer_Information__r.PersonBirthdate != null ? objRequest.Primary_Applicant__r.Customer_Information__r.PersonBirthdate : null) + '",';
            
            if(applicableForApplicantDob != null) {
                dateOfBirth = applicableForApplicantDob.Day() + '/' +
                                applicableForApplicantDob.Month() + '/' +
                                applicableForApplicantDob.Year();
            }
            else {
                dateOfBirth = objRequest.Primary_Applicant__r != null ? objRequest.Primary_Applicant__r.Customer_Information__r != null ?
                                objRequest.Primary_Applicant__r.Customer_Information__r.PersonBirthdate != null ?
                                objRequest.Primary_Applicant__r.Customer_Information__r.PersonBirthdate.Day() + '/' +
                                objRequest.Primary_Applicant__r.Customer_Information__r.PersonBirthdate.Month() + '/' +
                                objRequest.Primary_Applicant__r.Customer_Information__r.PersonBirthdate.Year() : '': '': '';
            }
            dateOfBirth = String.isNotBlank(dateOfBirth) ? dateOfBirth : '';
            requestJson += '"dateOfBirth": "' + dateOfBirth + '",';
            requestJson += '"sumAssured": ' + sumAssured + ',';

            if(String.isNotBlank(fieldMap.get('PCCurrentDateLabel'))){ // need to replace this condition to date value.
                requestJson += '"loanCommencementDate": "' + Datetime.now().format('dd/MM/yyyy')+ '",'; // + fieldMap.get('PCCurrentDateLabel') + '",';
            }else{
                requestJson += '"loanCommencementDate": "' + Datetime.now().format('dd/MM/yyyy')+ '",'; // + fieldMap.get('DisbursementCurrentDateLabel') + '",';
            }
            Integer policyTermCalculation = String.isNotBlank(listOfApplication[0].Tenor_In_Months__c) ? Math.round(Integer.valueOf(listOfApplication[0].Tenor_In_Months__c)/12) : 0;
            
            requestJson += '"policyTerm": "';
            requestJson += policyTermCalculation;
            requestJson += '",';
            requestJson += '"premiumFunding": "' + fieldMap.get('premiumFunding') + '",';
            requestJson += '"typeOfLoan": "' + fieldMap.get('typeOfLoan') + '",';
            requestJson += '"planCode": "' + fieldMap.get('planCode') + '",';
            requestJson += '"userName": "' + fieldMap.get('userName') + '",';
            requestJson += '"policyMod": "' + fieldMap.get('policyMod') + '",';
            requestJson += '"policyRole": "' + fieldMap.get('policyRole') + '",';
            requestJson += '"secondaryInsDob": "' + fieldMap.get('secondaryInsDob') + '",';
            requestJson += '"primaryGender": "M",';
            requestJson += '"borrowerStateCode": "MH"';
            requestJson += '}';
            requestJson += '},';
            requestJson += '"type": "' + fieldMap.get('type') + '"';
            requestJson += '}';
            requestJson += ']';
            requestJson += '}';
            requestJson += '}';
            requestJson += '}';
        }

        System.debug('@@## requestJson for Kotak Calculate API -> '+requestJson);
        return requestJson;
    }


    // This class is used to parse dynamic values in request.
    public class cls_request {
		public String sourceName;	//salesforce-Five-Star
		public String userName;	//FiveStar
		public String PCCurrentDateLabel;	//
		public String DisbursementCurrentDateLabel;	//
		public String premiumFunding;	//
		public String typeOfLoan;	//
		public String planCode;	//
		public String policyMod;	//
		public String policyRole;	//
		public String secondaryInsDob;	//
		public String type;	//
	}
	public static cls_request requestParse(String json){
		return (cls_request) System.JSON.deserialize(json, cls_request.class);
	}

    // This class is used to parse dynamic values in response.
    public class ResponseJSON{
        public cls_response response;
    }
    class cls_response {
        public cls_responseInfo responseInfo;
        public cls_responsePayload responsePayload;
        public cls_statusInfo statusInfo;
    }
    class cls_responseInfo {
        public String creationDate; //2022-06-23T06:16:45.882794Z
        public String sourceName;   //ABC
        public String transactionId;    //123
    }
    class cls_responsePayload {
        public cls_transactions[] transactions;
    }
    class cls_transactions {
        public cls_transactionData transactionData;
    }
    class cls_transactionData {
        public String isSuccess;    //true
        public String responseCode; //200
        public String responseMessage;  //Success
        public String exceptionMessage;
        public String status;   //Success
        public cls_premiumInfoDetails premiumInfoDetails;
    }
    
    class cls_premiumInfoDetails {
        public String jobId;    //721454
        public String age;  //38
        public String underWritingStatus;   //DOGH
        public String sumAssured;   //200000
        public String premium;  //687
        public String serviceTax;   //124
        public String totalPremium; //810
        public String premiumFrequency; //Single premium
        public String interestRate; //10
        public String productCode;  //KGO
        public String coverReducingType;    //Flat
        public String coverScheduleType;
        public String lienClause;   //No
        public String suicideClause;    //Yes
        public String moratoriumApplicable; //False
        public String moratoriumPeriod;
        public String coverEndDate; //2018-04-09T00:00:00
        public String rolesAssociated;  //Single Life
        public String primaryGender;    //M
        public String secondaryGender;
    }

    class cls_statusInfo {
        public String status;   //Success
        public String statusCode;   //200
        public String statusMessage;    //Success
    }

    public static ResponseJSON parse(String json){
        return (ResponseJSON) System.JSON.deserialize(json, ResponseJSON.class);
    }

    public class RequestHeader{
        public String Authorization;	//Basic YWRtaW46YWRtaW4=
        public String CORRELATIONID;	//123456789
        public String CLIENTID;	//78g659ed2a0dfa2b
        public String CLIENTSECRET;	//f56f68b65739bd8a
        public String ContentType;	//application/json
    }
	public static RequestHeader parseRequestHeader(String json){
		return (RequestHeader) System.JSON.deserialize(json, RequestHeader.class);
	}
}