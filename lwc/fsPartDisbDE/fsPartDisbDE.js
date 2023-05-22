import { LightningElement, api, track, wire } from 'lwc';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import { getRecord } from 'lightning/uiRecordApi';
import BusinessDate from '@salesforce/label/c.Business_Date';
import NAME from '@salesforce/schema/Application__c.Name';
import Disbursal_type_FIELD from '@salesforce/schema/Application__c.Disbursal_Type__c';
import Part_Disbursal_Remarks_FIELD from '@salesforce/schema/Application__c.Part_Disbursal_Remarks__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateApptStageFromDE from '@salesforce/apex/fsPartDisbDEController.updateApptStageFromDE';


export default class FsPartDisbDE extends LightningElement {

    @api recordId;
    objectApiName = "Application__c";
    @track applicationName;
    @track todaysDate = BusinessDate;
    @track lastLoginDate;
    @track value = 'inProgress';
    @track requiredDocuments;
    @track showPendingReason = false;
    @track isSpinner = false;
    @track disbursalType = '';
    @track disbursalRemark = '';
    @track errorMsgs = [];
    @track tabName = 'Document Upload';
    @track showErrorTab = false;
    disableButtonSave = true;


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

    connectedCallback() {
        this.handleGetLastLoginDate();
    }
    
    handleInputChange(event) {
        if(event.target.fieldName == 'Disbursal_Type__c'){
            this.disbursalType = event.target.value;
        }else if(event.target.fieldName == 'Part_Disbursal_Remarks__c'){
            this.disbursalRemark = event.target.value;
        }
    }

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME, Disbursal_type_FIELD, Part_Disbursal_Remarks_FIELD] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;            
            if(data.fields.Disbursal_Type__c && data.fields.Disbursal_Type__c.value)
                this.disbursalType = data.fields.Disbursal_Type__c.value;
            if(data.fields.Part_Disbursal_Remarks__c && data.fields.Part_Disbursal_Remarks__c.value)
                this.disbursalRemark = data.fields.Part_Disbursal_Remarks__c.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        this.isSpinner = false;
        this.handlePartDisbursementSubmit();
    }

    rowselectionevent(event) {
        var detail = event.detail;
        if (detail === 'Submit') {
            this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
        } else if (detail === 'pendingReason') {
            this.showHidePendingReasonGrid();
        }
    }

    // do all the code related to submit in this method
    handlePartDisbursementSubmit() {
        this.errorMsgs = [];
        this.showErrorTab = false;
        this.requiredDocumentValidation();
        if(!this.disbursalRemark || !this.disbursalType){
            this.errorMsgs.push('Please Complete Data Entry.');
        }

        if(this.disbursalType == 'Part Disb'){
            this.errorMsgs.push('Application Cannot Move Ahead In Part Disbursement Mode.');
        }
        if(this.errorMsgs && this.errorMsgs.length){
            this.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.tabName = 'Error';
            }, 300);
        }else{
            // Submit work. #JUNEID NEED TO CALL NEW METHOD
            //window.location.replace('/'+this.recordId);


            updateApptStageFromDE({
                apptId: this.recordId
            }).then((result) => {
        
                console.log('Fiv_Disb_Lwc Saved sfObjJSON = ', JSON.stringify(result));
        
                if (result !== 'Success') {
                    this.showNotification('ERROR', 'There is some error please contact with your system admin', 'error'); //incase if any apex exception happened it will show notification
                } else if(result == 'Success') {
                    this.showNotification('Success', 'Part Disbursment Stage submitted successfully ', 'success');
                }
                
            }).catch((err) => {
                //incase if any Salesforce exception happened it will show notification
                console.log('Error = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });
            
            window.location.replace('/'+this.recordId);
        }
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
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

    handleRevisitSuccess(){
        this.showNotifications('','Values Saved Successfully.','success');
    }

    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    handleActive(event) {
        console.log('handleActive= ', event.target.value);
        this.tabName = event.target.value;
    }

}