public class FS_PreLoginControllerMock {
    
    @auraEnabled
    Public static Wrapper SubmitForOCR(String kycType,String frontbase64,String rearbase64){
        try{

            APICredentials__mdt kycOCR = APICredentials__mdt.getInstance('KYCOCR');
            string ocrRequest='{';
            ocrRequest+='"fileB64" : "",'; 
            ocrRequest+='"maskAadhaar" : false,';
            ocrRequest+='"hideAadhaar" : false,';
            ocrRequest+='"conf" : true,';
            ocrRequest+='"docType" : "",';
            ocrRequest+='"checkBlur": false,';
            ocrRequest+='"checkBlackAndWhite": false,';
            ocrRequest+='"checkCutCard": false,';
            ocrRequest+='"checkBrightness": false';
            ocrRequest+='}'; 
            
            //Wrapper wrpObj =new Wrapper(); 
            string mockResponse='';
            // if(kycType=='Aadhar Card')
            mockResponse='{ "requestId": "d6942a47-9598-4dda-a2db-c44bc317a426", "result": [ { "details": { "aadhaar": { "value": "446318766832", "conf": 1.0, "isMasked": "no" }, "dob": { "value": "24/08/2000", "conf": 1.0 }, "father": { "value": "", "conf": 0 }, "gender": { "value": "MALE", "conf": 1.0 }, "mother": { "value": "", "conf": 0 }, "name": { "value": "Vellayadevan Ravikumar", "conf": 0.99 }, "yob": { "value": "", "conf": 0 }, "imageUrl": { "value": "" }, "qr": { "value": "" } }, "type": "Aadhaar Front Bottom" }, { "details": { "aadhaar": { "value": "446318766832", "conf": 1.0, "isMasked": "no" }, "address": { "value": "Vellayadevan Ravikumar s/o: Ravikumar 5/6 METTUMARANUR Aarurpatti Aarurpatti Omalur Salem Tamil Nadu 636502", "conf": 0.9 }, "name": { "value": "", "conf": 0 }, "phone": { "value": "9047752537", "conf": 0.83 }, "pin": { "value": "636502", "conf": 0 }, "imageUrl": { "value": "" }, "father": { "value": "", "conf": 0 }, "husband": { "value": "", "conf": 0 }, "addressSplit": { "careOf": "", "houseNumber": "", "city": "Omalur", "line1": "Vellayadevan Ravikumar s / o : Ravikumar 5 / 6 METTUMARANUR Aarurpatti Aarurpatti", "line2": "", "street": "", "locality": "", "landmark": "", "district": "Salem", "state": "Tamil Nadu", "pin": "636502" } }, "type": "Aadhaar Front Top" } ], "statusCode": 101, "description": "Successful OCR" }';
            // if(kycType=='Pan Card')
            //     mockResponse='{ "requestId": "37578b97-7976-413b-96ae-786da69d0519", "result": [ { "details": { "date": { "value": "16/05/1986", "conf": 1.0 }, "dateOfIssue": { "value": "", "conf": 0 }, "father": { "value": "KRISHNA DAYAL MISHRA", "conf": 0.71 }, "name": { "value": "VINAY KUMAR", "conf": 1.0 }, "panNo": { "value": "DCKPK8902E", "conf": 1.0 } }, "type": "Pan" } ], "statusCode": 101, "description": "Successful OCR" }';
            // if(kycType=='Voter Id') 
            //     mockResponse='{ "requestId": "0ae7713d-2c4f-46f5-ae29-fdbd7b4449a1", "result": [ { "details": { "voterid": { "value": "MZH2380426", "conf": 0.98 }, "address": { "value": "HNO. 153SECTOR NO.12 PANCHKULA TEHPANCHKULA, DISTT.PANCHKULA", "conf": 0.51 }, "pin": { "value": "", "conf": 0.51 }, "gender": { "value": "", "conf": 0 }, "date": { "value": "", "conf": 0 }, "age": { "value": "", "conf": 0 }, "dob": { "value": "", "conf": 0 }, "type": { "value": "", "conf": 0 }, "addressSplit": { "houseNumber": "HNO. 153SECTOR NO.12", "city": "", "line1": "HNO. 153SECTOR NO.12 TEHPANCHKULA DISTT.PANCHKULA", "line2": "", "street": "", "locality": "", "landmark": "", "district": "Panchkula", "state": "", "pin": "" } }, "type": "Voterid Back" }, { "details": { "voterid": { "value": "MZH2380426", "conf": 1.0 }, "name": { "value": "SONIA", "conf": 1.0 }, "gender": { "value": "FEMALE", "conf": 0.73 }, "relation": { "value": "BRIJ BHUSHAN", "conf": 0.99 }, "dob": { "value": "", "conf": 0.0 }, "doc": { "value": "", "conf": 0.0 }, "age": { "value": "", "conf": 0.0 } }, "type": "Voterid Front" } ], "statusCode": 101, "description": "Successful OCR" }';
            
            
            Wrapper wrp=new Wrapper();
            
            
            
            system.debug(wrp);
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            request.setBody(ocrRequest);
            request.setEndpoint(kycOCR.Endpoint__c);//
            request.setMethod(kycOCR.Method__c); 
            request.setHeader('Authorization', kycOCR.Authorization__c);
            request.setHeader('CORRELATION-ID',kycOCR.CORRELATION_ID__c);
            request.setHeader('CLIENT-ID',kycOCR.CLIENT_ID__c);
            request.setHeader('CLIENT-SECRET',kycOCR.CLIENT_SECRET__c);
            request.setHeader('Content-Type', kycOCR.Content_Type__c);
            request.setTimeout(120000);
            HttpResponse response ;//= http.send(request); 

            response.setStatusCode(200);
            response.setBody(mockResponse);
            // system.debug('resp'+wrp);
            if(response.getStatusCode()==200){
                FS_KYCOCRWrapper respWrap=FS_KYCOCRWrapper.parse(mockResponse);
                if(respWrap.description!=null)
                    wrp.statusCode=string.valueof(respWrap.statusCode);
                if(respWrap.description!=null)
                wrp.description=respWrap.description;
                for(FS_KYCOCRWrapper.cls_result detail:respWrap.result){
                    if(detail.details.addressSplit!=null){
                        if(string.isNotBlank(detail.details.addressSplit.city))
                            wrp.City=detail.details.addressSplit.city;
                    }
                    
                    if(detail.details.name!=null){
                        if(string.isNotBlank(detail.details.name.value)){
                            if(detail.details.name.value.contains(' ')){
                                wrp.Name= detail.details.name.value.Substring(0,detail.details.name.value.lastindexof(' '));
                                wrp.lastname = detail.details.name.value.Substring(detail.details.name.value.lastindexof(' '),detail.details.name.value.length());
                            }
                            else{
                                wrp.Name= detail.details.name.value;
                            }
                        }
                    }
                    if(detail.details.panNo!=null){
                        if(string.isNotBlank(detail.details.panNo.value))
                            wrp.kycNo=detail.details.panNo.value;
                    }
                    if(detail.details.father!=null){
                        if(string.isNotBlank(detail.details.father.value) )  
                            wrp.FathersName =detail.details.father.value;
                    }
                    if(detail.details.husband!=null)  {
                        if(string.isNotBlank(detail.details.husband.value) )        
                            wrp.SpouceName=detail.details.husband.value;
                    }
                    else if(detail.details.wife!=null)  {
                        if(string.isNotBlank(detail.details.wife.value) )        
                            wrp.SpouceName=detail.details.wife.value;
                    }
                    else
                        wrp.SpouceName=''; 
                    if(detail.details.gender!=null) {
                        if(string.isNotBlank(detail.details.gender.value))           
                            wrp.Gender=detail.details.gender.value;
                    }
                    
                    if(detail.details.phone!=null) {
                        if(string.isNotBlank(detail.details.phone.value))
                            wrp.MobileNo=detail.details.phone.value; 
                    }
                    if(detail.details.address!=null) {
                        if(string.isNotBlank(detail.details.address.value))  
                            wrp.Address=detail.details.address.value;
                    }
                    //wrp.City=detail.details.address.value;
                    if(detail.details.dob!=null){
                        if(string.isNotBlank(detail.details.dob.value)){ 
                            String str = detail.details.dob.value;
                            string day=str.SubStringBefore('/');
                            string month=str.SubStringafter('/');
                            string year=month.SubStringafter('/');
                            month=month.SubStringBefore('/');
                            string strdate=year+'-'+month+'-'+day;
                            wrp.DOB=date.valueof(strdate);
                        }
                    }
                    if(detail.details.pin!=null){
                        if(string.isNotBlank(detail.details.pin.value) )
                            wrp.Pincode=detail.details.pin.value;
                    }
                    if(detail.details.voterid!=null){
                        if(string.isNotBlank(detail.details.voterid.value) )     
                            wrp.kycNo=detail.details.voterid.value;
                    }
                    if(detail.details.mother!=null){
                        if(string.isNotBlank(detail.details.mother.value) )     
                            wrp.MothersName=detail.details.mother.value;
                    }
                    if(detail.details.aadhaar!=null){
                        if(string.isNotBlank(detail.details.aadhaar.value) )     
                            wrp.kycNo=detail.details.aadhaar.value;
                    }
                }  
              API_Logger__c al=new API_Logger__c();
              al.Name='FS_PreLoginController';
              al.API_Name__c='kycocr'; 
              //al.Request__c= request.getBody();   
              al.Response__c= response.getBody();
              al.EndPoint__c=request.getEndpoint();
              al.ID__c=  wrp.kycNo;
              insert al; 
                if(wrp.statuscode!=null && wrp.statuscode=='101'){
                    KYC_OCR__c ocr=new KYC_OCR__c();
                    ocr.City__c=wrp.City;
                    ocr.Gender__c=wrp.Gender;
                    ocr.Fathers_Name__c=wrp.FathersName;
                    ocr.DOB__c=wrp.DOB;
                    ocr.Name__c=wrp.name;
                    ocr.Name='test';
                    ocr.API_Logger__c=al.id;
                    ocr.ID__c=wrp.kycNo;
                    ocr.Description__c=wrp.description;
                    ocr.Mothers_Name__c=wrp.MothersName;
                    ocr.Pincode__c=integer.valueof(wrp.Pincode);
                    ocr.Spouce_Name__c=wrp.SpouceName;
                    insert ocr;
                }
              return wrp;
            }
            else {
                
              FS_KYCOCRWrapper respWrapp=FS_KYCOCRWrapper.parse(mockResponse);
              wrp.description=respWrapp.error.message;   
              API_Logger__c al=new API_Logger__c();
              al.Name='FS_PreLoginController';
              al.API_Name__c='kycocr'; 
              //al.Request__c= request.getBody();   
              al.Response__c= response.getBody();
              al.EndPoint__c=request.getEndpoint();
              insert al; 
              return wrp;
            } 
            
        }
        Catch(Exception e){
            system.debug('exception'+e.getLineNumber()+e.getMessage());
            Error_Logger__c el=new Error_Logger__c();
            el.Exception_Message__c=e.getMessage();
            el.Name='FS_PreLoginController';
            el.Line_Number__c=string.valueof(e.getLineNumber());
            insert el;
            Wrapper wrp=new Wrapper();
            wrp.description=e.getMessage();
            return wrp; 
        }
        
    }
    
