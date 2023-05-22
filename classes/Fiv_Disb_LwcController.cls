/**
 * @author            : Karan Singh Soni
 * @group             : TechMatrix Consulting
 * @description       : This is an main class for the Disbursal Maker and Disbursal Author Components -
 * @created on        : 12-07-2022
 * @last modified on  : 12-10-2022
 * @last modified by  : Karan Singh Soni
**/
/* *Changes
 * Karan Singh : 11-10-2022 : CH01 - changed the Beneficiary IFSC Code from lookup to text field and change in IFSC API
 *             : 12-10-2022 : CH01 - Continuation
*/
public without sharing class Fiv_Disb_LwcController extends GenericFormBuilderController{

    /**
    * @description : This is used to get the existing records of insurance details of application.
    * @author Neeraj Soni | 01-09-2022
    * @param applicationId
    * @return label-value pair of loan applicant names
    **/
    @AuraEnabled
    public static List<Insurance_Details__c> getInsuranceDetailRecords(String applicationId){
        return [Select Insurance_Waiver__c, Insured_Person_Date_of_Birth__c,Nominee_Type__c,
            NomineeName__c,Insured_Person__c,
            Nominee_Relationship_Type__c, Nominee_KYC_ID_Type__c, Nominee_KYC_ID_No__c, Nominee_DOB_as_per_KYC__c,
            Nominee_Relationship_with_Insured_Person__c,Nominee_Name__c, Insured_Person_Name__c, Part_of_Loan__c, Not_Part_of_Loan__c,
            Insurance_Requirement__c, Insurance_Medical_Test_Result__c, Id, Application__c, Application__r.id
            from Insurance_Details__c where Application__r.id =:applicationId ];
    }

    /**
    * @description : This is used to get the naames of Loan Applicants related to an Application.
    * @author Neeraj Soni | 01-09-2022
    * @param applicationId
    * @return label-value pair of loan applicant names
    **/
    @AuraEnabled
    public static List<String> getLoanApplicantnames(String applicationId){
        List<String> loanApplicantNames = new List<String>();
        List<Application__c> applicationRecords = [Select Id, (select id, Customer_Type__c, Applicant_Type__c,
                                                               Applicant_Name__c from Loan_Applicants__r)
                                                   from Application__c where id =:applicationId LIMIT 1];
        if(applicationRecords.size() > 0){
            for(Loan_Applicant__c applicantRec: applicationRecords.get(0).Loan_Applicants__r){
                loanApplicantNames.add(applicantRec.Applicant_Name__c+'_'+applicantRec.Id);
            }
        }
        return loanApplicantNames;
    }

    @AuraEnabled
    public static List<Loan_Applicant__c> getLoanApplicants(String applicationId){
        return [SELECT Id, Applicant_Name__c FROM Loan_Applicant__c WHERE Application__c =: applicationId];
    }

    @AuraEnabled
    public static Map<String, Date> getLoanApplicantDOB(String applicationId){
        Map<String, Date> loanApplicantDOBs = new Map<String, Date>();
        List<Application__c> applicationRecords = [Select Id, (select id, Dob__c, Customer_Type__c, Applicant_Type__c,
                                                               Applicant_Name__c from Loan_Applicants__r)
                                                   from Application__c where id =:applicationId LIMIT 1];
        if(applicationRecords.size() > 0){
            for(Loan_Applicant__c applicantRec: applicationRecords.get(0).Loan_Applicants__r){
                loanApplicantDOBs.put(applicantRec.Applicant_Name__c, applicantRec.Dob__c);
            }
        }
        return loanApplicantDOBs;
    }

    @AuraEnabled
    public static Insurance_Details__c  getNominee(String applicationId){
      //  List<Application__c> applicationRecords = [Select Id,Nominee_Party__c, Name__c, Nominee_Relationship_Type__c, Nominee_Party_Relationship_with_Insured__c, Nominee__c from Application__c where id =:applicationId LIMIT 1];
        List<Insurance_Details__c> applicationRecords = [select Id,NomineeName__c,Insured_Person__c,Insurance_Requirement__c,Insurance_Medical_Test_Result__c,Nominee_KYC_ID_Type__c,Insured_Person_Name__c,Nominee_Type__c,Nominee_Name__c,Nominee_Relationship_with_Insured_Person__c,Nominee_KYC_ID_No__c,Nominee_DOB_as_per_KYC__c,Insurance_Waiver__c,Application__r.Nominee_Party__c,Application__r.Nominee__c,Nominee_Relationship_Type__c,Application__r.Nominee_Relationship_Type__c,Application__r.Nominee_Party_Relationship_with_Insured__c,Application__r.Name__c,Application__r.Insurance_Requirement__c,Application__r.Insurance_Medical_Test_Result__c from Insurance_Details__c where Application__c=:applicationId];
        if(applicationRecords.size()>0){
            return applicationRecords[0];
        }
        return null;
    }


    @AuraEnabled
    public static List<Application__c> getAppStage(String apptId){
        List<Application__c> appList = new List<Application__c>();
        try {
            appList =[select Id,Stage__c,Sourcing_Branch__c, LMS_Response_Reference__c from Application__c where Id=:apptId LIMIT 1];
           if(appList.size()>0){
             return appList;
           }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
         return null;
    }

    @AuraEnabled
    public static List<insuranceWrap> getInsuranceDetailsData(String appId){
        try {
            
            List<insuranceWrap> insuranceWrapperObj = new List<insuranceWrap>();
            insuranceWrap obj = new insuranceWrap();

            List<Insurance_Details__c>insList = [select Id,NomineeName__c,Insured_Person__c,Insurance_Requirement__c,Insurance_Medical_Test_Result__c,Nominee_KYC_ID_Type__c,Insured_Person_Name__c,Nominee_Type__c,Nominee_Name__c,Nominee_Relationship_with_Insured_Person__c,Nominee_KYC_ID_No__c,Nominee_DOB_as_per_KYC__c,Insurance_Waiver__c,Application__r.Nominee_Party__c,Application__r.Nominee__c,Nominee_Relationship_Type__c,Application__r.Nominee_Relationship_Type__c,Application__r.Nominee_Party_Relationship_with_Insured__c,Application__r.Name__c,Application__r.Insurance_Requirement__c,Application__r.Insurance_Medical_Test_Result__c from Insurance_Details__c where Application__c=:appId];
            List<Loan_Applicant__c> loanList =[select Id,Dob__c,Applicant_Name__c,KYC_Id_1__c,KYC_ID_Type_1__c from Loan_Applicant__c where Application__c=:appId];
            Map<String,Loan_Applicant__c> dobMaps = new Map<String,Loan_Applicant__c>();
            
            System.debug('insList is >>>'+insList);
            System.debug('loanList is >>>'+loanList);

            if(loanList.size()>0){
                for(Loan_Applicant__c loanObj : loanList){
                    dobMaps.put(loanObj.Applicant_Name__c,loanObj);
                }
            }
           
            System.debug('dobMaps is >>>'+dobMaps);
           
            if(insList.size()>0){

           // if(/*insList[0].Application__r.Nominee_Party__c!=null*/insList[0].Nominee_Name__c!=null){
                //commented to get insurance data data
               /* if(dobMaps.containsKey(insList[0].Application__r.Nominee_Party__c)){
                    obj.NomineeKYCIDNo=dobMaps.get(insList[0].Application__r.Nominee_Party__c).KYC_Id_1__c;
                    obj.NomineeKYCIDType=dobMaps.get(insList[0].Application__r.Nominee_Party__c).KYC_ID_Type_1__c;
                    obj.NomineeDOB=String.valueOf(dobMaps.get(insList[0].Application__r.Nominee_Party__c).Dob__c);
                }else{*/
                    obj.NomineeKYCIDNo = insList[0].Nominee_KYC_ID_No__c!=null?insList[0].Nominee_KYC_ID_No__c:'';
                    obj.NomineeKYCIDType = insList[0].Nominee_KYC_ID_Type__c!=null?insList[0].Nominee_KYC_ID_Type__c:'';
                    obj.NomineeDOB = insList[0].Nominee_DOB_as_per_KYC__c!=null?String.valueOf(insList[0].Nominee_DOB_as_per_KYC__c):'';
                //}
           // }

           /* if(insList[0].Application__r.Name__c!=null){
                if(dobMaps.containsKey(insList[0].Application__r.Name__c)){
                    obj.InsuredPersonDateofBirth=String.valueOf(dobMaps.get(insList[0].Application__r.Name__c).Dob__c);
                }else{
                    obj.InsuredPersonDateofBirth='';
                }
            }*/

            if(insList[0].Insured_Person_Name__c!=null){
                if(dobMaps.containsKey(insList[0].Insured_Person_Name__c)){
                    obj.InsuredPersonDateofBirth=String.valueOf(dobMaps.get(insList[0].Insured_Person_Name__c).Dob__c);
                }else{
                    obj.InsuredPersonDateofBirth='';
                }
            }


              obj.Id = insList[0].Id;
              obj.InsuranceMedicalTestResult=insList[0].Insurance_Medical_Test_Result__c!=null?insList[0].Insurance_Medical_Test_Result__c:'';
              obj.InsuranceRequirement=insList[0].Insurance_Requirement__c!=null?insList[0].Insurance_Requirement__c:'';
              obj.InsuredPersonName=insList[0].Insured_Person_Name__c!=null?insList[0].Insured_Person_Name__c:'';
              obj.NomineeName=insList[0].Nominee_Name__c!=null?insList[0].Nominee_Name__c:'';
              obj.NomineeRelationshipType=insList[0].Nominee_Relationship_Type__c!=null?insList[0].Nominee_Relationship_Type__c:'';
              obj.NomineeRelationshipwithInsuredPerson=insList[0].Nominee_Relationship_with_Insured_Person__c!=null?insList[0].Nominee_Relationship_with_Insured_Person__c:'';
              obj.NomineeType = insList[0].Nominee_Type__c!=null?insList[0].Nominee_Type__c:'';
              //  obj.InsuranceMedicalTestResult=insList[0].Application__r.Insurance_Medical_Test_Result__c!=null?insList[0].Application__r.Insurance_Medical_Test_Result__c:'';
              //  obj.InsuranceRequirement=insList[0].Application__r.Insurance_Requirement__c!=null?insList[0].Application__r.Insurance_Requirement__c:'';
                obj.InsuranceWaiver=insList[0].Insurance_Waiver__c!=null?insList[0].Insurance_Waiver__c:'';
              //  obj.InsuredPersonName=insList[0].Application__r.Name__c!=null?insList[0].Application__r.Name__c:'';
              //  obj.NomineeName=insList[0].Application__r.Nominee_Party__c!=null?insList[0].Application__r.Nominee_Party__c:'';
              //  obj.NomineeRelationshipType=insList[0].Application__r.Nominee_Relationship_Type__c!=null?insList[0].Application__r.Nominee_Relationship_Type__c:'';
             //   obj.NomineeRelationshipwithInsuredPerson=insList[0].Application__r.Nominee_Party_Relationship_with_Insured__c!=null?insList[0].Application__r.Nominee_Party_Relationship_with_Insured__c:'';
                
             /*   if(String.isNotBlank(insList[0].Application__r.Nominee__c) && String.isNotEmpty(insList[0].Application__r.Nominee__c) && insList[0].Application__r.Nominee__c!=null){
                    if(insList[0].Application__r.Nominee__c == 'Yes'){
                        obj.NomineeType = 'Part of Loan';
                    }else if(insList[0].Application__r.Nominee__c == 'No'){
                        obj.NomineeType = 'Not Part of Loan';
                    }
                }else{
                    obj.NomineeType = '';
                }*/

                insuranceWrapperObj.add(obj);
                System.debug('insuranceWrapperObj is >>>'+insuranceWrapperObj);
                return insuranceWrapperObj;

            }
            return null;
        } catch (Exception e) {
            System.debug('the exception is >>>'+e.getMessage());
            System.debug('the exception line is >>>'+e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static Boolean checkLoggedInUser(){
            List<User> userList=[select Id,profile.name from User where Id=:UserInfo.getUserId()];

                if(userList[0].profile.name=='System Administrator'){
                    return true;
                }
        return false;
    }

    @AuraEnabled
    public static List<Loan_Applicant__c> getApplicantsAcData(String apptId,String applicantName){
        List<Loan_Applicant__c> appList = new List<Loan_Applicant__c>();
        try {
            appList =[select Id,Dob__c from Loan_Applicant__c where Application__c=:apptId AND Applicant_Name__c=:applicantName AND Dob__c!=NULL LIMIT 1];
           if(appList.size()>0){
             return appList;
           }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
         return null;
    }

     @AuraEnabled
    public static List<Disbursal__c> getDueDateError(String apptId){
        List<Disbursal__c> disbList = new List<Disbursal__c>();
        try {
           disbList =[select Id,Disbursal_Beneficiary_Type__c,Disbursal_Type__c,Due_Date__c,First_Installment_Date__c,Interest_Start_Date__c from Disbursal__c where Application__c=:apptId LIMIT 1];
           if(disbList.size()>0){
             return disbList;
           }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
         return disbList;
    }

    /**
    * @description : This is used to invoke generic edit form logic.
    * @author Karan Singh Soni | 02-08-2022
    * @param recordIds - record id of the object mentioned in the metadata
    * @param metaDetaName - Name of the Generic_Detail_Page__mdt record which will have Generic_Detail_Page_Content__mdt fields
    * @return GenericFormBuilderController.InitWrapper
    * prerequistic - create Generic_Detail_Page__mdt and Generic_Detail_Page_Content__mdt records for testing
    **/
    @AuraEnabled
    public static GenericFormBuilderController.InitWrapper getMetaDataFields(String recordIds, String metaDetaName){
        Fiv_Disb_LwcController obj = new Fiv_Disb_LwcController();
        obj.METADATA_NAME = metaDetaName;
        obj.IDS_SET = new Set<String>();
        if(String.isNotEmpty(recordIds)){
            obj.IDS_SET = new Set<String>();
            obj.IDS_SET.addAll(recordIds.split('_'));
            obj.WHERE_CLAUSE = ' Id IN : IDS_SET';
            obj.RECORD_LIMIT = '1';
        }
        return obj.initialize();//getSectionContent();
    }



    /**
    * @description
    * @author Karan Singh Soni | 02-08-2022
    * @param recordId
    * @param childObjectName
    * @param parentObjectName
    * @param parentWhereRecdCondn
    * @param listPrntConditions
    * @param listChildConditions
    * @return DisbursalCompWrap
    **/
    @AuraEnabled
    public static DisbursalCompWrap getParentAndRelatedData( String recordId ,String childObjectName,String parentObjectName, String parentWhereRecdCondn , List<String> listPrntConditions,List<String> listChildConditions){
        System.debug('inside cycle date is >>>>>');
        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        String schemeRecdTypDisb = 'Disbursal_Parameters';
        String businessDate = System.Label.Business_Date;
        Date disbursementDate = Date.parse(businessDate);
        Date cycleDate;

        if( String.isBlank(recordId) ){
            objDisbursalCompWrap.statusCode = 400;
            objDisbursalCompWrap.message = 'Invalid Record Id.';
            return objDisbursalCompWrap;
        }
        if( String.isBlank(parentWhereRecdCondn) ){
            parentWhereRecdCondn = 'ID';
        }

        String strPrntWithChildQuery =  'SELECT Id,Name,( SELECT Id,Name FROM {0} ORDER BY CreatedDate DESC {1} ) FROM {2} WHERE '+parentWhereRecdCondn+' =: recordId';

        if( !listPrntConditions.isEmpty() ){
            for( String conditionId : listPrntConditions ){
                strPrntWithChildQuery += ' AND ' + conditionId.split('--')[0] +' =\''+conditionId.split('--')[1] + '\'';
            }

        }
        if( !listChildConditions.isEmpty() ){
            List<String> listqueryStr = strPrntWithChildQuery.split('ORDER');
            System.debug('listqueryStr ' + listqueryStr );
            String queryChildConds = '';

            for( String conditionId : listChildConditions ){
                system.debug( 'conditionId ' + conditionId );
                if( !listqueryStr[0].contains('WHERE') ){

                    queryChildConds += ' WHERE ' + conditionId.split('--')[0] +' =\''+conditionId.split('--')[1] + '\'';
                }else{
                    queryChildConds += ' AND ' + conditionId.split('--')[0] +' =\''+conditionId.split('--')[1] + '\'';
                }
            }
            strPrntWithChildQuery = listqueryStr[0] + queryChildConds + ' ORDER ' + listqueryStr[1];

        }

        try {

            //bydeault we will be calling disbursal records
            if( String.isBlank(childObjectName) && String.isBlank(parentObjectName)){

                strPrntWithChildQuery = String.format(strPrntWithChildQuery, new List<Object>{'Disbursals__r', 'LIMIT 1','Application__c'});

                //adding more fields in Applications for inital load up
                strPrntWithChildQuery = strPrntWithChildQuery.replace( 'FROM Application__c' , ',Stage__c,LMS_Response_Reference__c,Emi_PcAc__c,Loan_Amount__c,Amount_Recommended__c,Nach_Party__c,Nach_Party_2__c,NACH_Party_1_ID__c,NACH_Party_2_ID__c,Pre_Login__c,Total_Amount_Recommended_PcAc__c,Customer_Communicated__c,Margin_ROI__c,Tenor_In_Months__c,Tranche_Disbursal__c,AC_Submission_Date__c,Name__c FROM Application__c');
            }else{

                strPrntWithChildQuery = String.format(strPrntWithChildQuery, new List<Object>{ childObjectName, '' , parentObjectName});

                if( childObjectName == 'Disbursal_Repayment_Details__r' ){

                    //adding more fields in Disbursal_Repayment_Detail__c
                strPrntWithChildQuery = strPrntWithChildQuery.replace( 'FROM Disbursal_Repayment_Details__r' , ', NACH_Party_Type__c FROM Disbursal_Repayment_Details__r');
                }
            }
            System.debug('strPrntWithChildQuery -> ' + strPrntWithChildQuery);
            List< Sobject > listSobject = Database.query(strPrntWithChildQuery);

            if( listSobject.isEmpty() ){
                objDisbursalCompWrap.statusCode = 400;
                objDisbursalCompWrap.message = 'No Data found.';
            }else{

                //incase of application get the related records of application and fill the map for auto population
                if( Id.valueOf(String.valueOf( listSobject[0].get('Id') )).getSobjectType()
                    == Schema.Application__c.getSObjectType()){
                        //need to do this else many existing got affected
                    objDisbursalCompWrap.objAppt = (Application__c)listSobject[0];

                    if( objDisbursalCompWrap.objAppt.Stage__c == 'Disbursal Maker' ){

                        objDisbursalCompWrap.disbMetaPrefix = 'DISBM_';

                    }else if( objDisbursalCompWrap.objAppt.Stage__c == 'Disbursal Author' ){

                        objDisbursalCompWrap.disbMetaPrefix = 'DISBA_';
                    }

                    //Karan SIngh : 28-09-2022 : CH - (NP-17-09-22) - N
                    if( objDisbursalCompWrap.objAppt.Name__c <> Null ){
                        objDisbursalCompWrap.mapExtraParams.put( 'insuredPersonName',objDisbursalCompWrap.objAppt.Name__c);

                    }else{
                        objDisbursalCompWrap.mapExtraParams.put( 'insuredPersonName','');
                    }
                    //==========================================================
                    //starting of code added by sandeep kumar//

                for( MS_Scheme__c objSchemeMaster : [ SELECT Id,Cycle_Date_Type__c, Due_Date__c, First_Installment_Date__c, Interest_Start_Date__c
                                                                            FROM MS_Scheme__c
                                                                            ORDER BY CreatedDate DESC LIMIT 1])
                {
                    if(objSchemeMaster.Cycle_Date_Type__c == 'Range'){

                    for(Cycle_Date__mdt objMdt : [SELECT Id, From__c, To__c, Cycle_Date__c
                                                 FROM Cycle_Date__mdt]){
                        System.debug('From '+Integer.valueOf(objMdt.From__c)+' To '+Integer.valueOf(objMdt.To__c)+' Disb Date '+disbursementDate.day());
                                                     System.debug('disbursement monthe is >>>'+disbursementDate.month());
                        if(disbursementDate.day() >= Integer.valueOf(objMdt.From__c) && disbursementDate.day() <= Integer.valueOf(objMdt.To__c) && disbursementDate.month()==12){
                            System.debug('Inside '+Integer.valueOf(objMdt.Cycle_Date__c));
                            cycleDate = date.newinstance(disbursementDate.year(),disbursementDate.month(),Integer.valueOf(objMdt.Cycle_Date__c));
                            System.debug('cycleDate '+cycleDate.day()+'/'+cycleDate.month()+'/'+cycleDate.year());
                        }else if(disbursementDate.day() >= Integer.valueOf(objMdt.From__c) && disbursementDate.day() <= Integer.valueOf(objMdt.To__c) ){
                            cycleDate = date.newinstance(disbursementDate.year(),disbursementDate.month(),Integer.valueOf(objMdt.Cycle_Date__c));
                        }
                    }

                    if(cycleDate == null){
                        if(disbursementDate.day()>20 && disbursementDate.day()<=31){
                            cycleDate = date.newinstance(disbursementDate.year(),disbursementDate.month()+1,05);
                        }
                    }

                    Date firstInstlmntDate = date.newinstance(cycleDate.year(),cycleDate.month()+1,cycleDate.day());

                    System.debug('cycle date is >>>>>'+cycleDate);
                    //ending of code added by sandeep kumar//

                    //----------------------------------------------------------
                    //need to auto populate
                    

                            objDisbursalCompWrap.mapExtraParams.put( 'Due_Date__c',''+String.valueOf(cycleDate).remove(' 00:00:00'));
                            objDisbursalCompWrap.mapExtraParams.put( 'First_Installment_Date__c',''+String.valueOf(firstInstlmntDate).remove(' 00:00:00'));
                            objDisbursalCompWrap.mapExtraParams.put( 'Interest_Start_Date__c',''+String.valueOf(cycleDate).remove(' 00:00:00'));
                }else if(objSchemeMaster.Cycle_Date_Type__c == 'EOM'){
                    
                    Integer month = disbursementDate.month();
                    Integer day = disbursementDate.day();
                    Integer year = disbursementDate.year();
                    Date finalEomDate = Date.valueOf(Datetime.newInstance(disbursementDate.year(), disbursementDate.month(), 20).format('yyy-MM-dd'));
                    System.debug('finalEomDate >>>'+finalEomDate);
                    System.debug('disbursementDate >>>'+disbursementDate);
                    if(finalEomDate>=disbursementDate){
                        System.debug('inside tyhe lesser  evalue');
                        Date firstDayOfMonth = disbursementDate.toStartOfMonth();
                        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                        Date firstDate = lastDayOfMonth.addMonths(1);
                        Date lastyday2 = firstDate.toStartOfMonth();
                        Date lastDay = lastyday2.addDays(Date.daysInMonth(lastyday2.year(), lastyday2.month()) - 1);


                        objDisbursalCompWrap.mapExtraParams.put( 'Due_Date__c',''+String.valueOf(lastDayOfMonth).remove(' 00:00:00'));
                        objDisbursalCompWrap.mapExtraParams.put( 'First_Installment_Date__c',''+String.valueOf(lastDay).remove(' 00:00:00'));
                        objDisbursalCompWrap.mapExtraParams.put( 'Interest_Start_Date__c',''+String.valueOf(lastDayOfMonth).remove(' 00:00:00'));

                    }else if(finalEomDate<disbursementDate){

                        System.debug('inside tyhe greater evalue');

                        Date nextMonthDate = disbursementDate.addMonths(1);
                        Date firstDayOfMonth = nextMonthDate.toStartOfMonth();
                        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                        Date firstDate = lastDayOfMonth.addMonths(1);

                        

                        objDisbursalCompWrap.mapExtraParams.put( 'Due_Date__c',''+String.valueOf(lastDayOfMonth).remove(' 00:00:00'));
                        objDisbursalCompWrap.mapExtraParams.put( 'First_Installment_Date__c',''+String.valueOf(firstDate).remove(' 00:00:00'));
                        objDisbursalCompWrap.mapExtraParams.put( 'Interest_Start_Date__c',''+String.valueOf(lastDayOfMonth).remove(' 00:00:00'));


                    }
                }
            }

                            //.remove(' 00:00:00') this is done so that in lightning input take string as param so we need to remove this suffix while conversion
                           // objDisbursalCompWrap.mapExtraParams.put( 'Due_Date__c',''+String.valueOf(objSchemeMaster.Due_Date__c).remove(' 00:00:00'));
                            //objDisbursalCompWrap.mapExtraParams.put( 'First_Installment_Date__c',''+String.valueOf(objSchemeMaster.First_Installment_Date__c).remove(' 00:00:00'));
                            //objDisbursalCompWrap.mapExtraParams.put( 'Interest_Start_Date__c',''+String.valueOf(objSchemeMaster.Interest_Start_Date__c).remove(' 00:00:00'));
                       // }
                    //}
                    //----------------------------------------------------------


                    //Karan Singh : 10/09/2022 - Get the primary applicant Name
                    for( Loan_Applicant__c objLoanApp : [ SELECT Id, Customer_Type__c,Application__r.Risk_Document_Color__c,Customer_Information__r.Name, CKYC_ID_Number__c
                                                             FROM Loan_Applicant__c
                                                             WHERE  Application__c =: objDisbursalCompWrap.objAppt.Id
                                                             AND  Customer_Type__c = 'Primary Applicant' AND Customer_Information__c <> Null
                                                             ORDER BY CreatedDate LIMIT 1] )
                        {
                            objDisbursalCompWrap.mapExtraParams.put( 'ROI_category__c', objLoanApp.Application__r.Risk_Document_Color__c);
                            objDisbursalCompWrap.mapExtraParams.put( 'apptPrimaryApplicantName', objLoanApp.Customer_Information__r.Name);
                            objDisbursalCompWrap.mapExtraParams.put( 'apptPrimaryApplicantCkyc', objLoanApp.CKYC_ID_Number__c);
                        }

                    
                    System.debug('after objDisbursalCompWrap.mapExtraParams is >>'+objDisbursalCompWrap.mapExtraParams);


                    //Karan Singh : 29/08/2022 : getting Insurance amount for deduction - - Disbursal Paramaters
                    for( AggregateResult  objAggResult : [ SELECT Sum( Total_Fee__c ) totalAmnt
                                                        FROM Fee_Creation__c
                                                        WHERE Application__c =:objDisbursalCompWrap.objAppt.Id AND RecordType.Name = 'Fee'
                                                        AND Repayment_Type_2__c = 'Deduct from Disbursement' ] )
                    {

                        if( objAggResult.get('totalAmnt') != Null ){

                            objDisbursalCompWrap.mapExtraParams.put( 'Total_Deductions__c', String.valueOf(objAggResult.get('totalAmnt')));

                        }
                    }

                    if(!objDisbursalCompWrap.mapExtraParams.containsKey('Total_Deductions__c')){

                        objDisbursalCompWrap.mapExtraParams.put( 'Total_Deductions__c', '0');
                    }

                    //calculating final disbursement amount - Disbursal Paramaters
                    Decimal finalDisbAmt = objDisbursalCompWrap.objAppt.Total_Amount_Recommended_PcAc__c<> Null ? objDisbursalCompWrap.objAppt.Total_Amount_Recommended_PcAc__c : 0;
                    finalDisbAmt -= objDisbursalCompWrap.mapExtraParams.get( 'Total_Deductions__c' ) <> Null ? Decimal.valueOf( objDisbursalCompWrap.mapExtraParams.get( 'Total_Deductions__c' ) ): 0;
                    finalDisbAmt =finalDisbAmt.setScale(2);
                    objDisbursalCompWrap.mapExtraParams.put('Final_Disbursal_Amount__c', String.valueOf( finalDisbAmt) );

                    //Checking Final Disbursement Amount saved in object
                    for( Disbursal__c objDisbursal : [ SELECT Id,Disbursal_Beneficiary_Type__c,Disbursal_Type__c,Application__r.Stage__c,Disbursal_Author_ID__c,Disbursal_Maker_ID__c, Final_Disbursal_Amount__c,CKYC_Original__c
                                                        FROM Disbursal__c
                                                        WHERE Application__c =: objDisbursalCompWrap.objAppt.Id
                                                        ORDER BY CreatedDate Desc LIMIT 1 ] )
                    {
                        if( objDisbursal.Final_Disbursal_Amount__c <> Null  ){

                            objDisbursalCompWrap.mapExtraParams.put('finalDisbAmtfromDB', String.valueOf( objDisbursal.Final_Disbursal_Amount__c) );

                            if( objDisbursal.CKYC_Original__c <> Null ){
                                objDisbursalCompWrap.mapExtraParams.put('ckycOriginal', String.valueOf( objDisbursal.CKYC_Original__c) );
                            }
                        }
                        if(objDisbursal.Disbursal_Beneficiary_Type__c!=null){
                            objDisbursalCompWrap.mapExtraParams.put('Disbursal_Beneficiary_Type__c', String.valueOf(objDisbursal.Disbursal_Beneficiary_Type__c)); 
                        }
                        if(objDisbursal.Disbursal_Type__c!=null){
                            objDisbursalCompWrap.mapExtraParams.put('Disbursal_Type__c', String.valueOf(objDisbursal.Disbursal_Type__c)); 
                        }

                        if(objDisbursal.Disbursal_Author_ID__c!=null){
                            objDisbursalCompWrap.mapExtraParams.put('Disbursal_Author_ID__c', String.valueOf(objDisbursal.Disbursal_Author_ID__c)); 
                        }

                        if(objDisbursal.Disbursal_Maker_ID__c!=null && objDisbursal.Application__r.Stage__c =='Disbursal Author'){
                            objDisbursalCompWrap.mapExtraParams.put('Disbursal_Maker_ID__c', String.valueOf(objDisbursal.Disbursal_Maker_ID__c)); 
                        }
                    }
                    if( !objDisbursalCompWrap.mapExtraParams.containsKey('finalDisbAmtfromDB') ){

                        objDisbursalCompWrap.mapExtraParams.put('finalDisbAmtfromDB', '0' );
                    }
                }else{

                    objDisbursalCompWrap.objSobject = listSobject[0];
                }

                //getting user empoyeeid
                for( User objUser : [ SELECT Id, EmployeeNumber FROM USER WHERE Id =: UserInfo.getUserId()] )
                {
                    if( objDisbursalCompWrap.disbMetaPrefix == 'DISBM_' ){

                        objDisbursalCompWrap.mapExtraParams.put('Disbursal_Maker_ID__c', objUser.EmployeeNumber);
                    }/*else{
                        objDisbursalCompWrap.mapExtraParams.put('Disbursal_Author_ID__c', objUser.EmployeeNumber);
                    }*/
                }

        
                //added Karan : 22-09-22 as per yogender
                if(Schema.SObjectType.Property__c.getRecordTypeInfosByName().containsKey('AC Property Detail')){
                    objDisbursalCompWrap.mapExtraParams.put('acRecordId', Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('AC Property Detail').getRecordTypeId());
                }
                //added Karan : 22-09-22 as per yogender, need to send recordtypeId instead of recordId
                /*for( Verification__c objVerif : [ SELECT Id
                                                    FROM Verification__c
                                                    WHERE recordtype.name = 'AC' ORDER BY CreatedDate DESC
                                                    LIMIT 1 ])
                {
                    objDisbursalCompWrap.mapExtraParams.put('acRecordId', objVerif.Id);
                }*/
                //

                //Karan SIngh : 04-10-2022 : CH
                if( Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().containsKey('Disbursal Author') ){
                    objDisbursalCompWrap.mapExtraParams.put('daRecdTypId', Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().get('Disbursal Author').getRecordTypeId());
                }
                if( Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().containsKey('Disbursal Maker') ){
                    objDisbursalCompWrap.mapExtraParams.put('dmRecdTypId', Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().get('Disbursal Maker').getRecordTypeId());
                }
                //==============================================================
                objDisbursalCompWrap.statusCode = 200;
                objDisbursalCompWrap.message = 'Data fetched successfully.';
            }
        } catch (Exception e) {

            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }
        return objDisbursalCompWrap;
    }

    @AuraEnabled
    public static string getDisbursalData(String appId){
        try {
         List<Disbursal__c> disbList =  [select Id,Disbursal_Type__c from Disbursal__c where Application__c=:appId LIMIT 1];
        if(disbList.size()>0){
            if(disbList[0].Disbursal_Type__c!=null){
                return disbList[0].Disbursal_Type__c;
            }
        }
        } catch (Exception e) {
            System.debug('line number is >>>'+e.getLineNumber());
            System.debug('line number is >>>'+e.getMessage());
        }

        return '';
    }

    @AuraEnabled
    public static List<Application__c> getfeeData(String appId){
        try { 
            List<Application__c> appList = new List<Application__c>();
             appList = [select Id,Insurance_Medical_Test_Result__c,Insurance_Requirement__c from Application__c where Id=:appId LIMIT 1];
            if(appList.size()>0){
                return appList;
            }

            return null;
                        
        } catch (Exception e) {
            System.debug('line number is >>>'+e.getLineNumber());
            System.debug('line number is >>>'+e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static GenericDataTableController.DataTableResponse getRelatedRecords(List<String> setRecordIds,String metadataName){

        system.debug( 'metadataName ' + metadataName );
        system.debug( 'setRecordIds ' + setRecordIds );
        GenericDataTableController genericDTObjCapabilty = new GenericDataTableController();
        genericDTObjCapabilty.METADATA_NAME = metadataName ;
        genericDTObjCapabilty.IDS_SET = new Set< String >(setRecordIds);
        genericDTObjCapabilty.WHERE_CLAUSE = 'ID IN : IDS_SET';
        return genericDTObjCapabilty.getTable();

    }

    /**
     * CH01 : added API support in this
     */
    @AuraEnabled
    public static DisbursalCompWrap getIfscDetails( String ifscCodeId ){

        DisbursalCompWrap objWrapDisbComp = new DisbursalCompWrap();

        if( String.isBlank( ifscCodeId ) ){

            objWrapDisbComp.statusCode = 400;
            objWrapDisbComp.message = 'IFSC Code is blank.';
            return objWrapDisbComp;
        }
        try {

            FsIFSCController.WrapperResponse objifscWrap = FsIFSCController.getIFSCData(ifscCodeId);
            system.debug(objifscWrap);

            if(objifscWrap.isSuccess){

                objWrapDisbComp.statusCode = 200;
                objWrapDisbComp.message = objifscWrap.result;
            }else{

                objWrapDisbComp.statusCode = 400;
                objWrapDisbComp.message = 'IFSC - '+ objifscWrap.result;
            }

            /*CH01 Commented
            List< IFSC_Code_Master__c > listIfscMaster = [ SELECT Id,Name, Bank_Branch_Name__c, Bank_Name__c
                                                            FROM IFSC_Code_Master__c
                                                            WHERE Id =: ifscCodeId  ];

            if( listIfscMaster.isEmpty() ){

                objWrapDisbComp.statusCode = 404;
                objWrapDisbComp.message = 'IFSC Code not found.';
                objWrapDisbComp.mapExtraParams.put( 'Beneficiary_Branch_Name__c', '' );
                objWrapDisbComp.mapExtraParams.put( 'Beneficiary_Bank_Name__c', '' );
            }else{

                objWrapDisbComp.statusCode = 200;
                objWrapDisbComp.mapExtraParams.put( 'Beneficiary_Branch_Name__c', listIfscMaster[0].Bank_Name__c );
                objWrapDisbComp.mapExtraParams.put( 'Beneficiary_Bank_Name__c', listIfscMaster[0].Bank_Branch_Name__c );
            }*/
        } catch (Exception e) {

            objWrapDisbComp.statusCode = 503;
                objWrapDisbComp.message = e.getMessage();
        }

        return objWrapDisbComp;
    }


    @AuraEnabled
    public static DisbursalCompWrap initDisbursalPayee( String jsonParamData){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        List<String> listApptNameType = new List<String>();

        if( String.isBlank(jsonParamData) ){

            objDisbursalCompWrap.statusCode = 400;
            objDisbursalCompWrap.message = 'Invalid data passed';
            return objDisbursalCompWrap;
        }
        try{

            Map<String, Object> mapJsonParam =   (Map<String, Object>) JSON.deserializeUntyped(jsonParamData);
            Set<String> setLoanApptIds =  new Set<String>();
            Decimal sanctionLoanAmt = 0;
            Integer i=0;
            Integer j=0;
            for( Application__c objAppt : [ SELECT Id,Total_Amount_Recommended_PcAc__c,
                                                ( SELECT Id,Customer_Information__r.Name, Customer_Type__c FROM Loan_Applicants__r )
                                            FROM Application__c
                                            WHERE Id =: (String) mapJsonParam.get('apptId')])
            {
                sanctionLoanAmt = objAppt.Total_Amount_Recommended_PcAc__c;
                for(  Loan_Applicant__c objLoanAppt :  objAppt.Loan_Applicants__r ){
                    
                    setLoanApptIds.add( objLoanAppt.Id );
                    if(objLoanAppt.Customer_Type__c =='Co-Applicant'){
                        ++i;
                      listApptNameType.add( objLoanAppt.Customer_Type__c+' '+i+ '---' + objLoanAppt.Customer_Information__r.Name + '---' + objLoanAppt.Id);

                    }else if(objLoanAppt.Customer_Type__c =='Guarantor'){
                        ++j;
                      listApptNameType.add( objLoanAppt.Customer_Type__c+' '+j+ '---' + objLoanAppt.Customer_Information__r.Name + '---' + objLoanAppt.Id);

                    }else{
                      listApptNameType.add( objLoanAppt.Customer_Type__c + '---' + objLoanAppt.Customer_Information__r.Name + '---' + objLoanAppt.Id);

                    }
                }
                listApptNameType.add( 'BT Bank---' );
                listApptNameType.add( 'Third Party---' );
            }
            if( !listApptNameType.isEmpty() ){

                objDisbursalCompWrap.mapExtraParams.put('listApptNameType' , String.join( listApptNameType, ','));
            }
            objDisbursalCompWrap.mapExtraParams.put('sanctionLoanAmt' , ''+sanctionLoanAmt);


            //fetching exisitng Disbursal Payee details
            if( mapJsonParam.containsKey('existDisbId') ){

                for( Disbursal__c objDisb : [ SELECT Id,Final_Disbursal_Amount__c,
                                                ( SELECT Id, Is_Deduct_From__c,Loan_Applicant__c,Adjusted_Beneficiary_Amount__c,Beneficiary_Account_Type__c, Beneficiary_Amount__c, Beneficiary_Bank_Account_Number__c, Beneficiary_Bank_Name__c, Beneficiary_Branch_Name__c,Beneficiary_IFSC_Code__c, Beneficiary_Name__c, Beneficiary_Type__c, Disbursal__c, Is_Verified__c, Payment_Type__c, Name FROM Disbursal_Payees__r )

                                             FROM Disbursal__c
                                             WHERE Id =: (String) mapJsonParam.get('existDisbId')] )
                {
                    if(objDisb.Final_Disbursal_Amount__c <> Null ){
                        objDisbursalCompWrap.mapExtraParams.put('Final_Disbursal_Amount' , ''+objDisb.Final_Disbursal_Amount__c);
                    }else{
                        objDisbursalCompWrap.mapExtraParams.put('Final_Disbursal_Amount' , '0');
                    }
                    if( !objDisb.Disbursal_Payees__r.isEmpty() ){

                        objDisbursalCompWrap.listSObject = objDisb.Disbursal_Payees__r;
                        objDisbursalCompWrap.sObjectListType = 'Disbursal_Payee__c';
                    }

                }
            }

            //---------------------------------------------------
            //getting loan applicant premium and final AMount
            /*Karan Singh : 01-10-2022 : change in calculation logic
            List<String> listStrLoanApptDetails =new  List<String>();
            for(Application__c objAppt : [ SELECT Id,Name,Stage__c,
                                                    ( SELECT Id, Premium__c, Stage_Due__c,Total_Fee__c
                                                        FROM Fee_Creations__r
                                                        WHERE  RecordType.Name = 'Insurance' AND Repayment_Type_2__c = 'Deduct from Disbursement' AND Stage_Due__c IN ('Approval Credit', 'Disbursal Maker')
                                                        ORDER BY CreatedDate ASC )
                                                 FROM Application__c WHERE ID=: (String) mapJsonParam.get('apptId') ])
            {
                String json;
                //now we will give preference DM then AC first in case  of Da, AC incase of DM
                if( objAppt.Stage__c == 'Disbursal Maker' ){

                    Decimal totalPremiumAC = 0;
                    Decimal totalFeesAC = 0;
                    for( Fee_Creation__c objFee : objAppt.Fee_Creations__r ){

                        if( objFee.Stage_Due__c == 'Approval Credit' ){

                            totalPremiumAC += objFee.Premium__c <> Null ? objFee.Premium__c : 0;
                            totalFeesAC += objFee.Total_Fee__c <> Null ? objFee.Total_Fee__c : 0;
                        }
                    }
                    json = '{ "premium" :'+totalPremiumAC +', "fee" : '+totalFeesAC+' }';
                    System.debug(' DM - premium '+totalPremiumAC +', "fee" : '+totalFeesAC);
                }else{

                    Decimal totalPremiumAC = 0;
                    Decimal totalFeesAC = 0;
                    Decimal totalPremiumDM = 0;
                    Decimal totalFeesDM = 0;

                    for( Fee_Creation__c objFee : objAppt.Fee_Creations__r ){

                        if( objFee.Stage_Due__c == 'Approval Credit' ){

                            totalPremiumAC += objFee.Premium__c <> Null ? objFee.Premium__c : 0;
                            totalFeesAC += objFee.Total_Fee__c <> Null ? objFee.Total_Fee__c : 0;
                        }
                        else if( objFee.Stage_Due__c == 'Disbursal Maker' ){

                            totalPremiumDM += objFee.Premium__c <> Null ? objFee.Premium__c : 0;
                            totalFeesDM += objFee.Total_Fee__c <> Null ? objFee.Total_Fee__c : 0;
                        }

                    }
                    System.debug(' DA - totalPremiumDM '+totalPremiumDM +' "totalFeesDM" : '+totalFeesDM);
                    System.debug(' DA - totalPremiumAC '+totalPremiumAC +' "totalFeesAC" : '+totalFeesAC);

                    if(totalPremiumDM != 0 ||totalFeesDM != 0 ){
                        json = '{ "premium" :'+totalPremiumDM +', "fee" : '+totalFeesDM+' }';
                    }else{
                        json = '{ "premium" :'+totalPremiumAC +', "fee" : '+totalFeesAC+' }';
                    }

                }
                objDisbursalCompWrap.mapExtraParams.put('insuranceCalc' , json);
            }

            if(listStrLoanApptDetails.size() > 0){
                objDisbursalCompWrap.mapExtraParams.put('listLoanApptPremiumFees' , String.join( listStrLoanApptDetails, ','));
            }*/

            //Karan Singh : 24/09/2022 : CH - fetching the penny drop bank details of loan applicants
            //Karan Singh : 24/09/2022 : CH - Adding Insurance Premium amount Logic
            //CH01 : added IFSC_Code__c in query
            for( Loan_Applicant__c objLoan : [ SELECT Id,
                                                ( SELECT Id, Loan_Applicant__c,Loan_Applicant__r.Customer_Information__r.Name, Loan_Applicant__r.Customer_Type__c, Account_Number__c, Account_Type__c, MS_IFSC_Code__c,Name,Branch_Name__c,IFSC_Code__c FROM Bank_Details__r WHERE Is_Account_Verified__c = true ORDER BY Account_Verified_on__c DESC LIMIT 1)
                                               FROM Loan_Applicant__c
                                               WHERE Id IN: setLoanApptIds ] )
            {
                if( !objLoan.Bank_Details__r.isEmpty() ){
                    objDisbursalCompWrap.listSObject2.add(objLoan.Bank_Details__r[0]);
                }
            }
            //======================================================================================

            objDisbursalCompWrap.statusCode = 200;
        } catch (Exception e) {

            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }

        //getting Disbursal Data

        return objDisbursalCompWrap;
    }

    //Karan Singh : 03-10-2022 - CH
    @AuraEnabled
    public static DisbursalCompWrap getDeductionAmount( String apptId){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        List< Disbursal__c > listDisb = [ SELECT Id, Total_Deductions__c,
                                            ( SELECT Id, Beneficiary_Amount__c, Adjusted_Beneficiary_Amount__c,Is_Deduct_From__c FROM Disbursal_Payees__r )
                                        FROM Disbursal__c WHERE Application__c =: apptId ];
        List <Application__c> listAppt = [ SELECT Id,
                                            ( SELECT Id, Total_Fee__c,RecordType.Name,Repayment_Type_2__c FROM Fee_Creations__r
                                                WHERE Total_Fee__c <> NULL )
                                          FROM Application__c
                                          WHERE Id =: apptId];

        List< Property__c > listProp = [ SELECT ID,
                                            ( SELECT Id, Total_Fee__c FROM Fee_Creations__r
                                                WHERE RecordType.Name = 'Insurance' AND  Repayment_Type_2__c = 'Deduct from Disbursement' AND Total_Fee__c <> NULL ORDER BY CreatedDate DESC)
                                        FROM Property__c WHERE Application__c =: apptId ];
        List< Loan_Applicant__c > listLoanAppt = [ SELECT Id,
                                                    ( SELECT Id, Total_Fee__c FROM Fee_Creations__r
                                                      WHERE RecordType.Name = 'Insurance' AND  Repayment_Type_2__c = 'Deduct from Disbursement' AND Total_Fee__c <> NULL ORDER BY CreatedDate DESC)
                                                    FROM Loan_Applicant__c WHERE Application__c =: apptId];
            system.debug('577 objDisbursalCompWrap.mapExtraParams ' +objDisbursalCompWrap.mapExtraParams );

        //======================================================================
        objDisbursalCompWrap.mapExtraParams.put('disbTotalDeduct', !listDisb.isEmpty() ? ''+listDisb[0].Total_Deductions__c : '0');
            system.debug('581 objDisbursalCompWrap.mapExtraParams ' +objDisbursalCompWrap.mapExtraParams );

        //======================================================================
        if( !listDisb.isEmpty() && !listDisb[0].Disbursal_Payees__r.isEmpty() ){

            Decimal totalBenifAmt = 0;
            for( Disbursal_Payee__c objDisbPayee : listDisb[0].Disbursal_Payees__r ){

                system.debug(objDisbPayee.Is_Deduct_From__c +' objDisbPayee ' +objDisbPayee );

                if( objDisbPayee.Is_Deduct_From__c && objDisbPayee.Adjusted_Beneficiary_Amount__c <> Null){

                    totalBenifAmt += objDisbPayee.Adjusted_Beneficiary_Amount__c;

                }else if( objDisbPayee.Beneficiary_Amount__c <> Null ){

                    totalBenifAmt += objDisbPayee.Beneficiary_Amount__c;

                }
            }

            totalBenifAmt = totalBenifAmt.setScale(2);
            system.debug(' totalBenifAmt ' +totalBenifAmt );
            objDisbursalCompWrap.mapExtraParams.put('disbPayeeTotal', ''+totalBenifAmt);

        }else{

            objDisbursalCompWrap.mapExtraParams.put('disbPayeeTotal', '0');
        }
        //======================================================================
        //Now calculating Total Deduction and Insurance premium
        Decimal totalFeeDeduction = 0;
        Decimal totalInsurancePremium = 0;
            system.debug('612 objDisbursalCompWrap.mapExtraParams ' +objDisbursalCompWrap.mapExtraParams );

        if( !listAppt.isEmpty() && !listAppt[0].Fee_Creations__r.isEmpty()){

            for( Fee_Creation__c objFeeCreat : listAppt[0].Fee_Creations__r ){

                if( objFeeCreat.RecordType.Name == 'Fee' && objFeeCreat.Repayment_Type_2__c == 'Deduct from Disbursement'){

                    totalFeeDeduction += objFeeCreat.Total_Fee__c;
                    System.debug('the deductiona are >>>>'+totalFeeDeduction);
                }else if( objFeeCreat.RecordType.Name == 'Insurance' && objFeeCreat.Repayment_Type_2__c == 'Deduct from Disbursement'){
                    System.debug('621totalInsurancePremium is >>'+totalInsurancePremium);
                    System.debug('622objFeeCreat.Total_Fee__c >>'+objFeeCreat.Total_Fee__c);
                    totalInsurancePremium += objFeeCreat.Total_Fee__c;
                     System.debug('624objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);
                }
            }
        }
        System.debug('627objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);
            system.debug('629 objDisbursalCompWrap.mapExtraParams ' +objDisbursalCompWrap.mapExtraParams );

        if( !listProp.isEmpty() ){

            for(Property__c objProp : listProp){

                if( !objProp.Fee_Creations__r.isEmpty()){
                    System.debug('633objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);
                    System.debug('634oobjProp.Fee_Creations__r[0].Total_Fee__c >>'+objProp.Fee_Creations__r[0].Total_Fee__c);
                    totalInsurancePremium += objProp.Fee_Creations__r[0].Total_Fee__c;
                    System.debug('636objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);

                }
            }
        }
    system.debug('642 objDisbursalCompWrap.mapExtraParams ' +objDisbursalCompWrap.mapExtraParams );

        System.debug('638objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);
        if( !listLoanAppt.isEmpty() ){

            for(Loan_Applicant__c objLoanAppt : listLoanAppt){

                if( !objLoanAppt.Fee_Creations__r.isEmpty()){
                    System.debug('633objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);
                    System.debug('634oobjProp.Fee_Creations__r[0].Total_Fee__c >>'+objLoanAppt.Fee_Creations__r[0].Total_Fee__c);
                   // totalInsurancePremium += objLoanAppt.Fee_Creations__r[0].Total_Fee__c;
                    System.debug('650objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);
 
                }
            }
        }
        //======================================================================
        System.debug('656objFeeCreat.Total_Fee__c >>'+totalInsurancePremium);
        totalFeeDeduction = totalFeeDeduction.setScale(2);
        totalInsurancePremium = totalInsurancePremium.setScale(2);
        system.debug(' totalFeeDeduction ' +totalFeeDeduction );
        system.debug(' totalInsurancePremium ' +totalInsurancePremium );
        objDisbursalCompWrap.mapExtraParams.put('totalFeeDeduction', ''+totalFeeDeduction);
        objDisbursalCompWrap.mapExtraParams.put('totalInsurancePremium', ''+totalInsurancePremium);
        //ab sabka disb krna hai + error message bhi handle krna hai + plus init me bhi auto populate krna hai

        system.debug(' objDisbursalCompWrap.mapExtraParams ' +objDisbursalCompWrap.mapExtraParams );
        return objDisbursalCompWrap;

    }

    //Karan Singh : 29-09-2022 : CH
    @AuraEnabled
    public static DisbursalCompWrap initCKyc( String jsonParamData){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        List<String> listApptNameType = new List<String>();

        if( String.isBlank(jsonParamData) ){

            objDisbursalCompWrap.statusCode = 400;
            objDisbursalCompWrap.message = 'Invalid data passed';
            return objDisbursalCompWrap;
        }
        try{

            Map<String, Object> mapJsonParam =   (Map<String, Object>) JSON.deserializeUntyped(jsonParamData);

            //fetching the Loan Applicant's Kyc ids
            objDisbursalCompWrap.listSObject = [ SELECT Id,CKYC_ID_Number__c,Disbursal_CKYC_ID__c,Disbursal_CKYC_ID_Number_History__c,Customer_Type__c,Customer_Information__r.Name  FROM Loan_Applicant__c WHERE Application__c =: (String) mapJsonParam.get('apptId') ORDER BY CreatedDate ASC];

            objDisbursalCompWrap.statusCode = 200;
        } catch (Exception e) {

            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }

        //getting Disbursal Data

        return objDisbursalCompWrap;
    }

    @AuraEnabled
    public static String callPennyDropAPI( Id disbPayee ){
        String status = 'Success';
        try {
            status = PennyDropAPI.callPennyDropAPI(disbPayee);
            if( status.contains('_') ){
                status = status.split('_')[1];
            }
        } catch (Exception e) {
            status = e.getMessage();
        }
        return status;
    }
    @AuraEnabled
    public static List<ContentVersion> getDocumentId(String parentId, String documentPrefix){
        documentPrefix = documentPrefix + '%';
        return [SELECT Id, Title,ContentDocumentId FROM ContentVersion WHERE Parent_Id__c =:parentId AND Title LIKE :documentPrefix ORDER BY CreatedDate DESC LIMIT 1];
    }
    /*
     * Karan Singh : 02/09/2022 : This method will update the owner of the application
     */
    @AuraEnabled
    public static String allocateUser( String stageName, String apptId ){

        
      
        String msg = 'Success';
        try{
            Id userId = null;
            
            if( stageName == 'Disbursal Maker' ){
                List<PermissionSetAssignment> listPermissionSet = [SELECT Id,AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Disbursal_Maker_Permission_Set' LIMIT 1];

                if( !listPermissionSet.isEmpty() ){
                    userId = listPermissionSet[0].AssigneeId;
                }

            }else if(stageName == 'Disbursal Author'){
                List<PermissionSetAssignment> listPermissionSet = [SELECT Id,AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Disbursal_Author_Permission_Set' LIMIT 1];

                if( !listPermissionSet.isEmpty() ){
                    userId = listPermissionSet[0].AssigneeId;
                }
            }else if(stageName == 'File Inward'){
                List<PermissionSetAssignment> listPermissionSet = [SELECT Id,AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'File_Inward_Permission_Set' LIMIT 1];

                if( !listPermissionSet.isEmpty() ){
                    userId = listPermissionSet[0].AssigneeId;
                }
            }
            if( userId == Null ){

                msg= 'No Applicable Disbursal Author user found.';
                return msg;
            }else{

                update new Application__c(Id = apptId, OwnerId = userId);
                List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Verification_Notification'];

                Messaging.CustomNotification currNotification = new Messaging.CustomNotification();

                currNotification.setTitle('Application Assigend.' );
                currNotification.setBody('Application has been assigned to you.');
                currNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);

                currNotification.setTargetId(apptId);
                currNotification.send(new Set<String>{userId});

            }

        } catch (Exception e) {


            msg = e.getMessage();
        }
        return msg;
    }

    /*
     * Karan Singh : 02/09/2022 : This method will update the Stage of the application base on defferal condition.
     *             : 10-09-2022 : CH01 : object is changed for deferral logic
     */
    @AuraEnabled
    public static String updateApptStageFromDA( String apptId,String ApprovalStatus,String approvalRemarks){

        String msg = 'Success';
        try{

            /*List<ContentVersion> listCntnVrsnDefferal =  [ SELECT Id FROM ContentVersion
                                                             WHERE Deferal_Stage__c = 'Post Disbursement' AND Parent_Id__c =: apptId LIMIT 1];*/

            /* 28-09-2022 : Yogender change this query
            List<Deferral_Document__c> listDeffDoc = [ SELECT Id FROM Deferral_Document__c
                                                        WHERE Is_Deferral_Document__c = TRUE
                                                        AND Application__c =: apptId LIMIT 1 ];
            */
           // commented as per kuldeep sir and arsalan discussion 
          /*  List<Deferral_Document__c> listDeffDoc = [ SELECT Id FROM Deferral_Document__c
                                                        WHERE Deferral_Stage__c = 'Document Deferral' AND Is_Deferral_Document__c = TRUE AND Status__c = 'Deferred'
                                                        AND Application__c =: apptId LIMIT 1 ];*/
            List<Deferral_Document__c> listDeffDoc =  [SELECT Id,Name,Document_Name__c,Is_Deferral_Document__c,Deferral_Stage__c,Deferred_From__c FROM Deferral_Document__c WHERE Status__c = 'Deferred' AND Application__c =: apptId LIMIT 1];
            
            List<Disbursal__c> listOfdisbursal = [SELECT id FROM Disbursal__c  WHERE Application__c =: apptId AND Disbursal_Type__c = 'Part Disb' LIMIT 1];
            Application__c objAppt = new Application__c();
            objAppt.Id = apptId;
            objAppt.Disbursal_Author_Decision__c = ApprovalStatus;
            objAppt.Disbursal_Author_Decision_Remarks__c=approvalRemarks;
            if(ApprovalStatus=='Approve'){
                objAppt.application_status__c = 'Active';
            }else if(ApprovalStatus=='Reject'){
                objAppt.application_status__c = 'Rejected';
            }
             
            //objAppt.Stage__c = listCntnVrsnDefferal.isEmpty() ? 'File Inward' : 'Document Deferral';
            objAppt.Stage__c = !listOfdisbursal.isEmpty() ? 'Part Disbursment DE' : listDeffDoc.isEmpty() ? 'File Inward' : 'Document Deferral';
            objAppt.Disbursal_Author_Completion_Date__c = Date.today();//Karan Singh 26-09-2022: CH : Used to completion date of DA
            update objAppt;
          /*  if( objAppt.Stage__c == 'File Inward'){
                msg = allocateUser( objAppt.Stage__c, objAppt.Id);
            }*/

        }catch (Exception e) {


            msg = e.getMessage();
        }
        return msg;
    }

    @AuraEnabled
    public static Boolean getAllocatedUser(String apptId){
        try {
            List<Disbursal__c> disbList =[select Id,Disbursal_Author_ID__c,Application__r.Stage__c from Disbursal__c where Application__c=:apptId];
            if(disbList.size()>0){
               
                List<User> userList=[select Id,profile.name from User where Id=:UserInfo.getUserId()];
                if(userList[0].profile.name=='System Administrator'){
                    return true;
                }
                else if(disbList[0].Disbursal_Author_ID__c!=null && disbList[0].Application__r.Stage__c =='Disbursal Author'){
                    if(userList[0].Id == disbList[0].Disbursal_Author_ID__c && disbList[0].Application__r.Stage__c =='Disbursal Author' ){
                        return true;
                    }
                }else if(disbList[0].Application__r.Stage__c =='Disbursal Maker'){
                    return true;
                }

            }else if(disbList.size() == 0){
                return true;
            }
        } catch (Exception e) {
            System.debug('exception is >>>'+e.getMessage());
            System.debug('exception line is >>>'+e.getLineNumber());
        }
        return false;
    }



    @AuraEnabled
    public static boolean trackUser(String stageName, String apptId){
        List<SObject> pendingTrackRecords = new List<SObject>();
        List<Disbursal__c> disbList = [select Id,Disbursal_Author_ID__c from Disbursal__c where Application__c=:apptId LIMIT 1];
       

        try {
            List<Application_User_Tracking__c> prevDmRecords =[select Id,Stage__c,Status__c from Application_User_Tracking__c where Status__c='Pending' AND Stage__c='Disbursal Maker' AND Application__c=:apptId];

            if(prevDmRecords.size()>0){
                for(Application_User_Tracking__c Obj : prevDmRecords){
                    Application_User_Tracking__c apptObj = new Application_User_Tracking__c();
                    apptObj.Id=Obj.Id;
                    apptObj.Status__c='Completed';
                    apptObj.End_Date__c=System.now();
                    pendingTrackRecords.add(apptObj);
                }
            }

            if(disbList.size()>0){
                
                if(disbList[0].Disbursal_Author_ID__c!=null){
                    
                    Application__c app = new Application__c();
                    app.Id=apptId;
                    app.OwnerId=disbList[0].Disbursal_Author_ID__c;
                    pendingTrackRecords.add(app);

                    Application_User_Tracking__c trackObj = new Application_User_Tracking__c();
                    trackObj.Application__c=apptId;
                    trackObj.Start_Date__c=System.now();
                    trackObj.Status__c = 'Pending';
                    trackObj.Stage__c='Disbursal Author';
                    trackObj.Previous_Stage__c='Disbursal Maker';
                    trackObj.Owner__c=disbList[0].Disbursal_Author_ID__c;
                    pendingTrackRecords.add(trackObj);

                }
            }

        
            if(pendingTrackRecords.size()>0){
                upsert pendingTrackRecords;
            }

            if(disbList.size()>0){
                List<User> userList=[select Id from User where Id=:UserInfo.getUserId()];
                if(disbList[0].Disbursal_Author_ID__c!=null){
                    if(userList[0].Id == disbList[0].Disbursal_Author_ID__c){
                        return true;
                    }
                }
            }


        } catch (Exception e) {
            System.debug('exception is >>>>'+e.getMessage());
            System.debug('exception Line  is >>>>'+e.getLineNumber());
        }
        return false;
    }


    /**
    * @description : Will be used in DA, check if any pending deviaiton is there or not.
    * @author Karan Singh Soni | 17-09-2022
    * @param apptId
    * @return DisbursalCompWrap
    **/
    @AuraEnabled
    public static DisbursalCompWrap chechExistDeviaitons( String apptId ){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();

        if( apptId == Null ){

            objDisbursalCompWrap.statusCode = 400;
            objDisbursalCompWrap.message = 'Invalid application Id';
            return objDisbursalCompWrap;
        }
        List < TR_Deviation__c > listDeviation = [SELECT Id,Name,Decistion__c,IS_Deviation_Active__c,MS_Deviation__r.Stage__c,Deviation_Description__c  FROM Tr_Deviation__c WHERE  Decistion__c !='Approved' AND Decistion__c != 'Not Applicable' AND MS_Deviation__r.Stage__c='Operations' AND Application__c=:apptId  AND Is_Deviation_Active__c=true];

        if( listDeviation.isEmpty() ){
            objDisbursalCompWrap.statusCode = 200;
        }else{
            objDisbursalCompWrap.statusCode = 400;
            objDisbursalCompWrap.message = 'All Deviations are not approved.';
        }
        return objDisbursalCompWrap;
    }
    //objDisbursal will be any type of object
    //base64, filename,prntRecordId will be used to create file under the prntRecordId. if prntRecordId is blank then it means the parent will be objDisbursal object
    @AuraEnabled
    public static DisbursalCompWrap saveDisbursalCompData( Sobject objDisbursal, String base64, String filename, String prntRecordId ){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        System.debug('inside saveDisbursalCompData >>>'+objDisbursal );
        System.debug('inside filename >>>'+filename );
        System.debug('inside prntRecordId >>>'+prntRecordId );
       // System.debug('inside saveDisbursalCompData >>>'+objDisbursal );
        if( objDisbursal == Null ){
            System.debug('inside null >>>'+objDisbursal );
            objDisbursalCompWrap.statusCode = 400;
            objDisbursalCompWrap.message = 'Invalid Data to Save.';
            return objDisbursalCompWrap;
        }

        try{
            System.debug('objDisbursal in insurance is >>>'+objDisbursal );
            upsert objDisbursal;

            if(objDisbursal.Id.getSobjectType() == Schema.Insurance_Details__c.SObjectType){
                   
                List<Sobject> sObjList = new List<Sobject>();
                sObjList.add(objDisbursal);
                List<Insurance_Details__c> DisbPayyeObjList = new List<Insurance_Details__c>();
                List<Insurance_Details__c> DisbObjList =sObjList;
                List<Application__c> appList = new List<Application__c>();

                if(DisbObjList.size()>0){
                    for(Insurance_Details__c insObj : DisbObjList){
                        if(String.isNotBlank(insObj.Insured_Person_Name__c) && String.isNotEmpty(insObj.Insured_Person_Name__c) && insObj.Insured_Person_Name__c!=null){
                            Application__c app = new Application__c();
                            app.Id = insObj.Application__c;
                            app.Insurance_Waiver__c = insObj.Insurance_Waiver__c;
                            app.Name__c = insObj.Insured_Person_Name__c;
                            app.Insured_Person_Date_of_Birth__c = insObj.Insured_Person_Date_of_Birth__c;
                            app.Nominee_Party__c = insObj.Nominee_Name__c;                
                            app.Nominee_Relationship_Type__c = insObj.Nominee_Relationship_Type__c;      
                            app.Nominee_Party_Relationship_with_Insured__c = insObj.Nominee_Relationship_with_Insured_Person__c;      
                            app.Nominee_KYC_ID_Type__c = insObj.Nominee_KYC_ID_Type__c;        
                            app.Nominee_KYC_ID_No__c = insObj.Nominee_KYC_ID_No__c;    
                            app.Nominee_DOB_as_per_KYC__c = insObj.Nominee_DOB_as_per_KYC__c;        
                            app.Insurance_Requirement__c = insObj.Insurance_Requirement__c;
                            app.Insurance_Medical_Test_Result__c  = insObj.Insurance_Medical_Test_Result__c;  
                            app.Insured_Person__c = insObj.Insured_Person__c;
                            app.NomineeName__c  = insObj.NomineeName__c;                            
                            
                            if(String.valueOf(insObj.Nominee_Type__c) == 'Not Part of Loan'){
                                app.Nominee__c = 'No';
                            }
                            else if(String.valueOf(insObj.Nominee_Type__c) == 'Part of Loan'){
                                app.Nominee__c = 'Yes';
                            }
                            appList.add(app);
                        }
                    }
                }
                if(appList.size()>0){
                    update appList;
                }
            }

            //Karan Singh : 04-10-2022 : CH
            if(objDisbursal.Id.getSobjectType() == Schema.Disbursal__c.SObjectType){

                List<Disbursal__c> ListDisb = [ SELECT Id,RecordTypeId, RecordType.Name, Application__r.Stage__c
                                                FROM Disbursal__c
                                                WHERE Id =: objDisbursal.Id ];

                if( ListDisb[0].Application__r.Stage__c == 'Disbursal Author' && ListDisb[0].Application__r.Stage__c != ListDisb[0].RecordType.Name){
                    ListDisb[0].RecordTypeId = Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().get('Disbursal Author').getRecordTypeId();
                }
                else if(ListDisb[0].Application__r.Stage__c != ListDisb[0].RecordType.Name){
                    ListDisb[0].RecordTypeId = Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().get('Disbursal Maker').getRecordTypeId();
                }
                System.debug('update objDisbursal in insurance is >>>'+ListDisb[0] );
                update ListDisb[0];
            }
            //=================================================================
            //if prntRecordId is blank it means the above record will be the parent
            if( String.isNotBlank(base64) && String.isNotBlank(filename) ){

                ContentVersion objContntVrsn = new ContentVersion();
                objContntVrsn.VersionData = EncodingUtil.base64Decode(base64);
                objContntVrsn.FirstPublishLocationId = String.isNotBlank(prntRecordId) ? prntRecordId : objDisbursal.Id;
                objContntVrsn.Title = filename;
                objContntVrsn.PathOnClient = filename;
                objContntVrsn.PathOnClient = filename;
                objContntVrsn.Parent_Id__c = objContntVrsn.FirstPublishLocationId;

                insert objContntVrsn;
                system.debug( 'objContntVrsn id ' + objContntVrsn.Id );
            }
            objDisbursalCompWrap.statusCode = 201;
            objDisbursalCompWrap.message = 'Data saved successfully.';

        } catch (Exception e) {
            System.debug('message is >>>'+e.getMessage());
            System.debug('message line no is >>>'+e.getLineNumber());
            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }
        return objDisbursalCompWrap;
    }

     @AuraEnabled
    public static DisbursalCompWrap saveDisbursalPayeeData( Sobject objDisbursal, String base64, String filename, String prntRecordId ){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        System.debug('inside saveDisbursalCompData >>>'+objDisbursal );
        System.debug('inside filename >>>'+filename );
        System.debug('inside prntRecordId >>>'+prntRecordId );
       // System.debug('inside saveDisbursalCompData >>>'+objDisbursal );
        if( objDisbursal == Null ){
            System.debug('inside null >>>'+objDisbursal );
            objDisbursalCompWrap.statusCode = 400;
            objDisbursalCompWrap.message = 'Invalid Data to Save.';
            return objDisbursalCompWrap;
        }

        try{

            System.debug('objDisbursal in insurance is >>>'+objDisbursal );

            List<Sobject> sObjList = new List<Sobject>();
            sObjList.add(objDisbursal);
            List<Disbursal_Payee__c> DisbPayyeObjList = new List<Disbursal_Payee__c>();
            List<Disbursal_Payee__c> DisbObjList =sObjList;
            
            System.debug('DisbObjList >>>>'+DisbObjList);
            if(DisbObjList.size()>0){

                for(Disbursal_Payee__c Obj : DisbObjList){
                    Disbursal_Payee__c disbursalPayObj = new Disbursal_Payee__c();
                    if(Obj.IsDisbIdCheck__c!='true'){
                        disbursalPayObj.Id=Obj.Id;
                    }

                    //if(Obj.IsDisbIdCheck__c=='true'){
                        disbursalPayObj.Disbursal__c=Obj.Disbursal__c;
                   // }

                    disbursalPayObj.Adjusted_Beneficiary_Amount__c=Obj.Adjusted_Beneficiary_Amount__c;
                    disbursalPayObj.Application__c=Obj.Application__c;
                    disbursalPayObj.Beneficiary_Account_Type__c=Obj.Beneficiary_Account_Type__c;
                    disbursalPayObj.Beneficiary_Amount__c=Obj.Beneficiary_Amount__c;
                    disbursalPayObj.Beneficiary_Bank_Account_Number__c=Obj.Beneficiary_Bank_Account_Number__c;
                    disbursalPayObj.Beneficiary_Bank_Name__c=Obj.Beneficiary_Bank_Name__c;
                    disbursalPayObj.Beneficiary_Branch_Name__c=Obj.Beneficiary_Branch_Name__c;
                    disbursalPayObj.Beneficiary_IFSC_Code__c=Obj.Beneficiary_IFSC_Code__c;
                    disbursalPayObj.Beneficiary_Name__c=Obj.Beneficiary_Name__c;
                    disbursalPayObj.Beneficiary_Type__c=Obj.Beneficiary_Type__c;
                    disbursalPayObj.Loan_Applicant__c=Obj.Loan_Applicant__c;
                    disbursalPayObj.Payment_Type__c=Obj.Payment_Type__c;
                    //disbursalPayObj.Is_Verified__c=Obj.Is_Verified__c;
                    
                    DisbPayyeObjList.add(disbursalPayObj);
                }
            }

            if(DisbPayyeObjList.size()>0){
                System.debug('Hi >>>>');
                upsert DisbPayyeObjList;
            }
            System.debug('DisbPayyeObjList 931 >>>>'+DisbPayyeObjList);
            Set<Id> disursalIdsSet = new Set<Id>();
            if(DisbPayyeObjList.size()>0){
                for(Disbursal_Payee__c dispayObj : DisbPayyeObjList){
                    disursalIdsSet.add(dispayObj.Disbursal__c);
                }
            }
            
          //  upsert objDisbursal;
            System.debug('disursalIdsSet is >>>'+disursalIdsSet);
            List<Disbursal__c> ListDisb1 =[ SELECT Id,RecordTypeId, RecordType.Name, Application__r.Stage__c
                                                FROM Disbursal__c
                                                WHERE Id IN : disursalIdsSet /*objDisbursal.Id*/ ];
            System.debug('ListDisb1 is >>>'+ListDisb1);
            //Karan Singh : 04-10-2022 : CH
            if(disursalIdsSet.size()>0 /*objDisbursal.Id.getSobjectType() == Schema.Disbursal__c.SObjectType*/){

                List<Disbursal__c> ListDisb = [ SELECT Id,RecordTypeId, RecordType.Name, Application__r.Stage__c
                                                FROM Disbursal__c
                                                WHERE Id IN : disursalIdsSet /*objDisbursal.Id*/ ];

                if( ListDisb[0].Application__r.Stage__c == 'Disbursal Author' && ListDisb[0].Application__r.Stage__c != ListDisb[0].RecordType.Name){
                    ListDisb[0].RecordTypeId = Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().get('Disbursal Author').getRecordTypeId();
                }
                else if(ListDisb[0].Application__r.Stage__c != ListDisb[0].RecordType.Name){
                    ListDisb[0].RecordTypeId = Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().get('Disbursal Maker').getRecordTypeId();
                }
                System.debug('update objDisbursal in insurance is >>>'+ListDisb[0] );
                update ListDisb[0];
            }
            //=================================================================
            //if prntRecordId is blank it means the above record will be the parent
            if( String.isNotBlank(base64) && String.isNotBlank(filename) ){

                ContentVersion objContntVrsn = new ContentVersion();
                objContntVrsn.VersionData = EncodingUtil.base64Decode(base64);
                objContntVrsn.FirstPublishLocationId = String.isNotBlank(prntRecordId) ? prntRecordId : objDisbursal.Id;
                objContntVrsn.Title = filename;
                objContntVrsn.PathOnClient = filename;
                objContntVrsn.PathOnClient = filename;
                objContntVrsn.Parent_Id__c = objContntVrsn.FirstPublishLocationId;

                insert objContntVrsn;
                system.debug( 'objContntVrsn id ' + objContntVrsn.Id );
            }
            objDisbursalCompWrap.statusCode = 201;
            objDisbursalCompWrap.message = 'Data saved successfully.';

        } catch (Exception e) {
            System.debug('message is >>>'+e.getMessage());
            System.debug('message line no is >>>'+e.getLineNumber());
            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }
        return objDisbursalCompWrap;
    }






    @AuraEnabled
    public static DisbursalCompWrap changeDisbursalRecTypeId( String jsonParamData){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();

        try{

            Map<String, Object> mapJsonParam =   (Map<String, Object>) JSON.deserializeUntyped(jsonParamData);
            Disbursal__c objDisb = new Disbursal__c( Id = String.valueOf(mapJsonParam.get('disbId')));
            if(Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().containsKey(String.valueOf(mapJsonParam.get('disbRecTypeName')))){

                objDisb.RecordTypeId = Schema.SObjectType.Disbursal__c.getRecordTypeInfosByName().get(String.valueOf(mapJsonParam.get('disbRecTypeName'))).getRecordTypeId();
                update objDisb;
            }

            objDisbursalCompWrap.statusCode = 200;
        } catch (Exception e) {

            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }
        return objDisbursalCompWrap;
    }

    @AuraEnabled
    public static DisbursalCompWrap saveSobjectLists( List<Sobject> listSobjects ){
        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        try{

            System.debug(' saveSobjectLists listSobject ' + listSobjects );
            upsert listSobjects;
            objDisbursalCompWrap.statusCode = 200;
        } catch (Exception e) {

            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }
        return objDisbursalCompWrap;
    }
    //Karan Singh : 27/09/2022 : CH
    @AuraEnabled
    public static DisbursalCompWrap deleteRecords( List<Sobject> listSobjects){

        DisbursalCompWrap objDisbursalCompWrap = new DisbursalCompWrap();
        try{

            delete listSobjects;
            objDisbursalCompWrap.statusCode = 200;
        } catch (Exception e) {

            objDisbursalCompWrap.statusCode = 500;
            objDisbursalCompWrap.message = e.getMessage();
        }
        return objDisbursalCompWrap;
    }

    //starting of code  added  by sandeep kumar
    @AuraEnabled
    public static List<Character__c> getNomineeData(String applicationId,String NomineeName){
        List<Character__c> charList = [select Id,Loan_Applicant__r.Customer_Information__r.Name,Loan_Applicant__r.Customer_Information__r.PersonBirthdate,Loan_Applicant__c,Relationship__c,Loan_Applicant__r.KYC_ID_Type_1__c,
                                       Loan_Applicant__r.KYC_Id_1__c, Loan_Applicant__r.Application__r.Nominee_Relationship_Type__c, Loan_Applicant__r.Application__r.Nominee_Party_Relationship_with_Insured__c
                                       from Character__c where Loan_Applicant__r.Application__c=:applicationId AND Loan_Applicant__r.Customer_Information__r.Name=:NomineeName  LIMIT 1];
        return charList;
    }

     @AuraEnabled
    public static Boolean getPennyDropStatus(String DisbPayeeId,String checkVerify){
        try {

            List<Disbursal_Payee__c> disbursalPayeeList = [select Id,Is_Verified__c from Disbursal_Payee__c where Id=:DisbPayeeId LIMIT 1]; 
            if(disbursalPayeeList.size()>0){

                if(checkVerify == 'false'){
                    Disbursal_Payee__c dbObj = new Disbursal_Payee__c();
                    dbObj.Id=disbursalPayeeList[0].Id;
                    dbObj.Is_Verified__c=false;
                    update dbObj;
                }
                if(disbursalPayeeList[0].Is_Verified__c){
                    return true;
                }else{
                    return false;
                }
            }
        } catch (Exception e) {
            System.debug('exception message is >>>'+e.getMessage());
            System.debug('exception message is >>>'+e.getLineNumber());
        }
        return false;
    }

    @AuraEnabled
    public static string setDisbursalDate(String appId){
        String approvalStatus ='';

        try{
        List<Application__c>appsList = new  List<Application__c>();
        List<Application__c> appList =[select Id,application_status__c,GetRepayScheduleCalled__c,Stage__c,LMS_Response_Reference__c from Application__c where Id=:appId AND Stage__c='Disbursal Author'];
        if(appList.size()>0){
             if(appList.size()>0){
                for(Application__c app: appList){
                    if(app.LMS_Response_Reference__c==NULL){
                        String businessDate = System.Label.Business_Date;
                        Application__c apps = new Application__c();
                        apps.Id=app.Id;
                        apps.Disbursal_Date__c=Date.parse(businessDate);
                        appsList.add(apps);
                    }
                }
                if(appsList.size()>0){
                    //update appsList;
                }

                if(appList.size()>0){
                        for(Application__c appobj: appList){
                            if(appobj.LMS_Response_Reference__c!=null && appobj.GetRepayScheduleCalled__c){
                                System.debug('inside firts if');
                                return appobj.LMS_Response_Reference__c+'+'+'true'+'+'+appobj.application_status__c;
                            }else if(appobj.LMS_Response_Reference__c!=null && !appobj.GetRepayScheduleCalled__c){
                                System.debug('inside second if');
                                return appobj.LMS_Response_Reference__c+'+'+'false'+'+'+appobj.application_status__c;
                            }
                        }
                }
                
                if(appList.size()>0){
                    approvalStatus = appList[0].application_status__c;
                }
               
             } 
        }
        }catch(Exception e){
            System.debug('exception is >>>'+e.getmessage());
            System.debug('exception line is >>>'+e.getLineNumber());
        }

        return 'false'+'+'+'false'+'+'+approvalStatus;
    }
    
    @AuraEnabled
    public static string checkDisbursalMemo(String apptId){
        try {
            String getTitleDoc ='';
            List<Application__c> appList= [select Id,Stage__c from Application__c where Id=:apptId LIMIT 1];
           /* if(appList.size()>0){
                for(Application__c appObj : appList){
                    for(ContentDocumentLink obj : appObj.ContentDocumentLinks){
                         getTitleDoc = obj.ContentDocument.title;
                        if(getTitleDoc.contains('Disbursal Memo')){
                            return true;
                        }
                    }
                }
            }*/

            String title='Disbursal Memo';
            String path='Disbursal Memo.PDF';
            String ftype='Disbursal Memo';

            PageReference PDf = Page.Disbursement_MemoVfPage;
            PDf.getParameters().put('id',apptId);
            PDf.setRedirect(false);
            Blob b ;
            if( Test.isRunningTest() ){
                b = Blob.valueOf('o');
            }else{
                b = PDf.getContentAsPdf();
            }
            ContentVersion cv = new ContentVersion(File_Type__c= ftype,Title = appList[0].Stage__c +'_'+title, PathOnClient = path, VersionData = b, FirstPublishLocationId = apptId,Is_Additional_Document__c=true,Uploaded_From__c=appList[0].Stage__c);
            insert cv;
            return cv.Id;
            
        } catch (Exception e) {
            return '';
           // throw new AuraHandledException(e.getMessage());
        }
        
    }



    // starting of code  added  by sandeep kumar


    public class DisbursalCompWrap{
        @AuraEnabled public Application__c objAppt;
        @AuraEnabled public Sobject objSobject;
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String  message;
        @AuraEnabled public Map<String,String> mapExtraParams = new Map<String,String>();
        @AuraEnabled public String  disbMetaPrefix;
        @AuraEnabled public List<Sobject> listSObject = new List<Sobject>();
        @AuraEnabled public String sObjectListType;
        @AuraEnabled public List<Sobject> listSObject2 = new List<Sobject>();
    }

    public class insuranceWrap{
        @AuraEnabled public String Id;
        @AuraEnabled public String NomineeDOB;
        @AuraEnabled public String NomineeKYCIDNo;
        @AuraEnabled public String NomineeKYCIDType;
        @AuraEnabled public String InsuranceMedicalTestResult;
        @AuraEnabled public String InsuranceRequirement;
        @AuraEnabled public String InsuranceWaiver;
        @AuraEnabled public String InsuredPersonDateofBirth;
        @AuraEnabled public String InsuredPersonName;
        @AuraEnabled public String NomineeName;
        @AuraEnabled public String NomineeRelationshipType;
        @AuraEnabled public String NomineeRelationshipwithInsuredPerson;
        @AuraEnabled public String NomineeType;

        insuranceWrap(){
            NomineeDOB = '';
            NomineeKYCIDNo = '';
            NomineeKYCIDType = '';
            InsuranceMedicalTestResult = '';
            InsuranceRequirement = '';
            InsuranceWaiver = '';
            InsuredPersonDateofBirth = '';
            InsuredPersonName = '';
            NomineeName = '';
            NomineeRelationshipType = '';
            NomineeRelationshipwithInsuredPerson = '';
            NomineeType = '';
        }



    }


    //@Description: For validation msg Advance Installment fee should equal to Emi_PcAc__c*Number_of_advance_EMI__c
    @AuraEnabled
    public static String getAdvanceInstallmentAmt(String applicationId){
        try {
            Boolean advantInsFee = false;
            Decimal totalAmount = 0;

            String validationMsg;
            Integer numberofAdvanceEMI;
        if(String.isNotBlank(applicationId) && String.isNotEmpty(applicationId) ){
            
            List<Application__c> app = [SELECT Name, Emi_PcAc__c, Number_of_advance_EMI__c FROM Application__c WHERE Id = : applicationId];
            
            //branchCode = app[0].Sourcing_Branch__r.Branch_Code__c;
            if(app != null && app.size() >0){
                
                if(app[0].Number_of_advance_EMI__c != null){
                    numberofAdvanceEMI = Integer.valueOf(app[0].Number_of_advance_EMI__c);
                }

                List<Fee_Creation__c> feeList = [SELECT Name,Fee_Amount__c,  Description__c, Total_Fee__c FROM Fee_Creation__c WHERE Application__c = : applicationId ];
                Fee_Creation__c objFee = new Fee_Creation__c();

                for(Fee_Creation__c itrFeeCreation : feeList){
                    if(!String.isBlank(itrFeeCreation.Description__c) && itrFeeCreation.Description__c.contains('Advance EMI') ){
                        objFee = new Fee_Creation__c();
                        objFee.Total_Fee__c = itrFeeCreation.Total_Fee__c;   
                        objFee.Description__c = itrFeeCreation.Description__c;
                        objFee.Fee_Amount__c = itrFeeCreation.Fee_Amount__c; 
                    }
                }

                //--------11 May 2023 this is assured by client there will be only one rec according to description = 'Advance EMI'
                if(objFee != null){
                    if(numberofAdvanceEMI == 0 && objFee.Fee_Amount__c > numberofAdvanceEMI){   //case 1
                        validationMsg = 'fee amount should be 0 as there is no advance emi';
                    }else if(numberofAdvanceEMI != null && numberofAdvanceEMI > 0 ){
                        if(app[0].Emi_PcAc__c != null && objFee.Total_Fee__c != null){          //case 2
                            if(objFee.Total_Fee__c != (app[0].Emi_PcAc__c * numberofAdvanceEMI) ){
                                validationMsg = 'Total fee should be equal to multiple of EMI and number of Advance EMI';
                            }
                        }
                    }
                }else if(objFee != null && numberofAdvanceEMI > 0 ){ 
                    validationMsg = 'Advance Installment fee is not there';
                }

                
                //--------11 May 2023 -----------------------------

                // if(feeList != null && feeList.size() > 0){
                //     for(Fee_Creation__c fee : feeList){
                //         if(fee.Description__c.contains('Advance Installment')){
                //             System.debug('description'+ fee.Description__c);
                //             totalAmount += fee.Total_Fee__c;
                //         }
                        
                //     }
                // }
                // if(app[0].Emi_PcAc__c != null && app[0].Number_of_advance_EMI__c != null){
                //     if(totalAmount == (app[0].Emi_PcAc__c * Integer.valueOf(app[0].Number_of_advance_EMI__c))){
                //         advantInsFee = false; // no validation for advance installment
                //     }
                //     else{
                //         advantInsFee = true;  // validation for advance installment
                        
                //     }
                    
                // }
                // else{
                //     if(totalAmount == 0){
                //         advantInsFee = false; // no validation for advance installment
                //     }
                //     else{
                //         advantInsFee = true; // validation for advance installment
                        
                //     }
                // }
            }
        }
        return validationMsg; 
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}