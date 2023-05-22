import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Application__c.Name';
import TOTAL_AMOUNT_RECOMMENDAD from '@salesforce/schema/Application__c.Total_amount_recommended__c';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import getExistingMODRegistraton from '@salesforce/apex/FS_MODRegistrationController.getExistingMODRegistraton';
// import getRequiredDocuments from '@salesforce/apex/fsGenericUploadDocumentsController.getRequiredDocuments';
import getLoanApplicantRecords from '@salesforce/apex/FS_MODRegistrationController.getLoanApplicantRecords';
import BusinessDate from '@salesforce/label/c.Business_Date';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import updateStage from '@salesforce/apex/FS_MODRegistrationController.updateStage';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';
import APPLICATION_ID from '@salesforce/schema/Application__c.Id';
import SOURCING_OFFICER from '@salesforce/schema/Application__c.Sourcing_Officer__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
export default class ModRegisterationLWC extends NavigationMixin(LightningElement) {
    @api recordId;

    @track lastLoginDate;
    @track todaysDate = BusinessDate;
    @track applicationName;
    @track totalRecommendadAmount;

    @track customerMap;
    @track customerList1;
    @track customerList2;

    @track erpDate;
    @track oneYearBackDate;
    @track oneMonthLaterDate;

    @track tabName = 'DocUpload';
    @track errorMsgs;
    @track showSpinner = false;
    @track showErrorTab = false;
    @track secondRequired = true;
    @track recordTypeName;
    @track fieldOfficer;

