@isTest
public class OwnerValidationsControllerTest implements HttpCalloutMock{
    
    protected integer statuscode;
    protected String Body;
    
    public OwnerValidationsControllerTest(integer code,String Body){
        this.statuscode=code;
        this.Body=body;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(Body);
        res.setStatusCode(statuscode);
        return res;
    }    
    @TestSetup
    static void testdata(){
        Account acc = new Account();
        acc.LastName = 'test1';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        insert acc;
        
        Id NewLoginRecordType = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        Pre_Login__c listlogin = new Pre_Login__c();
        Pre_Login__c login1= new Pre_Login__c(Status__c='Active',RecordTypeId= NewLoginRecordType);
        Pre_Login__c login2= new Pre_Login__c(Status__c='Rejected',RecordTypeId = NewLoginRecordType);
        insert login1;
        
        Property__c prp = new Property__c();
        prp.Login__c= login1.Id;
        prp.Address_Line_2__c = 'Testing';
        insert prp;
        
        Application__c app= new Application__c();
        app.Applicant_Name__c = 'Application';
        app.Pre_Login__c = login1.Id;
        insert app;
        
        Verification__c verObj= new Verification__c();
        Id OnlineECRecordType = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        verObj.RecordTypeId = OnlineECRecordType;
        verObj.Application__c= app.Id;
        verObj.Status__c = 'Pending';
        insert verObj;
    }
    
