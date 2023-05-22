@isTest
public class DedupeAPITest implements HttpCalloutMock {
    
    	protected integer statuscode;
        protected String Body;
        
        public DedupeAPITest(integer code,String Body){
            this.statuscode=code;
            this.Body=body;
    	}
    
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(Body);
            res.setStatusCode(statuscode);
            return res;
        }

    @TestSetup
    public static void setupDedupeData() {
        
        List<Application__c> appList = new List<Application__c>();
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        List<Dedupe_Loan_Detail__c> dedupeLoanList = new List<Dedupe_Loan_Detail__c>();
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        List<Account> accList = new List<Account>();
        
        Account acc = new Account();
        acc.FirstName='ram';
        acc.LastName='kumar';
        accList.add(acc);
        insert accList;
        
        Application__c app = new Application__c();
        app.Stage__c ='Login';
      	insert app;
        
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Application__c=app.Id;
        loanAppObj.KYC_Id_1__c='HQD4572046';
        loanAppObj.KYC_Id_2__c='HQD4572046';
        loanAppObj.KYC_ID_Type_1__c	='Voter Id';
        loanAppObj.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj.Customer_Information__c=accList[0].Id;
        loanAppList.add(loanAppObj);
        
        Loan_Applicant__c loanAppObj1 = new Loan_Applicant__c();
        loanAppObj1.Application__c=app.Id;
        loanAppObj1.KYC_Id_1__c='HQD4572046';
        loanAppObj1.KYC_Id_2__c='HQD4572046';
        loanAppObj1.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj1.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj1.Customer_Information__c=accList[0].Id;
        loanAppList.add(loanAppObj1);
        
        Loan_Applicant__c loanAppObj2 = new Loan_Applicant__c();
        loanAppObj2.Application__c=app.Id;
        loanAppObj2.KYC_Id_1__c='HQD4572046';
        loanAppObj2.KYC_Id_2__c='HQD4572046';
        loanAppObj2.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj2.Customer_Information__c=accList[0].Id;
        loanAppList.add(loanAppObj2);
        
        Loan_Applicant__c loanAppObj3 = new Loan_Applicant__c();
        loanAppObj3.Application__c=app.Id;
        loanAppObj3.KYC_Id_1__c='HQD4572046';
        loanAppObj3.KYC_Id_2__c='HQD4572046';
        loanAppObj3.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj3.Customer_Information__c=accList[0].Id;
        loanAppList.add(loanAppObj3);
        
        Loan_Applicant__c loanAppObj4 = new Loan_Applicant__c();
        loanAppObj4.Application__c=app.Id;
        loanAppObj4.KYC_Id_1__c='HQD4572046';
        loanAppObj4.KYC_Id_2__c='HQD4572046';
        loanAppObj4.KYC_ID_Type_1__c	='Aadhaar Card';
        loanAppObj4.KYC_ID_Type_2__c='Voter Id';
        loanAppObj4.Customer_Information__c=accList[0].Id;
        loanAppList.add(loanAppObj4);
        
        Loan_Applicant__c loanAppObj5 = new Loan_Applicant__c();
        loanAppObj5.Application__c=app.Id;
        loanAppObj5.KYC_Id_1__c='HQD4572046';
        loanAppObj5.KYC_Id_2__c='HQD4572046';
        loanAppObj5.KYC_ID_Type_1__c	='Pan Card';
        loanAppObj5.KYC_ID_Type_2__c='Pan Card';
        loanAppObj5.Customer_Information__c=accList[0].Id;
        loanAppList.add(loanAppObj5);
        
        Loan_Applicant__c loanAppObj6 = new Loan_Applicant__c();
        loanAppObj6.Application__c=app.Id;
        loanAppObj6.KYC_Id_1__c='HQD4572046';
        loanAppObj6.KYC_Id_2__c='HQD4572046';
        loanAppObj6.KYC_ID_Type_1__c	='Driving License';
        loanAppObj6.KYC_ID_Type_2__c='Driving License';
        loanAppObj6.Customer_Information__c=accList[0].Id;
        loanAppList.add(loanAppObj6);
        
        Loan_Applicant__c loanAppObj7 = new Loan_Applicant__c();
        loanAppObj7.Application__c=app.Id;
        loanAppObj7.KYC_Id_1__c='HQD4572046';
        loanAppObj7.KYC_Id_2__c='HQD4572046';
        loanAppObj7.KYC_ID_Type_1__c	='Passport';
        loanAppObj7.KYC_ID_Type_2__c='Passport';
        loanAppObj7.Customer_Information__c=accList[0].Id;
        loanAppObj7.LMS_Customer_Info_File_Number__c ='qq';
        loanAppList.add(loanAppObj7);
        insert loanAppList;
        
        Dedupe_Detail__c dd = new Dedupe_Detail__c();
        dd.Application__c = app.Id;
        dd.Loan_Applicant__c = loanAppList[0].Id;
        dd.Archive__c = false;
        insert dd;    
    }
    @isTest
    public static void methodOne(){   
        Application__c app = [SELECT ID ,Stage__c FROM Application__c WHERE Stage__c='Login'];
        List<Dedupe_Detail__c> dedAppList =[select Id,Button_Name__c,Dedupe_Invoke_From__c,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__c,Loan_Applicant__r.Application__c,CIF_Id__c from Dedupe_Detail__c where CIF_Id__c='xyz123' LIMIT 1];
        List<Loan_Applicant__c> loanApplicantList =[select Id,Application__c from Loan_Applicant__c];
		String response='{ "applicant": [ { "applicant": { "applicantId": "a0qC2000000A64BIAS", "matches": [ { "match": { "customerRelId": "GLBCUST00000898260", "cifId": "GLBCUST00000898260", "source": "LMS", "loans": [ { "loan": { "lan": "FSTNLALONS000005248606", "lanstatus": "A", "applicationNo": "APPL00311886", "applicationStatus": "Post Disbursal", "applicantType": "Co-Applicant", "branchCode": "TN016", "branchName": "Coimbatore-II", "firstName": "NAVEEN", "lastName": "K", "gender": "MALE", "fatherName": "", "motherName": "", "spouseName": "", "dob": "31-05-1997", "mobileNo": "8838719696", "residenceAddress": { "addressLine1": "25/4 , PARISALTHURAI STREET , THIMMARAYANPALAYAM , METTUPALAYAM , SIRUMUGAI , COIMBATORE", "addressLine2": "", "addressLine3": "", "city": "Periyar", "district": "", "state": "Tamil Nadu", "pincode": "641302" } } }, { "loan": { "lan": "FSTNLALONS000005259639", "lanstatus": "A", "applicationNo": "APPL00337435", "applicationStatus": "Post Disbursal", "applicantType": "Co-Applicant", "branchCode": "TN016A", "branchName": "Coimbatore 22", "firstName": "NAVEEN", "lastName": "K", "gender": "MALE", "fatherName": "", "motherName": "", "spouseName": "", "dob": "31-05-1997", "mobileNo": "8838719696", "residenceAddress": { "addressLine1": "25/4 , PARISALTHURAI STREET , THIMMARAYANPALAYAM , METTUPALAYAM , SIRUMUGAI , COIMBATORE", "addressLine2": "", "addressLine3": "", "city": "Periyar", "district": "", "state": "Tamil Nadu", "pincode": "641302" } } }, { "loan": { "lan": "FSTNLALONS000005277797", "lanstatus": "A", "applicationNo": "APPT0523", "applicationStatus": "", "applicantType": "Co-Applicant", "branchCode": "TN091", "branchName": "SHOLINGUR", "firstName": "NAVEEN", "lastName": "K", "gender": "MALE", "fatherName": "", "motherName": "", "spouseName": "", "dob": "31-05-1997", "mobileNo": "8838719696", "residenceAddress": { "addressLine1": "25/4 , PARISALTHURAI STREET , THIMMARAYANPALAYAM , METTUPALAYAM , SIRUMUGAI , COIMBATORE", "addressLine2": "", "addressLine3": "", "city": "", "district": "", "state": "", "pincode": "641302" } } } ], "kycIds": { "pan": "FJUPK2431K", "passport": null, "aadhaar": "999999999892", "voterId": null, "drivingLicense": null } } } ] } } ] }';
        DedupeAPITest fakeResponse = new DedupeAPITest(200,response);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        DedupeAPI.callDedupeAPI(loanApplicantList[0].Application__c,'Pc','Check Dedupe',loanApplicantList);
        Test.stopTest();
    }
}