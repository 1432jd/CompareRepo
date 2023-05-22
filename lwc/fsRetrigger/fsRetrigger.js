import { LightningElement, api, track } from 'lwc';
import createVerification from '@salesforce/apex/FSRetriggerController.createVerification';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSendBackHistory from '@salesforce/apex/Utility.createSendBackHistory';

export default class FsSendBack extends LightningElement {
    @api showModal;
    @api stageFrom;
    @api applicationId;
    @track isSpinnerActive;
    @track stageValue;
    get stageOptions() {
        if (this.stageFrom === 'Lead Details') {
            return [
                { label: 'FIV(B)', value: 'FIV_B' },
                { label: 'FIV(C)', value: 'FIV_C' },
                { label: 'Online EC', value: 'Online_EC' }
            ];
        }
        if (this.stageFrom === 'Process Credit' || this.stageFrom == 'Approval Credit') {
            return [
                { label: 'FIV(B)', value: 'FIV_B' },
                { label: 'FIV(C)', value: 'FIV_C' },
                { label: 'Online EC', value: 'Online_EC' }

            ];
        }
    }
    handleStageChange(event) {
        console.log(event.target.value);
        this.stageValue = event.target.value;
    }
    handleCancel(event) {
        const selectedtriggerEvent = new CustomEvent('checktriggervalidation', { detail: true });
        this.dispatchEvent(selectedtriggerEvent);
        const selectedEvent = new CustomEvent('closeclick', { detail: true });
        this.dispatchEvent(selectedEvent);
    }

    handleSubmitClick(event) {
        this.isSpinnerActive = true;
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if (isValid) {
            console.log('app Id in retriggger>>>> ', this.applicationId);
            console.log('stage from  in retriggger>>>> ', this.stageFrom);
            //this.isSpinnerActive = false;

            createVerification({ applicationId: this.applicationId, stageFrom: this.stageFrom, reTriggerStage: this.stageValue })
                .then(result => {
                    console.log('datatable result ', result);
                    if (result == true) {

                        var remarksValue = this.template.querySelector('lightning-textarea').value;
                        var selectedValue = this.template.querySelector('lightning-combobox').value;
                        console.log('selectedValue>>>111 ',selectedValue,'remarksValue>>@2 ',remarksValue)
                        if (remarksValue && selectedValue) {
                            this.createSendBackHistoryMethod(remarksValue,selectedValue);
                        } else {
                            this.handleCancel();
                        }
                    }
                    else if (result == false) {
                        this.showToastMessage('Error', 'Verification already Initiated', 'error');
                        this.handleCancel();
                    }
                    this.isSpinnerActive = false;
                })
                .catch(error => {
                    console.log('error in getpropownersdata ', error);
                    this.showToastMessage('Error', error, 'Error');
                    this.isSpinnerActive = false;
                })
        } else {
            this.showToastMessage('Error', 'Complete Required Field.', 'Error');
            this.isSpinnerActive = false;
        }
    }

    createSendBackHistoryMethod(remarksValue, selectedValue) {
        var moduleTo;
        if(selectedValue == 'FIV_C'){
            moduleTo = 'FIV-C';
        }else if(selectedValue == 'FIV_B'){
            moduleTo = 'FIV-B';
        }else if(selectedValue == 'Online_EC'){
            moduleTo = 'Online EC';
        }
        createSendBackHistory({
            parentId: this.applicationId,
            title: this.stageFrom + ' - ' + moduleTo,
            body: remarksValue
        }).then((result) => {
            console.log('createSendBackHistory result =', result);
            if (result == 'success') {
                console.log('resiltttt>> ', result)
                this.showToastMessage('Success', 'Verification Initiated Successfully', 'Success');
                this.isSpinnerActive = false;
                const selectedEvent = new CustomEvent('submitclick', { detail: selectedValue });
                this.dispatchEvent(selectedEvent);
                console.log('selectedEvent result22222 =', moduleTo);
                this.handleCancel();
            }
        }).catch((err) => {
            console.log('error in createSendBackHistory= ', err);
            this.isSpinnerActive = false;
        });
    }
    showToastMessage(title, message, variant) {
        console.log('toast', title, ' callled ', message, '>>>> ', variant)
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );

    }
}