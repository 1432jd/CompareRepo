global without sharing class StagingCustomerBatchController implements Database.Batchable<sObject> {
    //, Database.stateful
    global List<Loan_Applicant__c> listOfLoanAPP = new List<Loan_Applicant__c>();
    global List<sObject> listOfCapFamEmp = new List<sObject>();
    global List<Capability__c> listOfCapabilities = new List<Capability__c>();
    global List<Family_Detail__c> listOfFamilies = new List<Family_Detail__c>();
    global List<Employment_Details__c> listOfEmploymentDetails = new List<Employment_Details__c>();
    global List<Account> listOfAcc = new List<Account>();
    global Set<String> cifNumberSet = new Set<String>();
    global Set<String> successApplications = new Set<String>();
    global Set<String> sucessIdsSet = new Set<String>();
    global Map<String,String> failureErrorMap = new Map<String,String>();
    
    global StagingCustomerBatchController(Set<String> succId){
        System.debug('Initiating Customer Batch...');
        successApplications = succId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Set<String> loanId = new Set<String>{'APPL00334407','APPL00322733','APPL00332291','APPL00330292','APPL00330394','APPL00332750','APPL00334007','APPL00323370','APPL00327776','APPL00325017','APPL00319159','APPL00324696','APPL00331167','APPL00333672','APPL00332641','APPL00336572','APPL00337976','APPL00332990','APPL00334069','APPL00326556','APPL00327141','APPL00337169','APPL00327075','APPL00334158','APPL00332961','APPL00330420','APPL00336349'};
        //WHERE Loan_Account_No__c In : loanId
        String query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Customer__c')+' FROM '+'Staging_Customer__c';
        System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Map<String,String> customMaps = new Map<String, String>();
        Map<String,String> capabilityMap = new Map<String, String>();
        Map<String,String> pincodeMap = new Map<String, String>();
        Map<String,String> familyMap = new Map<String, String>();
        Map<String,String> employmentDetailsMap = new Map<String, String>();
        Map<String,String> accountMap = new Map<String,String>();

        List<Staging_Customer__c> listToProcess = new List<Staging_Customer__c>();
        
        for(Staging_Customer__c s : (List<Staging_Customer__c>)scope){
            if(successApplications.contains(s.Loan_Account_No__c) && String.isNotBlank(s.Neo_CIF_Id__c)){
                cifNumberSet.add(s.Neo_CIF_Id__c);
                listToProcess.add(s);
            }
            else{
                failureErrorMap.put(s.Loan_Account_No__c,'Application Not Exist');
            }
        }

        System.debug('listToProcess size '+listToProcess.size());
        System.debug('listToProcess '+listToProcess);
        
        if(!cifNumberSet.isEmpty()){
            customMaps = StagingBatchHelper.getCustomerIds(cifNumberSet);
            capabilityMap = StagingBatchHelper.getCapabilityIds(cifNumberSet);
            familyMap = StagingBatchHelper.getFamilyIds(cifNumberSet);
            employmentDetailsMap = StagingBatchHelper.getEmploymentDetailIds(cifNumberSet);

            for(Account acc : [SELECT Id, Neo_CIF_Id_Staging__c FROM Account WHERE Neo_CIF_Id_Staging__c In : cifNumberSet]){
                accountMap.put(acc.Neo_CIF_Id_Staging__c, acc.Id);
            }

        }  

        System.debug('accountMap '+accountMap.size());
        System.debug('accountMap '+accountMap);

        
        Map<String, Account> customerMap = new Map<String, Account>();
        String personAccRecTypeId = DatabaseUtililty.getRecordTypeId('Account','Person Account');
        for(Staging_Customer__c s : listToProcess){
            if(!accountMap.containsKey(s.Neo_Cif_Id__c)){
                Account acc = new Account();
                if(customerMap.containsKey(s.Neo_Cif_Id__c)){
                    acc = customerMap.get(s.Neo_Cif_Id__c);
                }
                else{
                    acc = new Account();
                }
                acc.Neo_CIF_Id_Staging__c = s.Neo_Cif_Id__c;
                acc.RecordTypeId = personAccRecTypeId; //DatabaseUtililty.getRecordTypeId('Account','Person Account');
                acc.FirstName = s.First_Name__c;
                acc.LastName = s.Last_Name__c;
                acc.PersonBirthDate = s.Date_of_Birth__c;
                acc.Father_s_Name__c = s.Father_Name__c;
                acc.Mother_s_Name__c = s.Mother_s_Name__c;
                acc.Gender__c = s.Applicant_s_Gender__c;
                acc.Salutation = s.Salutation__c!=null ? StagingBatchHelper.salutionTypeMap.containsKey(s.Salutation__c) ? StagingBatchHelper.salutionTypeMap.get(s.Salutation__c) : s.Salutation__c : null; 
                acc.Category__c = s.Category__c;
                acc.Guardian_Name__c = s.Guardian_Name__c;
                acc.Nationality__c = s.Nationality__c;
                acc.Place_Of_Birth__c = s.Place_Of_Birth__c;
                acc.Religion__c = s.Religion__c;
                acc.Created_From_Batch__c = true;
                //temporary change
                //acc.Description = 'Updated Ten Thousand Batch POC';
                //listOfAcc.add(acc);
                customerMap.put(s.Neo_Cif_Id__c, acc);
            }
        }

        System.debug('customerMap '+customerMap.size());
        System.debug('customerMap '+customerMap);

        if(!customerMap.isEmpty())
            listOfAcc.addAll(customerMap.values());

        System.debug('listOfAcc '+listOfAcc.size());
        System.debug('listOfAcc '+listOfAcc);
        
        if(!listOfAcc.isEmpty()){
            Schema.SObjectField ftoken = Account.Fields.Neo_CIF_Id_Staging__c;
            List<Database.SaveResult> result = Database.INSERT(listOfAcc,false);
            for(Integer i = 0;i< result.size();i++){
                if(result.get(i).isSuccess()){
                    System.debug('Account INSERTED');
                    //sucessIdsSet.add(listOfAcc.get(i).Neo_CIF_Id_Staging__c);
                }
                else{
                    Database.Error errObj = result.get(i).getErrors().get(0);
                   	failureErrorMap.put(listOfAcc.get(i).Neo_CIF_Id_Staging__c,errObj.getFields()+'\n'+errObj.getMessage()); 
                    System.debug('Account Not INSERTED'+errObj.getFields()+' :: '+errObj.getMessage());
                }
            }
        }
        
        for(Account acc : [SELECT Id, Neo_CIF_Id_Staging__c FROM Account WHERE Neo_CIF_Id_Staging__c In : cifNumberSet]){
            accountMap.put(acc.Neo_CIF_Id_Staging__c, acc.Id);
        }

        System.debug('accountMap size '+accountMap.size());
        System.debug('accountMap '+accountMap);

        
        Map<String, Loan_Applicant__c> loanAPPMap = new Map<String, Loan_Applicant__c>();
        for(Staging_Customer__c s : listToProcess){
            Loan_Applicant__c la = new Loan_Applicant__c();
            if(loanAPPMap.containsKey(s.Neo_Cif_Id__c)){
                la = loanAPPMap.get(s.Neo_Cif_Id__c);
            }
            else{
                la = new Loan_Applicant__c();
            }
            la.Customer_Information__c = accountMap.get(s.Neo_Cif_Id__c);
            la.Application__r = new Application__c(LMS_Response_Reference__c = s.Loan_Account_No__c);
            la.Customer_Type__c = s.Applicant_Type__c != null && StagingBatchHelper.applicantTypeMap.containsKey(s.Applicant_Type__c)? StagingBatchHelper.applicantTypeMap.get(s.Applicant_Type__c) : null;
            la.Email__c = s.Email_Id__c;
            la.Marital_Status__c = s.Marital_Status__c;
            if(s.Marital_Status__c == 'Married'){
                la.Married__c = 'Yes';
            }
            else{
                la.Married__c = 'No';
            }
            la.Phone_Office__c = String.isNotEmpty(s.Phone_Office__c) && (s.Phone_Office__c).length() == 10 ? s.Phone_Office__c : null;
            la.Mobile__c = String.isNotEmpty(s.Phone_Residence__c) && (s.Phone_Residence__c).length() == 10 ? s.Phone_Residence__c : null;
            if(StagingBatchHelper.relationshipMap.containsKey(s.Relationship_With_Applicant__c)){
                la.Relationship_With_Main_Applicant__c = StagingBatchHelper.relationshipMap.get(s.Relationship_With_Applicant__c);
            }
            else{
                la.Relationship_With_Main_Applicant__c = s.Relationship_With_Applicant__c;
            }
            
            if(StagingBatchHelper.residentTypeMap.containsKey(s.Resident_Type__c))
                la.Resident_Type__c = StagingBatchHelper.residentTypeMap.get(s.Resident_Type__c);
            else
                la.Resident_Type__c = s.Resident_Type__c;
            
            la.LMS_Customer_Info_File_Number__c = s.Neo_Cif_Id__c;
            //new change 18/01/2022
            la.Staging_External_Id__c = s.Application_Number__c  + s.Neo_Cif_Id__c;
            la.Group_Name_Staging__c = s.Group_Name__c;
            StagingBatchHelper.mapOfKYCIds.clear();
            if(s.Aadhar_No__c != null){
                StagingBatchHelper.mapOfKYCIds.put('Aadhaar Card',s.Aadhar_No__c);
            }
            if(s.PAN__c != null){
                StagingBatchHelper.mapOfKYCIds.put('Pan Card',s.PAN__c);
            }
            if(s.Voters_Id__c != null){
                StagingBatchHelper.mapOfKYCIds.put('Voter Id',s.Voters_Id__c); 
            }
            if(s.Driving_Licence__c != null){
                StagingBatchHelper.mapOfKYCIds.put('Driving License',s.Driving_Licence__c);
            }
            if(s.Passport__c != null){
                StagingBatchHelper.mapOfKYCIds.put('Passport',s.Passport__c);
            }
            if(!StagingBatchHelper.mapOfKYCIds.isEmpty()){
                Integer count = 0;
                for(String kyc : StagingBatchHelper.mapOfKYCIds.keySet()){
                    count++;
                    if(count == 1){
                        la.KYC_ID_Type_1__c = kyc;
                        la.KYC_Id_1__c = StagingBatchHelper.mapOfKYCIds.get(kyc);
                    }
                    if(count == 2){
                        la.KYC_ID_Type_2__c = kyc;
                        la.KYC_Id_2__c = StagingBatchHelper.mapOfKYCIds.get(kyc);
                    }
                }
            }
            loanAPPMap.put(s.Neo_Cif_Id__c, la);
        }
        if(!loanAPPMap.isEmpty())
            listOfLoanAPP.addAll(loanAPPMap.values());
        System.debug('listOfLoanAPP '+listOfLoanAPP);
        if(!listOfLoanAPP.isEmpty()){
            //new change
        	//Schema.SObjectField ftoken = Loan_Applicant__c.Fields.LMS_Customer_Info_File_Number__c;
            Schema.SObjectField ftoken = Loan_Applicant__c.Fields.Staging_External_Id__c;
            List<Database.UpsertResult> result = Database.UPSERT(listOfLoanAPP,ftoken,false);
            for(Integer i = 0;i< result.size();i++){
                if(result.get(i).isSuccess()){
                    sucessIdsSet.add(listOfLoanAPP.get(i).LMS_Customer_Info_File_Number__c);
                }
                else{
                    Database.Error errObj = result.get(i).getErrors().get(0);
                   	failureErrorMap.put(listOfLoanAPP.get(i).LMS_Customer_Info_File_Number__c,errObj.getFields()+'\n'+errObj.getMessage()); 
                }
            }
        }
        Map<String, Capability__c> capMap = new Map<String, Capability__c>();
        Map<String, Family_Detail__c> familyNeoCifIdMap = new Map<String, Family_Detail__c>();
        Map<String, Employment_Details__c> empDetailsMap = new Map<String, Employment_Details__c>();
        for(Staging_Customer__c s : listToProcess){
            //Capability
            Capability__c cap = new Capability__c();
            if(capMap.containsKey(s.Neo_Cif_Id__c)){
                cap = capMap.get(s.Neo_Cif_Id__c);
            }
            else{
                cap = new Capability__c();
            }
            if(capabilityMap.containsKey(s.Neo_Cif_Id__c)){
                cap.Id = capabilityMap.get(s.Neo_Cif_Id__c);
            }
            cap.Name_of_the_Employer__c = s.Employer_Name__c;
            cap.Business_Nature__c = s.Nature_Of_Business__c;
            cap.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c = s.Neo_Cif_Id__c);
            cap.Neo_CIf_Id_Staging__c = s.Neo_Cif_Id__c;
            capMap.put(s.Neo_Cif_Id__c, cap);
            
            //Family
            Family_Detail__c family = new Family_Detail__c();
            if(familyNeoCifIdMap.containsKey(s.Neo_Cif_Id__c)){
                family = familyNeoCifIdMap.get(s.Neo_Cif_Id__c);
            }
            else{
                family = new Family_Detail__c();
            }
            if(familyMap.containsKey(s.Neo_Cif_Id__c)){
                family.Id = familyMap.get(s.Neo_Cif_Id__c);
            }
            family.Number_Of_Children__c = s.Number_Of_Childrens__c;
            family.No_Of_Adult_Dependents__c = s.Number_Of_Dependents__c;
            family.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c = s.Neo_Cif_Id__c);
            familyNeoCifIdMap.put(s.Neo_Cif_Id__c, family);
            
            //Employment
            Employment_Details__c emp = new Employment_Details__c();
            if(empDetailsMap.containsKey(s.Neo_Cif_Id__c)){
                emp = empDetailsMap.get(s.Neo_Cif_Id__c);
            }
            else{
                emp = new Employment_Details__c();
            }
            if(employmentDetailsMap.containsKey(s.Neo_Cif_Id__c)){
                emp.Id = employmentDetailsMap.get(s.Neo_Cif_Id__c);
            }
            emp.No_of_years_Employment_Business__c = s.No_Of_Years_Employment_Business__c;
            if(StagingbatchHelper.occuptaionMap.containsKey(s.Occupation__c)){
                emp.Occupation__c = StagingbatchHelper.occuptaionMap.get(s.Occupation__c);
            }
            else{
                emp.Occupation__c = s.Occupation__c;
            }
            emp.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c = s.Neo_Cif_Id__c);
            empDetailsMap.put(s.Neo_Cif_Id__c, emp);
        }
        if(!capMap.isEmpty()){
            System.debug('CapMap '+capMap);
            //listOfCapFamEmp.addAll(capMap.values());
            Map<Id,Capability__c> capMapNew = new Map<Id,Capability__c>();
            for(Capability__c capNew : capMap.values()){
                if(capNew.Id != NULL){
                    capMapNew.put(capNew.Id, capNew);
                }else{
                    listOfCapabilities.add(capNew);
                }
            }
            listOfCapabilities.addAll(capMapNew.values());
        }
                
        if(!familyNeoCifIdMap.isEmpty()){
            //listOfCapFamEmp.addAll(familyNeoCifIdMap.values());
            Map<Id,Family_Detail__c>famMapNew = new Map<Id,Family_Detail__c>();
            for(Family_Detail__c famNew : familyNeoCifIdMap.values()){
                if(famNew.Id != NULL){
                    famMapNew.put(famNew.Id, famNew);
                }else{
                    listOfFamilies.add(famNew);
                }
            }
            listOfFamilies.addAll(famMapNew.values());
        }

        
        if(!empDetailsMap.isEmpty()){
            //listOfCapFamEmp.addAll(empDetailsMap.values());
            Map<Id,Employment_Details__c> empMapNew = new Map<Id,Employment_Details__c>();
            for(Employment_Details__c empNew : empDetailsMap.values()){
                if(empNew.Id != NULL){
                    empMapNew.put(empNew.Id, empNew);
                }else{
                    listOfEmploymentDetails.add(empNew);
                }
            }
            listOfEmploymentDetails.addAll(empMapNew.values());
        }

        if(!listOfCapabilities.isEmpty()){
            Database.UPSERT(listOfCapabilities,false);
        }

        if(!listOfFamilies.isEmpty()){
            Database.UPSERT(listOfFamilies,false);
        }

        if(!listOfEmploymentDetails.isEmpty()){
            Database.UPSERT(listOfEmploymentDetails,false);
        }
        
        /*if(!listOfCapFamEmp.isEmpty()){
            listOfCapFamEmp.sort();
            Database.UPSERT(listOfCapFamEmp,false);
        }*/
        
        if(!sucessIdsSet.isEmpty()){
            System.debug('sucessIdsSet @@ '+sucessIdsSet);
            System.debug('Size :: '+sucessIdsSet.size());
            
            /*************** Commented Untill UAT Sign-OFF ***************************/
            List<Staging_Customer__c> stagingCustlist = [SELECT Id,Status__c,Error_Reason__c FROM Staging_Customer__c WHERE Neo_CIF_Id__c In : sucessIdsSet];
            //List<Staging_Customer__c> updStagingCustlist = new List<Staging_Customer__c>();
            if(!stagingCustlist.isEmpty()){
                Database.Delete(stagingCustlist);
                /*for(Staging_Customer__c stg : stagingCustlist){
                    stg.Error_Reason__c = null;
                    stg.Status__c = 'Process';
                    updStagingCustlist.add(stg);
                }
                if(!updStagingCustlist.isEmpty())
                    DATABASE.update(updStagingCustlist);*/
            }
        }
        if(!failureErrorMap.isEmpty()){
            System.debug('failureErrorMap '+failureErrorMap);
            List<Staging_Customer__c> listStagingCust = new List<Staging_Customer__c>();
            for(Staging_Customer__c sc : [SELECT Id,Neo_CIF_Id__c,Status__c,Error_Reason__c
                                          FROM Staging_Customer__c
                                          WHERE Neo_CIF_Id__c IN : failureErrorMap.keySet()]){
                                              sc.Status__c = 'Failed';
                                              sc.Error_Reason__c = failureErrorMap.get(sc.Neo_CIF_Id__c);
                                              listStagingCust.add(sc);                         
                                          }
            if(!listStagingCust.isEmpty())
                Database.UPDATE(listStagingCust);   
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('FINISH EXECUTING StagingAddressBatchController Initiating...');
        Database.executeBatch(new StagingAddressBatchController(), 1000);
    }
}