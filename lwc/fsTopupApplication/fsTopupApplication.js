import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import searchApplication from '@salesforce/apex/ReloginTopupController.getApplications';
//import insertReloginOrTopup from '@salesforce/apex/ReloginTopupController.insertReloginOrTopup';
import cloneExistingApplication from '@salesforce/apex/FS_CloningController.cloneExistingApplication';

export default class FsTopupApplication extends LightningElement {

    @track appNumber;
    @track topupApp;
    @track topupKYC;
    @track kycNumber;
    @track loanAppNumber;
    @track topupLoanAcc;
    @track isAppDataArrived = false;
    @track hasTopup = false;
    @track appResult = [];
    @track moveNext = true;
    @track isSpinnerActive = false;
    @track oldAppId;
    @track newAppId;

    handleTopupApp(event) {
        console.log('handlcReloginApp');
        console.log('appNo ', event.detail.value);
        this.appNumber = event.detail.value;
        this.topupApp = event.detail.value;
        this.topupKYC = '';
        this.kycNumber = '';
        this.loanAppNumber = '';
        this.topupLoanAcc = '';
    }

    handleTopupKYC(event) {
        console.log('handleReloginKYC');
        console.log('KYC no ', event.detail.value);
        this.kycNumber = event.detail.value;
        this.topupKYC = event.detail.value;
        this.topupApp = '';
        this.appNumber = '';
        this.loanAppNumber = '';
        this.topupLoanAcc = '';
    }

    handleLoanApp(event){
        console.log('handleLoanAccountNumber');
        console.log('Loan Acccount No ', event.detail.value);
        this.loanAppNumber = event.detail.value;
        this.topupLoanAcc = event.detail.value;
        this.kycNumber = '';
        this.topupKYC = '';
        this.topupApp = '';
        this.appNumber = '';
    }

    searchAllApplication() {
        this.isSpinnerActive = true;
        this.isAppDataArrived = false;
        this.appResult = undefined;
        console.log('Search Called ', this.appNumber + ' :: ', this.kycNumber);
        if ((this.appNumber != undefined && this.appNumber != null && this.appNumber != '') || (this.kycNumber != undefined && this.kycNumber != null && this.kycNumber != '') || this.loanAppNumber) {
            searchApplication({ appNumber: this.appNumber, kycNumber: this.kycNumber, loanAppNo : this.loanAppNumber, recType : '3. Top-up loan' })
                .then(result => {
                    var temp =  result; //JSON.parse(result.strDataTableData);
                    console.log('temp', temp);
                    console.log('relogin length ', temp.length);
                    this.hasTopup = (temp.length == 0) ? false : true;
                    console.log('hasRelogin ', this.hasTopup);
                    this.appResult =  result;//JSON.parse(JSON.stringify(result));
                    this.isAppDataArrived = true;
                    //console.log('json data ====> ' , JSON.parse(JSON.stringify(result)));
                    this.isSpinnerActive = false;
                    if(!this.hasTopup){
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
            this.showToast('Error', 'Error', 'Enter Application Number Or KYC Number Or Loan Account Number!!');
            this.closeAction();
            this.isSpinnerActive = false;
        }
    }

    handleRadioButton(event){
        console.log('onselect ');
        this.oldAppId = event.target.dataset.appId
        console.log('oldAppId ',this.oldAppId);
        // if (event.detail[0]['Application__r.application_status__c'] === 'Active') {
        //     this.showToast('Error', 'Error', 'Application already active, proceed with existing application.');
        //     this.closeAction();
        //     return;
        // }
        this.moveNext = false;
    }

    handleNext(){
        this.isSpinnerActive = true;
        console.log('Next Clicked ');
        cloneExistingApplication({oldApplicationId : this.oldAppId, recTypeName : '3. Top-up loan'})
        .then(result =>{
            console.log('res ',result);
            if(result){
                this.moveNext = true;
                this.newAppId = result.appId;
                var sendObj = { isNewLogin : '', newAppId : '', preloginId : '', oldAppName : '', newAppName : '' };
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
        .catch(error =>{
            console.log('error ',error);
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