    @auraEnabled
    Public static Wrapper SendOTP(String AccountId,String MobileNo){
        System.debug('AccountId '+AccountId+' : MobileNo '+MobileNo);
        try{
            APICredentials__mdt MobileOTP = APICredentials__mdt.getInstance('MobileOTP');
            HttpRequest request = new HttpRequest();
            string MobileOTPRequest='{"mobile": "'+MobileNo+'","consent": "y"}';
            Http http = new Http();
            request.setBody(MobileOTPRequest);
            request.setEndpoint(MobileOTP.Endpoint__c);//
            request.setMethod(MobileOTP.Method__c); 
            request.setHeader('Authorization', MobileOTP.Authorization__c);
            request.setHeader('CORRELATION-ID',MobileOTP.CORRELATION_ID__c);
            request.setHeader('CLIENT-ID',MobileOTP.CLIENT_ID__c);
            request.setHeader('CLIENT-SECRET',MobileOTP.CLIENT_SECRET__c);
            request.setHeader('Content-Type', MobileOTP.Content_Type__c);
            request.setTimeout(120000); 
            Wrapper wrp=new Wrapper();
            
            HttpResponse response = http.send(request); 
			System.debug('Response '+response);
            API_Logger__c al=new API_Logger__c();
            al.Name='FS_PreLoginController';
            al.API_Name__c='mobileotp'; 
            al.Request__c= request.getBody();   
            al.Response__c= response.getBody();
            al.EndPoint__c=request.getEndpoint();
            al.Customer_Information__c=Accountid;
            insert al;
            if(response.getStatusCode()==200){
                MobileOTPWrapper respWrap=MobileOTPWrapper.parse(response.getBody());
                System.debug(response.getBody());
                wrp.msg=respWrap.statusCode;
                wrp.description=respWrap.description;
                wrp.requestId=respWrap.requestId;
                return wrp;
            }
            else{
                
                MobileOTPWrapper respWrap=MobileOTPWrapper.parse(response.getBody());
                wrp.msg=respWrap.error.message;
                wrp.description=respWrap.error.description;
                return wrp; 
            } 
            //return null;
        }
        catch(Exception e){
            
            
            Error_Logger__c el=new Error_Logger__c();
            el.Exception_Message__c=e.getMessage();
            el.Name='FS_PreLoginController';
            el.Line_Number__c=string.valueof(e.getLineNumber());
            el.Customer_Information__c=AccountId;
            insert el;
            Wrapper wrp=new Wrapper();
            wrp.description=e.getMessage();
            return wrp; 
            
        }
    }
    
