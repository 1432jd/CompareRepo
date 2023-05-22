/**
* @author            : Sandeep Kumar
* @group             : TechMatrix Consulting
* @description       : This class will cover test coverage of DedupeDetailsController.
* @created on        : 13-09-2022
* @last modified on  : 13-09-2022
* @last modified by  : Sandeep Kumar
**/
@IsTest
public class DedupeDetailsControllerTest {
    
    @TestSetup
    public static void setupDedupeData() {
        
        List<Application__c> appList = new List<Application__c>();
        List<Dedupe_Detail__c> dedupeList = new List<Dedupe_Detail__c>();
        List<Dedupe_Loan_Detail__c> dedupeLoanList = new List<Dedupe_Loan_Detail__c>();
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        List<Account> accList = new List<Account>();
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        preLogin.RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        insert preLogin;
        
        Account acc = new Account();
        acc.FirstName='ram';
        acc.LastName='kumar';
        accList.add(acc);
        insert accList;
        
        Application__c app = new Application__c();
        app.Stage__c ='Login';
        app.Created_From_Batch__c = true;
        app.Pre_Login__c = preLogin.Id;
        insert app;
        
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Application__c= app.Id;
        loanAppObj.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj.KYC_Id_1__c='xyz';
        loanAppObj.KYC_Id_2__c ='dwd';
        loanAppObj.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj.IsDedupeExecuted__c=true;
        loanAppObj.Customer_Information__c=acc.Id;
        loanAppObj.LMS_Customer_Info_File_Number__c='GLBCUST00000668385';
        loanAppObj.Override__c ='Override';
        insert loanAppObj;
        
        Dedupe_Detail__c dedupeObj = new Dedupe_Detail__c();
        dedupeObj.CIF_Id__c	='xyz123';
        dedupeObj.Dedupe_Invoke_From__c='Pc';
        dedupeObj.Button_Name__c='Check Dedupe';
        dedupeObj.Loan_Applicant__c=loanAppObj.Id;
        dedupeObj.Active__c='No';
        dedupeObj.Archive__c=false;
        dedupeObj.Application__c = app.Id;
        dedupeObj.Source__c ='LMS';
        insert dedupeObj;
        //dedupeList.add(dedupeObj);
        
        Dedupe_Detail__c dedupeObj1 = new Dedupe_Detail__c();
        dedupeObj1.CIF_Id__c	='xyz1234';
        dedupeObj1.Dedupe_Invoke_From__c='Pc';
        dedupeObj1.Button_Name__c='Check Dedupe';
        dedupeObj1.Loan_Applicant__c=loanAppObj.Id;
        dedupeObj1.Active__c='Yes';
        dedupeObj1.Archive__c=false;
        dedupeObj1.Application__c = app.Id;
        dedupeObj1.Source__c ='LMS';
        insert dedupeObj1;
        
        Dedupe_Detail__c dedupeObj2 = new Dedupe_Detail__c();
        dedupeObj2.CIF_Id__c	='xyz12345';
        dedupeObj2.Dedupe_Invoke_From__c='Pc';
        dedupeObj2.Button_Name__c='Check Dedupe';
        dedupeObj2.Loan_Applicant__c=loanAppObj.Id;
        dedupeObj2.Active__c='Override';
        dedupeObj2.Archive__c=false;
        dedupeObj2.Application__c = app.Id;
        dedupeObj2.Source__c ='LMS';
        insert dedupeObj2;
        
        Dedupe_Loan_Detail__c dedupeLoanObj = new Dedupe_Loan_Detail__c();
        dedupeLoanObj.Lan__c='abc123xyz';
        dedupeLoanObj.Dedupe_Detail__c=dedupeObj.Id;
        dedupeLoanList.add(dedupeLoanObj);
        insert dedupeLoanList;
        
    
    }
    
