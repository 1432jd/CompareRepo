public class ApplicantDocumentGeneratorController {
    
    public String recordId{get;set;}
    public String docType{get;set;}
    public ApplicantWrapper applicants{get;set;}
    public WitnessWrapper witness{get;set;}
    public Loan_Applicant__c objLoan{get;set;}
    public Date docDate{get;set;}
    public String branchAddress{get;set;}
    public Decimal agriculturalIncome{get;set;}
    public Decimal otherIncome{get;set;}
    
    public ApplicantDocumentGeneratorController(){
        objLoan = new Loan_Applicant__c(); 
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        applicants = new ApplicantWrapper();
        witness = new WitnessWrapper();
        if(ApexPages.currentPage().getParameters().get('borrowerName') != null)
            System.debug(ApexPages.currentPage().getParameters().get('borrowerName'));
        if(ApexPages.currentPage().getParameters().get('witnessName') != null)
            System.debug(ApexPages.currentPage().getParameters().get('witnessName'));
        if(ApexPages.currentPage().getParameters().get('witnessAddress') != null)
            System.debug(ApexPages.currentPage().getParameters().get('witnessAddress'));
        if(ApexPages.currentPage().getParameters().get('witnessMonthsKnown') != null)
            System.debug(ApexPages.currentPage().getParameters().get('witnessMonthsKnown'));
        if(ApexPages.currentPage().getParameters().get('witnessRelation') != null)
            System.debug(ApexPages.currentPage().getParameters().get('witnessRelation'));
        if(ApexPages.currentPage().getParameters().get('borrowerName') != null && ApexPages.currentPage().getParameters().get('witnessName') != null 
           && ApexPages.currentPage().getParameters().get('witnessAddress') != null && ApexPages.currentPage().getParameters().get('witnessMonthsKnown') != null
           && ApexPages.currentPage().getParameters().get('witnessRelation') != null){
               witness.borrowerName = ApexPages.currentPage().getParameters().get('borrowerName');
               witness.witnessName = ApexPages.currentPage().getParameters().get('witnessName');
               witness.witnessAddress = ApexPages.currentPage().getParameters().get('witnessAddress');
               witness.witnessMonthsKnown = ApexPages.currentPage().getParameters().get('witnessMonthsKnown');
               witness.witnessRelation = ApexPages.currentPage().getParameters().get('witnessRelation');
           }
        if(ApexPages.currentPage().getParameters().get('docType') != null){
            docType = ApexPages.currentPage().getParameters().get('docType');
        }
        objLoan = [SELECT Id, Customer_Information__c, Customer_Information__r.Name, Customer_Information__r.PersonBirthdate, Application__r.Name, Application__r.Sourcing_Branch__r.Name,Application__r.Emi_PcAc__c,
                   Residence_Address_Line_1__c, Residence_City__c, Residence_State__c, Residence_Country__c, Residence_Pincode__r.Name,Customer_Type__c, Application__c, Application__r.Total_Amount_Recommended_PcAc__c,
                   Application__r.Balance_Transfer__c,Application__r.Tranche_Disbursal__c,Application__r.AC_Submission_Date__c
                   FROM Loan_Applicant__c
                   WHERE Id = :recordId];
        branchAddress = objLoan.Application__r.Sourcing_Branch__r.Name;
        Agreement_Execution_Document_Generation__c objAG = new Agreement_Execution_Document_Generation__c();
        objAG = [SELECT Id,MOD_Date__c,Agreement_Stamping_Date__c
                 FROM Agreement_Execution_Document_Generation__c
                 WHERE RecordType.Name = 'Schedule A' AND Application__c = :objLoan.Application__c ORDER BY CreatedDate DESC LIMIT 1];
        applicants.applicationName = objLoan.Application__r.Name;
        applicants.applicantName = objLoan.Customer_Information__r.Name;
        applicants.applicantAge = calculateAge(objLoan.Customer_Information__r.PersonBirthdate);
        if(String.isNotEmpty(objLoan.Residence_Address_Line_1__c) && String.isNotBlank(objLoan.Residence_Address_Line_1__c))
            applicants.applicantAddress = objLoan.Residence_Address_Line_1__c+', ';
        if(String.isNotEmpty(objLoan.Residence_City__c) && String.isNotBlank(objLoan.Residence_City__c))
            applicants.applicantAddress += objLoan.Residence_City__c+', ';
        if(String.isNotEmpty(objLoan.Residence_State__c) && String.isNotBlank(objLoan.Residence_State__c))
            applicants.applicantAddress += objLoan.Residence_State__c+', ';
        if(String.isNotEmpty(objLoan.Residence_Pincode__r.Name) && String.isNotBlank(objLoan.Residence_Pincode__r.Name))
            applicants.applicantAddress += objLoan.Residence_Pincode__r.Name;
        applicants.applicantAddress.removeEnd(',');
        applicants.applicationDOB = objLoan.Customer_Information__r.PersonBirthdate;
        if(objLoan.Application__r.Balance_Transfer__c == 'No' && objLoan.Application__r.Tranche_Disbursal__c != 'II'){
            docDate = objAG.MOD_Date__c >= objAG.Agreement_Stamping_Date__c ? objAG.MOD_Date__c : objAG.Agreement_Stamping_Date__c;
        }
        else if(objLoan.Application__r.Balance_Transfer__c != 'No' || objLoan.Application__r.Tranche_Disbursal__c == 'II'){
            docDate = objLoan.Application__r.AC_Submission_Date__c;
        }
        else{
            docDate = System.today();
        }
        agriculturalIncome = getAgriculturalIncome(objLoan.Application__c,recordId).agriIncome != 0 ? (getAgriculturalIncome(objLoan.Application__c,recordId).agriIncome) : null ;
        otherIncome = getAgriculturalIncome(objLoan.Application__c,recordId).otrIncome != 0 ? (getAgriculturalIncome(objLoan.Application__c,recordId).otrIncome) : null ;
    }
    
    public Integer calculateAge(Date dob){
        Integer days = dob.daysBetween(Date.Today());
        Integer age = Integer.valueOf(days/365);
        return age;
    }
    
    public incomeWrapper getAgriculturalIncome(String applicationId,String loanAppId){
        List<Capability__c> capabilities = new List<Capability__c>();
        Decimal monthlyIncome = 0;
        Decimal otrIncome = 0;
        incomeWrapper income = new incomeWrapper();
        capabilities = [SELECT Id, Customer_Information__c, Segment__c, Income_segment__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
                        Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
                        Electricity__c, Rent__c, Others__c, Salary__c,Gross_Monthly_Income__c
                        FROM Capability__c 
                        WHERE Application__c =: applicationId  AND Loan_Applicant__c = :loanAppId AND RecordType.Name = 'AC Capability'];
        
        for(Capability__c cap : capabilities){
            System.debug('monthlyIncome '+monthlyIncome);
            System.debug('otrIncome '+otrIncome);
            if(cap.Income_segment__c == 'Daily wages' && cap.Subsegment__c == 'Agri labour'){
                System.debug('cap.Gross_Monthly_Income__c '+cap.Gross_Monthly_Income__c);
                monthlyIncome += cap.Income_per_day__c * cap.Number_of_days__c;
            } 
            else if(cap.Subsegment__c != 'Agri labour'){
                if(cap.Income_segment__c == 'Salaried'){
                    otrIncome += cap.Monthly_Salary__c;
                } 
                else if(cap.Income_segment__c == 'Rental Income'){
                    otrIncome += cap.Rental_Income__c;
                } 
                else if(cap.Income_segment__c == 'Daily wages'){
                    otrIncome += cap.Income_per_day__c * cap.Number_of_days__c;
                } 
                else if(cap.Income_segment__c == 'Pension' || cap.Income_segment__c == 'Income from Abroad'){
                    otrIncome += cap.Income_per_month__c;
                } 
                else if(cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                          cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                          cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                          cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed'){
                              if(cap.Day_Margin_Basis__c == 'Day Basis'){
                                  System.debug('Day BASIS');
                                  otrIncome += cap.Income_per_day__c * cap.Number_of_days__c;
                                  System.debug('otrIncome '+otrIncome);
                              } 
                              else if(cap.Day_Margin_Basis__c == 'Margin Basis'){
                                  Decimal totalSales = Integer.valueOf(cap.Sales_per_month__c);
                                  Decimal margin = cap.Margin__c != null ? cap.Margin__c : 0;
                                  Decimal totalIncome = 0;
                                  if(totalSales != NULL && totalSales != 0){
                                      totalIncome = (totalSales / 100 * margin);
                                  }
                                  if(cap.Electricity__c != Null && cap.Electricity__c != 0){
                                      totalIncome = totalIncome - cap.Electricity__c;
                                  }
                                  if(cap.Rent__c != Null && cap.Rent__c != 0){
                                      totalIncome = totalIncome - cap.Rent__c;
                                  }
                                  if(cap.Others__c != Null && cap.Others__c != 0){
                                      totalIncome = totalIncome - cap.Others__c;
                                  }
                                  if(cap.Salary__c != Null && cap.Salary__c != 0){
                                      totalIncome = totalIncome - cap.Salary__c;
                                  }
                                  otrIncome += totalIncome;
                              }
                          }
            }
        }
        System.debug('otrIncome '+otrIncome);
        income.agriIncome = monthlyIncome;
        income.otrIncome = otrIncome;
        return income;
    }
    
    @AuraEnabled    
    public static void generateApplicantAgreementExecutionDocs(String recordId){
        List<String> vfPageName = new List<String>{'SignatureMismatchLetterVf','AadharConsentVF','VernacularVF','Form60'};
            List<ContentVersion> cvList = new List<ContentVersion>();
        List<Loan_Applicant__c> loanAppList = [SELECT Id,Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c = :recordId];
        for(Loan_Applicant__c objLoan : loanAppList){
            for(String vfName : vfPageName){
                PageReference pdf;
                if(vfName == 'SignatureMismatchLetterVf')
                    pdf = Page.SignatureMismatchLetterVf; 
                if(vfName == 'AadharConsentVF')
                    pdf = Page.AadharConsentVF; 
                if(vfName == 'VernacularVF')
                    pdf = Page.VernacularVF; 
                if(vfName == 'Form60')
                    pdf = Page.Form60;
                pdf.getParameters().put('recordId',objLoan.Id);
                Blob body;   
                if(Test.isRunningTest()) { 
                    body = blob.valueOf('Unit.Test');
                } else {
                    body = pdf.getContentAsPDF();
                }    
                ContentVersion cv = new ContentVersion(Title = objLoan.Customer_Information__r.Name+'-'+vfName, PathOnClient =vfName+'.PDF', VersionData = body, FirstPublishLocationId = recordId);
                cvList.add(cv); 
            }   
        }
        System.debug('cvList '+cvList);
        if(cvList.size() > 0)
            INSERT cvList; 
    }
    
    public WitnessWrapper getWitness(String applicationId){
        Agreement_Execution_Document_Generation__c objAE = new Agreement_Execution_Document_Generation__c();
        objAE = [SELECT Id,  Borrower__c, Witness__c, Witness_Name__c, Witness_Address__c , Application__c, Relationship_Between_Borrower_And_Witnes__c, No_of_years_known__c 
                 FROM Agreement_Execution_Document_Generation__c
                 WHERE Application__c = : applicationId AND RecordType.Name = 'Vernacular / LTI Declaration'];  
        WitnessWrapper objWrap = new WitnessWrapper();
        objWrap.witnessName = objAE.Witness_Name__c;
        objWrap.witnessAddress = objAE.Witness_Address__c;
        objWrap.witnessRelation = objAE.Relationship_Between_Borrower_And_Witnes__c;
        objWrap.witnessMonthsKnown = String.valueOf(objAE.No_of_years_known__c);
        return objWrap;
    }
    
    public class ApplicantWrapper{
        public String applicantName{get;set;}
        public String applicantAddress{get;set;}
        public String applicationName{get;set;}
        public Date applicationDOB{get;set;}
        public Integer applicantAge{get;set;}
    }
    
    public class WitnessWrapper{
        public String borrowerName{get;set;}
        public String witnessName{get;set;}
        public String witnessAddress{get;set;}
        public String witnessRelation{get;set;}
        public String witnessMonthsKnown{get;set;}
    }
    
    public class incomeWrapper{
        public Decimal agriIncome{get;set;}
        public Decimal otrIncome{get;set;}
    }
}