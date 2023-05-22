@isTest
public class FSFIVBReportVfControllerTest {
    
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
        prop1.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-B Property Detail').getRecordTypeId(); 
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
        prop1.Value_per_sq_ft__c = 44;
        prop1.Building_Area_Sq_Ft__c = 22.0;
        prop1.Building_Value_per_Sq_ft__c = 44.6;
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
        
        Cashflow__c cshobj = new Cashflow__c();
        cshobj.Verification__c = verifi1.Id;
        cshobj.Obligations__c = 100;
        cshobj.Gross_Income__c = 1300;
        cshobj.Loan_Applicant__c = l.Id;
        insert cshobj;
    }
    @isTest
    public static void testMethod1(){
        Application__c applicationRecord = [SELECT Id, Application_Id__c FROM Application__c LIMIT 1];
        Verification__c verifi1 = [Select Id from Verification__c Limit 1];
        
        PageReference testPage = Page.FIVBReportVF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('applicationId', String.valueOf(applicationRecord.Id));
        testPage.getParameters().put('verificationId', String.valueOf(verifi1.Id));
        
        
        Test.StartTest(); 
        FSFIVBReportVfController  obj = new FSFIVBReportVfController();
        FSFIVBReportVfController.generateFIVBPdf(verifi1.Id,applicationRecord.Id);
        Test.StopTest();
        
    }  
    
}