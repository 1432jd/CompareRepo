/**
* @File Name          : StagingLoan_Batch.cls
* @Description        : StagingLoan_Batch Class Used To Import Data From Staging Object To Respectives Objects
* @Author             : Parag Goyal
* @Created On         : 29/09/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        29/09/2022              Parag Goyal             Initial Version
*/
public class StagingLoan_Batch /*implements Database.Batchable<sObject>*/{
    
    /*List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Loan__c')+' FROM Staging_Loan__c';
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Staging_Loan__c> scope){        
        Set<String> loanAccountNumberSet = new Set<String>();
        Set<String> cifids = new Set<String>();
        for(Staging_Loan__c s : scope){
            loanAccountNumberSet.add(s.Loan_Account_No__c);
            cifids.add(s.Neo_Cif_Id__c);
        }
        
        Map<String,String> applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet);
        Map<String,String> customMaps = StagingBatchHelper.getCustomerIds(cifids);
        List<sObject> updateObjList = new List<sObject>();
        List<sObject> insertObjList = new List<sObject>();
        for(Staging_Loan__c s : scope){
            if(applicationIds.containsKey(s.Loan_Account_No__c)){
                Application__c aapp = new Application__c(
                    Id = applicationIds.get(s.Loan_Account_No__c)
                );
                aapp.Sourcing_Branch__c = StagingBatchHelper.getBranchIds(s.Branch_Name__c);
                aapp.Alternate_Channel_Mode__c = s.Alternate_Channel_Mode__c;
                aapp.Channel__c = s.Channel__c;
                aapp.Customer_Request_Amount__c = s.Customer_Requested_Loan_Amount__c;
                aapp.DPD__c = String.valueOf(s.Dpd__c);
                aapp.DBR__c = s.Dbr__c;
                aapp.EMI__c = s.Emi__c;
                aapp.Field_Officer_Name__c = s.Field_Officer_Name__c;
                aapp.Field_Officer_Emp_Id__c = StagingBatchHelper.getUserId(s.Field_Officer_Id__c);
                //aapp.Loan_Purpose_1__c = s.Loan_Purpose__c;
                aapp.Amount_Recommended__c = s.Loan_Amount__c;
                //aapp.Total_Amount_Recommended_PcAc__c = s.Loan_Amount__c;
                aapp.LTV__c = s.Ltv__c;
                aapp.Old_Collateral_value__c = Decimal.valueOf(s.Old_Collateral_Value__c);
                aapp.Old_Loan_Gross_Income__c = s.Old_Loan_Gross_Income__c;
                aapp.Old_Loan_Net_Income__c = s.Old_Loan_Net_Income__c;
                aapp.Old_Loan_Obligationss__c = String.valueOf(s.Old_Loan_Obligations__c);
                updateObjList.add(aapp);
                
                Capability__c cap = new Capability__c();
                cap.Loan_Applicant__c = customMaps.get(s.Neo_Cif_Id__c);
                /*if(s.Agricultural_Income__c != null)
                    cap.Gross_Monthly_Income__c = s.Agricultural_Income__c;
                if(s.Business_Income__c != null)
                    cap.Gross_Monthly_Income__c = s.Business_Income__c;
                cap.Rental_Income__c = s.Rentral_Income__c;
                cap.Monthly_Salary__c = s.Salary_Income__c;
                if(s.Pension_Income__c != null)
                    cap.Income_per_month__c = s.Pension_Income__c;
                if(s.Other_Income__c != null)
                    cap.Income_per_month__c = s.Other_Income__c;
                if(s.Nri_Income__c != null)
                    cap.Income_per_month__c = s.Nri_Income__c;
                
                if(StagingBatchHelper.getCapabilityId(customMaps.get(s.Neo_Cif_Id__c)) != null){
                    cap.Id = StagingBatchHelper.getCapabilityId(customMaps.get(s.Neo_Cif_Id__c));
                    updateObjList.add(cap);
                }
                else{
                    insertObjList.add(cap);
                }
                
                /*Bank_Detail__c bank = new Bank_Detail__c();
                bank.Loan_Applicant__c = customMaps.get(s.Neo_Cif_Id__c);
                bank.Application__c = applicationIds.get(s.Loan_Account_No__c);
                bank.Account_Number__c = String.valueOf(s.Account_Number__c);
                if(StagingBatchHelper.getBankId(customMaps.get(s.Neo_Cif_Id__c)) != null){
                    bank.Id = StagingBatchHelper.getBankId(customMaps.get(s.Neo_Cif_Id__c));
                    updateObjList.add(bank);
                }
                else{
                    insertObjList.add(bank);
                }
            }
        }
        if(updateObjList.size() > 0)
        	updateResult = DATABASE.UPDATE(updateObjList);
        if(insertObjList.size() > 0)
        	DATABASE.INSERT(insertObjList);
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Finish');
        if(updateResult.size() > 0)
        	StagingBatchHelper.deleteLoanRecords(updateResult);
    }*/
    
}