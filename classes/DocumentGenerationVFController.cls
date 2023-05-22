public class DocumentGenerationVFController {
    public String recordId{get;set;}
    public List<ApplicantWrapper> applicants{get;set;}
    public Application__c application{get;set;}
    public String amountInWords{get;set;} 
    public Loan_Applicant__c loanApp{get;set;}
    public Property__c objProp{get;set;}
    public List<PropertyWrapper> listPropWrap{get;set;}
    public Date docDate{get;set;}
    public String toAddress{get;set;}
    public DocumentGenerationVFController(){
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>(); 
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        applicants = new List<ApplicantWrapper>();
        application = new Application__c();
        listPropWrap = new List<PropertyWrapper>();
        objProp = new Property__c();
        loanApp = new Loan_Applicant__c();
        application = [SELECT Id, Name,Record_Type__c,Loan_Amount__c,Effective_IRR__c,Balance_Transfer__c,
                       Tranche_Disbursal__c,AC_Submission_Date__c, Total_ROI_percent__c,Name__c,
                       Tenure_Requested__c, Sourcing_Branch__r.Name, Tenor_In_Months__c ,
                       Total_Amount_Recommended_PcAc__c, Customer_Communicated__c,Emi_PcAc__c,
                       Sourcing_Branch__r.Branch_Address_Line_1__c,Sourcing_Branch__r.Branch_Address_Line_2__c,Sourcing_Branch__r.Branch_Address_Line_3__c,
                       Sourcing_Branch__r.Branch_City__c,Sourcing_Branch__r.Branch_Code__c,Sourcing_Branch__r.Branch_Pincode__c,Sourcing_Branch__r.Branch_State__c,LMS_Response_Reference__c
                       FROM Application__c
                       WHERE Id = :recordId];
        toAddress = application.Sourcing_Branch__r.Name+' '+application.Sourcing_Branch__r.Branch_Code__c+' ';
        if(String.isNotBlank(application.Sourcing_Branch__r.Branch_Address_Line_1__c))
            toAddress += application.Sourcing_Branch__r.Branch_Address_Line_1__c+' ';
        if(String.isNotBlank(application.Sourcing_Branch__r.Branch_Address_Line_2__c))
            toAddress += application.Sourcing_Branch__r.Branch_Address_Line_2__c+' ';
        if(String.isNotBlank(application.Sourcing_Branch__r.Branch_Address_Line_3__c))
            toAddress += application.Sourcing_Branch__r.Branch_Address_Line_3__c+' ';
        if(String.isNotBlank(application.Sourcing_Branch__r.Branch_City__c))
            toAddress += application.Sourcing_Branch__r.Branch_City__c+' '; 
        if(String.isNotBlank(application.Sourcing_Branch__r.Branch_State__c))
            toAddress += application.Sourcing_Branch__r.Branch_State__c+' '; 
        if(String.isNotBlank(application.Sourcing_Branch__r.Branch_Pincode__c))
            toAddress += application.Sourcing_Branch__r.Branch_Pincode__c+' ';     
        Agreement_Execution_Document_Generation__c objAG = new Agreement_Execution_Document_Generation__c();
        objAG = [SELECT Id,MOD_Date__c,Agreement_Stamping_Date__c
                 FROM Agreement_Execution_Document_Generation__c
                 WHERE RecordType.Name = 'Schedule A' AND Application__c = :recordId ORDER BY CreatedDate DESC LIMIT 1];
        if(application.Balance_Transfer__c == 'No' && application.Tranche_Disbursal__c != 'II'){
            docDate = objAG.MOD_Date__c >= objAG.Agreement_Stamping_Date__c ? objAG.MOD_Date__c : objAG.Agreement_Stamping_Date__c;
        }
        else if(application.Balance_Transfer__c != 'No' || application.Tranche_Disbursal__c == 'II'){
            docDate = application.AC_Submission_Date__c;
        }
        else{
            docDate = System.today();
        }
        amountInWords = DatabaseUtililty.amountInWords(application.Total_Amount_Recommended_PcAc__c);
        loanAppList = [SELECT Id, Customer_Information__c, Customer_Information__r.Name, Customer_Information__r.PersonBirthdate, Application__r.Name, Application__r.Sourcing_Branch__r.Name,
                       Residence_Address_Line_1__c, Residence_City__c, Residence_State__c, Residence_Country__c, Residence_Pincode__r.Name,Customer_Type__c 
                       FROM Loan_Applicant__c
                       WHERE Application__c = :recordId 
                       ORDER BY Customer_Type__c];
        Integer count = 0;
        for(Loan_Applicant__c objLoan : loanAppList){
            count = count+1;
            ApplicantWrapper objWrap = new ApplicantWrapper();
            objWrap.applicantName = objLoan.Customer_Information__r.Name;
            objWrap.applicantAge = calculateAge(objLoan.Customer_Information__r.PersonBirthdate);
            if(String.isNotEmpty(objLoan.Residence_Address_Line_1__c) && String.isNotBlank(objLoan.Residence_Address_Line_1__c))
                objWrap.applicantAddress = objLoan.Residence_Address_Line_1__c+', ';
            if(String.isNotEmpty(objLoan.Residence_City__c) && String.isNotBlank(objLoan.Residence_City__c))
                objWrap.applicantAddress += objLoan.Residence_City__c+', ';
            if(String.isNotEmpty(objLoan.Residence_State__c) && String.isNotBlank(objLoan.Residence_State__c))
                objWrap.applicantAddress += objLoan.Residence_State__c+', ';
            if(String.isNotEmpty(objLoan.Residence_Pincode__r.Name) && String.isNotBlank(objLoan.Residence_Pincode__r.Name))
                objWrap.applicantAddress += objLoan.Residence_Pincode__r.Name;
            objWrap.applicantAddress.removeEnd(',');
            objWrap.applicantType = objLoan.Customer_Type__c == 'Primary Applicant' ? 'Borrower' : objLoan.Customer_Type__c == 'Co-Applicant' ? 'Co-Borrower' : 'Guarantor';
            objWrap.counter = count;
            applicants.add(objWrap);
        } 
        loanApp = getPrimaryApplicant(recordId);
        listPropWrap = getPropertyDetails(recordId);
    }
    
    public Loan_Applicant__c getPrimaryApplicant(String applicationId){
        Loan_Applicant__c objLoan = [SELECT Id, Customer_Information__c, Customer_Information__r.Name, Customer_Information__r.PersonBirthdate, Application__r.Name,
                                     Application__r.Sourcing_Branch__r.Name,Residence_Address_Line_1__c, Residence_City__c, Residence_State__c, Residence_Country__c,
                                     Residence_Pincode__r.Name,Customer_Type__c,Application__r.Loan_Amount__c,Application__r.Emi_PcAc__c,Application__r.Total_Amount_Recommended_PcAc__c
                                     FROM Loan_Applicant__c
                                     WHERE Application__c = :applicationId AND Customer_Type__c = 'Primary Applicant'];
        return objLoan;
    }
    
    public List<PropertyWrapper> getPropertyDetails(String applicationId){
        List<PropertyWrapper> listPropWrap = new List<PropertyWrapper>();
        List<Property__c> listProp = [SELECT Id,Title_Deed_Number__c,Title_Deed_Type__c,Nature_Of_Property__c,Title_Deed_Date__c,Document_Type__c
                                      FROM Property__c
                                      WHERE Application__c = : applicationId AND RecordType.Name = 'Legal Approval'];
        if(listProp.size() > 0){
            Integer count = 0;
            for(Property__c objProp : listProp){
                count = count + 1;
                PropertyWrapper wrapProp = new PropertyWrapper();
                wrapProp.propTitleDeedNumber = objProp.Title_Deed_Number__c;
                wrapProp.propTitleDeedType = objProp.Document_Type__c;
                wrapProp.propNatureOfDoc = objProp.Nature_Of_Property__c;
                wrapProp.propTitleDeedDate = objProp.Title_Deed_Date__c;
                wrapProp.counter = count;
                listPropWrap.add(wrapProp);
            }
        }
        return listPropWrap;
    }
    
    public Property__c getTitleDeedNumber(String recordId){
        return [SELECT Id,Title_Deed_Number__c FROM Property__c WHERE Id = :recordId];
    }
    
    public Integer calculateAge(Date dob){
        Integer days = dob.daysBetween(Date.Today());
        Integer age = Integer.valueOf(days/365);
        return age;
    }
    
    @AuraEnabled   
    public static void generateAgreementExecutionDocs(String recordId){
        List<String> vfPageName = new List<String>{'Schedule_A','DPN','End_Use_Declaration','InsuranceUndertakingLetterVf','ModAmountVf'}; //'Form60',
            List<ContentVersion> cvList = new List<ContentVersion>();
        List<Loan_Applicant__c> loanAppList = [SELECT Id, Customer_Information__c, Customer_Information__r.Name, Customer_Information__r.PersonBirthdate, Application__r.Name, Application__r.Sourcing_Branch__r.Name,
                                               Residence_Address_Line_1__c, Residence_City__c, Residence_State__c, Residence_Country__c, Residence_Pincode__r.Name,Customer_Type__c 
                                               FROM Loan_Applicant__c
                                               WHERE Application__c = :recordId 
                                               ORDER BY Customer_Type__c];
        for(String vfName : vfPageName){
            PageReference pdf;
            if(vfName == 'Schedule_A')
                pdf = Page.Schedule_A; 
            if(vfName == 'DPN')
                pdf = Page.DPN;
            if(vfName == 'End_Use_Declaration')
                pdf = Page.End_Use_Declaration;
            if(vfName == 'InsuranceUndertakingLetterVf')
                pdf = Page.InsuranceUndertakingLetterVf; 
            if(vfName == 'ModAmountVf')
                pdf = Page.ModAmountVf; 
            pdf.getParameters().put('recordId',recordId);
            Blob body;   
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }    
            ContentVersion cv = new ContentVersion(Title = vfName, PathOnClient =vfName+'.PDF', VersionData = body, FirstPublishLocationId = recordId);
            cvList.add(cv); 
        }
        System.debug('cvList '+cvList);
        if(cvList.size() > 0)
            INSERT cvList; 
    }
    
    public class ApplicantWrapper{
        public String applicantName{get;set;}
        public String applicantAddress{get;set;}
        public String applicantType{get;set;}
        public Integer applicantAge{get;set;}
        public Integer counter{get;set;}
    }
    
    public class PropertyWrapper{
        public String propTitleDeedNumber{get;set;}
        public String propTitleDeedType{get;set;}
        public String propNatureOfDoc{get;set;}
        public Date propTitleDeedDate{get;set;}
        public Integer counter{get;set;}
    }   
}