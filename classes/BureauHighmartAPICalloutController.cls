/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Parag Goyal  
* @modifiedBy       Parag Goyal  
* @created          2022-07-26
* @modified         2022-07-26
* @TestClassName    
* @Description      Highmark/Bureau API Callout FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public without sharing class BureauHighmartAPICalloutController {

    public static Loan_Applicant__c objLoan;
    
    @AuraEnabled
    public static Boolean doHighmarkCallout(List<Id> listOfLoanApp){
        Boolean isBureauVerified = false;
        System.debug('loanapp list>>>'+listOfLoanApp);
        if(listOfLoanApp.size() > 0){
            List<KYC__c> listKYC = [SELECT Id,Type__c,dlNumber__c,passportNumberFromSource__c,epicNo__c,Loan_Applicant__c 
                                    FROM KYC__c 
                                    WHERE Id IN : listOfLoanApp AND Loan_Applicant__c != null AND Loan_Applicant__r.Is_KYC_Verified__c = true];
            for(String loanId : listOfLoanApp){
                isBureauVerified = initiateBureau(loanId);
            }
        }
        System.debug('isBureauVerified>>>>>>'+isBureauVerified);
        return isBureauVerified;
    }               
    
    //@future(callout=true)
    public static Boolean initiateBureau(String loanAppId){
        Boolean isBureauVerified = false;
        objLoan = new Loan_Applicant__c();
        try{
            objLoan = [SELECT Id,Email__c,Customer_Information__r.Father_s_Name__c,Customer_Information__r.Name,Residence_Pincode__c,Residence_Address_Line_1__c,Is_Bureau_Verified__c, 
                       Residence_City__c,Customer_Information__r.Gender__c,State_Code__c,Customer_Information__r.PersonBirthdate,Customer_Information__r.Mother_s_Name__c,Husband_Wife_s_Name__c,
                       Mobile__c, KYC_ID_Type_1__c, KYC_ID_Type_2__c, KYC_Id_1__c, KYC_Id_2__c,Residence_Pincode__r.Name,Application__c,
                       Application__r.Name,Application__r.Pre_Login__r.Name,Application__r.Requested_Loan_Amount__c
                       FROM Loan_Applicant__c WHERE Id = :loanAppId];
            Highmark_API_Codes__mdt hmMdt = [SELECT Id,DeveloperName,Mobile__c,Male__c,Female__c,Father__c,Mother__c,
                                             Son__c,Daughter__c,Wife__c,Brother__c,Mother_In_Law__c,Husband__c,
                                             Aadhaar_Card__c,Voter_Id__c,Driving_Licence__c,Pan_Card__c,Passport__c,
                                             Residence_Phone__c,Company_Phone__c
                                             FROM Highmark_API_Codes__mdt WHERE DeveloperName = 'Highmark_API_Codes'];           
            String dob = convertDate(String.valueOf(objLoan.Customer_Information__r.PersonBirthdate)); 
            String objAddress = '';
            String gender = '';
            String email = '';
            String spouse = '';
            String spouseCode = '';
            if(String.isNotBlank(objLoan.Residence_Address_Line_1__c))
                objAddress = objLoan.Residence_Address_Line_1__c.contains('\n') ? objLoan.Residence_Address_Line_1__c.replaceAll('\n',' ') : objLoan.Residence_Address_Line_1__c;
            if(String.isNotBlank(objLoan.Customer_Information__r.Gender__c))
                gender = objLoan.Customer_Information__r.Gender__c == 'Male' ? 'G01' : objLoan.Customer_Information__r.Gender__c == 'Female' ? 'G02' : '';
            if(String.isNotBlank(objLoan.Email__c))
                email = objLoan.Email__c;
            if(String.isNotBlank(objLoan.Husband_Wife_s_Name__c)){
                spouse = objLoan.Husband_Wife_s_Name__c;
                if(objLoan.Customer_Information__r.Gender__c == 'Male'){
                    spouseCode = hmMdt.Husband__c;
                }
                else{
                    spouseCode = hmMdt.Wife__c;
                }
            }
            String highmarkRequest='{"name": "'+objLoan.Customer_Information__r.Name+'",';  
            highmarkRequest+='"dob": "'+dob+'",';//06-07-1975
            highmarkRequest+='"phone": [';
            highmarkRequest+='{';
            highmarkRequest+='"phoneNumber": "'+objLoan.Mobile__c+'",';
            highmarkRequest+='"phoneType" : "'+hmMdt.Mobile__c+'"';      //"mobile"';
            highmarkRequest+='}';
            highmarkRequest+='],';
            highmarkRequest+='"kyc": [';
            if(objLoan.KYC_ID_Type_1__c == 'Voter Id' || objLoan.KYC_ID_Type_2__c == 'Voter Id'){  
                highmarkRequest+='{';
                highmarkRequest+='"kycName": "'+hmMdt.Voter_Id__c+'",';                    //"voter-id",';
                if(objLoan.KYC_ID_Type_1__c == 'Voter Id' && String.isNotBlank(objLoan.KYC_Id_1__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_1__c+'"';
                if(objLoan.KYC_ID_Type_2__c == 'Voter Id' && String.isNotBlank(objLoan.KYC_Id_2__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_2__c+'"';
                highmarkRequest+='},';  
            }
            if(objLoan.KYC_ID_Type_1__c == 'Driving License' || objLoan.KYC_ID_Type_2__c == 'Driving License' ){ 
                highmarkRequest+='{';
                highmarkRequest+='"kycName": "'+hmMdt.Driving_Licence__c+'",';                                            //"Driving License",';
                if(objLoan.KYC_ID_Type_1__c == 'Driving License' && String.isNotBlank(objLoan.KYC_Id_1__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_1__c+'"';
                if(objLoan.KYC_ID_Type_2__c == 'Driving License' && String.isNotBlank(objLoan.KYC_Id_2__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_2__c+'"';
                highmarkRequest+='},';  
            }
            if(objLoan.KYC_ID_Type_1__c == 'Passport' || objLoan.KYC_ID_Type_2__c == 'Passport'){ 
                highmarkRequest+='{';
                highmarkRequest+='"kycName": "'+hmMdt.Passport__c+'",';                                     //"Passport",';
                if(objLoan.KYC_ID_Type_1__c == 'Passport' && String.isNotBlank(objLoan.KYC_Id_1__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_1__c+'"';
                if(objLoan.KYC_ID_Type_2__c == 'Passport' && String.isNotBlank(objLoan.KYC_Id_2__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_2__c+'"';
                highmarkRequest+='},';  
            }    
            /*
Commented as per the mail sent by anand on 28/04/2023 
if(objLoan.KYC_ID_Type_1__c == 'Aadhaar Card' || objLoan.KYC_ID_Type_2__c == 'Aadhaar Card'){ 
highmarkRequest+='{';
highmarkRequest+='"kycName": "aadhaar card",';
if(objLoan.KYC_ID_Type_1__c == 'Aadhaar Card' && String.isNotBlank(objLoan.KYC_Id_1__c))
highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_1__c+'"';
if(objLoan.KYC_ID_Type_2__c == 'Aadhaar Card' && String.isNotBlank(objLoan.KYC_Id_2__c))
highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_2__c+'"';
highmarkRequest+='},';  
}*/    
            if(objLoan.KYC_ID_Type_1__c == 'Pan Card' || objLoan.KYC_ID_Type_2__c == 'Pan Card'){ 
                highmarkRequest+='{';
                highmarkRequest+='"kycName": "'+hmMdt.Pan_Card__c+'",'; //"pan card",';
                if(objLoan.KYC_ID_Type_1__c == 'Pan Card' && String.isNotBlank(objLoan.KYC_Id_1__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_1__c+'"';
                if(objLoan.KYC_ID_Type_2__c == 'Pan Card' && String.isNotBlank(objLoan.KYC_Id_2__c))
                    highmarkRequest+='"kycValue": "'+objLoan.KYC_Id_2__c+'"';
                highmarkRequest+='},';  
            }    
            highmarkRequest=highmarkRequest.removeEnd(',');
            highmarkRequest+='],';
            highmarkRequest+='"relation": [';
            //new changes
            if(String.isNotBlank(objLoan.Customer_Information__r.Father_s_Name__c)){
                highmarkRequest+='{';
                highmarkRequest+='"name": "'+objLoan.Customer_Information__r.Father_s_Name__c+'",';
                highmarkRequest+='"type": "'+hmMdt.Father__c+'"';
                highmarkRequest+='},'; 
            }
            if(String.isNotBlank(objLoan.Customer_Information__r.Mother_s_Name__c)){
                highmarkRequest+='{';
                highmarkRequest+='"name": "'+objLoan.Customer_Information__r.Mother_s_Name__c+'",';
                highmarkRequest+='"type": "'+hmMdt.Mother__c+'"';
                highmarkRequest+='},'; 
            }
            if(String.isNotBlank(spouse) && String.isNotBlank(spouseCode)){
                highmarkRequest+='{';
                highmarkRequest+='"name": "'+spouse+'",';
                highmarkRequest+='"type": "'+spouseCode+'"';
                highmarkRequest+='},'; 
            }
            highmarkRequest=highmarkRequest.removeEnd(',');
            //new changes
            highmarkRequest+='],';
            highmarkRequest+='"gender": "'+gender+'",';
            //new change
            highmarkRequest+='"emails": [';
            highmarkRequest+='{';
            highmarkRequest+='"email": "'+email+'"';
            highmarkRequest+='}';
            highmarkRequest+='],';
            //new change end
            highmarkRequest+='"address": [';
            highmarkRequest+='{';
            highmarkRequest+='"addressType": "residence",';
            highmarkRequest+='"address": "'+objAddress+'",';
            highmarkRequest+='"city": "'+objLoan.Residence_City__c+'",';
            highmarkRequest+='"state": "'+objLoan.State_Code__c+'",';
            highmarkRequest+='"pincode": "'+objLoan.Residence_Pincode__r.Name+'"';
            highmarkRequest+='}';
            highmarkRequest+='],';
            highmarkRequest+='"loanAmount": "'+objLoan.Application__r.Requested_Loan_Amount__c+'",'; //"0",';
            highmarkRequest+='"loanType": "Business loan",';
            highmarkRequest+='"stage": "",';
            highmarkRequest+='"leadId": "'+objLoan.Application__r.Name+'",'; //"",';
            highmarkRequest+='"refId": "123",';
            highmarkRequest+='"appId": "'+objLoan.Application__r.Name+'"'; //"0"';
            highmarkRequest+='}';
            System.debug('httpReq '+highmarkRequest);
            HttpCalloutHelper http = new HttpCalloutHelper('Highmark',null,highmarkRequest);
            http.className = 'BureauHighmartAPICalloutController';
            HttpCalloutHelper.applicationId = objLoan.Application__c;
            HttpCalloutHelper.loanAppId = loanAppId;
            HttpCalloutHelper.ResponseWrapper resWrap = http.doCallout();
            System.debug('KYC RESPWRAP '+resWrap.response.getBody());
            
            List<Bureau_Highmark__c> listtoinsertHighmark=new list<Bureau_Highmark__c>();
            List<Personal_Info_Variation__c> listtoinsertPersonalInfo=new list<Personal_Info_Variation__c>();
            List<Loan_Details__c> listtoinsertLoanDetails=new list<Loan_Details__c>();
            List<Inquiry_History__c> listtoinsertInquiryHistory=new list<Inquiry_History__c>();
            List<Account_Summary__c> accSummaryList=new list<Account_Summary__c>();
            
            Id AddressVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Address Variations').getRecordTypeId();
            Id EmailVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Email Variations').getRecordTypeId();
            Id DOBVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Date Of Birth Variations').getRecordTypeId();
            Id DLVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Driving License Variations').getRecordTypeId();
            Id NameVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Name Variations').getRecordTypeId();
            Id PanVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Pan Variations').getRecordTypeId();
            Id PassportVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Passport Variations').getRecordTypeId();
            Id PhoneNumberVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Phone Number Variations').getRecordTypeId();
            Id RationCardVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Ration Card Variations').getRecordTypeId();
            Id VoterIdVariationsRecordTypeId = Schema.SObjectType.Personal_Info_Variation__c.getRecordTypeInfosByName().get('Voter Id Variations').getRecordTypeId();
            Id DerivedAttributesRecordTypeId = Schema.SObjectType.Loan_Details__c.getRecordTypeInfosByName().get('Derived Attributes').getRecordTypeId();
            Id PrimaryAccountsSummaryRecordTypeId = Schema.SObjectType.Loan_Details__c.getRecordTypeInfosByName().get('Primary Accounts Summary').getRecordTypeId();
            Id SecondaryAccountsSummaryRecordTypeId = Schema.SObjectType.Loan_Details__c.getRecordTypeInfosByName().get('Secondary Accounts Summary').getRecordTypeId();
            Id LoanDetailsRecordTypeId = Schema.SObjectType.Loan_Details__c.getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
            Id SecondaryAccSummaryRecordTypeId = Schema.SObjectType.Account_Summary__c.getRecordTypeInfosByName().get('Secondary Accounts Summary').getRecordTypeId();
            Id PrimaryAccSummaryRecordTypeId = Schema.SObjectType.Account_Summary__c.getRecordTypeInfosByName().get('Primary Accounts Summary').getRecordTypeId();
            Id DerivedAccSummaryRecordTypeId = Schema.SObjectType.Account_Summary__c.getRecordTypeInfosByName().get('Derived Attributes').getRecordTypeId();
            
            System.debug('resWrap.response.getStatusCode() '+resWrap.response.getStatusCode());
            if(resWrap.response.getStatusCode()==200 ){
                List<Bureau_Highmark__c> previousBureau = new List<Bureau_Highmark__c>([SELECT ID FROM Bureau_Highmark__c WHERE Loan_Applicant__c = :loanAppId]); 
                HighMarkWrapper respWrap=HighMarkWrapper.parse(resWrap.response.getbody());
                System.debug('respWrap.response.getbody() '+resWrap.response.getbody());
                if(respWrap.basePlusReportFile!=null && respWrap.basePlusReportFile.basePlusReports!=null){
                    System.debug('insert bureau');
                    if(respWrap.basePlusReportFile.basePlusReports.basePlusReport!=null){
                        System.debug('insert bureau 1');
                        Bureau_Highmark__c bureauHighmark=new Bureau_Highmark__c();
                        
                        /*if(isBureauVerified!= false)
                            isBureauVerified= true;*/
                        
                        //Score Populating
                        if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.scores!=null){
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.scores.score!=null){
                                System.debug('insert bureau 2');
                                bureauHighmark.Highmark_Score__c = respWrap.basePlusReportFile.basePlusReports.basePlusReport.scores.score.scoreValue;
                            }
                        }
                        if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request!=null){
                            bureauHighmark.Loan_Applicant__c=objLoan.id;
                            
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.name!=null)
                                bureauHighmark.Name=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.name;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.dob!=null){
                                bureauHighmark.DOB__c=date.valueof(convertDate((respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.dob)));
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.addresss1!=null)
                                bureauHighmark.Address__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.addresss1;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.mbrId!=null)
                                bureauHighmark.MbrId__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.mbrId;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditInqPurpsTyp!=null)
                                bureauHighmark.CreditInqPurpsType__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditInqPurpsTyp;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditInqPurpsTypDesc!=null)
                                bureauHighmark.creditInqPurpsTypDesc__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditInqPurpsTypDesc;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditInquiryStage!=null)
                                bureauHighmark.CreditInquiryStage__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditInquiryStage;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditRptId!=null)
                                bureauHighmark.CreditRptId__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditRptId;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditReqTyp!=null)
                                bureauHighmark.CreditReqType__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditReqTyp;
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditRptTrnDtTm!=null)
                                bureauHighmark.CreditRptTrnDtTm__c=respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.creditRptTrnDtTm;
                            if(String.isNotBlank(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.loanAmount) && respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.loanAmount!=null && respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.loanAmount!= 'null')
                                bureauHighmark.LoanAmount__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.request.loanAmount);
                            if(previousBureau.size() == 0){
                                listtoinsertHighmark.add(bureauHighmark);
                            }
                            System.debug('listtoinsertHighmark'+listtoinsertHighmark);
                            if(listtoinsertHighmark.size()>0)
                                insert listtoinsertHighmark;
                            
                        }
                        if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation!=null){
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.nameVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.nameVariations[0].variation!=null){
                                    for(HighMarkWrapper.nameVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.nameVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=NameVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }                               
                                }
                                
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.addressVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.addressVariations[0].variation!=null){
                                    for(HighMarkWrapper.addressVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.addressVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=AddressVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }
                                    
                                }
                                
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.panVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.panVariations[0].variation!=null){
                                    for(HighMarkWrapper.panVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.panVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=PanVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }  
                                }
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.drivingLicenseVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.drivingLicenseVariations[0].variation!=null){
                                    for(HighMarkWrapper.drivingLicenseVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.drivingLicenseVariations){
                                        //HighMarkWrapper.drivingLicenseVariations detail = respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.drivingLicenseVariations;
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=DLVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }      
                                }   
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.dateOfBirthVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.dateOfBirthVariations[0].variation!=null){
                                    for(HighMarkWrapper.dateOfBirthVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.dateOfBirthVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=DOBVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }
                                }
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.voterIdVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.voterIdVariations[0].variation!=null){
                                    for(HighMarkWrapper.voterIdVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.voterIdVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=VoterIdVariationsRecordTypeId; 
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }
                                    
                                }
                                
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.passportVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.passportVariations[0].variation!=null){
                                    for(HighMarkWrapper.passportVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.passportVariations){
                                        //HighMarkWrapper.passportVariations detail = respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.passportVariations;
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=PassportVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }
                                }
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.phoneNumberVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.phoneNumberVariations[0].variation!=null){
                                    for(HighMarkWrapper.phoneNumberVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.phoneNumberVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=PhoneNumberVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }
                                    
                                }
                                
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.rationCardVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.rationCardVariations[0].variation!=null){
                                    for(HighMarkWrapper.rationCardVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.rationCardVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=RationCardVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }
                                    
                                }
                                
                            }
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.emailVariations!=null){
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.emailVariations[0].variation!=null){
                                    for(HighMarkWrapper.emailVariations detail:respWrap.basePlusReportFile.basePlusReports.basePlusReport.personalInfoVariation.emailVariations){
                                        Personal_Info_Variation__c pv=new Personal_Info_Variation__c();
                                        pv.RecordTypeId=EmailVariationsRecordTypeId;
                                        if(listtoinsertHighmark.size()>0)
                                            pv.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                        if(detail.variation.value!=null || detail.variation.reportedDate!=null){
                                            if(detail.variation.value!=null)
                                                pv.Value__c=detail.variation.value;
                                            if(detail.variation.reportedDate!=null){
                                                pv.Reported_Date__c = date.valueof(convertDate((detail.variation.reportedDate)));
                                            }
                                            listtoinsertPersonalInfo.add(pv); 
                                        }
                                    }
                                    
                                }
                                
                            }                    
                        }
                        //Loan Details 
                        if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary!=null){
                            //Loan Details Derived
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes!=null){
                                Account_Summary__c loanDetail=new Account_Summary__c();
                                loanDetail.Type__c = 'Bureau';
                                if(listtoinsertHighmark.size()>0)
                                    loanDetail.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                loanDetail.RecordTypeId=DerivedAccSummaryRecordTypeId;
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.inquiriesInLastSixMonths!=null){
                                    loanDetail.Inquiries_In_Last_Six_Months__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.inquiriesInLastSixMonths);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.lengthOfCreditHistoryYear!=null){
                                    loanDetail.Length_Of_Credit_History_Year__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.lengthOfCreditHistoryYear);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.lengthOfCreditHistoryMonth!=null){
                                    loanDetail.Length_Of_Credit_History_Month__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.lengthOfCreditHistoryMonth);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.averageAccountAgeYear!=null){
                                    loanDetail.Average_Account_Age_Year__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.averageAccountAgeYear);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.averageAccountAgeMonth!=null){
                                    loanDetail.Average_Account_Age_Month__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.averageAccountAgeMonth);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.newAccountsInLastSixMonths!=null){
                                    loanDetail.New_Accounts_In_Last_Six_Months__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.newAccountsInLastSixMonths);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.newDelinqAccountsInLastSixMonths!=null){
                                    loanDetail.New_Delinq_Accounts_In_Last_Six_Months__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.derivedAttributes.newDelinqAccountsInLastSixMonths);
                                }
                                
                                accSummaryList.add(loanDetail);
                            }  
                            //Loan Details Primary
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary!=null){
                                Account_Summary__c loanDetail=new Account_Summary__c();
                                loanDetail.Type__c = 'Bureau';
                                loanDetail.RecordTypeId=PrimaryAccSummaryRecordTypeId;
                                if(listtoinsertHighmark.size()>0)
                                    loanDetail.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryNumberOfAccounts!=null){
                                    loanDetail.Primary_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryNumberOfAccounts);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryActiveNumberOfAccounts!=null){
                                    loanDetail.Primary_Active_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryActiveNumberOfAccounts);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryOverdueNumberrOfAccounts!=null){
                                    loanDetail.Primary_Overdue_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryOverdueNumberrOfAccounts);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primarySecuredNumberOfAccounts!=null){
                                    loanDetail.Primary_Secured_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primarySecuredNumberOfAccounts);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryUnsecuredNumberOfAccounts!=null){
                                    loanDetail.Primary_Unsecured_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryUnsecuredNumberOfAccounts);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryUntaggedNumberOfAccounts!=null){
                                    loanDetail.Primary_Untagged_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryUntaggedNumberOfAccounts);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryCurrentBalance!=null){
                                    String primaryCurrentBalance = respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryCurrentBalance;
                                    primaryCurrentBalance = primaryCurrentBalance.remove(',');
                                    loanDetail.Primary_Current_Balance__c=decimal.valueof(primaryCurrentBalance);
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primarySanctionedAmount!=null){
                                    loanDetail.Primary_Sanctioned_Amount__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primarySanctionedAmount.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryDisbursedAmount!=null){
                                    loanDetail.Primary_Disbursed_Amount__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.primaryAccountsSummary.primaryDisbursedAmount.remove(','));
                                }
                                
                                accSummaryList.add(loanDetail);
                                
                            }
                            //Loan Details Secondary
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary!=null){
                                Account_Summary__c loanDetail=new Account_Summary__c();
                                loanDetail.Type__c = 'Bureau';
                                if(listtoinsertHighmark.size()>0)
                                    loanDetail.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                loandetail.RecordTypeId=SecondaryAccSummaryRecordTypeId;
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryNumberOfAccounts!=null){
                                    loanDetail.Secondary_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryNumberOfAccounts.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryActiveNumberOfAccounts!=null){
                                    loanDetail.Secondary_Active_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryActiveNumberOfAccounts.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryOverdueNumberOfAccounts!=null){
                                    loanDetail.Secondary_Overdue_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryOverdueNumberOfAccounts.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondarySecuredNumberOfAccounts!=null){
                                    loanDetail.Secondary_Secured_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondarySecuredNumberOfAccounts.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryUnSecuredNumberOfAccounts!=null){
                                    loanDetail.Secondary_Unsecured_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryUnSecuredNumberOfAccounts.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryUntaggedNumberOfAccounts!=null){
                                    loanDetail.Secondary_Untagged_Number_Of_Accounts__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryUntaggedNumberOfAccounts.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryCurrentBalance!=null){
                                    loanDetail.Secondary_Current_Balance__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryCurrentBalance.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondarySanctionedAmount!=null){
                                    loanDetail.Secondary_Sanctioned_Amount__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondarySanctionedAmount.remove(','));
                                }
                                if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryDisbursedAmount!=null){
                                    loanDetail.Secondary_Disbursed_Amount__c=decimal.valueof(respWrap.basePlusReportFile.basePlusReports.basePlusReport.accountsSummary.secondaryAccountsSummary.secondaryDisbursedAmount.remove(','));
                                }
                                accSummaryList.add(loanDetail);
                            }
                            //Loan Details Main
                            // code added by Vivek Sengar [07-07-2022]
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.responses!=null){
                                for(HighMarkWrapper.responses resObj : respWrap.basePlusReportFile.basePlusReports.basePlusReport.responses){
                                    if(resObj.response!=null){
                                        HighMarkWrapper.response restObj = resObj.response;
                                        
                                        
                                        if(restObj.loanDetails!=null){
                                            HighMarkWrapper.loanDetails loanDtlObj = restObj.loanDetails;
                                            Loan_Details__c loanDetail=new Loan_Details__c();
                                            loanDetail.Type__c = 'Bureau';
                                            if(listtoinsertHighmark.size()>0)
                                                loanDetail.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                            loanDetail.RecordTypeId=LoanDetailsRecordTypeId;
                                            
                                            if(loanDtlObj.acctType!=null){
                                                loanDetail.Type_of_Loan__c = loanDtlObj.acctType;
                                            }
                                            if(loanDtlObj.ownershipInd!=null){
                                                loanDetail.Ownership__c = loanDtlObj.ownershipInd;
                                            }
                                            if(loanDtlObj.disbursedAmt!=null){
                                                loanDetail.Loan_Amt__c = Decimal.valueOf(loanDtlObj.disbursedAmt.remove(','));
                                            }
                                            if(loanDtlObj.currentBal!=null){
                                                loanDetail.O_S__c = Decimal.valueOf(loanDtlObj.currentBal.remove(','));
                                            }
                                            if(loanDtlObj.overdueAmt!=null){
                                                loanDetail.Overdue_Amt__c = Decimal.valueOf(loanDtlObj.overdueAmt.remove(','));
                                            }
                                            //updated on 16/9
                                            if(loanDtlObj.accountStatus!=null){
                                                loanDetail.Account_Status__c = loanDtlObj.accountStatus;
                                            }
                                            if(loanDtlObj.creditGuarantor!=null){
                                                loanDetail.Credit_Guarantor__c = loanDtlObj.creditGuarantor;
                                            }
                                            if(loanDtlObj.repaymentTenure!=null){
                                                loanDetail.Repayment_Tenure__c = Decimal.valueOf(loanDtlObj.repaymentTenure);
                                            }
                                            if(loanDtlObj.installationAmt!=null){
                                                System.debug('loanDtlObj.installationAmt '+loanDtlObj.installationAmt);
                                                if(loanDtlObj.installationAmt.contains('/')){
                                                    String temp = loanDtlObj.installationAmt.split('/')[0];
                                                    String emiFreq = loanDtlObj.installationAmt.split('/')[1];
                                                    System.debug('temp '+temp);
                                                    System.debug('emiFreq '+emiFreq);
                                                    loanDetail.EMI_Frequency__c = emiFreq;
                                                    loanDetail.Obligations__c = Decimal.valueOf(temp.remove(','));
                                                }
                                            }
                                            // DPD Calculation Added By Parag Goyal
                                            if(loanDtlObj.combinedPaymentHistory!=null){
                                                DPDWrapper objDPD = new DPDWrapper();
                                                objDPD = calcDPD(loanDtlObj.combinedPaymentHistory);
                                                loanDetail.Current_DPD__c = String.valueOf(objDPD.currentDPD);
                                                loanDetail.Max_DPD__c = String.valueOf(objDPD.maxDPD);
                                            }
                                            listtoinsertLoanDetails.add(loanDetail);
                                            
                                        }
                                    }
                                }  
                            }
                        }
                        if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.inquiryHistory!=null){
                            
                            for(HighMarkWrapper.InquiryHistory historyy:respWrap.basePlusReportFile.basePlusReports.basePlusReport.inquiryHistory){
                                Inquiry_History__c inquiryHistory=new Inquiry_History__c();
                                if(listtoinsertHighmark.size()>0)
                                    inquiryHistory.Bureau_Highmark__c=listtoinsertHighmark[0].id;
                                if(historyy.history.memberName!=null)
                                    inquiryHistory.Name=historyy.history.memberName;
                                if(historyy.history.inquiryDate!=null){
                                    inquiryHistory.InquiryDate__c=date.valueof(convertDate((historyy.history.inquiryDate)));
                                }
                                if(historyy.history.purpose!=null)
                                    inquiryHistory.Purpose__c=historyy.history.purpose;
                                if(historyy.history.ownershipType!=null)
                                    inquiryHistory.OwnershipType__c=historyy.history.ownershipType;
                                if(historyy.history.amount!=null)
                                    inquiryHistory.Amount__c=decimal.valueof(historyy.history.amount.remove(','));
                                listtoinsertInquiryHistory.add(inquiryHistory) ;
                            }   
                            
                            
                        }
                        if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.printableReport!=Null){
                            if(respWrap.basePlusReportFile.basePlusReports.basePlusReport.printableReport.content!=Null){
                                system.debug('reporthtml'+respWrap.basePlusReportFile.basePlusReports.basePlusReport.printableReport.content);
                                Blob bodyBlob=Blob.valueOf(respWrap.basePlusReportFile.basePlusReports.basePlusReport.printableReport.content); 
                                ContentVersion contentVersion_1 = new ContentVersion(
                                    Title='HighMark Report '+objLoan.Application__r.Name+' '+objLoan.Customer_Information__r.Name, /*+' '+respWrap.basePlusReportFile.basePlusReports.basePlusReport.printableReport.fileName,*/ 
                                    PathOnClient =respWrap.basePlusReportFile.basePlusReports.basePlusReport.printableReport.fileName,
                                    VersionData = bodyBlob, 
                                    origin = 'H',
                                    Loan_Applicant__c = objLoan.Id,
                                    isBureauReport__c = true,
                                    Uploaded_From__c = 'Login',
                                    Is_Additional_Document__c  = true
                                );
                                insert contentVersion_1;
                                ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
                                system.debug('contentVersion_2'+contentVersion_2.contentdocumentid);
                                ContentDocumentLink contentlink = new ContentDocumentLink();
                                contentlink.LinkedEntityId = objLoan.Application__c;
                                contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
                                contentlink.ShareType = 'V';
                                insert contentlink;  
                            } 
                        } 
                        if(accSummaryList.size()>0)
                            insert accSummaryList;
                        if(listtoinsertPersonalInfo.size()>0)    
                            insert listtoinsertPersonalInfo;
                        if(listtoinsertLoanDetails.size()>0)
                            insert listtoinsertLoanDetails;
                        if(listtoinsertInquiryHistory.size()>0)
                            insert listtoinsertInquiryHistory;  
                        objLoan.Is_Bureau_Verified__c = true;
                        isBureauVerified= true;
                    }  
                }
                
            }  
            else{
                objLoan.Is_Bureau_Verified__c = false;
                isBureauVerified= false;
            }
            UPDATE objLoan;
            System.debug('isBureauVerified #### '+isBureauVerified);
            return isBureauVerified;
        }
        catch(Exception e){
            system.debug('Main exception '+ e.getLineNumber() + ' - ' + e.getMessage());
            Error_Logger__c objErrorLog = new Error_Logger__c();
            objErrorLog.Description__c = e.getMessage().length() > 30000 ? e.getMessage().substring(0, 255) : e.getMessage();  
            objErrorLog.Exception_Message__c = e.getMessage().length() > 30000 ? e.getMessage().substring(0, 255) : e.getMessage();
            objErrorLog.Name = 'Bureau Highmark API';
            objErrorLog.Loan_Applicant__c = loanAppId;
            objErrorLog.Application__c = objLoan.Application__c;
            objErrorLog.Line_Number__c = string.valueof(e.getLineNumber());
            insert objErrorLog;
            return false;
        }
    }
    
    private static DPDWrapper calcDPD(String combPayHistory){
        //String str = 'Jun:2021,000/XXX|May:2021,000/XXX|Apr:2021,000/XXX|Mar:2021,000/XXX|Feb:2021,000/XXX|Jan:2021,000/XXX|Dec:2020,000/XXX|Nov:2020,000/XXX|Oct:2020,000/XXX|Sep:2020,000/XXX|Aug:2020,000/XXX|Jul:2020,000/XXX|Jun:2020,000/XXX|May:2020,000/XXX|Apr:2020,000/XXX|Mar:2020,000/XXX|Feb:2020,000/XXX|Jan:2020,000/XXX|Dec:2019,000/XXX|Nov:2019,000/XXX|Oct:2019,000/XXX|Sep:2019,000/XXX|Aug:2019,000/XXX|Jul:2019,000/XXX|Jun:2019,000/XXX|May:2019,000/XXX|Apr:2019,000/XXX|Mar:2019,000/XXX|Feb:2019,000/XXX|Jan:2019,000/XXX|Dec:2018,000/XXX|Nov:2018,000/XXX|Oct:2018,000/XXX|Sep:2018,000/XXX|Aug:2018,000/XXX|Jul:2018,000/XXX|';
        //System.debug(str.split('/'));
        System.debug('combPayHistory '+combPayHistory);
        Integer currentDPD;
        Integer maxDPD = 0;
        for(String dt : combPayHistory.split('/')){
            if(String.isNotBlank(dt)){
                String rst = dt.mid((dt.indexOf(',')+1),dt.length()-dt.indexOf(','));
                System.debug(rst + ' == ' + rst.isNumeric());
                if(rst.isNumeric()){
                    Integer val = Integer.valueOf(rst);
                    if(maxDPD < val){
                        maxDPD = val;
                    }
                    if(currentDPD == null || currentDPD > val){
                        currentDPD = val;
                    }
                }
            }else{
                System.debug('Blank');
            }
        }
        
        System.debug('currentDPD= '+currentDPd);
        System.debug('maxDPD= '+maxDPD);
        DPDWrapper objDPD = new DPDWrapper();
        objDPD.currentDPD = currentDPD;
        objDPD.maxDPD = maxDPD;
        return objDPD;
    }
    
    private static String convertDate(String dob){
        String str = string.valueof(dob);
        string day=str.SubStringBefore('-');
        string month=str.SubStringafter('-');
        string year=month.SubStringafter('-');
        month=month.SubStringBefore('-');
        return year+'-'+month+'-'+day; 
    }
    
    public class DPDWrapper{
        public Integer currentDPD;
        public Integer maxDPD;
    }
    
}