/**
* @Class Name         : FeeCreationTypeInsuranceNewController.apxc
* @Description        : Class to fetch details from Fee_Creation__c, Fee_Type_Master__c and Fee_Value_Master__c for insurance child component
                    on Pre-Login Screen/Fee Details.
* @Author             : Sangeeta Yadv
* @Created On         : 25/07/2022
*========================================================================================
* Ver         Date                     Author                       Modification
*========================================================================================
* 1.0        25/07/2022               Sangeeta Yadav                  Initial Version
* 2.0        03/10/2022               Sangeeta Yadav                  Modified Version
* 3.0        26/10/2022               Umair Ahmad                  Modified Version
**/
public with sharing class FeeCreationTypeInsuranceNewController {

    /*
    @Author : Sangeeta
    @Description : This method is used to fetch fee creation records for given application id.
    *//*Commented not in use
    @AuraEnabled(cacheable = true)
    public static List<Fee_Creation__c> getFeeTypeInsurance(String applicationId){
        List<Fee_Creation__c> listOfExistingInsFeeCreation = new List<Fee_Creation__c>();
        try { 
            if(String.isNotBlank(applicationId)){
                // Get fee creation records of type system and record type insurance with limit 1 to show only one record on UI
                // if records to disply in insurance of fee detail of type system only
                /*   listOfExistingInsFeeCreation = [SELECT Id,Type__c,Fee_Code__c,Stage_Due__c,Premium__c,Tax_Amount__c,
                                    Total_Fee__c,Sum_Assured__c,Repayment_Type_2__c, Application__r.Requested_Loan_Amount__c
                                    FROM Fee_Creation__c WHERE Application__c =: applicationId AND Type__c = 'System' AND RecordType.DeveloperName = 'Insurance' WITH SECURITY_ENFORCED];   
            */
                // list of insurance for type system and user
                /*Commented not in use
                listOfExistingInsFeeCreation = [SELECT Id,Type__c,Fee_Code__c,Stage_Due__c,Premium__c,Tax_Amount__c,External_Agency_Master__r.Name, Fee_Value_Master__c,
                                    Total_Fee__c,Sum_Assured__c,Repayment_Type_2__c,Fetch_Premium__c, Application__r.Requested_Loan_Amount__c, Fee_Collected__c, Applicable_For__c, 
                                    Property__c, Loan_Applicant__c,Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Receipt_Created__c 
                                    FROM Fee_Creation__c WHERE Application__c =: applicationId AND RecordType.DeveloperName = 'Insurance' WITH SECURITY_ENFORCED Order by Fee_Code__c Asc];   
    
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listOfExistingInsFeeCreation;
    }*/
    
    /* 
    @Author : Sangeeta
    @Description : This method is used to create fee creation record for given application id if it does not already contains fee creation records
                        based on fee type master records of type insurance and return single record to display on UI.
    
    @AuraEnabled(cacheable = true)
    public static List<Fee_Creation__c> createFeeCreationInsuranceRecords (String applicationId){
        System.debug('@@## applicationId   '+applicationId);
        List<Fee_Creation__c> createFeeCreationInsuranceList = new List<Fee_Creation__c>();
        // Map of repayment and fee creation id for Repayment multi picklist from Fee_Type_Master__c object to pass to Rrpayment_Type_2__c picklist of Fee creation
        Map<String, String> mapFeeToRepayment = new Map<String,String>(); 
        // Map for fee creation Id and fee value master id for calculation
        Map<String, String> mapFeeToRepaymentmapFeeToValueMaster = new Map<String,String>(); 
        // fetch fee value of type system
        List<Fee_Value_Master__c> feeValueMasterList = [SELECT Id, Fee_Type_Code__c, Fee_Type__c, Description__c, Fee_Type_Master__r.Stage_Due__c, Amount__c,
                                                        Fee_Type_Master__r.Repayment_of_Fee__c, Fee_Type_Master__r.Type__c, Fee_Type_Master__r.Amount__c, 
                                                        Fee_Type_Master__r.Applicable_For__c, Fee_Type_Master__r.Calculation_Basis__c, Fee_Type_Master__r.GL_Code__c,
                                                        Fee_Type_Master__r.Event__c, Fee_Type_Master__r.Tax__c, Fee_Type_Master__r.Value__c, Fee_Type_Master__r.Waivable__c 
                                                        FROM Fee_Value_Master__c WHERE Fee_Type__c = 'User' AND Fee_Type_Master__r.Type__c = 'Insurance' AND Fee_Type_Master__r.Active__c = 'Yes' AND Active__c = 'Yes'];
        // map to store existing records of type insurancefor given application 
        Map<String,Fee_Creation__c> existingFeeCreationInsuranceMap = new Map<String,Fee_Creation__c>();
        List<Fee_Creation__c> feeCreationInsList = [SELECT Id,Application__c,Application__r.Requested_Loan_Amount__c,Fee_Code__c, Stage__c, Amount__c, Applicable_For__c, RecordType.Name, Calculation_Basis__c FROM Fee_Creation__c WHERE Application__c =: applicationId AND RecordType.DeveloperName = 'Insurance'];
        for(Fee_Creation__c feeCreationIns : feeCreationInsList) {
            if(feeCreationIns.Application__c != null && feeCreationIns.Fee_Code__c != null && feeCreationIns.RecordType.Name == 'Insurance') {
                existingFeeCreationInsuranceMap.put(feeCreationIns.Application__c + '-' +feeCreationIns.Fee_Code__c, feeCreationIns );
            }
        }
        System.debug('EXISTING MAPPPPP   '+existingFeeCreationInsuranceMap);
        Decimal reqLoanAmount = [SELECT Id, Requested_Loan_Amount__c From Application__c WHERE Id =:applicationId].Requested_Loan_Amount__c;
        if(!feeValueMasterList.isEmpty()) {
            // create fee creation records based on master records
            for(Fee_Value_Master__c  feeValue : feeValueMasterList) {
                //System.debug('VALUEEEEE   '+ existingFeeCreationInsuranceMap.get(applicationId + '-' + feeValue.Fee_Type_Code__c));
                System.debug('Type   '+ feeValue.Fee_Type__c);
                System.debug('CODEEEEE   '+ feeValue.Fee_Type_Code__c);
    
                if(!(existingFeeCreationInsuranceMap.containsKey(applicationId + '-' + feeValue.Fee_Type_Code__c)) && String.IsNotBlank(feeValue.Fee_Type__c) && feeValue.Fee_Type__c == 'User') {
                    Fee_Creation__c feeCreation = new Fee_Creation__c();
                    feeCreation.Application__c = applicationId;
                    feeCreation.Fee_Code__c = feeValue.Fee_Type_Code__c;
                    feeCreation.Type__c = feeValue.Fee_Type__c;
                    feeCreation.Description__c = feeValue.Description__c;
                    //stage due is also used to check on which stage of application the fee is created. therefore stage is used on fee creation to 
                    //save stage due from fee master
                    feeCreation.Stage_Due__c = feeValue.Fee_Type_Master__r.Stage_Due__c;
                    feeCreation.Stage__c = feeValue.Fee_Type_Master__r.Stage_Due__c;
                    feeCreation.Fee_Type_Master__c = feeValue.Fee_Type_Master__r.Id;
                    if(reqLoanAmount != null){
                        feeCreation.Sum_Assured__c = reqLoanAmount;}
                    else{feeCreation.Sum_Assured__c = 0;}
                    feeCreation.Repayment_Type_2__c = 'Deduct from Disbursement';
                    // fetch record type Id for insurance to create records for insurance.
                    feeCreation.Applicable_For__c = null;
                    feeCreation.External_Agency_Master__c = null;
                    feeCreation.Premium__c = 0;
                    feeCreation.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
                    //Mapping for all fields on master
                    feeCreation.Amount__c = feeValue.Fee_Type_Master__r.Amount__c;
                    feeCreation.Calculation_Basis__c = feeValue.Fee_Type_Master__r.Calculation_Basis__c;
                    feeCreation.Event__c = feeValue.Fee_Type_Master__r.Event__c;
                    feeCreation.GL_Code__c = feeValue.Fee_Type_Master__r.GL_Code__c;
                    feeCreation.Tax__c = feeValue.Fee_Type_Master__r.Tax__c;
                    feeCreation.Value__c = feeValue.Fee_Type_Master__r.value__c;
                    feeCreation.Waivable__c = feeValue.Fee_Type_Master__r.Waivable__c;
                    feeCreation.Amount_Percentage__c = feeValue.Amount__c;
                    feeCreation.Fetch_Premium__c = false;
                    feeCreation.Receipt_Created__c = false;
                    
                    createFeeCreationInsuranceList.add(feeCreation);
                }
            }
            System.debug('SIZEEEEEEEEEEEE   CREATE LIST  '+ createFeeCreationInsuranceList);
            if(!createFeeCreationInsuranceList.isEmpty()) {
                createFeeCreationRecord( JSON.serialize(createFeeCreationInsuranceList) );                
            }
        }
        return createFeeCreationInsuranceList;
    }*/
    
    /*
    @Author : Sangeeta
    @Description : This method is used to insert new created records as method called in lwc can not insert records directly  
    *//*commented not in use
    @AuraEnabled(cacheable = true)
    @future
    public static void createFeeCreationRecord (String feeCreation)  {
        System.debug('feeCreation ' +feeCreation);
        if(String.isNotBlank(feeCreation)){
            List<Fee_Creation__c> feeCreationList = (List<Fee_Creation__c>)JSON.deserialize(feeCreation,List<Fee_Creation__c>.class);
            System.debug('VVVVVVVVVVVv ' +feeCreationList);
            insert feeCreationList;
            System.debug('id created'+ feeCreationList[0].Id);
        }
    }*/
    
    /*
    @Author : Sangeeta
    @Description : This method is used to update user entered sum insured on value change in sum insured column
    *//*commented not in use
    @AuraEnabled(cacheable = true)
    Public static String updateFeeCreationInsuranceRecordsSumAssured(String feeCreationId, Decimal sumAssured, Decimal premium, Decimal taxAmount, Decimal totalFee, String repayment, String applicableForValue, String applicableForSelect, String agencyName, Boolean fetchPremium){
        system.debug('update fee creation' + feeCreationId + sumAssured + applicableForValue + applicableForSelect + agencyName);
        Fee_Creation__c feeCreationUpdate = [SELECT Id, Sum_Assured__c, Fee_Code__c, Premium__c,Repayment_Type_2__c, Applicable_For__c, Loan_Applicant__r.Applicant_Name__c From Fee_Creation__c WHERE Id =: feeCreationId LIMIT 1];// limit to be add
        system.debug(feeCreationUpdate);
        //  feeCreationUpdate.Fee_Code__c = feeCreationUpdate.Fee_Code__c + rowNo;
        //  String agencyId = [SELECT Id, Name FROM External_Agency_Master__c WHERE Name =: agencyName].Id;
        System.debug('Agency Id'+agencyName);
        System.debug(feeCreationUpdate.Fee_Code__c);
        feeCreationUpdate.Sum_Assured__c = sumAssured;
        feeCreationUpdate.Premium__c = premium;
        feeCreationUpdate.Tax_Amount__c = taxAmount;
        feeCreationUpdate.Total_Fee__c = totalFee;
        feeCreationUpdate.Repayment_Type_2__c = repayment;
        System.debug('applicable for'+applicableForValue);
        feeCreationUpdate.Applicable_For__c = applicableForValue;
        if(feeCreationUpdate.Applicable_For__c == 'Applicant'){
            feeCreationUpdate.Loan_Applicant__c = applicableForSelect;
            feeCreationUpdate.Property__c = null;
        }
        else if(feeCreationUpdate.Applicable_For__c == 'Asset'){
            feeCreationUpdate.Property__c = applicableForSelect;
            feeCreationUpdate.Loan_Applicant__c = null;
        }
        else if(feeCreationUpdate.Applicable_For__c == 'Application'){
            feeCreationUpdate.Property__c = null;
            feeCreationUpdate.Loan_Applicant__c = null;
        }
        
            //feeCreationUpdate.External_Agency_Master__c = agencyId;
            feeCreationUpdate.External_Agency_Master__c = agencyName;
            feeCreationUpdate.Fetch_Premium__c = fetchPremium;
            System.debug('Fee creation Agency'+ feeCreationUpdate.External_Agency_Master__c);
        
        
        system.debug(feeCreationUpdate);
        if(feeCreationUpdate != null) {
            updateCallFeeCreationRecord( JSON.serialize(feeCreationUpdate) );
        }
        
        return 'feeCreationUpdate';
        
    }
    
    @AuraEnabled(cacheable=true)
    @future
    public static void updateCallFeeCreationRecord (String feeCreation)  {
        System.debug('update feecreation '+ feeCreation);
        Fee_Creation__c feeCreationUpdate = (Fee_Creation__c)JSON.deserialize(feeCreation,Fee_Creation__c.class);
        update(feeCreationUpdate);
        
    }*/
    
    /*
    @Author : Sangeeta
    @Description : To get picklist values based on fee value master.
    *//*Commented not in use
    @AuraEnabled(cacheable = true)
    public static Map<String, String> getRepaymentPicklist(String feeCode) {
        Map<String, String> values = new Map<String, String>{};
        if(String.isNotBlank(feeCode)){
            List<Fee_Type_Master__c> listOfFeeTypeMaster = [SELECT Id, Fee_Type_Code__c, Repayment_of_Fee__c FROM Fee_Type_Master__c
                                                        WHERE Fee_Type_Code__c =: feeCode];
            system.debug('listOfFeeTypeMaster '+ listOfFeeTypeMaster);
            if(listOfFeeTypeMaster != null && listOfFeeTypeMaster.size() > 0){
                List<String> repaymentList = new List<String>();
                if(String.IsNotBlank(listOfFeeTypeMaster[0].Repayment_of_Fee__c)){
                    if(listOfFeeTypeMaster[0].Repayment_of_Fee__c.contains(';')){
                        repaymentList = listOfFeeTypeMaster[0].Repayment_of_Fee__c.split(';');
                    }else{
                        repaymentList.add(listOfFeeTypeMaster[0].Repayment_of_Fee__c);
                    }
                }
                system.debug('repaymentList '+repaymentList);
                String objectName = 'Fee_Creation__c';
                String fieldName = 'Repayment_Type_2__c';
                
                List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
                String feeValue = '';
                for(Schema.DescribeSobjectResult res : results) {
                    for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                        if (entry.isActive()) {
                            feeValue = entry.getLabel();
                            if(repaymentList.contains(feeValue)){
                                values.put(entry.getValue(), entry.getLabel());
                            }
                            system.debug('entry'+ feeValue);
                        }
                    }system.debug('map'+ values);
                }
            }
        }
        return values;
    }*/
    /*@Author : Sangeeta
    @Description : This method is used to add new row to insurance details */
    @AuraEnabled
    public static Fee_Creation__c addRow(String applicationId, String feeCode, String rowNo, String stageName){
        //   List<Fee_Creation__c> wrapperFeeCreationList = (List<Fee_Creation__c>)JSON.deserialize(feeExist,List<Fee_Creation__c>.class);
        //   system.debug('wrapper'+ wrapperFeeCreationList);
        system.debug(feecode + 'stageNAme'+stageName);
        Fee_Creation__c feeCreated = new Fee_Creation__c();
        Decimal requestLoanAmount = [SELECT Id, Requested_Loan_Amount__c FROM Application__c WHERE Id =:applicationId].Requested_Loan_Amount__c;
        feeCreated.Fee_Code__c = feeCode + rowNo;
        feeCreated.Total_Fee__c = 0;
        feeCreated.Type__c = 'User';
        if(stageName != null && stageName != ''){
            feeCreated.Stage_Due__c = stageName;
        }
        else{
            feeCreated.Stage_Due__c = 'Pre Login';
        }
        
        feeCreated.Tax_Amount__c = 0;
        feeCreated.Premium__c = 0;
        feeCreated.Repayment_Type_2__c = 'Deduct from Disbursement';  
        feeCreated.Applicable_For__c = '';
        feeCreated.External_Agency_Master__c = null;
        feeCreated.Fetch_Premium__c = false;
        //  feeCreated.Applicable_For__c = 'Application';
        //  feeCreated.Loan_Applicant__c = null;
        //  feeCreated.Property__c = null;
        feeCreated.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        if(requestLoanAmount != null){
            feeCreated.Sum_Assured__c = requestLoanAmount;}
        else{
            feeCreated.Sum_Assured__c = 0;}
        feeCreated.Application__c = applicationId; 
        feeCreated.Receipt_Created__c = false;
        
        system.debug('list is'+ feeCreated);
        return feeCreated;
    }
    /*@Author : Sangeeta
        @Description : this method is used to create new record of insurance added by user from fee detail screen*/
    
  /*  @AuraEnabled
    public static Fee_Creation__c createNewFee(Fee_Creation__c feeCreate, String appId, String agencyName, String applicableTo, String applicableForValue, Boolean fetchPremium){
        system.debug('feeCreate'+feeCreate + agencyName + applicableTo + applicableForValue);
        List<Fee_creation__c> craeteFee = new List<Fee_creation__c>();
        String feeId;
    
        if(feeCreate != null && appId != null && appId != ''){
            //   Application__c requestLoanAmount = [SELECT Id, Requested_Loan_Amount__c FROM Application__c WHERE Id =:appId];
            /*   feeCreate.Sum_Assured__c = requestLoanAmount.Requested_Loan_Amount__c;
            system.debug('feeCreate'+feeCreate);*/
         /*   feeCreate.External_Agency_Master__c = agencyName;
            if(applicableForValue == 'Applicant'){
                feeCreate.Loan_Applicant__c = applicableTo;
            }
            else if(applicableForValue == 'Asset'){
                feeCreate.Property__c = applicableTo;
            }
            feeCreate.Fetch_Premium__c = fetchPremium;
            craeteFee.add(feeCreate);
            //	createFeeCreationRecord( JSON.serialize(feeCreate) ); 
                    
        }
        Fee_Creation__c newFeeToReturn = new Fee_Creation__c();
        if(craeteFee.size() == 1 && !Test.isRunningTest()){
            feeId = createNewFeeCreationNewRowRecord(JSON.serialize(craeteFee));
            newFeeToReturn = [SELECT Id,Type__c,Fee_Code__c,Stage_Due__c,Premium__c,Tax_Amount__c,External_Agency_Master__r.Name,
            Total_Fee__c,Sum_Assured__c,Repayment_Type_2__c, Application__r.Requested_Loan_Amount__c, Fee_Collected__c, Applicable_For__c, Property__c, Loan_Applicant__c,Loan_Applicant__r.Applicant_Name__c, Property__r.Name
            FROM Fee_Creation__c WHERE Id =: feeId];
        }
        return newFeeToReturn;
    }*/
   /* public static String createNewFeeCreationNewRowRecord (String feeCreation)  {
        System.debug('feeCreation ' +feeCreation);
        String feeId;
        if(String.isNotBlank(feeCreation)){
            List<Fee_Creation__c> feeCreationList = (List<Fee_Creation__c>)JSON.deserialize(feeCreation,List<Fee_Creation__c>.class);
            System.debug('VVVVVVVVVVVv ' +feeCreationList);
            //  String agencyId = [SELECT Id, Name FROM External_Agency_Master__c WHERE Name =: feeCreationList[0].External_Agency_Master__c].Id;
            // feeCreationList[0].External_Agency_Master__c = agencyId;
            insert feeCreationList;
            System.debug('id created'+ feeCreationList);
            feeId = feeCreationList[0].Id;
            //   updateFeeCreationInsuranceRecordsSumAssured(feeCreationList[0].Id, feeCreationList[0].Sum_Assured__c, feeCreationList[0].Premium__c, feeCreationList[0].Tax_Amount__c, feeCreationList[0].Total_Fee__c, feeCreationList[0].Repayment_Type_2__c, '', '');
    
        }
        return feeId;
    }*/
    /*Description: To get picklist values from Fee type master for applicable for*/
    @AuraEnabled
    public static Map<String, String> picklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};
    
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
    
        return values;
    }
    // to get list of applicant and property based on applicable on selection
    @AuraEnabled
    public static Map<String, String> getLoanApplicant(String applicationId, String applicableFor){
        Map<String, String> applicableString = new Map<String, String>();
        system.debug('applicableFor'+applicableFor);
        if(ApplicationId != null && ApplicationId != ''){
            if(applicableFor == 'Applicant'){
                List<Loan_Applicant__c> applicantDetails = [SELECT Id, Applicant_Name__c FROM Loan_Applicant__c 
                                                            WHERE Application__c =:applicationId];
                for(Loan_Applicant__c appName : applicantDetails){
                    applicableString.put(appName.Id, appName.Applicant_Name__c);
                }
            }
            else if(applicableFor == 'Asset'){
                List<Property__c> propertyDetails = [SELECT Id, Name, Title_Deed_Number__c FROM Property__c 
                                                            WHERE Application__c =:applicationId AND RecordType.name = 'Pre Login Property Detail'];
                for(Property__c propName : propertyDetails){
                    applicableString.put(propName.Id, propName.Name);
                }
            }
            else{
                
            }
        }
        system.debug('applicable for:'+applicableString);
        return applicableString;
    }
    //Method to show Agency Name from agency master
    @AuraEnabled
    Public static Map<String, String> getAgencyPicklist(){
       // List<External_Agency_Master__c> agencyList = [SELECT Id, Name FROM External_Agency_Master__c];
        List<Account> agencyList = [select id,name, RecordType.DeveloperName from account where RecordType.DeveloperName = 'Insurance_Agency'];
        Map<String, String> agencyName = new Map<String, String>();
        for(Account agency : agencyList){
            agencyName.put(agency.Id, agency.Name);
        }
        System.debug('Agency Map'+agencyName);
        return  agencyName;       
    }
    
        
    
    /*
    @Author : Navin Soni
    @Description : This method is use to call Kotak Calculate API.
    */
        @AuraEnabled
        public static List<Premium_Details__c> callKotakCalculateAPI(String feeId, Decimal sumAssured){
            if(String.isNotBlank(feeId)){
                KotakCalculateAPI.callKotakCalculateAPI(feeId, sumAssured);
                List<Premium_Details__c> listOfPremiumDetails = [SELECT Id, Application__c, Job_Id__c, Sum_Assured__c, Premium__c, Service_Tax__c, Total_Premium__c, Fee_Creation__r.Sync_Error__c FROM Premium_Details__c where Fee_Creation__c =: feeId ORDER BY ID DESC LIMIT 1 ];
                if(listOfPremiumDetails != null && listOfPremiumDetails.size() > 0 && String.isBlank(listOfPremiumDetails[0].Fee_Creation__r.Sync_Error__c)){
                    return listOfPremiumDetails;
                }
            }
            return null;
        }
        //for vs 2 on 03/10/22
    
        @AuraEnabled
        public static List<insuranceWrapper> getInsuranceRecords(String applicationId,String stageName){
            System.debug('get insurance called');
        List<Fee_Creation__c> listOfExistingInsFeeCreation = new List<Fee_Creation__c>();
        //wrapper added on 03-10-22
        List<insuranceWrapper> insFeeWrapList = new List<insuranceWrapper>();
        try { 
            if(String.isNotBlank(applicationId)){
                // Get fee creation records of type system and record type insurance with limit 1 to show only one record on UI
                // if records to disply in insurance of fee detail of type system only
                /*   listOfExistingInsFeeCreation = [SELECT Id,Type__c,Fee_Code__c,Stage_Due__c,Premium__c,Tax_Amount__c,
                                    Total_Fee__c,Sum_Assured__c,Repayment_Type_2__c, Application__r.Requested_Loan_Amount__c
                                    FROM Fee_Creation__c WHERE Application__c =: applicationId AND Type__c = 'System' AND RecordType.DeveloperName = 'Insurance' WITH SECURITY_ENFORCED];   
            */
                // list of insurance for type system and user
                listOfExistingInsFeeCreation = [SELECT Id,Type__c,Fee_Code__c,Stage_Due__c,Premium__c,Tax_Amount__c,External_Agency_Master__r.Name, External_Agency_Master__c,
                                    Total_Fee__c,Sum_Assured__c,Repayment_Type_2__c,Fetch_Premium__c, Application__r.Requested_Loan_Amount__c, Application__r.Total_Amount_Recommended_PcAc__c ,Fee_Collected__c, Applicable_For__c, 
                                    Property__c, Loan_Applicant__c,Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Receipt_Created__c, Pending_Premium_Calculation__c, Fee_Value_Master__c, Description__c 
                                    FROM Fee_Creation__c WHERE Application__c =: applicationId AND RecordType.DeveloperName = 'Insurance' WITH SECURITY_ENFORCED Order by createdDate Asc];   
    
            }
            //Changes done on 03-10-22
            Map<String, List<String>> repaymentListMasterBased = new Map<String, List<String>>();
            if(listOfExistingInsFeeCreation != null && listOfExistingInsFeeCreation.size() >0){
                repaymentListMasterBased =  repaymentTypeFromMaster('Insurance');
                for(Fee_Creation__c fee : listOfExistingInsFeeCreation){
                    insuranceWrapper insFeeWrap = new insuranceWrapper();
                    if(fee.Total_Fee__c == null){
                        fee.Total_Fee__c = 0;
                    }
                    insFeeWrap.feeList = fee;
                    if(fee.External_Agency_Master__c != null){
                        insFeeWrap.externalAgencyName = fee.External_Agency_Master__r.Name;
                    }
                    else{
                        insFeeWrap.externalAgencyName = '';
                    }
                    
                    if(fee.Applicable_For__c == 'Applicant'){
                        insFeeWrap.applicantAsset = true;
                        insFeeWrap.isApplication = false;
                        if(fee.Loan_Applicant__c != null){
                            insFeeWrap.applicantOrAssetName = fee.Loan_Applicant__r.Applicant_Name__c;
                        }
                        else{
                            insFeeWrap.applicantOrAssetName = null;
    
                        }
                    }
                    else if(fee.Applicable_For__c == 'Asset'){
                        insFeeWrap.applicantAsset = false;
                        insFeeWrap.isApplication = false;
                        if(fee.Property__c != null){
                            insFeeWrap.applicantOrAssetName = fee.Property__r.Name;
                        }
                        else{
                            
                            insFeeWrap.applicantOrAssetName = null;
                        }
                    }
                   /* else if(fee.Applicable_For__c == 'Application'){
                        insFeeWrap.applicantAsset = false;
                        insFeeWrap.isApplication = true;
                        insFeeWrap.loanPropertyName = null;
                    }*/
                    else{
                        insFeeWrap.applicantAsset = false;
                        insFeeWrap.isApplication = true;
                        insFeeWrap.applicantOrAssetName = null;
                    }
                    
                    insFeeWrap.isNewRow = false;
                    insFeeWrap.isChange = false;
                    
                    insFeeWrap.repaymentDetail = new List<RepaymentDetailWrapper>();
                    if(repaymentListMasterBased.keySet().contains(fee.Fee_Code__c)){
                        List<String> repaymentValue = repaymentListMasterBased.get(fee.Fee_Code__c);
                        if(repaymentValue != null && repaymentValue.size() > 0){
                            for(String repayment : repaymentValue){
                                RepaymentDetailWrapper repDetail = new RepaymentDetailWrapper();
                                repDetail.label = repayment;
                                repDetail.value = repayment;
                                insFeeWrap.repaymentDetail.add(repDetail);
                            }
                        }
                    }
                    insFeeWrapList.add(insFeeWrap);
                }
                System.debug('get insurance' + insFeeWrapList);
            }
            system.debug('stageName before'+stageName);
             if(stageName == 'Process Credit' || stageName == 'Approval Credit')
             { 
                 system.debug('stageName after'+stageName);
                 updateInsurancePremium(applicationId);}
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return insFeeWrapList;
    }
    
    // Wrapper added for vs 2 (changes done on 03-10-22)  
    public Class insuranceWrapper{
        // public List<Tr_Deviation__c> devList;
        @AuraEnabled public Fee_Creation__c feeList;
        @AuraEnabled public String externalAgencyName;
        @AuraEnabled public String loanPropertyName;
        @AuraEnabled public Boolean isNewRow;
        @AuraEnabled public Boolean applicantAsset;
        @AuraEnabled public Boolean isApplication;
        @AuraEnabled public String applicantOrAssetName;
        @AuraEnabled public List<RepaymentDetailWrapper> repaymentDetail;
        @AuraEnabled public Boolean isChange; 
       // @AuraEnabled public Boolean applicantAsset;
       // @AuraEnabled public Boolean isApplication;
        
       // @AuraEnabled public String applicantOrAssetName;
        
       // @AuraEnabled public List<UserDetailWrapper> userDetail;
        
    }  
    
    //get new row for vs2
    @AuraEnabled
    public static insuranceWrapper getNewRow(String applicationId, String stageName){
        //Decimal requestLoanAmount;
        Decimal recommendedLoanAmount;
        insuranceWrapper insWrap = new insuranceWrapper();
        Fee_Creation__c feeCreated = new Fee_Creation__c();
        if(String.isNotBlank(applicationId)){
            //requestLoanAmount = [SELECT Id, Requested_Loan_Amount__c FROM Application__c WHERE Id =:applicationId].Requested_Loan_Amount__c;
            recommendedLoanAmount = [SELECT Id, Total_Amount_Recommended_PcAc__c FROM Application__c WHERE Id =:applicationId].Total_Amount_Recommended_PcAc__c;
        }
        //feeCreated.Fee_Code__c = feeCode + rowNo;
        feeCreated.Total_Fee__c = 0;
        feeCreated.Type__c = 'User';
        if(stageName != null && stageName != ''){
            feeCreated.Stage_Due__c = stageName;
        }
        else{
            feeCreated.Stage_Due__c = 'Pre Login';
        }
        
        feeCreated.Tax_Amount__c = 0;
        feeCreated.Premium__c = 0;
        //feeCreated.Repayment_Type_2__c = 'Deduct from Disbursement';  
        feeCreated.Applicable_For__c = '';
        feeCreated.External_Agency_Master__c = null;
        feeCreated.Fetch_Premium__c = false;
        feeCreated.Pending_Premium_Calculation__c = false;
        
        //  feeCreated.Applicable_For__c = 'Application';
        //  feeCreated.Loan_Applicant__c = null;
        //  feeCreated.Property__c = null;
        feeCreated.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Insurance').getRecordTypeId();
        if(recommendedLoanAmount != null){
            //feeCreated.Sum_Assured__c = requestLoanAmount;
            feeCreated.Sum_Assured__c = recommendedLoanAmount;
        }
        else{
            feeCreated.Sum_Assured__c = 0;
        }
        feeCreated.Application__c = applicationId; 
        feeCreated.Receipt_Created__c = false;
        insWrap.feeList = feeCreated;
        insWrap.externalAgencyName = null;
        //insWrap.loanPropertyName = null;
        insWrap.isNewRow = true;
        insWrap.applicantOrAssetName = null;
        insWrap.applicantAsset = false;
        insWrap.isApplication = false;
        insWrap.isChange = true;
        insWrap.repaymentDetail = new List<RepaymentDetailWrapper>(); 
        return insWrap;
    }
    
    // get fee code based on master of insurance for picklist of fee code in insurance detail
    /*@AuraEnabled
    
        public Static Map<String, Fee_Type_Master__C> getFeeCodeFromMaster(String applicationId){
            //Map<String, String> feeCode = new Map<String, String>();
            Map<String, Fee_Type_Master__C> feeCode = new Map<String, Fee_Type_Master__C>();
            System.debug('get fee code from master');
            List<Fee_Creation__c> fee = [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Fee_Type_Master__r.Fee_Type_Code__c,Fee_Type_Master__r.Id, Total_Fee__c FROM Fee_Creation__c WHERE Type__c = 'User' AND RecordType.DeveloperName = 'Insurance' AND Application__c =:applicationId];
            List<Fee_Type_Master__C> feeMasterCode = [SELECT Id, Fee_Type_Code__c, Applicable_For__c FROM Fee_Type_Master__c WHERE Fee_Type__c = 'User' AND Type__c ='Insurance' AND Active__c = 'Yes'];
            if(feeMasterCode != null && feeMasterCode.size() > 0){
                for(Fee_Type_Master__C masterMap : feeMasterCode){
                    //feeCode.put(masterMap.Id, masterMap.Fee_Type_Code__c);
                    feeCode.put(masterMap.Id, masterMap);
                }
            }
            system.debug('feeCode before remove'+feeCode);
            // To add fee code based on applicant/asset and fee code combination commented below if condition
           /* if(fee.size() > 0){
                for(Fee_Creation__c feeRemove : fee){
                    String masterId = feeRemove.Fee_Type_Master__r.Id;
                    if(feeCode.containsKey(masterId)){
                        feeCode.remove(masterId);
                    }
                    
                }
            }*/
          /*  System.debug('feeMasterCode'+feeCode);
            return feeCode;
        }*/


        @AuraEnabled
    //public Static Map<String, Fee_Type_Master__C> getFeeCodeFromMaster(String applicationId){
    //Added to add FVM in Fee name dropdown on fee creation screen : 22-11-22
    public Static List<feeValueWrapper> getFeeCodeFromMaster(String applicationId){
        //Map<String, String> feeCode = new Map<String, String>();
        Map<String, Fee_Type_Master__C> feeCode = new Map<String, Fee_Type_Master__C>();
        //Map<Fee_value_Master__c, Fee_Type_Master__C> feeCode = new Map<Fee_value_Master__c, Fee_Type_Master__C>();
        List<feeValueWrapper> wrapperForFeeOptionList = new List<feeValueWrapper>();
        System.debug('get fee code from master');
       // List<Fee_Creation__c> fee = [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Fee_Type_Master__r.Fee_Type_Code__c,Fee_Type_Master__r.Id, Total_Fee__c FROM Fee_Creation__c WHERE Type__c = 'User' AND RecordType.DeveloperName = 'Fee' AND Application__c =:applicationId];
        List<Fee_Type_Master__C> feeMasterCode = [SELECT Id, Fee_Type_Code__c, Applicable_For__c, Stage_Due__c, Amount__c, Calculation_Basis__c, Event__c, GL_Code__c, Tax__c, value__c, Waivable__c, Modifiable_at_run_Time__c, (SELECT Id, Name, Fee_Type_Code__c, Fee_Type__c, Amount__c, Description__c
                                                    FROM Fee_Value_Master__r WHERE Active__c = 'Yes') FROM Fee_Type_Master__c WHERE Fee_Type__c = 'User' AND Type__c ='Insurance' AND Active__c = 'Yes'];
        if(feeMasterCode.size() > 0){
            
            for(Fee_Type_Master__C masterMap : feeMasterCode){
                //Fee value master added to add fVM in fee name dropdown : 22-11-22
                if(masterMap.Fee_Value_Master__r != null && masterMap.Fee_Value_Master__r.size() > 0){
                    for(Fee_Value_Master__C masterValueMap : masterMap.Fee_Value_Master__r){
                        feeValueWrapper feeValueWrap = new feeValueWrapper(); 
                        //feeCode.put(masterMap.Id, masterMap.Fee_Type_Code__c);
                        //feeCode.put(masterMap.Id, masterMap);
                        //FVM added in option : 22-11-22
                        feeCode.put(masterMap.Id, masterMap);
                        feeValueWrap.feeValueId = masterValueMap.Id;
                        feeValueWrap.feeMasterId = masterMap.Id;
                        feeValueWrap.feeMasterFeeCode = masterMap.Fee_Type_Code__c;
                        feeValueWrap.feeValue = masterValueMap;
                        feeValueWrap.feeTypeFromMaster = masterMap;
                        wrapperForFeeOptionList.add(feeValueWrap);
                    }
                }
            }
        }
        system.debug('feeCode before remove'+feeCode);
        // To add fee code based on applicant/asset and fee code combination commented below if condition
       /* if(fee.size() > 0){
            for(Fee_Creation__c feeRemove : fee){
                String masterId = feeRemove.Fee_Type_Master__r.Id;
                if(feeCode.containsKey(masterId)){
                    feeCode.remove(masterId);
                }
                
            }
        }*/
        System.debug('feeMasterCode'+feeCode);
       // return feeCode;
       return wrapperForFeeOptionList;
    }
    
        // for repayment picklist based on master
        public class RepaymentDetailWrapper {
            @AuraEnabled
            public String label;
            @AuraEnabled
            public String value;
        }
    
        //Repayment picklist based on master
        @AuraEnabled
        public static Map<String, List<String>> repaymentTypeFromMaster(String feeRecordType){
            try {
                //List<Fee_Type_Master__c> feeValueMasterList = [SELECT Id, Repayment_of_Fee__c, Type__c, Applicable_For__c FROM Fee_Type_Master__c 
                //WHERE Fee_Type__c = 'User' AND Type__c = 'Insurance' AND Active__c = 'Yes'];
                Map<String, List<String>> repaymentMap = new Map<String, List<String>>();
                List<Fee_Type_Master__c> feeValueMasterList = [SELECT Id, Fee_Type_Code__c, Repayment_of_Fee__c, Type__c, Applicable_For__c 
                                                            FROM Fee_Type_Master__c  WHERE Active__c = 'Yes' AND Type__c =: feeRecordType];
                if(feeValueMasterList != null && feeValueMasterList.size() > 0){
                    for(Fee_Type_Master__c feeMaster : feeValueMasterList){
                        List<String> repaymentValue = new List<String>();
                        if(String.IsNotBlank(feeMaster.Repayment_of_Fee__c)){
                            if(feeMaster.Repayment_of_Fee__c.contains(';')){
                                repaymentValue = feeMaster.Repayment_of_Fee__c.split(';');
                            }else{
                                repaymentValue.add(feeMaster.Repayment_of_Fee__c);
                            }
                        }
                        repaymentMap.put(feeMaster.Fee_Type_Code__c, repaymentValue);
                        
                    }
                }
                System.debug('repaymentMap'+ repaymentMap);
                return repaymentMap;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        // upsert insurance fee
        @AuraEnabled
        public static List<Fee_Creation__c> saveInsFeeRecords(String insWrapperList){
            List<Fee_Creation__c> updateInsFeeList = new List<Fee_Creation__c>();
            System.debug('save wrapper list' + insWrapperList);
            //if(devWrapperList != null){
                List<insuranceWrapper> wrapperInsFeeList = (List<insuranceWrapper>)JSON.deserialize(insWrapperList,List<insuranceWrapper>.class);
                System.debug('wrapper data to update'+wrapperInsFeeList);
                List<Fee_Value_Master__C> wrapMaster = new List<Fee_Value_Master__C>();
                if(wrapperInsFeeList != null && wrapperInsFeeList.size() > 0){
                    System.debug('wrapperInsFeeList.master' + wrapperInsFeeList[0].feeList.Fee_Type_Master__C);
                    if(wrapperInsFeeList[0].isNewRow == true){
                    wrapMaster = [SELECT Id, Amount__c, Amount_Flat__c, Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Applicable_For__c, Fee_Type_Master__r.Calculation_Basis__c, Fee_Type_Master__r.Event__c, Fee_Type_Master__r.Type__c, Fee_Type_Master__r.GL_Code__c, Description__c,
                    Fee_Type_Master__r.Stage_Due__c, Fee_Type_Master__r.Tax__c, Fee_Type_Master__r.Value__c, Fee_Type_Master__r.Waivable__c FROM Fee_Value_Master__C WHERE Fee_Type_Master__c =: wrapperInsFeeList[0].feeList.Fee_Type_Master__C AND Id =: wrapperInsFeeList[0].feeList.Fee_Value_Master__C];
                    }
    
                    for(insuranceWrapper wrapList : wrapperInsFeeList){
                        System.debug('wrapList.RowNumber'+wrapList);
                        Fee_Creation__c feeItem = new Fee_Creation__c();
                        feeItem = wrapList.feeList;
                        if(wrapList.isNewRow == true && wrapMaster != null && wrapMaster.size() > 0){
                            feeItem.Amount__c = wrapMaster[0].Fee_Type_Master__r.Amount__c;
                            feeItem.Fee_Value_Amount__c = wrapMaster[0].Amount_Flat__c;
                            feeItem.Amount_Percentage__c = wrapMaster[0].Amount__c;
                            feeItem.Description__c = wrapMaster[0].Description__c;
                            feeItem.Applicable_For__c = wrapMaster[0].Fee_Type_Master__r.Applicable_For__c;
                            feeItem.Calculation_Basis__c = wrapMaster[0].Fee_Type_Master__r.Calculation_Basis__c;
                            feeItem.Event__c = wrapMaster[0].Fee_Type_Master__r.Event__c;
                            //feeItem.Type__c = wrapMaster[0].Fee_Type_Master__r.Type__c;
                            feeItem.GL_Code__c = wrapMaster[0].Fee_Type_Master__r.GL_Code__c;
                            feeItem.Stage__c = wrapMaster[0].Fee_Type_Master__r.Stage_Due__c;
                            feeItem.Tax__c = wrapMaster[0].Fee_Type_Master__r.Tax__c;
                            feeItem.Value__c = wrapMaster[0].Fee_Type_Master__r.Value__c;
                            feeItem.Waivable__c = wrapMaster[0].Fee_Type_Master__r.Waivable__c;
                        }
                        System.debug('feeItem to save' + feeItem.Fee_Type_Master__C);
                        updateInsFeeList.add(feeItem);
                    }
                }
            //}
            System.debug('tr list to update' + updateInsFeeList.size() +updateInsFeeList);
            if(updateInsFeeList.size() > 0 && !Test.isRunningTest()){
                upsert updateInsFeeList;
            }
            return updateInsFeeList;
    
        }
    
        //To delete insurance record vs 2
        
        @AuraEnabled
        public static List<Fee_Creation__c> deleteFee(String insWrapperList){
            List<Fee_Creation__c> deleteInsFeeList = new List<Fee_Creation__c>();
            System.debug('save wrapper list' + insWrapperList);
            //if(devWrapperList != null){
                List<insuranceWrapper> wrapperInsFeeList = (List<insuranceWrapper>)JSON.deserialize(insWrapperList,List<insuranceWrapper>.class);
                System.debug('wrapper data to delete'+wrapperInsFeeList);
                if(wrapperInsFeeList != null && wrapperInsFeeList.size() > 0){
                    for(insuranceWrapper wrapList : wrapperInsFeeList){
                        System.debug('wrapList.RowNumber'+wrapList);
                        Fee_Creation__c feeItem = new Fee_Creation__c();
                        feeItem = wrapList.feeList;
    
                        deleteInsFeeList.add(feeItem);
                    }
                }
            //}
            System.debug('tr list to update' + deleteInsFeeList.size() +deleteInsFeeList);
            if(deleteInsFeeList.size() > 0 && !test.isRunningTest()){
                delete deleteInsFeeList;
            }
            return deleteInsFeeList;
    
        }
    
        //Check if Kotak API is active or not
        @AuraEnabled
        public static Boolean isApiActive(){
            Boolean isApiActive;
            List<API_Handler__mdt> isApi = [SELECT Id, DeveloperName, isActive__c FROM API_Handler__mdt where DeveloperName = 'Kotak_Calculate' AND isActive__c = true ];
            if(isApi != null && isApi.size() > 0){
                isApiActive = true;
            }
            else{
                isApiActive = false;
            }
            System.debug('isApiActive'+ isApiActive);
            return isApiActive;
        }

        //To show error message from kotak api API fail
        //added on 20-10-2022
        @AuraEnabled
        public static String getSyncError(String feeId){
            System.debug('Fee creation to get error' + feeId);
            
            if(String.isNotBlank(feeId)) {
                
                List<Fee_Creation__c> feeCreationList = [SELECT Id, Sync_Error__c FROM Fee_Creation__c WHERE Id =: feeId LIMIT 1];

              //  System.debug('Sync_Error__c is >>>>'+feeCreationList[0].Sync_Error__c);

                if(feeCreationList != null && feeCreationList.size() > 0){
                    if(String.isNotBlank(feeCreationList[0].Sync_Error__c)){
                         System.debug('Sync_Error__c is 2 >>>>'+feeCreationList[0].Sync_Error__c);
                         cls_error obj = new cls_error();
                        //String syncErrSerialize = JSON.serialize(feeCreationList[0].Sync_Error__c);
                        errorMessage objError = new errorMessage();
                        objError = errorParse(feeCreationList[0].Sync_Error__c);
                        obj=objError.error;
                   //     System.debug('obj description is >>>'+obj.description[0]);
                        //objError = errorParse(syncErrSerialize);
                        System.debug('@@## objError '+objError);
                        if(objError != null && objError.error != null && String.isNotBlank(objError.error.description)){
                            return ''+objError.error.description;
                        }
                        return 'Error Occurred. Please try again later';
                    }
                    else{
                        return 'Success';
                    }
                     
                }
            }  
            return 'null';
        }
    
// Added By Ajay Kumar: 06/01/2023
     // method used to update total insurance premium at the Application
       @AuraEnabled
        public static void updateInsurancePremium(String applicationId){   
            Decimal TotalPremium = 0;
            Fee_Creation__c[] InsuranceObjList  = new List<Fee_Creation__c>();
            String childTrancheDisb = '',parentTrancheDisb = '';
             InsuranceObjList = [SELECT Id,Premium__c,Total_Fee__c,Tax_Amount__c,Application__r.Tranche_Disbursal__c,Application__r.Old_Application__r.Tranche_Disbursal__c,Stage_Due__c,Application__r.Stage__c,Application__r.Insurance_Premium__c  FROM Fee_Creation__c WHERE RecordType.Name = 'Insurance' 
            AND Application__c=:applicationId AND  Stage_Due__c  IN ('Process Credit','Approval Credit') AND Application__r.Stage__c  IN ('Process Credit','Approval Credit') ];
            for(Fee_Creation__c InsuranceObj : InsuranceObjList)
            {
                childTrancheDisb = InsuranceObj.Application__r.Tranche_Disbursal__c;
                parentTrancheDisb = InsuranceObj.Application__r.Old_Application__r.Tranche_Disbursal__c;
                if(InsuranceObj.Total_Fee__c!= null )
                {    TotalPremium += InsuranceObj.Total_Fee__c; }
                                
            }
            
            If(String.isnotEmpty(applicationId) && String.isnotBlank(applicationId) && InsuranceObjList.size()>0)
            {
                Application__c appObj = new Application__c();
                appObj.Id = applicationId;
                appObj.Insurance_Premium__c  = TotalPremium.round(System.RoundingMode.HALF_UP);
                if(childTrancheDisb == 'I')
                appObj.Insurance_Premium_Tranche_1__c = TotalPremium.round(System.RoundingMode.HALF_UP);
                Update appObj;		
            }
        }
    /*@Description: For CR discussion on 09/01/23: Premium and tax will be editable in Insurance fee if:
                   Insurance_Medical_Test_Result__c: Rated Up
                   Insurance_Requirement__c: DOGH + MT
   Dated: 10 jan 23
   @Author: Sangeeta Yadav */
   @AuraEnabled
   public Static Boolean insuranceRequirement(String applicationId){
       Boolean medicalInsuranceReq = false; // Premium and tax will be non editable
       if(String.isNotBlank(applicationId)){
           Application__c app = [SELECT Id, Insurance_Medical_Test_Result__c, Insurance_Requirement__c FROM Application__c WHERE Id =: applicationId LIMIT 1];
           if(app != null){
               if(String.isNotBlank(app.Insurance_Requirement__c) && String.isNotBlank(app.Insurance_Medical_Test_Result__c)){
                   if(app.Insurance_Requirement__c == 'DOGH + MT' && app.Insurance_Medical_Test_Result__c == 'Rated Up'){
                       medicalInsuranceReq = true;//// Premium and tax will be editable
                   }
               }
           }
       }
       return medicalInsuranceReq;
   }    

    public class errorMessage{
        public cls_error error;
    }    
    public class cls_error {
		public String source;	//Portal
		public String target;	//Kotak
		public String errorCode;	//401
		public String message;	//Response Failed Due to IFundery Exception
		public String description;	//Error Occurred. Please try again later
		public String timestamp;	//2022-10-20 17:56:32+0000
	}
    public static errorMessage errorParse(String json){
		return (errorMessage) System.JSON.deserialize(json, errorMessage.class);
	}

    //Wrapper added to add FVM in fee name dropdown : 26-11-22
    public class feeValueWrapper {
        @AuraEnabled
        public String feeValueId;
        @AuraEnabled
        public String feeMasterId;
        @AuraEnabled
        public String feeMasterFeeCode;
        @AuraEnabled
        public Fee_Value_Master__c feeValue;
        @AuraEnabled
        public Fee_Type_Master__c feeTypeFromMaster;
    }

}