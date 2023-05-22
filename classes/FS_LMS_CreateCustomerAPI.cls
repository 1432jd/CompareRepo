/**
* @author            : Ashish Sharma/Navin Soni
* @group             : TechMatrix Consulting
* @description       : This class will invoke LMS create customer api which will create customer to external lms system.
* @created on        : 17-07-2022
* @last modified by  : Ashish Sharma on 24/08/2022
* Changes - SK : 03/08/22 : Parsing the response
**/
public without Sharing class FS_LMS_CreateCustomerAPI {
    // Created by Ashish Sharma 24/08/2022 for store loan Applicant detail
	public static Loan_Applicant__c loanApplicantRecord;
    // FS_LMS_CreateCustomerAPI.createCustomer('a0L0w000002fgBQEAY','','');
    // FS_LMS_CreateCustomerAPI.createCustomer('a0L0w000002fwpnEAA');


   // @future(callout=true)
    public static String createCustomer( String loanApptId,String applicantName,String CustId ) {

        List<Loan_Applicant__c> loanApplicantRecords = new List<Loan_Applicant__c>();
        DataToSendWrapper dataWrapperObj = new DataToSendWrapper();
        String applicationId = '';
        String returnString='';
        List< Sobject > listSobject = new List< Sobject >();
        
        if (String.isNotBlank(loanApptId)) {
            fetchLoanApplicantDetails(loanApptId);
            if(loanApplicantRecord != null) {
                String payload = '';
                payload = generateRequestJson();
                //payload = '{ "productProcessor": "EXTERNAL", "requestReferenceNumber": "339", "globalCustomer": { "associatedLoanAppId": "339", "hostCIFNumber": "", "contactInfo": { "preferredTelephoneType": "Mobile", "addressInfo": [ { "primaryAddress": true, "addressInfoPojo": { "accomodationTypeCode": "", "activeAddress": true, "addressLine1": "6/44 -1 namakkal,namakkal", "addressLine2": "null", "addressLine3": "", "addressLine4": "", "addressTypeCode": "ResidentialAddress", "area": "", "city": "007", "country": "IND", "district": "", "landMark": "", "monthsInCurrentCity": 0, "numberOfMonthsAtAddress": 0, "numberOfYearsAtAddress": 0, "phoneNumbers": [ { "countryCode": "IN", "isdCode": "+91", "stdCode": "", "telephoneExtension": "", "telephoneNumber": "8949595353", "telephoneTypeCode": "Mobile", "verified": true } ], "region": "IR", "residenceTypeCode": "Flat", "state": "MZ", "tehsil": "", "village": "", "yearsInCurrentCity": 0, "zipcode": "796001" } }, { "primaryAddress": false, "addressInfoPojo": { "accomodationTypeCode": "", "activeAddress": true, "addressLine1": "6/127 -1 cs puram,rasipuram", "addressLine2": "null", "addressLine3": "", "addressLine4": "", "addressTypeCode": "PermanentAddress", "area": "", "city": "010", "country": "IND", "district": "", "landMark": "", "monthsInCurrentCity": 0, "numberOfMonthsAtAddress": 0, "numberOfYearsAtAddress": 0, "phoneNumbers": [ { "countryCode": "IN", "isdCode": "+91", "stdCode": "", "telephoneExtension": "", "telephoneNumber": "8949595353", "telephoneTypeCode": "Mobile", "verified": true } ], "region": "IR", "residenceTypeCode": "Flat", "state": "MH", "tehsil": "", "village": "", "yearsInCurrentCity": 0, "zipcode": "444001" } }, { "primaryAddress": false, "addressInfoPojo": { "accomodationTypeCode": "", "activeAddress": true, "addressLine1": "6/120 -1 rs puram,rasipuram ", "addressLine2": "null", "addressLine3": "null", "addressLine4": "", "addressTypeCode": "OfficeAddress", "area": "", "city": "259", "country": "IND", "district": "", "landMark": "NTPC", "monthsInCurrentCity": 0, "numberOfMonthsAtAddress": 0, "numberOfYearsAtAddress": 0, "phoneNumbers": [ ], "region": "IR", "residenceTypeCode": "Flat", "state": "WB", "tehsil": "", "village": "", "yearsInCurrentCity": 0, "zipcode": "711101" } } ], "bankDetails": [ { "branchName": "KATAGERI", "accountTypeCode": "Salary A/c", "accountNumber": "61069126099", "bankName": "KARNATAKA VIKAS GRAMEENA BANK", "associatedLoanAppId": "", "clientId": null, "accountOpeningDate": null, "accountValidatedDate": null, "numberOfMonthsAccHeld": null, "remarks": null }, { "branchName": "UMRANALA", "accountTypeCode": "Saving", "accountNumber": "123456789010", "bankName": "State Bank of India", "associatedLoanAppId": "", "clientId": null, "accountOpeningDate": null, "accountValidatedDate": null, "numberOfMonthsAccHeld": null, "remarks": null } ], "telephoneInfo": [ { "primaryTelephone": true, "phoneNumbers": { "countryCode": "IN", "isdCode": "+91", "stdCode": "", "telephoneExtension": "", "telephoneNumber": "8949595353", "telephoneTypeCode": "Mobile", "verified": true } } ] }, "externalCustomerInfoFileNumber": "", "identificationInfo": [ { "expiryDate": "", "identificationNumber": "AKZPC9527F", "identificationTypeCode": "PAN", "issueDate": "", "issuingCountry": "" } ], "customerType": "individual", "personInfo": { "accountType": "", "aliasName": "", "constitutionCode": "Indiv", "customerCategoryCode": "SC", "customerSegmentCode": "NewCustomer", "dateOfBirth": "1980-08-12", "disability": "", "fatherName": "ABDUL HAMID", "firstName": "Virat", "fourthName": "", "fullName": "UZMA NAAZ SIDDIQUI", "genderCode": "FEMALE", "guardianName": "", "husbandName": "", "lastName": "Kohli", "maidenFirstName": "null", "maidenLastName": "null", "maidenMiddleName": "null", "maidenSalutation": "", "maritalStatusCode": "Married", "middleName": "", "motherName": "BADRUNISA SIDDIQUI", "mothersMaidenName": "", "nationality": "Indian", "placeOfBirth": "Indian", "religion": "", "residentType": "Resident Individual", "householdTypeCode": "Family", "salutationCode": "MR" }, "sourceSystem": "" } } ';
                if (String.isNotBlank(payload)) {
                    try {
                        loanApplicantRecords = [SELECT Id, Application__c FROM Loan_Applicant__c WHERE Id =: loanApptId];
                        if(loanApplicantRecords.size() > 0) {
                            applicationId = loanApplicantRecords[0].Application__c != null ? loanApplicantRecords[0].Application__c : '';
                        }
                        API_Handler__mdt objLMS_CreateCustomerAPI = API_Handler__mdt.getInstance('LMS_CreateCustomer');
                        if(objLMS_CreateCustomerAPI !=null && objLMS_CreateCustomerAPI.isActive__c) {
                            RequestHeader objRequestHeader = parseRequestHeader(objLMS_CreateCustomerAPI.HeaderParameters__c);

                            Http http = new Http();
                            HttpRequest request = new HttpRequest();
                            request.setEndpoint(objLMS_CreateCustomerAPI.Endpoint__c);
                            request.setMethod(objLMS_CreateCustomerAPI.Method__c);
                            request.setHeader('Authorization', objRequestHeader.Authorization);
                            request.setHeader('CORRELATION-ID', objRequestHeader.CORRELATIONID);
                            request.setHeader('CLIENT-ID', objRequestHeader.CLIENTID);
                            request.setHeader('CLIENT-SECRET', objRequestHeader.CLIENTSECRET);
                            request.setHeader('Content-Type', objRequestHeader.ContentType);
                            request.setBody(payload);
                            request.setTimeout(120000);
                            System.debug(payload);
                            System.debug(request);

                            HttpResponse response = new HttpResponse();
                            if(!Test.isRunningTest()){
                                response = http.send(request); 
                            }else{
                                response.setBody(objLMS_CreateCustomerAPI.Mock_Response__c);
                                response.setStatusCode(201);
                            }

                            //request.setBody(payload);
                            System.debug('response : ' + response);
                            System.debug('URL : ' + request.getEndpoint());
                            System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
                            //System.debug(response.getBody());

                            
                            if (response != null && response.getStatusCode() == 201) {
                                FS_LMS_CreateCustomerAPI objWrapResponse = parse(response.getbody());
                                system.debug('@@## objRegResponse '+objWrapResponse);
                                if(objWrapResponse != null) {
                                    if( String.isNotBlank(objWrapResponse.customerInfoFileNumber )){
                                        String requestBody=request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                                        
                                        dataWrapperObj.apiName='FS_LMS_CreateCustomerAPI';
                                        dataWrapperObj.endPointUrl=objLMS_CreateCustomerAPI.Endpoint__c;
                                        dataWrapperObj.requestBody=requestBody;
                                        dataWrapperObj.Status=response.getStatus();
                                        dataWrapperObj.StatusCode=String.valueOf(response.getStatusCode());
                                        dataWrapperObj.userId=loanApptId;
                                        dataWrapperObj.userName=applicantName;
                                        dataWrapperObj.responseBody=response.getbody();
                                        dataWrapperObj.lmsCustomerNumber=objWrapResponse.customerInfoFileNumber;
                                        dataWrapperObj.errorDescription='';
                                        dataWrapperObj.exceptionMessage='';
                                        dataWrapperObj.exceptionLineNo='';
                                        dataWrapperObj.custmerId=CustId;
                                        dataWrapperObj.appId=applicationId;
                                       // listSobject.add( new Loan_Applicant__c( Id = loanApptId, LMS_Customer_Info_File_Number__c = objWrapResponse.customerInfoFileNumber ));
                                    }
                                }
                            }
                            else {
                                Wrapper wrapObj = new Wrapper();
                                Error errorObj = new Error();
                                wrapObj = (Wrapper)System.JSON.deserialize(response.getBody(), Wrapper.class);
                                errorObj= wrapObj.error; 
                                String requestBody=request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                                
                                
                                dataWrapperObj.apiName='FS_LMS_CreateCustomerAPI';
                                dataWrapperObj.endPointUrl=objLMS_CreateCustomerAPI.Endpoint__c;
                                dataWrapperObj.requestBody=requestBody;
                                dataWrapperObj.Status=response.getStatus();
                                dataWrapperObj.StatusCode=String.valueOf(response.getStatusCode());
                                dataWrapperObj.userId=loanApptId;
                                dataWrapperObj.userName=applicantName;
                                dataWrapperObj.responseBody=response.getbody();
                                dataWrapperObj.lmsCustomerNumber='';
                                dataWrapperObj.errorDescription=errorObj.description;
                                dataWrapperObj.exceptionMessage='';
                                dataWrapperObj.exceptionLineNo='';
                                dataWrapperObj.custmerId=CustId;
                                dataWrapperObj.appId=applicationId;

                                system.debug('API exception '+response);
                                system.debug('API exception getStatusCode '+response.getStatusCode());
                                Error_Logger__c objErrorLog = new Error_Logger__c();
                                //objErrorLog.Exception_Message__c = response.getbody();
                                objErrorLog.Description__c = response.getBody().length() > 30068 ? response.getBody().substring(0, 30068) : response.getBody();
                                objErrorLog.Name = 'FS_LMS_CreateCustomerAPI';
                               // listSobject.add( objErrorLog ) ;
                            }
                            API_Logger__c objAPILogger = new API_Logger__c();
                            objAPILogger.Name = 'FS_LMS_CreateCustomerAPI';
                            objAPILogger.API_Name__c = 'FS_LMS_CreateCustomerAPI';
                            objAPILogger.Application__c = applicationId;
                            objAPILogger.Status__c = String.valueOf(response.getStatus());
                            objAPILogger.Request__c = request.getBody().length() > 130068 ? request.getBody().substring(0, 130068) : request.getBody();
                            objAPILogger.Response__c = response.getBody().length() > 130068 ? response.getBody().substring(0, 130068) : response.getBody();
                            objAPILogger.EndPoint__c = request.getEndpoint();
                          //  listSobject.add(objAPILogger);
                        }
                    }
                    catch(System.CalloutException e) {
                        dataWrapperObj.exceptionMessage=e.getMessage();
                        dataWrapperObj.exceptionLineNo=String.valueOf(e.getLineNumber());
                        system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
                        Error_Logger__c objErrorLog = new Error_Logger__c();
                        //objErrorLog.Exception_Message__c = e.getMessage();
                        objErrorLog.Name = 'FS_LMS_CreateCustomerAPI';
                        objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
                        objErrorLog.Description__c = e.getMessage().length() > 30068 ? e.getMessage().substring(0, 30068) : e.getMessage();
                       // listSobject.add(objErrorLog);
                    }
                    catch(Exception e){
                        dataWrapperObj.exceptionMessage=e.getMessage();
                        dataWrapperObj.exceptionLineNo=String.valueOf(e.getLineNumber());


                        system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
                        Error_Logger__c objErrorLog = new Error_Logger__c();
                        //objErrorLog.Exception_Message__c = e.getMessage();
                        objErrorLog.Name = 'FS_LMS_CreateCustomerAPI';
                        objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
                        objErrorLog.Description__c = e.getMessage().length() > 30068 ? e.getMessage().substring(0, 30068) : e.getMessage();
                       // listSobject.add( objErrorLog );
                    }

                    if( !listSobject.isEmpty() ){
                       // upsert  listSobject;
                    }
                }
                else {
                    //throw exception request json not available
                }
            }
        }
        else {
            //throw exception loan Applicant id not available
        }
        return JSON.serialize(dataWrapperObj);
      }

    // Created by Ashish Sharma 24/08/2022
    private static void fetchLoanApplicantDetails( String recordId ) {
        List<Loan_Applicant__c> loanApplicantRecords = new List<Loan_Applicant__c>();
        loanApplicantRecords = [SELECT Id, Resident_Type__c, Marital_Status__c, Guardian_Name__c, KYC_ID_Type_1__c, KYC_ID_Type_2__c,
                                                        Mobile__c, KYC_Id_1__c, KYC_Id_2__c, Mobile_Verified__c,
                                                        Issuing_Country__c, Issue_Date__c, Expiry_Date__c,Customer_Type__c,
                                                        Duration_At_This_Address_From__c, Duration_At_This_City_From__c, Ownership_Type__c ,
                                                        Residence_Landmark__c, Residence_District__c, Residence_Address_Line_2__c, 
                                                        Residence_Country__c, Residence_City__c, Residence_Taluka__c, Residence_Village__c,
                                                        Permanent_Address_Line_1__c, Permanent_State__c,
                                                        Permanent_Landmark__c, Permanent_District__c, Permanent_Address_Line_2__c,
                                                        Permanent_Country__c, Permanent_City__c, Permanent_Taluka__c, Permanent_Village__c,
                                                        Business_Address_Line_1__c, Business_State__c,
                                                        Business_Landmark__c, Business_District__c, Business_Address_Line_2__c,
                                                        Business_Country__c, Business_City__c, Business_Taluka__c, Business_Village__c,
                                						Residence_Address_Line_1__c, Residence_State__c,
                                                        Husband_Wife_s_Name__c, Person_With_Disability__c,
                                						//----------------Pincodes----------------------
                                                        Residence_Pincode__r.Pincode__c, Residence_Pincode__r.State_Code__c,
                                						Residence_Pincode__r.City_Code__c,
                                                        Permanent_Pincode__r.Pincode__c, Permanent_Pincode__r.State_Code__c,
                                						Permanent_Pincode__r.City_Code__c,
                                                        Business_Pincode__r.Pincode__c, Business_Pincode__r.State_Code__c,
                                						Business_Pincode__r.City_Code__c,
   														//----------------Account / Customer Information-----------
                                                        Customer_Information__r.Religion__c, Customer_Information__r.Gender__c,
                                                        Customer_Information__r.Father_s_Name__c, Customer_Information__r.Marital_Status__c,
                                                        Customer_Information__r.Mother_s_Name__c, Customer_Information__r.Category__c,
                                                        Customer_Information__r.Salutation, Customer_Information__r.PersonBirthdate,
                                                        Customer_Information__r.Place_Of_Birth__c, Customer_Information__r.LastName,
                                                        Customer_Information__r.FirstName, Customer_Information__r.Name,
                                                        Customer_Information__r.Person_With_Disability__c,
                                    					//----------------Application---------------------------                    
                                                        Application__r.Name,
                                                        //----------------Sourcing Branch-----------------------
                                                        Application__r.Sourcing_Branch__r.Name,
                                                        //----------------Bank Details--------------------------
                                                        (SELECT Id, Name, Account_Number__c, Account_Type__c, Branch_Name__c 
                                                         FROM Bank_Details__r)
                                           FROM Loan_Applicant__c WHERE Id =: recordId];
        if (loanApplicantRecords.size() > 0) {
            FS_LMS_CreateCustomerAPI.loanApplicantRecord = loanApplicantRecords.get(0);
        }
    }
    


    //Author    : junaid @01 May 2023
    //desc      : get all the loan applicant and return the mobile number of higher income applicant 
    public static String getMobileNoOfhigherIncomeLoanAppt(String loanApptId ){
        String applicationId;
        String mobileNumber;
        String stageName;
        List<Loan_Applicant__c> listOfLoanAppt;         //query to get the application id and then get all the loan applicant
        List<Loan_Applicant__c> listOfAllLoanAppt;      //get all the applicant 
        try{
            listOfLoanAppt = [Select id,Application__c,Application__r.Stage__c,Customer_Type__c  From Loan_Applicant__c WHERE id =: loanApptId];

            if(listOfLoanAppt != null && listOfLoanAppt.size() > 0){
                if(listOfLoanAppt[0].Application__c != null ) {
                    applicationId  = listOfLoanAppt[0].Application__c;
                    stageName = listOfLoanAppt[0].Application__r.Stage__c;
                } 
            }

            if(applicationId != null){
                if(stageName == 'Process Credit'){
                    listOfAllLoanAppt = [Select id,Application__c,Mobile__c,Gross_Income_PC__c, Customer_Type__c  
                                            From Loan_Applicant__c 
                                            WHERE Application__c != null 
                                            AND Application__c =: applicationId
                                            AND Gross_Income_PC__c != null          //Gross_Income_AC__c, Gross_Income_PC__c, Gross_Income_FIVC__c
                                            ORDER by Gross_Income_PC__c Desc
                                            LIMIT 1];

                }
                else if(stageName == 'Approval Credit'){
                    listOfAllLoanAppt = [Select id,Application__c,Mobile__c,Gross_Income_AC__c, Customer_Type__c  
                                            From Loan_Applicant__c 
                                            WHERE Application__c != null 
                                            AND Application__c =: applicationId
                                            AND Gross_Income_AC__c != null          //Gross_Income_AC__c, Gross_Income_PC__c, Gross_Income_FIVC__c
                                            ORDER by Gross_Income_AC__c Desc
                                            LIMIT 1];
                }

                System.debug('listOfAllLoanAppt  >>> '+listOfAllLoanAppt );
                if(listOfAllLoanAppt != null && listOfAllLoanAppt.size() > 0 ){ 
                    mobileNumber = String.valueOf( listOfAllLoanAppt[0].Mobile__c);
                }
            }
            System.debug('listOfLoanAppt  >>> '+listOfLoanAppt);
            System.debug('listOfAllLoanAppt  >>> '+listOfAllLoanAppt);
            System.debug('mobileNumber  >>> '+mobileNumber);
        }catch(Exception e){
            System.debug('Exception msg   -> '+e.getMessage());
            System.debug('Exception msg   -> '+e.getLineNumber());
        }

        return mobileNumber;
    
    }


    // Created by Ashish Sharma 24/08/2022
    private static String generateRequestJson() {
        String mobileNumber;
        String requestJson = '';
        try {

            System.debug('loanApplicantRecord');
            System.debug(loanApplicantRecord);
            if(loanApplicantRecord != null){
                mobileNumber = FS_LMS_CreateCustomerAPI.getMobileNoOfhigherIncomeLoanAppt(loanApplicantRecord.id);
            }



            Map<String,String> LMSDefaultValuesMap = new Map<String,String>();
          	for (Drop_Down_Code__mdt LMSValue : [SELECT Id, Name__c, Value__c FROM Drop_Down_Code__mdt WHERE API_Name__c = 'CreateCustomer']) {
                LMSDefaultValuesMap.put(LMSValue.Name__c,LMSValue.Value__c);
            }
            Integer monthsInCurrentCity = 0;
            Integer yearsInCurrentCity = 0;        
            if (loanApplicantRecord.Duration_At_This_City_From__c != null) {
                monthsInCurrentCity = loanApplicantRecord.Duration_At_This_City_From__c.monthsBetween(Date.today());
                yearsInCurrentCity = monthsInCurrentCity / 12;
            }            
            Integer numberOfMonthsAtAddress = 0;
            Integer numberOfYearsAtAddress = 0;        
            if (loanApplicantRecord.Duration_At_This_City_From__c != null) {
                numberOfMonthsAtAddress = loanApplicantRecord.Duration_At_This_Address_From__c.monthsBetween(Date.today());
                numberOfYearsAtAddress = numberOfMonthsAtAddress / 12;
            }
            
            String loanAppId = loanApplicantRecord.Application__r.Name != null ?loanApplicantRecord.Application__r.Name.replace(' - ', 'T'):'';
            requestJson = '{';
            requestJson += '"productProcessor":"';
            requestJson += LMSDefaultValuesMap.get('productProcessor') !=null ? LMSDefaultValuesMap.get('productProcessor') : '';
            requestJson += '",';
            requestJson += '"requestReferenceNumber":"'+ loanAppId +'",';
			requestJson += '"globalCustomer":' + '{';
            requestJson += '"associatedLoanAppId":"'+ loanAppId +'",';
            requestJson += '"hostCIFNumber":"';
            requestJson += LMSDefaultValuesMap.get('hostCIFNumber') !=null ? LMSDefaultValuesMap.get('hostCIFNumber'):'';
            requestJson += '",';
            
            //--------------------------------------Contact Info-------------------------------------------------------------------------------
            
            requestJson += '"contactInfo":' + '{';
            requestJson += '"preferredTelephoneType":"';
            requestJson += LMSDefaultValuesMap.get('preferredTelephoneType') !=null ? LMSDefaultValuesMap.get('preferredTelephoneType'):'';
            requestJson += '",';
            //requestJson += '"preferredTelephoneType":"'+ loanApplicantRecord.Mobile__c +'"' + ',';
            
            //----------------------------------------------------( Address Info )-----------------------------------------------------------------------

            // ------------------------------------------------( Current/Residential Address details )--------------------------------------------------------

            requestJson += '"addressInfo":' + '[' + '{';
            requestJson += '"primaryAddress":'+ true +',';
            requestJson += '"addressInfoPojo":' + '{';
            requestJson += '"accomodationTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('accomodationTypeCode') !=null ? LMSDefaultValuesMap.get('accomodationTypeCode'):'';
            requestJson += '",';
            requestJson += '"activeAddress":';
            requestJson += LMSDefaultValuesMap.get('activeAddress');
            requestJson += ',';

            //Get Address lines and convert in string from TextArea
            String residence_Address1 = String.isNotBlank(loanApplicantRecord.Residence_Address_Line_1__c) ?
                loanApplicantRecord.Residence_Address_Line_1__c.replaceAll('\r\n', ' '):'';

            String residence_Address2 = String.isNotBlank(loanApplicantRecord.Residence_Address_Line_2__c) ?
                loanApplicantRecord.Residence_Address_Line_2__c.replaceAll('\r\n', ' '):'';

            requestJson += '"addressLine1":"'+ residence_Address1 +'"'+',';
            requestJson += '"addressLine2":"'+ residence_Address2 +'",';
            requestJson += '"addressLine3":"';
            requestJson += LMSDefaultValuesMap.get('addressLine3') !=null ? LMSDefaultValuesMap.get('addressLine3'):'';
            requestJson += '",';
            requestJson += '"addressLine4":"';
            requestJson += LMSDefaultValuesMap.get('addressLine4') !=null ? LMSDefaultValuesMap.get('addressLine4'):'';
            requestJson += '",';
            requestJson += '"addressTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('ResidentialaddressTypeCode') == null ? '':
                            LMSDefaultValuesMap.get('ResidentialaddressTypeCode');
            requestJson += '",';
            requestJson += '"area":"';
            requestJson += LMSDefaultValuesMap.get('area') !=null ? LMSDefaultValuesMap.get('area'):'';
            requestJson += '",';
            
            requestJson += '"city":"';
            //requestJson += '"city":"010"' + ',';
            requestJson += loanApplicantRecord.Residence_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Residence_Pincode__r.City_Code__c) ?
            				loanApplicantRecord.Residence_Pincode__r.City_Code__c : '': '';
            requestJson += '",';
            requestJson += '"country":"';
            requestJson += LMSDefaultValuesMap.get('country');
            requestJson += '",';
            requestJson += '"district":"';
            //requestJson += loanApplicantRecord.Residence_District__c ==null?'':loanApplicantRecord.Residence_District__c;
            requestJson += '",';
            requestJson += '"landMark":"';
            //requestJson += loanApplicantRecord.Residence_Landmark__c ==null?'':loanApplicantRecord.Residence_Landmark__c;
            requestJson += '",';
            requestJson += '"monthsInCurrentCity":'+ monthsInCurrentCity + ',';
            requestJson += '"numberOfMonthsAtAddress":'+ numberOfMonthsAtAddress + ',';
            requestJson += '"numberOfYearsAtAddress":'+ numberOfYearsAtAddress + ',';
            
            requestJson += '"phoneNumbers":' + '[' + '{';
            requestJson += '"countryCode":"';
            requestJson += LMSDefaultValuesMap.get('countryCode') !=null ? LMSDefaultValuesMap.get('countryCode'):'';
            requestJson += '",';
            requestJson += '"isdCode":"';
            requestJson += LMSDefaultValuesMap.get('isdCode') ==null ?'': LMSDefaultValuesMap.get('isdCode');
            requestJson += '",';
            requestJson += '"stdCode":"';
            requestJson += LMSDefaultValuesMap.get('stdCode') !=null ? LMSDefaultValuesMap.get('stdCode'):'';
            requestJson += '",';
            requestJson += '"telephoneExtension":"';
            requestJson += LMSDefaultValuesMap.get('telephoneExtension') !=null ? LMSDefaultValuesMap.get('telephoneExtension'):'';
            requestJson += '",';
            requestJson += '"telephoneNumber":"';

             // junaid   :   added logic if ! primary applicant then choose the mobile number those have hogher income.
             if(loanApplicantRecord.Customer_Type__c != 'Primary Applicant' ){
                requestJson += loanApplicantRecord.Mobile__c !=null ? loanApplicantRecord.Mobile__c :'';
            }else{
                if(String.isNotBlank(mobileNumber)){
                    requestJson += mobileNumber !=null ? mobileNumber : (loanApplicantRecord.Mobile__c != NULL ? loanApplicantRecord.Mobile__c : '');
                }
            }

            requestJson += '",';
            requestJson += '"telephoneTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('telephoneTypeCode') !=null ? LMSDefaultValuesMap.get('telephoneTypeCode'):'';
            requestJson += '",';
            requestJson += '"verified":' + loanApplicantRecord.Mobile_Verified__c + '}],';

            requestJson += '"region":"';
            requestJson += LMSDefaultValuesMap.get('region') != null ? LMSDefaultValuesMap.get('region') : '';
            requestJson += '",';

            requestJson += '"residenceTypeCode":"';
            requestJson += String.isNotBlank(loanApplicantRecord.Ownership_Type__c) ? loanApplicantRecord.Ownership_Type__c : '';
            //requestJson += LMSDefaultValuesMap.get('residenceTypeCode');
            requestJson += '",';
            //requestJson += '"state":"UP"' + ',';
            requestJson += '"state":"';
            //requestJson += loanApplicantRecord.Residence_State__c == null ? '': loanApplicantRecord.Residence_State__c;
            requestJson += loanApplicantRecord.Residence_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Residence_Pincode__r.State_Code__c) ?
                            loanApplicantRecord.Residence_Pincode__r.State_Code__c  : '': '';
            requestJson += '",';
            requestJson += '"tehsil":"';
            //requestJson += loanApplicantRecord.Residence_Taluka__c == null ? '': loanApplicantRecord.Residence_Taluka__c;
            requestJson += '",';
            requestJson += '"village":"';
            //requestJson += loanApplicantRecord.Residence_Village__c == null ? '': loanApplicantRecord.Residence_Village__c;
            requestJson += '",';
            requestJson += '"yearsInCurrentCity":'+ yearsInCurrentCity + ',';
            requestJson += '"zipcode":"';
            requestJson += loanApplicantRecord.Residence_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Residence_Pincode__r.Pincode__c) ?
            				loanApplicantRecord.Residence_Pincode__r.Pincode__c : '' :'';
            requestJson += '"}},{';
            //--------------------------------------------------PermanentAddress------------------------------------------------------
            
            requestJson += '"primaryAddress":'+ false +',';
            requestJson += '"addressInfoPojo":' + '{';
            requestJson += '"accomodationTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('accomodationTypeCode') !=null ? LMSDefaultValuesMap.get('accomodationTypeCode'):'';
            requestJson += '",';
            requestJson += '"activeAddress":';
            requestJson += LMSDefaultValuesMap.get('activeAddress');
            requestJson += ',';
            String permanent_Address1 = String.isNotBlank(loanApplicantRecord.Permanent_Address_Line_1__c) ?
                loanApplicantRecord.Permanent_Address_Line_1__c.replaceAll('\r\n', ' '):'';
            requestJson += '"addressLine1":"'+ permanent_Address1 +'"'+',';
            String permanent_Address2 = String.isNotBlank(loanApplicantRecord.Permanent_Address_Line_2__c) ?
                loanApplicantRecord.Permanent_Address_Line_2__c.replaceAll('\r\n', ' '):'';
            requestJson += '"addressLine2":"'+ permanent_Address2 +'",';
            requestJson += '"addressLine3":"';
            requestJson += LMSDefaultValuesMap.get('addressLine3') !=null ? LMSDefaultValuesMap.get('addressLine3'):'';
            requestJson += '",';
            requestJson += '"addressLine4":"';
            requestJson += LMSDefaultValuesMap.get('addressLine4') !=null ? LMSDefaultValuesMap.get('addressLine4'):'';
            requestJson += '",';
            requestJson += '"addressTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('PermanentaddressTypeCode') != null ? 
                            LMSDefaultValuesMap.get('PermanentaddressTypeCode') :'';
            requestJson += '",';
            requestJson += '"area":"';
            requestJson += LMSDefaultValuesMap.get('area') !=null ? LMSDefaultValuesMap.get('area'):'';
            requestJson += '",';
            
            requestJson += '"city":"';
            requestJson += loanApplicantRecord.Permanent_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Permanent_Pincode__r.City_Code__c) ?
            				loanApplicantRecord.Permanent_Pincode__r.City_Code__c : '' : '';
            requestJson += '",';
            //requestJson += '"city":"010"' + ',';
            requestJson += '"country":"'+ LMSDefaultValuesMap.get('country') +'"' + ',';
            requestJson += '"district":"';
            //requestJson += loanApplicantRecord.Permanent_District__c ==null ? '': loanApplicantRecord.Permanent_District__c;
            requestJson += '",';
            requestJson += '"landMark":"';
            //requestJson += loanApplicantRecord.Permanent_Landmark__c ==null ? '': loanApplicantRecord.Permanent_Landmark__c;
            requestJson += '",';
            requestJson += '"monthsInCurrentCity":'+ monthsInCurrentCity + ',';
            requestJson += '"numberOfMonthsAtAddress":'+ numberOfMonthsAtAddress + ',';
            requestJson += '"numberOfYearsAtAddress":'+ numberOfYearsAtAddress + ',';
            
            requestJson += '"phoneNumbers":' + '[' + '{';
            requestJson += '"countryCode":"';
            requestJson += LMSDefaultValuesMap.get('countryCode') !=null ? LMSDefaultValuesMap.get('countryCode'):'';
            requestJson += '",';
            requestJson += '"isdCode":"';
            requestJson += LMSDefaultValuesMap.get('isdCode') !=null ? LMSDefaultValuesMap.get('isdCode'):'';
            requestJson += '",';
            requestJson += '"stdCode":"';
            requestJson += LMSDefaultValuesMap.get('stdCode') !=null ? LMSDefaultValuesMap.get('stdCode'):'';
            requestJson += '",';
            requestJson += '"telephoneExtension":"';
            requestJson += LMSDefaultValuesMap.get('telephoneExtension') !=null ? LMSDefaultValuesMap.get('telephoneExtension'):'';
            requestJson += '",';
            requestJson += '"telephoneNumber":"';
             // junaid   :   added logic if ! primary applicant then choose the mobile number those have hogher income.
            if(loanApplicantRecord.Customer_Type__c != 'Primary Applicant' ){
                requestJson += loanApplicantRecord.Mobile__c !=null ? loanApplicantRecord.Mobile__c :'';
            }else{
                if(String.isNotBlank(mobileNumber)){
                    requestJson += mobileNumber !=null ? mobileNumber : (loanApplicantRecord.Mobile__c != NULL ? loanApplicantRecord.Mobile__c : '');
                }
            } 
            requestJson += '",';
            requestJson += '"telephoneTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('telephoneTypeCode') !=null ? LMSDefaultValuesMap.get('telephoneTypeCode'):'';
            requestJson += '",';
            requestJson += '"verified":' + loanApplicantRecord.Mobile_Verified__c + '}' + ']' + ',';

            requestJson += '"region":"';
            requestJson += LMSDefaultValuesMap.get('region') != null ? LMSDefaultValuesMap.get('region') : '';
            requestJson += '",';
            requestJson += '"residenceTypeCode":"';
            requestJson += String.isNotBlank(loanApplicantRecord.Ownership_Type__c) ? loanApplicantRecord.Ownership_Type__c : '';
            //requestJson += LMSDefaultValuesMap.get('residenceTypeCode');
            requestJson += '",';
            //requestJson += '"state":"UP"' + ',';
            requestJson += '"state":"';
            //requestJson += loanApplicantRecord.Permanent_State__c == null ? '': loanApplicantRecord.Permanent_State__c;
            requestJson += loanApplicantRecord.Permanent_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Permanent_Pincode__r.State_Code__c) ?
                            loanApplicantRecord.Permanent_Pincode__r.State_Code__c : '' : '';
            requestJson += '",';
            requestJson += '"tehsil":"';
            //requestJson += loanApplicantRecord.Permanent_Taluka__c == null ? '': loanApplicantRecord.Permanent_Taluka__c;
            requestJson += '",';
            requestJson += '"village":"';
            //requestJson += loanApplicantRecord.Permanent_Village__c == null ? '': loanApplicantRecord.Permanent_Village__c;
            requestJson += '",';
            requestJson += '"yearsInCurrentCity":'+ yearsInCurrentCity + ',';
            requestJson += '"zipcode":"';
            requestJson += loanApplicantRecord.Permanent_Pincode__r != null ?
                            String.isNotBlank(loanApplicantRecord.Permanent_Pincode__r.Pincode__c) ?
            				loanApplicantRecord.Permanent_Pincode__r.Pincode__c : '': '';
            requestJson += '"}},{';
            //--------------------------------------------------OfficeAddress------------------------------------------------------

            requestJson += '"primaryAddress":'+ false +',';
            requestJson += '"addressInfoPojo":' + '{';
            requestJson += '"accomodationTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('accomodationTypeCode') !=null ? LMSDefaultValuesMap.get('accomodationTypeCode'):'';
            requestJson += '",';
            requestJson += '"activeAddress":';
            requestJson += LMSDefaultValuesMap.get('activeAddress');
            requestJson += ',';
            String office_Address1 = String.isNotBlank(loanApplicantRecord.Business_Address_Line_1__c) ?
                loanApplicantRecord.Business_Address_Line_1__c.replaceAll('\r\n', ' '):'';
            requestJson += '"addressLine1":"'+ office_Address1 +'"'+',';
            String office_Address2 = String.isNotBlank(loanApplicantRecord.Business_Address_Line_2__c) ?
                loanApplicantRecord.Business_Address_Line_2__c.replaceAll('\r\n', ' '):'';
            requestJson += '"addressLine2":"'+ office_Address2 +'",';
            requestJson += '"addressLine3":"';
            requestJson += LMSDefaultValuesMap.get('addressLine3') !=null ? LMSDefaultValuesMap.get('addressLine3'):'';
            requestJson += '",';
            requestJson += '"addressLine4":"';
            requestJson += LMSDefaultValuesMap.get('addressLine4') !=null ? LMSDefaultValuesMap.get('addressLine4'):'';
            requestJson += '",';
            requestJson += '"addressTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('OfficeaddressTypeCode') != null ? 
                            LMSDefaultValuesMap.get('OfficeaddressTypeCode') :'';
            requestJson += '",';
            requestJson += '"area":"';
            requestJson += LMSDefaultValuesMap.get('area') !=null ? LMSDefaultValuesMap.get('area'):'';
            requestJson += '",';
            
            requestJson += '"city":"';
            requestJson += loanApplicantRecord.Business_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Business_Pincode__r.City_Code__c) ?
            				loanApplicantRecord.Business_Pincode__r.City_Code__c : '' : '';
            requestJson += '",';
            //requestJson += '"city":"010"' + ',';
            requestJson += '"country":"'+ LMSDefaultValuesMap.get('country') +'"' + ',';
            requestJson += '"district":"';
            //requestJson += loanApplicantRecord.Business_District__c ==null ? '': loanApplicantRecord.Business_District__c;
            requestJson += '",';
            requestJson += '"landMark":"';
            //requestJson += loanApplicantRecord.Business_Landmark__c ==null ? '': loanApplicantRecord.Business_Landmark__c;
            requestJson += '",';
            requestJson += '"monthsInCurrentCity":'+ monthsInCurrentCity + ',';
            requestJson += '"numberOfMonthsAtAddress":'+ numberOfMonthsAtAddress + ',';
            requestJson += '"numberOfYearsAtAddress":'+ numberOfYearsAtAddress + ',';
            
            requestJson += '"phoneNumbers":' + '[' + '{';
            requestJson += '"countryCode":"';
            requestJson += LMSDefaultValuesMap.get('countryCode') !=null ? LMSDefaultValuesMap.get('countryCode'):'';
            requestJson += '",';
            requestJson += '"isdCode":"';
            requestJson += LMSDefaultValuesMap.get('isdCode') !=null ? LMSDefaultValuesMap.get('isdCode'):'';
            requestJson += '",';
            requestJson += '"stdCode":"';
            requestJson += LMSDefaultValuesMap.get('stdCode') !=null ? LMSDefaultValuesMap.get('stdCode'):'';
            requestJson += '",';
            requestJson += '"telephoneExtension":"';
            requestJson += LMSDefaultValuesMap.get('telephoneExtension') !=null ? LMSDefaultValuesMap.get('telephoneExtension'):'';
            requestJson += '",';
            requestJson += '"telephoneNumber":"';
            // junaid   :   added logic if ! primary applicant then choose the mobile number those have hogher income.
            if(loanApplicantRecord.Customer_Type__c != 'Primary Applicant' ){
                requestJson += loanApplicantRecord.Mobile__c !=null ? loanApplicantRecord.Mobile__c :'';
            }else{
                if(String.isNotBlank(mobileNumber)){
                    requestJson += mobileNumber !=null ? mobileNumber : (loanApplicantRecord.Mobile__c != NULL ? loanApplicantRecord.Mobile__c : '');
                }
            }           
            requestJson += '",';
            requestJson += '"telephoneTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('telephoneTypeCode') !=null ? LMSDefaultValuesMap.get('telephoneTypeCode'):'';
            requestJson += '",';
            requestJson += '"verified":' + loanApplicantRecord.Mobile_Verified__c + '}],';

            requestJson += '"region":"';
            requestJson += LMSDefaultValuesMap.get('region') != null ? LMSDefaultValuesMap.get('region') : '';
            requestJson += '",';
            requestJson += '"residenceTypeCode":"';
            requestJson += String.isNotBlank(loanApplicantRecord.Ownership_Type__c) ? loanApplicantRecord.Ownership_Type__c : '';
            //requestJson += LMSDefaultValuesMap.get('residenceTypeCode');
            requestJson += '",';
            //requestJson += '"state":"UP"' + ',';
            requestJson += '"state":"';
            requestJson += loanApplicantRecord.Business_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Business_Pincode__r.State_Code__c) ?
            				loanApplicantRecord.Business_Pincode__r.State_Code__c : '' : '';
            //requestJson += loanApplicantRecord.Business_State__c == null ? '': loanApplicantRecord.Business_State__c;
            requestJson += '",';
            requestJson += '"tehsil":"';
            //requestJson += loanApplicantRecord.Business_Taluka__c == null ? '': loanApplicantRecord.Business_Taluka__c;
            requestJson += '",';
            requestJson += '"village":"';
            //requestJson += loanApplicantRecord.Business_Village__c == null ? '': loanApplicantRecord.Business_Village__c;
            requestJson += '",';

            requestJson += '"yearsInCurrentCity":'+ yearsInCurrentCity + ',';
            requestJson += '"zipcode":"';
            requestJson += loanApplicantRecord.Business_Pincode__r != null ? 
                            String.isNotBlank(loanApplicantRecord.Business_Pincode__r.Pincode__c) ?
            				loanApplicantRecord.Business_Pincode__r.Pincode__c : '' : '';
            requestJson += '"}}],';
            

    
