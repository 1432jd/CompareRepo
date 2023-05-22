import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//------------------------------------------------------------------------------

import getInsuranceDetailsData from "@salesforce/apex/Fiv_Disb_LwcController.getInsuranceDetailsData";
import getfeeData from "@salesforce/apex/Fiv_Disb_LwcController.getfeeData";
import getLoanAplicantNames from "@salesforce/apex/Fiv_Disb_LwcController.getLoanApplicantnames";
import getLoanApplicants from "@salesforce/apex/Fiv_Disb_LwcController.getLoanApplicants";
import getInsuranceDetailRecords from "@salesforce/apex/Fiv_Disb_LwcController.getInsuranceDetailRecords";
import getMetaDataFields from '@salesforce/apex/Fiv_Disb_LwcController.getMetaDataFields';
import getRelatedRecords from '@salesforce/apex/Fiv_Disb_LwcController.getRelatedRecords';
import saveInsuranceDetailData from '@salesforce/apex/Fiv_Disb_LwcController.saveDisbursalCompData';
import getParentAndRelatedData from '@salesforce/apex/Fiv_Disb_LwcController.getParentAndRelatedData';
import getDocumentId from '@salesforce/apex/Fiv_Disb_LwcController.getDocumentId';
import getNomineeData from '@salesforce/apex/Fiv_Disb_LwcController.getNomineeData';
import getApplicantsAcData from '@salesforce/apex/Fiv_Disb_LwcController.getApplicantsAcData';

import getLoanApplicantDOB from '@salesforce/apex/Fiv_Disb_LwcController.getLoanApplicantDOB'
import getNominee from '@salesforce/apex/Fiv_Disb_LwcController.getNominee'

//------------------------------------------------------------------------------
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import INSURANCE_DETAIL_OBJECT from '@salesforce/schema/Insurance_Details__c';
import getAppStage from '@salesforce/apex/Fiv_Disb_LwcController.getAppStage';
import INSURANCE_WAIVER from '@salesforce/schema/Insurance_Details__c.Insurance_Waiver__c';
import NOMINEE_RELATION_TYPE from '@salesforce/schema/Insurance_Details__c.Nominee_Relationship_Type__c';
import NOMINEE_KYC_ID_TYPE from '@salesforce/schema/Insurance_Details__c.Nominee_KYC_ID_Type__c';
import INSURANCE_REQUIREMENT from '@salesforce/schema/Insurance_Details__c.Insurance_Requirement__c';
import INSURNCE_MEDICAL_TEST_RESULT from '@salesforce/schema/Insurance_Details__c.Insurance_Medical_Test_Result__c';

export default class Fiv_Disb_InsuranceDetails extends NavigationMixin(LightningElement) {

    @api obj_parent_appt_wrapper_data;
    @track trackInsurance;
    @track listExistInsuranceDetails;
    @track objInsuranceDetails;
    @track insuranceDetailRecord = {
        'Nominee_Relationship_Type__c': '',
        'Nominee_Relationship_with_Insured_Person__c': ''
    }
    @track mapDisbPayeeIdWithDocumentId;
    @track relationWithInsuredPersonPicklistVal;
    @track loanApplicantNames = [];
    showLoader = false;
    currentEditInsuranceDetailId = null; //this will store current editing Insurance Details Id
    @track acceptedFormats = ['.png', '.jpg', '.pdf'];
    @track fileData = {};
    showNominee = true; //Karan Singh : 28-09-2022 : CH
    @track nomineeTypeValue = [];
    @track relationshipTracker = '';
    @track checkrelationArr;
    @track isdisable = false;
    @track makeUploadRequire = false;
    @track medicalTestResultPicklistVal;
    @track stageName = '';
    @track isShow = true;
    @track applicantDOBs;
    @track applicationRecords;
    @track currentDate;
    @track yearsDiff;
    @track objinsurance=[];
    @track showInsuranceData = { "Id": '', 'InsuranceMedicalTestResult': '', 'InsuranceRequirement': '', 'InsuranceWaiver': '', 'InsuredPersonDateofBirth': '', 'InsuredPersonName': '', 'NomineeDOB': '', 'NomineeKYCIDNo': '', 'NomineeKYCIDType': '', 'NomineeName': '', 'NomineeRelationshipType': '', 'NomineeRelationshipwithInsuredPerson': '', 'NomineeType': ''};    get options() {
            return [
            { label: 'Part of Loan', value: 'Part of Loan' },
            { label: 'Not part of loan', value: 'Not part of loan' },
        ];
    }

    @track loanApplicants = [];
    disableSaveEditBtn = false;
    personNameErr = '';
    personDobErr = '';
    nomineeTypeErr = '';
    nomineeNameErr = '';
    nomineeRelTypeErr = '';
    relWithInsuredPersonErr = '';
    kycIdTypeErr = '';
    kycIdNoErr = '';
    nomineeDobErr = '';
    insuranceReqErr = '';
    testResultErr = '';
    fileErrMsg = '';
    timeId = '';
    disableNomineeType = false;
    showui = true;
    nomineePartOfLoan = false; //Karan SIngh : 30-09-2022 : CH - if part of loan then show combobox

    @wire(getObjectInfo, { objectApiName: INSURANCE_DETAIL_OBJECT })
    insuranceDetailMetadata;

    // now retriving the StageName picklist values of Opportunity

    @wire(getPicklistValues, {
        recordTypeId: '$insuranceDetailMetadata.data.defaultRecordTypeId',
        fieldApiName: INSURANCE_WAIVER
    }) insuranceWaiverPicklistVal;

    @wire(getPicklistValues, {
        recordTypeId: '$insuranceDetailMetadata.data.defaultRecordTypeId',
        fieldApiName: NOMINEE_RELATION_TYPE
    }) nomineeRelationTypePicklistVal;

    @wire(getPicklistValues, {
        recordTypeId: '$insuranceDetailMetadata.data.defaultRecordTypeId',
        fieldApiName: NOMINEE_KYC_ID_TYPE
    }) nomineeKycIdTypePicklistVal;

    @wire(getPicklistValues, {
        recordTypeId: '$insuranceDetailMetadata.data.defaultRecordTypeId',
        fieldApiName: INSURANCE_REQUIREMENT
    }) insuranceReqPicklistVal;

    /* @wire(getPicklistValues, {
         recordTypeId: '$insuranceDetailMetadata.data.defaultRecordTypeId',
         fieldApiName: INSURNCE_MEDICAL_TEST_RESULT
     }) medicalTestResultPicklistVal;*/


    /* bloodRelatives = [
         { label: 'Husband', value: 'Husband' },
         { label: 'Wife', value: 'Wife' },
         { label: 'Son', value: 'Son' },
         { label: 'Daughter', value: 'Daughter' },
         { label: 'Father', value: 'Father' },
         { label: 'Mother', value: 'Mother' },
         { label: 'Brother', value: 'Brother' },
         { label: 'Sister', value: 'Sister' },
         { label: 'Grandfather', value: 'Grandfather' },
         { label: 'Grandmother', value: 'Grandmother' },
     ];
 
     nonBloodRelatives = [
         { label: 'Uncle', value: 'Uncle ' },
         { label: 'Aunty', value: 'Aunty ' },
         { label: 'In laws', value: 'In laws ' },
         { label: 'Cousin', value: 'Cousin ' },
         { label: 'Nephew', value: 'Nephew' },
         { label: 'Neice', value: 'Neice' },
     ];*/

    bloodRelatives = [
        { label: 'Husband of', value: 'Husband of' },
        { label: 'Wife of', value: 'Wife of' },
        { label: 'Son of', value: 'Son of' },
        { label: 'Daughter Of', value: 'Daughter Of' },
        { label: 'Father of', value: 'Father of' },
        { label: 'Mother of', value: 'Mother of' },
        { label: 'Brother of', value: 'Brother of' },
        { label: 'Sister of', value: 'Sister of' },
        { label: 'Grandfather of', value: 'Grandfather of' },
        { label: 'Grandmother of', value: 'Grandmother of' },
        { label: 'Grandson of', value: 'Grandson of' },
        { label: 'Granddaughter of', value: 'Granddaughter of' },
    ];

    nonBloodRelatives = [
        { label: 'Uncle of', value: 'Uncle of' },
        { label: 'Aunt of', value: 'Aunt of' },
        { label: 'In laws', value: 'In laws ' },
        { label: 'Cousin of', value: 'Cousin of' },
        { label: 'Nephew', value: 'Nephew' },
        { label: 'Neice', value: 'Neice' },
        { label: 'Brother in law of', value: 'Brother in law of' },
    ];

