public without sharing class FIVCReportVfController {
    public String applicationId{get;set;}
    public List<String> AppNames{get;set;}
    public List<String> Name{get;set;}
    public Application__c application{get;set;}
    public Boolean showSecondLifestyle{get;set;}
    public Boolean showThirdLifestyle{get;set;}
    public Boolean showFourthLifestyle{get;set;}
    public Boolean IsInvolved{get;set;}
    public Verification__c verificationObj{get;set;}
    public List<Loan_Applicant__c> applicants{get;set;}
    public List<Character__c> familyList{get;set;}
    public List<Character__c> affiliationList{get;set;}
    public List<Character__c> neighbourList{get;set;}
    public List<Character__c> livingStandardList{get;set;}
    public List<Account> accountList{get;set;}
    public List<Property__c> propertyList{get;set;}
    public List<Capability__c> capabilities{get;set;}
    public List<ContentDistribution> imageList{get;set;}
    public List<IncomeWrapper> incomeDetails{get;set;}
    public List<repaymentBehaviourWrapper> loanDetailWrapList {get;set;}
    public List<characterWrapper> characterWrapperList{get;set;}
    public List<floorWrapper> floorWrapperList {get;set;}
    public Decimal totalMonthlyIncome{get;set;}
    public Decimal allObligations{get;set;}
    public Decimal netMonthlyIncome{get;set;}
    public User userDetails{get;set;}
    public DecisionAuthoritydetailsWrapper decisionAuthDetailWrapObj{get;set;} 
    public List<PropertyWrapper> PropertyWrapperList{get;set;}
    
    public Decimal totalBuildingValue{get;set;}
    public Decimal totalLandValue{get;set;}
    public Decimal totalCollateralValue{get;set;}
    public Decimal businessValue{get;set;}
    
    public Boolean isMoreThanOne{get;set;}
    public List<Loan_Details__c> repaymentBehaviour{get;set;}
    public List<Revisit__c> generalRevists{get;set;}
    public List<Revisit__c> seniorRevisits{get;set;}
    public List<Image> imagesURL{get;set;}
    public String otherRemarks{get;set;}
    
    public String image{get;set;}
    Public FIVCReportVfController(){
        applicationId = ApexPages.currentPage().getParameters().get('applicationId');
        if(applicationId == '' || applicationId == NULL){
            applicationId = 'a030w000009jbuNAAQ';
        }
        allObligations = 0;
        userDetails = new User();
        userDetails = [SELECT Id, Name, Employee_Id__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        characterWrapperList = new List<characterWrapper>();
        repaymentBehaviour = new List<Loan_Details__c>();
        loanDetailWrapList = new List<repaymentBehaviourWrapper>();
        floorWrapperList = new List<floorWrapper>();
        application = [SELECT Id, Name,Type__c,Collateral_ID__c, Total_Amount_Recommended_PcAc__c, Loan_ID__c, Lien_Marked__c, Considered_for__c, Old_Collateral_value__c, Group_Valuation__c, Collateral_Address__c, 
                       Balance_Transfer__c, Primary_Applicant__r.Applicant_Name__c, Sourcing_Branch__r.Name, Loan_Type__c,Staff_Loan__c, BM_Recommended_Amount__c ,PC_Remarks__c,AC_Remarks__c,
                       Customer_Type_PcAc__c,Guarantor_Networth_Choosen__c, Loan_Purpose_1__c, Loan_Purpose_2__c, Customer_Segment__c, Customer_Sub_Segment__c,Requested_Loan_Amount__c,Principal_O_S__c,
                       Group_Total_Exposure_PcAc__c,Legal_Approval_User__r.Name,Tranche_Disbursal__c,Tenor_In_Months__c,Total_ROI_percent__c,Emi_PcAc__c,Number_of_advance_EMI__c,Effective_IRR__c,
                       Transaction_DBR__c,DBR_PC__c,Transaction_LTV__c,Combined_LTV__c,Risk_Document__c,KYC_Risk_Rating__c,Borrower_s_Risk_Rating__c, Amount_Recommended__c,
                       Legal_Approval_User__c,Combined_DBR__c,Nominee_Party_Relationship_with_Insured__c,Verified_UN_sanctions_list_and_no_match__c,Name__c,Nominee__c,Insurance_Premium__c,
                       Nominee_Party__c,Nach_Party__c,Nach_Party_2__c,Disbursement_party__c,Disbursement_Party_Name__c,Third_Party_Name__c, FIV_C_USer__c, Neighbour_feedback__c, Product_Type__c,
                       Customer_Communicated__c, FIV_C_USer__r.Name,HM__c,Previous_Owner_PC__c,Comment_Remarks__c,LTV_PCAC__c,DBR_PC_AC__c,Balance_Transfer_Amount__c,Nominee_Relationship_Type__c,                             
                       Total_net_income_after_2nd_tranche__c,Reason_for_change_in_net_income__c,Final_Collateral_value_for_Tranche_2__c,Reason_for_change_in_collateral_value__c,Tranche_1__c,User_ID__c,
                       Tranche_2__c,EMI_for_Tranche_Amount_2__c,Total_Tranche_Income__c,Tranche_Remarks__c,Remarks_change_in_net_income__c,Remarks_for_change_in_collateral_value__c,Living_style__c
                       FROM Application__c
                       WHERE Id =: applicationId];
        Set<String> bureauHighmarkIdSet = new Set<String>();
        for(Bureau_Highmark__c highmarkRecord : [SELECT Id,Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__r.Application__c =:applicationId]) {
            bureauHighmarkIdSet.add(highmarkRecord.Id);
        }
        String loanDetailRecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        for(Loan_details__c loanObj:[SELECT Id, Repayment_Remarks__c, Loan_Applicant__r.Applicant_Name__c, Type_of_Loan__c, Obligations__c,To_be_considerd_for_DBR__c,Stage__c,Bureau_Highmark__r.Highmark_Score__c FROM Loan_Details__c WHERE Bureau_Highmark__c IN:bureauHighmarkIdSet AND RecordTypeId =:loanDetailRecordTypeId]){
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes'){
                System.debug('loanObj '+loanObj.Id);
                allObligations+=loanObj.Obligations__c;
            }
            repaymentBehaviour.add(loanObj);
        }
        for(Character__c character : [SELECT Overall_Remarks_Highmark_Obligations__c,Repayment_Behaviour_Remarks__c FROM Character__c WHERE Application__c =:applicationId AND Section_Type__c = 'Repayment Behaviour Detail' AND RecordType.Name = 'FIV-C Character']){
            characterWrapper charWrap = new characterWrapper();
            charWrap.overallRemarkRepay = character.Overall_Remarks_Highmark_Obligations__c;
            characterWrapperList.add(charWrap);
        }
        
        imagesURL = new List<Image>();
        for(ContentVersion cv : [SELECT Id, Document_Name__c FROM ContentVersion WHERE Parent_Id__c =:applicationId AND File_Type__c = 'FIV - C Photo' ORDER by createdDate ASC]){
            Image img = new Image();
            img.imageURL = '/sfc/servlet.shepherd/version/download/'+cv.Id;
            img.imageName = cv.Document_Name__c;
            imagesURL.add(img);
        }
        
        verificationObj = [SELECT 
                           Id, Application__c, Application__r.Name, Owner__c,
                           Status__c, Result__c, Application__r.Requested_Loan_Amount__c, Application__r.Branch__c,Application__r.Sourcing_Branch__r.Name,
                           Remarks_Declaration__c, Is_applicant_co_applicant_related_kn__c, Is_applic_co_applic_related__c,Remarks__c
                           FROM Verification__c 
                           WHERE Application__c =:applicationId 
                           AND recordType.Name = 'FIV - C' 
                           ORDER BY CreatedDate 
                           DESC LIMIT 1];
        if(verificationObj.Application__r.Requested_Loan_Amount__c != null)
        {                
            showSecondLifestyle = (verificationObj.Application__r.Requested_Loan_Amount__c > 200000 && verificationObj.Application__r.Requested_Loan_Amount__c <= 400000) ? true : false;                
            showThirdLifestyle = (verificationObj.Application__r.Requested_Loan_Amount__c > 400000 && verificationObj.Application__r.Requested_Loan_Amount__c <= 800000) ? true : false;                
            showFourthLifestyle = (verificationObj.Application__r.Requested_Loan_Amount__c > 800000) ? true : false;
        }
        
        Set<String> loanApplicantIds = new Set<String>();
        applicants = new List<Loan_Applicant__c>();
        applicants = [SELECT Id, Customer_Type__c, Customer_Information__c, Mobile__c, Customer_Information__r.Name, Customer_Information__r.Age__c FROM Loan_Applicant__c WHERE Application__c =: applicationId ORDER BY Customer_Type_No__c];
        for(Loan_Applicant__c loanApplicant : applicants){
            loanApplicantIds.add(loanApplicant.Id);
        }
        
        familyList = new List<Character__c>();
        affiliationList = new List<Character__c>();
        neighbourList = new List<Character__c>();
        livingStandardList = new List<Character__c>();
        seniorRevisits = new List<Revisit__c>();
        generalRevists = new List<Revisit__c>();
        for(Revisit__c revisit : [SELECT Id, Revisit_Type__c,Reason_For_Visit__c,Employee_No_Of_Person_Revisited__r.EmployeeNumber, Senior_Person_Comments__c, Remarks__c, Employee_No_Of_Person_Revisited__r.Name, Years_of_possession_of_the_property__c, Revisit_done__c, Revisit_date__c,Reason_for_revist__c, Applicant_is_owner_of_the_property__c, Name, 
                                  Senior_Auditor_Confirmation_Visit__c,Does_property_mortgaged_with_any_financi__c,Mortgage_details_of_property__c FROM Revisit__c WHERE Verification__r.Application__c =:applicationId AND Verification__r.RecordType.Name = 'FIV - C']){
                                      if(revisit.Revisit_Type__c == 'Senior Revisit'){
                                          seniorRevisits.add(revisit);
                                      }
                                      else if(revisit.Revisit_Type__c == 'General Revisit'){
                                          generalRevists.add(revisit);
                                      }
                                  }
        
        // allObligations = 0;
        for(Character__c character : [SELECT Id, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name, 
                                      Application__c, Section_Type__c,Customer_Type__c, Family_Member_Name__c ,Relationship__c,
                                      Living_with_Applicant__c, Overall_Remarks__c, Neighbour_Name__c, Neighbour_Number__c, FeedBack__c, Remarks__c,
                                      Is_Involved__c, Applicant_Type__c, Affiliation_Name__c, Affiliation_with__c, Current_position_Position_held_in_Past__c,
                                      Name_of_party__c, No_of_years_in_politics__c, Present_Political_Status__c, Character_Of_Affiliated_Person__c,
                                      Lifestyle__c, Lifestyle_Loan_Amount_2L_to_4_Lakhs__c, Lifestyle_Loan_Amount_4L_to_8_Lakhs__c, Lifestyle_Loan_Amount_8Lakhs__c, 
                                      Consumer_Durables__c, Living_Standard_Remarks__c,Affiliation_Remarks__c
                                      FROM Character__c WHERE Application__c =:applicationId AND RecordType.Name = 'FIV-C Character' ORDER BY Customer_Type_No__c])
        {
            System.debug('IN LOOP= '+ character.Section_Type__c +' - '+character);
            if(character.Section_Type__c == 'Family Detail'){
                familyList.add(character);
            } else if(character.Section_Type__c == 'Neighbour Detail'){
                neighbourList.add(character);
            } else if(character.Section_Type__c == 'Affiliation Detail' ){
                affiliationList.add(character);
            } else if(character.Section_Type__c == 'Living Standard Detail'){
                livingStandardList.add(character);
            }
        }
        
        IsInvolved = false;
        if(affiliationList.size() >= 1)
        {
            IsInvolved = (affiliationList[0].Is_Involved__c != null ?(affiliationList[0].Is_Involved__c == 'Yes' ? true : false ): false);
        }
        
        for(Loan_Details__c ldObj : [Select ID, Loan_Applicant__r.Application__c, Loan_Applicant__r.Name,Loan_Applicant__r.Applicant_Name__c, Type_of_Loan__c, Loan_Amt__c , Ownership__c, O_S__c, Overdue_Amt__c,
                                     Account_Status__c, Obligations__c, Repayment_Remarks__c,To_be_considerd_for_DBR__c,Type__c,Stage__c
                                     From Loan_Details__c where Bureau_Highmark__r.Loan_Applicant__r.Application__c =:applicationId AND Stage__c IN('FIV - C','')]){
                                         repaymentBehaviourWrapper wrapObj = new repaymentBehaviourWrapper();
                                         //Deductions And Obligations
                                         //  wrapObj.srNo = srNo;
                                         wrapObj.applicantName = ldObj.Loan_Applicant__r.Applicant_Name__c;
                                         wrapObj.typeOfLoan = ldObj.Type_of_Loan__c;
                                         wrapObj.natureOfBorrower = ldObj.Type__c;
                                         wrapObj.loanAmount = ldObj.Loan_Amt__c;
                                         wrapObj.os = ldObj.O_S__c;
                                         wrapObj.emiObligations = ldObj.Obligations__c;
                                         wrapObj.emiToBeConsider = ldObj.To_be_considerd_for_DBR__c;
                                         wrapObj.remarks = ldObj.Repayment_Remarks__c;
                                         //Repayment Behaviour
                                         wrapObj.ownership = ldObj.Ownership__c;
                                         wrapObj.overDueAmount = ldObj.Overdue_Amt__c;
                                         wrapObj.accountStatus = ldObj.Account_Status__c;                             
                                         loanDetailWrapList.add(wrapObj);}
        
        
        Integer i =0;
        totalBuildingValue = 0;
        totalLandValue = 0;
        totalCollateralValue = 0;
        propertyList = new List<Property__c>();
        PropertyWrapperList = new List<PropertyWrapper>();
        propertyList = [SELECT Id, North_By_Boundaries_Physical__c,South_By_Boundaries_Physical__c, East_By_Boundaries_Physical__c, West_By_Boundaries_Physical__c,North_By_Land_Same_As_Document__c, 
                        North_By_Same_As_Document__c, South_By_Same_As_Document__c, East_By_Same_As_Document__c, West_By_Same_As_Document__c,South_By_Land_Same_As_Document__c, 
                        North_by_boundaries__c, South_by_boundaries__c,East_by_boundaries__c, West_by_boundaries__c, Avg_Floor_Value_Per_Sq_Ft__c, 
                        Name,Address_Line_2__c, Original_Mortgage_Document__c, Title_Deed_Number__c, Document_Type__c,MS_Pincode__r.Name,East_By_Land_Same_As_Document__c,Pincode__r.Name,
                        Month__c, Title_Deed_Year__c, Mortgage_property_PINCODE__c, Mortgage_property_Living_property_are__c,System_computed_distance__c,
                        Person_residing_at_Mortgage_property__c, Living_property_Pincode__c, Living_property_Distance_from_Branch__c,Property_Type__c,
                        landmark__c, Overall_Remarks__c, Title_Deed_Date__c, Pathway_Available__c, Distance_from_Branch__c,Is_living_property_is_own_property__c,
                        Boundaries_As_Per_Inspection_Are_Same__c, Mortgage_Property_Area__c, Location_of_Mortgage_Property__c,Land_area_valuation_remarks__c,
                        Mortgage_Property_Remarks__c, Boundries_Remarks__c, Remarks__c, Remarks_land_measurements__c,Nature_Of_Property__c,West_By_Land_Same_As_Document__c,
                        East_by_land_measurements__c, North_by_land_measurements__c, South_by_land_measurements__c, West_by_land_measurements__c,
                        Valuation_Remarks__c, Valuation_Market_Value_Per_SqFt__c,                
                        Building_Age__c, Building_Type__c, floor__c, lengthSq_ft__c, widthSq_ft__c, Value_per_sq_ft__c,No_of_boundaries_without_name_having__c,
                        Land_Measurement_total_area__c, Adopted_Value_Per_SqFt__c, Valuation_Final_land_value__c,All_four_boundaries_mentioned_in_doc__c,
                        Area_value_per_Sq_ft__c, Building_area_total_value__c, Total_Collateral_Value__c, Mortgage_property_distance_from_branch__c,
                        North_By_Land_Physical__c, South_By_Land_Physical__c, East_By_Land_Physical__c, West_By_Land_Physical__c,Land_Total_Area_Phy__c,
                        Land_Measurement_Length_Sq_ft__c, Land_Measurement_Width_Sq_ft__c,Building_Constructed_with_Remarks__c,Land_Total_Area_Doc__c,Property__r.Name,
                        No_Of_House_Near_Property_Within_250m_Rd__c, No_Of_Side_Wid_Vacant_Land_In_4_Boundary__c,Final_Land_Value__c,Total_Floor_Value__c,Land_Area_Sq_Ft__c,
                        Total_Floor_Area__c,
                        (SELECT Id, Enquiry_Name__c, Enquiry_Contact_Number__c, Enquiry_Market_Value__c,Application__c, Object_Type__c, Length_ft__c, Area_Extent_Sq_ft__c, Value_per_Sq_ft__c, Width_ft__c, Total_Value__c, Building_Floor__c,
                         Parent_Property__c, Property__r.Name,Property__r.Record_Type_Name__c FROM Enquiries__r WHERE Object_Type__c IN ('Enquiry','Building Floors'))
                        FROM Property__c  
                        WHERE Application__c =: applicationId AND RecordType.Name = 'FIV-C Property Detail' ];
        
        Map<String,Boolean> enquiryMap = new Map<String,Boolean>();
        isMoreThanOne = propertyList.size()>1?true:false;
        for(Property__c pro : propertyList){
            totalLandValue = totalLandValue + (pro.Valuation_Final_land_value__c != NULL ? pro.Valuation_Final_land_value__c : 0);
            totalBuildingValue += (pro.Total_Floor_Value__c !=  NULL ? pro.Total_Floor_Value__c : 0);
            totalCollateralValue = totalCollateralValue + (pro.Total_Collateral_Value__c != NULL ? pro.Total_Collateral_Value__c : 0); 
            PropertyWrapper wrapObj = new PropertyWrapper();
            wrapObj.propertyId = pro.Id;
            wrapObj.buildingtype = pro.Building_Type__c;
            wrapObj.ageofthebuilding = pro.Building_Age__c;
            
            //Floor Details
            List<FloorWrapper> floorList = new List<FloorWrapper>();
            if(pro.Enquiries__r.size() > 0){                                          
                for(CommonObject__c comObj : pro.Enquiries__r){  
                    if(comObj.Object_Type__c == 'Building Floors'){
                        FloorWrapper floorWrap = new FloorWrapper();
                        floorWrap.length = comObj.Length_ft__c;
                        floorWrap.width = comObj.Width_ft__c;  
                        floorWrap.totalValue = comObj.Total_Value__c;
                        floorWrap.areaExtent = comObj.Area_Extent_Sq_ft__c;
                        floorWrap.floors = comObj.Building_Floor__c;
                        floorWrap.valueExtent = comObj.Value_per_Sq_ft__c;
                        //floorwrap.propName = propName;
                        floorList.add(floorWrap); 
                    }
                }}         
            //Collateral Summary
            if(pro.Enquiries__r != null && pro.Enquiries__r.size() > 1){
                wrapObj.moreThanOne = true;
            }
            wrapObj.buildingFloorList = floorList;
            wrapObj.particulars = pro.Name;
            wrapObj.landArea = pro.Land_Measurement_total_area__c;
            wrapObj.landValue2 = pro.Adopted_Value_Per_SqFt__c;
            wrapObj.finalLandValue = pro.Valuation_Final_land_value__c;
            wrapObj.totalFloorArea = pro.Total_Floor_Area__c;
            wrapObj.buildingvalue = pro.Avg_Floor_Value_Per_Sq_Ft__c;
            wrapObj.finalBuildingValue = pro.Total_Floor_Value__c;
            wrapObj.totalCollateralValue = pro.Total_Collateral_Value__c;
            PropertyWrapperList.add(wrapObj);
        }
        
        capabilities = [SELECT Id, Loan_Applicant__r.Customer_Type__c, Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Rental_income_property_address__c,Income_reference_Contact_Number__c,Proof_Remarks_Daily_Wages__c,
                        Loan_Applicant__r.Customer_Information__r.Name, Income_segment__c,Remarks__c,Rental_Property_Owner_name__c,Other_Confirmations_Daily_Wages__c,considered_for_DBR__c,Reference_Name__c,Reference_Name_2__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,Overall_Remarks_Regarding_Business__c,Income_reference_name__c,Income_per_month_Pension__c,Reference_Contact_Number__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,of_income_transacted_through_bank_acco__c,Spouse_alive__c,Reference_Contact_Number_2__c,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c,FC_Enquiry_with__c,Proof_of_Ownership__c, Rental_Income__c,Margin_in_amount__c,Assumptions_for_Income__c,Business_Reference_Contact_Number_2__c,Feedback_2__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,Gross_Monthly_Income__c,Business_Reference_Name_2__c,Income_Proof_Pension__c,Year_of_Service_With_Employer__c,
                        Electricity__c, Rent__c, Others__c, Salary__c,Ownership_document_proof__c,Nature_of_Document_Proof_Self_Employed__c,Sales_per_day__c,No_of_Units__c,Name_of_the_Employer__c,Nature_of_Job__c,
                        Total_Work_Experience__c,Mode_of_Salary__c,Employment_Document_Proof__c,Nature_of_Document_Proof__c,IncomePincode__r.Name,Overall_Remarks__c,Business_name__c,Business_Nature__c,Year_of_Business__c,
                        Total_experience_in_this_business_yrs__c,Nature_of_Ownership__c,Ownership_Proof_available__c,Ownership_proof__c,regular_business_activity__c,Nature_of_Ownership_Transport__c,Nature_of_Ownership_Proof__c,BusinessPincode__r.Name
                        
                        FROM Capability__c 
                        WHERE Verification__c =: verificationObj.Id Order BY Loan_Applicant__r.Customer_Type_No__c]; 
        otherRemarks = '';
        for(Capability__c cap1 : capabilities){
            if(cap1.Income_Remarks__c == null){
                otherRemarks = 'Nil';
            } else if(cap1.Income_Remarks__c != null){
                otherRemarks = cap1.Income_Remarks__c;
            }
        }
        
        totalMonthlyIncome = 0;
        netMonthlyIncome = 0;       
        incomeDetails = new List<IncomeWrapper>();
        for(Capability__c cap : capabilities){
            IncomeWrapper incWrapObj = new IncomeWrapper();
            incWrapObj.applicantName = cap.Loan_Applicant__r.Customer_Information__r.Name;
            incWrapObj.IncomeSegment = cap.Income_segment__c;
            Decimal monthlyIncome = 0;
            if(cap.Income_segment__c == 'Salaried'){
                cap.Monthly_Salary__c = cap.Monthly_Salary__c != null ? cap.Monthly_Salary__c : 0;
                monthlyIncome = Integer.valueOf(cap.Monthly_Salary__c);
            } else if(cap.Income_segment__c == 'Rental Income'){
                cap.Rental_Income__c = cap.Rental_Income__c != null ? cap.Rental_Income__c : 0;
                monthlyIncome = Integer.valueOf(cap.Rental_Income__c);
            } else if(cap.Income_segment__c == 'Daily wages' || cap.Income_segment__c == 'Transport business'){
                cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
            } else if(cap.Income_segment__c == 'Pension' || cap.Income_segment__c == 'Income from Abroad'){
                cap.Income_per_month__c = cap.Income_per_month__c != null ? cap.Income_per_month__c : 0;
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
            } else if(cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                      cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                      cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                      cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed'){
                          if(cap.Day_Margin_Basis__c == 'Day Basis'){
                              cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                              cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                              monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                          } else if(cap.Day_Margin_Basis__c == 'Margin Basis'){
                              Decimal totalSales = Integer.valueOf(cap.Sales_per_month__c);
                              Decimal margin = cap.Margin__c != null ? cap.Margin__c : 0;
                              Decimal totalIncome = 0;
                              if(totalSales != NULL && totalSales != 0){
                                  totalIncome = (totalSales / 100 * margin);
                              }
                              if(cap.Electricity__c != Null && cap.Electricity__c != 0){
                                  totalIncome = totalIncome - cap.Electricity__c;
                              }
                              if(cap.Rent__c != Null && cap.Rent__c != 0){
                                  totalIncome = totalIncome - cap.Rent__c;
                              }
                              if(cap.Others__c != Null && cap.Others__c != 0){
                                  totalIncome = totalIncome - cap.Others__c;
                              }
                              if(cap.Salary__c != Null && cap.Salary__c != 0){
                                  totalIncome = totalIncome - cap.Salary__c;
                              }
                              monthlyIncome = totalIncome;
                          }
                      } 
            incWrapObj.incomePerMonth = Decimal.valueOf(''+monthlyIncome);
            totalMonthlyIncome += monthlyIncome;
            
            incomeDetails.add(incWrapObj);
        }
        
        netMonthlyIncome = totalMonthlyIncome - allObligations;
        
        decisionAuthDetailWrapObj = new DecisionAuthoritydetailsWrapper();
        DateTime fivcApproverDate;
        Map<String,User> UserEmployeeNumberMap = new Map<String,User>([SELECT Id,EmployeeNumber FROM User]);
        for(Verification__c vrObj : [SELECT Id,LastModifiedDate, Application__c, Record_Type_Name__c, Name, Owner__c ,BM_Recommended_Amount__c, Initiate_From__c, Application__r.FIV_C_USer__r.Name,
                                     Application__r.FIV_C_USer__c,Application__r.PC_Submission_Date__c,Application__r.AC_Submission_Date__c ,OwnerId,Owner.name FROM Verification__c 
                                     WHERE Record_Type_Name__c='FIV_C' and Owner__c != null And Application__c=:applicationId]){  
                                         if(vrObj.Record_Type_Name__c == 'FIV_C' && vrObj.Initiate_From__c=='Pre Login')
                                             fivcApproverDate = vrObj.LastModifiedDate; 
                                     }                             
        decisionAuthDetailWrapObj.fieldCreditOfficer =(String.isNotBlank(application.FIV_C_USer__r.Name)?( application.FIV_C_USer__r.Name +(UserEmployeeNumberMap.containsKey(application.FIV_C_USer__c) ?
                                                                                                                                            (String.isNOtBlank(UserEmployeeNumberMap.get(application.FIV_C_USer__c).EmployeeNumber)?
                                                                                                                                             (' / '+UserEmployeeNumberMap.get(application.FIV_C_USer__c).EmployeeNumber):'') :'')
                                                                                                          +(fivcApproverDate != null ? ' / '+fivcApproverDate.date().format() : '')):'');
        
        for(Verification__c ver : [SELECT Id,Initiate_From__c,CreatedBy.Name,CreatedDate,CreatedById FROM Verification__c WHERE RecordType.Name = 'FIV - C' AND Initiate_From__c != 'Pre Login' 
                                   AND Application__c =: applicationId ORDER BY CreatedDate DESC LIMIT 1]){
                                       decisionAuthDetailWrapObj.retrigger=(String.isNotBlank(ver.CreatedBy.Name)?( ver.CreatedBy.Name +(UserEmployeeNumberMap.containsKey(ver.CreatedById) ?
                                                                                                                                         (String.isNOtBlank(UserEmployeeNumberMap.get(ver.CreatedById).EmployeeNumber)?
                                                                                                                                          (' / '+UserEmployeeNumberMap.get(ver.CreatedById).EmployeeNumber):'') :'')
                                                                                                                   +(ver.CreatedDate != null ? ' / '+ ver.CreatedDate.date().format() : '')):'');
                                   } 
        decisionAuthDetailWrapObj.recommendingOfficer = '';
        
        /*  for(CommonObject__c co: [SELECT Id, Application__c, Object_Type__c, Length_ft__c, Area_Extent_Sq_ft__c, Value_per_Sq_ft__c, Width_ft__c, Total_Value__c, Building_Floor__c,
Parent_Property__c, Property__r.Name,Property__r.Record_Type_Name__c
FROM CommonObject__c Where Application__c =:applicationId AND Object_Type__c = 'Building Floors' AND 
Property__r.Record_Type_Name__c = 'FIV_C_Property_Detail']){
floorWrapper floorWrap = new floorWrapper();
floorWrap.length = co.Length_ft__c;
floorWrap.width = co.Width_ft__c;
floorWrap.totalValue = co.Total_Value__c;
floorWrap.areaExtent = co.Area_Extent_Sq_ft__c;
floorWrap.valueExtent = co.Value_per_Sq_ft__c;
floorWrap.floors = co.Building_Floor__c;
floorWrapperList.add(floorWrap);
}*/
    }
    
    @AuraEnabled    
    public static void generateFIVCPdf(String verificationId, String applicationId){
        PageReference pdf = Page.FIVCReportVf;
        pdf.getParameters().put('applicationId',applicationId);
        Blob body;
        
        List<ContentVersion> fivCReport = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: applicationId AND File_Type__c='FIV - C Report'];
        String title = 'FIV-C Report ' + (fivCReport != NULL && !fivCReport.isEmpty() ? (fivCReport.size() + 1)+'' : '1');
        if(Test.isRunningTest()) { 
            body = blob.valueOf('Unit.Test');
        } else {
            body = pdf.getContentAsPDF();
        }   
        System.debug('Body '+body);
        ContentVersion cv = new ContentVersion(Title = title ,File_Type__c='FIV - C Report', PathOnClient ='FIV-C Report.PDF', VersionData = body, FirstPublishLocationId = applicationId, Is_Additional_Document__c = true, Uploaded_From__c = 'FIV - C', Parent_Id__c = applicationId);
        System.debug('CV '+cv);
        insert cv;
    }
    
    
    public class IncomeWrapper{
        public String applicantName{get;set;}
        public String IncomeSegment{get;set;}
        public Decimal incomePerMonth{get;set;}
        
        public IncomeWrapper(){
            applicantName = '';
            IncomeSegment = '';
            // incomePerMonth = '';
        }
    }
    
    public class Image{
        public String imageURL{get;set;}
        public String imageName{get;set;}
    }
    
    public Class repaymentBehaviourWrapper{
        public Integer srNo{get; set;}
        public Integer srNo1{get; set;}
        public String applicantName{get; set;}
        public String natureOfBorrower{get; set;}
        public String typeOfLoan{get;set;}
        public String ownership{get;set;}
        public Decimal loanAmount{get;set;}
        public Decimal os{get;set;}
        public Decimal overDueAmount{get;set;}
        public String accountStatus{get;set;}
        public Decimal emiObligations{get;set;}
        public String emiToBeConsider{get;set;}
        public String remarks{get;set;}
        
    }
    public Class characterWrapper{
        public String overallRemarkRepay{get;set;}
    }
    
    public Class PropertyWrapper{
        public String propertyId {get;set;}
        public Decimal ageofthebuilding  {get;set;}
        public String buildingtype {get;set;}
        //1.4 Collateral Summary
        public Boolean moreThanOne{get;set;} 
        public String particulars{get;set;}
        public Decimal landArea{get;set;}
        public Decimal landValue2{get;set;}
        public Decimal finalLandValue{get;set;}
        public Decimal buildingArea{get;set;}
        public Decimal buildingvalue{get;set;}
        public Decimal finalBuildingValue{get;set;}
        public Decimal totalCollateralValue{get;set;}
        public Decimal totalBuildingValue{get;set;}
        public String floorList {get;set;}
        public Decimal totalFloorArea{get;set;}
        public List<FloorWrapper> buildingFloorList{get;set;}
        public PropertyWrapper(){
            moreThanOne = false;
        }
    }
    
    public Class FloorWrapper{
        public Decimal length{get;set;}
        public Decimal width{get;set;}
        public Decimal totalValue{get;set;}
        public Decimal areaExtent{get;set;}
        public Decimal valueExtent{get;set;}
        public String floors{get;set;}
        public String propName{get;set;}
    }
    
    public Class DecisionAuthoritydetailsWrapper {
        public String fieldCreditOfficer {get;set;}
        public String retrigger {get;set;}
        public String recommendingOfficer {get;set;}
    }
}