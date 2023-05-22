global without sharing class StagingLoanBatchController implements Schedulable,Database.Batchable<sObject>, Database.stateful{
    global boolean isStagingRecordDelete = false;
    global Set<String> sucessIdsSet = new Set<String>();
    global Map<String,String> failureErrorMap = new Map<String,String>();
    
    global StagingLoanBatchController(boolean isStagingRecDelete){
        //System.debug('isStagingRecDelete '+isStagingRecDelete);
        isStagingRecordDelete = isStagingRecDelete;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Set<String> loanId = new Set<String>{'FSAPLALONS000005398550'}; //,'APPL00322733','APPL00332291','APPL00330292','APPL00330394','APPL00332750','APPL00334007','APPL00323370','APPL00327776','APPL00325017','APPL00319159','APPL00324696','APPL00331167','APPL00333672','APPL00332641','APPL00336572','APPL00337976','APPL00332990','APPL00334069','APPL00326556','APPL00327141','APPL00337169','APPL00327075','APPL00334158','APPL00332961','APPL00330420','APPL00336349'};
        // WHERE Loan_Account_No__c IN : loanId
        String query = 'SELECT Id, '+Utility.getFieldAPINames('Staging_Loan__c')+' FROM '+'Staging_Loan__c';
        //System.debug('query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Application__c> listOfAPP = new List<Application__c>();
        List<Pre_Login__c> listOfPreLogin = new List<Pre_Login__c>();
        Set<String> loanAccountNumberSet = new Set<String>();
        Set<String> cifIds = new Set<String>();
        Set<String> branchSet = new Set<String>();
        Set<String> empIds = new Set<String>(); 
        Map<String,String> branchMap = new Map<String, String>();
        Map<String,String> userMap = new Map<String, String>();
        Map<String,String> applicationIds = new Map<String, String>();
        if(!isStagingRecordDelete){
            //System.debug('Staging Loan Application Creation...');
            for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                loanAccountNumberSet.add(s.Loan_Account_No__c);
                branchSet.add(s.Branch_Code__c);
                empIds.add(s.Field_Officer_Id__c);
            }
            if(!loanAccountNumberSet.isEmpty())
                applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet);
            if(!branchSet.isEmpty())
                branchMap = StagingBatchHelper.getBranchId(branchSet);
            if(!empIds.isEmpty())
                userMap = StagingBatchHelper.getUserIds(empIds);
            Map<String, String> preLoginMap = new Map<String, String>();
            for(Pre_Login__c pre : [SELECT Id, Loan_Account_Number_Staging__c FROM Pre_Login__c WHERE Loan_Account_Number_Staging__c In : loanAccountNumberSet]){
                preLoginMap.put(pre.Loan_Account_Number_Staging__c, pre.Id);
            }
            for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                if(!preLoginMap.containsKey( s.Loan_Account_No__c)){
                    Pre_login__c pl = new Pre_login__c(Loan_Account_Number_Staging__c = s.Loan_Account_No__c,status__c = 'Active',RecordTypeId = DatabaseUtililty.getRecordTypeId('Pre_login__c','1. New login')); 
                    listOfPreLogin.add(pl);
                }
            }
            if(!listOfPreLogin.isEmpty()){
                Database.Insert(listOfPreLogin);
            }
            for(Pre_Login__c pre : [SELECT Id, Loan_Account_Number_Staging__c FROM Pre_Login__c WHERE Loan_Account_Number_Staging__c In : loanAccountNumberSet]){
                preLoginMap.put(pre.Loan_Account_Number_Staging__c, pre.Id);
            }
            Map<String, Application__c> applicationMap = new Map<String, Application__c>();
            for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                Application__c app = new Application__C(Application_Status__c = 'Active',Stage__c = 'Closed');
                if(applicationMap.containsKey(s.Loan_Account_No__c)){
                    app = applicationMap.get(s.Loan_Account_No__c);
                }
                else{
                    app = new Application__c();
                }
                app.Pre_Login__c = preLoginMap.get(s.Loan_Account_No__c);
                app.Sourcing_Branch__c = branchMap.containsKey(s.Branch_Code__c)?branchMap.get(s.Branch_Code__c):null; 
                if(StagingBatchHelper.altChannelTypeMap.containsKey(s.Alternate_Channel_Mode__c))
                    app.Alternate_Channel_Mode__c = StagingBatchHelper.altChannelTypeMap.get(s.Alternate_Channel_Mode__c);
                else
                    app.Alternate_Channel_Mode__c = s.Alternate_Channel_Mode__c;
                if(StagingBatchHelper.channelTypeMap.containsKey(s.Channel__c))
                    app.Channel__c = s.Channel__c;
                app.Name = s.Application_Number__c; //ApplicationNumber
                app.Created_From_Batch__c = true;
                app.LMS_Response_Reference__c = s.Loan_Account_No__c;
                app.Customer_Request_Amount__c = s.Customer_Requested_Loan_Amount__c;
                app.DPD__c = s.Dpd__c!=null?String.valueOf(s.Dpd__c):'';
                app.DBR__c = s.Dbr__c;
                app.EMI__c = s.Emi__c;
                app.Field_Officer_Name__c = s.Field_Officer_Name__c;
                app.Field_Officer_Emp_Id__c = userMap.containsKey(s.Field_Officer_Id__c)?userMap.get(s.Field_Officer_Id__c):null; 
                app.Loan_Purpose_1__c = s.Loan_Purpose__c;
                app.Amount_Recommended__c = s.Loan_Amount__c;
                app.LTV__c = s.Ltv__c;
                app.Old_Collateral_value__c = s.Old_Collateral_Value__c != null ? Decimal.valueOf(s.Old_Collateral_Value__c) : null;
                app.Old_Loan_Gross_Income__c = s.Old_Loan_Gross_Income__c;
                app.Old_Loan_Net_Income__c = s.Old_Loan_Net_Income__c;
                app.Old_Loan_Obligationss__c = String.valueOf(s.Old_Loan_Obligations__c);
                app.Tranche_Disbursal__c = String.isNotEmpty(s.Application_Type__c) ? StagingBatchHelper.applicationTypeMap.containsKey(s.Application_Type__c) ? StagingBatchHelper.applicationTypeMap.get(s.Application_Type__c) : null : null;
                //PC-AC Mapping
                app.Loan_Amount__c = s.Loan_Amount__c;
                //app.Tenor_In_Months__c = s.Tenure_Requested__c != null ? String.valueOf(s.Tenure_Requested__c) : null;
                app.Principal_O_S__c = s.Principal_OS__c != null ? Decimal.valueOf(s.Principal_OS__c) : null;
                app.Total_Tenor__c = s.Total_Tenor__c;
                app.Stage__c = 'Closed';

                //new changes 13/01/2023
                app.Staging_External_Id__c = s.Application_Number__c+s.Loan_Account_No__c;
                //temporary changes
                //app.Remarks__c = 'Updated Ten Thousand Batch POC';
                
                applicationMap.put(s.Loan_Account_No__c, app);
            }
            if(!applicationMap.isEmpty())
                listOfAPP.addAll(applicationMap.values());
            //System.debug('listOfAPP '+listOfAPP);
            if(!listOfApp.isEmpty()){
                List<Application__c> appToUpdate = new List<Application__c>();
                List<Verification__c> verificationToInsert = new List<Verification__c>();
                //Schema.SObjectField ftoken = Application__C.Fields.LMS_Response_Reference__c;
                Schema.SObjectField ftoken = Application__C.Fields.Staging_External_Id__c;

                List<Database.UpsertResult> result = Database.UPSERT(listOfAPP,ftoken,false);
                Map<Id,Pre_Login__c> loginsToUpdate = new Map<Id,Pre_Login__c>();
                for(Integer i = 0;i< result.size();i++){
                    if(result.get(i).isSuccess()){
                        sucessIdsSet.add(listOfAPP.get(i).LMS_Response_Reference__c);
                        loginsToUpdate.put(listOfAPP.get(i).Pre_Login__c, new Pre_Login__c(Id=listOfAPP.get(i).Pre_Login__c, Application__c = listOfAPP.get(i).Id));
                        if(result.get(i).isCreated()){
                            //System.debug('Insert Case for '+listOfAPP.get(i).LMS_Response_Reference__c);
                            Map<Application__c, List<Verification__c>> appVerificationMap = new Map<Application__c, List<Verification__c>>();
                            appVerificationMap = StagingBatchHelper.createVerifications(listOfAPP.get(i));
                            appToUpdate.addAll(appVerificationMap.keySet());
                            verificationToInsert.addAll(appVerificationMap.get(listOfAPP.get(i)));
                        }
                    }
                    else{
                        Database.Error errObj = result.get(i).getErrors().get(0);
                        failureErrorMap.put(listOfAPP.get(i).LMS_Response_Reference__c,errObj.getFields()+'\n'+errObj.getMessage()); 
                    }
                }
                
                if(!loginsToUpdate.isEmpty()){
                    update loginsToUpdate.values();
                }
                
                if(!appToUpdate.isEmpty()){
                    Database.Update(appToUpdate);
                }
                if(!verificationToInsert.isEmpty()){
                    //System.debug('verificationToInsert '+verificationToInsert);
                    Database.Insert(verificationToInsert);
                }
            }
            //System.debug('sucessIdsSet '+sucessIdsSet);
            if(!failureErrorMap.isEmpty()){
                //System.debug('failureErrorMap '+failureErrorMap);
                List<Staging_Loan__c> listStagingLoan = new List<Staging_Loan__c>();
                for(Staging_Loan__c sl : [SELECT Id,Loan_Account_No__c,Status__c,Error_Reason__c
                                          FROM Staging_Loan__c WHERE Loan_Account_No__c IN : failureErrorMap.keySet()]){
                                              sl.Status__c = 'Failed';
                                              sl.Error_Reason__c = failureErrorMap.get(sl.Loan_Account_No__c);
                                              listStagingLoan.add(sl);                         
                                          }
                if(!listStagingLoan.isEmpty())
                    Database.Update(listStagingLoan);   
            }
        }
        if(isStagingRecordDelete){
            List<Disbursal__c> disbursalList = new List<sObject>();
            List<sObject> sObjectList = new List<sObject>();
            //System.debug('Final Staging Loan Batch Executing...');
            for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                loanAccountNumberSet.add(s.Loan_Account_No__c);
                cifIds.add(s.Neo_Cif_Id__c);
            }
            
            applicationIds = StagingBatchHelper.getApplicationIds(loanAccountNumberSet);
            Map<String, String> customMaps = StagingBatchHelper.getCustomerIds(cifids);
            Map<String, String> capabilityMap = StagingBatchHelper.getCapabilityIds(cifids);
            Map<String, String> incomeMap = StagingBatchHelper.getIncomeIds(cifids);
            Map<String, String> disbursalIdMap = StagingBatchHelper.getDisbursalIds(loanAccountNumberSet);

            List<Capability__c> listOfCapabilities = new List<Capability__c>();
            List<Income__c> listOfIncome = new List<Income__c>();
            //System.debug('cifids '+cifids);
            //System.debug('customMaps '+customMaps);

            Map<String, Capability__c> capMap = new Map<String, Capability__c>();
            Map<String, Income__c> incMap = new Map<String, Income__c>();
            List<Disbursal__c> insertionList = new List<Disbursal__c>();
            List<Disbursal__c> updationList = new List<Disbursal__c>();
            for(Staging_Loan__c s : (List<Staging_Loan__c>)scope){
                if(customMaps.containsKey(s.Neo_Cif_Id__c)){
                    Capability__c cap = new Capability__c();
                    if(capMap.containsKey(s.Neo_Cif_Id__c)){
                        cap = capMap.get(s.Neo_Cif_Id__c);
                    }
                    else{
                        cap = new Capability__c();
                    }
                    cap.Loan_Applicant__c = customMaps.get(s.Neo_Cif_Id__c);
                    cap.Rental_Income__c = s.Rentral_Income__c!=null?s.Rentral_Income__c:0;
                    cap.Monthly_Salary__c = s.Salary_Income__c!=null?s.Salary_Income__c:0;
                    cap.Income_per_month__c = s.Pension_Income__c!=null?s.Pension_Income__c:0;
                    cap.Income_per_month__c = s.Other_Income__c!=null?s.Other_Income__c:0;
                    cap.Income_per_month__c = s.Nri_Income__c!=null?s.Nri_Income__c:0;
                    if(capabilityMap.containsKey(s.Neo_Cif_Id__c)){
                        cap.Id = capabilityMap.get(s.Neo_Cif_Id__c);
                    }
                    capMap.put(s.Neo_Cif_Id__c, cap);
                    
                    //listOfCapabilities.add(cap);
                    //sObjectList.add(cap);
                    
                    Income__c income = new Income__c();
                    if(incMap.containsKey(s.Neo_Cif_Id__c)){
                        income = incMap.get(s.Neo_Cif_Id__c);
                    }
                    else{
                        income = new Income__c();
                    }
                    income.Agricultural_Income__c = s.Agricultural_Income__c!=null?s.Agricultural_Income__c:0;
                    income.Business_Income__c = s.Business_Income__c!=null?s.Business_Income__c:0;
                    income.Pension_Income__c = s.Pension_Income__c!=null?s.Pension_Income__c:0;
                    income.NRI_Income__c = s.Nri_Income__c!=null?s.Nri_Income__c:0;
                    income.Other_Income__c = s.Other_Income__c!=null?s.Other_Income__c:0;
                    income.Other_Expected_Income__c = s.Other_Expected_Income__c!=null?s.Other_Expected_Income__c:0;
                    income.Salary_Income__c = s.Salary_Income__c!=null?s.Salary_Income__c:0;
                    income.Rentral_Income__c = s.Rentral_Income__c!=null?s.Rentral_Income__c:0;
                    income.Loan_Applicant__c = customMaps.get(s.Neo_Cif_Id__c);
                    if(incomeMap.containsKey(s.Neo_Cif_Id__c)){
                        income.Id = incomeMap.get(s.Neo_Cif_Id__c);
                    }
                    incMap.put(s.Neo_Cif_Id__c, income);
                    
                    //listOfIncome.add(income);
                    //sObjectList.add(income);
                }
                
                //Processing Disbursal
                if(applicationIds.containsKey(s.Loan_Account_No__c)){
                    Map<String,Disbursal__c> mapOfDisb = new Map<String,Disbursal__c>();
                    Disbursal__c dis = new Disbursal__c();
                    if(mapOfDisb.containsKey(disbursalIdMap.get(s.Loan_Account_No__c))){
                        dis = mapOfDisb.get(disbursalIdMap.get(s.Loan_Account_No__c));
                    }
                    else{
                        if(disbursalIdMap.containsKey(s.Loan_Account_No__c))
                            dis = new Disbursal__c(Id = disbursalIdMap.get(s.Loan_Account_No__c));
                    }
                    dis.Final_Disbursal_Amount__c = s.Customer_Disbursal_Amount__c;
                    dis.Loan_Amount_Sanctioned__c = s.Sanction_Loan_Amount__c;
                    dis.Application__c = applicationIds.get(s.Loan_Account_No__c);
                    if(disbursalIdMap.containsKey(s.Loan_Account_No__c)){
                        mapOfDisb.put(disbursalIdMap.get(s.Loan_Account_No__c),dis);
                        disbursalList.add(mapOfDisb.values());
                    }
                    else
                        disbursalList.add(dis); 
                } 
            }
            if(!disbursalList.isEmpty()){
                for(Disbursal__c objDis : disbursalList){
                    if(objDis.Id != null && !updationList.contains(objDis)){
                        updationList.add(objDis);
                    }
                    else if(objDis.Id == null && !insertionList.contains(objDis)){
                        insertionList.add(objDis);
                    }    
                }
                if(!insertionList.isEmpty())
                    Database.insert(insertionList,false);
                if(!updationList.isEmpty())
                    Database.update(updationList,false);
            }
            if(!listOfCapabilities.isEmpty()){
                if(!capMap.isEmpty()){
                        //System.debug('CapMap '+capMap);
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
                Database.upsert(listOfCapabilities, false);
            }
            if(!listOfIncome.isEmpty()){
                if(!incMap.isEmpty()){
                        //System.debug('incMap '+incMap);
                        Map<Id,Income__c> incMapNew = new Map<Id,Income__c>();
                        for(Income__c incNew : incMap.values()){
                            if(incNew.Id != NULL){
                                incMapNew.put(incNew.Id, incNew);
                            }else{
                                listOfIncome.add(incNew);
                            }
                        }
                        listOfIncome.addAll(incMapNew.values());
                    }
                Database.upsert(listOfIncome, false);
            }
            /*if(!sObjectList.isEmpty()){
                sObjectList.sort();
                Database.upsert(sObjectList, false);
            }*/
            if(!disbursalList.isEmpty()){
                //Set<String> successRecordId = new Set<String>();
                //Schema.SObjectField ftoken = Disbursal__c.Fields.Id;
                //List<Database.upsertResult> result = Database.upsert(disbursalList,ftoken,false);
                
                /************* Commented Untill UAT Sign-Off  *************************/
                List<Staging_Loan__c> stagingLoanlist = [SELECT Id,Error_Reason__c,Status__c FROM Staging_Loan__c WHERE Loan_Account_No__c In : applicationIds.keySet()];
                //List<Staging_Loan__c> updateStagLoanList = new List<Staging_Loan__c>();
                if(!stagingLoanlist.isEmpty()){
                    Database.Delete(stagingLoanlist);
                    /*for(Staging_Loan__c stg : stagingLoanlist){
                        stg.Error_Reason__c = null;
                        stg.Status__c = 'Process';
                        updateStagLoanList.add(stg);
                    }
                    if(!updateStagLoanList.isEmpty())
                        DATABASE.update(updateStagLoanList);*/
                }
            }
        }
    }
    
    global void execute(SchedulableContext ctx) {
       Database.executeBatch(new StagingLoanBatchController(false), 1000);
    }
    
    global void finish(Database.BatchableContext bc) {
        //System.debug('Finish Executing StagingCustomerBatchController Initiating...');
        if(!isStagingRecordDelete && !sucessIdsSet.isEmpty())
            Database.executeBatch(new StagingCustomerBatchController(sucessIdsSet), 1000);
    }
}