    medicalTestResultPicklistFirst = [
        { label: 'Standard', value: 'Standard' },
    ];

    nomineeType = [
        { label: 'Part of Loan', value: 'Part of Loan' },
        { label: 'Not Part of Loan', value: 'Not Part of Loan' },
    ]

    medicalTestResultPicklistSecond = [
        { label: 'Standard', value: 'Standard' },
        { label: 'Rated Up', value: 'Rated Up' },
        { label: 'Rejected', value: 'Rejected' },
    ];



    // this.checkrelationArr = this.nonBloodRelatives;


    applicationId = '';
    isExistInsuranceDetails = false;

    //--------------------------------------------------------------------------
    connectedCallback() {
        
        this.doInit();
        this.loanApplicantNames = [];
        getLoanAplicantNames({ applicationId: this.applicationId }).then(result => {
            if(result){
                result.forEach(currentItem => {
                    this.loanApplicantNames.push({label : ''+currentItem, value : ''+currentItem});
                });
            }
        })

        getLoanApplicants({ applicationId: this.applicationId }).then((result) => {
            if(result && result.length){
                let temp = [];
                result.forEach(la => {
                    temp.push({label : la.Applicant_Name__c, value : la.Id});
                });
                this.loanApplicants = JSON.parse(JSON.stringify(temp));
            }
        }).catch((err) => {
            console.log('Error in getLoanApplicant = ',err);
        });
       
        this.isdisable = true;
        this.makeUploadRequire = false;
        this.getDOBs();
        this.getNomineeValue();
        this.getInsuranceDetailsData();
        console.log('Loan Applicant Names', this.loanApplicantNames);
    }

    getInsuranceDetailsData() {
        getInsuranceDetailsData({ appId: this.applicationId })
            .then(result => {
                console.log('the data of result is >>>',result);
                this.objinsurance = result;
                console.log('the data of object is >>>',this.objinsurance);
            }).catch(error => {
                console.log('data Not Found', error);
            })
    }

    getDOBs() {
        getLoanApplicantDOB({ applicationId: this.applicationId })
            .then(result => {
                this.applicantDOBs = result;
            })
    }

    getNomineeValue() {
        getNominee({ applicationId: this.applicationId})
            .then(result => {
                console.log('loanApplicantNames', JSON.parse(JSON.stringify(this.loanApplicantNames)));
                console.log('ApplicationRecords Found', result);
                this.applicationRecords = result;
              //  if(!this.listExistInsuranceDetails.length){
                if(this.applicationRecords!=null){
                    this.insuranceDetailRecord.Nominee_Type__c = this.applicationRecords.Nominee_Type__c/*==='Yes'?'Part of Loan':'Not Part of Loan'*/;
                    //this.insuranceDetailRecord.Nominee_Type__c = this.applicationRecords.Nominee__c==='Yes'?'Part of Loan':'Not Part of Loan';
                    this.insuranceDetailRecord.Insured_Person_Name__c = this.applicationRecords.Insured_Person_Name__c;
                    this.insuranceDetailRecord.Nominee_Name__c = this.applicationRecords.Nominee_Name__c;
                    this.insuranceDetailRecord.Nominee_Relationship_Type__c = this.applicationRecords.Nominee_Relationship_Type__c;
                    if (this.insuranceDetailRecord.Nominee_Relationship_Type__c === 'Blood Relative') {
                        this.relationWithInsuredPersonPicklistVal = this.bloodRelatives;
                    }
                    else if (this.insuranceDetailRecord.Nominee_Relationship_Type__c === 'Not a Blood Relative') {
                        this.relationWithInsuredPersonPicklistVal = this.nonBloodRelatives;
                    }
                    if(this.insuranceDetailRecord.Nominee_Type__c === 'Part of Loan'){
                        this.nomineePartOfLoan = true;
                    }
                    else if (this.insuranceDetailRecord.Nominee_Type__c === 'Not Part of Loan'){
                        this.nomineePartOfLoan = false;
                    }
                    this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = this.applicationRecords.Nominee_Relationship_with_Insured_Person__c;
                    getNomineeData({ applicationId: this.applicationId, NomineeName: this.applicationRecords.Nominee_Party__c})
                        .then((result) => {
                            console.log('Getting Nominee Data ', JSON.stringify(result));
                            
                            JSON.parse(JSON.stringify(result)).forEach(element => {
                                if(element.Loan_Applicant__r){
                                    this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = element.Loan_Applicant__r.KYC_ID_Type_1__c;
                                    this.insuranceDetailRecord.Nominee_KYC_ID_No__c = element.Loan_Applicant__r.KYC_Id_1__c;
                                    if(element.Loan_Applicant__r.Customer_Information__r){
                                        this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = element.Loan_Applicant__r.Customer_Information__r.PersonBirthdate;
                                    }
                                }
                            });
                        });

                    this.enableDisableFields();

                    this.trackInsurance = this.insuranceDetailRecord;
                }
               

                console.log('this.this.objinsurance in getnominee',this.objinsurance);
                  console.log('this.trackInsurance in getnominee',this.trackInsurance);
                console.log('this.insuranceDetailRecord in getnominee',this.insuranceDetailRecord);
                //this.doInit();
            })
            .catch(error => {
                console.log('ApplicationRecords Not Found', error);
            })
    }


   

