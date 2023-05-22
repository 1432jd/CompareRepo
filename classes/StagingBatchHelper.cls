/**
* @File Name          : StagingBatchHelper.cls
* @Description        : StagingBatchHelper Class Used To create Records for Respective & To Get Records From the Objects & Delete Records From Staging Objects
* @Author             : Parag Goyal / Mo Arslan
* @Created On         : 15/10/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0        15/10/2022         Parag Goyal / Mo Arslan       Initial Version
*/
public with sharing class StagingBatchHelper {
    
    public static Map<String,String> applicationTypeMap = new Map<String,String>{'0'=>'Normal','1'=>'I','2'=>'II','I'=>'I','II'=>'II','Normal'=>'Normal'};
    public static Map<String,String> applicantTypeMap = new Map<String,String>{'G'=>'Guarantor','PRIMARY'=>'Primary Applicant','Co-applicant'=>'Co-Applicant','Guarantor'=>'Guarantor','P'=>'Primary Applicant','C'=>'Co-Applicant'};
	public static Map<String,String> salutionTypeMap = new Map<String,String>{'Mr'=>'Mr.','Mrs'=>'Mrs.','Ms'=>'Ms.'}; 
	public static Map<String,String> mapOfKYCIds = new Map<String,String>();
    
    public static Map<String,String> channelTypeMap = new Map<String,String>{'ALTERNATE_CHANNEL'=>'Alternate Channel','COMMON'=>'Common'};
	public static Map<String,String> altChannelTypeMap = new Map<String,String>{'Direct Marketing'=>'Top-up Loan','Additional Loan'=>'Light Board','Other Referrals'=>'Other Refferal', 'Customer Referral' => 'Customer Refferal'};
	public static Map<String,String> titleDeedTypeMap = new Map<String,String>{'Gift Deed'=>'Settlement or Gift or Consent Deed', 'Settlement Deed' => 'Settlement or Gift or Consent Deed'};
	public static Map<String,String> propPurchaseTypeMap = new Map<String,String>{'Existing / Resale'=>'Existing'};
	public static Map<String,String> propPurposeMap = new Map<String,String>{'SELF_OCCUPIED'=>'Self Occupied', 'Mixed_Use' => 'Mixed Use', 'Multi_Tenanted' => 'Multi Tenanted'};
	public static Map<String, String> residualAgeOfPropMap = new Map<String, String>{'LESS_THAN_5_YEARS' => 'Less than 5 Years', 'MORE_THAN_25_AND_LESS_THAN_40_YEARS' => 'More than 40 Years', 'MORE_THAN_5_TO_15_YEARS' => '5 to 15 Years', 'FROM_15_TO_25_YEARS' => '15 to 25 Years', 'FROM_15_TO_25_YEARS' => '25 to 40 Years'};
	public static Map<String, String> residentTypeMap = new Map<String, String>{'Resident Indian' => 'Resident'};
	public static Map<String, String> relationshipMap = new Map<String, String>{'Main_applicant' => 'Self'};
	public static Map<String, String> occuptaionMap = new Map<String, String>{'Others' => 'Retired'};
	public static Map<String, String> propertyTypeMap = new Map<String, String>{'ROW HOUSE' => 'House'};
                                            
                                            
	// public static Map<String,Pre_Login__c> insertPrelogin(Staging_Loan__c scope){
	// 	Map<String,Pre_Login__c> mapOfLANPre = new Map<String,Pre_Login__c>();
	// 	Pre_login__c pl = new Pre_login__c(
	// 		Loan_Account_Number_Staging__c = scope.Loan_Account_No__c,
	// 		status__c = 'Active',
	// 		RecordTypeId = DatabaseUtililty.getRecordTypeId('Pre_login__c','1. New login')
	// 	);
	// 	mapOfLANPre.put(scope.Loan_Account_No__c,pl);
	// 	return mapOfLANPre;
	// }
    
    
    // public static Map<String,Application__c> insertApplication(Staging_Loan__c scope, String appId, String branchId, String userId){
    //     Map<String,Application__c> mapOfLANApp = new Map<String,Application__c>();
    //     Application__c app = new Application__c(
    //         LMS_Response_Reference__c = scope.Loan_Account_No__c,
    //         Application_Status__c = 'Active',
    //         Stage__c = 'Custody'
    //     );
    //     if(String.isNotBlank(appId) && String.isNotEmpty(appId)){
    //         app.Id = appId;
    //     }
    //     else{
    //         app.Pre_login__r = new Pre_login__c(Loan_Account_Number_Staging__c = scope.Loan_Account_No__c);
    //     }
    //     app.Sourcing_Branch__c = branchId; //getBranchIds(scope.Branch_Name__c);
    //     if(altChannelTypeMap.containsKey(scope.Alternate_Channel_Mode__c))
    //         app.Alternate_Channel_Mode__c = altChannelTypeMap.get(scope.Alternate_Channel_Mode__c);
    //     else
    //         app.Alternate_Channel_Mode__c = scope.Alternate_Channel_Mode__c;
    //     if(channelTypeMap.containsKey(scope.Channel__c))
    //         app.Channel__c = scope.Channel__c;
    //     app.Customer_Request_Amount__c = scope.Customer_Requested_Loan_Amount__c;
    //     app.DPD__c = String.valueOf(scope.Dpd__c);
    //     app.DBR__c = scope.Dbr__c;
    //     app.EMI__c = scope.Emi__c;
    //     app.Field_Officer_Name__c = scope.Field_Officer_Name__c;
    //     app.Field_Officer_Emp_Id__c = userId; //getUserId(scope.Field_Officer_Id__c);
    //     app.Loan_Purpose_1__c = scope.Loan_Purpose__c;
    //     app.Amount_Recommended__c = scope.Loan_Amount__c;
    //     app.LTV__c = scope.Ltv__c;
    //     app.Old_Collateral_value__c = scope.Old_Collateral_Value__c != null ? Decimal.valueOf(scope.Old_Collateral_Value__c) : null;
    //     app.Old_Loan_Gross_Income__c = scope.Old_Loan_Gross_Income__c;
    //     app.Old_Loan_Net_Income__c = scope.Old_Loan_Net_Income__c;
    //     app.Old_Loan_Obligationss__c = String.valueOf(scope.Old_Loan_Obligations__c);
    //     mapOfLANApp.put(scope.Loan_Account_No__c,app);
    //     return mapOfLANApp;
    // }
    
    public static Map<String,String> getPinIds(Set<String> pincodeSet){
        System.debug('pincodeSet '+pincodeSet);
        Map<String,String> pincodeMap = new Map<String,String>();
        if(pincodeSet.size() > 0){
            List<MS_Pincode__c> Ids = [SELECT Id, Name, Pincode__c FROM MS_Pincode__c WHERE Name In :pincodeSet OR Pincode__c In :pincodeSet];
            if(Ids.size()>0){
                for(MS_Pincode__c pin : Ids){
                    pincodeMap.put(pin.Pincode__c,pin.Id);
                }
            }
        }
        System.debug('Return Pincode '+pincodeMap);
        return pincodeMap;
    }
    
    public static Map<String,String> getApplicationIds(Set<String> loanAccountNumberSet){
        Map<String,String> returnMap = new Map<String,String>();
        for(Application__c app : [SELECT Id, LMS_Response_Reference__c FROM Application__c WHERE LMS_Response_Reference__c IN : loanAccountNumberSet]){
            returnMap.put(app.LMS_Response_Reference__c, app.Id);
        }
        return returnMap;
    }
    
    public static Map<String,String> getCustomerIds(Set<String> cifids){
        Map<String,String> returnMap = new Map<String,String>();
        for(Loan_Applicant__C la : [SELECT Id, LMS_Customer_Info_File_Number__c FROM Loan_Applicant__C WHERE LMS_Customer_Info_File_Number__c IN : cifids]){
            returnMap.put(la.LMS_Customer_Info_File_Number__c , la.Id);
        }
        return returnMap;
    }
    
    
    // public static Map<String,String> getAccountIds(Set<String> cifids){
    //     Map<String,String> returnMap = new Map<String,String>();
    //     for(Account acc : [SELECT Id, Neo_CIF_Id_Staging__c FROM Account WHERE Neo_CIF_Id_Staging__c IN : cifids]){
    //         returnMap.put(acc.Neo_CIF_Id_Staging__c, acc.Id);
    //     }
    //     return returnMap;
    // }
    
    public static Map<String,String> getBranchId(Set<String> listOfBranch){
        Map<String,String> mapOfBranch = new Map<String,String>();
        List<Branch_Master__c> brList = [SELECT Id, Name,Branch_Code__c FROM Branch_Master__c WHERE Branch_Code__c In :listOfBranch];
        if(brList.size() > 0){
            for(Branch_Master__c branch : brList){
                mapOfBranch.put(branch.Branch_Code__c,branch.Id);
            }
        }
        return mapOfBranch;
    }
    
    public static Map<String,String> getUserIds(Set<String> listOfEMPId){ 
        Map<String,String> mapOfUser = new Map<String,String>();
        List<User> userList = [SELECT Id, EmployeeNumber FROM User WHERE EmployeeNumber In :listOfEMPId];
        if(userList.size() > 0){
            for(User u : userList){
                mapOfUser.put(u.EmployeeNumber,u.Id);
            }
        }
        return mapOfUser;
    }
    
    public static Map<String,String> getPreLoginIds(Set<String> lanNos){
        Map<String,String> returnMap = new Map<String,String>();
        for(Pre_Login__c preLogin : [SELECT Id, Loan_Account_Number_Staging__c FROM Pre_Login__c WHERE Loan_Account_Number_Staging__c IN :lanNos]){
            returnMap.put(preLogin.Loan_Account_Number_Staging__c , preLogin.Id);
        }
        return returnMap;
    }
    
    public static Map<String,String> getCapabilityIds(Set<String> cifids){
        Map<String,String> returnMap = new Map<String,String>();
        for(Capability__c cap : [SELECT Id, Loan_Applicant__c, Loan_Applicant__r.LMS_Customer_Info_File_Number__c FROM Capability__c WHERE Loan_Applicant__r.LMS_Customer_Info_File_Number__c IN :cifids]){
            returnMap.put(cap.Loan_Applicant__r.LMS_Customer_Info_File_Number__c , cap.Id);
        }
        System.debug('returnMap '+returnMap.values());
        return returnMap;
    }
    
    public static Map<String,String> getFamilyIds(Set<String> cifids){
        Map<String,String> returnMap = new Map<String,String>();
        for(Family_Detail__c fam : [SELECT Id, Loan_Applicant__c, Loan_Applicant__r.LMS_Customer_Info_File_Number__c FROM Family_Detail__c WHERE Loan_Applicant__r.LMS_Customer_Info_File_Number__c IN :cifids]){
            returnMap.put(fam.Loan_Applicant__r.LMS_Customer_Info_File_Number__c , fam.Id);
        }
        System.debug('returnMap '+returnMap.values());
        return returnMap;
    }
    
    public static Map<String,String> getEmploymentDetailIds(Set<String> cifids){
        Map<String,String> returnMap = new Map<String,String>();
        for(Employment_Details__c emp : [SELECT Id, Loan_Applicant__c, Loan_Applicant__r.LMS_Customer_Info_File_Number__c FROM Employment_Details__c WHERE Loan_Applicant__r.LMS_Customer_Info_File_Number__c IN :cifids]){
            returnMap.put(emp.Loan_Applicant__r.LMS_Customer_Info_File_Number__c , emp.Id);
        }
        System.debug('returnMap '+returnMap.values());
        return returnMap;
    }
    
    public static Map<String,String> getIncomeIds(Set<String> cifids){
        Map<String,String> returnMap = new Map<String,String>();
        for(Income__c inc : [SELECT Id, Loan_Applicant__c, Loan_Applicant__r.LMS_Customer_Info_File_Number__c FROM Income__c WHERE Loan_Applicant__r.LMS_Customer_Info_File_Number__c IN :cifids]){
            returnMap.put(inc.Loan_Applicant__r.LMS_Customer_Info_File_Number__c , inc.Id);
        }
        System.debug('returnMap '+returnMap.values());
        return returnMap;
    }
    
    // public Static Map<String, Account> insertAccount(Staging_Customer__c scope, String accId){
    //     Map<String, Account> nifAccountMap = new Map<String, Account>();
    //     Account acc = new Account();
    //     acc.Neo_CIF_Id_Staging__c = scope.Neo_Cif_Id__c;
    //     acc.RecordTypeId = DatabaseUtililty.getRecordTypeId('Account','Person Account');
    //     acc.FirstName = scope.First_Name__c;
    //     acc.LastName = scope.Last_Name__c;
    //     acc.PersonBirthDate = scope.Date_of_Birth__c;
    //     acc.Father_s_Name__c = scope.Father_Name__c;
    //     acc.Mother_s_Name__c = scope.Mother_s_Name__c;
    //     acc.Gender__c = scope.Applicant_s_Gender__c;
    //     acc.Salutation = salutionTypeMap.get(scope.Salutation__c); 
    //     acc.Category__c = scope.Category__c;
    //     acc.Guardian_Name__c = scope.Guardian_Name__c;
    //     acc.Nationality__c = scope.Nationality__c;
    //     acc.Place_Of_Birth__c = scope.Place_Of_Birth__c;
    //     acc.Religion__c = scope.Religion__c;
    //     if(String.isNotBlank(accId) && String.isNotEmpty(accId)){
    //         acc.Id = accId;
    //     }
    //     nifAccountMap.put(acc.Neo_CIF_Id_Staging__c, acc);
    //     return nifAccountMap;
    // }
    
    // public static Map<String, Loan_Applicant__c> insertLoanApplicant(sObject obj, String loanAppId,String pinId, String appId, String accId){
    //     Map<String, Loan_Applicant__c> cifLANAccount = new Map<String, Loan_Applicant__c>();
    //     Loan_Applicant__c la = new Loan_Applicant__c();
    //     System.debug(obj.getSObjectType());
    //     if(String.valueOf(obj.getSObjectType())=='Staging_Address__c'){
    //         Staging_Address__c s = (Staging_Address__c)obj;
    //         la.Ownership_Type__c = s.Ownership_Type__c;
    //         if(s.Address_Type__c == 'ResidentialAddress'){
    //             la.Residence_City__c = s.City__c;
    //             la.Residence_Country__c = s.Country__c;
    //             la.Residence_District__c = s.District__c;
    //             la.Residence_Flat_Plot_Number__c = s.Flat_Plot_Number__c;
    //             if(String.isNotBlank(pinId) && String.isNotEmpty(pinId)){
    //                 la.Residence_Pincode__c = pinId;
    //             }
    //             la.Residence_State__c = s.State__c;
    //             la.Residence_Taluka__c = s.Taluka__c;
    //             la.Residence_Village__c = s.Village__c;
    //             la.Residence_Address_Line_1__c = s.Address_Line_2__c;
    //             la.Residence_Address_Line_2__c = s.Address_Line_3__c;
    //         }
    //         if(s.Address_Type__c == 'PermanentAddress'){
    //             la.Permanent_City__c = s.City__c;
    //             la.Permanent_Country__c = s.Country__c;
    //             la.Permanent_District__c = s.District__c;
    //             la.Permanent_Flat_Plot_Number__c = s.Flat_Plot_Number__c;
    //             if(String.isNotBlank(pinId) && String.isNotEmpty(pinId)){
    //                 la.Permanent_Pincode__c = pinId;
    //             }
    //             //la.Permanent_Pincode__c = s.Pincode__c;
    //             la.Permanent_State__c = s.State__c;
    //             la.Permanent_Taluka__c = s.Taluka__c;
    //             la.Permanent_Village__c = s.Village__c;
    //             la.Permanent_Address_Line_1__c = s.Address_Line_2__c;
    //             la.Permanent_Address_Line_2__c = s.Address_Line_3__c;
    //         }
    //         if(s.Address_Type__c == 'BusinessAddress'){
    //             la.Business_City__c = s.City__c;
    //             la.Business_Country__c = s.Country__c;
    //             la.Business_District__c = s.District__c;
    //             la.Business_Flat_Plot_Number__c = s.Flat_Plot_Number__c;
    //             if(String.isNotBlank(pinId) && String.isNotEmpty(pinId)){
    //                 la.Business_Pincode__c = pinId;
    //             }
    //             //la.Business_Pincode__c = s.Pincode__c;
    //             la.Business_State__c = s.State__c;
    //             la.Business_Taluka__c = s.Taluka__c;
    //             la.Business_Village__c = s.Village__c;
    //             la.Permanent_Address_Line_1__c = s.Address_Line_2__c;
    //             la.Permanent_Address_Line_2__c = s.Address_Line_3__c;
    //         }
    //         la.Customer_Information__r = new Account(Neo_CIF_Id_Staging__c = s.Loan_Account_No__c);
    //         if(String.isNotBlank(loanAppId) && String.isNotEmpty(loanAppId)){
    //             la.Id = loanAppId;
    //         }
    //         cifLANAccount.put(s.Neo_Cif_Id__c, la);
    //     }
    //     if(String.valueOf(obj.getSObjectType()) == 'Staging_Customer__c'){
    //         System.debug('for Customer');
    //         Staging_Customer__c scope = (Staging_Customer__c)obj;
    //         la.Customer_Type__c = StagingBatchHelper.applicantTypeMap.get(scope.Applicant_Type__c);
    //         la.Email__c = scope.Email_Id__c;
    //         la.Marital_Status__c = scope.Marital_Status__c;
    //         la.Phone_Office__c = scope.Phone_Office__c;
    //         la.Mobile__c = scope.Phone_Residence__c;
    //         if(relationshipMap.containsKey(scope.Relationship_With_Applicant__c)){
    //             la.Relationship_With_Main_Applicant__c = relationshipMap.get(scope.Relationship_With_Applicant__c);
    //         }
    //         else{
    //             la.Relationship_With_Main_Applicant__c = scope.Relationship_With_Applicant__c;
    //         }
            
    //         if(residentTypeMap.containsKey(scope.Resident_Type__c))
    //             la.Resident_Type__c = residentTypeMap.get(scope.Resident_Type__c);
    //         else
    //             la.Resident_Type__c = scope.Resident_Type__c;
    //         la.LMS_Customer_Info_File_Number__c = scope.Neo_Cif_Id__c;
    //         la.Group_Name_Staging__c = scope.Group_Name__c;
    //         if(String.isNotBlank(loanAppId) && String.isNotEmpty(loanAppId)){
    //             la.Id = loanAppId;
    //         }
    //         if(String.isNotBlank(accId) && String.isNotEmpty(accId)){
    //             la.Customer_Information__c = accId;
    //         }
    //         if(String.isNotBlank(appId) && String.isNotEmpty(appId)){
    //             la.Application__c = appId;
    //         }
    //         StagingBatchHelper.mapOfKYCIds.clear();
    //         if(scope.Aadhar_No__c != null){
    //             mapOfKYCIds.put('Aadhaar Card',scope.Aadhar_No__c);
    //         }
    //         if(scope.PAN__c != null){
    //             mapOfKYCIds.put('Pan Card',scope.PAN__c);
    //         }
    //         if(scope.Voters_Id__c != null){
    //             mapOfKYCIds.put('Voter Id',scope.Voters_Id__c); 
    //         }
    //         if(scope.Driving_Licence__c != null){
    //             mapOfKYCIds.put('Driving License',scope.Driving_Licence__c);
    //         }
    //         if(scope.Passport__c != null){
    //             mapOfKYCIds.put('Passport',scope.Passport__c);
    //         }
    //         if(!mapOfKYCIds.isEmpty()){
    //             Integer count = 0;
    //             for(String kyc : mapOfKYCIds.keySet()){
    //                 count++;
    //                 if(count == 1){
    //                     la.KYC_ID_Type_1__c = kyc;
    //                     la.KYC_Id_1__c = mapOfKYCIds.get(kyc);
    //                 }
    //                 if(count == 2){
    //                     la.KYC_ID_Type_2__c = kyc;
    //                     la.KYC_Id_2__c = mapOfKYCIds.get(kyc);
    //                 }
    //             }
    //         }
    //         cifLANAccount.put(scope.Neo_Cif_Id__c, la);
    //         System.debug('Loan Applicnt '+cifLANAccount.values());
    //     }
    //     return cifLANAccount;
    // }
    
    // public static Family_Detail__c insertFamily(Staging_Customer__c scope, String loanAppId){
    //     Family_Detail__c family = new Family_Detail__c();
    //     family.Number_Of_Children__c = scope.Number_Of_Childrens__c;
    //     family.No_Of_Adult_Dependents__c = scope.Number_Of_Dependents__c;
    //     if(String.isNotBlank(loanAppId) && String.isNotEmpty(loanAppId)){
    //         family.Loan_Applicant__c = loanAppId; //getCustomerIds(new Set<String>{scope.Neo_Cif_Id__c}).get(scope.Neo_Cif_Id__c);
    //     }
    //     else{
    //         family.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c = scope.Neo_Cif_Id__c);
    //     }
    //     return family;
    // }
    
    // public static Employment_Details__c insertEmployee(Staging_Customer__c scope, String loanAppId){
    //     Employment_Details__c emp = new Employment_Details__c();
    //     emp.No_of_years_Employment_Business__c = scope.No_Of_Years_Employment_Business__c;
        
    //     if(occuptaionMap.containsKey(scope.Occupation__c)){
    //         emp.Occupation__c = occuptaionMap.get(scope.Occupation__c);
    //     }
    //     else{
    //         emp.Occupation__c = scope.Occupation__c;
    //     }
        
    //     if(String.isNotBlank(loanAppId) && String.isNotEmpty(loanAppId)){
    //         emp.Loan_Applicant__c = loanAppId; //getCustomerIds(new Set<String>{scope.Neo_Cif_Id__c}).get(scope.Neo_Cif_Id__c);
    //     }
    //     else{
    //         emp.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c = scope.Neo_Cif_Id__c);
    //     }
    //     return emp;
    // }
    
    // public static Property__c insertProperty(Staging_Property__c scope, String appId, String preLoginId){
    //     Property__c ObjProp = new Property__c();
    //     objProp.Property_Address__c = scope.Address_Line_2__c+' '+scope.Address_Line_3__c;
    //     objProp.Age_Of_Property__c = Decimal.valueOf(scope.Age_Of_Property__c);
    //     objProp.Building_Area_Sq_Ft__c = scope.Building_Area__c;
    //     objProp.Carpet_Area__c = String.valueOf(scope.Carpet_Area__c);
    //     objProp.City__c = scope.City__c;
    //     objProp.Co_Owner_Name__c = scope.Co_Owner_Name__c;
    //     objProp.District__c = scope.District__c;
    //     objProp.East_by__c = scope.Eastby__c;
    //     if(scope.Eastby1__c!=null)
    //         objProp.East_by_land_measurements__c = Decimal.valueOf(scope.Eastby1__c);
    //     objProp.Flat_Plot_Number__c = scope.Flat_Plot_Number__c;
    //     objProp.Nature_Of_Property__c = scope.Nature_Of_Property__c;
    //     objProp.North_by__c = scope.Northby__c;
    //     if(scope.Northby1__c!=null)
    //         objProp.North_by_land_measurements__c = Decimal.valueOf(scope.Northby1__c);
    //     objProp.Property_Location_Classification__c = scope.Property_Location_Classification__c;
    //     if(propPurchaseTypeMap.containsKey(scope.Property_Purchased_Type__c))
    //         objProp.Property_Purchased_Type__c = propPurchaseTypeMap.get(scope.Property_Purchased_Type__c);
    //     else
    //         objProp.Property_Purchased_Type__c = scope.Property_Purchased_Type__c;
    //     if(propPurposeMap.containsKey(scope.Property_Purpose__c))
    //         objProp.Property_Purpose__c = propPurposeMap.get(scope.Property_Purpose__c);
    //     else
    //         objProp.Property_Purpose__c = scope.Property_Purpose__c;
    //     if(propertyTypeMap.containsKey(scope.Property_Type__c))
    //         objProp.Property_Type__c = propertyTypeMap.get(scope.Property_Type__c);
    //     else
    //         objProp.Property_Type__c = scope.Property_Type__c;
    //     objProp.Proposed_Area__c = scope.Proposed_Area__c;
    //     if(residualAgeOfPropMap.containsKey(scope.Residual_Age_of_property__c))
    //         objProp.Residual_Age_Of_Property__c = residualAgeOfPropMap.get(scope.Residual_Age_of_property__c);//commented due to LESS_THAN_5_YEARS
    //     else
    //         objProp.Residual_Age_Of_Property__c = scope.Residual_Age_of_property__c;
    //     objProp.South_by__c = scope.Southby__c;
    //     if(scope.Southby1__c!=null)
    //         objProp.South_by_land_measurements__c = Decimal.valueOf(scope.Southby1__c);
    //     objProp.State__c = scope.State__c;
    //     objProp.Title_Deed_Date__c = scope.Title_Deed_Date__c;
    //     objProp.Title_Deed_Number__c = String.valueOf(scope.Title_Deed_Number__c);
    //     if(titleDeedTypeMap.containsKey(scope.Title_Deed_Type__c))
    //         objProp.Title_Deed_Type__c = titleDeedTypeMap.get(scope.Title_Deed_Type__c);
    //     else
    //         objProp.Title_Deed_Type__c = scope.Title_Deed_Type__c;
    //     objProp.Village__c = scope.Village__c;
    //     objProp.West_by__c = scope.Westby__c;
    //     if(scope.Westby1__c!=null)
    //         objProp.West_by_land_measurements__c = Decimal.valueOf(scope.Westby1__c);
    //     objProp.LMS_Collateral_Number__c = scope.Collateral_Id__c;
    //     objProp.Valuation_Market_Value_Per_SqFt__c = scope.Market_Value__c;
    //     objProp.Land_Area_Sq_Ft__c = 1;
    //     objProp.Market_Value_Of_Property__c = scope.Market_Value__c;
    //     if(String.isNotBlank(appId) && String.isNotEmpty(appId)){
    //         objProp.Application__c = appId;
    //     }
    //     if(String.isNotBlank(preLoginId) && String.isNotEmpty(preLoginId)){
    //         objProp.Login__c = preLoginId;
    //     }
    //     return objProp;
    // }
    
    // public static Map<String, Disbursal__c> insertDisbursal(Staging_Loan__c scope,String appId){
    //     Set<String> loanAccountNo = new Set<String>{scope.Loan_Account_No__c};
    //         Map<String, Disbursal__c> disbursalMap = new Map<String, Disbursal__c>();
    //     Disbursal__c dis = new Disbursal__c();
    //     dis.Final_Disbursal_Amount__c = scope.Customer_Disbursal_Amount__c;
    //     dis.Loan_Amount_Sanctioned__c = scope.Sanction_Loan_Amount__c;
    //     if(String.isNotBlank(appId) && String.isNotEmpty(appId)){
    //         dis.Application__c = appId; //getApplicationIds(loanAccountNo).get(scope.Loan_Account_No__c);
    //     }
    //     disbursalMap.put(scope.Neo_Cif_Id__c, dis);
    //     return disbursalMap;
    // }
    
    // public static Capability__c insertCapability(sObject scope,String loanAppId){
    //     Capability__c cap = new Capability__c();
    //     if(String.valueOf(scope.getSObjectType())=='Staging_Customer__c'){
    //         Staging_Customer__c s = (Staging_Customer__c)scope;
    //         cap.Name_of_the_Employer__c = s.Employer_Name__c;
    //         cap.Business_Nature__c = s.Nature_Of_Business__c;
    //         if(String.isNotEmpty(loanAppId)){
    //             cap.Loan_Applicant__c = loanAppId; //getCustomerIds(new Set<String>{s.Neo_Cif_Id__c}).get(s.Neo_Cif_Id__c);
    //         }
    //         else{
    //             cap.Loan_Applicant__r = new Loan_Applicant__c(LMS_Customer_Info_File_Number__c = s.Neo_Cif_Id__c);
    //         }
    //     }
    //     if(String.valueOf(scope.getSObjectType())=='Staging_Loan__c'){
    //         Staging_Loan__c s = (Staging_Loan__c)scope;
    //         if(String.isNotEmpty(loanAppId)){
    //             cap.Loan_Applicant__c = loanAppId; //getCustomerIds(new Set<String>{s.Neo_Cif_Id__c}).get(s.Neo_Cif_Id__c);
    //         }
    //         cap.Rental_Income__c = s.Rentral_Income__c;
    //         cap.Monthly_Salary__c = s.Salary_Income__c;
    //         if(s.Pension_Income__c != null)
    //             cap.Income_per_month__c = s.Pension_Income__c;
    //         if(s.Other_Income__c != null)
    //             cap.Income_per_month__c = s.Other_Income__c;
    //         if(s.Nri_Income__c != null)
    //             cap.Income_per_month__c = s.Nri_Income__c;
    //     }
    //     return cap;
    // }
    
    // public static Income__c insertIncome(Staging_Loan__c scope,String loanAppId){
    //     Income__c income = new Income__c();
    //     income.Agricultural_Income__c = scope.Agricultural_Income__c;
    //     income.Business_Income__c = scope.Business_Income__c;
    //     income.Pension_Income__c = scope.Pension_Income__c;
    //     income.NRI_Income__c = scope.Nri_Income__c;
    //     income.Other_Income__c = scope.Other_Income__c;
    //     income.Other_Expected_Income__c = scope.Other_Expected_Income__c;
    //     income.Salary_Income__c = scope.Salary_Income__c;
    //     income.Rentral_Income__c = scope.Rentral_Income__c;
    //     if(String.isNotEmpty(loanAppId) && String.isNotBlank(loanAppId)){
    //         income.Loan_Applicant__c = loanAppId; //getCustomerIds(new Set<String>{scope.Neo_Cif_Id__c}).get(scope.Neo_Cif_Id__c);
    //     }
    //     return income;
    // }
    
    // public static Map<Property__c, List<Property__c>> clonePropertyNew(Property__c prop){
    //     Map<Property__c, List<Property__c>> newOldProperties = new Map<Property__c, List<Property__c>>();
    //     String recordTypesToCreate = System.Label.Property_RecordTypes_To_Clone;
    //     List<String> recordTypeNames = recordTypesToCreate.split(',');
    //     List<Property__c> newPropList = new List<Property__c>();
    //     if(prop!= NULL){
    //         if(!prop.hasRelatedRecords__c){
    //             for(String rcName : recordTypeNames){
    //                 Property__c newProperty = prop.clone(false,false,false,true);
    //                 newProperty.RecordTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get(rcName).getRecordTypeId();
    //                 newProperty.Application__c = prop.Application__c;
    //                 newProperty.Property__c = prop.Id;
    //                 newPropList.add(newProperty);
    //             }
    //             prop.hasRelatedRecords__c = true; 
    //         }
    //         newOldProperties.put(prop, newPropList);
    //     }
    //     return newOldProperties;
    // }
    
    public static Map<Application__c,List<Verification__c>> createVerifications(Application__c app){
        List<Verification__c> verificationList = new List<Verification__c>();
        Map<Application__c, List<Verification__c>> appVerificationsMap = new Map<Application__c, List<Verification__c>>();
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
		appVerificationsMap.put(app, verificationList);
        return appVerificationsMap;
    }
//     public static void deleteStagingSobjectRecord(List<Database.SaveResult> databaseResult, String sourceSObject, String sourceFieldName, String sourceFieldSecond, String targetSObject, String targetFieldName){
//         Set<String> successRecordIds = new Set<String>();
//         Set<String> failedRecordIds = new Set<String>();
//         List<sObject> sObjectToDelete = new List<sObject>();
//         List<sObject> sObjectToUpdate = new List<sObject>();
//         Map<String, String> failedRecordIdWithError = new Map<String, String>();
//         Map<String, String> uniqueKeyWithError = new Map<String, String>();
//         List<Messaging.SingleEmailMessage> masterListMails =  new List<Messaging.SingleEmailMessage>();
//         String errorMsg = '';
//         for(Database.SaveResult sr : databaseResult){
//             if(sr.isSuccess()){
//                 if(String.valueOf(sr.getId().getSobjectType())==sourceSObject){
//                     successRecordIds.add(sr.getId());
//                 }
//             }
//             else{
//                 /*if(String.valueOf(sr.getId().getSobjectType())==sourceSObject){
// String errorMsg = '';
// for(Database.Error err : sr.getErrors()){
// errorMsg+=err.getStatusCode() + ': ' + err.getMessage()+' ,';
// }
// errorMsg.removeEnd(',');
// System.debug('Error '+errorMsg);
// failedRecordIdWithError.put(sr.getId(), errorMsg);
// }*/
//                 errorMsg+=sr.getErrors()+'\n\n'; 
//             }
//         }
//         errorMsg.removeEnd(',');
//         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//         mail.setToAddresses(new String[] {'parag.g@techmatrixconsulting.com','arslan.m@techmatrixconsulting.com'});
//         mail.setSubject('Staging Batch Failure Reasons '+sourceSObject);
//         mail.setPlainTextBody('Reasons are ::  '+errorMsg);
//         masterListMails.add(mail);
//         if(masterListMails.size()>0){
//             Messaging.sendEmail(masterListMails);
//         }
//         failedRecordIds.addAll(failedRecordIdWithError.keySet());
//         System.debug('successRecordIds '+successRecordIds);
//         System.debug('failedRecordIdWithError '+failedRecordIdWithError.keySet());
//         System.debug('failedRecordIds '+failedRecordIds);
//         if(successRecordIds.size() > 0 || !failedRecordIdWithError.isEmpty()){
//             Set<String> processKeyId = new Set<String>();
//             Set<String> failedKeyId = new Set<String>();
//             String query = 'SELECT Id, ';
//             if(String.isNotBlank(sourceFieldSecond) && String.isNotEmpty(sourceFieldSecond)){
//                 query+=sourceFieldSecond+', ';
//             }
//             query+=sourceFieldName+' FROM '+sourceSObject+' WHERE Id IN :successRecordIds OR Id In :failedRecordIds';
//             List<sObject> sObjectList = Database.query(query);
//             System.debug('query '+query);
//             System.debug('sObjectList '+sObjectList);
//             if(sObjectList.size()>0){
//                 for(sObject obj : sObjectList){
//                     if(successRecordIds.contains(String.valueOf(obj.get('Id')))){
//                         if(sourceFieldName.contains('__r')){
//                             List<String> parentObjectAndFieldName = sourceFieldName.split('__r.');
//                             System.debug('parentObjectAndFieldName '+parentObjectAndFieldName);
//                             if(String.isNotBlank(sourceFieldSecond) && String.isNotEmpty(sourceFieldSecond)){
//                                 if(String.valueOf(obj.get(parentObjectAndFieldName[0]+'__c'))!=null){
//                                     processKeyId.add(String.valueOf(obj.getSObject(parentObjectAndFieldName[0]+'__r').get(parentObjectAndFieldName[1]))+'_'+String.valueOf(obj.get(sourceFieldSecond)));
//                                 }
//                             }
//                             else{
//                                 if(String.valueOf(obj.get(parentObjectAndFieldName[0]+'__c'))!=null){
//                                     processKeyId.add(String.valueOf(obj.getSObject(parentObjectAndFieldName[0]+'__r').get(parentObjectAndFieldName[1])));
//                                 }
//                             }
//                         }
//                         else{
//                             processKeyId.add(String.valueOf(obj.get(sourceFieldName)));
//                         }
//                     }
//                     if(failedRecordIdWithError.containsKey(String.valueOf(obj.get('Id')))){
//                         System.debug('Failed Record Id '+String.valueOf(obj.get('Id')));
//                         if(sourceFieldName.contains('__r')){
//                             List<String> parentObjectAndFieldName = sourceFieldName.split('__r.');
//                             if(String.isNotBlank(sourceFieldSecond) && String.isNotEmpty(sourceFieldSecond)){
//                                 if(String.valueOf(obj.get(parentObjectAndFieldName[0]+'__c'))!=null){
//                                     failedKeyId.add(String.valueOf(obj.getSObject(parentObjectAndFieldName[0]+'__r').get(parentObjectAndFieldName[1]))+'_'+String.valueOf(obj.get(sourceFieldSecond)));
//                                     uniqueKeyWithError.put(String.valueOf(obj.getSObject(parentObjectAndFieldName[0]+'__r').get(parentObjectAndFieldName[1]))+'_'+String.valueOf(obj.get(sourceFieldSecond)), failedRecordIdWithError.get(String.valueOf(obj.get('Id'))));
//                                 }
//                             }
//                             else{
//                                 if(String.valueOf(obj.get(parentObjectAndFieldName[0]+'__c'))!=null){
//                                     failedKeyId.add(String.valueOf(obj.getSObject(parentObjectAndFieldName[0]+'__r').get(parentObjectAndFieldName[1])));
//                                     uniqueKeyWithError.put(String.valueOf(obj.getSObject(parentObjectAndFieldName[0]+'__r').get(parentObjectAndFieldName[1])), failedRecordIdWithError.get(String.valueOf(obj.get('Id'))));
//                                 }
//                             }
//                         }
//                         else{
//                             System.debug('Inside Else');
//                             failedKeyId.add(String.valueOf(obj.get(sourceFieldName)));
//                             uniqueKeyWithError.put(String.valueOf(obj.get(sourceFieldName)), failedRecordIdWithError.get(String.valueOf(obj.get('Id'))));
//                         }
//                     }
//                 }
//                 System.debug('uniqueKeyWithError '+uniqueKeyWithError);
//                 System.debug('processKeyId '+processKeyId);
//                 System.debug('failedKeyId '+failedKeyId);
//                 String queryToStagingObject = 'SELECT Id, Status__c, Error_Reason__c, '+targetFieldName+' FROM '+targetSObject+' WHERE '+targetFieldName+' IN : processKeyId OR '+targetFieldName+' IN : failedKeyId';
//                 List<sObject> stagingSobjectToProcess = Database.query(queryToStagingObject);
//                 System.debug('stagingSobjectToProcess '+stagingSobjectToProcess);
//                 for(sObject stObj : stagingSobjectToProcess){
//                     if(processKeyId.contains(String.valueOf(stObj.get(targetFieldName)))){
//                         sObjectToDelete.add(stObj);
//                     }
//                     if(failedKeyId.contains(String.valueOf(stObj.get(targetFieldName)))){
//                         System.debug('');
//                         stObj.put('Status__c', 'Failed');
//                         stoBJ.put('Error_Reason__c', uniqueKeyWithError.get(String.valueOf(stObj.get(targetFieldName))));
//                         sObjectToUpdate.add(stObj);
//                     }
//                 }
//                 System.debug('sObjectToDelete '+sObjectToDelete);
//                 System.debug('sObjectToUpdate '+sObjectToUpdate);
//             }
//             if(sObjectToDelete.size() > 0){
//                 System.debug('sObjectToDelete Deleting...'+sObjectToDelete.size());
//                 System.debug('sObjectToDelete '+sObjectToDelete);
//                 List<Database.DeleteResult> deleteResult = Database.delete(sObjectToDelete);
//                 System.debug('delRes '+deleteResult);
//                 for(Database.DeleteResult dl : deleteResult){
//                     System.debug('Delete Success '+dl+' :: '+dl.isSuccess() + dl.getId());
//                 }
//                 //delete sObjectToDelete;
//                 System.debug('sObjectToDelete list Deleted.');
//             }
//             if(sObjectToUpdate.size() > 0){
//                 System.debug('sObjectToUpdate Updating...');
//                 List<Database.SaveResult> saveResult = Database.update(sObjectToUpdate);
//                 for(Database.SaveResult rs : saveResult){
//                     System.debug('Succes '+rs.isSuccess() + rs.getId());
//                 }
//                 //update sObjectToUpdate;
//                 System.debug('sObjectToUpdate list Updated.');
//             }
//         }
//     }
    
    // public static Capability__c updateCapability(sObject scope, Capability__c cap, String loanAppId){
    //     if(String.valueOf(scope.getSObjectType())=='Staging_Loan__c'){
    //         Staging_Loan__c s = (Staging_Loan__c)scope;
    //         if(String.isNotEmpty(loanAppId)){
    //             cap.Loan_Applicant__c = loanAppId; //getCustomerIds(new Set<String>{s.Neo_Cif_Id__c}).get(s.Neo_Cif_Id__c);
    //         }
    //         cap.Rental_Income__c = s.Rentral_Income__c;
    //         cap.Monthly_Salary__c = s.Salary_Income__c;
    //         cap.Neo_CIf_Id_Staging__c = s.Neo_Cif_Id__c;
    //         if(s.Pension_Income__c != null)
    //             cap.Income_per_month__c = s.Pension_Income__c;
    //         if(s.Other_Income__c != null)
    //             cap.Income_per_month__c = s.Other_Income__c;
    //         if(s.Nri_Income__c != null)
    //             cap.Income_per_month__c = s.Nri_Income__c;
    //     }
    //     return cap;
    // }
    
    public static Map<String, String> getDisbursalIds(Set<String> lans){
       	Map<String, String> disbursalIdsMap = new Map<String, String>();
        for(Disbursal__c dis : [SELECT Id, Application__r.LMS_Response_Reference__c FROM Disbursal__c WHERE Application__r.LMS_Response_Reference__c IN :lans]){
            disbursalIdsMap.put(dis.Application__r.LMS_Response_Reference__c, dis.Id);
        }
        return disbursalIdsMap;
    }
}