@isTest
global class EmandateRequeryAPITestMock implements HttpCalloutMock {

       global HTTPResponse respond(HTTPRequest req) {
      
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"status": "1","url": "https://emandateuat.rblbank.com/enach/emandateuploadpage.aspx?ref=6wRfsmynaber9VIg%2FkAsNA%3D%3D&amp;Mandatereqid=API942667890117345678910184090"}');
		res.setStatusCode(200);
        return res;
    }

}