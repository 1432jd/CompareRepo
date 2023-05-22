@isTest
public class CAMReportVfControllerTest {
    
    @TestSetup
    static void createTestData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Pre_Login__c preLogin = new Pre_Login__c();
        preLogin.Status__c = 'Active';
        insert preLogin;
        
        Application__c appObj = new Application__c(Pre_Login__c=preLogin.id , Stage__c = 'Disbursal Author',
                                                   LMS_Response_Reference__c='asds',application_status__c='Active',
                                                   EMI__c=23443, Loan_Amount__c =2334,Tranche_Disbursal__c='I',
                                                   Nach_Party__c='sdssd', Nach_Party_2__c='sdssd', Mandate_Req_ID__c = 'APItest0123457791010116');
        insert appObj;
        
        Account ci = new account();
        ci.Name = 'Testname';
        insert ci;
        
        List<Loan_Applicant__c> loanList = new List<Loan_Applicant__c>();
        Loan_Applicant__c l = new Loan_Applicant__c();
        l.Application__c = appObj.Id;
        l.Customer_Type__c ='Primary Applicant';
        l.Residence_Address_Line_1__c = 'wewe';
        l.Customer_Information__c = ci.id; 
        insert l;  
        
        MS_Deviation__c msDevObj = new MS_Deviation__c(Deviation_Description__c='DBR above 50% upto 55% - OTHERS', Code__c='123',Stage__c='Operations');
        insert msDevObj;
        
        String userInfo = UserInfo.getUserId();
        User u3 = [SELECT Id, name,username FROM User WHERE Id =:userInfo];
        
        TR_Deviation__c trDevObj = new 	TR_Deviation__c();
        system.debug('User '+u3);
        system.runAs(u3){
            trDevObj = new TR_Deviation__c(MS_Deviation__c = msDevObj.ID,Approval_Level__c='L5', 
                                           Approval_Authority__c=u3.Id, Application__c=appObj.ID, 
                                           Decistion__c='Approval for Pending',is_Deviation_Active__c=true, 
                                           Is_Deviation_Raised__c=true, Date_of_Approval__c=system.today());
            insert trDevObj;
        }
        
        Sanction_Condition__c sc = new Sanction_Condition__c();
        sc.Application__c = appObj.Id;
        sc.Other_Condition__c = 'Yes';
        sc.Print_In_Sanction_Letter__c = 'Yes';
        sc.Remark__c = 'Test';
        sc.MsSanctionCondition__c = 'Test34';
        insert sc;
        
        Bureau_Highmark__c bh = new Bureau_Highmark__c();
        bh.Highmark_Score__c = '50';
        bh.Loan_Applicant__c = l.Id;
        insert bh;
        
        Loan_Details__c loan_detailsObj = new Loan_Details__c(
            RecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId(),
            Bureau_Highmark__c = bh.Id,
            Account_Status__c = 'Savings',
            Type_Of_Loan__c = 'Property',
            Ownership__c = 'Self',
            Credit_Guarantor__c = 'Self',
            Inquiries_In_Last_Six_Months__c = 6,To_be_considerd_for_DBR__c='Yes');
        insert loan_detailsObj;
        
        Character__c charObj1 = new Character__c();
        charObj1.Application__c = appObj.Id;
        charObj1.Section_Type__c = 'Neighbour Detail';
        charObj1.Customer_Type__c = 'Guarantor';
        charObj1.Family_Member_Name__c = 'Family member';
        charObj1.Relationship__c = 'Self';
        charObj1.Living_with_Applicant__c = 'Yes';
        charObj1.Overall_Remarks__c = 'Test overall remarks';
        charObj1.Neighbour_Name__c = 'Test Neighbour';
        charObj1.Neighbour_Number__c = '9656726778';
        charObj1.FeedBack__c = 'Positive';
        charObj1.Remarks__c = 'Test remarks';
        charObj1.Is_Involved__c = 'No';
        charObj1.Applicant_Type__c = 'Both';
        charObj1.Affiliation_Name__c = 'TestAffiliation';
        charObj1.Affiliation_with__c = 'Police';
        charObj1.Current_position_Position_held_in_Past__c = 'Current Position';
        charObj1.Name_of_party__c = 'Test party name';
        charObj1.No_of_years_in_politics__c = 11.22;
        charObj1.Present_Political_Status__c = 'Active';
        charObj1.Character_Of_Affiliated_Person__c = 'Positive';
        charObj1.Lifestyle__c = 'Good';
        charObj1.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c = 'Good';
        charObj1.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c = 'Average';
        charObj1.Lifestyle_Loan_Amount_8Lakhs__c = 'Below Average';
        charObj1.Consumer_Durables__c = 'Cooler';
        charObj1.Living_Standard_Remarks__c = 'Test living standard remarks';
        charObj1.RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('PC Character').getRecordTypeId();
        insert charObj1;
        
