public class CAMReportVfController {    
    public String currentApplicationId {get;set;}
    public Application__c application{get;set;}
    public List<String> TabNames {get;set;}
    public List<Capability__c> capabilities{get;set;}
    public String staffLoan {get;set;}
    public List<ApplicantWrapper> loanApp {get;set;}
    public List<repaymentBehaviourWrapper> loanDetailWrapList {get;set;}
    public List<repaymentBehaviourWrapper> deductionList {get;set;}
    public List<existingLoanDetailWrapper> existingLoanDetailWrapperList {get;set;}
    public List<legalPropertyWrapper> legalPropertyWrapperList {get;set;}
    public List<legalModtSummaryWrapper> legalModtSummaryWrapperList {get;set;}
    public List<existingCollateralDetailWrapper> existingCollateralDetailWrapperList {get;set;}
    public List<characterWrapper> characterWrapperList {get;set;}
    public List<SpecialConditionWrapper> SpecialConditionWrapperList{get;set;}
    public List<Character__c> familyDetails {get;set;}
    public List<Character__c> affiliationDetails {get;set;}
    public List<InsuranceDetailsWrapper> insuranceDetailsList{get;set;}
    public List<CommonObject__c> comList{get;set;}
    public List<sendBackWrapper> sendbackList{get;set;}
    public natureofPropertyWrapper natureOfPropertyObj{get;set;}
    
    public List<IncomeDetailsWrapper> IncomeDetailsWrapperList {get;set;}
    public IncomeTotalWrap incRwapObj{get;set;}
    public List<PropertyWrapper> PropertyWrapperList{get;set;} 
    public List<Property__c> propList{get;set;}    
    public Decimal totalOfLandArea{get;set;}
    public Decimal totalOfLandValue{get;set;}
    public Decimal grandLandValue{get;set;}
    public Decimal totalOfBuildingArea{get;set;}
    public Decimal totalOfBuildingValue{get;set;}
    public Decimal grandBuildingValue{get;set;}
    public Decimal totalOfColateralValue{get;set;}
    public String combinedltv{get;set;}
    public String combineddbr{get;set;}
    public String livingstyleRating{get;set;}
    public String neighbourRating{get;set;}
    public String hmRating {get;set;}
    public String acpcName{get;set;}
    public String reportName{get;set;}
    public String currentUser{get;set;}
    public String dtIST{get;set;}
    public String pcacRemarks{get;set;}
    public Boolean tableShowHide{get;set;}
    public Boolean IsInvolved{get;set;}
    public Boolean showTrancheTables{get;set;}
    public Boolean showTopupTables{get;set;}
    
    public List<deviationwrapper> deviationwrapperList{get;set;}
    public DecisionAuthoritydetailsWrapper decisionAuthDetailWrapObj{get;set;} 
    public Decimal totalMonthlyIncome{get;set;}
    public Decimal allObligations{get;set;}
    public Decimal netMonthlyIncome{get;set;}
    public List<IncomWrapper> incomeDetails{get;set;}
    public String highmarkScore{get;set;}
    public String generatedFrom;
    public String neighbourNamess{get;set;}
    public String repaymentBehaviours{get;set;}
    public String lifeStyles{get;set;}
    public String consumerDurables{get;set;}
    public String affilationRemarkss{get;set;}
    public String NeighbourRemarks{get;set;}
    public String LivingStandardRemarks{get;set;}
    public String affiliationWith{get;set;}
    public String currentPosition{get;set;}
    public String nameOfParty{get;set;}
    public Decimal noOfYears{get;set;}
    public String presentPoliticalStatus{get;set;}
    public String characterOf{get;set;}
    public String remarks{get;set;}
    public String feedbacks{get;set;}
    public String livingStyle{get;set;}
    public String neighbourHood{get;set;}
    public Decimal bmRecommendedAmount{get;set;}
    public String lanownershipss{get;set;}
    public String verifiedUnSanction{get;set;}
    public String principalOs{get;set;}
    public User userDetails{get;set;}
    public Decimal totalNetIncome{get;set;}
    public Decimal finalCollateralValue{get;set;}
    public String reasonNet{get;set;}
    public String remarksNet{get;set;}
    public String reasonCollateral{get;set;}
    public String remarksCollateral{get;set;}
    public Decimal tranche1{get;set;}
    public Decimal tranche2{get;set;}
    public Decimal insurancePremium{get;set;}
    public Decimal finaltranche{get;set;}
    public Decimal total{get;set;}
    public Decimal emiTranche2{get;set;}
    public String trancheRemarks{get;set;}
    
