/**
* @author            :
* @group             : TechMatrix Consulting
* @description       :
* @created on        :
* @last modified on  : 03-08-2022
* @last modified by  : Suraj Kumar - Karan Singh Soni
* Changes - SK : 03/08/22 : Parsing the response
**/
public without sharing class FS_LMS_GetLoanDetailsAPI {
    
    //FS_LMS_GetLoanDetailsAPI.getLoanDetails('a030w000009gk8iAAA');
    public static void getLoanDetails( String apptId ){
        
        List< Sobject > listSobject = new List< Sobject >();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://uat-api.fsbl.in/api/1.0/ux/loan/details?branchId=5000400');
            request.setMethod('GET');
            request.setHeader('Authorization', 'Basic YWRtaW46YWRtaW4=');
            request.setHeader('CORRELATION-ID', 'HFGKDHN');
            request.setHeader('CLIENT-ID','78g659ed2a0dfa2b');
            request.setHeader('CLIENT-SECRET','f56f68b65739bd8a');
            request.setHeader('loanId','2Z4c4j6zy3ZX5wCdWnIVDQ==.dVBKHCfNddMXPxsx2Vitpg==');
            request.setHeader('loanAccountNumber','yUqDCj2AEDY9OsAALJX/9lMgQVUghAGV2zXDfzWVPgc=.woGex2Fo44tnk92ndBbIsg==');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Basic ' +EncodingUtil.base64Encode(Blob.valueOf('admin:admin')));
            request.setTimeout(120000);
            
            HttpResponse response = http.send(request);
            //HttpResponse response = new HttpResponse();
            //response.setStatusCode(200);
            //response.setBody('{ "success": { "requestHeader": null, "loanId": 5001121, "loanAccountNumber": "FSTNLALONS000005001121", "productDescription": "FSBL LAP", "financedAmount": 900000, "currencyIsoCode": "INR", "disbursalDate": "18/07/2017", "agreementDate": "03/07/2017", "productTypeDescription": "Loan Against Property", "businessDate": "04/05/2022", "matured": true, "tenure": 48, "propertyAddress": null, "disbursalStatus": "Fully Disbursed", "nextDueInstallmentAmount": 0, "nextDueDate": null, "balanceTenure": 0, "numberOfInstallmentUnpaid": 17, "amountOverdue": 842403.04, "loanRepaymentDetailMO": { "effectiveRateOfInterest": 26.6306345, "interestChargeMode": "Fixed", "repaymentFrequency": "Monthly", "repaymentDueDay": "18", "installmentAmount": 0, "repaymentModeDetails": [] }, "customerDetailMO": { "customerNumber": "GLBCUST00000003699", "fullName": "Karuppaiah K", "mobileNumber": "9787889706", "dateOfBirth": "01/07/1942", "primaryEmailId": null, "indvCorpFlag": "individual", "corporateDateOfInception": null, "panNumber": null, "identificationDetails": [ { "identificationType": "Ration Card", "identificationNumber": "25G0159736", "identificationReferenceNumber": null }, { "identificationType": "Aadhar No.", "identificationNumber": "814252902847", "identificationReferenceNumber": null } ], "vehicleRegistrationNumber": null, "requestHeader": null }, "noOfTransactionToDisplay": 0, "lastNPaymentsByCustomer": null, "lastNBounces": null, "nextNInstallments": null, "anchorCode": "BRATE", "anchorDescription": "BASE RATE FOR HOME LOAN", "anchorRate": 11.75, "netMarkup": 14.88, "applicationFormNumber": null, "ltv": 34, "lastDisbursalDate": null, "disbursedAmount": 900000, "finalSanctionedAmount": 900000, "maturityDate": "18/06/2021", "sourceApplicationId": 5001526, "status": "Active", "groupId": null, "limitReferenceNo": null, "depositLinkedAccount": null, "requestChannel": null, "principalOutstanding": 413345.77, "futurePrincipal": 0, "moratoriumInterest": 0, "moratoriumInterestReceived": 0, "tenureUnit": "Months", "nextEmiDueDate": null } }');
            System.debug('URL : ' + request.getEndpoint());
            System.debug('The status code returned : ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
            if (response != null && response.getStatusCode() == 200) {
                
                FS_LMS_GetLoanDetailsAPI objWrapResponse = parse(response.getbody());
                system.debug('@@## objRegResponse '+objWrapResponse);
                parseResponse(objWrapResponse, apptId );
                
                API_Logger__c objAPILogger = new API_Logger__c();
                objAPILogger.Name = 'FS_LMS_GetLoanDetailsAPI';
                objAPILogger.API_Name__c = 'FS_LMS_GetLoanDetailsAPI';
                objAPILogger.Status__c = 'Success';
                objAPILogger.Request__c = request.getBody();
                objAPILogger.Response__c = response.getBody().length() > 130068 ? response.getBody().substring(0, 130068) : response.getBody();
                objAPILogger.EndPoint__c = request.getEndpoint();
                listSobject.add(objAPILogger);
                
                /*if(objWrapResponse != null){

}*/
                
            }else{
                system.debug('API exception '+response);
                system.debug('API exception getStatusCode '+response.getStatusCode());
                Error_Logger__c objErrorLog = new Error_Logger__c();
                objErrorLog.Exception_Message__c = response.getbody();
                objErrorLog.Name = 'FS_LMS_GetLoanDetailsAPI';
                //listSobject.add( objErrorLog ) ;
            }
        }
        catch(System.CalloutException e) {
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Name = 'FS_LMS_GetLoanDetailsAPI';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            //listSobject.add( objErrorLog );
        }
        catch(Exception e){
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Exception_Message__c = e.getMessage();
            objErrorLog.Name = 'FS_LMS_GetLoanDetailsAPI';
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            //listSobject.add( objErrorLog );
        }
        
        if( !listSobject.isEmpty() ){
            upsert listSobject;
        }
    }
    //apptId is application Id which will be used as parent of LMS_Details__c
    private static void parseResponse( FS_LMS_GetLoanDetailsAPI objWrapResponse , String apptId){
        List<SObject> sObjList = new List<SObject>();
                
        String externalId = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));

        LMS_Details__c lmsReference = new LMS_Details__c(External__c = externalId);
        LMS_Details__c objLms = new LMS_Details__c(External__c = externalId);
        objLms.Application__c = apptId;
        
        objLms.RecordTypeId = Schema.SObjectType.LMS_Details__c.getRecordTypeInfosByDeveloperName()
            .get('LMS_Detail_Records')
            .getRecordTypeId();
        System.debug('lms detail rec id : ' + objLms.RecordTypeId);
        
        //objLms.Anchor_Code__c = objWrapResponse.Success.anchorCode;
        //objLms.Request_Header__c = objWrapResponse.success.requestHeader;
        //objLms.Loan_Id__c = objWrapResponse.success.loanId;
        objLms.Loan_Account_Number__c = objWrapResponse.success.loanAccountNumber;
        objLms.Product_Description__c = objWrapResponse.success.productDescription;
        //objLms.Financed_Amount__c = objWrapResponse.success.financedAmount;
        objLms.Currency_ISO_Code__c = objWrapResponse.success.currencyIsoCode;
        //objLms.Disbursal_Date__c = objWrapResponse.success.disbursalDate;
        //objLms.Agreement_Date__c = objWrapResponse.success.agreementDate;
        objLms.Product_Type_Description__c = objWrapResponse.success.productTypeDescription;
        //objLms.Business_Date__c = objWrapResponse.success.businessDate;
        objLms.Matured__c = objWrapResponse.success.matured;
        objLms.Tenure__c = objWrapResponse.success.tenure;
        objLms.Property_Address__c = objWrapResponse.success.propertyAddress;
        objLms.Disbursal_Status__c = objWrapResponse.success.disbursalStatus;
        //objLms.Next_Due_Installment_Amount__c = objWrapResponse.success.nextDueInstallmentAmount;
        //objLms.Next_Due_Date__c = objWrapResponse.success.nextDueDate;
        //objLms.Balance_Tenure__c = objWrapResponse.success.balanceTenure;
        objLms.Number_of_Installment_Unpaid__c = objWrapResponse.success.numberOfInstallmentUnpaid;
        objLms.Amount_Overdue__c = objWrapResponse.success.amountOverdue;
        objLms.Effective_Rate_Of_Interest__c = objWrapResponse.success.loanRepaymentDetailMO.effectiveRateOfInterest;
        objLms.Interest_Charge_Mode__c = objWrapResponse.success.loanRepaymentDetailMO.interestChargeMode;
        objLms.Repayment_Frequency__c = objWrapResponse.success.loanRepaymentDetailMO.repaymentFrequency;
        objLms.Repayment_Due_Day__c = objWrapResponse.success.loanRepaymentDetailMO.repaymentDueDay;
        //objLms.Installment_Amount__c = objWrapResponse.success.loanRepaymentDetailMO.installmentAmount;
        objLms.Customer_Number__c = objWrapResponse.success.customerDetailMO.customerNumber; //it can be string as per excel sheet
        objLms.Full_Name__c = objWrapResponse.success.customerDetailMO.fullName;
        //objLms.Mobile_Number__c = objWrapResponse.success.customerDetailMO.mobileNumber;
        //objLms.Date_Of_Birth__c = objWrapResponse.success.customerDetailMO.dateOfBirth;
        //objLms.Primary_Email_Id__c = objWrapResponse.success.CustomerDetailMO.primaryEmailId;
        objLms.Individual_Corp_Flag__c = objWrapResponse.success.customerDetailMO.indvCorpFlag;
        //objLms.Corporate_Date_Of_Inception__c = objWrapResponse.success.customerDetailMO.corporateDateOfInception;
        //objLms.Pan_Number__c = objWrapResponse.success.customerDetailMO.panNumber;
        
        
        List<LMS_Identification_Details__c> lmsIdList = new List<LMS_Identification_Details__c>();
        String recId = Schema.SObjectType.LMS_Identification_Details__c.getRecordTypeInfosByDeveloperName().get('LMS_Id_Details').getRecordTypeId();

        for(IdentificationDetails lmsId : objWrapResponse.success.customerDetailMO.IdentificationDetails){
            LMS_Identification_Details__c objLmsId = new LMS_Identification_Details__c();
           // LMS_Details__c lmsReference = new LMS_Details__c(External__c = externalId);
            //LMS_Details__c objLms1 = new LMS_Details__c(External__c = externalId);

            objLmsId.RecordTypeId = recId;
            
            objLmsId.Identification_Type__c = String.isNotBlank(lmsId.identificationType) ? lmsId.identificationType : Null;
            objLmsId.Identification_Number__c = String.isNotBlank(lmsId.identificationNumber) ? lmsId.identificationNumber : Null;
            
            //objLmsId.Identification_Reference_Number__c = lmsId.identificationReferenceNumber;
            
            //lmsIdList.add(objLmsId);
            objLmsId.LMS_Details__r = lmsReference;
            sObjList.add(objLmsId);
            
            System.debug('Api : ' + objLmsId.LMS_Details__r);
            
            
            lmsIdList.add(objLmsId);
            
            //LMS_Details__c lms = new LMS_Details__c(External__c = externalId); 

            
        }
        
        
        
        //System.debug('Identification1 : ' + lmsIdList);
        
	    //objLms.Vehicle_Registration_Number__c = objWrapResponse.success.customerDetailMO.vehicleRegistrationNumber;
        objLms.Number_Of_Transactions_To_Display__c = objWrapResponse.success.noOfTransactionToDisplay;
        //objLms.Last_N_Payments_By_Customer__c = objWrapResponse.success.lastNPaymentsByCustomer;
        //objLms.Last_N_Bounces__c = objWrapResponse.success.lastNBounces;
        //objLms.Next_N_Installments__c = objWrapResponse.success.nextNInstallments;
        objLms.Anchor_Code__c = objWrapResponse.success.anchorCode;
        objLms.Anchor_Description__c = objWrapResponse.success.anchorDescription;
        objLms.Anchor_Rate__c = objWrapResponse.success.anchorRate;
        objLms.Net_Markup__c = objWrapResponse.success.netMarkup;
        //objLms.Application_Form_Number__c = objWrapResponse.success.applicationFormNumber;
        //objLms.ltv__c = objWrapResponse.success.ltv;
        //objLms.Last_Disbursal_Date__c = objWrapResponse.success.lastDisbursalDate;
        //objLms.Disbursed_Amount__c = objWrapResponse.success.disbursedAmount;
        //objLms.Final_Sanctioned_Amount__c = objWrapResponse.success.finalSanctionedAmount;
        //objLms.Maturity_Date__c = objWrapResponse.success.maturityDate;
        //objLms.Source_Application_Id__c = objWrapResponse.success.sourceApplicationId;
        objLms.Status__c = objWrapResponse.success.status;
        //objLms.Group_Id__c = objWrapResponse.success.groupId;
        //objLms.Limit_Reference_Number__c = objWrapResponse.success.limitReferenceNo;
        //objLms.Deposit_Linked_Account__c = objWrapResponse.success.depositLinkedAccount;
        //objLms.Request_Channel__c = objWrapResponse.success.requestChannel;
        objLms.Principal_Outstanding__c = objWrapResponse.success.principalOutstanding;
        objLms.Future_Principal__c = objWrapResponse.success.futurePrincipal;
        objLms.Moratorium_Interest__c = objWrapResponse.success.moratoriumInterest;
        objLms.Moratorium_Interest_Received__c = objWrapResponse.success.moratoriumInterestReceived;
        objLms.Tenure_Unit__c = objWrapResponse.success.tenureUnit;
        //objLms.Next_Emi_Due_Date__c = objWrapResponse.success.nextEmiDueDate;
        
        System.debug('objLms : ' + objLms);
        
        
        
        //object ke saath record type jarur dena, schema se record type id kese laye for both the objects
        //objWrapResponse.Success.anchorCode;
        //objWrapResponse.Success.loanRepaymentDetailMO.interestChargeMode;
        //objWrapResponse.Success.customerDetailMO.identificationDetails;//iterate
        //System.debug(objWrapResponse);
        sObjList.add(objLms);
        System.debug('Sobject : ' + sObjList);
       
        
   		//Database.SaveResult[] results = Database.insert(new SObject[] {
            //objLms, objLmsId });
        Database.SaveResult[] res = Database.insert(sObjList,false);
        //Database.UpsertResult[] res = Database.upsert(sObjList,false);
        System.debug('Res : ' + res);
        /*System.debug('Cr : ' + res);
        
        for (Integer i = 0; i < res.size(); i++) {
            if (res[i].isSuccess()) {
            System.debug('Successfully created ID: '
                  + res[i].getId());
            } else {
            System.debug('Error: could not create sobject '
                  + 'for array element ' + i + '.');
            System.debug('   The error reported was: '
                  + res[i].getErrors()[0].getMessage() + '\n');
            }
        }*/
     
    }


