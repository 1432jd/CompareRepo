@isTest
global class KotakCalculateAPITestMock implements HttpCalloutMock {

       global HTTPResponse respond(HTTPRequest req) {
      
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"request":{"requestInfo":{"creationDate":"2017-04-10T05:14:15","sourceName":"ABC","transactionId":"123"},"requestPayload":{"transactions":[{"transactionData":{"userName":"lo116","calculatePremium":{"dateOfBirth":"23/03/1979","sumAssured":200000,"loanCommencementDate":"10/04/2017","policyTerm":"1","premiumFunding":"No","typeOfLoan":"Affinity Insurance","planCode":"GO000002","userName":"LO116","policyMod":"Single premium","policyRole":"Single Life","secondaryInsDob":"","primaryGender":"M","borrowerStateCode":"MH"}},"type":"CalculatePrem"}]}}}');
		res.setStatusCode(200);
        return res;
    }

}