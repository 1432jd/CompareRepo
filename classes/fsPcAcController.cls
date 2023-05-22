/**
* @File Name          : fsPcAcController.cls
* @Description        : Service Class For FS PC/AC Screen Lightning Web Component
* @Author             : Ajay Kumar
* @Created On         : 22/06/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         22/06/2022              Ajay Kumar             Initial Version
*/
public without sharing class fsPcAcController {
    
    public fsPcAcController() {
        
    }
    
     @AuraEnabled
    public static effIrrWrapper getEffectiveIRR(String appId,Integer Tenure,String loanType,String numofEmi,String riskDocument,String recordTypeName)
    {
        effIrrWrapper wrapObj = new effIrrWrapper();
        Boolean isStaffplusVacant=false;
        if(recordTypeName == 'PC')
            recordTypeName = 'PC Property Detail';
        else if(recordTypeName == 'AC')
            recordTypeName = 'AC Property Detail';
        if(numofEmi!= null)
        {
            numofEmi = numofEmi+' Advance EMI'; 
        }
        System.debug('numofEmi'+numofEmi);
        system.debug('tenor'+Tenure);
        System.debug('loanType'+loanType);
        System.debug('Risk Document'+riskDocument);
        
        List<MS_IRR__c> effectiveList = new List<MS_IRR__c>();
        String mQuery = 'SELECT Eff_IRR__c, Rate__c, Tenure__c, Type_of_loan__c, EMI__c FROM MS_IRR__C WHERE Name =:numofEmi AND Tenure__c=:Tenure ';  
        Set<String> PropertyTypeSet = new Set<String>();
		for(Property__c proObj: [SELECT ID,Name,Property_Type__c FROM Property__c WHERE Application__c =:appId AND RecordType.Name =:recordTypeName])
		{
			if(proObj.Property_Type__c != null)
			{
				PropertyTypeSet.add(proObj.Property_Type__c);
			}
		}  
		
		if(PropertyTypeSet.contains('Vacant Land') || riskDocument == 'Orange' || riskDocument == 'Red')
		{ 
			isStaffplusVacant = ( loanType == '5S employee' ? true : false);			
			mQuery +=( loanType == '5S employee' ? ' AND Type_of_Loan__c =:loanType LIMIT 1' : ' AND Property_Type__c =\'Vacant land\' LIMIT 1'); 
		}
		else if(riskDocument == 'Green')
		{
			mQuery +=' AND Type_of_Loan__c =:loanType LIMIT 1';
		}          
        
        
        System.debug('mQUery'+mQuery);       
        effectiveList = Database.query(mQuery);
        System.debug('effectiveList'+effectiveList);
        if(effectiveList!= null && effectiveList.size()>0 )
        { 
            if(effectiveList[0].Rate__c !=null  || effectiveList[0].Eff_IRR__c != null)
            {
                wrapObj.Rate = (isStaffplusVacant == false ? effectiveList[0].Rate__c : effectiveList[0].Rate__c + 1);
                wrapObj.EffIrr = (isStaffplusVacant == false ? effectiveList[0].Eff_IRR__c : effectiveList[0].Eff_IRR__c + 1);
                /*Application__c appObj = new Application__c();
appObj.Id = appId;
appObj.Tenor_In_Months__c = String.valueOf(Tenure);
appObj.Effective_IRR__c = wrapObj.EffIrr;
appObj.Customer_Communicated__c = wrapObj.Rate;
Update appObj;*/                
            }
        } 
        
        return wrapObj;         
    }
    
    
    // This Method is used to update the status of PC Stage when AC Send back to PC Stage
    @AuraEnabled 
    public static void sendBackUpdate(String appId)    
    {
        Verification__c verObj = new Verification__c();
        for(Verification__c verificationObj : [SELECT Id,Status__c FROM Verification__c WHERE Application__c =:appId AND RecordType.Name = 'PC' AND Status__c != 'Pending' ORDER BY CreatedDate DESC ])
        {
            verObj.Id = verificationObj.Id;
            verObj.Status__c = 'Pending';                
        }
        System.debug('Verification List>>>> '+verObj);              
        if(verObj.Id!= null)
            update verObj;
    }
    
    // This Method is Used to get All AC Users From Public Group as per Branch
    @AuraEnabled
    public static List<User> getACUsers(String SourcingBranch)
    {
        Set<String> userIds = new Set<String>();
        for(Access_Branch_Allocation__c accuser:[SELECT Id, Access_Master__r.User__c ,Access_Master__r.Level__c
                                                 FROM Access_Branch_Allocation__c 
                                                 WHERE Access_Master__r.Access_For__c =: 'Approval Credit' 
                                                 AND Branch_Master__c =: SourcingBranch ])
        {  userIds.add(accuser.Access_Master__r.User__c);
         
        }
        system.debug('userids'+userIds);
        
        if(!userIds.isEmpty()){
            system.debug('data'+ [SELECT Id, Name FROM User WHERE Id IN : userIds]);
            return [SELECT Id, Name FROM User WHERE Id IN : userIds];
        }
        return null;
    }   
    
    // This method is used to fetch all the Properties List under an Application
    @AuraEnabled
    public static List<Property__c> getProperties(String appId)
    {
        
        List<Property__c> propertyList=[SELECT ID,Name FROM Property__c WHERE Application__C =:appId AND RecordType.Name IN ('FIV-C Property Detail','FIV-B Property Detail')];
        return propertyList;
    }
    
    // This method is used to fetch all the Applicants List under an Application
    @AuraEnabled 
    public static List<Loan_Applicant__c> getAccounts(String appId)
    {
        List<Loan_Applicant__c> LALIst=[SELECT ID,Customer_Information__r.Name,Customer_Type__c,Application__r.IsTopupDetailsGenerated__c FROM Loan_Applicant__c WHERE Application__C =:appId];
        return LALIst;
    }
    
    // This Method Is Used To Return Applicant Map For Particular Application
    @AuraEnabled
    public static Map<Id,Loan_Applicant__c> getApplicantList(String appId){
        return new Map<Id,Loan_Applicant__c>([SELECT Id, Application__c, Customer_Information__c, Customer_Information__r.Name, Customer_Type__c FROM Loan_Applicant__c WHERE Application__c =: appId  ]);
    }   
    
    /*
* Added By Yogendra Degra
* Date : 04/08/2022
* Cloned Functionality Start Here
*/
    public static void clonedPCRecordToAC(String appId,String verfId){
        //Character Record Clone//
        List<Character__c> listOfChar = new List<Character__c>();
        Set<String> setOfCharIds = new Set<String>();
        Map<String,String> AcCharMap = new Map<String,String>();
        String AC_CHAR_RECORD_TYPE = Utility.AC_CHARACTER_RECORD_TYPE_ID;
        for(Character__c objChar : [SELECT Id, Application__c,RecordTypeId,PC_Record_Id__c FROM Character__c WHERE Application__c =: appId AND (RecordTypeId =: Utility.PC_CHARACTER_RECORD_TYPE_ID OR RecordTypeId =:AC_CHAR_RECORD_TYPE)]){
            if(objChar.RecordTypeId == Utility.PC_CHARACTER_RECORD_TYPE_ID )
                setOfCharIds.add(objChar.Id);
            if(objChar.RecordTypeId == AC_CHAR_RECORD_TYPE && objChar.PC_Record_Id__c != null)
                AcCharMap.put(objChar.PC_Record_Id__c,objChar.Id);
        }
        System.debug('ACChar Map ###'+AcCharMap);
        System.debug('Set of char Ids &&&'+setOfCharIds);
        if(setOfCharIds != null && setOfCharIds.size() > 0){           
            for(Character__c objChar : (List<Character__c>)Utility.doClone(setOfCharIds, 'Character__c', true)){                   
                objChar.PC_Record_Id__c = objChar.Id;
                objChar.RecordTypeId = AC_CHAR_RECORD_TYPE;
                objChar.Verification__c = verfId;
                if(AcCharMap.containsKey(objChar.Id))
                {
                    system.debug('iteration'+objChar.Section_Type__c);
                    objChar.Id = AcCharMap.get(objChar.Id);
                    listOfChar.add(objChar.clone(true, false, false, false));
                }
                else
                {
                    listOfChar.add(objChar.clone(false, false, false, false));
                }
                
            }    
        }
        for(Character__c c:listOfChar )
        {
            System.debug('AC Char Obj ###'+c.Id);
        }
        
        if(listOfChar != null && listOfChar.size() > 0)
            upsert listOfChar;
        
        //Property Record Clone//
        List<Property__c> listOfProperty = new List<Property__c>();
        List<CommonObject__c> listOfFloor = new List<CommonObject__c>();
        Set<String> setOfProIds = new Set<String>();
        Set<String> setOfFloorIds = new Set<String>();
        Map<String,String> AcPropMap = new Map<String,String>();
        Map<String,String> FloorPropMap = new Map<String,String>();
        System.debug('AcPropMap Map ###'+AcPropMap);
        String AC_PRO_REOCRD_TYPE = Utility.AC_PROPERTY_RECORD_TYPE_ID;
        for(Property__c objPro : [SELECT Id, Application__c,Property__c,PC_Record_Id__c,RecordTypeId,(SELECT Id,PC_Record_Id__c FROM Enquiries__r) FROM Property__c WHERE Application__c =: appId AND (RecordTypeId =: Utility.PC_PROPERTY_RECORD_TYPE_ID OR RecordTypeId =: AC_PRO_REOCRD_TYPE)]){
            if(objPro.RecordTypeId == Utility.PC_PROPERTY_RECORD_TYPE_ID)
                setOfProIds.add(objPro.Id); 
            if(objPro.RecordTypeId == AC_PRO_REOCRD_TYPE && objPro.PC_Record_Id__c != null)
                AcPropMap.put(objPro.PC_Record_Id__c,objPro.Id);
            if(!objPro.Enquiries__r.isEmpty() && objPro.Enquiries__r.size()>0)
            {
                for(CommonObject__c com:objPro.Enquiries__r)
                {
                    if(objPro.RecordTypeId == Utility.PC_PROPERTY_RECORD_TYPE_ID)
                        setOfFloorIds.add(com.Id);
                    if(objPro.RecordTypeId == AC_PRO_REOCRD_TYPE && com.PC_Record_Id__c != null)
                        FloorPropMap.put(com.PC_Record_Id__c,com.Id);
                }
            }
        }
        if(setOfProIds != null && setOfProIds.size() > 0){
            for(Property__c objPro : (List<Property__c>)Utility.doClone(setOfProIds, 'Property__c', true)){
                objPro.PC_Record_Id__c = objPro.Id;
                objPro.RecordTypeId = AC_PRO_REOCRD_TYPE;
                if(AcPropMap.containsKey(objPro.Id))
                {    objPro.Id = AcPropMap.get(objPro.Id);
                 listOfProperty.add(objPro.clone(true, false, false, false));}
                else
                    listOfProperty.add(objPro.clone(false, false, false, false)); 
            }   
            
        }
        
        System.debug('listOfProperty ### '+listOfProperty);
        if(listOfProperty != null && listOfProperty.size() > 0)
            upsert listOfProperty;
        
        Map<String,String> AcPropInsertedMap = new Map<String,String>();
        for(Property__c acObj: listOfProperty)
        {
            AcPropInsertedMap.put(acObj.PC_Record_Id__c,acObj.Id);
        }
        
        if(setOfFloorIds != null && setOfFloorIds.size() > 0){
            for(CommonObject__c comOBj : (List<CommonObject__c>)Utility.doClone(setOfFloorIds, 'CommonObject__c', false))
            {
                comOBj.PC_Record_Id__c = comOBj.Id;
                if(AcPropInsertedMap.containsKey(comOBj.Property__c))
                    comOBj.Property__c = AcPropInsertedMap.get(comOBj.Property__c);
                if(FloorPropMap.containsKey(comOBj.Id))
                {    comOBj.Id = FloorPropMap.get(comOBj.Id);
                 listOfFloor.add(comOBj.clone(true, false, false, false));}
                else
                    listOfFloor.add(comOBj.clone(false, false, false, false));  
                
            }
        }
        System.debug('listOfFloor ### '+listOfFloor);
        
        if(listOfFloor != null && listOfFloor.size() > 0)
            upsert listOfFloor;         
        
        //Capability Record Clone//
        List<Capability__c> listOfCapability = new List<Capability__c>();
        Set<String> setOfCaPIds = new Set<String>();
        Map<String,String> AcCapMap = new Map<String,String>();
        String AC_CAP_REOCRD_TYPE = Utility.AC_CAPABILITY_RECORD_TYPE_ID;
        Set<String> loanApplicantId = new Map<String,SObject>([SELECT Id FROM Loan_Applicant__c  WHERE Application__c =: appId]).keySet();
        if(loanApplicantId != null && loanApplicantId.size() > 0){
            for(Capability__c objPro : [SELECT Id,RecordTypeId,PC_Record_Id__c FROM Capability__c WHERE Loan_Applicant__c IN: loanApplicantId AND (RecordTypeId =: Utility.PC_CAPABILITY_RECORD_TYPE_ID OR RecordTypeId =: AC_CAP_REOCRD_TYPE)]){
                if(objPro.RecordTypeId == Utility.PC_CAPABILITY_RECORD_TYPE_ID)
                    setOfCaPIds.add(objPro.Id);   
                if(objPro.RecordTypeId == AC_CAP_REOCRD_TYPE && objPro.PC_Record_Id__c != null)
                    AcCapMap.put(objPro.PC_Record_Id__c,objPro.Id);
            }
            if(setOfCaPIds != null && setOfCaPIds.size() > 0){
                for(Capability__c objCap : (List<Capability__c>)Utility.doClone(setOfCaPIds, 'Capability__c', true)){
                    objCap.PC_Record_Id__c = objCap.Id;
                    objCap.RecordTypeId = AC_CAP_REOCRD_TYPE; 
                    objCap.Verification__c = verfId;
                    if(AcCapMap.containsKey(objCap.Id))
                    {   objCap.Id = AcCapMap.get(objCap.Id);
                     listOfCapability.add(objCap.clone(true, false, false, false));}
                    else{ listOfCapability.add(objCap.clone(false, false, false, false));}                        
                }    
            }
            System.debug('listOfCapability ### '+listOfCapability);
            for(Capability__c c:listOfCapability )
            {
                System.debug('AC Cap Obj ###'+c.Id);
            }
            if(listOfCapability != null && listOfCapability.size() > 0)
                upsert listOfCapability;
        }
        
    }
    
    // This method is used to clone the Floor Details
    @AuraEnabled
    public static String cloneFloorDetails(String appId, String propertyIdtobeclone, String propertyIdforclone)
    {
        system.debug('appId >>'+appId+'<< propertyIdtobeclone >>'+propertyIdtobeclone+'<< propertyIdforclone >>'+propertyIdforclone);
        Decimal totalFloorArea ,avgFloorValue,totalFloorValue;
        Boolean iscloned = true;
        List<Property__c> propertyList = new List<Property__c>();
        List<CommonObject__c> floorList = new List<CommonObject__c>();
        for(Property__c proObj:[SELECT Id,Total_Floor_Area__c,Avg_Floor_Value_Per_Sq_Ft__c,Total_Floor_Value__c,IsCloned__c,(SELECT         Id,Building_Floor__c,Length_ft__c,Width_ft__c,Object_Type__c,Application__c,
                                                                                                                             Value_per_Sq_ft__c FROM Enquiries__r WHERE Object_Type__c='Building Floors') FROM Property__c WHERE Id =: propertyIdtobeclone AND IsCloned__c=false])
        {
            iscloned = proObj.IsCloned__c;
            totalFloorArea = proObj.Total_Floor_Area__c;
            avgFloorValue = proObj.Avg_Floor_Value_Per_Sq_Ft__c;
            totalFloorValue = proObj.Total_Floor_Value__c;
            system.debug('prop Id'+proObj);
            system.debug('size %%%'+proObj.Enquiries__r.size());
            if(!proObj.Enquiries__r.isEmpty() && proObj.Enquiries__r.size()>0)
            {
                for(CommonObject__c comObj:proObj.Enquiries__r) {   
                    CommonObject__c newRec = comObj.clone(false, false, false, false);
                    newRec.Application__c = appId;
                    newRec.Property__c = propertyIdforclone;
                    floorList.add(newRec);
                }      
            }            
        }
        
        if(!iscloned)
        {
            List<Property__c> properties= new List<Property__c>();
            Property__c oldpropObj = new Property__c();
            oldpropObj.Id = propertyIdtobeclone;
            oldpropObj.IsCloned__c = true;
            properties.add(oldpropObj);
            
            Property__c  newpropObj = new Property__c();
            newpropObj.Id = propertyIdforclone;
            newpropObj.Total_Floor_Area__c = totalFloorArea;
            newpropObj.Avg_Floor_Value_Per_Sq_Ft__c = avgFloorValue;
            newpropObj.Total_Floor_Value__c = totalFloorValue;
            properties.add(newpropObj);
            update properties;
        }
        
        system.debug('floor list'+floorList);
        if(!floorList.isEmpty()  && floorList.size() > 0) {
            insert floorList;
            return 'success';            
        }        
        return null;                      
    }    
    
    
    // This method is used to Finish the PC/AC stage
    @AuraEnabled
    public static void handleFinish(String appId,String stage,String verfId,String DecisionValue)
    {
        
        // get the AC User from Application
        Application__c appObj = [SELECT Id,Name,AC_User__c,Sanction_Amount_Restriction__c,Sanction_amount_restriction_upto__c,Total_Amount_Recommended_PcAc__c,Recommended_AC_User__c  FROM Application__c WHERE Id =:appId LIMIT 1];
        if(stage == 'PC'){           
            Verification__c pcverObj = new Verification__c();
            pcverObj.Id = verfId;
            pcverObj.Application__c = appId;
            pcverObj.Status__c ='Completed';
            update pcverObj;        
            
            
            // Fee Creation on PC Submission
            FeeCreationComponentHelper.createFeeCreationRecords(appId, 'PC Completion',null);
            
            List<Verification__c> verObjList=[SELECT ID,OwnerId FROM Verification__c WHERE RecordType.Name = 'AC' AND Application__c =:appId ORDER BY CreatedDate LIMIT 1];
            if(verObjList != null && verObjList.size()>0)            
            {   clonedPCRecordToAC(appId,verObjList[0].Id);
             
             Verification__c oldverObj = new Verification__c();
             oldverObj.Id = verObjList[0].Id; 
             oldverObj.OwnerId = (appObj.AC_User__c != null ? appObj.AC_User__c:( appObj.Recommended_AC_User__c != null ? appObj.Recommended_AC_User__c : verObjList[0].OwnerId));
             Update oldverObj;
             
             // Update Existing Application Owner to AC User
             Application__c newAppObj = new Application__c();
             newAppObj.Id = appId;
             newAppObj.OwnerId = (appObj.AC_User__c != null ? appObj.AC_User__c:( appObj.Recommended_AC_User__c != null ? appObj.Recommended_AC_User__c : verObjList[0].OwnerId));
             Update newAppObj;
             
             // Update End Date and Status on Application User Tracking Record for PC stage
             List<Application_User_Tracking__c> autList = new List<Application_User_Tracking__c>([SELECT Id,Status__c,End_Date__c FROM  Application_User_Tracking__c WHERE Application__C=:appId AND Stage__c='Process Credit' ORDER BY CREATEDDATE DESC LIMIT 1]);
             if(autList.size()>0)
             {
                 Application_User_Tracking__c autObj = new Application_User_Tracking__c();
                 autObj.Id =autList[0].Id; 
                 autObj.Status__c = 'Completed';
                 autObj.End_Date__c = System.now();
                 Update autObj;
             }
             
             // Create New Application User Tracking Record For PC -> AC Stage Movement
             Application_User_Tracking__c autObj = new Application_User_Tracking__c();
             autObj.Application__c =appId; 
             autObj.Previous_Stage__c = 'Process Credit';
             autObj.Stage__c = 'Approval Credit';
             autObj.Owner__c=(appObj.AC_User__c != null ? appObj.AC_User__c:( appObj.Recommended_AC_User__c != null ? appObj.Recommended_AC_User__c : verObjList[0].OwnerId));
             autObj.Status__c = 'Pending';
             autObj.Start_Date__c = System.Now();
             insert autObj;
            }
            if(verObjList.isEmpty())
            {              
                Verification__c verObj = new Verification__c();
                verObj.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('AC').getRecordTypeId();
                verObj.Application__c = appId;
                if(appObj.Recommended_AC_User__c != null)
                    verObj.OwnerId = appObj.Recommended_AC_User__c;
                insert verObj;
                
                // Update Existing Application Owner to AC User
                Application__c newAppObj = new Application__c();
                newAppObj.Id = appId;
                if(appObj.Recommended_AC_User__c != null)
                    newAppObj.OwnerId = appObj.Recommended_AC_User__c;
                Update newAppObj;
                
                // Update End Date and Status on Application User Tracking Record for PC stage
                List<Application_User_Tracking__c> autList = new List<Application_User_Tracking__c>([SELECT Id,Status__c,End_Date__c FROM  Application_User_Tracking__c WHERE Application__C=:appId AND Stage__c='Process Credit' ORDER BY CREATEDDATE DESC LIMIT 1]);
                if(autList.size()>0)
                {
                    Application_User_Tracking__c autObj = new Application_User_Tracking__c();
                    autObj.Id =autList[0].Id; 
                    autObj.Status__c = 'Completed';
                    autObj.End_Date__c = System.now();
                    Update autObj;
                }
                
                // Create New Application User Tracking Record For PC -> AC Stage Movement
                Application_User_Tracking__c autObj = new Application_User_Tracking__c();
                autObj.Application__c =appId; 
                autObj.Previous_Stage__c = 'Process Credit';
                autObj.Stage__c = 'Approval Credit';
                if(appObj.Recommended_AC_User__c != null)
                    autObj.Owner__c=appObj.Recommended_AC_User__c;
                autObj.Status__c = 'Pending';
                autObj.Start_Date__c = System.Now();
                insert autObj;      
                
                
                String recTypeName = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosById().get(verObj.RecordTypeId).getName();                  
                // send notification and create Task
                //Utility.createTask(UserInfo.getName()+' has assigned you a task',null,verObj.id,verObj.OwnerId,null,'Approval Credit Case has been assigned to you',true);   
                if(appObj.AC_User__c != null)               
                    Utility.sendNotification(UserInfo.getName()+' has assigned you a task',appObj.Name +' :: '+ recTypeName ,verObj.id,'Verification_Notification',verObj.OwnerId);
                clonedPCRecordToAC(appId,verObj.Id);
            } 
        }
        else if(stage == 'AC')
        {
            if(appObj.Sanction_Amount_Restriction__c == 'No'){
                appObj.Sanction_amount_restriction_upto__c = appObj.Total_Amount_Recommended_PcAc__c;
            }
            update appObj;

            if(DecisionValue == 'Approve')
            {Verification__c acverObj = new Verification__c();
             acverObj.Id = verfId;
             acverObj.Application__c = appId;            
             acverObj.Status__c ='Completed';
             update acverObj;}
            
            else if(DecisionValue == 'Recommend to Another AC')
            {
                Verification__c newacverObj = new Verification__c();
                newacverObj.Id = verfId;
                if(appObj.AC_User__c != null)
                    newacverObj.OwnerId = appObj.AC_User__c;
                update newacverObj;
                
                // Update Existing Application Owner to AC User
                Application__c newAppObj = new Application__c();
                newAppObj.Id = appId;
                if(appObj.AC_User__c != null)
                    newAppObj.OwnerId = appObj.AC_User__c;
                Update newAppObj;
                
                // Update End Date and Status on Application User Tracking Record for AC stage
                List<Application_User_Tracking__c> autList = new List<Application_User_Tracking__c>([SELECT Id,Status__c,End_Date__c FROM  Application_User_Tracking__c WHERE Application__C=:appId AND Stage__c='Approval Credit' ORDER BY CREATEDDATE DESC LIMIT 1]);
                if(autList.size()>0)
                {
                    Application_User_Tracking__c autObj = new Application_User_Tracking__c();
                    autObj.Id =autList[0].Id; 
                    autObj.Status__c = 'Completed';
                    autObj.End_Date__c = System.now(); 
                    Update autObj;
                }
                
                // Create New Application User Tracking Record For PC -> AC Stage Movement
                Application_User_Tracking__c autObj = new Application_User_Tracking__c();
                autObj.Application__c =appId; 
                autObj.Previous_Stage__c = 'Approval Credit';
                autObj.Stage__c = 'Approval Credit';
                if(appObj.AC_User__c != null)
                    autObj.Owner__c=appObj.AC_User__c;
                autObj.Status__c = 'Recommended';
                autObj.Start_Date__c = System.Now();
                insert autObj;
                
                String recTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('AC').getRecordTypeId();
                String recTypeName = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosById().get(recTypeId).getName();                 
                // send notification and create Task
                //Utility.createTask(UserInfo.getName()+' has assigned you a task',null,newacverObj.id,newacverObj.OwnerId,null,'Approval Credit Case has been recommended to you',true);   
                if(appObj.AC_User__c != null)               
                    Utility.sendNotification(UserInfo.getName()+' has assigned you a task',appObj.Name +' :: '+ recTypeName ,newacverObj.id,'Verification_Notification',newacverObj.OwnerId);
            }
            
        }     }  
    
    
 
    // This method is used to get the Bureau document for the loan Applicant Id
    @AuraEnabled
    public static String getBureauDocument(String loanApplicantId)
    {
        System.debug('loan Applicant Id>>'+loanApplicantId);
        Id contentId;
        List<ContentVersion> cvIds= [SELECT Loan_Applicant__c,isBureauReport__c,ContentDocumentId FROM ContentVersion WHERE  Loan_Applicant__c =:loanApplicantId AND isBureauReport__c =true ORDER BY CreatedDate LIMIT 1];
        if(cvIds.size()>0)
            contentId = cvIds[0].ContentDocumentId;
        if(contentId!= null)
        {   
            System.debug('contentdocument Id'+contentId);
            return contentId;
        }    
        else 
        {
            System.debug('false');
            return 'false';
        }        
    }
    
    // This method is used to update the fields at the Insurance Detail Object
    @AuraEnabled
    public static void setInsuranceFields(String applicationId)
    {
        Insurance_details__c iObj = new Insurance_details__c();
        for(Insurance_details__c InsuranceObj : [Select id,Insurance_Requirement__c, Insurance_Medical_Test_Result__c,Application__r.Insurance_Requirement__c,Application__r.Insurance_Medical_Test_Result__c from Insurance_details__c WHERE  Application__c=:applicationId ORDER BY CreatedDate DESC])
        {
            iObj.Id = InsuranceObj.Id;
            iObj.Insurance_Requirement__c = (InsuranceObj.Application__r.Insurance_Requirement__c != null ? InsuranceObj.Application__r.Insurance_Requirement__c : InsuranceObj.Insurance_Requirement__c);
             
        }
        
        if(String.isNotBlank(iObj.Id) && String.isNotEmpty(iObj.Id))
            Update iObj;       
        
    }
    
    
    // This Method is used to fetch the records for Character DataTable
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCharacterTabRecords(String appId, String metadataName ,String sectionName,string recType){
        Set<String> loanApplicantIds = new Set<String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: appId]){
            loanApplicantIds.add(loanApplicant.Id);
        }
        String rcId;
        system.debug('verfId'+appId);
        if(recType=='PC')
            rcId = Schema.getGlobalDescribe().get('Character__c').getDescribe().getRecordTypeInfosByName().get('PC Character').getRecordTypeId();
        else if(recType=='AC')
            rcId = Schema.getGlobalDescribe().get('Character__c').getDescribe().getRecordTypeInfosByName().get('AC Character').getRecordTypeId();   
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = metadataName;
        genericDTObj.IDS_SET = loanApplicantIds;
        genericDTObj.IDS_SET.add(rcId);
        genericDTObj.IDS_SET.add(sectionName);
        genericDTObj.IDS_SET.add(appId);
        genericDTObj.WHERE_CLAUSE = 'Application__c IN :IDS_SET AND RecordTypeId IN : IDS_SET AND Section_Type__c IN : IDS_SET';
        return genericDTObj.getTable();
    }
    
    // This Method is used to fetch the records for Property DataTable
    @AuraEnabled
    public static List<Property__c> getCollateralSummary(String applicationId,String recTypeName){
        String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        List<Property__c> propertyList = new List<Property__c>();
        propertyList = [SELECT Id, Property__r.Name, Land_Area_Sq_Ft__c, Valuation_Market_Value_Per_SqFt__c,Building_Value__c,Total_Collateral_Value_PcAc__c,
                        Building_Area_Sq_Ft__c,Building_Value_per_Sq_ft__c,Final_Land_Value__c,Total_Floor_Area__c,Avg_Floor_Value_Per_Sq_Ft__c,Total_Floor_Value__c,
                        (SELECT Id FROM Enquiries__r WHERE Object_Type__c='Building Floors')
                        FROM Property__c
                        WHERE Application__c =: applicationId
                        AND RecordTypeId =: rcId AND Property__c != null];
        for(Property__c pro : propertyList){
            if(pro.Enquiries__r != NULL && pro.Enquiries__r.size() > 1){
                pro.Avg_Floor_Value_Per_Sq_Ft__c = null;
            }
        }       
        return propertyList;
    }
    
    // This Method is used to Calculate the Total Building Value
    @AuraEnabled
    public static Decimal GetBuildingTotalValue(String appId,String recordTypeName)
    {
        system.debug('appId'+appId);
        Decimal totalValue=0;
        for(Property__c pObj:[SELECT ID,Total_Floor_Value__c  FROM Property__c WHERE Application__c =:appId AND RecordType.Name =:recordTypeName])
        {
            system.debug('property total buidling value'+pObj.Total_Floor_Value__c);
            if(pObj.Total_Floor_Value__c!=null)
                totalValue+=pObj.Total_Floor_Value__c;
        }
        system.debug('total value'+totalValue);
        return totalValue;
    }
    
    // This method is used in Compare docs component of Carousal View for fetching the Documents for Comparision
    @AuraEnabled
    public static List<ContentVersion> getDocumentPublicList(String appId){
        //system.debug('applicantId ###'+applicantId+' propertyId ##'+propertyId);
        List<ContentVersion> imgList = new List<ContentVersion>();
        String docQuery= 'SELECT Id, Uploaded_From__c,ContentDocumentId, Title, File_Type__c, FileExtension, ContentSize, Type__c FROM ContentVersion WHERE Parent_Id__c =:appId';
        imgList = Database.query(docQuery);
        system.debug('imgList ##'+imgList);
        return imgList;
    }
    
    // this method is used to fetch the recordTypeId
    @AuraEnabled(cacheable=true)
    public static  Id getRecordTypeId(String objName,String recordTypeName)
    {
        return Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
    }
    
    // This method is used to compare the Property Land Area And Value Field Values of FIV-B and FIV-C
    @AuraEnabled(cacheable=true)
    public static String  ComparePropertyValues(String parentPropertyId)
    {   
        Map<String,Property__c> proMap=new Map<String,Property__c>();
        for(Property__c proObj:[SELECT Id,Property__c,RecordTYpe.Name,Land_Area_Sq_Ft__c,Land_Measurement_total_area__c,Valuation_Market_Value_Per_SqFt__c,Value_per_sq_ft__c FROM Property__c WHERE Property__c=:parentPropertyId AND RecordTYpe.Name IN('FIV-B Property Detail','FIV-C Property Detail')])
        {
            proMap.put(proObj.RecordTYpe.Name,proObj);
        }
        system.debug('promap>>>>'+proMap);
        LandValueWrapper wrapObj= new LandValueWrapper();
        if(proMap.containsKey('FIV-B Property Detail') && proMap.containsKey('FIV-B Property Detail'))
        { 
            if(proMap.get('FIV-B Property Detail').Land_Area_Sq_Ft__c != null && proMap.get('FIV-C Property Detail').Land_Measurement_total_area__c != null)            
                wrapObj.Land_Area = (Math.min(proMap.get('FIV-B Property Detail').Land_Area_Sq_Ft__c,proMap.get('FIV-C Property Detail').Land_Measurement_total_area__c )).round() ; 
            if(proMap.get('FIV-B Property Detail').Value_per_sq_ft__c != null && proMap.get('FIV-C Property Detail').Valuation_Market_Value_Per_SqFt__c != null)            
                wrapObj.Market_Value = (Math.min(proMap.get('FIV-B Property Detail').Value_per_sq_ft__c, proMap.get('FIV-C Property Detail').Valuation_Market_Value_Per_SqFt__c)).round();
            if(wrapObj.Land_Area != null && wrapObj.Market_Value != null) 
                wrapObj.FinalLandValue = wrapObj.Land_Area * wrapObj.Market_Value;
        }
        system.debug('promapWRapper>>>>'+wrapObj);
        return JSON.serialize(wrapObj);
    }
    
    @AuraEnabled 
    public static List<String> checkPCACMobileValidation(String verfId,String appId){
        List<String> validationList = new List<String>();
        String label = System.Label.Mobile_Verification_Mandatory;
        if (label.equalsignorecase('YES')){
            List<Verification__c> verficationList = [SELECT Id, RecordType.Name FROM Verification__c WHERE Id =: verfId];
            if(verficationList != NULL && !verficationList.isEmpty() && verficationList.get(0).RecordType.Name == 'AC'){
                getACCapabilitySummary(appId);
                List<Loan_Applicant__c> loanApplicant = [SELECT id, Mobile_Verified__c, Customer_Information__r.Name, Gross_Income_AC__c FROM Loan_Applicant__c WHERE Application__c =:appId ORDER BY Gross_Income_AC__c DESC LIMIT 1];
                if(loanApplicant != NULL && !loanApplicant.isEmpty() && loanApplicant.get(0).Mobile_Verified__c != true){
                    validationList.add(loanApplicant.get(0).Customer_Information__r.Name);
                }
            } else if(verficationList != NULL && !verficationList.isEmpty() && verficationList.get(0).RecordType.Name == 'PC'){
                getCapabilitySummary(appId);
                List<Loan_Applicant__c> loanApplicant = [SELECT id, Mobile_Verified__c, Customer_Information__r.Name, Gross_Income_PC__c FROM Loan_Applicant__c WHERE Application__c =:appId ORDER BY Gross_Income_PC__c DESC LIMIT 1];
                if(loanApplicant != NULL && !loanApplicant.isEmpty() && loanApplicant.get(0).Mobile_Verified__c != true){
                    validationList.add(loanApplicant.get(0).Customer_Information__r.Name);
                }
            }
        }
        return validationList;
    }
    
    // method used to check all the Validations on Submit Button
    @AuraEnabled 
    public static PCValidationWrapper checkPCValidation(String verfId,String appId)
    {
        Boolean GuarantorExist = false;
        PCValidationWrapper validationWrapObj = new PCValidationWrapper();
        characterValidationWrapper charWrapObj = new characterValidationWrapper();
        Set<String> loanapps = new Set<String>();
        Set<String> charLoanApps = new Set<String>();
        
        
         List<Loan_Applicant__c> loanObjList = [SELECT Id,Customer_Type__c ,Customer_Information__r.Name,Is_Bureau_Verified__c,Applicant_Name__c,Is_Lead_Detail_Done__c, Created_From__c,Mobile_Verified__c,Is_KYC_Verified__c,IsDedupeExecuted__c,isKYCorDOBorNameChanged__c,LMS_Customer_Info_File_Number__c,(SELECT Id FROM Dedupe_Details__r) FROM Loan_Applicant__c WHERE  Application__c=:appId];
        system.debug('loan apps'+loanObjList);
        if(loanObjList.size()>0)
        {    for(Loan_Applicant__c laObj:loanObjList)
        {
            if(laObj.Created_From__c == 'Process Credit')
            { 
                validationWrapObj.isLoanApplicantAdded = true;
                if(!laObj.Is_Lead_Detail_Done__c)
                    validationWrapObj.pendingLeadDetailList.add(laObj.Applicant_Name__c);
            }
            if(!laObj.Is_Bureau_Verified__c)
            {
                validationWrapObj.bureauList.add(laObj.Applicant_Name__c);
            }
            /*if(laObj.Mobile_Verified__c == false)
            {
                validationWrapObj.mobileverificationList.add(laObj.Customer_Information__r.Name);
            }*/
            if(laObj.Is_KYC_Verified__c == false)
            {
                validationWrapObj.kycVerificationList.add(laObj.Customer_Information__r.Name);
            }
            if(laObj.Customer_Type__c == 'Guarantor')
            {
                GuarantorExist = true;
            }
            if(laObj.isKYCorDOBorNameChanged__c && laObj.Dedupe_Details__r.size() == 0 && laObj.IsDedupeExecuted__c && laObj.LMS_Customer_Info_File_Number__c == null)
            {
                system.debug('inside isKYCorNameorDOBChanged 1');
                validationWrapObj.isKYCorNameorDOBChanged = true;
            }
            else if(laObj.Dedupe_Details__r.size() == 0 && laObj.IsDedupeExecuted__c && laObj.LMS_Customer_Info_File_Number__c == null)
            {
                system.debug('inside isKYCorNameorDOBChanged 2');
                validationWrapObj.isKYCorNameorDOBChanged = true;
            }
               loanapps.add(laObj.Id);
        } 
        }
        
        for(Verification__c verObj :[SELECT ID,(SELECT ID,Section_Type__c,Loan_Applicant__c FROM Characters__r WHERE RecordType.Name='PC Character' AND Verification__c =:verfId AND Section_Type__c IN ('Family Detail',
                                                                                                                                                                                       'Neighbour Detail','Affiliation Detail','Living Standard Detail')) FROM Verification__c WHERE Id=:verfId AND Application__c =:appId])
        {
            for( Character__c charObj: verObj.Characters__r)
            { if(charObj.Section_Type__c == 'Family Detail')
            {  charWrapObj.familyDetail = false;
              if(String.isNotBlank(charObj.Loan_Applicant__c) && String.isNotEmpty(charObj.Loan_Applicant__c))
                 charLoanApps.add(charObj.Loan_Applicant__c);
            }
              else if(charObj.Section_Type__c == 'Neighbour Detail')
                 charWrapObj.NeighbourDetail = false;
             else if(charObj.Section_Type__c == 'Affiliation Detail')
                 charWrapObj.AffiliationDetail = false;
             else if(charObj.Section_Type__c == 'Living Standard Detail')
                 charWrapObj.LivingStandardDetail = false;
            }
        }
        
        if(!charLoanApps.isEmpty() && !loanapps.isEmpty())
        {
           if(charLoanApps.size() == loanapps.size())
            charWrapObj.NeighbourDetail = false;
         }
        
        collateralValidationWrapper colWrapObj = new collateralValidationWrapper();
        for(Property__c proObj:[SELECT Id,  Title_Deed_Number__c,Document_Type__c,Pathway_Available__c ,Mortgage_Property_Area__c,isPrimaryOwner__c,Property_Type__c,
                                Building_Age__c,Building_Type__c,RecordType.Name,Created_From__c FROM Property__c WHERE Application__c =:appId AND RecordType.Name IN ('PC Property Detail','Pre Login Property Detail')])
        {
            if(proObj.RecordType.Name == 'PC Property Detail')
            {
                if(proObj.Title_Deed_Number__c!= null&& proObj.Document_Type__c !=null)
                    colWrapObj.PropertyDetails = false;
                if(proObj.Pathway_Available__c!=null && proObj.Mortgage_Property_Area__c !=null)
                    colWrapObj.LandArea = false;
                if(proObj.Property_Type__c == 'Vacant Land')
                {
                    colWrapObj.BuildingValuation = false;
                }
                else
                {
                    if(proObj.Building_Age__c!=null && proObj.Building_Type__c !=null)
                        colWrapObj.BuildingValuation = false;
                }
            }
            else if(proObj.RecordType.Name == 'Pre Login Property Detail' && proObj.Created_From__c == 'Process Credit')
            {
                validationWrapObj.isPropertyAdded = true;
            }
            else if(proObj.RecordType.Name == 'Pre Login Property Detail' && proObj.isPrimaryOwner__c)
            {
                validationWrapObj.isPrimaryOwner = true;
            }
        }
        
       
        
        List<Capability__c> capList=[SELECT Id FROM Capability__c WHERE Verification__c=:verfId AND RecordType.Name ='PC Capability'];
        if(capList.size()>0)
            validationWrapObj.capabilityValidation = true;
        
        for( Verification__c verObj : [SELECT Id,Initiate_From__c,Status__c,RecordType.Name,Application__r.PC_Decision__c FROM Verification__c WHERE RecordType.Name IN ('FIV - C','FIV - B','Online EC')  AND Application__c=:appId])
        {
            if(verObj.Initiate_From__c =='Process Credit')
            {
                if(verObj.RecordType.Name == 'FIV - C')
                {  validationWrapObj.isfivcInitiated = true;}
                if(verObj.RecordType.Name == 'FIV - C' && verObj.Status__c == 'Completed')
                {  validationWrapObj.isfivcCompleted = true;  }
                if(verObj.RecordType.Name == 'FIV - B')
                {  validationWrapObj.isfivbInitiated = true;}
                if(verObj.RecordType.Name == 'FIV - B' && verObj.Status__c == 'Completed')
                {  validationWrapObj.isfivbCompleted = true;  }
                if(verObj.RecordType.Name == 'Online EC')
                {  validationWrapObj.isonlineECinitiated = true;}
                if(verObj.RecordType.Name == 'Online EC' && verObj.Status__c == 'Completed')
                {  validationWrapObj.isonlineECCompleted = true;  }
            }
        }
        
        financialValidationWrapper finWrapObj =new financialValidationWrapper(); 
        for( Application__c appObj:[SELECT Id, Loan_Purpose_2__c , Verified_UN_sanctions_list_and_no_match__c, Balance_Transfer__c,Balance_Transfer_Amount__c,Total_Net_income_for_Tranche_2__c,   Final_Collateral_value_for_Tranche_2__c,Guarantor_Networth_Choosen__c,Group_Total_Exposure_PcAc__c,Transaction_LTV__c,DBR_PC__c,Transaction_DBR__c,Combined_LTV__c,
                                    Name__c,Nominee__c,Nach_Party__c,Amount_Recommended__c, Total_Net_Income__c,KYC_Risk_Rating__c,Discussion_done_with__c,Comment_Remarks__c,Requested_Loan_Amount__c,Total_Amount_Recommended_PcAc__c FROM Application__c WHERE Id =:appId])
        {
            if(appObj.Loan_Purpose_2__c !=null)
                finWrapObj.ApplicationDetail = false;
            if(appObj.Balance_Transfer__c !=null )
                finWrapObj.LoanDetail = false;
            if(appObj.Total_Net_income_for_Tranche_2__c !=null && appObj.Final_Collateral_value_for_Tranche_2__c !=null)
                finWrapObj.TrancheDetail = false;
            if(appObj.Name__c !=null && appObj.Nominee__c !=null)
                finWrapObj.InsuranceDetail = false;
            if(appObj.Nach_Party__c !=null )
                finWrapObj.DisbursementDetail = false;
            if(appObj.Amount_Recommended__c !=null )
                finWrapObj.LoanAmtDetail = false;
            if(appObj.Total_Net_Income__c !=null )
                finWrapObj.EligibilityDetail = false;
            if(appObj.KYC_Risk_Rating__c !=null )
                finWrapObj.RiskDetail = false;
            if(appObj.Discussion_done_with__c !=null )
                finWrapObj.OtherDetail = false;
            if(appObj.Comment_Remarks__c !=null )
                finWrapObj.ExecutiveDetail = false;
            if(appObj.Verified_UN_sanctions_list_and_no_match__c)
                finWrapObj.isVerifiedFalse = false;
            if(appObj.Group_Total_Exposure_PcAc__c > 5000000 && GuarantorExist && appObj.Guarantor_Networth_Choosen__c == null )
                validationWrapObj.isGaurantorNetworthMissing = true; 
            if(appObj.Requested_Loan_Amount__c < appObj.Total_Amount_Recommended_PcAc__c)
                validationWrapObj.isLoanAmountNotValid = true; 
            if(appObj.Transaction_LTV__c > 80)
                validationWrapObj.paramList.add('Transaction LTV');
            if(appObj.Transaction_DBR__c > 80)
                validationWrapObj.paramList.add('Transaction DBR');
            if(appObj.Combined_LTV__c > 80)
                validationWrapObj.paramList.add('Combined LTV');
            if(appObj.DBR_PC__c > 80)
                validationWrapObj.paramList.add('Combined DBR');
        }
        
        validationWrapObj.charWrap = charWrapObj;
        validationWrapObj.colWrap = colWrapObj;
        validationWrapObj.finWrap = finWrapObj;
        return  validationWrapObj;
        
    }
    
    // method used to check all the Validations on Submit Button for Approval Credit
    @AuraEnabled 
    public static ACValidationWrapper checkACValidation(String verfId,String appId)
    {
        Boolean GuarantorExist = false;
        ACValidationWrapper validationWrapObj = new ACValidationWrapper();
        characterValidationWrapper charWrapObj = new characterValidationWrapper();
        Set<String> loanapps = new Set<String>();
        Set<String> charLoanApps = new Set<String>();
        

         List<Loan_Applicant__c> loanObjList = [SELECT Id ,Customer_Type__c,Customer_Information__r.Name,Is_Bureau_Verified__c,Applicant_Name__c,Is_Lead_Detail_Done__c, Created_From__c,Mobile_Verified__c,Is_KYC_Verified__c,isKYCorDOBorNameChanged__c,IsDedupeExecuted__c,LMS_Customer_Info_File_Number__c,(SELECT Id FROM Dedupe_Details__r) FROM Loan_Applicant__c WHERE  Application__c=:appId];
        if(loanObjList.size()>0)
        {    for(Loan_Applicant__c laObj:loanObjList)
        {
            if(laObj.Created_From__c == 'Approval Credit')
            { 
                validationWrapObj.isLoanApplicantAdded = true;
                if(!laObj.Is_Lead_Detail_Done__c)
                    validationWrapObj.pendingLeadDetailList.add(laObj.Applicant_Name__c);                
            }
            if(!laObj.Is_Bureau_Verified__c)
            {
                validationWrapObj.bureauList.add(laObj.Applicant_Name__c);
            }
            /*if(laObj.Mobile_Verified__c == false)
            {
                validationWrapObj.mobileverificationList.add(laObj.Customer_Information__r.Name);
            }*/
            if(laObj.Is_KYC_Verified__c == false)
            {
                validationWrapObj.kycVerificationList.add(laObj.Customer_Information__r.Name);
            }
            if(laObj.Customer_Type__c == 'Guarantor')
            {
                GuarantorExist = true;
            }
            if(laObj.isKYCorDOBorNameChanged__c && laObj.Dedupe_Details__r.size() == 0 && laObj.IsDedupeExecuted__c && laObj.LMS_Customer_Info_File_Number__c == null)
            {
                validationWrapObj.isKYCorNameorDOBChanged = true;
            }
            else if(laObj.Dedupe_Details__r.size() == 0 && laObj.IsDedupeExecuted__c && laObj.LMS_Customer_Info_File_Number__c == null)
            {
                validationWrapObj.isKYCorNameorDOBChanged = true;
            }
               loanapps.add(laObj.Id);
        } 
        }
        
        for(Verification__c verObj :[SELECT ID,(SELECT ID,Loan_Applicant__c,Section_Type__c FROM Characters__r WHERE RecordType.Name='AC Character' AND Verification__c =:verfId AND Section_Type__c IN ('Family Detail',
                                                                                                                                                                                       'Neighbour Detail','Affiliation Detail','Living Standard Detail')) FROM Verification__c WHERE Id=:verfId AND Application__c =:appId])
        {
            for( Character__c charObj: verObj.Characters__r)
            { if(charObj.Section_Type__c == 'Family Detail')
                charWrapObj.familyDetail = false;
           else if(charObj.Section_Type__c == 'Neighbour Detail')
             {  
                 charWrapObj.NeighbourDetail = false;
                 if(String.isNotBlank(charObj.Loan_Applicant__c) && String.isNotEmpty(charObj.Loan_Applicant__c))
                 charLoanApps.add(charObj.Loan_Applicant__c);
             }
             else if(charObj.Section_Type__c == 'Affiliation Detail')
                 charWrapObj.AffiliationDetail = false;
             else if(charObj.Section_Type__c == 'Living Standard Detail')
                 charWrapObj.LivingStandardDetail = false;
            }
        }
        
        if(!charLoanApps.isEmpty() && !loanapps.isEmpty())
        {
           if(charLoanApps.size() == loanapps.size())
            charWrapObj.NeighbourDetail = false;
         }
        
        collateralValidationWrapper colWrapObj = new collateralValidationWrapper();
        for(Property__c proObj:[SELECT Id,  Title_Deed_Number__c,   Document_Type__c,Pathway_Available__c ,     Mortgage_Property_Area__c,isPrimaryOwner__c,Property_Type__c,
                                Building_Age__c,Building_Type__c,RecordType.Name,Created_From__c FROM Property__c WHERE Application__c =:appId AND RecordType.Name IN ('AC Property Detail','Pre Login Property Detail') ])
        {
             if(proObj.RecordType.Name == 'AC Property Detail')
            {
                if(proObj.Title_Deed_Number__c != null && proObj.Document_Type__c != null)
                    colWrapObj.PropertyDetails = false;
                if(proObj.Pathway_Available__c != null && proObj.Mortgage_Property_Area__c != null)
                    colWrapObj.LandArea = false;
                if(proObj.Property_Type__c == 'Vacant Land')
                {
                    colWrapObj.BuildingValuation = false;
                }
                else
                {
                    if(proObj.Building_Age__c != null && proObj.Building_Type__c != null)
                    colWrapObj.BuildingValuation = false;
                }
            }
            else 
            if(proObj.RecordType.Name == 'Pre Login Property Detail' && proObj.Created_From__c == 'Approval Credit')
            {
                validationWrapObj.isPropertyAdded = true;
            }
            else if(proObj.RecordType.Name == 'Pre Login Property Detail' && proObj.isPrimaryOwner__c)
            {
                validationWrapObj.isPrimaryOwner = true;
            }
        }
        
       
        
        List<Capability__c> capList=[SELECT Id FROM Capability__c WHERE Verification__c=:verfId AND RecordType.Name ='AC Capability' ];
        if(capList.size()>0)
        validationWrapObj.capabilityValidation = true;
        
        for( Verification__c verObj : [SELECT Id,Initiate_From__c,Status__c,RecordType.Name,Application__r.AC_Decision__c FROM Verification__c WHERE RecordType.Name IN ('FIV - C','FIV - B','Online EC') AND Application__c =:appId])
        {
            if(verObj.Initiate_From__c =='Approval Credit')
            {
                if(verObj.RecordType.Name == 'FIV - C')
                {  validationWrapObj.isfivcInitiated = true;}
                if(verObj.RecordType.Name == 'FIV - C' && verObj.Status__c == 'Completed')
                {  validationWrapObj.isfivcCompleted = true;  }
                if(verObj.RecordType.Name == 'FIV - B')
                {  validationWrapObj.isfivbInitiated = true;}
                if(verObj.RecordType.Name == 'FIV - B' && verObj.Status__c == 'Completed')
                {  validationWrapObj.isfivbCompleted = true;  }
                if(verObj.RecordType.Name == 'Online EC')
                {  validationWrapObj.isonlineECinitiated = true;}
                if(verObj.RecordType.Name == 'Online EC' && verObj.Status__c == 'Completed')
                {  validationWrapObj.isonlineECCompleted = true;  }               
            }
        }
        
        List<Legal_Approval__c> laList = new List<Legal_Approval__c>([SELECT Id,Status__c FROM Legal_Approval__c WHERE Application__c =: appId  LIMIT 1]);
        if(laList!= null && laList.size()>0)
        {
            for(Legal_Approval__c loanObj: laList)
            {
                if(loanObj.Status__c == 'Pending')
                    validationWrapObj.isLegalApprovalCompleted = false;
            }
            
        }
        else
            validationWrapObj.isLegalApprovalCompleted = false;
        
        financialValidationWrapper finWrapObj =new financialValidationWrapper(); 
        for( Application__c appObj:[SELECT Id, Loan_Purpose_2__c ,Total_Amount_Recommended_PcAc__c,Verified_UN_sanctions_list_and_no_match__c,Requested_Loan_Amount__c,  Balance_Transfer__c,Balance_Transfer_Amount__c,Total_Net_income_for_Tranche_2__c,   Final_Collateral_value_for_Tranche_2__c,Guarantor_Networth_Choosen__c,Transaction_LTV__c,DBR_PC__c,Transaction_DBR__c,Combined_LTV__c,
                                    Name__c,Group_Total_Exposure_PcAc__c,Nominee__c,Nach_Party__c,Amount_Recommended__c, Total_Net_Income__c,KYC_Risk_Rating__c,Discussion_done_with__c,Comment_Remarks__c FROM Application__c WHERE Id =:appId])
        {
            if(appObj.Loan_Purpose_2__c !=null)
                finWrapObj.ApplicationDetail = false;
            if(appObj.Balance_Transfer__c !=null )
                finWrapObj.LoanDetail = false;
            if(appObj.Total_Net_income_for_Tranche_2__c !=null && appObj.Final_Collateral_value_for_Tranche_2__c !=null)
                finWrapObj.TrancheDetail = false;
            if(appObj.Name__c !=null && appObj.Nominee__c !=null)
                finWrapObj.InsuranceDetail = false;
            if(appObj.Nach_Party__c !=null )
                finWrapObj.DisbursementDetail = false;
            if(appObj.Amount_Recommended__c !=null )
                finWrapObj.LoanAmtDetail = false;
            if(appObj.Total_Net_Income__c !=null )
                finWrapObj.EligibilityDetail = false;
            if(appObj.KYC_Risk_Rating__c !=null )
                finWrapObj.RiskDetail = false;
            if(appObj.Discussion_done_with__c !=null )
                finWrapObj.OtherDetail = false;
            if(appObj.Comment_Remarks__c !=null )
                finWrapObj.ExecutiveDetail = false;
            if(appObj.Verified_UN_sanctions_list_and_no_match__c)
                finWrapObj.isVerifiedFalse = false;
            if(appObj.Group_Total_Exposure_PcAc__c > 5000000 && GuarantorExist && appObj.Guarantor_Networth_Choosen__c == null )
                validationWrapObj.isGaurantorNetworthMissing = true;
            if(appObj.Requested_Loan_Amount__c < appObj.Total_Amount_Recommended_PcAc__c)
                validationWrapObj.isLoanAmountNotValid = true; 
            if(appObj.Transaction_LTV__c > 80)
                validationWrapObj.paramList.add('Transaction LTV');
            if(appObj.Transaction_DBR__c > 80)
                validationWrapObj.paramList.add('Transaction DBR');
            if(appObj.Combined_LTV__c > 80)
                validationWrapObj.paramList.add('Combined LTV');
            if(appObj.DBR_PC__c > 80)
                validationWrapObj.paramList.add('Combined DBR');
        }
        
        validationWrapObj.charWrap = charWrapObj;
        validationWrapObj.colWrap = colWrapObj;
        validationWrapObj.finWrap = finWrapObj;
        return validationWrapObj;
        
    }
    
    
    
    // This Method is used to fetch the records 
    @AuraEnabled
    public static List<sObject> getData(String CustomerId,String ObjName)    
    {
        System.debug('ObjNAme>>>.'+ObjName);
        System.debug('customerId>>>>>>>> '+CustomerId);
        if(ObjName=='Property__c')
        {
            
            List<Property__C> PropertyList=[SELECT Id,Land_Area_Sq_Ft__c,Value_per_sq_ft__c,Month__c,Living_property_Distance_from_Branch__c,Title_Deed_Year__c,Type_Of_Property__c  FROM Property__c WHERE Property__c=:CustomerId AND RecordType.Name='PC Property Detail' ]; 
            system.debug('plist>>>'+PropertyList);
            return PropertyList;
        }
        else if(ObjName=='Verification__c')
        {
            List<Verification__c> verificationList= [SELECT Id,Application__r.Name,Application__r.Rejection_Reason__c,Application__c,Application__r.Verified_UN_sanctions_list_and_no_match__c,Application__r.PC_Remarks__c ,Application__r.Stage__c,
                                                     Application__r.Pre_Login__c,Application__r.Pre_Login__r.RecordType.Name,Application__r.Requested_Loan_Amount__c,Application__r.AC_Remarks__c ,
                                                     Application__r.Sourcing_Branch__c,Application__r.AC_User__c,Application__r.AC_User__r.Name,Application__r.AC_Decision__c,Application__r.PC_Decision__c,Application__r.Recommended_AC_User__c FROM  Verification__c WHERE Id=:CustomerId LIMIT 1];
            System.debug('Verification List>>>> '+verificationList);
            return verificationList;
        }
        else if(ObjName=='Financial')
        {
            List<Verification__c> verificationList= [SELECT Id, ROI__c,Tenor__c FROM Verification__c WHERE Application__c =:CustomerId AND RecordType.Name = 'FIV - B' LIMIT 1];
            System.debug('Verification List>>>> '+verificationList);
            return verificationList;
        }
        else if(ObjName=='Approval Credit')
        {
            List<Verification__c> verificationList= [SELECT Id,Status__c FROM Verification__c WHERE Application__c =:CustomerId AND RecordType.Name = 'PC' AND Status__c!='Completed' ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('Verification List>>>> '+verificationList);
            return verificationList;
        }
        return null;
    }
    
    // This method is used to fetch the Income Summary for the PC/AC Verification
    @AuraEnabled
    public static IncomSummary getIncomeSummary(String applicationId,String caprecordtypeName, String VerfRecordTypeName) {
        system.debug('appId'+applicationId);
        system.debug('caprecordtypeName'+caprecordtypeName);
        system.debug('VerfRecordTypeName'+VerfRecordTypeName);
        IncomSummary incomeObj = new IncomSummary();
        Set < String > loanApplicationId = new Set < String > ();
        
        for (Loan_Applicant__c loanApplicant: [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: applicationId]) {
            
            loanApplicationId.add(loanApplicant.Id);
        }
        String rcId = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get(caprecordtypeName).getRecordTypeId();
        Verification__c verificationObj = [SELECT ID FROM Verification__c WHERE Application__c =: applicationId AND RecordType.Name = :VerfRecordTypeName LIMIT 1];
        
        Set<String> bureauHighmarkIdSet = new Set<String>();
        for(Bureau_Highmark__c highmarkRecord : [SELECT Id,Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__c IN (SELECT Id FROM Loan_Applicant__c WHERE Application__c =:applicationId)]) {
            bureauHighmarkIdSet.add(highmarkRecord.Id);
        }
        String loanDetailRecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        for(Loan_details__c loanObj:[SELECT Id,Obligations__c,To_be_considerd_for_DBR__c,Stage__c FROM Loan_Details__c WHERE Bureau_Highmark__c IN:bureauHighmarkIdSet AND RecordTypeId =:loanDetailRecordTypeId ])
        {
            // if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='FIV - C'))
            //     incomeObj.allObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0); 
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='PC') && caprecordtypeName == 'PC Capability')
                incomeObj.allObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0);
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='PC' || loanObj.Stage__c =='AC') && caprecordtypeName == 'AC Capability')
                incomeObj.allObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0);
            
        }
        
        List < Capability__c > capabilities = [SELECT Id, Customer_Information__c, Segment__c, Income_segment__c,Loan_Applicant__r.Income_Considered__c,
                                               Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
                                               Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
                                               Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
                                               Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
                                               Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
                                               Electricity__c, Rent__c, Others__c, Salary__c,Income_per_month_Pension__c
                                               FROM Capability__c
                                               WHERE Application__c =: applicationId AND RecordTypeId =: rcId Order BY Loan_Applicant__r.Customer_Information__r.Name
                                              ];
        system.debug('capabilities ###'+capabilities);
        List < IncomWrapper > incomeDetails = new List < IncomWrapper > ();
        for (Capability__c cap: capabilities) {
            IncomWrapper incWrapObj = new IncomWrapper();
            incWrapObj.applicantId = cap.Loan_Applicant__c;
            incWrapObj.applicantName = cap.Loan_Applicant__r.Customer_Information__r.Name;
            incWrapObj.incomeConsidered = cap.Loan_Applicant__r.Income_Considered__c;
            Decimal monthlyIncome = 0;
            Decimal busmonthlyIncome = 0;
            Decimal monthlyIncomeConsidered = 0;
            if (cap.Income_segment__c == 'Salaried') {
                monthlyIncome = Integer.valueOf(cap.Monthly_Salary__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = Integer.valueOf(cap.Monthly_Salary__c);  
                else
                    monthlyIncomeConsidered = 0;   
            } else if (cap.Income_segment__c == 'Rental Income') {
                monthlyIncome = Integer.valueOf(cap.Rental_Income__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = Integer.valueOf(cap.Rental_Income__c); 
                else
                    monthlyIncomeConsidered = 0;   
            } else if (cap.Income_segment__c == 'Daily wages'  || cap.Income_segment__c == 'Transport business') {
                monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered =  cap.Income_per_day__c * cap.Number_of_days__c; 
                else
                    monthlyIncomeConsidered = 0;   
            } else if ( cap.Income_segment__c == 'Income from Abroad' ) {
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = Integer.valueOf(cap.Income_per_month__c); 
                else
                    monthlyIncomeConsidered = 0;   
            }
            else if(cap.Income_segment__c == 'Pension'  ){
                monthlyIncome = cap.Income_per_month_Pension__c != null ? Integer.valueOf(cap.Income_per_month_Pension__c) : 0;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
                else
                    monthlyIncomeConsidered = 0;
            }else if (cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                       cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                       cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                       cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed') {
                           if (cap.Day_Margin_Basis__c == 'Day Basis') {
                               busmonthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                               monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                               if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                   monthlyIncomeConsidered = cap.Income_per_day__c * cap.Number_of_days__c;
                               else
                                   monthlyIncomeConsidered = 0;   
                           } else if (cap.Day_Margin_Basis__c == 'Margin Basis') {
                               Decimal totalSales = Integer.valueOf(cap.Sales_per_month__c);
                               Decimal margin = cap.Margin__c != null ? cap.Margin__c : 0;
                               Decimal totalIncome = 0;
                               if (totalSales != NULL && totalSales != 0) {
                                   totalIncome = (totalSales / 100 * margin);
                               }
                               if (cap.Electricity__c != Null && cap.Electricity__c != 0) {
                                   totalIncome = totalIncome - cap.Electricity__c;
                               }
                               if (cap.Rent__c != Null && cap.Rent__c != 0) {
                                   totalIncome = totalIncome - cap.Rent__c;
                               }
                               if (cap.Others__c != Null && cap.Others__c != 0) {
                                   totalIncome = totalIncome - cap.Others__c;
                               }
                               if (cap.Salary__c != Null && cap.Salary__c != 0) {
                                   totalIncome = totalIncome - cap.Salary__c;
                               }
                               monthlyIncome = totalIncome;
                               busmonthlyIncome = totalIncome;
                               if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                   monthlyIncomeConsidered = totalIncome; 
                               else
                                   monthlyIncomeConsidered = 0;   
                           }
                       }
            
            incWrapObj.incomePerMonth = '' + monthlyIncome;
            incWrapObj.busincomePerMonth = '' + busmonthlyIncome;
            incWrapObj.monthlyIncomeConsidered = '' + monthlyIncomeConsidered;
            incomeObj.totalMonthlyIncome += monthlyIncome;
            incomeObj.totalbusMonthlyIncome += busmonthlyIncome;
            incomeObj.totalMonthlyIncomeConsidered +=(monthlyIncomeConsidered!=null?monthlyIncomeConsidered:0);                     
            incomeObj.incomeList.add(incWrapObj);
        }
        System.debug('incomeObj =' + incomeObj);
        incomeObj.netMonthlyIncome = incomeObj.totalMonthlyIncome - incomeObj.allObligations;
        incomeObj.netMonthlyIncomeBusiness = incomeObj.totalbusMonthlyIncome - incomeObj.allObligations;
        incomeObj.netMonthlyIncomeConsidered = incomeObj.totalMonthlyIncomeConsidered - incomeObj.allObligations; 
        return incomeObj;
    }
    
    
    
    // to get the property table data
    @AuraEnabled(cacheable=true)
    public static GenericDataTableController.DataTableResponse getCollateralTableRecords(String appId, String metadataName){      
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = metadataName;
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(appId);
        String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        genericDTObj.IDS_SET.add(rcId);
        genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET';
        return genericDTObj.getTable();
    }
    
    // to get the property table data
    @AuraEnabled(cacheable=true)
    public static GenericDataTableController.DataTableResponse getFloorTableRecords(String appId ,String propId, String metadataName,String calledFrom){
        Set<String> propIds = new Set<String>();
        for(Property__c prop:[SELECT Id FROM Property__c WHERE Application__c =:appId AND RecordType.Name = 'FIV-C Property Detail'])
        {
            propIds.add(prop.Id);
        }
        
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = metadataName;
        genericDTObj.IDS_SET = new Set<String>();
        if(calledFrom == 'PC')
            genericDTObj.IDS_SET.add(propId);
        else  if(calledFrom == 'AC')
            genericDTObj.IDS_SET  = propIds;
        genericDTObj.IDS_SET.add('Building Floors');
        genericDTObj.WHERE_CLAUSE = ' Property__c IN : IDS_SET AND Object_Type__c IN : IDS_SET';
        return genericDTObj.getTable();
    }      
    
    
    
    
    // to get the CapabilityTable Records 
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCapabiltyData(String appId,string recTypeName,String metadataName,String caprecordTypeName){
        Id recTypeId,caprecTypeId;
        System.debug('rectypename'+recTypeName+'cap type'+caprecordTypeName+'APP Id #'+appId);  
        if(caprecordTypeName != null)
            caprecTypeId =Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get(caprecordTypeName).getRecordTypeId();        
        GenericDataTableController genericDTObjCapabilty = new GenericDataTableController();
        genericDTObjCapabilty.METADATA_NAME = metadataName ;
        genericDTObjCapabilty.IDS_SET = new Set<String>();
        genericDTObjCapabilty.IDS_SET.add(appId);        
        genericDTObjCapabilty.IDS_SET.add(caprecTypeId); 
        genericDTObjCapabilty.WHERE_CLAUSE ='Application__c IN: IDS_SET   AND  RecordTypeId IN: IDS_SET';        
        return genericDTObjCapabilty.getTable();
    } 
    
    
    // This Method Is Used To Return Capability Summary Data
    @AuraEnabled
    public static Map<String, Decimal> getCapabilityIncomeSummary(String applicationId, String recordTypeName){
        String rcId = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();        
        List<Capability__c> capabilities = new List<Capability__c>();
        capabilities = [SELECT Id, Income_segment__c, Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
            Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
            Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
            Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
            Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
            Electricity__c, Rent__c, Others__c, Salary__c, Income_per_month_Pension__c
            FROM Capability__c 
            WHERE Application__c = : applicationId 
                AND RecordTypeId = :rcId ];
                    
        Map<String, Decimal> IncomeSegmentMap = new Map<String, Decimal>();
        for(Capability__c cap : capabilities){ 
            Decimal monthlyIncome = 0;
            if(cap.Income_segment__c == 'Salaried'){
                cap.Monthly_Salary__c = cap.Monthly_Salary__c != null ? cap.Monthly_Salary__c : 0;
                monthlyIncome = Integer.valueOf(cap.Monthly_Salary__c);
            } else if(cap.Income_segment__c == 'Rental Income'){
                cap.Rental_Income__c = cap.Rental_Income__c != null ? cap.Rental_Income__c : 0;
                monthlyIncome = Integer.valueOf(cap.Rental_Income__c);
            } else if(cap.Income_segment__c == 'Daily wages' || cap.Income_segment__c == 'Transport business'){
                cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
            } else if(cap.Income_segment__c == 'Income from Abroad'){
                cap.Income_per_month__c = cap.Income_per_month__c != null ? cap.Income_per_month__c : 0;
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
            } else if(cap.Income_segment__c == 'Pension'){
                monthlyIncome = cap.Income_per_month_Pension__c != null ? Integer.valueOf(cap.Income_per_month_Pension__c) : 0;
            } else if(cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                      cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                      cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                      cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed'){
                          if(cap.Day_Margin_Basis__c == 'Day Basis'){
                              cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                              cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                              monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                          } else if(cap.Day_Margin_Basis__c == 'Margin Basis'){
                              Decimal totalSales = Integer.valueOf(cap.Sales_per_month__c);
                              Decimal margin = cap.Margin__c != null ? cap.Margin__c : 0;
                              Decimal totalIncome = 0;
                              if(totalSales != NULL && totalSales != 0){
                                  totalIncome = (totalSales / 100 * margin);
                              }
                              if(cap.Electricity__c != Null && cap.Electricity__c != 0){
                                  totalIncome = totalIncome - cap.Electricity__c;
                              }
                              if(cap.Rent__c != Null && cap.Rent__c != 0){
                                  totalIncome = totalIncome - cap.Rent__c;
                              }
                              if(cap.Others__c != Null && cap.Others__c != 0){
                                  totalIncome = totalIncome - cap.Others__c;
                              }
                              if(cap.Salary__c != Null && cap.Salary__c != 0){
                                  totalIncome = totalIncome - cap.Salary__c;
                              }
                              monthlyIncome = totalIncome;
                          }
                      } 			
            Decimal applicantsIncome= 0;
            String segmentSubSegment = cap.Income_segment__c;
            if(String.isNotBlank(cap.Subsegment__c)){
                segmentSubSegment = segmentSubSegment + '-' + cap.Subsegment__c;
            }
            if(String.isNotBlank(segmentSubSegment) && IncomeSegmentMap.containsKey(segmentSubSegment)){
                applicantsIncome += IncomeSegmentMap.get(segmentSubSegment);
                applicantsIncome += monthlyIncome;
                IncomeSegmentMap.put(segmentSubSegment, applicantsIncome);
            }else if(String.isNotBlank(segmentSubSegment) && !IncomeSegmentMap.containsKey(segmentSubSegment)){
                IncomeSegmentMap.put(segmentSubSegment, monthlyIncome);
            }	           
        }
        System.debug('map' + IncomeSegmentMap);
        return IncomeSegmentMap;
    }
    
    // to get the Capability Summary Table for PC
    @AuraEnabled 
    public static IncomeSummary getCapabilitySummary(String applicationId)
    {
        Decimal fivCObligations = 0,pcObligations = 0;
        Set<String> bureauHighmarkIdSet = new Set<String>();
        for(Bureau_Highmark__c highmarkRecord : [SELECT Id,Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__c IN (SELECT Id FROM Loan_Applicant__c WHERE Application__c =:applicationId)]) {
            bureauHighmarkIdSet.add(highmarkRecord.Id);
        }
        String loanDetailRecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        for(Loan_details__c loanObj:[SELECT Id,Obligations__c,To_be_considerd_for_DBR__c,Stage__c FROM Loan_Details__c WHERE Bureau_Highmark__c IN:bureauHighmarkIdSet AND RecordTypeId =:loanDetailRecordTypeId ])
        {
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='FIV - C'))
            {
                system.debug('inside fivc');
                fivCObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0); 
            }
            
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='PC'))
            {
                system.debug('inside pc');
                pcObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0);
            }
        }
        system.debug('pc obligation:'+pcObligations);
        system.debug('fivc obligation:'+fivCObligations);
        List<Id> verificationIds = new List<Id>();
        for(Verification__c verObj:[SELECT Id FROM Verification__c WHERE Application__c =:applicationId AND RecordType.Name IN('FIV - C','PC')])
        {
            verificationIds.add(verObj.Id);
        }
        IncomeSummary incomeObj = new IncomeSummary();
        String rcId1 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('PC Capability').getRecordTypeId();
        String rcId2 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        List<String> rcIds = new List<String>{rcId1, rcId2};
            
            
            Decimal totalfivbIncome = 0,allfivBOBligations =0;
        Map<Id,String> loanApplicationId = new Map<Id,String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =: applicationId]){
            
            loanApplicationId.put(loanApplicant.Id,loanApplicant.Customer_Information__r.Name);
        }       
        
        List<Capability__c> capabilities = new List<Capability__c>();
        capabilities = [SELECT Id, Customer_Information__c, Income_segment__c,Loan_Applicant__r.Income_Considered__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
                        Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
                        Electricity__c, Rent__c, Others__c, Salary__c,RecordType.Name,Income_per_month_Pension__c
                        FROM Capability__c 
                        WHERE Verification__c IN: verificationIds AND RecordTypeId IN: rcIds Order BY Loan_Applicant__r.Customer_Information__r.Name];
        
        system.debug('capab list+'+capabilities);
        ////////
        Map<String,Map<String,Decimal>> incomeMap = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> segmentMap = new Map<String,Map<String,Decimal>>();
        Map<Id, Decimal> applicantIncomeMap = new Map<Id, Decimal>();
        decimal totalpcIncome = 0;
        decimal totalfivcIncome =0;
        decimal totalpcbusinessmonthlyincome = 0;
        decimal totalpcIncomeConsidered = 0;
        for(Capability__c cap : capabilities){
            Decimal busmonthlyIncome = 0;
            Decimal monthlyIncome = 0;
            Decimal monthlyIncomeConsidered = 0;
            if(cap.Income_segment__c == 'Salaried'){
                cap.Monthly_Salary__c = cap.Monthly_Salary__c != null ? cap.Monthly_Salary__c : 0;
                monthlyIncome = Integer.valueOf(cap.Monthly_Salary__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Rental Income'){
                cap.Rental_Income__c = cap.Rental_Income__c != null ? cap.Rental_Income__c : 0;
                monthlyIncome = Integer.valueOf(cap.Rental_Income__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Daily wages' || cap.Income_segment__c == 'Transport business'){
                cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
                if(cap.Income_segment__c == 'Transport business')
                    busmonthlyIncome = monthlyIncome;
                
            } else if( cap.Income_segment__c == 'Income from Abroad' ){
                cap.Income_per_month__c = cap.Income_per_month__c != null ? cap.Income_per_month__c : 0;
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            }else if(cap.Income_segment__c == 'Pension'  ){
                monthlyIncome = cap.Income_per_month_Pension__c != null ? Integer.valueOf(cap.Income_per_month_Pension__c) : 0;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            }
            else if(cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                      cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                      cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                      cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed'){
                          if(cap.Day_Margin_Basis__c == 'Day Basis'){
                              cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                              cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                              monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                              if(cap.RecordType.Name == 'PC Capability')
                                  busmonthlyIncome = monthlyIncome;
                              if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                  monthlyIncomeConsidered = monthlyIncome;
                          } else if(cap.Day_Margin_Basis__c == 'Margin Basis'){
                              Decimal totalSales = Integer.valueOf(cap.Sales_per_month__c);
                              Decimal margin = cap.Margin__c != null ? cap.Margin__c : 0;
                              Decimal totalIncome = 0;
                              if(totalSales != NULL && totalSales != 0){
                                  totalIncome = (totalSales / 100 * margin);
                              }
                              if(cap.Electricity__c != Null && cap.Electricity__c != 0){
                                  totalIncome = totalIncome - cap.Electricity__c;
                              }
                              if(cap.Rent__c != Null && cap.Rent__c != 0){
                                  totalIncome = totalIncome - cap.Rent__c;
                              }
                              if(cap.Others__c != Null && cap.Others__c != 0){
                                  totalIncome = totalIncome - cap.Others__c;
                              }
                              if(cap.Salary__c != Null && cap.Salary__c != 0){
                                  totalIncome = totalIncome - cap.Salary__c;
                              }
                              monthlyIncome = totalIncome;
                              if(cap.RecordType.Name == 'PC Capability')
                                  busmonthlyIncome = monthlyIncome;
                              if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                  monthlyIncomeConsidered = monthlyIncome;
                          }
                      } 
            
            totalpcbusinessmonthlyincome += busmonthlyIncome;
            
            if(cap.RecordType.Name == 'PC Capability'){
                Decimal applicantsIncome= 0;
                if(applicantIncomeMap.containsKey(cap.Loan_Applicant__c)){
                    applicantsIncome += applicantIncomeMap.get(cap.Loan_Applicant__c);
                    applicantIncomeMap.put(cap.Loan_Applicant__c,applicantsIncome);
                }else{
                    applicantIncomeMap.put(cap.Loan_Applicant__c,monthlyIncome);
                }	
            }
            
            if(!incomeMap.containsKey(cap.Loan_Applicant__c)){    
                if(cap.RecordType.Name == 'FIV-C Capability'){ 
                    incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
                    totalfivcIncome+=monthlyIncome;
                    
                }else  if(cap.RecordType.Name == 'PC Capability'){   
                    incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'PC Income'=>monthlyIncome});
                    totalpcIncome+=monthlyIncome;
                    if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                        totalpcIncomeConsidered += monthlyIncomeConsidered;                                        
                }
            }
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('FIV-C Income'))
                    {    tempMap.put('FIV-C Income',tempMap.get('FIV-C Income')+monthlyIncome);
                     totalfivcIncome+=monthlyIncome;}
                    else
                    {  tempMap.put('FIV-C Income',monthlyIncome);
                     totalfivcIncome+=monthlyIncome;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap); 
                }
                else  if(cap.RecordType.Name == 'PC Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('PC Income'))
                    {   tempMap.put('PC Income',tempMap.get('PC Income')+monthlyIncome);
                     totalpcIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalpcIncomeConsidered += monthlyIncomeConsidered;
                    }else
                    {   tempMap.put('PC Income',monthlyIncome);
                     
                     totalpcIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalpcIncomeConsidered += monthlyIncomeConsidered;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap);
                }}
            
            if(!segmentMap.containsKey(cap.Income_segment__c))
            {    if(cap.RecordType.Name == 'FIV-C Capability')
                segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
             else if(cap.RecordType.Name == 'PC Capability')
                 segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'PC Income'=>monthlyIncome});}
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {     
                    Map<String , Decimal> SegMap= segmentMap.get(cap.Income_segment__c);
                    if(SegMap.containsKey('FIV-C Income'))
                        SegMap.put('FIV-C Income',SegMap.get('FIV-C Income')+monthlyIncome);
                    else
                        SegMap.put('FIV-C Income',monthlyIncome);
                    segmentMap.put(cap.Income_segment__c,SegMap);             }
                else if(cap.RecordType.Name == 'PC Capability')
                {   Map<String , Decimal> tempMap= segmentMap.get(cap.Income_segment__c);
                 if(tempMap.containsKey('PC Income'))
                     tempMap.put('PC Income',tempMap.get('PC Income')+monthlyIncome);
                 else
                     tempMap.put('PC Income',monthlyIncome);
                 segmentMap.put(cap.Income_segment__c,tempMap);    }}
        }
        
        for(Cashflow__C cashflowObj :[SELECT ID ,Loan_Applicant__c,Gross_Income__c,Obligations__c,Net_Income__c FROM Cashflow__C WHERE Loan_Applicant__c IN :loanApplicationId.keySet()])
        {
            if(!incomeMap.containsKey(cashflowObj.Loan_Applicant__c))
            {
                incomeMap.put(cashflowObj.Loan_Applicant__c,new Map<String,Decimal>{'FIV-B Income'=>cashflowObj.Gross_Income__c});
                totalfivbIncome += cashflowObj.Gross_Income__c;
                allfivBOBligations += cashflowObj.Obligations__c;
            }
            else
            {
                Map<String , Decimal> tempMap= incomeMap.get(cashflowObj.Loan_Applicant__c);
                if(tempMap.containsKey('FIV-B Income') && cashflowObj.Gross_Income__c != null)
                {   
                    tempMap.put('FIV-B Income',tempMap.get('FIV-B Income')+cashflowObj.Gross_Income__c);
                    totalfivbIncome+=cashflowObj.Gross_Income__c;
                    allfivBOBligations += cashflowObj.Obligations__c;}
                else  if(cashflowObj.Gross_Income__c != null)
                {  tempMap.put('FIV-B Income',cashflowObj.Gross_Income__c);
                 totalfivbIncome+=cashflowObj.Gross_Income__c;
                 allfivBOBligations += cashflowObj.Obligations__c;
                }
                incomeMap.put(cashflowObj.Loan_Applicant__c,tempMap);
            }
        }      
        
        if(!applicantIncomeMap.isEMpty()){
            List<Loan_Applicant__c> loanApplicantToUpdate = new List<Loan_Applicant__c>();
            for(Id applicantId : applicantIncomeMap.keySet()){
                loanApplicantToUpdate.add(new Loan_Applicant__c(Id=applicantId,Gross_Income_PC__c= applicantIncomeMap.get(applicantId)));                
            }             
            update loanApplicantToUpdate;
        }        
        
        incomeObj.totalFivCMonthlyIncome = totalfivcIncome;
        incomeObj.totalPCMonthlyIncome = totalpcIncome;
        incomeObj.totalPCbusincomeIncome = totalpcbusinessmonthlyincome;
        incomeObj.allpCObligations = pcObligations;
        incomeObj.allfivCObligations = fivCObligations;
        incomeObj.totalFivBMonthlyIncome = totalfivbIncome;
        incomeObj.allfivBObligations = allfivBOBligations;
        incomeObj.pcnetbusincomeIncome = totalpcbusinessmonthlyincome - pcObligations;
        incomeObj.totalPCMonthlyIncomeConsidered = totalpcIncomeConsidered - fivCObligations;
        incomeObj.pcnetMonthlyIncomeConsidered = totalpcIncomeConsidered - pcObligations;
        incomeObj.fivbnetMonthlyIncome = totalfivbIncome - allfivBOBligations;
        incomeObj.pcnetMonthlyIncome = totalpcIncome - pcObligations;
        incomeObj.fivcnetMonthlyIncome = totalfivcIncome - fivCObligations;
        
        List<IncomeWrapper> incomeList =new List<IncomeWrapper>();
        List<SegmentWrapper> segList = new List<SegmentWrapper>();
        for(String key:incomeMap.keySet())
        {
            Map<String,Decimal> temp = incomeMap.get(key);
            IncomeWrapper incObj = new IncomeWrapper();
            if(loanApplicationId.containsKey(key))
                incObj.customerName = loanApplicationId.get(key);
            incObj.customerId = key;
            incObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            incObj.pcIncome = (temp.get('PC Income')!=null)?temp.get('PC Income'):0;
            incObj.fivBIncome = (temp.get('FIV-B Income')!=null)?temp.get('FIV-B Income'):0;
            incomeList.add(incObj);
        }
        for(String key:segmentMap.keySet())
        {
            Map<String,Decimal> temp = segmentMap.get(key);
            SegmentWrapper segObj = new SegmentWrapper();
            segObj.SegmemtName = key;
            segObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            segObj.pcIncome = (temp.get('PC Income')!=null)?temp.get('PC Income'):0;
            segList.add(segObj);
        }
        incomeObj.incomList= incomeList;
        incomeObj.segmentList = segList;
        
        System.debug('incomeObj ='+incomeObj);
        System.debug('segmentMap ='+segmentMap);
        System.debug('incomeMap ='+incomeMap);
        
        return incomeObj;
        
    }
    
    // get the Capability Summary for AC
    @AuraEnabled
    public static IncomeSummary getacCapabilitySummary(String applicationId)
    {
        Decimal fivCObligations = 0,acObligations = 0;
        Set<String> bureauHighmarkIdSet = new Set<String>();
        for(Bureau_Highmark__c highmarkRecord : [SELECT Id,Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__c IN (SELECT Id FROM Loan_Applicant__c WHERE Application__c =:applicationId)]) {
            bureauHighmarkIdSet.add(highmarkRecord.Id);
        }
        String loanDetailRecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        for(Loan_details__c loanObj:[SELECT Id,Obligations__c,To_be_considerd_for_DBR__c,Stage__c FROM Loan_Details__c WHERE Bureau_Highmark__c IN:bureauHighmarkIdSet AND RecordTypeId =:loanDetailRecordTypeId ])
        {
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='FIV - C'))
                fivCObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0);  
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='AC' || loanObj.Stage__c =='PC'))
                acObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0); 
        }
        List<Id> verificationIds = new List<Id>();
        for(Verification__c verObj:[SELECT Id FROM Verification__c WHERE Application__c =:applicationId AND RecordType.Name IN('FIV - C','AC')])
        {
            verificationIds.add(verObj.Id);
        }
        IncomeSummary incomeObj = new IncomeSummary();
        String rcId1 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('AC Capability').getRecordTypeId();
        String rcId2 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        List<String> rcIds = new List<String>{rcId1, rcId2};
            
            Decimal totalfivbIncome = 0,allfivBOBligations =0;
        Map<Id,String> loanApplicationId = new Map<Id,String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =: applicationId]){
            
            loanApplicationId.put(loanApplicant.Id,loanApplicant.Customer_Information__r.Name);
        }       
        
        List<Capability__c> capabilities = new List<Capability__c>();
        Map<Id, Decimal> applicantIncomeMap = new Map<Id, Decimal>();
        capabilities = [SELECT Id, Customer_Information__c, Income_segment__c,Loan_Applicant__r.Income_Considered__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
                        Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
                        Electricity__c, Rent__c, Others__c, Salary__c,RecordType.Name,Income_per_month_Pension__c
                        FROM Capability__c 
                        WHERE Verification__c IN: verificationIds AND RecordTypeId IN: rcIds Order BY Loan_Applicant__r.Customer_Information__r.Name];
        
        system.debug('capab list+'+capabilities);
        ////////
        Map<String,Map<String,Decimal>> incomeMap = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> segmentMap = new Map<String,Map<String,Decimal>>();
        decimal totalacIncome = 0;
        decimal totalfivcIncome =0;
        decimal totalacbusinessmonthlyincome = 0;
        decimal totalacIncomeConsidered =0;
        for(Capability__c cap : capabilities){
            Decimal busmonthlyIncome = 0;
            Decimal monthlyIncome = 0;
            Decimal monthlyIncomeConsidered = 0;
            if(cap.Income_segment__c == 'Salaried'){
                cap.Monthly_Salary__c = cap.Monthly_Salary__c != null ? cap.Monthly_Salary__c : 0;
                monthlyIncome = Integer.valueOf(cap.Monthly_Salary__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Rental Income'){
                cap.Rental_Income__c = cap.Rental_Income__c != null ? cap.Rental_Income__c : 0;
                monthlyIncome = Integer.valueOf(cap.Rental_Income__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Daily wages' || cap.Income_segment__c == 'Transport business'){
                cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
                if(cap.Income_segment__c == 'Transport business')
                    busmonthlyIncome = monthlyIncome;
            } else if( cap.Income_segment__c == 'Income from Abroad' ){
                cap.Income_per_month__c = cap.Income_per_month__c != null ? cap.Income_per_month__c : 0;
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
                system.debug('Income segment'+cap.Income_segment__c+'income' +cap.Income_per_month__c);
            } 
            else if(cap.Income_segment__c == 'Pension'  ){
                monthlyIncome = cap.Income_per_month_Pension__c != null ? Integer.valueOf(cap.Income_per_month_Pension__c) : 0;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            }else if(cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                      cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                      cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                      cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed'){
                          if(cap.Day_Margin_Basis__c == 'Day Basis'){
                              cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                              cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                              monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                              if(cap.RecordType.Name == 'AC Capability')
                                  busmonthlyIncome = monthlyIncome;
                              if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                  monthlyIncomeConsidered = monthlyIncome;
                          } else if(cap.Day_Margin_Basis__c == 'Margin Basis'){
                              Decimal totalSales = Integer.valueOf(cap.Sales_per_month__c);
                              Decimal margin = cap.Margin__c != null ? cap.Margin__c : 0;
                              Decimal totalIncome = 0;
                              if(totalSales != NULL && totalSales != 0){
                                  totalIncome = (totalSales / 100 * margin);
                              }
                              if(cap.Electricity__c != Null && cap.Electricity__c != 0){
                                  totalIncome = totalIncome - cap.Electricity__c;
                              }
                              if(cap.Rent__c != Null && cap.Rent__c != 0){
                                  totalIncome = totalIncome - cap.Rent__c;
                              }
                              if(cap.Others__c != Null && cap.Others__c != 0){
                                  totalIncome = totalIncome - cap.Others__c;
                              }
                              if(cap.Salary__c != Null && cap.Salary__c != 0){
                                  totalIncome = totalIncome - cap.Salary__c;
                              }
                              monthlyIncome = totalIncome;
                              if(cap.RecordType.Name == 'AC Capability')
                                  busmonthlyIncome = monthlyIncome;
                              if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                  monthlyIncomeConsidered = monthlyIncome;
                          }
                      } 
            totalacbusinessmonthlyincome += busmonthlyIncome;
            
            if(cap.RecordType.Name == 'AC Capability'){
                Decimal applicantsIncome= 0;
                if(applicantIncomeMap.containsKey(cap.Loan_Applicant__c)){
                    applicantsIncome += applicantIncomeMap.get(cap.Loan_Applicant__c);
                    applicantIncomeMap.put(cap.Loan_Applicant__c,applicantsIncome);
                }else{
                    applicantIncomeMap.put(cap.Loan_Applicant__c,monthlyIncome);
                }	
            }
            
            if(!incomeMap.containsKey(cap.Loan_Applicant__c))
            {    if(cap.RecordType.Name == 'FIV-C Capability')
            { incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
             totalfivcIncome+=monthlyIncome;
             
            }else  if(cap.RecordType.Name == 'AC Capability')
            {   incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'AC Income'=>monthlyIncome});
             totalacIncome+=monthlyIncome;
             if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                 totalacIncomeConsidered += monthlyIncomeConsidered;
            }
            }
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('FIV-C Income'))
                    {    tempMap.put('FIV-C Income',tempMap.get('FIV-C Income')+monthlyIncome);
                     totalfivcIncome+=monthlyIncome;}
                    else
                    {  tempMap.put('FIV-C Income',monthlyIncome);
                     totalfivcIncome+=monthlyIncome;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap); 
                }
                else  if(cap.RecordType.Name == 'AC Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('AC Income'))
                    {   tempMap.put('AC Income',tempMap.get('AC Income')+monthlyIncome);
                     totalacIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalacIncomeConsidered += monthlyIncomeConsidered;
                    }else
                    {   tempMap.put('AC Income',monthlyIncome);
                     
                     totalacIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalacIncomeConsidered += monthlyIncomeConsidered;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap);
                }}
            
            if(!segmentMap.containsKey(cap.Income_segment__c))
            {    if(cap.RecordType.Name == 'FIV-C Capability')
                segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
             else if(cap.RecordType.Name == 'AC Capability')
                 segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'AC Income'=>monthlyIncome});}
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {     
                    Map<String , Decimal> SegMap= segmentMap.get(cap.Income_segment__c);
                    if(SegMap.containsKey('FIV-C Income'))
                        SegMap.put('FIV-C Income',SegMap.get('FIV-C Income')+monthlyIncome);
                    else
                        SegMap.put('FIV-C Income',monthlyIncome);
                    segmentMap.put(cap.Income_segment__c,SegMap);             }
                else if(cap.RecordType.Name == 'AC Capability')
                {   Map<String , Decimal> tempMap= segmentMap.get(cap.Income_segment__c);
                 if(tempMap.containsKey('AC Income'))
                     tempMap.put('AC Income',tempMap.get('AC Income')+monthlyIncome);
                 else
                     tempMap.put('AC Income',monthlyIncome);
                 segmentMap.put(cap.Income_segment__c,tempMap);    }}
        }
        
        for(Cashflow__C cashflowObj :[SELECT ID ,Loan_Applicant__c,Gross_Income__c,Obligations__c,Net_Income__c FROM Cashflow__C WHERE Loan_Applicant__c IN :loanApplicationId.keySet()])
        {
            if(!incomeMap.containsKey(cashflowObj.Loan_Applicant__c))
            {
                incomeMap.put(cashflowObj.Loan_Applicant__c,new Map<String,Decimal>{'FIV-B Income'=>cashflowObj.Gross_Income__c});
                totalfivbIncome += cashflowObj.Gross_Income__c;
                allfivBOBligations += cashflowObj.Obligations__c;
            }
            else
            {
                Map<String , Decimal> tempMap= incomeMap.get(cashflowObj.Loan_Applicant__c);
                if(tempMap.containsKey('FIV-B Income') && cashflowObj.Gross_Income__c != null)
                {    tempMap.put('FIV-B Income',tempMap.get('FIV-B Income')+cashflowObj.Gross_Income__c);
                 totalfivbIncome+=cashflowObj.Gross_Income__c;
                 allfivBOBligations += cashflowObj.Obligations__c;}
                else if(cashflowObj.Gross_Income__c != null)
                {  tempMap.put('FIV-B Income',cashflowObj.Gross_Income__c);
                 totalfivbIncome+=cashflowObj.Gross_Income__c;
                 allfivBOBligations += cashflowObj.Obligations__c;
                }
                incomeMap.put(cashflowObj.Loan_Applicant__c,tempMap);
            }
        }      
        
        if(!applicantIncomeMap.isEMpty()){
            List<Loan_Applicant__c> loanApplicantToUpdate = new List<Loan_Applicant__c>();
            for(Id applicantId : applicantIncomeMap.keySet()){
                loanApplicantToUpdate.add(new Loan_Applicant__c(Id=applicantId,Gross_Income_AC__c= applicantIncomeMap.get(applicantId)));                
            } 
            
            update loanApplicantToUpdate;
        }    
        
        incomeObj.totalFivCMonthlyIncome = totalfivcIncome;
        incomeObj.totalPCMonthlyIncome = totalacIncome;
        incomeObj.totalPCbusincomeIncome = totalacbusinessmonthlyincome;
        incomeObj.allpCObligations = acObligations;
        incomeObj.allfivCObligations = fivCObligations;
        incomeObj.totalFivBMonthlyIncome = totalfivbIncome;
        incomeObj.allfivBObligations = allfivBOBligations;
        incomeObj.pcnetbusincomeIncome = totalacbusinessmonthlyincome - acObligations;
        incomeObj.totalPCMonthlyIncomeConsidered = totalacIncomeConsidered - acObligations;
        incomeObj.pcnetMonthlyIncomeConsidered = totalacIncomeConsidered - fivCObligations;
        incomeObj.fivbnetMonthlyIncome = totalfivbIncome - allfivBOBligations;
        incomeObj.pcnetMonthlyIncome = totalacIncome - acObligations;
        incomeObj.fivcnetMonthlyIncome = totalfivcIncome - fivCObligations;
        
        List<IncomeWrapper> incomeList =new List<IncomeWrapper>();
        List<SegmentWrapper> segList = new List<SegmentWrapper>();
        for(String key:incomeMap.keySet())
        {
            Map<String,Decimal> temp = incomeMap.get(key);
            IncomeWrapper incObj = new IncomeWrapper();
            if(loanApplicationId.containsKey(key))
                incObj.customerName = loanApplicationId.get(key);
            incObj.customerId = key;
            incObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            incObj.pcIncome = (temp.get('AC Income')!=null)?temp.get('AC Income'):0;
            incObj.fivBIncome = (temp.get('FIV-B Income')!=null)?temp.get('FIV-B Income'):0;
            incomeList.add(incObj);
        }
        for(String key:segmentMap.keySet())
        {
            Map<String,Decimal> temp = segmentMap.get(key);
            SegmentWrapper segObj = new SegmentWrapper();
            segObj.SegmemtName = key;
            segObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            segObj.pcIncome = (temp.get('AC Income')!=null)?temp.get('AC Income'):0;
            segList.add(segObj);
        }
        incomeObj.incomList= incomeList;
        incomeObj.segmentList = segList;
        
        System.debug('incomeObj ='+incomeObj);
        System.debug('segmentMap ='+segmentMap);
        System.debug('incomeMap ='+incomeMap);        
        return incomeObj;
    }
    
    
     
      @AuraEnabled 
    public static void handleTrancheApplication(String appId)
    {
        system.debug('appId'+appId);
        Application__c newApp = new Application__c();
        
        List<Application__c> oldAppList = new List<Application__c>([SELECT Id,Tranche_Disbursal__c,Old_Application__r.Loan_Amount__c,Old_Application__r.Name,Old_Application__r.Insurance_Premium_Tranche_1__c,Pre_Login__r.RecordType.Name,
                                                                    Old_Application__r.Tranche_Disbursal__c,Old_Application__r.Total_Amount_Recommended_PcAc__c,Old_Application__r.Tranche_2__c  FROM Application__c WHERE Id =:appId]);
        if(oldAppList != null && oldAppList.size()>0)
        {
            if(oldAppList.get(0).Old_Application__r.Tranche_Disbursal__c == 'I' && oldAppList.get(0).Tranche_Disbursal__c == 'I' && oldAppList.get(0).Old_Application__r.Name.contains('-') && oldAppList.get(0).Pre_Login__r.RecordType.Name == '4. Tranche loan' )
            {   
                newApp.Id = appId;
                newApp.Tranche_Disbursal__c = 'II';
                newApp.Insurance_Premium_Tranche_1__c = (oldAppList.get(0).Old_Application__r.Insurance_Premium_Tranche_1__c != null ? oldAppList.get(0).Old_Application__r.Insurance_Premium_Tranche_1__c : 0);
                newApp.Insurance_Premium__c = null;
                newApp.Amount_Recommended__c = (oldAppList.get(0).Old_Application__r.Tranche_2__c != null ? oldAppList.get(0).Old_Application__r.Tranche_2__c : 0);        
            }
            else  if(oldAppList.get(0).Old_Application__r.Tranche_Disbursal__c == 'I' && oldAppList.get(0).Tranche_Disbursal__c == 'I' && !oldAppList.get(0).Old_Application__r.Name.contains('-') && oldAppList.get(0).Pre_Login__r.RecordType.Name == '4. Tranche loan')
            {   
                newApp.Id = appId;
                newApp.Tranche_Disbursal__c = 'II';
                newApp.Insurance_Premium_Tranche_1__c = (oldAppList.get(0).Old_Application__r.Insurance_Premium_Tranche_1__c != null ? oldAppList.get(0).Old_Application__r.Insurance_Premium_Tranche_1__c : 0);
                newApp.Insurance_Premium__c = null;
                newApp.Amount_Recommended__c = (oldAppList.get(0).Old_Application__r.Loan_Amount__c != null ? oldAppList.get(0).Old_Application__r.Loan_Amount__c : 0);        
            }
        }
        
        if(newApp.Id != null)
            Update newApp;
        
    }
    
    @AuraEnabled
    public static String saveTopupDetails(String Data,String applicationId,String calledFrom)
    {
        IncomeSummary newObj = new IncomeSummary();
        if(calledFrom == 'PC')
            newObj = fsPcAcController.getCapabilitySummary(applicationId);
        else if(calledFrom == 'AC')
            newObj = fsPcAcController.getacCapabilitySummary(applicationId);
        System.debug('Data %%%'+Data);
        Decimal totalOutstandingAmt = 0, totalEmiAmount = 0,totalLoanAmount = 0;
        List<Topup__c> appDataList = new List<Topup__c>();
        List<topupDetailsWrapper> topupWrapObjList = (List<topupDetailsWrapper>)JSON.deserialize(Data, List<topupDetailsWrapper>.class);
        system.debug('topupWrapObjList->'+topupWrapObjList);
        system.debug('application Id ->'+applicationId);
        for(topupDetailsWrapper TopupWrapObj: topupWrapObjList)
        {
            system.debug('TopupWrapObj.PrincipalOs->'+TopupWrapObj.PrincipalOs);
            system.debug('TopupWrapObj.ConsiderForTotalExposure->'+TopupWrapObj.ConsiderForTotalExposure);
            totalOutstandingAmt += (TopupWrapObj.ConsiderForTotalExposure == 'Yes' ? (TopupWrapObj.PrincipalOs != null ? TopupWrapObj.PrincipalOs : 0) : 0);
            totalEmiAmount += (TopupWrapObj.ConsiderForTotalExposure == 'Yes' ? (TopupWrapObj.Emi != null ? TopupWrapObj.Emi : 0) : 0);
            totalLoanAmount += (TopupWrapObj.ConsiderForTotalExposure == 'Yes' ? (TopupWrapObj.LoanAmt != null ? TopupWrapObj.LoanAmt : 0) : 0);
            Topup__c appObj = new Topup__c();
            appObj.Id = TopupWrapObj.applicationId;
            appObj.Considered_For__c = TopupWrapObj.ConsiderForTotalExposure;
            appObj.Remarks__c = TopupWrapObj.Remarks;
            appDataList.add(appObj);        
        }
        system.debug('totalOutstandingAmt->'+totalOutstandingAmt+'totalEmiAmount ->'+totalEmiAmount);
        if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId))
        {
            String loanType = '';
            Application__c newAppObj = new Application__c();
            newAppObj.Id = applicationId;
            newAppObj.Principal_O_S__c = totalOutstandingAmt;
            newAppObj.EMI__c = totalEmiAmount;
            newAppObj.Loan_Amount__c = totalLoanAmount;
            if(newAppObj.EMI__c != 0)
            {  newAppObj.Considered_for__c = 'Yes';
             if (newObj.totalPCbusincomeIncome != null && newObj.totalPCMonthlyIncome != null) {
                 if (newObj.totalPCbusincomeIncome > (newObj.totalPCMonthlyIncome * (25 / 100)))
                     loanType = 'FSBL Business Loan Top up';
                 else
                     loanType = 'FSBL Mortgage Loan Top up';
             }             
            }
            else
            {   newAppObj.Considered_for__c = 'No';
             if (newObj.totalPCbusincomeIncome != null && newObj.totalPCMonthlyIncome != null) {
                 if (newObj.totalPCbusincomeIncome > (newObj.totalPCMonthlyIncome * (25 / 100)))
                     loanType = 'FSBL Business Loan';
                 else
                     loanType = 'FSBL Mortgage Loan';
             }
             
            }
            newAppObj.Loan_Type__c = loanType;
            newAppObj.Scheme__c = loanType;
            
            Update newAppObj;
        }
        if(!appDataList.isEmpty() && appDataList.size()>0 && appDataList != null)
        {
            try {
                upsert appDataList; 
                return 'success';
            } catch (DmlException e) {
                System.debug(e.getMessage());
                return 'error';
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static void  generateTopupDetails(String applicationId)
    {
        Application__c appnObj = new Application__c();
        appnObj = [SELECT Id,IsTopupDetailsGenerated__c FROM Application__c WHERE Id =:applicationId];      
        
        //if(!appnObj.IsTopupDetailsGenerated__c)
        //{
        
        List<Topup__c> topupObjList = new List<Topup__c>();
        Set<String> AppSet = new Set<String>();
        Set<String> CIFNumbersSet = new Set<String>();
        Set<String> appNumberSet = new Set<String>();
        if(String.isNotEmpty(applicationId) && String.isNotBlank(applicationId))
        {
            for(Loan_Applicant__C loanObj:[SELECT Id,LMS_Customer_Info_File_Number__c FROM Loan_Applicant__c WHERE Application__c =:applicationId])
            {
                if(loanObj.LMS_Customer_Info_File_Number__c != null)
                    CIFNumbersSet.add(loanObj.LMS_Customer_Info_File_Number__c);
            }
        }
        
        if(CIFNumbersSet != null && !CIFNumbersSet.isEmpty())
       { 	for(Loan_Applicant__c lObj :[SELECT Id,Application__c from Loan_Applicant__c WHERE  LMS_Customer_Info_File_Number__c IN: CIFNumbersSet AND Application__r.Created_From_Batch__c = true ])
            {
                if(lObj.Application__c != null)
                    AppSet.add(lObj.Application__c);
            }
       } 
        
        if(appnObj.IsTopupDetailsGenerated__c) {
			for(Topup__c topupObj :[SELECT Id,Application_No__c FROM Topup__c WHERE Application__c =:applicationId]){
				appNumberSet.add(topupObj.Application_No__c);		
			}
		}
        else{
            appNumberSet.add('');
        }
        System.debug('AppSet->'+AppSet);
        System.debug('appNumberSet->'+appNumberSet);
        if(AppSet != null && AppSet.size() >0)
        { for(Application__c appObj: [SELECT Id,Created_From_Batch__c,Total_Amount_Recommended_PcAc__c ,LMS_Response_Reference__c,Name,Primary_Applicant__r.Applicant_Name__c,Sourcing_Branch__r.Name,Loan_Amount__c,
                                      Emi__c,Principal_O_S__c,Total_Tenor__c,DPD__c,Considered_for__c,Remarks_Topup__c,Old_Collateral_value__c, 
                                      Old_Loan_Net_Income__c,Old_Loan_Gross_Income__c,Old_Loan_Obligationss__c,DBR__c,LTV__c FROM Application__C WHERE Id IN:AppSet AND Name NOT IN:appNumberSet])
        {
            Topup__c topupObj = new Topup__c();
            topupObj.Application__c = ((String.isNotBlank(applicationId) && String.isNotEmpty(applicationId)) ? applicationId : '');
            topupObj.Existing_loan_A_C_No__c = appObj.LMS_Response_Reference__c;
            topupObj.Application_No__c = appObj.Name;
            topupObj.Applicant_Name__c = appObj.Primary_Applicant__r.Applicant_Name__c;
            topupObj.Branch__c = appObj.Sourcing_Branch__r.Name;
            topupObj.Loan_Amount__c = appObj.Loan_Amount__c;
            topupObj.EMI__c = appObj.Emi__c;
            topupObj.Principal_O_S__c = appObj.Principal_O_S__c;
            topupObj.Total_Tenor__c = String.valueOf(appObj.Total_Tenor__c);
            topupObj.DPD__c = appObj.DPD__c;
            topupObj.Considered_For__c = appObj.Considered_for__c;
            topupObj.Remarks__c = appObj.Remarks_Topup__c; 
            topupObj.Existing_loan_Gross_Income__c = appObj.Old_Loan_Gross_Income__c; 
            topupObj.Existing_loan_Obligations__c = appObj.Old_Loan_Obligationss__c; 
            topupObj.Existing_Loan_Net_income__c = appObj.Old_Loan_Net_Income__c;
            topupObj.Existing_Collateral_Value__c = appObj.Old_Collateral_value__c;
            topupObj.DBR__c = appObj.DBR__c;
            topupObj.LTV__c = appObj.LTV__c; 
            topupObjList.add(topupObj);            
        }}
    
        if(topupObjList != null && topupObjList.size()>0)
        { 
            Application__c applObj = new Application__c();
            applObj.Id = applicationId;
            applObj.IsTopupDetailsGenerated__c = true;
            Update applObj;
            insert topupObjList;
        }
    }
    
    
    @AuraEnabled(cacheable = true)
    public static TopupWrapper gettopupDetails(String applicationId)
    {
        String PropertyRecordTypeId = Utility.PC_PROPERTY_RECORD_TYPE_ID;
         
        TopupWrapper parentWrapperObj = new TopupWrapper();
        List<topupDetailsWrapper> topupWrapObjList = new List<topupDetailsWrapper>();
        List<PropertyWrapper> collateralWrapperList = new List<PropertyWrapper>();
        Set<String> AppSet = new Set<String>();
        Set<String> CIFNumbersSet = new Set<String>();
        if(String.isNotEmpty(applicationId) && String.isNotBlank(applicationId))
        {
            for(Loan_Applicant__C loanObj:[SELECT Id,LMS_Customer_Info_File_Number__c FROM Loan_Applicant__c WHERE Application__c =:applicationId])
            {
                if(loanObj.LMS_Customer_Info_File_Number__c != null)
                    CIFNumbersSet.add(loanObj.LMS_Customer_Info_File_Number__c);
            }}
        
        if(CIFNumbersSet != null && !CIFNumbersSet.isEmpty())
        {for(Loan_Applicant__c lObj :[SELECT Id,Application__c from Loan_Applicant__c WHERE  LMS_Customer_Info_File_Number__c IN: CIFNumbersSet AND Application__r.Created_From_Batch__c = true ])
        {
            if(lObj.Application__c != null)
                AppSet.add(lObj.Application__c);
        }} 
        Integer index = 0;
        if(AppSet != null && !AppSet.isEmpty())
        { 
            for(Property__c pObj : [SELECT Id,LMS_Collateral_Number__c,Property_Address__c,Application__r.LMS_Response_Reference__c FROM Property__c WHERE RecordTypeId =:PropertyRecordTypeId AND Application__c IN:AppSet])
            {
                 PropertyWrapper proWrapObj = new PropertyWrapper();
                 proWrapObj.SrNo = ++index;
                 proWrapObj.CollateralId = pObj.LMS_Collateral_Number__c;
                 proWrapObj.LoanId = pObj.Application__r.LMS_Response_Reference__c;
                 proWrapObj.CollateralAddress = pObj.Property_Address__c;
                 collateralWrapperList.add(proWrapObj);
            }
        }
            
             if(String.isNotEmpty(applicationId) && String.isNotBlank(applicationId))
        {
            for(Topup__c appObj: [SELECT Id,Existing_loan_A_C_No__c ,Application_No__c,Name,Branch__c,Loan_Amount__c,Applicant_Name__c,
                                      EMI__c,Principal_O_S__c,Total_Tenor__c,DPD__c,Considered_For__c,Remarks__c,Existing_Collateral_Value__c, 
                                      Existing_Loan_Net_income__c,Existing_loan_Gross_Income__c,Existing_loan_Obligations__c,DBR__c,LTV__c FROM Topup__c WHERE Application__c =:applicationId])
        {
            topupDetailsWrapper topupWrapObj = new topupDetailsWrapper();
            topupWrapObj.applicationId = appObj.Id;
            topupWrapObj.ExistingLANNo = appObj.Existing_loan_A_C_No__c;
            topupWrapObj.ApplicationNo = appObj.Application_No__c;
            topupWrapObj.ApplicantName = appObj.Applicant_Name__c;
            topupWrapObj.Branch = appObj.Branch__c;
            topupWrapObj.LoanAmt = appObj.Loan_Amount__c;
            topupWrapObj.Emi = appObj.EMI__c;
            topupWrapObj.PrincipalOs = appObj.Principal_O_S__c;
            topupWrapObj.TotalTenor = appObj.Total_Tenor__c;
            topupWrapObj.DPD = appObj.DPD__c;
            topupWrapObj.ConsiderForTotalExposure = appObj.Considered_For__c;
            topupWrapObj.Remarks = appObj.Remarks__c; 
            topupWrapObj.OldLoanGrossIncome = appObj.Existing_loan_Gross_Income__c; 
            topupWrapObj.OldLoanObligations = appObj.Existing_loan_Obligations__c; 
            topupWrapObj.OldLoanNetIncome = appObj.Existing_Loan_Net_income__c;
            topupWrapObj.OldCollateralValue = appObj.Existing_Collateral_Value__c;
            topupWrapObj.DBR = appObj.DBR__c;
            topupWrapObj.LTV = appObj.LTV__c; 
            topupWrapObjList.add(topupWrapObj);            
        }}  
        parentWrapperObj.TopupDetailsList = topupWrapObjList;
        parentWrapperObj.PropertyList = collateralWrapperList;
        
        return parentWrapperObj;
    } 
    
    // This method is used to check Insurance Validation
    @AuraEnabled
    public static Boolean checkInsuranceValidation(String applicationId)
    {
        Boolean insuranceFlag = false;
        Boolean FinalFlag = FeeCreationTypeInsuranceNewController.isApiActive();
        List<Fee_Creation__c> fcList = new List<Fee_Creation__c>([SELECT Id, Fee_Code__c,Pending_Premium_Calculation__c 
                                                                  FROM Fee_Creation__c WHERE Application__c =: applicationId AND RecordType.DeveloperName = 'Insurance' AND Pending_Premium_Calculation__c = true]);
        if(fcList != null && fcList.size()>0 )
        { insuranceFlag = true;} 
        if(FinalFlag && insuranceFlag)
            return true;
        else 
            return false; 
    }
    
    @AuraEnabled
    public static void setHMScore(String appId,String calledFrom)
    {
        system.debug('Called from>>>>>'+calledFrom);
        IncomeSummary newObj = new IncomeSummary();
        if(calledFrom == 'PC')
            newObj = fsPcAcController.getCapabilitySummary(appId);
        if(calledFrom == 'AC')
            newObj = fsPcAcController.getacCapabilitySummary(appId);
        Decimal highestIncome = 0;
        String loanAppId;
        system.debug('$$$'+newObj.incomList);
        if(newObj.incomList.size()>0)
        { for( IncomeWrapper incObj:newObj.incomList)
        { if(incObj.pcIncome > highestIncome && incObj.customerId != null)
        {   highestIncome = incObj.pcIncome;
         loanAppId = incObj.customerId;
        } }}
        system.debug('loan app Id >>>'+loanAppId+'highest income'+highestIncome);
        string appHMScore;  
        for(Application__c appObj:[SELECT Id,HM__c FROM Application__c WHERE Id =:appId])
        {
            if(appObj.HM__c != null)
                appHMScore = appObj.HM__c;
        }
        String hmScore;
        List<Bureau_Highmark__c> HMScoreList = new List<Bureau_Highmark__c>();
        if(loanAppId != null)
            HMScoreList=[SELECT Id,Highmark_Score__c, Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__c=:loanAppId ORDER BY CreatedDate DESC LIMIT 1];
        if(HMScoreList.size()>0)
            hmScore = HMScoreList[0].Highmark_Score__c;
        system.debug('hmScore >>> '+hmScore+'appHMScore >>>>'+ appHMScore);
        if( hmScore != null && hmScore !=  appHMScore)
        {
            Application__c appObj = new Application__c();
            appObj.Id = appId;
            appObj.HM__c = hmScore;
            update appObj;
        }
        
    }    
    
    @AuraEnabled
    public static void setlivingStyle(String appId,String verificationId)
    {
        system.debug('AppId ###'+appId+'VerfId ###'+verificationId);
        String livingStyle,appLivingStyle;
        List<Character__c> livingStyleList = new List<Character__c>();
        if(appId != null && verificationId != null)
        {  //Verification__c=:verificationId AND
            for(Application__c appOBj : [SELECT ID ,Requested_Loan_Amount__c,Living_style__c,(SELECT Id,LifeStyle__c,Lifestyle_Loan_Amount_8Lakhs__c,Lifestyle_Loan_Amount_4L_to_8_Lakhs__c,Lifestyle_Loan_Amount_2L_to_4_Lakhs__c FROM Characters__r WHERE  Application__c =:appId AND Verification__c =:verificationId AND Section_Type__c='Living Standard Detail' ORDER BY CreatedDate ) FROM Application__c WHERE Id =: appId])
            {               
                appLivingStyle = (appOBj.Living_style__c != null)? appOBj.Living_style__c: null;
                if(appOBj.Characters__r.size()>0)   
                {                    
                    livingStyle = ((appOBj.Characters__r[0].LifeStyle__c != null && appOBj.Characters__r[0].LifeStyle__c != '' )? appOBj.Characters__r[0].LifeStyle__c : null );
                }
        }}
        system.debug('livingStyle >>> '+livingStyle+'app livingStyle >>'+appLivingStyle);
        if(livingStyle != appLivingStyle)
        {
            Application__c applicationObj = new Application__c();
            applicationObj.Id = appId;
            applicationObj.Living_style__c = livingStyle;
            Update applicationObj;
        }       
    }
    
    @AuraEnabled
    public static void setNeighbourFeedBack(String appId,String verificationId)
    {
        system.debug('AppId ###'+appId+'VerfId ###'+verificationId);
        String neighbourFeedBack,appNeighbourFeedBack;
        Map<String,Integer> CountMap = new Map<String,Integer>();  
        
        if(appId != null && verificationId != null)
        {    for(Application__c appObj:[SELECT Id,Neighbour_feedback__c,(SELECT Id,Feedback__c FROM Characters__r WHERE Verification__c=:verificationId AND Application__c =:appId AND Section_Type__c='Neighbour Detail') FROM Application__c WHERE Id =:appId])
        {
            appNeighbourFeedBack = (appObj.Neighbour_feedback__c != null)? appObj.Neighbour_feedback__c: null;
            if(appObj.Characters__r.size()>0)
            {
                for(Character__c negObj:appObj.Characters__r)
                {if(negObj.Feedback__c != null && !CountMap.containsKey(negObj.Feedback__c))
                    CountMap.put(negObj.Feedback__c,1);
                 else
                     CountMap.put(negObj.Feedback__c,CountMap.get(negObj.Feedback__c) + 1); } }             
        }}
        system.debug('Count Map ###'+ CountMap);
        if(CountMap.keySet().size() == 1)
        {
            for(String feedBack: CountMap.keySet())
                neighbourFeedBack = feedBack;
        }
        else 
        {if(CountMap.keySet().contains('Negative'))
        { neighbourFeedBack = 'Negative';}
         else if( CountMap.keySet().contains('Neutral') && CountMap.keySet().contains('Positive') && !CountMap.keySet().contains('Negative') )
         { neighbourFeedBack = 'Neutral';}
         else if( !CountMap.keySet().contains('Neutral') && CountMap.keySet().contains('Positive') && !CountMap.keySet().contains('Negative') )
         { neighbourFeedBack = 'Positive';}}           
        system.debug('neighbourFeedBack >>> '+neighbourFeedBack+'App neighbourFeedBack >>>>'+appNeighbourFeedBack);
        
        if(neighbourFeedBack != appNeighbourFeedBack)
        { Application__c applicationObj = new Application__c();
         applicationObj.Id = appId;
         applicationObj.Neighbour_feedback__c = neighbourFeedBack;
         Update applicationObj;}
        
    }
    
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getACCollateralTabRecords(String appId,String recordTypeName){
        Set<String> propIds = new Set<String>();
        for(Property__c objProp : [SELECT Id FROM Property__c WHERE Application__c =:appId AND RecordType.Name =:recordTypeName AND Application__c!= null]){
            propIds.add(objProp.Id);
        }
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'AC_Collateral';
        genericDTObj.IDS_SET = propIds;
        genericDTObj.WHERE_CLAUSE = 'Id IN:IDS_SET';
        return genericDTObj.getTable();
    }
    
    // This Method is Used to get All AC Users From Public Group as per Branch
    @AuraEnabled
    public static DecisionWrapper getDecision(String SourcingBranch,String appId)
    {
        DecisionWrapper wrapObj = new DecisionWrapper();
        Application__c appObj = [SELECT Id ,Total_Amount_Recommended_PcAc__c FROM Application__c WHERE Id =:appId LIMIT 1];
        String Level =[SELECT  Id,Level__c from Access_Master__C  WHERE User__c =: UserInfo.getUserId() LIMIT 1].Level__c;
        for(Loan_Approval_Matrix__c laObj :[SELECT  Id,Level__c,From__c, To__c from Loan_Approval_Matrix__c WHERE Level__c =: Level])
        {
            if( laObj.Level__c == '1' && (laObj.From__c <= appObj.Total_Amount_Recommended_PcAc__c && laObj.To__c >= appObj.Total_Amount_Recommended_PcAc__c))
            {
                wrapObj.IsApproved = true;
            }
            else if(Integer.valueOf(laObj.Level__c) == 7 && ( appObj.Total_Amount_Recommended_PcAc__c >= 0 && laObj.To__c >= appObj.Total_Amount_Recommended_PcAc__c))
            {   wrapObj.L7Approval = true;
            }
            else
            {
                if ( (Integer.valueOf(laObj.Level__c) > 1 && Integer.valueOf(laObj.Level__c) <7) && ( appObj.Total_Amount_Recommended_PcAc__c >= 0 && laObj.To__c >= appObj.Total_Amount_Recommended_PcAc__c))
                    wrapObj.IsApproved = true;
                else
                    wrapObj.IsApproved = false;
            }
        }      
        
        Set<String> userIds = new Set<String>();
        for(Access_Branch_Allocation__c accuser:[SELECT Id, Access_Master__r.User__c ,Access_Master__r.Level__c
                                                 FROM Access_Branch_Allocation__c 
                                                 WHERE Access_Master__r.Access_For__c = 'Approval Credit' 
                                                 AND Branch_Master__c =: SourcingBranch ])
        {  
            system.debug('Integer.valueOf(accuser.Access_Master__r.Level__c)'+Integer.valueOf(accuser.Access_Master__r.Level__c));
            system.debug('Integer.valueOf(Level)'+Integer.valueOf(Level));
            system.debug('Integer.valueOf(accuser.Access_Master__r.Level__c)> Integer.valueOf(Level)'+(Integer.valueOf(accuser.Access_Master__r.Level__c)> Integer.valueOf(Level)));
            if(Integer.valueOf(accuser.Access_Master__r.Level__c)> Integer.valueOf(Level))
                userIds.add(accuser.Access_Master__r.User__c);
        }
        
        List<User> userList = new List<User>();
        if(!userIds.isEmpty()){
            userList = [SELECT Id, Name FROM User WHERE Id IN : userIds];
        }
        if(!userList.isEmpty())
            wrapObj.ACUserList = userList;
        else
            wrapObj.ACUserList = new List<User>();
        
        
        return wrapObj;
    } 
    
    public class DecisionWrapper
    {
        @AuraEnabled public Boolean IsApproved;
        @AuraEnabled public Boolean L7Approval;
        @AuraEnabled public List<User> ACUserList;
    }
    
    
    
    // Wrapper Class For PC Income Summary
    public class IncomeWrapper{
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerId;
        @AuraEnabled public Decimal fivCIncome;
        @AuraEnabled public Decimal pcIncome;
        @AuraEnabled public Decimal fivBIncome;
        public IncomeWrapper(){
            customerId = '';
            customerName = '';
            pcIncome = 0;
            fivCIncome = 0;
            fivBIncome = 0;
        }
    }
    public class SegmentWrapper{
        @AuraEnabled public String SegmemtName;
        @AuraEnabled public Decimal fivCIncome;
        @AuraEnabled public Decimal pcIncome;
        public SegmentWrapper(){
            SegmemtName='';
            pcIncome =0;
            fivCIncome =0;
        }
    }
    
    
    public class IncomeSummary{
        @AuraEnabled public Decimal totalFivCMonthlyIncome;
        @AuraEnabled public Decimal totalPCMonthlyIncome;
        @AuraEnabled public Decimal totalFivBMonthlyIncome;
        @AuraEnabled public Decimal totalPCbusincomeIncome;
        @AuraEnabled public Decimal totalPCMonthlyIncomeConsidered;
        @AuraEnabled public Decimal allfivCObligations;
        @AuraEnabled public Decimal allpCObligations;
        @AuraEnabled public Decimal allfivBObligations;
        @AuraEnabled public Decimal pcnetMonthlyIncome;
        @AuraEnabled public Decimal fivcnetMonthlyIncome;
        @AuraEnabled public Decimal fivbnetMonthlyIncome;
        @AuraEnabled public Decimal pcnetbusincomeIncome; 
        @AuraEnabled public Decimal pcnetMonthlyIncomeConsidered;
        @AuraEnabled public List<IncomeWrapper> incomList;
        @AuraEnabled public List<SegmentWrapper> segmentList;
        
        public IncomeSummary(){
            incomList = new List<IncomeWrapper> ();
            segmentList = new List<SegmentWrapper>();
            fivcnetMonthlyIncome = 0;
            pcnetMonthlyIncome = 0;
            allpCObligations = 0;
            allfivCObligations = 0;
            totalPCMonthlyIncome = 0;
            totalFivCMonthlyIncome = 0;
            fivbnetMonthlyIncome = 0;
            allfivBObligations = 0;
            totalFivBMonthlyIncome = 0;
            totalPCbusincomeIncome = 0;
            pcnetbusincomeIncome = 0;
            totalPCMonthlyIncomeConsidered = 0;
            pcnetMonthlyIncomeConsidered = 0;
        }
    }
    
    
    /// Wrapper Class for Income Summary for FIV-C
    public class IncomWrapper {
        @AuraEnabled public String applicantName;
        @AuraEnabled public String applicantId;
        @AuraEnabled public String incomeConsidered;
        @AuraEnabled public String incomePerMonth;
        @AuraEnabled public String busincomePerMonth;
        @AuraEnabled public String monthlyIncomeConsidered;
        
        public IncomWrapper() {
            applicantName = '';
            applicantId = '';
            incomePerMonth = '';
            busincomePerMonth = '';
            monthlyIncomeConsidered = '';
            incomeConsidered = 'No';
        }
    }
    
    public class IncomSummary {
        @AuraEnabled public List < IncomWrapper > incomeList;
        @AuraEnabled public Decimal totalMonthlyIncome;
        @AuraEnabled public Decimal totalbusMonthlyIncome;
        @AuraEnabled public Decimal totalMonthlyIncomeConsidered;
        @AuraEnabled public Decimal allObligations;
        @AuraEnabled public Decimal netMonthlyIncome;
        @AuraEnabled public Decimal netMonthlyIncomeBusiness;
        @AuraEnabled public Decimal netMonthlyIncomeConsidered;
        
        public IncomSummary() {
            incomeList = new List < IncomWrapper > ();
            totalMonthlyIncome = 0;
            totalbusMonthlyIncome = 0;
            allObligations = 0;
            netMonthlyIncome = 0;
            totalMonthlyIncomeConsidered = 0;
            netMonthlyIncomeBusiness = 0;
            netMonthlyIncomeConsidered = 0;
        }
    }  
    
    ///////////////////// Land and Building Value Wrapper
    public class LandValueWrapper{
        @AuraEnabled public Decimal Land_Area;
        @AuraEnabled public Decimal Market_Value;
        @AuraEnabled public Decimal FinalLandValue;
    }
    
    public class BuildingValueWrapper{
        @AuraEnabled public Decimal Building_Area;
        @AuraEnabled public Decimal Building_Value;
        @AuraEnabled public Decimal Total_Building_Value;
    }
    
    
    ////////////////////////// Wrapper class for PC Check Validation
    public class characterValidationWrapper{
        @AuraEnabled public Boolean familyDetail;
        @AuraEnabled public Boolean NeighbourDetail;
        @AuraEnabled public Boolean AffiliationDetail;
        @AuraEnabled public Boolean LivingStandardDetail;
        
        public characterValidationWrapper()
        {
            familyDetail = true;
            NeighbourDetail = true;
            AffiliationDetail = true;
            LivingStandardDetail = true;
        }
    }
    
    public class collateralValidationWrapper{
        @AuraEnabled public Boolean PropertyDetails;
        @AuraEnabled public Boolean LandArea;
        @AuraEnabled public Boolean BuildingValuation;
        
        public collateralValidationWrapper()
        {
            PropertyDetails = true;
            BuildingValuation = true;
            LandArea = true;
        }
    }
    
    
    public class financialValidationWrapper{
        @AuraEnabled public Boolean TopupDetail;
        @AuraEnabled public Boolean CollateralDetail;
        @AuraEnabled public Boolean OldLoanDetail;
        @AuraEnabled public Boolean TrancheDetail;
        @AuraEnabled public Boolean ApplicationDetail;
        @AuraEnabled public Boolean LoanDetail;
        @AuraEnabled public Boolean InsuranceDetail;
        @AuraEnabled public Boolean DisbursementDetail;
        @AuraEnabled public Boolean LoanAmtDetail;
        @AuraEnabled public Boolean EligibilityDetail;
        @AuraEnabled public Boolean RiskDetail;
        @AuraEnabled public Boolean OtherDetail;
        @AuraEnabled public Boolean ExecutiveDetail;
        @AuraEnabled public Boolean IsCalculationChanged;
        @AuraEnabled public Boolean isVerifiedFalse;
        
        public financialValidationWrapper()
        {
            TopupDetail = true;
            CollateralDetail = true;
            OldLoanDetail = true;
            ApplicationDetail = true;
            TrancheDetail = true;
            LoanDetail = true;
            InsuranceDetail = true;
            DisbursementDetail = true;
            LoanAmtDetail = true;
            EligibilityDetail = true;
            RiskDetail = true;
            OtherDetail = true;
            ExecutiveDetail = true;
            IsCalculationChanged = true;
            isVerifiedFalse = true;
        }
    }
    
    // PC Validation Wrapper Class
    public class PCValidationWrapper{
        @AuraEnabled public characterValidationWrapper charWrap;
        @AuraEnabled public collateralValidationWrapper colWrap;
        @AuraEnabled public financialValidationWrapper  finWrap;
        @AuraEnabled public Boolean capabilityValidation;
        @AuraEnabled public Boolean isfivbInitiated;
        @AuraEnabled public Boolean isfivcInitiated;
        @AuraEnabled public Boolean isonlineECinitiated;
        @AuraEnabled public Boolean isfivbCompleted;
        @AuraEnabled public Boolean isfivcCompleted;
        @AuraEnabled public Boolean isonlineECCompleted;        
        @AuraEnabled public Boolean isLoanApplicantAdded;
        @AuraEnabled public Boolean isPropertyAdded;
        @AuraEnabled public Boolean isPrimaryOwner;
        @AuraEnabled public Boolean isGaurantorNetworthMissing;
        @AuraEnabled public Boolean isLoanAmountNotValid;
        @AuraEnabled public Boolean isKYCorNameorDOBChanged;
        @AuraEnabled public List<String> paramList;
        @AuraEnabled public List<String> pendingLeadDetailList;
        @AuraEnabled public List<String> mobileverificationList;
        @AuraEnabled public List<String> kycVerificationList;
        @AuraEnabled public List<String> bureauList;
        
        public PCValidationWrapper()
        {
            charWrap = new characterValidationWrapper();
            colWrap = new collateralValidationWrapper();
            finWrap = new financialValidationWrapper();
            mobileverificationList = new List<String>();
            kycVerificationList = new List<String>(); 
            pendingLeadDetailList = new List<String>();
            paramList = new List<String>();
            bureauList = new List<String>();
            capabilityValidation = false;
            isfivbInitiated = false;
            isfivcInitiated = false;
            isonlineECinitiated = false;
            isfivbCompleted = false;
            isfivcCompleted = false;
            isonlineECCompleted = false;
            isPropertyAdded = false;
            isPrimaryOwner = false;
            isLoanApplicantAdded = false; 
            isGaurantorNetworthMissing = false;
            isKYCorNameorDOBChanged = false;
            isLoanAmountNotValid = false;           
        }
    }
    
    // AC Validation Wrapper Class
    public class ACValidationWrapper{
        @AuraEnabled public characterValidationWrapper charWrap;
        @AuraEnabled public collateralValidationWrapper colWrap;
        @AuraEnabled public financialValidationWrapper  finWrap;
        @AuraEnabled public Boolean capabilityValidation;
        @AuraEnabled public Boolean isfivbInitiated;
        @AuraEnabled public Boolean isfivcInitiated;
        @AuraEnabled public Boolean isonlineECinitiated;
        @AuraEnabled public Boolean isfivbCompleted;
        @AuraEnabled public Boolean isfivcCompleted;
        @AuraEnabled public Boolean isonlineECCompleted;
        @AuraEnabled public Boolean isLoanApplicantAdded;
        @AuraEnabled public Boolean isPropertyAdded;
        @AuraEnabled public Boolean isPrimaryOwner;
        @AuraEnabled public Boolean isGaurantorNetworthMissing;
        @AuraEnabled public Boolean isLoanAmountNotValid;
        @AuraEnabled public Boolean isKYCorNameorDOBChanged;
        @AuraEnabled public List<String> paramList;
        @AuraEnabled public List<String> pendingLeadDetailList;
        @AuraEnabled public List<String> mobileverificationList;
        @AuraEnabled public List<String> kycVerificationList;
        @AuraEnabled public List<String> bureauList;
        @AuraEnabled public Boolean isLegalApprovalCompleted;
        
        public ACValidationWrapper()
        {
            charWrap = new characterValidationWrapper();
            colWrap = new collateralValidationWrapper();
            finWrap = new financialValidationWrapper();
            mobileverificationList = new List<String>();
            kycVerificationList = new List<String>();
            pendingLeadDetailList = new List<String>();
            paramList = new List<String>();
            bureauList = new List<String>();
            capabilityValidation = false;
            isfivbInitiated = false;
            isfivcInitiated = false;
            isonlineECinitiated = false;
            isfivbCompleted = false;
            isfivcCompleted = false;
            isonlineECCompleted = false;
            isPropertyAdded = false;
            isPrimaryOwner = false;
            isLoanApplicantAdded = false;
            isGaurantorNetworthMissing = false;
            isLegalApprovalCompleted = true;
            isKYCorNameorDOBChanged = false;
            isLoanAmountNotValid = false;
        }
    }
    
    // Topup Details Wrapper Class
    public class TopupWrapper
    {
        @AuraEnabled public List<topupDetailsWrapper> TopupDetailsList;
        @AuraEnabled public List<PropertyWrapper> PropertyList;
    }
    
    
    public class topupDetailsWrapper{
        @AuraEnabled public String applicationId;
        @AuraEnabled public String ExistingLANNo;
        @AuraEnabled public String ApplicationNo;
        @AuraEnabled public String ApplicantName;
        @AuraEnabled public String Branch;
        @AuraEnabled public Decimal LoanAmt;
        @AuraEnabled public Decimal Emi;
        @AuraEnabled public Decimal PrincipalOs;
        @AuraEnabled public String TotalTenor;
        @AuraEnabled public String DPD;
        @AuraEnabled public String ConsiderForTotalExposure;
        @AuraEnabled public String Remarks;
        @AuraEnabled public Decimal OldLoanGrossIncome;
        @AuraEnabled public String OldLoanObligations;
        @AuraEnabled public Decimal OldLoanNetIncome;
        @AuraEnabled public Decimal OldCollateralValue;
        @AuraEnabled public Decimal LienMarked;
        @AuraEnabled public Decimal LTV;
        @AuraEnabled public Decimal DBR;
        @AuraEnabled public Boolean IsChanged;
        
        
        public topupDetailsWrapper()
        {
            IsChanged = false;
        }
    }
    
    public class PropertyWrapper
    {
        @AuraEnabled public Integer SrNo;
        @AuraEnabled public String CollateralId;
        @AuraEnabled public String LoanId;
        @AuraEnabled public String CollateralAddress;            
    }
    
    // wrapper class for Effective Irr
    public class effIrrWrapper
    {
        @AuraEnabled public Decimal Rate;
        @AuraEnabled public Decimal EffIrr;
    }   
}