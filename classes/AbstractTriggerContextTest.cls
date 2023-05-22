@isTest 
private class AbstractTriggerContextTest {
    
    @isTest
    public static void testMethod1(){
        String objectName = 'Application__c';
        System.TriggerOperation operationType;
       // operationType.AFTER_INSERT c = new operationType.AFTER_INSERT();
        Application__c app = new Application__c();
        app.name = 'Test';
        insert app;
        
        app.name = 'update name';
        update app;
        
        List<Application__c> newList = new List<Application__c>();
        newList.add(app);
        List<Application__c> oldList = new List<Application__c>();
        oldList.add(app);
        Map<Id,Application__c> newMap = new Map<Id,Application__c>();
        newMap.put(app.Id,app);
        Map<Id, Application__c> oldMap = new Map<Id,Application__c>();
        oldMap.put(app.ID,app);
        AbstractTriggerContext abs;
        
        AbstractTriggerContext.run(objectName, System.TriggerOperation.BEFORE_INSERT, newList, oldList, newMap, oldMap);
		AbstractTriggerContext.run(objectName, System.TriggerOperation.BEFORE_UPDATE, newList, oldList, newMap, oldMap);
		AbstractTriggerContext.run(objectName, System.TriggerOperation.BEFORE_DELETE, newList, oldList, newMap, oldMap);
		AbstractTriggerContext.run(objectName, System.TriggerOperation.AFTER_UNDELETE, newList, oldList, newMap, oldMap);
		AbstractTriggerContext.run(objectName, System.TriggerOperation.AFTER_INSERT, newList, oldList, newMap, oldMap);
		AbstractTriggerContext.run(objectName, System.TriggerOperation.AFTER_UPDATE, newList, oldList, newMap, oldMap);
        AbstractTriggerContext.getTiming(true, false);
		AbstractTriggerContext.getTiming(false, true);
		AbstractTriggerContext.getAction(true, true, true, true);
        AbstractTriggerContext.getAction(false, true, true, true);
		AbstractTriggerContext.getAction(false, false, true, true);
		AbstractTriggerContext.getAction(false, false, false, true);
		//abs.beforeInsert(newList);
        //abs.beforeUpdate(newList, oldList, newMap, oldMap);
        
    }
}