/**
* @File Name          : VerificationHelper.cls
* @Description        : Helper Class For Verification Trigger
* @Author             : Dipshi Verma
* @Created On         : 25/04/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         25/04/2022              Ajay Kumar             Initial Version
*/
public class VerificationHelper {

    public static void UpdateStageLogic(List<Verification__c> VerificationList)
    {
        List<Application__c> ApplicationList=new List<Application__c>();
        Set<String> ApplicationIdSet=new Set<String>();
        for(Verification__c verObj:VerificationList)
        {
            ApplicationIdSet.add(verObj.Application__c);
        }
        
        Map<String,List<Verification__c>> AppMap=new Map<String,List<Verification__c>>();
        for(Application__c applicationObj:[SELECT Id,(SELECT Id,Status__c, RecordTypeId FROM Verifications__r) FROM Application__c WHERE Id IN:ApplicationIdSet])
        {
            AppMap.put(applicationObj.Id,applicationObj.Verifications__r);
        }
        
        for(String appkey:AppMap.KeySet())
        {
            Integer fivbCount=0,fivcCount=0;
            for(Verification__c verfObj:AppMap.get(appkey))
            {
                if(verfObj.Status__c=='Completed' && verfObj.RecordTypeId==Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - B').getRecordTypeId())
                {
                    fivbCount++;
                }
                else if(verfObj.Status__c=='Completed' && verfObj.RecordTypeId==Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId())
                {
                    fivcCount++;
                }
                if(fivbCount>=1 && fivcCount>=1)
                {
                    Application__c applObj=new Application__c();
                     System.debug('appid'+appkey);
                    applObj.Id=appkey;
                    applObj.Stage__c='In Principle Sanction';
                    ApplicationList.add(applObj);
                }
            }
             System.debug('ApplicationList'+ApplicationList);
            if(ApplicationList.size()>0)
                update ApplicationList;
            
        }
        
     }
    
}