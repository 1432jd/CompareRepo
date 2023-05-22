import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PENDING_REASON_OBJECT from '@salesforce/schema/Pending_Reason__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PENDING_RESAON_FIELD from '@salesforce/schema/Pending_Reason__c.Pending_Reason__c';
import PENDING_STATUS_FIELD from '@salesforce/schema/Pending_Reason__c.Pending_Status__c';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import getPendingReasonRecords from '@salesforce/apex/FS_PendingReasonController.getPendingReasonRecords';
import savePendingReasonRecords from '@salesforce/apex/FS_PendingReasonController.savePendingReasonRecords';
import getPendingReasonExceptAppCurrentStage from '@salesforce/apex/FS_PendingReasonController.getPendingReasonExceptAppCurrentStage';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FsPendingReasonGrid extends LightningElement {
    @api applicationId;
    @api stageName;
    
    @track pendingReasonOptions;
    @track pendingStatusOptions;
    @track todayDate;
    @track currentUserName;
    @track showSpinner = false;

    @track recordList = [];
    getPendingReasonList = [];

    @wire(getObjectInfo, { objectApiName: PENDING_REASON_OBJECT })
    pendingObjectInfo;

    @wire(getPicklistValues, { recordTypeId: "$pendingObjectInfo.data.defaultRecordTypeId", fieldApiName: PENDING_RESAON_FIELD })
    pendingReasonPicklistInfo({ data, error }) {
        this.pendingReasonOptions = [];
        if (data) {
            console.log('pendingReasonPicklistInfo = ',data);
            console.log('Stage Value = ',data.controllerValues[this.stageName])
            let stageValue = data.controllerValues[this.stageName];
            let tempList = [];
            data.values.forEach(element => {
                if(element.validFor.includes(stageValue)){
                    tempList.push({label : element.label,value : element.value});
                }
            });
            this.pendingReasonOptions = JSON.parse(JSON.stringify(tempList))
            console.log('pendingStatusPicklistInfo = ',this.pendingStatusOptions);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$pendingObjectInfo.data.defaultRecordTypeId", fieldApiName: PENDING_STATUS_FIELD })
    pendingStatusPicklistInfo({ data, error }) {
        this.pendingStatusOptions = [];
        if (data) {
            console.log('pendingStatusPicklistInfo = ',data);
            this.pendingStatusOptions = data.values;            
        }
    }

    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            this.error = error ;
        }
    }

    connectedCallback() {
        let td = new Date();
        this.todayDate = td.toISOString();
        this.handleGetPendingReasons();
        this.getPendingReasonExceptAppCurrentStage();
    }

    //@12 May 2023 : it will display the read-only data in the on pending reason button on FIV-B, FIV-C button on application
    getPendingReasonExceptAppCurrentStage(){
        getPendingReasonExceptAppCurrentStage({ applicationId: this.applicationId, stage : this.stageName}).then((result) => {
            console.log('this.applicationId >>  = ', this.applicationId);
            console.log('this.stageName >>   = ', this.stageName);
            console.log('getPendingReasonExceptAppCurrentStage = ', result);
            if (result && result.length) {
                this.getPendingReasonList = JSON.parse(JSON.stringify(result));
                console.log('getPendingReasonList >>>  = ', this.getPendingReasonList);
            } else {
                this.getPendingReasonList = [];
            }
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in getPendingReasonRecords = ', err);
            this.showSpinner = false;
        });
    }

    pushRecord() {
        let newList = JSON.parse(JSON.stringify(this.recordList));
        this.recordList = undefined;
        //let floorNo = (newList && newList.length) ? (newList.length + 1) : 1;
        let tempObj = {
            Application__c: this.applicationId,
            Pending_Reason__c: undefined,
            Pending_Remarks__c: undefined,
            Pending_Status__c: undefined,
            Query_Raised_Date__c: undefined,
            Pending_Stage__c: this.stageName,
            CreatedDate__c: this.todayDate,
            CreatedById: undefined
        };
        newList.push(tempObj);
        this.recordList = JSON.parse(JSON.stringify(newList));
    }

    handleFormValues(evt){
        let index = evt.currentTarget.dataset.index;
        console.log('handleFormValues Index = ', index)
        let newList = JSON.parse(JSON.stringify(this.recordList));
        if (evt.target.name) {
            newList[index][evt.target.name] = evt.target.value;
        }
        this.recordList = JSON.parse(JSON.stringify(newList));
    }

    handleSave(){
        let recordValid = this.checkInputValidity();
        if (!recordValid) {
            this.showNotifications('', 'Please fill all the data correctly', 'error');
            return;
        } else {
            this.saveRecords();
        }
    }

    checkInputValidity() {
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

        return allValid1 && allValid2;
    }

    // This Method Is Used To Show Toast Notification.
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    handleGetPendingReasons(){
        getPendingReasonRecords({ applicationId: this.applicationId, stage : this.stageName }).then((result) => {
            console.log('getPendingReasonRecords = ', result);
            if (result && result.length) {
                this.recordList = JSON.parse(JSON.stringify(result));
            } else {
                this.recordList = [];
                this.pushRecord();
            }
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in getPendingReasonRecords = ', err);
            this.showSpinner = false;
        });
    }

    saveRecords(){
        this.showSpinner = true;
        savePendingReasonRecords({ jsonData: JSON.stringify(this.recordList) }).then((result) => {
            console.log('savePendingReasonRecords= ', result);
            if (result == 'success') {
                this.showNotifications('', 'Records Saved Successfully', 'success');
                this.handleGetPendingReasons();
            }
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in savePendingReasonRecords= ', err);
            this.showSpinner = false;
        });
    }
}