//---------------------------------------------------------------( Bank Info )---------------------------------------------------------------            
			requestJson += '"bankDetails":' + '[';
            
            if ( loanApplicantRecord.Bank_Details__r != null && loanApplicantRecord.Bank_Details__r.size() > 0 ) {
                for ( Bank_Detail__c bankDetail : loanApplicantRecord.Bank_Details__r ) {
                    
                    requestJson += '{';
                    requestJson += '"branchName":"';
                    requestJson += loanApplicantRecord.Application__r !=null ?
                                    loanApplicantRecord.Application__r.Sourcing_Branch__r !=null ?
                                    String.isNotBlank(loanApplicantRecord.Application__r.Sourcing_Branch__r.Name) ?
                                    loanApplicantRecord.Application__r.Sourcing_Branch__r.Name : '': '': '';
                    requestJson += '",';
                    //requestJson += LMSDefaultValuesMap.get('accountTypeCode') !=null ? LMSDefaultValuesMap.get('accountTypeCode'):'';
                    //requestJson += 'Saving';
                    String accountTypeCodeValue = String.isNotBlank(bankDetail.Account_Type__c) ?
                                                    LMSDefaultValuesMap.containsKey(bankDetail.Account_Type__c) ?
                                                    String.isNotBlank(LMSDefaultValuesMap.get(bankDetail.Account_Type__c)) ?
                                                    LMSDefaultValuesMap.get(bankDetail.Account_Type__c) : '': '': '';
                    requestJson += '"accountTypeCode":"'+ accountTypeCodeValue +'",';
                    requestJson += '"accountNumber":"';
                    requestJson += String.isNotBlank(bankDetail.Account_Number__c) ? bankDetail.Account_Number__c : '';
                    requestJson += '",';
                    requestJson += '"bankName":"';
                    requestJson += String.isNotBlank(bankDetail.Name) ? bankDetail.Name : '';
                    requestJson += '",';
                    requestJson += '"associatedLoanAppId":"'+ loanAppId +'"' + ',';
                    requestJson += '"clientId":' + LMSDefaultValuesMap.get('clientId') + ',';
                    requestJson += '"accountOpeningDate":' + LMSDefaultValuesMap.get('accountOpeningDate')  + ',';
                    requestJson += '"accountValidatedDate":'+ LMSDefaultValuesMap.get('accountValidatedDate') +',';
                    requestJson += '"numberOfMonthsAccHeld":'+ LMSDefaultValuesMap.get('numberOfMonthsAccHeld') +',';
                    requestJson += '"remarks":'+ LMSDefaultValuesMap.get('remarks') +'},';
                }
            }
            requestJson = requestJson.removeEnd(',');
			requestJson += +']' + ',';
            
