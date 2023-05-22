public class AcknowledgementSlipController {
    public List<DocSlipWrapper> wrapperList{get;set;}
    public String application {get;set;}
    public List<String> slipCopies {get;set;}
    public String branchName {get;set;}

    public AcknowledgementSlipController(){
        String applicationId;
        applicationId = Apexpages.currentPage().getParameters().get('applicationId');
        wrapperList = getSlipRecords(applicationId);
        slipCopies = new List<String>{'Customer Copy','Branch Copy','H.O. Copy'};
        try{
           branchName = [SELECT Sourcing_Branch__r.Name FROM Application__c WHERE Id = :applicationId].Sourcing_Branch__r.Name; 
        }
        catch(exception e){
            System.debug(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertAcknowledgementSlipRecords(String jsonOflistOfDocs) {
        List<Agreement_Execution_Acknowledgement_Slip__c> listOfDocs = (List<Agreement_Execution_Acknowledgement_Slip__c>) JSON.deserialize(jsonOflistOfDocs, List<Agreement_Execution_Acknowledgement_Slip__c>.class);
        INSERT listOfDocs;
    }

    @AuraEnabled   
    public static String generateAcknowledgementSlip(String recordId){
        List<String> vfPageName = new List<String>{'AcknowledgementSlipVf'}; 
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(String vfName : vfPageName){
            PageReference pdf;
            pdf = Page.AcknowledgementSlipVf; 
            pdf.getParameters().put('applicationId',recordId);
            Blob body;   
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
            } else {
                body = pdf.getContentAsPDF();
            }    
            ContentVersion cv = new ContentVersion(Title = 'Acknowledgement_Slip', PathOnClient ='Acknowledgement_Slip.PDF', VersionData = body, FirstPublishLocationId = recordId, Uploaded_From__c = 'Agreement Execution',Is_Additional_Document__c  = true);
            cvList.add(cv); 
        }
        System.debug('cvList '+cvList);
        if(cvList.size() > 0){
        	INSERT cvList; 
            return 'Success';
        }
        return 'Failed';
    }

    @AuraEnabled
    public static List<DocSlipWrapper> getSlipRecords(String appId){
        List<DocSlipWrapper> listDocSlip = new List<DocSlipWrapper>();
        List<Agreement_Execution_Acknowledgement_Slip__c> listSlip = new List<Agreement_Execution_Acknowledgement_Slip__c>();
        listSlip = [SELECT Id,Application__r.Name,Name,Document_Type__c,Document_Number__c,Document_Date__c,Document_Condition__c,Number_Of_Pages__c 
                    FROM Agreement_Execution_Acknowledgement_Slip__c
                    WHERE Application__c = :appId ORDER BY CreatedDate];
        System.debug('ListSlip '+listSlip.size());
        if(!listSlip.isEmpty()){
            Integer count = 1;
            for(Agreement_Execution_Acknowledgement_Slip__c slip : listSlip){
                DocSlipWrapper doc = new DocSlipWrapper();
                doc.docName = slip.Name;
                doc.docType = slip.Document_Type__c;
                doc.docNumber = slip.Document_Number__c;
                doc.docDate = slip.Document_Date__c;
                doc.docCondition = slip.Document_Condition__c;
                doc.noOfPages = slip.Number_Of_Pages__c;
                doc.isNewRow = false;
                doc.index = count;
                doc.recId = slip.Id;
                doc.appName = slip.Application__r.Name;
                count++;
                listDocSlip.add(doc);
            }
        }
        System.debug('listDocSlip '+listDocSlip);
        return listDocSlip;
    }

    @AuraEnabled
    public static Boolean deleteSlipRecord(String recId){
        Agreement_Execution_Acknowledgement_Slip__c slip = [SELECT Id FROM Agreement_Execution_Acknowledgement_Slip__c WHERE Id =:recId];
        Database.DeleteResult srList = Database.DELETE(slip);
        if (srList.isSuccess()) {
            System.debug('Successfully deleted recordID: ' + srList.getId());
            return true;
        }
        else {
            return false;
        }
    }

    public class ListOfDocWrapper{
        @AuraEnabled public Integer count{get;set;}
        @AuraEnabled public ContentVersion cv{get;set;}
        @AuraEnabled public String docNumber{get;set;}
        
        public ListOfDocWrapper(){
            cv = new ContentVersion();
            docNumber = '';
            count = 0;
        }
    }

    public class DocSlipWrapper{
        @AuraEnabled public String docName{get;set;}
        @AuraEnabled public String docType{get;set;}
        @AuraEnabled public String docNumber{get;set;}
        @AuraEnabled public Date docDate{get;set;}
        @AuraEnabled public String docCondition{get;set;}
        @AuraEnabled public Decimal noOfPages{get;set;}
        @AuraEnabled public Boolean isNewRow{get;set;}
        @AuraEnabled public Integer index{get;set;}
        @AuraEnabled public String recId{get;set;}
        @AuraEnabled public String appName{get;set;}
    }
    
}