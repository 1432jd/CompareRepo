import { LightningElement, api, track } from 'lwc';

export default class FeeInsuranceParentPCScreen extends LightningElement {
    @api recordId;
    @api preLogInId;
    @api appName;
    @api primaryApplicantName;
    @api stageName;
    @track feeList = true;
    @track isLoading = false;
    @track receiptWrapper = { hasReceipt: false, allApproved: false, pendingReceiptList: [], lengthOfDirectRec: 0, existingFeeCodeOption: [] };

    @api getReceipt() {
        this.template.querySelector('c-prelogin-receipt-screen').getAllReceiptData();
    }

    @api showFee(){
        this.isLoading = true;
        //this.feeList = false;
        setTimeout(() => {
            if(this.template.querySelector('c-fee-creation-screen-2')){
                this.feeList = false;
                this.template.querySelector('c-fee-creation-screen-2').getFeeCreationRecords();
            }
        }, 300);       
    }

    refreshFee(event){
        console.log('parag ',event.detail);
        this.isLoading = false;
        this.feeList = true;
    }


    getReceiptPendingList(event) {
        this.receiptWrapper.hasReceipt = event.detail.hasReceipt;
        this.receiptWrapper.allApproved = event.detail.allApproved;
        this.receiptWrapper.pendingReceiptList = event.detail.pendingReceiptList;
        this.receiptWrapper.lengthOfDirectRec = event.detail.lengthOfDirectRec;
        this.receiptWrapper.existingFeeCodeOption = event.detail.existingFeeCodeOption;
        const receiptEvent = new CustomEvent("getreceiptevent", {
            detail: this.receiptWrapper,
            bubbles: true,
            composed: true
        });
        console.log('dispatch receiptEvent ', JSON.stringify(receiptEvent));
        this.dispatchEvent(receiptEvent);

        this.feeList = false;
         
         if(this.template.querySelector('c-fee-creation-screen-2')){
             
            this.template.querySelector('c-fee-creation-screen-2').getFeeCreationRecords();
         //this.feeList = true;
         }
         //this.feeList = false;
         if(this.template.querySelector('c-fee-type-insurance-creation')){
            this.template.querySelector('c-fee-type-insurance-creation').getInsuranceRecords();
         
         }
         this.feeList = true;
    }
    
    getRecFeeCodeChange(event) {
        this.feeList = false;
        console.log('fee code change parent', this.template.querySelector('c-prelogin-receipt-screen'));
        this.template.querySelector('c-prelogin-receipt-screen').getFeeCodeChange();
        this.feeList = true;
        this.template.querySelector('c-prelogin-receipt-screen').handleResetReceipt();
    }

    
}