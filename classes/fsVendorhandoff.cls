public without sharing class fsVendorhandoff {
    @AuraEnabled
    public static List<VendorHandoffWrapper> getApplicationData(Date fromDate,Date toDate,String applicationName,String loanNumber){
        try {
            System.debug('loanNo is >>>'+loanNumber);
            Date fromInDate= fromDate;
            Date toInDate= toDate;
            String loanNo = loanNumber.trim();
            String  appName = applicationName.trim();
            System.debug('loanNo is >>>'+loanNo);
            if(toDate!=null){
              //  toInDate = ((toInDate.addHours(11)).addMinutes(59)).addSeconds(59);
                
            }
            String Stage = 'Vendor Handoff';
            List<VendorHandoffWrapper> vendorHandoffWrapperList = new List<VendorHandoffWrapper>();
            List<Application__c> appList = new List<Application__c>();
            String query = 'select Id,Name,LMS_Response_Reference__c,Stage_in_Date__c,Stage__c,Handoff_Date__c,File_Bar_Code__c,Box_Bar_Code__c,Storage_Vendor_Name__c,File_Status__c,'; 
            query += 'Sourcing_Branch__r.Name from Application__c';

            if((String.isNotBlank(appName) && String.isNotEmpty(appName) && appName != null) && 
             (String.isNotBlank(loanNo) || String.isNotEmpty(loanNo) || loanNo != null) && fromDate != null && toDate != null){
                 query += ' where Stage__c =: Stage AND LMS_Response_Reference__c=:loanNo AND Stage_in_Date__c>=:fromInDate AND Stage_in_Date__c<=:toInDate';
            }else if((String.isNotBlank(appName) && String.isNotEmpty(appName) && appName != null) && 
             (String.isNotBlank(loanNo) || String.isNotEmpty(loanNo) || loanNo != null) && fromDate == null && toDate != null){
                 query += ' where Stage__c =: Stage AND LMS_Response_Reference__c=:loanNo AND Stage_in_Date__c<=:toInDate';
            }else if((String.isNotBlank(appName) && String.isNotEmpty(appName) && appName != null) && 
             (String.isNotBlank(loanNo) || String.isNotEmpty(loanNo) || loanNo != null) && fromDate != null && toDate == null){
                 query += ' where Stage__c =: Stage AND LMS_Response_Reference__c=:loanNo AND Stage_in_Date__c >=: fromInDate';
            }else if(fromDate != null && toDate != null){
                query += ' where Stage_in_Date__c>=:fromInDate AND Stage_in_Date__c<=:toInDate AND Stage__c =: Stage';
            }else if(fromDate == null && toDate != null){
                query += ' where Stage_in_Date__c <=: toInDate AND Stage__c =: Stage';
            }else if(fromDate != null && toDate == null){
                query += ' where Stage_in_Date__c >=: fromInDate AND Stage__c =: Stage';
            }else if((String.isNotBlank(appName) && String.isNotEmpty(appName) && appName != null) && 
             (String.isNotBlank(loanNo) && String.isNotEmpty(loanNo) && loanNo != null)){
                query += ' where Stage__c =: Stage AND Name=:appName AND LMS_Response_Reference__c=:loanNo';
            }else if((String.isNotBlank(appName) && String.isNotEmpty(appName) && appName != null) && 
             (String.isBlank(loanNo) || String.isEmpty(loanNo) || loanNo == null)){
                 query += ' where Stage__c =: Stage AND Name=:appName';
            }else if((String.isBlank(appName) || String.isEmpty(appName) || appName == null) && 
             (String.isNotBlank(loanNo) && String.isNotEmpty(loanNo) && loanNo != null)){
                 query += ' where Stage__c =: Stage AND LMS_Response_Reference__c=:loanNo';
            }else if(fromDate == null && toDate == null && ((String.isBlank(appName) || String.isEmpty(appName) || appName == null)) && 
            ((String.isBlank(loanNo) || String.isEmpty(loanNo) || loanNo == null))){
                query += ' where Stage__c =: Stage';
            }

            System.debug('query is >>>'+query);

           appList = Database.query(query);
           System.debug('appList is >>>'+appList);
            
            if(appList.size()>0){
                System.debug('appList'+ appList);
                Integer sNo=0;
                for(Application__c app : appList){
                    ++sNo;
                    VendorHandoffWrapper vendorObj = new VendorHandoffWrapper();
                    vendorObj.Id = app.Id;
                    vendorObj.serialNumber = sNo;
                    vendorObj.applicationNo = app.Name;
                    vendorObj.sourcingBranchName = app.Sourcing_Branch__r.Name!=null?app.Sourcing_Branch__r.Name:'';
                    vendorObj.handoffDate = String.valueOf(app.Handoff_Date__c)!=null?String.valueOf(app.Handoff_Date__c):'';
                    vendorObj.fileBarCode = app.Box_Bar_Code__c!=null?app.Box_Bar_Code__c:'';
                    vendorObj.boxBarCode = app.File_Bar_Code__c!=null?app.File_Bar_Code__c:'';
                    vendorObj.storageVendorName = app.Storage_Vendor_Name__c!=null?app.Storage_Vendor_Name__c:'';
                    vendorObj.fileStatus = app.File_Status__c!=null?app.File_Status__c:'';
                    vendorObj.isError = false;
                    vendorHandoffWrapperList.add(vendorObj);
                }
            }else{
                return null;
            }
            
            return vendorHandoffWrapperList;
        } catch (Exception e) {
            System.debug('exeption is >>>>'+e.getMessage());
            System.debug('exeption Line Number  is >>>>'+e.getLineNumber());
        }

        return null;
    }


    @AuraEnabled
    public static string saveApplications(String dataWrapper){
        try {
            System.debug('inside appList >>>');
        List<Application__c> appList = new List<Application__c>();
        
		List<VendorHandoffWrapper> wrapperList = (List<VendorHandoffWrapper> ) JSON.deserialize(dataWrapper, List<VendorHandoffWrapper> .class);
        System.debug('wrapperList appList >>>'+wrapperList);
		Set<Id> appIdSet = new Set<Id> ();
		for (VendorHandoffWrapper wrapObj: wrapperList) {
			if (wrapObj.isChanged == true && wrapObj.Id!=null) {
				Application__c appObj = new Application__c();
                appObj.Id = wrapObj.Id;
                appObj.Handoff_Date__c = Date.valueOf(wrapObj.handoffDate);
                appObj.Box_Bar_Code__c = wrapObj.fileBarCode;
                appObj.File_Bar_Code__c = wrapObj.boxBarCode;
                appObj.Storage_Vendor_Name__c = wrapObj.storageVendorName;
                appObj.File_Status__c = wrapObj.fileStatus;
                appList.add(appObj);
			}
		}
        System.debug('vegfroe appList >>>'+appList);
        if(appList != null && appList.size()>0){
            System.debug('appList >>>'+appList);
            update appList;
            return 'success';
        }
        
            
        } catch (Exception e) {
            System.debug('exception is >>>>>'+e.getMessage());
            System.debug('exception is >>>>>'+e.getLineNumber());
        }
        return 'error';
    }

    @AuraEnabled
    public static string submitApplications(String dataWrapper){
        try {
            System.debug('dataWrapper'+ dataWrapper);
            List<Application__c> appList = new List<Application__c>();
            List<VendorHandoffWrapper> wrapperList = (List<VendorHandoffWrapper> ) JSON.deserialize(dataWrapper, List<VendorHandoffWrapper> .class);
            Boolean success = false;
            for (VendorHandoffWrapper wrapObj: wrapperList) {
                  if (((String.isNotBlank(wrapObj.handoffDate) && String.isNotEmpty(wrapObj.handoffDate) && wrapObj.handoffDate != null) &&
                  ((String.isNotBlank(wrapObj.boxBarCode) && String.isNotEmpty(wrapObj.boxBarCode) && wrapObj.boxBarCode != null)) &&
                  ((String.isNotBlank(wrapObj.fileBarCode) && String.isNotEmpty(wrapObj.fileBarCode) && wrapObj.fileBarCode != null))&&
                  ((String.isNotBlank(wrapObj.storageVendorName) && String.isNotEmpty(wrapObj.storageVendorName) && wrapObj.storageVendorName != null)) &&
                  ((String.isNotBlank(wrapObj.fileStatus) && String.isNotEmpty(wrapObj.fileStatus) && wrapObj.fileStatus != null)))) { 
                    Application__c appObj = new Application__c();
                    appObj.Id = wrapObj.Id;
                    appObj.Stage__c = 'Closed';
                    appList.add(appObj);
                }
            }
    
            if(appList != null && appList.size()>0){
                update appList;
                return 'success';
            }
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'error';
    }

    @AuraEnabled
    public static String getRepaymentDoc(String recordId){
        
        List<Application__c> appList= [select id,Name,(Select Id,ContentDocument.title, LinkedEntityId, ContentDocumentId FROM ContentDocumentLinks) from Application__c where Id=:recordId];
        
        if(appList.size()>0){
            
            for(Application__c appObj : appList){
                for(ContentDocumentLink obj : appObj.ContentDocumentLinks){
                    System.debug('obj.title'+obj.ContentDocument.title);
                    String title = 'RepaySchedule - '+ appObj.Name;
                    //if(obj.ContentDocument.title=='RepaySchedule'){
                    if(obj.ContentDocument.title.contains('RepaySchedule')){
                        return obj.ContentDocumentId;
                    }
                }
            }
        }
        
        return '';
        
    }




    public class VendorHandoffWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public Integer serialNumber;
        @AuraEnabled
        public String applicationNo;
        @AuraEnabled
        public String sourcingBranchName;
        @AuraEnabled 
        public Boolean isChanged;
        @AuraEnabled 
        public Boolean isError = false;
        @AuraEnabled
        public String handoffDate;
        @AuraEnabled
        public Boolean handoffDateError = false;
        @AuraEnabled
        public String fileBarCode;
        @AuraEnabled
        public Boolean fileBarCodeError = false;
        @AuraEnabled
        public String boxBarCode;
        @AuraEnabled
        public Boolean boxBarCodeError = false;
        @AuraEnabled
        public String storageVendorName;
        @AuraEnabled
        public Boolean storageVendorNameError = false;
        @AuraEnabled
        public String fileStatus;
        @AuraEnabled
        public Boolean fileStatusError = false;

        public VendorHandoffWrapper() {
			isChanged = false;
			fileStatus = '';
			storageVendorName = '';
            boxBarCode = '';
            fileBarCode = '';
            handoffDate = '';
		}

    }
}