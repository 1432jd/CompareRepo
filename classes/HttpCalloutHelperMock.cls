@isTest
global class HttpCalloutHelperMock  implements HttpCalloutMock { 
    
    global String reqBody;
    global Integer reqStatusCode;
    
    public HttpCalloutHelperMock(String body){
        reqBody = body;
    }
    
    public HttpCalloutHelperMock(String body,Integer statusCode){
        reqBody = body;
        reqStatusCode = statusCode;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(reqBody);
        if(reqStatusCode!=null)
        	res.setStatusCode(reqStatusCode);
        else
           res.setStatusCode(200); 
        return res;
    }
}