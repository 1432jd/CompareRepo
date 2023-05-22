@isTest
global class FS_LMS_CreateRecieptPayOutAPITestMock implements HttpCalloutMock {

       global HTTPResponse respond(HTTPRequest req) {
      
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"success":[{"i18nCode":"msg.00000117","messageArguments":["19758089"],"type":"INFO","isParent":false,"value":"msg.00000117 : Receipt entry done successfully. Receipt ref # 19758089."}]}');
		res.setStatusCode(201);
        return res;
    }

}