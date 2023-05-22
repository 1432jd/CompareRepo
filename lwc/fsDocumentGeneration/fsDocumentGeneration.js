import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import { getRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Application__c.Name';
import BusinessDate from '@salesforce/label/c.Business_Date';


export default class FsDocumentGeneration extends NavigationMixin(LightningElement){
    @api recordId;

    @track showSpinner = false;
    @track applicationName;
    @track lastLoginDate;
    @track todaysDate = BusinessDate;
    @track tabName = 'Doc_Gen';
    loadAll = false;
    @track button = [
        {
            name: 'Close',
            label: 'Close',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ];


    connectedCallback(){
        this.handleGetLastLoginDate();
        setTimeout(() => {
            this.template.querySelector('c-fs-aggrement-execution-d-g').getAllApplicant();
        }, 300);
        console.log('appId >> ', this.recordId);
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
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
            window.location.replace('/'+this.recordId);
        }
    }


}