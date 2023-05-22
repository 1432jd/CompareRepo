/**
* @File Name          : TRDeviationTriggerHelper
* @Author             : Navin Soni
* @Created On         : 14 Sep 2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       14 Sep 2022              Navin Soni             Initial Version
**/
public without sharing class TRDeviationTriggerHelper{
    // This method is use to send Notifications to the Application Davition Approval User.
    public static void sendDevitionNotifications(Boolean isInsert, List<TR_Deviation__c> listOfTRDeviation, Map<Id,TR_Deviation__c> oldMap ){
        Map<String, TR_Deviation__c> mapOfApplications = new Map<String, TR_Deviation__c>();
        Set<String> approvalAuthorityUsers = new Set<String>();
        Set<Application__c> setOfApplication = new Set<Application__c>();
        //This map is Added for Application Tracking record : 14-11-22 : Sangeeta yadav
        Map<String, String> mapOfTrDev = new Map<String, String>();
        Set<String> appSetForTrack = new Set<String>();
        Set<String> decistionChangedApplications = new Set<String>();
        Set<String> inActiveDeviations = new Set<String>();
        Map<String, TR_Deviation__c> decistionChangedL5Applications = new Map<String, TR_Deviation__c>(); //Not approved L6 and L7 by L5 only
        // Create a new custom notification
        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        
        if(listOfTRDeviation != null && listOfTRDeviation.size() > 0){
            
            for(TR_Deviation__c objTRDev : listOfTRDeviation){
                
                if(isInsert){
                    System.debug('isInsert'+objTRDev.Is_Deviation_Raised__c + objTRDev.Deviation_Description__c);
                    if(objTRDev.Is_Deviation_Active__c && objTRDev.Is_Deviation_Raised__c && objTRDev.Approval_Authority__c != null){
                        mapOfApplications.put(objTRDev.Application__c, objTRDev);
                    }
                }else{
                    if(objTRDev.Is_Deviation_Active__c && objTRDev.Is_Deviation_Raised__c != oldMap.get(objTRDev.id).Is_Deviation_Raised__c && objTRDev.Is_Deviation_Raised__c && objTRDev.Approval_Authority__c != null){
                        mapOfApplications.put(objTRDev.Application__c, objTRDev);
                    }
                    if(objTRDev.Is_Deviation_Active__c && objTRDev.Is_Deviation_Raised__c && (objTRDev.Decistion__c != oldMap.get(objTRDev.id).Decistion__c || (objTRDev.Is_Send_Email__c !=  oldMap.get(objTRDev.id).Is_Send_Email__c && objTRDev.Is_Send_Email__c == true)) && objTRDev.Approval_Authority__c != null){
                        decistionChangedApplications.add(objTRDev.Application__c);
                    }
                    //If L5 rejects L6 or L7 deviation
                    if(objTRDev.Is_Deviation_Active__c && objTRDev.Decistion__c != oldMap.get(objTRDev.id).Decistion__c && objTRDev.Decistion__c == 'Not Approved' && objTRDev.Is_Send_Email__c == false && objTRDev.Approval_Authority__c != null){
                        if(objTRDev.Approval_Level__c == 'L6' || objTRDev.Approval_Level__c == 'L7')
                            System.debug('If L5 rejects L6 or L7 deviation');
                            decistionChangedL5Applications.put(objTRDev.Application__c, objTRDev);
                    }
                    if(objTRDev.Is_Deviation_Raised__c && objTRDev.Approval_Authority__c != null && objTRDev.Is_Deviation_Active__c != oldMap.get(objTRDev.id).Is_Deviation_Active__c && (!objTRDev.Is_Deviation_Active__c)){
                        inActiveDeviations.add(objTRDev.Application__c);
                        System.debug('inActiveDeviations'+inActiveDeviations);
                    }
                }
            }
            
            try{
                System.debug('@@##  mapOfApplications' + mapOfApplications.keySet());
                System.debug('@@##  mapOfApplications' + mapOfApplications.size());
                if(mapOfApplications != null && mapOfApplications.size() > 0){
                    // Get the custom Notification type.
                    List<CustomNotificationType > ListOfTemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Deviation_Notification'];
                    List<Messaging.CustomNotification> LiscurrNotification = new List<Messaging.CustomNotification>();
                    
                    for(String objStr : mapOfApplications.keySet()){
                        // Set the contents for the delinking notification
                        currNotification.setTitle('Deviation has Raised for the Application!');
                        currNotification.setBody(mapOfApplications.get(objStr).Application_Name__c);

                        // Set the notification type and target
                        currNotification.setNotificationTypeId(ListOfTemplateInfoDetail[0].Id);
                        currNotification.setTargetId(objStr);

                        // Send the notification
                        currNotification.send(new Set<String> {mapOfApplications.get(objStr).Approval_Authority__c});
                        
                        Application__c objApp = new Application__c();
                        objApp.id = objStr;
                        objApp.Current_Deviation_Approval__c = mapOfApplications.get(objStr).Approval_Authority__c;
                        objApp.Is_Deviation_Raised__c = TRUE;
                        setOfApplication.add(objApp);
                        System.debug('mapOfApplications.get(objStr).Approval_Authority__c'+mapOfApplications.get(objStr).Approval_Authority__c);
                        System.debug('mapOfApplications.get(objStr).Approval_Level__c'+mapOfApplications.get(objStr).Approval_Level__c);
                       // if(mapOfApplications.get(objStr).Approval_Level__c == 'L6' || mapOfApplications.get(objStr).Approval_Level__c == 'L7'){
                        if(mapOfApplications.get(objStr).Approval_Level__c == 'Credit committee'){
                            mapOfTrDev.put(objApp.id, 'L5');
                        }
                        else{
                            mapOfTrDev.put(objApp.id, mapOfApplications.get(objStr).Approval_Level__c);
                        }
                       // }
                       // else{
                            appSetForTrack.add(objApp.id);
                       // }
                        

                        
                    }
                    // Update Application.
                    if(setOfApplication != null && setOfApplication.size() > 0){
                        List<Application__c> listOfApplications = new List<Application__c>();
                        listOfApplications.addAll(setOfApplication);
                        System.debug('listOfApplications' + listOfApplications);
                        Update listOfApplications;
                        //To Create Application Tracking Record for Deviation: 12-11-22
                        List<string> appIds = new List<String>();
                        appIds.addAll(appSetForTrack);
                        //pcDeviationController.devApplicationTracking(listOfApplications);
                        //changed for L6 and L7 in application user tracking
                        //pcDeviationController.devApplicationTracking(appIds);
                        pcDeviationController.devApplicationTracking(mapOfTrDev);
                        
                    }
                }

                if(decistionChangedApplications != null && decistionChangedApplications.size() > 0){
                    removeCurrentApproval(decistionChangedApplications);
                }
                //for L6 and L7 not approved by L5 user
                if(decistionChangedL5Applications != null && decistionChangedL5Applications.size() > 0){
                    removeCurrentApprovalByL5(decistionChangedL5Applications);
                }
                /*@Author : Sangeeta Yadav
                 @Dated : 16-Nov-22
                 @Description : To update Raised TR Deviation if current raised deviation is inactive on re-execution */
                 System.debug('inActiveDeviations' + inActiveDeviations);
                if(inActiveDeviations != null && inActiveDeviations.size() > 0){
                   updateRaisedDevOnInactiveDev(inActiveDeviations);
                }

                
            }
            catch (Exception ex) {
                System.debug('Notification Failed: ' + ex.getMessage());
            }
        }
    }

    //remove current approval if L5 reject L6/L7 deviation
    public static void removeCurrentApprovalByL5(Map<String, TR_Deviation__c> setOfApplicationIds){
        List<Application__c> appList = new List<Application__c>();
        List<Application_User_Tracking__c> appTrackingList = [SELECT Id,Status__c,Stage__c,Application__c, Type__c,Start_Date__c, End_Date__c, Sub_Type__c FROM  Application_User_Tracking__c
                                                                 WHERE  Application__c =:setOfApplicationIds.keySet() AND Type__c = 'Deviation' AND Status__c = 'Pending'AND Sub_Type__c = 'Deviation L5'];
        if(setOfApplicationIds != null && setOfApplicationIds.size() > 0){
            for(String objTrApp : setOfApplicationIds.keySet()){
                if(setOfApplicationIds.get(objTrApp).Decistion__c == 'Not Approved'){
                    Application__c objApp = new Application__c();
                    objApp.id = objTrApp;
                    objApp.Current_Deviation_Approval__c = null;
                    objApp.Is_Deviation_Raised__c = FALSE;
                    appList.add(objApp);
                    if(appTrackingList != null && appTrackingList.size() > 0){
                        for(Application_User_Tracking__c appTrack: appTrackingList){
                            if(appTrack.Application__c == objTrApp){
                                appTrack.Status__c = 'Completed';
                                appTrack.End_Date__c = System.now();
                            }
                        }
                    }
                }
            }
        }
        if(appList != null && appList.size() > 0){
            update appList;
            if(appTrackingList != null && appTrackingList.size() > 0){
                update appTrackingList;
            }
        }
        
    }

    // This method is used to remove Current Approval user and Davition Raise option.
    public static void removeCurrentApproval(Set<String> setOfApplicationIds){
        List<Application__c> listOfApplications = new List<Application__c>();
        Set<String> setOfApprovedApplication = new Set<String>();
        Set<String> setOfNotApprovedApplication = new Set<String>();
        Map<String,Boolean> isPending = new Map<String,Boolean>();
        if(setOfApplicationIds != null && setOfApplicationIds.size() > 0){
            for(TR_Deviation__c objTR : [SELECT ID, Application__c, Decistion__c FROM TR_Deviation__c WHERE Application__c IN : setOfApplicationIds AND Is_Deviation_Active__c = TRUE AND Is_Deviation_Raised__c = TRUE ]){
                if(objTR.Decistion__c == 'Not Approved'){
                    setOfNotApprovedApplication.add(objTR.Application__c);
                }
                else if(objTR.Decistion__c == 'Approved'){
                    setOfApprovedApplication.add(objTR.Application__c);
                }
                else if(objTR.Decistion__c == 'Approval for pending'){
                    System.debug('objTR.Decistion__c' + objTR.Decistion__c);
                    isPending.put(objTR.Application__c,true);
                }
            }
            List<String> appList = new List<String>();
            for(String applicationId : setOfApplicationIds){
                if(setOfNotApprovedApplication.contains(applicationId) || (setOfApprovedApplication.contains(applicationId) && !setOfNotApprovedApplication.contains(applicationId))){
                    if(isPending != null && isPending.size() > 0 && isPending.containsKey(applicationId)){
                    }
                    else{
                    Application__c objApp = new Application__c();
                    objApp.id = applicationId;
                    objApp.Current_Deviation_Approval__c = null;
                    objApp.Is_Deviation_Raised__c = FALSE;
                    listOfApplications.add(objApp);
                    appList.add(objApp.Id);
                    System.debug('appList to update to null if no deviation raised'+appList);
                    }
                }
            }
            // do not update application tracking for L6/L7 if there is pending deviation swhich are not raised for L6/L7
            List<Tr_Deviation__c> deviationList = [SELECT Id, Approval_Authority__c, Approval_Level__c, Is_Deviation_Active__c, Is_Deviation_Raised__c, Decistion__c, Application__c FROM Tr_Deviation__c
                                                  WHERE Application__c =: appList AND Is_Deviation_Active__c = true AND (Approval_Level__c = 'L6' OR Approval_Level__c = 'L7') AND Decistion__c = 'Approval for Pending' AND Is_Deviation_Raised__c = false ORDER BY Approval_Level__c Asc];
            if(listOfApplications != null && listOfApplications.size() > 0){
                Update listOfApplications;
                //to update application tracking for deviation records: 13-Nov-22
                List<Application_User_Tracking__c> appTrackingList = [SELECT Id,Status__c,Stage__c,Application__c, Type__c,Start_Date__c, End_Date__c, Sub_Type__c FROM  Application_User_Tracking__c
                                                                 WHERE  Application__c =:listOfApplications AND Type__c = 'Deviation' AND Status__c = 'Pending'];
                // To update pending application tracking
                for(Application__c app : listOfApplications){
                    if(appTrackingList != null && appTrackingList.size() > 0){
                        for(Application_User_Tracking__c appTrack : appTrackingList){
                            if(appTrack.Application__c == app.Id && (appTrack.Sub_Type__c == 'Deviation L6' || appTrack.Sub_Type__c == 'Deviation L7') && !setOfNotApprovedApplication.contains(app.Id)){
                                System.debug('sub type is L6/L7');
                                Integer countPendingDev = 0;
                                if(deviationList != null && deviationList.size() > 0){
                                    for(Tr_Deviation__c devLev : deviationList){
                                        if(('Deviation ' + devLev.Approval_Level__c) == appTrack.Sub_Type__c){
                                            countPendingDev++;
                                        }
                                        else{
                                            continue;
                                        }
                                    }
                                    if(countPendingDev > 0){
                                        continue;
                                    }
                                    else{
                                        appTrack.Status__c = 'Completed';
                                        appTrack.End_Date__c = System.now();
                                    }
                                }
                                else{
                                    //No pending deviation for L6/L7
                                    appTrack.Status__c = 'Completed';
                                    appTrack.End_Date__c = System.now();

                                }
                                
                            }
                            else{
                                System.debug('sub type is not L6/L7' + appTrack.Sub_Type__c);
                                appTrack.Status__c = 'Completed';
                                appTrack.End_Date__c = System.now();
                            }
                        }
                    }  
                } 
                if(appTrackingList != null && appTrackingList.size() > 0){
                    update appTrackingList;
                }                                              
            }
        }
    }

    // This method is used to update application current deviation user if deviation raised is in active on re-execution : 16-nov-22
    public static void updateRaisedDevOnInactiveDev(Set<String> setOfApplicationIds){
        if(setOfApplicationIds != null && setOfApplicationIds.size() > 0){
            Map<String, Application__c> applicationUpdated = new Map<String, Application__c>();
            List<Application__c> updateApp = new List<Application__c>(); // if there is no pending deviation for the application: 9 Dec 22
            List<TR_Deviation__c> raiseDeviationList = new List<TR_Deviation__c>();
            List<Application__c> applicationObj = [Select Id, Name, Stage__c, Is_Deviation_Raised__c, Current_Deviation_Approval__c from Application__c where Id =:setOfApplicationIds];
            Map<String, List<Tr_Deviation__c>> appWithTrDevList = new Map<String, List<Tr_Deviation__c>>();
            List<TR_Deviation__c> listTrDeviation = new List<TR_Deviation__c>();
            listTrDeviation = [SELECT Id, Decistion__c, Approval_Authority__c, Approval_Level__c, Application__r.Current_Deviation_Approval__c, MS_Deviation__r.Stage__c,
                                Is_Deviation_Active__c, Is_Deviation_Raised__c, Application__r.Is_Deviation_Raised__c, Deviation_Description__c, Application__c FROM TR_Deviation__c 
                                where Application__c =: setOfApplicationIds AND Is_Deviation_Active__c = true ORDER BY Approval_Level__c];// AND Decistion__c = 'Approval for Pending' removed to get all deviations
            if(listTrDeviation != null && listTrDeviation.size() > 0){
                String stageType;
                for(Tr_Deviation__c dev : listTrDeviation){
                    
                    if(appWithTrDevList.containsKey(dev.Application__c)){
                        appWithTrDevList.get(dev.Application__c).add(dev);
                    }
                    else{
                        appWithTrDevList.put(dev.Application__c, new List<Tr_deviation__c> {dev});
                    }
                }
                if(applicationObj != null && applicationObj.size() > 0){
                    for(Application__c appId : applicationObj){
                        List<Tr_deviation__c> trDevList = new List<Tr_deviation__c>(); // Tr Deviation for this application (All: not filtered based on stageName)
                        List<String> mapKeySet = new List<String>(); // for approval level set
                        Map<String, List<TR_Deviation__c>> levelBasedTrMap = new  Map<String, List<TR_Deviation__c>>();//Map of Tr deviation with level
                        if(appWithTrDevList != null && appWithTrDevList.size() > 0){
                            if(appWithTrDevList.containsKey(appId.Id)){
                                if(String.isNotBlank(appId.Stage__c)  ){
                                    if(appId.Stage__c == 'Process Credit' || appId.Stage__c == 'Approval Credit')
                                    {
                                        stageType = 'Credit';
                                    }
                                    else
                                        if(appId.Stage__c == 'Disbursal Maker' || appId.Stage__c == 'Disbursal Author')
                                    {
                                        stageType = 'Operations';
                    
                                    }
                                }
                                trDevList = appWithTrDevList.get(appId.Id); //All tr deviation from application is copied credit and operation both
                            }
                            //If map does not contain application id i.e. no pending deviation: 9 Dec 22
                            //update app
                            else{
                                appId.Is_Deviation_Raised__c = false;
                                appId.Current_Deviation_Approval__c = null;
                                updateApp.add(appId);
                            }

                            List<Tr_Deviation__c> appDevStageWise = new List<Tr_Deviation__c>();//List of Tr deviation based on stage credit or operations
                            if(trDevList != null && trDevList.size() > 0){
                                
                                for(Tr_Deviation__c appDev : trDevList){
                                    if(appDev.MS_Deviation__r.Stage__c == stageType){
                                        appDevStageWise.add(appDev);
                                    }
                                }
                            }
                            if(appDevStageWise != null && appDevStageWise.size() > 0){
                                for(Tr_deviation__c devForLevel : appDevStageWise){
                                    if(devForLevel.Approval_Level__c != null){
                                        if(devForLevel.Decistion__c == 'Approval for Pending' || devForLevel.Decistion__c == 'Not Approved'){
                                            // trDevObj.Is_Deviation_Raised__c = True;
                                            if(!mapKeySet.contains(devForLevel.Approval_Level__c)){
                                                mapKeySet.add(devForLevel.Approval_Level__c);
                                            }
                                            if(levelBasedTrMap.containsKey(devForLevel.Approval_Level__c)){
                                                levelBasedTrMap.get(devForLevel.Approval_Level__c).add(devForLevel);
                                            }
                                            else{
                                                levelBasedTrMap.put(devForLevel.Approval_Level__c, new List<TR_Deviation__c>{devForLevel});
                                            }
                                        }      
                                    }
                                //                    }
                                }
                                
                                //List<TR_Deviation__c> raiseDeviationList = new List<TR_Deviation__c>();
                                if(mapKeySet != null){
                                    mapKeySet.sort();
                                    for(String level : mapKeySet){
                                        System.debug('level is'+level);
                                        if(level == 'L6' || level == 'L7'){
                                            System.debug('level in if'+level);
                                            // Added to assign Deviation Approval user as L5 if L6 and L7 level deviation to raise
                            
                                            if(levelBasedTrMap != null && levelBasedTrMap.size() > 0 && levelBasedTrMap.containsKey(level)){
                                                System.debug('Lvel from level map'+ level + 'size' + levelBasedTrMap.get(level).size() + levelBasedTrMap.get(level));
                                                if(levelBasedTrMap.get(level) != null && levelBasedTrMap.get(level).size() > 0 ){
                                                    System.debug('levelBasedTrMap'+ levelBasedTrMap.get(level));
                                                    Map<String, Map<String, String>> sourchingBranchUser = pcDeviationController.getUserBasedOnSourcingBranch(appId.Id);
                                                    for(TR_Deviation__c trBasedOnLevel : levelBasedTrMap.get(level)){
                                                        System.debug('trBasedOnLevel'+ trBasedOnLevel);
                                                        if(trBasedOnLevel.Decistion__c == 'Approval for Pending' && trBasedOnLevel.Approval_Authority__c != null){
                                                            System.debug('trBasedOnLevel sourcing branch'+ trBasedOnLevel);
                                                            //if(trBasedOnLevel.Is_Deviation_Raised__c == false && applicationObj.Is_Deviation_Raised__c == false && appId.Current_Deviation_Approval__c == null){
                                                            // In this case when raised deviation become inactive on re execution no deviation will be raised so application will not updated as is_deviation_raised false and approval authority null. so this condition will not met
                                                            if(trBasedOnLevel.Is_Deviation_Raised__c == false ){    
                                                                System.debug('trBasedOnLevel sourcing branch'+ trBasedOnLevel);
                                                                
                                                                if(sourchingBranchUser != null && sourchingBranchUser.size() >0 && sourchingBranchUser.containsKey('L5')){
                                                                    appId.Is_Deviation_Raised__c = true;
                                                                    System.debug('trBasedOnLevel sourcing branch'+ trBasedOnLevel);
                                                                    if(sourchingBranchUser.get('L5') != null && sourchingBranchUser.get('L5').size() > 0){
                                                                        System.debug('sourchingBranchUser.get(L5)[0].keySet();'+ sourchingBranchUser.get('L5').keySet());
                                                                        Set<String> l5UserId = sourchingBranchUser.get('L5').keySet();
                                                                        if(l5UserId.isEmpty() == false){
                                                                            for(String userId : l5UserId){
                                                                                System.debug(userId);
                                                                                appId.Current_Deviation_Approval__c = userId;
                                                                
                                                                            }
                                                                            // applicationUpdated = true;
                                                                            //applicationUpdated.put(appId, true);
                                                                            applicationUpdated.put(appId.Id, appId);
                                                            
                                                                        }
                                                                    }
                                                    
                                                                        //applicationObj.Current_Deviation_Approval__c = 
                                                                }
                                                            }
                                                        }
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
                                //No deviation pending : 9 dec 22
                                else{

                                    appId.Is_Deviation_Raised__c = false;
                                    appId.Current_Deviation_Approval__c = null;
                                    updateApp.add(appId);
                                }

                            }
                        }
                        //if application map is null: 9 dec 22
                    }
                }
            /*    lowestPendingLevel = listTrDeviation[0].Approval_Level__c;
                if(listTrDeviation[0].Is_Deviation_Raised__c == true && listTrDeviation[0].Application__r.Current_Deviation_Approval__c != null){
                    if(listTrDeviation[0].Application__r.Current_Deviation_Approval__c == listTrDeviation[0].Approval_Authority__c){
                        // do nothing
                    }
                    else{
                        //List<String> appList = new List<String>();
            
                        Application__c objApp = new Application__c();
                        objApp.id = listTrDeviation[0].Application__c;
                        objApp.Current_Deviation_Approval__c = listTrDeviation[0].Approval_Authority__c;
                        objApp.Is_Deviation_Raised__c = True;
                        
                
            
                    }
                }
                for(Tr_Deviation__c dev : listTrDeviation){
                    
                }*/

                if(raiseDeviationList != null && raiseDeviationList.size() > 0){
                    update raiseDeviationList;
                }
                List<Application__c> applicationUpdate = new List<Application__c>();
                if(applicationUpdated != null && applicationUpdated.size() > 0){
                    List<CustomNotificationType > ListOfTemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Deviation_Notification'];
                    for(String appToUpdate : applicationUpdated.keySet()){
                        //if(applicationUpdated.get(appToUpdate) == true){
                        applicationUpdate.add(applicationUpdated.get(appToUpdate));
                            //update applicationObj;
                            //send notification to L5 user to raise deviation for L6/L7 user: 11-nov-22
                            //sendNotificationToL5User(applicationObj);
                        //}
                        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        	            List<Messaging.CustomNotification> LiscurrNotification = new List<Messaging.CustomNotification>();
                        // Set the contents for the delinking notification
                        currNotification.setTitle('Please Raise Pending Deviations for L6/L7!');
                        currNotification.setBody(applicationUpdated.get(appToUpdate).Name);

                        // Set the notification type and target
                        currNotification.setNotificationTypeId(ListOfTemplateInfoDetail[0].Id);
                        currNotification.setTargetId(applicationUpdated.get(appToUpdate).Id);

                        // Send the notification
                        currNotification.send(new Set<String> {applicationUpdated.get(appToUpdate).Current_Deviation_Approval__c});
                    }
                }
                if(applicationUpdate != null && applicationUpdate.size() > 0){
                    update applicationUpdate;

                }
                
            }
            //No pending Tr Deviation : 9 Dec 22
            //update app
            if(applicationObj != null && applicationObj.size() > 0){
                for(Application__c app : applicationObj){
                    app.Is_Deviation_Raised__c = false;
                    app.Current_Deviation_Approval__c = null;
                    updateApp.add(app);
                }
            }
            if(updateApp != null && updateApp.size() > 0){
                update updateApp;
            }
            
        }
        

    }
}