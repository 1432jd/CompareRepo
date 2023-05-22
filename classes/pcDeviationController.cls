/**
* @Class Name         : pcDeviationController.apxc
* @Description        : Class to fetch details from Tr_Deviation__c for PcDeviationTable LWC component child of PcDeviation Component
on Pre-Login Screen/Fee Details.
* @Author             : Sangeeta Yadav
* @Created On         : 19/08/2022
*========================================================================================
* Ver         Date                     Author                       Modification
*========================================================================================
* 1.0      19/08/2022               Sangeeta Yadav                  Initial Version
**/

public without sharing class pcDeviationController {
    
    // To get all Tr deviation data for application
    @AuraEnabled
    public static List<deviationWrapper> getTrDeviationData(String applicationId, String stageName){
        String appStage = [SELECT Id, Stage__c FROM Application__c WHERE Id =:applicationId].Stage__c;
        System.debug('appStage'+appStage);
        List<Tr_Deviation__c> deviationList = new List<Tr_Deviation__c>();
        //if(appStage == 'Process Credit' || appStage == 'Approval Credit'){
        if(stageName == 'Process Credit' || stageName == 'Approval Credit'){
            deviationList = [SELECT Id,Name, Deviation_Code__c, Deviation_Type__c, Applicable_For__c, Loan_Applicant__c, Application__r.Is_Deviation_Raised__c,
                             Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Property__c, Approval_Level__c, Decistion__c, Remark__c, Mitigants__c, 
                             Approval_Authority__c,Approval_Authority__r.Name, MS_Deviation__c, MS_Deviation__r.Name, MS_Deviation__r.Deviation_Description__c, 
                             Is_Deviation_Raised__c, Deviation_Description__c FROM Tr_Deviation__c 
                             WHERE Application__c =: applicationId AND Is_Deviation_Active__c = true AND MS_Deviation__r.Stage__c = 'Credit' AND Decistion__c = 'Approval for Pending'
                             ORDER BY Approval_Level__c Asc];
        }
        //else if(appStage == 'Disbursal Maker' || appStage == 'Disbursal Author'){
        else if(stageName == 'Disbursal Maker' || stageName == 'Disbursal Author'){
            deviationList = [SELECT Id,Name, Deviation_Code__c, Deviation_Type__c, Applicable_For__c, Loan_Applicant__c, Application__r.Is_Deviation_Raised__c,
                             Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Property__c, Approval_Level__c, Decistion__c, Remark__c, Mitigants__c, 
                             Approval_Authority__c,Approval_Authority__r.Name, MS_Deviation__c, MS_Deviation__r.Name, MS_Deviation__r.Deviation_Description__c, 
                             Is_Deviation_Raised__c, Deviation_Description__c FROM Tr_Deviation__c 
                             WHERE Application__c =: applicationId AND Is_Deviation_Active__c = true AND MS_Deviation__r.Stage__c = 'Operations'  AND Decistion__c = 'Approval for Pending'
                             ORDER BY Approval_Level__c Asc];
            
        }
        System.debug('deviationList'+deviationList.size());
        // need to change later based on approval level. to get user on same level
        
        /* List<User> userList = [SELECT Id, Name, Department FROM User WHERE Department = 'Credit Approver' OR Department = 'CCO/ Sr Head credit' 
OR Department ='CEO' OR Department = 'MD'];
System.debug('userList'+userList);
Map<String,Map<String,String>> userListMap = new Map<String,Map<String,String>>();
// Map<String, String> userMap = new Map<String, String>();
// List<String> userNameList = new List<String>();
if(userList.size() > 0){
for(User usr : userList){
if(userListMap.containsKey(usr.Department)){

userListMap.get(usr.Department).put(usr.Id, usr.Name);
System.debug('user map'+userListMap + 'size'+ userListMap.size());
}
else{
Map<String, String> userMap = new Map<String, String>();
userMap.put(usr.Id, usr.Name);
System.debug('uswr map to add'+userMap);
userListMap.put(usr.Department,userMap);
}

}
}
System.debug('userMap size'+userListMap.size()+ userListMap.get('MD'));*/
        List<deviationWrapper> deviationWrapperList = new List<deviationWrapper>();
        if(deviationList.size() > 0){
            
            for(Tr_Deviation__c dev : deviationList){
                deviationWrapper deviationWrapperItem = new deviationWrapper();
                if(dev.Mitigants__c == null){
                    dev.Mitigants__c = '';
                }
                if(dev.Remark__c == null){
                    dev.Remark__c = '';
                }
                if ((dev.Applicable_For__c != null || dev.Applicable_For__c != '') && dev.Applicable_For__c == 'Applicant') {
                    //applicantAsset true meant applicant
                    deviationWrapperItem.applicantAsset = true;
                    deviationWrapperItem.isApplication = false;
                    deviationWrapperItem.isAsset = false;
                    if(dev.Loan_Applicant__c != null){
                        deviationWrapperItem.applicantOrAssetName = dev.Loan_Applicant__r.Applicant_Name__c;
                        deviationWrapperItem.isApplicant = false; //Applicable for Applicant and applicant is selected
                    }
                    else{
                        deviationWrapperItem.applicantOrAssetName = '';
                        deviationWrapperItem.isApplicant = true;
                    }
                    
                }
                if ((dev.Applicable_For__c != null || dev.Applicable_For__c != '') && dev.Applicable_For__c == 'Asset') {
                    //applicantAsset true meant applicant
                    deviationWrapperItem.applicantAsset = false;
                    deviationWrapperItem.isApplication = false;
                    deviationWrapperItem.isApplicant = false;
                    if(dev.Property__c != null){
                        deviationWrapperItem.applicantOrAssetName = dev.Property__r.Name;
                        deviationWrapperItem.isAsset = false;
                    }
                    else{
                        deviationWrapperItem.applicantOrAssetName = '';
                        deviationWrapperItem.isAsset = true;// is asset true i.e. applicable for is asset but asset is not selected yet
                    }
                }
                if ((dev.Applicable_For__c != null || dev.Applicable_For__c != '') && dev.Applicable_For__c == 'Application') {
                    //applicantAsset true meant applicant
                    deviationWrapperItem.applicantAsset = false;
                    deviationWrapperItem.isApplication = true;
                    deviationWrapperItem.isAsset = false;
                    deviationWrapperItem.isApplicant = false;
                }
                deviationWrapperItem.devList = dev;
                deviationWrapperItem.isNewRow = false;
                if(dev.Approval_Authority__c != null){
                    deviationWrapperItem.userName = dev.Approval_Authority__r.Name;
                }
                else{
                    deviationWrapperItem.userName = '';
                }
                //System.debug('deviationWrapperItem.devList'+deviationWrapperItem.devList);
                List<UserDetailWrapper> useDetList = new List<UserDetailWrapper>();
                // Map<String,List<User>> userMap = getUserBasedOnLevel();
                Map<String,Map<String, String>> userMap = getUserBasedOnSourcingBranch(applicationId);
                System.debug('user map in get deviation'+ userMap.get(dev.Approval_Level__c)+dev.Approval_Level__c+'userMapuserMapuserMap>>> '+userMap);
                if(userMap.containsKey(dev.Approval_Level__c)){
                    if(userMap.get(dev.Approval_Level__c).size() > 0){
                        // commented for vs 2
                        /* for(User devAuthUser : userMap.get(dev.Approval_Level__c)){
UserDetailWrapper useDet = new UserDetailWrapper();
useDet.label = devAuthUser.Name;
useDet.value = devAuthUser.Id;
useDetList.add(useDet);
System.debug('user map list for deviation is in loop'+useDetList);
}*/
                        for(String devAuthUser : userMap.get(dev.Approval_Level__c).keySet()){
                            UserDetailWrapper useDet = new UserDetailWrapper();
                            useDet.label = userMap.get(dev.Approval_Level__c).get(devAuthUser);
                            useDet.value = devAuthUser;
                            useDetList.add(useDet);
                            System.debug('user map list for deviation is in loop'+useDetList);
                        }
                        System.debug('user map list for deviation is'+useDetList);
                        
                        //deviationWrapperItem.userDetail = ;
                    }}
                if(useDetList.size() > 0){
                    deviationWrapperItem.userDetail = useDetList;
                    System.debug('User Deviation List for Authority'+deviationWrapperItem.userDetail);
                }
                deviationWrapperItem.sendEmail = false;
                /*  if(!userListMap.isEmpty()){

if(dev.Approval_Level__c <> null && dev.Approval_Level__c <> ''){
if(dev.Approval_Level__c == 'L3'){
deviationWrapperItem.approvalUser = userListMap.get('Credit Approver');

}
else if(dev.Approval_Level__c == 'L5'){
deviationWrapperItem.approvalUser = userListMap.get('CCO/ Sr Head credit');
}
else if(dev.Approval_Level__c == 'L6'){
deviationWrapperItem.approvalUser = userListMap.get('CEO');
}
else if(dev.Approval_Level__c == 'L7'){
deviationWrapperItem.approvalUser = userListMap.get('MD');
}
}
//  deviationWrapperItem.approvalUser = userListMap;

}*/
                deviationWrapperList.add(deviationWrapperItem);
            }
            
        }
        /* as add row is shifted to top. so dummy row is not required*/
        /* if(deviationList.size() == 0 && (appStage == 'Disbursal Maker' || appStage == 'Disbursal Author')){
deviationWrapperList.add(getNewRow(applicationId));
}*/
        
        
        System.debug('deviation wrapper'+deviationWrapperList.size()+deviationWrapperList);
        return deviationWrapperList;
    }
    
    //To get user based on approval level for department as L1,L2....
    // commented for vs 2
    /*@AuraEnabled
public static Map<String,List<User>> getUserBasedOnLevel(){
List<User> userList = [SELECT Id, Name, Department FROM User ];
Map<String,List<User>> userListMap = new Map<String,List<User>>();

if(userList.size() > 0){
for(User usr : userList){
if(userListMap.containsKey(usr.Department)){

userListMap.get(usr.Department).add(usr);
System.debug('user map'+userListMap + 'size'+ userListMap.get(usr.Department));
}
else{
Map<String, String> userMap = new Map<String, String>();

userListMap.put(usr.Department, new List<user>{usr});
}

}
}
System.debug('userMap size'+userListMap.size()+ userListMap.get('MD'));
if(userListMap.size() >0){

}
System.debug('userListMap based on level'+userListMap);
return userListMap;
}*/
    
    //To get user based on approval level
    /*  @AuraEnabled
public static Map<String,List<User>> getUserBasedOnLevel(){
List<User> userList = [SELECT Id, Name, Department FROM User WHERE Department = 'Credit Approver' OR Department = 'CCO/ Sr Head credit' 
OR Department ='CEO' OR Department = 'MD'];
Map<String,List<User>> userListMap = new Map<String,List<User>>();
Map<String,List<User>> userLevelMap = new Map<String,List<User>>();
if(userList.size() > 0){
for(User usr : userList){
if(userListMap.containsKey(usr.Department)){

userListMap.get(usr.Department).add(usr);
System.debug('user map'+userListMap + 'size'+ userListMap.get(usr.Department));
}
else{
Map<String, String> userMap = new Map<String, String>();

userListMap.put(usr.Department, new List<user>{usr});
}

}
}
System.debug('userMap size'+userListMap.size()+ userListMap.get('MD'));
if(userListMap.size() >0){
for(String key : userListMap.keySet()){
System.debug('user map with department'+ key);
if(key == 'Credit Approver'){

userLevelMap.put('L3', userListMap.get(key));


}
else if(key == 'CCO/ Sr Head credit'){
userLevelMap.put('L5', userListMap.get(key));
}
else if(key == 'CEO'){
userLevelMap.put('L6', userListMap.get(key));

}
else if(key == 'MD'){
userLevelMap.put('L7', userListMap.get(key));

}
}
}
System.debug('userListMap based on level'+userLevelMap);
return userLevelMap;
}*/
    
    // To add new row in deviation table of manual type
    @AuraEnabled
    public static deviationWrapper getNewRow(String applicationId){
        System.debug('Get new row for application id'+applicationId);
        deviationWrapper newManualDevWrapper = new deviationWrapper();
        Tr_Deviation__c newManualDev = new Tr_Deviation__c();
        newManualDev.Application__c = applicationId;
        newManualDev.Decistion__c = 'Approval for Pending';
        newManualDev.Remark__c = '';
        newManualDev.Deviation_Type__c = 'Manual';
        newManualDev.Approval_Level__c = '';
        newManualDev.Approval_Authority__c = null;
        newManualDev.Property__c = null;
        newManualDev.Loan_Applicant__c = null;
        newManualDev.Is_Deviation_Active__c = true;
        newManualDev.Deviation_Description__c = '';
        newManualDev.Mitigants__c = '';
        newManualDev.Remark__c = '';
        newManualDev.Is_Deviation_Raised__c = false;
        newManualDev.Deviation_Code__c = '';
        newManualDevWrapper.devList = newManualDev;
        newManualDevWrapper.isNewRow = true;
        newManualDevWrapper.userName = '';
        newManualDevWrapper.applicantOrAssetName = '';
        newManualDevWrapper.sendEmail = false;
        newManualDevWrapper.userDetail = new List<UserDetailWrapper>();
        return newManualDevWrapper;
    }
    
    @AuraEnabled
    public static String saveDeviation(String devId, String approvalAut){
        // public static String saveDeviation(List<String> devId, List<String> approvalAut){
        System.debug('save deviation called' + devId + approvalAut);
        Tr_Deviation__c updateDev = new Tr_Deviation__c();
        if(devId != null){
            updateDev = [SELECT Id, Approval_Authority__c, Application__c, Approval_Level__c FROM Tr_Deviation__c WHERE Id =:devId];
        }
        System.debug('updateDev' + updateDev);
        if(updateDev != null && approvalAut != null){
            updateDev.Approval_Authority__c = approvalAut;
            updateDev(updateDev);
            
        }
        
        
        return 'record saved';
    }
    
    
    public static void updateDev(Tr_Deviation__c deviationUpdate){
        update deviationUpdate;
        
    }
    /*Commented not in use
    @AuraEnabled
    public static String saveNewDeviation(String devData, String approvalAut, String applicableFor, String applicableOn, String authLevel, String devMaster, String remarks){
        System.debug('Insert New Row');
        System.debug(devData + 'authL'+ authLevel+ 'master'+ devMaster);
        Tr_Deviation__c trDev = (Tr_Deviation__c)JSON.deserialize(devData,Tr_Deviation__c.class);
        System.debug('trDev'+ trDev);
        trDev.Approval_Authority__c = approvalAut;
        trDev.Applicable_For__c = applicableFor;
        if(applicableFor == 'Applicant'){
            trDev.Loan_Applicant__c = applicableOn;
        }
        else if(applicableFor == 'Asset'){
            trDev.Property__c = applicableOn;
        }
        trDev.Approval_Level__c = authLevel;
        trDev.MS_Deviation__c = devMaster;
        // String remarks = [SELECT Id, Deviation_Description__c FROM MS_Deviation__c WHERE Id =:devMaster].Deviation_Description__c;
        // trDev.Remark__c = remarks;
        trDev.Deviation_Description__c = remarks;
        inserNewRow(trDev);
        return 'new data inserted';
    }
    
    @AuraEnabled
    public static void inserNewRow(Tr_Deviation__c trDeviation){
        insert trDeviation;
        System.debug('new deviation id'+trDeviation.Id);
        
    }
    @AuraEnabled
    public static String saveDeviationApplication(String devId, String applicableOn){
        System.debug('details to update'+devId + applicableOn);
        if(devId != null){
            Tr_Deviation__c trDev = [SELECT Id,Loan_Applicant__c, Property__c, Applicable_For__c FROM Tr_Deviation__c WHERE Id =: devId ];
            if(trDev != null){
                if(trDev.Applicable_For__c != null || trDev.Applicable_For__c != ''){
                    if(trDev.Applicable_For__c == 'Applicant'){
                        System.debug(trDev.Applicable_For__c);
                        trDev.Loan_Applicant__c = applicableOn;
                    }
                    else if(trDev.Applicable_For__c == 'Asset'){
                        System.debug(trDev.Applicable_For__c);
                        trDev.Property__c= applicableOn;
                    }
                }
                updateThisDev(trDev);
            }
        }
        return 'Yes Update Applicable';
    }
    
    public Static Void updateThisDev(Tr_Deviation__c trDev){
        update trDev;
    }*/
    
    //get available code from master
    @AuraEnabled
    public static Map<String, MS_Deviation__c> getDevCodeFromMaster(String applicationId){
        System.debug('Application id in get code'+applicationId);
        String appStage = [SELECT Id, Stage__c FROM Application__c WHERE Id =:applicationId].Stage__c;
        System.debug('appStage'+appStage);
        Map<String, MS_Deviation__c> devCode = new Map<String, MS_Deviation__c>();
        System.debug('get dev code from master');
        List<Tr_Deviation__c> dev = new List<Tr_Deviation__c>();
        List<MS_Deviation__c> devMasterCode = new List<MS_Deviation__c>();
        if(appStage == 'Process Credit' || appStage == 'Approval Credit'){
            dev = [SELECT Id, MS_Deviation__c, MS_Deviation__r.Name, MS_Deviation__r.Id FROM Tr_Deviation__c WHERE Deviation_Type__c = 'Manual' AND Application__c =:applicationId AND MS_Deviation__r.Stage__c = 'Credit' AND Is_Deviation_Active__c = true];
            devMasterCode = [SELECT Id, Name, Approval_Authority__c, Deviation_Level__c,Deviation_Description__c, Code__c  FROM MS_Deviation__c WHERE Deviation_Type__c = 'Manual' AND Is_Active__c = 'Yes' AND Stage__c = 'Credit' ];
        }
        else if(appStage == 'Disbursal Maker' || appStage == 'Disbursal Author'){
            dev = [SELECT Id, MS_Deviation__c, MS_Deviation__r.Name, MS_Deviation__r.Id FROM Tr_Deviation__c WHERE Deviation_Type__c = 'Manual' AND Application__c =:applicationId AND MS_Deviation__r.Stage__c = 'Operations' AND Is_Deviation_Active__c = true];
            devMasterCode = [SELECT Id, Name, Approval_Authority__c, Deviation_Level__c,Deviation_Description__c, Code__c  FROM MS_Deviation__c WHERE Deviation_Type__c = 'Manual' AND Is_Active__c = 'Yes' AND Stage__c = 'Operations' ];
        }
        if(devMasterCode.size() > 0){
            for(MS_Deviation__c masterMap : devMasterCode){
                devCode.put(masterMap.Id, masterMap);
            }
        }
        system.debug('devCode before remove'+devCode);
        if(dev.size() > 0){
            for(Tr_Deviation__c devRemove : dev){
                String masterId = devRemove.MS_Deviation__r.Id;
                if(devCode.containsKey(masterId)){
                    devCode.remove(masterId);
                }
                
            }
        }
        System.debug('devMasterCode'+devCode);
        return devCode;
    }
    
    
    public Class deviationWrapper{
        // public List<Tr_Deviation__c> devList;
        @AuraEnabled public Tr_Deviation__c devList;
        @AuraEnabled public Map<String,String> approvalUser;
        @AuraEnabled public Boolean isNewRow;
        @AuraEnabled public Boolean applicantAsset;
        @AuraEnabled public Boolean isAsset;
        @AuraEnabled public Boolean isApplicant;
        @AuraEnabled public Boolean isApplication;
        @AuraEnabled public String userName;
        @AuraEnabled public String applicantOrAssetName;
        @AuraEnabled public Boolean sendEmail;
        @AuraEnabled public List<UserDetailWrapper> userDetail;
        @AuraEnabled public Boolean iscurrentUser = false;
        
        
    }
    public class UserDetailWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    /* commented not in use
    //Pending for decision
    @AuraEnabled
    public static List<Tr_Deviation__c> getPendingDeviationData(String applicationId){
        System.debug('application Id'+applicationId);
        List<Tr_Deviation__c> deviationList = [SELECT Id,Name, Deviation_Code__c, Deviation_Type__c, Applicable_For__c, Loan_Applicant__c,Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Property__c, Approval_Level__c, Decistion__c, Remark__c, Mitigants__c, Approval_Authority__c,Approval_Authority__r.Name FROM Tr_Deviation__c WHERE Application__c =: applicationId AND (Decistion__c = '' OR Decistion__c = 'Not Approved') AND Is_Deviation_Active__c = true ORDER BY createdDate Asc];
        System.debug(deviationList);
        List<Tr_Deviation__c> trDevList = new List<Tr_Deviation__c>();
        if(deviationList.size() > 0){
            for(Tr_Deviation__c trDev : deviationList){
                if(trDev.Mitigants__c == null || trDev.Mitigants__c == ''){
                    trDev.Mitigants__c = '';
                }
                if(trDev.Remark__c == null || trDev.Remark__c == ''){
                    trDev.Remark__c = '';
                }
                if(trDev.Decistion__c == null || trDev.Decistion__c == ''){
                    trDev.Decistion__c = '';
                }
                trDevList.add(trDev);
                
            }
        }
        return trDevList;
    }
    */
    // For Vs 2
    //To get users based on approval user from user branch allocation based on application sourcing branch
    /* commented to add user from Access master
@AuraEnabled
public static Map<String,Map<String, String>> getUserBasedOnSourcingBranch(String applicationId){
Map<String,Map<String,String>> userListMap = new Map<String,Map<String,String>>();
List<User_Branch_Allocation__c> usrBranchAllocation = new List<User_Branch_Allocation__c>();
if(applicationId != null){
String sourcingBranch = [SELECT Id, Sourcing_Branch__c FROM Application__c WHERE Id =:applicationId].Sourcing_Branch__c;
System.debug('sourcingBranch'+sourcingBranch);
if(sourcingBranch != null){
usrBranchAllocation = [SELECT Id, Name, Branch_Master__c, User__c, User__r.Name, User__r.Approval_Level__c, UniqueKey__c 
FROM User_Branch_Allocation__c where Branch_Master__c =: sourcingBranch];

if(usrBranchAllocation.size() > 0){
for(User_Branch_Allocation__c userBranch : usrBranchAllocation){
List<String> usrApprovalLevel = new List<String>();
if(userBranch.User__r.Approval_Level__c != null){
if(userBranch.User__r.Approval_Level__c.contains(';')){
usrApprovalLevel = userBranch.User__r.Approval_Level__c.split(';');
}else{
usrApprovalLevel.add(userBranch.User__r.Approval_Level__c);
}

//Loop on user approval level (multiselect picklist)
for(String approvalLevel : usrApprovalLevel){
if(userListMap.containsKey(approvalLevel)){

userListMap.get(approvalLevel).put(userBranch.User__c, userBranch.User__r.Name);
System.debug('user map'+userListMap + 'size'+ userListMap.get(approvalLevel));
}
else{
// Map<String, String> userMap = new Map<String, String>();

userListMap.put(approvalLevel, new Map<String, String>{userBranch.User__c => userBranch.User__r.Name});
}
}
}
}
}



}
}
if(userListMap.size() > 0){
System.debug('userList map vs 2'+userListMap);
// if approval level is Credit committee then provide list of L5 users
if(userListMap.containsKey('L5')){
userListMap.put('Credit committee',userListMap.get('L5'));
}
}
return userListMap;
}  commented to add user from Access master*/
    
    // For raise deviation button blick vs2 requirement
    
    @AuraEnabled
    public static void getLowestLevelePendingTRDevRecords(String applicationId){
        
        try {
            
            Map<String, List<TR_Deviation__c>> levelBasedTrMap = new  Map<String, List<TR_Deviation__c>>();
            Map<String, List<TR_Deviation__c>> levelBasedRejectedTrMap = new  Map<String, List<TR_Deviation__c>>();
            String stageType ;
            Boolean applicationUpdated = false;   // if current deviation to be raised is L6 or L7 than application current deviation user is updated to L5 user        
            List<String> mapKeySet = new List<String>();
            Application__c applicationObj = new  Application__c();
            integer index = 1;
            
            set<String> levelSet = new Set<String>();
            //   levelList.sort();
            //   System.debug('Sorted level List::'+   levelList);
            
            if(applicationId != null){
                applicationObj = [Select Id, Name, Stage__c, Is_Deviation_Raised__c, Current_Deviation_Approval__c from Application__c where Id =:applicationId Limit 1];
            }
            if(applicationObj.Stage__c != null || applicationObj.Stage__c != ''){
                if(applicationObj.Stage__c == 'Process Credit' || applicationObj.Stage__c == 'Approval Credit')
                {
                    stageType = 'Credit';
                }
                else
                    if(applicationObj.Stage__c == 'Disbursal Maker' || applicationObj.Stage__c == 'Disbursal Author')
                {
                    stageType = 'Operations';
                    
                }
            }
            if(applicationId != null){
                for(TR_Deviation__c trDevObj : [Select Id, Deviation_Description__c , MS_Deviation__c, Applicable_For__c,Approval_Level__c,
                                                Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Decistion__c, Remark__c,
                                                Mitigants__c, Deviation_Type__c, Approval_Authority__c From TR_Deviation__c where Application__c =: applicationId AND Is_Deviation_Active__c = true]){
                                                    
                                                    levelSet.add(trDevObj.Approval_Level__c);
                                                    
                                                    
                                                }
            }
            
            
            if(applicationId != null){
                for(TR_Deviation__c trDevObj : [Select Id, Deviation_Description__c , MS_Deviation__c, Applicable_For__c,
                                                Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Decistion__c, Remark__c,
                                                Mitigants__c, Deviation_Type__c, Is_Deviation_Raised__c, Approval_Level__c, Approval_Authority__c From TR_Deviation__c
                                                where Application__c =: applicationId AND
                                                MS_Deviation__r.Stage__c =:stageType AND is_Deviation_Active__c = True ]){
                                                    for(String level : levelSet){
                                                        
                                                        if(trDevObj.Approval_Level__c != null){
                                                            if(level == trDevObj.Approval_Level__c && (trDevObj.Decistion__c == 'Approval for Pending' || trDevObj.Decistion__c == 'Not Approved')){
                                                                // trDevObj.Is_Deviation_Raised__c = True;
                                                                if(!mapKeySet.contains(level)){
                                                                    mapKeySet.add(level);
                                                                }
                                                                if(levelBasedTrMap.containsKey(level)){
                                                                    levelBasedTrMap.get(level).add(trDevObj);
                                                                }
                                                                else{
                                                                    levelBasedTrMap.put(level, new List<TR_Deviation__c>{trDevObj});
                                                                }
                                                            }      
                                                        }
                                                    }
                                                }
                
                System.debug('Level and tr deviation map'+levelBasedTrMap);
                mapKeySet.sort();
                List<TR_Deviation__c> raiseDeviationList = new List<TR_Deviation__c>();
                if(mapKeySet != null){
                    for(String level : mapKeySet){
                        System.debug('level is'+level);
                        if(level == 'L6' || level == 'L7'){
                            System.debug('level in if'+level);
                            // Added to assign Deviation Approval user as L5 if L6 and L7 level deviation to raise
                            //Date : 11-Nov-22 Sangeeta Yadav
                            
                            if(levelBasedTrMap != null && levelBasedTrMap.size() > 0 && levelBasedTrMap.containsKey(level)){
                                System.debug('Lvel from level map'+ level + 'size' + levelBasedTrMap.get(level).size() + levelBasedTrMap.get(level));
                                if(levelBasedTrMap.get(level) != null && levelBasedTrMap.get(level).size() > 0 ){
                                    System.debug('levelBasedTrMap'+ levelBasedTrMap.get(level));
                                    Map<String, Map<String, String>> sourchingBranchUser = getUserBasedOnSourcingBranch(applicationId);
                                    for(TR_Deviation__c trBasedOnLevel : levelBasedTrMap.get(level)){
                                        System.debug('trBasedOnLevel'+ trBasedOnLevel);
                                        if(trBasedOnLevel.Decistion__c == 'Approval for Pending' && trBasedOnLevel.Approval_Authority__c != null){
                                            System.debug('trBasedOnLevel sourcing branch'+ trBasedOnLevel);
                                            if(trBasedOnLevel.Is_Deviation_Raised__c == false && applicationObj.Is_Deviation_Raised__c == false && applicationObj.Current_Deviation_Approval__c == null){
                                                System.debug('trBasedOnLevel sourcing branch'+ trBasedOnLevel);
                                                //Map<String, Map<String, String>> sourchingBranchUser = getUserBasedOnSourcingBranch(applicationId);
                                                if(sourchingBranchUser != null && sourchingBranchUser.size() >0 && sourchingBranchUser.containsKey('L5')){
                                                    applicationObj.Is_Deviation_Raised__c = true;
                                                    System.debug('trBasedOnLevel sourcing branch'+ trBasedOnLevel);
                                                    if(sourchingBranchUser.get('L5') != null && sourchingBranchUser.get('L5').size() > 0){
                                                        System.debug('sourchingBranchUser.get(L5)[0].keySet();'+ sourchingBranchUser.get('L5').keySet());
                                                        Set<String> l5UserId = sourchingBranchUser.get('L5').keySet();
                                                        if(l5UserId.isEmpty() == false){
                                                            for(String userId : l5UserId){
                                                                System.debug(userId);
                                                                applicationObj.Current_Deviation_Approval__c = userId;
                                                                
                                                            }
                                                            applicationUpdated = true;
                                                            
                                                        }
                                                    }
                                                    
                                                    //applicationObj.Current_Deviation_Approval__c = 
                                                }
                                            }}
                                    } 
                                }
                            }
                            
                        }
                        else {
                            System.debug('level is'+level);
                            if(levelBasedTrMap != null && levelBasedTrMap.size() > 0 && levelBasedTrMap.containsKey(level)){
                                System.debug('Lvel from level map'+ level + levelBasedTrMap.get(level));
                                if(levelBasedTrMap.get(level) != null && levelBasedTrMap.get(level).size() > 0 ){
                                    for(TR_Deviation__c trBasedOnLevel : levelBasedTrMap.get(level)){
                                        if(trBasedOnLevel.Decistion__c == 'Approval for Pending' && trBasedOnLevel.Approval_Authority__c != null){
                                            trBasedOnLevel.Is_Deviation_Raised__c = True;
                                            raiseDeviationList.add(trBasedOnLevel);
                                            
                                        }
                                        else if(trBasedOnLevel.Decistion__c == 'Not Approved'){
                                            break;
                                        }
                                    }
                                    break;
                                }
                                else{
                                    System.debug(levelBasedTrMap.get(level).size());
                                }
                            }
                        }
                    }
                }
                if(raiseDeviationList.size() > 0){
                    update raiseDeviationList;
                }
                if(applicationUpdated == true && applicationObj != null){
                    update applicationObj;
                    //send notification to L5 user to raise deviation for L6/L7 user: 11-nov-22
                    sendNotificationToL5User(applicationObj);
                }
            }
            
            
        } catch (Exception e) {
            system.debug('Exception'+e.getLineNumber()+' meassage '+e.getMessage());
            //throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    // save tr deviation for vs 2
    @AuraEnabled
    public static List<Tr_Deviation__c> saveTrDeviationRecords(String devWrapperList){
        List<Tr_Deviation__c> updateTrDevList = new List<Tr_Deviation__c>();
        System.debug('save wrapper list' + devWrapperList);
        //if(devWrapperList != null){
        List<deviationWrapper> wrapperTrDevList = (List<deviationWrapper>)JSON.deserialize(devWrapperList,List<deviationWrapper>.class);
        System.debug('wrapper data to update'+wrapperTrDevList);
        if(wrapperTrDevList.size() > 0){
            for(deviationWrapper wrapList : wrapperTrDevList){
                Tr_Deviation__c trItem = new Tr_Deviation__c();
                trItem = wrapList.devList;
                
                updateTrDevList.add(trItem);
            }
        }
        //}
        System.debug('tr list to update' + updateTrDevList.size());
        if(updateTrDevList.size() > 0){
            upsert updateTrDevList;
        }
        return updateTrDevList;
        
    }
    
    // get current login user for vs 2 if deviation created level is lower than current login user than it should be assigned to current login user 
    // and its approval authority dropdown should disabled
    //User__r.Approval_Level__c
    /* @AuraEnabled
public static Map<String, User> getCurrentLoginUser(String applicationId){
String loggedInUser = UserInfo.getUserId();
Map<String, User> currentDevLevelWithUser = new Map<String, User>();
System.debug('logged in user' + loggedInUser);
User currentUser = [SELECT Id, Name, Approval_Level__c FROM User WHERE Id =:loggedInUser LIMIT 1];
System.debug('Current user details' + currentUser);
List<Tr_Deviation__c> currentTrDevToApprove = [SELECT Id, Approval_Level__c, Is_Deviation_Raised__c, Decistion__c, Application__c FROM Tr_Deviation__c 
WHERE Is_Deviation_Raised__c = true AND (Decistion__c = 'Approval for Pending' OR Decistion__c = 'Not Approved') 
AND Application__c =:applicationId LIMIT 1] ;
String currentTrDevLevel;  
if(currentTrDevToApprove.size() > 0)   {
currentTrDevLevel = currentTrDevToApprove[0].Approval_Level__c;
currentDevLevelWithUser.put(currentTrDevLevel, currentUser);
}
else{
System.debug('in else');
List<Tr_Deviation__c> initialTrDevToApprove = [SELECT Id, Approval_Level__c, Is_Deviation_Raised__c, Decistion__c, Application__c FROM Tr_Deviation__c 
WHERE (Decistion__c = 'Approval for Pending' ) AND Is_Deviation_Raised__c = false 
AND Application__c =:applicationId ORDER BY Approval_Level__c ASC] ;
System.debug('in else' + initialTrDevToApprove);
if(initialTrDevToApprove.size() > 0){
currentTrDevLevel = initialTrDevToApprove[0].Approval_Level__c;
currentDevLevelWithUser.put(currentTrDevLevel, currentUser);
}
}                         

System.debug('current deviation level' + currentTrDevLevel + 'and user' + currentDevLevelWithUser.get(currentTrDevLevel));

return currentDevLevelWithUser;
}*/
    @AuraEnabled
    //public static void sendEmailToApprovalUser(String usrToMail, String devDes, String applicationId, String devId){
        public static void sendEmailToApprovalUser(String usrToMail,  String applicationId){
        System.debug('users map to send email'+usrToMail  + applicationId);
        List<Tr_Deviation__c> devToRaise = new List<Tr_Deviation__c>(); 
        if(applicationId != null){
            String applicationNumber = [SELECT Id, Name FROM Application__c WHERE Id =:applicationId LIMIT 1].Name;
            //if(devId != null){
             //   devToRaise = [SELECT Id,  Is_Deviation_Raised__c FROM Tr_Deviation__c WHERE Id =: devId AND Application__c =: applicationId AND Is_Deviation_Active__c = true LIMIT 1];
          //  }
            System.debug('application name '+ applicationNumber);
            List<String> sendTo = new List<String>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            if(usrToMail != null){
                User usrToSendMail = [SELECT Id, Email, Name FROM User WHERE Id =:usrToMail AND IsActive = true LIMIT 1];
                
                if( usrToSendMail != null && usrToSendMail.Email != null){
                    System.debug('user and email'+usrToSendMail.Id + usrToSendMail.Email );
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    sendTo.add(usrToSendMail.Email);
                    
                    mail.setToAddresses(sendTo);
                    mail.setSubject('Deviation Raised for Application: '+ applicationNumber);
                    String body = 'Dear ' + usrToSendMail.Name + ', <br><br>';
                    body += 'Deviation is assigned to you for Application: ' + applicationNumber;
                    body += '. Please click on below link to view this Application. <br>';
                    body += URL.getSalesforceBaseUrl().toExternalForm() + '/' + applicationId;
                    body += '<br><br>';
                    body += 'Thanks<br>';
                    body += UserInfo.getName();
                    mail.setHtmlBody(body);
                    mails.add(mail);
                    // Step 6: Send all emails in the master list
                    Messaging.sendEmail(mails); 
                    
                }
              //  if(devToRaise != null && devToRaise.size() > 0){
                //devToRaise[0].Is_Deviation_Raised__c = true;
                  //  System.debug('devToRaise' + devToRaise + 'and if raised ' + devToRaise[0].Is_Deviation_Raised__c);
                   // update devToRaise; //Commented By umair
               // }
            }
            
        }
        
        
    }
    //To get map of Ms_Deviation__c with user based on level of Ms deviation and tr deviation
    @AuraEnabled
    public static void StringmapOfMsDevWithUser(String applicationId, String stageName){
        
        List<Tr_Deviation__c> trDevList = new List<Tr_Deviation__c>();
        List<Ms_Deviation__c> msCode = new List<Ms_Deviation__c>();
        //Map of Level with user ida nad name
        Map<String, Map<String,String>> levelWithUserMap = new Map<String, Map<String,String>>();
        Map<Ms_Deviation__c, Map<String,String>> msDevWithUserMap= new Map<Ms_Deviation__c,Map<String,String>>();
        if(applicationId != null){
            levelWithUserMap = getUserBasedOnSourcingBranch(applicationId);
            if(stageName != null){
                if(stageName == 'Process Credit' || stageName == 'Approval Credit'){
                    trDevList = [SELECT Id, Ms_Deviation__c, Approval_Authority__c, MS_Deviation__r.Stage__c FROM Tr_Deviation__c WHERE Application__c =:applicationId
                                 AND Deviation_Type__c = 'Manual' AND Is_Deviation_Active__c = true AND MS_Deviation__r.Stage__c = 'Credit'];
                    
                    msCode = [SELECT Id, Name, Approval_Authority__c, Deviation_Level__c,Deviation_Description__c, Code__c  FROM MS_Deviation__c 
                              WHERE Deviation_Type__c = 'Manual' AND Is_Active__c = 'Yes' AND Stage__c = 'Credit' ];
                    
                }
                else if(stageName == 'Disbursal Maker' || stageName == 'Disbursal Author'){
                    trDevList = [SELECT Id, Ms_Deviation__c, Approval_Authority__c, MS_Deviation__r.Stage__c FROM Tr_Deviation__c WHERE Application__c =:applicationId
                                 AND Deviation_Type__c = 'Manual' AND Is_Deviation_Active__c = true AND MS_Deviation__r.Stage__c = 'Operations'];
                    
                    msCode = [SELECT Id, Name, Approval_Authority__c, Deviation_Level__c,Deviation_Description__c, Code__c  FROM MS_Deviation__c 
                              WHERE Deviation_Type__c = 'Manual' AND Is_Active__c = 'Yes' AND Stage__c = 'Operations' ];
                }
            }
            Set<String> uniqueId = new Set<String>();
            if(trDevList.size() > 0){
                for(Tr_Deviation__c trDev : trDevList){
                    if(trDev.Approval_Authority__c != null){
                        uniqueId.add(applicationId + '-' + trDev.Ms_Deviation__c + '-' + trDev.Approval_Authority__c);
                        System.debug('uniqueId'+ uniqueId);
                    }
                }
                
            }
            Map<String,String> userBasedOnLevel = new Map<String,String>();
            
            if(msCode.size() > 0){
                for(Ms_Deviation__c msDev : msCode){
                    if(levelWithUserMap.size() > 0){
                        if(levelWithUserMap.containsKey(msDev.Approval_Authority__c)){
                            userBasedOnLevel = levelWithUserMap.get(msDev.Approval_Authority__c);
                            if(userBasedOnLevel.size() > 0){
                                Map<String,String> userAvailable = new Map<String,String>();
                                for(String userId : userBasedOnLevel.keySet()){ 
                                    String uniqueIdToAssign = applicationId + '-' + msDev.Id + '-' + userId;
                                    if(uniqueId.contains(uniqueIdToAssign)){
                                        System.debug('already have tr deviation for same ms deviation and user');
                                    }
                                    else{
                                        userAvailable.put(userId, userBasedOnLevel.get(userId));
                                    }
                                }
                                if(userAvailable.size() > 0){
                                    msDevWithUserMap.put(msDev, userAvailable);
                                }
                            }
                        }
                    }
                }
            }
            
        }
        System.debug('final map'+ msDevWithUserMap);
    }
    
    //To Fet lastlogindate of current user
    @AuraEnabled
    public static Boolean isDeviationApprovalStage(String verificationId){
        system.debug('@@## verificationId '+verificationId);
        List<Verification__c> verifications = [SELECT ID, Application__c, Application__r.Is_Deviation_Raised__c, Application__r.Is_Deviation_Approval_User__c FROM Verification__c WHERE ID =: verificationId AND Application__r.Is_Deviation_Raised__c = TRUE];
        if(verifications != NULL && !verifications.isEmpty()){
            return verifications.get(0).Application__r.Is_Deviation_Approval_User__c;
        }
        return false;
    }
    
    
    /***** Added By Ajay Kumar 
******* For Checking Validations at Submit for PC/AC*****************/
    @AuraEnabled
    public static ValidationWrapper  getAllPendingDeviatons(String applicationId,String stage)
    {
        ValidationWrapper validationWrapObj = new ValidationWrapper();
        for(Tr_Deviation__c trObj : [SELECT Id,Name,Decistion__c,IS_Deviation_Active__c,MS_Deviation__r.Stage__c,Deviation_Description__c  FROM Tr_Deviation__c WHERE  Decistion__c !='Approved' AND Decistion__c != 'Not Applicable' AND MS_Deviation__r.Stage__c=:stage AND Application__c=:applicationId  AND Is_Deviation_Active__c=true])
        {
            validationWrapObj.PendingDeviationsExist = true;
            validationWrapObj.pendingDeviationsList.add(trObj.Deviation_Description__c);            
        }        
        return validationWrapObj;
    }
    
    public class ValidationWrapper
    {       
        @AuraEnabled public Boolean PendingDeviationsExist;
        @AuraEnabled public List<String> pendingDeviationsList;
        
        public ValidationWrapper()
        {
            PendingDeviationsExist = false;
            pendingDeviationsList = new List<String>();
        }
    }
    
    // For Vs 3 
    //To get users based on approval user from Access branch allocation from Access Master based on application sourcing branch
    @AuraEnabled
    public static Map<String,Map<String, String>> getUserBasedOnSourcingBranch(String applicationId){
        Map<String,Map<String,String>> userListMap = new Map<String,Map<String,String>>();
        List<Access_Branch_Allocation__c> usrBranchAllocation = new List<Access_Branch_Allocation__c>();
        if(applicationId != null){
            String sourcingBranch = [SELECT Id, Sourcing_Branch__c FROM Application__c WHERE Id =:applicationId].Sourcing_Branch__c;
            System.debug('sourcingBranch'+sourcingBranch);
            if(sourcingBranch != null){
                usrBranchAllocation = [SELECT Id, Access_Master__r.User__c, Access_Master__r.Level__c, Access_Master__r.User__r.Name FROM Access_Branch_Allocation__c 
                                       WHERE Branch_Master__c =: sourcingBranch AND Access_Master__r.Access_For__c = 'Deviation Approval'];
                
                if(usrBranchAllocation != null && usrBranchAllocation.size() > 0){
                    for(Access_Branch_Allocation__c userBranch : usrBranchAllocation){
                        List<String> usrApprovalLevel = new List<String>();
                        String approvalLevel;
                        if(userBranch.Access_Master__r.Level__c != null){
                            approvalLevel = 'L'+userBranch.Access_Master__r.Level__c;
                            
                            if(userListMap.containsKey(approvalLevel)){
                                
                                userListMap.get(approvalLevel).put(userBranch.Access_Master__r.User__c, userBranch.Access_Master__r.User__r.Name);
                                System.debug('user map'+userListMap + 'size'+ userListMap.get(approvalLevel));
                            }
                            else{
                                // Map<String, String> userMap = new Map<String, String>();
                                
                                userListMap.put(approvalLevel, new Map<String, String>{userBranch.Access_Master__r.User__c => userBranch.Access_Master__r.User__r.Name});
                            }
                        }
                    }
                }
            }
            
            
            
            
        }
        if(userListMap.size() > 0){
            System.debug('userList map vs 2'+userListMap);
            // if approval level is Credit committee then provide list of L5 users
            if(userListMap.containsKey('L5')){
                userListMap.put('Credit committee',userListMap.get('L5'));
            }
        }
        System.debug(userListMap);
        return userListMap;
    }
    
    //For vs 3 
    //To get current login user and check if he is deviation approval user of application sourcing branch
    //SELECT Id, Access_Master__r.Name, Branch_Master__r.Name, Access_Master__r.User__r.Name, Access_Master__r.Level__c 
    //FROM Access_Branch_Allocation__c WHERE Branch_Master__c = 'a0T0w000004Ky4wEAC' AND Access_Master__r.User__c = '0050w000003bQa5AAE' AND Access_Master__r.Access_For__c = 'Deviation Approval'
    
    // get current login user for vs 2 if deviation created level is lower than current login user than it should be assigned to current login user 
    // and its approval authority dropdown should disabled
    //User__r.Approval_Level__c
    @AuraEnabled
    public static Map<String, CurrentUserWrapper> getCurrentLoginUser(String applicationId){
        String loggedInUser = UserInfo.getUserId();
        Map<String, CurrentUserWrapper> currentDevLevelWithUser = new Map<String, CurrentUserWrapper>();
        CurrentUserWrapper loginUserLevel = new CurrentUserWrapper();
        String currentTrDevLevel;
        System.debug('logged in user' + loggedInUser);
        User currentUser = [SELECT ID, Name FROM User WHERE Id =: loggedInUser AND IsActive = true];
        if(applicationId != null){
            String sourcingBranch = [SELECT Id, Sourcing_Branch__c FROM Application__c WHERE Id =: applicationId LIMIT 1].Sourcing_Branch__c;
            
            List<Tr_Deviation__c> currentTrDevToApprove = [SELECT Id, Approval_Level__c, Is_Deviation_Raised__c, Decistion__c, Application__c FROM Tr_Deviation__c 
                                                           WHERE Is_Deviation_Raised__c = true AND (Decistion__c = 'Approval for Pending' OR Decistion__c = 'Not Approved') 
                                                           AND Application__c =:applicationId AND Is_Deviation_Active__c = true LIMIT 1] ;
            if(currentTrDevToApprove != null && currentTrDevToApprove.size() > 0)   {
                currentTrDevLevel = currentTrDevToApprove[0].Approval_Level__c;
                if(currentTrDevLevel == 'Credit committee'){
                    currentTrDevLevel = 'L5';
                }
            }
            
            
            
            //Check if current login user is Deviation approval user for application sourcing branch
            if(String.isNotBlank(sourcingBranch)){
                List<Access_Branch_Allocation__c> accessBranchUser = [SELECT Id, Access_Master__r.Name, Branch_Master__r.Name, Access_Master__r.User__r.Name, Access_Master__r.Level__c FROM Access_Branch_Allocation__c 
                                                                      WHERE Branch_Master__c =: sourcingBranch AND Access_Master__r.User__c =: loggedInUser AND Access_Master__r.Access_For__c = 'Deviation Approval'];
                
                if(accessBranchUser != null && accessBranchUser.size() > 0){
                    // if this is true i.e. user is Deviation approval of application sourcing branch
                    List<String> levelOfCurrentLogInUserInBranch = new List<string>();
                    for(Access_Branch_Allocation__c accesBranch : accessBranchUser){
                        //if user is selected for multiple levels in same branch
                        levelOfCurrentLogInUserInBranch.add('L'+accesBranch.Access_Master__r.Level__c);
                    }
                    loginUserLevel.currentUser = currentUser;
                    loginUserLevel.approvalLevel = levelOfCurrentLogInUserInBranch;                                       
                    
                    if(currentTrDevToApprove != null && currentTrDevToApprove.size() > 0)   {
                        currentTrDevLevel = currentTrDevToApprove[0].Approval_Level__c;
                        if(currentTrDevLevel == 'Credit committee'){
                            currentTrDevLevel = 'L5';
                        }
                        currentDevLevelWithUser.put(currentTrDevLevel, loginUserLevel);
                    }
                    else{
                        System.debug('in else');
                        /*List<Tr_Deviation__c> initialTrDevToApprove = [SELECT Id, Approval_Level__c, Is_Deviation_Raised__c, Decistion__c, Application__c FROM Tr_Deviation__c 
                                                                       WHERE (Decistion__c = 'Approval for Pending' ) AND Is_Deviation_Raised__c = false 
                                                                       AND Application__c =:applicationId AND Is_Deviation_Active__c = true ORDER BY Approval_Level__c ASC] ;
                        System.debug('in else' + initialTrDevToApprove);*/
                        
                       /* if(initialTrDevToApprove != null && initialTrDevToApprove.size() > 0){
                            currentTrDevLevel = initialTrDevToApprove[0].Approval_Level__c;
                            currentDevLevelWithUser.put(currentTrDevLevel, loginUserLevel);
                            
                        }
                        else{*/
                            currentTrDevLevel = 'L1';
                            currentDevLevelWithUser.put(currentTrDevLevel, loginUserLevel);
                       // }
                    } 
                }
                else{
                    //this user is not part of application sourcing branch and deviation created level is lower than current raised deviation level for this application
                    loginUserLevel.currentUser = null;
                    loginUserLevel.approvalLevel = null;
                    currentDevLevelWithUser.put(currentTrDevLevel, loginUserLevel);
                }
            }
        }                        
        
        System.debug('current deviation level' + currentTrDevLevel + 'and user' + currentDevLevelWithUser.get(currentTrDevLevel));
        System.debug('currentDevLevelWithUser MAp'+ currentDevLevelWithUser);
        
        return currentDevLevelWithUser;
    }
    
    public class CurrentUserWrapper {
        @AuraEnabled
        public User currentUser;
        @AuraEnabled
        public List<String> approvalLevel;
    }
     //Date : 11-Nov-22 : To send notification to L5 user if there is pending deviation for L6/L7 user
    public static void sendNotificationToL5User(Application__c app){
        System.debug('Send notification with app id' + app.Name);
        // Create a new custom notification
        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        if(app != null){
            // Get the custom Notification type.
            List<CustomNotificationType > ListOfTemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Deviation_Notification'];
            List<Messaging.CustomNotification> LiscurrNotification = new List<Messaging.CustomNotification>();
            // Set the contents for the delinking notification
             currNotification.setTitle('Please Raise Pending Deviations for L6/L7!');
             currNotification.setBody(app.Name);

             // Set the notification type and target
             currNotification.setNotificationTypeId(ListOfTemplateInfoDetail[0].Id);
             currNotification.setTargetId(app.Id);

             // Send the notification
             currNotification.send(new Set<String> {app.Current_Deviation_Approval__c});
                // to create application tracking for L5
             Map<String, String> mapOfTrDev = new Map<String,String>();
             mapOfTrDev.put(app.Id, 'L5');
             devApplicationTracking(mapOfTrDev);
        }
    }
    //Date : 12-Nov-22 : To Create application user tracking record based on deviation
    //public static void devApplicationTracking(List<Application__c> appList){
    // changed for L6/L7 
    /*public static void devApplicationTracking(List<String> appList){
        if(appList != null && appList.size() > 0){
            List<Application_User_Tracking__c> appTrackingList = [SELECT Id,Status__c,Stage__c,Application__c, Type__c,Start_Date__c, End_Date__c FROM  Application_User_Tracking__c
                                                                 WHERE  Application__c =:appList AND Type__c = 'Deviation' AND Status__c = 'Pending'];
                                                                 
            List<Application__c> applicationList = [SELECT Id, Current_Deviation_Approval__c, Is_Deviation_Raised__c, Stage__c FROM Application__c WHERE Id =: appList];
            List<Application_User_Tracking__c> appTrackingToUpdate = new List<Application_User_Tracking__c>();
            //for(Application__c app : appList){
            for(Application__c app : applicationList){
                Application_User_Tracking__c devTracking = new Application_User_Tracking__c();
                //To create Application_User_Tracking__c record for Deviation : 12-11-22
                devTracking.Stage__c = app.Stage__c;
                //devTracking.Stage__c = 'Approval Credit';
                devTracking.Application__c = app.Id;
                devTracking.Status__c = 'Pending';
                devTracking.Type__c = 'Deviation';
                devTracking.Owner__c = app.Current_Deviation_Approval__c;
                devTracking.Start_Date__c = System.now();
                appTrackingToUpdate.add(devTracking);
                // To update pending application tracking
                if(appTrackingList != null && appTrackingList.size() > 0){
                    for(Application_User_Tracking__c appTrack : appTrackingList){
                        if(appTrack.Application__c == app.Id){
                            appTrack.Status__c = 'Completed';
                            appTrack.End_Date__c = System.now();
                            appTrackingToUpdate.add(appTrack);
                        }
                    }
                }
            }
            if(appTrackingToUpdate != null && appTrackingToUpdate.size() > 0){
                upsert appTrackingToUpdate;
            }
        }
        
    }*/

    public static void devApplicationTracking(Map<String, String> appList){
        system.debug('appList'+ appList);
        if(appList != null && appList.size() > 0){
            List<Application_User_Tracking__c> appTrackingList = [SELECT Id,Status__c,Stage__c,Application__c, Type__c,Start_Date__c, Sub_Type__c , End_Date__c FROM  Application_User_Tracking__c
                                                                 WHERE  Application__c =:appList.keySet() AND Type__c = 'Deviation' AND Status__c = 'Pending'];
                                                                 
            List<Application__c> applicationList = [SELECT Id, Current_Deviation_Approval__c, Is_Deviation_Raised__c, Stage__c FROM Application__c WHERE Id =: appList.keySet()];
            List<Tr_Deviation__c> deviationList = [SELECT Id, Approval_Authority__c, Approval_Level__c, Is_Deviation_Active__c, Is_Deviation_Raised__c, Decistion__c, Application__c FROM Tr_Deviation__c
                                                  WHERE Application__c =: appList.keySet() AND Is_Deviation_Active__c = true AND (Approval_Level__c = 'L6' OR Approval_Level__c = 'L7') AND Decistion__c = 'Approval for Pending' AND Is_Deviation_Raised__c = false ORDER BY Approval_Level__c Asc];
            
            Map<String, TR_Deviation__c> devBasedOnRaisedDev = new Map<String, TR_Deviation__c>();
            //To check level for tr dev
            for(String appIds : appList.keySet()){
                if(appList.get(appIds) == 'L6' || appList.get(appIds) == 'L7'){
                    if(deviationList != null && deviationList.size() > 0){
                        system.debug('deviationList'+ deviationList);
                        for(Tr_Deviation__c dev : deviationList){
                        
                            if(dev.Application__c == appIds && dev.Approval_Level__c == appList.get(appIds)){
                                devBasedOnRaisedDev.put(appIds, dev);
                                system.debug('devBasedOnRaisedDev'+ devBasedOnRaisedDev);
                            }
                    
                        }
                
                    }
                }

              /*  else if(appList.get(appIds) == 'L7'){
                    if(deviationList != null && deviationList.size() > 0){
                        for(Tr_Deviation__c dev : deviationList){
                        
                            if(dev.Application__c == appIds && dev.Approval_Level__c == 'L7'){
                                devBasedOnRaisedDev.put(appIds, dev);
                            }
                    
                        }
                
                    }
                }*/
            }
            List<Application_User_Tracking__c> appTrackingToUpdate = new List<Application_User_Tracking__c>();
            if(applicationList != null && applicationList.size() > 0){
           
            //for(Application__c app : appList){
            for(Application__c app : applicationList){
                if(appList.get(app.Id) == 'L6' || appList.get(app.Id) == 'L7'){
                    system.debug('app'+ app);
                    if(appTrackingList != null && appTrackingList.size() > 0){
                        for(Application_User_Tracking__c appTrack : appTrackingList){
                            system.debug('appTrack'+ appTrack);
                            if(appTrack.Application__c == app.Id && appTrack.Sub_Type__c == 'Deviation '+ appList.get(app.Id)){
                                system.debug('appTrack sub type'+ appTrack.Sub_Type__c);
                                continue;
                               /* if(devBasedOnRaisedDev != null && devBasedOnRaisedDev.size() > 0 && devBasedOnRaisedDev.containsKey(app.Id)){
                                    continue;
                                }
                                else{
                                    appTrack.Status__c = 'Completed';
                                    appTrack.End_Date__c = System.now();
                                    appTrackingToUpdate.add(appTrack);
                                }*/
                                
                            }
                            else{
                                System.debug('create L6/L7 tracking');
                                // create new tracking record for L6/L7
                                Application_User_Tracking__c devTracking = new Application_User_Tracking__c();
                                //To create Application_User_Tracking__c record for Deviation : 12-11-22
                                devTracking.Stage__c = app.Stage__c;
                                //devTracking.Stage__c = 'Approval Credit';
                                devTracking.Application__c = app.Id;
                                devTracking.Status__c = 'Pending';
                                devTracking.Type__c = 'Deviation';
                                devTracking.Sub_Type__c = 'Deviation '+ appList.get(app.Id);
                                devTracking.Owner__c = app.Current_Deviation_Approval__c;
                                devTracking.Start_Date__c = System.now();
                                appTrackingToUpdate.add(devTracking);
                                // To update pending application tracking
                                if(appTrackingList != null && appTrackingList.size() > 0){
                                    for(Application_User_Tracking__c appTracking : appTrackingList){
                                        if(appTracking.Application__c == app.Id){
                                            appTracking.Status__c = 'Completed';
                                            appTracking.End_Date__c = System.now();
                                            appTrackingToUpdate.add(appTracking);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        // there is no application tracking record
                        System.debug('create L6/L7 tracking if no pending tracking record');
                        // create new tracking record for L6/L7
                        Application_User_Tracking__c devTracking = new Application_User_Tracking__c();
                        //To create Application_User_Tracking__c record for Deviation : 12-11-22
                        devTracking.Stage__c = app.Stage__c;
                        //devTracking.Stage__c = 'Approval Credit';
                        devTracking.Application__c = app.Id;
                        devTracking.Status__c = 'Pending';
                        devTracking.Type__c = 'Deviation';
                        devTracking.Sub_Type__c = 'Deviation '+ appList.get(app.Id);
                        devTracking.Owner__c = app.Current_Deviation_Approval__c;
                        devTracking.Start_Date__c = System.now();
                        appTrackingToUpdate.add(devTracking);
                                
                    }
                }
                // for any other level
                else{
                    Application_User_Tracking__c devTracking = new Application_User_Tracking__c();
                    //To create Application_User_Tracking__c record for Deviation : 12-11-22
                    devTracking.Stage__c = app.Stage__c;
                    //devTracking.Stage__c = 'Approval Credit';
                    devTracking.Application__c = app.Id;
                    devTracking.Status__c = 'Pending';
                    devTracking.Type__c = 'Deviation';
                    devTracking.Sub_Type__c = 'Deviation '+ appList.get(app.Id);
                    devTracking.Owner__c = app.Current_Deviation_Approval__c;
                    devTracking.Start_Date__c = System.now();
                    appTrackingToUpdate.add(devTracking);
                    // To update pending application tracking
                    if(appTrackingList != null && appTrackingList.size() > 0){
                        for(Application_User_Tracking__c appTrack : appTrackingList){
                            if(appTrack.Application__c == app.Id){
                                appTrack.Status__c = 'Completed';
                                appTrack.End_Date__c = System.now();
                                appTrackingToUpdate.add(appTrack);
                            }
                        }
                    }
                }
            }
        }
            if(appTrackingToUpdate != null && appTrackingToUpdate.size() > 0){
                upsert appTrackingToUpdate;
            }
        }
        
    }

    //Added to get approved or rejected deviation for approval authority validation for same level
    @AuraEnabled
    public static Map<String, String> getApprovedDev(String applicationId, String stageName){
        Map<String, String> approvalAutWithLevel = new Map<String, String>();
        try {
            List<TR_Deviation__c> deviationList = new List<TR_Deviation__c>();
            if(applicationId != null && String.isNotBlank(stageName)){
                
                if(stageName == 'Process Credit' || stageName == 'Approval Credit'){
                    deviationList = [SELECT Id,Name, Deviation_Code__c, Deviation_Type__c, Applicable_For__c, Loan_Applicant__c,
                                     Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Property__c, Approval_Level__c, Decistion__c, Remark__c, Mitigants__c, 
                                     Approval_Authority__c,Approval_Authority__r.Name, MS_Deviation__c, MS_Deviation__r.Name, MS_Deviation__r.Deviation_Description__c, 
                                     Is_Deviation_Raised__c, Deviation_Description__c FROM Tr_Deviation__c 
                                     WHERE Application__c =: applicationId AND Is_Deviation_Active__c = true AND MS_Deviation__r.Stage__c = 'Credit' AND (Decistion__c = 'Approved' OR Decistion__c = 'Not Approved')
                                     ORDER BY Approval_Level__c Asc];
                }
                else if(stageName == 'Disbursal Maker' || stageName == 'Disbursal Author'){
                    deviationList = [SELECT Id,Name, Deviation_Code__c, Deviation_Type__c, Applicable_For__c, Loan_Applicant__c,
                                     Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Property__c, Approval_Level__c, Decistion__c, Remark__c, Mitigants__c, 
                                     Approval_Authority__c,Approval_Authority__r.Name, MS_Deviation__c, MS_Deviation__r.Name, MS_Deviation__r.Deviation_Description__c, 
                                     Is_Deviation_Raised__c, Deviation_Description__c FROM Tr_Deviation__c 
                                     WHERE Application__c =: applicationId AND Is_Deviation_Active__c = true AND MS_Deviation__r.Stage__c = 'Operations'  AND (Decistion__c = 'Approved' OR Decistion__c = 'Not Approved')
                                     ORDER BY Approval_Level__c Asc];
                    
                }
            }
            if(deviationList != null && deviationList.size() > 0){
                for(Tr_Deviation__c dev : deviationList){
                    approvalAutWithLevel.put(dev.Approval_Level__c, dev.Approval_Authority__c);
                }
            }
            return approvalAutWithLevel;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //To check if deviation raised for application or not if yes only deviation approval user can add row else other can also.: 5 dec 22
    @AuraEnabled
    public static Boolean appIsRaise(String applicationId){
        try {
            //if(applicationId != null){
                return [SELECT Id, Is_Deviation_Raised__c FROM Application__c WHERE Id =: applicationId].Is_Deviation_Raised__c;
            //}
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}