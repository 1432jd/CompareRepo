import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Application__c.Name';
import BusinessDate from '@salesforce/label/c.Business_Date';
import APPLICANT_ID from '@salesforce/schema/Loan_Applicant__c.Id';
import IS_KYC_VERIFIED from '@salesforce/schema/Loan_Applicant__c.Is_KYC_Verified__c';
import VERIFIED_BY from '@salesforce/schema/Loan_Applicant__c.Verified_by__c';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import getPendingKYCVerificationApplicants from '@salesforce/apex/FetchDataTableRecordsController.getPendingKYCVerificationApplicants';
import insertApplicationHistory from '@salesforce/apex/KYCAPIController.insertApplicationHistory';

export default class KYCVerificationByBM extends NavigationMixin(LightningElement) {

    @api recordId;

    @track accData = [];
    @track isAccDataArrived = false;
    @track applicationName;
    @track lastLoginDate;
    @track todaysDate = BusinessDate;
    @track button = [
        {
            name: 'Close',
            label: 'Close',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ];
    @track accRowAction = [
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:asset_audit',
                title: 'Validate KYC',
                variant: 'border-filled',
                alternativeText: 'Validate KYC',
                name: 'validate'
            }
        }
    ];


    @wire(getRecord, { recordId: '$recordId', fields: [NAME] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    connectedCallback() {
        this.handleGetLastLoginDate();
        console.log('appId >> ', this.recordId);
        this.getAllApplicants();
    }

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    rowselectionevent(event) {
        var detail = event.detail;
        if (detail === 'Close') {
            window.location.replace('/' + this.recordId);
        }
    }

    getAllApplicants() {
        console.log('get Acc data called!!', this.recordId);
        this.isAccDataArrived = false;
        this.isSpinnerActive = true;
        getPendingKYCVerificationApplicants({ applicationId: this.recordId })
            .then(result => {
                this.accData = [];
                this.accData = result;
                this.isAccDataArrived = true;
                this.isSpinnerActive = false;
            })
            .catch(error => {
                this.isSpinnerActive = false;
                console.log('Error In Get ACC Data ', error);
            })
    }

    handleSelectedApplicant(event) {
        console.log('on selected applicant ', event);
        console.log('Verify KYC called #### ', JSON.stringify(event.detail));
        var recordData = event.detail.recordData;
        console.log('recordData ', recordData);
        var loanAppId = recordData.Id;
        console.log('loanAppId ', loanAppId);
        const isKYCVerified = recordData.Is_KYC_Verified__c;
        const kyc_Id = recordData.KYC_Id_1__c;
        console.log('recordData.Application__c ', recordData.Application__c);
        if (event.detail.ActionName === 'validate') {
            if (!isKYCVerified && kyc_Id) {
                this.isSpinnerActive = true;
                const fields = {};
                fields[APPLICANT_ID.fieldApiName] = loanAppId;
                fields[IS_KYC_VERIFIED.fieldApiName] = true;
                fields[VERIFIED_BY.fieldApiName] = 'BM Verified';
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.getAllApplicants();
                    insertApplicationHistory({applicationId : this.recordId}).then(res=>{}).catch(err=>{console.log(err)})
                    this.isSpinnerActive = false;
                    this.showToast('Success', 'Success', 'KYC Verified Successfully');
                })
                    .catch(error => {
                        console.error('ERROR ', error);
                        this.isSpinnerActive = false;
                        this.showToast('Error', 'Error', 'KYC Verification Failed, Contact System Admin');
                    })
            }
            else if (isKYCVerified) {
                this.showToast('Error', 'Error', 'KYC Already Verified!!');
            }
            else {
                this.showToast('Error', 'Error', 'KYC Id Does Not Exist!!');
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

}