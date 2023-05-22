public class MobileVerificationController {
     
    @AuraEnabled
    public static Wrapper SendOTP(String loanAppId,String MobileNo){
        System.debug('loanAppId '+loanAppId+' : MobileNo '+MobileNo);
        String MobileOTPRequest = '{"mobile": "'+MobileNo+'","consent": "y"}';
        HttpCalloutHelper http = new HttpCalloutHelper('Mobile_OTP',null,MobileOTPRequest);
        http.className = 'MobileVerificationController';
        HttpCalloutHelper.applicationId = DatabaseUtililty.getApplicationId(loanAppId);
        HttpCalloutHelper.loanAppId = loanAppId;
        HttpCalloutHelper.ResponseWrapper resWrap = http.doCallout();
        System.debug('KYC RESPWRAP '+resWrap.response.getBody());
        Wrapper wrp = new Wrapper();
        if(resWrap.response.getStatusCode()==200){
            MobileOTPWrapper respWrap = MobileOTPWrapper.parse(resWrap.response.getBody());
            System.debug(resWrap.response.getBody());
            wrp.msg = respWrap.statusCode;
            wrp.description = respWrap.description;
            wrp.requestId = respWrap.requestId;
            return wrp;
        }
        else{
            MobileOTPWrapper respWrap = MobileOTPWrapper.parse(resWrap.response.getBody());
            wrp.msg = respWrap.error.message;
            wrp.description = respWrap.error.description;
            return wrp; 
        } 
    }
    
    @AuraEnabled
    public static Wrapper ValidateOTP(String loanAppId,String requestId,String OTP){
        System.debug('requestId '+requestId+' : OTP '+OTP);
        try{ 
            String validateOTPRequest='{"requestId": "'+requestId+'","otp": "'+OTP+'"}';
            HttpCalloutHelper http = new HttpCalloutHelper('Validate_OTP',null,validateOTPRequest);
            http.className = 'MobileVerificationController';
            HttpCalloutHelper.applicationId = DatabaseUtililty.getApplicationId(loanAppId);
            HttpCalloutHelper.loanAppId = loanAppId;
            HttpCalloutHelper.ResponseWrapper resWrap = http.doCallout();
            System.debug('KYC RESPWRAP '+resWrap.response.getBody());
            Wrapper wrp=new Wrapper();
            system.debug(resWrap.response.getBody());
            if(resWrap.response.getStatusCode()==200){
                system.debug('statuscode'+resWrap.response.getStatusCode());
                ValidateOTPWrapper respWrap=ValidateOTPWrapper.parse(resWrap.response.getBody());
                system.debug('statuscodeee'+resWrap.response.getStatusCode());
                if(respWrap.description!=null)
                    wrp.description=respWrap.description; 
                if(respWrap.status!=null)
                    wrp.description=respWrap.status; 
                wrp.msg=respWrap.statusCode;
                system.debug('return');
                return wrp;
            }
            else{ 
                ValidateOTPWrapper respWrap=ValidateOTPWrapper.parse(resWrap.response.getBody());
                wrp.description=respWrap.error.message;
                return wrp; 
            } 
        }
        catch(Exception e){         
            Error_Logger__c el=new Error_Logger__c();
            el.Exception_Message__c=e.getMessage();
            el.Name='MobileVerificationController';
            el.Line_Number__c=string.valueof(e.getLineNumber());
            el.Loan_Applicant__c = loanAppId;
            el.Application__c = DatabaseUtililty.getApplicationId(loanAppId);
            insert el;
            Wrapper wrp=new Wrapper();
            wrp.description=e.getMessage();
            return wrp;         
        }
    }
    
    @AuraEnabled
    public static Boolean loanAppMobileVerification(String loanAppId){
        System.debug('loanAppId Id '+loanAppId);
        Loan_Applicant__c objLoan = [SELECT Id,Mobile_Verified__c,Mobile_Verification_Type__c,Application__r.Stage__c FROM Loan_Applicant__c WHERE Id = :loanAppId];
        if(objLoan!=null){
            System.debug('objLoan '+objLoan);
            objLoan.Mobile_Verified__c = true; 
            objLoan.Mobile_Verification_Type__c = 'System';
            if(objLoan.Application__r.Stage__c == 'Process Credit')
                objLoan.PC_Mobile_Verified__c = true;
            if(objLoan.Application__r.Stage__c == 'Approval Credit')
                objLoan.AC_Mobile_Verified__c = true;
            UPDATE objLoan;
            if(objLoan.Mobile_Verified__c == true)
                return true;
            else
                return false;
        }
        else
            return false;
    }
    
    
    public class Wrapper{
        @auraEnabled public String description;
        @auraEnabled public String requestId;
        @auraEnabled public String msg;
    }
    
}