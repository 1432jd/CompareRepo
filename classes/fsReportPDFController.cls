public without sharing class fsReportPDFController {
    
    
    //LWC Attribute
    public Static String applicationId;
    
    //VF Attribute
    public String getVal{get;set;}
    public List<InitWrapper> IWList{get;set;}

    //VF PAGE METHOD
    public fsReportPDFController(){
        IWList = new List<InitWrapper>();
        applicationId = Apexpages.currentPage().getParameters().get('Id');
        Attachment att = [select Id,Name,Body from Attachment where parentId=:applicationId AND createddate=today LIMIT 1];
        String str = String.valueOf(att.Body.toString());
        IWList = (List<InitWrapper>)System.JSON.deserialize(str, List<InitWrapper>.class);
        system.debug('::IWList::' + IWList);
    }

    @AuraEnabled
    public static InitWrapper getData(String appId,String selectedStage){

        System.debug('app Id is >>>>'+appId);

        applicationId = appId;
        System.debug('application Id is >>>>'+appId);
        InitWrapper IW = new InitWrapper();
        IW.pageHeader = selectedStage + ' Report';
        Map<String,List<Custom_Report__mdt>> customReportMap = new  Map<String,List<Custom_Report__mdt>>();
        customReportMap = getMetadataQuery(selectedStage);
        for(Custom_Report__mdt cr : customReportMap.get(selectedStage)){
            String strVal = cr.Section_Query__c.replaceAll( '\\s+', '');
            List<String> fieldToQuery = strVal.split(',');
            String whereClause = cr.Application_Record_Id_Field_Name__c+' =: applicationId';
            if(String.isNotEmpty(cr.Additional_Where_Clause__c)){
                whereClause += ' AND ' + cr.Additional_Where_Clause__c;
            }
            String query = selector(cr.Object_Name__c,fieldToQuery,whereClause);

            System.debug('query is 35 >>>'+query);
            
            SectionWrapper sw = new SectionWrapper();
            if(String.isEmpty(cr.SubSection_Name__c)){      
                sw = fillSectionWrapper(cr.Section_Name__c,query,cr.Object_Name__c,fieldToQuery);
            }else{
                sw.sectionLabel = cr.Section_Name__c;
                sw.listRecords = null;
                sw.fieldLabelMap = null;
                sw.listSubSectionWrapper.add(fillSubSectionWrapper(cr.Section_Name__c, query,cr.Object_Name__c, fieldToQuery,cr.SubSection_Name__c));
            }
            IW.sectionList.add(sw);
        }
        return IW;
    }
    
    @AuraEnabled
    //public static boolean createDataForVF(String jsonData,String appId){
    public static boolean createDataForVF(List<InitWrapper> jsonData,String appId){
        String dataToSave = JSON.serialize(jsonData); 
        if(String.isEmpty(dataToSave)){
            return false;
        }else{
            List<Attachment> previousAttachment = new List<Attachment>([SELECT id FROM Attachment WHERE ParentId =: appId]);
            if(!previousAttachment.isEmpty()){
                delete previousAttachment;
            }
            
            Attachment att = new Attachment();
            att.Body = Blob.valueOf(dataToSave);
            att.Name='data'+'.json';
            att.parentId = appId;
            insert att;
            return true;
        }
    }
    
    private static Map<String,List<Custom_Report__mdt>> getMetadataQuery(String selectedStages){
        Map<String,List<Custom_Report__mdt>> returnMap = new  Map<String,List<Custom_Report__mdt>>();
        for(Custom_Report__mdt mdt : [SELECT Id, SubSection_Name__c, DeveloperName, Object_Name__c, Section_Name__c,
                                        Section_Query__c, Sequence__c, Stage__c, Additional_Where_Clause__c, 
                                        Application_Record_Id_Field_Name__c
                                        from Custom_Report__mdt where Stage__c =: selectedStages  ORDER BY Sequence__c ASC]){
            if(returnMap.containskey(mdt.Stage__c)){
                    returnMap.get(mdt.Stage__c).add(mdt);
            }else{
                    returnMap.put(mdt.Stage__c,new List<Custom_Report__mdt>{mdt});
            }                             
        }
        return returnMap;
    }
    
    private static SectionWrapper fillSectionWrapper(String sl, String query,String objAPIName, List<String> fieldToQuery){
        SectionWrapper SW = new SectionWrapper();
        SW.sectionLabel = sl;
        SW.fieldLabelMap = getFieldLabel(objAPIName,fieldToQuery); 
        System.debug('query data in section wrapper is >>>>'+Database.query(query));
        SW.listRecords = Database.query(query);
        SW.sObjectName = objAPIName;
        return SW;
    }
    
    private static SubSectionWrapper fillSubSectionWrapper(String sl, String query,String objAPIName, List<String> fieldToQuery,String ssl){
        SubSectionWrapper SW = new SubSectionWrapper();
        SW.subSectionLabel = ssl;
        SW.subSectionFieldLabelMap = getFieldLabel(objAPIName,fieldToQuery);
        SW.subSectionlistRecords = Database.query(query);
        SW.subSobjectName = objAPIName;
        return SW;
    }

    /*
    private static Map<String,String> parseQuery(sObject record, List<String> fieldToQuery){
        Map<String,String> returnMap = new Map<String,String>();        
        for(String field : fieldToQuery){
            if(field.contains('.')){
                String relName = field.substringBefore('.');
                String fldName = field.substringAfter('.');
                sObject childObj = record.getSObject(relName);
                System.debug('***' + childObj);
                System.debug('***' + fldName);                
                
                if(childObj != null && String.isNotBlank(String.valueOf(childObj.get(fldName)))){
                    returnMap.put(field,String.valueOf(childObj.get(fldName)));
                }else{
                    returnMap.put(field,' ');
                }
            }else{
                if(String.isNotBlank(String.valueOf(record.get(field)))){
                    returnMap.put(field,String.valueOf(record.get(field)));
                }else{
                    returnMap.put(field,' ');
                }
            }
        }
        //    System.debug('returnMap value is >>>'+returnMap);
        return returnMap;
    }
    */

    private static String selector(String objectName, List<String> fieldToQuery,String WHERE_CLAUSE){
        String simpleQuery = 'select {0} FROM {1}';
        String queryWithConditional = 'select {0} FROM {1} WHERE {2}';
        String fields = String.join(new List<String>(fieldToQuery),',');
        String query;
        if(String.isNotBlank(WHERE_CLAUSE)){
            query = String.format(queryWithConditional, new List<Object>{fields, objectName, WHERE_CLAUSE});
        }else{
            query = String.format(simpleQuery, new List<Object>{fields, objectName});
        }
        return query;
    }

    private static Map<String,String> getFieldLabel(String objAPIName, List<String> fieldsToWork){
        /****** WORKING CODE **
        Map<String,String> fieldsLabelMap = new Map<String,String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objAPIName);
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        
        for (String apiName: fieldMap.keySet()) {
            if(fieldsToWork.contains((apiName.toLowercase()))){
                String fieldLabel = fieldMap.get(apiName).getDescribe().getLabel();
                fieldsLabelMap.put(apiName.toLowercase(), fieldLabel);
            }else{
                system.debug('==>' + apiName);
            }
        }
        return fieldsLabelMap;
        */
        Map<String,String> fieldsLabelMap = new Map<String,String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objAPIName);
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        Map<String,String> refMap = new Map<String,String>();
        for (String apiName: fieldMap.keySet()) {
            if( String.valueOf(fieldMap.get(apiName).getDescribe().getType())== 'REFERENCE'){
                refMap.put(
                    String.valueOf(fieldMap.get(apiName).getDescribe().getRelationshipName()).toLowercase(),
                    String.valueOf(fieldMap.get(apiName).getDescribe().getReferenceTo()).toLowercase()
                );
            }
        }
        for(String field : fieldsToWork){
            if(field.contains('.')){
                String[] obj_fld = field.split('\\.');
                Schema.SObjectType targetType = Schema.getGlobalDescribe().get(refMap.get(obj_fld[0].toLowerCase()).replaceAll('[\\[\\](){}]',''));
                String lbl = targetType.getDescribe().fields.getMap().get(obj_fld[1]).getDescribe().getLabel();
                fieldsLabelMap.put(field.toLowercase(), lbl);
            }else{
                String fieldLabel = fieldMap.containsKey(field.toLowercase()) ? fieldMap.get(field.toLowercase()).getDescribe().getLabel() : '';
                fieldsLabelMap.put(field.toLowercase(), fieldLabel);
            }
        }
      //  System.debug('fieldsLabelMap is >>>'+fieldsLabelMap);
        return fieldsLabelMap;
    }

                 
    public class InitWrapper{        
        @AuraEnabled public String pageHeader{get;set;}
        @AuraEnabled public List<SectionWrapper> sectionList{get;set;}
        
        public InitWrapper(){
            this.sectionList = new List<SectionWrapper>();
        }
    }

    public class SectionWrapper{
        @AuraEnabled public String sectionLabel{get;set;}
        @AuraEnabled public List <sobject> listRecords{get;set;}
        @AuraEnabled public Map<String,String> fieldLabelMap{get;set;}
        @AuraEnabled public List <SubSectionWrapper> listSubSectionWrapper{get;set;}
        @AuraEnabled public String sObjectName{get;set;}        
        public SectionWrapper(){
            this.listRecords = new List<sobject>();
            this.fieldLabelMap = new Map<String,String>();            
            this.listSubSectionWrapper = new List<SubSectionWrapper>();
        }
    }
    
    public class SubSectionWrapper{
        @AuraEnabled public String subSectionLabel{get;set;}             
        @AuraEnabled public List <sObject> subSectionListRecords{get;set;}
        @AuraEnabled public Map<String,String> subSectionFieldLabelMap{get;set;}
        @AuraEnabled public String subSobjectName{get;set;}
        public SubSectionWrapper(){              
            this.subSectionListRecords = new List<sObject>();
            this.subSectionFieldLabelMap = new Map<String,String>();
        }
    }
    
}