public class OnlineEC_Controller extends GenericDataTableController {
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCollateralDetails(String applicationId){      
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Online_EC_collateral';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(applicationId);
        String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Online EC Property Detail').getRecordTypeId();
        genericDTObj.IDS_SET.add(rcId);
        genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId =: IDS_SET';
        return genericDTObj.getTable();
    }

    @AuraEnabled
    public static List<Verification__c> getVerification(String recordId){
        System.debug('record id'+recordId);
        List<Verification__c> listOfVerification= [SELECT Id,Application__c, Application__r.Name, Application__r.Pre_Login__r.RecordTypeId, Status__c FROM Verification__c WHERE Id =: recordId AND RecordType.Name = 'Online EC'];
        System.debug('listOfVerification'+listOfVerification);
        if(listOfVerification != null && listOfVerification.size() > 0){
            listOfVerification[0].Status__c = 'Completed';
            update listOfVerification;
            System.debug('listtofVerification'+listOfVerification);
        }return listOfVerification;
    }
    @AuraEnabled
    public static string getOnlineECRecordTypeId(){
        return Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Online EC Property Detail').getRecordTypeId();
    }
    
    @AuraEnabled
    public static Map<Id,Account> getApplicantRecords(String appId){
        Set<String> applicantIds = new Set<String>();
        if(String.isNotBlank(appId)){
            for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: appId]){
                applicantIds.add(loanApplicant.Customer_Information__c);
            }
        }
        return new Map<Id,Account>([SELECT Id, Name, Applicant_Type__c FROM Account WHERE Id IN : applicantIds]);
    }
    
    @AuraEnabled
    public static Map<Id,Loan_Applicant__c> getLoanApplicantRecords(String appId){
        System.debug('appid'+appId);
        
        Map<Id,Loan_Applicant__c> loanApplicantMap = new Map<Id,Loan_Applicant__c>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Application__c, Customer_Information__c, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =: appId]){
            loanApplicantMap.put(loanApplicant.Customer_Information__c, loanApplicant);
        }
        
        return loanApplicantMap;
    }    
    
    @AuraEnabled
    public static Map<Id, Property__c> getPropertyRecords(String appId, String loanApplicationId){
        return new Map<Id, Property__c>([SELECT Id, Name, Login__c FROM Property__c WHERE Application__c =: appId AND Loan_Applicant__c =: loanApplicationId AND RecordType.Name !=  'Online EC Property Detail']);
    }
    
    @AuraEnabled
    public static List <Property__c> getPropertyRec(String proId){
        
        List<Property__c> listPro= [SELECT Id, Name,Title_Deed_Date__c,MS_Pincode__c,Title_Deed_Number__c,Title_Document_date__c,Plot_No__c,Sub_Registrar_Office__c,Property_Number__c,Survey_Number__c,Village__c,District__c,State__c,Title_Deed_Type__c, Login__c FROM Property__c WHERE  Id =:proId AND  RecordType.Name = 'Online EC Property Detail'];
        System.debug(listPro);
        if(listPro.size() != null)
            return listPro;
        else
            return null;
    }
    
    @AuraEnabled
    public static string generatePublicLink(String contentVersionId){
        try{
            ContentVersion cv = [SELECT Id, ContentDocumentId, Title, FileType, FileExtension, ContentSize FROM ContentVersion WHERE Id =:contentVersionId AND FileExtension IN ('jpg','jpeg','png','tiff','tif') LIMIT 1];
            cv.Uploaded_From__c = 'Online-EC';
            update cv;
            System.debug('cv'+cv);
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            return 'success';
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Online_EC_TableData getOnline_EC_Data(String appId){
        Online_EC_TableData tableData = new Online_EC_TableData();
        Set<String> applicantIds = new Set<String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: appId]){
            applicantIds.add(loanApplicant.Customer_Information__c);
        }
        GenericDataTableController genericDTObjCustomer = new GenericDataTableController();
        genericDTObjCustomer.METADATA_NAME = 'Online_EC_Customer_Information';
        genericDTObjCustomer.IDS_SET = applicantIds;
        genericDTObjCustomer.WHERE_CLAUSE = ' ID IN : IDS_SET';
        tableData.Online_EC_Table_Customer = genericDTObjCustomer.getTable();
        System.debug('tableData.Online_EC_Table_Customer= '+tableData.Online_EC_Table_Customer);
        GenericDataTableController genericDTObjNeighbour = new GenericDataTableController();
        genericDTObjNeighbour.METADATA_NAME = 'Online_EC_Neighbour';
        genericDTObjNeighbour.IDS_SET = applicantIds;
        genericDTObjNeighbour.WHERE_CLAUSE = ' Customer_Information__c IN : IDS_SET';
        tableData.Online_EC_Table_Neighbour = genericDTObjNeighbour.getTable();
        System.debug('tableData.Online_EC_Table_Neighbour= '+tableData.Online_EC_Table_Neighbour);
        return tableData;
    }
    
    public class Online_EC_TableData{
        @AuraEnabled
        public GenericDataTableController.DataTableResponse Online_EC_Table_Customer;
        @AuraEnabled
        public GenericDataTableController.DataTableResponse Online_EC_Table_Neighbour;
        public Online_EC_TableData(){
            Online_EC_Table_Customer = new GenericDataTableController.DataTableResponse();
            Online_EC_Table_Neighbour = new GenericDataTableController.DataTableResponse();
        }
    }
    
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getApplicantData(String appId){
        System.debug('appId=  '+appId);
        Set<String> applicantIds = new Set<String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: appId]){
            applicantIds.add(loanApplicant.Customer_Information__c);
        } 
        System.debug('applicantIds=  '+applicantIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Online_EC_Customer_Information';
        genericDTObj.IDS_SET = applicantIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();
    }   
    @AuraEnabled
    public static String saveRecord(sobject dataToInsert){
        try{
            system.debug('dataToInsert=' + dataToInsert);
            upsert dataToInsert;
            
        } catch(Exception ex){
            System.debug('exception='+ex);
            return JSON.serialize(ex);
        }
        return 'Record Successfully Created.';
    }
    
    /*@AuraEnabled
public static string insertPropert(String propId,Property__c proObj){
System.debug('proObj '+proObj);
System.debug('id'+propId);
System.debug('1'+proObj.Title_Deed_Number__c);
System.debug('2'+proObj.Village__c);
System.debug('3'+proObj.District__c);
System.debug('4'+proObj.State__c);
System.debug('5'+proObj.Survey_Number__c);
System.debug('6'+proObj.Sub_Registrar_Office__c);
System.debug('7'+proObj.Property_Number__c);
if(proObj.Title_Deed_Number__c == null || proObj.Title_Deed_Number__c=='' && proObj.Village__c == null|| proObj.Village__c == '' && proObj.District__c ==null || proObj.District__c == '' && proObj.State__c ==null || proObj.State__c== ''&& proObj.Survey_Number__c ==null ||proObj.Survey_Number__c == ''&& proObj.Sub_Registrar_Office__c== null || proObj.Sub_Registrar_Office__c == '' && proObj.Property_Number__c== null || proObj.Property_Number__c =='' && proObj.Plot_No__c == null|| proObj.Plot_No__c==''){
return 'Please fill all the required fields';
}
else{

Property__c propObj = [Select Property_Type__c, Application__c,Login__c, Title_Deed_Date__c, Floor__c,LengthSq_ft__c, Land_Measurement_Length_Sq_ft__c,Building_Age__c, Building_Area_Sq_Ft__c, Building_Constructed_with_Remarks__c, Building_Type__c, Building_Value_per_Sq_ft__c, Title_Deed_Type__c, Title_Deed_Number__c From Property__c Where Id =:propId];
proObj.Property_Type__c = propObj.Property_Type__c;
proObj.Application__c = propObj.Application__c;
proObj.Login__c = propObj.Login__c;
proObj.RecordTypeId =Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Online EC Property Detail').getRecordTypeId();

proObj.Title_Deed_Type__c = propObj.Title_Deed_Type__c;

//  insert proObj;
return 'record created successfully';
}

}*/
}