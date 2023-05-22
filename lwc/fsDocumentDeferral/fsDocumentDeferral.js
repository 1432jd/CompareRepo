import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import BusinessDate from '@salesforce/label/c.Business_Date';
import NAME from '@salesforce/schema/Application__c.Name';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import saveRecord from '@salesforce/apex/FsDocumentDefferal.saveRecord';
import getSectionContent from '@salesforce/apex/FsDocumentDefferal.getSectionContent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FsDocumentDeferral extends LightningElement {
    @api recordId;
    @api recordIds;
    @track todaysDate = BusinessDate;
    @track applicationName;
    @track lastLoginDate;
    @track fieldsContent;
    @track objectIdMap = { 'ContentVersion': '' };
    @track isSpinnerActive = false;

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
            this.lastLoginDate = result;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    connectedCallback() {
        this.handleGetLastLoginDate();
        console.log('recordId', this.recordId);
        this.getSectionPageContent('');
    }
    getSectionPageContent(recId) {
        try {
            getSectionContent({ recordIds: recId, metaDetaName: 'fs_Document_Deferral' })
                .then(result => {
                    console.log('data ### ', JSON.parse(result.data));
                    this.fieldsContent = result.data;
                })
                .catch(error => {
                    console.log(error);
                });
        } catch (error) {
            console.log(error);
        }
    }
    changedFromChild(event) {
        console.log('changedFromChild ### ', JSON.stringify(event.detail));
    }
    handleSave() {
        try {
            var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
            if (data.length > 0) {
                this.isSpinnerActive = true;
                for (var i = 0; i < data.length; i++) {
                    if (this.recordIds == null) {
                        data[i].Id = this.objectIdMap[data[i].sobjectType];
                    }
                    console.log('data 2## ', JSON.stringify(data));
                    saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                        .then(result => {
                            this.showToast('Success', 'Success', 'Record Save Successfully.');
                            this.isSpinnerActive = false;
                        })
                        .catch(error => {
                            console.log(error);
                            this.showToast('Error', 'Error', JSON.stringify(error));
                        });
                }
            } else {
                this.showToast('Error', 'Error', 'Complete Required Field(s).');
            }
        } catch (error) {
            console.log('Error',error);
        }
    }
   

    handleCancel() {
        console.log('handle cancel called ###');
        this.fieldsContent = {};
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