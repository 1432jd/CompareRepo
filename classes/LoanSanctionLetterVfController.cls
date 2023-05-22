/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Arnav Chaudhary 
* @modifiedBy       Arnav Chaudhary  
* @created          2022-08-12
* @modified         2022-08-12
* @Description      This class is used to map fields to LoanSanctionVf page.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class LoanSanctionLetterVfController {
    public String applicationId{get;set;}
    public String primaryAppName{get;set;}
    public String address{get;set;}
    public String relationCoApp{get;set;}
    public String relationGurantor{get;set;} 
    public Application__c objApp{get;set;}
    public List<String> coAppName{get;set;}
    public List<String> gurantorName{get;set;}
    public List<String> remarks{get;set;}
    public LoanSanctionLetterVfController(){
        applicationId = Apexpages.currentPage().getParameters().get('id');
        System.debug('ID ' + applicationId);
        if(String.isBlank(applicationId)){
            applicationId = 'a030w000008HwIQAA0';
        }
        try{
            if(String.isNotBlank(applicationId)){
                objApp = [SELECT Id,Name,EMI__c,Emi_PcAc__c,Customer_Communicated__c,Effective_IRR__c,Number_of_advance_EMI__c,Loan_Purpose_1__c,Nach_Party__c,Total_Amount_Recommended_PcAc__c,Tenor_In_Months__c,Customer_Visit_date__c,
                          (SELECT Loan_Amount_Sanctioned__c,Additional_Rate_of_Interest_if_app__c, ROI_including_advance_EMI__c, Fnl_annu_ROI_incl_adv_EMI__c,
                           Reason_for_add_l_ROI_if_appl__c,Repayment_Tenure__c,Monthly_Installment_EMI_Rs__c FROM Disbursals__r),Tenure_Requested__c,Legal_Sanction_Condition__c,Loan_Purpose_2__c
                           ,Disbursement_Party_Name__c,Disbursement_party__c,Name__c,Nominee_Party__c,Insurance_Requirement__c
                           FROM 
                          Application__c 
                          WHERE 
                          Id=: applicationId];
                //Nach_Party__c,Disbursement_party__c,Name__c,Nominee_Party__c,Insurance_Requirement__c
                List <Loan_Applicant__c> loanList =[SELECT Id,Application__c,Customer_Information__r.Name,Customer_Type__c,Residence_Address_Line_1__c 
                                                    FROM 
                                                    Loan_Applicant__c Where Application__c=: applicationId 
                                                    AND
                                                    Customer_Type__c = 'Primary Applicant'];
                System.debug('Loan List'+ loanList);
                if(loanList.size() == 0){
                    address = '';
                    primaryAppName = '';
                    System.debug('primary' + primaryAppName);
                }else {
                    if(loanList[0].Customer_Information__r.Name != null && loanList[0].Customer_Information__r.Name != ''){
                        primaryAppName = loanList[0].Customer_Information__r.Name;
                    }
                    if(loanList[0].Residence_Address_Line_1__c != null && loanList[0].Residence_Address_Line_1__c != ''){
                        address = loanList[0].Residence_Address_Line_1__c ;
                        System.debug('name' + primaryAppName);
                    }
                }
                List<Character__c> charList = [SELECT Id,Customer_Type__c,Family_Member_Name__c,RecordType.Name,Relationship__c,Section_Type__c
                                               FROM 
                                               Character__C 
                                               WHERE 
                                               Application__c =: applicationId 
                                               AND 
                                               Section_Type__c = 'Family Detail'
                                               AND
                                               Customer_Type__c = 'Co-Applicant'
                                               AND
                                               RecordType.Name  ='AC Character'];
                System.debug('charList'+ charList);
                if(charList.size() == 0){
                    coAppName = new List<String>();
                    relationCoApp =''; 
                }
                else {
                    coAppName = new List<String>();
                    relationCoApp ='';
                    for(Character__c char1 : charList){
                        if(char1.Customer_Type__c == 'Co-Applicant'){
                            coAppName.add(char1.Family_Member_Name__c + ',' + char1.Relationship__c);
                        }
                    }
                }
                
                List<Character__c> charList1 = [SELECT Id,Customer_Type__c,Family_Member_Name__c,RecordType.Name,Relationship__c,Section_Type__c
                                                FROM 
                                                Character__C 
                                                WHERE 
                                                Application__c =: applicationId 
                                                AND 
                                                Section_Type__c = 'Family Detail'
                                                AND
                                                Customer_Type__c = 'Guarantor'
                                                AND
                                                RecordType.Name  ='AC Character'];
                System.debug('charList'+ charList1);
                if(charList1.size() == 0){
                    gurantorName = new List<String>();
                    relationGurantor =''; 
                }
                else {
                    gurantorName = new List<String>();
                    relationGurantor ='';
                    for(Character__c char1 : charList1){
                        if(char1.Customer_Type__c == 'Guarantor'){
                            gurantorName.add(char1.Family_Member_Name__c + ',' + char1.Relationship__c);
                        }
                    }
                }
                List<Sanction_Condition__c> sanctionConditionList = [SELECT Id, Application__c, Other_Condition__c, Print_In_Sanction_Letter__c, Remark__c, MsSanctionCondition__c
                                                                     FROM Sanction_Condition__c 
                                                                     WHERE Application__c = : applicationId];
                if(sanctionConditionList.size() == 0){
                    remarks = new List<String>();
                }
                else{
                    remarks = new List<String>();
                    for(Sanction_Condition__c sanction : sanctionConditionList){
                        if(sanction.Other_Condition__c != null){
                            remarks.add(sanction.Remark__c);
                        }
                    }
                }
                /*else{
                    remarks = '';
                    for(Sanction_Condition__c sanction : sanctionConditionList){
                        if(sanction.Other_Condition__c == 'Yes' && sanction.Print_In_Sanction_Letter__c == 'Yes'){
                            remarks += sanction.Remark__c;
                            remarks += ',';
                            System.debug('remark1' + remarks);
                        }else {
                            if(sanction.Other_Condition__c == 'No' && sanction.Print_In_Sanction_Letter__c == 'Yes'){
                                remarks += sanction.MsSanctionCondition__c;
                                remarks += ',';
                                System.debug('remark2' + remarks);
                            }
                            
                        }
                    }remarks = remarks.removeEnd(',');
                }*/              
            }
        }catch(Exception e){
            System.debug('Error msg 1'+e.getMessage()+'----->'+e.getLineNumber());
        }
    }
}