//---------------------------------------------------------------( Telephone Info )---------------------------------------------------------------
            
            requestJson += '"telephoneInfo":' + '[';

            if( !String.isBlank(loanApplicantRecord.Mobile__c) ) {
                requestJson += '{';
                requestJson += '"primaryTelephone":'+ loanApplicantRecord.Mobile_Verified__c +',';
                requestJson += '"phoneNumbers":' + '{';
                requestJson += '"countryCode":"';
                requestJson += LMSDefaultValuesMap.get('countryCode') !=null ? LMSDefaultValuesMap.get('countryCode'):'';
                requestJson += '",';
                requestJson += '"isdCode":"';
                requestJson += LMSDefaultValuesMap.get('isdCode') !=null ? LMSDefaultValuesMap.get('isdCode'):'';
                requestJson += '",';
                requestJson += '"stdCode":"';
                requestJson += LMSDefaultValuesMap.get('stdCode') !=null ? LMSDefaultValuesMap.get('stdCode'):'';
                requestJson += '",';
                requestJson += '"telephoneExtension":"';
                requestJson += LMSDefaultValuesMap.get('telephoneExtension') !=null ? LMSDefaultValuesMap.get('telephoneExtension'):'';
                requestJson += '",';
                requestJson += '"telephoneNumber":"';

                // junaid   :   added logic if ! primary applicant then choose the mobile number those have hogher income.
                if(loanApplicantRecord.Customer_Type__c != 'Primary Applicant' ){
                    requestJson += loanApplicantRecord.Mobile__c !=null ? loanApplicantRecord.Mobile__c :'';
                }else{
                    if(String.isNotBlank(mobileNumber)){
                        requestJson += mobileNumber !=null ? mobileNumber : (loanApplicantRecord.Mobile__c != NULL ? loanApplicantRecord.Mobile__c : '');
                    }
                }
                
                requestJson += '",';
                requestJson += '"telephoneTypeCode":"';
                requestJson += LMSDefaultValuesMap.get('telephoneTypeCode') !=null ? LMSDefaultValuesMap.get('telephoneTypeCode'):'';
                requestJson += '",';
                requestJson += '"verified":'+ loanApplicantRecord.Mobile_Verified__c + '}';
                requestJson += '}';
            }
            
            //requestJson = requestJson.removeEnd(',');
            requestJson += ']},';
            
