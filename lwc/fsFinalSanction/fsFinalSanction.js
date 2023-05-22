import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord, createRecord } from 'lightning/uiRecordApi';
import getPropertyRecords from '@salesforce/apex/FinalSanctionController.getValidationTableData';
import APPLICATION_OBJECT from "@salesforce/schema/Application__c";
import ID_FIELD from "@salesforce/schema/Application__c.Id";
import NAME_FIELD from '@salesforce/schema/Application__c.Name';
import STAGE_FIELD from "@salesforce/schema/Application__c.Stage__c";
import SUB_STAGE_FIELD from "@salesforce/schema/Application__c.Sub_Stage__c";
import checkSendBackVaidation from '@salesforce/apex/FinalSanctionController.checkSendBackVaidation';
import sendBackLegalApproval from '@salesforce/apex/FinalSanctionController.sendBackLegalApproval';
import sendBackAprovalCredit from '@salesforce/apex/FinalSanctionController.sendBackAprovalCredit';
import moveStage from '@salesforce/apex/FinalSanctionController.moveStage';
//import doSendBack from '@salesforce/apex/FinalSanctionController.doSendBack';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Verification from '@salesforce/schema/Verification__c';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';
//import Legal_Approval__c from '@salesforce/schema/Legal_Approval__c';


