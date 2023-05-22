public without sharing class FeeReceiptController {
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getReceiptData(String applicationId, String stage){
        System.debug('applicationId=  '+applicationId + stage);
        Set<String> recIds = new Set<String>();
       if(stage == 'Lead Detail' || stage == 'Disbursal Maker' || stage == 'Disbursal Author' || stage == 'Agreement Execution'){
            for(Receipt__c rec : [SELECT Id,Approval_Status__c FROM Receipt__c WHERE Application__c  =: applicationId]){
                recIds.add(rec.Id);
            }
        }
        else if(stage == 'Process Credit' || stage == 'Approval Credit'){
            for(Receipt__c rec : [SELECT Id,Approval_Status__c FROM Receipt__c WHERE Application__c  =: applicationId ]){
                recIds.add(rec.Id);
            }
        }
        else if(stage == 'Pre Login'){
            for(Receipt__c rec : [SELECT Id,Approval_Status__c FROM Receipt__c WHERE Application__c  =: applicationId AND Fee_Code__r.RecordType.DeveloperName = 'Fee']){
                recIds.add(rec.Id);
            }
        }
        System.debug('propIds=  '+recIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Receipt_Metadata';
        genericDTObj.IDS_SET = recIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();  
    }
    @AuraEnabled
    public static Map<Id,String> getCashiers(){
        System.debug('Current User '+userinfo.getuserid());
        /* Account objAcc = [SELECT Id,Branch_Master__c,Branch_Master__r.Name
From Account
WHERE User__c = :userinfo.getuserid()];
List<Account> bmList=[SELECT id,User__c ,User__r.Designation__c,User__r.Name,Branch_Master__c,Branch_Master__r.name 
FROM Account 
WHERE Branch_Master__c=:objAcc.Branch_Master__c AND User__r.Designation__c='Cashier'];*/
        //List<User> bmList = [SELECT Id, Designation__c, Name FROM User WHERE Id = :userinfo.getuserid() AND Designation__c='Cashier'];
        List<User> bmList = [SELECT Id, Designation__c, Name FROM User WHERE Designation__c='Cashier'];
        Map<Id,String> cashierMap = new Map<Id,String>();
        
        if(bmList.size()>0){
            for(User usr : bmList){
                cashierMap.put(usr.Id,usr.Name);
            }
        }
        System.debug('Map '+cashierMap);
        if(cashierMap.size() > 0)
            return cashierMap;
        else
            return null;
    }
    //Receipt Submission For Approval
    @AuraEnabled
    public static String submitReceiptForApproval(String receiptId , String approverId){
        System.debug('Receipt Id :: '+receiptId);
        System.debug('ApproverId :: '+approverId);
        if(String.isNotBlank(receiptId) && String.isNotEmpty(receiptId) && String.isNotBlank(approverId) && String.isNotEmpty(approverId)){
            String AppId = [SELECT Application__r.Name FROM Receipt__c WHERE Id = : receiptId].Application__r.Name;
            System.debug('App '+AppId);
            List<Id> listApproverId = new List<Id>(); 
            //listApproverId.add(approverId);
            System.debug('user info'+UserInfo.getName());
            Utility.createTask(UserInfo.getName()+' is asking for approval',null, receiptId,approverId,null,'Please Approve this Receipt',true);
            Utility.sendNotification(UserInfo.getName()+' is asking approval for Receipt',AppId,receiptId,'Verification_Notification',approverId);
            return 'Success';
        }     
        else{
            return 'Failed';
        }
    }  
    
    /*
@Author : Navin Soni
@Date : 30 July 2022
@Description : This method is used to get all Fee Code from Fee Creation object basis on Application.  
*/
    @AuraEnabled
    public Static Map<String, Decimal> getExistingFeeCode(String applicationId){
        system.debug('get existing code'+applicationId);
        Map<String, Decimal> mapOfFeeCode = new Map<String, Decimal>();
        if(String.isNotBlank(applicationId)){
            for(Fee_Creation__c objFeeCreation : [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Total_Fee__c, RecordType.Name FROM Fee_Creation__c WHERE Application__c =: applicationId AND (Recordtype.DeveloperName = 'Fee' OR Recordtype.DeveloperName = 'Insurance') AND Repayment_Type_2__c = 'Direct Receipt']){
                if(String.IsNotBlank(objFeeCreation.Fee_Code__c)){
                    system.debug('fee code'+objFeeCreation.Fee_Code__c);
                    system.debug('fee collection'+objFeeCreation.Fee_Collection__c);
                    if(objFeeCreation.Fee_Collection__c == null){
                        objFeeCreation.Fee_Collection__c = 0;
                    }
                    if(objFeeCreation.Total_Fee__c == null){
                        objFeeCreation.Total_Fee__c = 0;
                    }
                    system.debug('fee collection'+objFeeCreation.Fee_Collection__c);
                    if(objFeeCreation.RecordType.Name == 'Fee'){
                        mapOfFeeCode.put(objFeeCreation.Fee_Code__c, objFeeCreation.Fee_Collection__c);
                    }
                    else if(objFeeCreation.RecordType.Name == 'Insurance'){
                        mapOfFeeCode.put(objFeeCreation.Fee_Code__c, objFeeCreation.Total_Fee__c);
                    }
                    
                }
                
            }
        }
        return mapOfFeeCode;
    }
    
    /*
@Author : Sanggeta Yadav
@Date : 03 August 2022
@Description : This method is used to get all Fee Code from Fee Creation object of type insurance basis on Application (for PC screen).  
*/
    @AuraEnabled
    public Static Map<String, Fee_Creation__c> getExistingFeeCodeIns(String applicationId){
        system.debug('get existing code'+applicationId);
        Map<String, Fee_Creation__c> mapOfFeeCode = new Map<String, Fee_Creation__c>();
        if(String.isNotBlank(applicationId)){
            for(Fee_Creation__c objFeeCreation : [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Total_Fee__c FROM Fee_Creation__c WHERE Application__c =: applicationId AND Repayment_Type_2__c = 'Direct Receipt']){
                if(String.IsNotBlank(objFeeCreation.Fee_Code__c)){
                    
                    if(objFeeCreation.Total_Fee__c == null){
                        objFeeCreation.Total_Fee__c = 0;
                    }
                    mapOfFeeCode.put(objFeeCreation.Id, objFeeCreation);
                    
                }
            }
        }
        system.debug('map'+mapOfFeeCode);
        return mapOfFeeCode;
    }
    
    
    // for multiple value for same fee code and checking their receipts
    @AuraEnabled
    public Static Map<String, Fee_Creation__c> getExistingFeeCodeRec(String applicationId, String stageName){
        system.debug('get existing code'+applicationId);
        Map<String, Fee_Creation__c> mapOfFeeCode = new Map<String, Fee_Creation__c>();
        List<Fee_Creation__c> fee = new List<Fee_Creation__c>();
        if(stageName == 'Process Credit' || stageName == 'Approval Credit'){
            // only insurance record
            System.debug('stageName'+stageName);
            fee = [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Total_Fee__c, RecordType.Name, Stage__c, Fee_Value_Master__c, Fee_Value_Master__r.Description__c, Description__c 
                   FROM Fee_Creation__c WHERE Application__c =: applicationId AND Repayment_Type_2__c = 'Direct Receipt'];
        }
        else if(stageName == 'Pre Login'){
            //only fee type
            System.debug('stageName'+stageName);
            fee = [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Total_Fee__c, RecordType.Name, Stage__c, Fee_Value_Master__c, Fee_Value_Master__r.Description__c , Description__c
                   FROM Fee_Creation__c WHERE Application__c =: applicationId AND (Recordtype.DeveloperName = 'Fee') AND Repayment_Type_2__c = 'Direct Receipt'];
            
        }
        else if(stageName == 'Lead Detail' || stageName == 'Disbursal Maker' || stageName == 'Disbursal Author' || stageName == 'Agreement Execution'){
            // both insurance and fee
            System.debug('stageName'+stageName);
            fee = [SELECT Id, Type__c, Fee_Code__c, Fee_Collection__c, Total_Fee__c, RecordType.Name, Stage__c, Fee_Value_Master__c, Fee_Value_Master__r.Description__c , Description__c
                   FROM Fee_Creation__c WHERE Application__c =: applicationId AND (Recordtype.DeveloperName = 'Fee' OR Recordtype.DeveloperName = 'Insurance') AND Repayment_Type_2__c = 'Direct Receipt'];
            
        }
        List<Receipt__c> receiptList = [SELECT Id, Fee_code__c FROM Receipt__c WHERE Application__c =:applicationId AND Fee_code__c IN : fee 
                                        AND (Approval_Status__c = 'Approved' OR Approval_Status__c = 'Pending' OR Approval_Status__c = 'Submitted')];
        System.debug('receiptList' + receiptList);
        if(String.isNotBlank(applicationId)){
            for(Fee_Creation__c objFeeCreation : fee){
               // if(String.IsNotBlank(objFeeCreation.Fee_Code__c)){
                //For FVM Changes: 27 Nov 22
                if(String.IsNotBlank(objFeeCreation.Fee_Value_Master__c)){
                    system.debug('fee code'+objFeeCreation.Fee_Value_Master__r.Description__c);
                    system.debug('fee collection'+objFeeCreation.Fee_Collection__c);
                    if(objFeeCreation.Fee_Collection__c == null){
                        objFeeCreation.Fee_Collection__c = 0;
                    }
                    if(objFeeCreation.Total_Fee__c == null){
                        objFeeCreation.Total_Fee__c = 0;
                    }
                    system.debug('fee collection'+objFeeCreation.Fee_Collection__c);
                    // if(objFeeCreation.RecordType.Name == 'Fee'){
                    //    mapOfFeeCode.put(objFeeCreation.Id, objFeeCreation.Fee_Code__c);
                    //  }
                    //  else if(objFeeCreation.RecordType.Name == 'Insurance'){
                    //      mapOfFeeCode.put(objFeeCreation.Id, objFeeCreation.Fee_Code__c);
                    //  }
                    mapOfFeeCode.put(objFeeCreation.Id, objFeeCreation);
                    
                }
            }
        }
        if(receiptList.size() > 0){
            for(Receipt__c rec : receiptList){
                if(mapOfFeeCode.containsKey(rec.Fee_Code__c)){
                    mapOfFeeCode.remove(rec.Fee_Code__c);
                }
            }
        }
        System.debug('mapOfFeeCode' + mapOfFeeCode);
        return mapOfFeeCode;
    }
    //To update feecode in receipt
    @AuraEnabled
    public static String updateReceiptFee(String receiptId, String feeId, String stage){
        if(receiptId != null && feeId != null && receiptId != '' && feeId != ''){
            Receipt__c rec = [SELECT Id,Fee_Code__c, Stage__c, Application__r.stage__c, Application__c, Cashier__c FROM Receipt__c WHERE Id =:receiptId WITH SECURITY_ENFORCED LIMIT 1 ]; 
            rec.Fee_Code__c = feeId;
            //To add stage of application in receipt for content version: 5/1/23
            //rec.Stage__c = rec.Application__r.stage__c;
            if(String.isNotBlank(stage))
                rec.Stage__c = stage;
            Fee_Creation__c fee = [SELECT Id, Receipt_Created__c FROM Fee_Creation__c WHERE Id =:feeId WITH SECURITY_ENFORCED LIMIT 1 ];
            fee.Receipt_Created__c = true;
            if(rec != null){
                updateReceipt(rec);
                //Application user tracking for receipt as per discussion on 5/1/23
                Application_User_Tracking__c recTracking = new Application_User_Tracking__c();
                //To create Application_User_Tracking__c record for Receipt : 05-01-23
                String status = (rec.Cashier__c == System.Label.Pull_Queue_User) ? 'Unassigned' : 'Pending';
                recTracking.Stage__c = rec.Application__r.Stage__c;                
                recTracking.Application__c = rec.Application__c;
                recTracking.Status__c = status;
                recTracking.Type__c = 'Receipt';
                recTracking.Owner__c = rec.Cashier__c;
                recTracking.Receipt__c = rec.Id;
                recTracking.Start_Date__c = System.now();
                insert recTracking;
            }
            if(fee != null){
                updateFee(fee);
            }
        }
        
        return 'yes';
    }
    
    public static void updateReceipt(Receipt__c rec){
        update rec;
    }
    public static void updateFee(Fee_Creation__c fee){
        update fee;
    }
    @AuraEnabled
    public static String getRecFeeRepayment(String recId){
        System.debug('Receipt id to get repayment'+recId);
        String repayment = [SELECT Id, Fee_Code__r.Repayment_Type_2__c FROM Receipt__c WHERE Id =: recId AND Approval_Status__c = 'Rejected'].Fee_Code__r.Repayment_Type_2__c;
        System.debug('Receipt repayment'+repayment);
        return repayment;
    }

      /*
        @Author : Sanggeta Yadav
        @Date : 11 October 2022
        @Description : To check if branch code is available or not in application.  
*/
@AuraEnabled 
 public static String getApplicationBranchCode(String applicationId){
        
    System.debug('ApproverId :: '+applicationId);
    if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId) ){
        String branchCode;
        List<Application__c> app = [SELECT Name, Sourcing_Branch__c, Sourcing_Branch__r.Branch_Code__c FROM Application__c WHERE Id = : applicationId];
        //branchCode = app[0].Sourcing_Branch__r.Branch_Code__c;
        if(app != null && app.size() >0){
            System.debug(app[0].Sourcing_Branch__c);
        if(app[0].Sourcing_Branch__c != null ){
        if(app[0].Sourcing_Branch__r.Branch_Code__c != null && app[0].Sourcing_Branch__r.Branch_Code__c != ''){

            return branchCode;
        }
        else{
            return 'Fail';
        }
        
    }
    else{
            return 'Fail';
        }
    }
    else{
            return 'Fail';
        }
}
else{
            return 'Fail';
        }
}

