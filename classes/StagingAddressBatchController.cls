global without sharing class StagingAddressBatchController implements Database.Batchable<sObject>{
    //, Database.stateful
    global Map<String,String> pincodeMap = new Map<String, String>();
    global Map<String,String> customMaps = new Map<String, String>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //Set<String> loanId = new Set<String>{'APPL00334407','APPL00322733','APPL00332291','APPL00330292','APPL00330394','APPL00332750','APPL00334007','APPL00323370','APPL00327776','APPL00325017','APPL00319159','APPL00324696','APPL00331167','APPL00333672','APPL00332641','APPL00336572','APPL00337976','APPL00332990','APPL00334069','APPL00326556','APPL00327141','APPL00337169','APPL00327075','APPL00334158','APPL00332961','APPL00330420','APPL00336349'};
        //WHERE Loan_Account_No__c In : loanId
        String query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Address__c')+' FROM '+'Staging_Address__c';
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        System.debug('execute running...');
        Set<String> cifids = new Set<String>();
        Set<String> pincodeSet = new Set<String>();
        Map<Id, Loan_Applicant__c> loanAPPMap = new Map<Id, Loan_Applicant__c>();
        for(Staging_Address__c s : (List<Staging_Address__c>)scope){            
            cifids.add(s.Neo_Cif_Id__c);
            pincodeSet.add(s.Pincode__c);
        }
        System.debug('cifids '+cifids.size());
        System.debug('pincodeSet '+pincodeSet);

        if(!cifids.isEmpty())
			customMaps = StagingBatchHelper.getCustomerIds(cifids);
        System.debug('customMaps '+customMaps);
        if(!pincodeSet.isEmpty())
            pincodeMap = StagingBatchHelper.getPinIds(pincodeSet);
        System.debug('Pincodes '+pincodeMap);
        for(Staging_Address__c s : (List<Staging_Address__c>)scope){            
            if(customMaps.containsKey(s.Neo_Cif_Id__c)){
                System.debug('Entry Point...');
                Loan_Applicant__c la = new Loan_Applicant__c();
                if(loanAPPMap.containsKey(customMaps.get(s.Neo_Cif_Id__c))){
                    la = loanAPPMap.get(customMaps.get(s.Neo_Cif_Id__c));
                }
                else{
                    la = new Loan_Applicant__c(Id = customMaps.get(s.Neo_Cif_Id__c));
                }
                la.Ownership_Type__c = s.Ownership_Type__c;
                la.LMS_Customer_Info_File_Number__c = s.Neo_Cif_Id__c;
                if(s.Address_Type__c == 'ResidentialAddress'){
                    la.Residence_City__c = s.City__c;
                    la.Residence_Country__c = s.Country__c;
                    la.Residence_District__c = s.District__c;
                    la.Residence_Flat_Plot_Number__c = s.Flat_Plot_Number__c;
                    if(pincodeMap.containsKey(s.Pincode__c)){
                        System.debug('Pin Code '+pincodeMap.get(s.Pincode__c));
                        la.Residence_Pincode__c = pincodeMap.get(s.Pincode__c);
                    }
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
                    if(pincodeMap.containsKey(s.Pincode__c)){
                        System.debug('Pin Code '+pincodeMap.get(s.Pincode__c));
                        la.Permanent_Pincode__c = pincodeMap.get(s.Pincode__c);
                    }
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
                    if(pincodeMap.containsKey(s.Pincode__c)){
                        System.debug('Pin Code '+pincodeMap.get(s.Pincode__c));
                        la.Business_Pincode__c = pincodeMap.get(s.Pincode__c);
                    }
                    la.Business_State__c = s.State__c;
                    la.Business_Taluka__c = s.Taluka__c;
                    la.Business_Village__c = s.Village__c;
                    la.Business_Address_Line_1__c = s.Address_Line_2__c;
                    la.Business_Address_Line_2__c = s.Address_Line_3__c;
                }
                System.debug('la '+la);
                loanAPPMap.put(la.Id, la);
            }
        }
        System.debug('loanAPPMap '+loanAPPMap);
        if(!loanAPPMap.isEmpty()){
            Set<String> faileRecords = new Set<String>();
            Set<String> sucessRecords = new Set<String>();
            Map<String, String> failedRecordMap = new Map<String, String>();
            List<sObject> sObjectToDelete = new List<sObject>();
            List<sObject> sObjectToUpdate = new List<sObject>();
            List<Database.UpsertResult> result = Database.upsert(loanAPPMap.values(), false);
            System.debug('result '+result);
            for(Integer i=0; i<result.size();i++){
                if(result.get(i).isSuccess()){
                    sucessRecords.add(loanAPPMap.get(result.get(i).getId()).LMS_Customer_Info_File_Number__c);
                }
                else{
                    Database.Error errMsg = result.get(i).getErrors().get(0);
                    faileRecords.add(loanAPPMap.get(result.get(i).getId()).LMS_Customer_Info_File_Number__c);
                    failedRecordMap.put(loanAPPMap.get(result.get(i).getId()).LMS_Customer_Info_File_Number__c,errMsg.getFields()+'\n'+errMsg.getMessage());
                }
            }
            for(Staging_Address__c address : [SELECT Id, Neo_Cif_Id__c, Status__c, Error_Reason__c FROM Staging_Address__c WHERE Neo_Cif_Id__c In : sucessRecords OR Neo_Cif_Id__c In : faileRecords]){
                if(sucessRecords.contains(address.Neo_Cif_Id__c)){
                    sObjectToDelete.add(address);
                    //temporary
                    /*address.Status__c = 'Process';
                    address.Error_Reason__c = null;
                    sObjectToUpdate.add(address);*/
                }
                else{
                    address.Status__c = 'Failed';
                    address.Error_Reason__c = failedRecordMap.get(address.Neo_Cif_Id__c);
                    sObjectToUpdate.add(address);
                }
            }
            if(!sObjectToDelete.isEmpty()){
                /**************** Commented Untill UAT Sign-Off *******************/
                delete sObjectToDelete;
            }
            if(!sObjectToUpdate.isEmpty()){
                update sObjectToUpdate;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        Database.executeBatch(new StagingPropertyBatchController(), 1000);
    }
}