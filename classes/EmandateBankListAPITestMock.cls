@isTest
global class EmandateBankListAPITestMock  implements HttpCalloutMock{

    public HttpResponse respond(HttpRequest request) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        throw e;
    }
}