public without sharing class OCRController {
    
    public static final List<String> applicantTypeList = new List<String>{'Primary Applicant','Co-Applicant','Guarantor'};

    @AuraEnabled 
    public static ReturnWrapper initialize(){
        ReturnWrapper RW = new ReturnWrapper();
        for(String str : applicantTypeList){
            RW.applicantTypePicklist.add(new PicklistWrapper(str, str));
        } 
        RW.metadataMap = getKYCType();
        for(String str : RW.metadataMap.keySet()){
            RW.kycTypePicklist.add(new PicklistWrapper(str, str));
        }
        return RW;
    }
    
    @AuraEnabled 
    public static CalloutWrapper doOCRCallout(String base64String,String metadataName,String recId,String KYCType,String ocrSide){
        System.debug('ocrSide '+ocrSide);
        CalloutWrapper objCallOut = new CalloutWrapper();
        HttpCalloutHelper http = new HttpCalloutHelper(metadataName,base64String);
        http.className = 'OCRController';
        HttpCalloutHelper.ResponseWrapper resWrap = http.doCallout();
        System.debug('response '+resWrap.response);
        FS_KYCOCRWrapper respWrap = FS_KYCOCRWrapper.parse(resWrap.response.getBody());
        System.debug('respWrap '+respWrap);
        KYC__c objOcr = getOCRRecord(recId);
        objCallOut.respWrap = respWrap;
        objCallOut.kycOcrId = parseInsertData(respWrap,objOcr,resWrap.apiLoggerId,KYCType,ocrSide);
        return objCallOut;
    }
    
    //Getting KYCOCR Records In Data Table
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getOCRData(List<String> kycOCRId){
        System.debug('applicationId=  '+kycOCRId); 
        Set<String> ocrIds = new Set<String>();
        for(KYC__c ocr : [SELECT Id FROM KYC__c 
                                WHERE Id IN :kycOCRId]){
                                    ocrIds.add(ocr.Id);
                                }
        
        System.debug('propIds=  '+ocrIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'fs_KYCOCR';
        genericDTObj.IDS_SET = ocrIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();     
    }
        
    private static KYC__c getOCRRecord(String recId){
        System.debug('recId '+recId);
        if(String.isEmpty(recId))
          return null;
        KYC__c objOcr = [SELECT Id,Name,isOCRDone__c, Description__c, City__c, ID__c, Fathers_Name__c, Spouce_Name__c, Gender__c, Mobile_Number__c,
                             DOB__c, Pin__c, Mothers_Name__c, API_Logger__c, First_Name__c, Last_Name__c, DateOfIssue__c, Passport_FileNo__c, Old_Passport_DOI__c, 
                             Old_Passport_No__c, Old_Passport_Place_Of_Issue__c, Loan_Applicant__c, address__c,DateOfExpiry__c,Flat_Plot_Number__c,Address_Line_2__c,addressLine1__c,Landmark__c
                             FROM KYC__c
                             WHERE Id = :recId LIMIT 1];
        System.debug('objOcr '+objOcr); 
        return objOcr;
    }

    private static String parseInsertData(FS_KYCOCRWrapper resWrap,KYC__c objOcr,String APILoggerId,String KYCType,String ocrSide){
        String query = '';
        for(FS_KYCOCRWrapper.cls_result detail : resWrap.result){
            System.debug('KYCType && typeReturn '+KYCType+' :: '+detail.type);
            String key = (KYCType.contains('Aadhaar')) ? 'Aadhaar' : (KYCType.contains('Voter')) ? 'Voter' : (KYCType.contains('Pan')) ? 'Pan' : (KYCType.contains('Driving')) ? 'DL' : (KYCType.contains('Passport')) ? 'Passport' : '';
            System.debug(key);
            if(!detail.type.contains(key)){
                return 'KYC Type Missmatch Error';
            }
            if(KYCType != 'Pan Card' && !KYCType.contains('Driving') && !detail.type.containsIgnoreCase(ocrSide)){
                return 'Wrong Side Image Uploaded Error';
            }
            query = '{';
            if(objOcr != null ){
                query +=  '"Id":"'+objOcr.id+'",';
                query +=  '"isOCRDone__c":"'+true+'",';
            }
            String dob;
            String exDob;
            if(objOcr!= null && objOcr.DOB__c != null){
                Date dT = objOcr.DOB__c;
                exDob = String.valueOf(date.newinstance(dT.year(), dT.month(), dT.day())) ;       
            }
            if(detail.details!= null && detail.details.dob!=null){
                if(string.isNotBlank(detail.details.dob.value)){ 
                    dob = getFormattedDate(KYCType, detail.details.dob.value);
                    System.debug('dob '+dob); 
                }
            }
            String addLine1 = '';
            if(detail.details != null && detail.details.addressSplit != null){
                if(detail.details.addressSplit.careOf != null)
                    addLine1 += detail.details.addressSplit.careOf+',';
                if(detail.details.addressSplit.line1 != null)
                    addLine1 += detail.details.addressSplit.line1;
            }
            String addLine2 = '';
            if(detail.details != null && detail.details.addressSplit != null){
                if(detail.details.addressSplit.line2 != null)
                    addLine2 += detail.details.addressSplit.line2+',';
                if(detail.details.addressSplit.street != null)
                    addLine2 += detail.details.addressSplit.street+',';
                if(detail.details.addressSplit.locality != null)
                    addLine2 += detail.details.addressSplit.locality;
            }
            query += '"API_Logger__c":"'+APILoggerId+'",'
                  + '"Flat_Plot_Number__c":"'+(objOcr != null && objOcr.Flat_Plot_Number__c!=null?objOcr.Flat_Plot_Number__c:(detail.details != null && detail.details.addressSplit != null && detail.details.addressSplit.houseNumber!= null  ?detail.details.addressSplit.houseNumber:''))+'",'
                  + '"Landmark__c":"'+(objOcr != null && objOcr.Landmark__c!=null?objOcr.Landmark__c:(detail.details != null && detail.details.addressSplit != null && detail.details.addressSplit.landmark!= null  ?detail.details.addressSplit.landmark:''))+'",'
                  + '"address__c":"'+(objOcr != null && objOcr.address__c!=null?objOcr.address__c:(detail.details != null && detail.details.address != null ?detail.details.address.value:''))+'",'
                  + '"addressLine1__c":"'+(objOcr != null && objOcr.addressLine1__c!=null?objOcr.addressLine1__c:(String.isNotBlank(addLine1)?addLine1:''))+'",'
                  + '"Address_Line_2__c":"'+(objOcr != null && objOcr.Address_Line_2__c!=null?objOcr.Address_Line_2__c:(String.isNotBlank(addLine2)?addLine2:''))+'",'
                  + '"City__c":"'+(objOcr != null && objOcr.City__c!=null?objOcr.City__c:(detail.details != null && detail.details.addressSplit != null ?detail.details.addressSplit.city:''))+'",'
                  + '"Name":"'+(objOcr != null && objOcr.Name!=null?objOcr.Name:KYCType)+'",'
                  + '"Gender__c":"'+(objOcr != null && objOcr.Gender__c!=null?objOcr.Gender__c:(detail.details != null && detail.details.gender != null?detail.details.gender.value:''))+'",'
                  + '"Fathers_Name__c":"'+(objOcr != null && objOcr.Fathers_Name__c!=null?objOcr.Fathers_Name__c:(detail.details!= null && detail.details.father != null ? detail.details.father.value:''))+'",'
                  + '"DOB__c":'+(objOcr != null && objOcr.DOB__c!=null?'"'+exDob+'",':(dob!=null?'"'+dob+'",':null+','))
                  + '"Mobile_Number__c":"'+(objOcr != null && objOcr.Mobile_Number__c!=null ? objOcr.Mobile_Number__c : (detail.details != null && detail.details.phone != null ? (detail.details.phone.value) : ''))+'",'
                  + '"Mothers_Name__c":"'+(objOcr != null && objOcr.Mothers_Name__c!=null?objOcr.Mothers_Name__c:(detail.details!= null && detail.details.mother != null ? detail.details.mother.value:''))+'",'
                  + '"Pin__c":"'+(objOcr != null && objOcr.Pin__c !=null ? objOcr.Pin__c :(detail.details!= null && detail.details.addressSplit != null ? detail.details.addressSplit.pin:''))+'"';     //Integer.valueof(detail.details.pin.value))+'",';
            if(KYCType != 'Passport'){ 
                if(detail.details.name!=null){
                    if(string.isNotBlank(detail.details.name.value)){
                        if(detail.details.name.value.contains(' ')){
                            String fName = detail.details.name.value.Substring(0,detail.details.name.value.lastindexof(' '));
                            String lName = detail.details.name.value.Substring(detail.details.name.value.lastindexof(' '),detail.details.name.value.length());
                            query += ',"First_Name__c":"'+(objOcr != null && objOcr.first_Name__c!=null?objOcr.first_Name__c:fName)+'"'
                                  + ',"Last_Name__c":"'+(objOcr != null && objOcr.last_Name__c!=null?objOcr.last_Name__c:lName)+'"';
                        }
                        else{
                            query += ',"First_Name__c":"'+(objOcr != null && objOcr.first_Name__c!=null?objOcr.first_Name__c:detail.details.name.value)+'"';
                        }
                    }
                } 
                if(KYCType == 'Aadhaar Card'){
                    if(detail.details != null && string.isNotEmpty(detail.details.aadhaar.value) )
                        query += ',"ID__c":"'+(objOcr != null && objOcr.ID__c!=null?objOcr.ID__c:detail.details.aadhaar.value)+'"';
                }
                else if(KYCType == 'Voter Id'){
                    if(string.isNotEmpty(detail.details.voterid.value) )
                        query += ',"ID__c":"'+(objOcr != null && objOcr.ID__c!=null?objOcr.ID__c:detail.details.voterid.value)+'"';
                }
                else if(KYCType == 'Pan Card'){
                    if(string.isNotEmpty(detail.details.panNo.value) )
                        query += ',"ID__c":"'+(objOcr != null && objOcr.ID__c!=null?objOcr.ID__c:detail.details.panNo.value)+'"';
                }
                else if(KYCType == 'Driving License'){
                    query += ',"ID__c":"'+(objOcr != null && objOcr.ID__c!=null?objOcr.ID__c:detail.details.dlNo.value)+'"';
                }  
            }
            else{
                System.debug('objOcr '+objOcr);
                System.debug('detail.details.fileNum.value '+detail.details.fileNum);
                String doi;
                String exDOI;
                String exOldDOI;
                String doe;
                String exDOE;
                query +=  ',"Passport_FileNo__c":"' + (objOcr != null && objOcr.Passport_FileNo__c != null ? objOcr.Passport_FileNo__c : detail.details.fileNum != null ? detail.details.fileNum.value : '')+'"'
                        + ',"Old_Passport_Place_Of_Issue__c":"'+(objOcr != null && objOcr.Old_Passport_Place_Of_Issue__c!=null?objOcr.Old_Passport_Place_Of_Issue__c:detail.details.oldPlaceOfIssue != null ? detail.details.oldPlaceOfIssue.value:'') + '"'
                        + ',"Old_Passport_No__c":"'+(objOcr != null && objOcr.Old_Passport_No__c!=null?objOcr.Old_Passport_No__c:detail.details.oldPassportNum!=null?detail.details.oldPassportNum.value:'')+'"';
                if(objOcr != null && objOcr.Old_Passport_DOI__c!=null){
                    Date dT = objOcr.Old_Passport_DOI__c;
                    exOldDOI = String.valueOf(date.newinstance(dT.year(), dT.month(), dT.day())) ; 
                    query  += ',"Old_Passport_DOI__c":"'+exOldDOI+'"';
                }
                else if(detail.details.oldDoi!=null && String.isNotBlank(detail.details.oldDoi.value)){
                    query  += ',"Old_Passport_DOI__c":"'+date.valueOf(detail.details.oldDoi.value)+'"';
                }
                else{
                    query  += ',"Old_Passport_DOI__c":null';
                }
                if(objOcr != null && objOcr.dateOfIssue__c!=null){
                    Date dT = objOcr.dateOfIssue__c;
                    exDOI = String.valueOf(date.newinstance(dT.year(), dT.month(), dT.day())) ;       
                    query  += ',"dateOfIssue__c":"'+exDOI+'"';
                }
                else if(detail.details.doi!=null && String.isNotBlank(detail.details.doi.value)){
                    doi = getFormattedDate(KYCType, detail.details.doi.value);
                    System.debug('doi '+doi); 
                    query  += ',"dateOfIssue__c":"'+doi+'"';// date.valueOf(detail.details.doi.value)
                }
                else{
                    query  += ',"dateOfIssue__c":null';
                }
                if(objOcr != null && objOcr.DateOfExpiry__c!=null){
                    Date dT = objOcr.DateOfExpiry__c;
                    exDOE = String.valueOf(date.newinstance(dT.year(), dT.month(), dT.day())) ;       
                    query  += ',"DateOfExpiry__c":"'+exDOE+'"';
                }
                else if(detail.details.doe!=null && String.isNotBlank(detail.details.doe.value)){
                    doe = getFormattedDate(KYCType, detail.details.doe.value);
                    System.debug('doe '+doe); 
                    query  += ',"DateOfExpiry__c":"'+doe+'"';// date.valueOf(detail.details.doi.value)
                }
                else{
                    query  += ',"DateOfExpiry__c":null';
                }
                if(detail.details.passportNum!=null){
                    if(string.isNotBlank(detail.details.passportNum.value) )
                        query += ',"ID__c":"'+(objOcr != null && objOcr.ID__c!=null?objOcr.ID__c:detail.details.passportNum.value)+'"';
                }
                if(detail.details.givenName!=null){
                    if(string.isNotBlank(detail.details.givenName.value))
                        query += ',"First_Name__c":"'+(objOcr != null && objOcr.first_Name__c!=null?objOcr.first_Name__c:detail.details.givenName.value)+'"';
                }
                if(detail.details.surname!=null){
                    if(string.isNotBlank(detail.details.surname.value))
                        query += ',"Last_Name__c":"'+(objOcr != null && objOcr.last_Name__c!=null?objOcr.last_Name__c:detail.details.surname.value)+'"';
                }
            }
            query += '}';
        }
        System.debug('query '+query);
        KYC__c kycOcr = (KYC__c)JSON.deserialize(query, KYC__c.class);
        kycOcr.RecordTypeId = DatabaseUtililty.getRecordTypeId('KYC__c','KYC OCR');
        System.debug('kycocr obj '+kycOcr);
        UPSERT kycOcr;
        return kycOcr.Id;
    }
    
    private static String getFormattedDate(String KYCType, String inputDate){
        if(KYCType == 'Voter Id'){
            string day = inputDate.SubStringBefore('-');
            string month = inputDate.SubStringafter('-');
            string year = month.SubStringafter('-');
            month = month.SubStringBefore('-');
            string strdate = year+'-'+month+'-'+day;
            inputDate = strdate;   
            return inputDate;
        }
        else{
            string day = inputDate.SubStringBefore('/');
            string month = inputDate.SubStringafter('/');
            string year = month.SubStringafter('/');
            month = month.SubStringBefore('/');
            string strdate = year+'-'+month+'-'+day;
            inputDate = strdate;
            return inputDate;
        }
    }

    private static Map<String,List<API_Handler__mdt>> getKYCType(){  
        Map<String,List<API_Handler__mdt>> metadataMap = new Map<String,List<API_Handler__mdt>>();
        List<API_Type__mdt> kycType = [SELECT id, (SELECT Id, MasterLabel, DeveloperName, Sub_Type__c, Order__c , Orientation__c FROM API_Handler__r) FROM API_Type__mdt WHERE Type__c =: 'OCR' AND isActive__c =: true LIMIT 1];
        if(!kycType.isEmpty()){            
            for(API_Handler__mdt ah : kycType[0].API_Handler__r){ 
                if(metadataMap.containsKey(ah.Sub_Type__c)){
                    metadataMap.get(ah.Sub_Type__c).add(ah);
                }else{
                    metadataMap.put(ah.Sub_Type__c,new List<API_Handler__mdt>{ah});
                }
            }
        }
        return metadataMap;
    }
    
    /*public static Boolean checkDuplicateKYC(String kycId){
        System.debug('KYCType '+kycId);
        if(String.isEmpty(kycId))
          return false;
        try{
            KYC__c objOcr = [SELECT Id,Id__c,isOCRDone__c
                                 FROM KYC__c
                                 WHERE Id__c = :kycId AND isOCRDone__c = true];
            System.debug('objOcr '+objOcr); 
            if(objOcr != null)
                return true;
            else
                return false;   
        }
        catch(Exception ex){
            System.debug(ex);
            return false;
        }
    }*/
    
    /*private static String getKYCId(FS_KYCOCRWrapper respWrap,String KYCType){
        String kycId = null;
        for(FS_KYCOCRWrapper.cls_result detail : respWrap.result){
            if(KYCType == 'Aadhaar Card'){
                if(string.isNotBlank(detail.details.aadhaar.value) )
                   kycId = detail.details.aadhaar.value;
            }
            else if(KYCType == 'Voter Id'){
                if(string.isNotBlank(detail.details.voterid.value) )
                    kycId = detail.details.voterid.value;
            }
            else if(KYCType == 'Pan Card'){
                if(string.isNotBlank(detail.details.panNo.value) )
                   kycId = detail.details.panNo.value;
            }
        }
        return kycId;
    }*/


    public class ReturnWrapper{
        @AuraEnabled public List<PicklistWrapper> applicantTypePicklist;
        @AuraEnabled public List<PicklistWrapper> kycTypePicklist;
        @AuraEnabled public Map<String,List<API_Handler__mdt>> metadataMap;

        public ReturnWrapper(){
            this.applicantTypePicklist = new List<PicklistWrapper>();
            this.kycTypePicklist = new List<PicklistWrapper>();
            this.metadataMap = new Map<String,List<API_Handler__mdt>>();
        }
    }
    
    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public PicklistWrapper(){}

        public PicklistWrapper(String l, String v){
            this.label = l; 
            this.value = v;
        }
    }
    
    public class CalloutWrapper{
       @AuraEnabled public FS_KYCOCRWrapper respWrap;
       @AuraEnabled public String kycOcrId;
    }
    
}