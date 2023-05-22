import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';

import getAllApplicantMeta from '@salesforce/apex/FsLeadDetailsControllerHelper.getAllApplicantMeta';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import BusinessDate from '@salesforce/label/c.Business_Date';
import Mobile_Verification_Mandatory from '@salesforce/label/c.Mobile_Verification_Mandatory';

import { getRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Application__c.Name';
import getPropertyDetailsData from '@salesforce/apex/FsLeadDetailsControllerHelper.getPropertyDetailsData';
import getPropertyOwners from '@salesforce/apex/FetchDataTableRecordsController.getPropertyOwners';
//import getRequiredDocuments from '@salesforce/apex/fsGenericUploadDocumentsController.getRequiredDocuments';
import { createRecord } from 'lightning/uiRecordApi';
import VERIFICATION_OBJECT from '@salesforce/schema/Verification__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import STAGE_FIELD from '@salesforce/schema/Application__c.Stage__c';
import SUB_FLOW_FIELD from '@salesforce/schema/Application__c.Sub_Flow__c';
import IS_MAKER_DONE from '@salesforce/schema/Application__c.Lead_Detail_Maker_Done__c';
import clonePropertyNew from '@salesforce/apex/FsPreloginController.clonePropertyNew';
import checkInsuranceValidation from '@salesforce/apex/fsPcAcController.checkInsuranceValidation';
import updateApptStageFromDA from '@salesforce/apex/Fiv_Disb_LwcController.updateApptStageFromDA';
import mailResponse from '@salesforce/apex/FS_LMS_CreateCustomerAPI.mailResponse';
import FIELD_OFFICER_EMPLOYEE_ID from '@salesforce/schema/Application__c.Field_Officer_Emp_Id__c';

//Added by Sangeeta : 22/11/22 : for repayment and zero fee validation
import getFeeWithoutRepayment from '@salesforce/apex/FeeCreationComponentHelper.getFeeWithoutRepayment';
import getZeroFee from '@salesforce/apex/FeeCreationComponentHelper.getZeroFee';
import getApplicants from '@salesforce/apex/FsLeadDetailsController.getApplicants';
import saveAllRecordsLeadDetails from '@salesforce/apex/FS_SaveAndSubmitController.saveAllRecordsLeadDetails';
import checkBureauVerified from '@salesforce/apex/FsPreloginController.checkBureauVerification';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';
import { loadAllData, populateData, removeData, checkValidationLeadDetails, lead_detail_data_template } from 'c/fsGenericDataSave';

const APPLICATION_FIELDS = [
    'Application__c.Name',
    'Application__c.Stage__c',
    'Application__c.Field_Officer_Emp_Id__c'
];
export default class FsLeadDetails extends NavigationMixin(LightningElement) {
    @api recordId;
    @api preLogin;
    @track processCustomerData;
    @track customerDetails = [];
    @track dedupeDetails;
    @api allLoanApplicant;
    @api isPCRecordAvailable;
    @track recordTypeId;
    @track requiredDocuments;
    @track isSpinnerActive;
    @track isCoApplicant;
    @track isGuarantor;
    @track isMobileVerified;
    @track isBureauVerified;
    @track mobileVerifiedData;
    @track bureauVerifiedData;
    @track propertyAllData;
    @track allApplicantData;
    @track showErrorTab = false;
    @track activeError = 'step-1';
    @track checkEmpDetails = false;
    @track checkBank = false;
    @track checkLoanType = false;
    @track checkPropDetails = false;
    @track isAddApplicant = false;
    @track isAddProperty = false;
    @track initiateRetrigger = false;
    @track isLoanType = true;
    @api primaryApplicantName;
    @track loanApplicantList;
    @track ownerOptions = [];
    @track isMobileVerMandatory = Mobile_Verification_Mandatory;
    @track showPendingReason = false;
    @track childData = {
        'PersonalInformation': '',
        'Education': '',
        'Family': '',
        'EmploymentDetails': '',
        'IncomeDetails': '',
        'BankDetails': '',
        'ReferenceDetails': '',
        'ReceiptDetails': '',
        'LoanType': '',
        'PropertyDetails': '',
        'PropertyBoundaries': '',
        'PropertyMeasurements': '',
    };
    @track rowAction = [
        {
            //label: 'Edit',
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:edit',
                title: 'Edit',
                variant: 'border-filled',
                alternativeText: 'Edit',
                name: 'edit'
            }
        },
        {
            //label: 'Delete',
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:delete',
                title: 'Delete',
                variant: 'border-filled',
                alternativeText: 'Delete',
                name: 'delete'
            }
        },
    ]
    @track btns = [
        // {
        //     name: 'Submit',
        //     label: 'Submit',
        //     variant: 'brand',
        //     class: 'slds-m-left_x-small'

        // },
        {
            name: 'SaveSubmit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small'

        },
        {
            name: 'AddApplicant',
            label: 'Add Applicant',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'AddProperty',
            label: 'Add Property',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'InitiateRetrigger',
            label: 'Initiate Retrigger',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'pendingReason',
            label: 'Pending Reason',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ]
    @track applicationName;
    @track todaysDate = BusinessDate;
    @track lastLoginDate;
    @track callOnce = false;
    @track pcRecordTypeId;
    //checkValidity
    @track personalInfo = [];
    @track errorMsgs = [];
    @track recordTypeId;
    @track propDetailData;
    @track propAddressData;
    @track propOwnershipData;
    @track propIdList = [];
    @track stage;
    @track fieldOfficerEmpId;

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.stringify(data));
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Lead Detail');
        } else if (error) {

        }
    }

    @wire(getObjectInfo, { objectApiName: VERIFICATION_OBJECT })
    getPcRecordData({ data, error }) {
        if (data) {
            var recordTypeData = data.recordTypeInfos;
            this.pcRecordTypeId = Object.keys(recordTypeData).find(rti => recordTypeData[rti].name === 'PC');
        }
    }
    connectedCallback() {
        loadAllData();
        this.isSpinnerActive = true;
        console.log('preLogin ### ', this.preLogin);
        this.getAllApplicants();
        //this.getRequiredDocuments();
        this.handleGetLastLoginDate();
        //this.getAllApplicantMeta();
    }

    renderedCallback() {
        console.log('renderedCallback called')
        if (!this.callOnce) {
            let currentTab = this.activeError;
            let tabs = this.template.querySelectorAll('lightning-tab');
            console.log('entry 1');
            if (tabs && tabs.length) {
                console.log('entry 2= ', tabs);
                tabs.forEach(element => {
                    element.loadContent();
                    if (element.label == 'Loan Details') {
                        let childTabs = element.querySelectorAll('lightning-tab');
                        console.log('entry 3= ', childTabs);
                        if (childTabs && childTabs.length) {
                            childTabs.forEach(currentItem => {
                                currentItem.loadContent();
                                this.isSpinnerActive = false;
                            });
                            this.callOnce = true;
                        }
                    }
                });
            }
            this.activeError = currentTab;
            this.isSpinnerActive = false;

        }
    }

    getAllApplicants() {
        getApplicants({ applicationId: this.recordId }).then((result) => {
            console.log('getAllApplicants = ', result);
            if (result && result.length) {
                this.allLoanApplicant = [];
                result.forEach(currentItem => {
                    this.allLoanApplicant.push(currentItem.Id);
                });
                this.getAllApplicantMeta();
            }
        }).catch((err) => {
            console.log('Error in getAllApplicants = ', err);
        });
    }

    getAllApplicantMeta() {
        console.log('called metadata ', JSON.stringify(this.allLoanApplicant));
        this.allApplicantData = undefined;
        getAllApplicantMeta({ allLoanApplicant: this.allLoanApplicant })
            .then(result => {
                this.allApplicantData = result;
                let loanAppList = [];
                let ownerOps = [];
                console.log('allApplicantData #### ', JSON.stringify(this.allApplicantData));
                if (this.allApplicantData.strDataTableData) {
                    JSON.parse(this.allApplicantData.strDataTableData).forEach(curr => {
                        loanAppList.push({ label: curr.Applicant_Name__c, value: curr.Id });
                        ownerOps.push({ label: curr.Applicant_Name__c, value: curr.Id + '_' + curr.Customer_Type__c });
                    })
                }
                this.loanApplicantList = loanAppList;
                this.ownerOptions = ownerOps;
                console.log(' this.loanApplicantListttt ', this.loanApplicantList);
                console.log(' this.ownerOptionsssss ', this.ownerOptions);
                console.log('loanApplicant List #=>', this.loanApplicantList);
            })
            .catch(error => {
                console.log(error);
            })
    }

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            this.lastLoginDate = result;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    @wire(getRecord, { recordId: '$recordId', fields: APPLICATION_FIELDS })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;
            this.stage = data.fields.Stage__c.value;
            // this.fieldOfficerEmpId = data.fields.Field_Officer_Emp_Id__c.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    getdedupedetails(event) {
        let result = event.detail;
        this.dedupeDetails = JSON.parse(result);
        console.log('Dedupe Details', this.dedupeDetails);
        //if(this.dedupeDetails.errorFlag)
        //this.errorMsg.push(this.dedupeDetails.message);
    }






    updateStageAfterCustomerCreation() {

        this.showErrorTab = false;

        var fields = { 'Application__c': this.recordId, 'RecordTypeId': this.pcRecordTypeId };//'this.recordTypeId 
        var objRecordInput = { 'apiName': 'Verification__c', fields };
        if (!this.isPCRecordAvailable) {
            createRecord(objRecordInput)
                .then(response => {
                    console.log('Verification created with Id: ' + response.id);
                    this.handleStageNavigation();
                }).catch(error => {
                    this.isSpinnerActive = false;
                    console.log('Verification ' + JSON.stringify(error));
                });
            // this.isSpinnerActive=false;
        } else {
            this.handleStageNavigation();
            // this.isSpinnerActive=false;
        }
        ///this.callLmsApiClass();
    }

    handleStageNavigation() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;

        console.log('Save and submit records>>> in lead detail partial save ', JSON.stringify(lead_detail_data_template))
        saveAllRecordsLeadDetails({ jsonStr: JSON.stringify(lead_detail_data_template) }).then((result) => {
            console.log('saveAllRecordsLeadDetails= ', result);
            if (result == 'success') {
                fields[ID_FIELD.fieldApiName] = this.recordId;                
                fields[SUB_FLOW_FIELD.fieldApiName] = 'Lead Detail Maker';  
                fields[IS_MAKER_DONE.fieldApiName] = true;  
                
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.showToastMessage('Success', 'Lead Detail Completed Successfully.', 'Success');
                    window.location.replace('/' + this.recordId);
                    this.isSpinnerActive = false;
                }).catch(error => {
                    console.log(error);
                    this.isSpinnerActive = false;
                });
            }
        }).catch((err) => {
            console.log('Error in saveAllRecordsLeadDetails= ', err);
        });

        // fields[SUB_FLOW_FIELD.fieldApiName] = 'Lead Detail Maker';  
        // fields[IS_MAKER_DONE.fieldApiName] = true;              
        // const recordInput = { fields };
        // updateRecord(recordInput).then(() => {
        //     this.showToastMessage('Success', 'Lead Detail Completed Successfully.', 'Success');
        //     window.location.replace('/' + this.recordId);
        //     this.isSpinnerActive = false;
        // }).catch(error => {
        //     console.log(error);
        //     this.isSpinnerActive = false;
        // });
    }


    async handleSaveSubmit() {
        console.log('handleSaveSubmit');
        this.errorMsgs = [];
        let validations = checkValidationLeadDetails();
        console.log('validations = ', validations);
        this.errorMsgs = validations;
        await checkBureauVerified({ appId: this.recordId }).then(result => {
            console.log('checkBureauVerified= !!', result);
            if (result && result.length) {
                console.log('Push Message Displayed!!');
                result.forEach(applicantName => {
                    this.errorMsgs.push('Bureau Verfication Pending For ' + applicantName + '!!');
                });
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Bureau Verification failed ', error);
        })

        await getPendingReasonValidation({applicationId: this.recordId, stage: 'Lead Detail Maker' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsgs.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })
        this.handleSubmit();
    }

    handleSubmit() {
        this.dedupeDetails = undefined;
        console.log('dhello dedupe 272');

        let dedupeResult = this.template.querySelector('c-fsdedupe-details-lwc').submitDedupeData();
        console.log('dedupe result in handle subm,it >>>', dedupeResult);
        this.template.querySelector('c-fs-generic-upload-documents').checkAllRequiredDocument();
    }


    handleTabValueChange(event) {
        console.log('partaiall save  eventtt ', event.detail)
        var data = event.detail;
        let fValue = data.fieldvalue;

        if ((data.fieldapiname == 'Dob__c' || data.fieldapiname == 'Account_Opening_Date__c' || data.fieldapiname == 'Issue_Date__c' || data.fieldapiname == 'Expiry_Date__c') && fValue && fValue.trim()) {
            fValue = fValue.substr(0, 10);
        } else if ((data.fieldapiname == 'Dob__c' || data.fieldapiname == 'Account_Opening_Date__c' || data.fieldapiname == 'Issue_Date__c' || data.fieldapiname == 'Expiry_Date__c') && (!fValue || !fValue.trim())) {
            fValue = null;
        }

        if (fValue && fValue === ' ') {
            fValue = fValue.trim();
        }

        populateData('Lead Detail', data.tabname, data.subtabname, data.fieldapiname, fValue, 'Id', data.recordId);
        console.log('populate dataaa', lead_detail_data_template);
    }
    handleTabValueRemove(event) {
        console.log('partaiall removee  eventtt ', event.detail)
        var data = event.detail;
        removeData('Lead Detail', data.tabname, data.subtabname);
        console.log('removee111 dataaa', lead_detail_data_template);
    }


    finalSubmit() {
        this.isSpinnerActive = true;
        var insurancePendingCalculation = false;
        try {
            console.log('dhello dedupe 270');
            this.template.querySelector('c-fs-lead-details-personal-information').getPersonalInformationData(false, true);
            this.template.querySelector('c-fs-lead-details-employment-details').getEmploymentDetailsAllData(false);
            this.template.querySelector('c-fs-lead-details-property-details').getPropertyVal();
            this.template.querySelector('c-fs-lead-details-property-address').refreshAddNewProperty(false);
            this.template.querySelector('c-fs-lead-details-ownership-details').refreshAddNewProperty(false);
            this.template.querySelector('c-fs-lead-details-loan-type').getLoanTypeData();
            console.log('dhello dedupe 271');
            //  this.dedupeDetails = undefined;
            console.log('dhello dedupe 272');
            //  let dedupeResult = this.template.querySelector('c-fsdedupe-details-lwc');
            //console.log('dhello dedupe 274');
            //if (dedupeResult)
            //  dedupeResult.submitDedupeData();
            console.log('dhello dedupe 276');
            console.log('Property Detail Data 11111###', JSON.parse(JSON.stringify(this.propDetailData)));
            console.log('Property Address Data 11111###', JSON.parse(JSON.stringify(this.propAddressData)));
            console.log('Ownership Deails Data 11111###', JSON.parse(JSON.stringify(this.propOwnershipData)));

            //console.log('dedupeResult ###', dedupeResult);
            console.log('loan type data ', this.isLoanType);
            setTimeout(() => {
                //To get if Insurance detail API not called after record save in Fee Insurance Details
                //Author : Sangeeta Yadav
                //Date : 01 Nov 2022
                checkInsuranceValidation({ applicationId: this.recordId })
                    .then(res => {
                        console.log('Result Of Insurance Validation ###', res);
                        if (res) {
                            // this.errorMsgs.push('Please Invoke Insurance Api First');
                            insurancePendingCalculation = true;
                            console.log('Result Of Insurance Validation ###', insurancePendingCalculation);
                        }
                    })
                    .catch(err => {
                        console.log('Error %%%', err);
                    })
            }, 300);
        } catch (error) {
            console.log(error);
            this.isSpinnerActive = false;
        }
        setTimeout(() => {
            console.log('this.dedupeDetails', this.dedupeDetails);
            console.log('this.personalInfo.length ', this.personalInfo.length);
            console.log('this.checkEmpDetails ', this.checkEmpDetails);
            console.log('this.checkPropDetails ', this.checkPropDetails);
            console.log('!this.isLoanType ', this.isLoanType);
            console.log('!this.isCoApplicant ', this.isCoApplicant);
            console.log('!this.isGuarantor ', this.isGuarantor);
            console.log('this.isMobileVerified', this.isMobileVerified);
            console.log('this.isBureauVerified', this.isBureauVerified);

            if ((this.errorMsgs.length == 0) && (!(this.dedupeDetails.errorFlag)) && this.personalInfo.length == 0 && this.checkEmpDetails && this.checkPropDetails && this.isLoanType && ((this.isCoApplicant || this.isGuarantor)) && insurancePendingCalculation === false) {
                console.log('inside if 468', this.errorMsgs.length);
                if (this.errorMsgs.length == 0) {
                    console.log('length of error msg is  451 is >>>', this.errorMsgs.length);
                    this.isSpinnerActive = true;
                    this.updateStageAfterCustomerCreation();
                    // this.callCreateCustomerAPi();
                }
            }
            else {
                this.isSpinnerActive = false;
                console.log('test @@@@ ', typeof this.checkPropDetails);
                console.log('dedupe is >>', this.dedupeDetails);
                if (this.dedupeDetails) {
                    if (this.dedupeDetails.errorFlag)
                        this.errorMsgs.push(this.dedupeDetails.message);

                    console.log('dedupe message is >>', this.dedupeDetails.message);
                }
                let propError = false;
                let propAddressError = false;
                let propOwnerError = false;

                if (this.propDetailData) {
                    JSON.parse(this.propDetailData.strDataTableData).forEach(pObj => {
                        console.log('propDetailData of prop ', pObj);
                        if (pObj.Property_Identified__c == ' ' || pObj.Property_Purchased_Type__c == ' ' || pObj.Title_Deed_Type__c == ' '
                            || pObj.Title_Deed_Number__c == ' ' || pObj.Title_Deed_Date__c == ' ' || pObj.Land_Area_Sq_Ft__c == ' '
                            || pObj.Building_Area_Sq_Ft__c == ' ' || pObj.Age_Of_Property__c == ' ' || pObj.Property_Purpose__c == ' '
                            || pObj.Nature_Of_Property__c == ' ') {
                            propError = true;
                        }
                    });
                }

                if (this.propAddressData) {
                    JSON.parse(this.propAddressData.strDataTableData).forEach(pObj => {
                        console.log('propAddressData of prop ', pObj);
                        if (pObj.Address_Type__c == ' ' || pObj.Flat_Plot_Number__c == ' ' || pObj.Address_Line_2__c == ' ' || pObj.Address_Line_3__c == ' '
                            || pObj.Village__c == ' ' || pObj.Survey_Number__c == ' ' || pObj.MS_Pincode__c == ' ') {
                            propAddressError = true;
                        }
                    });
                }

                if (this.propOwnershipData) {
                    JSON.parse(this.propOwnershipData.strDataTableData).forEach(pObj => {
                        console.log('propOwnershipData of prop ', pObj);
                        if (pObj.Ownership_Status__c == ' ' || pObj.Percent_Share__c == ' ' || pObj.Ownership_Date__c == ' ') {
                            propOwnerError = true;
                        }
                    });
                }
                console.log('this.propDetailData>>. ', this.propDetailData)
                if (propError)
                    this.errorMsgs.push('Please Complete Entry in Property Details SubSection in Loan Details Section');

                if (propAddressError)
                    this.errorMsgs.push('Please Complete Entry in Property Address SubSection in Loan Details Section');

                if (propOwnerError)
                    this.errorMsgs.push('Please Complete Entry in Ownership Details SubSection in Loan Details Section');

                console.log('this.fieldOfficerEmpId>>!@#123>> ', this.fieldOfficerEmpId)
                if (!this.fieldOfficerEmpId) {
                    this.errorMsgs.push('Please Complete Entry in Application Details SubSection in Sourcing Details Section');
                }
                /* //To get if Insurance detail API not called after record save in Fee Insurance Details
                //Author : Sangeeta Yadav
                //Date : 01 Nov 2022
                checkInsuranceValidation({ applicationId: this.recordId })
                    .then(res => {
                        console.log('Result Of Insurance Validation ###', res);
                        if (res){
                            this.errorMsgs.push('Please Invoke Insurance Api First');
                   
                        }
                    })
                    .catch(err => {
                        console.log('Error %%%', err);
                    })*/
                if (insurancePendingCalculation == true)
                    this.errorMsgs.push('Please Invoke Insurance Api First');

                this.getFeeWithoutRepayment();
                this.getZeroFee();

                if (!this.isCoApplicant && !this.isGuarantor) {
                    this.errorMsgs.push('Atleast one Co-Applicant or Guarantor will be mandatory On Personal  Information Tab.')
                }
                console.log('this.isMobileVerified=', this.isMobileVerified);
                if (!this.isMobileVerified) {
                    console.log('this.isMobileVerified1111', this.isMobileVerified);
                    //this.errorMsgs.push('Verify Mobile of ' + this.mobileVerifiedData.join() + ' on Personal Information Tab');
                    this.errorMsgs.push('Verify Mobile Of Atleast One Applicant In Personal Information Tab');
                }
                if (this.personalInfo.length > 0) {
                    this.errorMsgs.push('Fill Required Fields Of ' + this.personalInfo.join() + ' By Editing Them In Applicant Information Tab')
                }
                if (!this.checkEmpDetails) {
                    this.errorMsgs.push('Create Atleast A Record On Employment Detail Tab.')
                }

                // if (this.isLoanType === false) {
                //     this.errorMsgs.push('Fill Required Fields On Loan Type Tab.')
                // }
                if (this.checkPropDetails === false) {
                    this.errorMsgs.push('Fill Required Fields On Property Details Tab')
                }
                if (this.errorMsgs.length) {
                    this.showErrorTab = true;
                    let ref = this;
                    setTimeout(() => {
                        ref.activeError = 'Error';
                    }, 300);
                } else {
                    this.updateStageAfterCustomerCreation();
                }
            }
        }, 1000);
    }

    //child handler

    checkPersonalInfo(event) {
        var details = event.detail
        console.log('details #### applicant ### ', JSON.stringify(details));
        this.personalInfo = details.IsAllRecordEdit;
        this.isCoApplicant = details.IsCoApplicant;
        this.isGuarantor = details.IsGuarantor;
        this.isMobileVerified = this.isMobileVerMandatory.toUpperCase() === 'NO' ? true : details.IsMobileVerified;
        this.isBureauVerified = details.isBureauVerified;
        this.mobileVerifiedData = details.mobileVerifiedData;
        this.bureauVerifiedData = details.bureauVerifiedData;
        console.log('this.isMobileVerified###', this.isMobileVerified);
        console.log('child ####  ', JSON.stringify(event.detail));
    }

    checkEmpTabDetails(event) {
        this.checkEmpDetails = event.detail;
        console.log('chils ', this.checkEmpDetails);
    }

    checkBankTab(event) {
        this.checkBank = event.detail;
    }

    checkLoanTypeTab(event) {
    }
    checkloantypeinfo(event) {

        this.isLoanType = event.detail
        console.log('this.isLoanType ####', this.isLoanType);
    }

    handlePropertyData(event) {
        let wrapObj = event.detail;
        console.log('event detaillllsss 333 ', event.detail)
        if (wrapObj.from == 'Property_Details')
            this.propDetailData = wrapObj.data;
        if (wrapObj.from == 'Property_Address')
            this.propAddressData = wrapObj.data;
        if (wrapObj.from == 'Property_Ownership')
            this.propOwnershipData = wrapObj.data;
        if (wrapObj.from == 'Sourcing_Details')
            this.fieldOfficerEmpId = wrapObj.data;

        console.log('fieldOfficerEmpId Data ###', this.fieldOfficerEmpId);
    }

    checkpropertyvalidation(event) {
        this.checkPropDetails = event.detail;
        console.log('this.checkPropDetails ### ', this.checkPropDetails);
    }
    // Check Validity Method

    getPropertyDetailsData() {
        try {
            getPropertyDetailsData({ applicationId: this.applicantId })
                .then(result => {
                    this.checkLoanType = false;
                    var temp = JSON.parse(result.strDataTableData);
                    console.log('result #### ', temp);
                    if (temp.length == 0)
                        this.checkPropDetails = false;
                    else
                        this.checkPropDetails = true;
                })
                .catch(error => {

                })
        } catch (error) { console.log(error) }
    }

    handleActive(event) {
        console.log('active tab value is >>>>', event.target.value);

        this.activeError = event.target.value;
        setTimeout(() => {
            if (this.activeError == 'Property Details') {
                this.template.querySelector('c-fs-lead-details-property-details').refreshAddNewProperty();
            }
            if (this.activeError == 'Property Boundaries') {
                this.template.querySelector('c-fs-lead-details-property-boundaries').refreshAddNewProperty();
            }
            if (this.activeError == 'Property Measurement') {
                this.template.querySelector('c-fs-lead-details-property-measurement').refreshAddNewProperty();
            }
            if (this.activeError == 'Property Address') {
                this.template.querySelector('c-fs-lead-details-property-address').refreshAddNewProperty();
            }

            if (this.activeError == 'Ownership Details') {
                this.template.querySelector('c-fs-lead-details-ownership-details').refreshAddNewProperty();
            }

        }, 1000)

        if (this.activeError == 'Receipt Details') {
            setTimeout(() => {
                if (this.template.querySelector('c-fee-creation-parent')) {
                    this.template.querySelector('c-fee-creation-parent').showFee();
                }
            }, 1000);
        }

        if (this.activeError == 'Dedupe') {
            setTimeout(() => {
                if (this.template.querySelector('c-fsdedupe-details-lwc')) {
                    this.template.querySelector('c-fsdedupe-details-lwc').getCurrentAppsLoanApp();
                }
            }, 1000);
        }
        /*if (this.activeError == 'Receipt Details') {
            setTimeout(() => {
                if (this.template.querySelector('c-fee-creation-parent')) {
                    this.template.querySelector('c-fee-creation-parent').showFee();
                }
            }, 1000);
        }*/
    }


    rowselectionevent(event) {
        var detail = event.detail;
        console.log('detail ### ', JSON.stringify(detail));
        if (detail === 'AddApplicant') {
            this.isAddApplicant = true;
            //this.allLoanApplicant.push();
        } else if(detail === 'pendingReason'){
            this.showHidePendingReasonGrid();
        }
        else if (detail === 'AddProperty') {
            //this.getAllOwners();
            this.getAllApplicantMeta();
            this.isAddProperty = true;
            //this.propertytobeCheck = true;
            let ref = this.template.querySelector('c-fs-add-new-property');
            console.log('property child called', ref);
            setTimeout(() => {
                if (this.template.querySelector('c-fs-add-new-property')) {
                    console.log('loanaPPlist ', this.loanApplicantList);
                    console.log('application Id', this.applicationId);
                    this.template.querySelector('c-fs-add-new-property').getApplicationId(this.recordId);
                    this.template.querySelector('c-fs-add-new-property').getLoanAppList(this.loanApplicantList);
                    this.template.querySelector('c-fs-add-new-property').getPropertyOwnersName(this.recordId);
                    this.template.querySelector('c-fs-add-new-property').getPropertyOwnersList(this.ownerOptions);
                }
            }, 300);
        }
        else if (detail === 'InitiateRetrigger') {
            this.initiateRetrigger = true;
        }
        else if (detail === 'Submit') {
            this.handleSubmit();
        }
        else if (detail === 'Cancel') {

        }
        else if (detail === 'SaveSubmit') {
            this.handleSaveSubmit();
        }
    }

    showHidePendingReasonGrid(){
        this.showPendingReason = (!this.showPendingReason);
    }

    addapplicantclose() {
        this.isAddApplicant = false;
    }
    getapplicantid(event) {
        try {
            this.isAddApplicant = false;
            var tempApplicant = this.allLoanApplicant;
            this.allLoanApplicant = undefined;
            try {
                tempApplicant = [...tempApplicant, event.detail];
                this.allLoanApplicant = tempApplicant;
                this.getAllApplicantMeta();
                this.tableData = undefined;
                setTimeout(() => {
                    console.log("Delayed for 1 second.");
                    this.template.querySelector('c-fs-lead-details-personal-information').getPersonalInformationData(true, false);
                }, "1000")
            } catch (error) {
                console.log(error);
            }
        } catch (error) {
            console.log(error);
        }

    }
    getAllOwners() {
        console.log('get property owners called!!', this.allLoanApplicant);
        getPropertyOwners({ applicantId: this.allLoanApplicant })
            .then(result => {
                console.log('datatable result ', result);
                this.propertyAllData = result;
                this.isAddProperty = true;
            })
            .catch(error => {
                console.log('error in getpropownersdata ', error);
            })
    }
    addpropertyclose() {
        this.isAddProperty = false;

    }

    handlenewlyaddedProperty(event) {
        console.log('newly created property', event.detail);
        if (event.detail != undefined)
            this.propIdList = event.detail;

        this.handlecloneNewPropety();
    }

    // cloning newly Added Property
    handlecloneNewPropety() {
        this.isSpinnerActive = true;
        console.log('recorsddsiiidd cloneeee ', this.recordId);
        clonePropertyNew({ appId: this.recordId })
            .then(result => {
                console.log('result in clone property ', result);
                this.template.querySelector('c-fs-lead-details-property-details').refreshAddNewProperty();
                this.template.querySelector('c-fs-lead-details-property-boundaries').refreshAddNewProperty();
                this.template.querySelector('c-fs-lead-details-property-address').refreshAddNewProperty();
                this.template.querySelector('c-fs-lead-details-property-measurement').refreshAddNewProperty();
                this.template.querySelector('c-fs-lead-details-ownership-details').refreshAddNewProperty();

                this.isSpinnerActive = false;
            })
            .catch(error => {
                this.isSpinnerActive = false;
                console.log('error in clone property ', error);
            });
    }
    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        this.requiredDocumentValidation();
    }
    requiredDocumentValidation() {
        console.log('requiredDocuments ', JSON.stringify(this.requiredDocuments));
        if (this.requiredDocuments.length > 0) {
            this.requiredDocuments.forEach(element => {
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.errorMsgs.push('Upload Application Document ' + element.documentName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Applicant') {
                    this.errorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.customerName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Asset') {
                    this.errorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.propertyName + ' In Document Upload Tab');
                }
                //this.errorMsgs.push('Upload Required Document ' + element + ' In Document Upload Tab');
            });
        }
        this.finalSubmit();
    }

    getpropertydata() {
        this.isAddProperty = false;
        if (this.activeError == 'Property Details') {
            this.template.querySelector('c-fs-lead-details-property-details').refreshAddNewProperty();
        }
        if (this.activeError == 'Property Boundaries') {
            this.template.querySelector('c-fs-lead-details-property-boundaries').refreshAddNewProperty();
        }
        if (this.activeError == 'Property Measurement') {
            this.template.querySelector('c-fs-lead-details-property-measurement').refreshAddNewProperty();
        }
        if (this.activeError == 'Property Address') {
            this.template.querySelector('c-fs-lead-details-property-address').refreshAddNewProperty();
        }
        if (this.activeError == 'Ownership Details') {
            this.template.querySelector('c-fs-lead-details-ownership-details').refreshAddNewProperty();
        }
    }
    handleRetriggerClose() {
        this.initiateRetrigger = false;
    }

    getFeeWithoutRepayment() {
        console.log('in getFeeWithoutRepayment');

        console.log('pendingFeeAndReceiptForDA Stage - this.stageName in pending receipt ' + this.recordId);
        getFeeWithoutRepayment({ recordId: this.recordId })
            .then(result => {
                console.log('::: fee ::: ', result);

                if (result) {
                    console.log('inside repayment value', result);

                    this.errorMsgs.push('Please Select Repayment Type in Fee Details section of Fee details tab');
                }

            })
            .catch(error => {
                // this.showNotification('Error', error.body.message, 'error');
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })

    }

    //Sangeeta Yadav : Added on : 22/11/22 : fee amount not null
    getZeroFee() {
        console.log('in getZeroFee');

        console.log('getZeroFee Stage - this.stageName in pending receipt ' + this.recordId);
        getZeroFee({ recordId: this.recordId })
            .then(result => {
                console.log('::: getZeroFee ::: ', result);

                if (result) {
                    console.log('inside getZeroFee', result);

                    this.errorMsgs.push('Total Fee can not be 0 in Fee Details section of Fee details tab');
                }

            })
            .catch(error => {
                // this.showNotification('Error', error.body.message, 'error');
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })

    }
}