// To get pending receipt based on fee stage
@AuraEnabled 
 public static List<Receipt__c> getReceiptFeeStage(List<String> receiptNameList, String stageName){
     System.debug('receipt name list' + receiptNameList.size());
     List<Receipt__c> receiptList = new List<Receipt__c>();
     if(receiptNameList != null && receiptNameList.size() > 0 && stageName != null){
         if(stageName == 'Pre Login' ){
            receiptList = [SELECT Id,Name, Approval_Status__c, Fee_Code__r.Stage__c, Fee_Code__r.Fee_Code__c FROM Receipt__c WHERE Name =: receiptNameList AND Fee_Code__r.Stage__c =: stageName];
         }
         else if(stageName == 'Process Credit'){
             receiptList = [SELECT Id,Name, Approval_Status__c, Fee_Code__r.Stage__c, Fee_Code__r.Fee_Code__c FROM Receipt__c WHERE Name =: receiptNameList AND (Fee_Code__r.Stage__c =: stageName OR Fee_Code__r.Stage__c = 'Pre Login')];
         }
         else if(stageName == 'Disbursal Author'){
             receiptList = [SELECT Id,Name, Approval_Status__c, Fee_Code__r.Stage__c, Fee_Code__r.Fee_Code__c FROM Receipt__c WHERE Name =: receiptNameList AND (Fee_Code__r.Stage__c = 'Disbursement' OR Fee_Code__r.Stage__c = 'Pre Disbursement' OR Fee_Code__r.Stage__c = 'Pre Login' OR Fee_Code__r.Stage__c = 'Process Credit')];
         }
         else if(stageName == 'Agreement Execution'){
             receiptList = [SELECT Id,Name, Approval_Status__c, Fee_Code__r.Stage__c, Fee_Code__r.Fee_Code__c FROM Receipt__c WHERE Name =: receiptNameList AND (Fee_Code__r.Stage__c = 'Pre Disbursement' OR Fee_Code__r.Stage__c = 'Pre Login' OR Fee_Code__r.Stage__c = 'Process Credit')];
         }
     }
     if(receiptList != null && receiptList.size() > 0){
         return receiptList;
     }
     return null;
 }

 //To show Pending Receipt and Fee to add for fiv_Disb_Lwc component
 @AuraEnabled 
 public static Map<String, List<String>> pendingFeeAndReceiptForDA(String applicationId){
    System.debug('application id'+ applicationId);
     List<Receipt__c> receiptList = new List<Receipt__c>();
     Map<String, List<String>> feeReceiptPendingMap = new Map<String, List<String>>();
     List<Fee_Creation__c> pendingFee = new List<Fee_Creation__c>();
     List<String> receiptFeeAvailable = new List<String>();
     Set<String> rejectedReceiptList = new Set<String>();
     if(applicationId != null){
         String appStage = [SELECT Id, Stage__c FROM Application__c WHERE Id =: applicationId].Stage__c;
        if(String.IsNotBlank(appStage) && appStage == 'Disbursal Author'){
         //All receipt list to check which fee is pending to create receipt
        receiptList = [SELECT Id,Name, Approval_Status__c, Fee_Code__r.Stage__c, Fee_Code__r.Fee_Code__c, Fee_Code__c, Fee_Code__r.Repayment_Type_2__c FROM Receipt__c WHERE Application__c =: applicationId];
        pendingFee = [SELECT Id, Fee_Code__c, Repayment_Type_2__c, Description__c FROM Fee_Creation__c WHERE Application__c =: applicationId AND Repayment_Type_2__c = 'Direct Receipt'];
        if(receiptList != null && receiptList.size() > 0){
            for(Receipt__c rec : receiptList){
                //receiptFeeAvailable.add(rec.Fee_Code__c);
                System.debug('Receipt is' + rec.Name + rec.Fee_Code__c);
                if(rec.Approval_Status__c == 'Approved'){
                    receiptFeeAvailable.add(rec.Fee_Code__c);
                }
                if(rec.Approval_Status__c != 'Approved' && rec.Fee_Code__r.Repayment_Type_2__c == 'Direct Receipt'){
                    if(rec.Approval_Status__c != 'Rejected'){
                        receiptFeeAvailable.add(rec.Fee_Code__c);
                    }
                    else{
                        //Rejected Fee_code list
                        rejectedReceiptList.add(rec.Fee_Code__c);
                    }
                    if(rec.Approval_Status__c == 'Submitted'){
                        if(feeReceiptPendingMap != null && feeReceiptPendingMap.containsKey('Receipt')){
                            feeReceiptPendingMap.get('Receipt').add(rec.Name);
                        }
                        else{
                            feeReceiptPendingMap.put('Receipt', new List<String>{rec.Name});
                        }
                    }
                    
                }
                
            }
        }
        // to remove those fee code from receipt list those are first rejected and receipt have created again for them
       /* if(rejectedReceiptList != null && rejectedReceiptList.size() > 0){
            for(String feeId : rejectedReceiptList){
                if(receiptFeeAvailable != null && receiptFeeAvailable.size() > 0){
                    if(receiptFeeAvailable.contains(feeId)){
                        receiptFeeAvailable.add()
                    }
        }*/
        if(pendingFee != null && pendingFee.size() > 0){
            System.debug('pendingFee'+ pendingFee);
            for(Fee_Creation__c fee : pendingFee){
                if(receiptFeeAvailable != null && receiptFeeAvailable.size() > 0){
                    System.debug('receiptFeeAvailable' + receiptFeeAvailable);
                    if(!receiptFeeAvailable.contains(fee.Id)){
                        if(feeReceiptPendingMap != null && feeReceiptPendingMap.containsKey('Fee')){
                        feeReceiptPendingMap.get('Fee').add(fee.Description__c);
                        }
                        else{
                            feeReceiptPendingMap.put('Fee', new List<String>{fee.Description__c});
                        }
                    }
                }
                else{
                    if(feeReceiptPendingMap != null && feeReceiptPendingMap.containsKey('Fee')){
                        feeReceiptPendingMap.get('Fee').add(fee.Description__c);
                    }
                    else{
                        feeReceiptPendingMap.put('Fee', new List<String>{fee.Description__c});
                    }
                }

            }
        }
     }
     }
     System.debug('feeReceiptPendingMap' + feeReceiptPendingMap);
     return feeReceiptPendingMap;
 
 }

 @AuraEnabled
 public static string getApplicationPrimaryApplicantName(String applicationId){
    try {
        String applicantName = '';
        if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId) ){
            
            List<Application__c> app = [SELECT Name, Primary_Applicant__c, Primary_Applicant__r.Applicant_Name__c FROM Application__c WHERE Id = : applicationId];
            //branchCode = app[0].Sourcing_Branch__r.Branch_Code__c;
            if(app != null && app.size() >0){
                System.debug(app[0].Primary_Applicant__c);
                if(app[0].Primary_Applicant__c != null ){
                    if(app[0].Primary_Applicant__r.Applicant_Name__c != null && app[0].Primary_Applicant__r.Applicant_Name__c != ''){
                        applicantName = app[0].Primary_Applicant__r.Applicant_Name__c;
                
                    }
                }
            }
            
        }
        return applicantName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}