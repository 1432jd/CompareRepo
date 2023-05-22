@isTest 
public without sharing class fsPcAcControllerTest {
    
    @Testsetup
    public static void testsetup(){
        
        // Pre Login Creation
        Pre_Login__c login1= new Pre_Login__c(Status__c='Active',RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId());
        insert login1;
        
        // Application Creation
        Application__c app = new Application__c();
        app.Name = 'APP - 0001';
        app.Pre_Login__c = login1.Id;
        app.Loan_Purpose_2__c = 'Outside Credit';
        app.Balance_Transfer__c = 'No';
        app.Total_Net_income_for_Tranche_2__c = 2000;
        app.Final_Collateral_value_for_Tranche_2__c = 34000;
        app.Name__c = 'hari prashad';
        app.Nominee__c = 'Yes';
        app.Nach_Party__c = 'Ajay Kumar';
        app.Amount_Recommended__c = 5000001;
        app.Total_Net_Income__c = 8000;
        app.KYC_Risk_Rating__c = 'Low';
        app.Comment_Remarks__c = 'test';
        app.Discussion_done_with__c = 'TL';
        app.Requested_Loan_Amount__c = 45000;
        app.Tranche_Disbursal__c = 'I';
        insert app; 
		
		 // Pre Login Creation
        Pre_Login__c login2= new Pre_Login__c(Status__c='Active',RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId());
        insert login2;
        
         // Application Creation
        Application__c app1 = new Application__c();
        app1.Created_From_Batch__c = true;
        app1.Pre_Login__c = login2.Id;
        app1.Name__c = 'APP - 0002';
        app1.Tranche_Disbursal__c = 'I';
        insert app1;
        
        // Property Creation
        Property__c ac1pcProperty = new Property__c();
        ac1pcProperty.RecordTypeId = Utility.PC_PROPERTY_RECORD_TYPE_ID;
        ac1pcProperty.Application__c = app1.Id;
        ac1pcProperty.LMS_Collateral_Number__c = 'COL123456788909';
        ac1pcProperty.Property_Address__c ='NEW DELHI';
        insert ac1pcProperty;
        
        // Pre Login Creation
        Pre_Login__c login3= new Pre_Login__c(Status__c='Active',RecordTypeId = Schema.getGlobalDescribe().get('Pre_Login__c').getDescribe().getRecordTypeInfosByName().get('1. New login').getRecordTypeId());
        insert login3;
        
         // Application Creation
        Application__c app2 = new Application__c();
        app2.Pre_Login__c = login3.Id;
        app2.Name__c = 'APP - 0003';
        app2.Old_Application__c = app1.Id;
        app2.Tranche_Disbursal__c = 'I';
        app2.IsTopupDetailsGenerated__c = false;
       
        insert app2;
        
        // account for app2
        Account acc1 = new Account();
        acc1.FirstName='Ajay';
        acc1.LastName='kumar';
        insert acc1;
        
        // Loan Applicant Creation for app2
        Loan_Applicant__c loanAppObj2 = new Loan_Applicant__c();
        loanAppObj2.Application__c=app2.Id;
        loanAppObj2.KYC_Id_1__c='HQD4572046';
        loanAppObj2.KYC_Id_2__c='HQD4572046';
        loanAppObj2.KYC_ID_Type_1__c	='Aadhaar Card';
        loanAppObj2.KYC_ID_Type_2__c='Voter Id';
        loanAppObj2.Customer_Information__c=acc1.Id;
        loanAppObj2.cifId__c=NULL;
        loanAppObj2.Created_From__c = 'Pre Login';
        loanAppObj2.IsDedupeExecuted__c = true;
        loanAppObj2.Income_Considered__c = 'Yes';
        loanAppObj2.LMS_Customer_Info_File_Number__c = 'GLB6789002345';
        insert loanAppObj2;
        
        // account for app1
        Account acc2 = new Account();
        acc2.FirstName='Ajay';
        acc2.LastName='kumar';
        insert acc2;
        
        // Loan Applicant Creation for app2
        Loan_Applicant__c loanAppObj3 = new Loan_Applicant__c();
        loanAppObj3.Application__c=app1.Id;
        loanAppObj3.KYC_Id_1__c='HQD4572046';
        loanAppObj3.KYC_Id_2__c='HQD4572046';
        loanAppObj3.KYC_ID_Type_1__c	='Aadhaar Card';
        loanAppObj3.KYC_ID_Type_2__c='Voter Id';
        loanAppObj3.Customer_Information__c=acc1.Id;
        loanAppObj3.cifId__c=NULL;
        loanAppObj3.Created_From__c = 'Pre Login';
        loanAppObj3.IsDedupeExecuted__c = true;
        loanAppObj3.Income_Considered__c = 'Yes';
        loanAppObj3.LMS_Customer_Info_File_Number__c = 'GLB6789002345';
        insert loanAppObj3;
        
          
        
		
      
        // Disbursal Creation
        Disbursal__c dObj = new Disbursal__c();
        dObj.Application__c = app.Id;
        insert dObj;
            
            
        // Insurance DEtails Record Creation
        Insurance_details__c iObj = new Insurance_details__c();
        iObj.Application__c = app.Id;
        iObj.Insurance_Medical_Test_Result__c = 'Standard';
        iObj.Insurance_Requirement__c = 'DOGH';
        iObj.Disbursal__c = dObj.Id;
        insert iObj;
        
        
        List<Account> accList = new List<Account>();
        List<Loan_Applicant__c> loanAppList = new List<Loan_Applicant__c>();
        // Customer Information Creation
        Account acc = new Account();
        acc.FirstName='Ajay';
        acc.LastName='kumar';
        accList.add(acc);
        insert accList;
        
        // Loan Applicant Creation
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Application__c=app.Id;
        loanAppObj.KYC_Id_1__c='HQD4572046';
        loanAppObj.KYC_Id_2__c='HQD4572046';
        loanAppObj.KYC_ID_Type_1__c	='Aadhaar Card';
        loanAppObj.KYC_ID_Type_2__c='Voter Id';
        loanAppObj.Customer_Information__c=accList[0].Id;
        loanAppObj.cifId__c=NULL;
        loanAppObj.Created_From__c = 'Pre Login';
        loanAppObj.IsDedupeExecuted__c = true;
        loanAppObj.Income_Considered__c = 'Yes';
        insert loanAppObj;
        
        // Bureau Highmark Record Creation
        Bureau_Highmark__c bObj = new Bureau_Highmark__c();
        bObj.Loan_Applicant__c = loanAppObj.Id;
        insert bObj;
        
        // Loan Details Creation
        Loan_Details__c lObj = new Loan_Details__c();
        lObj.Bureau_Highmark__c = bObj.Id;
        lObj.Obligations__c = 123;
        lObj.To_be_considerd_for_DBR__c = 'Yes';
        lObj.Stage__c = 'AC';
        insert lObj;
        
        
        
        Loan_Applicant__c loanAppObj1 = new Loan_Applicant__c();
        loanAppObj1.Application__c=app.Id;
        loanAppObj1.KYC_Id_1__c='HQD4572046';
        loanAppObj1.KYC_Id_2__c='HQD4572046';
        loanAppObj1.KYC_ID_Type_1__c	='Aadhaar Card';
        loanAppObj1.KYC_ID_Type_2__c='Voter Id';
        loanAppObj1.Customer_Information__c=accList[0].Id;
        loanAppObj1.cifId__c=NULL;
        loanAppObj1.Created_From__c = 'Process Credit';
        loanAppObj1.Is_Lead_Detail_Done__c = false;
        loanAppObj1.Is_Bureau_Verified__c  = false;
        loanAppObj1.Is_KYC_Verified__c  = false;
        loanAppObj1.Mobile_Verified__c  = false;
        loanAppObj1.Income_Considered__c = 'Yes';
        loanAppObj1.Customer_Type__c = 'Guarantor';
        loanAppObj1.IsDedupeExecuted__c = true;
        loanAppObj1.isKYCorDOBorNameChanged__c = true;
        insert loanAppObj1;
        
        // content version object for bureau doc
        ContentVersion cv=new Contentversion();
        cv.title='Bureau Report';
        cv.PathOnClient = 'Bureau.PDF';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Loan_Applicant__c = loanAppObj.Id;
        cv.isBureauReport__c = true;
        insert cv;
        
        // content version object for bureau doc
        ContentVersion cv1=new Contentversion();
        cv1.title='FIV-C Photo';
        cv1.PathOnClient = 'Any.PDF';
        cv1.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv1.Parent_Id__c = app.Id;
        insert cv1;
        
        // Verification Creation PC
        Verification__c verObj = new verification__c();
        verObj.Application__c = app.Id;
        verObj.RecordTypeId = Schema.getGlobalDescribe().get('Verification__c').getDescribe().getRecordTypeInfosByName().get('PC').getRecordTypeId();
        verObj.Status__c = 'Completed';
        insert verObj;
        
        // Verification Creation FIV - C
        Verification__c verObjfc = new verification__c();
        verObjfc.Application__c = app.Id;
        verObjfc.RecordTypeId = Utility.VERIFICATION_FIV_C_RECORD_TYPE_ID;
        verObjfc.Status__c = 'Completed';
        verObjfc.Initiate_From__c = 'Process Credit';
        insert verObjfc;
        
        // Verification Creation FIV - B
        Verification__c verObjfb = new verification__c();
        verObjfb.Application__c = app.Id;
        verObjfb.RecordTypeId = Utility.VERIFICATION_FIV_B_RECORD_TYPE_ID;
        verObjfb.Status__c = 'Completed';
        verObjfb.Initiate_From__c = 'Process Credit';
        insert verObjfb;
        
        // Verification Creation ONline EC
        Verification__c verObjec = new verification__c();
        verObjec.Application__c = app.Id;
        verObjec.RecordTypeId = Utility.VERIFICATION_FIV_EC_RECORD_TYPE_ID;
        verObjec.Status__c = 'Completed';
        verObjec.Initiate_From__c = 'Process Credit';
        insert verObjec;
        
        // Verification Creation FIV - C - AC
        Verification__c verObjfc1 = new verification__c();
        verObjfc1.Application__c = app.Id;
        verObjfc1.RecordTypeId = Utility.VERIFICATION_FIV_C_RECORD_TYPE_ID;
        verObjfc1.Status__c = 'Completed';
        verObjfc1.Initiate_From__c = 'Approval Credit';
        insert verObjfc1;
        
        // Verification Creation FIV - B - AC
        Verification__c verObjfb1 = new verification__c();
        verObjfb1.Application__c = app.Id;
        verObjfb1.RecordTypeId = Utility.VERIFICATION_FIV_B_RECORD_TYPE_ID;
        verObjfb1.Status__c = 'Completed';
        verObjfb1.Initiate_From__c = 'Approval Credit';
        insert verObjfb1;
        
        // Verification Creation ONline EC - AC
        Verification__c verObjec1 = new verification__c();
        verObjec1.Application__c = app.Id;
        verObjec1.RecordTypeId = Utility.VERIFICATION_FIV_EC_RECORD_TYPE_ID;
        verObjec1.Status__c = 'Completed';
        verObjec1.Initiate_From__c = 'Approval Credit';
        insert verObjec1;
        
         // Verification Creation AC
        Verification__c verObjac = new verification__c();
        verObjac.Application__c = app.Id;
        verObjac.RecordTypeId = Utility.VERIFICATION_AC_RECORD_TYPE_ID;
        insert verObjac;      
        

        //Character Creation
        Character__c charObj = new Character__c();
        charObj.RecordTypeId = Utility.PC_CHARACTER_RECORD_TYPE_ID;
        charObj.Section_Type__c = 'Family Detail';
        charObj.Verification__c = verObj.Id;
        charObj.Application__c = app.Id;
        charObj.Loan_Applicant__c = loanAppObj.Id;
        insert charObj;
        
         //Character Creation for Neighbour
        Character__c charObj1 = new Character__c();
        charObj1.RecordTypeId = Utility.PC_CHARACTER_RECORD_TYPE_ID;
        charObj1.Section_Type__c = 'Neighbour Detail';
        charObj1.Verification__c = verObj.Id;
        charObj1.Application__c = app.Id;
        charObj1.FeedBack__c = 'Neutral';
        insert charObj1;
        
        //Character Creation for Neighbour
        Character__c charObj2 = new Character__c();
        charObj2.RecordTypeId = Utility.PC_CHARACTER_RECORD_TYPE_ID;
        charObj2.Section_Type__c = 'Neighbour Detail';
        charObj2.Verification__c = verObj.Id;
        charObj2.Application__c = app.Id;
        charObj2.FeedBack__c = 'Negative';
        insert charObj2;
        
        //Character Creation for Neighbour
        Character__c charObj3 = new Character__c();
        charObj3.RecordTypeId = Utility.PC_CHARACTER_RECORD_TYPE_ID;
        charObj3.Section_Type__c = 'LIving Standard Detail';
        charObj3.Verification__c = verObj.Id;
        charObj3.Application__c = app.Id;
        charObj3.Lifestyle__c = 'Good';
        insert charObj3;
        
        // Capability Creation for Field Credit
        Capability__c capObjfc = new Capability__c();
        capObjfc.Loan_Applicant__c = loanAppObj1.Id;
        capObjfc.RecordTypeId = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        capObjfc.Verification__c = verObjfc.Id;
        capObjfc.Application__c = app.Id;
        capObjfc.Income_segment__c = 'Salaried';
        capObjfc.Monthly_Salary__c = 12000;
        
        // Capability Creation for Process Credit
         //Capability Creation Salaried
        Capability__c capObj = new Capability__c();
        capObj.Loan_Applicant__c = loanAppObj1.Id;
        capObj.RecordTypeId = Utility.PC_CAPABILITY_RECORD_TYPE_ID;
        capObj.Verification__c = verObj.Id;
        capObj.Application__c = app.Id;
        capObj.Income_segment__c = 'Salaried';
        capObj.Monthly_Salary__c = 12000;
       
        
        //Capability Creation Rental Income
        Capability__c capObj1 = new Capability__c();
        capObj1.RecordTypeId = Utility.PC_CAPABILITY_RECORD_TYPE_ID;
        capObj1.Loan_Applicant__c = loanAppObj1.Id;
        capObj1.Verification__c = verObj.Id;
        capObj1.Application__c = app.Id;
        capObj1.Income_segment__c = 'Rental Income';
        capObj1.Rental_Income__c = 12000;
        
        //Capability Creation Transport business
        Capability__c capObj2 = new Capability__c();
        capObj2.Loan_Applicant__c = loanAppObj1.Id;
        capObj2.RecordTypeId = Utility.PC_CAPABILITY_RECORD_TYPE_ID;
        capObj2.Verification__c = verObj.Id;
        capObj2.Application__c = app.Id;
        capObj2.Income_segment__c = 'Transport business';
        capObj2.Income_per_day__c = 12;
        capObj2.Number_of_days__c = 13;
        
        //Capability Creation Pension
        Capability__c capObj3 = new Capability__c();
        capObj3.Loan_Applicant__c = loanAppObj1.Id;
        capObj3.RecordTypeId = Utility.PC_CAPABILITY_RECORD_TYPE_ID;
        capObj3.Verification__c = verObj.Id;
        capObj3.Application__c = app.Id;
        capObj3.Income_segment__c = 'Pension';
        capObj3.Income_per_month__c = 12;
        
         //Capability Creation Eateries
        Capability__c capObj4 = new Capability__c();
        capObj4.Loan_Applicant__c = loanAppObj1.Id;
        capObj4.RecordTypeId = Utility.PC_CAPABILITY_RECORD_TYPE_ID;
        capObj4.Verification__c = verObj.Id;
        capObj4.Application__c = app.Id;
        capObj4.Income_segment__c = 'Eateries';
        capObj4.Income_per_day__c = 12;
        capObj4.Number_of_days__c = 34;
        capObj4.Day_Margin_Basis__c = 'Day Basis';
        
        
         //Capability Creation Food Business
        Capability__c capObj5 = new Capability__c();
        capObj5.Loan_Applicant__c = loanAppObj1.Id;
        capObj5.RecordTypeId = Utility.PC_CAPABILITY_RECORD_TYPE_ID;
        capObj5.Verification__c = verObj.Id;
        capObj5.Application__c = app.Id;
        capObj5.Margin__c = 2;
        capObj5.Income_segment__c = 'Food business';
        capObj5.Income_per_day__c = 12000;
        capObj5.Number_of_days__c = 34;
        capObj5.Electricity__c = 10;
        capObj5.Rent__c = 10;
        capObj5.Others__c = 10;
        capObj5.Salary__c = 10;
        capObj5.Day_Margin_Basis__c = 'Margin Basis';
        
        
        // Capability Creation for Approval Credit
         //Capability Creation Salaried
        Capability__c capObjac1 = new Capability__c();
        capObjac1.Loan_Applicant__c = loanAppObj1.Id;
        capObjac1.RecordTypeId = Utility.AC_CAPABILITY_RECORD_TYPE_ID;
        capObjac1.Verification__c = verObjac.Id;
        capObjac1.Application__c = app.Id;
        capObjac1.Income_segment__c = 'Salaried';
        capObjac1.Monthly_Salary__c = 12000;
       
        
        //Capability Creation Rental Income
        Capability__c capObjac2 = new Capability__c();
        capObjac2.RecordTypeId = Utility.AC_CAPABILITY_RECORD_TYPE_ID;
        capObjac2.Loan_Applicant__c = loanAppObj1.Id;
        capObjac2.Verification__c = verObjac.Id;
        capObjac2.Application__c = app.Id;
        capObjac2.Income_segment__c = 'Rental Income';
        capObjac2.Rental_Income__c = 12000;
        
        //Capability Creation Transport business
        Capability__c capObjac3 = new Capability__c();
        capObjac3.Loan_Applicant__c = loanAppObj1.Id;
        capObjac3.RecordTypeId = Utility.AC_CAPABILITY_RECORD_TYPE_ID;
        capObjac3.Verification__c = verObjac.Id;
        capObjac3.Application__c = app.Id;
        capObjac3.Income_segment__c = 'Transport business';
        capObjac3.Income_per_day__c = 12;
        capObjac3.Number_of_days__c = 13;
        
        //Capability Creation Pension
        Capability__c capObjac4 = new Capability__c();
        capObjac4.Loan_Applicant__c = loanAppObj1.Id;
        capObjac4.RecordTypeId = Utility.AC_CAPABILITY_RECORD_TYPE_ID;
        capObjac4.Verification__c = verObjac.Id;
        capObjac4.Application__c = app.Id;
        capObjac4.Income_segment__c = 'Pension';
        capObjac4.Income_per_month__c = 12;
        
         //Capability Creation Eateries
        Capability__c capObjac5 = new Capability__c();
        capObjac5.Loan_Applicant__c = loanAppObj1.Id;
        capObjac5.RecordTypeId = Utility.AC_CAPABILITY_RECORD_TYPE_ID;
        capObjac5.Verification__c = verObjac.Id;
        capObjac5.Application__c = app.Id;
        capObjac5.Income_segment__c = 'Eateries';
        capObjac5.Income_per_day__c = 12;
        capObjac5.Number_of_days__c = 34;
        capObjac5.Day_Margin_Basis__c = 'Day Basis';
        
        
         //Capability Creation Food Business
        Capability__c capObjac6 = new Capability__c();
        capObjac6.Loan_Applicant__c = loanAppObj1.Id;
        capObjac6.RecordTypeId = Utility.AC_CAPABILITY_RECORD_TYPE_ID;
        capObjac6.Verification__c = verObjac.Id;
        capObjac6.Application__c = app.Id;
        capObjac6.Margin__c = 2;
        capObjac6.Income_segment__c = 'Food business';
        capObjac6.Income_per_day__c = 12000;
        capObjac6.Number_of_days__c = 34;
        capObjac6.Electricity__c = 10;
        capObjac6.Rent__c = 10;
        capObjac6.Others__c = 10;
        capObjac6.Salary__c = 10;
        capObjac6.Day_Margin_Basis__c = 'Margin Basis';
        
        insert new List<Capability__c>{capObjfc,capObj,capObj2,capObj1,capObj3,capObj4,capObj5,capObjac1,capObjac2,capObjac3,capObjac4,capObjac5,capObjac6};
            
        Cashflow__c cshobj = new Cashflow__c();
        cshobj.Verification__c = verObjfb.Id;
        cshobj.Obligations__c = 100;
        cshobj.Gross_Income__c = 1300;
        cshobj.Loan_Applicant__c = loanAppObj1.Id;
        insert cshobj;
        
        Fee_Creation__c fObj = new Fee_Creation__c();
        fObj.Application__c = app.Id;
        fObj.Fee_Code__c = 'FEE-101';
        fObj.Pending_Premium_Calculation__c = true;
        insert fObj;
        
        // FIV-C Property
        Property__c plProperty = new Property__c();
        plProperty.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId();
        plProperty.Application__c = app.Id;
        plProperty.isPrimaryOwner__c = true;
        insert plProperty;
        Property__c pl1Property = new Property__c();
        pl1Property.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('Pre Login Property Detail').getRecordTypeId();
        pl1Property.Application__c = app.Id;
        pl1Property.Created_From__c = 'Process Credit';
        insert pl1Property;
        Property__c fivcProperty = new Property__c();
        fivcProperty.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        fivcProperty.Application__c = app.Id;
        fivcProperty.Property__c = plProperty.Id;
        fivcProperty.IsCloned__c = false;
        fivcProperty.Total_Floor_Value__c = 2300;
        fivcProperty.Valuation_Market_Value_Per_SqFt__c = 100;
        Property__c fivBProperty = new Property__c();
        fivBProperty.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-B Property Detail').getRecordTypeId();
        fivBProperty.Application__c = app.Id;
        fivBProperty.Property__c = plProperty.Id;
        fivBProperty.Land_Area_Sq_Ft__c = 1200;
        fivBProperty.Value_per_sq_ft__c = 100;
        Property__c pcProperty = new Property__c();
        pcProperty.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('PC Property Detail').getRecordTypeId();
        pcProperty.Application__c = app.Id;
        pcProperty.Document_Type__c = 'Sale Deed';
        pcProperty.Title_Deed_Number__c = '1234';
        pcProperty.Pathway_Available__c = 'Yes';
        pcProperty.Mortgage_Property_Area__c = 'Positive';
        pcProperty.Property_Type__c = 'Vacant Land';
        pcProperty.Property__c = plProperty.Id;
        pcProperty.Total_Floor_Value__c = 2300;
        Property__c acProperty = new Property__c();
        acProperty.RecordTypeId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('AC Property Detail').getRecordTypeId();
        acProperty.Application__c = app.Id;
        acProperty.Property__c = plProperty.Id;
        
		List<Property__c> propertyList = new List<Property__c>{pcProperty,fivcProperty,fivBProperty,acProperty};        
            insert propertyList;
        
        CommonObject__c comObj1 = new CommonObject__c();
        comObj1.Object_Type__c = 'Building Floors';
        comObj1.Application__c = app.Id;
        comObj1.Property__c = fivcProperty.Id;
        comObj1.Building_Floor__c = 'GF';
        comObj1.Length_ft__c = 100;
        comObj1.Width_ft__c = 200;
        comObj1.Value_per_Sq_ft__c = 400;
        insert comObj1;
        
        CommonObject__c comObj = new CommonObject__c();
        comObj.Object_Type__c = 'Building Floors';
        comObj.Application__c = app.Id;
        comObj.Property__c = pcProperty.Id;
        comObj.Building_Floor__c = 'GF';
        comObj.Length_ft__c = 100;
        comObj.Width_ft__c = 200;
        comObj.Value_per_Sq_ft__c = 400;
        insert comObj;
        
        
          User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FS Platform User Profile'].Id,
            LastName = 'last',
            Email = 'acuser000@amamama.com',
            Username = 'acuser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        Access_Master__c acm = new Access_Master__c();
        acm.Access_For__c = 'Approval Credit';
        acm.Capacity__c = 50;
        acm.Capacity_Used__c = 0;
        acm.User__c = u.Id;
        acm.Level__c = '7';
        acm.Name = 'Approval Credi Access';
        insert acm;
        
        Branch_Master__c bm =new Branch_Master__c();
		bm.Name = 'Rajasthan';
		bm.State__c = 'RJ';
		insert bm;
        
        Access_Branch_Allocation__c abm = new Access_Branch_Allocation__c();
		abm.Branch_Master__c = bm.Id;
		abm.Access_Master__c = acm.Id;
		insert abm;
        
        Topup__c topObj = new Topup__c();
        topObj.Application__c =app2.Id;
        topObj.Remarks__c = 'MyTopup';
        insert topObj;
              
    } 
    
    @isTest
    public static void PcAcTestMethod(){
        String propId,pcpropId,fivcpropId,verId,laId,trancheApp,parentApp,acverId;
        fsPcAcController fsPcAcObj = new  fsPcAcController();
        
        Application__c appObj = [SELECT Id,Name,(SELECT Id,RecordType.Name,Created_From__c FROM Properties__r),(SELECT Id,RecordType.Name FROM Verifications__r),(SELECT Id FROM Loan_Applicants__r WHERE Created_From__c ='Pre Login' LIMIT 1) FROM Application__c WHERE Name='APP - 0001'  LIMIT 1];
        system.debug('app Name'+appObj.Name);
        for(Property__c proObj:appObj.Properties__r)
        {
            if(proObj.RecordType.Name == 'Pre Login Property Detail' && proObj.Created_From__c !='Process Credit')
            propId = proObj.Id;
            else if(proObj.RecordType.Name == 'PC Property Detail')
            pcpropId = proObj.Id;
             else if(proObj.RecordType.Name == 'FIV-C Property Detail')
            fivcpropId = proObj.Id;
        }
        for(Verification__c verObj:appObj.Verifications__r)
        {     
            if(verObj.RecordType.Name == 'PC')
            verId = verObj.Id;
            else if(verObj.RecordType.Name == 'AC')
            acverId = verObj.Id;
        }
         for(Loan_Applicant__c laonOBj:appObj.Loan_Applicants__r)
        {            
            laId = laonOBj.Id;
        }
        
        for(Application__c App : [SELECT Id,Name__c FROM Application__c ])
        {
            
            system.debug('Name ->'+App.Name__c);
            if(App.Name__c == 'APP - 0003')
                trancheApp = App.Id;
            else if(App.Name__c == 'APP - 0002')
                parentApp = App.Id;
        }
        
        Branch_Master__c bmObj = [SELECT Id FROM Branch_Master__c WHERE Name= 'Rajasthan' lIMIT 1];
      
        
        
        
        Test.startTest();
        fsPcAcController.getProperties(appObj.Id);
        fsPcAcController.getACCollateralTabRecords(appObj.Id,'AC Property Detail');
        fsPcAcController.getCharacterTabRecords(appObj.Id,'PC_Table_Family_Details','Family Detail','PC');
        fsPcAcController.sendBackUpdate(appObj.Id);
        fsPcAcController.getAccounts(appObj.Id);
        fsPcAcController.getApplicantList(appObj.Id);
        fsPcAcController.getRecordTypeId('Verification__c','PC');
        fsPcAcController.getData(propId,'Property__c');
        fsPcAcController.getData(propId,'Property__c');
        fsPcAcController.getCharacterTabRecords(appObj.Id,'PC_Table_Family_Details','Family Detail','PC');
        fsPcAcController.getCapabiltyData(appObj.Id, 'PC', 'PC_Capabilty', 'PC Capability');
        fsPcAcController.setNeighbourFeedBack(appObj.Id, verId);
        fsPcAcController.setlivingStyle(appObj.Id, verId);
        fsPcAcController.getCollateralSummary(appObj.Id, 'AC Property Detail');
        fsPcAcController.getBureauDocument(laId);
        fsPcAcController.getDocumentPublicList(appObj.Id);
		fsPcAcController.checkPCValidation(verId,appObj.Id);  
        fsPcAcController.clonedPCRecordToAC(appObj.Id, verId);
        fsPcAcController.getFloorTableRecords(appObj.Id,pcpropId,'PC_Collateral_Floor_Details','PC');
        fsPcAcController.cloneFloorDetails(appObj.Id,fivcpropId,pcpropId);
        fsPcAcController.setInsuranceFields(appObj.Id);
        fsPcAcController.GetBuildingTotalValue(appObj.Id,'FIV-C Property Detail');
        fsPcAcController.getCollateralTableRecords(appObj.Id,'PC_Col_GenDetails');
        fsPcAcController.handleTrancheApplication(trancheApp);
        fsPcAcController.generateTopupDetails(trancheApp);
        fsPcAcController.gettopupDetails(trancheApp);
        Topup__c tObj = [SELECT Id FROM Topup__c WHERE Remarks__c = 'MyTopup' LIMIT 1];
        String Data = '[{"ApplicantName":"VELUSAMY S","applicationId":"'+tObj.Id+'","ApplicationNo":"APPL00333672","Branch":"Bodinayakanur2","ConsiderForTotalExposure":"Yes","DBR":0.4429,"DPD":"0.0","Emi":6650,"ExistingLANNo":"FSTNLALONS000005259549","IsChanged":true,"LoanAmt":230000,"LTV":29.86,"OldCollateralValue":400000,"OldLoanGrossIncome":252000,"OldLoanNetIncome":180192,"OldLoanObligations":"0.0","PrincipalOs":204315.06,"Remarks":"fdsfds","TotalTenor":"60.00"}]';
        fsPcAcController.saveTopupDetails(Data, trancheApp, 'PC');
        List<Application__c> appList = new List<Application__c>{new Application__c(Id = parentApp,Name = 'APPL00004'),new Application__c(Id = trancheApp,Tranche_Disbursal__c ='I')};
        update appList;
        system.debug('newApp'+appList);
        fsPcAcController.handleTrancheApplication(trancheApp);
        fsPcAcController.getACUsers(bmObj.Id);
        fsPcAcController.setHMScore(appObj.Id, 'PC');
        
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void PcAcTestMethod1(){
        String propId,pcpropId,fivcpropId,verId,laId,trancheApp,parentApp,acverId;
        fsPcAcController fsPcAcObj = new  fsPcAcController();
        
        Application__c appObj = [SELECT Id,Name,(SELECT Id,RecordType.Name,Created_From__c FROM Properties__r),(SELECT Id,RecordType.Name FROM Verifications__r),(SELECT Id FROM Loan_Applicants__r WHERE Created_From__c ='Pre Login' LIMIT 1) FROM Application__c WHERE Name='APP - 0001'  LIMIT 1];
        system.debug('app Name'+appObj.Name);
        for(Property__c proObj:appObj.Properties__r)
        {
            if(proObj.RecordType.Name == 'Pre Login Property Detail' && proObj.Created_From__c !='Process Credit')
            propId = proObj.Id;
            else if(proObj.RecordType.Name == 'PC Property Detail')
            pcpropId = proObj.Id;
             else if(proObj.RecordType.Name == 'FIV-C Property Detail')
            fivcpropId = proObj.Id;
        }
        for(Verification__c verObj:appObj.Verifications__r)
        {     
            if(verObj.RecordType.Name == 'PC')
            verId = verObj.Id;
            else if(verObj.RecordType.Name == 'AC')
            acverId = verObj.Id;
        }
         for(Application__c App : [SELECT Id,Name__c FROM Application__c ])
        {
            if(App.Name__c == 'APP - 0003')
                trancheApp = App.Id;
            else if(App.Name__c == 'APP - 0002')
                parentApp = App.Id;
        }
        Test.startTest();
        fsPcAcController.getData(verId, 'Verification__c');
        fsPcAcController.getData(appObj.Id, 'Financial');
        fsPcAcController.getData(appObj.Id,'Approval Credit');
        fsPcAcController.getIncomeSummary(appObj.Id, 'PC Capability', 'PC');
        fsPcAcController.ComparePropertyValues(propId);
        fsPcAcController.handleFinish(appObj.Id,'PC', verId, '');
        fsPcAcController.handleFinish(appObj.Id,'AC', acverId, 'Approve');
        fsPcAcController.handleFinish(appObj.Id,'AC', acverId, 'Recommend to Another AC');
        fsPcAcController.checkACValidation(acverId, appObj.Id);
        fsPcAcController.getCapabilitySummary(appObj.Id);
        fsPcAcController.getacCapabilitySummary(appObj.Id);
        fsPcAcController.checkInsuranceValidation(appObj.Id);
        
        
        Test.stopTEst();
        
    }
    
    
}