    @IsTest
    public static void methodOne(){
        Test.startTest();
        List<Application__c> appli = [Select Id,Stage__c,Created_From_Batch__c FROM Application__c WHERE Created_From_Batch__c=true];
        List<Dedupe_Detail__c> dedAppList =[select Id,Application__c,Active__c,Loan_Applicant__r.Customer_Information__c,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__c,Loan_Applicant__r.Application__c,
                                            CIF_Id__c,Loan_Applicant__r.LMS_Customer_Info_File_Number__c,Source__c
                                            from Dedupe_Detail__c where CIF_Id__c='xyz123' AND Active__c='No'];
        List<Dedupe_Detail__c> dedAppList1 =[select Id,Application__c,Active__c,Loan_Applicant__r.Customer_Information__c,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__c,Loan_Applicant__r.Application__c,
                                             CIF_Id__c,Loan_Applicant__r.LMS_Customer_Info_File_Number__c,Source__c
                                            from Dedupe_Detail__c where CIF_Id__c='xyz1234' AND Active__c='Yes'];
        List<Dedupe_Detail__c> dedAppList2 =[select Id,Application__c,Active__c,Loan_Applicant__r.Customer_Information__c,Loan_Applicant__r.Applicant_Name__c,Loan_Applicant__c,Loan_Applicant__r.Application__c,
                                             CIF_Id__c,Loan_Applicant__r.LMS_Customer_Info_File_Number__c,Source__c
                                            from Dedupe_Detail__c where CIF_Id__c='xyz12345' AND Active__c='Override'];
        List<Loan_Applicant__c> loanApplicantList =[select Id,Application__r.Stage__c,Application__c,Application__r.Created_From_Batch__c,LMS_Customer_Info_File_Number__c,Override__c,Applicant_Name__c
                                                    from Loan_Applicant__c where Application__r.Created_From_Batch__c=true AND Override__c='Override' 
                                                    AND LMS_Customer_Info_File_Number__c='GLBCUST00000668385'];
       
        system.debug('loanlist' + loanApplicantList);
        DedupeDetailsController.initDedupeData(dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.initDedupeData('');
        DedupeDetailsController.getDedupeUserId(); 
        DedupeDetailsController.getDoneDedupeData(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__r.Applicant_Name__c,dedAppList[0].Loan_Applicant__c);
        DedupeDetailsController.saveDedupeData(dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.checkDedupeButtonStat(dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.checkDedupeValidation(dedAppList[0].Loan_Applicant__r.Application__c,'Lead Details');
        DedupeDetailsController.checkDedupeButton(dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.getCurrentUserId();
        DedupeDetailsController.getLoanApplicants(dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.getExceptionLoanApplicants(dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.getApplicantsStatus(loanApplicantList,dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.checkLoanAppt(loanApplicantList);
        DedupeDetailsController.isDedupeHasDone(loanApplicantList[0].Application__c);
        
        Application__c app = new Application__c();
        app.Id=dedAppList[0].Loan_Applicant__r.Application__c;
        app.Stage__c='Process Credit';
        update app;
        DedupeDetailsController.getApplicantsStatus(loanApplicantList,dedAppList[0].Loan_Applicant__r.Application__c);
        Application__c app1 = new Application__c();
        app1.Id=dedAppList[0].Loan_Applicant__r.Application__c;
        app1.Stage__c='Approval Credit';
        update app1;
        DedupeDetailsController.getApplicantsStatus(loanApplicantList,dedAppList[0].Loan_Applicant__r.Application__c);
        Application__c app2 = new Application__c();
        app2.Id=dedAppList[0].Loan_Applicant__r.Application__c;
        app2.Stage__c='Lead Detail';
        update app2;
        
        DedupeDetailsController.getApplicantsStatus(loanApplicantList,dedAppList[0].Loan_Applicant__r.Application__c);
		DedupeDetailsController.getLan(dedAppList[0].Id);
        DedupeDetailsController.getExceptionUserDedupe(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__r.Applicant_Name__c,dedAppList[0].Loan_Applicant__c);
		DedupeDetailsController.lmsLoanAppt(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__r.Applicant_Name__c,dedAppList[0].Loan_Applicant__c);
        DedupeDetailsController.getButtonStatus(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__r.Applicant_Name__c,dedAppList[0].Loan_Applicant__c);
		DedupeDetailsController.getExceptionUserApps();
        DedupeDetailsController.getDedupeUserData(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__r.Applicant_Name__c,dedAppList[0].Loan_Applicant__c);
        DedupeDetailsController.assignDedupeExceptionUser(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Id,dedAppList[0].Loan_Applicant__c,'No');
        DedupeDetailsController.assignDedupeExceptionUser(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Id,dedAppList[0].Loan_Applicant__c,'Yes');
        DedupeDetailsController.updateLoanApp(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__c,'1234');
        DedupeDetailsController.callApiforOverride(dedAppList[0].Loan_Applicant__c,dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.getDedupeWrapperData(dedAppList[0].Loan_Applicant__r.Application__c,'GLBCUST00000139398',dedAppList[0].Loan_Applicant__c,dedAppList[0].Id,'Yes');
        DedupeDetailsController.saveData(json.serialize(dedAppList));
		DedupeDetailsController.saveData(json.serialize(dedAppList1));
       // DedupeDetailsController.saveData(json.serialize(dedAppList2));
        DedupeDetailsController.saveCustomer(json.serialize(loanApplicantList));
        DedupeDetailsController.getLoanAlongDedupeData(dedAppList[0].Loan_Applicant__r.Application__c,'GLBCUST00000139398',dedAppList[0].Loan_Applicant__c,dedAppList[0].Id,'No');
      //  DedupeDetailsController.saveData(json.serialize(loanApplicantList));
      //  DedupeDetailsController.saveData(json.serialize(appli));
         //       DedupeDetailsController.saveCustomer(json.serialize(appli));
        
        Loan_Applicant__c loanAppObj1 = new Loan_Applicant__c();
        loanAppObj1.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj1.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj1.KYC_Id_1__c='xyz';
        loanAppObj1.IsDedupeExecuted__c=true;
        loanAppObj1.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj1;
        
        
        DedupeDetailsController.callCustomerApi(loanAppObj1.Application__c);
         DedupeDetailsController.getCustomerData(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__r.Applicant_Name__c,dedAppList[0].Loan_Applicant__c);
        //String str ='[{"Id":"a1J0w0000015hJZEAY","CIF_Id__c":"GLBCUST00000000821","Active__c":"Yes","Source__c":"LMS","Application__c":"a030w000008HwIQAA0"}]';
		//String saveCust = '[{"Id":"a0L0w000002fgBQEAY","Application__c":"a030w000008HwIQAA0","Applicant_Name__c":"KArthi gupta","Application__r":{"Pre_Login__c":"a020w000007Eh8qAAC","Id":"a030w000008HwIQAA0","Pre_Login__r":{"RecordTypeId":"0120w000001FJaLAAW","Id":"a020w000007Eh8qAAC","RecordType":{"Name":"1. New login","Id":"0120w000001FJaLAAW"}}},"Override__c":"Override","LMS_Customer_Info_File_Number__c":"GLBCUST00000668385"}]';
       	//DedupeDetailsController.saveCustomer(saveCust);
        // DedupeDetailsController.saveData(str);
        // 
        DedupeDetailsController.getLoanDetails(dedAppList[0].Loan_Applicant__r.Application__c,dedAppList[0].Loan_Applicant__c);
		
        Loan_Applicant__c loanAppObj2 = new Loan_Applicant__c();
        loanAppObj2.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj2.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj2.KYC_Id_1__c='xyz';
        loanAppObj2.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj2.KYC_Id_2__c='xyz';
        loanAppObj2.IsDedupeExecuted__c=true;
        loanAppObj2.Override__c='Override';
        loanAppObj2.Customer_Name__c='Ram';
         loanAppObj2.LMS_Customer_Info_File_Number__c='GLBCUST00000668385';
        loanAppObj2.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj2;
        DedupeDetailsController.callApiforOverride(loanAppObj2.Id,loanAppObj2.Application__c);

        DedupeDetailsController.getLoanDetails(loanAppObj2.Application__c,loanAppObj2.Id);
         DedupeDetailsController.doEmptyLoanApptData(dedAppList[0].Loan_Applicant__c,dedAppList[0].Loan_Applicant__r.Application__c);
        DedupeDetailsController.getLoanDedupeData(dedAppList[0].Loan_Applicant__r.Application__c,'GLBCUST00000668385',dedAppList[0].Loan_Applicant__c,dedAppList[0].Id,'No');
        DedupeDetailsController.getLoanDedupeData(loanAppObj2.Application__c,'GLBCUST00000668385',loanAppObj2.Id,'','Yes');
		
        DedupeDetailsController.getNewLoanWrapperData(loanAppObj2.Application__c,'GLBCUST00000668385',loanAppObj2.Id,'','No');

        
        Loan_Applicant__c loanAppObj6 = new Loan_Applicant__c();
        loanAppObj6.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj6.KYC_ID_Type_1__c='Voter Id';
        loanAppObj6.KYC_Id_1__c='xyz';
        loanAppObj6.KYC_ID_Type_2__c='Voter Id';
        loanAppObj6.KYC_Id_2__c='xyz';
        loanAppObj6.IsDedupeExecuted__c=true;
        loanAppObj6.Override__c='Override';
        loanAppObj6.Customer_Name__c='Ram';
        loanAppObj6.LMS_Customer_Info_File_Number__c='GLBCUST00000668385';
        loanAppObj6.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj6;
        
       
       // DedupeDetailsController.getNewLoanWrapperData(loanAppObj6.Application__c,'GLBCUST00000668385',loanAppObj6.Id,'','No');


        
        Loan_Applicant__c loanAppObj7 = new Loan_Applicant__c();
        loanAppObj7.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj7.KYC_ID_Type_1__c='Pan Card';
        loanAppObj7.KYC_Id_1__c='xyz';
        loanAppObj7.KYC_ID_Type_2__c='Pan Card';
        loanAppObj7.KYC_Id_2__c='xyz';
        loanAppObj7.IsDedupeExecuted__c=true;
        loanAppObj7.Override__c='Override';
        loanAppObj7.Customer_Name__c='Ram';
        loanAppObj7.LMS_Customer_Info_File_Number__c='GLBCUST00000668385';
        loanAppObj7.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj7;
        DedupeDetailsController.getNewLoanWrapperData(loanAppObj7.Application__c,'GLBCUST00000668385',loanAppObj7.Id,'','No');

        Loan_Applicant__c loanAppObj8 = new Loan_Applicant__c();
        loanAppObj8.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj8.KYC_ID_Type_1__c='Driving License';
        loanAppObj8.KYC_Id_1__c='xyz';
        loanAppObj8.KYC_ID_Type_2__c='Driving License';
        loanAppObj8.KYC_Id_2__c='xyz';
        loanAppObj8.IsDedupeExecuted__c=true;
        loanAppObj8.Override__c='Override';
        loanAppObj8.Customer_Name__c='Ram';
        loanAppObj8.LMS_Customer_Info_File_Number__c='GLBCUST00000668385';
        loanAppObj8.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj8;
        DedupeDetailsController.getNewLoanWrapperData(loanAppObj8.Application__c,'GLBCUST00000668385',loanAppObj8.Id,'','No');
        
        Loan_Applicant__c loanAppObj9 = new Loan_Applicant__c();
        loanAppObj9.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj9.KYC_ID_Type_1__c='Passport';
        loanAppObj9.KYC_Id_1__c='xyz';
        loanAppObj9.KYC_ID_Type_2__c='Passport';
        loanAppObj9.KYC_Id_2__c='xyz';
        loanAppObj9.IsDedupeExecuted__c=true;
        loanAppObj9.Override__c='Override';
        loanAppObj9.Customer_Name__c='Ram';
        loanAppObj9.LMS_Customer_Info_File_Number__c='GLBCUST00000668385';
        loanAppObj9.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj9;
        DedupeDetailsController.getNewLoanWrapperData(loanAppObj9.Application__c,'GLBCUST00000668385',loanAppObj9.Id,'','No');



        Loan_Applicant__c loanAppObj3 = new Loan_Applicant__c();
        loanAppObj3.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj3.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj3.KYC_Id_1__c='xyz';
        loanAppObj3.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj3.KYC_Id_2__c='xyz';
        loanAppObj3.IsDedupeExecuted__c=false;
        loanAppObj3.Override__c='Override';
        loanAppObj3.Customer_Name__c='Ram';
         loanAppObj3.LMS_Customer_Info_File_Number__c=NULL;
        loanAppObj3.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj3;
        DedupeDetailsController.checkDedupeValidation(loanAppObj3.Application__c,'Pre-Login');
        
        Loan_Applicant__c loanAppObj4 = new Loan_Applicant__c();
        loanAppObj4.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj4.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj4.KYC_Id_1__c='xyz';
        loanAppObj4.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj4.KYC_Id_2__c='xyz';
        loanAppObj4.IsDedupeExecuted__c=true;
        loanAppObj4.Override__c='Override';
        loanAppObj4.Customer_Name__c='Ram';
         
        loanAppObj4.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj4;
        
        Dedupe_Detail__c dedupeObj = new Dedupe_Detail__c();
        dedupeObj.CIF_Id__c	='xyz123';
        dedupeObj.Dedupe_Invoke_From__c='Pc';
        dedupeObj.Button_Name__c='Check Dedupe';
        dedupeObj.Loan_Applicant__c=loanAppObj4.Id;
        dedupeObj.Active__c='No';
        dedupeObj.Archive__c=false;
        insert dedupeObj;
        
        Dedupe_Detail__c dedupeObj1 = new Dedupe_Detail__c();
        dedupeObj1.CIF_Id__c	='xyz123';
        dedupeObj1.Dedupe_Invoke_From__c='Pc';
        dedupeObj1.Button_Name__c='Check Dedupe';
        dedupeObj1.Loan_Applicant__c=loanAppObj4.Id;
        dedupeObj1.Active__c='No';
        dedupeObj1.Archive__c=false;
        insert dedupeObj1;
        
        DedupeDetailsController.checkDedupeValidation(loanAppObj4.Application__c,'Pre-Login');
        
        
        Loan_Applicant__c loanAppObj5 = new Loan_Applicant__c();
        loanAppObj5.Application__c=dedAppList[0].Loan_Applicant__r.Application__c;
        loanAppObj5.KYC_ID_Type_1__c='Aadhaar Card';
        loanAppObj5.KYC_Id_1__c='xyz';
        loanAppObj5.KYC_ID_Type_2__c='Aadhaar Card';
        loanAppObj5.KYC_Id_2__c='xyz';
        loanAppObj5.IsDedupeExecuted__c=true;
        loanAppObj5.Override__c='Override';
        loanAppObj5.Customer_Name__c='Ram';
         
        loanAppObj5.Customer_Information__c=dedAppList[0].Loan_Applicant__r.Customer_Information__c;
        insert loanAppObj5;
        
        Dedupe_Detail__c dedupeObj3 = new Dedupe_Detail__c();
        dedupeObj3.CIF_Id__c	='xyz123';
        dedupeObj3.Dedupe_Invoke_From__c='Pc';
        dedupeObj3.Button_Name__c='Check Dedupe';
        dedupeObj3.Loan_Applicant__c=loanAppObj4.Id;
        dedupeObj3.Active__c='No';
        dedupeObj3.Archive__c=false;
        insert dedupeObj3;
        
        Dedupe_Detail__c dedupeObj4 = new Dedupe_Detail__c();
        dedupeObj4.CIF_Id__c	='xyz123';
        dedupeObj4.Dedupe_Invoke_From__c='Pc';
        dedupeObj4.Button_Name__c='Check Dedupe';
        dedupeObj4.Loan_Applicant__c=loanAppObj4.Id;
        dedupeObj4.Active__c='No';
        dedupeObj4.Archive__c=false;
        insert dedupeObj4;
        
        
        

        
       // DedupeDetailsController.checkDedupeValidation(dedupeObj4.Loan_Applicant__r.Application__c,'Pre-Login');
        
        String str ='[{"Id":"a1J0w0000015hJZEAY","CIF_Id__c":"GLBCUST00000000821","Active__c":"Yes","Source__c":"LMS","Application__c":"a030w000008HwIQAA0"}]';
		String saveCust = '[{"Id":"a0L0w000002fgBQEAY","Application__c":"a030w000008HwIQAA0","Applicant_Name__c":"KArthi gupta","Application__r":{"Pre_Login__c":"a020w000007Eh8qAAC","Id":"a030w000008HwIQAA0","Pre_Login__r":{"RecordTypeId":"0120w000001FJaLAAW","Id":"a020w000007Eh8qAAC","RecordType":{"Name":"1. New login","Id":"0120w000001FJaLAAW"}}},"Override__c":"Override","LMS_Customer_Info_File_Number__c":"GLBCUST00000668385"}]';
        Test.stopTest();
    }
    
     
  
}