//------------------------------ WRAPPER CLASS  -------------------------------------------------
public class RepaymentModeDetails {
}

public Success success;

public class LoanRepaymentDetailMO {
    public Double effectiveRateOfInterest;
    public String interestChargeMode;
    public String repaymentFrequency;
    public String repaymentDueDay;
    public Integer installmentAmount;
    public List<RepaymentModeDetails> repaymentModeDetails;
}

public class IdentificationDetails {
    public String identificationType;
    public String identificationNumber;
    public Object identificationReferenceNumber;
}

public class Success {
    public Object requestHeader;
    public Integer loanId;
    public String loanAccountNumber;
    public String productDescription;
    public Integer financedAmount;
    public String currencyIsoCode;
    public String disbursalDate;
    public String agreementDate;
    public String productTypeDescription;
    public String businessDate;
    public Boolean matured;
    public String tenure;
    public String propertyAddress;
    public String disbursalStatus;
    public Integer nextDueInstallmentAmount;
    public Object nextDueDate;
    public Integer balanceTenure;
    public Integer numberOfInstallmentUnpaid;
    public Double amountOverdue;
    public LoanRepaymentDetailMO loanRepaymentDetailMO;
    public CustomerDetailMO customerDetailMO;
    public Integer noOfTransactionToDisplay;
    public Object lastNPaymentsByCustomer;
    public Object lastNBounces;
    public Object nextNInstallments;
    public String anchorCode;
    public String anchorDescription;
    public Double anchorRate;
    public Double netMarkup;
    public Object applicationFormNumber;
    public Integer ltv;
    public Object lastDisbursalDate;
    public Integer disbursedAmount;
    public Integer finalSanctionedAmount;
    public String maturityDate;
    public Integer sourceApplicationId;
    public String status;
    public Object groupId;
    public Object limitReferenceNo;
    public Object depositLinkedAccount;
    public Object requestChannel;
    public Double principalOutstanding;
    public Integer futurePrincipal;
    public Integer moratoriumInterest;
    public Integer moratoriumInterestReceived;
    public String tenureUnit;
    public Object nextEmiDueDate;
}

public class CustomerDetailMO {
    public String customerNumber;
    public String fullName;
    public String mobileNumber;
    public String dateOfBirth;
    public Object primaryEmailId;
    public String indvCorpFlag;
    public Object corporateDateOfInception;
    public Object panNumber;
    public List<IdentificationDetails> identificationDetails;
    public Object vehicleRegistrationNumber;
    public Object requestHeader;
}
public static FS_LMS_GetLoanDetailsAPI parse(String json) {
    return (FS_LMS_GetLoanDetailsAPI) System.JSON.deserialize(json, FS_LMS_GetLoanDetailsAPI.class);
}



}