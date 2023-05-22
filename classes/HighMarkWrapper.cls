public without sharing class HighMarkWrapper {
    public basePlusReportFile basePlusReportFile;
    
    public class basePlusReportFile {
        public basePlusReports basePlusReports;
    }
    
    public class basePlusReports {
        public basePlusReport basePlusReport;
    }
    
    public class basePlusReport {
        public header header;
        public request request;
        public personalInfoVariation personalInfoVariation;
        public accountsSummary accountsSummary;
        public responses[] responses;
        public inquiryHistory[] inquiryHistory;
        public scores scores;
        public printableReport printableReport;
    }
    
    public class header {
        public String dateOfRequest; //13-09-2022
        public String preparedFor; //FiveStar Business
        public String preparedForId; //NBF0000039
        public String dateOfIssue; //13-09-2022
        public String reportId; //Five220913CR374158151
        public String batchId; //316737134220913
        public String status; //SUCCESS
    }
    
    public class request {
        public String name; //KASHIBAI SIDARAY KUMBAR
        public String dob; //01-01-1968
        public String addresss1; //KUMBAR GALLI JAMKHANDI 131 BAGALKOT 587301 BAGALKOT 587301 KA
        public String mbrId; //M12345
        public String creditInqPurpsTyp; //ACCT-ORIG
        public String creditInqPurpsTypDesc; //Others
        public String creditInquiryStage; //PRE-SCREEN
        public String creditRptId; //CR12345
        public String creditReqTyp; //INDV
        public String creditRptTrnDtTm; //M12345
        public String losAppId; //101M12345
        public String loanAmount; //500000
    }
    
    public class personalInfoVariation {
        public nameVariations[] nameVariations;
        public addressVariations[] addressVariations;
        public panVariations[] panVariations;
        public drivingLicenseVariations[] drivingLicenseVariations;
        //public drivingLicenseVariations drivingLicenseVariations; //Changed on 19/04/23
        public dateOfBirthVariations[] dateOfBirthVariations;
        public voterIdVariations[] voterIdVariations;
        public passportVariations[] passportVariations; 
        //public passportVariations passportVariations; //Changed on 19/04/23
        public phoneNumberVariations[] phoneNumberVariations;
        // public rationCardVariations rationCardVariations;
        public rationCardVariations[] rationCardVariations;
        //public emailVariations emailVariations;
        public emailVariations[] emailVariations;
    }
    
    public class nameVariations {
        public variation variation;
    }
    
    public class variation {
        public String value; //6673842636
        public String reportedDate; //31-05-2020
    }
    
    public class addressVariations {
        public variation variation;
    }
    
    public class panVariations {
        public variation variation;
    }
    
    public class drivingLicenseVariations {
        public variation variation;
    }
    
    public class dateOfBirthVariations {
        public variation variation;
    }
    
    public class voterIdVariations {
        public variation variation;
    }
    
    public class passportVariations {
        public variation variation;
    }
    
    public class phoneNumberVariations {
        public variation variation;
    }
    
    public class rationCardVariations {
        public variation variation;
    }
    
    public class emailVariations {
        public variation variation;
    }
    
    public class accountsSummary {
        public derivedAttributes derivedAttributes;
        public primaryAccountsSummary primaryAccountsSummary;
        public secondaryAccountsSummary secondaryAccountsSummary;
    }
    
    public class derivedAttributes {
        public String inquiriesInLastSixMonths; //0
        public String lengthOfCreditHistoryYear; //6
        public String lengthOfCreditHistoryMonth; //3
        public String averageAccountAgeYear; //1
        public String averageAccountAgeMonth; //11
        public String newAccountsInLastSixMonths; //0
        public String newDelinqAccountsInLastSixMonths; //0
    }
    
    public class primaryAccountsSummary {
        public String primaryNumberOfAccounts; //19
        public String primaryActiveNumberOfAccounts; //7
        public String primaryOverdueNumberrOfAccounts; //6
        public String primarySecuredNumberOfAccounts; //0
        public String primaryUnsecuredNumberOfAccounts; //0
        public String primaryUntaggedNumberOfAccounts; //0
        public String primaryCurrentBalance; //9,96,934
        public String primarySanctionedAmount; //2,72,460
        public String primaryDisbursedAmount; //2,72,460
    }
    
    public class secondaryAccountsSummary {
        public String secondaryNumberOfAccounts; //0
        public String secondaryActiveNumberOfAccounts; //0
        public String secondaryOverdueNumberOfAccounts; //0
        public String secondarySecuredNumberOfAccounts; //0
        public String secondaryUnSecuredNumberOfAccounts; //0
        public String secondaryUntaggedNumberOfAccounts; //0
        public String secondaryCurrentBalance; //0
        public String secondarySanctionedAmount; //0
        public String secondaryDisbursedAmount; //0
    }
    
    public class responses {
        public response response;
    }
    
    public class response {
        public loanDetails loanDetails;
    }
    
    public class loanDetails {
        public String acctNumber; //XXXX
        public String creditGuarantor; //XXXX
        public String acctType; //JLG Individual
        public String dateReported; //31-05-2020
        public String ownershipInd; //Primary
        public String accountStatus; //Active
        public String disbursedAmt; //14,000
        public String disbursedDt; //05-02-2014
        public String installationAmt; //318/Weekly
        public String overdueAmt;
        public String installmentAmt;
        public String writOffAmt; //0
        public String currentBal; //1,28,956
        public String combinedPaymentHistory;
        public String matchedType; //PRIMARY
        public String creditLimit; //14,000
        public String repaymentTenure; //50
    }
    
    public class inquiryHistory {
        public history history;
    }
    
    public class history {
        public String memberName; //XXXX
        public String inquiryDate; //15-07-2021
        public String purpose; //Education Loan
        public String ownershipType; //PRIMARY
        public String amount; //2,00,000
    }
    
    public class scores {
        public score score;
    }
    
    public class score {
        public String scoreType; //PERFORM-Consumer
        public String scoreValue; //702
        public String scoreComments; //F-Medium Risk
    }
    
    public class printableReport {
        public String type; //PDF
        public String fileName; //Five220913CR374158151.html
        public String content; //
    }
    
    public static HighMarkWrapper parse(String json){
        return (HighMarkWrapper) System.JSON.deserialize(json, HighMarkWrapper.class);
    }
}