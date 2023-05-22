public class fsDedupeExceptionUser {

    @AuraEnabled
    public static List<Dedupe_Detail__c> getExceptionUserApps(){
        List<Dedupe_Detail__c> appsList = new List<Dedupe_Detail__c>();
        Map<String,Dedupe_Detail__c> dedupeMap = new Map<String,Dedupe_Detail__c>();
        List<Dedupe_Detail__c> dedupeAppList = [select Id,Loan_Applicant__r.Application__r.Name,Loan_Applicant__r.Application__r.owner.Name,Loan_Applicant__r.Application__r.Stage__c,Loan_Applicant__r.Application__r.Id from Dedupe_Detail__c where owner.Name='Dedupe Exception User' AND Loan_Applicant__r.Application__r.Stage__c!=NULL];
        if(dedupeAppList.size()>0){
            for(Dedupe_Detail__c obj : dedupeAppList){
                if(!(dedupeMap.containsKey(obj.Loan_Applicant__r.Application__c))){
                    appsList.add(obj);
                    dedupeMap.put(obj.Loan_Applicant__r.Application__c,obj);
                }
            }
        }
        return appsList;
    }
}