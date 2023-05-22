@isTest
global class KYCAPIControllerMock  implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://example.com/example/test', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"basePlusReportFile":{"basePlusReports":{"basePlusReport":{"header":{"dateOfRequest":"30-12-2022","preparedFor":"FiveStar Business","preparedForId":"NBF0000039","dateOfIssue":"30-12-2022","reportId":"Five221230CR374867455","batchId":"317439428221230","status":"SUCCESS"},"request":{"name":"AEDUDODLA KOTI REDDY","dob":"04-03-1960","addresss1":"NO:17,  SURYAVAMSHI COLONY,  NEAR IMS SCHOOL DVK ROAD,  NALGONDA,  NALGONDA Nalgonda 508001 AP","mbrId":"M12345","creditInqPurpsTyp":"ACCT-ORIG","creditInqPurpsTypDesc":"Others","creditInquiryStage":"PRE-SCREEN","creditRptId":"CR12345","creditReqTyp":"INDV","creditRptTrnDtTm":"M12345","loanAmount":"0"},"personalInfoVariation":{"nameVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}],"addressVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}],"panVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}],"drivingLicenseVariations":null,"dateOfBirthVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}],"voterIdVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}],"passportVariations":null,"phoneNumberVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}],"rationCardVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}],"emailVariations":[{"variation":{"value":"6673842636","reportedDate":"12-09-2022"}}]},"accountsSummary":{"derivedAttributes":{"inquiriesInLastSixMonths":"1","lengthOfCreditHistoryYear":"0","lengthOfCreditHistoryMonth":"0","averageAccountAgeYear":"0","averageAccountAgeMonth":"0","newAccountsInLastSixMonths":"0","newDelinqAccountsInLastSixMonths":"0"},"primaryAccountsSummary":{"primaryNumberOfAccounts":"0","primaryActiveNumberOfAccounts":"0","primaryOverdueNumberrOfAccounts":"0","primarySecuredNumberOfAccounts":"0","primaryUnsecuredNumberOfAccounts":"0","primaryUntaggedNumberOfAccounts":"0","primaryCurrentBalance":"0","primarySanctionedAmount":"0","primaryDisbursedAmount":"0"},"secondaryAccountsSummary":{"secondaryNumberOfAccounts":"0","secondaryActiveNumberOfAccounts":"0","secondaryOverdueNumberOfAccounts":"0","secondarySecuredNumberOfAccounts":"0","secondaryUnSecuredNumberOfAccounts":"0","secondaryUntaggedNumberOfAccounts":"0","secondaryCurrentBalance":"0","secondarySanctionedAmount":"0","secondaryDisbursedAmount":"0"}},"inquiryHistory":[{"history":{"memberName":"FiveStar Business C","inquiryDate":"29-12-2022","purpose":"Other","ownershipType":"PRIMARY","amount":"0"}}],"printableReport":{"type":"PDF","fileName":"Five221230CR374867455.html","content":"xyz"}}}}}');
        
        res.setStatusCode(200);
        return res;
    }
}