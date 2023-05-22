public class FetchDataTableRecordsController extends GenericDataTableController{
    
	//Getting Applicant Records In Data Table 
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getAccData(String applicationId){
        System.debug('applicationId=  '+applicationId);
        Set<String> accIds = new Set<String>();
        for(Loan_Applicant__c acc : [SELECT Id FROM Loan_Applicant__c WHERE Application__c  =: applicationId AND Application__c  != null]){
            accIds.add(acc.Id); 
        }
        
        System.debug('accIds=  '+accIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Loan_Applicant'; 
        genericDTObj.IDS_SET = accIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();     
    }

    //Getting Applicant Records FOR BM KYC Verification In Data Table 
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getPendingKYCVerificationApplicants(String applicationId){
        System.debug('applicationId=  '+applicationId);
        Set<String> accIds = new Set<String>();
        for(Loan_Applicant__c acc : [SELECT Id FROM Loan_Applicant__c WHERE Application__c  =: applicationId AND Application__c  != null
                                        AND BM__c != Null AND Is_Kyc_Verified__c = false AND Is_KYC_executed__c = true]){
            accIds.add(acc.Id); 
        }
        
        System.debug('accIds=  '+accIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'BM_Loan_Applicant'; 
        genericDTObj.IDS_SET = accIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();     
    }
    
     //Getting Property Records In Data Table
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getPropertyData(String applicationId,String recTypeName){
        System.debug('applicationId=  '+applicationId); 
        Set<String> propIds = new Set<String>();
        for(Property__c prop : [SELECT Id FROM Property__c 
                                WHERE Application__c  =: applicationId AND Application__c != null AND RecordType.Name = :recTypeName]){
                                    propIds.add(prop.Id);
                                }
        
        System.debug('propIds=  '+propIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Pre_Login_Property';
        genericDTObj.IDS_SET = propIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();     
    }
    
     //Getting Applicant Records In Data Table 
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getPropertyOwners(List<String> applicantId){
        System.debug('applicationId=  '+applicantId);
        Set<String> loanAppIds = new Set<String>(applicantId);
        System.debug('loanAppIds=  '+loanAppIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'FS_Property_Owners'; 
        genericDTObj.IDS_SET = loanAppIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();     
    }
    
    //Retreive Application for Topup or Relogin
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse searchApplication(String appNumber,String kycNumber,String loanAppNo,String recType){
        Date dateValue = System.today()-90;
        Date todayDate = System.today();
        if(String.isNotBlank(appNumber) && String.isNotEmpty(appNumber) && String.isNotBlank(kycNumber) && String.isNotEmpty(kycNumber))
            return null;
        Set<String> appIds = new Set<String>();
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        String query = 'SELECT Id FROM Loan_Applicant__c ';
        	   query+= 'WHERE Application__c != NULL ';
        if(recType == '2. Re-login'){
               query+= 'AND (Application__r.Pre_Login__r.Status__c =  \'Rejected\' ';
               query+= 'OR Application__r.Pre_Login__r.Status__c = \'Cancelled\' '; 
               query+= 'OR Application__r.Pre_Login__r.Status__c = \'Active\') ';
        	   query+= 'AND Application__r.Pre_Login__r.RecordType.Name = \'1. New login\' ';
               query+= 'AND Application__r.LMS_Response_Reference__c = NULL ';
               query+= 'AND Application__r.Rejected_Date__c>=:dateValue '; // This line added by Mo Arslan
               query+= 'AND Application__r.Rejected_Date__c<=:todayDate ';//This line added by Mo Arslan
        }
        if(recType == '3. Top-up loan'){
            query+= 'AND Application__r.Pre_Login__r.Status__c = \'Active\' ';
            query+= 'AND Application__r.LMS_Response_Reference__c != NULL ';
        }
        if(String.isNotBlank(appNumber) && String.isNotEmpty(appNumber)){
            query+= 'AND Application__r.Name = :appNumber '; 
            query+= 'AND Application__r.Name != null '; 
            query+= 'AND Customer_Type__c = \'Primary Applicant\' ';
        }
        else if(String.isNotBlank(kycNumber) && String.isNotEmpty(kycNumber)){
            query+= 'AND (KYC_Id_1__c = :kycNumber OR KYC_Id_2__c = :kycNumber) ';
        }
        else if(String.isNotBlank(loanAppNo) && String.isNotEmpty(loanAppNo) && recType == '3. Top-up loan'){
            query+= 'AND Customer_Type__c = \'Primary Applicant\' ';
            query+= 'AND Application__r.LMS_Response_Reference__c =:loanAppNo ';
        }
        System.debug('query '+query);
        loanAppList = Database.query(query);
        if(!loanAppList.isEmpty()){
            for(Loan_Applicant__c app : loanAppList){
                appIds.add(app.Id);
            }
            System.debug('appIds=  '+appIds);
            GenericDataTableController genericDTObj = new GenericDataTableController();
            genericDTObj.METADATA_NAME = 'ReloginApplication';
            genericDTObj.IDS_SET = appIds;
            genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
            return genericDTObj.getTable();       
        }
        return null;
    }
    
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getFeeCreationDataTable(String applicationId){ 
        System.debug('appId #### '+applicationId);
        /* fetch data from fee */ 
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Fee_Creation_Insurance_Type';  
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(applicationId);
       // String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
       // genericDTObj.IDS_SET.add(rcId);
       //genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET';
       genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
       System.debug('result >>>>> '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
}