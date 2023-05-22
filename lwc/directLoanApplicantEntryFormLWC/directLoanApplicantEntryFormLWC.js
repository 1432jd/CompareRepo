import { LightningElement, wire, track, api } from 'lwc';
import insertPreLogin from '@salesforce/apex/FsPreloginController.insertPreLogin';
import insertDirectApplications from '@salesforce/apex/FsPreloginController.insertDirectApplications';
import insertApplicant from '@salesforce/apex/FsPreloginController.insertApplicant';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class DirectLoanApplicantEntryFormLWC extends LightningElement {

    @api isDirectEntry = false; //Is Direct Entry

    @track salutationValue;
    @track branchId;
    @track preloginId;
    @track saveDisable;
    @track applicationId;
    @track appName;
    @track accDetails = { Salutation: '', FirstName: '', LastName: '' };
    @track loanAppId;
    @track isLoading = false;

    get salutationOptions() {
        return [
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Mrs.', value: 'Mrs.' },
        ];
    }

    handleChange(event) {
        console.log(event);
        console.log(event.target.dataset.id);
        if (event.target.dataset.id === 'Salutation')
            this.accDetails.Salutation = event.detail.value;
        else if (event.target.dataset.id === 'FirstName')
            this.accDetails.FirstName = event.detail.value;
        else if (event.target.dataset.id === 'LastName')
            this.accDetails.LastName = event.detail.value;
    }

    handleSelectedBranch(event) {
        console.log('branchId ', event);
        if (event.detail) {
            this.branchId = event.detail;
        } else {
            this.branchId = undefined;
        }
        console.log('this.branchId ', this.branchId);
    }

    handleRemoveSelectedBranch(event){
        if(event.detail)
            this.branchId = undefined;
    }

    checkInputValidity() {
        const allValid = [
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
        return (allValid && allValid2);
    }

    handleSave() {
        console.log('this.accDetails ', this.accDetails);
        console.log('this.accDetails.LastName ', this.accDetails.LastName);
        if (this.checkInputValidity() && this.branchId) {
            this.isLoading = true;
            insertPreLogin().then(result => {
                console.log('preloginId ', result);
                if (result) {
                    this.preloginId = result;
                    insertDirectApplications({ preLogInId: this.preloginId, branchId: this.branchId }).then(result => {
                        console.log('applicationId after insertion ', result);
                        if (result) {
                            this.applicationId = result.appId;
                            this.appName = result.appName;
                            console.log('this.accDetails.LastName ', this.accDetails.LastName);
                            insertApplicant({ salutation: this.accDetails.Salutation, fName: this.accDetails.FirstName, lName: this.accDetails.LastName, appId: this.applicationId }).then(result => {
                                if (result) {
                                    console.log('applicant id ', result);
                                    this.loanAppId = result;
                                    this.isLoading = false;
                                    this.showToast('Success', 'Success', 'Record Saved Successfully.');
                                    this.sendAppDetails();
                                }
                            })
                                .catch(error => {
                                    this.isLoading = false;
                                    this.showToast('Error', 'Error', 'Failed to save record.');
                                    console.log('error in inserting prelogin ', error);
                                    this.saveDisable = false;
                                })
                        }
                    })
                        .catch(error => {
                            this.isLoading = false;
                            this.showToast('Error', 'Error', 'Failed to save record.');
                            console.log('error in inserting application ', error);
                            this.saveDisable = false;
                        })
                }
            })
                .catch(error => {
                    this.isLoading = false;
                    this.showToast('Error', 'Error', 'Failed to save record.');
                    console.log('error in inserting prelogin ', error);
                    this.saveDisable = false;
                })

        }
        else {
            this.showToast('Error', 'error', 'Complete Required Fields');
        }
    }

    handleDirectCancel() {
        const hideDirectEntry = new CustomEvent("hidedirectentry", {
            detail: false
        });
        console.log('hideDirectEntry on cancel ', hideDirectEntry);
        this.dispatchEvent(hideDirectEntry);
    }

    handleDirectSave() {
        const hideDirectEntry = new CustomEvent("hidedirectentrysave", {
            detail: true
        });
        console.log('hideDirectEntry on cancel ', hideDirectEntry);
        this.dispatchEvent(hideDirectEntry);
    }

    sendAppDetails() {
        const getAppName = new CustomEvent("appname", {
            detail: this.appName,
            bubbles: true,
            composed: true
        });
        console.log('dispatch event 4 ', getAppName);
        this.dispatchEvent(getAppName);
        const getAppIdEvent = new CustomEvent("getapplicationid", {
            detail: this.applicationId,
            bubbles: true,
            composed: true
        });
        console.log('dispatch event 1 ', getAppIdEvent);
        this.dispatchEvent(getAppIdEvent);
        const getPreloginIdEvent = new CustomEvent("getpreloginid", {
            detail: this.preloginId,
            bubbles: true,
            composed: true
        });
        console.log('dispatch event 2 ', getPreloginIdEvent);
        this.dispatchEvent(getPreloginIdEvent);
        const getLoanApplicantId = new CustomEvent("getapplicantid", {
            detail: this.loanAppId,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(getLoanApplicantId);
        var loanAppListIds = [];
        loanAppListIds.push(this.loanAppId);
        const getloanapplistid = new CustomEvent("getloanappidlist", {
            detail: loanAppListIds,
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(getloanapplistid);
        this.handleDirectSave();
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

}