    public CAMReportVfController(ApexPages.StandardController controller ) {
        currentApplicationId = (ApexPages.CurrentPage().getparameters().get('id') != null ? ApexPages.CurrentPage().getparameters().get('id') : 'a020w000007z9wyAAA');
        
        /*    if(currentApplicationId == '' || currentApplicationId == NULL){
currentApplicationId = 'a020w000007z9wyAAA';
}*/
        showTrancheTables = false;
        showTopupTables = false;
        feedbacks = '';     
        bmRecommendedAmount = 0;
        affilationRemarkss = '';
        lifeStyles = '';
        consumerDurables = '';
        //repaymentBehaviours = '';
        neighbourNamess = '';
        livingStyle = '';
        lanownershipss = '';
        generatedFrom = ( ApexPages.CurrentPage().getparameters().get('Generated_From') != null ? ApexPages.CurrentPage().getparameters().get('Generated_From') : 'PC') ;
        system.debug('pcGenerated '+generatedFrom);
        // if(currentApplicationId == null)
        //currentApplicationId ='a030w000008HwIQAA0';// 'a030w000009hB8UAAU';//a030w000008HwIQAA0 for app 022
        loanApp = new List<ApplicantWrapper>();
        natureOfPropertyObj = new natureofPropertyWrapper();
        loanDetailWrapList = new List<repaymentBehaviourWrapper>();
        deductionList = new List<repaymentBehaviourWrapper>();
        existingLoanDetailWrapperList = new List<existingLoanDetailWrapper>();
        legalPropertyWrapperList = new List<legalPropertyWrapper>();
        legalModtSummaryWrapperList = new List<legalModtSummaryWrapper>();
        existingCollateralDetailWrapperList = new List<existingCollateralDetailWrapper>();
        characterWrapperList = new List<characterWrapper>();
        deviationwrapperList = new List<deviationwrapper>();
        SpecialConditionWrapperList = new List<SpecialConditionWrapper>();
        IncomeDetailsWrapperList = new List<IncomeDetailsWrapper>();
        Date maturityDate = System.today(); //need to discuss
        List<String> loanAppIds = new List<String>();
        familyDetails = new List<Character__c>();
        affiliationDetails = new List<Character__c>();
        insuranceDetailsList = new List<InsuranceDetailsWrapper>();
        PropertyWrapperList = new List<PropertyWrapper>();
        propList = new List<Property__c>();
        decisionAuthDetailWrapObj = new DecisionAuthoritydetailsWrapper();
        sendbackList = new List<sendBackWrapper>();
        
        userDetails = new User();
        userDetails = [SELECT Id, Name, Employee_Id__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        
        TabNames = new List<String>{'Applicant Name 1 : MOHAMMAD SALEEM KHAN','Co-Applicant Name 2: IMRAN KHAN','Co-Applicant Name 3: ZAREEN KHAN','Co-Applicant Name 4: MAZHAR KHAN'};
            application = [SELECT Id, Name,Type__c,Collateral_ID__c, Total_Amount_Recommended_PcAc__c, Loan_ID__c, Lien_Marked__c, Considered_for__c, Old_Collateral_value__c, Group_Valuation__c, Collateral_Address__c, 
                           Balance_Transfer__c, Primary_Applicant__r.Applicant_Name__c, Sourcing_Branch__r.Name, Loan_Type__c,Staff_Loan__c, BM_Recommended_Amount__c ,PC_Remarks__c,AC_Remarks__c,Final_Tranche_1_Loan_Amount__c,
                           Customer_Type_PcAc__c,Guarantor_Networth_Choosen__c, Loan_Purpose_1__c, Loan_Purpose_2__c, Customer_Segment__c, Customer_Sub_Segment__c,Requested_Loan_Amount__c,Principal_O_S__c,
                           Group_Total_Exposure_PcAc__c,Legal_Approval_User__r.Name,Tranche_Disbursal__c,Tenor_In_Months__c,Total_ROI_percent__c,Emi_PcAc__c,Number_of_advance_EMI__c,Effective_IRR__c,
                           Transaction_DBR__c,DBR_PC__c,Transaction_LTV__c,Combined_LTV__c,Risk_Document__c,KYC_Risk_Rating__c,Borrower_s_Risk_Rating__c, Amount_Recommended__c,Insurance_Premium_Tranche_1__c,
                           Legal_Approval_User__c,Nominee_Party_Relationship_with_Insured__c,Verified_UN_sanctions_list_and_no_match__c,Name__c,Nominee__c,Insurance_Premium__c,Insurance_Requirement__c,
                           Nominee_Party__c,Nach_Party__c,Nach_Party_2__c,Disbursement_party__c,Disbursement_Party_Name__c,Third_Party_Name__c, FIV_C_USer__c, Neighbour_feedback__c, Product_Type__c,
                           Customer_Communicated__c, FIV_C_USer__r.Name,HM__c,Previous_Owner_PC__c,Comment_Remarks__c,LTV_PCAC__c,DBR_PC_AC__c,Balance_Transfer_Amount__c,Nominee_Relationship_Type__c,AC_Submission_Date__c,							
                           Total_net_income_after_2nd_tranche__c,Reason_for_change_in_net_income__c,Final_Collateral_value_for_Tranche_2__c,Reason_for_change_in_collateral_value__c,Tranche_1__c,Recommended_AC_User__r.Name,
                           Tranche_2__c,EMI_for_Tranche_Amount_2__c,Total_Tranche_Income__c,Tranche_Remarks__c,Remarks_change_in_net_income__c,Remarks_for_change_in_collateral_value__c,Living_style__c, Income_Segment_1__c,Income_Sub_Segment__c,
                           External_Lawyer__r.Name
                           FROM Application__c
                           WHERE Id =: currentApplicationId];
        staffLoan = application.Staff_Loan__c ? 'Yes' : 'No';
        
        if(application.Type__c == 'New login' )
        {         
            if (application.Tranche_Disbursal__c == 'I' || application.Tranche_Disbursal__c == 'II')
            {
                showTrancheTables = true;                
            }
        }       
        else if(application.Type__c == 'Top-up loan')
        {
            showTopupTables = true;
            if(application.Tranche_Disbursal__c == 'I' || application.Tranche_Disbursal__c =='II')
                showTrancheTables = true;                    
        }
        else if(application.Type__c == 'Tranche loan' )
        {
            showTrancheTables = true;
            showTopupTables = true;
        }
        System.debug('tranche'+showTrancheTables);
        System.debug('topup'+showTopupTables);
        
        List<Application__c> appList = [SELECT Id, Combined_LTV__c,Comment_Remarks__c,LTV_PCAC__c,PC_Remarks__c,AC_Remarks__c, DBR_PC_AC__c,Verified_UN_sanctions_list_and_no_match__c,DBR_PC__c,HM__c,Neighbour_feedback__c,Living_style__c,
                                        Total_net_income_after_2nd_tranche__c,Reason_for_change_in_net_income__c,Final_Collateral_value_for_Tranche_2__c,Reason_for_change_in_collateral_value__c,Tranche_1__c,Borrower_s_Risk_Rating__c,Insurance_Premium_Tranche_1__c,
                                        Tranche_2__c,EMI_for_Tranche_Amount_2__c,Total_Tranche_Income__c,Principal_O_S__c,Tranche_Remarks__c,Remarks_change_in_net_income__c,Remarks_for_change_in_collateral_value__c,Tranche_Disbursal__c,Final_Tranche_1_Loan_Amount__c
                                        FROM Application__c WHERE Id=:currentApplicationID];
        for(Application__c app : appList){
            if(app.Verified_UN_sanctions_list_and_no_match__c == true){
                verifiedUnSanction = 'Verified UN sanctions list and no match found.';
            }else{
                verifiedUnSanction = '';  
            }
            if(app.Comment_Remarks__c != null){
                pcacRemarks = app.Comment_Remarks__c;
            }else{
                pcacRemarks = '';
            }
            if(app.Principal_O_S__c == null){
                principalOs = 'NA';
            }else{
                principalOs = String.valueOf(app.Principal_O_S__c);
            }
            if(app.Tranche_Disbursal__c =='I' || app.Tranche_Disbursal__c=='II'){
                totalNetIncome = app.Total_net_income_after_2nd_tranche__c;
                finalCollateralValue = app.Final_Collateral_value_for_Tranche_2__c;
                reasonNet = app.Reason_for_change_in_net_income__c;
                remarksNet = app.Remarks_change_in_net_income__c;
                reasonCollateral = app.Reason_for_change_in_collateral_value__c;
                remarksCollateral = app.Remarks_for_change_in_collateral_value__c;
                tranche1 = app.Tranche_1__c;
                tranche2 = app.Tranche_2__c;
                insurancePremium = app.Insurance_Premium_Tranche_1__c;
                finaltranche = app.Final_Tranche_1_Loan_Amount__c;
                total =app.Total_Tranche_Income__c;
                emiTranche2 = app.EMI_for_Tranche_Amount_2__c;
                trancheRemarks = app.Tranche_Remarks__c;
            }
            else if(app.Tranche_Disbursal__c == 'Normal'){
                totalNetIncome = null;
                finalCollateralValue = null;
                reasonNet = '';
                remarksNet = '';
                reasonCollateral = '';
                remarksCollateral = '';
                tranche1 = null;
                tranche2 = null;
                total = null;
                insurancePremium = null;
                finaltranche = null;
                emiTranche2 = null;
                trancheRemarks = '';
            }
        }
        
        if(appList.size()==0){
            combinedltv = '';
            combineddbr= '';
            livingstyleRating = '';
            neighbourRating = '';
            hmRating = '';
        }
        else{
            for(Application__c app : appList){
                if ( application.Combined_LTV__c <= 45){
                    combinedltv = 'Low';
                }else if(application.Combined_LTV__c > 45 && application.Combined_LTV__c <= 65){
                    combinedltv = 'Medium';
                }else if(application.Combined_LTV__c > 65){
                    combinedltv = 'High';
                }
                if(application.DBR_PC__c <= 50){
                    combineddbr = 'Low';
                }else if(application.DBR_PC__c > 50 && application.DBR_PC__c <= 60){
                    combineddbr = 'Medium';
                }else if(application.DBR_PC__c > 60){
                    combineddbr = 'High';
                }
                livingstyleRating = (String.isNotBlank(application.Living_style__c) ? (application.Living_style__c == 'Good' ? 'Low' : (application.Living_style__c == 'Average' ? 'Medium' : (application.Living_style__c == 'Below Average' ? 'High' : ''))): '');
                neighbourRating = (String.isNotBlank(application.Neighbour_feedback__c) ?(application.Neighbour_feedback__c == 'Positive' ? 'Low' : (application.Neighbour_feedback__c == 'Neutral' ? 'Medium' : (application.Neighbour_feedback__c == 'Negative' ? 'High' : ''))):'');
                
                if( String.isNotBlank(application.HM__c) && application.HM__c.isnumeric())
                {
                    hmRating = ((Integer.valueOf(application.HM__c) < 350 && Integer.valueOf(application.HM__c) >= 300) ? 'High' : ((Integer.valueOf(application.HM__c) >= 350 && Integer.valueOf(application.HM__c) <= 500) ? 'Medium' : ((Integer.valueOf(application.HM__c) > 500 || Integer.valueOf(application.HM__c) < 300 || application.HM__c == 'NA' || application.HM__c == 'na') ? 'Low' : '')));                    
                } else if(application.HM__c == NULL || !application.HM__c.isnumeric()){
                    hmRating = 'Low';
                }
            }
        }
        
        for(Application__c application : [SELECT Id, AC_Decision__c, PC_Decision__c, PC_Submission_Date__c, AC_Submission_Date__c,Stage__c,Total_Amount_Recommended_PcAc__c,Tenor_In_Months__c,Emi_PcAc__c,
                                          Customer_Communicated__c,Owner__c FROM Application__c WHERE ID=:currentApplicationId]){
                                              
                                          }
        
        List<Loan_Applicant__c> applicant = [SELECT Id,Applicant_Name__c,Customer_Type__c,Mobile__c,Sorting_Order__c,Customer_Information__r.PersonBirthDate,Customer_Information__r.Age__c, Application__r.Tenor_In_Months__c,Application__r.HM__c,
                                             (SELECT Id, Name, Highmark_Score__c, Loan_Applicant__c FROM Bureau_Highmarks__r where Loan_Applicant__r.Customer_Type__c ='Primary Applicant' Limit 1) FROM Loan_Applicant__c
                                             WHERE Application__c = :currentApplicationId ORDER By Sorting_Order__c];
        String primaryApplicantId;
        for(Loan_Applicant__c objLoan : applicant){
            loanAppIds.add(objLoan.Id);
            ApplicantWrapper objWrap = new ApplicantWrapper();
            //Integer days =
            //objLoan.Customer_Information__r.PersonBirthDate.daysBetween(maturityDate) + Integer.valueOf(objLoan.Application__r.Tenor_In_Months__c)/12;
            // system.debug('daysss ' +days);
            if(objLoan.Customer_Information__r.Age__c != null && objLoan.Application__r.Tenor_In_Months__c != Null)
                objWrap.applicantAgeOnMaturity = Integer.valueOf(objLoan.Customer_Information__r.Age__c) +Integer.valueOf(objLoan.Application__r.Tenor_In_Months__c)/12;
            //Integer.valueOf(days/365);
            objWrap.applicantName = objLoan.Applicant_Name__c;
            objWrap.applicantMobile = objLoan.Mobile__c;
            objWrap.applicantType = objLoan.Customer_Type__c;
            objWrap.applicantAge = objLoan.Customer_Information__r.Age__c;
            objWrap.highmark = objLoan.Application__r.HM__c;
            loanApp.add(objWrap);
            if(objLoan.Customer_Type__c == 'Primary Applicant'  && objLoan.Bureau_Highmarks__r.size()>0){
                highmarkScore = objLoan.Bureau_Highmarks__r[0].Highmark_Score__c;
            }
        }
        
        //Deviation        
        for(TR_Deviation__c trdevObj : [SELECT Id, Application__c, Decistion__c, Remark__c, Deviation_Type__c, Approval_Authority__r.Name, Deviation_Description__c, Approval_Level__c
                                        ,Date_of_Approval__c, Is_Deviation_Active__c,Approval_Authority__r.EmployeeNumber FROM TR_Deviation__c
                                        WHERE Application__c = :currentApplicationId AND Is_Deviation_Active__c = true AND (Decistion__c = 'Not Approved' OR Decistion__c = 'Approved' OR Decistion__c ='Approval for Pending')]){
                                            deviationwrapper wrapObj = new deviationwrapper();
                                            wrapObj.category = trdevObj.Deviation_Description__c;
                                            wrapObj.natureofDeviation = trdevObj.Deviation_Type__c;
                                            wrapObj.status = trdevObj.Decistion__c;
                                            wrapObj.approvedBy = trdevObj.Approval_Authority__r.Name;
                                            if(trdevObj.Approval_Authority__r.EmployeeNumber != null)
                                                wrapObj.approvedBy += '/'+trdevObj.Approval_Authority__r.EmployeeNumber;
                                            wrapObj.approvalLevel = trdevObj.Approval_Level__c;
                                            if(trdevObj.Date_of_Approval__c != null){
                                                Date dToday = Date.valueOf(trdevObj.Date_of_Approval__c);
                                                wrapObj.dateOfApproval = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
                                            }
                                            wrapObj.mitigantsRemarks = trdevObj.Remark__c;
                                            deviationwrapperList.add(wrapObj);
                                        }
        
        //Special Conditions
        Integer index = 0;
        for(Sanction_Condition__c sancObj : [Select Id, name,CreatedDate, Remark__c, MsSanctionCondition__c, Added_By__r.Name,Print_In_Sanction_Letter__c 
                                             FROM Sanction_Condition__c WHERE Application__c=:currentApplicationId]){
                                                 SpecialConditionWrapper wrapObj = new SpecialConditionWrapper();
                                                 Date dtDate = Date.valueOf(sancObj.CreatedDate);
                                                 wrapObj.raisedDate = dtDate.day() + '/' + dtDate.month() + '/' + dtDate.year();
                                                 //String.valueOf(Date.valueOf(sancObj.CreatedDate)).removeEnd(' ') != null ? String.valueOf(Date.valueOf(sancObj.CreatedDate)).removeEnd(' ') : '';
                                                 wrapObj.srNo = index++ + 1;
                                                 wrapObj.raisedBy = sancObj.Added_By__r.Name;
                                                 wrapObj.specialCondDescription = sancObj.Remark__c;
                                                 wrapObj.specialCondCode = sancObj.name;
                                                 wrapObj.printInSanction = sancObj.Print_In_Sanction_Letter__c;                                     
                                                 wrapObj.sanctionCondition = sancObj.MsSanctionCondition__c;
                                                 SpecialConditionWrapperList.add(wrapObj);
                                             }
        
        String familyRecordTypeName;
        if(generatedFrom == 'PC'){
            familyRecordTypeName = 'PC Character';
            acpcName = 'Process Credit(INR)';
            reportName = 'Process';
        }
        else{
            familyRecordTypeName = 'AC Character';
            acpcName = 'Approval Credit(INR)';
            reportName = 'Approval';
        }
        
        familyDetails = [SELECT Id, Loan_Applicant__r.Applicant_Name__c,Family_Member_Name__c,Overall_Remarks__c, Living_with_Applicant__c, Customer_Type__c, Remarks__c, Relationship__c,Application__c
                         FROM Character__c
                         WHERE Application__c =: currentApplicationId AND Section_Type__c = 'Family Detail' AND recordType.name =:familyRecordTypeName ORDER BY Customer_Type_No__c];
        
        affiliationDetails = [Select Id, Neighbour_Name__c,Affiliation_Name__c, FeedBack__c,Affiliation_Remarks__c,Remarks__c,Consumer_Durables__c,Current_position_Position_held_in_Past__c,
                              Lifestyle__c, Lifestyle_Loan_Amount_2L_to_4_Lakhs__c, Section_Type__c,Loan_Applicant__r.Customer_Type__c,Living_Standard__c,Affiliation_with__c,
                              Lifestyle_Loan_Amount_4L_to_8_Lakhs__c, Lifestyle_Loan_Amount_8Lakhs__c, Overall_Remarks_Highmark_Obligations__c,Customer_Type__c,
                              Name_of_party__c,No_of_years_in_politics__c,Present_Political_Status__c,Character_Of_Affiliated_Person__c,Is_Involved__c
                              From Character__c where Application__c =:currentApplicationId AND Section_Type__c = 'Affiliation Detail' And RecordType.Name=: familyRecordTypeName];
        IsInvolved = false;
        if(affiliationDetails.size() >= 1)
        {
            IsInvolved = (affiliationDetails[0].Is_Involved__c != null ?(affiliationDetails[0].Is_Involved__c == 'Yes' ? true : false ): false);
        }
        
        Integer count = 0;
        for(Fee_Creation__c feeObj : [SELECT Id,Application__c,Description__c,External_Agency_Master__r.Name,Applicable_For__c,Premium__c,Tax_Amount__c,
                                      Sum_Assured__c,Total_Fee__c,Repayment_Type_2__c,Fee_Creation__c.Property__r.Name,Loan_Applicant__r.Applicant_Name__c 
                                      FROM Fee_Creation__c WHERE Application__c =: currentApplicationId AND RecordType.Name=:'Insurance']){
                                          count++;
                                          InsuranceDetailsWrapper insWrap = new InsuranceDetailsWrapper();
                                          insWrap.count = count;
                                          insWrap.insuranceName = feeObj.Description__c;
                                          insWrap.insuranceAgency = feeObj.External_Agency_Master__r.Name;
                                          if(feeObj.Applicable_For__c == 'Asset'){
                                              insWrap.applicableFor = feeObj.Property__r.Name;
                                          }else if(feeObj.Applicable_For__c == 'Applicant'){
                                              insWrap.applicableFor = feeObj.Loan_Applicant__r.Applicant_Name__c;
                                          }
                                          insWrap.premiunAmount = feeObj.Premium__c;
                                          insWrap.taxAmount = feeObj.Tax_Amount__c;
                                          insWrap.finalAmount = feeObj.Total_Fee__c;
                                          inswrap.sumAssured = feeObj.Sum_Assured__c;
                                          insWrap.mode = feeObj.Repayment_Type_2__c;
                                          insuranceDetailsList.add(insWrap);
                                      }
        
        String stage1;
        if(generatedFrom =='PC'){
            stage1 = 'PC';
        }else if(generatedFrom == 'AC'){
            stage1 = 'PC';
            stage1 = 'AC'; 
        }
        Set<String> stageSet = new Set<String>();
        if(generatedFrom == 'PC')
            stageSet.addAll(new List<String>{'PC',''});
        else if(generatedFrom == 'AC')
            stageSet.addAll(new List<String>{'PC','AC',''});
        Integer srNo = 0;
        Integer srNo1 = 0;
        for(Loan_Details__c ldObj : [Select ID, Loan_Applicant__r.Application__c, Loan_Applicant__r.Name,Loan_Applicant__r.Applicant_Name__c, Type_of_Loan__c, Loan_Amt__c , Ownership__c, O_S__c, Overdue_Amt__c,
                                     Account_Status__c, Obligations__c, Repayment_Remarks__c,To_be_considerd_for_DBR__c,Type__c,Stage__c
                                     From Loan_Details__c where Bureau_Highmark__r.Loan_Applicant__r.Application__c =:currentApplicationId AND Stage__c IN:stageSet]){
                                         srNo++;
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
                                         loanDetailWrapList.add(wrapObj);
                                         
                                         repaymentBehaviourWrapper wrapObj1 = new repaymentBehaviourWrapper();
                                         srNo1++;
                                         //Dedutions And Obligations
                                         if(ldObj.To_be_considerd_for_DBR__c == 'Yes'){
                                             //    wrapObj1.srNo1 = srNo1;
                                             wrapObj1.applicantName = ldObj.Loan_Applicant__r.Applicant_Name__c;
                                             wrapObj1.natureOfBorrower = ldObj.Type__c;    
                                             wrapObj1.typeOfLoan = ldObj.Type_of_Loan__c;
                                             wrapObj1.loanAmount = ldObj.Loan_Amt__c;
                                             wrapObj1.os = ldObj.O_S__c;
                                             wrapObj1.emiObligations = ldObj.Obligations__c;
                                             wrapObj1.emiToBeConsider = ldObj.To_be_considerd_for_DBR__c;
                                             wrapObj1.remarks = ldObj.Repayment_Remarks__c;
                                             deductionList.add(wrapObj1);
                                         }
                                     }
        
        fsPcAcController.TopupWrapper loanColaateralWrap;
        system.debug('Topup' + loanColaateralWrap);
        if(generatedFrom == 'PC'){
            system.debug('appidd '+currentApplicationId);
            loanColaateralWrap= fsPcAcController.gettopupDetails(currentApplicationId);
        }
        else if(generatedFrom == 'AC'){
            loanColaateralWrap= fsPcAcController.gettopupDetails(currentApplicationId);
        } 
        for(fsPcAcController.topupDetailsWrapper topupWrapObj : loanColaateralWrap.TopupDetailsList){
            existingLoanDetailWrapper wrapObj = new existingLoanDetailWrapper();
            //Loan Details
            wrapObj.existingLoanAccNo = topupWrapObj.ExistingLANNo;
            wrapObj.appName=topupWrapObj.ApplicationNo;
            wrapObj.applicantName = topupWrapObj.ApplicantName;
            wrapObj.branch = topupWrapObj.Branch;
            wrapObj.loanAmount = topupWrapObj.LoanAmt;
            wrapObj.emi = topupWrapObj.Emi;
            wrapObj.principalOS = topupWrapObj.PrincipalOs;
            wrapObj.dpd = topupWrapObj.DPD;
            wrapObj.considerFor = topupWrapObj.ConsiderForTotalExposure;
            wrapObj.remarks = topupWrapObj.Remarks; 
            //Old Loan Details
            wrapObj.oldCollateralValue = topupWrapObj.OldCollateralValue;
            wrapObj.oldLoanGrossIncome = topupWrapObj.OldLoanGrossIncome;
            wrapObj.oldLoanObligations = topupWrapObj.OldLoanObligations;
            wrapObj.oldLoanNetIncome = topupWrapObj.OldLoanNetIncome;
            wrapObj.DBR	= topupWrapObj.DBR;
            wrapObj.LTV = topupWrapObj.LTV;
            existingLoanDetailWrapperList.add(wrapObj);  
        }
        
        if(existingLoanDetailWrapperList != NULL && !existingLoanDetailWrapperList.isEMpty()){
            showTopupTables = true;
        }        
        
        Integer SrNoo = 0;
        for(fsPcAcController.PropertyWrapper proWrapObj : loanColaateralWrap.PropertyList){
            existingCollateralDetailWrapper wrapObj = new existingCollateralDetailWrapper();
            wrapObj.SrNoo = index++ +1;
            wrapObj.collateralId = proWrapObj.CollateralId;
            wrapObj.loanId = proWrapObj.LoanId;
            wrapObj.collateralAddress = proWrapObj.CollateralAddress;
            existingCollateralDetailWrapperList.add(wrapObj);
            //Missing Fields - To be considered, Property Valuation-Application(Group Valuation for current), Collateral Value(Application current collateral value), Lien Marked-Empty, Total Market Value
        }   
        
        //X. Character:
        List<Character__c> charObj =  [Select Id, Neighbour_Name__c, FeedBack__c,Affiliation_Remarks__c,Remarks__c,Consumer_Durables__c,Current_position_Position_held_in_Past__c,
                                       Lifestyle__c, Lifestyle_Loan_Amount_2L_to_4_Lakhs__c, Section_Type__c,Loan_Applicant__r.Customer_Type__c,Living_Standard__c,Affiliation_with__c,
                                       Lifestyle_Loan_Amount_4L_to_8_Lakhs__c, Lifestyle_Loan_Amount_8Lakhs__c, Overall_Remarks_Highmark_Obligations__c,Customer_Type__c,
                                       Name_of_party__c,No_of_years_in_politics__c,Present_Political_Status__c,Character_Of_Affiliated_Person__c,Living_Standard_Remarks__c
                                       From Character__c where Application__c =:currentApplicationId And RecordType.Name=: familyRecordTypeName];
        if(charObj.Size() == 0){
            LivingStandardRemarks = 'Nil';
            NeighbourRemarks = 'Nil';
            feedbacks = '';
            affilationRemarkss = '';
            lifeStyles = '';
            repaymentBehaviours= 'Nil';												
            affiliationWith = '';
            consumerDurables ='';
            currentPosition ='';
            nameOfParty = '';
            noOfYears =0;
            presentPoliticalStatus='';
            characterOf='';
            remarks ='';
        }
        else{
            if(charObj[0].Section_Type__c == 'Affiliation Detail' && charObj[0].Current_position_Position_held_in_Past__c != null){
                currentPosition = charObj[0].Current_position_Position_held_in_Past__c;  
            }
            
            system.debug('current===>' + currentPosition);
            nameOfParty = charObj[0].Name_of_party__c;
            noOfYears = charObj[0].No_of_years_in_politics__c;
            presentPoliticalStatus = charObj[0].Present_Political_Status__c;
            characterOf = charObj[0].Character_Of_Affiliated_Person__c;
            remarks = charObj[0].Remarks__c;
            feedbacks ='';
            for(Character__c charList1 : charObj){
                if(charList1.Section_Type__c == 'Neighbour Detail' && charList1.Neighbour_Name__c != null){
                    feedbacks += charList1.FeedBack__c;
                    feedbacks += ',';
                }
                if(charList1.Section_Type__c == 'Neighbour Detail' && charList1.Remarks__c != null){
                    NeighbourRemarks = charList1.Remarks__c;                   
                }else
                    NeighbourRemarks = 'Nil';
            }
            feedbacks = feedbacks.removeEnd(',');
            affilationRemarkss = '';
            for(Character__c charList1 : charObj){
                if(charList1.Section_Type__c == 'Affiliation Detail' && charList1.Remarks__c != null){
                    affilationRemarkss += charList1.Remarks__c;
                    affilationRemarkss += ',';
                }
            }
            affilationRemarkss =affilationRemarkss.removeEnd(',');
            //  affiliationWith =affiliationWith.removeEnd(',');
            
            affiliationWith = '';
            for(Character__c charList : charObj){
                if(charList.Section_Type__c == 'Affiliation Detail' && charList.Affiliation_with__c != null){
                    affiliationWith += charList.Affiliation_with__c;
                    affiliationWith += '/';
                }
            }
            affiliationWith =affiliationWith.removeEnd('/');
            for(Character__c charList1 : charObj){
                if(charList1.Section_Type__c == 'Affiliation Detail' && charList1.Current_position_Position_held_in_Past__c != null){
                    currentPosition += charObj[0].Current_position_Position_held_in_Past__c;
                    affilationRemarkss += ',';
                }
            }
            
            consumerDurables = '';
            LivingStandardRemarks = 'Nil';
            for(Character__c charList2 : charObj){
                if(charList2.Section_Type__c == 'Living Standard Detail' && charList2.Consumer_Durables__c != null){
                    consumerDurables = charList2.Consumer_Durables__c.replace(';',', ');
                }
                if(charList2.Section_Type__c == 'Living Standard Detail' && charList2.Living_Standard_Remarks__c != null){
                    LivingStandardRemarks = charList2.Living_Standard_Remarks__c;
                }
            }
            
            lifeStyles = '';
            for(Character__c charList2 : charObj){
                if(charList2.Section_Type__c == 'Living Standard Detail' && charList2.Lifestyle__c != null){
                    lifeStyles += charList2.Lifestyle__c;
                    //lifeStyles += ',';
                }
            }
            
            repaymentBehaviours = 'Nil';
            for(Character__c charList3 : charObj){
                if(charList3.Section_Type__c == 'Repayment Behaviour Detail' && charList3.Overall_Remarks_Highmark_Obligations__c != null){
                    repaymentBehaviours = charList3.Overall_Remarks_Highmark_Obligations__c;
                    //repaymentBehaviours += ',';
                }
            }
            //repaymentBehaviours = repaymentBehaviours.removeEnd(',');
        }
        
        List <Character__c> charList = [SELECT ID, Application__c, Neighbour_Name__c, Section_Type__c, FeedBack__c, RecordType.Name
                                        FROM Character__c
                                        WHERE Application__c =:currentApplicationId AND RecordType.Name = 'FIV-C Character'];
        
        if(charList.size() == 0){
            neighbourNamess = '';
            //   feedbacks = '';
        }
        else{
            neighbourNamess = '';
            //      feedbacks = ''; 
            for(Character__c character : charList){
                if(character.Section_Type__c == 'Neighbour Detail' && character.Neighbour_Name__c != null){
                    neighbourNamess += character.Neighbour_Name__c;
                    //      feedbacks += character.FeedBack__c;
                    //     feedbacks += ',';
                    neighbourNamess += ', ';
                }
            }
            neighbourNamess = neighbourNamess.removeEnd(', ');
            //  feedbacks = feedbacks.removeEnd(',');
        }
        
        /*      if(character.Section_Type__c == 'Neighbour Detail' && character.Neighbour_Name__c != null){
neighbourNamess += character.Neighbour_Name__c+',';
feedbacks += character.FeedBack__c+' '; 
}
neighbourNamess = neighbourNamess.removeEnd(',');
}
*/
        DateTime legalApproverDate,fivcApproverDate;
        
        Map<String,User> UserEmployeeNumberMap = new Map<String,User>([SELECT Id,EmployeeNumber FROM User]);
        List<legal_Approval__c> legalList = new List<Legal_Approval__c>([SELECT Id,LastModifiedDate FROM Legal_Approval__c WHERE Application__c =:currentApplicationId]);
        if(legalList.size()>0)
        {
            legalApproverDate = legalList[0].LastModifiedDate;
        }
        
        
        //XVI. Decision Authority details 
        for(Verification__c vrObj : [SELECT Id,LastModifiedDate, Application__c, Record_Type_Name__c, Name, Owner__c ,BM_Recommended_Amount__c, Initiate_From__c, Application__r.FIV_C_USer__r.Name,Application__r.FIV_C_USer__c,Application__r.PC_Submission_Date__c,Application__r.AC_Submission_Date__c 
                                     ,OwnerId,Owner.name FROM Verification__c where (Record_Type_Name__c='PC' OR Record_Type_Name__c='AC' OR Record_Type_Name__c = 'FIV_B' OR Record_Type_Name__c = 'FIV_C') and Owner__c != null And Application__c=:currentApplicationId])
        { 
            if(vrObj.Record_Type_Name__c == 'AC')
                decisionAuthDetailWrapObj.creditApprover = (String.isNotBlank(vrObj.Owner.Name)?(vrObj.Owner.Name+(UserEmployeeNumberMap.containsKey(vrObj.OwnerId) ?
                                                                                                                   (String.isNOtBlank(UserEmployeeNumberMap.get(vrObj.OwnerId).EmployeeNumber)?
                                                                                                                    (' / '+UserEmployeeNumberMap.get(vrObj.OwnerId).EmployeeNumber):'') :'')
                                                                                                 +(vrObj.Application__r.AC_Submission_Date__c != null ? ' / '+vrObj.Application__r.AC_Submission_Date__c.format() : '')):'');
            
            if(vrObj.Record_Type_Name__c == 'FIV_B' && vrObj.Initiate_From__c=='Pre Login')
                bmRecommendedAmount = vrObj.BM_Recommended_Amount__c; 
            if(vrObj.Record_Type_Name__c == 'FIV_C' && vrObj.Initiate_From__c=='Pre Login')
                fivcApproverDate = vrObj.LastModifiedDate; 
        }
        decisionAuthDetailWrapObj.legalApprover =(String.isNOtBlank(application.Legal_Approval_User__r.Name)?( application.Legal_Approval_User__r.Name +(UserEmployeeNumberMap.containsKey(application.Legal_Approval_User__c) ?
                                                                                                                                                         (String.isNOtBlank(UserEmployeeNumberMap.get(application.Legal_Approval_User__c).EmployeeNumber)?
                                                                                                                                                          (' / '+UserEmployeeNumberMap.get(application.Legal_Approval_User__c).EmployeeNumber):'') :'')
                                                                                                              +(legalApproverDate != null ? ' / '+legalApproverDate.date().format() : '')):'');
        
        
        decisionAuthDetailWrapObj.fieldCreditOfficer =(String.isNotBlank(application.FIV_C_USer__r.Name)?( application.FIV_C_USer__r.Name +(UserEmployeeNumberMap.containsKey(application.FIV_C_USer__c) ?
                                                                                                                                            (String.isNOtBlank(UserEmployeeNumberMap.get(application.FIV_C_USer__c).EmployeeNumber)?
                                                                                                                                             (' / '+UserEmployeeNumberMap.get(application.FIV_C_USer__c).EmployeeNumber):'') :'')
                                                                                                          +(fivcApproverDate != null ? ' / '+fivcApproverDate.date().format() : '')):'');
        
        //New Fields on Decision Authority Details
        
        decisionAuthDetailWrapObj.externalLegal = (String.isNotBlank(application.External_Lawyer__r.Name)?(application.External_Lawyer__r.Name):'');
        
        
        List<Application_User_Tracking__c> autHistory = [SELECT Id, Owner__c, Owner__r.Name ,Owner__r.Employee_Id__c FROM Application_User_Tracking__c WHERE Application__c =: currentApplicationId AND Stage__c='FIV - B'];
        String branchOwnerName = '';
        String branchOwnerEmpNUmber = '';
        if(autHistory != NULL && !autHistory.isEmpty()){
            branchOwnerName = (String.isNotBlank(autHistory.get(0).Owner__r.Name)?(autHistory.get(0).Owner__r.Name):'');
            branchOwnerEmpNUmber = (String.isNotBlank(autHistory.get(0).Owner__r.Employee_Id__c)?(autHistory.get(0).Owner__r.Employee_Id__c)+ '/':'');
            decisionAuthDetailWrapObj.bm = branchOwnerName +  + branchOwnerEmpNUmber;
        }
        
 
        List<Application__c> appList11 = [SELECT Id, Field_Officer_Emp_Id__r.Name, Field_Officer_Emp_Id__r.Employee_Id__c, Current_Deviation_Approval__r.Name, Current_Deviation_Approval__r.Employee_Id__c FROM Application__c WHERE Id =: currentApplicationId];
        for(Application__c app : appList11){
            decisionAuthDetailWrapObj.deviationApprovals = (String.isNotBlank(app.Current_Deviation_Approval__r.Name)?(app.Current_Deviation_Approval__r.Name +(String.isNotBlank(app.Current_Deviation_Approval__r.Employee_Id__c)?(' / '+app.Current_Deviation_Approval__r.Employee_Id__c):'')):'');
            decisionAuthDetailWrapObj.sourcingOfficer = (String.isNotBlank(app.Field_Officer_Emp_Id__r.Name)?(app.Field_Officer_Emp_Id__r.Name +(String.isNotBlank(app.Field_Officer_Emp_Id__r.Employee_Id__c)?(' / '+app.Field_Officer_Emp_Id__r.Employee_Id__c):'')):'');
                                               
        }
        
        
        for(Application_User_Tracking__c appUser : [Select Id, Application__c,Status__c, Stage__c,Start_Date__c,CreatedDate, Owner__r.Name,Application__r.PC_Submission_Date__c,Owner__r.EmployeeNumber,Application__r.AC_User__c,Application__r.AC_User__r.Name 
                                                    FROM Application_User_Tracking__c WHERE Application__c=:currentApplicationId AND Owner__c != null]){
                                                        if(appUser.Stage__c == 'Process Credit'){
                                                            decisionAuthDetailWrapObj.processCreditOfficer =(String.isNotBlank(appUser.Owner__r.Name)?(appUser.Owner__r.Name +(String.isNOtBlank(appUser.Owner__r.EmployeeNumber)?
                                                                                                                                                                               (' / '+appUser.Owner__r.EmployeeNumber):'')
                                                                                                                                                       +(appUser.Application__r.PC_Submission_Date__c != null ? ' / '+appUser.Application__r.PC_Submission_Date__c.format() : '')):'');
                                                            
                                                        }
                                                        if(appUser.Stage__c == 'Approval Credit' && appUser.Status__c == 'Recommended'){
                                                            decisionAuthDetailWrapObj.recommendingOfficer = (String.isNotBlank(appUser.Application__r.AC_User__c)?( appUser.Application__r.AC_User__r.Name +(UserEmployeeNumberMap.containsKey(appUser.Application__r.AC_User__c) ?
                                                                                                                                                                                                             (String.isNotBlank(UserEmployeeNumberMap.get(appUser.Application__r.AC_User__c).EmployeeNumber)?
                                                                                                                                                                                                              (' / '+UserEmployeeNumberMap.get(appUser.Application__r.AC_User__c).EmployeeNumber):'') :'')
                                                                                                                                                                   +(appUser.CreatedDate != null ? ' / '+appUser.CreatedDate.format('dd/MM/yyyy') : '')):'');
                                                            
                                                        }
                                                    }
        
        for(Application_User_Tracking__c appUser : [Select Id, Application__c, Stage__c, Owner__r.Name FROM Application_User_Tracking__c WHERE Application__c=:currentApplicationId AND Owner__c != null]){
            if(appUser.Stage__c == 'Process Credit'){
                currentUser = appUser.Owner__r.Name;
            }else if(appUser.Stage__c == 'Approval Credit'){
                currentUser =  appUser.Owner__r.Name;
            }
        }
        
        
        //Get current date time in GMT format
        Datetime dt = System.now();
        
        //Convert it into Pacific Standard Time(PST).
        String dtIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
        
        System.debug('dt-' + dt);
        
        
        //Capability
        String capabilityRecordType;
        if(generatedFrom == 'PC')
            capabilityRecordType = 'PC Capability';
        else{
            capabilityRecordType = 'AC Capability';
        }
        capabilities = [SELECT Id, Loan_Applicant__r.Customer_Type__c,Loan_Applicant__r.Customer_Type_No__c, Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Rental_income_property_address__c,Income_reference_Contact_Number__c,Proof_Remarks_Daily_Wages__c,
                        Loan_Applicant__r.Customer_Information__r.Name, Segment__c, Income_segment__c,Remarks__c,Rental_Property_Owner_name__c,Other_Confirmations_Daily_Wages__c,considered_for_DBR__c,Reference_Name__c,Reference_Name_2__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,Overall_Remarks_Regarding_Business__c,Income_reference_name__c,Income_per_month_Pension__c,Reference_Contact_Number__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,of_income_transacted_through_bank_acco__c,Spouse_alive__c,Reference_Contact_Number_2__c,BusinessPincode__r.Name,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c,FC_Enquiry_with__c,Proof_of_Ownership__c, Rental_Income__c,Margin_in_amount__c,Assumptions_for_Income__c,Business_Reference_Contact_Number_2__c,Feedback_2__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,Gross_Monthly_Income__c,Business_Reference_Name_2__c,Income_Proof_Pension__c,Year_of_Service_With_Employer__c,
                        Electricity__c, Rent__c, Others__c, Salary__c,Ownership_document_proof__c,Nature_of_Document_Proof_Self_Employed__c,Sales_per_day__c,No_of_Units__c,Name_of_the_Employer__c,Nature_of_Job__c,
                        Total_Work_Experience__c,Mode_of_Salary__c,Employment_Document_Proof__c,Nature_of_Document_Proof__c,IncomePincode__r.Name,Overall_Remarks__c,Business_name__c,Business_Nature__c,Year_of_Business__c,
                        Total_experience_in_this_business_yrs__c,Nature_of_Ownership__c,Ownership_Proof_available__c,Ownership_proof__c,regular_business_activity__c,Nature_of_Ownership_Transport__c,Nature_of_Ownership_Proof__c
                        FROM Capability__c  
                        WHERE application__c =:currentApplicationId AND recordType.Name=: capabilityRecordType Order BY Loan_Applicant__r.Customer_Type_No__c]; 
        
        totalMonthlyIncome = 0;
        netMonthlyIncome = 0;       
        incomeDetails = new List<IncomWrapper>();
        for(Capability__c cap : capabilities){
            IncomWrapper incWrapObj = new IncomWrapper();
            incWrapObj.applicantName = cap.Loan_Applicant__r.Customer_Information__r.Name;
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
            incWrapObj.incomePerMonth = ''+monthlyIncome;
            totalMonthlyIncome += monthlyIncome;
            
            incomeDetails.add(incWrapObj);
        }
        
        //XII. Income Details
        IncomeSummary incomeWrap;
        if(generatedFrom == 'PC'){
            system.debug('appidd '+currentApplicationId);
            incomeWrap= getCapabilitySummary(currentApplicationId);
        }
        else{
            incomeWrap= getacCapabilitySummary(currentApplicationId);
        }        
        
        for(IncomeWrapper incomeWrapObj : incomeWrap.incomList){
            
            IncomeDetailsWrapper wrapObj = new IncomeDetailsWrapper();
            wrapObj.name = incomeWrapObj.customerName;
            wrapObj.branchManager = incomeWrapObj.fivBIncome;
            wrapObj.fieldCredit = incomeWrapObj.fivCIncome;
            wrapObj.approvalCredit = incomeWrapObj.pcIncome;
            IncomeDetailsWrapperList.add(wrapObj);
        }
        incRwapObj = new IncomeTotalWrap();
        incRwapObj.totalFivCMonthlyIncome = incomeWrap.totalFivCMonthlyIncome;
        incRwapObj.totalPCMonthlyIncome = incomeWrap.totalPCMonthlyIncome;
        incRwapObj.totalFivBMonthlyIncome = incomeWrap.totalFivBMonthlyIncome;
        incRwapObj.allfivCObligations = incomeWrap.allfivCObligations;
        incRwapObj.allpCObligations = incomeWrap.allpCObligations;
        incRwapObj.allfivBObligations = incomeWrap.allfivBObligations;
        incRwapObj.pcnetMonthlyIncome = incomeWrap.pcnetMonthlyIncome;
        incRwapObj.fivcnetMonthlyIncome = incomeWrap.fivcnetMonthlyIncome;
        incRwapObj.fivbnetMonthlyIncome = incomeWrap.fivbnetMonthlyIncome;
        //XII. Income Details End heree
        
        Integer secNo = 0;
        totalOfLandArea =0 ;
        totalOfLandValue =0;
        grandLandValue = 0;
        totalOfBuildingArea =0;
        totalOfBuildingValue = 0;
        grandBuildingValue = 0;
        totalOfColateralValue = 0;
        
        
        String propRecordTypeName;
        // Set<String> propRecordTypeName = new Set<String>();
        if(generatedFrom == 'PC'){
            propRecordTypeName = 'PC_Property_Detail';
            //propRecordTypeName.add('PC_Property_Detail'); 
        }
        else if(generatedFrom == 'AC'){
            propRecordTypeName = 'AC_Property_Detail';
            // propRecordTypeName.addall(new List<String>{'AC_Property_Detail','Legal_Approval'});  
        }
        
        for(Property__c propObj: [Select Name, Pathway_Available__c, Overall_Remarks__c, Overall_Land_Remarks__c, Property_Surrounding__c, Title_Deed_Year__c,Total_Value__c,Building_Floor__c,
                                  Title_Deed_Number__c, Document_Type__c, Property_Address__c, Building_Constructed_with_Remarks__c,Land_Area_Sq_Ft__c,Month__c,Title_Deed_Date__c,
                                  Avg_Floor_Value_Per_Sq_Ft__c, Floor__c, Building_Type__c, Building_Age__c, Land_area_valuation_remarks__c, Final_Land_Value__c,
                                  (SELECT Id, Application__c, Object_Type__c, Length_ft__c, Area_Extent_Sq_ft__c, Value_per_Sq_ft__c, Width_ft__c, Total_Value__c, Building_Floor__c,Parent_Property__c, Property__r.Name
                                   FROM Enquiries__r Where Object_Type__c = 'Building Floors'),Boundaries_As_Per_Inspection_Are_Same__c,Pincode__r.Name,
                                  Building_Area_Sq_Ft__c,Nature_Of_Property__c, Total_Collateral_Value__c, Valuation_Market_Value_Per_SqFt__c, Type_Of_Property__c, Land_Ownership__c,
                                  Mortgage_property_Living_property_are__c, Mortgage_property_distance_from_branch__c, Person_residing_at_Mortgage_property__c, Building_Ownership__c,
                                  Living_property_Distance_from_Branch__c,Is_living_property_is_own_property__c,Living_property_Pincode__c, Landmark__c, Mortgage_Property_Remarks__c,
                                  Value_per_sq_ft__c,Boundaries_as_per_document_and_physical__c,Boundries_Remarks__c,Mortgage_Property_Area__c,Record_Type_Name__c,Total_Floor_Area__c,
                                  Total_Floor_Value__c,Remarks__c,Property__r.Name,Property_Type__c,Market_value_per_sq_ft__c
                                  From Property__c where Application__c =: currentApplicationId AND Record_Type_Name__c =: propRecordTypeName ]) {
                                      PropertyWrapper wrapObj = new PropertyWrapper();
                                      secNo++;
                                      wrapObj.secNo =  secNo;
                                      
                                      //1.1 Collateral Details
                                      wrapObj.name = propObj.Property__r.Name;
                                      wrapObj.recordType = propObj.Record_Type_Name__c;
                                      wrapObj.pathwayisavailable = propObj.Pathway_Available__c;
                                      wrapObj.overallRemarks = propObj.Overall_Remarks__c;
                                      wrapObj.Surroundingareaofcollateral = propObj.Property_Surrounding__c;
                                      wrapObj.natureOfProp = propObj.Nature_Of_Property__c;
                                      wrapObj.typeofproperty= propObj.Property_Type__c;
                                      wrapObj.buildingownership = 'Not yet decided';
                                      wrapObj.landownership = 'Not yet decided';
                                      wrapObj.titleDocumentYear = propObj.Title_Deed_Year__c;
                                      wrapObj.titleDocumentDate = propObj.Title_Deed_Date__c;
                                      wrapObj.titleDocumentNumber = propObj.Title_Deed_Number__c;
                                      wrapObj.documentType = propObj.Document_Type__c;
                                      wrapObj.collateralAddress = propObj.Property_Address__c;
                                      wrapObj.collateralId = propObj.Name;
                                      wrapObj.month = propObj.Month__c;
                                      wrapObj.mortgagePropLiving = propObj.Mortgage_property_Living_property_are__c;
                                      if(propObj.Mortgage_property_Living_property_are__c == 'No'){
                                          wrapObj.mortgagePropLiving = propObj.Mortgage_property_Living_property_are__c;
                                          wrapObj.typeOfPerson = propObj.Person_residing_at_Mortgage_property__c;
                                          wrapObj.livingPropDistance = propObj.Living_property_Distance_from_Branch__c;
                                          wrapObj.isLivingPropOwn = propObj.Is_living_property_is_own_property__c;
                                          wrapObj.livingPropPincode = propObj.Pincode__r.Name;				
                                      }
                                      else if(propObj.Mortgage_property_Living_property_are__c == 'Yes'){
                                          wrapObj.mortgagePropLiving = propObj.Mortgage_property_Living_property_are__c;
                                          wrapObj.typeOfPerson ='';
                                          wrapObj.livingPropDistance =null;
                                          wrapObj.isLivingPropOwn ='';
                                          wrapObj.livingPropPincode ='';				
                                      }
                                      wrapObj.mortgagePropDistance = propObj.Mortgage_property_distance_from_branch__c;
                                      wrapObj.landmark = propObj.Landmark__c;
                                      
                                      //1.2Collateral Details
                                      wrapObj.remarks  = propObj.Overall_Land_Remarks__c;
                                      wrapObj.landvalue = propObj.Final_Land_Value__c;
                                      wrapObj.forcedvaluepersqft = propObj.Valuation_Market_Value_Per_SqFt__c;
                                      wrapObj.marketvaluepersqft = propObj.Market_value_per_sq_ft__c;
                                      wrapObj.landareaasperCredit = propObj.Land_Area_Sq_Ft__c;
                                      wrapObj.boundariesAsPer = propObj.Boundaries_As_Per_Inspection_Are_Same__c;
                                      if(propObj.Boundaries_As_Per_Inspection_Are_Same__c == 'No'){
                                          wrapObj.boundariesAsPer = propObj.Boundaries_As_Per_Inspection_Are_Same__c;
                                          wrapObj.boundariesRemarks = propObj.Boundries_Remarks__c;                                    
                                      }else if(propObj.Boundaries_As_Per_Inspection_Are_Same__c == 'Yes'){
                                          wrapObj.boundariesAsPer = propObj.Boundaries_As_Per_Inspection_Are_Same__c;
                                          wrapObj.boundariesRemarks = propObj.Boundries_Remarks__c;                                    
                                      }
                                      if(propObj.Pathway_Available__c == 'No'){
                                          wrapObj.pathwayisavailable = propObj.Pathway_Available__c;
                                          wrapObj.pathwayRemarks = propObj.Remarks__c;                                    
                                      }else if(propObj.Pathway_Available__c == 'Yes'){
                                          wrapObj.pathwayisavailable = propObj.Pathway_Available__c;
                                          wrapObj.pathwayRemarks = '';                                    
                                      }
                                      wrapObj.mortgageRemarks = propObj.Mortgage_Property_Remarks__c;
                                      wrapObj.landAreaRemarks = propObj.Land_area_valuation_remarks__c;
                                      wrapObj.mortgagePropArea = propObj.Mortgage_Property_Area__c;
                                      wrapObj.landAreaToBeConsi = propObj.Land_Area_Sq_Ft__c;
                                      //Floor Details
                                      List<FloorWrapper> floorList = new List<FloorWrapper>();
                                      if(propObj.Enquiries__r.size() > 0){                                          
                                          for(CommonObject__c comObj : propObj.Enquiries__r){                                            
                                              FloorWrapper floorWrap = new FloorWrapper();
                                              floorWrap.length = comObj.Length_ft__c;
                                              floorWrap.width = comObj.Width_ft__c;  
                                              floorWrap.totalValue = comObj.Total_Value__c;
                                              floorWrap.areaExtent = comObj.Area_Extent_Sq_ft__c;
                                              floorWrap.floors = comObj.Building_Floor__c;
                                              floorWrap.valueExtent = comObj.Value_per_Sq_ft__c;
                                              //floorwrap.propName = propName;
                                              floorList.add(floorWrap);                                          
                                          }}                                       
                                      // Boolean MorethanOne = false;
                                      if(propObj.Enquiries__r != null && propObj.Enquiries__r.size() > 1){
                                          wrapObj.moreThanOne = true;
                                      }
                                      
                                      wrapObj.buildingFloorList = floorList;
                                      wrapObj.totalFloorArea = propObj.Total_Floor_Area__c;
                                      wrapObj.totalFloorValue = propObj.Total_Floor_Value__c;
                                      
                                      //1.3 Building Area and Valuation
                                      wrapObj.buildingOverallRemarks = propObj.Building_Constructed_with_Remarks__c;
                                      wrapObj.totalValueList = propObj.Total_Value__c;
                                      wrapObj.valuePerSqFtList = propObj.Avg_Floor_Value_Per_Sq_Ft__c;
                                      wrapObj.areaList = propObj.Total_Floor_Area__c;
                                      wrapObj.floorList = propObj.Building_Floor__c;
                                      wrapObj.buildingtype = propObj.Building_Type__c;
                                      wrapObj.ageofthebuilding = propObj.Building_Age__c;
                                      
                                      //1.4 Collateral Summary
                                      wrapObj.particulars = propObj.Property__r.Name;
                                      // wrapObj.totalBuildingValue = propObj.Name;
                                      wrapObj.totalCollateralValue = propObj.Final_Land_Value__c + (propObj.Total_Floor_Value__c != NULL ? propObj.Total_Floor_Value__c : 0);
                                      //if(MoreThanOne)
                                      // wrapObj.buildingvalue = null;
                                      // if(propObj.Avg_Floor_Value_Per_Sq_Ft__c!= null)
                                      wrapObj.buildingvalue = propObj.Avg_Floor_Value_Per_Sq_Ft__c;
                                      wrapObj.buildingArea = propObj.Total_Floor_Area__c;
                                      wrapObj.finalBuildingValue = propObj.Total_Floor_Value__c != NULL ? propObj.Total_Floor_Value__c : 0;
                                      wrapObj.finalLandValue = propObj.Final_Land_Value__c;
                                      wrapObj.landValue2 = propObj.Valuation_Market_Value_Per_SqFt__c;
                                      wrapObj.landArea = propObj.Land_Area_Sq_Ft__c;
                                      wrapObj.landOwnership = propObj.Land_Ownership__c;
                                      wrapObj.buldingOwnership = propObj.Building_Ownership__c;
                                      
                                      lanownershipss +=propObj.Land_Ownership__c+', ';
                                      
                                      if(propObj.Land_Area_Sq_Ft__c != Null)
                                          totalOfLandArea += propObj.Land_Area_Sq_Ft__c;
                                      if(propObj.Valuation_Market_Value_Per_SqFt__c != Null)
                                          totalOfLandValue += propObj.Valuation_Market_Value_Per_SqFt__c;
                                      if(propObj.Final_Land_Value__c != null)
                                          grandLandValue += propObj.Final_Land_Value__c;
                                      if(propObj.Total_Floor_Area__c != null)
                                          totalOfBuildingArea += propObj.Total_Floor_Area__c;
                                      //if(MoreThanOne)
                                      //   totalOfBuildingValue = null;
                                      if(propObj.Avg_Floor_Value_Per_Sq_Ft__c!= null)
                                          totalOfBuildingValue += propObj.Avg_Floor_Value_Per_Sq_Ft__c;
                                      if(propObj.Total_Floor_Value__c!= null)
                                          grandBuildingValue += propObj.Total_Floor_Value__c;
                                      if(propObj.Final_Land_Value__c != null || propObj.Total_Floor_Value__c != Null)
                                          totalOfColateralValue += (propObj.Final_Land_Value__c + (propObj.Total_Floor_Value__c != NULL ? propObj.Total_Floor_Value__c : 0));
                                      PropertyWrapperList.add(wrapObj);
                                  }
        lanownershipss = lanownershipss.removeEnd(',');
        natureOfPropertyObj = CAMReportVfController.getNatureofProperty(currentApplicationId,propRecordTypeName);
        system.debug('natur+++' + natureOfPropertyObj);
        
        //1.4 Collateral Summary
        TotalSumCollateral totalWrap = new TotalSumCollateral();
        totalWrap.totalOfLandArea = totalOfLandArea;
        totalWrap.totalOfLandValue = totalOfLandValue;
        totalWrap.grandLandValue = grandLandValue;        
        totalWrap.totalOfBuildingArea = totalOfBuildingArea;
        totalWrap.totalOfBuildingValue = totalOfBuildingValue;
        totalWrap.grandBuildingValue = grandBuildingValue;
        totalWrap.totalOfColateralValue = totalOfColateralValue;
        
        //Legal Justification
        Integer srNum = 0;
        for(Property__c propObj : [SELECT 
                                   Id, Is_Legal_Updated__c, Title_Document_in_Name_of__c, Title_Deed_Number__c,Property__r.Name,
                                   Title_Deed_Date__c, Document_Type__c, Survey_Number__c, Plot_No__c, Property__c,
                                   House_Door_No__c, Village__c, District__c, MS_Pincode__c, Extent_Sqft__c,
                                   Supporting_Document_SD__c, SD_in_name_of__c, SD_Date__c, Link_Doc_Status__c,
                                   Link_Document_Type__c, Link_Doc_Date__c, Link_Documents_in_Name_of__c, Login_EC_Type__c,
                                   Login_EC_Number__c, Login_EC_Date_From__c, Login_EC_Date_Till__c, Online_EC_Status__c,Remarks_In_Encumberance__c,
                                   Online_EC_Date_From__c, Online_EC_Date_Till__c, GuidelineValue_SqFt_asPer_LegalOpinion__c,Title_Document_date__c,
                                   Online_Guideline_Value_Search__c, Online_Guidelive_Value__c, Existing_Encumberances__c,Application__c
                                   FROM Property__c 
                                   WHERE Application__c =: currentapplicationId 
                                   AND RecordType.Name = 'Legal Approval']){
                                       legalPropertyWrapper wrapObj = new legalPropertyWrapper();
                                       srNum++;
                                       wrapObj.propName = propObj.Property__r.Name;
                                       wrapObj.secNum = srNum;
                                       wrapObj.titleDocumentName = propObj.Title_Document_in_Name_of__c;
                                       wrapObj.titleDocumentNumber = propObj.Title_Deed_Number__c;
                                       wrapObj.titleDocumentDate = propObj.Title_Deed_Date__c;
                                       wrapObj.titleDocumentType = propObj.Document_Type__c;
                                       wrapObj.surveyNo = propObj.Survey_Number__c;
                                       wrapObj.extent = propObj.Extent_Sqft__c;
                                       wrapObj.linkDocStatus = propObj.Link_Doc_Status__c;
                                       wrapObj.linkDocTypes = propObj.Link_Document_Type__c;
                                       wrapObj.linkDocumentDate = propObj.Link_Doc_Date__c;
                                       wrapObj.linkDocumentInNameOf = propObj.Link_Documents_in_Name_of__c;
                                       wrapObj.onlineGuideline = propObj.Online_Guidelive_Value__c;
                                       wrapObj.existingEmcumb = propObj.Existing_Encumberances__c;
                                       wrapObj.loginEcType = propObj.Login_EC_Type__c;
                                       wrapObj.loginEcNumber = propObj.Login_EC_Number__c;
                                       wrapObj.loginEcDateFrom = propObj.Login_EC_Date_From__c;
                                       wrapObj.loginEcDateTill = propObj.Login_EC_Date_Till__c;
                                       wrapObj.onlineEcStatus = propObj.Online_EC_Status__c;
                                       wrapObj.onlineEcDateFrom = propObj.Online_EC_Date_From__c;
                                       wrapObj.onlineEcDateTill = propObj.Online_EC_Date_Till__c;
                                       wrapObj.guidelineAsPerLegalOpinion = propObj.GuidelineValue_SqFt_asPer_LegalOpinion__c;
                                       wrapObj.onlineGuidelineValueSearch = propObj.Online_Guideline_Value_Search__c;
                                       if(propObj.Existing_Encumberances__c == 'Yes'){
                                           wrapObj.existingEmcumb = propObj.Existing_Encumberances__c;
                                           wrapObj.existingEmcumbRemarks = propObj.Remarks_In_Encumberance__c;
                                       }else if(propObj.Existing_Encumberances__c == 'No'){
                                           wrapObj.existingEmcumb = propObj.Existing_Encumberances__c;
                                           wrapObj.existingEmcumbRemarks = '';
                                       }
                                       wrapObj.loginEcType = propObj.Login_EC_Type__c;
                                       legalPropertyWrapperList.add(wrapOBj);
                                   }
        
        //---------------------------------------------------------------------------------------------------------------------------------------------------------------//
        for(Application__c app : [SELECT 
                                  Id,Name,Sourcing_Branch__r.Name,File_Type__c,MODT_Template__c,MODT_to_be_done_in_name_of__c,Old_Loan_Sanction_Date__c,Old_MODT_Document_No__c,
                                  Old_Loan_Amount__c,Old_Mortgage_Date__c,Registration_District__c,SRO_Office__c,MODT_Schedule__c,Sanction_Amount_Restriction__c,File_Category__c,
                                  Risk_Document_Color__c,User_ID__c,Legal_Decision__c,Legal_Sanction_Condition__c,Sub_Stage__c,Sanction_amount_restriction_upto__c,Any_Approval_to_be_Obtained__c,Legal_Summary_Remarks__c
                                  FROM Application__c 
                                  WHERE Id =: currentapplicationId]){
                                      legalModtSummaryWrapper wrapObj = new legalModtSummaryWrapper();
                                      wrapObj.fileType = app.File_Type__c;
                                      wrapObj.modtTemplate = app.MODT_Template__c;
                                      wrapObj.modtInNameOF = app.MODT_to_be_done_in_name_of__c;
                                      wrapObj.registDist = app.Registration_District__c;
                                      wrapObj.sroOffice = app.SRO_Office__c;
                                      wrapObj.modtSchedule = app.MODT_Schedule__c;
                                      wrapObj.oldLoanSanctDate = app.Old_Loan_Sanction_Date__c;
                                      wrapObj.oldModtDocNo = app.Old_MODT_Document_No__c;
                                      wrapObj.oldLoanAmnt = app.Old_Loan_Amount__c;
                                      wrapObj.oldMortgageDate = app.Old_Mortgage_Date__c;
                                      wrapObj.sancAmountRest = app.Sanction_Amount_Restriction__c;
                                      wrapObj.sancAmountRestUpto = app.Sanction_amount_restriction_upto__c;
                                      wrapObj.fileCategory = app.File_Category__c;
                                      wrapObj.riskDocColor = app.Risk_Document_Color__c;
                                      wrapObj.legalDecision = app.Legal_Decision__c;
                                      wrapObj.legalSancCondition = app.Legal_Sanction_Condition__c;
                                      wrapObj.anyApproval = app.Any_Approval_to_be_Obtained__c;
                                      wrapObj.legalRemarks = app.Legal_Summary_Remarks__c;
                                      legalModtSummaryWrapperList.add(wrapObj);
                                  }
        
        
    }  
    @AuraEnabled 
    public static void generateCamReport(String currentApplicationId, String stage){
        PageReference pdf = Page.CAMReportVf;
        pdf.getParameters().put('id',currentApplicationId);
        Blob body;
        
        if(Test.isRunningTest()) { 
            body = blob.valueOf('Unit.Test');
        } else {
            body = pdf.getContentAsPDF();
        }    
        ContentVersion cv = new ContentVersion(File_Type__c='CAM Report', PathOnClient ='CAM Report.PDF', VersionData = body, FirstPublishLocationId = currentApplicationId,Is_Additional_Document__c=true,Uploaded_From__c = stage);
        if(stage == 'Process Credit'){
            cv.Title = 'PC CAM Report';
        }
        else if(stage == 'Approval Credit'){
            cv.Title = 'AC CAM Report';
        }
        insert cv;
    }
    
    ///// CH02 ::: Added By Ajay Kumar to check if CAM Report has been created for the particular stage... 
    ///// CH02 ::: Date :- 09/01/2023
    @auraEnabled
    public static Boolean checkCAMExistence(String applicationId, String stageName){
        Boolean camExist = false;
        String cvTitle = stageName + ' CAM Report';
        List<ContentVersion> cvList = new List<ContentVersion>([SELECT Id FROM ContentVersion WHERE File_Type__c='CAM Report' AND Title =:cvTitle AND  FirstPublishLocationId = :applicationId ORDER BY CREATEDDATE DESC LIMIT 1]);
        if(cvList != null && cvList.size()>0)
            camExist = true;
        
        return camExist;
    }
    
    
    public static natureofPropertyWrapper getNatureofProperty(String appId,String RecordTypename){
        system.debug('appId====>' + appId);
        system.debug('rect====>' + RecordTypename);
        decimal collateralValue= 0;
        String tempropId;
        Map<String,Decimal> collateralValueMap = new Map<String,Decimal>();
        Map<String,String> natureofPropertyMap = new Map<String,String>();
        natureofPropertyWrapper wrapObj = new natureofPropertyWrapper();
        for(Property__c proObj : [SELECT Id,Name,Nature_Of_Property__c,Total_Floor_Value__c,Final_Land_Value__c FROM Property__c WHERE Application__c=: appId AND RecordType.DeveloperName =: RecordTypename]){   
            if(proObj.Nature_Of_Property__c != null){
                natureofPropertyMap.put(proObj.Id, proObj.Nature_Of_Property__c);
            }   
            decimal tempcollateralValue = (proObj.Total_Floor_Value__c != null ? proObj.Total_Floor_Value__c : 0) + (proObj.Final_Land_Value__c != null ? proObj.Final_Land_Value__c : 0);
            collateralValueMap.put(proObj.Id,tempcollateralValue);
            if(tempcollateralValue > collateralValue){
                collateralValue = tempcollateralValue;
                wrapObj.propId = proObj.Id;
            }
        }
        system.debug('colMap###' + collateralValueMap);
        system.debug('natureofprop###' + natureofPropertyMap);
        Set<Decimal> tempSet = new Set<Decimal>();
        if(collateralValueMap.size()>=1){
            tempSet.addAll(collateralValueMap.values());
        }
        if(!tempSet.isEmpty() && tempSet.size()== 1){
            if(natureofPropertyMap.values().contains('Residential'))
                wrapObj.natureofProperty = 'Residential';
            else  if(natureofPropertyMap.values().contains('Commercial'))
                wrapObj.natureofProperty = 'Commercial';
            else  if(natureofPropertyMap.values().contains('Vacant Land'))
                wrapObj.natureofProperty = 'Vacant Land';
        }
        else  if(!tempSet.isEmpty() && tempSet.size() > 1){
            wrapObj.natureofProperty = natureofPropertyMap.get(wrapObj.propId);
        }  
        system.debug('nature###' + wrapObj); 
        return wrapObj;
    }
    
    public class ApplicantWrapper{
        public String applicantName{get;set;}
        public String applicantMobile{get;set;}
        public String applicantType{get;set;}
        public Decimal applicantAge{get;set;}
        public Integer applicantAgeOnMaturity{get;set;}
        public String highmark{get;set;}
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
    
    public Class existingLoanDetailWrapper{
        public String existingLoanAccNo{get;set;}
        public String appName{get;set;}
        public String applicantName{get;set;}
        public String branch{get;set;}
        public Decimal loanAmount{get;set;}
        public Decimal emi{get;set;}
        public Decimal principalOS{get;set;}
        public String dpd{get;set;}
        public String considerFor{get;set;}
        public String remarks{get;set;}
        public Decimal oldCollateralValue{get;set;}
        public Decimal oldLoanNetIncome{get;set;}
        public Decimal oldLoanGrossIncome{get;set;}
        public String oldLoanObligations{get;set;}
        public Decimal lienMarked{get;set;}
        public Decimal LTV{get;set;}
        public Decimal DBR{get;set;}
    } 
    public Class existingCollateralDetailWrapper{
        public Integer SrNoo{get;set;}
        public String collateralId{get;set;}
        public String loanId{get;set;}
        public String collateralAddress{get;set;} 
    }
    public Class characterWrapper{
        public String neighbourNames {get;set;}
        public String feedback {get;set;}
        public String affilationRemarks {get;set;}
        public String lifeStyle {get;set;}
        public String repaymentBehaviour {get;set;}
    }
    
    public Class IncomeDetailsWrapper{
        public String name {get;set;}
        public Decimal branchManager {get;set;}
        public Decimal fieldCredit {get;set;}
        public Decimal approvalCredit {get;set;}
        
    }
    public Class IncomeTotalWrap{
        public Decimal totalFivCMonthlyIncome{get;set;}
        public Decimal totalPCMonthlyIncome{get;set;}
        public Decimal totalFivBMonthlyIncome{get;set;}
        public Decimal allfivCObligations{get;set;}
        public Decimal allpCObligations{get;set;}
        public Decimal allfivBObligations{get;set;}
        public Decimal pcnetMonthlyIncome{get;set;}
        public Decimal fivcnetMonthlyIncome{get;set;}
        public Decimal fivbnetMonthlyIncome{get;set;}
    }
    
    public Class deviationwrapper{
        public String category{get;set;}
        public String natureofDeviation{get;set;}
        public String status{get;set;}
        public String approvedBy{get;set;}
        public String dateOfApproval{get;set;}
        public String mitigantsRemarks{get;set;}
        public String approvalLevel{get;set;}
        public deviationwrapper()
        {
            approvedBy = '';
        }
    }
    public Class InsuranceDetailsWrapper{
        public Integer count{get;set;}
        public String insuranceName{get;set;}
        public String insuranceAgency{get;set;}
        public String applicableFor{get;set;}
        public Decimal premiunAmount{get;set;}
        public Decimal taxAmount{get;set;}
        public Decimal finalAmount{get;set;}
        public Decimal sumAssured{get;set;}
        public String mode{get;set;}
    }
    public Class PropertyWrapper{ 
        public String name{get;set;}
        public Decimal secNo{get;set;}
        public String recordType{get;set;} 
        //1.1 Collateral Details
        public String collateralId{get;set;}
        public String collateralAddress{get;set;}
        public String documentType{get;set;}
        public String titleDocumentNumber{get;set;}
        public String titleDocumentYear{get;set;}
        public Date titleDocumentDate{get;set;}
        public String landownership {get;set;}
        public String buildingownership{get;set;}
        public String typeofproperty{get;set;}
        public String Surroundingareaofcollateral{get;set;}
        public String overallRemarks {get;set;}
        public String buldingOwnership{get;set;}
        public String month{get;set;}
        public String natureOfprop{get;set;}
        public String typeOfPerson{get;set;}
        public String mortgagePropLiving{get;set;}
        public Decimal mortgagePropDistance{get;set;}
        public Decimal livingPropDistance{get;set;}
        public String isLivingPropOwn{get;set;}
        public String livingPropPincode{get;set;}
        public String landmark{get;set;}
        
        //1.2Collateral Details
        public Decimal landareaasperCredit {get;set;}
        public Decimal forcedvaluepersqft {get;set;}
        public Decimal marketvaluepersqft {get;set;}
        public Decimal landvalue {get;set;}
        public String pathwayisavailable{get;set;}
        public String pathwayRemarks{get;set;}
        public String remarks {get;set;}
        public String boundariesAsPer{get;set;}
        public String boundariesRemarks{get;set;}
        public String mortgageRemarks{get;set;}
        public String landAreaRemarks {get;set;}
        public String mortgagePropArea{get;set;}
        public Decimal landAreaToBeConsi{get;set;}
        
        //1.3 Building Area and Valuation
        public Decimal ageofthebuilding  {get;set;}
        public String buildingtype {get;set;}
        public String floorList {get;set;}
        public Decimal areaList {get;set;}
        public Decimal valuePerSqFtList {get;set;}
        public Decimal totalValueList {get;set;}
        public Decimal totalFloorArea {get;set;}
        public Decimal totalFloorValue {get;set;}
        public String buildingOverallRemarks{get;set;}        
        public List<FloorWrapper> buildingFloorList{get;set;}
        public Boolean moreThanOne{get;set;} 
        
        //1.4 Collateral Summary
        public String particulars{get;set;}
        public Decimal landArea{get;set;}
        public Decimal landValue2{get;set;}
        public Decimal finalLandValue{get;set;}
        public Decimal buildingArea{get;set;}
        public Decimal buildingvalue{get;set;}
        public Decimal finalBuildingValue{get;set;}
        public Decimal totalCollateralValue{get;set;}
        public Decimal totalBuildingValue{get;set;}
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
    
    public Class legalPropertyWrapper{
        public String propName{get;set;}
        public Integer secNum{get;set;}
        public String titleDocumentName{get;set;}
        public String titleDocumentType{get;set;}
        public String titleDocumentNumber{get;set;}
        public Date titleDocumentDate{get;set;}
        public String surveyNo{get;set;}
        public Decimal extent{get;set;}
        public String linkDocStatus{get;set;}
        public String linkDocTypes{get;set;}
        public Date linkDocumentDate{get;set;}
        public String linkDocumentInNameOf{get;set;}
        public String onlineGuideline{get;set;}
        public String existingEmcumb{get;set;}
        public String loginEcType{get;set;}
        public String loginEcNumber{get;set;}
        public Date loginEcDateFrom{get;set;}
        public Date loginEcDateTill{get;set;}
        public String onlineEcStatus{get;set;}
        public Date onlineEcDateFrom{get;set;}
        public Date onlineEcDateTill{get;set;}
        public String guidelineAsPerLegalOpinion{get;set;}
        public String onlineGuidelineValueSearch{get;set;}
        public String existingEmcumbRemarks{get;set;}
    }
    
    public Class legalModtSummaryWrapper{
        public String fileType{get;set;}
        public String modtTemplate{get;set;}
        public String modtInNameOF{get;set;}
        public String registDist{get;set;}
        public String sroOffice{get;set;}
        public String modtSchedule{get;set;}
        public Date oldLoanSanctDate{get;set;}
        public String oldModtDocNo{get;set;}
        public String oldLoanAmnt{get;set;}
        public Date oldMortgageDate{get;set;}
        public String sancAmountRest{get;set;}
        public Decimal sancAmountRestUpto{get;set;}
        public String fileCategory{get;set;}
        public String riskDocColor{get;set;}
        public String legalDecision{get;set;}
        public String legalSancCondition{get;set;}
        public String anyApproval{get;set;}
        public String legalRemarks{get;set;}
    }
    
    public Class TotalSumCollateral{
        public Decimal totalOfLandArea{get;set;}
        public Decimal totalOfLandValue{get;set;}
        public Decimal grandLandValue{get;set;}
        public Decimal totalOfBuildingArea{get;set;}
        public Decimal totalOfBuildingValue{get;set;}
        public Decimal grandBuildingValue{get;set;}
        public Decimal totalOfColateralValue{get;set;}
        
    }
    
    public Class SpecialConditionWrapper{
        public Integer srNo{get;set;}
        public String specialCondCode {get;set;}
        public String specialCondDescription {get;set;}
        public String raisedBy {get;set;}
        public String raisedDate {get;set;}
        public String sanctionCondition{get;set;}
        public String printInSanction{get;set;}
    }
    
    public Class DecisionAuthoritydetailsWrapper {
        public String creditApprover {get;set;}
        public String recommendingOfficer {get;set;}
        public String processCreditOfficer {get;set;}
        public String fieldCreditOfficer {get;set;}
        public String legalApprover {get;set;}
        public String sourcingOfficer {get;set;}
        public String bm {get;set;}
        public String externalLegal {get;set;}
        public String deviationApprovals {get;set;}
    }
    
    public Class sendBackWrapper{
        public String decision{get;set;}
        public String decisionRemarks{get;set;}
        public String stage{get;set;}
        public String amountSanction{get;set;}
        public String interestRate{get;set;}
        public String emi{get;set;}
        public String tenor{get;set;}
        public String decisionOwner{get;set;}
        public String submissionDate{get;set;}
    }
    
    public class IncomWrapper{
        public String applicantName{get;set;}
        public String incomePerMonth{get;set;}
        
        public IncomWrapper(){
            applicantName = '';
            incomePerMonth = '';
        }
    } 
    public class natureofPropertyWrapper{
        public string propId{get;set;}
        public string natureofProperty{get;set;}
        
        public natureofPropertyWrapper(){
            propId = '';
            natureofProperty = '';
        }
    }
    
    // to get the Capability Summary Table for PC 
    public static IncomeSummary getCapabilitySummary(String applicationId)
    {
        Decimal fivCObligations = 0,pcObligations = 0;
        Set<String> bureauHighmarkIdSet = new Set<String>();
        for(Bureau_Highmark__c highmarkRecord : [SELECT Id,Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__c IN (SELECT Id FROM Loan_Applicant__c WHERE Application__c =:applicationId)]) {
            bureauHighmarkIdSet.add(highmarkRecord.Id);
        }
        String loanDetailRecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        for(Loan_details__c loanObj:[SELECT Id,Obligations__c,To_be_considerd_for_DBR__c,Stage__c FROM Loan_Details__c WHERE Bureau_Highmark__c IN:bureauHighmarkIdSet AND RecordTypeId =:loanDetailRecordTypeId ])
        {
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='FIV - C'))
            {
                system.debug('inside fivc');
                fivCObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0); 
            }
            
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='PC'))
            {
                system.debug('inside pc');
                pcObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0);
            }
        }
        system.debug('pc obligation:'+pcObligations);
        system.debug('fivc obligation:'+fivCObligations);
        List<Id> verificationIds = new List<Id>();
        for(Verification__c verObj:[SELECT Id FROM Verification__c WHERE Application__c =:applicationId AND RecordType.Name IN('FIV - C','PC')])
        {
            verificationIds.add(verObj.Id);
        }
        IncomeSummary incomeObj = new IncomeSummary();
        String rcId1 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('PC Capability').getRecordTypeId();
        String rcId2 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        List<String> rcIds = new List<String>{rcId1, rcId2};
            
            
            Decimal totalfivbIncome = 0,allfivBOBligations =0;
        Map<Id,String> loanApplicationId = new Map<Id,String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =: applicationId]){
            
            loanApplicationId.put(loanApplicant.Id,loanApplicant.Customer_Information__r.Name);
        }       
        
        List<Capability__c> capabilities = new List<Capability__c>();
        capabilities = [SELECT Id, Customer_Information__c, Income_segment__c,Loan_Applicant__r.Income_Considered__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
                        Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
                        Electricity__c, Rent__c, Others__c, Salary__c,RecordType.Name,Income_per_month_Pension__c
                        FROM Capability__c 
                        WHERE Verification__c IN: verificationIds AND RecordTypeId IN: rcIds Order BY Loan_Applicant__r.Customer_Information__r.Name];
        
        system.debug('capab list+'+capabilities);
        ////////
        Map<String,Map<String,Decimal>> incomeMap = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> segmentMap = new Map<String,Map<String,Decimal>>();
        decimal totalpcIncome = 0;
        decimal totalfivcIncome =0;
        decimal totalpcbusinessmonthlyincome = 0;
        decimal totalpcIncomeConsidered = 0;
        for(Capability__c cap : capabilities){
            Decimal busmonthlyIncome = 0;
            Decimal monthlyIncome = 0;
            Decimal monthlyIncomeConsidered = 0;
            if(cap.Income_segment__c == 'Salaried'){
                cap.Monthly_Salary__c = cap.Monthly_Salary__c != null ? cap.Monthly_Salary__c : 0;
                monthlyIncome = Integer.valueOf(cap.Monthly_Salary__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Rental Income'){
                cap.Rental_Income__c = cap.Rental_Income__c != null ? cap.Rental_Income__c : 0;
                monthlyIncome = Integer.valueOf(cap.Rental_Income__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Daily wages' || cap.Income_segment__c == 'Transport business'){
                cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
                if(cap.Income_segment__c == 'Transport business')
                    busmonthlyIncome = monthlyIncome;
                
            } else if( cap.Income_segment__c == 'Income from Abroad' ){
                cap.Income_per_month__c = cap.Income_per_month__c != null ? cap.Income_per_month__c : 0;
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            }else if(cap.Income_segment__c == 'Pension'  ){
                monthlyIncome = cap.Income_per_month_Pension__c != null ? Integer.valueOf(cap.Income_per_month_Pension__c) : 0;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            }
            else if(cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                    cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                    cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                    cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed'){
                        if(cap.Day_Margin_Basis__c == 'Day Basis'){
                            cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                            cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                            monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                            if(cap.RecordType.Name == 'PC Capability')
                                busmonthlyIncome = monthlyIncome;
                            if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                monthlyIncomeConsidered = monthlyIncome;
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
                            if(cap.RecordType.Name == 'PC Capability')
                                busmonthlyIncome = monthlyIncome;
                            if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                monthlyIncomeConsidered = monthlyIncome;
                        }
                    } 
            
            totalpcbusinessmonthlyincome += busmonthlyIncome;
            
            
            
            if(!incomeMap.containsKey(cap.Loan_Applicant__c)){    
                if(cap.RecordType.Name == 'FIV-C Capability'){ 
                    incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
                    totalfivcIncome+=monthlyIncome;
                    
                }else  if(cap.RecordType.Name == 'PC Capability'){   
                    incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'PC Income'=>monthlyIncome});
                    totalpcIncome+=monthlyIncome;
                    if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                        totalpcIncomeConsidered += monthlyIncomeConsidered;                                        
                }
            }
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('FIV-C Income'))
                    {    tempMap.put('FIV-C Income',tempMap.get('FIV-C Income')+monthlyIncome);
                     totalfivcIncome+=monthlyIncome;}
                    else
                    {  tempMap.put('FIV-C Income',monthlyIncome);
                     totalfivcIncome+=monthlyIncome;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap); 
                }
                else  if(cap.RecordType.Name == 'PC Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('PC Income'))
                    {   tempMap.put('PC Income',tempMap.get('PC Income')+monthlyIncome);
                     totalpcIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalpcIncomeConsidered += monthlyIncomeConsidered;
                    }else
                    {   tempMap.put('PC Income',monthlyIncome);
                     
                     totalpcIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalpcIncomeConsidered += monthlyIncomeConsidered;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap);
                }}
            
            if(!segmentMap.containsKey(cap.Income_segment__c))
            {    if(cap.RecordType.Name == 'FIV-C Capability')
                segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
             else if(cap.RecordType.Name == 'PC Capability')
                 segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'PC Income'=>monthlyIncome});}
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {     
                    Map<String , Decimal> SegMap= segmentMap.get(cap.Income_segment__c);
                    if(SegMap.containsKey('FIV-C Income'))
                        SegMap.put('FIV-C Income',SegMap.get('FIV-C Income')+monthlyIncome);
                    else
                        SegMap.put('FIV-C Income',monthlyIncome);
                    segmentMap.put(cap.Income_segment__c,SegMap);             }
                else if(cap.RecordType.Name == 'PC Capability')
                {   Map<String , Decimal> tempMap= segmentMap.get(cap.Income_segment__c);
                 if(tempMap.containsKey('PC Income'))
                     tempMap.put('PC Income',tempMap.get('PC Income')+monthlyIncome);
                 else
                     tempMap.put('PC Income',monthlyIncome);
                 segmentMap.put(cap.Income_segment__c,tempMap);    }}
        }
        
        for(Cashflow__C cashflowObj :[SELECT ID ,Loan_Applicant__c,Gross_Income__c,Obligations__c,Net_Income__c FROM Cashflow__C WHERE Loan_Applicant__c IN :loanApplicationId.keySet()])
        {
            if(!incomeMap.containsKey(cashflowObj.Loan_Applicant__c))
            {
                incomeMap.put(cashflowObj.Loan_Applicant__c,new Map<String,Decimal>{'FIV-B Income'=>cashflowObj.Gross_Income__c});
                totalfivbIncome += cashflowObj.Gross_Income__c;
                allfivBOBligations += cashflowObj.Obligations__c;
            }
            else
            {
                Map<String , Decimal> tempMap= incomeMap.get(cashflowObj.Loan_Applicant__c);
                if(tempMap.containsKey('FIV-B Income') && cashflowObj.Gross_Income__c != null)
                {   
                    tempMap.put('FIV-B Income',tempMap.get('FIV-B Income')+cashflowObj.Gross_Income__c);
                    totalfivbIncome+=cashflowObj.Gross_Income__c;
                    allfivBOBligations += cashflowObj.Obligations__c;}
                else  if(cashflowObj.Gross_Income__c != null)
                {  tempMap.put('FIV-B Income',cashflowObj.Gross_Income__c);
                 totalfivbIncome+=cashflowObj.Gross_Income__c;
                 allfivBOBligations += cashflowObj.Obligations__c;
                }
                incomeMap.put(cashflowObj.Loan_Applicant__c,tempMap);
            }
        }              
        
        incomeObj.totalFivCMonthlyIncome = totalfivcIncome;
        incomeObj.totalPCMonthlyIncome = totalpcIncome;
        incomeObj.totalPCbusincomeIncome = totalpcbusinessmonthlyincome;
        incomeObj.allpCObligations = pcObligations;
        incomeObj.allfivCObligations = fivCObligations;
        incomeObj.totalFivBMonthlyIncome = totalfivbIncome;
        incomeObj.allfivBObligations = allfivBOBligations;
        incomeObj.pcnetbusincomeIncome = totalpcbusinessmonthlyincome - pcObligations;
        incomeObj.totalPCMonthlyIncomeConsidered = totalpcIncomeConsidered - fivCObligations;
        incomeObj.pcnetMonthlyIncomeConsidered = totalpcIncomeConsidered - pcObligations;
        incomeObj.fivbnetMonthlyIncome = totalfivbIncome - allfivBOBligations;
        incomeObj.pcnetMonthlyIncome = totalpcIncome - pcObligations;
        incomeObj.fivcnetMonthlyIncome = totalfivcIncome - fivCObligations;
        
        List<IncomeWrapper> incomeList =new List<IncomeWrapper>();
        List<SegmentWrapper> segList = new List<SegmentWrapper>();
        for(String key:incomeMap.keySet())
        {
            Map<String,Decimal> temp = incomeMap.get(key);
            IncomeWrapper incObj = new IncomeWrapper();
            if(loanApplicationId.containsKey(key))
                incObj.customerName = loanApplicationId.get(key);
            incObj.customerId = key;
            incObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            incObj.pcIncome = (temp.get('PC Income')!=null)?temp.get('PC Income'):0;
            incObj.fivBIncome = (temp.get('FIV-B Income')!=null)?temp.get('FIV-B Income'):0;
            incomeList.add(incObj);
        }
        for(String key:segmentMap.keySet())
        {
            Map<String,Decimal> temp = segmentMap.get(key);
            SegmentWrapper segObj = new SegmentWrapper();
            segObj.SegmemtName = key;
            segObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            segObj.pcIncome = (temp.get('PC Income')!=null)?temp.get('PC Income'):0;
            segList.add(segObj);
        }
        incomeObj.incomList= incomeList;
        incomeObj.segmentList = segList;
        
        System.debug('incomeObj ='+incomeObj);
        System.debug('segmentMap ='+segmentMap);
        System.debug('incomeMap ='+incomeMap);
        
        return incomeObj;
        
    }
    
    // get the Capability Summary for AC
    public static IncomeSummary getacCapabilitySummary(String applicationId)
    {
        Decimal fivCObligations = 0,acObligations = 0;
        Set<String> bureauHighmarkIdSet = new Set<String>();
        for(Bureau_Highmark__c highmarkRecord : [SELECT Id,Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__c IN (SELECT Id FROM Loan_Applicant__c WHERE Application__c =:applicationId)]) {
            bureauHighmarkIdSet.add(highmarkRecord.Id);
        }
        String loanDetailRecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        for(Loan_details__c loanObj:[SELECT Id,Obligations__c,To_be_considerd_for_DBR__c,Stage__c FROM Loan_Details__c WHERE Bureau_Highmark__c IN:bureauHighmarkIdSet AND RecordTypeId =:loanDetailRecordTypeId ])
        {
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='FIV - C'))
                fivCObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0);  
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='AC' || loanObj.Stage__c =='PC'))
                acObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0); 
        }
        List<Id> verificationIds = new List<Id>();
        for(Verification__c verObj:[SELECT Id FROM Verification__c WHERE Application__c =:applicationId AND RecordType.Name IN('FIV - C','AC')])
        {
            verificationIds.add(verObj.Id);
        }
        IncomeSummary incomeObj = new IncomeSummary();
        String rcId1 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('AC Capability').getRecordTypeId();
        String rcId2 = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        List<String> rcIds = new List<String>{rcId1, rcId2};
            
            Decimal totalfivbIncome = 0,allfivBOBligations =0;
        Map<Id,String> loanApplicationId = new Map<Id,String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__r.Name FROM Loan_Applicant__c WHERE Application__c =: applicationId]){
            
            loanApplicationId.put(loanApplicant.Id,loanApplicant.Customer_Information__r.Name);
        }       
        
        List<Capability__c> capabilities = new List<Capability__c>();
        capabilities = [SELECT Id, Customer_Information__c, Income_segment__c,Loan_Applicant__r.Income_Considered__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
                        Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
                        Electricity__c, Rent__c, Others__c, Salary__c,RecordType.Name,Income_per_month_Pension__c
                        FROM Capability__c 
                        WHERE Verification__c IN: verificationIds AND RecordTypeId IN: rcIds Order BY Loan_Applicant__r.Customer_Information__r.Name];
        
        system.debug('capab list+'+capabilities);
        ////////
        Map<String,Map<String,Decimal>> incomeMap = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,Decimal>> segmentMap = new Map<String,Map<String,Decimal>>();
        decimal totalacIncome = 0;
        decimal totalfivcIncome =0;
        decimal totalacbusinessmonthlyincome = 0;
        decimal totalacIncomeConsidered =0;
        for(Capability__c cap : capabilities){
            Decimal busmonthlyIncome = 0;
            Decimal monthlyIncome = 0;
            Decimal monthlyIncomeConsidered = 0;
            if(cap.Income_segment__c == 'Salaried'){
                cap.Monthly_Salary__c = cap.Monthly_Salary__c != null ? cap.Monthly_Salary__c : 0;
                monthlyIncome = Integer.valueOf(cap.Monthly_Salary__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Rental Income'){
                cap.Rental_Income__c = cap.Rental_Income__c != null ? cap.Rental_Income__c : 0;
                monthlyIncome = Integer.valueOf(cap.Rental_Income__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            } else if(cap.Income_segment__c == 'Daily wages' || cap.Income_segment__c == 'Transport business'){
                cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
                if(cap.Income_segment__c == 'Transport business')
                    busmonthlyIncome = monthlyIncome;
            } else if( cap.Income_segment__c == 'Income from Abroad' ){
                cap.Income_per_month__c = cap.Income_per_month__c != null ? cap.Income_per_month__c : 0;
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
                system.debug('Income segment'+cap.Income_segment__c+'income' +cap.Income_per_month__c);
            } 
            else if(cap.Income_segment__c == 'Pension'  ){
                monthlyIncome = cap.Income_per_month_Pension__c != null ? Integer.valueOf(cap.Income_per_month_Pension__c) : 0;
                if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                    monthlyIncomeConsidered = monthlyIncome;
            }else if(cap.Income_segment__c == 'Eateries' || cap.Income_segment__c == 'Food business' ||
                     cap.Income_segment__c == 'Manufacturing' || cap.Income_segment__c == 'Shop owner' ||
                     cap.Income_segment__c == 'Milk business' || cap.Income_segment__c == 'General shops' ||
                     cap.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor' || cap.Income_segment__c == 'Self Employed'){
                         if(cap.Day_Margin_Basis__c == 'Day Basis'){
                             cap.Income_per_day__c = cap.Income_per_day__c != null ? cap.Income_per_day__c : 0;
                             cap.Number_of_days__c = cap.Number_of_days__c != null ? cap.Number_of_days__c : 0;
                             monthlyIncome = cap.Income_per_day__c * cap.Number_of_days__c;
                             if(cap.RecordType.Name == 'AC Capability')
                                 busmonthlyIncome = monthlyIncome;
                             if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                 monthlyIncomeConsidered = monthlyIncome;
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
                             if(cap.RecordType.Name == 'AC Capability')
                                 busmonthlyIncome = monthlyIncome;
                             if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                                 monthlyIncomeConsidered = monthlyIncome;
                         }
                     } 
            totalacbusinessmonthlyincome += busmonthlyIncome;
            
            if(!incomeMap.containsKey(cap.Loan_Applicant__c))
            {    if(cap.RecordType.Name == 'FIV-C Capability')
            { incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
             totalfivcIncome+=monthlyIncome;
             
            }else  if(cap.RecordType.Name == 'AC Capability')
            {   incomeMap.put(cap.Loan_Applicant__c,new Map<String,Decimal>{'AC Income'=>monthlyIncome});
             totalacIncome+=monthlyIncome;
             if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                 totalacIncomeConsidered += monthlyIncomeConsidered;
            }
            }
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('FIV-C Income'))
                    {    tempMap.put('FIV-C Income',tempMap.get('FIV-C Income')+monthlyIncome);
                     totalfivcIncome+=monthlyIncome;}
                    else
                    {  tempMap.put('FIV-C Income',monthlyIncome);
                     totalfivcIncome+=monthlyIncome;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap); 
                }
                else  if(cap.RecordType.Name == 'AC Capability')
                {
                    Map<String , Decimal> tempMap= incomeMap.get(cap.Loan_Applicant__c);
                    if(tempMap.containsKey('AC Income'))
                    {   tempMap.put('AC Income',tempMap.get('AC Income')+monthlyIncome);
                     totalacIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalacIncomeConsidered += monthlyIncomeConsidered;
                    }else
                    {   tempMap.put('AC Income',monthlyIncome);
                     
                     totalacIncome+=monthlyIncome;
                     if(cap.Loan_Applicant__r.Income_Considered__c == 'Yes')
                         totalacIncomeConsidered += monthlyIncomeConsidered;
                    }
                    incomeMap.put(cap.Loan_Applicant__c,tempMap);
                }}
            
            if(!segmentMap.containsKey(cap.Income_segment__c))
            {    if(cap.RecordType.Name == 'FIV-C Capability')
                segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'FIV-C Income'=>monthlyIncome});
             else if(cap.RecordType.Name == 'AC Capability')
                 segmentMap.put(cap.Income_segment__c,new Map<String,Decimal>{'AC Income'=>monthlyIncome});}
            else 
            {
                if(cap.RecordType.Name == 'FIV-C Capability')
                {     
                    Map<String , Decimal> SegMap= segmentMap.get(cap.Income_segment__c);
                    if(SegMap.containsKey('FIV-C Income'))
                        SegMap.put('FIV-C Income',SegMap.get('FIV-C Income')+monthlyIncome);
                    else
                        SegMap.put('FIV-C Income',monthlyIncome);
                    segmentMap.put(cap.Income_segment__c,SegMap);             }
                else if(cap.RecordType.Name == 'AC Capability')
                {   Map<String , Decimal> tempMap= segmentMap.get(cap.Income_segment__c);
                 if(tempMap.containsKey('AC Income'))
                     tempMap.put('AC Income',tempMap.get('AC Income')+monthlyIncome);
                 else
                     tempMap.put('AC Income',monthlyIncome);
                 segmentMap.put(cap.Income_segment__c,tempMap);    }}
        }
        
        for(Cashflow__C cashflowObj :[SELECT ID ,Loan_Applicant__c,Gross_Income__c,Obligations__c,Net_Income__c FROM Cashflow__C WHERE Loan_Applicant__c IN :loanApplicationId.keySet()])
        {
            if(!incomeMap.containsKey(cashflowObj.Loan_Applicant__c))
            {
                incomeMap.put(cashflowObj.Loan_Applicant__c,new Map<String,Decimal>{'FIV-B Income'=>cashflowObj.Gross_Income__c});
                totalfivbIncome += cashflowObj.Gross_Income__c;
                allfivBOBligations += cashflowObj.Obligations__c;
            }
            else
            {
                Map<String , Decimal> tempMap= incomeMap.get(cashflowObj.Loan_Applicant__c);
                if(tempMap.containsKey('FIV-B Income') && cashflowObj.Gross_Income__c != null)
                {    tempMap.put('FIV-B Income',tempMap.get('FIV-B Income')+cashflowObj.Gross_Income__c);
                 totalfivbIncome+=cashflowObj.Gross_Income__c;
                 allfivBOBligations += cashflowObj.Obligations__c;}
                else if(cashflowObj.Gross_Income__c != null)
                {  tempMap.put('FIV-B Income',cashflowObj.Gross_Income__c);
                 totalfivbIncome+=cashflowObj.Gross_Income__c;
                 allfivBOBligations += cashflowObj.Obligations__c;
                }
                incomeMap.put(cashflowObj.Loan_Applicant__c,tempMap);
            }
        }         
        
        incomeObj.totalFivCMonthlyIncome = totalfivcIncome;
        incomeObj.totalPCMonthlyIncome = totalacIncome;
        incomeObj.totalPCbusincomeIncome = totalacbusinessmonthlyincome;
        incomeObj.allpCObligations = acObligations;
        incomeObj.allfivCObligations = fivCObligations;
        incomeObj.totalFivBMonthlyIncome = totalfivbIncome;
        incomeObj.allfivBObligations = allfivBOBligations;
        incomeObj.pcnetbusincomeIncome = totalacbusinessmonthlyincome - acObligations;
        incomeObj.totalPCMonthlyIncomeConsidered = totalacIncomeConsidered - acObligations;
        incomeObj.pcnetMonthlyIncomeConsidered = totalacIncomeConsidered - fivCObligations;
        incomeObj.fivbnetMonthlyIncome = totalfivbIncome - allfivBOBligations;
        incomeObj.pcnetMonthlyIncome = totalacIncome - acObligations;
        incomeObj.fivcnetMonthlyIncome = totalfivcIncome - fivCObligations;
        
        List<IncomeWrapper> incomeList =new List<IncomeWrapper>();
        List<SegmentWrapper> segList = new List<SegmentWrapper>();
        for(String key:incomeMap.keySet())
        {
            Map<String,Decimal> temp = incomeMap.get(key);
            IncomeWrapper incObj = new IncomeWrapper();
            if(loanApplicationId.containsKey(key))
                incObj.customerName = loanApplicationId.get(key);
            incObj.customerId = key;
            incObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            incObj.pcIncome = (temp.get('AC Income')!=null)?temp.get('AC Income'):0;
            incObj.fivBIncome = (temp.get('FIV-B Income')!=null)?temp.get('FIV-B Income'):0;
            incomeList.add(incObj);
        }
        for(String key:segmentMap.keySet())
        {
            Map<String,Decimal> temp = segmentMap.get(key);
            SegmentWrapper segObj = new SegmentWrapper();
            segObj.SegmemtName = key;
            segObj.fivCIncome = (temp.get('FIV-C Income')!=null)?temp.get('FIV-C Income'):0;
            segObj.pcIncome = (temp.get('AC Income')!=null)?temp.get('AC Income'):0;
            segList.add(segObj);
        }
        incomeObj.incomList= incomeList;
        incomeObj.segmentList = segList;
        
        System.debug('incomeObj ='+incomeObj);
        System.debug('segmentMap ='+segmentMap);
        System.debug('incomeMap ='+incomeMap);        
        return incomeObj;
    }
    
    
    // Wrapper Class For PC Income Summary
    public class IncomeWrapper{
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerId;
        @AuraEnabled public Decimal fivCIncome;
        @AuraEnabled public Decimal pcIncome;
        @AuraEnabled public Decimal fivBIncome;
        public IncomeWrapper(){
            customerId = '';
            customerName = '';
            pcIncome = 0;
            fivCIncome = 0;
            fivBIncome = 0;
        }
    }
    public class SegmentWrapper{
        @AuraEnabled public String SegmemtName;
        @AuraEnabled public Decimal fivCIncome;
        @AuraEnabled public Decimal pcIncome;
        public SegmentWrapper(){
            SegmemtName='';
            pcIncome =0;
            fivCIncome =0;
        }
    }
    
    
    public class IncomeSummary{
        @AuraEnabled public Decimal totalFivCMonthlyIncome;
        @AuraEnabled public Decimal totalPCMonthlyIncome;
        @AuraEnabled public Decimal totalFivBMonthlyIncome;
        @AuraEnabled public Decimal totalPCbusincomeIncome;
        @AuraEnabled public Decimal totalPCMonthlyIncomeConsidered;
        @AuraEnabled public Decimal allfivCObligations;
        @AuraEnabled public Decimal allpCObligations;
        @AuraEnabled public Decimal allfivBObligations;
        @AuraEnabled public Decimal pcnetMonthlyIncome;
        @AuraEnabled public Decimal fivcnetMonthlyIncome;
        @AuraEnabled public Decimal fivbnetMonthlyIncome;
        @AuraEnabled public Decimal pcnetbusincomeIncome; 
        @AuraEnabled public Decimal pcnetMonthlyIncomeConsidered;
        @AuraEnabled public List<IncomeWrapper> incomList;
        @AuraEnabled public List<SegmentWrapper> segmentList;
        
        public IncomeSummary(){
            incomList = new List<IncomeWrapper> ();
            segmentList = new List<SegmentWrapper>();
            fivcnetMonthlyIncome = 0;
            pcnetMonthlyIncome = 0;
            allpCObligations = 0;
            allfivCObligations = 0;
            totalPCMonthlyIncome = 0;
            totalFivCMonthlyIncome = 0;
            fivbnetMonthlyIncome = 0;
            allfivBObligations = 0;
            totalFivBMonthlyIncome = 0;
            totalPCbusincomeIncome = 0;
            pcnetbusincomeIncome = 0;
            totalPCMonthlyIncomeConsidered = 0;
            pcnetMonthlyIncomeConsidered = 0;
        }
    }
    
    
}