//-----------------------------------------------------------( Identification Info )---------------------------------------------------------------
            
            requestJson += '"externalCustomerInfoFileNumber":"';
            requestJson += LMSDefaultValuesMap.get('externalCustomerInfoFileNumber') !=null ? 
                LMSDefaultValuesMap.get('externalCustomerInfoFileNumber'):'';
            requestJson += '",';
            String kycIdTypeValue = String.isNotBlank(loanApplicantRecord.KYC_ID_Type_1__c) ?
                                    LMSDefaultValuesMap.containsKey(loanApplicantRecord.KYC_ID_Type_1__c) ?
                                    String.isNotBlank(LMSDefaultValuesMap.get(loanApplicantRecord.KYC_ID_Type_1__c)) ?
                                    LMSDefaultValuesMap.get(loanApplicantRecord.KYC_ID_Type_1__c) : '': '': '';
            requestJson += '"identificationInfo":'+'[{';

            String passportExpiryDate = loanApplicantRecord.Expiry_Date__c != null ?
                                                loanApplicantRecord.Expiry_Date__c.Year() + '-' +
                                                loanApplicantRecord.Expiry_Date__c.Month() + '-' +
                                                loanApplicantRecord.Expiry_Date__c.Day() : '';

            String passportIssueDate = loanApplicantRecord.Issue_Date__c != null ?
                                                loanApplicantRecord.Issue_Date__c.Year() + '-' +
                                                loanApplicantRecord.Issue_Date__c.Month() + '-' +
                                                loanApplicantRecord.Issue_Date__c.Day() : '';

            if(kycIdTypeValue == 'PASSPORT_No') {
                requestJson += '"expiryDate":"';
                requestJson += String.isNotBlank(passportExpiryDate) ? passportExpiryDate : '';
                requestJson += '",';
                requestJson += '"issueDate":"';
                requestJson += String.isNotBlank(passportIssueDate) ? passportIssueDate : '';
                requestJson += '",';
            } else {
                requestJson += '"expiryDate":"';
                requestJson += LMSDefaultValuesMap.get('expiryDate') !=null ? LMSDefaultValuesMap.get('expiryDate'):'';
                requestJson += '",';
                requestJson += '"issueDate":"';
                requestJson += LMSDefaultValuesMap.get('issueDate') !=null ? LMSDefaultValuesMap.get('issueDate'):'';
                requestJson += '",';
            }

            requestJson += '"identificationNumber":"';
            requestJson += String.isNotBlank(loanApplicantRecord.KYC_Id_1__c) ? loanApplicantRecord.KYC_Id_1__c : '';
            requestJson += '",';
            requestJson += '"identificationTypeCode":"'+ kycIdTypeValue +'",';
            requestJson += '"issuingCountry":"';
            requestJson += String.isNotBlank(loanApplicantRecord.Issuing_Country__c) ? loanApplicantRecord.Issuing_Country__c : '';
            requestJson += '"}';

            if(String.isNotBlank(loanApplicantRecord.KYC_Id_2__c) && String.isNotBlank(loanApplicantRecord.KYC_ID_Type_2__c)) {
                String kycIdTypeValue2 = String.isNotBlank(loanApplicantRecord.KYC_ID_Type_2__c) ?
                                        LMSDefaultValuesMap.containsKey(loanApplicantRecord.KYC_ID_Type_2__c) ?
                                        String.isNotBlank(LMSDefaultValuesMap.get(loanApplicantRecord.KYC_ID_Type_2__c)) ?
                                        LMSDefaultValuesMap.get(loanApplicantRecord.KYC_ID_Type_2__c) : '': '': '';
                requestJson += ',';
                requestJson += '{';

                if(kycIdTypeValue2 == 'PASSPORT_No') {
                    requestJson += '"expiryDate":"';
                    requestJson += String.isNotBlank(passportExpiryDate) ? passportExpiryDate : '';
                    requestJson += '",';
                    requestJson += '"issueDate":"';
                    requestJson += String.isNotBlank(passportIssueDate) ? passportIssueDate : '';
                    requestJson += '",';
                } else {
                    requestJson += '"expiryDate":"';
                    requestJson += LMSDefaultValuesMap.get('expiryDate') !=null ? LMSDefaultValuesMap.get('expiryDate'):'';
                    requestJson += '",';
                    requestJson += '"issueDate":"';
                    requestJson += LMSDefaultValuesMap.get('issueDate') !=null ? LMSDefaultValuesMap.get('issueDate'):'';
                    requestJson += '",';
                }

                requestJson += '"identificationNumber":"';
                requestJson += String.isNotBlank(loanApplicantRecord.KYC_Id_2__c) ? loanApplicantRecord.KYC_Id_2__c : '';
                requestJson += '",';
                requestJson += '"identificationTypeCode":"'+ kycIdTypeValue2 +'",';
                requestJson += '"issuingCountry":"';
                requestJson += String.isNotBlank(loanApplicantRecord.Issuing_Country__c) ? loanApplicantRecord.Issuing_Country__c : '';
                requestJson += '"}';
            }
            requestJson += '],';
            
