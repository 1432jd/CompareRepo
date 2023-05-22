public class FsCourierApplicationGrid {
    
    @AuraEnabled
    public static List<Courier_Application__c> getCourierApplications(String courierControlId){
        System.debug('Courier Application => '+[SELECT Application__r.Name, Courier_Control__r.Name, Status__c, Document_Type__c, Remarks__c FROM Courier_Application__c WHERE Courier_Control__c =:courierControlId]);
        return [SELECT Id,Status__c, Application__c,isStatusDisable__c, Application__r.Name, Courier_Control__r.Name, Document_Type__c, Remarks__c FROM Courier_Application__c WHERE Courier_Control__c =:courierControlId];
    }
    
    @AuraEnabled
    public static Map<String, String> getStatusValues(){
        Map<String, String> statusValuesMap = new Map<String, String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('Courier_Application__c');
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get('Status__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            statusValuesMap.put(objPickList.getLabel(), objPickList.getValue());
        }
        System.debug('statusValuesMap '+statusValuesMap);
        return statusValuesMap;
    }
    
    @AuraEnabled
    public static String updatedCourierApplications(String updatedObjects){
        try {
            List<Application__c> applicationList = new List<Application__c>();
            Set<String> appIds = new Set<String>();
            List<Courier_Application__c> courierApplications = (List<Courier_Application__c>)JSON.deserialize(updatedObjects, List<Courier_Application__c>.class);
            update courierApplications;
            for(Courier_Application__c courierApp : courierApplications){
                appIds.add(courierApp.Application__c);
            }
            Map<Id, Application__c> applicationMap = new  Map<Id, Application__c>([SELECT Id, Stage__c, Sub_Stage__c FROM Application__C WHERE Id In: appIds]);
            for(Courier_Application__c courierApp : courierApplications){
                Application__c app = applicationMap.get(courierApp.Application__c);
                if(app.Stage__c!='Disbursal Maker' && app.Stage__c!='Disbursal Author' && app.Stage__c!='Document Deferral' && app.Stage__c!='File Inward' && app.Stage__c!='VDC Maker' && app.Stage__c!='VDC Checker' && app.Stage__c!='Vendor Handoff'){
                    if(courierApp.Status__c == 'Received'){
                        app.Stage__c = 'Disbursal Maker';
                        // if(app.Sub_Stage__c == 'DOS'){
                        //     app.Stage__c = 'Awaiting DOS';
                        // }
                    }
                    else if(courierApp.Status__c == 'Not Received'){
                        app.Stage__c = 'Dispatch Pending';
                    }
                    applicationList.add(app);
                }
            }
            if(applicationList.size()>0){
                update applicationList;
            }
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getIconName(String sObjectName){
        String icon;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }
        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sObjectName == tr.getSobjectName() ) {
                if( tr.isCustom() == true ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    icon = 'standard:' + sObjectName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                icon = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return icon;
    }
}