@isTest
global class FsIFSCControllerTestMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        system.debug('req' + req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        if (req.getEndpoint().endsWith('PUNB0013600')) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"MICR":"176024102","BRANCH":"DHARAMSALA, DISTT. DHARAMSALA","ADDRESS":"KOTWALI BAZAR","STATE":"HIMACHAL PRADESH","CONTACT":"","UPI":true,"RTGS":true,"CITY":"DHARAMSHALA","CENTRE":"DHARAMSHALA","DISTRICT":"DHARAMSHALA","NEFT":true,"IMPS":true,"SWIFT":null,"ISO3166":"IN-HP","BANK":"Punjab National Bank","BANKCODE":"PUNB","IFSC":"PUNB0013600"}');
            res.setStatusCode(200);
            res.setStatus('Ok');
            return res;
        } else if (req.getEndpoint().endsWith('HDFC0001636')) {
            HTTPResponse res1 = new HTTPResponse();
            res1.setStatusCode(404);
            res1.setStatus('Not Found');
            return res1;
        } else {
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
        }
    }
}