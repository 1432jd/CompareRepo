/**
* @File Name          : TRDeviationApprovalCLass.apxc
* @Author             : Umair Ahmad	
* @Description		  : This is a controller for deviationApprovalScreen LWC Component
* @Created On         : 25 August 2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       27 August 2022            Umair Ahmad             Initial Version
**/

public without sharing class TRDeviationApprovalCLass {
    
    
    //This method fetch TR Deviation Approval records and TR Deviation And MS Master fields and send it to Component in JS. 
    @AuraEnabled(cacheable=true)
    public static List<deviationApprovalWrapper> getTRDeviationRecord(String applicationId, String stageName){
        
        try {
            Boolean isLevelFive = false;
            String stageType ;
            String loggedInUser = UserInfo.getUserId();
            User us = [Select ID, Approval_Level__c From user where Id=:loggedInUser];
            
            List<deviationApprovalWrapper> dvWrapList = new List<deviationApprovalWrapper>();
            List<deviationApprovalWrapper> dvWrapLevelFiveList = new List<deviationApprovalWrapper>();
            
            Application__c applicationObj = new  Application__c();
            integer index = 0;
            Boolean isLevelFiveValid = false;

            if(applicationId != null){
                applicationObj = [Select Id, Stage__c, Current_Deviation_Approval__c, Is_Deviation_Raised__c from Application__c where Id =:applicationId Limit 1];
            }
            
            //if(applicationObj.Stage__c == 'Process Credit' || applicationObj.Stage__c == 'Approval Credit')
            if(stageName == 'Process Credit' || stageName == 'Approval Credit')
            {
                stageType = 'Credit';
            }
            else
                if(stageName == 'Disbursal Maker' || stageName == 'Disbursal Author')
            {
                stageType = 'Operations';
                
            }
            
            if(applicationId != null){
                Map<String, Map<String, String>> sourchingBranchUser = pcDeviationController.getUserBasedOnSourcingBranch(applicationId);
                System.debug('sourchingBranchUser>>>1111>>> '+sourchingBranchUser);
                for(TR_Deviation__c trDevObj : [Select Id,Date_of_Approval__c,Is_Send_Email__c, Deviation_Description__c , MS_Deviation__c, Applicable_For__c,
                Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Decistion__c, Remark__c,Approval_Authority__c,
                Mitigants__c, Deviation_Type__c, Is_Deviation_Raised__c, Approval_Level__c,MS_Deviation__r.Deviation_Description__c
                From TR_Deviation__c
                where Application__c =: applicationId  AND MS_Deviation__r.Stage__c =:stageType AND
                Decistion__c ='Approval for Pending'  AND is_Deviation_Active__c = true AND (Is_Deviation_Raised__c = true OR ((Approval_Level__c ='L6' OR Approval_Level__c ='L7') AND Is_Send_Email__c = false))]){
                    system.debug('isLevelFiveValiddddd '+isLevelFiveValid);
                    System.debug('applicationObj.Is_Deviation_Raised__c111>> ' + trDevObj.Is_Deviation_Raised__c);
                        if(trDevObj.Approval_Level__c == 'L5' ){
                            system.debug('sourchingBranchUser.get(l5555 )?????'+sourchingBranchUser.get('L5'));
                            system.debug('sourcing branhc L5555 '+sourchingBranchUser.get('L5').containsKey(us.Id));
                            if(sourchingBranchUser.get('L5') != null && sourchingBranchUser.get('L5').containsKey(us.Id) && applicationObj.Is_Deviation_Raised__c == true){
                                isLevelFiveValid = true;

                            }
                        }
                        else 
                            if((trDevObj.Approval_Level__c == 'L6' || trDevObj.Approval_Level__c == 'L7') && !trDevObj.Is_Send_Email__c && applicationObj.Is_Deviation_Raised__c == true){
                            if(sourchingBranchUser.get('L5') != null && sourchingBranchUser.get('L5').containsKey(us.Id) ){
                                isLevelFiveValid = true;
                            }
                            system.debug('isLevelFiveValiddddd2222 '+isLevelFiveValid);

                            }
                            else 
                            if(trDevObj.Approval_Level__c != 'L5' && trDevObj.Approval_Level__c != 'L6' && trDevObj.Approval_Level__c != 'L7'){
                                isLevelFiveValid = false;
                                break;
                            }
                }
            }

            if(applicationId != null){
                Map<String, Map<String, String>> sourchingBranchUser = pcDeviationController.getUserBasedOnSourcingBranch(applicationId);
                
                if(sourchingBranchUser.get('L5') != null && sourchingBranchUser.get('L5').containsKey(us.Id) && isLevelFiveValid){
                    isLevelFive = true;
                    for(TR_Deviation__c trDevObj : [Select Id,Date_of_Approval__c,Is_Send_Email__c, Deviation_Description__c , MS_Deviation__c, Applicable_For__c,
                                                    Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Decistion__c, Remark__c,Approval_Authority__c,
                                                    Mitigants__c, Deviation_Type__c, Is_Deviation_Raised__c, Approval_Level__c,MS_Deviation__r.Deviation_Description__c
                                                    From TR_Deviation__c
                                                    where Application__c =: applicationId  AND MS_Deviation__r.Stage__c =:stageType AND
                                                    Decistion__c ='Approval for Pending'  AND is_Deviation_Active__c = True AND 
                                                    ( (Approval_Level__c ='L5' AND Is_Deviation_Raised__c = true) OR ((Approval_Level__c ='L6' OR Approval_Level__c ='L7') )) AND Approval_Authority__c!= null order by Approval_Level__c asc]){
                                                        
                                                        List<ConditionallyDecisionWrapper> wrapDecisionList = new List<ConditionallyDecisionWrapper>();
                                                        deviationApprovalWrapper wrapObj = new deviationApprovalWrapper();
                                                        ++index;
                                                        wrapObj.srNo = index;
                                                        wrapObj.applicableFor = trDevObj.Applicable_for__c;
                                                        wrapObj.applicant = trDevObj.Loan_Applicant__r.Applicant_Name__c;
                                                        wrapObj.property = trDevObj.Property__r.Name;
                                                        wrapObj.approvalLevel = trDevObj.Approval_Level__c; 
                                                        wrapObj.approvalAuthority = trDevObj.Approval_Authority__c;
                                                        wrapObj.decision = trDevObj.Decistion__c;  
                                                        wrapObj.isSendEmail = trDevObj.Is_Send_Email__c;

                                                        ConditionallyDecisionWrapper wrapDecision1 = new ConditionallyDecisionWrapper();
                                                        if(trDevObj.Approval_Level__c == 'L6' || trDevObj.Approval_Level__c == 'L7'){
                                                            wrapDecision1.label = 'Send Email';
                                                            wrapDecision1.value = 'Send Email';
                                                            wrapDecisionList.add(wrapDecision1);
                                                        }
                                                        else{
                                                            wrapDecision1.label = 'Approved';
                                                            wrapDecision1.value = 'Approved';
                                                            wrapDecisionList.add(wrapDecision1);
                                                        }
                                                        ConditionallyDecisionWrapper wrapDecision2 = new ConditionallyDecisionWrapper();
                                                        wrapDecision2.label = 'Rejected';
                                                        wrapDecision2.value = 'Rejected';
                                                        wrapDecisionList.add(wrapDecision2);
                                                        wrapObj.ConditionallyDecisionWrapList = wrapDecisionList;
                                                        wrapObj.applicationId = applicationId;
                                                        wrapObj.deviationType = trDevObj.Deviation_Type__c;
                                                        wrapObj.deviationDescriptionName = trDevObj.Deviation_Description__c;
                                                        wrapObj.devId = trDevObj.Id;
                                                        dvWrapLevelFiveList.add(wrapObj);
                                                        
                                                    }
                }
                else{
                    for(TR_Deviation__c trDevObj : [Select Id,Date_of_Approval__c,Is_Send_Email__c, Deviation_Description__c , MS_Deviation__c, Applicable_For__c,
                                                    Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Decistion__c, Remark__c,
                                                    Mitigants__c, Deviation_Type__c, Is_Deviation_Raised__c, Approval_Level__c,MS_Deviation__r.Deviation_Description__c
                                                    From TR_Deviation__c
                                                    where Application__c =: applicationId AND Approval_Authority__c=: loggedInUser AND 
                                                    Decistion__c ='Approval for Pending'  AND
                                                    MS_Deviation__r.Stage__c =:stageType AND is_Deviation_Active__c = True AND Is_Deviation_Raised__c=true order by Approval_Level__c asc]){
                                                        
                                                        List<ConditionallyDecisionWrapper> wrapDecisionList = new List<ConditionallyDecisionWrapper>();
                                                        deviationApprovalWrapper wrapObj = new deviationApprovalWrapper();
                                                        ++index;
                                                        wrapObj.srNo = index;
                                                        wrapObj.applicableFor = trDevObj.Applicable_for__c;
                                                        if(trDevObj.Applicable_for__c == 'Asset'){
                                                            wrapObj.property = trDevObj.Property__r.Name;
                                                        }else if(trDevObj.Applicable_for__c == 'Applicant'){
                                                            wrapObj.property = trDevObj.Loan_Applicant__r.Applicant_Name__c;
                                                        }
                                                        wrapObj.approvalLevel = trDevObj.Approval_Level__c; 
                                                        wrapObj.decision = trDevObj.Decistion__c;  
                                                        wrapObj.isSendEmail = trDevObj.Is_Send_Email__c;

                                                        ConditionallyDecisionWrapper wrapDecision1 = new ConditionallyDecisionWrapper();
                                                        wrapDecision1.label = 'Approved';
                                                        wrapDecision1.value = 'Approved';
                                                        wrapDecisionList.add(wrapDecision1);
                                                        ConditionallyDecisionWrapper wrapDecision2 = new ConditionallyDecisionWrapper();
                                                        wrapDecision2.label = 'Rejected';
                                                        wrapDecision2.value = 'Rejected';
                                                        wrapDecisionList.add(wrapDecision2);
                                                        wrapObj.ConditionallyDecisionWrapList = wrapDecisionList;
                                                        wrapObj.applicationId = applicationId;
                                                        wrapObj.deviationType = trDevObj.Deviation_Type__c;
                                                        wrapObj.deviationDescriptionName = trDevObj.Deviation_Description__c;
                                                        wrapObj.devId = trDevObj.Id;
                                                        dvWrapList.add(wrapObj);
                                                        
                                                        
                                                        
                                                    }
                }
                system.debug('levell five  '+isLevelFive);
                
                
            }
            
            system.debug('dvWrapList '+dvWrapList);
            system.debug('dvWrapLevelFiveList '+dvWrapLevelFiveList);
            
            if(isLevelFive == true){
                return dvWrapLevelFiveList;
            }  else{
                return dvWrapList;
            }
        } catch (Exception e) {
            system.debug('Exception'+e.getLineNumber()+' meassage '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    //@Author : Sangeeta
    /*Description : This method fetch TR Deviation records to send notification to user based on lowest approval level pending deviation 
by setting raised deviation checkbox to true */
    @AuraEnabled
    public static void getLowestLevPendingTRDev(String applicationId, String Decision){
        
        try {
            
            Map<String, List<TR_Deviation__c>> levelBasedTrMap = new  Map<String, List<TR_Deviation__c>>();
            Map<String, List<TR_Deviation__c>> levelBasedRejectedTrMap = new  Map<String, List<TR_Deviation__c>>();
            String stageType ;
            Boolean applicationUpdated = false;   // if current deviation to be raised is L6 or L7 than application current deviation user is updated to L5 user
            Boolean isLevelFiveAppUpdate = false;
            List<String> mapKeySet = new List<String>();
            Application__c applicationObj = new  Application__c();
            integer index = 1;
            Boolean currentLevelFive = false;
            Boolean isLevelSixExist = false;
            set<String> levelSet = new Set<String>();
            
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
                for(TR_Deviation__c trDevObj : [Select Id, Is_Send_Email__c,Deviation_Description__c , MS_Deviation__c, Applicable_For__c,Approval_Level__c,
                                                Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Decistion__c, Remark__c,
                                                Mitigants__c, Deviation_Type__c From TR_Deviation__c where Application__c =: applicationId AND Is_Deviation_Active__c = true]){
                                                    
                                                    levelSet.add(trDevObj.Approval_Level__c);
                                                    
                                                    
                                                }
            }
            
            
            if(applicationId != null){
                for(TR_Deviation__c trDevObj : [Select Id,Is_Send_Email__c, Deviation_Description__c , MS_Deviation__c, Applicable_For__c,
                                                Loan_Applicant__r.Applicant_Name__c, Property__r.Name, Decistion__c, Remark__c,
                                                Mitigants__c, Deviation_Type__c, Is_Deviation_Raised__c, Approval_Level__c, Approval_Authority__c From TR_Deviation__c
                                                where Application__c =: applicationId AND
                                                MS_Deviation__r.Stage__c =:stageType AND is_Deviation_Active__c = True ]){
                                                    
                                                    for(String level : levelSet){
                                                        if(trDevObj.Approval_Level__c != null){
                                                            if(level == trDevObj.Approval_Level__c && (trDevObj.Decistion__c == 'Approval for Pending' || trDevObj.Decistion__c == 'Not Approved' )){//|| trDevObj.Decistion__c == 'Send Email'
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
                Set<String> sendEmailSet = new Set<String>();
                
                if(mapKeySet != null){
                    for(String level : mapKeySet){
                        
                        System.debug('Lvel from level map'+ level + levelBasedTrMap.get(level));
                        if(level == 'L6' || level == 'L7'){
                            System.debug('level in if'+level);
                            // Added to assign Deviation Approval user as L5 if L6 and L7 level deviation to raise
                            //Date : 11-Nov-22 Sangeeta Yadav
                            
                            if(levelBasedTrMap != null && levelBasedTrMap.size() > 0 && levelBasedTrMap.containsKey(level)){
                                System.debug('Lvel from level map'+ level + levelBasedTrMap.get(level));
                                if(levelBasedTrMap.get(level) != null && levelBasedTrMap.get(level).size() > 0 ){
                                    for(TR_Deviation__c trBasedOnLevel : levelBasedTrMap.get(level)){
                                        if(trBasedOnLevel.Decistion__c == 'Approval for Pending' && trBasedOnLevel.Approval_Authority__c != null){
                                            if(trBasedOnLevel.Is_Deviation_Raised__c == false && applicationObj.Is_Deviation_Raised__c == false && applicationObj.Current_Deviation_Approval__c == null && trBasedOnLevel.Is_Send_Email__c == false){
                                                Map<String, Map<String, String>> sourchingBranchUser = pcDeviationController.getUserBasedOnSourcingBranch(applicationId);
                                                if(sourchingBranchUser != null && sourchingBranchUser.size() >0 && sourchingBranchUser.containsKey('L5')){
                                                    applicationObj.Is_Deviation_Raised__c = true;
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
                                                }
                                            } else if(trBasedOnLevel.Is_Send_Email__c == true && trBasedOnLevel.Decistion__c != 'Not Approved' && trBasedOnLevel.Approval_Authority__c != null){
                                                isLevelFiveAppUpdate = true;
                                                trBasedOnLevel.Is_Deviation_Raised__c = true;
                                                raiseDeviationList.add(trBasedOnLevel);
                                                
                                                sendEmailSet.add(trBasedOnLevel.Approval_Authority__c);    
                                            }
                                        }
                                    } 
                                }
                            }
                            break;
                        }
                        else {
                            if(levelBasedTrMap != null && levelBasedTrMap.get(level).size() > 0 ){
                                
                                for(TR_Deviation__c trBasedOnLevel : levelBasedTrMap.get(level)){
                                    if(trBasedOnLevel.Decistion__c == 'Approval for Pending' && trBasedOnLevel.Approval_Authority__c != null ){
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
                
                if(!sendEmailSet.isEmpty() && sendEmailSet.size()>0 ){
                    List<String> sendEmailUserList = new List<String>();
                    sendEmailUserList.addAll(sendEmailSet);
                    pcDeviationController.sendEmailToApprovalUser(sendEmailUserList[0], applicationId);
                }
                
                if(raiseDeviationList != null && raiseDeviationList.size() > 0){
                    System.debug('raiseDeviationList' + raiseDeviationList);
                    update raiseDeviationList;
                }
                else{
                    if(applicationUpdated == false && isLevelFiveAppUpdate == false){
                        //if deviation raised and inactive but not approved/ rejected and there is no other deviation to raised
                        
                        applicationObj.Current_Deviation_Approval__c = null;
                        applicationObj.Is_Deviation_Raised__c = FALSE;
                        update applicationObj;
                        
                    }
                }
                if(applicationUpdated == true && applicationObj != null){
                    System.debug('update application');
                    if(Decision != 'Not Approved'){
                        update applicationObj;
                        //send notification to L5 user to raise deviation for L6/L7 user: 11-nov-22
                        
                        pcDeviationController.sendNotificationToL5User(applicationObj);
                    }
                    else{
                        applicationObj.Is_Deviation_Raised__c = false;
                        applicationObj.Current_Deviation_Approval__c = null;
                        update applicationObj;
                    }
                }
            }
        } catch (Exception e) {
            system.debug('Exception'+e.getLineNumber()+' meassage '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void updateDecisions(String deviationList){
        system.debug('deviationListtttttt '+deviationList);
        List<deviationApprovalWrapper> dvWrapList =  (List<deviationApprovalWrapper>) JSON.deserialize(deviationList, List<deviationApprovalWrapper>.class);
        List<String> trDevIdList = new List<string>();
        List<TR_Deviation__c> trDevList = new  List<TR_Deviation__c>();
        String Decision;
        
        String loggedInUser = UserInfo.getUserId();
        User us = [Select ID,name, Approval_Level__c From user where Id=:loggedInUser AND isActive = true Limit 1];
        Map<String, String> userMap = new  Map<String, String>();
        userMap.put(us.Id,us.Name);
        
        Boolean levelFiveRejected = false;
        Map<String,String> approvalLevelMap = new Map<String,String>();
        Boolean isLevelSixExist = false;
        Integer count = 0;
        Boolean isAnyRejected = false;
        
        for(deviationApprovalWrapper wrpData : dvWrapList){
            if(wrpData.approvalLevel == 'L6'){
                isLevelSixExist = true;
            }
        }
        
        //To updat TR devaition record
        for(deviationApprovalWrapper wrpData : dvWrapList){
            
            if(wrpData.approvalStatus == 'Rejected'){
                isAnyRejected = true;
            }
            Map<String, Map<String, String>> sourchingBranchUser = pcDeviationController.getUserBasedOnSourcingBranch(wrpData.applicationId);
            system.debug('chingBranchUser.get != null '+sourchingBranchUser.get('L5').containsKey(us.Id)+'send emailll '+wrpData.isSendEmail);
            if(sourchingBranchUser.get('L5') != null && sourchingBranchUser.get('L5').containsKey(us.Id) &&  !wrpData.isSendEmail){
                if(wrpData.approvalLevel == 'L5' && wrpData.approvalStatus == 'Rejected'){
                    levelFiveRejected = true;
                    TR_Deviation__c trDevObj = new TR_Deviation__c();
                    trDevObj.Id  = wrpData.devId;
                    trDevObj.Decistion__c = 'Not Approved';
                    trDevObj.Remark__c = wrpData.remarks;
                    trDevObj.Mitigants__c = wrpData.mitigants;
                    trDevObj.Date_of_Approval__c = system.today();
                    trDevList.add(trDevObj);
                }
                else
                    if(wrpData.approvalLevel == 'L5' && wrpData.approvalStatus == 'Approved'){
                        TR_Deviation__c trDevObj = new TR_Deviation__c();
                        trDevObj.Id  = wrpData.devId;
                        trDevObj.Decistion__c = 'Approved';
                        trDevObj.Remark__c = wrpData.remarks;
                        trDevObj.Mitigants__c = wrpData.mitigants;
                        trDevObj.Date_of_Approval__c = system.today();
                        trDevList.add(trDevObj);
                    }
                if(levelFiveRejected == false && (wrpData.approvalLevel == 'L6' || wrpData.approvalLevel == 'L7') 
                   && wrpData.approvalStatus == 'Send Email'){
                       TR_Deviation__c trDevObj = new TR_Deviation__c();
                       trDevObj.Id  = wrpData.devId;
                       trDevObj.Is_Send_Email__c = true;
                       trDevObj.Remark__c = wrpData.remarks;
                       trDevObj.Mitigants__c = wrpData.mitigants;
                       trDevObj.Date_of_Approval__c = system.today();
                       trDevList.add(trDevObj);
                       
                   }
                else if(levelFiveRejected == true && (wrpData.approvalLevel == 'L6' || wrpData.approvalLevel == 'L7') 
                        && wrpData.approvalStatus == 'Send Email'){
                            TR_Deviation__c trDevObj = new TR_Deviation__c();
                            trDevObj.Id  = wrpData.devId;
                            trDevObj.Remark__c = wrpData.remarks;
                            trDevObj.Is_Send_Email__c = true;
                            trDevObj.Mitigants__c = wrpData.mitigants;
                            trDevObj.Date_of_Approval__c = system.today();
                            trDevList.add(trDevObj);
                        }
                else if(levelFiveRejected == true && (wrpData.approvalLevel == 'L6' || wrpData.approvalLevel == 'L7') 
                        && wrpData.approvalStatus == 'Rejected'){
                            TR_Deviation__c trDevObj = new TR_Deviation__c();
                            trDevObj.Id  = wrpData.devId;
                            trDevObj.Decistion__c = 'Not Approved';
                            trDevObj.Remark__c = wrpData.remarks;
                            trDevObj.Mitigants__c = wrpData.mitigants;
                            trDevObj.Date_of_Approval__c = system.today();
                            trDevList.add(trDevObj);
                        }
                else if(levelFiveRejected == false && (wrpData.approvalLevel == 'L6' || wrpData.approvalLevel == 'L7') 
                        && wrpData.approvalStatus == 'Rejected'){
                            TR_Deviation__c trDevObj = new TR_Deviation__c();
                            trDevObj.Id  = wrpData.devId;
                            trDevObj.Decistion__c = 'Not Approved';
                            trDevObj.Remark__c = wrpData.remarks;
                            trDevObj.Mitigants__c = wrpData.mitigants;
                            trDevObj.Date_of_Approval__c = system.today();
                            trDevList.add(trDevObj);
                        }

                //@Description : if L5 user has assigned deviation of lower level : 7 Dec 22 : Sangeeta yadav
                else if(wrpData.approvalLevel != 'L5' && wrpData.approvalLevel != 'L6' && wrpData.approvalLevel != 'L7') {
                    if(wrpData.isChanged && wrpData.approvalStatus == 'Approved'  ){
                    system.debug('dvWrapListttt>> '+dvWrapList);
                    TR_Deviation__c trDevObj = new TR_Deviation__c();
                    trDevObj.Id  = wrpData.devId;
                    trDevObj.Decistion__c = 'Approved';
                    trDevObj.Remark__c = wrpData.remarks;
                    trDevObj.Mitigants__c = wrpData.mitigants;                    
                    trDevObj.Date_of_Approval__c = system.today();
                    trDevList.add(trDevObj);                    
                }
                else
                    if(wrpData.isChanged && wrpData.approvalStatus == 'Rejected'){
                        TR_Deviation__c trDevObj = new TR_Deviation__c();
                        trDevObj.Id  = wrpData.devId;
                        trDevObj.Decistion__c = 'Not Approved';
                        trDevObj.Date_of_Approval__c = system.today();
                        trDevList.add(trDevObj);
                        Decision = 'Not Approved';
                    }
                }
            }
            else {
                if(wrpData.isChanged && wrpData.approvalStatus == 'Approved'  ){
                    system.debug('dvWrapListttt>> '+dvWrapList);
                    TR_Deviation__c trDevObj = new TR_Deviation__c();
                    trDevObj.Id  = wrpData.devId;
                    trDevObj.Decistion__c = 'Approved';
                    trDevObj.Remark__c = wrpData.remarks;
                    trDevObj.Mitigants__c = wrpData.mitigants;                    
                    trDevObj.Date_of_Approval__c = system.today();
                    trDevList.add(trDevObj);                    
                }
                else
                    if(wrpData.isChanged && wrpData.approvalStatus == 'Rejected'){
                        TR_Deviation__c trDevObj = new TR_Deviation__c();
                        trDevObj.Id  = wrpData.devId;
                        trDevObj.Decistion__c = 'Not Approved';
                        trDevObj.Date_of_Approval__c = system.today();
                        trDevList.add(trDevObj);
                        Decision = 'Not Approved';
                    }
            }
            
        }
        
        if(!trDevList.isEmpty()){
            update trDevList;
        }
        if(!dvWrapList.isEmpty() && !isAnyRejected){
            getLowestLevPendingTRDev(dvWrapList[0].applicationId, Decision);
        }   
    }
    
    
    public class deviationApprovalWrapper{
        
        @AuraEnabled
        public Integer srNo;
        @AuraEnabled
        public String applicationId;
        @AuraEnabled
        public String deviationDescriptionName;
        @AuraEnabled
        public String applicableFor;
        @AuraEnabled
        public String applicant;
        @AuraEnabled
        public String property;
        @AuraEnabled
        public String approvalLevel;
        
        @AuraEnabled
        public List<ConditionallyDecisionWrapper> ConditionallyDecisionWrapList; 
        @AuraEnabled
        public Boolean isDisabled;
        @AuraEnabled
        public String remarks;
        @AuraEnabled
        public String mitigants;
        @AuraEnabled
        public String deviationType;
        @AuraEnabled
        public String decision;
        @AuraEnabled
        public String devId;
        @AuraEnabled
        public String applicationName;
        @AuraEnabled
        public String nextapprovallevel;        
        @AuraEnabled
        public String nextapprovalUser;        
        @AuraEnabled
        public String approvalStatus;       
        @AuraEnabled
        public Boolean isChanged;
        @AuraEnabled
        public String approvalAuthority;
        @AuraEnabled
        public Boolean isSendEmail;
        public  deviationApprovalWrapper(){
            isChanged = false;
            isDisabled = false;
            nextapprovallevel ='';
            nextapprovalUser ='';
            approvalStatus ='';
        }
    }
    
    public class ConditionallyDecisionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
}