    getfeeData() {
        getfeeData({
            appId: this.applicationId
        }).then((result) => {
            if (result) {

                var appResult = result;
                console.log('appResult is >>>',appResult);
                

            if(appResult[0].Insurance_Requirement__c){
                this.insuranceDetailRecord.Insurance_Requirement__c = appResult[0].Insurance_Requirement__c;
                var autoPopVal = 'Standard';
                this.medicalTestResultPicklistVal = this.medicalTestResultPicklistFirst;
                this.insuranceDetailRecord.Insurance_Medical_Test_Result__c = autoPopVal;
            }

            if(appResult[0].Insurance_Medical_Test_Result__c){

                    this.medicalTestResultPicklistVal = this.medicalTestResultPicklistSecond;
                    this.insuranceDetailRecord.Insurance_Medical_Test_Result__c = appResult[0].Insurance_Medical_Test_Result__c;

            }
             //   this.insuranceDetailRecord.Insurance_Requirement__c = appResult[0].Insurance_Requirement__c;
               // this.insuranceDetailRecord.Insurance_Medical_Test_Result__c = appResult[0].Insurance_Medical_Test_Result__c;

               /* if (this.insuranceDetailRecord.Insurance_Requirement__c == 'DOGH') {
                    var autoPopVal = 'Standard';
                    this.medicalTestResultPicklistVal = this.medicalTestResultPicklistFirst;
                    this.insuranceDetailRecord.Insurance_Medical_Test_Result__c = autoPopVal;


                } else if (this.insuranceDetailRecord.Insurance_Requirement__c == 'DOGH + MT') {

                    this.medicalTestResultPicklistVal = this.medicalTestResultPicklistSecond;

                }*/
            }
        }).catch((err) => {
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }

    getAppStageName() {

        getAppStage({
            apptId: this.applicationId
        }).then((result) => {
            var appValues = JSON.parse(JSON.stringify((result)));
            console.log('appValues >>>', appValues);
            this.stageName = appValues[0].Stage__c;
            if (this.stageName == 'Disbursal Author') {
                this.isShow = false;
            } else {
                this.isShow = true;
            }
        }).catch((err) => {
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }

    getApplicantsAcData(apptName) {

        getApplicantsAcData({
            apptId: this.applicationId, applicantName: apptName
        }).then((result) => {
            if (result) {
                var apptValues = JSON.parse(JSON.stringify((result)));
                this.insuranceDetailRecord.Insured_Person_Date_of_Birth__c = apptValues[0].Dob__c;
            }

        }).catch((err) => {
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }


    //02/09/2022 : added By karan to reinit the datable 
    doInit() {
        this.nomineePartOfLoan = false; //Karan Singh : 30-09-2022 : CH
        this.showui = true;
        this.disableNomineeType = false;
        this.nomineeTypeValue = [];
        this.loanApplicantNames = [];
        this.timeId = '';
        console.log('    ', JSON.stringify(this.obj_parent_appt_wrapper_data));
        this.applicationId = this.obj_parent_appt_wrapper_data.objAppt.Id;
        this.getAppStageName();

        this.disbursalId = this.checkExistingDisbursalId();
        console.log('application id this.disbursalId ', this.applicationId, this.disbursalId);
        this.reInitInsuranceDetail();
        this.checkExistInsuranceDetailRecords();
        this.mapDisbPayeeIdWithDocumentId = new Map();
        this.disableSaveEditBtn = false;

        getInsuranceDetailRecords({ applicationId: this.applicationId }).then(result => {

            console.log('existing records of insurance details ', JSON.stringify(result), result.length);
            this.listExistInsuranceDetails = [];

            for (let index in result) {
                console.log('name ', index, result[index]);
                result[index].nomineeType = '';
                if (result[index].Part_of_Loan__c) {
                    result[index].nomineeType = 'Part of Loan';
                }
                if (result[index].Not_Part_of_Loan__c) {
                    if (result[index].nomineeType != '') {
                        result[index].nomineeType += ', ';
                    }
                    result[index].nomineeType += 'Not part of loan';
                }
                this.listExistInsuranceDetails.push(result[index]);
            }
            console.log('list exist obj is >>>',this.listExistInsuranceDetails);
            console.log('Doinit this.listExistInsuranceDetails ', JSON.stringify(this.listExistInsuranceDetails));
            this.getLoanApptNames();
        }).catch(error => {
            console.log('error occured', error);
        });
    }
    getLoanApptNames() {

        getLoanAplicantNames({ applicationId: this.applicationId }).then(result => {
            console.log('Search Result ', JSON.stringify(result), result);
            this.loanApplicantNames = [];
            try {
                for (let index in result) {
                    console.log('name ', index, result[index]);
                    this.loanApplicantNames.push({
                        label: '' + result[index], value: '' + result[index]
                    });
                }
            } catch (error) {
                console.log('error ', error.message);
            }
        }).catch(error => {
            console.log('error occured', error);
        });
    }
    get existingInsuranceLength() {
        return this.listExistInsuranceDetails && this.listExistInsuranceDetails.length > 0 ? true : false;
    }

    checkExistingDisbursalId() {

        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Disbursals__r')) {
            return this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id;
        }
        return null;
    }


    renderedCallback() {
        //this.enableDisableFields();
    }

    get uploadedfileName() {
        return this.fileData.hasOwnProperty('filename') ? this.fileData.filename : 'Nominee KYC Upload';
    }

    reInitInsuranceDetail() {
        this.insuranceDetailRecord = { 'sobjectType': 'Insurance_Details__c', 'Nominee_Relationship_Type__c': ''};
        //Karan Singh : 28-09-2022 : CH - (NP-17-09-22) - N

        console.log('this.obj_parent_appt_wrapper_data.objAppt >>>', this.obj_parent_appt_wrapper_data.objAppt);
        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Name__c')) {
            this.getApplicantsAcData(this.obj_parent_appt_wrapper_data.objAppt.Name__c);
            this.insuranceDetailRecord.Insured_Person_Name__c = this.obj_parent_appt_wrapper_data.objAppt.Name__c;
        }
        this.getfeeData();
        console.log('this.obj_parent_appt_wrapper_data.objAppt.Insurance_Requirement__c >>', this.obj_parent_appt_wrapper_data.objAppt.Insurance_Requirement__c);
        /* if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Insurance_Requirement__c')) {
             this.insuranceDetailRecord.Insurance_Requirement__c = this.obj_parent_appt_wrapper_data.objAppt.Insurance_Requirement__c;
         }*/
    }

    handleInputChange(event) {

        if(event.target.dataset.field == 'Nominee_DOB_as_per_KYC__c'){
            if(this.objinsurance){
                this.objinsurance[0].NomineeDOB=event.detail.value;
            }
                
                this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = event.detail.value;
        }

        if(event.target.dataset.field == 'Nominee_KYC_ID_Type__c'){
            if(this.objinsurance){
                this.objinsurance[0].NomineeKYCIDType=event.detail.value;
            }
                this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = event.detail.value;
        }
        if(event.target.dataset.field == 'Nominee_KYC_ID_No__c'){
            if(this.objinsurance){
                this.objinsurance[0].NomineeKYCIDNo=event.detail.value;
            }
                this.insuranceDetailRecord.Nominee_KYC_ID_No__c = event.detail.value;
        }


         if(event.target.dataset.field == 'Nominee_DOB_as_per_KYC__c'){
             if(this.objinsurance){
            this.objinsurance[0].NomineeDOB=event.detail.value;
             }
            var date = new Date();
            var dateString = new Date(date.getTime() - (date.getTimezoneOffset() * 60000 ))
                    .toISOString()
                    .split("T")[0];

                var date1 = new Date();
                var date2 = new Date(event.detail.value);
                var yearsDiff =  Math.abs(date1.getFullYear() - date2.getFullYear());

                if(yearsDiff<18){
                    var dd = date2.getDate();
                    var mm = date2.getMonth();
                    var yyyy = date2.getFullYear() - 1;
                    var todayDate = yyyy + '-' + mm + '-' + dd;
                    this.currentDate=todayDate;
                }else{
                    this.currentDate='';
                }
        }

        if(event.target.dataset.field === 'Insurance_Waiver__c' && event.detail.value === 'No'){
            if(this.objinsurance){
            this.objinsurance[0].InsuranceWaiver=event.detail.value;
            }
            this.listExistInsuranceDetails.forEach(element => {
                if(element.Id === this.insuranceDetailRecord.Id){
                    this.insuranceDetailRecord = JSON.parse(JSON.stringify(element));
                }
            });
        }
        console.log(' before this.insuranceDetailRecord is >>>', this.insuranceDetailRecord);
        console.log('event.detail.value 123 ', event.target.dataset.field + ' ' + event.detail.value);
        this.insuranceDetailRecord[event.target.dataset.field] = event.detail.value;

        if (event.target.dataset.field == 'Insured_Person_Name__c') {
            if(this.objinsurance){
            this.objinsurance[0].InsuredPersonName=event.detail.value;
            }
            console.log('Applicant DOB', this.applicantDOBs);
            this.insuranceDetailRecord.Insured_Person_Date_of_Birth__c = this.applicantDOBs[event.detail.value];
        }

        /*starting of code added by sandeep kumar */

        if (event.target.dataset.field == 'Insurance_Requirement__c' && event.detail.value == 'DOGH') {
            var autoPopVal = 'Standard';
            this.medicalTestResultPicklistVal = this.medicalTestResultPicklistFirst;
            this.insuranceDetailRecord.Insurance_Medical_Test_Result__c = autoPopVal;
            this.insuranceDetailRecord.Insurance_Requirement__c = event.detail.value;
            if(this.objinsurance){
                this.objinsurance[0].InsuranceRequirement=event.detail.value;
            }

        } else if (event.target.dataset.field == 'Insurance_Requirement__c' && event.detail.value == 'DOGH + MT') {
            
            this.medicalTestResultPicklistVal = this.medicalTestResultPicklistSecond;
            this.insuranceDetailRecord.Insurance_Requirement__c = event.detail.value;
            if(this.objinsurance){
            this.objinsurance[0].InsuranceRequirement=event.detail.value;
            }
        }

        if (event.target.dataset.field == 'Insurance_Medical_Test_Result__c'){
            this.insuranceDetailRecord.Insurance_Medical_Test_Result__c = event.detail.value;
            if(this.objinsurance){
            this.objinsurance[0].InsuranceMedicalTestResult=event.detail.value;
            }
        }

        if (event.target.dataset.field == 'Nominee_Name__c' /*&& this.nomineePartOfLoan*/) {
            if(this.objinsurance){
            this.objinsurance[0].NomineeName=event.detail.value;
            }
            this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = '';
            this.insuranceDetailRecord.Nominee_KYC_ID_No__c = '';
            this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = '';
            this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = '';
            this.insuranceDetailRecord.Nominee_Relationship_Type__c = '';
            this.relationshipTracker = '';

            var nomineeData = [];
            var getloanApplicantData;
            console.log('inside the target of nominee name >>>');
            var applicantName = event.detail.value;
            getNomineeData({ applicationId: this.applicationId, NomineeName: applicantName }).then((result) => {
                nomineeData = JSON.parse(JSON.stringify(result));

                console.log('nomineeData data is >>>', nomineeData);

                nomineeData.forEach(currentItem => {
                    console.log('relationship is >>>', currentItem.Relationship__c);
                    this.relationshipTracker = currentItem.Nominee_Party_Relationship_with_Insured__c;
                    console.log('this.insuranceDetailRecord.Relationship__c is >>>', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);
                    if (currentItem.Loan_Applicant__r) {
                        getloanApplicantData = currentItem.Loan_Applicant__r;
                    }
                    if(currentItem.Loan_Applicant__r.Application__r){
                        this.insuranceDetailRecord.Nominee_Relationship_Type__c = currentItem.Loan_Applicant__r.Application__r.Nominee_Relationship_Type__c;
                        this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = currentItem.Loan_Applicant__r.Application__r.Nominee_Party_Relationship_with_Insured__c;
                    }
                });
                this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = getloanApplicantData.Customer_Information__r.PersonBirthdate;
                //this.insuranceDetailRecord.Nominee_KYC_ID_No__c=getloanApplicantData.Customer_Information__r.PersonBirthdate;
                this.insuranceDetailRecord.Nominee_KYC_ID_No__c = getloanApplicantData.KYC_Id_1__c;
                this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = getloanApplicantData.KYC_ID_Type_1__c;


                if (this.nonBloodRelatives.some(person => person.label == this.relationshipTracker)) {
                    this.relationWithInsuredPersonPicklistVal = this.nonBloodRelatives;
                    this.insuranceDetailRecord.Nominee_Relationship_Type__c = 'Not a Blood Relative';
                    this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = this.relationshipTracker;
                } else if (this.bloodRelatives.some(person => person.label == this.relationshipTracker)) {
                    console.log('inside if check bloof relative');
                    this.relationWithInsuredPersonPicklistVal = this.bloodRelatives;
                    this.insuranceDetailRecord.Nominee_Relationship_Type__c = 'Blood Relative';
                    if (this.insuranceDetailRecord.Nominee_Relationship_Type__c) {
                        this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = this.relationshipTracker;

                    }
                    console.log('dependent if check bloof relative', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);
                }

                console.log('after this.insuranceDetailRecord is >>>', this.insuranceDetailRecord);

            }).catch((err) => {
                console.log('Error in getExistingRecord= ', err);
            });
        }


        /*ending of code added bu sandeep kumar */

        if (event.target.dataset.field == 'Nominee_Type__c') {
            if(this.objinsurance){
            this.objinsurance[0].NomineeType=event.detail.value;
            }
            // let nomineeRelationType = this.template.querySelector("lightning-combobox[data-field=Nominee_Type__c]").value;
            this.insuranceDetailRecord.Nominee_Type__c = event.detail.value;
            console.log('this.insuranceDetailRecord.Nominee_Type__c value sis >>', this.insuranceDetailRecord.Nominee_Type__c);
            console.log('this record.insuranceDetailRecord.Nominee_Type__c value sis >>', this.insuranceDetailRecord);

            //Karan SIngh : 30-09-2022 : CH 
            // var arrNomineType = this.template.querySelector("lightning-checkbox-group").value;
            //var arrNomineType = this.template.querySelector("lightning-combobox[data-field=Nominee_Type__c]").value;
            var arrNomineType = this.insuranceDetailRecord.Nominee_Type__c;
            console.log(arrNomineType);
            this.nomineeTypeValue.push(arrNomineType);

            if (arrNomineType == 'Part of Loan') {
                this.nomineePartOfLoan = true;
            } else {
                this.nomineePartOfLoan = false;
            }


            //  this.nomineePartOfLoan = arrNomineType.includes("Part of Loan") ? true : false;
            this.insuranceDetailRecord.Nominee_Name__c = '';
            /* //Karan SIngh : 30-09-2022 : CH 
            if (event.detail.value.includes('Part of Loan')) {
                this.nomineeTypeValue.push('Part of Loan');
            }

            if (event.detail.value.includes('Not part of loan')) {
                this.nomineeTypeValue.push('Not part of loan');
            }*/
            console.log('this.nomineePartOfLoan before check>>', this.nomineePartOfLoan);
            if (this.nomineePartOfLoan) {
                console.log('inside make upload require');
                this.fileErrMsg = '';
                this.makeUploadRequire = false;
            } else if (!this.nomineePartOfLoan) {
                console.log('else of inside make upload require');
                this.makeUploadRequire = true;
              //  this.relationshipTracker = '';
               // this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = '';
               // this.insuranceDetailRecord.Nominee_KYC_ID_No__c = '';
               // this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = '';
               // this.insuranceDetailRecord.Nominee_Relationship_Type__c = '';
               // this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = '';
            }
            console.log('checking handle relation>>', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);

            if (arrNomineType.length == 0) {
                console.log('inside arr length if');
                this.relationshipTracker = '';
                this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = '';
                this.insuranceDetailRecord.Nominee_KYC_ID_No__c = '';
                this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = '';
                this.insuranceDetailRecord.Nominee_Relationship_Type__c = '';
                this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = '';
            }

            if (this.nomineeTypeValue.length == 1) {
                this.nomineeTypeErr = '';
            }
        }

        if (event.target.dataset.field == 'Insurance_Waiver__c' && event.detail.value == 'Yes' && this.insuranceDetailRecord.Id) {
           if(this.objinsurance){
            this.objinsurance[0].InsuranceWaiver=event.detail.value;
            
           }
         //  this.insuranceDetailRecord = {};
            let tempInsuranceDetailId = this.insuranceDetailRecord.Id;
            if (this.insuranceDetailRecord.Insurance_Waiver__c == 'Yes') {
                this.insuranceDetailRecord = {};
                this.insuranceDetailRecord.Insurance_Waiver__c = 'Yes';
                this.insuranceDetailRecord.Id = tempInsuranceDetailId;
                this.insuranceDetailRecord.Nominee_Type__c='';
                this.nomineeTypeValue = [];
            }
        }

        console.log('this.insuranceDetailRecord.Id >>>', this.insuranceDetailRecord.Id);
        /*   if (event.target.dataset.field == 'Insurance_Waiver__c' && event.detail.value == 'No' /*&&  this.insuranceDetailRecord.Id){
               let tempInsuranceDetailId = this.insuranceDetailRecord.Id;
               console.log('inside insurance id');
               if (this.insuranceDetailRecord.Insurance_Waiver__c == 'No') {
                   console.log('inside no else');
                   this.insuranceDetailRecord = {};
                   this.insuranceDetailRecord.Insurance_Waiver__c = 'No';
                   this.insuranceDetailRecord.Id = tempInsuranceDetailId;
                   this.nomineeTypeValue = [];
               }
           }*/

        let nomineeRelationType = this.template.querySelector("lightning-combobox[data-field=Nominee_Relationship_Type__c]").value;
        console.log('nomineeRelationType ', nomineeRelationType, this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);
        // if (this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c && this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c != '') {
        if (nomineeRelationType == 'Blood Relative') {
            console.log('inside if ', this.bloodRelatives);
            this.relationWithInsuredPersonPicklistVal = this.bloodRelatives;
            if (this.relationshipTracker) {
                this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = this.relationshipTracker;//added by sandeep
            }
        } else if (nomineeRelationType == 'Not a Blood Relative') {
            console.log('inside else  ', this.nonBloodRelatives);
            if (this.relationshipTracker) {
                this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = this.relationshipTracker;//added by sandeep
            }
            this.relationWithInsuredPersonPicklistVal = this.nonBloodRelatives;
        }
        console.log('checking handle relation>>', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);


        ///starting of code  added by sandeep kumar
        if (event.target.dataset.field == 'Nominee_Relationship_with_Insured_Person__c') {
            if(this.objinsurance){
            this.objinsurance[0].NomineeRelationshipwithInsuredPerson=event.detail.value;
            }
            var applicantRelationShipStatus = event.detail.value;
            this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = applicantRelationShipStatus;//added by sandeep
        }

        if (event.target.dataset.field == 'Nominee_Relationship_Type__c') {
            if(this.objinsurance){
            this.objinsurance[0].NomineeRelationshipType=event.detail.value;
            }
            this.insuranceDetailRecord.Nominee_Relationship_Type__c = event.detail.value;
        }
        /// ending of code  added by sandeep kumar


        // }
        // console.log('this.relationWithInsuredPersonPicklistVal ', this.relationWithInsuredPersonPicklistVal);
        // if (event.target.dataset.field == 'Beneficiary_Amount__c') {
        //     this.objDisbursalPayee[event.target.dataset.field] = Math.round(this.objDisbursalPayee[event.target.dataset.field] * 100) / 100;
        // }
        console.log('this.insuranceDetailRecord.id inside rendered callback ', this.insuranceDetailRecord, this.insuranceDetailRecord.id);

        //Karan SIngh : 30-09-2022 : CH

        /*console.log(this.template.querySelector("lightning-combobox[data-field=Insured_Person_Date_of_Birth__c]"));
        console.log(typeof this.template.querySelector("lightning-combobox[data-field=Insured_Person_Date_of_Birth__c]").value);
        var insuredDob = this.template.querySelector("lightning-combobox[data-field=Insured_Person_Date_of_Birth__c]").value;
        insuredDob = insuredDob.replace('-', '/');*/
        console.log('insuredDob');
        try {

            if (event.target.dataset.field == 'Insurance_Waiver__c') {

                this.showLoader = true;
                this.showui = false;
                setTimeout(() => {
                    console.log(' timeout ');
                    this.showui = true;
                    this.showLoader = false;
                    this.enableDisableFields();
                }, 500);
            } else {
                this.enableDisableFields();
            }

        } catch (error) {
            console.log('handleInputChange - ' + error);
        }
    }

    enableDisableFields() {
        console.log('checking enable relation>>', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);

        console.log('enableDisableFields showUI ' + this.showui);
        try {

            /*   this.template.querySelectorAll("lightning-input").forEach(element => {
                   console.log('element.label in input text is >>>',element.label);
   
                  if (element.label == 'Nominee KYC Uploaded' && !this.nomineePartOfLoan) {
                      
                       element.required = true;
                       console.log('sam here 3 ', element.required);
                   }else if (element.label == 'Nominee KYC Uploaded' && this.nomineePartOfLoan) {
                        
                        element.required = false;
                        console.log('sandy 3 ', element.required);
                    }else if (element.label == 'Nominee KYC Uploaded') {
                        console.log('kandy 3 ', element.required);
                        element.required = false;
                    }
               });*/

            // let insuredPersonName = this.template.querySelector("lightning-input[data-field=Insured_Person_Name__c]")?.value;
            let nomineeName = this.template.querySelector("lightning-combobox[data-field=Nominee_Name__c]")?.value;
            let insuredPersonName = this.template.querySelector("lightning-combobox[data-field=Insured_Person_Name__c]")?.value;

            if (!nomineeName) {
                nomineeName = this.insuranceDetailRecord.Nominee_Name__c;
            }
            console.log('enableDisableFields 123 ', insuredPersonName, nomineeName);

            if (insuredPersonName && nomineeName) {
                if (insuredPersonName && insuredPersonName != '' && nomineeName && nomineeName != '' && insuredPersonName == nomineeName) {
                    // alert('Insured Person Name and Nominee Name cannot be same');
                    this.showNotification('ERROR', 'Insured Person Name and Nominee Name cannot be same', 'error');
                    this.insuranceDetailRecord.Nominee_Name__c = '';
                    if (this.template.querySelector("lightning-combobox[data-field=Nominee_Name__c]")) {
                        this.template.querySelector("lightning-combobox[data-field=Nominee_Name__c]").value = '';
                    }
                    //this.template.querySelector("lightning-combobox[data-field=Nominee_Name__c]").value = '';
                    //this.template.querySelector("lightning-input[data-field=Insured_Person_Name__c]").value = '';

                }
            }
            console.log('this.template.querySelector("lightning-combobox[data-field=Insurance_Waiver__c]")?.value ', this.template.querySelector("lightning-combobox[data-field=Insurance_Waiver__c]")?.value, this.insuranceDetailRecord.Insurance_Waiver__c);
            console.log('0');
            if (this.insuranceDetailRecord.Insurance_Waiver__c == 'Yes') {
                console.log('1');
                console.log(this.template.querySelector("lightning-combobox[data-field=Insurance_Waiver__c]"));
                this.template.querySelector("lightning-combobox[data-field=Insurance_Waiver__c]").value = 'Yes';
            }
            console.log('2');
            let insuranceWaiver = this.template.querySelector("lightning-combobox[data-field=Insurance_Waiver__c]")?.value;
            console.log('insuranceWaiverinsuranceWaiverinsuranceWaiver  ', insuranceWaiver);
            console.log('this.insuranceDetailRecord.Insurance_Waiver__c  ', this.insuranceDetailRecord.Insurance_Waiver__c);

            if (insuranceWaiver == 'Yes' || this.insuranceDetailRecord.Insurance_Waiver__c == 'Yes') {
                console.log('inside insurance waiver if condition ');
                this.template.querySelectorAll("lightning-input").forEach(element => {
                    if (element.label != 'Insured Person Name') { //Karan SIngh : 28-09-2022 : CH
                        element.required = false;
                        element.disabled = false;
                        element.value = '';
                    } else {
                        //Karan Singh : 28-09-2022 : CH - (NP-17-09-22) - N
                        this.insuranceDetailRecord['Insured_Person_Name__c'] = '';
                    }
                });
                this.template.querySelectorAll("lightning-combobox").forEach(element => {
                    if (element.label != 'Insurance Waiver') {
                        element.required = false;
                        element.disabled = false;
                        element.value = '';
                    }
                });
                this.template.querySelectorAll("lightning-checkbox-group").forEach(element => {
                    element.required = false;
                    element.disabled = false;
                    element.value = '';
                });
                this.disableNomineeType = true;
            }
            else if (insuranceWaiver == 'No') {

                console.log('checking relation>>', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);

                this.disableNomineeType = false;
                console.log('inside insurance waiver else condition ');
                this.template.querySelectorAll("lightning-input").forEach(element => {
                    console.log('element.label in input text is >>>', element.label);

                    if (element.label == 'Nominee KYC ID No' && this.nomineePartOfLoan) {
                        element.required = true;
                        element.disabled = true;
                    } else if (element.label == 'Nominee DOB as per KYC' && this.nomineePartOfLoan) {
                        element.required = true;
                        element.disabled = true;
                    } else if (element.label == 'Nominee KYC Uploaded') {
                        console.log('neeraj here 3 ', element.required);
                        //element.required = true;
                        element.disabled = false;
                    }
                    else if (element.label === 'Insured Person Date of Birth') {
                        element.required = true;
                        element.disabled = true;
                    } else if (element.label != 'Insured Person Name') { //Karan SIngh : 28-09-2022 : CH
                        console.log('checking relation two>>', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);

                        element.required = true;
                        element.disabled = false;
                        console.log('checking relation thtree>>', this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);
                    } 
                    else {
                        //Karan Singh : 28-09-2022 : CH - (NP-17-09-22) - N
                        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Name__c')) {
                            this.insuranceDetailRecord['Insured_Person_Name__c'] = this.obj_parent_appt_wrapper_data.objAppt.Name__c;
                        }
                        //======================================================================
                    }
                });
                this.template.querySelectorAll("lightning-checkbox-group").forEach(element => {
                    element.required = true;
                    element.disabled = false;

                });
                this.template.querySelectorAll("lightning-combobox").forEach(element => {
                    console.log('element.label in combobox is >>>', element.label);
                    if (element.label == 'Nominee Relationship Type' && this.nomineePartOfLoan) {
                        element.required = true;
                        element.disabled = false;
                    } else if (element.label == 'Nominee Relationship with Insured Person' && this.nomineePartOfLoan) {
                        element.required = true;
                        element.disabled = false;
                    } else if (element.label == 'Nominee KYC ID Type' && this.nomineePartOfLoan) {
                        element.required = true;
                        element.disabled = true;
                    } 
                    else if (element.label != 'Insurance Waiver') {
                        element.required = true;
                        element.disabled = false;
                    }
                });
            }
            console.log('this.disableNomineeType ' + this.disableNomineeType);
            // console.log('neeraj here 1', this.currentEditInsuranceDetailId, this.insuranceDetailRecord.id);
            if (this.currentEditInsuranceDetailId && this.currentEditInsuranceDetailId != '') {
                this.template.querySelectorAll("lightning-input").forEach(element => {
                    console.log('neeraj here 2');
                    if (element.label == 'Nominee KYC Uploaded') {
                        console.log('neeraj here 3 ', element.required);
                        // element.required = false;
                    }
                });
            }
            console.log('enableDisableFields end')
        } catch (error) {
            console.log('Enable disbale error ' + error);
        }
    }
    //--------------------------------------------------------------------------c/aC_LWC
    checkExistInsuranceDetailRecords() {

        // this.listExistInsuranceDetails = null;
        this.objInsuranceDetails = null;
        this.isExistInsuranceDetails = false;
        //if we have disbursal id then check if we have any existing Insurance records
        if (this.checkExistingDisbursalId()) {

            getParentAndRelatedData({
                recordId: this.checkExistingDisbursalId(),
                childObjectName: 'Insurance_Details__r',
                parentObjectName: 'Disbursal__c'
            }).then((result) => {

                console.log('Fiv_Disb_Lwc checkExistInsuranceDetailRecords = ', JSON.stringify(result));
               

                if (result.statusCode !== 200) {

                    this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                    this.showLoader = false;
                } else {

                    //if any existing record found
                    if (result.objSobject.hasOwnProperty('Insurance_Details__r')) {

                        var arrInsuranceDetailsIds = [];
                        console.log(result.objSobject.Insurance_Details__r);
                        for (var key in result.objSobject.Insurance_Details__r) {

                            arrInsuranceDetailsIds.push(result.objSobject.Insurance_Details__r[key].Id);
                        }
                        this.isExistInsuranceDetails = true;
                        this.getExistInsuranceDetailRecords(arrInsuranceDetailsIds);
                    } else {

                        //create a new record
                        this.getInsuranceDetails(null);
                    }
                }

            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in Fiv_Disb_Lwc checkExistInsuranceDetailRecords = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });
        } else {
            //if any disbursal record does not exist that means there are no records of insurance
            this.getInsuranceDetails(null);
        }

    }
    //--------------------------------------------------------------------------
    //used to create/ edit single Insurace Detail Record
    //recordIds - Null means new record, Not Null means existing record 
    getInsuranceDetails(recordIds) {
        this.objInsuranceDetails = undefined;
        this.showLoader = true;
        //this.obj_parent_appt_wrapper_data.disbMetaPrefix will define the component will open for disbursal author or maker ex DISBM_Loan_Parameters
        getMetaDataFields({ recordIds: recordIds, metaDetaName: this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'Insurance_Details' }).then((result) => {
            console.log('Fiv_Disb_Lwc objInsuranceDetails = ', result);
            this.objInsuranceDetails = result.data;
            this.showLoader = false;
        }).catch((err) => {
            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc getInsuranceDetails = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }
    //this method will call exisitng records for the data table
    getExistInsuranceDetailRecords(arrInsuranceDetailsIds) {

        //this.listExistInsuranceDetails = [];
        this.showLoader = true;
        //this.obj_parent_appt_wrapper_data.disbMetaPrefix will define the component will open for disbursal author or maker ex DISBM_Loan_Parameters
        getRelatedRecords({ setRecordIds: arrInsuranceDetailsIds, metadataName: this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'Insurance_Details' }).then((result) => {
            console.log('Fiv_Disb_Lwc getInsuranceDetails = ', result);
            // this.listExistInsuranceDetails = result;
            // this.listExistInsuranceDetails = JSON.parse(this.listExistInsuranceDetails.strDataTableData);
            // console.log('listExistInsuranceDetails ', JSON.stringify(this.listExistInsuranceDetails));
            this.showLoader = false;
        }).catch((err) => {
            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc getInsuranceDetails = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }
    //--------------------------------------------------------------------------
    handleFieldChanges(event) {
        console.log('handleFieldChanges= ', event.detail.CurrentFieldAPIName);
        //this.handleFormValueChange(event);
    }
    handleSelectedRecord(event) {
        console.log('event.detail called>>>>>> ', event.detail);
        console.log('Edit called #### ', JSON.stringify(event.detail));
        this.fileData = {};
        this.fileErrMsg = '';
        this.currentEditInsuranceDetailId = event.detail.recordData.Id;
        this.getInsuranceDetails(this.currentEditInsuranceDetailId);

    }
    addRow(isCalledInChange) {
        if((!this.listExistInsuranceDetails && !this.listExistInsuranceDetails.length) || isCalledInChange === true){
            this.insuranceDetailRecord = {};
            this.reInitInsuranceDetail();
            this.insuranceDetailRecord.Nominee_Relationship_Type__c = this.applicationRecords.Nominee_Relationship_Type__c;
            if (this.insuranceDetailRecord.Nominee_Relationship_Type__c === 'Blood Relative') {
                this.relationWithInsuredPersonPicklistVal = this.bloodRelatives;
            }
            else if (this.insuranceDetailRecord.Nominee_Relationship_Type__c === 'Non a Blood Relative') {
                this.relationWithInsuredPersonPicklistVal = this.nonBloodRelatives;
            }
            if (this.applicationRecords.Nominee__c === 'Yes') {
                this.insuranceDetailRecord.Nominee_Type__c = 'Part of Loan';
            }
            else if (this.applicationRecords.Nominee__c === 'No') {
                this.insuranceDetailRecord.Nominee_Type__c = 'Not Part of Loan';
            }
            this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = this.applicationRecords.Nominee_Party_Relationship_with_Insured__c;
            this.currentEditInsuranceDetailId = null;
            this.getInsuranceDetails(null);
            this.fileErrMsg = '';
        }
        else{
            this.showNotification('Error', 'Can not add more than one Record', 'error');
        }
    }
    handleCancel() {
        this.objInsuranceDetails = null;
        this.currentEditInsuranceDetailId = null;
    }
    //--------------------------------------------------------------------------
    onOpenfileUpload(event) {
        this.fileErrMsg = '';
        //console.log(this.obj_parent_appt_wrapper_data.disbMetaPrefix);
        try {

            const file = event.target.files[0];

            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                //console.log('data' + JSON.stringify(reader.result));
                this.fileData = {
                    'filename': this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'NomineeKYCUpload- ' + file.name,
                    'base64': base64,
                }
                console.log('File name - ' + this.fileData.filename);
                //this.uploadedfileName = this.fileData.filename;
            }
            reader.readAsDataURL(file)
        } catch (error) {
            console.log('error -' + error.message);
            this.fileErrMsg = error.message;
            this.fileData = {};
        }

    }
    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
    checkExistingDisbursalId() {

        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Disbursals__r')) {
            console.log('this.obj_parent_appt_wrapper_data.Disbursals__r[0].Id ' + this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id);
            return this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id;
        }
        return null;
    }

    //--------------------------------------------------------------------------
    //02/09/2022 : added By karan to check for the validation if atleast one record is
    @api
    checkBeforeSubmit() {

        var custEvt;
        if (!this.listExistInsuranceDetails || this.listExistInsuranceDetails.length == 0) {
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: false, msg: 'Atleast add one insurance detail record.', fieldName: 'insuranceDetails' }
            });
        } else {
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: true, msg: '', fieldName: 'insuranceDetails' }
            });
        }

