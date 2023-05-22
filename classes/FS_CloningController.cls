public without sharing class FS_CloningController {
    public static Map<String,String> oldIdNewIdMap = new Map<String,String>();
    
    @AuraEnabled
    public static Wrapper cloneExistingApplication(String oldApplicationId, String recTypeName){
        Savepoint sp = Database.setSavepoint();
        try {
            Wrapper wrap = new Wrapper();
            String query = '';
            Id devRecordTypeId = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
            Pre_Login__c preLog = new Pre_Login__c(RecordTypeId=devRecordTypeId,Status__c='Active');
            INSERT preLog; 
            if(preLog.Id!=null){
                wrap.preloginId = preLog.Id;
            }
            System.debug('preLog = '+preLog);
            System.debug('oldApplicationId = '+oldApplicationId);
            
            query += 'SELECT Id,Name, '+getFieldAPINames('Application__c')+' FROM Application__c WHERE Id =: oldApplicationId';
            Application__c oldApplication = DATABASE.query(query);
            System.debug('oldApplication = '+oldApplication);
            
            Application__c newApplication = oldApplication.clone(false,false,false,false);
            newApplication.Pre_Login__c = preLog.Id;
            newApplication.application_status__c = 'Active';
            newApplication.Stage__c = 'Login';
            newApplication.Old_Application_Number__c = oldApplication.Name;
            newApplication.Old_Application__c = oldApplication.Id;
            newApplication.LMS_Response_Reference__c = '';
            newApplication.Staging_External_Id__c = '';
            newApplication.Created_From_Batch__c = false;
            newApplication.Name = '';
            newApplication.hasVerificationRecords__c = false;
            newApplication.IsTopupDetailsGenerated__c = false; // As per discussion with Ajay on 06/03.
            
            //As per discussion with Anand on 03/02/2023
            newApplication.Tenor_In_Months__c = null;
            newApplication.Amount_Recommended__c  = null;
            INSERT newApplication;
            
            preLog.Application__c = newApplication.Id;
            UPDATE preLog;

            Application_User_Tracking__c autObj = new Application_User_Tracking__c();
            autObj.Application__c = newApplication.Id;
            autObj.Stage__c = 'Login';
            autObj.Owner__c = UserInfo.getUserId();
            autObj.Start_Date__c = System.now();
            autObj.Status__c = 'Pending';
            insert autObj;


            wrap.appId = newApplication.Id;
            wrap.oldAppName = oldApplication.Name;
            wrap.newAppName = [SELECT Id,Name FROM Application__c WHERE Id = :newApplication.Id].Name;
            System.debug('newApplication = '+newApplication);
            oldIdNewIdMap.put(oldApplication.Id, newApplication.Id);
            
            //cloning contentVersion
            //cloneContentVersion(oldApplicationId);
            
            List<Loan_Applicant__c> laList = new List<Loan_Applicant__c>();
            query = '';
            String oldAppId = oldApplication.id;
            query += 'SELECT Id, '+getFieldAPINames('Loan_Applicant__c')+' FROM Loan_Applicant__c WHERE Application__c = :oldAppId';
            System.debug('la query '+query);
            laList = DATABASE.query(query);
   
            System.debug('laList old  = '+laList);
            
            Map<Id, Loan_Applicant__c> oldNewLoanApplicantMap = new Map<Id, Loan_Applicant__c>(); 
            for(Loan_Applicant__c oldLAObj : laList){
                Loan_Applicant__c newLAObj = oldLAObj.clone(false,false,false,false);
                newLAObj.Application__c = newApplication.Id;
                newLAObj.Old_Applicant_Id__c = oldLAObj.Id;
                newLAObj.Is_Bureau_Verified__c = false;
                //newLAObj.LMS_Customer_Info_File_Number__c = '';
                newLAObj.Staging_External_Id__c = '';
                newLAObj.IsDedupeExecuted__c = false; //After discussion with sandeep on 03/02/2023
                oldNewLoanApplicantMap.put(oldLAObj.Id, newLAObj);
            }
            System.debug('oldNewLoanApplicantMap  = '+oldNewLoanApplicantMap);
            if(!oldNewLoanApplicantMap.isEmpty()){
                INSERT oldNewLoanApplicantMap.values();
            }
            
            /* Updating Nach Parties */
            if(oldNewLoanApplicantMap != NULL && (String.isNotBlank(newApplication.NACH_Party_1_ID__c) || String.isNotBlank(newApplication.NACH_Party_2_ID__c))){
                Map<Id,Loan_Applicant__c> loanAppMap = new Map<Id,Loan_Applicant__c>([SELECT Id, Applicant_Name__c FROM Loan_Applicant__c WHERE Id IN : oldNewLoanApplicantMap.values()]);
                if(String.isNotBlank(newApplication.NACH_Party_1_ID__c)){
                    Id laId = oldNewLoanApplicantMap.get(newApplication.NACH_Party_1_ID__c).Id;
                    newApplication.NACH_Party_1_ID__c = laId;
                    newApplication.Nach_Party__c = loanAppMap.get(laId).Applicant_Name__c;
                }
                if(String.isNotBlank(newApplication.NACH_Party_2_ID__c)){
                    Id laId = oldNewLoanApplicantMap.get(newApplication.NACH_Party_2_ID__c).Id;
                    newApplication.NACH_Party_2_ID__c = laId;
                    newApplication.Nach_Party_2__c = loanAppMap.get(laId).Applicant_Name__c;
                }
                UPDATE newApplication;
            }
            
            List<Property__c> oldPropertyList = new List<Property__c>();
            query = '';
            oldAppId = oldApplication.id;
            String recType = 'Pre Login Property Detail';
            query += 'SELECT Id,RecordTypeId, '+getFieldAPINames('Property__c')+' FROM Property__c WHERE RecordType.Name = :recType AND  Application__c = :oldAppId';
            System.debug('prop query '+query);
            oldPropertyList = DATABASE.query(query);

            System.debug('oldPropertyList  = '+oldPropertyList);
            Map<Id, Property__c> oldNewPropertyMap = new Map<Id, Property__c>();
            for(Property__c oldProperty : oldPropertyList){
                Property__c newProperty = oldProperty.clone(false,false,false,false);
                newProperty.Application__c = newApplication.Id;
                newProperty.Old_Property_Id__c = oldProperty.Id;
                newProperty.Login__c = newApplication.Pre_Login__c;
                newProperty.LMS_Collateral_Number__c = '';
                newProperty.Staging_External_Id__c = '';
                oldNewPropertyMap.put(oldProperty.Id, newProperty);
            }                    
            
            System.debug('oldNewPropertyMap  = '+oldNewPropertyMap);
            if(!oldNewPropertyMap.isEmpty()){
                INSERT oldNewPropertyMap.values();
            }
            
            System.debug('oldNewPropertyMap After Insert = '+oldNewPropertyMap.values());
            List<Property_Owners__c> newPropertyOwners = new List<Property_Owners__c>();
            for(Property_Owners__c oldPropertyOwner : [SELECT Id, Loan_Applicant__c, Property__c FROM Property_Owners__c WHERE Property__c IN : oldNewPropertyMap.keyset()]){
                Property_Owners__c newPropertyOwner = oldPropertyOwner.clone(false,false,false,false);
                newPropertyOwner.Property__c = oldNewPropertyMap.get(oldPropertyOwner.Property__c).Id;
                newPropertyOwner.Loan_Applicant__c = oldNewLoanApplicantMap.get(oldPropertyOwner.Loan_Applicant__c).Id;
                newPropertyOwners.add(newPropertyOwner);
            }
            System.debug('newPropertyOwners  = '+newPropertyOwners);
            
            if(!newPropertyOwners.isEmpty()){
                INSERT newPropertyOwners;
            }
            System.debug('newPropertyOwners After Insert = '+newPropertyOwners);
            
          /*  List<Fee_Creation__c> oldFeeCreations = new List<Fee_Creation__c>();
            Map<Id, Fee_Creation__c> oldNewFeeCreationMap = new Map<Id, Fee_Creation__c>();
            query = '';
            oldAppId = oldApplication.id;
            query += 'SELECT Id,RecordTypeId, '+getFieldAPINames('Fee_Creation__c')+' FROM Fee_Creation__c WHERE Application__c = :oldAppId';
            System.debug('prop query '+query);
            oldFeeCreations = DATABASE.query(query);
            
            System.debug('oldFeeCreations  = '+oldFeeCreations);
            for(Fee_Creation__c oldFeeObj : oldFeeCreations){
                Fee_Creation__c newFeeObj = oldFeeObj.clone(false,false,false,false);
                newFeeObj.Application__c = newApplication.Id;                
                if(oldFeeObj.Loan_Applicant__c != NULL && oldNewLoanApplicantMap.containsKey(oldFeeObj.Loan_Applicant__c)){
                    newFeeObj.Loan_Applicant__c = oldNewLoanApplicantMap.get(oldFeeObj.Loan_Applicant__c).Id;
                }
                oldNewFeeCreationMap.put(oldFeeObj.Id, newFeeObj);
            }
            System.debug('oldNewFeeCreationMap  = '+oldNewFeeCreationMap);
            if(!oldNewFeeCreationMap.isEmpty()){
                INSERT oldNewFeeCreationMap.values();
            }
            System.debug('oldNewFeeCreationMap after insert = '+oldNewFeeCreationMap.values());
            
            List<Receipt__c> newReceipts = new List<Receipt__c>();
            List<Receipt__c> oldReceiptList = new List<Receipt__c>();
            query = '';
            oldAppId = oldApplication.id;
            query += 'SELECT Id,Name, '+getFieldAPINames('Receipt__c')+' FROM Receipt__c WHERE Application__c = :oldAppId';
            System.debug('receipt query '+query);
            oldReceiptList = DATABASE.query(query);
 
            for(Receipt__c oldReceipt : oldReceiptList){
                Receipt__c newReceipt = oldReceipt.clone(false,false,false,false);    
                newReceipt.Application__c = newApplication.Id;
                if(oldReceipt.Fee_Code__c != NULL && oldNewFeeCreationMap.containsKey(oldReceipt.Fee_Code__c)){
                    newReceipt.Fee_Code__c = oldNewFeeCreationMap.get(oldReceipt.Fee_Code__c).Id;     
                }                            
                if(oldReceipt.Loan_Applicant__c != NULL && oldNewLoanApplicantMap.containsKey(oldReceipt.Loan_Applicant__c)){
                    newReceipt.Loan_Applicant__c = oldNewLoanApplicantMap.get(oldReceipt.Loan_Applicant__c).Id;
                }  
                newReceipts.add(newReceipt);
            }
            System.debug('newReceipts  = '+newReceipts);
            if(!newReceipts.isEmpty()){
                INSERT newReceipts;
            }*/
            // if(!oldNewLoanApplicantMap.isEmpty()){
            //     for(String loanAppId : oldNewLoanApplicantMap.keySet()){
            //         oldIdNewIdMap.put(loanAppId,oldNewLoanApplicantMap.get(loanAppId).Id);
            //     }
            // }
            
            // if(!oldNewPropertyMap.isEmpty()){
            //     for(String propId : oldNewPropertyMap.keySet()){
            //         oldIdNewIdMap.put(propId,oldNewPropertyMap.get(propId).Id);
            //     }
            // }
            
            // Boolean isFinOne = oldApplication.LMS_Response_Reference__c != null && recTypeName == '2. Re-login' ? true : false;
            
            // cloneFIVCRecords(newApplication,isFinOne);
            // cloneFIVBRecords(newApplication,isFinOne);
            // cloneOnlineECRecords(newApplication,isFinOne);
            FS_DocumentUploadController.refreshRecords(newApplication.Id);
            return wrap;
        } catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void cloneVerificationData(String applicationId){
        Savepoint sp = Database.setSavepoint();
        try {
            oldIdNewIdMap = new Map<String,String>();
            Application__c newApplication = [SELECT Id, Pre_Login__c,Pre_Login__r.RecordType.Name, Old_Application__c, Old_Application__r.LMS_Response_Reference__c FROM Application__c WHERE Id =: applicationId LIMIT 1];
            String recTypeName = newApplication.Pre_Login__r.RecordType.Name;
            oldIdNewIdMap.put(newApplication.Old_Application__c, newApplication.Id);

            List<Loan_Applicant__c> loanApplicants = new List<Loan_Applicant__c>();
            loanApplicants = [SELECT 
                              Id, Customer_Information__c, Application__c, Old_Applicant_Id__c
                              FROM Loan_Applicant__c 
                              WHERE Application__c =: applicationId
                              AND Old_Applicant_Id__c != NULL];
            
            for(Loan_Applicant__c loanApplicant : loanApplicants){
                oldIdNewIdMap.put(loanApplicant.Old_Applicant_Id__c, loanApplicant.Id);
            }

            for(Property__c newPLProperty : [SELECT 
                                             Id, RecordTypeId, Application__c, Title_Deed_Number__c, Title_Deed_Type__c, Property_Type__c,
                                             Village__c, Taluka__c, City__c, State__c, Pincode__c, Property_Address__c, Title_Deed_Date__c,
                                             Old_Property_Id__c FROM 
                                             Property__c WHERE 
                                             RecordType.Name = 'Pre Login Property Detail' 
                                             AND Application__c =: applicationId])
            {
                oldIdNewIdMap.put(newPLProperty.Old_Property_Id__c, newPLProperty.Id);
            }
            
            Boolean isFinOne = newApplication.Old_Application__r.LMS_Response_Reference__c != null && recTypeName == '2. Re-login' ? true : false;

            cloneFIVCRecords(newApplication,isFinOne);
            cloneFIVBRecords(newApplication,isFinOne);
            cloneOnlineECRecords(newApplication,isFinOne);
            newApplication.hasVerificationRecords__c = true;
            UPDATE newApplication;
            cloneExistingApplicationDataTillPC(newApplication.Id);

        } catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void cloneFIVCRecords(Application__c newApplication, Boolean isFinOne){
        Savepoint sp = Database.setSavepoint();
        try{
            Verification__c verificationFIVC = new Verification__c();
            verificationFIVC.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
            verificationFIVC.Application__c = newApplication.Id;
            verificationFIVC.Status__c = 'Pending';
            verificationFIVC.Initiate_From__c = 'Pre Login';
            INSERT verificationFIVC;
            
            System.debug('verificationFIVC= '+verificationFIVC);
            List<Property__c> fivcProperties = new List<Property__c>();
            String query = '';
            String oldAppId = newApplication.Old_Application__c;
            String recType = 'FIV-C Property Detail';
            query += 'SELECT Id, '+getFieldAPINames('Property__c')+' FROM Property__c WHERE RecordType.Name = :recType AND  Application__c = :oldAppId';
            System.debug('prop query '+query);
            fivcProperties = DATABASE.query(query);
            Map<Id,Property__c> oldNewPropertyMap = new Map<Id,Property__c>();
            for(Property__c oldProperty : fivcProperties){
                Property__c newProperty = oldProperty.clone(false,false,false,false); 
                newProperty.Application__c = newApplication.Id;       
                newProperty.Login__c = newApplication.Pre_Login__c;     
                newProperty.Old_Property_Id__c = oldProperty.Id;
                if(oldProperty.Property__c != NULL && oldIdNewIdMap.containsKey(oldProperty.Property__c)){
                    newProperty.Property__c = oldIdNewIdMap.get(oldProperty.Property__c);
                }
                oldNewPropertyMap.put(oldProperty.Id, newProperty);
            }
            System.debug('oldNewPropertyMap= '+oldNewPropertyMap);
            if(!oldNewPropertyMap.isEmpty()){
                INSERT oldNewPropertyMap.values();
            }
            System.debug('After INsert oldNewPropertyMap= '+oldNewPropertyMap);
            
            List<CommonObject__c> enquiryList = new List<CommonObject__c>();
            for(CommonObject__c enqOldObj : [SELECT 
                                             Id, Application__c, Property__c, Enquiry_Name__c, Enquiry_Contact_Number__c, Enquiry_Market_Value__c, 
                                             Building_Floor__c, Length_ft__c, Object_Type__c, Value_per_Sq_ft__c, Width_ft__c
                                             FROM CommonObject__c 
                                             WHERE Application__c =: newApplication.Old_Application__c
                                             AND Object_Type__c IN ('Enquiry','Building Floors') 
                                             AND Property__r.RecordType.Name = 'FIV-C Property Detail'])
            {
                CommonObject__c enqNewObj = enqOldObj.clone(false,false,false,false);
                enqNewObj.Application__c = newApplication.Id;
                if(enqOldObj.Property__c != NULL && oldNewPropertyMap.containsKey(enqOldObj.Property__c)){
                    enqNewObj.Property__c = oldNewPropertyMap.get(enqOldObj.Property__c).Id;
                }
                enquiryList.add(enqNewObj);
            }
            System.debug('enquiryList= '+enquiryList);
            if(!enquiryList.isEmpty()){
                INSERT enquiryList;
            }
            System.debug('after insert enquiryList= '+enquiryList);
            
            if(!isFinOne){
                List<Character__c> oldCharacterRecords = new List<Character__c>();
                query = '';
                oldAppId = newApplication.Old_Application__c;
                recType = 'FIV-C Character';
                query += 'SELECT Id, '+getFieldAPINames('Character__c')+' FROM Character__c WHERE RecordType.Name = :recType AND  Application__c = :oldAppId';
                System.debug('Character__c query '+query);
                oldCharacterRecords = DATABASE.query(query);
 
                System.debug('oldCharacterRecords= '+oldCharacterRecords);
                List<Character__c> newCharacterRecords = new List<Character__c>();
                for(Character__c oldCharacter : oldCharacterRecords){
                    Character__c newCharacter = oldCharacter.clone(false,false,false,false);
                    newCharacter.Verification__c = verificationFIVC.Id;
                    newCharacter.Application__c = newApplication.Id;
                    if(oldCharacter.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldCharacter.Loan_Applicant__c)){
                        newCharacter.Loan_Applicant__c = oldIdNewIdMap.get(oldCharacter.Loan_Applicant__c);
                    }
                    newCharacterRecords.add(newCharacter);
                }
                
                System.debug('newCharacterRecords= '+newCharacterRecords);
                if(!newCharacterRecords.isEmpty()){
                    INSERT newCharacterRecords;
                }
                System.debug('after insert newCharacterRecords= '+newCharacterRecords);
                
                List<Capability__c> oldCapabilityRecords = new List<Capability__c>();
                query = '';
                oldAppId = newApplication.Old_Application__c;
                recType = 'FIV-C Capability';
                query += 'SELECT Id, '+getFieldAPINames('Capability__c')+' FROM Capability__c WHERE RecordType.Name = :recType AND  Application__c = :oldAppId';
                System.debug('Capability__c query '+query);
                oldCapabilityRecords = DATABASE.query(query);
                
                List<Capability__c> newCapabilityRecords = new List<Capability__c>();
                System.debug('oldCapabilityRecords= '+oldCapabilityRecords);
                for(Capability__c oldCapability : oldCapabilityRecords){
                    Capability__c newCapability = oldCapability.clone(false,false,false,false);
                    newCapability.Verification__c = verificationFIVC.Id;
                    newCapability.Application__c = newApplication.Id;
                    if(oldCapability.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldCapability.Loan_Applicant__c)){
                        newCapability.Loan_Applicant__c = oldIdNewIdMap.get(oldCapability.Loan_Applicant__c);
                    }
                    newCapabilityRecords.add(newCapability);
                }
                System.debug('newCapabilityRecords= '+newCapabilityRecords);
                if(!newCapabilityRecords.isEmpty()){
                    INSERT newCapabilityRecords;
                }
                System.debug('after insert newCapabilityRecords= '+newCapabilityRecords);
                List<Revisit__c> oldRevisitRecords = new List<Revisit__c>();
                query = '';
                oldAppId = newApplication.Old_Application__c;
                query += 'SELECT Id, '+getFieldAPINames('Revisit__c')+' FROM Revisit__c WHERE Verification__r.Application__c = :oldAppId';
                System.debug('Character__c query '+query);
                oldRevisitRecords = DATABASE.query(query);
    
                System.debug('oldRevisitRecords= '+oldRevisitRecords);
                List<Revisit__c> newRevisitRecords = new List<Revisit__c>();
                for(Revisit__c oldRevisit : oldRevisitRecords){
                    Revisit__c newRevisit = oldRevisit.clone(false,false,false,false);
                    newRevisit.Verification__c = verificationFIVC.Id;
                    newRevisitRecords.add(newRevisit);
                }
                System.debug('newRevisitRecords= '+newRevisitRecords);
                if(!newRevisitRecords.isEmpty()){
                    INSERT newRevisitRecords;
                }
                System.debug('after insert newRevisitRecords= '+newRevisitRecords);
            }
        }
        catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void cloneFIVBRecords(Application__c newApplication, Boolean isFinOne){
        Savepoint sp = Database.setSavepoint();
        try{
            List<Verification__c> oldFIVB = new List<Verification__c>();
            String query = '';
            String oldAppId = newApplication.Old_Application__c;
            String recType = 'FIV - B';
            query += 'SELECT Id, '+getFieldAPINames('Verification__c')+' FROM Verification__c WHERE RecordType.Name = :recType AND  Application__c = :oldAppId ORDER BY CreatedDate DESC LIMIT 1';
            System.debug('Character__c query '+query);
            oldFIVB = DATABASE.query(query);
       
            System.debug('oldFIVB = '+oldFIVB);
            Verification__c verificationFIVB = oldFIVB.get(0).clone(false,false,false,false);
            verificationFIVB.Application__c = newApplication.Id;
            verificationFIVB.Status__c = 'Pending';
            verificationFIVB.Initiate_From__c = 'Pre Login';
            INSERT verificationFIVB;
            System.debug('New verificationFIVB = '+verificationFIVB);
            
            List<Property__c> fivbProperties = new List<Property__c>();
            query = '';
            oldAppId = newApplication.Old_Application__c;
            recType = 'FIV-B Property Detail';
            query += 'SELECT Id, '+getFieldAPINames('Property__c')+' FROM Property__c WHERE RecordType.Name = :recType AND  Application__c = :oldAppId';
            System.debug('Character__c query '+query);
            fivbProperties = DATABASE.query(query);
    
            List<Property__c> newFIVBProperties = new List<Property__c>();
            System.debug('fivbProperties = '+fivbProperties);
            for(Property__c oldProperty : fivbProperties){
                Property__c newProperty = oldProperty.clone(false,false,false,false); 
                newProperty.Application__c = newApplication.Id;       
                newProperty.Old_Property_Id__c = oldProperty.Id;     
                newProperty.Login__c = newApplication.Pre_Login__c;
                if(oldProperty.Property__c != NULL && oldIdNewIdMap.containsKey(oldProperty.Property__c)){
                    newProperty.Property__c = oldIdNewIdMap.get(oldProperty.Property__c);
                }
                newFIVBProperties.add(newProperty);
            }
            System.debug('newFIVBProperties = '+newFIVBProperties);
            if(!newFIVBProperties.isEmpty()){
                INSERT newFIVBProperties;
            }
            System.debug('After Insert newFIVBProperties = '+newFIVBProperties);
            
            if(!isFinOne){
                List<Cashflow__c> oldCashflows = new List<Cashflow__c>();
                String queryCashFlow = 'SELECT Id, '+getFieldAPINames('Cashflow__c')+' FROM Cashflow__c WHERE Loan_Applicant__r.Application__c =:oldAppId';
                oldCashflows = Database.query(queryCashFlow);

                System.debug('oldCashflows = '+oldCashflows);
                
                List<Cashflow__c> newCashflows = new List<Cashflow__c>();
                for(Cashflow__c oldCashflow : oldCashflows){
                    Cashflow__c newCaseflow = oldCashflow.clone(false,false,false,false);
                    newCaseflow.Verification__c = verificationFIVB.Id;
                    if(oldCashflow.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldCashflow.Loan_Applicant__c)){
                        newCaseflow.Loan_Applicant__c = oldIdNewIdMap.get(oldCashflow.Loan_Applicant__c);
                    }
                    newCashflows.add(newCaseflow);
                }
                System.debug('newCashflows = '+newCashflows);
                if(!newCashflows.isEmpty()){
                    INSERT newCashflows;
                }
                System.debug('After Insert newCashflows = '+newCashflows);
                List<Loan_Applicant__c> loanApplicants = [SELECT Id FROM Loan_Applicant__c WHERE Application__c =: newApplication.Old_Application__c];
                
                List<Character__c> oldCharacters = new List<Character__c>();
                String rcTypeFivB = 'FIV-B Character';
                String queryCharacter = 'SELECT Id, '+getFieldAPINames('Character__c')+' FROM Character__c WHERE Loan_Applicant__c IN : loanApplicants AND RecordType.Name =:rcTypeFivB';
                oldCharacters = Database.query(queryCharacter);
                
                System.debug('oldCharacters = '+oldCharacters);
                List<Character__c> newCharacters = new List<Character__c>();
                for(Character__c oldCharacter : oldCharacters){
                    Character__c newCharacter = oldCharacter.clone(false,false,false,false);
                    newCharacter.Verification__c = verificationFIVB.Id;
                    if(oldCharacter.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldCharacter.Loan_Applicant__c)){
                        newCharacter.Loan_Applicant__c = oldIdNewIdMap.get(oldCharacter.Loan_Applicant__c);
                    }
                    newCharacters.add(newCharacter);
                }
                System.debug('newCharacters = '+newCharacters);
                
                if(!newCharacters.isEmpty()){
                    INSERT newCharacters;
                }
                System.debug('After INsert newCharacters = '+newCharacters);
            }
        }
        catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void cloneOnlineECRecords(Application__c newApplication, Boolean isFinOne){
        Savepoint sp = Database.setSavepoint();
        try{
            Verification__c verificationOnlineEC = new Verification__c();
            verificationOnlineEC.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('Online EC').getRecordTypeId();
            verificationOnlineEC.Application__c = newApplication.Id;
            verificationOnlineEC.Status__c = 'Pending';
            verificationOnlineEC.Initiate_From__c = 'Pre Login';
            INSERT verificationOnlineEC;
            String oldAppId = newApplication.Old_Application__c;
            System.debug('new verificationOnlineEC= '+verificationOnlineEC);
            String recordTypeName = 'Online EC Property Detail';
            List<Property__c> onlineECProperties = new List<Property__c>();
            
            String query = 'SELECT Id, RecordTypeId, '+getFieldAPINames('Property__c')+' FROM Property__c WHERE RecordType.Name =:recordTypeName AND Application__c = :oldAppId';
            onlineECProperties = DATABASE.query(query);
       
            List<Property__c> newOnlineECProperties = new List<Property__c>();
            System.debug('Old onlineECProperties= '+onlineECProperties);
            for(Property__c oldProperty : onlineECProperties){
                Property__c newProperty = oldProperty.clone(false,false,false,false); 
                newProperty.Application__c = newApplication.Id;       
                newProperty.Old_Property_Id__c = oldProperty.Id;     
                newProperty.Login__c = newApplication.Pre_Login__c;     
                if(oldProperty.Property__c != NULL && oldIdNewIdMap.containsKey(oldProperty.Property__c)){
                    newProperty.Property__c = oldIdNewIdMap.get(oldProperty.Property__c);
                }
                newOnlineECProperties.add(newProperty);
            }
            System.debug('newOnlineECProperties= '+newOnlineECProperties);
            if(!newOnlineECProperties.isEmpty()){
                INSERT newOnlineECProperties;
            }
            System.debug('After Insert newOnlineECProperties= '+newOnlineECProperties);
        }
        catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string cloneExistingApplicationDataTillPC(String applicationId){
        Savepoint sp = Database.setSavepoint();
        try {
            oldIdNewIdMap = new Map<String,String>();
            Application__c newApplication = [SELECT Id, Pre_Login__c,Pre_Login__r.RecordType.Name, Old_Application__c, Old_Application__r.LMS_Response_Reference__c FROM Application__c WHERE Id =: applicationId LIMIT 1];
            String recTypeName = newApplication.Pre_Login__r.RecordType.Name;
            oldIdNewIdMap.put(newApplication.Old_Application__c, newApplication.Id);                    
            
            List<Loan_Applicant__c> loanApplicants = new List<Loan_Applicant__c>();
            loanApplicants = [SELECT 
                              Id, Customer_Information__c, Application__c, Old_Applicant_Id__c
                              FROM Loan_Applicant__c 
                              WHERE Application__c =: applicationId
                              AND Old_Applicant_Id__c != NULL];
            
            for(Loan_Applicant__c loanApplicant : loanApplicants){
                oldIdNewIdMap.put(loanApplicant.Old_Applicant_Id__c, loanApplicant.Id);
            }
            
            
            List<Property__c> oldPropertyList = new List<Property__c>();
            
            for(Property__c newPLProperty : [SELECT 
                                             Id, RecordTypeId, Application__c, Title_Deed_Number__c, Title_Deed_Type__c, Property_Type__c,
                                             Village__c, Taluka__c, City__c, State__c, Pincode__c, Property_Address__c, Title_Deed_Date__c,
                                             Old_Property_Id__c FROM 
                                             Property__c WHERE 
                                             RecordType.Name = 'Pre Login Property Detail' 
                                             AND Application__c =: applicationId])
            {
                oldIdNewIdMap.put(newPLProperty.Old_Property_Id__c, newPLProperty.Id);
            }
            
            Boolean isFinOne = newApplication.Old_Application__r.LMS_Response_Reference__c != null && recTypeName == '2. Re-login' ? true : false;
            cloneLeadDetailData(newApplication, isFinOne);
            clonePCData(newApplication, isFinOne);
            
            return 'success';
        } catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void cloneLeadDetailData(Application__c newApplication, Boolean isFinOne){
        Savepoint sp = Database.setSavepoint();
        try{
            System.debug(' ####cloneLeadDetailData#### ');
            List<Property__c> oldLeadDetailProperties = new List<Property__c>();
            String oldAppId = newApplication.Old_Application__c;
            String recordTypeName = 'Lead Detail';
            String query = 'SELECT Id, RecordTypeId, '+getFieldAPINames('Property__c')+' FROM Property__c WHERE RecordType.Name =:recordTypeName AND Application__c =:oldAppId';
            oldLeadDetailProperties = Database.query(query);
        
            System.debug('oldLeadDetailProperties  = '+oldLeadDetailProperties);
            Map<Id,Property__c> oldNewPropertyMap = new Map<Id,Property__c>();
            for(Property__c oldLDProperty : oldLeadDetailProperties){
                Property__c newProperty = oldLDProperty.clone(false,false,false,false); 
                newProperty.Application__c = newApplication.Id;       
                newProperty.Login__c = newApplication.Pre_Login__c;     
                newProperty.Old_Property_Id__c = oldLDProperty.Id;
                if(oldLDProperty.Property__c != NULL && oldIdNewIdMap.containsKey(oldLDProperty.Property__c)){
                    newProperty.Property__c = oldIdNewIdMap.get(oldLDProperty.Property__c);
                }
                oldNewPropertyMap.put(oldLDProperty.Id, newProperty);
            }
            
            System.debug('oldNewPropertyMap  = '+oldNewPropertyMap);
            if(!oldNewPropertyMap.isEmpty()){
                INSERT oldNewPropertyMap.values();
            }
            System.debug('After INSERT oldNewPropertyMap  = '+oldNewPropertyMap);
            
            if(!isFinOne){
                System.debug('ISFINONE LEADDETAILS ');
                String queryEducation = 'SELECT Id, '+getFieldAPINames('Education__c')+' FROM Education__c WHERE Application__c =:oldAppId';
                List<Education__c> newEducations = new List<Education__c>();
                for(Education__c oldEdu : Database.query(queryEducation)){
                                               Education__c newEdu = oldEdu.clone(false,false,false,false);       
                                               newEdu.Application__c = newApplication.Id;                                    
                                               if(oldEdu.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldEdu.Loan_Applicant__c)){
                                                   newEdu.Loan_Applicant__c = oldIdNewIdMap.get(oldEdu.Loan_Applicant__c);
                                               }
                                               newEducations.add(newEdu);
                                           }
                System.debug('newEducation = '+newEducations);
                if(!newEducations.isEmpty()){
                    INSERT newEducations;
                }
                System.debug('AFTER INSERT newEducation = '+newEducations);
                
                List<Family_Detail__c> newFamilyDetails = new List<Family_Detail__c>();
                Set<String> laIds = oldIdNewIdMap.keySet();
                System.debug('laIds = '+laIds);
                String queryFamilDetail = 'SELECT Id, '+getFieldAPINames('Family_Detail__c')+' FROM Family_Detail__c WHERE Loan_Applicant__c != NULL AND Loan_Applicant__c IN: laIds';
                System.debug('queryFamilDetail   = '+queryFamilDetail);
                for(Family_Detail__c oldFD : Database.query(queryFamilDetail)){
                                                  Family_Detail__c newFD = oldFD.clone(false,false,false,false);              
                                                  if(oldFD.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldFD.Loan_Applicant__c)){
                                                      newFD.Loan_Applicant__c = oldIdNewIdMap.get(oldFD.Loan_Applicant__c);
                                                  }
                                                  newFamilyDetails.add(newFD);
                                              }
                System.debug('newFamilyDetails = '+newFamilyDetails);
                if(!newFamilyDetails.isEmpty()){
                    INSERT newFamilyDetails;
                }
                System.debug('AFTER INSERT newFamilyDetails = '+newFamilyDetails);
                
                List<Employment_Details__c> newEmployeeDetails = new List<Employment_Details__c>();                
                String queryEmployementDetails = 'SELECT Id, Name, '+getFieldAPINames('Employment_Details__c')+' FROM Employment_Details__c WHERE Loan_Applicant__r.APplication__c =:oldAppId';
                for(Employment_Details__c oldEmpDetail : Database.query(queryEmployementDetails)){
                                                              Employment_Details__c newEmpDetail = oldEmpDetail.clone(false,false,false,false);         
                                                              newEmpDetail.Application__c = newApplication.Id;                     
                                                              if(oldEmpDetail.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldEmpDetail.Loan_Applicant__c)){
                                                                  newEmpDetail.Loan_Applicant__c = oldIdNewIdMap.get(oldEmpDetail.Loan_Applicant__c);
                                                              }
                                                              newEmployeeDetails.add(newEmpDetail);
                                                          }
                
                System.debug('newEmployeeDetails = '+newEmployeeDetails);
                if(!newEmployeeDetails.isEmpty()){
                    INSERT newEmployeeDetails;
                }
                System.debug('AFTER INSERT newEmployeeDetails = '+newEmployeeDetails);
                
                List<Income__c> newIncomeDetails = new List<Income__c>();
                String queryIncome = 'SELECT Id, Name, '+getFieldAPINames('Income__c')+' FROM Income__c WHERE Application__c =:oldAppId';
                for(Income__c oldIncome : Database.query(queryIncome)){
                                               Income__c newIncome = oldIncome.clone(false,false,false,false);         
                                               newIncome.Application__c = newApplication.Id;                     
                                               if(oldIncome.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldIncome.Loan_Applicant__c)){
                                                   newIncome.Loan_Applicant__c = oldIdNewIdMap.get(oldIncome.Loan_Applicant__c);
                                               }
                                               newIncomeDetails.add(newIncome);
                                           }
                System.debug('newIncomeDetails = '+newIncomeDetails);
                if(!newIncomeDetails.isEmpty()){
                    INSERT newIncomeDetails;
                }
                System.debug('AFTER INSERT newIncomeDetails = '+newIncomeDetails);
                
                List<Bank_Detail__c> newBankDetails = new List<Bank_Detail__c>();
                String queryBankDetails = 'SELECT Id, Name, '+getFieldAPINames('Bank_Detail__c')+' FROM Bank_Detail__c WHERE Application__c =:oldAppId';
                for(Bank_Detail__c oldBank : Database.query(queryBankDetails)){
                                                  Bank_Detail__c newBank = oldBank.clone(false,false,false,false);         
                                                  newBank.Application__c = newApplication.Id;                     
                                                  if(oldBank.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldBank.Loan_Applicant__c)){
                                                      newBank.Loan_Applicant__c = oldIdNewIdMap.get(oldBank.Loan_Applicant__c);
                                                  }
                                                  newBankDetails.add(newBank);
                                              }
                System.debug('newBankDetails = '+newBankDetails);
                if(!newBankDetails.isEmpty()){
                    INSERT newBankDetails;
                }
                System.debug('AFTER INSERT newBankDetails = '+newBankDetails);
                
                
                List<Reference__c> newReferences = new List<Reference__c>();
                String queryReference = 'SELECT Id, '+getFieldAPINames('Reference__c')+' FROM Reference__c WHERE Loan_Applicant__r.Application__c =:oldAppId';
                for(Reference__c oldReference : Database.query(queryReference)){
                                                     Reference__c newReference = oldReference.clone(false,false,false,false);     
                                                     if(oldReference.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldReference.Loan_Applicant__c)){
                                                         newReference.Loan_Applicant__c = oldIdNewIdMap.get(oldReference.Loan_Applicant__c);
                                                     }
                                                     newReferences.add(newReference);
                                                 }
                System.debug('newReferences = '+newReferences);
                if(!newReferences.isEmpty()){
                    INSERT newReferences;
                }
                System.debug('AFTER INSERT newReferences = '+newReferences);
            }
        }
        catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void clonePCData(Application__c newApplication, Boolean isFinOne){
        Savepoint sp = Database.setSavepoint();
        try{
            System.debug(' ####clonePCData#### ');
            List<Property__c> oldPcProperties = new List<Property__c>();
            String oldAppId = newApplication.Old_Application__c;
            String recordTypeName = 'PC Property Detail';
            String query = 'SELECT Id, RecordTypeId, '+getFieldAPINames('Property__c')+' FROM Property__c WHERE RecordType.Name =:recordTypeName AND Application__c =:oldAppId';
            oldPcProperties = Database.query(query);
        
            System.debug('oldPcProperties = '+oldPcProperties);
            String rcTypePc = 'PC';
            String queryPC = 'SELECT Id, RecordTypeId, '+getFieldAPINames('Verification__c')+' FROM Verification__c WHERE Application__c =:oldAppId AND RecordType.Name =:rcTypePc ORDER BY CreatedDate DESC LIMIT 1';
            
            List<Verification__c> oldPC = Database.query(queryPC);
            System.debug('oldPC = '+oldPC);
            Verification__c verificationPC = oldPC.get(0).clone(false,false,false,false);
            verificationPC.Application__c = newApplication.Id;
            verificationPC.Status__c = 'Pending';
            INSERT verificationPC;
            System.debug('New verificationPC = '+verificationPC);
            
            Map<Id,Property__c> oldNewPropertyMap = new Map<Id,Property__c>();
            for(Property__c oldPCProperty : oldPcProperties){
                Property__c newProperty = oldPCProperty.clone(false,false,false,false); 
                newProperty.Application__c = newApplication.Id;       
                newProperty.Login__c = newApplication.Pre_Login__c;     
                newProperty.Old_Property_Id__c = oldPCProperty.Id;
                if(oldPCProperty.Property__c != NULL && oldIdNewIdMap.containsKey(oldPCProperty.Property__c)){
                    newProperty.Property__c = oldIdNewIdMap.get(oldPCProperty.Property__c);
                }
                oldNewPropertyMap.put(oldPCProperty.Id, newProperty);
            }
            System.debug('oldNewPropertyMap = '+oldNewPropertyMap);
            if(!oldNewPropertyMap.isEmpty()){
                INSERT oldNewPropertyMap.values();
            }
            System.debug('After Insert oldNewPropertyMap = '+oldNewPropertyMap);
            
            /*----------Clone Legal APproval Property Start----------*/
            List<Property__c> legalApprovalProperty = new List<Property__c>();
            for(Property__c property : [SELECT 
                                        Id, Name,Loan_Applicant__c,Login__c,Old_Property_Id__c ,Application__c,Property_Type__c ,Property__c,
                                        Title_Deed_Type__c,Title_Deed_Number__c,Title_Deed_Date__c,Property_Address__c,Pincode__c 
                                        FROM Property__c
                                        WHERE Application__c = :newApplication.Old_Application__c AND RecordType.Name = 'Legal Approval'])
            {
                Property__c newProperty = property.clone(false,false,false,false); 
                newProperty.Application__c = newApplication.Id;       
                newProperty.Login__c = property.Login__c;    
                newProperty.Property__c = oldIdNewIdMap.get(property.Property__c); 
                newProperty.Old_Property_Id__c = property.Id;
                newProperty.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
                legalApprovalProperty.add(newProperty);
            }
            
            if(!legalApprovalProperty.isEmpty()){
                insert legalApprovalProperty;
            }
            
            /*----------Clone Legal APproval Property End----------*/
            if(!isFinOne){
                System.debug('ISFINONE IN PC');
                List<Character__c> oldCharacterRecords = new List<Character__c>();
                String rcType = 'PC Character';
                String getQuery = 'SELECT Id, '+getFieldAPINames('Character__c')+' FROM Character__c WHERE RecordType.Name =:rcType AND Application__c =:oldAppId';
                oldCharacterRecords = Database.query(getQuery);
                
                List<Character__c> newCharacterRecords = new List<Character__c>();
                for(Character__c oldCharacter : oldCharacterRecords){
                    Character__c newCharacter = oldCharacter.clone(false,false,false,false);
                    newCharacter.Verification__c = verificationPC.Id;
                    newCharacter.Application__c = newApplication.Id;
                    if(oldCharacter.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldCharacter.Loan_Applicant__c)){
                        newCharacter.Loan_Applicant__c = oldIdNewIdMap.get(oldCharacter.Loan_Applicant__c);
                    }
                    newCharacterRecords.add(newCharacter);
                }
                System.debug('newCharacterRecords = '+newCharacterRecords);
                if(!newCharacterRecords.isEmpty()){
                    INSERT newCharacterRecords;
                }
                System.debug('After INSERT newCharacterRecords = '+newCharacterRecords);
                
                List<Capability__c> oldCapabilityRecords = new List<Capability__c>();
                String pcRecordType = 'PC Capability';
                String queryPcRecords = 'SELECT Id, '+getFieldAPINames('Capability__c')+' FROM Capability__c WHERE RecordType.Name =:pcRecordType AND Application__c =:oldAppId';
                oldCapabilityRecords = Database.query(queryPcRecords);
             
                
                List<Capability__c> newCapabilityRecords = new List<Capability__c>();
                for(Capability__c oldCapability : oldCapabilityRecords){
                    Capability__c newCapability = oldCapability.clone(false,false,false,false);
                    newCapability.Verification__c = verificationPC.Id;
                    newCapability.Application__c = newApplication.Id;
                    if(oldCapability.Loan_Applicant__c != NULL && oldIdNewIdMap.containsKey(oldCapability.Loan_Applicant__c)){
                        newCapability.Loan_Applicant__c = oldIdNewIdMap.get(oldCapability.Loan_Applicant__c);
                    }
                    newCapabilityRecords.add(newCapability);
                }
                
                System.debug('newCapabilityRecords = '+newCapabilityRecords);
                if(!newCapabilityRecords.isEmpty()){
                    INSERT newCapabilityRecords;
                }
                System.debug('After INSERT newCapabilityRecords = '+newCapabilityRecords);
            }
        }
        catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void cloneContentVersion(String oldAppId){
        Savepoint sp = Database.setSavepoint();
        try{
            if(!oldIdNewIdMap.isEmpty()){
                String newAppId = oldIdNewIdMap.get(oldAppId);
                List<ContentDocumentLink> listOfOldContentDoc = [SELECT ContentDocumentId,ContentDocument.Title, 
                                                                 ContentDocument.ContentModifiedDate, ContentDocument.ContentSize
                                                                 FROM ContentDocumentLink
                                                                 WHERE LinkedEntityId = :oldAppId];
                if(!listOfOldContentDoc.isEmpty()){
                    List<ContentDocumentLink> listOfNewContentDoc = new List<ContentDocumentLink>();
                    for(ContentDocumentLink file: listOfOldContentDoc){
                        ContentDocumentLink newCon = file.clone();
                        newCon.LinkedEntityId = newAppId;
                        newCon.ShareType = 'V';
                        listOfNewContentDoc.add(newCon);
                        
                    }
                    if(!listOfNewContentDoc.isEmpty()){
                        INSERT listOfNewContentDoc;
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('Exception  = '+e);
            System.debug('Exception  = '+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }


    //Cloning newly created property from pre-login for Property_RecordTypes_To_Clone Custom Label
    @AuraEnabled
    public static void clonePropertyNew(String newAppId,String recordType){
        //List<String> recordTypeNames = recordTypesToCreate.split(',');
        String creF = '	Pre Login';
        String query = 'SELECT Id, RecordTypeId, '+getFieldAPINames('Property__c')+' FROM Property__c WHERE RecordType.Name =:recordType AND Application__c =:newAppId AND Created_From__c = :creF';
        List<Property__c> newPropList = new List<Property__c>();
        List<Property__c> oldPropList = new List<Property__c>();
        List<Property__c> listOfProp = new List<Property__C>();
        listOfProp = Database.query(query);
        if(listOfProp != NULL && !listOfProp.isEmpty()){
            for(Property__c objProp : listOfProp){
                Property__c newProperty = objProp.clone(false,false,false,false);
                newProperty.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
                newProperty.Application__c = objProp.Application__c;
                newProperty.Property__c = objProp.Id;
                newPropList.add(newProperty);
            }
            
            if(newPropList.size() > 0){
                INSERT newPropList; 
            }
        }
    }
    
    @AuraEnabled
    public static String getFieldAPINames(String objectAPIName){
        String fields = '';
        SObjectType sObjectType = Schema.getGlobalDescribe().get(objectAPIName);
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldInfo = fieldMap.get(fieldName).getDescribe(); 
            if(fieldInfo.isCustom()){
                System.debug('APINAME '+fieldName);
                fields += fieldName+',';
            }
        }
        System.debug('fields '+fields);
        fields = fields.removeEnd(',');
        return fields;
    }
    
    public class Wrapper{
        @auraEnabled public String preloginId;
        @auraEnabled public String appId;
        @auraEnabled public String oldAppName;
        @auraEnabled public String newAppName;
    }
}