        Verification__c verifi1 = new Verification__c();
        verifi1.Name__c = 'Test';
        verifi1.Status__c = 'Pending';
        verifi1.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('AC').getRecordTypeId();
        verifi1.Application__c = appObj.Id;
        insert verifi1;
        
        Capability__c capObj = new Capability__c();
        capObj.Application__c = appObj.Id;
        capObj.Loan_Applicant__c = l.Id;
        capObj.Nature_of_Job__c = 'Engineer';
        capObj.Income_segment__c = 'Eateries';
        capObj.Income_per_day__c = 600;
        capObj.Number_of_days__c = 14;
        capObj.Day_Margin_Basis__c = 'Day Basis';
        capObj.Electricity__c = 300;
        capObj.Salary__c = 320;
        capObj.Rent__c = 300;
        capObj.Others__c = 450;
        capObj.Verification__c = verifi1.Id;
        capObj.RecordTypeId = Schema.SObjectType.Capability__c.getRecordTypeInfosByName().get('PC Capability').getRecordTypeId();
        insert capObj;
        
        Property__c prop1 = new Property__c();
        prop1.Application__c =appObj.Id;
        prop1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('PC Property Detail').getRecordTypeId(); 
        prop1.Survey_Number__c = '233432';
        prop1.Plot_No__c = '234324';
        prop1.Property_Number__c = '234232';
        prop1.Village__c = 'Testing';
        prop1.District__c = 'Agra';
        prop1.Mortgage_property_Living_property_are__c = 'No';
        prop1.Boundaries_As_Per_Inspection_Are_Same__c = 'Yes';
        prop1.Boundries_Remarks__c='';
        prop1.Pathway_Available__c = 'Yes';
        prop1.Remarks__c = '';
        prop1.Land_Area_Sq_Ft__c = 22.0;
        prop1.Valuation_Market_Value_Per_SqFt__c = 22;
        prop1.Total_Floor_Area__c = 22;
        prop1.Avg_Floor_Value_Per_Sq_Ft__c = 22;
        prop1.Total_Floor_Value__c = 22;
        prop1.Existing_Encumberances__c = 'Yes';
        prop1.Remarks_In_Encumberance__c = 'eerf';
        insert prop1;
        
        Property__c prop2 = new Property__c();
        prop2.Application__c =appObj.Id;
        prop2.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('PC Property Detail').getRecordTypeId(); 
        prop2.Survey_Number__c = '233432';
        prop2.Plot_No__c = '234324';
        prop2.Property_Number__c = '234232';
        prop2.Village__c = 'Testing';
        prop2.District__c = 'Agra';
        prop2.Mortgage_property_Living_property_are__c = 'Yes';
        prop2.Boundaries_As_Per_Inspection_Are_Same__c = 'No';
        prop2.Pathway_Available__c = 'No';
        prop2.Land_Area_Sq_Ft__c = 22.0;
        prop2.Valuation_Market_Value_Per_SqFt__c = 22;
        prop2.Total_Floor_Area__c = 22;
        prop2.Avg_Floor_Value_Per_Sq_Ft__c = 22;
        prop2.Total_Floor_Value__c = 22;
        prop2.Existing_Encumberances__c = 'No';
        prop2.Remarks_In_Encumberance__c ='';
        insert prop2;
        
        Property__c prop3 = new Property__c();
        prop3.Application__c =appObj.Id;
        prop3.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        prop3.Existing_Encumberances__c = 'Yes';
        prop3.Remarks_In_Encumberance__c ='dddd';
        insert prop3;
        
        Property__c prop4 = new Property__c();
        prop4.Application__c =appObj.Id;
        prop4.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('AC Property Detail').getRecordTypeId();
        prop4.Existing_Encumberances__c = 'Yes';
        prop4.Remarks_In_Encumberance__c ='dddd';
        insert prop4;
        
        CommonObject__c enq = new CommonObject__c();
        enq.Property__c = prop1.Id;
        enq.Object_Type__c = 'Building Floors';
        insert enq;
        