    @isTest
    static void callOwnersAPIsVehicleRCTest(){
        Map<String,String> params = new Map<String,String>();
        params.put('chassisNo','1234567890');
        Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
        Application__c app = [Select Id from Application__c Limit 1];
        
        String response = '{"result":{"rcManuMonthYr":"2011","rcMakerModel":"SANTRO GL","rcFName":"","rcEngNo":"G4HGBM194771","rcOwnerName":"SUMIT MEHTA","rcVhClassDesc":"MOTOR CAR","rcPresentAddress":"","rcColor":"D GREY MET","rcRegnNo":"MP09CJ7775","taxPaidUpto":"","rcMakerDesc":"HYUNDAI MOTORS","rcChasiNo":"MALAA51HLBM638048B","rcMobileNo":"","rcRegisteredAt":"INDORE","rcValidUpto":"05-07-2026","rcRegnDt":"06-07-2011","rcFinancer":"","rcPermanentAddress":""},"requestId":"b906b7d8-819a-4bee-8566-d462ad5c7a14","statusCode":"101","description":"Valid Authentication"}';
        //{"result": {"rcManuMonthYr": null,"rcMakerModel": null,"rcFName": null,"rcEngNo": null,"rcOwnerName": null,"rcVhClassDesc": null,"rcPresentAddress": null,"rcColor": null,"rcRegnNo": null,"taxPaidUpto": null,"rcMakerDesc": null,"rcChasiNo": null,"rcMobileNo": null,"rcRegisteredAt": null,"rcValidUpto": null,"rcRegnDt": null,"rcFinancer": null,"rcPermanentAddress": null},"requestId": "214b0059-d75b-44b2-9bd7-d38ef037b83a","statusCode": "102","description": "Invalid ID number or combination of inputs"}';
        OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        OwnerValidationsController.callOwnersAPIs(app.Id, 'Vehicle_RC', params);
        Test.stopTest();
    }
    @isTest
    static void callOwnersAPIsElectTest(){
        Map<String,String> params = new Map<String,String>();
        params.put('chassisNo','1234567890');
        Application__c app = [Select Id from Application__c Limit 1];
        Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
        String response = '{"result":{"billNo":"450010313754","billDueDate":"07-10-2022","consumerNumber":"401501528","billAmount":"Rs. 1010.00","billIssueDate":"","mobileNumber":"8158830819","amountPayable":"Rs. 1010.00","totalAmount":"Rs. 1010.00","address":"","consumerName":"AKTARUL ISLAM","emailAddress":"","billDate":"22-09-2022"},"statusCode":"101","requestId":"e04b5187-a95c-44f8-9ae3-98bf7a426a26","description":"Valid Authentication"}';
        OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        OwnerValidationsController.callOwnersAPIs(app.Id, 'Electricity_Bill', params);
        Test.stopTest();
    }
    @isTest
    static void callOwnersAPIsPropertyTest(){
        Map<String,String> params = new Map<String,String>();
        params.put('chassisNo','1234567890');
        Application__c app = [Select Id from Application__c Limit 1];
        Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
        KYCWrapper.cls_plotAreaInSqYrd pAIS = new KYCWrapper.cls_plotAreaInSqYrd();
        
        String response = '{"result":{"propertyDetails":{"propertyId":"12344","propertyAddress":"xyzz","plotAreaInSqYrd":null,"plotAreaInSqMtrs":null,"vacantAreaInSqYrd":null,"constructedArea":null,"exemptionCategory":null,"multipurposeOwnership":null,"ownershipType":null,"registrationDocNo":null,"registrationDocDate":null,"billingName":"ajjuu","billingAddress":"Kajju","floorDetails":[{"floor":1,"areaInSqft":1200,"firmName":"GC Motors","occupancy":500,"occupantName":"Suresh Khanna","effectiveFromDate":null,"breadth":400}]},"taxCalculations":[{"taxType":"Normal","totalTax" : 5000,"totalTaxDue":200,"totalamountPaidRs":345,"paymentStatus":"confirm"}],"penalty":{"debitAmount":null,"creditAmount":null,"balanceTaxAmount":null},"ownerDetails":[{"mobileNo":"9999999999","ownerName" : "Suresh Raina","email":"ak@gmail.com","totalamountPaidRs":345,"panNo":"DFGHU7890A"}],"paymentDetails":null},"statusCode":"101","description":"Valid Authentication"}';
        
        OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        OwnerValidationsController.callOwnersAPIs(app.Id, 'Property_Tax', params);
        Test.stopTest();
    }
    @isTest
    static void callOwnersAPIsVehicleTest(){
        Map<String,String> params = new Map<String,String>();
        params.put('chassisNo','1234567890');
        Application__c app = [Select Id from Application__c Limit 1];
        Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
        String response = '{"requestId":"7ad634a9-ce80-432f-8ae4-5503bed6b3bd","result":{"blackListInfo":[],"blackListStatus":"NA","bodyTypeDescription":"SALOON","chassisNumber":"MBJ11JV40070650241106","color":"BLACK MET","cubicCapacity":"1998.0","engineNumber":"2KD9780094","fatherName":"TANGAVELU NAYAR","financier":"","fitnessUpto":"17-01-2027","fuelDescription":"DIESEL","grossVehicleWeight":"2290","insuranceCompany":"Royal Sundaram General Insurance Co. Ltd","insurancePolicyNumber":"VPT0390069000100","insuranceUpto":"30-01-2023","makerDescription":"TOYOTA KIRLOSKAR MOTOR PVT LTD","makerModel":"INNOVA 2.5 G WITH POWER STEER","manufacturedMonthYear":"11-2006","nationalPermitExpiryDate":null,"nationalPermitIssuedBy":null,"nationalPermitNumber":null,"nocDetails":"NA","nonUseFrom":null,"nonUseTo":null,"normsDescription":"Not Available","numberOfCylinders":"4","ownerName":"JAYPRAKASH TANGAVELU NAYAR","ownerSerialNumber":"4","permanentAddress":"A/502 5TH FLOOR MANU MAHALI CHS LTD , DNC SCHOOL NANDIVLI ROAD,AYARE DOMBIVALI EAST, Thane -421201","presentAddress":"A/502 5TH FLOOR MANU MAHALI CHS LTD , DNC SCHOOL NANDIVLI ROAD,AYARE DOMBIVALI EAST, Thane -421201","pucExpiryDate":"06-01-2023","pucNumber":"MH00501370003174","rcMobileNo":"","rcNonUseStatus":"N","rcStatus":"ACTIVE","registeredAt":"KALYAN, Maharashtra","registrationDate":"30-12-2006","registrationNumber":"MH04CY4545","seatingCapacity":"7","sleeperCapacity":"0","standingCapacity":"0","stateCd":null,"statePermitExpiryDate":null,"statePermitIssuedDate":null,"statePermitNumber":null,"statePermitType":null,"statusAsOn":null,"stautsMessage":null,"taxPaidUpto":null,"unladenWeight":"1630","vehicleCatgory":"LMV","vehicleClassDescription":"Motor Car(LMV)","wheelbase":"2750"},"statusCode":101,"description":"Valid Authentication"}'; 
        OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        OwnerValidationsController.callOwnersAPIs(app.Id, 'Vehicle_RC_Advance', params);
        Test.stopTest();
    }
    /*  @isTest
static void getKYCReportManualElectricityBillTest(){
Map<String,String> params = new Map<String,String>();
params.put('chassisNo','1234567890');
Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
String response = '{"result":{"billNo":"450010313754","billDueDate":"07-10-2022","consumerNumber":"401501528","billAmount":"1010","billIssueDate":"","mobileNumber":"8158830819","amountPayable":"1010","totalAmount":"1010","address":"","consumerName":"AKTARUL ISLAM","emailAddress":"","billDate":"22-09-2022"},"statusCode":"101","requestId":"e04b5187-a95c-44f8-9ae3-98bf7a426a26","description":"Valid Authentication"}';
OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
Test.startTest();
Test.setMock(HttpCalloutMock.class, fakeResponse);
OwnerValidationsController.getKYCReportManualElectricityBill(preLogin.Id,'401501528','WBENGAL');
Test.stopTest();
}
@isTest
static void getKYCReportManualPropertyTaxTest(){
Map<String,String> params = new Map<String,String>();
params.put('chassisNo','1234567890');
Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
String response = '{"result":{"propertyDetails":{"propertyId":"12344","propertyAddress":"xyzz","plotAreaInSqYrd":null,"plotAreaInSqMtrs":null,"vacantAreaInSqYrd":null,"constructedArea":null,"exemptionCategory":null,"multipurposeOwnership":null,"ownershipType":null,"registrationDocNo":null,"registrationDocDate":null,"billingName":"ajjuu","billingAddress":"Kajju","floorDetails":null},"taxCalculations":null,"penalty":{"debitAmount":null,"creditAmount":null,"balanceTaxAmount":null},"ownerDetails":null,"paymentDetails":null},"statusCode":"101","description":"Valid Authentication"}';
OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
Test.startTest();
Test.setMock(HttpCalloutMock.class, fakeResponse);
OwnerValidationsController.getKYCReportManualPropertyTax(preLogin.Id,'Delhi','Delhi','1223','','');
Test.stopTest();
}
@isTest
static void getKYCReportManualVehicleRCTest(){
Map<String,String> params = new Map<String,String>();
params.put('chassisNo','1234567890');
Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
String response = '{"result":{"rcManuMonthYr":"2011","rcMakerModel":"SANTRO GL","rcFName":"","rcEngNo":"G4HGBM194771","rcOwnerName":"SUMIT MEHTA","rcVhClassDesc":"MOTOR CAR","rcPresentAddress":"","rcColor":"D GREY MET","rcRegnNo":"MP09CJ7775","taxPaidUpto":"","rcMakerDesc":"HYUNDAI MOTORS","rcChasiNo":"MALAA51HLBM638048B","rcMobileNo":"","rcRegisteredAt":"INDORE","rcValidUpto":"05-07-2026","rcRegnDt":"06-07-2011","rcFinancer":"","rcPermanentAddress":""},"requestId":"b906b7d8-819a-4bee-8566-d462ad5c7a14","statusCode":"101","description":"Valid Authentication"}';
OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
Test.startTest();
Test.setMock(HttpCalloutMock.class, fakeResponse);
OwnerValidationsController.getKYCReportManualVehicleRC(preLogin.Id,'G4HGBM194771','MALAA51HLBM638048B','MP');
Test.stopTest();
}
@isTest
static void getKYCReportManualVehiclercAdvTest(){
Map<String,String> params = new Map<String,String>();
params.put('chassisNo','1234567890');
Pre_Login__c preLogin = [SELECT Id FROM Pre_Login__c WHERE status__c= 'Active' Limit 1];
String response = '{"requestId":"7ad634a9-ce80-432f-8ae4-5503bed6b3bd","result":{"blackListInfo":[],"blackListStatus":"NA","bodyTypeDescription":"SALOON","chassisNumber":"MBJ11JV40070650241106","color":"BLACK MET","cubicCapacity":"1998.0","engineNumber":"2KD9780094","fatherName":"TANGAVELU NAYAR","financier":"","fitnessUpto":"17-01-2027","fuelDescription":"DIESEL","grossVehicleWeight":"2290","insuranceCompany":"Royal Sundaram General Insurance Co. Ltd","insurancePolicyNumber":"VPT0390069000100","insuranceUpto":"30-01-2023","makerDescription":"TOYOTA KIRLOSKAR MOTOR PVT LTD","makerModel":"INNOVA 2.5 G WITH POWER STEER","manufacturedMonthYear":"11-2006","nationalPermitExpiryDate":null,"nationalPermitIssuedBy":null,"nationalPermitNumber":null,"nocDetails":"NA","nonUseFrom":null,"nonUseTo":null,"normsDescription":"Not Available","numberOfCylinders":"4","ownerName":"JAYPRAKASH TANGAVELU NAYAR","ownerSerialNumber":"4","permanentAddress":"A/502 5TH FLOOR MANU MAHALI CHS LTD , DNC SCHOOL NANDIVLI ROAD,AYARE DOMBIVALI EAST, Thane -421201","presentAddress":"A/502 5TH FLOOR MANU MAHALI CHS LTD , DNC SCHOOL NANDIVLI ROAD,AYARE DOMBIVALI EAST, Thane -421201","pucExpiryDate":"06-01-2023","pucNumber":"MH00501370003174","rcMobileNo":"","rcNonUseStatus":"N","rcStatus":"ACTIVE","registeredAt":"KALYAN, Maharashtra","registrationDate":"30-12-2006","registrationNumber":"MH04CY4545","seatingCapacity":"7","sleeperCapacity":"0","standingCapacity":"0","stateCd":null,"statePermitExpiryDate":null,"statePermitIssuedDate":null,"statePermitNumber":null,"statePermitType":null,"statusAsOn":null,"stautsMessage":null,"taxPaidUpto":null,"unladenWeight":"1630","vehicleCatgory":"LMV","vehicleClassDescription":"Motor Car(LMV)","wheelbase":"2750"},"statusCode":101,"description":"Valid Authentication"}';
OwnerValidationsControllerTest  fakeResponse = new OwnerValidationsControllerTest(200,response);
Test.startTest();
Test.setMock(HttpCalloutMock.class, fakeResponse);
OwnerValidationsController.getKYCReportManualVehiclercAdv(preLogin.Id,'MH04CY4545');
Test.stopTest();
}*/
}