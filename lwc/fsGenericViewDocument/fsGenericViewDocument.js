import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getUploadedRecords from '@salesforce/apex/FS_DocumentUploadController.getUploadedRecords';
import getHackURL from '@salesforce/apex/FS_DocumentUploadController.getHackURL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FsGenericViewDocument extends NavigationMixin(LightningElement) {
    @api recordId;
    @api stageName;
    @track uploadedDocData;
    @track addtionalDocuments;

    connectedCallback() {
        this.getUploadedRecords();
    }

    renderedCallback() {
        this.getUploadedRecords();
    }

    getUploadedRecords() {
        getUploadedRecords({ parentId: this.recordId, stageName : this.stageName})
            .then(result => {
                this.uploadedDocData = JSON.parse(JSON.stringify(result.uploadedDocuments));
                this.addtionalDocuments = JSON.parse(JSON.stringify(result.additionalDocuments));
            })
            .catch(error => {

            })
    }

    downLoadDocuments() {
        var contentDocumentIds = [];
        var chechboxes = this.template.querySelectorAll('lightning-input');
        chechboxes.forEach(currentItem => {
            if ((currentItem.name === 'RequiredCheckBox' || currentItem.name === 'AddtionalCheckBox') && currentItem.checked) {
                contentDocumentIds.push(currentItem.dataset.index);
            }
        });
        if (contentDocumentIds && contentDocumentIds.length) {
            this.isSpinnerActive = true;
            getHackURL({ contentDocumentIds: JSON.stringify(contentDocumentIds) })
                .then(result => {
                    if (result) {
                        console.log('HackURL', result);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__webPage',
                            attributes: {
                                url: result
                            }

                        }, false);
                        chechboxes.forEach(currentItem => {
                            if (currentItem.checked) {
                                currentItem.checked = false;
                            }
                        })
                        this.isSpinnerActive = false;
                    }
                });
        }
        else {
            this.toast('Information', 'info', 'Select atleast one document to download');
        }
    }

    handleDownloadCheckbox(event) {
        var inputFields = this.template.querySelectorAll('lightning-input');
        if (event.target.name === 'RequiredDocumentCheckbox') {
            inputFields.forEach(currentItem => {
                if (currentItem.name === 'RequiredCheckBox' && !currentItem.disabled) {
                    currentItem.checked = event.target.checked ? true : false;
                }
            });
        }
        if (event.target.name === 'AddtionalDocumentCheckbox') {
            inputFields.forEach(currentItem => {
                if (currentItem.name === 'AddtionalCheckBox' && !currentItem.disabled) {
                    currentItem.checked = event.target.checked ? true : false;
                }
            });
        }
        if (event.target.name === 'RequiredCheckBox' || event.target.name === 'AddtionalCheckBox') {
            var additionaCheckboxes = 0;
            var requiredCheckboxes = 0
            var reqSelectedCheckbox = 0
            var addSelectedCheckbox = 0;
            inputFields.forEach(element => {
                if (element.name === 'RequiredCheckBox' && element.checked) {
                    reqSelectedCheckbox++;
                }
                if (element.name === 'RequiredCheckBox') {
                    requiredCheckboxes++;
                }
                if (element.name === 'AddtionalCheckBox' && element.checked) {
                    addSelectedCheckbox++;
                }
                if (element.name === 'AddtionalCheckBox') {
                    additionaCheckboxes++;
                }
            });
            if (reqSelectedCheckbox >= 0 && requiredCheckboxes >= 0 && addSelectedCheckbox >= 0 && additionaCheckboxes >= 0) {
                inputFields.forEach(element => {
                    if (reqSelectedCheckbox === requiredCheckboxes && element.name === 'RequiredDocumentCheckbox') {
                        element.checked = true
                    }
                    else if (reqSelectedCheckbox != requiredCheckboxes && element.name === 'RequiredDocumentCheckbox') {
                        element.checked = false
                    }
                    if (addSelectedCheckbox === additionaCheckboxes && element.name === 'AddtionalDocumentCheckbox') {
                        element.checked = true;
                    }
                    else if (addSelectedCheckbox != additionaCheckboxes && element.name === 'AddtionalDocumentCheckbox') {
                        element.checked = false;
                    }
                });
            }
        }
    }

    viewDocument(event) {
        var contentDocumentId = event.target.dataset.index;
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

    toast(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: variant,
            message: message
        })
        this.dispatchEvent(toastEvent)
    }
}