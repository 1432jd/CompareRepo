/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-04-07
* @modified         2022-07-15
* @TestClassName    FIV_C_ControllerTest
* @Description      This component is build to handle all the operations related to 
                    Verification-C in FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class FIV_C_Controller extends GenericDataTableController {

    /* ===========================Common Methods Starts=========================== */

    // This Method Is Used To Return Verification Object Details
    @AuraEnabled
    public static List<Verification__c> getVerification(String recordId){
        return [SELECT 
                Id, RecordTypeId, Application__c, Application__r.Name, Application__r.Requested_Loan_Amount__c, Result__c, Remarks_Declaration__c,
                Application__r.Pre_Login__r.RecordTypeId, Status__c, Is_applic_co_applic_related__c, Is_applicant_co_applicant_related_kn__c, Remarks__c 
                FROM Verification__c WHERE Id =: recordId AND RecordType.Name = 'FIV - C'];
    }
    
    // This Method Is Used To Return Account Map For Particular Application
    @AuraEnabled
    public static Map<Id,Account> getApplicantRecords(String appId){
        Set<String> applicantIds = new Set<String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: appId]){
            applicantIds.add(loanApplicant.Customer_Information__c);
        }
        
        return new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN : applicantIds]);
    }

    @AuraEnabled
    public static Boolean checkFIVCReport(String appId){
        List<ContentVersion> fivCReport = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =: appId AND File_Type__c='FIV - C Report'];
        return (fivCReport != NULL && !fivCReport.isEmpty());
    }

    // This Method Is Used To Return Applicant Map For Particular Application
    @AuraEnabled
    public static Map<Id,Loan_Applicant__c> getApplicantList(String appId){
        return new Map<Id,Loan_Applicant__c>([SELECT Id, Application__c, Customer_Information__c, Customer_Information__r.Name, Customer_Type__c, Income_Considered__c FROM Loan_Applicant__c WHERE Application__c =: appId ]);
    }

    // This Method Is Used To Return Applicant Map For Particular Application
    @AuraEnabled
    public static Map<Id,Loan_Applicant__c> getLoanApplicantRecords(String appId){
        Map<Id,Loan_Applicant__c> loanApplicantMap = new Map<Id,Loan_Applicant__c>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Application__c, Customer_Information__c, Customer_Information__r.Name, Customer_Type__c FROM Loan_Applicant__c WHERE Application__c =: appId]){
            loanApplicantMap.put(loanApplicant.Customer_Information__c, loanApplicant);
        }
        return loanApplicantMap;
    }

    // This Method Is Used To Return Property-Enquiry Map For Particular Application
    @AuraEnabled
    public static Map<Id,List<CommonObject__c>> getEnquiryMap(String appId){
        Map<Id,List<CommonObject__c>> propertyEnquiryMap = new Map<Id,List<CommonObject__c>>();
        for(CommonObject__c cobj : [SELECT Id, Property__c, Object_Type__c, Enquiry_Name__c, Enquiry_Contact_Number__c, Enquiry_Market_Value__c FROM CommonObject__c WHERE Application__c =: appId AND Object_Type__c='Enquiry']){
            if(!propertyEnquiryMap.containsKey(cobj.Property__c)){
                propertyEnquiryMap.put(cobj.Property__c, new List<CommonObject__c>());
            }
            propertyEnquiryMap.get(cobj.Property__c).add(cobj);
        }
        
        return propertyEnquiryMap;
    }
    /* ===========================Common Tab Methods Ends=========================== */


    /* ===========================Character Tab Methods Starts=========================== */

    // This Method Is Used To Return Verification Pending Accounts For Table 
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getPendingAccounts(String applicationId){
        System.debug('applicationId=  '+applicationId);
        Set<String> accIds = new Set<String>();
        for(Loan_Applicant__c acc : [SELECT Id FROM Loan_Applicant__c WHERE Application__c  =: applicationId]){
            accIds.add(acc.Id); 
        }
        
        System.debug('accIds=  '+accIds);
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'Loan_Applicant'; 
        genericDTObj.IDS_SET = accIds;
        genericDTObj.WHERE_CLAUSE = ' ID IN : IDS_SET';
        return genericDTObj.getTable();     
    }

    // This Method Is Used To Return Character Section Data For Tables
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCharacterTabRecords(String appId, String metadataName ,String sectionName){
        String rcId = Schema.getGlobalDescribe().get('Character__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Character').getRecordTypeId();
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = metadataName;
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(appId);
        genericDTObj.IDS_SET.add(rcId);
        genericDTObj.IDS_SET.add(sectionName);
        genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET AND Section_Type__c IN : IDS_SET';
        return genericDTObj.getTable();
    }
    /* ===========================Character Tab Methods ends=========================== */


    /* ===========================Collateral Tab Methods Starts=========================== */
    
    // This Method Is Used To Return FIV-C record Id For Property Object.
    @AuraEnabled
    public static string getFIV_CRecordTypeId(){
        return Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
    }

    // This Method Is Used To Return Property Records Map.
    @AuraEnabled
    public static Map<Id, Property__c> getPropertyRecords(String appId, String loanApplicationId){
        return new Map<Id, Property__c>([SELECT Id, Name, Login__c FROM Property__c WHERE Application__c =: appId AND RecordType.Name = 'Pre Login Property Detail']);
    }

    // This Method Is Used To Return Collateral Section Data For Tables
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCollateralTabRecords(String appId, String metadataName){      
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = metadataName;
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(appId);
        String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        genericDTObj.IDS_SET.add(rcId);
        genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET';
        return genericDTObj.getTable();
    }

    // This Method Is Used To Return Collateral-Enquiry Section Data For Table
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCollateralEnquiryRecords(String appId, String propertyId){      
        GenericDataTableController genericDTObj = new GenericDataTableController();
        genericDTObj.METADATA_NAME = 'FIV_C_Col_Enquiry';
        genericDTObj.IDS_SET = new Set<String>();
        genericDTObj.IDS_SET.add(appId);
        genericDTObj.IDS_SET.add(propertyId);
        genericDTObj.IDS_SET.add('Enquiry');
        genericDTObj.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND Property__c IN : IDS_SET AND Object_Type__c IN : IDS_SET';
        return genericDTObj.getTable();
    }
    /* ===========================Collateral Tab Methods ends=========================== */


    /* ===========================Capability Tab Methods Starts=========================== */

    // This Method Is Used To Return Capability Section Data For Table
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getCapabiltyData(String recordId){
        
        GenericDataTableController genericDTObjNeighbour = new GenericDataTableController();
        genericDTObjNeighbour.METADATA_NAME = 'FIV_C_Capabilty';
        String rcId = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        genericDTObjNeighbour.IDS_SET = new Set<String>();
        genericDTObjNeighbour.IDS_SET.add(recordId);
        genericDTObjNeighbour.IDS_SET.add(rcId);
        genericDTObjNeighbour.WHERE_CLAUSE = ' Application__c IN : IDS_SET AND RecordTypeId IN : IDS_SET';
        return genericDTObjNeighbour.getTable();
    } 

    // This Method Is Used To Return Collateral Summary Data
    @AuraEnabled
    public static List<Property__c> getCollateralSummary(String applicationId){
        String rcId = Schema.getGlobalDescribe().get('Property__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Property Detail').getRecordTypeId();
        List<Property__c> propertyList = new List<Property__c>();
        propertyList = [SELECT Id, Name, Valuation_Final_land_value__c, Land_Measurement_total_area__c,
                        Total_Collateral_Value__c, Total_Floor_Value__c,
                        Adopted_Value_Per_SqFt__c, Total_Floor_Area__c, Avg_Floor_Value_Per_Sq_Ft__c,
                        (SELECT Id FROM Enquiries__r WHERE Object_Type__c='Building Floors')
                        FROM Property__c
                        WHERE Application__c =: applicationId
                        AND RecordTypeId =: rcId];
        Decimal totalLandArea = 0;
        Decimal totalBuildingArea = 0;
        Decimal totalValue = 0;
        for(Property__c pro : propertyList){
            if(pro.Enquiries__r != NULL && pro.Enquiries__r.size() > 1){
                pro.Avg_Floor_Value_Per_Sq_Ft__c = null;
            }
            if(pro.Land_Measurement_total_area__c != NULL){
                totalLandArea = totalLandArea + pro.Land_Measurement_total_area__c;
            }
            if(pro.Total_Floor_Area__c != NULL){
                totalBuildingArea = totalBuildingArea + pro.Total_Floor_Area__c;
            }
            if(pro.Total_Collateral_Value__c != NULL){
                totalValue = totalValue + pro.Total_Collateral_Value__c;
            }
        }
        
        Application__c app = new Application__c();
        app.ID = applicationId;
        app.FIVC_Total_Land_Area__c = totalLandArea;
        app.FIVC_Total_Building_Area__c = totalBuildingArea;
        app.FIVC_Final_Collateral_Value__c = totalValue;
        update app;
        return propertyList;
    }

    // This Method Is Used To Return Capability Summary Data
    @AuraEnabled
    public static IncomeSummary getIncomeSummary(String applicationId, String verificationId){
        IncomeSummary incomeObj = new IncomeSummary();
        String rcId = Schema.getGlobalDescribe().get('Capability__c').getDescribe().getRecordTypeInfosByName().get('FIV-C Capability').getRecordTypeId();
        Set<String> customerIds = new Set<String>();
        Set<String> loanApplicationId = new Set<String>();
        for(Loan_Applicant__c loanApplicant : [SELECT Id, Customer_Information__c FROM Loan_Applicant__c WHERE Application__c =: applicationId]){
            customerIds.add(loanApplicant.Customer_Information__c);
            loanApplicationId.add(loanApplicant.Id);
        }
        incomeObj.allObligations = 0;
        Set<String> bureauHighmarkIdSet = new Set<String>();
        for(Bureau_Highmark__c highmarkRecord : [SELECT Id,Loan_Applicant__c FROM Bureau_Highmark__c WHERE Loan_Applicant__c IN (SELECT Id FROM Loan_Applicant__c WHERE Application__c =:applicationId)]) {
            bureauHighmarkIdSet.add(highmarkRecord.Id);
        }
        String loanDetailRecordTypeId = Schema.getGlobalDescribe().get('Loan_Details__c').getDescribe().getRecordTypeInfosByName().get('Loan Details').getRecordTypeId();
        for(Loan_details__c loanObj:[SELECT Id,Obligations__c,To_be_considerd_for_DBR__c,Stage__c FROM Loan_Details__c WHERE Bureau_Highmark__c IN:bureauHighmarkIdSet AND RecordTypeId =:loanDetailRecordTypeId ])
        {
            if(loanObj.To_be_considerd_for_DBR__c == 'Yes' && (String.isEmpty(loanObj.Stage__c) || loanObj.Stage__c =='FIV - C'))
            {
                incomeObj.allObligations += (loanObj.Obligations__c!=null?loanObj.Obligations__c:0); 
            }
        }
        List<Capability__c> capabilities = new List<Capability__c>();
        capabilities = [SELECT Id, Customer_Information__c, Income_segment__c,
                        Subsegment__c, Year_of_Occupation__c, Proof__c, Proof_Remarks__c, Other_Confirmations__c,
                        Income_per_month__c, Income_Remarks__c, Business_Reference_Name__c, Business_Reference_Contact_Number__c,
                        Feedback__c, Business_Reference_Remarks__c, Monthly_Salary__c, Rental_Income__c,
                        Income_per_day__c, Number_of_days__c, Day_Margin_Basis__c, Sales_per_month__c, Margin__c,
                        Loan_Applicant__c, Loan_Applicant__r.Customer_Information__c, Loan_Applicant__r.Customer_Information__r.Name,
                        Electricity__c, Rent__c, Others__c, Salary__c,Income_per_month_Pension__c
                        FROM Capability__c 
                        WHERE Application__c =: applicationId AND RecordTypeId =: rcId Order BY Loan_Applicant__r.Customer_Information__r.Name];

        List<IncomeWrapper> incomeDetails = new List<IncomeWrapper>();
        Map<Id, Decimal> applicantIncomeMap = new Map<Id, Decimal>();
        for(Capability__c cap : capabilities){
            IncomeWrapper incWrapObj = new IncomeWrapper();
            incWrapObj.applicantName = cap.Loan_Applicant__r.Customer_Information__r.Name;
            incWrapObj.incomeSegment = cap.Income_segment__c; 
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
            } else if(cap.Income_segment__c == 'Income from Abroad'){
                cap.Income_per_month__c = cap.Income_per_month__c != null ? cap.Income_per_month__c : 0;
                monthlyIncome = Integer.valueOf(cap.Income_per_month__c);
            } else if(cap.Income_segment__c == 'Pension'){
                monthlyIncome = cap.Income_per_month_Pension__c != null ? Integer.valueOf(cap.Income_per_month_Pension__c) : 0;
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
            incomeObj.totalMonthlyIncome += monthlyIncome;
			
            Decimal applicantsIncome= 0;
            if(cap.Loan_Applicant__c != NULL && applicantIncomeMap.containsKey(cap.Loan_Applicant__c)){
                applicantsIncome += applicantIncomeMap.get(cap.Loan_Applicant__c);
                applicantIncomeMap.put(cap.Loan_Applicant__c,applicantsIncome);
            }else if(cap.Loan_Applicant__c != NULL && !applicantIncomeMap.containsKey(cap.Loan_Applicant__c)){
                applicantIncomeMap.put(cap.Loan_Applicant__c,monthlyIncome);
            }	
            
            incomeObj.incomeList.add(incWrapObj);
        }
        System.debug('incomeObj ='+incomeObj);
        incomeObj.netMonthlyIncome = incomeObj.totalMonthlyIncome - incomeObj.allObligations;
        Verification__c objVer = new Verification__c();
        objVer.Total_Income__c = incomeObj.totalMonthlyIncome;
        objVer.Id = verificationId;
        Update objVer;
        
        if(!applicantIncomeMap.isEMpty()){
            List<Loan_Applicant__c> loanApplicantToUpdate = new List<Loan_Applicant__c>();
            for(Id applicantId : applicantIncomeMap.keySet()){
                loanApplicantToUpdate.add(new Loan_Applicant__c(Id=applicantId,Gross_Income_PC__c= applicantIncomeMap.get(applicantId)));                
            }             
            if(!loanApplicantToUpdate.isEmpty()){
                update loanApplicantToUpdate;
            }            
        }        
        
        Application__c app = new Application__c();
        app.ID = applicationId;
        app.FIVC_Gross_Income__c = incomeObj.totalMonthlyIncome;
        app.FIVC_Total_Obligations__c = incomeObj.allObligations;
        app.FIVC_Net_Income__c = incomeObj.netMonthlyIncome;
        update app;
        
        return incomeObj;
    }
    /* ===========================Capability Tab Methods ends=========================== */


    /* ===========================Revisit Tab Methods Starts=========================== */
    // This Method Is Used To Return Revisit/Senior Revisit Section Data For Table
    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getRevisitData(String recordId, String metadataName, String type){       
        GenericDataTableController genericDTObjNeighbour = new GenericDataTableController();
        genericDTObjNeighbour.METADATA_NAME = metadataName;
        genericDTObjNeighbour.IDS_SET = new Set<String>();
        genericDTObjNeighbour.IDS_SET.add(recordId);
        genericDTObjNeighbour.IDS_SET.add(type);
        genericDTObjNeighbour.WHERE_CLAUSE = ' Verification__c IN : IDS_SET AND Revisit_Type__c IN : IDS_SET';
        return genericDTObjNeighbour.getTable();
    } 
    /* ===========================Revisit Tab Methods ends=========================== */


    /* ===========================Document Upload Tab Methods Starts=========================== */
    
    // This Method Is Used To Generate Public Link For Uploaded Document IN FIV-C
    @AuraEnabled
    public static string generatePublicLink(String contentVersionId){
        try{
            ContentVersion cv = [SELECT Id, ContentDocumentId, Title, FileType, FileExtension, ContentSize FROM ContentVersion WHERE Id =:contentVersionId AND FileExtension IN ('jpg','jpeg','png','tiff','tif') LIMIT 1];
            cv.Uploaded_From__c = 'FIV-C';
            update cv;
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            return 'success';
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /* ===========================Document Upload Tab Methods Ends=========================== */


    /* ===========================Wrapper Classes Starts===========================*/
    public class IncomeWrapper{
        @AuraEnabled public String applicantName;
        @AuraEnabled public String incomePerMonth;
		@AuraEnabled public String incomeSegment;
        public IncomeWrapper(){
            applicantName = '';
            incomePerMonth = '';
            incomeSegment ='';
        }
    }

    public class IncomeSummary{
        @AuraEnabled public List<IncomeWrapper> incomeList;
        @AuraEnabled public Decimal totalMonthlyIncome;
        @AuraEnabled public Decimal allObligations;
        @AuraEnabled public Decimal netMonthlyIncome;

        public IncomeSummary(){
            incomeList = new List<IncomeWrapper>();
            totalMonthlyIncome = 0;
            allObligations = 0;
            netMonthlyIncome = 0;
        }
    }
}