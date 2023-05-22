@isTest
public without sharing class OCRControllerTest {

    @isTest
    public static void doAadhaarFrontTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
        String base64 = 'iVBORw0KGgoAAAANSUhEUgAAAgUAAAFiCAYAAABmhatyAAAAAXNSR0IArs4c6QA';
        String body = '{\"requestId\":\"185d33f1-1d95-4e6a-ba97-c8218a26e3ad\",\"result\":[{\"details\":{\"aadhaar\":{\"value\":\"853875354900\",\"conf\":1.0,\"isMasked\":\"no\"},\"dob\":{\"value\":\"01/07/1974\",\"conf\":1.0},\"father\":{\"value\":\"\",\"conf\":0},\"gender\":{\"value\":\"MALE\",\"conf\":1.0},\"mother\":{\"value\":\"\",\"conf\":0},\"name\":{\"value\":\"PrakashGopichandRathod\",\"conf\":1.0},\"yob\":{\"value\":\"\",\"conf\":0},\"imageUrl\":{\"value\":\"\"},\"qr\":{\"value\":\"\"}},\"type\":\"AadhaarFrontBottom\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Aadhaar Card';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_AC_FRONT', kyc.Id, 'Aadhaar Card', 'FRONT');
        test.stopTest();
    }
    
    @isTest
    public static void doAadhaarBackTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
        String base64 = 'iVBORw0KGgoAAAANSUhEUgAAAgUAAAFiCAYAAABmhatyAAAAAXNSR0IArs4c6QA';
        String body = '{\"requestId\":\"f0cf1440-bd39-49d5-a91b-5e545f95bb8e\",\"result\":[{\"details\":{\"aadhaar\":{\"value\":\"4133\",\"conf\":0.58,\"isMasked\":\"no\"},\"address\":{\"value\":\"S/O:Kathirvel,24MUKKUDIVELAMPALAYAMMAINSTREETErode,Pasur,TamilNadu,638154\",\"conf\":1.0},\"pin\":{\"value\":\"638154\",\"conf\":0},\"imageUrl\":{\"value\":\"\"},\"qr\":{\"value\":\"\"},\"father\":{\"value\":\":Kathirvel\",\"conf\":1.0},\"husband\":{\"value\":\"\",\"conf\":0},\"addressSplit\":{\"careOf\":\"S/O:Kathirvel\",\"houseNumber\":\"24\",\"city\":\"Pasur\",\"line1\":\"24\",\"line2\":\"MUKKUDIVELAMPALAYAMMAINSTREET\",\"street\":\"MUKKUDIVELAMPALAYAMMAINSTREET\",\"locality\":\"\",\"landmark\":\"\",\"district\":\"Erode\",\"state\":\"TamilNadu\",\"pin\":\"638154\"}},\"type\":\"AadhaarBack\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(''));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Aadhaar Card';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        //test.startTest();
        //OCRController.getOCRData(listKYC);
        //call = OCRController.doOCRCallout(base64, 'OCR_AC_BACK', kyc.Id, 'Aadhaar Card', 'BACK');
        //test.stopTest();
    }
    
     @isTest
    public static void doPanTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
        String base64 = 'JVBERi0xLjcKCjQgMCBvYmoKPDwKL0JpdHNQZXJDb21wb25lbnQgOAovQ29sb3JTcGFjZSAvRGV2aWNlUk';
        String body = '{\"requestId\":\"7ae304d5-9e5a-415c-9846-945c2489e934\",\"result\":[{\"details\":{\"date\":{\"value\":\"10/04/1992\",\"conf\":1.0},\"dateOfIssue\":{\"value\":\"\",\"conf\":0},\"father\":{\"value\":\"JAYABAL\",\"conf\":0.94},\"name\":{\"value\":\"IVELAVENDAN\",\"conf\":0.97},\"panNo\":{\"value\":\"BDOPV9321H\",\"conf\":1.0}},\"type\":\"Pan\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Pan Card';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_PAN', kyc.Id, 'Pan Card', 'FRONT');
        test.stopTest();
    }
    
     @isTest
    public static void doVoterFrontTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
        String base64 = 'JVBERi0xLjcKCjQgMCBvYmoKPDwKL0JpdHNQZXJDb21wb25lbnQgOAovQ29sb3JTcGFjZSAv';
        String body = '{\"requestId\":\"b2b1e485-f68b-40d2-b3c0-b59ef5496809\",\"result\":[{\"details\":{\"voterid\":{\"value\":\"ZY81003408\",\"conf\":1.0},\"name\":{\"value\":\"EameraHasmL\",\"conf\":1.0},\"relation\":{\"value\":\"aurpanSeukar\",\"conf\":0.8}},\"type\":\"VoteridFrontNew\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Voter Id';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_VI_FRONT', kyc.Id, 'Voter Id', 'FRONT');
        test.stopTest();
    }
    
     @isTest
    public static void doVoterBackTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
        String base64 = 'JVBERi0xLjcKCjQgMCBvYmoKPDwKL0JpdHNQZXJDb21wb25lbnQgOAovQ29sb3JTcGFjZSAv';
        String body = '{\"requestId\":\"db697f52-f86b-4036-bee1-51fe1c226589\",\"result\":[{\"details\":{\"voterid\":{\"value\":\"\",\"conf\":0},\"address\":{\"value\":\"Dasvtaevhamanarfivauraakanpmamd-anatunsamxooMt3527Pdvyatkna/rikailhDvae1n3oh\",\"conf\":0.81},\"pin\":{\"value\":\"\",\"conf\":0.81},\"gender\":{\"value\":\"\",\"conf\":0},\"date\":{\"value\":\"\",\"conf\":0},\"age\":{\"value\":\"\",\"conf\":0},\"dob\":{\"value\":\"\",\"conf\":0},\"type\":{\"value\":\"\",\"conf\":0},\"addressSplit\":{\"houseNumber\":\"\",\"city\":\"\",\"line1\":\"DasvtaevhamanarfivauraakanpmamdanatunsamxooMt3527Pdvyatkna/rikailhDvae1n3oh\",\"line2\":\"\",\"street\":\"\",\"locality\":\"\",\"landmark\":\"\",\"district\":\"\",\"state\":\"\",\"pin\":\"\"}},\"type\":\"VoteridBack\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Voter Id';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_VI_BACK', kyc.Id, 'Voter Id', 'BACK');
        test.stopTest();
    }
    
     @isTest
    public static void doDLFrontTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
        String base64 = 'JVBERi0xLjcKCjQgMCBvYmoKPDwKL0JpdHNQZXJDb21wb25lbnQgOAovQ';
        String body = '{\"requestId\":\"ac9f951b-389e-41ae-af49-0f8b016b195a\",\"result\":[{\"details\":{\"dlNo\":{\"value\":\"TN-4120060005889\",\"conf\":0.56},\"name\":{\"value\":\"SURESHBABUP\",\"conf\":0.97},\"dob\":{\"value\":\"02/02/1986\",\"conf\":0.52}},\"type\":\"DLFront\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Driving License';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_DL_FRONT', kyc.Id, 'Driving License', 'FRONT');
        test.stopTest();
    }
    
    @isTest
    public static void doDLBackTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
        String base64 = 'JVBERi0xLjcKCjQgMCBvYmoKPDwKL0JpdHNQZXJDb21wb25lbnQgOAovQ';
        String body = '{\"requestId\":\"8fb7b824-254b-49da-853e-e58d77d65234\",\"result\":[{\"details\":{\"dlNo\":{\"value\":\"\",\"conf\":0.0},\"name\":{\"value\":\"\",\"conf\":0.0},\"dob\":{\"value\":\"\",\"conf\":0.0}},\"type\":\"DLFront\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Driving License';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_DL_BACK', kyc.Id, 'Driving License', 'BACK');
        test.stopTest();
    }
    
     @isTest
    public static void doPassportFrontTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
	    String base64 = '';
        String body = '{\"requestId\":\"0908e201-5596-49cf-8ef2-9d6a923a4d99\",\"result\":[{\"details\":{\"countryCode\":{\"value\":\"IND\",\"conf\":0.98},\"dob\":{\"value\":\"01/11/1993\",\"conf\":0.9},\"doe\":{\"value\":\"23/08/2027\",\"conf\":0.9},\"doi\":{\"value\":\"24/08/2017\",\"conf\":0.9},\"gender\":{\"value\":\"MALE\",\"conf\":0.97},\"givenName\":{\"value\":\"NARESH\",\"conf\":0.98},\"surname\":{\"value\":\"SIDLAGHATTAKRISHNAMURTHY\",\"conf\":0.98},\"nationality\":{\"value\":\"\",\"conf\":0.0},\"passportNum\":{\"value\":\"R3952227\",\"conf\":0.97},\"placeOfBirth\":{\"value\":\"SIDLAGHATTA,KARNATAKA\",\"conf\":0.53},\"placeOfIssue\":{\"value\":\"BENGALURU\",\"conf\":1.0},\"type\":{\"value\":\"P\",\"conf\":0.98},\"mrz\":{\"line1\":\"P<INDSIDLAGHATTA<KRISHNAMURTHY<<NARESH<<<<<<\",\"line2\":\"R3952227<5IND9311011M2708230<<<<<<<<<<<<<<<2\",\"conf\":0.97}},\"type\":\"PassportFront\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Passport';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_PS_FRONT', kyc.Id, 'Passport', 'FRONT');
        test.stopTest();
    }
    
     @isTest
    public static void doPassportBackTest(){
        OCRController.ReturnWrapper obj = new OCRController.ReturnWrapper();
        obj = OCRController.initialize();
        OCRController ocr = new OCRController();
        OCRController.CalloutWrapper call = new OCRController.CalloutWrapper();
	    String base64 = '';
        String body = '{\"requestId\":\"04da0af8-5b92-4bb3-a076-f06591247fef\",\"result\":[{\"details\":{\"passportNum\":{\"value\":\"\",\"conf\":0.0},\"fileNum\":{\"value\":\"MD1067798746714\",\"conf\":0.99},\"father\":{\"value\":\"RAJENDRAN\",\"conf\":0.59},\"mother\":{\"value\":\"KUPPUMANI\",\"conf\":0.99},\"oldDoi\":{\"value\":\"\",\"conf\":0.0},\"oldPassportNum\":{\"value\":\"\",\"conf\":0.0},\"oldPlaceOfIssue\":{\"value\":\"\",\"conf\":0.0},\"pin\":{\"value\":\"625012\",\"conf\":0.8},\"spouse\":{\"value\":\"\",\"conf\":0.0},\"address\":{\"value\":\"4/3NNO:38,THIRUVALLUVARSTREET,AVANIYAPURAM,MADURAIRURAL,PIN:625012,TAMILNADU,INDIA\",\"conf\":0.88},\"addressSplit\":{\"houseNumber\":\"4/3NNO:38\",\"city\":\"\",\"line1\":\"4/3NNO:38\",\"line2\":\"THIRUVALLUVARSTREETAVANIYAPURAMRURALPIN:625012\",\"street\":\"THIRUVALLUVARSTREET\",\"locality\":\"AVANIYAPURAM\",\"landmark\":\"\",\"district\":\"Madurai\",\"state\":\"TamilNadu\",\"pin\":\"625012\"}},\"type\":\"PassportBack\"}],\"statusCode\":101,\"description\":\"SuccessfulOCR\"}';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutHelperMock(body));
        Kyc__c kyc = new Kyc__c();
        kyc.Name = 'Passport';
        insert kyc;
        List<String> listKYC = new List<String>();
        listKYC.add(kyc.Id);
        test.startTest();
        OCRController.getOCRData(listKYC);
        call = OCRController.doOCRCallout(base64, 'OCR_PS_BACK', kyc.Id, 'Passport', 'BACK');
        test.stopTest();
    }
}