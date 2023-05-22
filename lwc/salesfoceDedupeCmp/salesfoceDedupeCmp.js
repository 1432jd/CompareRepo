import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDedupeRecords from '@salesforce/apex/FS_SalesforceDedupeCtrl.getDedupeRecords';
import getApplicantData from '@salesforce/apex/FS_SalesforceDedupeCtrl.getApplicantData';
export default class SalesfoceDedupeCmp extends LightningElement {
    currentApplicantId;

    @api
    get loanApplicantId() {
        return this.currentApplicantId;
    }

    set loanApplicantId(value) {
        console.log('value Set= ', value);
        this.currentApplicantId = value;
        this.getRecords(false);
    }
    @track currentCustomer=[];
    @track isSpinner;
    @track showDedupeModal=false;
    @track dedupeRecords;
    @track showLoader = false;
    @track showInnerLoader = false;
    @track showModal = false;
    @track ApplicationId;

    handleLoanDetails(event) {
        console.log('handleLoanDetails = ', event.target.dataset.id);
        let currentIndex = event.target.dataset.id;
        let recordId = this.dedupeRecords[currentIndex].applicant.Application__c;
        this.ApplicationId = recordId;
        this.showModal = true;
        this.showInnerLoader = true;
        let ref = this;
        setTimeout(() => {
            ref.showInnerLoader = false;
        }, 500);
    }

    showHideModal() {
        this.showModal = !(this.showModal);
        if (!this.showModal) {
            this.ApplicationId = undefined;
        }
    }



    handleCustomerDetails(event){
           this.isSpinner  = true;
           let currentApplicant = event.target.dataset.id;
           let custId = event.target.dataset.customerid;
           console.log('custid is >>>',custId);
           console.log('this.currentApplicantId is >>>',currentApplicant);
           this.getDedupeApptData(currentApplicant,custId);
    }

    getDedupeApptData(currentcifId,custId){
        this.currentCustomer = [];
        getApplicantData({applicantId: custId,CustomerNumber :  currentcifId}).then((result) => { 
            console.log('result is cyst>>',result);   
            if(result!=null){
                this.currentCustomer = result;
                console.log('this.currentCustomer is cyst>>',this.currentCustomer);
                this.showDedupeModal = true;
                this.isSpinner = false;
            }else{ 
                this.currentCustomer = [];
                this.showDedupeModal = false;
                this.showNotification('WARNING', 'No record found', 'warning');
                this.isSpinner=false;
            }
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getLastLoginDate= ', err);
            console.log('cifDedupeData', this.cifDedupeData);
        });
    }

    closeModal(event) {
        this.showDedupeModal = false;
    }

    getRecords(check) {
        this.showLoader = true;
        getDedupeRecords({ recordId: this.loanApplicantId }).then((result) => {
            console.log('getDedupeRecords = ', result);
            this.showLoader = false;
            if (result && result.length) {
                this.dedupeRecords = JSON.parse(JSON.stringify(result));
            }
        }).catch((err) => {
            console.log('Error in getDedupeRecords = ', err);
            this.showLoader = false;
        });
    }

    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
}