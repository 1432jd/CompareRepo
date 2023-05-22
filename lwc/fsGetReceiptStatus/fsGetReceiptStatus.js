import { LightningElement,track,api,wire } from 'lwc';
import getReceiptStatus from '@salesforce/apex/fsGetReceiptSyncError.getReceiptStatus';
import { getRecord } from 'lightning/uiRecordApi';
export default class FsGetReceiptStatus extends LightningElement {

@api recordId;
@track status='';
@track showApprovalMsg='';
@track showRejectionlMsg='';


    connectedCallback() {
        this.getStatus();
    }

   getStatus(){
        getReceiptStatus({ recordId: this.recordId }).then((result) => {
           if(result){
               this.status=result;
               if(this.status.includes('Approved')){
                this.showApprovalMsg=result;
                this.showRejectionlMsg=''
               }else if(this.status){
                   this.showApprovalMsg='';
                   this.showRejectionlMsg=result;
               }
           }else{
                    this.showApprovalMsg='';
                    this.showRejectionlMsg='';
            }
           
        }).catch((err) => {
           console.log(error);
        });
   }

   @wire(getRecord, { recordId: '$recordId', fields: [ 'Receipt__c.Name', 'Receipt__c.Sync_Error__c' ] })
    getaccountRecord({ data, error }) {
        console.log('accountRecord => ', data, error);
        if (data) {
            this.getStatus();
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); 
        }
    }
}