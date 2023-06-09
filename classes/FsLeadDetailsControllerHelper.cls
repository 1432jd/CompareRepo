/**
* @File Name          : LeadDetailsController.cls
* @Description        : Service Class For Lead Details Lightning Web Component
* @Author             : Yogendra Degra
* @Created On         : 05/05/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         05/05/2022              Yogendra Degra       Initial Version
*/
public class FsLeadDetailsControllerHelper {
    @AuraEnabled
    public static List<Application__c> getPrimaryApplicantData(String applicationId){
        System.debug('### applicationId '+applicationId);
        List<Application__c> listOfApplication = new List<Application__c>(); 
        if(String.isNotBlank(applicationId)){
            listOfApplication = [SELECT Id, Name, Pre_Login__c, Old_Application_Number__c, Pre_Login__r.RecordType.Name,
                                 (SELECT Id, Application__r.Requested_Loan_Amount__c, Name, Customer_Type__c, Customer_Information__r.FirstName, Customer_Information__r.LastName, 
                                  Customer_Information__c, Customer_Information__r.Name, Customer_Information__r.Customer_Type__c, Constitution__c FROM Loan_Applicants__r WHERE Customer_Type__c = 'Primary Applicant')
                                 FROM Application__c WHERE Id =:applicationId];    
        }
        return listOfApplication;
    }
	@AuraEnabled
    public static IFSC_Code_Master__c getBankIFSCDetails(String masterId){
        return [SELECT Id, Name, Bank_Name__c, Bank_Branch_Name__c FROM IFSC_Code_Master__c WHERE Id =: masterId];
    }    
    @AuraEnabled
    public static void getChildData(String applicationId){
        Set<String> setOfApplicants = new Set<String>();
        List<Account> listOfAccount = new List<Account>();
        for(Loan_Applicant__c objLoan : [SELECT Id, Application__c, Customer_Information__c, Customer_Type__c FROM Loan_Applicant__c WHERE Application__c =:applicationId]){
            if(String.isNotBlank(objLoan.Customer_Information__c)){
                setOfApplicants.add(objLoan.Customer_Information__c);	
            }    
        }
    }
   @AuraEnabled
    public static Boolean checkKYCIdExist(String kycId1, String kycId2,String appId,String loanAppId){
        if((String.isNotBlank(kycId1) && String.isNotEmpty(kycId1)) || String.isNotBlank(kycId2) && String.isNotEmpty(kycId2)){
            String query = 'SELECT Id FROM Loan_Applicant__c WHERE Application__c = :appId ';
            query += 'AND (';
            if(String.isNotBlank(kycId1) && String.isNotEmpty(kycId1)){
                kycId1 = EncryptDecryptController.encryptData(kycId1);
                query += 'KYC_ID_1__c = :kycId1 OR KYC_ID_2__c = :kycId1 OR ';        
            }
            if(String.isNotBlank(kycId2) && String.isNotEmpty(kycId2)){
                kycId2 = EncryptDecryptController.encryptData(kycId2);
                query += 'KYC_ID_1__c = :kycId2 OR KYC_ID_2__c = :kycId2 '; 
            }
            query = query.removeEnd('OR ');
            query += ')';
            System.debug(query);
            List<Loan_Applicant__c> listLoan = Database.query(query);
            System.debug(listLoan);
            System.debug(listLoan.size());
            if(listLoan.size() > 0){
                if(String.isNotBlank(loanAppId) && String.isNotEmpty(loanAppId) && listLoan.size() == 1 && listLoan.get(0).Id == loanAppId)
                    return false;
                else
                    return true;
            }
        }
        return false;
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getAllApplicantMeta(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'FS_All_Applicant';
        //genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Id IN : IDS_SET';
        System.debug('genericDTObj.getTable() #### '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getPersonalInformationData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Personal_Information';
        //genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Id IN : IDS_SET';
        System.debug('genericDTObj.getTable() #### '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getEducationData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Education';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getFamilyData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Family_Details';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getEmploymentDetailsData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Employment_Details';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getIncomeDetailsData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Income_Details';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getBankDetailsData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Bank_Details';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    } 
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getReferenceData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Reference';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    } 
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getReceiptData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Receipt';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getPropertyDetailsData(String applicationId){
        String rcIdPreLogin = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Lead Detail').getRecordTypeId();
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Property_Details';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(applicationId);
        genericDTObj.IDS_SET.add(rcIdPreLogin);
        genericDTObj.WHERE_CLAUSE='Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
        //
    }
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getLoanDetailsData(List<String> allLoanApplicant){
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Lead_Details_Loan_Type';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET = new Set<String>(allLoanApplicant);
        genericDTObj.WHERE_CLAUSE='Loan_Applicant__c IN : IDS_SET';
        System.debug('genericDTObj.getTable() '+genericDTObj.getTable());
        return genericDTObj.getTable(); 
    }
    @AuraEnabled
    public static String initiatFivC(String applicationId, String userAssignmentId){
        System.debug('applicationId #### '+applicationId + ' userAssignmentId '+userAssignmentId);
        Verification__c objVer = new Verification__c();
        objVer.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        objVer.Application__c = applicationId;
        objVer.Status__c = 'Pending';
        objVer.Initiate_From__c = 'Lead Details';
        objVer.OwnerId = userAssignmentId;
        insert objVer;
        Utility.sendNotification('Verification Initiated', objVer.Name, objVer.Id, 'Verification_Notification',userAssignmentId);
        Utility.createTask('FIV-C '+ objVer.Name + 'Initiated', null, null, userAssignmentId, null,'Please Approve this Receipt',true);
        return 'Initiated Successfully';
        
    }
    @AuraEnabled
    public static String isAllVerificationCompleted(String applicationId){
        System.debug('applicationId #### '+applicationId);
        List<Verification__c> verificationRecords = [SELECT Id, Application__c FROM Verification__c WHERE Application__c =: applicationId AND Status__c = 'Pending'];
        List<Loan_Applicant__c> listOfLoanApplicant = [SELECT Id, Customer_Type__c,(SELECT Id, Name FROM Properties__r) FROM Loan_Applicant__c WHERE Application__c =: applicationId AND Customer_Type__c = 'Primary Applicant' LIMIT 1];
        if(verificationRecords.size() > 0){
            return 'Complete All Verification';    
        }
        else if(listOfLoanApplicant.size() <= 0){
            return 'There Is No Primary Applicant On This Application.';  
        }
        else if(listOfLoanApplicant[0].Properties__r.size() <= 0){
            return 'Add Atleast One Property On Primary Applicant';            
        }
        else{
            Verification__c objVer = new Verification__c();
            objVer.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('PC').getRecordTypeId();
            objVer.Application__c = applicationId;
            objVer.Status__c = 'Pending';
            objVer.Initiate_From__c = 'Lead Details';
            //objVer.OwnerId = userAssignmentId;
            insert objVer;
            
            Application__c objApp = new Application__c();
            objApp.Id = applicationId;
            objApp.Stage__c = 'PC';
            update objApp;
        }
        return '';
    }
    @AuraEnabled
    public static List<User> getlAllUser(){
        return [SELECT Id, Name, Designation__c FROM User WHERE Designation__c = 'Credit Officer'];
    }
    @AuraEnabled
    public static List<MS_Pincode__c> getPincodeMaster(String pinId){
		return [SELECT Id, Name, DistrictName__c, StateName__c, City__c FROM MS_Pincode__c WHERE Id = : pinId];
    }
    @AuraEnabled
    public static void saveCustomerData(String customerData){
    	System.debug('customerData ##### '+customerData);   
        Account accountData = (Account)JSON.deserialize(customerData, Account.class);
        update accountData;
    }

         @AuraEnabled
    public static List<Loan_Applicant__c> getApplicantNames(String applicationId){
        List<Loan_Applicant__c> listOfApplicants; 
        if(applicationId != null)
        listOfApplicants = [Select ID,Customer_Information__r.Name From Loan_Applicant__c where Application__c =:applicationId];
        
        return listOfApplicants;
    }
    
      @AuraEnabled
    public static List<Loan_Applicant__c> getApplicantAddress(String applicantId){
        List<Loan_Applicant__c> listOfApplicants; 
        if(applicantId != null)
        listOfApplicants = [Select ID,Name, Residence_Flat_Plot_Number__c, Residence_Address_Line_1__c, Residence_Address_Line_2__c,
        Residence_Village__c, Residence_City__c, Residence_Taluka__c, Residence_District__c, Residence_State__c, Residence_Pincode__c,
        Business_Pincode__c, Business_State__c, Business_District__c, Business_Taluka__c, Business_City__c, Business_Village__c,
        Business_Address_Line_2__c, Business_Address_Line_1__c, Business_Flat_Plot_Number__c, Permanent_Flat_Plot_Number__c, Permanent_Address_Line_1__c,
        Permanent_Address_Line_2__c, Permanent_Landmark__c, Permanent_Village__c, Permanent_City__c, Permanent_Taluka__c, Permanent_District__c, Permanent_State__c,
        Permanent_Pincode__c
         From Loan_Applicant__c where Id =:applicantId];
        
        return listOfApplicants;
    }
    
}