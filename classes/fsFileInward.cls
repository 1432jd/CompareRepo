public without sharing class fsFileInward {
    @AuraEnabled
    public static List<FileInwardWrapper> getApplicationData(Date fromDate,Date toDate,String applicationName,String loanNumber){
        try {
            String Stage = 'File Inward';
            Date fromInDate= fromDate;
            Date toInDate= toDate;
            String loanNo = loanNumber.trim();
            String  appName = applicationName.trim();
            Map<String,Disbursal__c> disbursalAppMap = new Map<String,Disbursal__c>();
            if(toDate!=null){
           //     toInDate = ((toInDate.addHours(11)).addMinutes(59)).addSeconds(59);
                
            }
            //Datetime toDate = Datetime.newInstance(toDateInDate,Time.newInstance(11, 59, 59,0));
            System.debug('toDate'+toDate);
            List<FileInwardWrapper> fileInwardWrapperList = new List<FileInwardWrapper>();
            List<Application__c> appList = new List<Application__c>();
            //Added by sangeeta : 19 Dec 22 : if from date and end date is null
         /*   if(fromDate != null && toDate != null){
                System.debug('fromDate != null && toDate != null');
                appList =[select Id,Stage__c,Disbursal_Date__c,Stage_in_Date__c,Name,Primary_Applicant__r.Applicant_Name__c,LMS_Response_Reference__c,File_Inward_Status__c,Remarks__c,Pre_Login__r.recordtype.name,
                Sourcing_Branch__r.State__c,Sourcing_Branch__r.Name from Application__c where createdDate>=:fromInDate AND createdDate<=:toInDate AND Stage__c = 'File Inward'];
            }
            else if(fromDate == null && toDate == null){
                System.debug('fromDate == null && toDate == null');
                appList =[select Id,Stage__c,Disbursal_Date__c,Stage_in_Date__c,Name,Primary_Applicant__r.Applicant_Name__c,LMS_Response_Reference__c,File_Inward_Status__c,Remarks__c,Pre_Login__r.recordtype.name,
                Sourcing_Branch__r.State__c,Sourcing_Branch__r.Name from Application__c where Stage__c = 'File Inward'];
            }
            else if(fromDate == null && toDate != null){
                System.debug('fromDate == null && toDate != null');
                appList =[select Id,Stage__c,Disbursal_Date__c,Stage_in_Date__c,Name,Primary_Applicant__r.Applicant_Name__c,LMS_Response_Reference__c,File_Inward_Status__c,Remarks__c,Pre_Login__r.recordtype.name,
                Sourcing_Branch__r.State__c,Sourcing_Branch__r.Name from Application__c where createdDate <=: toInDate AND Stage__c = 'File Inward'];
            }
            else if(fromDate != null && toDate == null){
                System.debug('fromDate != null && toDate == null');
                appList =[select Id,Stage__c,Disbursal_Date__c,Stage_in_Date__c,Name,Primary_Applicant__r.Applicant_Name__c,LMS_Response_Reference__c,File_Inward_Status__c,Remarks__c,Pre_Login__r.recordtype.name,
                Sourcing_Branch__r.State__c,Sourcing_Branch__r.Name from Application__c where createdDate >=: fromInDate AND Stage__c = 'File Inward'];
            }*/
            //@Description : Ticket-0777 for old application number
            //@dated : 18 Jan 23
            //@Author: Sangeeta Yadav

            String query = 'select Id,Stage__c,Disbursal_Date__c,Stage_in_Date__c,Name,Primary_Applicant__r.Applicant_Name__c,LMS_Response_Reference__c,File_Inward_Status__c,Remarks__c,Pre_Login__r.recordtype.name,'; 
            query += 'Sourcing_Branch__r.State__c,Sourcing_Branch__r.Name, Old_Application__c, Old_Application__r.Name from Application__c';

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


           if(appList.size()>0){
            for(Disbursal__c disbObj : [select Id,Disbursal_Type__c,Application__c from Disbursal__c where Application__c IN : appList]){
                if(!(disbursalAppMap.containsKey(disbObj.Application__c))){
                    disbursalAppMap.put(disbObj.Application__c,disbObj);
                }
             }
           }
        
            
            if(appList.size()>0){
                System.debug('appList'+ appList);
                Integer sNo=0;
                for(Application__c app : appList){
                    ++sNo;
                    FileInwardWrapper fileInwardObj = new FileInwardWrapper();
                    fileInwardObj.Id = app.Id;
                    fileInwardObj.stage = app.Stage__c;
                    fileInwardObj.serialNumber = sNo;
                    fileInwardObj.applicationNo = app.Name;
                    //@Description : Ticket-0777 for old application number
                    //@dated : 18 Jan 23
                    //@Author: Sangeeta Yadav
                    if(app.Old_Application__c != null){
                        fileInwardObj.oldApplicationNo = app.Old_Application__r.Name;
                    }
                    else{
                        fileInwardObj.oldApplicationNo = 'NA';
                    }
                    fileInwardObj.customerName = app.Primary_Applicant__r.Applicant_Name__c!=null?app.Primary_Applicant__r.Applicant_Name__c:'';
                    fileInwardObj.sourcingBranchName = app.Sourcing_Branch__r.Name!=null?app.Sourcing_Branch__r.Name:'';
                    fileInwardObj.sourcingBranchState = app.Sourcing_Branch__r.State__c!=null?app.Sourcing_Branch__r.State__c:'';
                    fileInwardObj.loanNo = app.LMS_Response_Reference__c!=null?app.LMS_Response_Reference__c:'';
                    fileInwardObj.fileInwardStatus = app.File_Inward_Status__c!=null?app.File_Inward_Status__c:'';
                    fileInwardObj.remarks = app.Remarks__c!=null?app.Remarks__c:'';
                    fileInwardObj.appType = app.Pre_Login__r.recordtype.name;
                    fileInwardObj.disbursementDate = String.valueOf(app.Disbursal_Date__c)!=null?String.valueOf(app.Disbursal_Date__c):'';
                    fileInwardObj.stageInDate = String.valueOf(app.Stage_in_Date__c)!=null?String.valueOf(app.Stage_in_Date__c):'';
                    fileInwardObj.isError = false;

                    if(disbursalAppMap.containsKey(app.Id)){
                        fileInwardObj.disbursalType = disbursalAppMap.get(app.Id).Disbursal_Type__c;
                        fileInwardObj.disbursalId = disbursalAppMap.get(app.Id).Id;
                    }else{
                        fileInwardObj.disbursalType = '';
                    }


                    fileInwardWrapperList.add(fileInwardObj);
                }
            }
            
            return fileInwardWrapperList;
        } catch (Exception e) {
            System.debug('exeption is >>>>'+e.getMessage());
            System.debug('exeption Line Number  is >>>>'+e.getLineNumber());
        }

        return null;
    }


    @AuraEnabled
    public static string saveApplications(String dataWrapper){
        try {

        List<SObject> appList = new List<SObject>();
        
		List<FileInwardWrapper> wrapperList = (List<FileInwardWrapper> ) JSON.deserialize(dataWrapper, List<FileInwardWrapper> .class);

		Set<Id> appIdSet = new Set<Id> ();
		for (FileInwardWrapper wrapObj: wrapperList) {
			if (wrapObj.isChanged == true && wrapObj.Id!=null) {
				Application__c appObj = new Application__c();
                appObj.Id = wrapObj.Id;
                appObj.File_Inward_Status__c = wrapObj.fileInwardStatus;
                appObj.Remarks__c = wrapObj.remarks;
                appList.add(appObj);
			}
		}

        for (FileInwardWrapper wrapObj: wrapperList) {
                if(wrapObj.disbursalTypeChnaged && String.isNotBlank(wrapObj.disbursalId) && String.isNotEmpty(wrapObj.disbursalId) && wrapObj.disbursalId!=null){
                    Disbursal__c disbObj = new Disbursal__c();
                    disbObj.Id = wrapObj.disbursalId;
                    disbObj.Disbursal_Type__c = wrapObj.disbursalType;
                    appList.add(disbObj);
                }
		}

        if(appList != null && appList.size()>0){
            update appList;
            return 'success';
        }
        
            
        } catch (Exception e) {
            
            System.debug('exception is >>>>>'+e.getMessage());
            System.debug('exception is >>>>>'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return 'error';
    }

    @AuraEnabled
    public static string submitApplications(String dataWrapper){
        try {
            System.debug('dataWrapper'+ dataWrapper);
            Integer count =0;
            Integer pendingCount =0;
            List<Application__c> appList = new List<Application__c>();
            List<FileInwardWrapper> wrapperList = (List<FileInwardWrapper> ) JSON.deserialize(dataWrapper, List<FileInwardWrapper> .class);
            Boolean success = false;
            for (FileInwardWrapper wrapObj: wrapperList) {
                if((String.isNotBlank(wrapObj.disbursalType) && String.isNotEmpty(wrapObj.disbursalType) && wrapObj.disbursalType!=null && wrapObj.disbursalType=='Full Disb') && 
                ((String.isNotBlank(wrapObj.disbursalId) && String.isNotEmpty(wrapObj.disbursalId) && wrapObj.disbursalId!=null))){
                    if (wrapObj.isChanged == true && wrapObj.Id!=null && wrapObj.stage =='File Inward') { 
                        Application__c appObj = new Application__c();
                        appObj.Id = wrapObj.Id;
                        if(wrapObj.fileInwardStatus == 'Received'){
                            appObj.Stage__c = 'VDC Maker';
                            appList.add(appObj);
                        }else{
                            ++pendingCount;
                        }
                        success = true;
                    }
                }else{
                    ++count;
                } 
            }
    
            if(appList != null && appList.size()>0){
                update appList;
                return 'success';
            }else if(pendingCount >0){
                return 'pendingerror';
            }else if(count >0){
                return 'disberror';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return 'error';
    }




    public class FileInwardWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public Integer serialNumber;
        @AuraEnabled
        public String applicationNo;
        @AuraEnabled
        public String oldApplicationNo;
        @AuraEnabled
        public String customerName;
        @AuraEnabled
        public String sourcingBranchName;
        @AuraEnabled 
        public String sourcingBranchState;
        @AuraEnabled 
        public String loanNo;
        @AuraEnabled 
        public String fileInwardStatus;
        @AuraEnabled 
        public String remarks;
        @AuraEnabled 
        public String appType;
        @AuraEnabled 
        public String stageInDate;
        @AuraEnabled 
        public String disbursementDate;
        @AuraEnabled 
        public Boolean isChanged;
        @AuraEnabled 
        public String stage;
        @AuraEnabled 
        public String disbursalType;
        @AuraEnabled 
        public Boolean disbursalTypeChnaged;
        @AuraEnabled 
        public String disbursalId;
        @AuraEnabled 
        public Boolean isError = false;

        public FileInwardWrapper() {
			isChanged = false;
			remarks = '';
			fileInwardStatus = '';
            disbursalType='';
            disbursalId='';
            disbursalTypeChnaged=false;
		}

    }
}