export default class FsFinalSanction extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showPendingReason = false;
    @track _activeTab = 'Final_Sanction';
    @track _dataToDisplay = [];
    @track _btns = [
        {
            name: 'SendBack',
            label: 'Send Back',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
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
    @track _isSendBack = false;
    @track _showErrorTab = false;
    @track _errorMessages = [];
    @track _acRecordTypeId;
    @track _allPreviousStageDone = false;

    @track showSpinner = false;

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    application;

    get name() {
        return getFieldValue(this.application.data, NAME_FIELD);
    }

    @wire(getObjectInfo, { objectApiName: Verification })
    getPropertydata({ data, error }) {
        if (data) {
            for (var key in data.recordTypeInfos) {
                if (data.recordTypeInfos[key].name === 'AC') {
                    this._acRecordTypeId = data.recordTypeInfos[key].recordTypeId;
                }
            }
        }
    }

    connectedCallback() {
        getPropertyRecords({ applicationId: this.recordId })
            .then(result => {
                this._dataToDisplay = result;
                this.checkSendBack();
            })
            .catch(error => {
                this.showToast('Error', 'error', error.body.message);
            });
    }

    async rowselectionevent(event) {
        var detail = event.detail;
        if (detail === 'SendBack') {
            this._isSendBack = true;
        }
        if (detail === 'Submit') {
            await getPendingReasonValidation({ applicationId: this.recordId, stage: 'Final Sanction' }).then(result => {
                console.log('getPendingReasonValidation= !!', result);
                this.handleSubmit(result);
            }).catch(error => {
                console.log('Pending Reasons Not Resolved. ', error);
                this.handleSubmit(false);
            })
        }
        if (event.detail === 'pendingReason'){
            this.showHidePendingReasonGrid();
        }
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }
    
    handleSendbackClose(event) {
        this._isSendBack = event.detail ? false : true;
    }

    handleSendbackSubmit(event) {
        this._isSendBack = false;
        let value = event.detail;
        console.log('value' + value);
        if (value != null) {
            this.showSpinner = true;
            if (value == "Approval Credit") {
                sendBackAprovalCredit({ applicationId: this.recordId }).then(result => {
                    console.log('result' + result);
                    this.updateApplication(value);
                }).catch(error => {
                    console.log('Error', error)
                    this.showSpinner = false;
                })
            }
            if (value == 'Legal Approval') {
                sendBackLegalApproval({ applicationId: this.recordId }).then(result => {
                    this.updateApplication(value);
                }).catch(error => {
                    console.log('Error', error)
                    this.showSpinner = false;
                })
            }

        }

        // var type = event.detail;
        // var objToInsert = {};
        // objToInsert.Application__c = this.recordId;
        // if(type === 'Approval Credit'){
        //     objToInsert.sobjectType = 'Verification__c';            
        //     objToInsert.RecordTypeId = this._acRecordTypeId;            
        // }
        // if(type === 'Legal Approval'){
        //     objToInsert.sobjectType = 'Legal_Approval__c';
        //     objToInsert.Status__c = 'Pending';
        // }        
        // doSendBack({ objToInsert: objToInsert })
        //     .then(result => {
        //         this._isSendBack = false;
        //         this.showToast('Success', 'success', type+' inititated successfully.');
        //         this.updateApplication(type);
        //         this.checkSendBack();
        //     })
        //     .catch(error => {
        //         this._isSendBack = false;
        //         this.showToast('Error', 'error', error.body.message);
        //     });
    }

    getAllOkay() {
        var result = [];
        for (var i = 0; i < this._dataToDisplay.length; i++) {
            for (var j = 0; j < this._dataToDisplay[i].sectionContentList.length; j++) {
                result.push(this._dataToDisplay[i].sectionContentList[j].validation);
            }
        }
        return !result.includes("Not Okay");
    }

    checkSendBack() {
        checkSendBackVaidation({ applicationId: this.recordId })
            .then(result => {
                console.log('checkSendBack==', result);
                this._allPreviousStageDone = result;
            })
            .catch(error => {
                this.showToast('Error', 'error', error.body.message);
            });
    }

    handleSubmit(isPendingReason) {
        this._errorMessages = new Array();
        var _allOkay = this.getAllOkay();
        //var _allPreviousStageDone = this.checkSendBack();
        this.checkSendBack();
        console.log('==_allOkay==', _allOkay);
        console.log('==_allPreviousStageDone==', this._allPreviousStageDone);
        if (this._allPreviousStageDone && _allOkay && !isPendingReason) {
            //   this.updateApplication('Post Approval');
            this.showToast('success', 'success', 'Final Sanction stage is completed successfully!');
            moveStage({ applicationId: this.recordId }).then(result => {
                console.log('res ', result);
                window.location.replace('/'+this.recordId);
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__recordPage',
                //     attributes: {
                //         recordId: this.recordId,
                //         actionName: 'view'
                //     }
                // });
            })
        } else {
            this._showErrorTab = true;
            this._activeTab = 'Error'
            if (!_allOkay) {
                this._errorMessages.push('Found Not Okay in validation table. Inititate Send Back and Try again Later.');
            }
            if (!this._allPreviousStageDone) {
                this._errorMessages.push('Approval Credit Or Legal Approval is pending.');
            }
            if(isPendingReason){
                this._errorMessages.push('Pending Reasons Not Resolved.')
            }
        }
    }

    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

    navigateToApplication() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            }
        });
    }

    updateApplication(stageValue) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        if (stageValue === 'Legal Approval') {
            fields[SUB_STAGE_FIELD.fieldApiName] = stageValue;
            fields[STAGE_FIELD.fieldApiName] = 'Awaiting Legal Approval';
        } else {
            if (stageValue === 'Approval Credit') {
                fields[STAGE_FIELD.fieldApiName] = stageValue;
                console.log('fields' + fields[STAGE_FIELD.fieldApiName]);
            }
        }
        const recordInput = {
            fields: fields
        };

        console.log('fields To Upddate ', recordInput);
        updateRecord(recordInput)
            .then((record) => {
                this.showSpinner = false;
                this.showToast('Success', 'success', 'Final Sanction moved to ' + stageValue + ' successfully.');
                this.navigateToApplication();
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('Error', 'error', error.body.message);
            });
    }
    // const fields = {};
    // fields[ID_FIELD.fieldApiName] = this.recordId;        
    // if(stageValue === 'Legal Approval'){
    //     fields[SUB_STAGE_FIELD.fieldApiName] = stageValue;
    // }else{
    //     fields[STAGE_FIELD.fieldApiName] = stageValue;
    // }
    // const recordInput = {
    //     fields: fields
    // };

    // updateRecord(recordInput)
    // .then((record) => {
    //     this.showToast('Success', 'success', 'Final Sanction moved to '+stageValue+' successfully.');
    //     this.navigateToApplication();
    // })
    // .catch(error => {                
    //     this.showToast('Error', 'error', error.body.message);
    // }); 
}