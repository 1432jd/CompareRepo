public class fsGenerateStageReport {

public List<preLoginLoanAppWrap> preLoginDataList{get;set;}
public List<propertyOwnerWrapper> propertyOwnerList{get;set;}
public List<ApplicationDetailWrapper> applicationDetailList{get;set;}
public List<feeCreationWrapper> feeCreationList{get;set;}
public List<preLoginDocWrapper> preLoginDocList{get;set;}

public String  applicationId{get;set;}
public String  Stage{get;set;}

public fsGenerateStageReport(){

        applicationId ='a030w000008HwIQAA0';
       //  applicationId  =ApexPages.currentPage().getParameters().get('appId');
     Stage ='Approval Credit';
      //  Stage  =ApexPages.currentPage().getParameters().get('StageValue');

        if(Stage=='Approval Credit'){
                preLoginDataList = new List<preLoginLoanAppWrap>();
                propertyOwnerList = new List<propertyOwnerWrapper>();        
                applicationDetailList = new List<ApplicationDetailWrapper>();
                feeCreationList = new List<feeCreationWrapper>();
                preLoginDocList = new List<preLoginDocWrapper>();
    ///Starting of get Pre-Login loan-Applicant data////
    if(applicationId != Null){
        for(Loan_Applicant__c loanObj : [select Id,Application__c,Created_From__c,Application__r.Stage__c,Customer_Information__r.PersonBirthdate,Customer_Information__r.FirstName,Customer_Information__r.LastName,Customer_Type__c,Mobile__c,Mobile_Verified__c,Is_KYC_Verified__c,Residence_Pincode__r.Name,Residence_City__c
                                    from Loan_Applicant__c where Application__c=:applicationId /*AND Application__r.Stage__c=:Stage*/ AND Created_From__c='Pre Login']){
        
            preLoginLoanAppWrap wrapObj = new preLoginLoanAppWrap();
            wrapObj.personBirthdate = String.valueOf(loanObj.Customer_Information__r.PersonBirthdate);
            wrapObj.firstName  =loanObj.Customer_Information__r.FirstName;
            wrapObj.lastName =loanObj.Customer_Information__r.LastName;
            wrapObj.customerType =loanObj.Customer_Type__c;
            wrapObj.mobile =loanObj.Mobile__c;
            wrapObj.isMobileVerified =loanObj.Mobile_Verified__c;
            wrapObj.pincode =loanObj.Residence_Pincode__r.Name;
            wrapObj.city =loanObj.Residence_City__c;
            wrapObj.isKYCVerified = loanObj.Is_KYC_Verified__c;
            preLoginDataList.add(wrapObj);
        
    }

}

    ///Starting of get Pre-Login Property data////
       if(applicationId != Null){
        for(Property_Owners__c	 propertyObj : [select Id, Property_Owner__c,Loan_Applicant__r.Customer_Information__r.FirstName, Loan_Applicant__r.Customer_Information__r.LastName,
                                        Loan_Applicant__r.Applicant_Name__c,Property__r.State__c,Property__r.Pincode__r.Pincode__c	,Property__r.Property_Type__c,Property__r.Title_Deed_Type__c,Property__r.Title_Deed_Number__c,Property__r.Title_Deed_Date__c,Property__r.Property_Address__c,Property__r.Taluka__c,Property__r.District__c,Property__r.City__c
                                        from Property_Owners__c where Property__r.recordtype.name='Pre Login Property Detail' AND Loan_Applicant__r.Application__c=:applicationId /*AND Loan_Applicant__r.Application__r.Stage__c=:Stage*/]){


        propertyOwnerWrapper wrapObj = new propertyOwnerWrapper();
            wrapObj.propertyOwner = propertyObj.Loan_Applicant__r.Customer_Information__r.FirstName +' '+propertyObj.Loan_Applicant__r.Customer_Information__r.LastName;
            wrapObj.state = propertyObj.Property__r.State__c;
            wrapObj.pincode = propertyObj.Property__r.Pincode__r.Pincode__c;
            wrapObj.propertyType = propertyObj.Property__r.Property_Type__c;
            wrapObj.titeDeedType = propertyObj.Property__r.Title_Deed_Type__c;
            wrapObj.titeDeedNumber = propertyObj.Property__r.Title_Deed_Number__c;
            wrapObj.titeDeedDate = String.valueOf(propertyObj.Property__r.Title_Deed_Date__c).removeEnd(' 00:00:00');
            wrapObj.propertyAddress = propertyObj.Property__r.Property_Address__c;
            wrapObj.taluka = propertyObj.Property__r.Taluka__c;
            wrapObj.district = propertyObj.Property__r.District__c;
            wrapObj.city = propertyObj.Property__r.City__c;
            propertyOwnerList.add(wrapObj);
        }
}
    


    ///Starting of get Pre-Login Application data////

if(applicationId != Null){
for(Application__c appObj : [select Id,Staff_Loan__c, Field_Officer_Emp_Id__r.FirstName, Field_Officer_Emp_Id__r.LastName, Employee_ID__c, Customer_Visit_date__c,Requested_Loan_Amount__c,Channel__c,Alternate_Channel_Mode__c,Scheme__c,Sourcing_Branch__r.Name,Field_Officer_Emp_Id__r.Name
                                from Application__c where Id=:applicationId /*AND Stage__c=:Stage*/]){
            ApplicationDetailWrapper preLoginAppObj = new ApplicationDetailWrapper();
            preLoginAppObj.staffLoan = String.valueOf(appObj.Staff_Loan__c)!=NULL?String.valueOf(appObj.Staff_Loan__c):'';
            preLoginAppObj.customerVisitDate = String.valueOf(appObj.Customer_Visit_date__c)!=NULL?String.valueOf(appObj.Customer_Visit_date__c).removeEnd(' 00:00:00'):'';
            preLoginAppObj.requestedLoanAmount = String.valueOf(appObj.Requested_Loan_Amount__c)!=NULL?String.valueOf(appObj.Requested_Loan_Amount__c):'';
            preLoginAppObj.channel=String.valueOf(appObj.Channel__c)!=NULL?String.valueOf(appObj.Channel__c):'';
            preLoginAppObj.alternateChannelMode=String.valueOf(appObj.Alternate_Channel_Mode__c)!=NULL?String.valueOf(appObj.Alternate_Channel_Mode__c):'';
            preLoginAppObj.scheme=String.valueOf(appObj.Scheme__c)!=NULL?String.valueOf(appObj.Scheme__c):'';
            preLoginAppObj.sourcingBranchName=String.valueOf(appObj.Sourcing_Branch__r.Name)!=NULL?String.valueOf(appObj.Sourcing_Branch__r.Name):'';
            preLoginAppObj.fieldOfficerName=appObj.Field_Officer_Emp_Id__r.FirstName+' '+appObj.Field_Officer_Emp_Id__r.LastName;
            preLoginAppObj.empId = String.valueOf(appObj.Employee_ID__c)!=NULL?String.valueOf(appObj.Employee_ID__c):'';
            applicationDetailList.add(preLoginAppObj);
    }
    
}
        ///Starting of get Pre-Login Fee Creation data////
if(applicationId != Null){
    try{
      for(Fee_Creation__c feeObj : [select Id,Application__c,Fee_Code__c,Fee_Amount__c,Tax_Amount__c,Total_Fee__c,Fee_Collection__c,Type__c,Stage_Due__c,Applicable_on_Loan_Amount_Asset_Value__c,
                                     Repayment_Type_2__c,Description__c from Fee_Creation__c where Application__c=:applicationId]){

         feeCreationWrapper preLoginFeeObj = new feeCreationWrapper();
         preLoginFeeObj.feecode=String.valueOf(feeObj.Fee_Code__c)!=NULL?String.valueOf(feeObj.Fee_Code__c):'';
         preLoginFeeObj.feeAmount= String.valueOf(feeObj.Fee_Amount__c)!=NULL?String.valueOf(feeObj.Fee_Amount__c):'';
         preLoginFeeObj.taxAmount=String.valueOf(feeObj.Tax_Amount__c)!=NULL?String.valueOf(feeObj.Tax_Amount__c):'';
         preLoginFeeObj.totalFee=String.valueOf(feeObj.Total_Fee__c)!=NULL?String.valueOf(feeObj.Total_Fee__c):'';
         preLoginFeeObj.feeCollection=String.valueOf(feeObj.Fee_Collection__c)!=NULL?String.valueOf(feeObj.Fee_Collection__c):'';
         preLoginFeeObj.feeType=String.valueOf(feeObj.Type__c)!=NULL?String.valueOf(feeObj.Type__c):'';
         preLoginFeeObj.feeStageDue=String.valueOf(feeObj.Stage_Due__c)!=NULL?String.valueOf(feeObj.Stage_Due__c):'';
         preLoginFeeObj.feeLoanAmtOn=String.valueOf(feeObj.Applicable_on_Loan_Amount_Asset_Value__c)!=NULL?String.valueOf(feeObj.Applicable_on_Loan_Amount_Asset_Value__c):'';
         preLoginFeeObj.feeRepaymentType=String.valueOf(feeObj.Repayment_Type_2__c)!=NULL?String.valueOf(feeObj.Repayment_Type_2__c):'';
         preLoginFeeObj.description=String.valueOf(feeObj.Description__c)!=NULL?String.valueOf(feeObj.Description__c):'';
         feeCreationList.add(preLoginFeeObj);
     }
    }catch(Exception e){
        System.debug('exception is >>'+e.getmessage());
        System.debug('exception Line is >>'+e.getLineNumber());
    }
}

    

    ///Starting of get Pre-Login Doc data////

    if(applicationId != Null){
for(ContentDocumentLink contentDocObj : [SELECT Id, ContentDocument.title,LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility FROM ContentDocumentLink where LinkedEntityId=:applicationId]){
        preLoginDocWrapper obj = new preLoginDocWrapper();
        
        obj.docTitle=String.valueOf(contentDocObj.ContentDocument.title)!=NULL?contentDocObj.ContentDocument.title:'';
        preLoginDocList.add(obj);            
    }
    }
}

/*if(Stage=='Custody'){
   // fsGenerateCustodyReport custodyReport = new fsGenerateCustodyReport(applicationId,Stage);
}*/

}


public class WrpClass{
    public List<preLoginLoanAppWrap> preLoginLoanAppList{get;set;}
    public List<Application__c> preLoginAppList{get;set;}
    public List<propertyOwnerWrapper> preLoginPropertyList{get;set;}
    public List<Fee_Creation__c> preLoginFeeList{get;set;}
   // public List<preLoginDocWrapper> preDocList{get;set;}
}

public class preLoginDocWrapper{
    public String docTitle{get;set;}
}

public class preLoginLoanAppWrap{
    public String customerType{get;set;}
    public String personBirthdate{get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String mobile{get;set;}
    public Boolean isMobileVerified{get;set;}
    public Boolean isKYCVerified{get;set;}
    public String city{get;set;}
    public String pincode{get;set;}
}

public class propertyOwnerWrapper{
    public String state{get;set;}
    public String pincode{get;set;}
    public String propertyType{get;set;}
    public String city{get;set;}
    public String titeDeedType{get;set;}
    public String titeDeedNumber{get;set;}
    public String titeDeedDate{get;set;}
    public String propertyAddress{get;set;}
    public String taluka{get;set;}
    public String district{get;set;}
    public String propertyOwner{get;set;}
}

public class ApplicationDetailWrapper{
    public String staffLoan{get;set;}
    public String customerVisitDate{get;set;}
    public String requestedLoanAmount{get;set;}
    public String channel{get;set;}
    public String alternateChannelMode{get;set;}
    public String scheme{get;set;}
    public String sourcingBranchName{get;set;}
    public String fieldOfficerName{get;set;}
    public String empId{get;set;}
}

public class feeCreationWrapper{
		 
    public String feecode{get;set;}
    public String feeAmount{get;set;}
    public String taxAmount{get;set;}
    public String totalFee{get;set;}
    public String feeCollection{get;set;}
    public String feeType{get;set;}
    public String feeStageDue{get;set;}
    public String feeLoanAmtOn{get;set;}
    public String feeRepaymentType{get;set;}
    public String description{get;set;}
		 
}
}