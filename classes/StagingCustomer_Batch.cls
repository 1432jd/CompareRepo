/**
* @File Name          : StagingCustomer_Batch.cls
* @Description        : StagingCustomer_Batch Class Used To Import Data From Staging Object To Respectives Objects
* @Author             : Parag Goyal
* @Created On         : 28/09/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        28/09/2022              Parag Goyal             Initial Version
*/
public class StagingCustomer_Batch implements Database.Batchable<sObject>{

    List<Database.SaveResult> insertResult = new List<Database.SaveResult>();
    List<Database.SaveResult> updateResult = new List<Database.SaveResult>();

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Customer__c')+' FROM Staging_Customer__c';
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Staging_Customer__c> scope){
        System.debug('Execute');
        Set<String> loanAccountNumberSet = new Set<String>();
        Set<String> cifids = new Set<String>();
        for(Staging_Customer__c s : scope){
            loanAccountNumberSet.add(s.Loan_Account_No__c);
            cifids.add(s.Neo_Cif_Id__c);
        }
        
        Map<String,String> applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet); 
        Map<String,String> customMaps = StagingBatchHelper.getCustomerIds(cifids);
        Map<String,String> accountMap = StagingBatchHelper.getAccountIds(cifids);
        Map<String,String> mapOfKYCIds = new Map<String,String>();
        List<sObject> insertObjList = new List<sObject>();
        List<sObject> updateObjList = new List<sObject>();
        for(Staging_Customer__c s : scope){
            mapOfKYCIds.clear();
            if(s.Aadhar_No__c != null){
                mapOfKYCIds.put('Aadhaar Card',s.Aadhar_No__c);
            }
            if(s.PAN__c != null){
                mapOfKYCIds.put('Pan Card',s.PAN__c);
            }
            if(s.Voters_Id__c != null){
                mapOfKYCIds.put('Voter Id',s.Voters_Id__c);              
            }
            if(s.Driving_Licence__c != null){
                mapOfKYCIds.put('Driving License',s.Driving_Licence__c);
            }
            if(s.Passport__c != null){
                mapOfKYCIds.put('Passport',s.Passport__c);
            }
            if(applicationIds.containsKey(s.Loan_Account_No__c)){
                if(cifids.contains(s.Neo_Cif_Id__c)){
                    //Update Account
                    //UPDATE CUSTOMER
                    Account acc = new Account(
                        Id = accountMap.get(s.Neo_Cif_Id__c), 
                        Neo_CIF_Id_Staging__c = s.Neo_Cif_Id__c,
                        RecordTypeId = DatabaseUtililty.getRecordTypeId('Account','Person Account'),
                        FirstName = s.First_Name__c,
                        LastName = s.Last_Name__c,
                        PersonBirthDate = s.Date_of_Birth__c 
                    );
                    acc.Father_s_Name__c = s.Father_Name__c;
                    acc.Mother_s_Name__c = s.Mother_s_Name__c;
                    acc.Gender__c = s.Applicant_s_Gender__c;
                    acc.Salutation = StagingBatchHelper.salutionTypeMap.get(s.Salutation__c); 
                    acc.Category__c = s.Category__c;
                    acc.Guardian_Name__c = s.Guardian_Name__c;
                    acc.Nationality__c = s.Nationality__c;
                    acc.Place_Of_Birth__c = s.Place_Of_Birth__c;
                    acc.Religion__c = s.Religion__c;
                    updateObjList.add(acc);
                    
                    Loan_Applicant__C la = new Loan_Applicant__C(
                        Id = customMaps.get(s.Neo_Cif_Id__c),  
                        Application__c = applicationIds.get(s.Loan_Account_No__c)                      
                    );
                    la.Customer_Type__c = StagingBatchHelper.applicantTypeMap.get(s.Applicant_Type__c);
                    la.Email__c = s.Email_Id__c;
                    la.Marital_Status__c = s.Marital_Status__c;
                    la.Phone_Office__c = s.Phone_Office__c;
                    la.Mobile__c = s.Phone_Residence__c;
                    la.Relationship_With_Main_Applicant__c = s.Relationship_With_Applicant__c;
                    la.Resident_Type__c = s.Resident_Type__c;
                    la.Group_Name_Staging__c = s.Group_Name__c;
                    if(!mapOfKYCIds.isEmpty()){
                        Integer count = 0;
                        for(String kyc : mapOfKYCIds.keySet()){
                            count++;
                            if(count == 1){
                                la.KYC_ID_Type_1__c = kyc;
                                la.KYC_Id_1__c = mapOfKYCIds.get(kyc);
                            }
                            if(count == 2){
                                la.KYC_ID_Type_2__c = kyc;
                                la.KYC_Id_2__c = mapOfKYCIds.get(kyc);
                            }
                        }
                    }
                    updateObjList.add(la);
                    
                    Capability__c cap = new Capability__c();
                    cap.Loan_Applicant__c = customMaps.get(s.Neo_Cif_Id__c);
                    cap.Name_of_the_Employer__c = s.Employer_Name__c;
                    cap.Business_Nature__c = s.Nature_Of_Business__c;
                    if(StagingBatchHelper.getCapabilityId(customMaps.get(s.Neo_Cif_Id__c)) != null){
                        cap.Id = StagingBatchHelper.getCapabilityId(customMaps.get(s.Neo_Cif_Id__c));
                        updateObjList.add(cap);
                    }
                    else{
                        insertObjList.add(cap);
                    }
                    
                    
                    Family_Detail__c family = new Family_Detail__c();
                    family.Loan_Applicant__c = customMaps.get(s.Neo_Cif_Id__c);
                    family.Number_Of_Children__c = s.Number_Of_Childrens__c;
                    family.No_Of_Adult_Dependents__c  = s.Number_Of_Dependents__c;
                    if(StagingBatchHelper.getFamilyId(customMaps.get(s.Neo_Cif_Id__c)) != null){
                        family.Id = StagingBatchHelper.getFamilyId(customMaps.get(s.Neo_Cif_Id__c));
                        updateObjList.add(family);
                    }
                    else{
                        insertObjList.add(family);
                    }
                    
                    Employment_Details__c emp = new Employment_Details__c();
                    emp.Loan_Applicant__c = customMaps.get(s.Neo_Cif_Id__c);
                    emp.Application__c = applicationIds.get(s.Loan_Account_No__c);
                    emp.No_of_years_Employment_Business__c = s.No_Of_Years_Employment_Business__c;
                    emp.Occupation__c = s.Occupation__c;
                    if(StagingBatchHelper.getEMPId(customMaps.get(s.Neo_Cif_Id__c)) != null){
                        emp.Id = StagingBatchHelper.getEMPId(customMaps.get(s.Neo_Cif_Id__c));
                        updateObjList.add(emp);
                    }
                    else{
                        insertObjList.add(emp);
                    }
                }
                else{
                    //Insert Account
                    //INSERT CUSTOMER
                    Account acc = new Account(
                        Neo_CIF_Id_Staging__c = s.Neo_Cif_Id__c,
                        RecordTypeId = DatabaseUtililty.getRecordTypeId('Account','Person Account'),
                        FirstName = s.First_Name__c,
                        LastName = s.Last_Name__c,
                        PersonBirthDate = s.Date_of_Birth__c 
                    );
                    acc.Father_s_Name__c = s.Father_Name__c;
                    acc.Mother_s_Name__c = s.Mother_s_Name__c;
                    acc.Gender__c = s.Applicant_s_Gender__c;
                    acc.Salutation = StagingBatchHelper.salutionTypeMap.get(s.Salutation__c); 
                    acc.Category__c = s.Category__c;
                    acc.Guardian_Name__c = s.Guardian_Name__c;
                    acc.Nationality__c = s.Nationality__c;
                    acc.Place_Of_Birth__c = s.Place_Of_Birth__c;
                    acc.Religion__c = s.Religion__c;
                    insertObjList.add(acc);
                    
                    Loan_Applicant__c la = new Loan_Applicant__c(
                        Customer_Information__r  = new Account(Neo_CIF_Id_Staging__c = s.Neo_Cif_Id__c),
                        LMS_Customer_Info_File_Number__c = s.Neo_Cif_Id__c,
                        Application__c = applicationIds.get(s.Loan_Account_No__c)                     
                    );
                    la.Customer_Type__c = StagingBatchHelper.applicantTypeMap.get(s.Applicant_Type__c);
                    la.Email__c = s.Email_Id__c;
                    la.Marital_Status__c = s.Marital_Status__c;
                    la.Phone_Office__c = s.Phone_Office__c;
                    la.Mobile__c = s.Phone_Residence__c;
                    la.Relationship_With_Main_Applicant__c = s.Relationship_With_Applicant__c;
                    la.Resident_Type__c = s.Resident_Type__c;
                    la.Group_Name_Staging__c = s.Group_Name__c;
                    if(!mapOfKYCIds.isEmpty()){
                        Integer count = 0;
                        for(String kyc : mapOfKYCIds.keySet()){
                            count++;
                            if(count == 1){
                                la.KYC_ID_Type_1__c = kyc;
                                la.KYC_Id_1__c = mapOfKYCIds.get(kyc);
                            }
                            if(count == 2){
                                la.KYC_ID_Type_2__c = kyc;
                                la.KYC_Id_2__c = mapOfKYCIds.get(kyc);
                            }
                        }
                    }
                    insertObjList.add(la);
                    
                    Capability__c cap = new Capability__c();
                    cap.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c  = s.Neo_Cif_Id__c);
                    cap.Name_of_the_Employer__c = s.Employer_Name__c;
                    cap.Business_Nature__c = s.Nature_Of_Business__c;
                    insertObjList.add(cap);
                    
                    Family_Detail__c family = new Family_Detail__c();
                    family.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c  = s.Neo_Cif_Id__c);
                    family.Number_Of_Children__c = s.Number_Of_Childrens__c;
                    family.No_Of_Adult_Dependents__c  = s.Number_Of_Dependents__c;
                    insertObjList.add(family);
                    
                    Employment_Details__c emp = new Employment_Details__c();
                    emp.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c  = s.Neo_Cif_Id__c);
                    emp.Application__r = new Application__c(LMS_Response_Reference__c = s.Loan_Account_No__c);
                    emp.No_of_years_Employment_Business__c = s.No_Of_Years_Employment_Business__c;
                    emp.Occupation__c = s.Occupation__c;
                    insertObjList.add(emp);
                }
            }
            else{
                //INSERT
                //PRELOGIN
                //APPLICATION
                //Account
                //CUSTOMER
                
                Pre_login__c pl = new Pre_login__c(
                    Loan_Account_Number_Staging__c = s.Loan_Account_No__c,
                    status__c = 'Done',
                    RecordTypeId = DatabaseUtililty.getRecordTypeId('Pre_login__c','1. New login')
                );
                insertObjList.add(pl);
                
                Application__c aapp = new Application__c(
                    LMS_Response_Reference__c = s.Loan_Account_No__c,
                    application_status__c = 'Active',
                    Pre_login__r = new Pre_login__c(Loan_Account_Number_Staging__c = s.Loan_Account_No__c)
                );
                insertObjList.add(aapp);
                
                Account acc = new Account(
                    Neo_CIF_Id_Staging__c = s.Neo_Cif_Id__c,
                    RecordTypeId = DatabaseUtililty.getRecordTypeId('Account','Person Account'),
                    FirstName = s.First_Name__c,
                    LastName = s.Last_Name__c,
                    PersonBirthDate = s.Date_of_Birth__c 
                );
                acc.Father_s_Name__c = s.Father_Name__c;
                acc.Mother_s_Name__c = s.Mother_s_Name__c;
                acc.Gender__c = s.Applicant_s_Gender__c;
                acc.Salutation = StagingBatchHelper.salutionTypeMap.get(s.Salutation__c); 
                acc.Category__c = s.Category__c;
                acc.Guardian_Name__c = s.Guardian_Name__c;
                acc.Nationality__c = s.Nationality__c;
                acc.Place_Of_Birth__c = s.Place_Of_Birth__c;
                acc.Religion__c = s.Religion__c;
                insertObjList.add(acc);
                
                Loan_Applicant__c la = new Loan_Applicant__c(
                    Customer_Information__r  = new Account(Neo_CIF_Id_Staging__c = s.Neo_Cif_Id__c),
                    LMS_Customer_Info_File_Number__c  = s.Neo_Cif_Id__c,
                    Application__r = new Application__c(LMS_Response_Reference__c = s.Loan_Account_No__c)                         
                );
                la.Customer_Type__c = StagingBatchHelper.applicantTypeMap.get(s.Applicant_Type__c);
                la.Email__c = s.Email_Id__c;
                la.Marital_Status__c = s.Marital_Status__c;
                la.Phone_Office__c = s.Phone_Office__c;
                la.Mobile__c = s.Phone_Residence__c;
                la.Relationship_With_Main_Applicant__c = s.Relationship_With_Applicant__c;
                la.Resident_Type__c = s.Resident_Type__c;
                la.Group_Name_Staging__c = s.Group_Name__c;
                if(!mapOfKYCIds.isEmpty()){
                    Integer count = 0;
                    for(String kyc : mapOfKYCIds.keySet()){
                        count++;
                        if(count == 1){
                        	la.KYC_ID_Type_1__c = kyc;
                            la.KYC_Id_1__c = mapOfKYCIds.get(kyc);
                        }
                        if(count == 2){
                        	la.KYC_ID_Type_2__c = kyc;
                            la.KYC_Id_2__c = mapOfKYCIds.get(kyc);
                        }
                    }
                }
                insertObjList.add(la);
                
                Capability__c cap = new Capability__c();
                cap.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c  = s.Neo_Cif_Id__c);
                cap.Name_of_the_Employer__c = s.Employer_Name__c;
                cap.Business_Nature__c = s.Nature_Of_Business__c;
                insertObjList.add(cap);
                
                Family_Detail__c family = new Family_Detail__c();
                family.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c  = s.Neo_Cif_Id__c);
                family.Number_Of_Children__c = s.Number_Of_Childrens__c;
                family.No_Of_Adult_Dependents__c  = s.Number_Of_Dependents__c;
                insertObjList.add(family);
                
                Employment_Details__c emp = new Employment_Details__c();
                emp.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c  = s.Neo_Cif_Id__c);
                emp.Application__r = new Application__c(LMS_Response_Reference__c = s.Loan_Account_No__c);
                emp.No_of_years_Employment_Business__c = s.No_Of_Years_Employment_Business__c;
                emp.Occupation__c = s.Occupation__c;
                insertObjList.add(emp);
            }
        }
        System.debug(insertObjList.size());
        if(insertObjList.size() > 0)
            insertResult = DATABASE.INSERT(insertObjList);
        if(updateObjList.size() > 0)
            updateResult = DATABASE.UPDATE(updateObjList);
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Finish');
        if(insertResult.size() > 0)
        	StagingBatchHelper.deleteCustomerRecords(insertResult);
        if(updateResult.size() > 0)
        	StagingBatchHelper.deleteCustomerRecords(updateResult);
    }
    
}