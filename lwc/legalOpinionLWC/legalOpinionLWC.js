import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getExternalLawyerTableData from '@salesforce/apex/LegalOpinionApprovalController.getExternalLawyerTableData';
import generatePublicLink from '@salesforce/apex/DatabaseUtililty.generatePublicLink';
import moveToNextStage from '@salesforce/apex/LegalOpinionApprovalController.moveToNextStage';
import checkRequiredDocs from '@salesforce/apex/DatabaseUtililty.checkRequiredDocs';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import { getRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Application__c.Name';
import LegalOpinionDate from '@salesforce/schema/Application__c.Date_of_legal_opinion__c';
import ExternalLawyer from '@salesforce/schema/Application__c.External_Lawyer__c';
import BusinessDate from '@salesforce/label/c.Business_Date';
import REQUIRED_FIELD_ERROR_MSG from '@salesforce/label/c.Legal_Opinion_Required_Field_Missing_Error_Message';
import getProperties from '@salesforce/apex/LegalOpinionApprovalController.getProperties';
import getExternalLawyer from '@salesforce/apex/LegalOpinionApprovalController.getExternalLawyer';
import updateProperties from '@salesforce/apex/LegalOpinionApprovalController.updateProperties';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';

const rowAction = [{
    label: 'Action',
    type: 'button-icon',
    typeAttributes: {
        iconName: 'utility:check',
        title: 'Select',
        variant: 'border-filled',
        alternativeText: 'Select',
        name: 'select'
    }
}];
export default class LegalOpinionLWC extends NavigationMixin(LightningElement) {
    @api recordId;

    @track lawyerId;
    @track isLoader = false;
    @track todaysDate = new Date().toISOString();
    @track todaysDate1 = BusinessDate;
    @track lastLoginDate;
    @track applicationName;

    @track externalLawyerTableData;
    @track rowAction = rowAction;
    @track callOnce = false;
    @track tabName = "LawyerSelection";

    @track legalOpValidation = {
        isLawyerSelected: false,
        allDocUploaded: true,
        dataEntryDone: false
    };
    @track errorMsgs;
    @track showErrorTab = false;

    @track requiredDocuments;
    @track isSpinner = false;
    @track isVisible = false;
    @track options = [];
    @track properties = [{
        Id: undefined,
        Name: undefined,
        Title_Deed_Date__c: undefined,
        Title_Deed_Number__c: undefined,
        External_Lawyer__c: undefined
    }];
    @track recordTypeName;
    @track showPendingReason = false;

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

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.parse(JSON.stringify(data)));
            const rtis = data.recordTypeInfos;
            this.recordTypeName = Object.keys(rtis).find(rti => rtis[rti].name === 'Lead Detail');
        } else if (error) {
            console.log('error= ',error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME, LegalOpinionDate, ExternalLawyer] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;
            if (data.fields.Date_of_legal_opinion__c && data.fields.Date_of_legal_opinion__c.value) {
                this.legalOpValidation.dataEntryDone = true;
            }
            if (data.fields.External_Lawyer__c && data.fields.External_Lawyer__c.value) {
                this.legalOpValidation.isLawyerSelected = true;
                this.lawyerId = data.fields.External_Lawyer__c.value;
            }
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    connectedCallback() {
        console.log('Legal Opinion = ', this.recordId);
        this.handleGetLastLoginDate();
        //this.handleGetExternalLawyerTableData();
        this.handleCheckRequiredDocs(false);
        this.getApplicationProperty();
        this.getAllExternalLawyer();
    }
    renderedCallback() {
        if (!this.callOnce) {
            const style = document.createElement('style');
            style.innerText = `.slds-form-element__label{
            font-weight: bold;
        }`;
            this.template.querySelector('[data-id="legalOpinion"]').appendChild(style);
            const label = this.template.querySelectorAll('label');
            label.forEach(element => {
                element.classList.add('bold');
            });
            console.log('renderedCallback()');
        }
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }

    handleActive(event) {
        console.log('handleActive= ', event.target.value);
        this.tabName = event.target.value;
    }

    handleSubmit(event) {
        console.log('handleSubmit');
        this.showNotifications('', 'Data Saved Successfully', 'success');
    }

    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        this.isLoader = false;
        this.handleLegalOpinionSubmit();
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

    legalOpinioSubmit() {
        this.isLoader = true;
        this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
        // setTimeout(() => {
        //     this.isLoader = false;
        //     this.handleLegalOpinionSubmit();
        // }, 3000);
    }

    async handleLegalOpinionSubmit() {
        this.errorMsgs = [];
        this.requiredDocumentValidation();

        await getPendingReasonValidation({applicationId: this.recordId, stage: 'Legal Opinion' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsgs.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.isLoader = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })

        if (!this.legalOpValidation.isLawyerSelected) {
            this.properties.forEach(currentItem => {
                if (!currentItem.External_Lawyer__c) {
                    this.errorMsgs.push('No Lawyer is selected for Property ' + currentItem.Name + ', please select any lawyer.');
                }
            });
        }
        if (!this.legalOpValidation.dataEntryDone) {
            this.errorMsgs.push(REQUIRED_FIELD_ERROR_MSG);
        }


        if (this.errorMsgs && this.errorMsgs.length) {
            this.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.tabName = 'Error';
            }, 300);
        } else {
            this.showErrorTab = false;
            this.handleMoveToNextStage();
        }
    }

    handleSuccess() {
        console.log('handleSuccess');
        this.legalOpValidation.dataEntryDone = true;
    }

    handleCheckRequiredDocs(showMsg) {
        checkRequiredDocs({ appId: this.recordId, docList: ['Legal Opinion Report'] }).then((result) => {
            console.log('checkRequiredDocs= ', result);
            if (result && result['Legal Opinion Report'] == true) {
                this.legalOpValidation.allDocUploaded = true;
                if (showMsg) {
                    this.showNotifications('', 'Legal Report Uploaded Successfully', 'success');
                }
            }
        }).catch((err) => {
            console.log('Error in handleCheckRequiredDocs= ', err);
        });
    }

    handleMoveToNextStage() {
        moveToNextStage({ appId: this.recordId }).then((result) => {
            console.log('moveToNextStage= ', result);
            if (result == 'success') {
                console.log('result= ', result);
                window.location.replace('/'+this.recordId);
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__recordPage',
                //     attributes: {
                //         recordId: this.recordId,
                //         objectApiName: 'Application__c',
                //         actionName: 'view'
                //     }
                // });
            }
        }).catch((err) => {
            console.log('Error in moveToNextStage= ', err);
        });
    }

    handleDataEntryValidation() {

    }

    handleFileUplaod(event) {
        console.log('handleFileUplaod= ', event.detail);

        generatePublicLink({ contentVersionId: event.detail[0].contentVersionId, uploadedFrom: 'LegalOpinion' }).then((result) => {
            console.log('handleFileUplaod= ', result);
            this.template.querySelector('c-generic-view-documents').getDocuments();
            this.handleCheckRequiredDocs(true);
        }).catch((err) => {
            console.log('Error in handle File upload= ', err);
        });
    }

    /* ----------------- All the table method below --------------------- */

    /*handleLawyerSelection(evt) {
        console.log('handleLawyerSelection= ', JSON.stringify(evt.detail));
        var data = evt.detail;
        if (data !== undefined && data !== '') {
            this.lawyerId = data.recordData.Id;
            this.legalOpValidation.isLawyerSelected = true;
            let lawyerName = data.recordData.Name_LABEL;
            const fields = {};
            fields[APPLICATION_ID.fieldApiName] = this.recordId;
            fields[ExternalLawyer.fieldApiName] = this.lawyerId;

            const recordInput = { fields };

            updateRecord(recordInput).then(() => {
                console.log('Lawyer selection is done succesfully ');
                this.showNotifications('', (lawyerName + ' is selected'), 'info');
            }).catch(error => {
                console.log('Error in Lawyer selection= ', error);
                this.legalOpValidation.isLawyerSelected = false;
            });
        }
    }*/

    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    /* ----------------- All the apex method below --------------------- */
    handleGetExternalLawyerTableData() {
        getExternalLawyerTableData().then((result) => {
            console.log('getExternalLawyerTableData = ', result);
            this.externalLawyerTableData = result;
        }).catch((err) => {
            console.log('getExternalLawyerTableData Error= ', err);
        });
    }

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
    handleFromValue(event) {
        let foundelement = this.properties.find(ele => ele.Id == event.target.dataset.id);
        foundelement.External_Lawyer__c = event.target.value
        console.log(foundelement.External_Lawyer__c);
        this.properties = [...this.properties];
    }
    getApplicationProperty() {
        this.isSpinner = false;
        this.legalOpValidation.isLawyerSelected = true;
        getProperties({ appId: this.recordId }).then(result => {
            this.properties = JSON.parse(JSON.stringify(result));
            this.isSpinner = true;
            this.properties.forEach(currentItem => {
                if (!currentItem.External_Lawyer__c) {
                    this.legalOpValidation.isLawyerSelected = false;
                }
            });
            if (this.properties.length > 0) {
                this.isVisible = true;
            }
        }).catch(error => {
            console.log('error in get Property = ', error)
        });
    }
    getAllExternalLawyer() {
        getExternalLawyer()
            .then(result => {
                result.forEach(currentItem => {
                    const option = {
                        label: currentItem.Name,
                        value: currentItem.Id
                    };
                    this.options = [...this.options, option];
                });
            })
            .catch(error => {
            });
    }
    saveProperty() {
        var isInputsCorrect = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
            this.legalOpValidation.isLawyerSelected = true;
            this.updateAllProperties();
        }
    }
    updateAllProperties() {
        updateProperties({ propertyList: JSON.stringify(this.properties) }).then(result => {
            console.log('Property Updated Succcessfully');
            this.showNotifications('Success', 'Property updated successfully', 'success');
        }).catch(error => {
            console.log('Error in updateProperties= ', error);
        })
    }

    rowselectionevent(event) {
        var detail = event.detail;
        if(detail === 'Submit'){
            this.legalOpinioSubmit();
        } else if (event.detail === 'pendingReason'){
            this.showHidePendingReasonGrid();
        }
    }
}