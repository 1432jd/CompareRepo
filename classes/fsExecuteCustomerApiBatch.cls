public class fsExecuteCustomerApiBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {


        public List<Loan_Applicant__c> loanAppListList = new List<Loan_Applicant__c>();
        public fsExecuteCustomerApiBatch(List<Loan_Applicant__c> loanList){
            loanAppListList.addAll(loanList);
        }
    
        public  Database.QueryLocator start(Database.BatchableContext bc){
            return Database.getQueryLocator ('SELECT Id, Name, Application__c, Customer_Information__c, Customer_Type__c, Applicant_Name__c, Constitution__c, Is_Bureau_Verified__c, Initiate_From__c, Husband_Wife_s_Name__c, Guardian_Name__c, Marital_Status__c, Resident_Type__c, Person_With_Disability__c, KYC_ID_Type_1__c, KYC_ID_Type_2__c, Ownership_Status__c, Ownership_Type__c, Duration_At_This_Address_From__c, Duration_At_This_Address_To__c, Duration_At_This_City_From__c, Duration_At_This_City_To__c, Communication_Address__c, Mobile__c, Email__c, Residence_Country__c, Residence_Flat_Plot_Number__c, Residence_Address_Line_1__c, Residence_Address_Line_2__c, Residence_Pincode__c, Residence_Village__c, Residence_Taluka__c, Residence_City__c, Residence_District__c, Residence_State__c, Permanent_Country__c, Permanent_Flat_Plot_Number__c, Permanent_Address_Line_1__c, Permanent_Address_Line_2__c, Permanent_Pincode__c, Permanent_Village__c, Permanent_Taluka__c, Permanent_City__c, Permanent_District__c, Permanent_State__c, Business_Country__c, Business_Flat_Plot_Number__c, Business_Address_Line_1__c, Business_Address_Line_2__c, Business_Pincode__c, Business_Village__c, Business_Taluka__c, Business_City__c, Business_District__c, Business_State__c, Same_As_Address_Pernament__c, Same_As_Address_Business__c, Income_Considered__c, KYC_Id_1__c, KYC_Id_2__c, Applicant_Type__c, Married__c, Mobile_Verified__c, Residence_Landmark__c, Permanent_Landmark__c, Business_Landmark__c, Phone_Office__c, Phone_Residence__c, Verification_Type__c, Is_Lead_Detail_Done__c, LMS_Customer_Info_File_Number__c, Is_KYC_Verified__c, CKYC_ID_Number__c, Applicant_Customer_ID__c, State_Code__c, Created_From__c, isRetrigger__c, cifId__c, Pre_Login_Record_Type__c, Old_Applicant_Id__c, Is_KYC_ID_Change__c, IsDedupeExecuted__c FROM Loan_Applicant__c where Id IN :loanAppListList');       
        }

         public void execute(Database.BatchableContext bc, List<Loan_Applicant__c> loanApptList){
                FS_LMS_CreateCustomerAPI.createCustomer(loanApptList[0].Id);
         }

         public  void finish(Database.BatchableContext bc){
         }



}