        this.dispatchEvent(custEvt);
    }


    validateFields() {
        let isDataValid = true;

        // console.log('nomineeTypeValuenomineeTypeValue ', this.template.querySelector("lightning-checkbox-group").value, this.nomineeTypeValue);

        //let nomineeType = this.template.querySelector("lightning-checkbox-group");

        this.nomineeTypeValue.forEach(function (entry) {
            console.log('value of nominee type ', entry);
        });


        this.template.querySelectorAll("lightning-input").forEach(element => {
            console.log('element Input Name neeraj 123' + element.label + ' Value : ' + element.value);
            if (element.label == 'Insured Person Date of Birth' && element.disabled == false) {
                if (!element.value) {
                    //   this.personDobErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    //   this.personDobErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Nominee Relationship with Insured Person' && element.disabled == false) {
                if (!element.value) {
                    //        this.relWithInsuredPersonErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    //      this.relWithInsuredPersonErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Nominee KYC ID No' && element.disabled == false) {
                if (!element.value) {
                    //   this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    // this.kycIdNoErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Nominee KYC Uploaded' && element.disabled == false && element.required == true) {
                if (!this.fileData.hasOwnProperty('filename')) {
                    // this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    // this.kycIdNoErr = '';
                    // element.style = '';
                }
            }
        });

        this.template.querySelectorAll("lightning-combobox").forEach(element => {
            console.log('element Input Name neeraj 123' + element.label + ' Value : ' + element.value);
            if (element.label == 'Insurance Waiver' && element.disabled == false) {
                if (!element.value) {
                    // this.personDobErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    // this.personDobErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Insured Person Name' && element.disabled == false) {
                if (!element.value) {
                    // this.relWithInsuredPersonErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    // this.relWithInsuredPersonErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Nominee Name' && element.disabled == false) {
                if (!element.value) {
                    //   this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    //   this.kycIdNoErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Nominee Relationship Type' && element.disabled == false) {
                if (!element.value) {
                    // console.log('inside nominee relationship');
                    //  this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    // this.kycIdNoErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Nominee Relationship with Insured Person' && element.disabled == false) {
                if (!element.value) {
                    //   console.log('Nominee Relationship with Insured Person');
                    // this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    //  this.kycIdNoErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Nominee KYC ID Type' && element.disabled == false) {
                if (!element.value) {
                    //  this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    //  this.kycIdNoErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Insurance Requirement' && element.disabled == false) {
                if (!element.value) {
                    // this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    //  this.kycIdNoErr = '';
                    // element.style = '';
                }
            } else if (element.label == 'Insurance Medical Test Result' && element.disabled == false) {
                if (!element.value) {
                    // this.kycIdNoErr = 'Complete this field.';
                    isDataValid = false;
                    return isDataValid;
                } else {
                    //   this.kycIdNoErr = '';
                    // element.style = '';
                }
            }
        });
        console.log('this.nomineeTypeValue value is at check>>', this.nomineeTypeValue);
        /*   if (this.nomineeTypeValue.length <= 0 && nomineeType.disabled == false) {
               isDataValid = false;
           }*/

        return isDataValid;
    }

    handleCheckValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid3 = [
            ...this.template.querySelectorAll('lightning-dual-listbox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid4 = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return (allValid1 && allValid2 && allValid3 && allValid4);
    }

     fillUiWrapper(){
    try{
        if(this.insuranceDetailRecord.Id){
            this.showInsuranceData.Id = this.insuranceDetailRecord.Id;
        }else{
            this.showInsuranceData.Id = '11232';
        }
    	this.showInsuranceData.InsuredPersonName  =  this.insuranceDetailRecord.Insured_Person_Name__c;
        this.showInsuranceData.InsuredPersonDateofBirth   =  this.insuranceDetailRecord.Insured_Person_Date_of_Birth__c;
        this.showInsuranceData.InsuranceWaiver = this.insuranceDetailRecord.Insurance_Waiver__c;
        this.showInsuranceData.NomineeName   = this.insuranceDetailRecord.Nominee_Name__c ;
        this.showInsuranceData.NomineeRelationshipType   = this.insuranceDetailRecord.Nominee_Relationship_Type__c ;
        this.showInsuranceData.NomineeRelationshipwithInsuredPerson   = this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c ;
        this.showInsuranceData.NomineeKYCIDType   = this.insuranceDetailRecord.Nominee_KYC_ID_Type__c ;
        this.showInsuranceData.NomineeKYCIDNo  = this.insuranceDetailRecord.Nominee_KYC_ID_No__c ;
        this.showInsuranceData.NomineeDOB  =  this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c ;
        this.showInsuranceData.InsuranceRequirement  =  this.insuranceDetailRecord.Insurance_Requirement__c ;
        this.showInsuranceData.InsuranceMedicalTestResult  =  this.insuranceDetailRecord.Insurance_Medical_Test_Result__c ;
        this.showInsuranceData.NomineeType =this.insuranceDetailRecord.Nominee_Type__c;
          //  this.objinsurance.push(this.showInsuranceData);

          var arr = [];
          arr.push(this.showInsuranceData);
          this.objinsurance=arr;
         
        console.log('arra at 1349 is >>',arr);
        console.log('arra at  this.objinsurance is >>',this.objinsurancer);
        console.log('inside fillwrapper this.showInsuranceData',this.showInsuranceData);
        
       // this.objinsurance[0] = (this.showInsuranceData);
        console.log('inside fillwrapper',this.objinsurance);



    }catch(e){
        console.log('meessage in filluiwrapper is >>>',e.message);
    }
    }


    handleSave() {

       /*  if(this.yearsDiff<18){
            console.log('inside currentDate');
            this.showNotification('ERROR', 'Nominee dob cannot less than 18 years', 'error');
            return;
        } */
        

        if(this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c){

                var date1 = new Date();
                var date2 = new Date(this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c);
                this.yearsDiff =  Math.abs(date1.getFullYear() - date2.getFullYear());
                
                if(this.yearsDiff<18){
                    this.showNotification('ERROR', 'Nominee dob cannot less than 18 years', 'error');
                    return;
                }
        }

        console.log('handle save call', this.insuranceDetailRecord);
        this.showLoader = true;
        this.disableSaveEditBtn = true;
        // let allValid = this.handleCheckValidity();
        let isDataValid = this.validateFields();

        console.log('isDataValidisDataValid ', isDataValid, typeof isDataValid, this.insuranceDetailRecord.Insurance_Waiver__c);
        //only for new record validation and if insurance waiver is yes
        if (!this.nomineePartOfLoan && !this.fileData.hasOwnProperty('filename') && !this.currentEditInsuranceDetailId && this.insuranceDetailRecord.Insurance_Waiver__c != 'Yes' && (this.currentEditInsuranceDetailId || this.currentEditInsuranceDetailId != '')) {
            console.log('throwing file error ', this.currentEditInsuranceDetailId);
            //that means the file is not uploaded
            this.fileErrMsg = 'Please upload Nominee KYC.';
            this.delayAction(false, false);
            console.log('before handle save call');
            return;
        }


        /*   if (this.nomineeTypeValue.length == 2) {
               console.log('inside check validation method');
               this.nomineeTypeErr = 'Only one checkbox is allowed at one time.';
               this.delayAction(false, false);
               return;
           } else {
               this.nomineeTypeErr = '';
           }*/

        // == true || isDataValid == 'true'
        if (isDataValid || this.insuranceDetailRecord.Insurance_Waiver__c =='Yes') {
            console.log('donebefore handle save call');
            this.showLoader = true;

            // console.log('this.insuranceDetailRecord ', this.objDisbursalPayee.Id, this.insuranceDetailRecord);
            console.log(' this.nomineeTypeValue ' + this.nomineeTypeValue);
            /*  if (this.nomineeTypeValue.includes('Part of Loan')) {
                  this.insuranceDetailRecord.Part_of_Loan__c = true;
              } else {
                  this.insuranceDetailRecord.Part_of_Loan__c = false;
              }
              if (this.nomineeTypeValue.includes('Not part of loan')) {
                  this.insuranceDetailRecord.Not_Part_of_Loan__c = true;
              } else {
                  this.insuranceDetailRecord.Not_Part_of_Loan__c = false;
              }*/
            //=========== calling save method ===================//

            // delete this.insuranceDetailRecord.Nominee_Type__c;

            this.insuranceDetailRecord.Application__c = this.applicationId;
            this.insuranceDetailRecord.Disbursal__c = this.checkExistingDisbursalId();
            console.log('this.insuranceDetailRecord Before' + JSON.stringify(this.insuranceDetailRecord));
            //Added By Karan 03/09/2022
            if (this.insuranceDetailRecord.hasOwnProperty('Application__r')) {
                delete this.insuranceDetailRecord.Application__r;
            }
            console.log('before data before save is >>>', this.insuranceDetailRecord);
            if (this.insuranceDetailRecord.hasOwnProperty('nomineeType')) {
                delete this.insuranceDetailRecord.nomineeType;
            }
            if (this.insuranceDetailRecord.hasOwnProperty('Id')
                && this.insuranceDetailRecord.Id) {
                delete this.insuranceDetailRecord.Application__c;
                delete this.insuranceDetailRecord.Disbursal__c;
            }
            console.log('this.insuranceDetailRecord after' + JSON.stringify(this.insuranceDetailRecord));

            if (this.insuranceDetailRecord.Insurance_Waiver__c == 'Yes') {

                this.insuranceDetailRecord.Insured_Person_Name__c = null;
                this.insuranceDetailRecord.Insured_Person_Date_of_Birth__c = null;
                this.insuranceDetailRecord.Not_Part_of_Loan__c = null;
                this.insuranceDetailRecord.Part_of_Loan__c = null;
                this.insuranceDetailRecord.Nominee_Name__c = null;
                this.insuranceDetailRecord.Nominee_Relationship_Type__c = null;
                this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = null;
                this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = null;
                this.insuranceDetailRecord.Nominee_KYC_ID_No__c = null;
                this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = null;
                this.insuranceDetailRecord.Insurance_Requirement__c = null;
                this.insuranceDetailRecord.Insurance_Medical_Test_Result__c = null;
            }
            this.insuranceDetailRecord.Application__c = this.applicationId;
            console.log('data before save is >>>', this.insuranceDetailRecord);


            //END 03/09/2022
            saveInsuranceDetailData({
                objDisbursal: JSON.stringify(this.insuranceDetailRecord),
                base64: this.fileData.hasOwnProperty('base64') ? this.fileData.base64 : '',
                filename: this.fileData.hasOwnProperty('filename') ? this.fileData.filename : '',
                prntRecordId: ''

            }).then((result) => {

                console.log('Fiv_Disb_Lwc Saved sfObjJSON = ', JSON.stringify(result), result);

                if (result.statusCode !== 200
                    && result.statusCode !== 201) {

                    this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                    this.delayAction(false, false);
                } else {
                     this.getInsuranceDetailsData();
                    this.showNotification('SUCCESS', result.message, 'success');
                    var custEvt = new CustomEvent("reloadapplicationdata", {
                        detail: {}
                    });
                    this.dispatchEvent(custEvt);

                    // below code should display the table only
                    //this.addRow();
                    this.insuranceDetailRecord = {};
                    this.currentEditInsuranceDetailId = null;
                    this.delayAction(false, false);
                    this.doInit();//02/09/2022 : added By karan to fetch the data again
                }

                //this.showLoader = false; //this is removed as loader will be  false once data is load
            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in Fiv_Disb_Lwc handleSave = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.delayAction(false, false);
            });

            //=================================  Saving Method END ===============================
        } else {

            this.showNotification('ERROR', 'Please complete fields', 'error');
            this.delayAction(false, false);
        }

    }
    //this is done so that user cannot hit multiple save button 
    delayAction(showLoader, disableSaveEditBtn) {
        setTimeout(() => {
            //this is done so that user cannot hit multiple save button 
            this.showLoader = showLoader;
            this.disableSaveEditBtn = disableSaveEditBtn;
        }, 500);
    }
    handleEditRecord(event) {
        try {
            this.addRow(true);
            this.nomineeTypeValue = [];
            console.log('index', event.target.dataset.index, JSON.parse(JSON.stringify(this.listExistInsuranceDetails[event.target.dataset.index])));
            if (this.listExistInsuranceDetails[event.target.dataset.index]) {
                console.log('this.trackInsurance 1378',this.trackInsurance);
                console.log('this.insuranceDetailRecord 1376 >>>',JSON.stringify(this.insuranceDetailRecord));
                this.insuranceDetailRecord = JSON.parse(JSON.stringify(this.listExistInsuranceDetails[event.target.dataset.index]));
                //this.enableDisableFields();
                console.log('this.insuranceDetailRecord check data is >>>', this.insuranceDetailRecord);
                this.currentEditInsuranceDetailId = this.insuranceDetailRecord.Id;
                console.log('this.insuranceDetailRecord ', this.insuranceDetailRecord);

                //addedd by sandeep to override insurance data by app fields //
                this.insuranceDetailRecord.Insured_Person_Name__c = this.trackInsurance.Insured_Person_Name__c;
                this.insuranceDetailRecord.Nominee_Name__c = this.trackInsurance.Nominee_Name__c;
                this.insuranceDetailRecord.Nominee_Relationship_Type__c = this.trackInsurance.Nominee_Relationship_Type__c;
                this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c = this.trackInsurance.Nominee_Relationship_with_Insured_Person__c;
                this.insuranceDetailRecord.Nominee_Type__c = this.trackInsurance.Nominee_Type__c;
                this.insuranceDetailRecord.Insured_Person_Date_of_Birth__c = this.trackInsurance.Insured_Person_Date_of_Birth__c;
                this.insuranceDetailRecord.Nominee_KYC_ID_No__c = this.trackInsurance.Nominee_KYC_ID_No__c;
                this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = this.trackInsurance.Nominee_KYC_ID_Type__c;
                this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c= this.trackInsurance.Nominee_DOB_as_per_KYC__c;
                console.log('this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c 1397 >>',this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c);
                console.log('this.trackInsurance.Nominee_DOB_as_per_KYC__c 1397 >>',this.trackInsurance.Nominee_DOB_as_per_KYC__c);

                //addedd by sandeep to override insurance data by app fields //
                if(!this.trackInsurance.Nominee_KYC_ID_No__c){
                    this.trackInsurance.Nominee_KYC_ID_No__c = this.objinsurance[0].NomineeKYCIDNo;
                    this.insuranceDetailRecord.Nominee_KYC_ID_No__c = this.objinsurance[0].NomineeKYCIDNo;
                }
                if(!this.trackInsurance.Nominee_KYC_ID_Type__c){
                     this.trackInsurance.Nominee_KYC_ID_Type__c = this.objinsurance[0].NomineeKYCIDType;
                     this.insuranceDetailRecord.Nominee_KYC_ID_Type__c = this.objinsurance[0].NomineeKYCIDType;
                }
                if(!this.trackInsurance.Nominee_DOB_as_per_KYC__c){
                     this.trackInsurance.Nominee_DOB_as_per_KYC__c = this.objinsurance[0].NomineeDOB;
                     this.insuranceDetailRecord.Nominee_DOB_as_per_KYC__c = this.objinsurance[0].NomineeDOB;
                }
                
                let nomineeRelationType = this.insuranceDetailRecord.Nominee_Relationship_Type__c;
                console.log('the rel nom>>>',this.insuranceDetailRecord.Nominee_Relationship_Type__c);
                console.log('the nomrel nom>>>',this.insuranceDetailRecord.Nominee_Relationship_with_Insured_Person__c);
                if (nomineeRelationType == 'Blood Relative') {
                    console.log('inside if ', this.bloodRelatives);
                    this.relationWithInsuredPersonPicklistVal = this.bloodRelatives;
                } else if (nomineeRelationType == 'Not a Blood Relative') {
                    console.log('inside else  ', this.nonBloodRelatives);
                    this.relationWithInsuredPersonPicklistVal = this.nonBloodRelatives;
                }
                if (this.insuranceDetailRecord.Part_of_Loan__c || this.insuranceDetailRecord.Nominee_Type__c === 'Part of Loan') {
                    this.nomineeTypeValue.push('Part of Loan');
                    this.nomineePartOfLoan = true;
                }
                if (this.insuranceDetailRecord.Not_Part_of_Loan__c || this.insuranceDetailRecord.Nominee_Type__c === 'Not Part of Loan') {
                    this.nomineeTypeValue.push('Not part of loan');
                    this.nomineePartOfLoan = false;
                }
                if (this.insuranceDetailRecord.Insurance_Requirement__c == 'DOGH') {
                    this.medicalTestResultPicklistVal = this.medicalTestResultPicklistFirst;
                } else if (this.insuranceDetailRecord.Insurance_Requirement__c == 'DOGH + MT') {
                    this.medicalTestResultPicklistVal = this.medicalTestResultPicklistSecond;
                }
                this.disableNomineeType = this.insuranceDetailRecord.Insurance_Waiver__c == 'Yes' ? true : false;
                // this.enableDisableFields();
                if(this.insuranceDetailRecord.Insurance_Waiver__c === 'No' && this.insuranceDetailRecord.Nominee_Type__c === 'Part of Loan'){
                    this.enableDisableFields();
                }
                this.showLoader = true;
                setTimeout(() => {
                    console.log(' timeout ');
                    this.showLoader = false;
                    this.enableDisableFields();
                }, 2000);
            }
            // this.enableDisableFields();
        } catch (error) {
            console.log('error Handle edit', error);
        }


    }

    viewDocument(event) {
        console.log('inside view document neeraj ', event.target.dataset.index, this.listExistInsuranceDetails.length, this.listExistInsuranceDetails);
        console.log('inside view document neeraj', this.listExistInsuranceDetails[event.target.dataset.index].Id);
        console.log('this.mapDisbPayeeIdWithDocumentId', this.mapDisbPayeeIdWithDocumentId);
        var disbPayeeId = this.listExistInsuranceDetails[event.target.dataset.index].Id;
        if (this.mapDisbPayeeIdWithDocumentId.has(disbPayeeId)) {

            this.navigateDocument(this.mapDisbPayeeIdWithDocumentId.get(disbPayeeId));
        } else {

            this.showLoader = true;
            getDocumentId({
                parentId: disbPayeeId,
                documentPrefix: this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'NomineeKYCUpload- '
            }).then((result) => {

                console.log('getDocumentId neeraj  = ', JSON.stringify(result));
                if (result.length > 0) {
                    this.navigateDocument(result[0].ContentDocumentId);
                    this.mapDisbPayeeIdWithDocumentId.set(disbPayeeId, result[0].ContentDocumentId);
                }
                else {
                    this.showNotification('', 'No document found.', 'warning');
                }
                this.showLoader = false;

            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in getDocumentId = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });
        }

    }
    navigateDocument(contentDocId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: contentDocId
            }
        })

    }
}