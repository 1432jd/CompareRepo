import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPendingItems from '@salesforce/apex/changeOwnerController.getPendingItems'; // Apex method
import getUsers from '@salesforce/apex/changeOwnerController.getUsers'; // Apex method
import changeOwner from '@salesforce/apex/changeOwnerController.changeOwner'; // Apex method

export default class FsChangeOwnerLWC extends LightningElement {
    _recordId;
    @track stageOptions = [];
    @track userOptions = [];
    @track selectedStageValue;
    @track selectedStageLabel;
    @track selectedUserId;
    @track dataArrived = false;
    @track userArrived = false;
    @track toggleSpinner = false;
    @track fieldsToUpdate = {
        "FIV - B": "FIV_B_User__c",
        "FIV - C": "FIV_C_User__c",
        "Online EC": "Online_EC_User__c",
        "In Principle Sanction": "OwnerId",
        "Lead Detail": "OwnerId",
        "Process Credit": "OwnerId",
        "Legal Opinion": "Legal_Opinion_User__c",
        "Approval Credit": "OwnerId",
        "Legal Approval": "Legal_Approval_User__c",
        "Final Sanction": "OwnerId",
        "Post Approval": "OwnerId",
        "MOD Registration": "OwnerId",
        "Agreement Execution": "OwnerId",
        "Dispatch Pending": "OwnerId",
        "DOS": "DOS_User__c",
        "Document Receipt": "OwnerId",
        "Disbursal Maker": "OwnerId",
        "Disbursal Author": "OwnerId",
        "Document Deferral": "OwnerId",
        "Custody": "",
        "Deviation": "Current_Deviation_Approval__c"
    };

    @api set recordId(value) {
        this.toggleSpinner = true;
        this._recordId = value;
        this.getData();
    }

    get recordId() {
        return this._recordId;
    }
    getData() {
        getPendingItems({ applicationId: this._recordId }).then(results => {
            results.forEach(element => {
                if (element.Type__c && element.Type__c == 'Application') {
                    this.stageOptions.push({
                        label: element.Stage__c,
                        value: element.Id
                    });
                } else {
                    this.stageOptions.push({
                        label: element.Type__c,
                        value: element.Id
                    });
                }
            });
            this.dataArrived = true;
            this.toggleSpinner = false;
        }).catch(error => {
            console.error('Lookup error', JSON.stringify(error));
            this.toggleSpinner = false;
        });
    }

    handleChange(event) {
        this.toggleSpinner = true;
        var selectedStage = event.detail.value;
        var selectedStageName;
        this.stageOptions.forEach(element => {
            if (element.value === selectedStage) {
                selectedStageName = element.label;
            }
        });
        this.selectedStageValue = event.detail.value;
        this.selectedStageLabel = selectedStageName;
        getUsers({ applicationId: this._recordId, stageName: selectedStageName })
            .then(results => {
                results.forEach(element => {
                    this.userOptions.push({
                        label: element.Name,
                        value: element.Id
                    });
                });
                this.userArrived = true;
                this.toggleSpinner = false;
            }).catch(error => {
                console.error('Lookup error', JSON.stringify(error));
                this.toggleSpinner = false;
            });
    }

    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleUserChange(event) {
        this.toggleSpinner = true;
        this.selectedUserId = event.detail.value;
        this.toggleSpinner = false;
    }

    handleSubmit() {
        this.toggleSpinner = true;
        var applicationObj = {
            "sobjectType": "Application__c",
            "Id": this._recordId
        }
        applicationObj[this.fieldsToUpdate[this.selectedStageLabel]] = this.selectedUserId;

        var historyObj = {
            "sobjectType": "Application_User_tracking__c",
            "Id": this.selectedStageValue,
            "Owner__c": this.selectedUserId
        }
        changeOwner({ applicationRecord: applicationObj, historyRecord: historyObj })
            .then(results => {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record updated!',
                        variant: 'success'
                    })
                );
                eval("$A.get('e.force:refreshView').fire();");
            }).catch(error => {
                console.error('error', JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error.body.message),
                        variant: 'error'
                    })
                );
                this.toggleSpinner = false;
            });
    }
}