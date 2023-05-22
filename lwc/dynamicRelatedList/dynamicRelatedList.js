import { LightningElement, api, track } from 'lwc';
import returnRelatedRecords from '@salesforce/apex/FS_DynamicRelatedListCtrl.returnRelatedRecords';

const rowAction = [{
    //label: 'Edit',
    type: 'button-icon',
    fixedWidth: 50,
    typeAttributes: {
        iconName: 'utility:preview',
        title: 'View',
        variant: 'border-filled',
        alternativeText: 'View',
        name: 'view'
    }
}];
export default class DynamicRelatedList extends LightningElement {
    @api recordId;
    @api metadataName;
    @api userQuery;
    @api title;
    @api queryParameters;

    @track relatedRecords;
    @track showSpinner;
    @track objectAPIName;
    @track selectedRecordId;
    @track showModal = false;
    @track rowAction = rowAction;


    connectedCallback() {
        console.log('DynamicRelatedList Record Id = ', this.recordId, this.metadataName, this.userQuery);
        this.showSpinner = true;
        this.getRelatedRecords();
    }

    handleTableSelection(evt) {
        var data = evt.detail;
        this.selectedRecordId = data.recordData.Id;
        this.showModal = true;
    }

    hideModal() {
        this.showModal = false;
        this.selectedRecordId = undefined;
    }

    getRelatedRecords() {
        console.log('getRelatedRecords called');
        this.relatedRecords = undefined;
        returnRelatedRecords({ applicationId: this.recordId, metadataName: this.metadataName, query: this.userQuery, queryParameters: this.queryParameters }).then((result) => {
            console.log('Result in returnRelatedRecords = ', result);
            this.showSpinner = false;
            this.relatedRecords = result;
            this.objectAPIName = result.objectAPIName;
        }).catch((err) => {
            this.showSpinner = false;
            console.log('Error in returnRelatedRecords = ', err);
        });
    }
}