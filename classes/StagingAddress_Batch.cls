/**
* @File Name          : StagingAddress_Batch.cls
* @Description        : StagingAddress_Batch Class Used To Import Data From Staging Object To Respectives Objects
* @Author             : Parag Goyal
* @Created On         : 29/09/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        29/09/2022              Parag Goyal             Initial Version
*/
public class StagingAddress_Batch implements Database.Batchable<sObject>{
    
    List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Address__c')+' FROM Staging_Address__c';
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Staging_Address__c> scope){        
        Set<String> cifids = new Set<String>();
        for(Staging_Address__c s : scope){            
            cifids.add(s.Neo_Cif_Id__c);
        }
        Map<String,String> customMaps = StagingBatchHelper.getCustomerIds(cifids);
        List<sObject> updateObjList = new List<sObject>();
        for(Staging_Address__c s : scope){
            if(customMaps.containsKey(s.Neo_Cif_Id__c)){
                Loan_Applicant__C la = new Loan_Applicant__C(
                    Id = customMaps.get(s.Neo_Cif_Id__c)                    
                );
                la.Ownership_Type__c = s.Ownership_Type__c;
                if(s.Address_Type__c == 'ResidentialAddress'){
                    la.Residence_City__c = s.City__c;
                    la.Residence_Country__c = s.Country__c;
                    la.Residence_District__c = s.District__c;
                    la.Residence_Flat_Plot_Number__c = s.Flat_Plot_Number__c;
                    la.Residence_Pincode__c = s.Pincode__c;
                    la.Residence_State__c = s.State__c;
                    la.Residence_Taluka__c = s.Taluka__c;
                    la.Residence_Village__c = s.Village__c;
                    la.Residence_Address_Line_1__c = s.Address_Line_2__c;
                    la.Residence_Address_Line_2__c = s.Address_Line_3__c;
                }
                if(s.Address_Type__c == 'PermanentAddress'){
                    la.Permanent_City__c = s.City__c;
                    la.Permanent_Country__c = s.Country__c;
                    la.Permanent_District__c = s.District__c;
                    la.Permanent_Flat_Plot_Number__c = s.Flat_Plot_Number__c;
                    la.Permanent_Pincode__c = s.Pincode__c;
                    la.Permanent_State__c = s.State__c;
                    la.Permanent_Taluka__c = s.Taluka__c;
                    la.Permanent_Village__c = s.Village__c;
                    la.Permanent_Address_Line_1__c = s.Address_Line_2__c;
                    la.Permanent_Address_Line_2__c = s.Address_Line_3__c;
                }
                if(s.Address_Type__c == 'BusinessAddress'){
                    la.Business_City__c = s.City__c;
                    la.Business_Country__c = s.Country__c;
                    la.Business_District__c = s.District__c;
                    la.Business_Flat_Plot_Number__c = s.Flat_Plot_Number__c;
                    la.Business_Pincode__c = s.Pincode__c;
                    la.Business_State__c = s.State__c;
                    la.Business_Taluka__c = s.Taluka__c;
                    la.Business_Village__c = s.Village__c;
                    la.Permanent_Address_Line_1__c = s.Address_Line_2__c;
                    la.Permanent_Address_Line_2__c = s.Address_Line_3__c;
                }
                updateObjList.add(la);
            }
        }
        if(updateObjList.size() > 0)
        	updateResult = DATABASE.UPDATE(updateObjList);
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Finish');
        if(updateResult.size() > 0)
        	StagingBatchHelper.deleteLoanRecords(updateResult);
    }
    
}