//-------------------------------------------------------------( Person Info )------------------------------------------------------------------------

            requestJson += '"customerType":"';
            requestJson += LMSDefaultValuesMap.get('customerType') != null ? LMSDefaultValuesMap.get('customerType') :'';
            requestJson += '",';
            requestJson += '"personInfo":'+'{';
            requestJson += '"accountType":"';
            requestJson += LMSDefaultValuesMap.get('accountType') != null ? LMSDefaultValuesMap.get('accountType') :'';
            requestJson += '",';
            requestJson += '"aliasName":"';
            requestJson += LMSDefaultValuesMap.get('aliasName') !=null ? LMSDefaultValuesMap.get('aliasName'):'';
            requestJson += '",';
            requestJson += '"constitutionCode":"';
            requestJson += LMSDefaultValuesMap.get('constitutionCode') !=null ? LMSDefaultValuesMap.get('constitutionCode'):'';
            requestJson += '",';

            //System.debug('cate '+loanApplicantRecord.Customer_Information__r.Category__c);
            String customerCategoryCode = loanApplicantRecord.Customer_Information__r != null ? 
                                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Category__c) ?
                							loanApplicantRecord.Customer_Information__r.Category__c : '': '';
            customerCategoryCode = String.isNotBlank(customerCategoryCode) ?
                                    LMSDefaultValuesMap.containsKey(customerCategoryCode) ?
                                    LMSDefaultValuesMap.get(customerCategoryCode) :'' :'';
            requestJson += '"customerCategoryCode":"';
            requestJson += String.isNotBlank(customerCategoryCode) ? customerCategoryCode : '';
            requestJson += '",';
            //requestJson += '"customerCategoryCode":"'+ LMSDefaultValuesMap.get('customerCategoryCode') +'",';

            requestJson += '"customerSegmentCode":"';
            requestJson += LMSDefaultValuesMap.get('customerSegmentCode') !=null ? LMSDefaultValuesMap.get('customerSegmentCode'):'';
            requestJson += '",';
            //requestJson += '"dateOfBirth":"1980-08-12"' +',';
            requestJson += '"dateOfBirth":"';
            requestJson += loanApplicantRecord.Customer_Information__r != null ?
                            loanApplicantRecord.Customer_Information__r.PersonBirthdate != null ?
                            String.valueOf(loanApplicantRecord.Customer_Information__r.PersonBirthdate) : '': '';
            requestJson += '",';

            requestJson += '"disability":"';
            requestJson += String.isNotBlank(loanApplicantRecord.Person_With_Disability__c) ? 
                            loanApplicantRecord.Person_With_Disability__c.toUpperCase() : '';
            requestJson += '",';
            requestJson += '"fatherName":"';
            requestJson += loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Father_s_Name__c) ?
            				loanApplicantRecord.Customer_Information__r.Father_s_Name__c : '': '';
            requestJson += '",';
            requestJson += '"firstName":"';
            requestJson += loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.FirstName) ?
            				loanApplicantRecord.Customer_Information__r.FirstName : '': '';
            requestJson += '",';
            requestJson += '"fourthName":"';
            requestJson += LMSDefaultValuesMap.get('fourthName') !=null ? LMSDefaultValuesMap.get('fourthName'):'';
            requestJson += '",';
            requestJson += '"fullName":"';
            requestJson += loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Name) ?
                            loanApplicantRecord.Customer_Information__r.Name : '': '';
            requestJson += '",';
            requestJson += '"genderCode":"';
            requestJson += loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Gender__c) ?
                            loanApplicantRecord.Customer_Information__r.Gender__c.toUpperCase() : '': '';
            requestJson += '",';

            //requestJson += '"guardianName":"'+ loanApplicantRecord.Customer_Information__r.Guardian_Name__c +'",';
            requestJson += '"guardianName":"';
            requestJson += loanApplicantRecord.Guardian_Name__c !=null ? loanApplicantRecord.Guardian_Name__c:'';
            requestJson += '",';
            requestJson += '"husbandName":"';
            requestJson += String.isNotBlank(loanApplicantRecord.Husband_Wife_s_Name__c) ? loanApplicantRecord.Husband_Wife_S_Name__c : '';
            requestJson += '",';
            requestJson += '"lastName":"';
            requestJson += loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.LastName) ?
            				loanApplicantRecord.Customer_Information__r.LastName : '': '';
            requestJson += '",';
            requestJson += '"maidenFirstName":"';
            requestJson += LMSDefaultValuesMap.get('maidenFirstName') !=null ? LMSDefaultValuesMap.get('maidenFirstName'):'';
            requestJson += '",';
            requestJson += '"maidenLastName":"';
            requestJson += LMSDefaultValuesMap.get('maidenLastName') !=null ? LMSDefaultValuesMap.get('maidenLastName'):'';
            requestJson += '",';
            requestJson += '"maidenMiddleName":"';
            requestJson += LMSDefaultValuesMap.get('maidenMiddleName') !=null ? LMSDefaultValuesMap.get('maidenMiddleName'):'';
            requestJson += '",';
            requestJson += '"maidenSalutation":"';
            requestJson += LMSDefaultValuesMap.get('maidenSalutation') !=null ? LMSDefaultValuesMap.get('maidenSalutation'):'';
            requestJson += '",';
			requestJson += '"maritalStatusCode":"';
            if(String.isNotBlank(loanApplicantRecord.Marital_Status__c)) {
                    requestJson += LMSDefaultValuesMap.get(loanApplicantRecord.Marital_Status__c) != null ?
                                    LMSDefaultValuesMap.get(loanApplicantRecord.Marital_Status__c) : '';
            }
            requestJson += '",';
            requestJson += '"middleName":"';
            requestJson += LMSDefaultValuesMap.get('middleName') != null ? LMSDefaultValuesMap.get('middleName'):'';
            requestJson += '",';
            requestJson += '"motherName":"';
            requestJson +=  loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Mother_s_Name__c) ?
                            loanApplicantRecord.Customer_Information__r.Mother_s_Name__c : '': '';
            requestJson += '",';
            requestJson += '"mothersMaidenName":"';
            requestJson += LMSDefaultValuesMap.get('mothersMaidenName') != null ? LMSDefaultValuesMap.get('mothersMaidenName'):'';
            requestJson += '",';
            requestJson += '"nationality":"';
            requestJson += LMSDefaultValuesMap.get('nationality') !=null ? LMSDefaultValuesMap.get('nationality'):'';
            requestJson += '",';
            requestJson += '"placeOfBirth":"';
            requestJson +=  loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Place_Of_Birth__c) ?
                            loanApplicantRecord.Customer_Information__r.Place_Of_Birth__c : '': '';
            requestJson += '",';
            requestJson += '"religion":"';
            requestJson += loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Religion__c) ?
            loanApplicantRecord.Customer_Information__r.Religion__c : '': '';
            requestJson += '",';
            requestJson += '"residentType":"';
            requestJson += loanApplicantRecord.Resident_Type__c ==null ? '': loanApplicantRecord.Resident_Type__c;
            requestJson += '",';
            
            requestJson += '"householdTypeCode":"';
            requestJson += LMSDefaultValuesMap.get('householdTypeCode') !=null ? LMSDefaultValuesMap.get('householdTypeCode'):'';
            requestJson += '",';
            requestJson += '"salutationCode":"';
            requestJson +=  loanApplicantRecord.Customer_Information__r != null ?
                            String.isNotBlank(loanApplicantRecord.Customer_Information__r.Salutation) ?
                			loanApplicantRecord.Customer_Information__r.Salutation.remove('.').toUpperCase() : '': '';
            requestJson += '"},';
            
            requestJson += '"sourceSystem":"';
            requestJson += LMSDefaultValuesMap.get('sourceSystem') !=null ? LMSDefaultValuesMap.get('sourceSystem'):'';
            requestJson += '"';
            requestJson += '}'+'}';
	        System.debug('requestJson>>> '+requestJson);
        }
        catch(Exception e) {
            System.debug( e.getMessage()+' Line No. : '+e.getLineNumber() );
            throw new CalloutException( e.getMessage()+' Line No. : '+ e.getLineNumber() );
        }
        return requestJson;
    }
    
    public static FS_LMS_CreateCustomerAPI parse(String json) {
        return (FS_LMS_CreateCustomerAPI) System.JSON.deserialize(json, FS_LMS_CreateCustomerAPI.class);
    }


    @AuraEnabled
    public static void mailResponse(List<String> responseData){
        try {

            List<Sobject> lmsListSobject = new List<Sobject>();
            List<Sobject> apiLoggerSobject = new List<Sobject>();
            List<Sobject> accSobject = new List<Sobject>();
            List<Sobject> errorLoggerSobject = new List<Sobject>();
            List<DataToSendWrapper> dataObjList = new List<DataToSendWrapper>();
            List<Messaging.SingleEmailMessage> masterListMails =  new List<Messaging.SingleEmailMessage>();

            for(String jsonObj : responseData){
                DataToSendWrapper dataWrapperObj = new DataToSendWrapper();
                dataWrapperObj = (DataToSendWrapper) System.JSON.deserialize(jsonObj, DataToSendWrapper.class);
                dataObjList.add(dataWrapperObj);
            }

            System.debug('dataObjList is >>>'+dataObjList.size());

            if(dataObjList.size()>0){
                for(DataToSendWrapper obj : dataObjList){
                    if(obj.lmsCustomerNumber!=null && String.isNotBlank(obj.lmsCustomerNumber) && obj.lmsCustomerNumber!=''){  
                        Loan_Applicant__c loanObj = new Loan_Applicant__c();
                        loanObj.Id=obj.userId;
                        loanObj.LMS_Customer_Info_File_Number__c = obj.lmsCustomerNumber;
                        //loanObj.Customer_Information__r.Neo_CIF_Id_Staging__c=obj.lmsCustomerNumber;
                        lmsListSobject.add(loanObj);

                        Account accObj = new Account();
                        accObj.Id=obj.custmerId;
                        accObj.Neo_CIF_Id_Staging__c=obj.lmsCustomerNumber;
                        accSobject.add(accObj);
                    }

                    API_Logger__c objAPILogger = new API_Logger__c();
                    objAPILogger.Application__c=obj.appId;
                    objAPILogger.Name = 'FS_LMS_CreateCustomerAPI';
                    objAPILogger.API_Name__c = 'FS_LMS_CreateCustomerAPI';
                    objAPILogger.Status__c = obj.Status +' '+obj.StatusCode;
                    objAPILogger.Request__c =obj.requestBody.length() > 130068 ? obj.requestBody.substring(0, 130068) : obj.requestBody;
                    objAPILogger.Response__c =obj.responseBody.length() > 130068 ? obj.responseBody.substring(0, 130068) : obj.responseBody;
                    objAPILogger.EndPoint__c = obj.endPointUrl;
                    apiLoggerSobject.add(objAPILogger);
                System.debug('in loop sobject in else if>>'+apiLoggerSobject.size());

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {'ashish2.s@techmatrixconsulting.com'});
                    mail.setSubject('UAT CreateCustomerAPI');
                    mail.setPlainTextBody('Response Body '+obj.responseBody);
                    //masterListMails.add(mail);

                    if(obj.exceptionMessage!=null && String.isNotBlank(obj.exceptionMessage) && obj.exceptionMessage!=''){
                        Error_Logger__c objErrorLog = new Error_Logger__c();
                        objErrorLog.Exception_Message__c = obj.exceptionMessage;
                        objErrorLog.Name = 'FS_LMS_CreateCustomerAPI';
                        objErrorLog.Line_Number__c=obj.exceptionLineNo;
                        objErrorLog.Description__c = obj.errorDescription.length() > 30068 ? obj.errorDescription.substring(0, 30068) : obj.errorDescription;
                        errorLoggerSobject.add( objErrorLog );
                    }
                }
            }

            if(lmsListSobject.size()>0 && apiLoggerSobject.size()>0 && accSobject.size()>0){
             System.debug('size of loan app>>'+apiLoggerSobject.size());

                lmsListSobject.addAll(apiLoggerSobject);
                lmsListSobject.addAll(accSobject);
                
                if(errorLoggerSobject.size()>0){
                    lmsListSobject.addAll(errorLoggerSobject);
                }
                System.debug('size of lmsListSobject app>>'+lmsListSobject.size());

                System.debug('sobject in  if>>'+lmsListSobject);

                upsert lmsListSobject;
            }else if(apiLoggerSobject.size()>0 && lmsListSobject.size()==0){
                System.debug('before sobject in else if>>'+apiLoggerSobject.size());
                if(errorLoggerSobject.size()>0){
                    apiLoggerSobject.addAll(errorLoggerSobject);
                }
                System.debug('sobject in else if>>'+apiLoggerSobject.size());
                insert apiLoggerSobject;
            }

            if(masterListMails.size()>0){
                //Messaging.sendEmail(masterListMails);
            }
                     
        } catch (Exception e) {
            System.debug('exeption is >>>'+e.getMessage());
        }
    }

    //--------------------------------------------------------------------------
    public String status;
    public String messageCode;
    public String messageDescription;
    public String requestReferenceNumber;
    public String customerInfoFileNumber;
    public String hostCustomerInfoFileNumber;
    public String associatedLoanAppId;
    public GlobalCustomerIdMapping globalCustomerIdMapping;

    public class GlobalCustomerIdMapping {
        public List<CONTACT_DETAILS> CONTACT_DETAILS;
        public List<CONTACT_DETAILS> ADDRESS;
        public List<CONTACT_DETAILS> PHONE_NUMBER;
    }

    public class CONTACT_DETAILS {
        public Object clientId;
        public String gcdId;
        public Boolean mappingChanged;
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

   public class Wrapper{
        public Error error;
   }

   public class Error{
       public String description;
   }

   public class DataToSendWrapper{
        String requestBody;
        String responseBody;
        String endPointUrl;
        String StatusCode;
        String Status;
        String userName;
        String userId;
        String apiName;
        String lmsCustomerNumber;
        String errorDescription;
        String exceptionMessage;
        String exceptionLineNo;
        String custmerId;
        String appId;
   }

}