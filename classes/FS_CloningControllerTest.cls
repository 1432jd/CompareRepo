@isTest
public class FS_CloningControllerTest {
    @testSetup
    public static void testSetup(){
        
        MS_Pincode__c ms = new MS_Pincode__c();
        ms.Name = '860311';
        ms.Pincode__c = '860311';
        ms.City__c = 'Test';
        ms.State_Code__c = 'UP';
        ms.StateName__c = 'UP';
        INSERT ms;
        
        Branch_Master__c objBranch = new Branch_Master__c();
        objBranch.Branch_City__c = 'Test';
        objBranch.Branch_Code__c = 'BR-101';
        objBranch.Branch_Pincode__c = ms.Id;
        objBranch.Branch_State__c = 'UP';
        objBranch.Name = 'Test Branch';
        INSERT objBranch;
        
        Id preRecordTypeId = Schema.SObjectType.Pre_Login__c.getRecordTypeInfosByName().get('1. New login').getRecordTypeId();
        Pre_Login__c preLog = new Pre_Login__c(RecordTypeId=preRecordTypeId,Status__c='Active');
        INSERT preLog; 
        
        Application__c app = new Application__c();
        app.Pre_Login__c = preLog.Id;
        app.application_status__c = 'Active';
        app.Stage__c = 'Login';
        app.LMS_Response_Reference__c = '';
        app.Created_From_Batch__c = false;
        app.hasVerificationRecords__c = false;
        app.Sourcing_Branch__c = objBranch.Id;
        INSERT app;
        
        Account objAcc = new Account();
        objAcc.Salutation = 'Mr.';
        objAcc.FirstName = 'Test';
        objAcc.LastName = 'Account';
        objAcc.PersonBirthdate = System.today() - 15;
        objAcc.Father_s_Name__c = 'Test Father';
        objAcc.Mother_s_Name__c = 'Test Mother';
        objAcc.Gender__c = 'Male';
        INSERT objAcc;
        
        Loan_Applicant__c loanApp = new Loan_Applicant__c();
        loanApp.Business_Address_Line_1__c = 'loanadd';
        loanApp.Application__c = app.Id;
        loanApp.Customer_Information__c = objAcc.Id;
        loanApp.Residence_Pincode__c = ms.Id;
        loanApp.Residence_Address_Line_1__c = 'testaddress';
        loanApp.Residence_City__c = 'Testcity';
        loanApp.Mobile__c = '9988776655';
        loanApp.KYC_ID_Type_1__c = 'Driving License';
        loanApp.KYC_ID_Type_2__c = 'Aadhaar Card';
        loanApp.KYC_Id_1__c = '123456789';
        loanApp.KYC_Id_2__c = '998877665544';
        INSERT loanApp;
        
        Id propRecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId();
        Property__c newProperty = new Property__c();
        newProperty.RecordTypeId = propRecordTypeId;
        newProperty.Application__c = app.Id;
        newProperty.Login__c = preLog.Id;
        newProperty.Title_Deed_Number__c = '12345';
        INSERT newProperty;
        
        Property_Owners__c prop = new Property_Owners__c();
        prop.Loan_Applicant__c = loanApp.Id;
        prop.Property__c = newProperty.Id;
        INSERT prop;
        
        FsPreloginController.clonePropertyNew(app.Id);
        
        List<Verification__c> verificationList = new List<Verification__c>();
        for(String RTName : Schema.SObjectType.Verification__c.getRecordTypeInfosByName().keyset()){ 
            if(RTName!='Master'){
                if(!app.hasVerificationRecords__c){
                    Id recTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
                    Verification__c verification=new Verification__c();
                    verification.RecordTypeId=recTypeId;
                    verification.Application__c=app.Id;
                    verification.OwnerId= userinfo.getuserid();
                    verification.status__c='Completed';
                    verification.Initiate_From__c = 'Pre Login';
                    verificationList.add(verification);
                }
            }
        }
        app.hasVerificationRecords__c = true;
        INSERT verificationList;
        UPDATE app;
                
        Property__c fivcProp = [SELECT Id FROM Property__c WHERE RecordType.Name = 'FIV-C Property Detail' LIMIT 1];
        CommonObject__c com = new CommonObject__c();
        com.Application__c = app.Id;
        com.Object_Type__c = 'Enquiry';
        com.Property__c = fivcProp.Id;
        INSERT com;
        
        List<Character__c> listChar = new List<Character__c>();
        Character__c character = new Character__c();
        character.RecordTypeId = Schema.getGlobalDescribe().get('Character__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
        character.Application__c = app.Id;
        character.Loan_Applicant__c = loanApp.Id;
        listChar.add(character);
        
        Character__c fivBCharacter = new Character__c();
        fivBCharacter.RecordTypeId = Schema.getGlobalDescribe().get('Character__c').getDescribe().getRecordTypeInfosByName().get('FIV-B Character').getRecordTypeId();
        fivBCharacter.Application__c = app.Id;
        fivBCharacter.Loan_Applicant__c = loanApp.Id;
        listChar.add(fivBCharacter);
        
        Character__c pcCharacter = new Character__c();
        pcCharacter.RecordTypeId = Schema.getGlobalDescribe().get('Character__c').getDescribe().getRecordTypeInfosByName().get('PC Character').getRecordTypeId();
        pcCharacter.Application__c = app.Id;
        pcCharacter.Loan_Applicant__c = loanApp.Id;
        listChar.add(pcCharacter);
        
        INSERT listChar;
        
        List<Capability__c> listCap = new List<Capability__c>();
        Capability__c cap = new Capability__c();
        cap.RecordTypeId = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        cap.Application__c = app.Id;
        cap.Loan_Applicant__c = loanApp.Id;
        listCap.add(cap);
        
        Capability__c pcCap = new Capability__c();
        pcCap.RecordTypeId = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('PC Capability').getRecordTypeId();
        pcCap.Application__c = app.Id;
        pcCap.Loan_Applicant__c = loanApp.Id;
        listCap.add(pcCap);
        
        INSERT listCap;
        
        Verification__c objFIVBVer = [SELECT Id FROM Verification__c WHERE RecordType.Name = 'FIV - B'];
        Cashflow__c objCash = new Cashflow__c();
        objCash.Verification__c = objFIVBVer.Id;
        objCash.Application__c = app.Id;
        objCash.Loan_Applicant__c = loanApp.Id;
        INSERT objCash;
        
        Verification__c objVer = [SELECT Id FROM Verification__c WHERE RecordType.Name = 'FIV - C'];
        Revisit__c rev = new Revisit__c();
        rev.Verification__c = objVer.Id;
        INSERT rev;
        
        Education__c objEd = new Education__c();
        objEd.Application__c = app.Id;
        objEd.Loan_Applicant__c = loanApp.Id;
        INSERT objEd;
        
        Family_Detail__c objFm = new Family_Detail__c();
        objFm.Loan_Applicant__c = loanApp.Id;
        INSERT objFm;
        
        Income__c objIn = new Income__c();
        objIn.Application__c = app.Id;
        objIn.Loan_Applicant__c = loanApp.Id;
        INSERT objIn;
        
        Employment_Details__c objEmpd = new Employment_Details__c();
        objEmpd.Application__c = app.Id;
        objEmpd.Loan_Applicant__c = loanApp.Id;
        INSERT objEmpd;
        
        Bank_Detail__c objBn = new Bank_Detail__c();
        objBn.Loan_Applicant__c = loanApp.Id;
        objBn.Application__c = app.Id;
        INSERT objBn;
        
        Reference__c objRef = new Reference__c();
        objRef.Loan_Applicant__c = loanApp.Id;
        INSERT objRef;
    }
    
    @isTest
    public static void doTestCloning(){
        Application__c app = [SELECT Id,Stage__c FROM Application__c LIMIT 1];
        test.startTest();
        FS_CloningController.Wrapper objWrap = new FS_CloningController.Wrapper();
        objWrap = FS_CloningController.cloneExistingApplication(app.Id, '1. New login');
        FS_CloningController.cloneVerificationData(objWrap.appId);
        FS_CloningController.cloneExistingApplicationDataTillPC(objWrap.appId);
        test.stopTest();
    }
}