/**
* @File Name          : DropDownCode_Batch.cls
* @Description        : DropDownCode_Batch Class Used To Update Code Fields In the Respectives Objects
* @Author             : Mo Arslan
* @Created On         : 07/10/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        07/10/2022               Mo Arslan               Initial Version
*/

public class DropDownCode_Batch implements Schedulable,Database.Batchable<sObject> {
    public String query;
    public String sObjectType;
    public Integer batchSequence = 1;
    Date todayDate = System.today();
    Map<String, String> sourceTargetMap = new Map<String, String>();
    Map<String, String> sourceMetadataMap = new Map<String, String>();
    
    public DropDownCode_Batch(){
        sourceTargetMap.clear();
        query = 'SELECT ';
        for(Code_Alignment_Batch__mdt batchCode : [SELECT Source__c, Target__c, Object_Name__c, Sequence__c FROM Code_Alignment_Batch__mdt WHERE Sequence__c =:batchSequence]){
            query+=batchCode.Source__c+','+batchCode.Target__c+',';
            sourceTargetMap.put(batchCode.Source__c, batchCode.Target__c);
            sObjectType = batchCode.Object_Name__c;
        }
        query = query.removeEnd(',');
        query+=' FROM '+sObjectType+' WHERE DAY_ONLY(LastModifiedDate) =:todayDate';
        System.debug('Query '+query);
    }
    
    public DropDownCode_Batch(Integer sequence){
        sourceTargetMap.clear();
        batchSequence = sequence;
        query = 'SELECT ';
        for(Code_Alignment_Batch__mdt batchCode : [SELECT Source__c, Target__c, Object_Name__c, Sequence__c FROM Code_Alignment_Batch__mdt WHERE Sequence__c =:sequence]){
            query+=batchCode.Source__c+','+batchCode.Target__c+',';
            sourceTargetMap.put(batchCode.Source__c, batchCode.Target__c);
            sObjectType = batchCode.Object_Name__c;
        }
        query = query.removeEnd(',');
        query+=' FROM '+sObjectType+' WHERE DAY_ONLY(LastModifiedDate) =:todayDate';
        System.debug('Query '+query);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<sObject> sObjectToUpdate = new List<sObject>();
        Map<String, String> dropDownCode = new Map<String, String>();
        for(Drop_Down_Code__mdt code : [SELECT Name__c, Value__c FROM Drop_Down_Code__mdt WHERE Active__c = true]){
            dropDownCode.put(code.Name__c, code.Value__c);
        }
        System.debug('dropDownCode '+dropDownCode);
        for(sObject obj : scope){
            for(String sourceField : sourceTargetMap.keySet()){
                if(String.isNotBlank((String)obj.get(sourceField)) && dropDownCode.containsKey((String)obj.get(sourceField)))
                    obj.put(sourceTargetMap.get(sourceField), dropDownCode.get(String.valueOf(obj.get(sourceField))));
            }
            sObjectToUpdate.add(obj);
        }
        if(!sObjectToUpdate.isEmpty()){
            System.debug('sObjectToUpdate '+sObjectToUpdate);
            update sObjectToUpdate;
        }        
    }
    
    public void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new DropDownCode_Batch(),100);
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Finish');
        batchSequence = batchSequence+1;
        System.debug('Sequence '+batchSequence);
        if(batchSequence<=Integer.valueOf(System.Label.MaxinumSequence)){
            Database.executeBatch(new DropDownCode_Batch(batchSequence));            
        }
    }
}