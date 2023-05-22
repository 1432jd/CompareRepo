/**
* @File Name          : Staging_Batch.cls
* @Description        : Staging_Batch Class Used To Import Data From Staging Object To Respectives Objects
* @Author             : Mo Arslan
* @Created On         : 15/10/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        15/10/2022              Mo Arslan               Initial Version
*/
public class Staging_Batch implements Schedulable,Database.Batchable<sObject>{
    List<Database.SaveResult> insertResult = new List<Database.SaveResult>();
    List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
    public Set<String> loanAccountNumberSet = new Set<String>();
    public Set<String> cifids = new Set<String>();
    public Set<String> pincodes = new Set<String>();
    public Set<String> branchSet = new Set<String>();
    public Set<String> empIds = new Set<String>(); 
    public Map<String,String> applicationIds = new Map<String, String>();
    public Map<String,String> customMaps = new Map<String, String>();
    public Map<String,String> capabilityMap = new Map<String, String>();
    public Map<String,String> incomeMap = new Map<String, String>();
    public Map<String,String> pincodeMap = new Map<String, String>();
    public Map<String,String> familyMap = new Map<String, String>();
    public Map<String,String> employmentDetailsMap = new Map<String, String>();
    public Map<String,String> preLoginMap = new Map<String, String>();
    public Map<String,String> branchMap = new Map<String, String>();
    public Map<String,String> userMap = new Map<String, String>();
    public List<sObject> insertObjList = new List<sObject>();
    public List<sObject> updateObjList = new List<sObject>();
    public Set<String> neoCIfFromCapability = new Set<String>();
    List<Database.SaveResult> insertData = new List<Database.SaveResult>();
    List<String> processRecordId = new List<String>();
    public Integer batchSequence = 1;
    String query = '';
    public Map<Integer, String> batchObjectMap = new Map<Integer, String>{1 => 'Staging_Loan__c', 2 => 'Staging_Customer__c', 3 => 'Staging_Address__c', 4 => 'Staging_Property__c', 5 => 'Staging_Loan__c'};
        
        
        public Staging_Batch(){
            System.debug('CSV Batch Processing Started...');
        }
    
