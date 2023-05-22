public class fsGenerateCustodyReport {

    public String  applicationId{get;set;}
    public String  Stage{get;set;}
    public List<custodyWrap> custodyList{get;set;}


    public fsGenerateCustodyReport(){

        System.debug('hello custody');
        custodyList = new List<custodyWrap>();
            
            applicationId  =ApexPages.currentPage().getParameters().get('appId');

            for(Custody__c custodyObj : [select Id,Application_Number__r.Name,Application_Type__c,Box_Bar_Code__c,Branch_Name__r.Name,Checker_Id__r.Name,Checker_Remarks__c,Customer_Name__c,Disbursement_Date__c,File__c,File_Inward_Status__c,File_Status__c,
                                        Handoff_Date__c,Loan_Account_Number__c,Maker__c,Maker_Id__r.Name,Name,Old_Application_Number__c,Remarks__c,Stage_in_Date__c,State__c,Storage_Vendor_Name__c from Custody__c where Application_Number__c=:applicationId]){
                
                        custodyWrap custodywrpObj = new custodyWrap();
                        custodywrpObj.boxbarcode=String.valueOf(custodyObj.Box_Bar_Code__c)!=NULL?String.valueOf(custodyObj.Box_Bar_Code__c):'';
                        custodywrpObj.appNumber=String.valueOf(custodyObj.Application_Number__r.Name)!=NULL?String.valueOf(custodyObj.Application_Number__r.Name):'';
                        custodywrpObj.appType=String.valueOf(custodyObj.Application_Type__c)!=NULL?String.valueOf(custodyObj.Application_Type__c):'';
                        custodywrpObj.branchName=String.valueOf(custodyObj.Branch_Name__r.Name)!=NULL?String.valueOf(custodyObj.Branch_Name__r.Name):'';
                        custodywrpObj.checkerName=String.valueOf(custodyObj.Checker_Id__r.Name)!=NULL?String.valueOf(custodyObj.Checker_Id__r.Name):'';
                        custodywrpObj.checkerRemarks=String.valueOf(custodyObj.Checker_Remarks__c)!=NULL?String.valueOf(custodyObj.Checker_Remarks__c):'';
                        custodywrpObj.customerName=String.valueOf(custodyObj.Customer_Name__c)!=NULL?String.valueOf(custodyObj.Customer_Name__c):'';
                        custodywrpObj.disbursementDate=String.valueOf(custodyObj.Disbursement_Date__c)!=NULL?String.valueOf(custodyObj.Disbursement_Date__c):'';
                        custodywrpObj.fileBarCode=String.valueOf(custodyObj.File__c)!=NULL?String.valueOf(custodyObj.File__c):'';
                        custodywrpObj.fileInwardStatus=String.valueOf(custodyObj.File_Inward_Status__c)!=NULL?String.valueOf(custodyObj.File_Inward_Status__c):'';
                        custodywrpObj.fileStatus=String.valueOf(custodyObj.File_Status__c)!=NULL?String.valueOf(custodyObj.File_Status__c):'';
                        custodywrpObj.handOffDate=String.valueOf(custodyObj.Handoff_Date__c)!=NULL?String.valueOf(custodyObj.Handoff_Date__c):'';
                        custodywrpObj.loanAccountNo=String.valueOf(custodyObj.Loan_Account_Number__c)!=NULL?String.valueOf(custodyObj.Loan_Account_Number__c):'';
                        custodywrpObj.makerRemarks=String.valueOf(custodyObj.Maker__c)!=NULL?String.valueOf(custodyObj.Maker__c):'';
                        custodywrpObj.makerName=String.valueOf(custodyObj.Maker_Id__r.Name)!=NULL?String.valueOf(custodyObj.Maker_Id__r.Name):'';
                        custodywrpObj.Name=String.valueOf(custodyObj.Name)!=NULL?String.valueOf(custodyObj.Name):'';
                        custodywrpObj.oldAppNo=String.valueOf(custodyObj.Old_Application_Number__c)!=NULL?String.valueOf(custodyObj.Old_Application_Number__c):'';
                        custodywrpObj.remarks=String.valueOf(custodyObj.Remarks__c)!=NULL?String.valueOf(custodyObj.Remarks__c):'';
                        custodywrpObj.stageInDate=String.valueOf(custodyObj.Stage_in_Date__c)!=NULL?String.valueOf(custodyObj.Stage_in_Date__c):'';
                        custodywrpObj.state=String.valueOf(custodyObj.State__c)!=NULL?String.valueOf(custodyObj.State__c):'';
                        custodywrpObj.stageInDate=String.valueOf(custodyObj.Box_Bar_Code__c)!=NULL?String.valueOf(custodyObj.Box_Bar_Code__c):'';
                        custodywrpObj.storageVendorName=String.valueOf(custodyObj.Storage_Vendor_Name__c)!=NULL?String.valueOf(custodyObj.Storage_Vendor_Name__c):'';
                        custodyList.add(custodywrpObj);
            }
    }

    

    public class custodyWrap{
        public String boxbarcode{get;set;}
        public String appNumber{get;set;}
        public String appType{get;set;}
        public String branchName{get;set;}
        public String checkerName{get;set;}
        public String checkerRemarks{get;set;}
        public String customerName{get;set;}
        public String disbursementDate{get;set;}
        public String fileBarCode{get;set;}
        public String fileInwardStatus{get;set;}
        public String fileStatus{get;set;}
        public String handOffDate{get;set;}
        public String loanAccountNo{get;set;}
        public String makerRemarks{get;set;}
        public String makerName{get;set;}
        public String Name{get;set;}
        public String oldAppNo{get;set;}
        public String remarks{get;set;}
        public String stageInDate{get;set;}
        public String state{get;set;}
        public String storageVendorName{get;set;}
    }

}