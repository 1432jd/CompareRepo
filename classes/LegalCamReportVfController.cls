public without sharing class LegalCamReportVfController {
    public String applicationId{get;set;}
    public Application__c application{get;set;}
    public List<Property__c> objProp{get;set;}
    public List<ApplicationWrapper> applicationSummaryList{get;set;}
    /*public Decimal srNo{get;set;}
    public String sanctionAmountRest{get;set;}
    public Decimal sanctionAmountResUpto{get;set;}
    public String fileCategory{get;set;}
    public String riskDocColor{get;set;}
    public String anyApproval{get;set;}
    public String anyApprovalRemarks{get;set;}
    public String userId{get;set;}
    public String legalDecision{get;set;}
    public String legalSanctionCondition{get;set;}*/
    public LegalCamReportVfController(){
        applicationId = Apexpages.currentPage().getParameters().get('id');
        system.debug('appid==>' + applicationId);
        applicationSummaryList = new List<ApplicationWrapper>();
        objProp = new List<Property__c>();
        try{
            /*if(String.isBlank(applicationId))
                applicationId= 'a0GC2000000rOYrMAM';*/
            
            if(String.isNotBlank(applicationId)) {
                application = [SELECT 
                               Id,Name,Sourcing_Branch__r.Name,File_Type__c,MODT_Template__c,MODT_to_be_done_in_name_of__c,Old_Loan_Sanction_Date__c,Old_MODT_Document_No__c,Any_Approval_to_be_Obtained__c,
                               Old_Loan_Amount__c,Old_Mortgage_Date__c,Registration_District__c,SRO_Office__c,MODT_Schedule__c,Sanction_Amount_Restriction__c,File_Category__c,
                               Risk_Document_Color__c,User_ID__c,Legal_Decision__c,Legal_Sanction_Condition__c,Sub_Stage__c,Sanction_amount_restriction_upto__c,Legal_Summary_Remarks__c,
                               (Select Id,Applicant_Name__c FROM Loan_Applicants__r)
                               FROM Application__c 
                               WHERE Id =: applicationId];
                
                objProp = [SELECT 
                           Id, Is_Legal_Updated__c, Title_Document_in_Name_of__c, Title_Deed_Number__c,Name,
                           Title_Deed_Date__c, Document_Type__c, Survey_Number__c, Plot_No__c, Property__c,
                           House_Door_No__c, Village__c, District__c, MS_Pincode__r.Name, Extent_Sqft__c,Remarks_In_Encumberance__c,
                           Supporting_Document_SD__c, SD_in_name_of__c, SD_Date__c, Link_Doc_Status__c,Property_Number__c,
                           Link_Document_Type__c, Link_Doc_Date__c, Link_Documents_in_Name_of__c, Login_EC_Type__c,
                           Login_EC_Number__c, Login_EC_Date_From__c, Login_EC_Date_Till__c, Online_EC_Status__c,
                           Online_EC_Date_From__c, Online_EC_Date_Till__c, GuidelineValue_SqFt_asPer_LegalOpinion__c, 
                           Online_Guideline_Value_Search__c, Online_Guidelive_Value__c, Existing_Encumberances__c,Application__c
                           FROM Property__c 
                           WHERE Application__c =: applicationId 
                           AND RecordType.Name = 'Legal Approval'];
                
            }
            
            for(Application__c appObj : [SELECT 
                                         Id,Name,Sourcing_Branch__r.Name,File_Type__c,MODT_Template__c,MODT_to_be_done_in_name_of__c,Old_Loan_Sanction_Date__c,Old_MODT_Document_No__c,
                                         Old_Loan_Amount__c,Old_Mortgage_Date__c,Registration_District__c,SRO_Office__c,MODT_Schedule__c,Sanction_Amount_Restriction__c,File_Category__c,
                                         Risk_Document_Color__c,User_ID__c,Legal_Decision__c,Legal_Sanction_Condition__c,Sub_Stage__c,Sanction_amount_restriction_upto__c,
                                         Legal_Summary_Remarks__c,Any_Approval_to_be_Obtained__c
                                         FROM Application__c 
                                         WHERE Id =: applicationId]){
                                             ApplicationWrapper appWrap = new ApplicationWrapper();
                                             appWrap.sanctionAmountRest = appObj.Sanction_Amount_Restriction__c;
                                             appWrap.sanctionAmountResUpto = appObj.Sanction_amount_restriction_upto__c;
                                             appWrap.fileCategory = appObj.File_Category__c;
                                             appWrap.riskDocColor = appObj.Risk_Document_Color__c;
                                             appWrap.userId = appObj.User_ID__c;
                                             appWrap.legalSanctionCondition =appObj.Legal_Sanction_Condition__c;
                                             appWrap.anyApproval = appObj.Any_Approval_to_be_Obtained__c;
                                             appWrap.legalDecision = appObj.Legal_Decision__c;
                                             if(appObj.Any_Approval_to_be_Obtained__c == 'Yes'){
                                                 //appWrap.anyApproval = 'Yes';
                                                 appWrap.anyApprovalRemarks = appObj.Legal_Summary_Remarks__c;
                                             }else if(appObj.Any_Approval_to_be_Obtained__c == 'No'){
                                                 //appWrap.anyApproval = 'No';
                                                 appWrap.anyApprovalRemarks = ''; 
                                             }  
                                             applicationSummaryList.add(appWrap);
                                         }
        }
        Catch(Exception e){
            System.debug('Error msg 1'+e.getMessage()+'----->'+e.getLineNumber());
        }
    }
    public Class ApplicationWrapper{
        public String sanctionAmountRest{get;set;}
        public String fileCategory{get;set;}
        public String riskDocColor{get;set;}
        public String userId{get;set;}
        public String legalDecision{get;set;}
        public String legalSanctionCondition{get;set;}
        public String anyApprovalRemarks{get;set;}
        public String anyApproval{get;set;}
        public Decimal sanctionAmountResUpto{get;set;}
    }
}