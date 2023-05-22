/**
* @File Name          : CheckBureauVerified.cls
* @Description        : This class is being PreLogin LWC
* @Author             : Akshi Sharma
* @Created On         : 28/04/2023
**/


//This class is deprecated
public class CheckBureauVerified {
    @AuraEnabled
    public static Boolean checkBureauVerification(String appId, String label) {
        if (label == 'YES'){
            List<Loan_Applicant__c> pendingBureauLoanApplicants = [SELECT Id FROM Loan_Applicant__c WHERE Application__c=: appId AND Is_Bureau_Verified__c = False];
            return pendingBureauLoanApplicants!= null && pendingBureauLoanApplicants.size() > 0 ? false : true;          
        }
        return true;
    }
}