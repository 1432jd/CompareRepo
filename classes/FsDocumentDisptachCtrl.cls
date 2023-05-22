/*
		Date : 18/08/2022
		Author : Mo Arslan
*/
public class FsDocumentDisptachCtrl{
    @AuraEnabled
    public static List<Branch_Master__c> getBranch(){
        Set<Id> branchIdSet = FsDocumentDisptachCtrl.getBranchIdsFromBranchUserAllocation();
        List<Branch_Master__c> Branchs = new List<Branch_Master__c>();
        if(!branchIdSet.isEmpty()){
            Branchs = [SELECT Id, Name, HO_HUB__r.Branch_Address_Line_1__c, HO_HUB__r.Name, HO_HUB__c FROM Branch_Master__c WHERE Id IN:branchIdSet ORDER By Name ASC];
        }
        return Branchs;
    }

    @AuraEnabled
    public static List<Branch_Master__c> getHoHubs(){
        List<Branch_Master__c> Branchs = new List<Branch_Master__c>();
        Branchs = [SELECT Id, Name, Branch_Address_Line_1__c,Branch_Address_Line_2__c,Branch_Address_Line_3__c,Branch_City__c,Branch_Country__c,State__c,Branch_Pincode__c FROM Branch_Master__c WHERE Type__c IN ('HO','HUB') ORDER By Name ASC];        
        return Branchs; 
    }

    @AuraEnabled
    public static List<DocumentDispatchWrapper> getApplicationsWithDate(String branchId, Date fromDate, Date toDate){
        Integer sNo = 1;
        List<DocumentDispatchWrapper> documentDispatchList = new List<DocumentDispatchWrapper>();
        System.debug('fromDate = '+fromDate);
        System.debug('toDate = '+toDate);
        DateTime toDT;
        if(toDate != NULL){
            toDT = DateTime.newInstance(toDate.Year(), toDate.month(), toDate.day(), 23, 23, 50);
        }
        Set<Id> branchIdSet = new Set<Id>();
        Set<String> stages = new Set<String>{'Dispatch Pending', 'Document Receipt', 'Disbursal Maker', 'Disbursal Author', 'Document Deferral'};
        if(branchId == 'All'){
            branchIdSet = FsDocumentDisptachCtrl.getBranchIdsFromBranchUserAllocation();
        }
        else{
            branchIdSet.add(branchId);
        }

        System.debug('branchIdSet = '+branchIdSet);
        List<Application__c> applicationList = new List<Application__c>();
        applicationList =  [SELECT Id, Sourcing_Branch__r.Name, Stage__c, Name, (SELECT Id, Customer_Information__r.Name FROM Loan_Applicants__r) FROM Application__c WHERE Sourcing_Branch__c In : branchIdSet AND CreatedDate>=:fromDate AND CreatedDate<=:toDT AND Stage__c In:stages ORDER BY CreatedDate DESC];
        for(Application__c app : applicationList){
            DocumentDispatchWrapper docDispatch = new DocumentDispatchWrapper();
            docDispatch.Id = app.Id;
            docDispatch.serialNumber = sNo;
            docDispatch.applicationNo = app.Name;
            docDispatch.customerName = app.Loan_Applicants__r.size()>0?app.Loan_Applicants__r[0].Customer_Information__r.Name:'';
            docDispatch.sourcingBranch = app.Sourcing_Branch__r.Name;
            docDispatch.stageName = app.Stage__c;
            documentDispatchList.add(docDispatch);
            sNo++;
        }
        return documentDispatchList;
    }

    @AuraEnabled
    public static List<DocumentDispatchWrapper> getApplicationsWithoutDate(String branchId){
        Integer sNo = 1;
        List<DocumentDispatchWrapper> documentDispatchList = new List<DocumentDispatchWrapper>();
        Set<Id> branchIdSet = new Set<Id>();
        Set<String> stages = new Set<String>{'Dispatch Pending', 'Document Receipt', 'Disbursal Maker', 'Disbursal Author', 'Document Deferral'};
        if(branchId == 'All'){
            branchIdSet = FsDocumentDisptachCtrl.getBranchIdsFromBranchUserAllocation();
        }
        else{
            branchIdSet.add(branchId);
        }
        List<Application__c> applicationList = new List<Application__c>();
        Map<Id, Loan_Applicant__c> loanApplicantMap = new Map<Id, Loan_Applicant__c>();
        applicationList =  [SELECT Id, Sourcing_Branch__r.Name, Stage__c, Name, (SELECT Id, Customer_Information__r.Name FROM Loan_Applicants__r WHERE Customer_Type__c = 'Primary Applicant' limit 1) FROM Application__c WHERE Sourcing_Branch__c In:branchIdSet AND Stage__c In:stages ORDER BY CreatedDate DESC];
        for(Application__c app : applicationList){
            DocumentDispatchWrapper docDispatch = new DocumentDispatchWrapper();
            docDispatch.Id = app.Id;
            docDispatch.serialNumber = sNo;
            docDispatch.applicationNo = app.Name;
            docDispatch.customerName = app.Loan_Applicants__r.size()>0?app.Loan_Applicants__r[0].Customer_Information__r.Name:'';
            docDispatch.sourcingBranch = app.Sourcing_Branch__r.Name;
            docDispatch.stageName = app.Stage__c;
            documentDispatchList.add(docDispatch);
            sNo++;
        }
        return documentDispatchList;
    }

