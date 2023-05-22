@isTest
public class FIVCReportVfController_Test {
    @testSetup
    public static void testSetup(){
        
        // Inserting user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new user();
        u.FirstName = 'User First Name';
        u.LastName = 'Testclassra Code';
        u.Email = 'test@test.com';
        u.Alias = 'Tcode';
        u.Username = 'testclasshhhy@test.com';
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileId = pro.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        // Inserting Application
        Application__c applObj = new Application__c();
        applObj.Name__c = 'Test';
        applObj.Requested_Loan_Amount__c = 10000;
        applObj.Branch__c = 'TestBranch';
        insert applObj;

        // Inserting verification
        Verification__c vObj = new Verification__c();
        vObj.Status__c = 'Pending';
        vObj.Result__c = 'Positive';
        vObj.Is_applicant_co_applicant_related_kn__c = 'Yes';
        vObj.Is_applic_co_applic_related__c = 'No';
        vObj.Application__c = applObj.Id;
        vObj.Remarks_Declaration__c = 'Test data declaration';
        vObj.RecordTypeId = Schema.SObjectType.Verification__c.getRecordTypeInfosByName().get('FIV - C').getRecordTypeId();
        insert vObj;
        
        // Inserting ContentVersion
        ContentVersion cvObj = new ContentVersion();
        cvObj.PathOnClient = 'Test_Image.jpg';
        cvObj.Title = 'Test Image';
        cvObj.Parent_Id__c = applObj.Id;
        cvObj.File_Type__c = 'FIV - C Photo';
        cvObj.VersionData = Blob.valueOf('Test Image Data');
		string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        cvObj.VersionData = beforeblob;
        cvObj.Document_Name__c = 'ww';
        cvObj.IsMajorVersion = true;
        insert cvObj;
        
        // Inserting ContentDistribution
        ContentDistribution distObj = new ContentDistribution();
        distObj.ContentVersionId = cvObj.Id;
        distObj.Name = 'ABC';
		insert distObj;
        
        // Inserting Account
        Account accObj = new Account();
        accObj.Name = 'Test account name';
        insert accObj;
        
        // Inserting Loan Applicant
        Loan_Applicant__c loanAppObj = new Loan_Applicant__c();
        loanAppObj.Mobile__c = '9836726762';
        loanAppObj.Mobile_Verified__c = True;
        loanAppObj.Application__c = applObj.Id;
        loanAppObj.Customer_Information__c = accObj.Id;
        insert loanAppObj;
        
        //Inserting Revisit
        Revisit__c rev = new Revisit__c();
        rev.Verification__c = vObj.Id;
        rev.Revisit_Type__c = 'Senior Revisit';
        insert rev;
        
        Revisit__c rev1 = new Revisit__c();
        rev1.Verification__c = vObj.Id;
        rev1.Revisit_Type__c = 'General Revisit';
        insert rev1;
        
        //Inserting Bureau Highmark
        Bureau_Highmark__c br = new Bureau_Highmark__c();
        br.Address__c = 'testadd';
        br.LoanAmount__c = 33;
        br.Loan_Applicant__c = loanAppObj.Id;
        insert br;
        
        //Inserting Loan Details 
        Loan_details__c loan = new Loan_details__c();
        loan.Bureau_Highmark__c = br.Id;
        loan.Type__c = 'Self';
        loan.To_be_considerd_for_DBR__c = 'Yes';
        loan.Obligations__c = 2137257;
        loan.RecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        insert loan;    
        
        // Inserting Character data 1
        Character__c charObj = new Character__c();
        charObj.Loan_Applicant__c = loanAppObj.Id;
        charObj.Application__c = applObj.Id;
        charObj.Section_Type__c = 'Family Detail';
        charObj.Customer_Type__c = 'Guarantor';
        charObj.Family_Member_Name__c = 'Family member';
        charObj.Relationship__c = 'Self';
        charObj.Living_with_Applicant__c = 'Yes';
        charObj.Overall_Remarks__c = 'Test overall remarks';
        charObj.Neighbour_Name__c = 'Test Neighbour';
        charObj.Neighbour_Number__c = '9656726778';
        charObj.FeedBack__c = 'Positive';
        charObj.Remarks__c = 'Test remarks';
        charObj.Is_Involved__c = 'No';
        charObj.Applicant_Type__c = 'Both';
        charObj.Affiliation_Name__c = 'TestAffiliation';
        charObj.Affiliation_with__c = 'Police';
        charObj.Current_position_Position_held_in_Past__c = 'Current Position';
        charObj.Name_of_party__c = 'Test party name';
        charObj.No_of_years_in_politics__c = 11.22;
        charObj.Present_Political_Status__c = 'Active';
        charObj.Character_Of_Affiliated_Person__c = 'Positive';
        charObj.Lifestyle__c = 'Good';
        charObj.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c = 'Good';
        charObj.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c = 'Average';
        charObj.Lifestyle_Loan_Amount_8Lakhs__c = 'Below Average';
        charObj.Consumer_Durables__c = 'Cooler';
        charObj.Living_Standard_Remarks__c = 'Test living standard remarks';
        charObj.RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
		insert charObj;
        
        
        // Inserting Character data 2
        // Section_Type__c = 'Repayment Behaviour Detail' AND RecordType.Name = 'FIV-C Character'
        Character__c charObj1 = new Character__c();
        charObj1.Loan_Applicant__c = loanAppObj.Id;
        charObj1.Application__c = applObj.Id;
        charObj1.Section_Type__c = 'Repayment Behaviour Detail';
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
        charObj1.RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
        charObj1.Overall_Remarks_Highmark_Obligations__c = 'Test';
		insert charObj1;
        
        // Inserting Character data 3
        Character__c charObj2 = new Character__c();
        charObj2.Loan_Applicant__c = loanAppObj.Id;
        charObj2.Application__c = applObj.Id;
        charObj2.Section_Type__c = 'Affiliation Detail';
        charObj2.Customer_Type__c = 'Guarantor';
        charObj2.Family_Member_Name__c = 'Family member';
        charObj2.Relationship__c = 'Self';
        charObj2.Living_with_Applicant__c = 'Yes';
        charObj2.Overall_Remarks__c = 'Test overall remarks';
        charObj2.Neighbour_Name__c = 'Test Neighbour';
        charObj2.Neighbour_Number__c = '9656726778';
        charObj2.FeedBack__c = 'Positive';
        charObj2.Remarks__c = 'Test remarks';
        charObj2.Is_Involved__c = 'No';
        charObj2.Applicant_Type__c = 'Both';
        charObj2.Affiliation_Name__c = 'TestAffiliation';
        charObj2.Affiliation_with__c = 'Police';
        charObj2.Current_position_Position_held_in_Past__c = 'Current Position';
        charObj2.Name_of_party__c = 'Test party name';
        charObj2.No_of_years_in_politics__c = 11.22;
        charObj2.Present_Political_Status__c = 'Active';
        charObj2.Character_Of_Affiliated_Person__c = 'Positive';
        charObj2.Lifestyle__c = 'Good';
        charObj2.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c = 'Good';
        charObj2.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c = 'Average';
        charObj2.Lifestyle_Loan_Amount_8Lakhs__c = 'Below Average';
        charObj2.Consumer_Durables__c = 'Cooler';
        charObj2.Living_Standard_Remarks__c = 'Test living standard remarks';
        charObj2.RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
		insert charObj2;
        
        // Inserting Character data 4
        Character__c charObj3 = new Character__c();
        charObj3.Loan_Applicant__c = loanAppObj.Id;
        charObj3.Application__c = applObj.Id;
        charObj3.Section_Type__c = 'Living Standard Detail';
        charObj3.Customer_Type__c = 'Guarantor';
        charObj3.Family_Member_Name__c = 'Family member';
        charObj3.Relationship__c = 'Self';
        charObj3.Living_with_Applicant__c = 'Yes';
        charObj3.Overall_Remarks__c = 'Test overall remarks';
        charObj3.Neighbour_Name__c = 'Test Neighbour';
        charObj3.Neighbour_Number__c = '9656726778';
        charObj3.FeedBack__c = 'Positive';
        charObj3.Remarks__c = 'Test remarks';
        charObj3.Is_Involved__c = 'No';
        charObj3.Applicant_Type__c = 'Both';
        charObj3.Affiliation_Name__c = 'TestAffiliation';
        charObj3.Affiliation_with__c = 'Police';
        charObj3.Current_position_Position_held_in_Past__c = 'Current Position';
        charObj3.Name_of_party__c = 'Test party name';
        charObj3.No_of_years_in_politics__c = 11.22;
        charObj3.Present_Political_Status__c = 'Active';
        charObj3.Character_Of_Affiliated_Person__c = 'Positive';
        charObj3.Lifestyle__c = 'Good';
        charObj3.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c = 'Good';
        charObj3.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c = 'Average';
        charObj3.Lifestyle_Loan_Amount_8Lakhs__c = 'Below Average';
        charObj3.Consumer_Durables__c = 'Cooler';
        charObj3.Living_Standard_Remarks__c = 'Test living standard remarks';
        charObj3.RecordTypeId = Schema.SObjectType.Character__c.getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
		insert charObj3;
        
        // Inserting Enquiry
        CommonObject__c enqObj = new CommonObject__c();
        enqObj.Enquiry_Name__c = 'Test enquiry name';
        enqObj.Enquiry_Contact_Number__c = '9873566277';
        enqObj.Enquiry_Market_Value__c = 12000;
        enqObj.Object_Type__c = 'Enquiry';
        insert enqObj;
        
        // Inserting Property
        Property__c propObj = new Property__c();
        propObj.Original_Mortgage_Document__c = 'Yes';
        propObj.Title_Deed_Number__c = '28484';
        propObj.Document_Type__c = 'Will Deed';
        propObj.Month__c = 'March';
        propObj.Title_Deed_Year__c = '2020';
        propObj.Mortgage_property_PINCODE__c = '121004';
        propObj.Mortgage_property_Living_property_are__c = 'Yes';
        propObj.Person_residing_at_Mortgage_property__c = 'Vacant';
        propObj.Living_property_Pincode__c = '121004';
        propObj.Living_property_Distance_from_Branch__c = 6;
		propObj.Landmark__c = 'Near test';
        propObj.Overall_Remarks__c = 'Overall remarks';
        propObj.Title_Deed_Date__c = System.today();
        propObj.Pathway_Available__c = 'Yes';
        propObj.Distance_from_Branch__c = 3.22;
        propObj.Boundaries_As_Per_Inspection_Are_Same__c = 'No';
        propObj.Mortgage_Property_Area__c = 'Positive';
        propObj.Location_of_Mortgage_Property__c = 'Developing Area';
        propObj.Mortgage_Property_Remarks__c = 'Test remarks';
        propObj.Boundries_Remarks__c = 'Test boundary remarks';
        propObj.Remarks__c = 'Test remarks';
        propObj.Remarks_land_measurements__c = 'Test land Measurements';
        propObj.East_by_land_measurements__c = 12.22;
        propObj.North_by_land_measurements__c = 13.11;
        propObj.South_by_land_measurements__c = 11.10;
        propObj.West_by_land_measurements__c = 12.11;
        propObj.Valuation_Remarks__c = 'Test valuation remarks';
        propObj.Valuation_Market_Value_Per_SqFt__c = 12000;
        propObj.Building_Age__c = 22.11;
        propObj.Building_Type__c = 'ACC';
        propObj.Value_per_sq_ft__c = 12000;
        propObj.Adopted_Value_Per_SqFt__c = 4000;
        propObj.Application__c = applObj.Id;
        propObj.North_By_Land_Physical__c = 23;
        propObj.South_By_Land_Physical__c = 21;
        propObj.East_By_Land_Physical__c = 18;
        propObj.West_By_Land_Physical__c = 22;
        propObj.Total_Floor_Value__c = 10;
       // propObj.Land_Measurement_Length_Sq_ft__c = 43.22;
      //  propObj.Land_Measurement_Width_Sq_ft__c = 37.11;
        propObj.Building_Constructed_with_Remarks__c = 'Test building remarks';
        propObj.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        insert propObj;
        
        // Inserting Capabilities data 1
        Capability__c capObj = new Capability__c();
        capObj.Loan_Applicant__c = loanAppObj.Id;
        capObj.Income_segment__c = 'Salaried';
        capObj.Proof__c = 'yes';
        capObj.Proof_Remarks__c = 'Phone';
        capObj.Other_Confirmations__c = 'Reference';
        capObj.Income_per_month__c = 22000;
        capObj.Income_Remarks__c = 'Test income remarks';
        capObj.Business_Reference_Name__c = 'Business reference name';
        capObj.Business_Reference_Contact_Number__c = '9986757542';
        capObj.Feedback__c = 'Positive';
        capObj.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj.Monthly_Salary__c = 12000;
        capObj.Rental_Income__c = 10000;
        capObj.Income_per_day__c = 600;
        capObj.Number_of_days__c = 12;
        capObj.Day_Margin_Basis__c = 'Day Basis';
        capObj.Sales_per_day__c = 400;
        capObj.Margin__c = 122.22;
        capObj.Electricity__c = 3000;
        capObj.Rent__c = 6000;
        capObj.Others__c = 2000;
        capObj.Salary__c = 48000;
        capObj.Verification__c = vObj.Id;
        insert capObj;
        
        // Inserting Capabilities data 2
        Capability__c capObj2 = new Capability__c();
        capObj2.Loan_Applicant__c = loanAppObj.Id;
        capObj2.Income_segment__c = 'Rental Income';
        capObj2.Proof__c = 'yes';
        capObj2.Proof_Remarks__c = 'Phone';
        capObj2.Other_Confirmations__c = 'Reference';
        capObj2.Income_per_month__c = 22000;
        capObj2.Income_Remarks__c = 'Test income remarks';
        capObj2.Business_Reference_Name__c = 'Business reference name';
        capObj2.Business_Reference_Contact_Number__c = '9986757542';
        capObj2.Feedback__c = 'Positive';
        capObj2.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj2.Monthly_Salary__c = 12000;
        capObj2.Rental_Income__c = 10000;
        capObj2.Income_per_day__c = 600;
        capObj2.Number_of_days__c = 12;
        capObj2.Day_Margin_Basis__c = 'Day Basis';
        capObj2.Sales_per_day__c = 400;
        capObj2.Margin__c = 122.22;
        capObj2.Electricity__c = 3000;
        capObj2.Rent__c = 6000;
        capObj2.Others__c = 2000;
        capObj2.Salary__c = 48000;
        capObj2.Verification__c = vObj.Id;
        insert capObj2;
        
        // Inserting Capabilities data 3
        Capability__c capObj3 = new Capability__c();
        capObj3.Loan_Applicant__c = loanAppObj.Id;
        capObj3.Income_segment__c = 'Daily wages';
        capObj3.Proof__c = 'yes';
        capObj3.Proof_Remarks__c = 'Phone';
        capObj3.Other_Confirmations__c = 'Reference';
        capObj3.Income_per_month__c = 33000;
        capObj3.Income_Remarks__c = 'Test income remarks';
        capObj3.Business_Reference_Name__c = 'Business reference name';
        capObj3.Business_Reference_Contact_Number__c = '9986757543';
        capObj3.Feedback__c = 'Positive';
        capObj3.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj3.Monthly_Salary__c = 13000;
        capObj3.Rental_Income__c = 10000;
        capObj3.Income_per_day__c = 600;
        capObj3.Number_of_days__c = 13;
        capObj3.Day_Margin_Basis__c = 'Day Basis';
        capObj3.Sales_per_day__c = 400;
        capObj3.Margin__c = 133.33;
        capObj3.Electricity__c = 3000;
        capObj3.Rent__c = 6000;
        capObj3.Others__c = 3000;
        capObj3.Salary__c = 48000;
        capObj3.Verification__c = vObj.Id;
        insert capObj3;
        
        // Inserting Capabilities data 4
        Capability__c capObj4 = new Capability__c();
        capObj4.Loan_Applicant__c = loanAppObj.Id;
        capObj4.Income_segment__c = 'Pension';
        capObj4.Proof__c = 'yes';
        capObj4.Proof_Remarks__c = 'Phone';
        capObj4.Other_Confirmations__c = 'Reference';
        capObj4.Income_per_month__c = 44000;
        capObj4.Income_Remarks__c = 'Test income remarks';
        capObj4.Business_Reference_Name__c = 'Business reference name';
        capObj4.Business_Reference_Contact_Number__c = '9986757544';
        capObj4.Feedback__c = 'Positive';
        capObj4.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj4.Monthly_Salary__c = 14000;
        capObj4.Rental_Income__c = 10000;
        capObj4.Income_per_day__c = 600;
        capObj4.Number_of_days__c = 14;
        capObj4.Day_Margin_Basis__c = 'Day Basis';
        capObj4.Sales_per_day__c = 400;
        capObj4.Margin__c = 144.44;
        capObj4.Electricity__c = 4000;
        capObj4.Rent__c = 6000;
        capObj4.Others__c = 4000;
        capObj4.Salary__c = 48000;
        capObj4.Verification__c = vObj.Id;
        insert capObj4;
        
        
        // Inserting Capabilities data 5
        Capability__c capObj5 = new Capability__c();
        capObj5.Loan_Applicant__c = loanAppObj.Id;
        capObj5.Income_segment__c = 'Eateries';
        capObj5.Proof__c = 'yes';
        capObj5.Proof_Remarks__c = 'Phone';
        capObj5.Other_Confirmations__c = 'Reference';
        capObj5.Income_per_month__c = 55000;
        capObj5.Income_Remarks__c = 'Test income remarks';
        capObj5.Business_Reference_Name__c = 'Business reference name';
        capObj5.Business_Reference_Contact_Number__c = '9986757555';
        capObj5.Feedback__c = 'Positive';
        capObj5.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj5.Monthly_Salary__c = 15000;
        capObj5.Rental_Income__c = 10000;
        capObj5.Income_per_day__c = 600;
        capObj5.Number_of_days__c = 15;
        capObj5.Day_Margin_Basis__c = 'Day Basis';
        capObj5.Sales_per_day__c = 500;
        capObj5.Margin__c = 155.55;
        capObj5.Electricity__c = 5000;
        capObj5.Rent__c = 6000;
        capObj5.Others__c = 5000;
        capObj5.Salary__c = 58000;
        capObj5.Verification__c = vObj.Id;
        insert capObj5;
        
        // Inserting Capabilities data 6
        Capability__c capObj6 = new Capability__c();
        capObj6.Loan_Applicant__c = loanAppObj.Id;
        capObj6.Income_segment__c = 'Manufacturing';
        capObj6.Proof__c = 'yes';
        capObj6.Proof_Remarks__c = 'Phone';
        capObj6.Other_Confirmations__c = 'Reference';
        capObj6.Income_per_month__c = 66000;
        capObj6.Income_Remarks__c = 'Test income remarks';
        capObj6.Business_Reference_Name__c = 'Business reference name';
        capObj6.Business_Reference_Contact_Number__c = '9986767666';
        capObj6.Feedback__c = 'Positive';
        capObj6.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj6.Monthly_Salary__c = 16000;
        capObj6.Rental_Income__c = 10000;
        capObj6.Income_per_day__c = 600;
        capObj6.Number_of_days__c = 16;
        capObj6.Day_Margin_Basis__c = 'Margin Basis';
        capObj6.Sales_per_day__c = 600;
        capObj6.Margin__c = 166.66;
        capObj6.Electricity__c = 6000;
        capObj6.Rent__c = 6000;
        capObj6.Others__c = 6000;
        capObj6.Salary__c = 68000;
        capObj6.Verification__c = vObj.Id;
        insert capObj6;
        
        // Inserting Capabilities data 7
        Capability__c capObj7 = new Capability__c();
        capObj7.Loan_Applicant__c = loanAppObj.Id;
        capObj7.Income_segment__c = 'Milk business';
        capObj7.Proof__c = 'yes';
        capObj7.Proof_Remarks__c = 'Phone';
        capObj7.Other_Confirmations__c = 'Reference';
        capObj7.Income_per_month__c = 77000;
        capObj7.Income_Remarks__c = 'Test income remarks';
        capObj7.Business_Reference_Name__c = 'Business reference name';
        capObj7.Business_Reference_Contact_Number__c = '9987777777';
        capObj7.Feedback__c = 'Positive';
        capObj7.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj7.Monthly_Salary__c = 17000;
        capObj7.Rental_Income__c = 10000;
        capObj7.Income_per_day__c = 700;
        capObj7.Number_of_days__c = 17;
        capObj7.Day_Margin_Basis__c = 'Day Basis';
        capObj7.Sales_per_day__c = 700;
        capObj7.Margin__c = 177.77;
        capObj7.Electricity__c = 7000;
        capObj7.Rent__c = 7000;
        capObj7.Others__c = 7000;
        capObj7.Salary__c = 78000;
        capObj7.Verification__c = vObj.Id;
        insert capObj7;
        
        // Inserting Capabilities data 8
        Capability__c capObj8 = new Capability__c();
        capObj8.Loan_Applicant__c = loanAppObj.Id;
        capObj8.Income_segment__c = 'Self Employed';
        capObj8.Proof__c = 'yes';
        capObj8.Proof_Remarks__c = 'Phone';
        capObj8.Other_Confirmations__c = 'Reference';
        capObj8.Income_per_month__c = 88000;
        capObj8.Income_Remarks__c = 'Test income remarks';
        capObj8.Business_Reference_Name__c = 'Business reference name';
        capObj8.Business_Reference_Contact_Number__c = '9988888888';
        capObj8.Feedback__c = 'Positive';
        capObj8.Business_Reference_Remarks__c = 'Business reference remarks';
        capObj8.Monthly_Salary__c = 18000;
        capObj8.Rental_Income__c = 10000;
        capObj8.Income_per_day__c = 800;
        capObj8.Number_of_days__c = 18;
        capObj8.Day_Margin_Basis__c = 'Day Basis';
        capObj8.Sales_per_day__c = 800;
        capObj8.Margin__c = 188.88;
        capObj8.Electricity__c = 8000;
        capObj8.Rent__c = 8000;
        capObj8.Others__c = 8000;
        capObj8.Salary__c = 88000;
        capObj8.Verification__c = vObj.Id;
        insert capObj8;
        
        CommonObject__c com = new CommonObject__c();
    com.Application__c = applObj.Id;
    com.Object_Type__c = 'Building Floors';
    insert com;
    }

    @isTest
    public static void FIVCReportVfControllerTestMethod1(){

            List<Application__c> appList = [Select Id, Requested_Loan_Amount__c, Branch__c  FROM Application__c];
            List<Verification__c> vList = [SELECT Id, Name, Status__c, Result__c, Is_applicant_co_applicant_related_kn__c,
                                           Is_applic_co_applic_related__c, Remarks_Declaration__c FROM  Verification__c];
            Test.StartTest(); 
            PageReference pageRef = Page.FIVCReportVf; // Add your VF page Name here
            pageRef.getParameters().put('applicationId', String.valueOf(appList[0].Id));
            Test.setCurrentPage(pageRef);
        
        	FIVCReportVfController.generateFIVCPdf(vList[0].Id , appList[0].Id);
            FIVCReportVfController obj = new FIVCReportVfController();
            Test.StopTest();
    }  
}