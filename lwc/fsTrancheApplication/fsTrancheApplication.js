import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getApplications from '@salesforce/apex/FsTrancheController.getApplications';
import cloneExistingApplication from '@salesforce/apex/FS_CloningController.cloneExistingApplication';

export default class FsTrancheApplication extends LightningElement {

    @track appNumber;
    @track trancheApp;
    @track trancheLoanAccountNumber;
    @track loanAccountNumber;
    @track trancheKYC;
    @track kycNumber;
    @track isAppDataArrived = false;
    @track hasTranche = false;
    @track appResult = [];
    @track moveNext = true;
    @track isSpinnerActive = false;
    @track oldAppId;
    @track newAppId;

    handleTrancheApp(event) {
        console.log('handlcTrancheApp');
        console.log('appNo ', event.detail.value);
        this.appNumber = event.detail.value;
        this.trancheApp = event.detail.value;
        this.trancheLoanAccountNumber = '';
        this.loanAccountNumber = '';
        this.loanAccountNo = ''
        this.trancheKYC = '';
        this.kycNumber = '';
    }

    handleTrabcheLoanAccountNo(event) {
        console.log('handleLoanAccountNumber');
        console.log('Loan Acccount No ', event.detail.value);
        this.loanAccountNumber = event.detail.value;
        this.trancheLoanAccountNumber = event.detail.value;
        this.appNumber = '';
        this.trancheApp = '';
        this.trancheKYC = '';
        this.kycNumber = '';
    }
    handleTrancheKYC(event) {
        console.log('handleTrancheKYC');
        console.log('KYC Number', event.detail.value);
        this.kycNumber = event.detail.value;
        this.trancheKYC = event.detail.value;
        this.appNumber = '';
        this.trancheApp = '';
        this.loanAccountNumber = '';
        this.trancheLoanAccountNumber = '';
    }

    searchAllApplication() {
        this.isSpinnerActive = true;
        this.isAppDataArrived = false;
        console.log('Search Called ', this.appNumber + ' :: ', this.loanAccountNumber);
        if ((this.appNumber) || (this.loanAccountNumber) || (this.kycNumber)) {
            getApplications({ appNumber: this.appNumber, loanAccountNo: this.loanAccountNumber, kycNumber: this.kycNumber })
                .then(result => {
                    console.log('result', result);
                    this.hasTranche = (result.length == 0) ? false : true;
                    console.log('hasTranche ', this.hasTranche);
                    this.appResult = result;
                    this.isAppDataArrived = true;
                    this.isSpinnerActive = false;
                    if (!this.hasTranche) {
                        this.showToast('Error', 'Error', 'No Application Found!!');
                        this.closeAction();
                    }
                })
                .catch(error => {
                    console.log('Error In Get APP Data ', error);
                    this.showToast('Error', 'Error', 'No Application Found!!');
                    this.closeAction();
                    this.isSpinnerActive = false;
                })
        }
        else {
            this.showToast('Error', 'Error', 'Enter Application Number Or Loan Account Number Or KYC Number!!');
            this.closeAction();
            this.isSpinnerActive = false;
        }
    }

    handleRadioButton(event) {
        console.log('onselect ',event);
        this.oldAppId = event.target.dataset.appId
        console.log('oldAppId ', this.oldAppId);
        console.log('Radio button', parseFloat(event.target.dataset.disbursal),' :: ', parseFloat(event.target.dataset.sanction));
        // if(parseFloat(event.target.dataset.disbursal) >=  parseFloat(event.target.dataset.sanction)){
        //     this.showToast('Error', 'Error', 'Tranche not possible, whole amount is disbursed.');
        //     this.closeAction();
        // }
        // else
        //     this.moveNext = false;   
        this.moveNext = false;   
    }

    handleNext() {
        this.isSpinnerActive = true;
        console.log('Next Clicked ');
        cloneExistingApplication({ oldApplicationId: this.oldAppId, recTypeName: '4. Tranche loan' })
            .then(result => {
                this.moveNext = true;
                console.log('res ', result);
                if (result) {
                    console.log('Result ', result);
                    this.newAppId = result.appId;
                    var sendObj = { isNewLogin: '', newAppId: '', preloginId: '', oldAppName: '', newAppName: '' };
                    sendObj.isNewLogin = true;
                    sendObj.newAppId = result.appId;
                    sendObj.preloginId = result.preloginId;
                    sendObj.oldAppName = result.oldAppName;
                    sendObj.newAppName = result.newAppName;
                    const showNewLogin = new CustomEvent("shownewlogin", {
                        detail: sendObj
                    });
                    console.log('showNewLogin event  ', showNewLogin);
                    this.dispatchEvent(showNewLogin);
                    this.isSpinnerActive = false;
                }
            })
            .catch(error => {
                console.log('error ', error);
            })

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

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}