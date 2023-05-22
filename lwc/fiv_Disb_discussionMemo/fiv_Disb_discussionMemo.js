import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import savePdf from '@salesforce/apex/FS_DisbursalMemoController.saveDisbursalMemoPDF';
// Added By Ajay Kumar ::: Date : 27/11/2022
import checkDisbursalMemo from '@salesforce/apex/FS_DisbursalMemoController.checkDisbursalMemoPdf';


export default class Fiv_Disb_discussionMemo extends NavigationMixin(LightningElement) {
    @api applicationId;
    @api stageName = '';
    
    get buttonLabel()
    {
        return (this.stageName == 'Process Credit' || this.stageName == 'Approval Credit' ) ? 'Generate Discussion Memo': 'Generate Disbursal Memo';
    }

    _applicationId = '';
    _stageName = '';

    isModalOpen = false;
    showSpinner = false;
    siteURL = '';

    closeModal() {
        this.isModalOpen = false;
    }

    handleSavePdf() {
        console.log('Current StageName', this.stageName);
        this.showSpinner = true;
        console.log('before application Id >>>',this.applicationId);
        if (!this.applicationId) {
          //  this.applicationId = 'a030w000008HwIQAA0';
        }
        var pageName = this.stageName === 'Process Credit' || this.stageName === 'Approval Credit'?'fs_disbursalMemo':'Disbursement_MemoVfPage';
        this.siteURL = '/apex/'+pageName+'?id='+this.applicationId;
        this._applicationId = this.applicationId;
        this._stageName = this.stageName;
        console.log('save pdf called ', this.applicationId);
        savePdf({ applicationId: this._applicationId, stageName: this._stageName }).then(result => {
          /*  console.log('Search Result ', result);
            console.log('save df called successfully');

            var getResult = result;
            console.log('result of memeo is >>>',result);
            if(result == 'Error'){
                this.showNotification('ERROR', 'Loan number not generated yet', 'error'); //incase if any apex exception happened it will show notification
                this.showSpinner = false;
            }else if(result !=''){
                this.isModalOpen = true;
                this.showSpinner = false;
            }*/
                this.isModalOpen = true;
                this.showSpinner = false;
            
        }).catch(error => {
            console.log('error occured', error);
        });
    }

    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    ////// Added By Ajay Kumar to check if Disbursal Memo has been created for the particular stage... 
    ///// Date :- 27/11/2022
    @api checkDisbursalMemoCreation() {
        checkDisbursalMemo({ applicationId: this.applicationId, stageName: this.stageName })
            .then(result => {
                console.log('checkDisbursalMemoCreation ::', result);
                if(result != null)
                this.dispatchEvent(new CustomEvent("checkmemoexistence", { detail: result }));
            })
            .catch(err => {
                console.log('checkDisbursalMemoCreation In Error ::', err);
            })
    }
}