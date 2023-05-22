import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import NAME from '@salesforce/schema/Application__c.Name';
import BusinessDate from '@salesforce/label/c.Business_Date';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import STAGE_FIELD from '@salesforce/schema/Application__c.Stage__c';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import formFactorName from '@salesforce/client/formFactor';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';
export default class FsDeferalDocment extends NavigationMixin(LightningElement) {
    @api recordId;
    @api stageName;
    @api propRecTypeId;
    @track isSaveDisabled = true;
    @track isSpinnerActive = false;
    @track applicationName;
    @track todaysDate = BusinessDate;
    @track lastLoginDate;
    @track errorMasg = [];
    @track showErrorTab = false;
    @track requiredDocuments;
    @track activeTab = "Document Upload";
    @track showPendingReason = false;
    @track showPendingError = false;

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.stringify(data));
            const rtis = data.recordTypeInfos;
            this.propRecTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'AC Property Detail');
            console.log('Property Id ', this.propRecTypeId);
        } else if (error) {

        }
    }

    connectedCallback() {
        this.handleGetLastLoginDate();
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME] })
    applicationDetails({ error, data }) {
        if (data) {
            this.applicationName = data.fields.Name.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            this.lastLoginDate = result
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    @track btns = [
        {
            name: 'submit',
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
    ]

    rowselectionevent(event) {
        var detail = event.detail;
        console.log('detail ### ', JSON.stringify(detail));
        try {
            if (detail === 'submit') {
                this.showPendingError = false;
                this.showErrorTab = false;
                getPendingReasonValidation({ applicationId: this.recordId, stage: 'Document Deferral' }).then(result => {
                    console.log('getPendingReasonValidation= !!', result);
                    this.showPendingError = result;
                    this.template.querySelector('c-fs-generic-upload-documents').checkAllRequiredDocument();
                }).catch(error => {
                    this.isLoading = false;
                    console.log('Pending Reasons Not Resolved. ', error);
                })
            } else if (event.detail === 'pendingReason') {
                this.showHidePendingReasonGrid();
            }
        }
        catch (error) {
            console.log(error);
        }
    }

    toast(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: variant,
            message: message
        })
        this.dispatchEvent(toastEvent)
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }

    handleRequiredDocument(event) {
        this.requiredDocuments = JSON.parse(JSON.stringify(event.detail));
        this.errorMasg = [];
        if (this.requiredDocuments && this.requiredDocuments.length) {
            this.activeTab = 'Errors';
            console.log('requiredDocuments ', this.requiredDocuments);

            this.toast('error', 'error', 'Upload all the Required Documents.');
            this.requiredDocumentValidation();
        }
        if (this.showPendingError) {
            this.errorMasg.push('Pending Reasons Not Resolved.');
        }

        if (this.errorMasg && this.errorMasg.length) {
            this.showErrorTab = true;
        }
        else {
            this.isSpinnerActive = true;
            console.log('this.recordId= ', this.recordId);
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[STAGE_FIELD.fieldApiName] = 'File Inward';
            const recordInput = { fields };
            console.log('fiield ', fields);
            updateRecord(recordInput).then(() => {
                this.toast('Success', 'Success', 'Document Submitted Successfully.');
                if (formFactorName === 'Large') {
                    window.location.replace('/' + this.recordId);
                }
                else {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            actionName: 'view'
                        }
                    });
                }
                this.isSpinnerActive = false;
            }).catch(error => {
                console.log('upd ', error);
            });
        }
    }
    requiredDocumentValidation() {
        if (this.requiredDocuments.length > 0) {
            this.requiredDocuments.forEach(element => {
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.errorMasg.push('Upload Application Document ' + element.documentName);
                }
                if (element.documentType === 'Applicant') {
                    this.errorMasg.push('Upload Document ' + element.documentName + ' For ' + element.customerName);
                }
                if (element.documentType === 'Asset') {
                    this.errorMasg.push('Upload Document ' + element.documentName + ' For ' + element.propertyName);
                }
            });
        }
    }
}