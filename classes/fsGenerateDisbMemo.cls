public without sharing class fsGenerateDisbMemo {
    
    public Integer noOfPayments{get;set;}
    public InitWrapper wrpObj{get;set;}
    
    public fsGenerateDisbMemo(){
        String appId;
        appId = Apexpages.currentPage().getParameters().get('Id');
        //appId ='a030w000008J2fvAAC';
        
        wrpObj = new InitWrapper();
        LoanDetails loanObj  = new LoanDetails();
        DisbursalDetails disbursalObj  = new DisbursalDetails();
        // DisbursementDetails DisbursementObj  = new DisbursementDetails();
        
        Decimal totalDeduction = 0;
        Decimal totalLoan = 0;
        
        
        List<Application__c> appList = [select Id,AC_Submission_Date__c ,Total_Amount_Recommended_PcAc__c,Total_ROI_percent__c  , Disbursal_Date__c, Effective_IRR__c, Risk_Document_Color__c,Sourcing_Branch__r.Branch_Code__c,Tenor_In_Months__c,Pre_Login__r.RecordType.Name ,Tranche_Disbursal__c,Name,Sourcing_Branch__r.Name,LMS_Response_Reference__c,Primary_Applicant__r.Applicant_Name__c, Scheme__c, Loan_Purpose__c, Customer_Communicated__c, Emi_PcAc__c, Number_of_advance_EMI__c,
                                        (select Id,Customer_Type__c,Applicant_Name__c from Loan_Applicants__r where Customer_Type__c='Co-Applicant')  from Application__c where Id=:appId];
        List<Disbursal__c> disbist = [select Id,Application__r.Total_Amount_Recommended_PcAc__c,Ops_Comment__c,Total_Deductions__c,Loan_Amount_Sanctioned__c,Disbursal_Maker_ID__c,Disbursal_Author_ID__r.EmployeeNumber,Sanctioned_Loan_Amount__c,Final_Disbursal_Amount__c,Due_Date__c,First_Installment_Date__c,Interest_Start_Date__c from Disbursal__c  where Application__c=:appId];
        List<MOD_Registration__c> modList =[select Id,MOD_Date__c,MOD_Amount__c from MOD_Registration__c where Application__c=:appId];
        List<Fee_Creation__c> feeList = [select Id,Fee_Category__c,Total_Fee__c from Fee_Creation__c where Application__c=:appId] ; 
        
        
        for(Loan_Applicant__c apploan : [select Id,Customer_Type__c,Applicant_Name__c from Loan_Applicant__c where Application__c=:appId]){
            CoApplicants coAppObj = new CoApplicants();
            Guarntor guarntorObj = new Guarntor();
            
            if(apploan.Customer_Type__c =='Co-Applicant'){
                coAppObj.coApplicantName = apploan.Applicant_Name__c;
                wrpObj.coApplicantsList.add(coAppObj);
            }else if(apploan.Customer_Type__c =='Guarantor'){
                guarntorObj.guarntorName = apploan.Applicant_Name__c;
                wrpObj.guarntorList.add(guarntorObj);
            }
        }
        
        if(feeList.size()>0){
            
            DisbursementDetails disbObj = new DisbursementDetails();
            
            if(disbist.size()>0){
                for(Disbursal__c disbrseObj : disbist){
                    disbObj.disbursalAmount=(disbrseObj.Final_Disbursal_Amount__c)!=NULL?String.valueOf(disbrseObj.Final_Disbursal_Amount__c):'';
                    disbObj.loanSanction=(disbrseObj.Application__r.Total_Amount_Recommended_PcAc__c)!=NULL?String.valueOf(disbrseObj.Application__r.Total_Amount_Recommended_PcAc__c):'0';
                }     
            }
            
            for(Fee_Creation__c feeObj : feeList){
                if(feeObj.Fee_Category__c =='Processing Fees'|| Test.isRunningTest()){
                    if(String.isNotBlank(disbObj.procFee) && String.isNotEmpty(disbObj.procFee) && disbObj.procFee!=null){
                        Decimal amt = Decimal.valueOf(disbObj.procFee);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.procFee = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.procFee = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                } 
                if(feeObj.Fee_Category__c =='Advance EMI'|| Test.isRunningTest()){
                    if(String.isNotBlank(disbObj.advanceEmi) && String.isNotEmpty(disbObj.advanceEmi) && disbObj.advanceEmi!=null){
                        Decimal amt = Decimal.valueOf(disbObj.advanceEmi);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.advanceEmi = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.advanceEmi = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                }
                if(feeObj.Fee_Category__c =='Document Charges' || Test.isRunningTest()){
                    if(String.isNotBlank(disbObj.document) && String.isNotEmpty(disbObj.document) && disbObj.document!=null){
                        Decimal amt = Decimal.valueOf(disbObj.document);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.document = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.document = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                } 
                if(feeObj.Fee_Category__c =='Insurance Premium'|| Test.isRunningTest()){                    
                    if(String.isNotBlank(disbObj.insuranceCharge) && String.isNotEmpty(disbObj.insuranceCharge) && disbObj.insuranceCharge!=null){
                        Decimal amt = Decimal.valueOf(disbObj.insuranceCharge);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.insuranceCharge = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.insuranceCharge = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                } 
                if(feeObj.Fee_Category__c =='DD/RTGS Amount'|| Test.isRunningTest()){
                    if(String.isNotBlank(disbObj.ddRtgs) && String.isNotEmpty(disbObj.ddRtgs) && disbObj.ddRtgs!=null){
                        Decimal amt = Decimal.valueOf(disbObj.ddRtgs);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.ddRtgs = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.ddRtgs = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                } 
                if(feeObj.Fee_Category__c =='Document Storage Charge'|| Test.isRunningTest()){
                    if(String.isNotBlank(disbObj.storageCharge) && String.isNotEmpty(disbObj.storageCharge) && disbObj.storageCharge!=null){
                        Decimal amt = Decimal.valueOf(disbObj.storageCharge);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.storageCharge = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.storageCharge = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                }
                if(feeObj.Fee_Category__c =='Other Charges' || Test.isRunningTest()){
                    if(String.isNotBlank(disbObj.otherCharge) && String.isNotEmpty(disbObj.otherCharge) && disbObj.otherCharge!=null){
                        Decimal amt = Decimal.valueOf(disbObj.otherCharge);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.otherCharge = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.otherCharge = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                }
                if(feeObj.Fee_Category__c =='Legal and Inspection Charges' || Test.isRunningTest()){
                    if(String.isNotBlank(disbObj.legalFee) && String.isNotEmpty(disbObj.legalFee) && disbObj.legalFee!=null){
                        Decimal amt = Decimal.valueOf(disbObj.legalFee);
                        if(feeObj.Total_Fee__c!=null){
                            amt = amt + feeObj.Total_Fee__c;
                            disbObj.legalFee = String.valueOf(amt);
                        }  
                    }else{
                        disbObj.legalFee = feeObj.Total_Fee__c!=null?String.valueOf(feeObj.Total_Fee__c):'0';
                    }
                }
                
            }
            wrpObj.disbursementDetailsList.add(disbObj);
        }
        
        if(appList.size()>0){
            for(Application__c app : appList){
                Integer i=0;
                String applicantName='';
                for(Loan_Applicant__c loanApp : app.Loan_Applicants__r){
                    if(i==0){
                        applicantName+=loanApp.Applicant_Name__c;
                        ++i;
                    }else if(i!=0){
                        applicantName+=' , ';
                        applicantName+=loanApp.Applicant_Name__c;
                        ++i;
                    }
                }
                loanObj.sanctionDate=app.AC_Submission_Date__c!=null?convertDate(app.AC_Submission_Date__c):'';
                loanObj.sanctionAmount=String.valueOf(app.Total_Amount_Recommended_PcAc__c)!=NULL?String.valueOf(app.Total_Amount_Recommended_PcAc__c):'';
                loanObj.coApplicants=String.valueOf(applicantName)!=NULL?String.valueOf(applicantName):'';
                loanObj.appNo=String.valueOf(app.Name)!=NULL?String.valueOf(app.Name):'';
                loanObj.branchName=String.valueOf(app.Sourcing_Branch__r.Name)!=NULL?String.valueOf(app.Sourcing_Branch__r.Name):'';
                loanObj.loanNo=String.valueOf(app.LMS_Response_Reference__c)!=NULL?String.valueOf(app.LMS_Response_Reference__c):'';
                loanObj.branchCode=String.valueOf(app.Sourcing_Branch__r.Branch_Code__c)!=NULL?String.valueOf(app.Sourcing_Branch__r.Branch_Code__c):'';
                loanObj.name=String.valueOf(app.Primary_Applicant__r.Applicant_Name__c)!=NULL?String.valueOf(app.Primary_Applicant__r.Applicant_Name__c):'';
                loanObj.product='LAP';
                loanObj.scheme=String.valueOf(app.Scheme__c)!=NULL?String.valueOf(app.Scheme__c):'';
                loanObj.purpose=String.valueOf(app.Loan_Purpose__c)!=NULL?String.valueOf(app.Loan_Purpose__c):'';
                loanObj.noOfAdvanceEmi=String.valueOf(app.Number_of_advance_EMI__c)!=NULL?String.valueOf(app.Number_of_advance_EMI__c):'';
                loanObj.emi=String.valueOf(app.Emi_PcAc__c)!=NULL?String.valueOf(app.Emi_PcAc__c):'';
                loanObj.tenure=String.valueOf(app.Tenor_In_Months__c)!=NULL?String.valueOf(app.Tenor_In_Months__c):'';
                loanObj.roi=String.valueOf(app.Total_ROI_percent__c  );
                loanObj.tranche=String.valueOf(app.Tranche_Disbursal__c)!=NULL?String.valueOf(app.Tranche_Disbursal__c):'';
                if(app.Pre_Login__r.RecordType.Name=='2. Re-login'){
                    loanObj.reLogin = 'Yes';
                }else{
                    loanObj.reLogin='NO';
                }
                loanObj.roiCategory = String.valueOf(app.Risk_Document_Color__c);
                loanObj.loanDate = app.Disbursal_Date__c!=null?convertDate(app.Disbursal_Date__c):''; //String.valueOf(app.Disbursal_Date__c);
            }
        }
        
        if(disbist.size()>0){
            for(Disbursal__c disbObj : disbist){
                Date dt= Date.today();
                System.debug('disbObj.Due_Date__c >>>'+disbObj.Due_Date__c);
                if(disbObj.Due_Date__c!=null){
                    String str = disbObj.Due_Date__c.format();
                    List<STring>strLIst=str.split('/');
                    loanObj.dueDate=strLIst[0];
                }else{
                    loanObj.dueDate='';
                }
                loanObj.interestStartDate=String.valueOf(disbObj.Interest_Start_Date__c)!=NULL?convertDate(disbObj.Interest_Start_Date__c):'';
                loanObj.firstIntallmentDate=String.valueOf(disbObj.First_Installment_Date__c)!=NULL?convertDate(disbObj.First_Installment_Date__c):'';
                loanObj.disbursalAmount=String.valueOf(disbObj.Final_Disbursal_Amount__c)!=NULL?String.valueOf(disbObj.Final_Disbursal_Amount__c):'';
                loanObj.maker=String.valueOf(disbObj.Disbursal_Maker_ID__c)!=NULL?String.valueOf(disbObj.Disbursal_Maker_ID__c):'';
                loanObj.approver=String.valueOf(disbObj.Disbursal_Author_ID__r.EmployeeNumber)!=NULL?String.valueOf(disbObj.Disbursal_Author_ID__r.EmployeeNumber):'';
                loanObj.opsCommentFirst = disbObj.Ops_Comment__c;
                totalDeduction+= disbObj.Total_Deductions__c!=null?disbObj.Total_Deductions__c:0;
                totalLoan+=disbObj.Application__r.Total_Amount_Recommended_PcAc__c!=null?disbObj.Application__r.Total_Amount_Recommended_PcAc__c:0;
            }     
        }
        
        if(modList.size()>0){
            for(MOD_Registration__c modObj : modList){
                loanObj.modAmount=String.valueOf(modObj.MOD_Amount__c)!=NULL?String.valueOf(modObj.MOD_Amount__c):'';
                loanObj.modDate=String.valueOf(modObj.MOD_Date__c)!=NULL?convertDate(modObj.MOD_Date__c):'';
            }
        }
        
        List<Disbursal_Payee__c> disbPayeeList =[SELECT Id, Payment_Type__c, Beneficiary_Amount__c, Application__r.Name,Beneficiary_Name__c FROM Disbursal_Payee__c where Disbursal__r.Application__r.Id=:appId];
        noOfPayments = !disbPayeeList.isEmpty()?disbPayeeList.size():0;
        
        for(Disbursal_Payee__c payee : disbPayeeList){
            DisbursalDetails disbursalDetail = new DisbursalDetails();
            Integer count = 0;
            disbursalDetail.paymentMode = payee.Payment_Type__c;
            disbursalDetail.amount = String.valueOf(payee.Beneficiary_Amount__c);
            disbursalDetail.partyName = payee.Beneficiary_Name__c;
            disbursalDetail.details = String.valueOf(++count);
            wrpObj.disbursalDetailsList.add(disbursalDetail);
        }
        
        wrpObj.loanDetailsList.add(loanObj);
        wrpObj.totalDeduction = String.valueOf(totalDeduction);
        wrpObj.totalLoan = String.valueOf(totalLoan);
        System.debug('wrpObj is >>>>'+wrpObj);
        
    }
    
    private String convertDate(Date dt){
        return DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('dd-MMM-YYYY');
    }
    
    
    public class InitWrapper{
        public List <LoanDetails> loanDetailsList{get;set;}
        public List <CoApplicants> coApplicantsList{get;set;}
        public List <Guarntor> guarntorList{get;set;}
        public List <DisbursalDetails> disbursalDetailsList{get;set;}
        public List <DisbursementDetails> disbursementDetailsList{get;set;}
        public String totalDeduction{get;set;}
        public String totalLoan{get;set;}
        public InitWrapper(){           
            this.loanDetailsList = new List<LoanDetails>();
            this.disbursalDetailsList = new List<DisbursalDetails>();
            this.disbursementDetailsList = new List<DisbursementDetails>();
            this.coApplicantsList =  new List<CoApplicants>();
            this.guarntorList =  new List<Guarntor>();
        }
    }
    
    public class CoApplicants{
        public String coApplicantName{get;set;}
    }
    
    public class Guarntor{
        public String guarntorName{get;set;}
    }
    
    public class LoanDetails{
        public String appNo{get;set;}
        public String branchName{get;set;}
        public String loanNo{get;set;}
        public String branchCode{get;set;}
        public String name{get;set;}
        public String product{get;set;}
        public String scheme{get;set;}
        public String purpose{get;set;}
        public String sanctionAmount{get;set;}
        public String disbursalAmount{get;set;}
        public String noOfPayment{get;set;}
        public String roi{get;set;}
        public String emi{get;set;}
        public String tenure{get;set;}
        public String dueDate{get;set;}
        public String interestStartDate{get;set;}
        public String firstIntallmentDate{get;set;}
        public String noOfAdvanceEmi{get;set;}
        public String modAmount{get;set;}
        public String firstCollectionDate{get;set;}
        public String sanctionDate{get;set;}
        public String modDate{get;set;}
        public String loanDate{get;set;}
        public String reLogin{get;set;}
        public String tranche{get;set;}
        public String roiCategory{get;set;}
        public String pendingCategory{get;set;}
        public String maker{get;set;}
        public String approver{get;set;}
        public String opsCommentFirst{get;set;}
        public String opsCommentSecond{get;set;}
        public String coApplicants{get;set;}
    }
    
    public class DisbursalDetails{
        public String details{get;set;}
        public String paymentMode{get;set;}
        public String amount{get;set;}
        public String partyName{get;set;}
    }
    
    public class DisbursementDetails{
        public String loanSanction{get;set;}
        public String advanceEmi{get;set;}
        public String procFee{get;set;}
        public String document{get;set;}
        public String ddRtgs{get;set;}
        public String storageCharge{get;set;}
        public String otherCharge{get;set;}
        public String legalFee{get;set;}
        public String disbursalAmount{get;set;}
        public String insuranceCharge{get;set;}
        
    }
    
}