    public Staging_Batch(Integer sequence){
        batchSequence = sequence;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT Id, '+Utility.getFieldAPINames(batchObjectMap.get(batchSequence))+' FROM '+batchObjectMap.get(batchSequence);
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('Execute');
        Savepoint sp = Database.setSavepoint();
        //try{
        if(scope.size()>0){
            System.debug('scope.size() '+scope.size());
            //Staging Loan To Create/Update Application,Prelogin,Income and Capability.
            if(String.valueOf(scope[0].getSObjectType())=='Staging_Loan__c'){
                System.debug('Objcet '+scope[0].getSObjectType());
                if(batchSequence<5){
                    Map<String, Application__c> applicationInsertMap = new Map<String, Application__c>();
                    Map<String, Application__c> applicationUpdateMap = new Map<String, Application__c>();
                    Map<String, Disbursal__c> disbursalMap = new Map<String, Disbursal__c>();
                    Map<String,Pre_Login__c> preloginMap = new Map<String,Pre_Login__c>();
                    for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                        loanAccountNumberSet.add(s.Loan_Account_No__c);
                        cifids.add(s.Neo_Cif_Id__c);
                        branchSet.add(s.Branch_Name__c);
                        empIds.add(s.Field_Officer_Id__c);
                    }
                    
                    System.debug('loanAccountNumberSet '+loanAccountNumberSet);
                    System.debug('cifids '+cifids);
                    
                    applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet);
                    customMaps = StagingBatchHelper.getCustomerIds(cifids);
                    branchMap = StagingBatchHelper.getBranchId(branchSet);
                    userMap = StagingBatchHelper.getUserIds(empIds);
                    System.debug('applicationIds '+applicationIds);
                    System.debug('customMaps '+customMaps);
                    for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                        if(!applicationIds.containsKey(s.Loan_Account_No__c)){
                            //Loan Account Number not exist then we need to create Pre Login
                            preloginMap.putAll(StagingBatchHelper.insertPrelogin(s));
                        }
                    }
                    System.debug('preloginMap '+preloginMap);
                    if(!preloginMap.isEmpty()){
                        DATABASE.INSERT(preloginMap.values(), false);
                    }
                    
                    for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                        if(!applicationIds.containsKey(s.Loan_Account_No__c)){
                            System.debug('To Create Application and Create Disbursal');
                            //Creating Application and Disbursal if Application not exist
                            insertObjList.addAll(StagingBatchHelper.insertApplication(s, applicationIds.get(s.Loan_Account_No__c),branchMap.get(s.Branch_Name__c),userMap.get(s.Field_Officer_Id__c)).values());
                            System.debug('Application Created');
                        }
                        else{
                            //Updating Application if it is exist
                            updateObjList.addAll(StagingBatchHelper.insertApplication(s, applicationIds.get(s.Loan_Account_No__c),branchMap.get(s.Branch_Name__c),userMap.get(s.Field_Officer_Id__c)).values());
                        } 
                    }
                    System.debug('insertObjList '+insertObjList);
                    if(!insertObjList.isEmpty()){
                        insertObjList.sort();
                        insertResult.addAll(Database.insert(insertObjList, false));
                        System.debug('insertObjList Insert');
                    }
                    applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet); 
                    for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                        if(applicationIds.containsKey(s.Loan_Account_No__c))
                            disbursalMap.putAll(StagingBatchHelper.insertDisbursal(s,applicationIds.get(s.Loan_Account_No__c)));
                    }
                    System.debug('updateObjList '+updateObjList);
                    if(!updateObjList.isEmpty()){
                        updateResult.addAll(Database.update(updateObjList, false));
                    }
                    System.debug('disbursalMap '+disbursalMap);
                    if(!disbursalMap.isEmpty()){
                        Database.insert(disbursalMap.values(), false);
                    }
                }
                else{
                    // Inserting or Updating
                    // Capability
                    // Income
                    
                    System.debug('Insise Else###');
                    for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                        loanAccountNumberSet.add(s.Loan_Account_No__c);
                        cifids.add(s.Neo_Cif_Id__c);
                    }
                    applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet);
                    customMaps = StagingBatchHelper.getCustomerIds(cifids);
                    capabilityMap = StagingBatchHelper.getCapabilityIds(cifids);
                    incomeMap = StagingBatchHelper.getIncomeIds(cifids);
                    System.debug('cifids '+cifids);
                    System.debug('customMaps '+customMaps);
                    for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                        neoCIfFromCapability.add(s.Neo_Cif_Id__c);
                        Capability__c cap = StagingBatchHelper.insertCapability(s,customMaps.get(s.Neo_Cif_Id__c));
                        if(capabilityMap.get(s.Neo_Cif_Id__c) != null){
                            System.debug('Getting Capablity Id and Update Capability');
                            cap.Id = capabilityMap.get(s.Neo_Cif_Id__c);
                            updateObjList.add(cap);
                        }
                        else{
                            insertObjList.add(cap);
                        }
                        
                        Income__c income = StagingBatchHelper.insertIncome(s,customMaps.get(s.Neo_Cif_Id__c));
                        if(incomeMap.get(s.Neo_Cif_Id__c) != null){
                            income.Id = incomeMap.get(s.Neo_Cif_Id__c);
                            updateObjList.add(income);
                        }
                        else{
                            System.debug('Add Capability In insertObjList to Insert');
                            insertObjList.add(income);
                        }
                    }
                    if(!updateObjList.isEmpty()){
                        updateObjList.sort();
                        updateResult.addAll(Database.update(updateObjList,false));
                    }
                    
                    if(!insertObjList.isEmpty()){
                        insertObjList.sort();
                        insertResult.addAll(Database.insert(insertObjList, false));
                    }
                }
            }
            if(String.valueOf(scope[0].getSObjectType())=='Staging_Customer__c'){
                System.debug('scope[0].getSObjectType() '+scope[0].getSObjectType());
                Map<String, Account> accountInsertMap = new Map<String, Account>();
                Map<String, Account> accountUpdateMap = new Map<String, Account>();
                Map<String, Loan_Applicant__c> loanAppUpdateMap = new Map<String, Loan_Applicant__c>();
                Map<String, Loan_Applicant__c> loanAppInsertMap = new Map<String, Loan_Applicant__c>();
                for(Staging_Customer__c s : (List<Staging_Customer__c>)scope){
                    loanAccountNumberSet.add(s.Loan_Account_No__c);
                    cifids.add(s.Neo_Cif_Id__c);
                }
                customMaps = StagingBatchHelper.getCustomerIds(cifids);
                capabilityMap = StagingBatchHelper.getCapabilityIds(cifids);
                System.debug('loanAccountNumberSet '+loanAccountNumberSet);
                System.debug('cifids '+cifids);
                
                applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet); 
                System.debug('applicationIds '+applicationIds);
                System.debug('customMaps '+customMaps);
                Map<String,String> accountMap = StagingBatchHelper.getAccountIds(cifids);
                familyMap = StagingBatchHelper.getFamilyIds(cifids);
                employmentDetailsMap = StagingBatchHelper.getEmploymentDetailIds(cifids);
                System.debug('accountMap '+accountMap);
                for(Staging_Customer__c s : (List<Staging_Customer__c>)scope){
                    if(cifids.contains(s.Neo_Cif_Id__c)){
                        System.debug('Contains');
                        if(accountMap.containsKey(s.Neo_Cif_Id__c)){
                            // Updating account 
                            System.debug('Updated Account '+StagingBatchHelper.insertAccount(s, accountMap.get(s.Neo_Cif_Id__c)).values());
                            updateObjList.addAll(StagingBatchHelper.insertAccount(s, accountMap.get(s.Neo_Cif_Id__c)).values());
                        }
                        if(customMaps.containsKey(s.Neo_Cif_Id__c)){
                            // Updating Loan Applicant
                            System.debug('Updated Loan Applicant '+StagingBatchHelper.insertLoanApplicant(s, customMaps.get(s.Neo_Cif_Id__c),'', '', '').values());
                            updateObjList.addAll(StagingBatchHelper.insertLoanApplicant(s, customMaps.get(s.Neo_Cif_Id__c),'', '', '').values());
                            
                            // Updation Or Inserting Capability
                            Capability__c cap = StagingBatchHelper.insertCapability(s,customMaps.get(s.Neo_Cif_Id__c));
                            if(capabilityMap.get(s.Neo_Cif_Id__c) != null){
                                System.debug('Capablity Exist');
                                cap.Id = capabilityMap.get(s.Neo_Cif_Id__c) ;
                                updateObjList.add(cap);
                            }
                            else{
                                System.debug('New Capability Created');
                                insertObjList.add(cap);
                            }
                            
                            // Updating Or Inserting Family Details
                            Family_Detail__c family = StagingBatchHelper.insertFamily(s, customMaps.get(s.Neo_Cif_Id__c));
                            if(familyMap.get(s.Neo_Cif_Id__c)!= null){
                                System.debug('Family Exist');
                                family.Id = familyMap.get(s.Neo_Cif_Id__c);
                                updateObjList.add(family);
                            }
                            else{
                                System.debug('Family Created');
                                insertObjList.add(family);
                            }
                            
                            // Updating or Inserting Employment Details
                            Employment_Details__c emp = StagingBatchHelper.insertEmployee(s, customMaps.get(s.Neo_Cif_Id__c));
                            if(employmentDetailsMap.get(s.Neo_Cif_Id__c) != null){
                                System.debug('Employment Details Exist');
                                emp.Id = employmentDetailsMap.get(s.Neo_Cif_Id__c);
                                updateObjList.add(emp);
                            }
                            else{
                                System.debug('Employment Detail Created');
                                insertObjList.add(emp);
                            }
                        }
                    }
                }
                for(Staging_Customer__c s : (List<Staging_Customer__c>)scope){
                    if(!accountMap.containsKey(s.Neo_Cif_Id__c)){
                        System.debug('Not Contains');
                        // Inserting Account
                        accountInsertMap.putAll(StagingBatchHelper.insertAccount(s, ''));
                    }
                }
                System.debug('accountInsertMap '+accountInsertMap);
                if(!accountInsertMap.isEmpty()){
                    System.debug('Account Inserted');
                    insertResult.addAll(Database.insert(accountInsertMap.values(), false));
                }
                for(Staging_Customer__c s : (List<Staging_Customer__c>)scope){
                    loanAccountNumberSet.add(s.Loan_Account_No__c);
                    cifids.add(s.Neo_Cif_Id__c);
                }
                customMaps = StagingBatchHelper.getCustomerIds(cifids);
                accountMap = StagingBatchHelper.getAccountIds(cifids);
                List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
                for(Staging_Customer__c s : (List<Staging_Customer__c>)scope){
                    if(accountMap.containsKey(s.Neo_Cif_Id__c) && !customMaps.containsKey(s.Neo_Cif_Id__c)){
                        // Inserting 
                        // Loan Applicant
                        // Capability
                        // Family
                        // Employment Details
                        System.debug('Not Contains And Insert Account, Capability, Family, Employment Details');
                        loanAppList.addAll(StagingBatchHelper.insertLoanApplicant(s, '', '', applicationIds.get(s.Loan_Account_No__c), accountMap.get(s.Neo_Cif_Id__c)).values());
                        insertObjList.add(StagingBatchHelper.insertCapability(s, customMaps.get(s.Neo_Cif_Id__c)));
                        insertObjList.add(StagingBatchHelper.insertFamily(s, customMaps.get(s.Neo_Cif_Id__c)));
                        insertObjList.add(StagingBatchHelper.insertEmployee(s, customMaps.get(s.Neo_Cif_Id__c)));
                    }
                }
                System.debug('updateObjList '+updateObjList);
                if(!updateObjList.isEmpty()){
                    updateObjList.sort();
                    updateResult = Database.update(updateObjList, false);
                    System.debug('updateResult size '+updateResult.size());
                    System.debug('sObject Updated');
                }
                if(!loanAppList.isEmpty()){
                    insertData = Database.insert(loanAppList, false);
                }
                System.debug('insertObjList '+insertObjList);
                if(insertObjList.size()>0 && !loanAppList.isEmpty()){
                    insertObjList.sort();
                    insertResult = Database.insert(insertObjList, false);
                    insertResult.addAll(insertData);
                    insertResult.sort();
                    System.debug('insertResult size '+insertResult.size());
                    System.debug('sObject Inserted');
                }
            }  
            if(String.valueOf(scope[0].getSObjectType())=='Staging_Address__c'){
                System.debug('scope[0].getSObjectType() '+scope[0].getSObjectType());
                
                for(Staging_Address__c s : (List<Staging_Address__c>)scope){            
                    cifids.add(s.Neo_Cif_Id__c);
                }
                System.debug('cifids '+cifids);
                Map<String, Loan_Applicant__c> loanAppMap = new Map<String, Loan_Applicant__c>();
                incomeMap = StagingBatchHelper.getPinIds(cifids);
                customMaps = StagingBatchHelper.getCustomerIds(cifids);
                System.debug('customMaps '+customMaps);
                for(Staging_Address__c s : (List<Staging_Address__c>)scope){
                    if(customMaps.containsKey(s.Neo_Cif_Id__c)){
                        System.debug('Loan Applicant Exist');
                        // Updating Loan Applicant
                        Loan_Applicant__C la = StagingBatchHelper.insertLoanApplicant(s, customMaps.get(s.Neo_Cif_Id__c), incomeMap.get(s.Pincode__c), '', '').values();
                        loanAppMap.put(la.Id, la);
                        //updateObjList.add(la);
                    }
                }
                System.debug('updateObjList '+loanAppMap);
                
                if(loanAppMap.size() > 0){
                    updateObjList.sort();
                    updateResult.addAll(Database.update(loanAppMap.values(), false));
                    System.debug('sObject Updated');
                }
            }
            if(String.valueOf(scope[0].getSObjectType())=='Staging_Property__c'){
                System.debug('scope[0].getSObjectType() '+scope[0].getSObjectType());
                for(Staging_Property__c s : (List<Staging_Property__c>)scope){
                    loanAccountNumberSet.add(s.Loan_Account_No__c);
                }
                System.debug('loanAccountNumberSet '+loanAccountNumberSet);
                applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet); 
                preLoginMap = StagingBatchHelper.getPreLoginIds(loanAccountNumberSet);
                System.debug('applicationIds '+applicationIds);
                for(Staging_Property__c s : (List<Staging_Property__c>)scope){
                    if(applicationIds.containsKey(s.Loan_Account_No__c)){
                        System.debug('Loan Account Number Contains');
                        // Inserting Property
                        Property__c objProp = StagingBatchHelper.insertProperty(s, applicationIds.get(s.Loan_Account_No__c), preLoginMap.get(s.Loan_Account_No__c));
                        insertObjList.add(objProp);
                    }
                }
                System.debug('insertObjList '+insertObjList);
                if(insertObjList.size() > 0){
                    insertObjList.sort();
                    insertResult = Database.insert(insertObjList, false);
                    System.debug('sObject Inserted');
                }
            }   
        }
        if(batchObjectMap.get(batchSequence)=='Staging_Property__c'){
            System.debug('Related Property');
            List<Property__c> updatePropList = new List<Property__c>();
            List<Property__c> insertPropList = new List<Property__c>();
            System.debug('Staging Property');
            for(sObject obj : insertObjList){
                System.debug('Property Processing...');
                if(String.valueOf(obj.getSObjectType())=='Property__c'){
                    Map<Property__c, List<Property__c>> newOldProperty = new Map<Property__c, List<Property__c>>();
                    Property__c pro = (Property__c)obj;
                    newOldProperty = StagingBatchHelper.clonePropertyNew(pro);
                    updatePropList.addAll(newOldProperty.keySet());
                    insertPropList.addAll(newOldProperty.get(pro));
                }
            }
            System.debug('updatePropList '+updatePropList);
            if(!updatePropList.isEmpty()){
                Database.update(updatePropList);
                System.debug('Properties Updated');
            }
            System.debug('insertPropList '+insertPropList);
            if(!insertPropList.isEmpty()){
                Database.insert(insertPropList);
                System.debug('Properties Inserted');
            }
        }
        if(batchSequence == 1 && batchObjectMap.get(batchSequence)=='Staging_Loan__c'){
            System.debug('Batch Sequence '+batchSequence);
            List<Application__c> appToUpdate = new List<Application__c>();
            List<Verification__c> verificationToInsert = new List<Verification__c>();
            for(sObject obj : insertObjList){
                if(String.valueOf(obj.getSObjectType())=='Application__c'){
                    Application__c app = (Application__c)obj;
                    Map<Application__c, List<Verification__c>> appVerificationMap = new Map<Application__c, List<Verification__c>>();
                    appVerificationMap = StagingBatchHelper.createVerifications(app);
                    appToUpdate.addAll(appVerificationMap.keySet());
                    verificationToInsert.addAll(appVerificationMap.get(app));
                }
            }
            if(!appToUpdate.isEmpty()){
                Database.update(appToUpdate);
            }
            if(!verificationToInsert.isEmpty()){
                Database.insert(verificationToInsert);
            }
        }
        if(batchObjectMap.get(batchSequence)=='Staging_Loan__c' && batchSequence == 5){
            System.debug('Staging Loan is Deleting...');
            if(updateResult.size() > 0){
                System.debug('updateResult Stgaing_Loan__c');
                //StagingBatchHelper.deleteLoanRecords(updateResult);
                StagingBatchHelper.deleteStagingSobjectRecord(updateResult, 'Capability__c', 'Loan_Applicant__r.LMS_Customer_Info_File_Number__c', '', 'Staging_Loan__c', 'Neo_Cif_Id__c');
            }
            if(insertResult.size() > 0){
                System.debug('insertResult Stgaing_Loan__c');
                //StagingBatchHelper.deleteLoanRecords(insertResult);
                StagingBatchHelper.deleteStagingSobjectRecord(insertResult, 'Capability__c', 'Loan_Applicant__r.LMS_Customer_Info_File_Number__c', '', 'Staging_Loan__c', 'Neo_Cif_Id__c');
            }
        }
        if(batchObjectMap.get(batchSequence)=='Staging_Customer__c'){
            System.debug('Process To deleting Staging Customer...');
            if(updateResult.size() > 0){
                System.debug('updateResult '+updateResult);
                //StagingBatchHelper.deleteCustomerRecords(updateResult);
                StagingBatchHelper.deleteStagingSobjectRecord(updateResult, 'Loan_Applicant__c', 'LMS_Customer_Info_File_Number__c', '', 'Staging_Customer__c', 'Neo_Cif_Id__c');
            }
            if(insertResult.size() > 0){
                System.debug('insertResult '+insertResult);
                //StagingBatchHelper.deleteCustomerRecords(insertResult);
                StagingBatchHelper.deleteStagingSobjectRecord(insertResult, 'Loan_Applicant__c', 'LMS_Customer_Info_File_Number__c', '', 'Staging_Customer__c', 'Neo_Cif_Id__c');
            }
        }
        if(batchObjectMap.get(batchSequence)=='Staging_Property__c'){
            if(updateResult.size() > 0){
                //StagingBatchHelper.deletePropRecords(updateResult);
                StagingBatchHelper.deleteStagingSobjectRecord(updateResult, 'Property__c', 'Application__r.LMS_Response_Reference__c', 'Title_Deed_Number__c', 'Staging_Property__c', 'Title_Deed_LAN__c');
            }
            if(insertResult.size() > 0){
                //StagingBatchHelper.deletePropRecords(insertResult);
                StagingBatchHelper.deleteStagingSobjectRecord(insertResult, 'Property__c', 'Application__r.LMS_Response_Reference__c', 'Title_Deed_Number__c', 'Staging_Property__c', 'Title_Deed_LAN__c');
            }
        }
        if(batchObjectMap.get(batchSequence)=='Staging_Address__c'){
            System.debug('Staging Address is Deleting...');
            if(updateResult.size() > 0){
                System.debug('updateResult Stgaing_Address');
                //StagingBatchHelper.deleteAddressRecords(updateResult);
                StagingBatchHelper.deleteStagingSobjectRecord(updateResult, 'Loan_Applicant__c', 'LMS_Customer_Info_File_Number__c', '', 'Staging_Address__c', 'Neo_Cif_Id__c');
            }
            if(insertResult.size() > 0){
                System.debug('insertResult Stgaing_Address');
                //StagingBatchHelper.deleteAddressRecords(insertResult);
                StagingBatchHelper.deleteStagingSobjectRecord(updateResult, 'Loan_Applicant__c', 'LMS_Customer_Info_File_Number__c', '', 'Staging_Address__c', 'Neo_Cif_Id__c');
            }
        }
        /*}
catch(Exception e){
System.debug('Error Msg '+e.getMessage() +' '+e.getLineNumber());
Staging_Error_Logger__c errorLogger = new Staging_Error_Logger__c();
errorLogger.Error_Type__c = e.getTypeName();
errorLogger.Line_Number__c = e.getLineNumber();
errorLogger.Error__c = e.getMessage();
insert errorLogger;
//Database.rollback(sp);
}*/
    }
    
    public void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new Staging_Batch(),200);
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Finish');
        batchSequence = batchSequence+1;
        System.debug('Sequence '+batchSequence);
        if(batchObjectMap.size()>=batchSequence){
            System.debug('Going to execute batch for '+batchObjectMap.get(batchSequence));
            Database.executeBatch(new Staging_Batch(batchSequence), 200);
        }        
    }
}