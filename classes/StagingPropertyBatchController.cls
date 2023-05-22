global without sharing class StagingPropertyBatchController implements Database.Batchable<sObject> {
    global Map<String,String> applicationIds = new Map<String, String>();
    global Map<String,String> preLoginMap = new Map<String, String>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //Set<String> loanId = new Set<String>{'APPL00334407','APPL00322733','APPL00332291','APPL00330292','APPL00330394','APPL00332750','APPL00334007','APPL00323370','APPL00327776','APPL00325017','APPL00319159','APPL00324696','APPL00331167','APPL00333672','APPL00332641','APPL00336572','APPL00337976','APPL00332990','APPL00334069','APPL00326556','APPL00327141','APPL00337169','APPL00327075','APPL00334158','APPL00332961','APPL00330420','APPL00336349'};
        // WHERE Application_Number__c IN :loanId
        String query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Property__c')+' FROM '+'Staging_Property__c';
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        System.debug('Property Executing...');
        Set<String> loanAccountNumberSet = new Set<String>();
        List<Property__c> propertyList = new List<Property__c>();
        Map<String, Property__c> propertyMap = new Map<String, Property__c>();
        for(Staging_Property__c s : (List<Staging_Property__c>)scope){
            loanAccountNumberSet.add(s.Loan_Account_No__c);
        }
        if(!loanAccountNumberSet.isEmpty()){
            applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet);
            preLoginMap = StagingBatchHelper.getPreLoginIds(loanAccountNumberSet);
        }
        
        System.debug('Application Ids '+applicationIds);
        for(Staging_Property__c s : (List<Staging_Property__c>)scope){
            System.debug('Insert Prop');
            if(applicationIds.containsKey(s.Loan_Account_No__c)){
                Property__c ObjProp = new Property__c();
                if(propertyMap.containsKey(s.Loan_Account_No__c+'_'+s.Collateral_Id__c)){
                    ObjProp = propertyMap.get(s.Loan_Account_No__c+'_'+s.Collateral_Id__c);
                }
                else{
                    ObjProp = new Property__c();
                }
                objProp.Application__c = applicationIds.get(s.Loan_Account_No__c);
                objProp.Login__c = preLoginMap.get(s.Loan_Account_No__c);
                objProp.Property_Address__c = s.Address_Line_2__c+' '+s.Address_Line_3__c;
                objProp.Age_Of_Property__c = s.Age_Of_Property__c!=null?Decimal.valueOf(s.Age_Of_Property__c):0;
                objProp.Building_Area_Sq_Ft__c = s.Building_Area__c;
                objProp.Carpet_Area__c = String.valueOf(s.Carpet_Area__c);
                objProp.City__c = s.City__c;
                objProp.Co_Owner_Name__c = s.Co_Owner_Name__c;
                objProp.District__c = s.District__c;
                objProp.East_by__c = s.Eastby__c;
                objProp.East_by_land_measurements__c = s.Eastby1__c!=null?Decimal.valueOf(s.Eastby1__c):0;
                objProp.Flat_Plot_Number__c = s.Flat_Plot_Number__c;
                objProp.Nature_Of_Property__c = s.Nature_Of_Property__c;
                objProp.North_by__c = s.Northby__c;
                objProp.North_by_land_measurements__c = s.Northby1__c!=null?Decimal.valueOf(s.Northby1__c):0;
                objProp.Property_Location_Classification__c = s.Property_Location_Classification__c;
                objProp.Property_Purchased_Type__c = StagingBatchHelper.propPurchaseTypeMap.containsKey(s.Property_Purchased_Type__c)?StagingBatchHelper.propPurchaseTypeMap.get(s.Property_Purchased_Type__c):s.Property_Purchased_Type__c;
                objProp.Property_Purpose__c = StagingBatchHelper.propPurposeMap.containsKey(s.Property_Purpose__c)?StagingBatchHelper.propPurposeMap.get(s.Property_Purpose__c):s.Property_Purpose__c;
                objProp.Property_Type__c = StagingBatchHelper.propertyTypeMap.containsKey(s.Property_Type__c)?StagingBatchHelper.propertyTypeMap.get(s.Property_Type__c):s.Property_Type__c;
                objProp.Proposed_Area__c = s.Proposed_Area__c;
                objProp.Residual_Age_Of_Property__c = StagingBatchHelper.residualAgeOfPropMap.containsKey(s.Residual_Age_of_property__c)?StagingBatchHelper.residualAgeOfPropMap.get(s.Residual_Age_of_property__c):s.Residual_Age_of_property__c;
                objProp.South_by__c = s.Southby__c;
                objProp.South_by_land_measurements__c = s.Southby1__c!=null?Decimal.valueOf(s.Southby1__c):0;
                objProp.State__c = s.State__c;
                objProp.Title_Deed_Date__c = s.Title_Deed_Date__c;
                objProp.Title_Deed_Number__c = String.valueOf(s.Title_Deed_Number__c);
                objProp.Title_Deed_Type__c = StagingBatchHelper.titleDeedTypeMap.containsKey(s.Title_Deed_Type__c)?StagingBatchHelper.titleDeedTypeMap.get(s.Title_Deed_Type__c):s.Title_Deed_Type__c;
                objProp.Village__c = s.Village__c;
                objProp.West_by__c = s.Westby__c;
                objProp.West_by_land_measurements__c = s.Westby1__c!=null?Decimal.valueOf(s.Westby1__c):0;
                objProp.Property_ID__c = s.Collateral_Id__c;
                objProp.Valuation_Market_Value_Per_SqFt__c = s.Market_Value__c;
                objProp.Land_Area_Sq_Ft__c = 1;
                objProp.Market_Value_Of_Property__c = s.Market_Value__c;
                objProp.Staging_External_Id__c = s.Loan_Account_No__c+'_'+s.Collateral_Id__c;
                propertyMap.put(s.Loan_Account_No__c+'_'+s.Collateral_Id__c, objProp);
            }
        }
        if(!propertyMap.isEmpty()){
            propertyList.addAll(propertyMap.values());
        }
        if(!propertyList.isEmpty()){
            System.debug('propertyList '+propertyList);
            Set<String> failedRecords = new Set<String>();
            Set<String> successRecords = new Set<String>();
            Map<String, Property__c> parentPropertyMap = new Map<String, Property__c>();
            Map<String, String> failedloanAccNoMap = new Map<String, String>();
            Set<String> successloanAccNoSet = new set<String>();
            List<Staging_Property__c> listToDelete = new List<Staging_Property__c>();
            List<Staging_Property__c> listToUpdate = new List<Staging_Property__c>();
            List<Property__c> updatePropList = new List<Property__c>();
            List<Property__c> newPropList = new List<Property__c>();
            Map<String, String> applicationIdErrorMap = new Map<String, String>();
            Schema.SObjectField ftoken = Property__c.Fields.Staging_External_Id__c;
            List<Database.UpsertResult> result = Database.UPSERT(propertyList,ftoken, false);
            for(Integer i=0;i<result.size();i++){
                if(result.get(i).isSuccess()){
                    successRecords.add(propertyList.get(i).Application__c);
                    if(result.get(i).isCreated()){
                        String recordTypesToCreate = System.Label.Property_RecordTypes_To_Clone;
                        List<String> recordTypeNames = recordTypesToCreate.split(',');
                        if(!propertyList.get(i).hasRelatedRecords__c){
                            for(String rcName : recordTypeNames){
                                Property__c newProperty = propertyList.get(i).clone(false,false,false,true);
                                newProperty.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get(rcName).getRecordTypeId();
                                newProperty.Application__c = propertyList.get(i).Application__c;
                                newProperty.Property__c = propertyList.get(i).Id;
                                newProperty.Staging_External_Id__c = null;
                                newPropList.add(newProperty);
                            }
                            propertyList.get(i).hasRelatedRecords__c = true; 
                        }
                        updatePropList.add(propertyList.get(i));
                    }
                    else{
                        System.debug('Updated');
                        parentPropertyMap.put(result.get(i).getId(), propertyList.get(i));
                    }
                }
                else{
                    Database.Error errMsg = result.get(i).getErrors().get(0);
                    failedRecords.add(propertyList.get(i).Application__c);
                    applicationIdErrorMap.put(propertyList.get(i).Application__c, errMsg.getMessage());
                }
            }
            if(!parentPropertyMap.isEmpty()){
                Set<String> proIds = new Set<String>();
                proIds.addAll(parentPropertyMap.keySet());
                List<Property__c> childPropertyToUpdate = new List<Property__c>();
                List<Property__c> childProperties = new List<Property__c>();
                String query = 'SELECT Id, '+Utility.getFieldAPINames('Property__c')+' FROM Property__c WHERE Property__c In :proIds';
                System.debug('Property Query = '+query);
                childProperties = Database.query(query);
                System.debug('childProperties Size '+childProperties.size());
                for(Property__c objProp : childProperties){
                    if(parentPropertyMap.containsKey(objProp.Property__c)){
                        Property__c parentProperty = parentPropertyMap.get(objProp.Property__c);
                        objProp.Property_Ownership__c = parentProperty.Property_Ownership__c;
                        objProp.Market_Value_Of_Property__c = parentProperty.Market_Value_Of_Property__c;
                        objProp.Land_Area_Sq_Ft__c = parentProperty.Land_Area_Sq_Ft__c;
                        objProp.Valuation_Market_Value_Per_SqFt__c = parentProperty.Valuation_Market_Value_Per_SqFt__c;
                        objProp.LMS_Collateral_Number__c = parentProperty.LMS_Collateral_Number__c;
                        objProp.West_by_land_measurements__c = parentProperty.West_by_land_measurements__c;
                        objProp.West_by__c = parentProperty.West_by__c;
                        objProp.Village__c = parentProperty.Village__c;
                        objProp.Title_Deed_Type__c = parentProperty.Title_Deed_Type__c;
                        objProp.Title_Deed_Number__c = parentProperty.Title_Deed_Number__c;
                        objProp.Title_Deed_Date__c = parentProperty.Title_Deed_Date__c;
                        objProp.State__c = parentProperty.State__c;
                        objProp.South_by_land_measurements__c = parentProperty.South_by_land_measurements__c;
                        objProp.South_by__c = parentProperty.South_by__c;
                        objProp.Residual_Age_Of_Property__c = parentProperty.Residual_Age_Of_Property__c;
                        objProp.Proposed_Area__c = parentProperty.Proposed_Area__c;
                        objProp.Property_Type__c = parentProperty.Property_Type__c;
                        objProp.Property_Purpose__c = parentProperty.Property_Purpose__c;
                        objProp.Property_Purchased_Type__c = parentProperty.Property_Purchased_Type__c;
                        objProp.Property_Location_Classification__c = parentProperty.Property_Location_Classification__c;
                        objProp.North_by_land_measurements__c = parentProperty.North_by_land_measurements__c;
                        objProp.North_by__c = parentProperty.North_by__c;
                        objProp.Nature_Of_Property__c = parentProperty.Nature_Of_Property__c;
                        objProp.Flat_Plot_Number__c = parentProperty.Flat_Plot_Number__c;
                        objProp.East_by_land_measurements__c = parentProperty.East_by_land_measurements__c;
                        objProp.East_by__c = parentProperty.East_by__c;
                        objProp.District__c = parentProperty.District__c;
                        objProp.Co_Owner_Name__c = parentProperty.Co_Owner_Name__c;
                        objProp.City__c = parentProperty.City__c;
                        objProp.Application__c = parentProperty.Application__c;
                        objProp.Login__c = parentProperty.Login__c;
                        objProp.Property_Address__c = parentProperty.Property_Address__c;
                        objProp.Age_Of_Property__c = parentProperty.Age_Of_Property__c;
                        objProp.Building_Area_Sq_Ft__c = parentProperty.Building_Area_Sq_Ft__c;
                        objProp.Carpet_Area__c = parentProperty.Carpet_Area__c;
                        childPropertyToUpdate.add(objProp);
                    }
                }
                if(!childPropertyToUpdate.isEmpty()){
                    update childPropertyToUpdate;
                }
            }
            if(successRecords.size()>0 || failedRecords.size()>0){
                System.debug('successRecords '+successRecords.size());
                System.debug('failedRecords '+failedRecords.size());
                for(Application__c app : [SELECT Id, LMS_Response_Reference__c FROM Application__c WHERE Id In : successRecords OR Id In : failedRecords]){
                    if(successRecords.contains(app.Id)){
                        successloanAccNoSet.add(app.LMS_Response_Reference__c);
                    }
                    if(failedRecords.contains(app.Id)){
                        failedloanAccNoMap.put(app.LMS_Response_Reference__c, app.Id);
                    }
                }
                if(successloanAccNoSet.size()>0 || failedloanAccNoMap.size()> 0){
                    for(Staging_Property__c stPro : [SELECT Id, Loan_Account_No__c, Status__c, Error_Reason__c FROM Staging_Property__c WHERE Loan_Account_No__c IN : successloanAccNoSet OR Loan_Account_No__c IN : failedloanAccNoMap.keySet()]){
                        if(successloanAccNoSet.contains(stPro.Loan_Account_No__c)){
                            listToDelete.add(stPro);
                        }
                        if(failedloanAccNoMap.containsKey(stPro.Loan_Account_No__c)){
                            stPro.State__c = 'Failed';
                            stPro.Error_Reason__c = applicationIdErrorMap.get(failedloanAccNoMap.get(stPro.Loan_Account_No__c));
                            listToUpdate.add(stPro);
                        }
                    }
                }
                /************* Commented Untill UAT Sign-OFF ********************/
                if(!listToDelete.isEmpty() && !Test.isRunningTest())
				delete listToDelete;
                if(!listToUpdate.isEmpty())
                    update listToUpdate;
            }
            if(!updatePropList.isEmpty())
                update updatePropList;
            if(!newPropList.isEmpty())
                insert newPropList;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('final Executing... ');
        Database.executeBatch(new StagingLoanBatchController(true), 1000);
    }
}