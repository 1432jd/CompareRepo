/**
* @File Name          : StagingProperty_Batch.cls
* @Description        : StagingProperty_Batch Class Used To Import Data From Staging Object To Respectives Objects
* @Author             : Parag Goyal
* @Created On         : 30/09/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        30/09/2022              Parag Goyal             Initial Version
*/
public class StagingProperty_Batch implements Database.Batchable<sObject>{
    
    List<Database.SaveResult> insertResult = new List<Database.SaveResult>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Property__c')+' FROM Staging_Property__c';
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Staging_Property__c> scope){
        System.debug('Execute');
        Set<String> loanAccountNumberSet = new Set<String>();
        //Set<String> cifids = new Set<String>();
        for(Staging_Property__c s : scope){
            loanAccountNumberSet.add(s.Loan_Account_No__c);
            //cifids.add(s.Neo_Cif_Id__c);
        }
        
        Map<String,String> applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet); 
        //Map<String,String> customMaps = StagingBatchHelper.getCustomerIds(cifids);
        List<sObject> insertObjList = new List<sObject>();
        List<sObject> updateObjList = new List<sObject>();
        for(Staging_Property__c s : scope){
            if(applicationIds.containsKey(s.Loan_Account_No__c)){
                Property__c objProp = StagingBatchHelper.insertProperty(s);
                objProp.Application__c =  applicationIds.get(s.Loan_Account_No__c);
                //Property__c objProp = new Property__c(Application__c = applicationIds.get(s.Loan_Account_No__c));
                objProp.Login__c = StagingBatchHelper.getPreloginIds(applicationIds.get(s.Loan_Account_No__c));
                /*objProp.Property_Address__c = s.Address_Line_2__c+' '+s.Address_Line_3__c;
                objProp.Age_Of_Property__c = Decimal.valueOf(s.Age_Of_Property__c);
                objProp.Building_Area_Sq_Ft__c = s.Building_Area__c;
                objProp.Carpet_Area__c = String.valueOf(s.Carpet_Area__c);
                objProp.City__c = s.City__c;
                objProp.Co_Owner_Name__c = s.Co_Owner_Name__c;
                objProp.District__c = s.District__c;
                objProp.East_by__c = s.Eastby__c;
                objProp.East_by_land_measurements__c = Decimal.valueOf(s.Eastby1__c);
                objProp.Flat_Plot_Number__c = s.Flat_Plot_Number__c;
                objProp.Nature_Of_Property__c = s.Nature_Of_Property__c;
                objProp.North_by__c = s.Northby__c;
                objProp.North_by_land_measurements__c = Decimal.valueOf(s.Northby1__c);
                objProp.Property_Location_Classification__c = s.Property_Location_Classification__c;
                objProp.Property_Ownership__c = s.Property_Ownership__c;
                objProp.Property_Purchased_Type__c = s.Property_Purchased_Type__c;
                objProp.Property_Purpose__c = s.Property_Purpose__c;
                objProp.Property_Type__c = s.Property_Type__c;
                objProp.Proposed_Area__c = s.Proposed_Area__c;
				objProp.Residual_Age_Of_Property__c = s.Residual_Age_of_property__c;
				objProp.South_by__c = s.Southby__c;
                objProp.South_by_land_measurements__c = Decimal.valueOf(s.Southby1__c);
				objProp.State__c = s.State__c;
				objProp.Title_Deed_Date__c = s.Title_Deed_Date__c;
                objProp.Title_Deed_Number__c = String.valueOf(s.Title_Deed_Number__c);
                objProp.Title_Deed_Type__c = s.Title_Deed_Type__c;
                objProp.Village__c = s.Village__c;
                objProp.West_by__c = s.Westby__c;
                objProp.West_by_land_measurements__c = Decimal.valueOf(s.Westby1__c);
                objProp.Property_ID__c = s.Collateral_Id__c;
                objProp.Valuation_Market_Value_Per_SqFt__c = s.Market_Value__c;
                objProp.Land_Area_Sq_Ft__c = 1;*/
                insertObjList.add(objProp);
            }
        }    
        if(insertObjList.size() > 0)
           insertResult = DATABASE.INSERT(insertObjList);
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Finish');
        if(insertResult.size() > 0)
        	StagingBatchHelper.deletePropRecords(insertResult);
    }
    
}