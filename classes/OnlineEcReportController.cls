public class OnlineEcReportController {
    public String applicationId{get;set;}
    public Application__c applicationRecord{get;set;}
    Public OnlineEcReportController(){
        Set<String> applicantIds = new Set<String>();
        applicationRecord = new Application__c();
        applicationId = ApexPages.currentPage().getParameters().get('applicationId');
        applicationRecord = [SELECT Id, Name, Pre_Login__c, 
                             (SELECT Id, Name, Customer_Information__c, Customer_Information__r.Name,Title_Document_date__c,Risk_Document__c,Title_Deed_Type__c,Title_Deed_Number__c FROM Properties__r WHERE Customer_Information__c != NULL),
                             (SELECT Id, Customer_Information__c, Customer_Information__r.Customer_Type__c FROM Loan_Applicants__r WHERE Customer_Information__c != NULL),
                             (SELECT Id, Application__c, Application__r.Name, Inspection_Time__c,Status__c, Result__c, Owner__c 
                              FROM Verifications__r WHERE recordType.Name = 'Online Ec' ORDER BY CreatedDate DESC LIMIT 1)
                             FROM Application__c WHERE Id =: applicationId];
        for(Loan_Applicant__c objApplicant : applicationRecord.Loan_Applicants__r){
            applicantIds.add(objApplicant.Customer_Information__c); 
        }    
     
    }
  
  
}