    @auraEnabled
    Public static Wrapper ValidateOTP(String AccountId,String requestId,String OTP){
        System.debug('requestId '+requestId+' : OTP '+OTP);
        try{ 
            APICredentials__mdt validateOTP = APICredentials__mdt.getInstance('ValidateOTP');
            HttpRequest request = new HttpRequest();
            //string MobileOTPRequest='{"mobile": "'+MobileNo+'","consent": "y"}';
            string validateOTPRequest='{"requestId": "'+requestId+'","otp": "'+OTP+'"}';
            system.debug('validateOTPRequest'+validateOTPRequest);
            Http http = new Http();
            request.setBody(validateOTPRequest);
            request.setEndpoint(validateOTP.Endpoint__c);//
            request.setMethod(validateOTP.Method__c); 
            request.setHeader('Authorization', validateOTP.Authorization__c);
            request.setHeader('CORRELATION-ID',validateOTP.CORRELATION_ID__c);
            request.setHeader('CLIENT-ID',validateOTP.CLIENT_ID__c);
            request.setHeader('CLIENT-SECRET',validateOTP.CLIENT_SECRET__c);
            request.setHeader('Content-Type', validateOTP.Content_Type__c);
            request.setTimeout(120000); 
            //string mockResponse='{ "requestId": "d9a3e9d1-4050-45d5-be56-0f570b304d09", "result": { "contact": { "address": "Railway staion road, Bhagwatiganj, Balrampur, Balrampur, Up-271201", "altContact": "8860211008", "emailId": null, "workEmail": null }, "device": { "3gSupport": null, "deviceActivationDate": null, "imei": null, "model": "SamsungSM-A505 Galaxy A50 Dual Sim" }, "history": null, "identity": { "dateOfBirth": "16-05-1986", "gender": null, "name": "Vinay Kumar Mishra" }, "profile": { "education": null, "language": null, "maritalStatus": null, "occupation": null, "relationships": null, "workplace": null }, "simDetails": { "activationDate": null, "lastActivityDate": null, "otpValidated": true, "provider": "Reliance Jio", "type": "PREPAID" } }, "statusCode": "101", "description": "Valid Authentication" }';
            //   string mockResponse='{ "error": { "source": "Portal", "target": "Kyc system Api", "errorCode": "400", "message": "Bad Request", "description": "Request structure need to be analyzed", "timestamp": "2022-04-12 10:21:35+0000" } }';
            //string mockResponse ='{"status": "The OTP is invaild"}';
            Wrapper wrp=new Wrapper();
            
            //   system.debug(respWrap.error.message);
            HttpResponse response = http.send(request); 
            
            API_Logger__c al=new API_Logger__c();
            al.Name='FS_PreLoginController';
            al.API_Name__c='mobiledetails'; 
            al.Request__c= request.getBody();   
            al.Response__c= response.getBody();
            al.EndPoint__c=request.getEndpoint();
            al.Customer_Information__c=AccountId;
            insert al;   
            system.debug(response.getBody());
           
            if(response.getStatusCode()==200){
                 system.debug('statuscode'+response.getStatusCode());
                ValidateOTPWrapper respWrap=ValidateOTPWrapper.parse(response.getBody());
                    system.debug('statuscodeee'+response.getStatusCode());
                if(respWrap.description!=null)
                    wrp.description=respWrap.description; 
                if(respWrap.status!=null)
                    wrp.description=respWrap.status; 
                    wrp.msg=respWrap.statusCode;
                system.debug('return');
                    return wrp;
            }
            else{
                
                ValidateOTPWrapper respWrap=ValidateOTPWrapper.parse(response.getBody());
                wrp.description=respWrap.error.message;
                return wrp; 
            } 
            // return null;
        }
        catch(Exception e){
            
            Error_Logger__c el=new Error_Logger__c();
            el.Exception_Message__c=e.getMessage();
            el.Name='FS_PreLoginController';
            el.Line_Number__c=string.valueof(e.getLineNumber());
            el.Customer_Information__c=AccountId;
            insert el;
            Wrapper wrp=new Wrapper();
            wrp.description=e.getMessage();
            return wrp; 
            
        }
    }
    public class Wrapper{
        @auraEnabled public String Name;
        @auraEnabled public String FathersName;
        @auraEnabled public String  MothersName;
        @auraEnabled public String SpouceName;
        @auraEnabled public Date DOB;
        @auraEnabled public String MobileNo;
        @auraEnabled public String LandLineNo;
        @auraEnabled public String City;
        @auraEnabled public String Pincode;
        @auraEnabled public String Address;
        @auraEnabled public String Gender;
        @auraEnabled public String kycNo;
        @auraEnabled public String lastname;
        // @auraEnabled public String wife;
        @auraEnabled public String description;
        @auraEnabled public String requestId;
        @auraEnabled public String msg;
        @auraEnabled public String statusCode;
            }
    
    
}