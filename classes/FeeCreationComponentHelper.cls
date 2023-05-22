/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Arnav Chaudhary 
* @modifiedBy       Arnav Chaudhary  
* @created          2022-07-15
* @modified         2022-07-15
* @Description      This class is useddisplay fee details related to application .
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class FeeCreationComponentHelper {
    //public static Decimal tax = 18;
    public static Decimal tax = decimal.valueOf(label.tax);
    /*
@Author : Arnav
@Description : This method is used to fetch fee value master records for given application id.
*/
    @AuraEnabled
    public static List<Fee_Creation__c> createFeeCreationRecords (String applicationId, String eventName, List<Property__c> properyAddedList) {
        List<Fee_Creation__c> createFeeCreationList = new List<Fee_Creation__c>();
        Map<String, Fee_Creation__c> createFeeCreationMap = new Map<String, Fee_Creation__c>();
        String trancheDisbursal = '';
        String appType = '';
        System.debug('applicationId   '+applicationId);
        if(String.IsNotBlank(applicationId)){
            //13 Jan 23:Ticket-1217: Tranche_Disbursal__c, Type__c
            List<Application__c> applicantAssetFromApplication = [select id, Stage__c, Tranche_Disbursal__c, Old_Application__c, Old_Application__r.Tranche_Disbursal__c, Type__c, (SELECT Id, Applicant_Name__c FROM Loan_Applicants__r), (SELECT Id, Name, Final_Land_Value__c FROM Properties__r WHERE RecordType.name = 'Pre Login Property Detail') from Application__c WHERE Id =:applicationId LIMIT 1];
            List<Loan_Applicant__c> loanApplicantsList = applicantAssetFromApplication[0].Loan_Applicants__r;
            System.debug('Loan Applicant' + loanApplicantsList);
            List<Property__c> propertyList = applicantAssetFromApplication[0].Properties__r;
            System.debug('Properties' + propertyList);
            trancheDisbursal = applicantAssetFromApplication[0].Tranche_Disbursal__c;
            if(applicantAssetFromApplication[0].Old_Application__c != null && String.isNotBlank(applicantAssetFromApplication[0].Old_Application__r.Tranche_Disbursal__c) ){
                if(applicantAssetFromApplication[0].Old_Application__r.Tranche_Disbursal__c == 'I'){
                    trancheDisbursal = 'II';
                }
            }
            //trancheDisbursal = applicantAssetFromApplication[0].Tranche_Disbursal__c;
            appType = applicantAssetFromApplication[0].Type__c;
            List<Fee_Value_Master__c> feeValueMasterList  = new List<Fee_Value_Master__c>(); 
            Map<String,Map<String, Decimal>> mapFeeAmount = new Map<String,Map<String, Decimal>>();
            if(String.IsNotBlank(eventName)){
                if(eventName == 'Application Login' && applicantAssetFromApplication[0].Stage__c == 'Login'){
                feeValueMasterList = [SELECT Id, Name, Fee_Type_Code__c, Fee_Type__c, Amount__c, Description__c, Fee_Type_Master__r.Stage_Due__c,Fee_Type_Master__r.Applicable_For__c, Fee_Type_Master__r.Modifiable_at_run_Time__c, Fee_Type_Master__r.Id, Fee_Type_Master__r.Repayment_of_Fee__c, Fee_Type_Master__r.Type__c, Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,
                Fee_Type_Master__r.Event__c, Fee_Type_Master__r.GL_Code__c, Fee_Type_Master__r.Tax__c, Fee_Type_Master__r.value__c, Fee_Type_Master__r.Waivable__c, Amount_Flat__c FROM Fee_Value_Master__c WHERE Fee_Type_Master__r.Active__c = 'Yes' AND Fee_Type__c = 'System' AND Fee_Type_Master__r.Type__c = 'Fee' AND Fee_Type_Master__r.Event__c =: eventName AND Active__c = 'yes'];
                
                
                mapFeeAmount = calculation(applicationId, propertyList, eventName);
                }
                else if(eventName != 'Application Login'){
                    if(eventName == 'Asset Entry'){
                        feeValueMasterList = [SELECT Id, Name, Fee_Type_Code__c, Fee_Type__c, Amount__c, Description__c, Fee_Type_Master__r.Stage_Due__c,Fee_Type_Master__r.Applicable_For__c, Fee_Type_Master__r.Modifiable_at_run_Time__c, Fee_Type_Master__r.Id, Fee_Type_Master__r.Repayment_of_Fee__c, Fee_Type_Master__r.Type__c, Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,
                        Fee_Type_Master__r.Event__c, Fee_Type_Master__r.GL_Code__c, Fee_Type_Master__r.Tax__c, Fee_Type_Master__r.value__c, Fee_Type_Master__r.Waivable__c, Amount_Flat__c FROM Fee_Value_Master__c WHERE Fee_Type_Master__r.Active__c = 'Yes' AND Fee_Type__c = 'System' AND Fee_Type_Master__r.Type__c = 'Fee' AND Fee_Type_Master__r.Event__c =: eventName AND Active__c = 'yes'];
                        if(feeValueMasterList != null && feeValueMasterList.size() >0){
                            List<Property__c> propList = new List<Property__c>();
                            if(properyAddedList != null && properyAddedList.size() > 0){
                                for(Property__c prop : properyAddedList){
                                    if(prop.Application__c != null && prop.Application__c == applicationId ){
                                        propList.add(prop);
                                    }
                                }
                            
                                propertyList = propList;
                           // propertyList = [SELECT Id, Name, Final_Land_Value__c FROM Property__c WHERE Id =: propertyId AND Application__c =: applicationId];
                            mapFeeAmount = calculation(applicationId, propList, eventName);
                            }
                        }
                        
                        
                        }
                     else if(eventName != 'Asset Entry'){
                    System.debug('Event Name' + eventName);
                    feeValueMasterList = [SELECT Id, Name, Fee_Type_Code__c, Fee_Type__c, Amount__c, Description__c, Fee_Type_Master__r.Stage_Due__c,Fee_Type_Master__r.Applicable_For__c, Fee_Type_Master__r.Modifiable_at_run_Time__c, Fee_Type_Master__r.Id, Fee_Type_Master__r.Repayment_of_Fee__c, Fee_Type_Master__r.Type__c, Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,
                Fee_Type_Master__r.Event__c, Fee_Type_Master__r.GL_Code__c, Fee_Type_Master__r.Tax__c, Fee_Type_Master__r.value__c, Fee_Type_Master__r.Waivable__c, Amount_Flat__c FROM Fee_Value_Master__c WHERE Fee_Type_Master__r.Active__c = 'Yes' AND Fee_Type__c = 'System' AND Fee_Type_Master__r.Type__c = 'Fee' AND Fee_Type_Master__r.Event__c =: eventName AND Active__c = 'yes'];
                
                
                mapFeeAmount = calculation(applicationId, propertyList, eventName);
                    }
                
                }
            }
            
            Map<String, Fee_Creation__c> existingFeeCreationMap = new Map<String, Fee_Creation__c>();
            if(eventName != 'Asset Entry'){
            for(Fee_Creation__c feeCreation : [SELECT Id,Application__c,Fee_Code__c, RecordType.DeveloperName FROM Fee_Creation__c WHERE Application__c = :applicationId AND RecordType.DeveloperName = 'Fee']) {
                if(feeCreation.Application__c != null && String.IsNotBlank(feeCreation.Fee_Code__c)) {
                    existingFeeCreationMap.put(feeCreation.Application__c + '-' +feeCreation.Fee_Code__c , feeCreation );
                }
            }
        }
        
            System.debug('EXISTING MAPPPPP   '+existingFeeCreationMap);
            //Map<String,Map<String, Decimal>> mapFeeAmount = new Map<String,Map<String, Decimal>>();
            //mapFeeAmount = calculation(applicationId, propertyList);
            System.debug('fee master calculation'+mapFeeAmount);
            if(!feeValueMasterList.isEmpty()) {
                for(Fee_Value_Master__c  feeValue : feeValueMasterList) {
                    //System.debug('VALUEEEEE   '+ existingFeeCreationMap.get(applicationId + '-' + feeValue.Fee_Type_Code__c));
                    System.debug('Type   '+ feeValue.Fee_Type__c);
                    System.debug('CODEEEEE   '+ feeValue.Fee_Type_Code__c);
                    /*@Description: For Ticket-1217: if IMD Fee and Application Tranch II Skip this fee
                      @Dated : 13 Jan 23 Description__c
                      Tranche_Disbursal__c = II, Type__c = Tranche loan
                    */
                    if(String.isNotBlank(trancheDisbursal) && trancheDisbursal == 'II' && String.isNotBlank(appType) && appType == 'Tranche loan' && feeValue.Description__c == 'IMD Fee' && feeValue.Fee_Type__c == 'System') {
                        Continue;
                    }
                    if((!existingFeeCreationMap.containsKey(applicationId + '-' + feeValue.Fee_Type_Code__c)) && feeValue.Fee_Type__c == 'System') {
                        if(feeValue.Fee_Type_Master__r.Applicable_For__c == 'Application'){
                        Fee_Creation__c feeCreation = new Fee_Creation__c();
                        feeCreation = createSystemFee(applicationId, feeValue, applicantAssetFromApplication[0].Stage__c) ;         
                        createFeeCreationList.add(feeCreation);
                        createFeeCreationMap.put(feeValue.Name, feeCreation);
                        }
                        if(feeValue.Fee_Type_Master__r.Applicable_For__c == 'Applicant'){
                            if(loanApplicantsList.size() > 0){
                            for(Loan_Applicant__c applicant : loanApplicantsList){
                                Fee_Creation__c feeCreation = new Fee_Creation__c();
                                
                                feeCreation = createSystemFee(applicationId, feeValue, applicantAssetFromApplication[0].Stage__c) ; 
                                feeCreation.Loan_Applicant__c = applicant.Id;        
                                createFeeCreationList.add(feeCreation);
                                createFeeCreationMap.put(feeValue.Name, feeCreation);
                            }
                        }
                        }
                        if(feeValue.Fee_Type_Master__r.Applicable_For__c == 'Asset' && feeValue.Fee_Type_Master__r.Value__c == 'Asset Cost'){

                            if(propertyList.size() > 0){
                            for(Property__c property : propertyList){
                                System.debug('propertyId  '+property.Id);
                                Fee_Creation__c feeCreation = new Fee_Creation__c();
                                
                                feeCreation = createSystemFee(applicationId, feeValue, applicantAssetFromApplication[0].Stage__c) ; 
                                feeCreation.Property__c = property.Id;        
                                createFeeCreationList.add(feeCreation);
                                createFeeCreationMap.put(feeValue.Name + property.Name, feeCreation);
                            }
                        }
                        }
                        else if(feeValue.Fee_Type_Master__r.Applicable_For__c == 'Asset' && feeValue.Fee_Type_Master__r.Value__c != 'Asset Cost'){

                            if(propertyList.size() > 0){
                            for(Property__c property : propertyList){
                                System.debug('propertyId  '+property.Id);
                                Fee_Creation__c feeCreation = new Fee_Creation__c();
                                
                                feeCreation = createSystemFee(applicationId, feeValue, applicantAssetFromApplication[0].Stage__c) ; 
                                feeCreation.Property__c = property.Id;        
                                createFeeCreationList.add(feeCreation);
                                createFeeCreationMap.put(feeValue.Name, feeCreation);
                            }
                        }
                        }
                    }
                }
                System.debug('SIZEEEEEEEEEEEE   CREATE LIST  '+ createFeeCreationList.Size());
                if(createFeeCreationList != null && createFeeCreationList.size() > 0 && createFeeCreationMap != null && createFeeCreationMap.size() > 0) {
                    // changes for calculation based on fee value master
                   /* for(Fee_Creation__c feeCreation : createFeeCreationList){
                        system.debug('amount return'+mapFeeAmount);
                        system.debug('get from map'+mapFeeAmount.get('feeAmount'));
                        if(!mapFeeAmount.isEmpty()){
                            feeCreation.Fee_Amount__c = mapFeeAmount.get(feeCreation.Fee_Code__c).get('feeAmount'). setscale(2);
                            feeCreation.Tax_Amount__c = mapFeeAmount.get(feeCreation.Fee_Code__c).get('taxAmount'). setscale(2);
                            feeCreation.Total_Fee__c = mapFeeAmount.get(feeCreation.Fee_Code__c).get('totalFee'). setscale(2);
                            //  feeCreation.Fee_Collection__c = mapFeeAmount.get('totalFee'). setscale(2); 
                            feeCreation.Fee_Collection__c = 0;                          
                        } 
                    }*/
                    for(String feeCreation : createFeeCreationMap.KeySet()){
                        system.debug('amount return'+mapFeeAmount);
                        system.debug('get from map'+mapFeeAmount.get('feeAmount'));
                        if(!mapFeeAmount.isEmpty() && mapFeeAmount.size() > 0){
                            if(mapFeeAmount.containsKey(feeCreation)){
                                if(mapFeeAmount.get(feeCreation).get('feeAmount') != null)
                            		createFeeCreationMap.get(feeCreation).Fee_Amount__c = mapFeeAmount.get(feeCreation).get('feeAmount').setscale(2);
                                if(mapFeeAmount.get(feeCreation).get('taxAmount') != null)
                            		createFeeCreationMap.get(feeCreation).Tax_Amount__c = mapFeeAmount.get(feeCreation).get('taxAmount').setscale(2);
                                if(mapFeeAmount.get(feeCreation).get('totalFee') != null)
                            		createFeeCreationMap.get(feeCreation).Total_Fee__c = Math.round(mapFeeAmount.get(feeCreation).get('totalFee').setscale(2));
                            //  feeCreation.Fee_Collection__c = mapFeeAmount.get('totalFee'). setscale(2); 
                            createFeeCreationMap.get(feeCreation).Fee_Collection__c = 0;  
                            }                        
                        } 
                    }
                    createFeeCreationList = createFeeCreationMap.values();
                    System.debug('createFeeCreationList'+createFeeCreationList);
                    createFeeCreationRecord( JSON.serialize(createFeeCreationList) );
                }
            }
        }
        return createFeeCreationList;
    }


    // To create multiple fee creation of master based on Application/Asset

    public static Fee_Creation__c createSystemFee(String applicationId, Fee_Value_Master__c feeValue, String stageName){
        Map<String,Decimal> mapFeeAmount = new Map<String,Decimal>();
        Fee_Creation__c feeCreation = new Fee_Creation__c();
                        feeCreation.Application__c = applicationId;
                        feeCreation.Fee_Code__c = feeValue.Fee_Type_Code__c;
                        feeCreation.Type__c = feeValue.Fee_Type__c;
                        feeCreation.Description__c = feeValue.Description__c;
                        feeCreation.Stage_Due__c = stageName;
                        feeCreation.Stage__c = feeValue.Fee_Type_Master__r.Stage_Due__c;
                        //Fee_Value_Master__c added on 22-11-22 (while dropdown on fee name in from fee value description)
                        feeCreation.Fee_Value_Master__c = feeValue.Id;
                        if(String.IsNotBlank(feeValue.Fee_Type_Master__r.Repayment_of_Fee__c)){
                            if(feeValue.Fee_Type_Master__r.Repayment_of_Fee__c.contains(';')){
                            feeCreation.Repayment_Type_2__c = 'Deduct from Disbursement';
                            }else{
                            feeCreation.Repayment_Type_2__c = feeValue.Fee_Type_Master__r.Repayment_of_Fee__c;
                            }
                        }
                        System.debug('feeCreation.Repayment_Type_2__c' + feeCreation.Repayment_Type_2__c);
                        //feeCreation.Repayment_Type_2__c = 'Deduct from Disbursement';
                        //feeCreation.Repayment_Type_2__c = feeValue.Fee_Type_Master__r.Repayment_of_Fee__c;
                        feeCreation.Fee_Type_Master__c = feeValue.Fee_Type_Master__r.Id;
                        feeCreation.Amount__c = feeValue.Fee_Type_Master__r.Amount__c;
                        feeCreation.Calculation_Basis__c = feeValue.Fee_Type_Master__r.Calculation_Basis__c;
                        feeCreation.Event__c = feeValue.Fee_Type_Master__r.Event__c;
                        feeCreation.GL_Code__c = feeValue.Fee_Type_Master__r.GL_Code__c;
                        feeCreation.Tax__c = feeValue.Fee_Type_Master__r.Tax__c;
                        feeCreation.Value__c = feeValue.Fee_Type_Master__r.Value__c;
                        feeCreation.Waivable__c = feeValue.Fee_Type_Master__r.Waivable__c;
                        feeCreation.Receipt_Created__c = false;
                        //Added for seperate field on FVM for Amount and % Amount: 25 Nov 22

                        if(feeCreation.Amount__c == 'Amount'){
                            feeCreation.Fee_Value_Amount__c = feeValue.Amount_Flat__c;
                        }
                        if(feeCreation.Amount__c == 'Percentage'){
                            feeCreation.Amount_Percentage__c = feeValue.Amount__c;
                        }
                        //feeCreation.Amount_Percentage__c = feeValue.Amount__c;
                        feeCreation.Fee_Amount__c = 0;
                        feeCreation.Applicable_For__c = feeValue.Fee_Type_Master__r.Applicable_For__c;
                        /*      if(String.IsNotBlank(feeValue.Fee_Type_Master__r.Repayment_of_Fee__c)){
if(feeValue.Fee_Type_Master__r.Repayment_of_Fee__c.contains(';')){
feeCreation.Repayment_Type_2__c = feeValue.Fee_Type_Master__r.Repayment_of_Fee__c.split(';')[0];
}else{
feeCreation.Repayment_Type_2__c = feeValue.Fee_Type_Master__r.Repayment_of_Fee__c;
}
}*/
                        feeCreation.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByDeveloperName().get('Fee').getRecordTypeId();
                        
                      /*  if(feeCreation.Fee_Code__c == 'Cersai'){
                            feeCreation.Applicable_on_Loan_Amount_Asset_Value__c = 'Loan Amount';
                        }else if(feeCreation.Fee_Code__c == 'Technical'){
                            feeCreation.Applicable_on_Loan_Amount_Asset_Value__c = 'EMI';
                        }else if(feeCreation.Fee_Code__c == 'LegaL'){
                            feeCreation.Applicable_on_Loan_Amount_Asset_Value__c = 'Asset Value';
                        }else if(feeCreation.Fee_Code__c == 'IMD'){
                            feeCreation.Applicable_on_Loan_Amount_Asset_Value__c = 'Asset Value';
                        }else if(feeCreation.Fee_Code__c == 'PRC_FEE_Type'){
                            feeCreation.Applicable_on_Loan_Amount_Asset_Value__c = 'EMI';
                        }*/
                        //@Sangeeta
                  //For multiple fee      
                  /*     // mapFeeAmount = calculation(applicationId);
                        system.debug('amount return'+mapFeeAmount);
                        system.debug('get from map'+mapFeeAmount.get('feeAmount'));
                        if(!mapFeeAmount.isEmpty()){
                            feeCreation.Fee_Amount__c = mapFeeAmount.get('feeAmount'). setscale(2);
                            feeCreation.Tax_Amount__c = mapFeeAmount.get('taxAmount'). setscale(2);
                            feeCreation.Total_Fee__c = mapFeeAmount.get('totalFee'). setscale(2);
                            //  feeCreation.Fee_Collection__c = mapFeeAmount.get('totalFee'). setscale(2); 
                            feeCreation.Fee_Collection__c = 0;                          
                        } */
                       return feeCreation;    
    }
    
    /*
@Author : Arnav
@Description : This method is used to create fee Creation records for given application id.
*/
    @AuraEnabled
    
    public static void createFeeCreationRecord (String feeCreation)  {
        System.debug('YESSSSSSSSSS   '+feeCreation);
        if(String.isNotBlank(feeCreation)){
            List<Fee_Creation__c> feeCreationList = (List<Fee_Creation__c>)JSON.deserialize(feeCreation,List<Fee_Creation__c>.class);
            System.debug('VVVVVVVVVVVv ' +feeCreationList);
            Insert feeCreationList;
        }
    }
    
    /*
@Author : Arnav
@Description : This method is used to get existing fee Creation records for given application id.
*/
    @AuraEnabled
    public static String getFeeCreationRecords (String applicationId) {
        System.debug('GET CALLED   '+applicationId);
        List<FeeCreationWrapper> createFeeWrapperList = new List<FeeCreationWrapper>();
        //list added by sangeeta to update system generated records
        List<String> systemFeeCreationId = new List<String>();
        if(String.isNotBlank(applicationId)){
            List<Fee_Creation__c> feeCreationList = [Select Id,Application__c,Fee_Code__c,Type__c,Fee_Type_Master__r.Modifiable_at_run_Time__c,
                                                     Description__c,Stage_Due__c,Repayment_Type_2__c,Fee_Amount__c, Tax_Amount__c,Total_Fee__c, Applicable_For__c, Loan_Applicant__r.Applicant_Name__c, Property__r.Name,
                                                     Loan_Applicant__c, Property__c,Stage__c, Fee_Type_Master__r.Tax__c, Fee_Value_Master__c, Tax__c,
                                                     Fee_Collection__c, Fee_Collected__c, Receipt_Created__c FROM Fee_Creation__c WHERE Application__c =: applicationId AND RecordType.DeveloperName = 'Fee' Order BY Id];
            System.debug('feeCreationList  '+feeCreationList);
            Integer totalRecords = 0;
            List<String> feeCrea = new List<String>();
            Map<String,Decimal> mapFeeAmount = new Map<String,Decimal>();
            Map<String, List<String>> repaymentListMasterBased = new Map<String, List<String>>();
            if(!feeCreationList.isEmpty()) {
                Integer count = 1;
                totalRecords  = feeCreationList.size();
                repaymentListMasterBased =  repaymentTypeFromMaster('Fee');
                for(Fee_Creation__c feeCreationObj : feeCreationList ) {
                    /*@ Changes done by Sangeeta for calculation*/
                    /* @Method call for calculation based on fee code in fee creation*/              
                    
                    FeeCreationWrapper wrapper = new FeeCreationWrapper();
                    wrapper.Id = feeCreationObj.Id;
                    wrapper.sRNumnber = count;
                    wrapper.feeCode = feeCreationObj.Fee_Code__c;
                    wrapper.type = feeCreationObj.Type__c;
                    wrapper.description = feeCreationObj.Description__c;
                    wrapper.masterId = feeCreationObj.Fee_Value_Master__c;
                    wrapper.stageDue = feeCreationObj.Stage_Due__c;
                    wrapper.stage = feeCreationObj.Stage__c;
                    wrapper.applicableFor = feeCreationObj.Applicable_For__c;
                    if(wrapper.applicableFor == 'Application'){
                        wrapper.isApplication = true;
                        wrapper.isApplicant = false;
                        wrapper.isAsset = false;
                        wrapper.applicantAssetId = null;
                    }
                    else if(wrapper.applicableFor == 'Applicant'){
                        if(feeCreationObj.Loan_Applicant__c != null){
                            wrapper.loanApplicant = feeCreationObj.Loan_Applicant__r.Applicant_Name__c;
                            wrapper.applicantAssetId = feeCreationObj.Loan_Applicant__c;
                            wrapper.isApplicant = true;
                            wrapper.isApplication = false;
                            wrapper.isAsset = false;
                           }
                        else if(feeCreationObj.Loan_Applicant__c == null){
                            wrapper.isApplicant = true;
                            wrapper.isApplication = false;
                            wrapper.isAsset = false;
                            wrapper.applicantAssetId = null;
                        }
                    }
                    else if(wrapper.applicableFor == 'Asset'){
                        if(feeCreationObj.Property__c != null){
                            wrapper.property = feeCreationObj.Property__r.Name;
                            wrapper.applicantAssetId = feeCreationObj.Property__c;
                            wrapper.isAsset = true;
                            wrapper.isApplication = false;
                            wrapper.isApplicant = false;
                        }
                        else if(feeCreationObj.Property__c == null){
                            wrapper.isAsset = true;
                            wrapper.isApplication = false;
                            wrapper.isApplicant = false;
                            wrapper.applicantAssetId = null;
                        }
                        
                        
                    }
                    
                    

                    //if receipt for fee is submitted or approved make non editable repayment type until receipt is rejected
                    if(feeCreationObj.Receipt_Created__c == true || feeCreationObj.Fee_Collected__c == true){
                    //Disable repayment if receipt is approved
                    //if(feeCreationObj.Fee_Collected__c == true){
                        wrapper.isFeeCollected = true;
                    }
                    else{
                        wrapper.isFeeCollected = false;
                    }
                    //wrapper.isFeeCollected = feeCreationObj.Fee_Collected__c;
                    wrapper.repaymentDetail = new List<RepaymentDetailWrapper>();
                    
                  /*  List<String> repaymentList = new List<String>();
                    if(String.IsNotBlank(feeCreationObj.Repayment_Type_2__c)){
                        if(feeCreationObj.Repayment_Type_2__c.contains(';')){
                            repaymentList = feeCreationObj.Repayment_Type_2__c.split(';');
                        }else{
                            repaymentList.add(feeCreationObj.Repayment_Type_2__c);
                        }
                    }*/
                    if(repaymentListMasterBased.keySet().contains(feeCreationObj.Fee_Code__c)){
                        List<String> repaymentValue = repaymentListMasterBased.get(feeCreationObj.Fee_Code__c);
                        if(repaymentValue != null && repaymentValue.size() > 0){
                            for(String repayment : repaymentValue){
                                RepaymentDetailWrapper repDetail = new RepaymentDetailWrapper();
                                repDetail.label = repayment;
                                repDetail.value = repayment;
                                wrapper.repaymentDetail.add(repDetail);
                            }

                            //Validation for if Repayment value from master is removed for which fee was created.: 30 Nov 22
                            System.debug('Repayment list from master'+ repaymentValue);
                            wrapper.feeRepayment = feeCreationObj.Repayment_Type_2__c;
                            if(String.isNotBlank(feeCreationObj.Repayment_Type_2__c)){
                                System.debug('Repayment value from fee'+ feeCreationObj.Repayment_Type_2__c);
                                if(repaymentValue.contains(feeCreationObj.Repayment_Type_2__c)){
                                    wrapper.repaymentFromMaster = true;
                                }
                                else{
                                    System.debug('not available in master');
                                    wrapper.repaymentFromMaster = false;
                                    
                                    RepaymentDetailWrapper repDetail = new RepaymentDetailWrapper();
                                    repDetail.label = feeCreationObj.Repayment_Type_2__c;
                                    //repDetail.value = 'Not From Master';
                                    repDetail.value = feeCreationObj.Repayment_Type_2__c;
                                    wrapper.repaymentDetail.add(repDetail);

                                }
                            }
                        }
                    }
                    wrapper.repaymentType = feeCreationObj.Repayment_Type_2__c;
                    System.debug('wrapper.repaymentDetail' + wrapper.repaymentDetail + wrapper.feeCode);
                    wrapper.feeAmount = feeCreationObj.Fee_Amount__c;
                    wrapper.taxAmount = feeCreationObj.Tax_Amount__c;
                    wrapper.totalFee = feeCreationObj.Total_Fee__c;
                            //  wrapper.feeCollection = mapFeeAmount.get('totalFee'). setscale(2);
                            //done by sangeeta if master records created first time and amounts not updated
                            if(feeCreationObj.Fee_Collection__c == null ){
                                feeCreationObj.Fee_Amount__c = wrapper.feeAmount;
                                //   feeCreationObj.Fee_Collection__c = wrapper.feeCollection;
                                feeCreationObj.Fee_Collection__c = 0;
                                systemFeeCreationId.add(feeCreationObj.Id);
                            }
                            else{
                                wrapper.feeCollection = feeCreationObj.Fee_Collection__c;
                            }
                            
                        
                                        
                   // wrapper.applicableOn = feeCreationObj.Applicable_on_Loan_Amount_Asset_Value__c;
                    wrapper.totalRecord = feeCreationList.size();
                    if(count == totalRecords) {
                        wrapper.buttonFlag =  true;
                    }
                    if(feeCreationList.size() == count){
                        wrapper.showAdd = true;
                    }else{
                        wrapper.showAdd = false;
                    }

                    //if tax in fee is No then total fee will be editable: 12 Dec 22
                    wrapper.tax = feeCreationObj.Tax__c;
                   // if(feeCreationObj.Fee_Type_Master__r.Modifiable_at_run_Time__c == 'Yes' && feeCreationObj.Type__c == 'User'){
                    //Modifiable for run time for both system and user fee as discussed with anand on 19-11-22
                    if(feeCreationObj.Fee_Type_Master__r.Modifiable_at_run_Time__c == 'Yes'){
                        wrapper.modifiable = true;
                        //Added to make fee amount or total fee editable based on tax inclusive/exclusive in FTM: 22-11-22
                        if(String.isNotBlank(feeCreationObj.Fee_Type_Master__r.Tax__c) ){
                            //if(feeCreationObj.Fee_Type_Master__r.Tax__c == 'Inclusive'){
                                //for fee should not changed after save based on master : 25/11/22
                            if(feeCreationObj.Tax__c == 'Inclusive'){
                                wrapper.totalFeeModify = true;
                                wrapper.feeAmountModify = false;
                            }
                            //else if(feeCreationObj.Fee_Type_Master__r.Tax__c == 'Exclusive'){
                            //for fee should not changed after save based on master : 25/11/22
                            else if(feeCreationObj.Tax__c == 'Exclusive'){
                                wrapper.totalFeeModify = false;
                                wrapper.feeAmountModify = true;
                            }
                            else if(feeCreationObj.Tax__c == 'No'){
                                wrapper.totalFeeModify = true;
                                wrapper.feeAmountModify = false;
                            }
                            else {
                                wrapper.totalFeeModify = false;
                                wrapper.feeAmountModify = false;
                            }

                        }
                        else{
                            wrapper.totalFeeModify = false;
                            wrapper.feeAmountModify = false;
                        }
                        
                    }
                    else {
                        wrapper.modifiable = false;
                        wrapper.totalFeeModify = false;
                        wrapper.feeAmountModify = false;
                    }
                    count += 1;
                    createFeeWrapperList.add(wrapper);
                }
            }
        }
        if(systemFeeCreationId.size() >0){
            updateMasterRecords(systemFeeCreationId);
        }
        return JSON.serialize(createFeeWrapperList);
    }
    public static void updateMasterRecords(List<String> idList){
        List<Fee_Creation__c> feeCreationList = [Select Id,Application__c,Fee_Code__c,Type__c,
                                                 Description__c,Stage_Due__c,Repayment_Type_2__c,Fee_Amount__c, Tax_Amount__c,Total_Fee__c, 
                                                 Fee_Collection__c FROM Fee_Creation__c WHERE Application__c IN :idList AND RecordType.DeveloperName = 'Fee' Order BY Id];
        if(feeCreationList.size()>0){
            update feeCreationList;
        }
    }
    
    /*
@Author : Arnav
@Description : This method is used to add a new row.
*/
    @AuraEnabled(cacheable = true)
    public static String addRow(String wrapperData, String typeOf, String valuesOf, String stageName) {
        System.debug('Value#####' + valuesOf + stageName);
        System.debug('YES CALL APEXXX   '+wrapperData);
        List<FeeCreationWrapper> wrapperFeeCreationList = (List<FeeCreationWrapper>)JSON.deserialize(wrapperData,List<FeeCreationWrapper>.class);
        //System.debug('size of list ######' + wrapperFeeCreationList.size() + wrapperFeeCreationList[0].Id);
        integer sizeOfList = wrapperFeeCreationList.size();
        System.debug('dsadsad  '+ wrapperFeeCreationList);
        if(typeOf == 'add'){
            for(integer i =0;i<wrapperFeeCreationList.size();i++){
                wrapperFeeCreationList[i].showAdd = false;
            }
            FeeCreationWrapper wrapperObj = new FeeCreationWrapper();
            wrapperObj.type = 'User';
            wrapperObj.isnewRow = true;
            wrapperObj.sRNumnber = wrapperFeeCreationList.size() + 1;
            wrapperObj.showAdd = true; 
            wrapperObj.applicableFor = '';
            wrapperObj.loanApplicant = '';
            wrapperObj.applicantAssetId = null;
            wrapperObj.property = '';
            wrapperObj.isApplicant = false;
            wrapperObj.isApplication = false;
            wrapperObj.isAsset = false;
            wrapperObj.masterId = '';
            wrapperObj.description = '';
            wrapperObj.modifiable = false;
            wrapperObj.feeAmountModify = false;
            wrapperObj.totalFeeModify = false;
            if(stageName != null || stageName != ''){
                wrapperObj.stageDue = stageName;
            } 
            else{
                wrapperObj.stageDue = 'Pre Login';
            }
            wrapperObj.stage = '';
            //wrapperObj.repaymentType = 'Deduct from Disbursement';
            wrapperObj.feeAmount = 0;
            wrapperObj.taxAmount = 0;
            wrapperObj.totalFee = 0;
            wrapperObj.feeCollection = 0;
            wrapperFeeCreationList.add(wrapperObj);
            system.debug('Size after add #####'+wrapperFeeCreationList.size());
            return JSON.serialize(wrapperFeeCreationList); 
        }  
        else {
            System.debug('remove' + typeOf);
            for(integer x = 0 ; x<wrapperFeeCreationList.size();x++){
                
                if(wrapperFeeCreationList[x].sRNumnber == Integer.valueOf(valuesOf)){
                    wrapperFeeCreationList.remove(x);
                    if(wrapperFeeCreationList != null && wrapperFeeCreationList.size() > 0){
                    for(integer i =0;i<wrapperFeeCreationList.size();i++){
                        wrapperFeeCreationList[i].sRNumnber = i+1;
                        if(wrapperFeeCreationList.size() == i+1){ 
                            wrapperFeeCreationList[i].showAdd = true;
                        }
                    }
                }
                }
                
            }
            return JSON.serialize(wrapperFeeCreationList);
        }  
    }
    
    /*
@Author : Arnav
@Description : This method is used to Save a new Fee_Creation__c record.
*/
    @AuraEnabled
    public static void saveRecords(String wrapperData, String applicationId) {
        System.debug('YES CALL APEXXX   ' + wrapperData + applicationId);
        try {
            List<Fee_Creation__c> updateFeeCreationList = new List<Fee_Creation__c>();
            List<FeeCreationWrapper> wrapperFeeCreationList = (List<FeeCreationWrapper>)JSON.deserialize(wrapperData,List<FeeCreationWrapper>.class);
            System.debug('SIZE    ' +wrapperFeeCreationList.size());
            System.debug('DATAAAAAAA   '+wrapperFeeCreationList);
            List<String> wrapFeeCode = new List<String>();
            //Added on 24/11/22 for FVM logic
            Set<String> valueMasterIdSet = new Set<String>();
            for(FeeCreationWrapper wrapper : wrapperFeeCreationList) {
                if(wrapper.type == 'User'){
                    wrapFeeCode.add(wrapper.feeCode);
                    valueMasterIdSet.add(wrapper.masterId);
                }
            }
            Map<String, String> masterWithFee = new Map<String, String>();

            List<Fee_Type_Master__C> feeMasterCode = [SELECT Id, Fee_Type_Code__c FROM Fee_Type_Master__c 
                                                      WHERE Fee_Type__c = 'User' AND Type__c ='Fee' AND Active__c = 'Yes' 
                                                      AND Fee_Type_Code__c IN :wrapFeeCode];

            //Query for FVM : 24/11/22
            
            List<Fee_Value_Master__C> feeValueMasterCode = [SELECT Id, Name, Fee_Type_Code__c, Amount__c, Cap__c, Floor__c, Description__c, Fee_Type_Master__r.GL_Code__c, Amount_Flat__c,
                                                    Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,Fee_Type_Master__r.Fee_Type__c,Fee_Type_Master__r.Waivable__c,
                                                    Fee_Type_Master__r.Tax__c,Fee_Type_Master__r.Value__c,Fee_Type_Master__r.Type__c,Fee_Type_Master__r.Event__c,Fee_Type_Master__r.Applicable_For__c  
                                                    FROM Fee_Value_Master__c WHERE Fee_Type_Master__r.Fee_Type__c = 'User' AND Fee_Type_Master__r.Type__c = 'Fee'
                                                    AND Fee_Type_Master__r.Active__c = 'Yes' AND Active__c = 'yes'];

            Map<String, Fee_Value_Master__c> masterValueIdMap = new Map<String, Fee_Value_Master__c>();
            for(Fee_Value_Master__c feeValueMaster : feeValueMasterCode){
                masterValueIdMap.put(feeValueMaster.Id, feeValueMaster);
            }
            
            for(Fee_Type_Master__c feeMaster : feeMasterCode){
                masterWithFee.put(feeMaster.Fee_Type_Code__c, feeMaster.Id);
            }
            for(FeeCreationWrapper wrapper : wrapperFeeCreationList) {
                Fee_Creation__c feeObj = new Fee_Creation__c();
                if(wrapper.Id != null && String.isNotBlank(wrapper.Id) ) {
                    feeObj.Id = wrapper.Id;
                }
                //feeObj.Applicable_on_Loan_Amount_Asset_Value__c = wrapper.applicableOn;
                //feeObj.Description__c = wrapper.description;
                
                feeObj.Fee_Amount__c = wrapper.feeAmount;
                feeObj.Fee_Code__c = wrapper.feeCode;
                feeObj.Fee_Collection__c = wrapper.feeCollection;
                feeObj.Applicable_For__c = wrapper.applicableFor;
                feeObj.Fee_value_Master__c = wrapper.masterId;
                if(masterValueIdMap != null && masterValueIdMap.size() > 0 && masterValueIdMap.containsKey(feeObj.Fee_value_Master__c)){
                    Fee_Value_Master__c feeValueForFee = masterValueIdMap.get(feeObj.Fee_value_Master__c);
                    //to map fields from master to manual fee : 24-11-22
                    feeObj.Description__c = feeValueForFee.Description__c;
                    feeObj.Amount__c = feeValueForFee.Fee_Type_Master__r.Amount__c;
                    feeObj.Calculation_Basis__c = feeValueForFee.Fee_Type_Master__r.Calculation_Basis__c;
                    feeObj.Event__c = feeValueForFee.Fee_Type_Master__r.Event__c;
                    feeObj.GL_Code__c = feeValueForFee.Fee_Type_Master__r.GL_Code__c;
                    feeObj.Tax__c = feeValueForFee.Fee_Type_Master__r.Tax__c;
                    feeObj.Value__c = feeValueForFee.Fee_Type_Master__r.Value__c;
                    feeObj.Waivable__c = feeValueForFee.Fee_Type_Master__r.Waivable__c;
                    //feeObj.Receipt_Created__c = false;

                    //for amount and %amount of FVM
                    if(feeObj.Amount__c == 'Amount'){
                        feeObj.Fee_Value_Amount__c = feeValueForFee.Amount_Flat__c;
                    }
                    else if(feeObj.Amount__c == 'Percentage'){
                        feeObj.Amount_Percentage__c = feeValueForFee.Amount__c;
                    }
                   // feeObj.Amount_Percentage__c = feeValueForFee.Amount__c;
                    //feeObj.Fee_Amount__c = 0;
                    feeObj.Applicable_For__c = feeValueForFee.Fee_Type_Master__r.Applicable_For__c;
                    //----------------------------------------------------------------------
                }
                if(wrapper.applicantAssetId != null){
                    if(feeObj.Applicable_For__c == 'Applicant'){
                        feeObj.Loan_Applicant__c = wrapper.applicantAssetId;
                    }
                    else if(feeObj.Applicable_For__c == 'Asset'){
                        feeObj.Property__c = wrapper.applicantAssetId;
                    }
                }
                System.debug('feeObj.Repayment_Type_2__c'+wrapper.repaymentType + feeObj.Fee_Code__c);
                feeObj.Repayment_Type_2__c =  wrapper.repaymentType;
                feeObj.Stage_Due__c = wrapper.stageDue;
                feeObj.Stage__c = wrapper.stage;
                feeObj.Total_Fee__c = wrapper.totalFee;
                feeObj.Type__c = wrapper.type;
                feeObj.Tax_Amount__c = wrapper.taxAmount;
                feeObj.Application__c = applicationId;
                if(masterWithFee.containsKey(feeObj.Fee_Code__c)){
                    system.debug('fee master add'+feeObj.Fee_Code__c);
                    feeObj.Fee_Type_Master__c = masterWithFee.get(feeObj.Fee_Code__c);
                }
                
                updateFeeCreationList.add(feeObj);
            }
            if(!updateFeeCreationList.isEmpty()) {
                upsert updateFeeCreationList;
            }
        }
        catch(Exception e) {
            System.debug('ERROR     '+e.getMessage() + ' Line   ' + e.getLineNumber());
        }
    }

    /* @Method for calculation
@Author Sangeeta */ 
    public static Map<String,Map<String, Decimal>> calculation(String applicationId, List<Property__c> propertyList, String eventName){
        Decimal feeAmount;
        Decimal totalFee;
        Decimal taxAmount;
        Decimal percentageAmount;
        Decimal loanAmount;
       // Map<String, Decimal> mapAmountToFee = new Map<String, Decimal>();
        Map<String,Map<String, Decimal>> mapOfFeeWithAmount = new Map<String,Map<String, Decimal>>();
        try{  
            //AND Fee_Type_Master__r.Value__c = 'Loan Amount' removed from this query for all values
           /* List<Fee_Value_Master__c> feeValueMasterList = [SELECT Id,Fee_Type_Code__c, Amount__c, Cap__c, Floor__c, 
                                                            Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,
                                                            Fee_Type_Master__r.Tax__c,Fee_Type_Master__r.Value__c,Fee_Type_Master__r.Type__c,Fee_Type_Master__r.Event__c,Fee_Type_Master__r.Applicable_For__c  
                                                            FROM Fee_Value_Master__c WHERE Fee_Type_Code__c = :feeCode AND Fee_Type_Master__r.Stage_Due__c = 'Pre Login' AND Fee_Type_Master__r.Type__c = 'Fee'
                                                            AND Fee_Type_Master__r.Event__c = 'Application Login' LIMIT 1];*/
            
            //for multiple fee
            List<Fee_Value_Master__c> feeValueMasterList = [SELECT Id, Name, Fee_Type_Code__c, Amount__c, Cap__c, Floor__c, Amount_Flat__c,
                                                            Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,Fee_Type_Master__r.Fee_Type__c,
                                                            Fee_Type_Master__r.Tax__c,Fee_Type_Master__r.Value__c,Fee_Type_Master__r.Type__c,Fee_Type_Master__r.Event__c,Fee_Type_Master__r.Applicable_For__c  
                                                            FROM Fee_Value_Master__c WHERE Fee_Type_Master__r.Fee_Type__c = 'System' AND Fee_Type_Master__r.Type__c = 'Fee'
                                                            AND Fee_Type_Master__r.Event__c =: eventName AND Fee_Type_Master__r.Active__c = 'Yes' AND Active__c = 'yes'];
            List<Range_Value_Master__c> rangeValues = [SELECT Id, To__c, From__c, Value__c FROM Range_Value_Master__c];
            //  System.debug('feeValueMasterList'+feeValueMasterList+feeValueMasterList[0].Fee_Type_Master__r.Amount__c + feeValueMasterList[0].Fee_Type_Master__r.Value__c);
           // System.debug(feeValueMasterList[0].Fee_Type_Master__r.Calculation_Basis__c +feeValueMasterList[0].Fee_Type_Master__r.Tax__c);
            Application__c appRecord = [SELECT Id, Requested_Loan_Amount__c, Loan_Amount__c, Mortgage_property_Collateral_Value__c, Total_Amount_Recommended_PcAc__c, Emi_PcAc__c FROM Application__c WHERE Id =:applicationId];
            Decimal requestedAmount;
            //to calculate for all fee type master of fee type system
            if(feeValueMasterList <> null && feeValueMasterList.size() > 0 ){
            for(Fee_Value_Master__c feeValueMaster :feeValueMasterList){
                System.debug('Fee value master fee code is'+feeValueMaster.Fee_Type_Code__c);
                Map<String, Decimal> mapAmountToFee = new Map<String, Decimal>();
            if(feeValueMaster.Fee_Type_Master__r.Value__c == 'Loan Amount'){
                //if(appRecord.Loan_Amount__c != null){
                // Changes to use Recommended loan amount 
                if(appRecord.Total_Amount_Recommended_PcAc__c != null){
                    System.debug('Loan Amount'+ appRecord.Total_Amount_Recommended_PcAc__c);
                    //requestedAmount = appRecord.Loan_Amount__c;
                    requestedAmount = appRecord.Total_Amount_Recommended_PcAc__c;
                }
                else{
                    requestedAmount = 0;
                }
                mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
            }
            if(feeValueMaster.Fee_Type_Master__r.Value__c == 'Installment Amount'){
                // Installment amount is not defined in application
                System.debug('Installment Amount'+ appRecord.Emi_PcAc__c);
                // changes done to use Emi_PcAc__c for calculation
                //if(appRecord.Requested_Loan_Amount__c != null){
                    if(appRecord.Emi_PcAc__c != null){
                    System.debug('Requested_Loan_Amount__c'+ appRecord.Emi_PcAc__c);
                    requestedAmount = appRecord.Emi_PcAc__c;
                }
                else{
                    requestedAmount = 0;
                }
                mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
            }
            if(feeValueMaster.Fee_Type_Master__r.Value__c == 'Asset Cost'){
                // Asset Cost is not defined in application
                //chganges done to use Mortgage_property_Collateral_Value__c in calcuylation based on applicable for is asset or application//
                System.debug('Asset Cost'+ appRecord.Mortgage_property_Collateral_Value__c);
                //if(appRecord.Requested_Loan_Amount__c != null){
                if(feeValueMaster.Fee_Type_Master__r.Applicable_For__c == 'Application'){
                    System.debug('Applicable for' + feeValueMaster.Fee_Type_Master__r.Applicable_For__c);
                    if(appRecord.Mortgage_property_Collateral_Value__c != null){
                        System.debug('Requested_Loan_Amount__c'+ appRecord.Mortgage_property_Collateral_Value__c);
                        requestedAmount = appRecord.Mortgage_property_Collateral_Value__c;
                    }
                    else{
                        requestedAmount = 0;
                    }
                    mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                    mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
                }
                else if(feeValueMaster.Fee_Type_Master__r.Applicable_For__c == 'Asset'){
                    System.debug('Applicable for' + feeValueMaster.Fee_Type_Master__r.Applicable_For__c );
                    System.debug('Requested_Loan_Amount__c'+ appRecord.Mortgage_property_Collateral_Value__c);
                    if(propertyList!= null && propertyList.size() > 0){
                        for(Property__c prop : propertyList){
                            System.debug('prop name'+ prop.Name);
                            if(prop.Final_Land_Value__c != null){
                                requestedAmount = prop.Final_Land_Value__c;
                            }
                            else{
                                requestedAmount = 0;
                            }
                            mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                            //mapAmountToFee.put('Property', prop.Name);
                            mapOfFeeWithAmount.put(feeValueMaster.Name + prop.Name, mapAmountToFee); 
                        }
                    }
                    
                }
                else if(feeValueMaster.Fee_Type_Master__r.Applicable_For__c == 'Applicant'){
                    System.debug('Applicable for' + feeValueMaster.Fee_Type_Master__r.Applicable_For__c);
                    requestedAmount = 0;
                    mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                    mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
                }
            } 
           // mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
           // mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
            System.debug('fee and calculation'+ feeValueMaster.Fee_Type_Code__c + mapAmountToFee + 'mapOfFeeWithAmount'+mapOfFeeWithAmount);
           
            }
            }
            if(mapOfFeeWithAmount.size() > 0){
                for(String fee : mapOfFeeWithAmount.KeySet()){
                    System.debug('FeeCode'+fee);
            		System.debug('mapOfFeeWithAmount'+mapOfFeeWithAmount.get(fee)+fee);
                }
            }
         //   System.debug('mapAmountToFee'+mapAmountToFee);
        }
        catch(exception e){
            System.debug('Message: ' + e.getMessage() + e.getLineNumber()); 
        }
        return mapOfFeeWithAmount;
        
    }

    public static Map<String, Decimal> feeCalculation(Fee_value_Master__c feeValueMaster, List<Range_Value_Master__c> rangeValues, Application__c appRecord, Decimal requestedAmount){
        // if(feeValueMasterList <> null && feeValueMasterList.size() > 0 ){
                // removed from below if for range feeValueMasterList[0].Fee_Type_Master__r.Calculation_Basis__c == 'Flat' && 
        Decimal feeAmount;
        Decimal totalFee;
        Decimal taxAmount;
        Decimal percentageAmount;
        Decimal loanAmount;
                
        Map<String, Decimal> mapAmountToFee = new Map<String, Decimal>();
            if(feeValueMaster.Fee_Type_Master__r.Tax__c == 'Inclusive'){
                    // System.debug('feeValueMasterList'+feeValueMasterList+feeValueMasterList[0].Fee_Type_Master__r.Amount__c);
                     if(feeValueMaster.Fee_Type_Master__r.Amount__c == 'Amount'){
                         //totalFee = feeValueMaster.Amount__c; // total fee amount for fee creation for 18% tax 
                         //for Amount and %Amount : 25/11/22
                         totalFee = feeValueMaster.Amount_Flat__c;
                         system.debug(totalFee);
                         mapAmountToFee.put('totalFee',totalFee);
                         feeAmount = totalFee/1.18;//fee amount without tax for fee collection
                         system.debug('feeamount'+feeAmount);
                         mapAmountToFee.put('feeAmount',feeAmount);
                         taxAmount = totalFee - feeAmount;//Tax_Amount__c in fee creation
                         system.debug('tax amount'+ taxAmount);
                         mapAmountToFee.put('taxAmount',taxAmount);
                         System.debug('map of amount'+mapAmountToFee);
                     }
                 }
                 //feeValueMasterList[0].Fee_Type_Master__r.Calculation_Basis__c == 'Flat' && from below if for range
                 else if(feeValueMaster.Fee_Type_Master__r.Tax__c == 'Exclusive'){
                     if(feeValueMaster.Fee_Type_Master__r.Amount__c == 'Amount'){
                         //feeAmount = feeValueMaster.Amount__c; // total fee amount for fee creation for 18% tax
                         //for Amount and %Amount : 25/11/22
                         feeAmount = feeValueMaster.Amount_Flat__c;
                         system.debug('feeamount'+feeAmount);
                         mapAmountToFee.put('feeAmount',feeAmount);
                         taxAmount = feeAmount*tax*.01;//Tax_Amount__c in fee creation
                         system.debug('tax amount'+ taxAmount);
                         mapAmountToFee.put('taxAmount',taxAmount);
                         
                         totalFee = feeAmount+taxAmount; // total fee amount for fee creation for 18% tax
                         system.debug(totalFee);
                         mapAmountToFee.put('totalFee',totalFee);
                         System.debug('map of amount'+mapAmountToFee);
                     }
                 }
                  //if Tax is not applicable : 9 Dec 22 : Tax will be zero if Tax__c = No
                  else if(feeValueMaster.Fee_Type_Master__r.Tax__c == 'No'){
                    // System.debug('feeValueMasterList'+feeValueMasterList+feeValueMasterList[0].Fee_Type_Master__r.Amount__c);
                     if(feeValueMaster.Fee_Type_Master__r.Amount__c == 'Amount'){
                         //totalFee = feeValueMaster.Amount__c; // total fee amount for fee creation for 18% tax 
                         //for Amount and %Amount : 25/11/22
                         totalFee = feeValueMaster.Amount_Flat__c;
                         system.debug(totalFee);
                         mapAmountToFee.put('totalFee',totalFee);
                         feeAmount = totalFee;//fee amount = total fee as tax__c = no i.e. tax is not applicable
                         system.debug('feeamount'+feeAmount);
                         mapAmountToFee.put('feeAmount',feeAmount);
                         taxAmount = 0;//Tax_Amount__c in fee creation
                         system.debug('tax amount'+ taxAmount);
                         mapAmountToFee.put('taxAmount',taxAmount);
                         System.debug('map of amount'+mapAmountToFee);
                     }
                 }
                 // feeValueMasterList[0].Fee_Type_Master__r.Calculation_Basis__c == 'Flat' && from below if for range
                 if(feeValueMaster.Fee_Type_Master__r.Calculation_Basis__c <> null && feeValueMaster.Fee_Type_Master__r.Calculation_Basis__c <> '' && feeValueMaster.Fee_Type_Master__r.Amount__c == 'Percentage'){
                    // system.debug('feeValueMasterList[0].Fee_Type_Master__r.Amount__c'+feeValueMasterList[0].Fee_Type_Master__r.Amount__c);
                     //Percentage amount from fee value master as percentage of loan amount from application
                     percentageAmount = feeValueMaster.Amount__c; // total fee amount for fee creation for 18% tax
                     system.debug(percentageAmount);
                     // Application__c appRecord = [SELECT Id, Requested_Loan_Amount__c FROM Application__c WHERE Id =:applicationId];
                     System.debug('application loan amount'+ appRecord.Requested_Loan_Amount__c);
                     
                     if(feeValueMaster.Fee_Type_Master__r.Tax__c <> null && feeValueMaster.Fee_Type_Master__r.Tax__c <> '' && feeValueMaster.Fee_Type_Master__r.Tax__c == 'Inclusive' && appRecord.Total_Amount_Recommended_PcAc__c <> null){
                         // System.debug('application loan amount'+ appRecord.Requested_Loan_Amount__c);
                         System.debug('requestedAmount'+requestedAmount);
                         totalFee = requestedAmount * .01 * percentageAmount;
                         system.debug('totalFee'+totalFee);                     
                         
                         feeAmount = totalFee/1.18;//fee amount without tax for fee collection
                         system.debug('feeamount'+feeAmount);
                         // mapAmountToFee.put('feeAmount',feeAmount);
                         // if cap and floor for fee amount
                         if(feeValueMaster.Floor__c <> null && feeAmount < feeValueMaster.Floor__c){
                             feeAmount = feeValueMaster.Floor__c;
                             mapAmountToFee.put('feeAmount',feeAmount);
                             totalFee = feeAmount + feeAmount * .01 * tax;
                             mapAmountToFee.put('totalFee',totalFee);
                         }
                         else if(feeValueMaster.Cap__c <> null && feeAmount > feeValueMaster.Cap__c){
                             feeAmount = feeValueMaster.Cap__c;
                             mapAmountToFee.put('feeAmount',feeAmount);
                             totalFee = feeAmount + feeAmount * .01 * tax;
                             //mapAmountToFee.put('totalFee',feeValueMaster.Cap__c);
                             mapAmountToFee.put('totalFee',totalFee);
                         }
                         else{                          
                             mapAmountToFee.put('totalFee',totalFee);
                             mapAmountToFee.put('feeAmount',feeAmount);
                         }
                         taxAmount = totalFee - feeAmount;//Tax_Amount__c in fee creation
                         system.debug('tax amount'+ taxAmount);
                         mapAmountToFee.put('taxAmount',taxAmount);
                         System.debug('map of amount'+mapAmountToFee);
                         
                     }
                     else if(feeValueMaster.Fee_Type_Master__r.Tax__c <> null && feeValueMaster.Fee_Type_Master__r.Tax__c <> '' && feeValueMaster.Fee_Type_Master__r.Tax__c == 'Exclusive' && appRecord.Total_Amount_Recommended_PcAc__c <> null){
                         System.debug('application loan amount'+ requestedAmount);
                         feeAmount = requestedAmount * .01 * percentageAmount; // total fee amount for fee creation for 18% tax
                         system.debug('feeamount'+feeAmount);
                         // mapAmountToFee.put('feeAmount',feeAmount);
                         // if cap and floor to be on fee amount
                         if(feeValueMaster.Floor__c <> null && feeAmount < feeValueMaster.Floor__c){
                             feeAmount = feeValueMaster.Floor__c;
                             mapAmountToFee.put('feeAmount',feeAmount);
                         }
                         else if(feeValueMaster.Cap__c <> null && feeAmount > feeValueMaster.Cap__c){
                             feeAmount = feeValueMaster.Cap__c;
                             mapAmountToFee.put('feeAmount',feeAmount);
                         }
                         else{                          
                             mapAmountToFee.put('feeAmount',feeAmount);
                         }
                         taxAmount = feeAmount*tax*.01;//Tax_Amount__c in fee creation
                         system.debug('tax amount'+ taxAmount);
                         mapAmountToFee.put('taxAmount',taxAmount);
                         
                         totalFee = feeAmount+taxAmount; // total fee amount for fee creation for 18% tax
                         system.debug(totalFee);
                         mapAmountToFee.put('totalFee',totalFee);
                         System.debug('map of amount'+mapAmountToFee);
                     }
                     //if tax is not applicable in master : 9 Dec 22
                     else if(feeValueMaster.Fee_Type_Master__r.Tax__c <> null && feeValueMaster.Fee_Type_Master__r.Tax__c <> '' && feeValueMaster.Fee_Type_Master__r.Tax__c == 'No' && appRecord.Total_Amount_Recommended_PcAc__c <> null){
                        System.debug('application loan amount'+ requestedAmount);
                         feeAmount = requestedAmount * .01 * percentageAmount; // total fee amount for fee creation for 0 tax
                         system.debug('feeamount'+feeAmount);
                         // mapAmountToFee.put('feeAmount',feeAmount);
                         // if cap and floor to be on fee amount
                         if(feeValueMaster.Floor__c <> null && feeAmount < feeValueMaster.Floor__c){
                             feeAmount = feeValueMaster.Floor__c;
                             mapAmountToFee.put('feeAmount',feeAmount);
                         }
                         else if(feeValueMaster.Cap__c <> null && feeAmount > feeValueMaster.Cap__c){
                             feeAmount = feeValueMaster.Cap__c;
                             mapAmountToFee.put('feeAmount',feeAmount);
                         }
                         else{                          
                             mapAmountToFee.put('feeAmount',feeAmount);
                         }
                         taxAmount = 0;//Tax_Amount__c in fee creation
                         system.debug('tax amount'+ taxAmount);
                         mapAmountToFee.put('taxAmount',taxAmount);
                         
                         totalFee = feeAmount+taxAmount; // total fee amount for fee creation for 18% tax
                         system.debug(totalFee);
                         mapAmountToFee.put('totalFee',totalFee);
                         System.debug('map of amount'+mapAmountToFee);
                     }
                 }
                 // For Range Calculation
                 if(feeValueMaster.Fee_Type_Master__r.Calculation_Basis__c == 'Flat' ){
                    // System.debug('Calculation Basis'+ feeValueMasterList[0].Fee_Type_Master__r.Calculation_Basis__c);
                 }
                 else if(feeValueMaster.Fee_Type_Master__r.Calculation_Basis__c == 'Range (Floor + Cap)' ){
                     System.debug('Calculation Basis'+ feeValueMaster.Fee_Type_Master__r.Calculation_Basis__c + rangeValues);
                     if(rangeValues.size() > 0){
                         for(Range_Value_Master__c range : rangeValues){
                             System.debug('range'+ range);
                             if(range.To__c <> null && range.From__c <> null){
                                 if(range.To__c > mapAmountToFee.get('totalFee') && range.From__c <= mapAmountToFee.get('totalFee')){
                                     System.debug(mapAmountToFee.get('totalFee'));
                                     if(range.Value__c <> null){
                                         mapAmountToFee.put('totalFee', range.Value__c);
                                         Decimal rangeFee = range.Value__c/1.18;
                                         Decimal rangeTax = mapAmountToFee.get('totalFee') - rangeFee;
                                         mapAmountToFee.put('feeAmount', rangeFee);
                                         mapAmountToFee.put('taxAmount', rangeTax);
                                     }
                                 }
                             }
                         }
                     }
                 }
                 
                 //Range calculation end here
             
                 //}  
                 // changes for multiple fee value master of a fee type master
               // mapOfFeeWithAmount.put(feeValueMaster.Fee_Type_Code__c, mapAmountToFee); 
               return mapAmountToFee;
               
    }
    
    @AuraEnabled
    public static Map<String, String> getRepaymentPicklist_2(String feeCode) {
        Map<String, String> values = new Map<String, String>{};
            List<Fee_Type_Master__c> repaymentString = [SELECT Id, Fee_Type_Code__c, Repayment_of_Fee__c FROM Fee_Type_Master__c
                                                        WHERE Fee_Type_Code__c =: feeCode];
        system.debug('repaymentString'+repaymentString);
        List<String> repaymentList = repaymentString[0].Repayment_of_Fee__c.split(';');
        system.debug('repaymentList'+repaymentList[0]);
        String objectName = 'Fee_Creation__c';
        String fieldName = 'Repayment_Type_2__c';
        
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        String feeValue;
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
        return values;
    }
    @AuraEnabled
    //public Static Map<String, Fee_Type_Master__C> getFeeCodeFromMaster(String applicationId){
    //Added to add FVM in Fee name dropdown on fee creation screen : 22-11-22
    public Static List<feeValueWrapper> getFeeCodeFromMaster(String applicationId){
        //Map<String, String> feeCode = new Map<String, String>();
        Map<String, Fee_Type_Master__C> feeCode = new Map<String, Fee_Type_Master__C>();
        //Map<Fee_value_Master__c, Fee_Type_Master__C> feeCode = new Map<Fee_value_Master__c, Fee_Type_Master__C>();
        List<feeValueWrapper> wrapperForFeeOptionList = new List<feeValueWrapper>();
        System.debug('get fee code from master');
        //List<Fee_Creation__c> fee = [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Fee_Type_Master__r.Fee_Type_Code__c,Fee_Type_Master__r.Id, Total_Fee__c FROM Fee_Creation__c WHERE Type__c = 'User' AND RecordType.DeveloperName = 'Fee' AND Application__c =:applicationId];
        List<Fee_Type_Master__C> feeMasterCode = [SELECT Id, Fee_Type_Code__c, Applicable_For__c, Stage_Due__c, Amount__c, Calculation_Basis__c, Event__c, GL_Code__c, Tax__c, value__c, Waivable__c, Modifiable_at_run_Time__c, (SELECT Id, Name, Fee_Type_Code__c, Fee_Type__c, Amount__c, Description__c
                                                    FROM Fee_Value_Master__r WHERE Active__c = 'Yes') FROM Fee_Type_Master__c WHERE Fee_Type__c = 'User' AND Type__c ='Fee' AND Active__c = 'Yes'];
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

    //Repayment picklist based on master
    @AuraEnabled
    public static Map<String, List<String>> repaymentTypeFromMaster(String feeRecordType){
        try {
            //List<Fee_Type_Master__c> feeValueMasterList = [SELECT Id, Repayment_of_Fee__c, Type__c, Applicable_For__c FROM Fee_Type_Master__c 
            //WHERE Fee_Type__c = 'User' AND Type__c = 'Insurance' AND Active__c = 'Yes'];
            Map<String, List<String>> repaymentMap = new Map<String, List<String>>();
           // List<Fee_Type_Master__c> feeValueMasterList = [SELECT Id, Fee_Type_Code__c, Repayment_of_Fee__c, Type__c, Applicable_For__c 
           //                                             FROM Fee_Type_Master__c  WHERE Active__c = 'Yes' AND Type__c =: feeRecordType];

            // changed to get non active FVM repayment also: 30 Nov 22
            List<Fee_Type_Master__c> feeValueMasterList = [SELECT Id, Fee_Type_Code__c, Repayment_of_Fee__c, Type__c, Applicable_For__c 
                                                        FROM Fee_Type_Master__c  WHERE Type__c =: feeRecordType];

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

   
    
    public class FeeCreationWrapper {
        
        public String Id;
        public Integer sRNumnber;
        public String feeCode;
        public String type;
        public String description;
        public String stageDue;
        public String stage;
        public Boolean isApplication;
        public Boolean isAsset;
        public Boolean isApplicant;
        //public List<SelectOption> repaymentTypeOption;
        public String repaymentType;
        public Decimal feeAmount;
        public Decimal taxAmount;
        public Decimal totalFee;
        public Decimal feeCollection;
        public String applicableOn ;
        public String applicableFor;
        public String loanApplicant;
        public String applicantAssetId;
        public String property;
        public Integer totalRecord ;
        public Boolean buttonFlag = false;
        public Boolean isnewRow = false;
        public Boolean showAdd = false;
        public String masterId = '';
        //feeValueWrapper
        Public Boolean isFeeCollected = false;
        Public Boolean receiptSubmitted = false;
        Public Boolean modifiable = false;
        Public Boolean totalFeeModify = false;
        Public Boolean feeAmountModify = false;
        public List<RepaymentDetailWrapper> repaymentDetail;
        Public Boolean repaymentFromMaster = true;
        public String feeRepayment;
        public String tax = '';
    }

    public class RepaymentDetailWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }

    // get applicatipn detail for Agreement execution
    @AuraEnabled
    public static List<Application__c> getApplicationDetail(String recordId){
        System.debug('recordId' + recordId);
        List<Application__c> appList = new List<Application__c>();
        if(String.IsNotBlank(recordId)){
            appList = [SELECT Id, Pre_Login__c, Name, Applicant_Name__c FROM Application__c where Id =: recordId LIMIT 1];
        }
        if(appList != null && appList.size() > 0){
            return appList;
        }
        return null;
    }

    //@Description : get fee with repayment type not selected: validation on submit
    //@Date : 22-Nov22
    //@Author : Sangeeta yadav
    @AuraEnabled
    public static Boolean getFeeWithoutRepayment(String recordId){
        System.debug('recordId' + recordId);
        Boolean repaymentValue = false; //false : repayment is not balnk in fee
        List<Fee_Creation__c> feeList = new List<Fee_Creation__c>();
        if(String.IsNotBlank(recordId)){
            feeList = [SELECT Id, Repayment_Type_2__c FROM Fee_Creation__c WHERE Application__c =: recordId  AND (Repayment_Type_2__c = null OR Repayment_Type_2__c = '' )];
        }
        if(feeList != null && feeList.size() > 0){
            repaymentValue = true; //true : repayment is balnk in fee
           
        }
        return repaymentValue;
    }

    //@Description : get fee with zero Amount if any: validation on submit
    //@Date : 22-Nov22
    //@Author : Sangeeta yadav
    @AuraEnabled
    public static Boolean getZeroFee(String recordId){
        System.debug('recordId' + recordId);
        Boolean zeroFee = false; //false : fee is not avalaible with zero amount
        List<Fee_Creation__c> feeList = new List<Fee_Creation__c>();
        if(String.IsNotBlank(recordId)){
            feeList = [SELECT Id,Total_Fee__c  FROM Fee_Creation__c WHERE Application__c =: recordId  AND (Total_Fee__c = null OR Total_Fee__c = 0 )];
        }
        if(feeList != null && feeList.size() > 0){
            zeroFee = true; //true : fee is avalaible with zero amount
           
        }
        return zeroFee;
    }

    //Wrapper added to add FVM in fee name dropdown : 22-11-22
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

    /* @Method for Manual fee calculation: 24/11/22
@Author Sangeeta */ 
@AuraEnabled
 
public static Map<String,Map<String, Decimal>> calculationUserFee(String applicationId, String FeeValueId, String propId){
    Decimal feeAmount;
    Decimal totalFee;
    Decimal taxAmount;
    Decimal percentageAmount;
    Decimal loanAmount;
   // Map<String, Decimal> mapAmountToFee = new Map<String, Decimal>();
    List<Property__c> propertyList = new List<Property__c>();
    Map<String,Map<String, Decimal>> mapOfFeeWithAmount = new Map<String,Map<String, Decimal>>();
    if(String.isNotBlank(propId)){
        propertyList = [SELECT Id, Name, Final_Land_Value__c FROM Property__c WHERE Id =: propId AND RecordType.name = 'Pre Login Property Detail'];
    }

    try{  
        //AND Fee_Type_Master__r.Value__c = 'Loan Amount' removed from this query for all values
       /* List<Fee_Value_Master__c> feeValueMasterList = [SELECT Id,Fee_Type_Code__c, Amount__c, Cap__c, Floor__c, 
                                                        Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,
                                                        Fee_Type_Master__r.Tax__c,Fee_Type_Master__r.Value__c,Fee_Type_Master__r.Type__c,Fee_Type_Master__r.Event__c,Fee_Type_Master__r.Applicable_For__c  
                                                        FROM Fee_Value_Master__c WHERE Fee_Type_Code__c = :feeCode AND Fee_Type_Master__r.Stage_Due__c = 'Pre Login' AND Fee_Type_Master__r.Type__c = 'Fee'
                                                        AND Fee_Type_Master__r.Event__c = 'Application Login' LIMIT 1];*/
        
        //for multiple fee
        List<Fee_Value_Master__c> feeValueMasterList = [SELECT Id, Name, Fee_Type_Code__c, Amount__c, Cap__c, Floor__c, Amount_Flat__c,
                                                        Fee_Type_Master__r.Amount__c, Fee_Type_Master__r.Calculation_Basis__c,Fee_Type_Master__r.Fee_Type__c,
                                                        Fee_Type_Master__r.Tax__c,Fee_Type_Master__r.Value__c,Fee_Type_Master__r.Type__c,Fee_Type_Master__r.Event__c,Fee_Type_Master__r.Applicable_For__c  
                                                        FROM Fee_Value_Master__c WHERE Fee_Type_Master__r.Active__c = 'Yes' AND Active__c = 'yes' AND Id =: FeeValueId];
        List<Range_Value_Master__c> rangeValues = [SELECT Id, To__c, From__c, Value__c FROM Range_Value_Master__c];
        //  System.debug('feeValueMasterList'+feeValueMasterList+feeValueMasterList[0].Fee_Type_Master__r.Amount__c + feeValueMasterList[0].Fee_Type_Master__r.Value__c);
       // System.debug(feeValueMasterList[0].Fee_Type_Master__r.Calculation_Basis__c +feeValueMasterList[0].Fee_Type_Master__r.Tax__c);
        Application__c appRecord = [SELECT Id, Requested_Loan_Amount__c, Loan_Amount__c, Mortgage_property_Collateral_Value__c, Total_Amount_Recommended_PcAc__c, Emi_PcAc__c FROM Application__c WHERE Id =:applicationId];
        Decimal requestedAmount;
        //to calculate for all fee type master of fee type system
        if(feeValueMasterList <> null && feeValueMasterList.size() > 0 ){
        for(Fee_Value_Master__c feeValueMaster :feeValueMasterList){
            System.debug('Fee value master fee code is'+feeValueMaster.Fee_Type_Code__c);
            Map<String, Decimal> mapAmountToFee = new Map<String, Decimal>();
        if(feeValueMaster.Fee_Type_Master__r.Value__c == 'Loan Amount'){
            //if(appRecord.Loan_Amount__c != null){
            // Changes to use Recommended loan amount 
            if(appRecord.Total_Amount_Recommended_PcAc__c != null){
                System.debug('Loan Amount'+ appRecord.Total_Amount_Recommended_PcAc__c);
                //requestedAmount = appRecord.Loan_Amount__c;
                requestedAmount = appRecord.Total_Amount_Recommended_PcAc__c;
            }
            else{
                requestedAmount = 0;
            }
            mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
            mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
        }
        if(feeValueMaster.Fee_Type_Master__r.Value__c == 'Installment Amount'){
            // Installment amount is not defined in application
            System.debug('Installment Amount'+ appRecord.Emi_PcAc__c);
            // changes done to use Emi_PcAc__c for calculation
            //if(appRecord.Requested_Loan_Amount__c != null){
                if(appRecord.Emi_PcAc__c != null){
                System.debug('Requested_Loan_Amount__c'+ appRecord.Emi_PcAc__c);
                requestedAmount = appRecord.Emi_PcAc__c;
            }
            else{
                requestedAmount = 0;
            }
            mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
            mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
        }
        if(feeValueMaster.Fee_Type_Master__r.Value__c == 'Asset Cost'){
            // Asset Cost is not defined in application
            //chganges done to use Mortgage_property_Collateral_Value__c in calcuylation based on applicable for is asset or application//
            System.debug('Asset Cost'+ appRecord.Mortgage_property_Collateral_Value__c);
            //if(appRecord.Requested_Loan_Amount__c != null){
            if(feeValueMaster.Fee_Type_Master__r.Applicable_For__c == 'Application'){
                System.debug('Applicable for' + feeValueMaster.Fee_Type_Master__r.Applicable_For__c);
                if(appRecord.Mortgage_property_Collateral_Value__c != null){
                    System.debug('Requested_Loan_Amount__c'+ appRecord.Mortgage_property_Collateral_Value__c);
                    requestedAmount = appRecord.Mortgage_property_Collateral_Value__c;
                }
                else{
                    requestedAmount = 0;
                }
                mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
            }
            else if(feeValueMaster.Fee_Type_Master__r.Applicable_For__c == 'Asset'){
                System.debug('Applicable for' + feeValueMaster.Fee_Type_Master__r.Applicable_For__c );
                System.debug('Requested_Loan_Amount__c'+ appRecord.Mortgage_property_Collateral_Value__c);
                if(propertyList!= null && propertyList.size() > 0){
                    for(Property__c prop : propertyList){
                        System.debug('prop name'+ prop.Name);
                        if(prop.Final_Land_Value__c != null){
                            requestedAmount = prop.Final_Land_Value__c;
                        }
                        else{
                            requestedAmount = 0;
                        }
                        mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                        //mapAmountToFee.put('Property', prop.Name);
                        mapOfFeeWithAmount.put(feeValueMaster.Name + prop.Name, mapAmountToFee); 
                    }
                }
                
            }
            else if(feeValueMaster.Fee_Type_Master__r.Applicable_For__c == 'Applicant'){
                System.debug('Applicable for' + feeValueMaster.Fee_Type_Master__r.Applicable_For__c);
                requestedAmount = 0;
                mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
                mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
            }
        } 
       // mapAmountToFee = feeCalculation(feeValueMaster, rangeValues, appRecord, requestedAmount);
       // mapOfFeeWithAmount.put(feeValueMaster.Name, mapAmountToFee); 
        System.debug('fee and calculation'+ feeValueMaster.Fee_Type_Code__c + mapAmountToFee + 'mapOfFeeWithAmount'+mapOfFeeWithAmount);
       
        }
        }
        if(mapOfFeeWithAmount.size() > 0){
            for(String fee : mapOfFeeWithAmount.KeySet()){
                System.debug('FeeCode'+fee);
                System.debug('mapOfFeeWithAmount'+mapOfFeeWithAmount.get(fee)+fee);
            }
        }
     //   System.debug('mapAmountToFee'+mapAmountToFee);
    }
    catch(exception e){
        System.debug('Message: ' + e.getMessage() + e.getLineNumber()); 
    }
    return mapOfFeeWithAmount;
    
}
    
}