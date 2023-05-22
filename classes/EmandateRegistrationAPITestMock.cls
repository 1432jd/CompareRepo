@isTest
global class EmandateRegistrationAPITestMock  implements HttpCalloutMock {

     global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://example.com/example/test', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "1","url": "https://emandateuat.rblbank.com/enach/emandateuploadpage.aspx?ref=6wRfsmynaber9VIg%2FkAsNA%3D%3D&Mandatereqid=API942667890117345678910184983", "mandateReqID": "API942667890117345678910184983"}');
        res.setStatusCode(200);
        return res;
    }
}