    @AuraEnabled
    public static Courier_Control__c getExistingRecord(String recordId){
        return [SELECT Id, HO_HUB__c,Address__c ,Branch_Name__c, Branch__c ,Courier_Agency__c ,Courier_POD_No__c, From_Date__c, To_Date__c, (SELECT Application__c, Remarks__c FROM Courier_Applications__r) FROM Courier_Control__c WHERE Id =:recordId LIMIT 1 ];
    }

    @AuraEnabled
    public static String createRecords(String wrpObject, List<String> applicationIds, String applicationList){

        List<DocumentDispatchWrapper> applicationWrpList = (List<DocumentDispatchWrapper>)JSON.deserialize(applicationList, List<DocumentDispatchWrapper>.class);
        Map<String, String> remarksMap = new Map<String, String>();
        for(DocumentDispatchWrapper app : applicationWrpList){
            remarksMap.put(app.Id, app.remarks);
        }

        Map<Id, Application__c> applicationMap;
        Courier_Control__c courierControl = new Courier_Control__c();
        courierControl = (Courier_Control__c)JSON.deserialize(wrpObject, Courier_Control__c.class);
        upsert courierControl;
        
        List<Courier_Application__c> couAppLst = [SELECT Id FROM Courier_Application__c WHERE Courier_Control__c =:courierControl.Id];
        if(couAppLst.size()>0){
            delete couAppLst;
        }
        applicationMap = new Map<Id, Application__c>([SELECT Id, Stage__c FROM Application__c WHERE Id In: applicationIds]);
        if(applicationIds != NULL && !applicationIds.isEmpty()){
            List<Courier_Application__c> courierApplicationList = new List<Courier_Application__c>();
            for(String str : applicationIds){
                Courier_Application__c courierApplication = new Courier_Application__c();
                courierApplication.Application__c = str;
                courierApplication.Status__c = 'Dispatch';
                courierApplication.Courier_Control__c = courierControl.Id;
                courierApplication.Remarks__c = remarksMap.containsKey(str)?remarksMap.get(str):'';
                if(applicationMap.get(str).Stage__c == 'Dispatch Pending' || applicationMap.get(str).Stage__c == 'Document Receipt'){
                    courierApplication.Document_Type__c = 'Disbursement File';
                    //If Stage is Dispatch Pending 
                }
                else if(applicationMap.get(str).Stage__c == 'Disbursal Maker' || applicationMap.get(str).Stage__c =='Disbursal Author'){
                    courierApplication.Document_Type__c = 'Pending Document';
                    //If Disbursal Author or DM is not completed 
                }
                else if(applicationMap.get(str).Stage__c == 'Document Deferral' || applicationMap.get(str).Stage__c =='File Inward' || applicationMap.get(str).Stage__c =='VDC Maker' || applicationMap.get(str).Stage__c =='VDC Checker' || applicationMap.get(str).Stage__c =='Vendor Handoff'){
                   courierApplication.Document_Type__c = 'Deferral Documents';
                   // when application is on Document Defferel and Custody is not completed. 
                }
                courierApplicationList.add(courierApplication);
            }
            insert courierApplicationList; 
        }
        return courierControl.Id;
    }

