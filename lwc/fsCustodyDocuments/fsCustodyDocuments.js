import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import getUploadedRecords from '@salesforce/apex/fsGenericUploadDocumentsController.getUploadedRecords';
import getAdditionalRecords from '@salesforce/apex/FsCustodyController.getAdditionalRecords';
import getVDCDocuments from '@salesforce/apex/FsCustodyController.getVDCDocuments';
import updateDocuments from '@salesforce/apex/FsCustodyController.updateDocuments';
import updateDeferralDocument from '@salesforce/apex/FsCustodyController.updateDeferralDocument';
import DOCUMENT_CONDITION_FIELD from '@salesforce/schema/ContentVersion.Document_Condition__c';
import DOCUMENT_TPYE_FIELD from '@salesforce/schema/ContentVersion.Agreement_Document_Type__c';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
export default class FsCustodyDocuments extends NavigationMixin(LightningElement) {
    @api applicationId;
    @track uploadedDocData;
    @track addtionalDocuments;
    @track documentConditionPicklistOption;
    @track documenrTypePicklistOption;
    @track isSpinnerActive = false;


    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: DOCUMENT_CONDITION_FIELD })
    picklistDocumentConditionValues({ error, data }) {
        if (data) {
            this.documentConditionPicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: DOCUMENT_TPYE_FIELD })
    picklistDocumentTypeValues({ error, data }) {
        if (data) {
            this.documenrTypePicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    connectedCallback() {
        console.log('application Id', this.applicationId);
        this.getUploadedRecords();
    }

    handleActive(event) {
        this.tabName = event.target.value;
        console.log('this.tabName ### ', this.tabName);
        if (this.tabName === 'View Documents') {
            this.getUploadedRecords();
            this.getAdditionalRecords();
        }
    }
    getUploadedRecords() {
        getVDCDocuments({ applicationId: this.applicationId })
            .then(result => {
                console.log('uploaded document :: ', result);
                this.uploadedDocData = result;
            })
            .catch(error => {

            })
    }

    getAdditionalRecords() {
        getAdditionalRecords({ applicationId: this.applicationId })
            .then(result => {
                console.log('  Additional  uploaded document :: ', JSON.stringify(result));
                this.addtionalDocuments = result;
            })
            .catch(error => {
                console.log('getting error in ', error);
            })
    }

    viewDocument(event) {
        var contentDocumentId = event.target.dataset.index;
        if(contentDocumentId){
            console.log('contentDocumentId ### ', contentDocumentId);
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: contentDocumentId
                }
            })
        }
    }

    handleOptionChange(event) {
        var rowNo = event.target.getAttribute("data-row-index");
        var documentType = event.target.getAttribute("data-document-type");
        if (documentType === 'Req-Document') {
            this.uploadedDocData[rowNo][event.target.name] = event.target.value;
            console.log('Document Updated', JSON.stringify(this.uploadedDocData[rowNo]));
        }
        if (documentType === 'Add-Document') {
            this.addtionalDocuments[rowNo][event.target.name] = event.target.value;
            console.log('Document Updated', JSON.stringify(this.addtionalDocuments[rowNo]));
        }
    }
    handleSave() {
        var updatedDocuments = [];
        this.isSpinnerActive = true
        this.uploadedDocData.forEach(element => {
            if (element.Document_Condition__c && element.Document_Type__c) {
                this.updateDocument(element);
                this.toast('Success', 'success', 'Document Updated Successfully');
                this.isSpinnerActive = false;
            }
        });
        this.addtionalDocuments.forEach(currentItem => {
            if (currentItem.Document_Condition__c && currentItem.Agreement_Document_Type__c) {
                updatedDocuments.push({ Id: currentItem.Id, Document_Condition__c: currentItem.Document_Condition__c, Agreement_Document_Type__c: currentItem.Agreement_Document_Type__c });
            }
        });
        if(updatedDocuments && updateDocuments.length){
            updateDocuments({updatedDocument : JSON.stringify(updatedDocuments)})
            .then(result => {
                console.log('Updated All Documents ');
                this.toast('Success', 'success', 'Document Updated Successfully');
                this.isSpinnerActive = false;
            }).catch(error => {
                console.log('error in updateDocuments', error);
            })
        }
    }

    updateDocument(element){
        console.log('Element ', element);
        updateDeferralDocument({data : JSON.stringify(element)})
        .then(result =>{
            console.log('Result ', result);
        }).catch(error => {
            console.log('Error in updateDeferralDocument', error);
        })
    }
    toast(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: variant,
            message: message
        })
        this.dispatchEvent(toastEvent)
    }

    @api 
    requiredDocumentValidation(){
        var validations = [];
        this.uploadedDocData.forEach(element => {
            if(!element.cv.Agreement_Document_Type__c || !element.cv.Document_Condition__c){
                validations.push('Complete Required Field Of '+element.Document_Name__c+' In Documents Tab');
            }
        });
        this.addtionalDocuments.forEach(element => {
            if(!element.Agreement_Document_Type__c || !element.Document_Condition__c){
                validations.push('Complete Required Field Of '+element.Document_Name__c+' In Documents Tab');
            }
        })
        return validations;
    }
}