/**
 * @author            : Ashish Sharma/Navin Soni
 * @group             : TechMatrix Consulting
 * @description       :
 * @created on        :
 * @last modified on  : 17-07-2022
 * @last modified by  : Ashish Sharma on 24/08/2022
**/
public without sharing class FS_LMS_CreateColletralAPI {
	// Created by Ashish Sharma 24/08/2022 for store Property detail
    // FS_LMS_CreateColletralAPI.createColletral('a0L0w000002bIqgEAE');
	public static Property__c propertyRecord;
    

    @AuraEnabled
    public static String createColletral( String propertyRecordId ) {
        System.debug('id----- '+propertyRecordId);
        String APIResponse = '';

        if (String.isNotBlank(propertyRecordId)) {
            fetchPropertyDetails(propertyRecordId);
            if(propertyRecord != null) {
                List< Sobject > listSobject = new List< Sobject >();
                String payload = '';
                List<Property__c> propertyRecords = new List<Property__c>();
                String applicationId = '';
                payload = generateRequestJson();

                try {
                    propertyRecords = [SELECT Id, Application__c FROM Property__c WHERE Id =: propertyRecordId];
                    if(propertyRecords.size() > 0) {
                        applicationId = propertyRecords[0].Application__c != null ? propertyRecords[0].Application__c : '';
                    }
                    API_Handler__mdt objLMS_CreateCollateralAPI = API_Handler__mdt.getInstance('LMS_CreateCollateral');
                    if(objLMS_CreateCollateralAPI.isActive__c) {
                        RequestHeader objRequestHeader = parseRequestHeader(objLMS_CreateCollateralAPI.HeaderParameters__c);

                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(objLMS_CreateCollateralAPI.Endpoint__c);
                        request.setMethod(objLMS_CreateCollateralAPI.Method__c);
                        request.setHeader('Authorization', objRequestHeader.Authorization);
                        request.setHeader('CORRELATION-ID', objRequestHeader.CORRELATIONID);
                        request.setHeader('CLIENT-ID', objRequestHeader.CLIENTID);
                        request.setHeader('CLIENT-SECRET', objRequestHeader.CLIENTSECRET);
                        request.setHeader('Content-Type', objRequestHeader.ContentType);
                        request.setBody(payload);
                        request.setTimeout(120000);
                        
                        HttpResponse response = new HttpResponse();
                        if(!Test.isRunningTest()) {
                            response = http.send(request);
                        } else {
                            response.setBody(objLMS_CreateCollateralAPI.Mock_Response__c);
                            response.setStatusCode(200);
                        }

                        System.debug('URL : ' + request.getEndpoint());
                        System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
                        System.debug(response.getBody());

                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {'ashish2.s@techmatrixconsulting.com'});
                        mail.setSubject('UAT CollateralAPI');
                        mail.setPlainTextBody('Response Body '+ response.getBody() + '\n\nRequest Body '+payload);
                        //mail.setPlainTextBody('Request Body '+payload);
                        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                        API_Logger__c objAPILogger = new API_Logger__c();
                        objAPILogger.Name = 'Colletral API';
                        objAPILogger.API_Name__c = 'FS_LMS_CreateColletralAPI';
                        objAPILogger.Application__c = applicationId;
                        objAPILogger.Status__c = String.valueOf(response.getStatus());
                        objAPILogger.Request__c = request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                        objAPILogger.Response__c = response.getBody().length() > 130068 ? response.getBody().substring(0, 130068) : response.getBody();
                        objAPILogger.EndPoint__c = request.getEndpoint();
                        listSobject.add(objAPILogger);

                        if (response != null && response.getStatusCode() == 201) {

                            FS_LMS_CreateColletralAPI objWrapResponse = parse(response.getbody());
                            system.debug('@@## objRegResponse '+objWrapResponse);

                            if(objWrapResponse != null) {
                                if( String.isNotBlank(objWrapResponse.globalCollateralNumber )) {
                                    listSobject.add( new Property__c( Id = propertyRecordId, Sync_Error__c = '',
                                                    LMS_Collateral_Number__c = objWrapResponse.globalCollateralNumber));
                                }
                            }
                            APIResponse = 'Success_For ' + propertyRecord.Name + ' Collateral Executed API Successfully.!';
                        }
                        else {
                            system.debug('API exception '+response);
                            system.debug('API exception getStatusCode '+response.getStatusCode());
                            Error_Logger__c objErrorLog = new Error_Logger__c();
                            //objErrorLog.Exception_Message__c = response.getbody();
                            objErrorLog.Description__c = response.getbody().length() > 30068 ? response.getbody().substring(0, 30068) : response.getbody();
                            objErrorLog.Name = 'FS_LMS_CreateColletralAPI';
                            listSobject.add( objErrorLog ) ;
                            Property__c property = new Property__c(Id = propertyRecordId);
                            property.Sync_Error__c = response.getbody().length() > 130068 ? response.getbody().substring(0, 130068) : response.getbody();
                            if(property != null) {
                                listSobject.add(property);
                            }
                            cls_errorClass objclserrorClass = parseError(response.getBody());
                            APIResponse = 'Error_For ' + propertyRecord.Name + ' ' +objclserrorClass.error.description;
                        }
                    }
                }
                catch(Exception e) {
                    system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
                    Error_Logger__c objErrorLog = new Error_Logger__c();
                    //objErrorLog.Exception_Message__c = e.getMessage();
                    objErrorLog.Name = 'FS_LMS_CreateCustomerAPI';
                    objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
                    objErrorLog.Description__c = e.getMessage().length() > 30068 ? e.getMessage().substring(0, 30068) : e.getMessage();
                    listSobject.add( objErrorLog );
					//insert objErrorLog;
                    APIResponse = 'Error_For ' + propertyRecord.Name + ' ' +e.getMessage();
                }
                if( !listSobject.isEmpty() ) {
                    upsert listSobject;
                }
            }
        }
        else {
            System.debug('Property record id not available'); 
             // throw exception Property record id not available
             APIResponse = 'Error_Property Record Id Not Available.';
        }
        return APIResponse;
    }
    
    // Created by Ashish Sharma 24/08/2022
    private static void fetchPropertyDetails( String propertyRecordId ) {
        List<Property__c> properties = new List<Property__c>();
        properties = [SELECT Id, Name, Collateral_Sub_Type_Property_Details__c, Collateral_Type__c,
                                                    Property_Location_Classification__c, Property_Ownership__c, Property_Type__c,
                                                    Nature_Of_Property__c, Current__c, Address_Line_2__c, City__c, State__c,
                                                    Pincode__c, Ownership_Status__c, Percent_Share__c, Age_Of_Property__c,
                                                    Property_Purpose__c, Residual_Age_Of_Property__c, Current_Owner_Name__c,
                                                    Type_Of_Property__c, Total_Area__c, Land_Ownership__c, Property_Address__c,
                                                    Ownership_Date__c, Address_Type__c, Total_Collateral_Value_PcAc__c,
                                                    //------Address details-----
                                                    Pincode__r.Pincode__c, Pincode__r.State_Code__c,
                                                    Pincode__r.City_Code__c,
                                                    //------Application------
                                                    Application__r.Name
                                                    FROM Property__c WHERE Id =: propertyRecordId];
        if (properties.size() > 0) {
            FS_LMS_CreateColletralAPI.propertyRecord = properties.get(0);
        }
    }
    
    // Created by Ashish Sharma 24/08/2022
    public static String generateRequestJson() {
        String requestJson = '';
        try {
            String ownerName = '';
            if(String.isNotBlank(propertyRecord.Current_Owner_Name__c)) {
                List<Loan_Applicant__c> loanApplicantRecords = new List<Loan_Applicant__c>();
                loanApplicantRecords = [SELECT Id,Applicant_Name__c FROM Loan_Applicant__c WHERE Id =: propertyRecord.Current_Owner_Name__c];
                ownerName = loanApplicantRecords != null ? loanApplicantRecords.size() > 0 ? loanApplicantRecords[0].Applicant_Name__c : '': '';
            }
            Map<String,String> LMSDefaultValuesMap = new Map<String,String>();
            
            for (Drop_Down_Code__mdt LMSValue : [SELECT Id, Name__c, Value__c FROM Drop_Down_Code__mdt WHERE API_Name__c = 'CreateColletral']) {
                LMSDefaultValuesMap.put(LMSValue.Name__c,LMSValue.Value__c);
            }

            String loanAppId = propertyRecord.Application__r != null ? String.isNotBlank(propertyRecord.Application__r.Name) ?
                                propertyRecord.Application__r.Name.replace(' - ', 'T') : '' : '';
            String addressLine1 = String.isNotBlank(propertyRecord.Property_Address__c) ? propertyRecord.Property_Address__c.replace('\r\n', ' ') : '';
            addressLine1 = addressLine1.replace('\n', ' ');
            addressLine1 = addressLine1.replace('\r', ' ');
            String addressLine2 = String.isNotBlank(propertyRecord.Address_Line_2__c) ? propertyRecord.Address_Line_2__c.replace('\r\n', ' ') : '';
            addressLine2 = addressLine2.replace('\n', ' ');
            addressLine2 = addressLine2.replace('\r', ' ');

            requestJson = '{';
            requestJson += '"collParameterVO":' + ' {';
            requestJson += '"collateralSubTypeCode": "';
            //requestJson += String.isNotBlank(propertyRecord.Collateral_Sub_Type_Property_Details__c) ?
              //              LMSDefaultValuesMap.containsKey(propertyRecord.Collateral_Sub_Type_Property_Details__c) ?
                //            LMSDefaultValuesMap.get(propertyRecord.Collateral_Sub_Type_Property_Details__c) : '': '';
            requestJson += LMSDefaultValuesMap.get('collateralSubTypeCode') != null ? LMSDefaultValuesMap.get('collateralSubTypeCode') :'';
            requestJson += '",';
            requestJson += '"collateralTypeCode": "';
            requestJson += LMSDefaultValuesMap.get('collateralTypeCode') == null ? '': LMSDefaultValuesMap.get('collateralTypeCode');
            requestJson += '",';
            requestJson += '"referenceNumber": "'+ loanAppId +'",';
            requestJson += '"sourceSystem": "';
            requestJson += LMSDefaultValuesMap.get('sourceSystem') == null ? '':LMSDefaultValuesMap.get('sourceSystem');
            requestJson += '"},';
            requestJson += '"propertyDetailsVO": {';
            requestJson += '"propertyClassificationCode": "';
            requestJson += String.isNotBlank(propertyRecord.Property_Location_Classification__c) ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Location_Classification__c) != null ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Location_Classification__c) : '': '';
            requestJson += '",';
            requestJson += '"propertyOwnershipCode": "';
            //requestJson += LMSDefaultValuesMap.get('propertyOwnershipCode') == null ? '': LMSDefaultValuesMap.get('propertyOwnershipCode');
            requestJson += '",';
            requestJson += '"propertyTypeCode": "';
            requestJson += String.isNotBlank(propertyRecord.Property_Type__c) ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Type__c) != null ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Type__c) : '': '';
            requestJson += '",';
            requestJson += '"natureOfPropertyCode": "';
                        
            requestJson += String.isNotBlank(propertyRecord.Nature_Of_Property__c) ?
                			LMSDefaultValuesMap.get('Nature Of Property ' + propertyRecord.Nature_Of_Property__c) != NULL ? 
                			LMSDefaultValuesMap.get('Nature Of Property ' + propertyRecord.Nature_Of_Property__c) : 
                            LMSDefaultValuesMap.get(propertyRecord.Nature_Of_Property__c) != null ?
                            LMSDefaultValuesMap.get(propertyRecord.Nature_Of_Property__c) : '' : '';                        
            
            requestJson += '",';
            requestJson += '"propertyCost": {';
            requestJson += '"amount":';
            requestJson += propertyRecord.Total_Collateral_Value_PcAc__c != null ? propertyRecord.Total_Collateral_Value_PcAc__c : 0;
            requestJson += ',';
            requestJson += '"currencyCode": "';
            requestJson += LMSDefaultValuesMap.get('currencyCode') == null ? '': LMSDefaultValuesMap.get('currencyCode');
            requestJson += '"},';
            requestJson += '"address": {';
            requestJson += '"addressLine1": "';
            requestJson += String.isNotBlank(addressLine1) ? addressLine1 : '';
            requestJson += '",';            
            requestJson += '"addressLine2": "';
            requestJson += String.isNotBlank(addressLine2) ? addressLine2 : '';
            requestJson += '",';
            requestJson += '"addressTypeCode": "';
            requestJson += String.isNotBlank(propertyRecord.Address_Type__c) ?
                            LMSDefaultValuesMap.get(propertyRecord.Address_Type__c) != null ?
                            LMSDefaultValuesMap.get(propertyRecord.Address_Type__c) : '' : '';
            requestJson += '",';
            requestJson += '"cityCode": "';
            requestJson += propertyRecord.Pincode__c != null ? String.isNotBlank(propertyRecord.Pincode__r.City_Code__c) ?
                            propertyRecord.Pincode__r.City_Code__c :'' : '';
            requestJson += '",';
            requestJson += '"countryISOCode": "';
            requestJson += LMSDefaultValuesMap.get('countryISOCode') == null ?'':LMSDefaultValuesMap.get('countryISOCode');
            requestJson += '",';
            requestJson += '"stateCode": "';
            requestJson += propertyRecord.Pincode__c != null ? String.isNotBlank(propertyRecord.Pincode__r.State_Code__c) ?
                            propertyRecord.Pincode__r.State_Code__c :'' : '';
            requestJson += '",';
            requestJson += '"zipCode": "';
            requestJson += propertyRecord.Pincode__c != null ? String.isNotBlank(propertyRecord.Pincode__r.Pincode__c) ?
                            propertyRecord.Pincode__r.Pincode__c :'' : '';
            requestJson += '",';
            requestJson += '"numberOfMonthsAtAddress":'+ LMSDefaultValuesMap.get('numberOfMonthsAtAddress') +',';
            requestJson += '"numberOfYearsAtAddress":'+ LMSDefaultValuesMap.get('numberOfYearsAtAddress') +',';
            requestJson += '"monthsInCurrentCity":'+ LMSDefaultValuesMap.get('monthsInCurrentCity') +',';
            requestJson += '"yearsInCurrentCity":'+ LMSDefaultValuesMap.get('yearsInCurrentCity') +'},';
            requestJson += '"propertyOtherDetailsVO": {';
            requestJson += '"age":';
            requestJson += propertyRecord.Age_Of_Property__c != null ? propertyRecord.Age_Of_Property__c : 0;
            requestJson += ',';
            requestJson += '"constructionArea": {';
            requestJson += '"areaValue":';
            requestJson += propertyRecord.Total_Area__c != null ? String.valueOf(propertyRecord.Total_Area__c):'0';
            requestJson += ',';
            requestJson += '"muCode": "'+ LMSDefaultValuesMap.get('muCode');
            requestJson += '"},';
            requestJson += '"propertyClassificationCode": "';
            requestJson += String.isNotBlank(propertyRecord.Property_Location_Classification__c) ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Location_Classification__c) != null ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Location_Classification__c) : '': '';
            requestJson += '",';
            requestJson += '"propertyOwnershipCode": "';
            requestJson += LMSDefaultValuesMap.get('propertyOwnershipCode') == null ?'':LMSDefaultValuesMap.get('propertyOwnershipCode');
            requestJson += '",';
            requestJson += '"propertyPurposeCode": "';
            requestJson += String.isNotBlank(propertyRecord.Property_Purpose__c) ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Purpose__c) != null ?
                            LMSDefaultValuesMap.get(propertyRecord.Property_Purpose__c) : '': '';
            requestJson += '",';
            requestJson += '"residualAgeCode": "';
            requestJson += String.isNotBlank(propertyRecord.Residual_Age_Of_Property__c) ?
                            LMSDefaultValuesMap.get(propertyRecord.Residual_Age_Of_Property__c) != null ?
                            LMSDefaultValuesMap.get(propertyRecord.Residual_Age_Of_Property__c) : '': '';
            requestJson += '",';
            requestJson += '"totalArea": {';
            requestJson += '"areaValue":';
            requestJson += propertyRecord.Total_Area__c != null ? String.valueOf(propertyRecord.Total_Area__c):'0';
            requestJson += ',';
            requestJson += '"muCode": "'+ LMSDefaultValuesMap.get('muCode');
            requestJson += '"}},';
            requestJson += '"propertyOwnershipDetailVO": [{';
            requestJson += '"ownerName": "';
            requestJson += ownerName;
            requestJson += '",';
            requestJson += '"ownerType": "';
            //requestJson += propertyRecord.Land_Ownership__c == null ? '': propertyRecord.Land_Ownership__c;
            requestJson += LMSDefaultValuesMap.get('ownerType') == null ? '': LMSDefaultValuesMap.get('ownerType');
            requestJson += '",';
            
            String ownershipFromDate = propertyRecord.Ownership_Date__c == null ? '': String.valueOf(propertyRecord.Ownership_Date__c);

            requestJson += '"ownershipFrom": "';
            requestJson += String.isNotBlank(ownershipFromDate) ? ownershipFromDate + 'T00:00:00Z':'';
            //requestJson += propertyRecord.Ownership_Date__c == null ? '",': propertyRecord.Ownership_Date__c;
            requestJson += '",';
            String ownershipStatus = String.isNotBlank(propertyRecord.Ownership_Status__c) ?
                                    LMSDefaultValuesMap.get(propertyRecord.Ownership_Status__c) != null ?
                                    LMSDefaultValuesMap.get(propertyRecord.Ownership_Status__c) : '': '';
            requestJson += '"ownershipStatus": "';
            requestJson += ownershipStatus;
            requestJson += '"';
            if (ownershipStatus == 'JOINT') {
                requestJson += ',';
                requestJson += '"percentShare":';
                requestJson += propertyRecord.Percent_Share__c != null ? propertyRecord.Percent_Share__c : 0;
            }
            
            requestJson += '}]},';
            
            requestJson += '"requestReferenceNumber": "'+ loanAppId +'",';
            requestJson += '"productProcessor": "';
            requestJson += LMSDefaultValuesMap.get('productProcessor') == null ? '' : LMSDefaultValuesMap.get('productProcessor');
            requestJson += '"}';
            System.debug('requestJson>>> '+requestJson);
        }
        catch(Exception e) {
            System.debug( e.getMessage()+' Line No. : '+e.getLineNumber() );
            throw new CalloutException( e.getMessage()+' Line No. : '+ e.getLineNumber() );
        }
        return requestJson;
    }
    
    public class SellerResponseList {
	}
    
    public String status;
    public String requestReferenceNumber;
    public String globalCollateralNumber;
    public String referenceNumber;
    public String collateralType;
    public String collateralSubType;
    public String globalCollateralCurrentVersion;
    public Object errorCode;
    public Object errorDesc;
    public List<SellerResponseList> sellerResponseList;
    public String userName;
    public Object userId;
    public Long lastUpdatedTimeStamp;
    
    public static FS_LMS_CreateColletralAPI parse(String json) {
        return (FS_LMS_CreateColletralAPI) System.JSON.deserialize(json, FS_LMS_CreateColletralAPI.class);
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

    @AuraEnabled
    public static List<Property__c> getPropertyRecords(String applicatoinIds){
        try {
            return [SELECT Id, Name FROM Property__c WHERE RecordType.Name = 'Pre Login Property Detail' AND Application__c =: applicatoinIds AND LMS_Collateral_Number__c = ''];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}