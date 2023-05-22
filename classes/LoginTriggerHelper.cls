/**
* @File Name          : LoginTriggerHelper
* @Description        : This class is used to assign owner to FivB and FivC record and create task and send notification
                      : 
* @Author             : Vinay Mishra
* @Created On         : 29/04/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0         29/04/2022              Vinay Mishra             Initial Version
Comment(17/05/2022) : Not in use due to process change.
*/
public class LoginTriggerHelper {
    
    //public void updatefield(list<Pre_Login__c> loginList){     
    public static void updatefield(Map<Id,Pre_Login__c> newloginMap, Map<Id,Pre_Login__c> oldloginMap){    
        list<id> loginIDList=new list<id>();
        list<Pre_Login__c> preloginlisttoUpdate=new list<Pre_Login__c>();
        list<Verification__c> VerificationList=new list<Verification__c>();
        list<id> bmID=new list<id>();
        list<id> cmID=new list<id>();
        Id FIVBRecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - B').getRecordTypeId();
        Id FIVCRecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        
        for(Pre_Login__c prelogin:newloginMap.values()){
            if(newloginMap.get(prelogin.Id).status__C!='Done' &&  newloginMap.get(prelogin.Id).status__C!='Cancelled' && newloginMap.get(prelogin.Id).status__C!='Rejected'){
                if(newloginMap.get(prelogin.Id).All_Reciept_Count__c!=0 && newloginMap.get(prelogin.Id).Approved_Reciept_Count__c!=0){
                    if(newloginMap.get(prelogin.Id).All_Reciept_Count__c==newloginMap.get(prelogin.Id).Approved_Reciept_Count__c)
                        loginIDList.add(prelogin.id);
                    //if(prelogin.status__C=='Approved')
                }
            }
        } 
        if(loginIDList.size()>0){
            list<Pre_Login__c> loginLst=[select id,All_Reciept_Count__c,Approved_Reciept_Count__c from Pre_Login__c where id in:loginIDList];
            list<account> acclist=[select id ,Branch_Master__c,Branch_Master__r.Name from account where User__c=:userinfo.getuserid()];
            System.debug('acclist size'+acclist[0].Branch_Master__r.Name);
            if(acclist.size()>0)    {
                list<account> bmlist=[select id,user__c ,User__r.Designation__c,Branch_Master__c,Branch_Master__r.name from account where Branch_Master__c=:acclist[0].Branch_Master__c AND (User__r.Designation__c='Branch Manager' OR User__r.Designation__c='Credit Officer')];
                //list<Branch_Master__c> branchList=[select id ,name from Branch_Master__c where id=:acclist[0].Branch_Master__c];        
                //list<user> logedInUser=[select id,branch from user where id=:UserInfo.getUserId() ];
                //list<branch> branchList=[select id,branchmanager,creditmanager from branch where branch=:logedInUser.branch ];
                System.debug('bmlist>>>>'+bmlist);
                if(bmlist.size()>0)  {  
                    for(account acclst:bmlist){
                        if(acclst.User__r.Designation__c!=null && acclst.User__r.Designation__c=='Branch Manager')
                            bmID.add(acclst.User__c);
                        if(acclst.User__r.Designation__c!=null && acclst.User__r.Designation__c=='Credit Officer')
                            cmID.add(acclst.User__c);
                    }
                }
            }
            if(bmID!=null && cmID!=null){
                for(Pre_Login__c login:loginLst){
                    Verification__c verificationFIVB=new Verification__c();
                    verificationFIVB.RecordTypeId=FIVBRecordTypeId;
                    verificationFIVB.OwnerId=bmID.get(0);
                    //verificationFIVB.Application__c=
                    //verificationFIVB.BM_Comments_for_Overall_Summary__c
                    //verificationFIVB.BM_Recommended_Amount__c
                    //verificationFIVB.Category__c
                    verificationFIVB.status__c='Pending';
                    //verificationFIVB.Customer_Request_Amount__c
                    //verificationFIVB.I_hereby_declare__c
                    //verificationFIVB.Inspection_Date__c
                    //verificationFIVB.Inspection_Time__c
                    //verificationFIVB.Name__c
                    //verificationFIVB.Purpose__c
                    //verificationFIVB.Remarks__c
                    //verificationFIVB.ROI__c
                    //verificationFIVB.Sourcing_Officer__c
                    //verificationFIVB.Status__c
                    //verificationFIVB.Submission_Date__c
                    //verificationFIVB.Tenor__c
                    //verificationFIVB.Name
                    VerificationList.add(verificationFIVB);
                    Verification__c verificationFIVC=new Verification__c();
                    
                   verificationFIVC.OwnerId=cmID.get(0);
                    verificationFIVC.RecordTypeId=FIVCRecordTypeId;
                    System.debug('FIVCRecordTypeId :: '+FIVCRecordTypeId);
                    //verificationFIVC.Application__c=
                    //verificationFIVC.BM_Comments_for_Overall_Summary__c
                    //verificationFIVC.BM_Recommended_Amount__c
                    //verificationFIVC.Category__c
                    //verificationFIVC.Customer_Request_Amount__c
                    //verificationFIVC.status__c='Pending';
                    //verificationFIVC.I_hereby_declare__c
                    //verificationFIVC.Inspection_Date__c
                    //verificationFIVC.Inspection_Time__c
                    //verificationFIVC.Name__c
                    //verificationFIVC.Purpose__c
                    //verificationFIVC.Remarks__c
                    //verificationFIVC.ROI__c
                    //verificationFIVC.Sourcing_Officer__c
                    verificationFIVC.Status__c='Pending';
                    //verificationFIVC.Submission_Date__c
                    //verificationFIVC.Tenor__c
                    //verificationFIVC.Name
                    VerificationList.add(verificationFIVC);
                    login.Status__c='Done';
                    preloginlisttoUpdate.add(login);    
                }
                
                if(VerificationList.size()>0){
                    insert VerificationList;
                    if(preloginlisttoUpdate.size()>0)  
                        update preloginlisttoUpdate;    
                    for(Verification__c Verification:VerificationList){
                        system.debug(Verification.RecordTypeId+'recirdtype'+FIVCRecordTypeId);
                        if(Verification.RecordTypeId==FIVCRecordTypeId){
                            set<id> idSet=new set<id>();
                            idSet.add(Verification.id);
                            RoundRobinAssignment.assignVerificationRoundRobin(idSet);
                            idSet.clear();
                            
                        }
                        Utility.createTask('Task Assignment',null,Verification.id,Verification.OwnerId,system.today(),'New Task Assigned to You',true);
                        Utility.sendNotification('Task Assignment','Task Assignment',Verification.id,'Verification_Notification',Verification.OwnerId);
                    }
                }
            }
        }
    }
}