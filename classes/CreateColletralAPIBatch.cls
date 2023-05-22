/**
* @File Name          : CreateColletralAPIBatch.apxc
* @Author             : Navin Soni
* @Created On         : 11 Oct 2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       11 Oct 2022              Navin Soni             Initial Version
**/

/* CreateColletralAPIBatch objCreateColletralAPIBatch = new CreateColletralAPIBatch('a030w000008HwIQAA0');
   Database.executeBatch(objCreateColletralAPIBatch, 1); */
global class CreateColletralAPIBatch implements Database.Batchable<sObject>, Database.AllowsCallouts  {

    private String applicationId;
    private String LMS_Collateral_Number = '';

    public CreateColletralAPIBatch(String appId) {
        applicationId = appId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Property__c WHERE Application__c = \''+ applicationId + '\''+ ' AND LMS_Collateral_Number__c = \''+ LMS_Collateral_Number + '\''+ '';
        System.debug('@@## query '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Property__c> listOfProperty) {
        system.debug('@@## listOfProperty '+listOfProperty);    
        if(listOfProperty != null && listOfProperty.size() > 0){
            for(Property__c objPro : listOfProperty){
                //FS_LMS_CreateColletralAPI.createColletral(objPro.id);
            }
        }
    }   

    global void finish(Database.BatchableContext BC) {
        
        // Execute the Book Loan API after the all Create Colletral API Execution.
        // FS_LMS_BookLoanAPI.createLoan(applicationId);
    }
}