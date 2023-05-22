@isTest
global class EmandateStatusAPITestMock  implements HttpCalloutMock {

       global HTTPResponse respond(HTTPRequest req) {
      
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('{"status":"1","mandatereqid":"APItest0123457791010116","name":"veeta nair","mobilenumber":"+91-9773801229","telephonenumber":"+91-022-11234543","emailid":"veneetiaaaaaabcedfghijklknopqurstuvwdxyz@gmail.com","panno":"PPAZM1234M","accounttype":"savings","accountnumber":"11111","amount":"128.00","amounttype":"Fixed Amount","startdate":"12-08-2022","enddate":"07-08-2023","untilcancel":"False","fequency":"BIMN%Bi-Monthly","purpose":"Bill Payment Credit card","corpname":"nita pvt ltd","catcode":"B001","catdesc":"Bill Payment Credit card","umrnno":null,"rejectreson":"Merchant Cat Description is not approved list","rejby":"NPCI","npcirefmsgid":null,"mandatestatus":"Failed","requestdatetime":"8/12/2022 14:00:08","responsedatetime":"8/12/2022 14:00:21","bankname":"AXIS BANK","authenticationmode":"NetBanking","utilitycode":"RATN00005000010550"}');
		res.setStatusCode(200);
        return res;
    }
}