        Fee_Creation__c fee = new Fee_Creation__c();
        fee.Application__c = appObj.ID;
        fee.Applicable_For__c = 'Asset';
        fee.RecordTypeId = Schema.SObjectType.Fee_Creation__c.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        insert fee;
    }
    
    @isTest
    public static void testMethod1(){
        Application__c applicationRecord = new Application__c();
        Loan_Applicant__c objLoan = new Loan_Applicant__c();
        Fee_Creation__c fee = [Select ID from Fee_Creation__c Limit 1];
        applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        objLoan = [Select Id From Loan_Applicant__c Limit 1];
        TR_Deviation__c trDevObj = [Select Id from TR_Deviation__c Limit 1];
        Sanction_Condition__c sancObj = [Select Id from Sanction_Condition__c Limit 1];
        Bureau_Highmark__c brhObj = [Select Id from Bureau_Highmark__c Limit 1];
        Loan_Details__c loan_detailsObj = [Select Id from Loan_Details__c Limit 1];
        Character__c charObj = [Select Id from Character__c Limit 1];
        Capability__c capObj = [Select Id from Capability__c Limit 1];
        system.debug('charObj '+charObj);
		Property__c prop = [Select id from Property__c Limit 1];   
        CommonObject__c enq = [Select Id from CommonObject__c Limit 1];
        
        PageReference testPage = Page.CAMreportVF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('id', String.valueOf(applicationRecord.Id));
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(applicationRecord);
        CAMReportVfController  obj = new CAMReportVfController(sc);
        applicationRecord.Tranche_Disbursal__c = 'Normal';
        update applicationRecord;
        CAMReportVfController obj2 = new CAMReportVfController(sc);
        charObj.Section_Type__c = 'Affiliation Detail';
        update charObj;
        CAMReportVfController obj3 = new CAMReportVfController(sc);
        CAMReportVfController.generateCamReport(applicationRecord.ID, 'Process Credit');
        CAMReportVfController.checkCAMExistence(applicationRecord.Id, 'Approval Credit');
        Test.StopTest();
    }
    @isTest
    public static void testMethod2(){
        Character__c charObj = [Select Id from Character__c Limit 1];
        Application__c applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        Capability__c capObj = [Select Id from Capability__c Limit 1];
        Property__c prop = [Select id from Property__c Limit 1];   
        prop.Mortgage_property_Living_property_are__c = 'Yes';
        prop.Boundaries_As_Per_Inspection_Are_Same__c = 'Yes';
        prop.Pathway_Available__c = 'Yes';
		prop.Existing_Encumberances__c = 'No';
		prop.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Legal Approval').getRecordTypeId();
        update prop;
        
        PageReference testPage = Page.CAMreportVF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('id', String.valueOf(applicationRecord.Id));
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(applicationRecord);
        charObj.RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
        update charObj;
        CAMReportVfController obj1 = new CAMReportVfController(sc);
        delete charObj;
        CAMReportVfController obj2 = new CAMReportVfController(sc);
        capObj.Day_Margin_Basis__c = 'Margin Basis';
        update capObj;
        CAMReportVfController obj3 = new CAMReportVfController(sc);
        Test.stopTest();
    }
    @isTest
    public static void testMethod3(){
        Application__c applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        Loan_Applicant__c loanApp = [SELECT Id FROM Loan_Applicant__c WHERE Application__c =: applicationRecord.Id LIMIT 1];
        Verification__c acVerification = [SELECT Id FROM Verification__c WHERE Application__c =: applicationRecord.Id AND RecordType.Name = 'AC' LIMIT 1];
        
        Verification__c fivcVerification = new Verification__c();
        fivcVerification.Name__c = 'Test';
        fivcVerification.Status__c = 'Pending';
        fivcVerification.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        fivcVerification.Application__c = applicationRecord.Id;
        insert fivcVerification;
        PageReference testPage = Page.CAMreportVF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('id', String.valueOf(applicationRecord.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(applicationRecord);
        fsPcAcController.IncomeSummary inc = fsPcAcController.getCapabilitySummary(applicationRecord.ID);
        fsPcAcController.gettopupDetails(applicationRecord.Id);
        CAMReportVfController obj1 = new CAMReportVfController(sc);
        Test.stopTest();
        
        String rcId1 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('AC Capability').getRecordTypeId();
        String rcId2 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        List<Capability__c> capabilities = new List<Capability__c>();
        Capability__c cap1= new Capability__c();
        cap1.RecordTypeId = rcId1;
        cap1.Application__c = applicationRecord.ID;
        cap1.Verification__c = acVerification.Id;
        cap1.Income_segment__c = 'Salaried';
        cap1.Loan_Applicant__c = loanApp.Id;
        cap1.Monthly_Salary__c =1000;
        capabilities.add(cap1);
        
        Capability__c cap2= new Capability__c();
        cap2.Application__c = applicationRecord.ID;
        cap2.Verification__c = acVerification.Id;
        cap2.RecordTypeId = rcId1;
        cap2.Income_segment__c = 'Rental Income';
        cap2.Loan_Applicant__c = loanApp.Id;
        cap2.Rental_Income__c =1000;
        capabilities.add(cap2);
        
        Capability__c cap3= new Capability__c();
        cap3.Application__c = applicationRecord.ID;
        cap3.Verification__c = acVerification.Id;
        cap3.RecordTypeId = rcId1;
        cap3.Income_segment__c = 'Daily wages';
        cap3.Loan_Applicant__c = loanApp.Id;
        cap3.Income_per_day__c =1000;
        cap3.Number_of_days__c =30;
        capabilities.add(cap3);
        
        Capability__c cap4= new Capability__c();
        cap4.Application__c = applicationRecord.ID;
        cap4.Verification__c = acVerification.Id;
        cap4.RecordTypeId = rcId1;
        cap4.Income_segment__c = 'Income from Abroad';
        cap4.Loan_Applicant__c = loanApp.Id;
        cap4.Income_per_month__c =1000;
        capabilities.add(cap4);
        
        Capability__c cap5= new Capability__c();
        cap5.Application__c = applicationRecord.ID;
        cap5.Verification__c = acVerification.Id;
        cap5.RecordTypeId = rcId1;
        cap5.Income_segment__c = 'Pension';
        cap5.Loan_Applicant__c = loanApp.Id;
        cap5.Income_per_month__c =1000;
        capabilities.add(cap5);
        
        Capability__c cap6 = new Capability__c();
        cap6.Application__c = applicationRecord.ID;
        cap6.Verification__c = acVerification.Id;
        cap6.RecordTypeId = rcId1;
        cap6.Day_Margin_Basis__c = 'Day Basis';
        cap6.Income_segment__c = 'Eateries';
        cap6.Loan_Applicant__c = loanApp.Id;
        cap6.Income_per_day__c =1000;
        cap6.Number_of_days__c =30;
        capabilities.add(cap6);
        
        Capability__c cap7 = new Capability__c();
        cap7.Application__c = applicationRecord.ID;
        cap7.Verification__c = acVerification.Id;
        cap7.RecordTypeId = rcId1;
        cap7.Day_Margin_Basis__c = 'Margin Basis';
        cap7.Income_segment__c = 'Eateries';
        cap7.Loan_Applicant__c = loanApp.Id;
        cap7.Sales_per_day__c =10000;
        cap7.Number_of_days__c = 30;
        cap7.Margin__c =30;
        
        Capability__c cap8 = new Capability__c();
        cap8.Application__c = applicationRecord.ID;
        cap8.Verification__c = fivCVerification.Id;
        cap8.RecordTypeId = rcId2;
        cap8.Day_Margin_Basis__c = 'Margin Basis';
        cap8.Income_segment__c = 'Eateries';
        cap8.Loan_Applicant__c = loanApp.Id;
        cap8.Sales_per_day__c =10000;
        cap8.Number_of_days__c = 30;
        cap8.Margin__c =30;
        capabilities.add(cap8);
        
        insert capabilities;
        CAMReportVfController.getacCapabilitySummary(applicationRecord.ID);
    }
    
    @isTest
    public static void testMethod4(){
        Application__c applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        Loan_Applicant__c loanApp = [SELECT Id FROM Loan_Applicant__c WHERE Application__c =: applicationRecord.Id LIMIT 1];
        
        Verification__c pcVerification = new Verification__c();
        pcVerification.Name__c = 'Test';
        pcVerification.Status__c = 'Pending';
        pcVerification.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('PC').getRecordTypeId();
        pcVerification.Application__c = applicationRecord.Id;
        insert pcVerification;
        
        
        Verification__c fivcVerification = new Verification__c();
        fivcVerification.Name__c = 'Test';
        fivcVerification.Status__c = 'Pending';
        fivcVerification.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        fivcVerification.Application__c = applicationRecord.Id;
        insert fivcVerification;
        PageReference testPage = Page.CAMreportVF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('id', String.valueOf(applicationRecord.Id));
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(applicationRecord);
        fsPcAcController.IncomeSummary inc = fsPcAcController.getCapabilitySummary(applicationRecord.ID);
        fsPcAcController.gettopupDetails(applicationRecord.Id);
        CAMReportVfController obj1 = new CAMReportVfController(sc);
        Test.stopTest();
        
        String rcId1 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('PC Capability').getRecordTypeId();
        String rcId2 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        List<Capability__c> capabilities = new List<Capability__c>();
        Capability__c cap1= new Capability__c();
        cap1.RecordTypeId = rcId1;
        cap1.Application__c = applicationRecord.ID;
        cap1.Verification__c = pcVerification.Id;
        cap1.Income_segment__c = 'Salaried';
        cap1.Loan_Applicant__c = loanApp.Id;
        cap1.Monthly_Salary__c =1000;
        capabilities.add(cap1);
        
        Capability__c cap2= new Capability__c();
        cap2.Application__c = applicationRecord.ID;
        cap2.Verification__c = pcVerification.Id;
        cap2.RecordTypeId = rcId1;
        cap2.Income_segment__c = 'Rental Income';
        cap2.Loan_Applicant__c = loanApp.Id;
        cap2.Rental_Income__c =1000;
        capabilities.add(cap2);
        
        Capability__c cap3= new Capability__c();
        cap3.Application__c = applicationRecord.ID;
        cap3.Verification__c = pcVerification.Id;
        cap3.RecordTypeId = rcId1;
        cap3.Income_segment__c = 'Daily wages';
        cap3.Loan_Applicant__c = loanApp.Id;
        cap3.Income_per_day__c =1000;
        cap3.Number_of_days__c =30;
        capabilities.add(cap3);
        
        Capability__c cap4= new Capability__c();
        cap4.Application__c = applicationRecord.ID;
        cap4.Verification__c = pcVerification.Id;
        cap4.RecordTypeId = rcId1;
        cap4.Income_segment__c = 'Income from Abroad';
        cap4.Loan_Applicant__c = loanApp.Id;
        cap4.Income_per_month__c =1000;
        capabilities.add(cap4);
        
        Capability__c cap5= new Capability__c();
        cap5.Application__c = applicationRecord.ID;
        cap5.Verification__c = pcVerification.Id;
        cap5.RecordTypeId = rcId1;
        cap5.Income_segment__c = 'Pension';
        cap5.Loan_Applicant__c = loanApp.Id;
        cap5.Income_per_month__c =1000;
        capabilities.add(cap5);
        
        Capability__c cap6 = new Capability__c();
        cap6.Application__c = applicationRecord.ID;
        cap6.Verification__c = pcVerification.Id;
        cap6.RecordTypeId = rcId1;
        cap6.Day_Margin_Basis__c = 'Day Basis';
        cap6.Income_segment__c = 'Eateries';
        cap6.Loan_Applicant__c = loanApp.Id;
        cap6.Income_per_day__c =1000;
        cap6.Number_of_days__c =30;
        capabilities.add(cap6);
        
        Capability__c cap7 = new Capability__c();
        cap7.Application__c = applicationRecord.ID;
        cap7.Verification__c = pcVerification.Id;
        cap7.RecordTypeId = rcId1;
        cap7.Day_Margin_Basis__c = 'Margin Basis';
        cap7.Income_segment__c = 'Eateries';
        cap7.Loan_Applicant__c = loanApp.Id;
        cap7.Sales_per_day__c =10000;
        cap7.Number_of_days__c = 30;
        cap7.Margin__c =30;
        
        Capability__c cap8 = new Capability__c();
        cap8.Application__c = applicationRecord.ID;
        cap8.Verification__c = fivCVerification.Id;
        cap8.RecordTypeId = rcId2;
        cap8.Day_Margin_Basis__c = 'Margin Basis';
        cap8.Income_segment__c = 'Eateries';
        cap8.Loan_Applicant__c = loanApp.Id;
        cap8.Sales_per_day__c =10000;
        cap8.Number_of_days__c = 30;
        cap8.Margin__c =30;
        capabilities.add(cap8);
        
        insert capabilities;
        CAMReportVfController.getCapabilitySummary(applicationRecord.ID);
    }
}