    @track button = [
        {
            name: 'Submit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'pendingReason',
            label: 'Pending Reason',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ];

    @track showPendingReason = false;
    @track modId;
    @track trial = 1;

    @track modObj = {
        MOD_Done__c: undefined,
        MOD_Commitment_Date__c: undefined,
        MOD_Date__c: undefined,
        MOD_Amount__c: undefined,
        Sourcing_Officer__c: undefined,
        Sourcing_BM__c: undefined,
        Customer_for_Collection_A__c: undefined,
        Mobile_Number_of_A__c: undefined,
        Customer_for_Collection_B__c: undefined,
        Mobile_Number_of_B__c: undefined
    };


    @track validationObj = {
        dataEntry: false,
        fileUpload: true
    };

    get isMODDone() {
        return this.modObj.MOD_Done__c == 'Yes' ? true : false;
    }

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.parse(JSON.stringify(data)));
            const rtis = data.recordTypeInfos;
            this.recordTypeName = Object.keys(rtis).find(rti => rtis[rti].name === 'AC Property Detail');
            console.log('recordTypeName = ', this.recordTypeName)
        } else if (error) {

        }
    }


    @wire(getRecord, { recordId: '$recordId', fields: [NAME, TOTAL_AMOUNT_RECOMMENDAD, SOURCING_OFFICER] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;
            this.totalRecommendadAmount = data.fields.Total_amount_recommended__c.value;
            this.fieldOfficer = data.fields.Sourcing_Officer__c.value;
            let cmp = this.template.querySelector('c-l-w-c-lookup');
            if(cmp){
                cmp.getPreSelectedRecord(this.fieldOfficer);
            }
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    // This Method Is Used To Get All Data At Initial Level(Loading)
    connectedCallback() {
        let businessDateStr = this.todaysDate.substr(6, 4) + '-' + this.todaysDate.substr(3, 2) + '-' + this.todaysDate.substr(0, 2)
        console.log('businessDateStr=', businessDateStr)
        this.erpDate = new Date(businessDateStr).toISOString().substr(0, 10);
        const d = new Date(businessDateStr);
        d.setFullYear(d.getFullYear() - 1);
        this.oneYearBackDate = d.toISOString().substr(0, 10);

        const d2 = new Date(businessDateStr);
        d2.setMonth(d2.getMonth() + 1);
        this.oneMonthLaterDate = d2.toISOString().substr(0, 10);

        console.log('erpDate= ', this.erpDate, 'oneYearBackDate= ', this.oneYearBackDate, 'oneMonthLaterDate= ', this.oneMonthLaterDate);

        this.handleGetExistingRecord();
        // this.handleGetRequiredDocuments();
        this.handleGetLastLoginDate();
        this.handleGetApplicantRecords();
    }

    handleSelectedEMPId(event){
        console.log('fieldOfficerEMPId ',event);
         if (event.detail.length > 0) {
            this.fieldOfficer = event.detail[0].id;
        } else {
            this.fieldOfficer = undefined;
        }
        console.log('handleSelectedEMPId= ',this.fieldOfficer);
    }

    // This Method Is Used To Handle Tab Activation Event
    handleActive(event) {
        this.tabName = event.target.value;
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }

    handleFormValues(event) {
        if (event.target.fieldName == 'MOD_Done__c') {
            this.modObj.MOD_Done__c = event.target.value;
        } else if (event.target.name == 'MOD_Amount__c') {
            if (event.target.value) {
                this.modObj.MOD_Amount__c = parseInt(event.target.value);
            } else {
                this.modObj.MOD_Amount__c = event.target.value;
            }
        } else if (event.target.name == 'Customer_for_Collection_A__c') {
            this.modObj.Customer_for_Collection_A__c = event.target.value;
            let customerObj = JSON.parse(JSON.stringify(this.customerMap[event.target.value]))
            console.log('customerObj= ', customerObj);
            this.modObj.Mobile_Number_of_A__c = customerObj.Mobile__c;
            this.makeSecondList();
        } else if (event.target.name == 'Mobile_Number_of_A__c') {
            this.modObj.Mobile_Number_of_A__c = event.target.value;
        } else if (event.target.name == 'Customer_for_Collection_B__c') {
            this.modObj.Customer_for_Collection_B__c = event.target.value;
            let customerObj = JSON.parse(JSON.stringify(this.customerMap[event.target.value]))
            console.log('customerObj= ', customerObj);
            this.modObj.Mobile_Number_of_B__c = customerObj.Mobile__c;
        } else if (event.target.name == 'Mobile_Number_of_B__c') {
            this.modObj.Mobile_Number_of_B__c = event.target.value;
        } else if (event.target.name == 'MOD_Date__c') {
            this.modObj.MOD_Date__c = event.target.value;
        } else if (event.target.name == 'MOD_Commitment_Date__c') {
            this.modObj.MOD_Commitment_Date__c = event.target.value;
        }
    }

    handleBlur() {
        console.log('handleBlur called', this.totalRecommendadAmount, this.modObj.MOD_Amount__c);
        if (this.totalRecommendadAmount && this.modObj.MOD_Amount__c && this.totalRecommendadAmount > this.modObj.MOD_Amount__c && this.trial < 2) {
            this.modObj.MOD_Amount__c = undefined;
            this.trial = 2
            this.showNotifications('', 'MOD amount is less than the sanctioned amount. Please check the same', 'error');
        }
    }

    makeSecondList() {
        let tempList = [];
        if (this.customerList1) {
            this.customerList1.forEach(element => {
                if (element.value != this.modObj.Customer_for_Collection_A__c) {
                    tempList.push({ label: element.label, value: element.value });
                }
            });

            this.customerList2 = JSON.parse(JSON.stringify(tempList));
            if (!(this.customerList2 && this.customerList2.length)) {
                this.secondRequired = false;
            }
        }
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
        return (allValid1 && allValid2);
    }

    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        this.showSpinner = false;
        this.handleMODSubmit();
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
            });
        }
    }

    handleSubmitMOD() {
        this.showSpinner = true;
        this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
    }

    // This Method Is Used To Handle MOD Submit
    async handleMODSubmit() {
        this.errorMsgs = [];
        this.requiredDocumentValidation();

        await getPendingReasonValidation({applicationId: this.recordId, stage: 'MOD Registration' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsgs.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.showSpinner = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })

        if(this.modObj.MOD_Done__c === 'NA'){
            this.errorMsgs.push('Please select correct value(Yes) for MOD done.');
        }

        if(this.modObj.MOD_Done__c === 'No'){
            this.errorMsgs.push('Please select correct value(Yes) for MOD done.');
        }

        if (!this.validationObj.dataEntry) {
            this.errorMsgs.push('Complete all entries in Data Entry section.');
        }

        if (this.errorMsgs && this.errorMsgs.length) {
            this.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.tabName = 'Error';
            }, 300);
        } else {
            this.showErrorTab = false;

            // console.log('this.modId ', this.modId);
            // const fields = {};
            // fields[APPLICATION_ID.fieldApiName] = this.recordId;
            // fields[STAGE.fieldApiName] = 'Agreement Execution';
            // const recordInput = { fields };
            // updateRecord(recordInput).then(() => {
            //     this.showNotifications('', 'MOD Registration is completed successfully!', 'success');
            //     this[NavigationMixin.Navigate]({
            //         type: 'standard__recordPage',
            //         attributes: {
            //             recordId: this.recordId,
            //             objectApiName: 'Application__c',
            //             actionName: 'view'
            //         }
            //     });
            // }).catch(error => {
            //     console.log('Error in send back.', error);
            // });
            updateStage({ applicationId: this.recordId, stage: 'Agreement Execution' }).then(() => {
                this.showNotifications('', 'MOD Registration is completed successfully!', 'success');
                window.location.replace('/'+this.recordId);
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__recordPage',
                //     attributes: {
                //         recordId: this.recordId,
                //         objectApiName: 'Application__c',
                //         actionName: 'view'
                //     }
                // });
            }).catch(error => {
                console.log('Error in Stage Updation= ', error);
            });
        }
    }

    // This Method Is Used To Reset All Fields
    onCancel() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    handleSubmit(event) {
        console.log('Record Submitted Successfully')
        let allValid = this.handleCheckValidity();
        console.log('allValid= ', allValid);
        if (!allValid) {
            event.preventDefault();
            return;
        }
    }

    handleSuccess() {
        console.log('Record Saved Successfully')
        this.validationObj.dataEntry = true;
        this.showNotifications('', 'Record Saved Successfully.', 'success');
    }

    handleError(evt) {
        console.log('handleError= ', evt);
        console.log('handleError= ', evt.detail);
    }

    // This Method Is Used To Show Toast Notification
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    /* ----------------- All the apex method below --------------------- */

    // This Method Is Used To Get User's Last Login Date From Server Side.
    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result

            let currentTab = this.tabName;
            console.log('currentTab= ', currentTab);
            let tabs = this.template.querySelectorAll('lightning-tab');
            console.log('tabs= ', tabs);
            tabs.forEach(element => {
                element.loadContent();
            });
            console.log('currentTab= ', currentTab);
            this.tabName = currentTab;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    // This Method Is Used To Get Existing Registration Record.
    handleGetExistingRecord() {
        this.showSpinner = true;
        getExistingMODRegistraton({ appId: this.recordId }).then((result) => {
            this.showSpinner = false;
            console.log('handleGetExistingRecord= ', result);
            this.validationObj.dataEntry = false;
            if (result) {
                this.modId = result.Id;
                this.modObj = JSON.parse(JSON.stringify(result));
                this.makeSecondList();
                this.validationObj.dataEntry = true;
            }
        }).catch((err) => {
            this.showSpinner = false;
            console.log('Error in handleGetExistingRecord= ', err);
        });
    }

    handleGetApplicantRecords() {
        getLoanApplicantRecords({ appId: this.recordId }).then((result) => {
            this.customerMap = JSON.parse(JSON.stringify(result))
            let tempList = [];

            for (let keyValue of Object.keys(result)) {
                tempList.push({ label: keyValue, value: keyValue });
            }
            this.customerList1 = JSON.parse(JSON.stringify(tempList))
            this.makeSecondList();
        }).catch((err) => {
            console.log('getApplicantRecords= ', err);
        });
    }

    rowselectionevent(event) {
        var detail = event.detail;
        if (detail === 'Submit') {
            this.handleSubmitMOD();
        } else if (event.detail === 'pendingReason'){
            this.showHidePendingReasonGrid();
        }
    }
}