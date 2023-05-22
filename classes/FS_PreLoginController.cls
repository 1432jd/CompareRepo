/**
* @File Name          : Pre_Login__c
* @Description        : This Class is used To call KYCOCR api create API Logger Records,
Fetch records from Data Table (Metadata)
Create/Delete/Update/Fetch Prelogin related records like Login,Account,Poperty,Application,Loan Applicant,Receipt 
and Send Receipt record for Approval.
* @Author             : Vinay Mishra
* @Created On         : 04/04/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         04/04/2022              Vinay Mishra             Initial Version
* 53.0        04/05/2022              Parag Goyal               
*/
public class FS_PreLoginController extends GenericDataTableController { 
    //getting application records
    @AuraEnabled
    public static ApplicationWrapper getApplicationId(String recordId){
        System.debug('prelogin Id '+recordId);
        if(String.isNotBlank(recordId) && String.isNotEmpty(recordId)){
            String appId = '';
            Application__c objApp = [SELECT Id,Name FROM Application__c WHERE Pre_Login__c  = : recordId AND Pre_Login__c  != null];
                appId = objApp.Id;
                ApplicationWrapper appWrap = new ApplicationWrapper();
                appWrap.appId = objApp.Id;
                appWrap.appName = objApp.Name;
                System.debug('Application Wrapper '+appWrap);
                return appWrap;  
        }
        else
            return null;
    }
    
    public class ApplicationWrapper{
        @auraEnabled public String appId;
        @auraEnabled public String appName;
    }
}