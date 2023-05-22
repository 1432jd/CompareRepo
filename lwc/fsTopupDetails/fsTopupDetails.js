import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import APPLICATION_OBJECT from '@salesforce/schema/Topup__c';
import CONSIDER_FOR_FIELD from "@salesforce/schema/Topup__c.Considered_For__c";
import gettopupDetails from '@salesforce/apex/fsPcAcController.gettopupDetails';
import saveTopupDetails from '@salesforce/apex/fsPcAcController.saveTopupDetails';
export default class FsTopupDetails extends LightningElement {

    @api applicationId;
    @api showTopupDetails;
    @api showOldLoanDetails;
    @api showCollateralDetails;
    @api source;
    @track topupSpinner;
    @track topupData;
    @track collateralData;
    @track isDisabled = true;
    considerforValues;
    _wiredResult;


    // importing the  fields from Sanction_Condition__c 
    @wire(getObjectInfo, { objectApiName: APPLICATION_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CONSIDER_FOR_FIELD })
    considertype({ data, error }) {
        if (data) {
            this.considerforValues = data.values;
        } else if (error) {
            console.log(error);
        }
    }


    connectedCallback() {
        console.log('App Id in Topup ##', this.applicationId);
    }


    @wire(gettopupDetails, { applicationId: '$applicationId' })
    wiredTopupDetails(value) {
        this.topupSpinner = true;
        const { data, error } = value;
        this._wiredResult = value;
        if (data) {
            console.log('topup Details in Wire', data);
            if (data.TopupDetailsList.length)
                this.topupData = JSON.parse(JSON.stringify(data.TopupDetailsList));
            if (data.PropertyList.length)
                this.collateralData = JSON.parse(JSON.stringify(data.PropertyList));
            this.topupSpinner = false;
        } else if (error) {
            console.error('topup Details in Wire error => ', JSON.stringify(error));
            this.topupSpinner = false;
        }
    }

    handlechange(event) {
        let index = event.currentTarget.dataset.index;
        let value = event.target.value;
        console.log('index', index, ' value ', value);
        if (event.target.name == 'Considered_for__c') {
            this.topupData[index].ConsiderForTotalExposure = value;
        }
        else if (event.target.name == 'Remarks_Topup__c') {
            this.topupData[index].Remarks = value;
        }
        this.topupData[index].IsChanged = true;
        this.isDisabled = false;
    }

    // Method to handle Updation of Topup Details
    handleTopupSave() {
        let checkValidity = this.handleCheckValidity();
        console.log('checkValidity %%', checkValidity);
        if (checkValidity) {
            this.topupSpinner = true;
            saveTopupDetails({ Data: JSON.stringify(this.topupData),applicationId : this.applicationId ,calledFrom : this.source})
                .then(result => {
                    console.log('Response from Server--->', result);
                    if (result == 'success') {
                        this.showTopupNotification('Success', 'success', 'Records Saved Successfully');
                        refreshApex(this._wiredResult);
                    } else if (result == 'error') {
                        this.showTopupNotification('Error', 'error', 'Error occured while Saving Records');
                    }
                    this.dispatchEvent(new CustomEvent('refreshfinancialcalculation'));
                    this.topupSpinner = false;
                })
                .catch(err => {
                    console.log('error from Server----->', err);
                    this.topupSpinner = false;
                })
        }
        else {
            this.showTopupNotification('Error', 'error', 'Please Complete Required Fields');
        }
    }


    // method used to check Validation 
    handleCheckValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid1 && allValid2) {
            return true;
        }
        else {
            return false;
        }
    }


    // show toast Method
    showTopupNotification(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }
}