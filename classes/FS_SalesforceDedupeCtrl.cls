public without sharing class FS_SalesforceDedupeCtrl {
    
    @AuraEnabled
    public static List<DedupeWrapper> getDedupeRecords(String recordId){
        List<Loan_Applicant__c> currentApplicant = [SELECT Id, KYC_ID_Type_1__c, KYC_ID_Type_2__c, KYC_Id_1__c, KYC_Id_2__c FROM Loan_Applicant__c WHERE Id=:recordId];
        if(currentApplicant != NULL && !currentApplicant.isEmpty()){
            Set<String> stages = new Set<String>{'Document Deferral','Custody','File Inward','VDC Maker','VDC Checker','Vendor Handoff'};
            String kycId1 = currentApplicant.get(0).KYC_Id_1__c;
            String kycId2 = currentApplicant.get(0).KYC_Id_2__c;

            String query = 'SELECT Id, KYC_ID_Type_1__c,Applicant_Name__c,LMS_Customer_Info_File_Number__c, KYC_ID_Type_2__c, KYC_Id_1__c, KYC_Id_2__c, Application__r.application_status__c, Application__r.LastModifiedDate,';
            query += ' Application__c, Application__r.Name,Application__r.AC_Decision__c, Application__r.Stage__c,Application__r.Disbursal_Author_Decision_Remarks__c, Application__r.Owner.Name, Application__r.LastModifiedBy.Name FROM Loan_Applicant__c';
            query += ' WHERE Application__r.Stage__c NOT IN : stages AND Application__r.Created_From_Batch__c=false';
            if(String.isNotBlank(kycId1) && String.isNotBlank(kycId2)) {
                query += ' AND ((KYC_Id_1__c =: kycId1 OR KYC_Id_2__c =: kycId1) OR (KYC_Id_1__c =: kycId2 OR KYC_Id_2__c =: kycId2))';
            }
            else if(String.isNotBlank(kycId1)) {
                query += ' AND (KYC_Id_1__c =: kycId1 OR KYC_Id_2__c =: kycId1)';
            }
            else if(String.isNotBlank(kycId2)) {
                query += ' AND (KYC_Id_1__c =: kycId2 OR KYC_Id_2__c =: kycId2)';
            } 
            else {
                return null;
            }
            System.debug('getDedupeRecords = '+query);

            List<DedupeWrapper> dedupeResult = new List<DedupeWrapper>();
            for(Loan_Applicant__c applicant : Database.query(query)){
                DedupeWrapper dedupeObj = new DedupeWrapper();
                dedupeObj.applicant = applicant;
                if(applicant.Application__r.application_status__c == 'Rejected'){
                    if(applicant.Application__r.Stage__c == 'Approval Credit'){
                        dedupeObj.rejectionRemark = applicant.Application__r.AC_Decision__c;
                    } else if(applicant.Application__r.Stage__c == 'Disbursal Author'){
                        dedupeObj.rejectionRemark = applicant.Application__r.Disbursal_Author_Decision_Remarks__c;
                    }   
                    dedupeObj.rejectedBy = applicant.Application__r.LastModifiedBy.Name;
                    dedupeObj.rejectionDate = applicant.Application__r.LastModifiedDate;
                }else{
                    dedupeObj.rejectionDate = null;
                    dedupeObj.rejectionRemark = '';
                }
                dedupeResult.add(dedupeObj);
            }
            if(!dedupeResult.isEmpty()){
                return dedupeResult;
            }        
        }
        return null;
    }


    @AuraEnabled
    public static List<CustomerWrapper> getApplicantData(String applicantId,String CustomerNumber){
        try {

                System.debug('applicantId is >>>'+applicantId);
                System.debug('CustomerNumber is >>>'+CustomerNumber);
                List<CustomerWrapper> dedupeCustomerWrapperList = new List<CustomerWrapper>();
                List<Loan_Applicant__c> loanApptList = new List<Loan_Applicant__c>();

                if((String.isNotBlank(CustomerNumber) && String.isNotEmpty(CustomerNumber) && CustomerNumber!=null) && 
                (String.isNotBlank(applicantId) && String.isNotEmpty(applicantId) && applicantId!=null)){
                     loanApptList = [SELECT Id,Name,LMS_Customer_Info_File_Number__c,Applicant_Name__c,Dob__c,Application__r.LMS_Response_Reference__c,Application__r.Sourcing_Branch__r.Name,Application__r.Name,
                    KYC_Id_1__c,KYC_Id_2__c,KYC_ID_Type_1__c,KYC_ID_Type_2__c,Residence_Address_Line_1__c,Residence_Pincode__r.Name,Mobile__c from Loan_Applicant__c where  
                    LMS_Customer_Info_File_Number__c=:applicantId AND Id=:CustomerNumber LIMIT 1];
                    System.debug('loanapplist cehck is 68 >>>'+loanApptList);

                }

            if(loanApptList.size()>0){
                System.debug('loanapplist cehck is >>>'+loanApptList);

                for(Loan_Applicant__c loanObj : loanApptList){

                    CustomerWrapper wrapperObj = new CustomerWrapper();
                    wrapperObj.appId = loanObj.Application__r.Name;
                    wrapperObj.apptId = loanObj.Id;
                    wrapperObj.apptCustId = loanObj.LMS_Customer_Info_File_Number__c!=null?loanObj.LMS_Customer_Info_File_Number__c:'';
                    wrapperObj.apptName = loanObj.Applicant_Name__c!=null?loanObj.Applicant_Name__c:'';
                    wrapperObj.apptlastName =  loanObj.Applicant_Name__c!=null?loanObj.Applicant_Name__c:'';
                    wrapperObj.apptdob = String.valueOf(loanObj.Dob__c)!=null?String.valueOf(loanObj.Dob__c):'';
                    wrapperObj.apptmobile = String.valueOf(loanObj.Mobile__c)!=null?String.valueOf(loanObj.Mobile__c):'';
                    wrapperObj.apptresAddrss = loanObj.Residence_Address_Line_1__c!=null?loanObj.Residence_Address_Line_1__c:'';
                    wrapperObj.apptpincode = loanObj.Residence_Pincode__r.Name!=null?loanObj.Residence_Pincode__r.Name:'';
                    wrapperObj.apptloanapptName = loanObj.Name!=null?loanObj.Name:'';
                    wrapperObj.apptlanNo = loanObj.Application__r.LMS_Response_Reference__c!=null?loanObj.Application__r.LMS_Response_Reference__c:'';
                    wrapperObj.apptbranchName = loanObj.Application__r.Sourcing_Branch__r.Name!=null?loanObj.Application__r.Sourcing_Branch__r.Name:'';
                   

                    if(String.isNotBlank(loanObj.KYC_ID_Type_1__c) && String.isNotEmpty(loanObj.KYC_ID_Type_1__c) && loanObj.KYC_ID_Type_1__c!=null){

                        if(loanObj.KYC_ID_Type_1__c == 'Aadhaar Card'){
                            wrapperObj.apptadhar = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Voter Id'){
                            wrapperObj.apptvoterId = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Pan Card'){
                            wrapperObj.apptpan = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Driving License'){
                            wrapperObj.apptdl = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }else if(loanObj.KYC_ID_Type_1__c == 'Passport'){
                            wrapperObj.apptpassport = loanObj.KYC_Id_1__c!=null?loanObj.KYC_Id_1__c:''; 
                        }
                    }

                       if(String.isNotBlank(loanObj.KYC_ID_Type_2__c) && String.isNotEmpty(loanObj.KYC_ID_Type_2__c) && loanObj.KYC_ID_Type_2__c!=null){
                        if(loanObj.KYC_ID_Type_2__c == 'Aadhaar Card'){
                            wrapperObj.apptadhar = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Voter Id'){
                            wrapperObj.apptvoterId = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Pan Card'){
                            wrapperObj.apptpan =loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Driving License'){
                            wrapperObj.apptdl = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }else if(loanObj.KYC_ID_Type_2__c == 'Passport'){
                            wrapperObj.apptpassport = loanObj.KYC_Id_2__c!=null?loanObj.KYC_Id_2__c:''; 
                        }
                        
                    }

                    dedupeCustomerWrapperList.add(wrapperObj);
                }
                return dedupeCustomerWrapperList;
            }

            return null;
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DedupeWrapper{
        @AuraEnabled public Loan_Applicant__c applicant;
        @AuraEnabled public DateTime rejectionDate;
        @AuraEnabled public String rejectionRemark;
        @AuraEnabled public String rejectedBy;

        public DedupeWrapper(){
            applicant = new Loan_Applicant__c();
            rejectionRemark = '';
            rejectedBy='';
        }
    }

    public class CustomerWrapper{

        @AuraEnabled public String  apptId;
        @AuraEnabled public String  apptCustId;
        @AuraEnabled public String  appId;
        @AuraEnabled public String  apptName;
        @AuraEnabled public String  apptlastName;
        @AuraEnabled public String  apptdob;
        @AuraEnabled public String  apptadhar;
        @AuraEnabled public String  apptpan;
        @AuraEnabled public String  apptdl;
        @AuraEnabled public String  apptvoterId;
        @AuraEnabled public String  apptpassport;
        @AuraEnabled public String  apptmobile;
        @AuraEnabled public String  apptresAddrss;
        @AuraEnabled public String  apptpincode;
        @AuraEnabled public String  apptloanapptName;
        @AuraEnabled public String  apptlanNo;
        @AuraEnabled public String  apptbranchName;
        
        public  CustomerWrapper(){
            apptbranchName='';
            apptlanNo='';
            apptloanapptName='';
            apptpincode='';
            apptresAddrss='';
            apptmobile='';
            apptpassport='';
            apptvoterId='';
            apptdl='';
            apptpan='';
            apptadhar='';
            apptdob='';
            apptlastName='';
            apptName='';
            appId='';
            apptId='';
        }
    }



}