    @AuraEnabled
    public static void updateCourierApplications(String courierControlId){
        List<Application__c> applicationList = new List<Application__c>();
        Courier_Control__c courierControl = [SELECT Document_Generated__c, (SELECT Status__c, Application__r.Stage__c FROM Courier_Applications__r) FROM Courier_Control__c WHERE Id=:courierControlId];
        courierControl.Document_Generated__c = true;
        List<Courier_Application__c> couAppLst = new List<Courier_Application__c>();
        for(Courier_Application__c courierApp : courierControl.Courier_Applications__r){
            courierApp.Status__c = 'File In Transit';
            courierApp.Dispatch_Date__c = System.today();
            if(courierApp.Application__r.Stage__c!='Disbursal Maker' && courierApp.Application__r.Stage__c!='Disbursal Author' && courierApp.Application__r.Stage__c!='Document Deferral' && courierApp.Application__r.Stage__c!='Custody')
                courierApp.Application__r.Stage__c = 'Document Receipt';
            couAppLst.add(courierApp);
            applicationList.add(courierApp.Application__r);
        }
        update courierControl;
        if(couAppLst.size()>0){
            update couAppLst;
        }
        Set<String> applicationIds = new Set<String>();
        if(applicationList.size()>0){
            System.debug('applicationList '+applicationList);
            update applicationList;

            for(Application__c app : applicationList){
                if(app.Stage__c == 'Document Receipt'){
                    applicationIds.add(app.Id);
                }
            }
        }
        // 17 May 2023 : commente call and method 
        // if(!applicationIds.isEmpty()){
        //     checkDOSCondition(applicationIds);
        // }  
    }
    public static Set<Id> getBranchIdsFromBranchUserAllocation(){
        String usrId = UserInfo.getUserId();
        Set<Id> branchIdSet = new Set<Id>();
        List<Access_Branch_Allocation__c> branchAccesses = new List<Access_Branch_Allocation__c>();
        branchAccesses = [SELECT Id, Branch_Master__c FROM Access_Branch_Allocation__c WHERE Access_Master__r.User__c =: usrId];
        //List<User_Branch_Allocation__c> usrBranchAllo = [SELECT Id, Branch_Master__c FROM User_Branch_Allocation__c WHERE User__c =:usrId];
        for(Access_Branch_Allocation__c uba : branchAccesses){
            if(uba.Branch_Master__c!=null){
                branchIdSet.add(uba.Branch_Master__c);
            }
        }
        return branchIdSet;
    }

    @AuraEnabled
    public static void downloadPDF(String recordId){
        Set<String> applicationIds = new Set<String>();
        List<Courier_Application__c> applicationList = [SELECT Id, Application__c FROM Courier_Application__c WHERE Courier_Control__c =:recordId];
        List<ContentVersion> cvList = new List<ContentVersion>();
        PageReference pdf = Page.courierControlSheetVf;
        pdf.getParameters().put('recordId',recordId);
        Blob body;
        
        if(Test.isRunningTest()) { 
            body = blob.valueOf('Unit.Test');
        } else {
            body = pdf.getContentAsPDF();
        }
        for(Courier_Application__c app : applicationList){
            applicationIds.add(app.Application__c);
            ContentVersion cv = new ContentVersion(Title = 'Document Receipt', PathOnClient ='Document Receipt.PDF', VersionData = body, FirstPublishLocationId = app.Application__c, Is_Additional_Document__c = true, Uploaded_From__c = 'Dispatch Pending');
            cvList.add(cv);
        }        

        if(!cvList.isEmpty()){
            insert cvList;
        }  
    }

    // public static void checkDOSCondition(Set<String> recordIds){
        
    //     if(recordIds != NULL && !recordIds.isEmpty()){
    //         List<Application__c> appList = [SELECT 
    //                                         ID, Name, Group_Total_Exposure_PcAc__c, Loan_Amount__c, Sourcing_Branch__r.State__c, Tranche_Disbursal__c  
    //                                         FROM Application__c
    //                                         WHERE ID IN: recordIds AND DOS_Required__c != TRUE];

    //         for(Application__c appObj : appList){
    //             Boolean decision = true;
    //             String branch = appObj.Sourcing_Branch__r.State__c;           
    //             Decimal amount = appObj.Group_Total_Exposure_PcAc__c; 

    //             if(appObj.Tranche_Disbursal__c == 'II'){
    //                 decision = false;
    //             } else {
    //                 if(branch == 'TN' || branch == 'AP' || branch == 'TS' || branch == 'KA'){
    //                     if(amount <= 500000){
    //                         decision = false;
    //                     }
    //                 }else if(branch == 'MP' || branch == 'MH' || branch == 'CG' || branch == 'UP'){
    //                     if(amount <= 500000){
    //                         decision = false;
    //                     }
    //                 }
    //             }    

    //             appObj.DOS_Required__c = decision;
    //             if(decision){
    //                 appObj.Sub_Stage__c = 'DOS';
    //             }
    //         }                                
            

    //         if(appList != NULL && !appList.isEmpty()){
    //             update appList;
    //         }            
    //     }
    // }

    public class DocumentDispatchWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public Integer serialNumber;
        @AuraEnabled public String applicationNo;
        @AuraEnabled public String customerName;
        @AuraEnabled public String sourcingBranch;
        @AuraEnabled public String stageName;
        @AuraEnabled public String remarks;
    }
}