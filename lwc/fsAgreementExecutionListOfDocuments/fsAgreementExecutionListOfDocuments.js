import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACKNOWLEDGEMENT_SLIP from '@salesforce/schema/Agreement_Execution_Acknowledgement_Slip__c';
import DOC_TYPE_FIELD from '@salesforce/schema/Agreement_Execution_Acknowledgement_Slip__c.Document_Type__c';
import DOC_CONDITION_FIELD from '@salesforce/schema/Agreement_Execution_Acknowledgement_Slip__c.Document_Condition__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import generateAcknowledgementSlip from '@salesforce/apex/AcknowledgementSlipController.generateAcknowledgementSlip';
import insertAcknowledgementSlipRecords from '@salesforce/apex/AcknowledgementSlipController.insertAcknowledgementSlipRecords';
import getSlipRecords from '@salesforce/apex/AcknowledgementSlipController.getSlipRecords';
import deleteSlipRecord from '@salesforce/apex/AcknowledgementSlipController.deleteSlipRecord';

// import CV_OBJECT from '@salesforce/schema/ContentVersion';
// import DOC_TYPE_FIELD from '@salesforce/schema/ContentVersion.Agreement_Document_Type__c';
// import DOC_CON_FIELD from '@salesforce/schema/ContentVersion.Document_Condition__c';
// import getContentVersionRecords from '@salesforce/apex/AgreementExecutionController.getContentVersionRecordsNew';
// import updateDocuments from '@salesforce/apex/AgreementExecutionController.updateDocuments';

export default class FsAgreementExecutionListOfDocuments extends NavigationMixin(LightningElement) {

    @api applicationId;

    //@track allContentVersionRecord;
    //@track stageName = 'Agreement Execution';
    @track docTypeList;
    @track docConList;
    @track showSpinner = false;
    //@track validationObj = false;
    @track listOfDocs;
    @track isSave = true;
    @track enableSave = true;
    @track maxDate = new Date().toISOString();

    @wire(getObjectInfo, { objectApiName: ACKNOWLEDGEMENT_SLIP })
    acSlipMetadata;

    @wire(getPicklistValues, { recordTypeId: "$acSlipMetadata.data.defaultRecordTypeId", fieldApiName: DOC_TYPE_FIELD })
    docTypePicklistInfo({ data, error }) {
        if (data) {
            console.log('data ', data);
            this.docTypeList = data.values;
        }
        if (error) {
            console.log('Error while getting docType ', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$acSlipMetadata.data.defaultRecordTypeId", fieldApiName: DOC_CONDITION_FIELD })
    docConPicklistInfo({ data, error }) {
        if (data) this.docConList = data.values;
        if (error) console.log('Error while getting docType ', error);
    }

    connectedCallback() {
        this.initData();
        this.getAcknowldgementSlips();
    }

    initData() {
        let listOfDocs = [];
        this.createRow(listOfDocs);
        this.listOfDocs = listOfDocs;
    }

    createRow(listOfDocs) {
        let listOfDOcObject = {};
        if(listOfDocs.length > 0) {
            listOfDOcObject.index = listOfDocs[listOfDocs.length - 1].index + 1;
        } else {
            listOfDOcObject.index = 1;
        }
        listOfDOcObject.Name = null;
        listOfDOcObject.Document_Type__c = null;
        listOfDOcObject.Document_Number__c = null;
        listOfDOcObject.Document_Date__c = null;
        listOfDOcObject.Number_Of_Pages__c = null;
        listOfDOcObject.Document_Condition__c = null;
        listOfDOcObject.Application__c = this.applicationId;
        listOfDOcObject.isNewRow = true;
        listOfDocs.push(listOfDOcObject);
    }

    /*** Adds a new row ***/
    addNewRow() {
        this.enableSave = false;
        this.createRow(this.listOfDocs);
    }

    /*** Removes the selected row ***/
    async removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;
        let isSave = event.target.dataset.saved;
        let recId = event.target.dataset.id;
        console.log('Details ',toBeDeletedRowIndex,' :: ',isSave,' :: ',recId);
        let deleteResult = true;
        if(isSave && recId){
            deleteResult = await this.deleteAcknowledgementSlipRecord(recId);
            console.log('deleteResult ',deleteResult);
        }
        if(deleteResult){
            this.removeSelectedRow(toBeDeletedRowIndex);
            this.showToast('Success','Success','Row deleted successfully.');
        }
        else{
            this.showToast('Error','Error','Unable to delete row.');
        }
    }

    removeSelectedRow(toBeDeletedRowIndex){
        let listOfDocs = [];
        for(let i = 0; i < this.listOfDocs.length; i++) {
            let tempRecord = Object.assign({}, this.listOfDocs[i]); 
            if(tempRecord.index !== toBeDeletedRowIndex) {
                listOfDocs.push(tempRecord);
            }
        }
        for(let i = 0; i < listOfDocs.length; i++) {
            listOfDocs[i].index = i + 1;
        }
        this.listOfDocs = listOfDocs;
        let listSize = 0;
        this.listOfDocs.forEach(element =>{
            if(!element.isNewRow) listSize = listSize + 1;
        });
        if(this.listOfDocs.length === listSize) this.enableSave = true;
        else this.enableSave = false;
        if(listSize === 0) this.isSave = true;
    }

    handleInputChange(event) {
        this.enableSave = false;
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;
        for(let i = 0; i < this.listOfDocs.length; i++) {
            if(this.listOfDocs[i].index === parseInt(index)) {
                this.listOfDocs[i][fieldName] = value;
            }
        }
    }

    checkInputValidity() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return (allValid && allValid2);
    }

    createAcknowledgementSlipRecords() {
        this.showSpinner = true;
        console.log('JSON.stringify(this.listOfDocs) ',JSON.stringify(this.listOfDocs));
        let insertList = [];
        this.listOfDocs.forEach(element =>{
            if(element.isNewRow)
                insertList.push(element);
        });
        console.log('insertList ',insertList);
        if(insertList && !this.checkInputValidity()){
            this.enableSave = false;
            this.showSpinner = false;
            this.showToast('Error', 'Error', 'Complete required fields.');
            return;
        }
        if (insertList && this.checkInputValidity()) {
            this.enableSave = true;
            insertAcknowledgementSlipRecords({
                jsonOflistOfDocs: JSON.stringify(insertList)
            })
                .then(data => {
                    this.initData();
                    this.showToast('Success', 'Success', 'Record Created Successfully.');
                    this.showSpinner = false;
                    this.getAcknowldgementSlips();
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.log(error);
                });
        }
    }

    deleteAcknowledgementSlipRecord(recId){
        return new Promise((resolve, reject) => {
            deleteSlipRecord({ recId: recId }).then(result => {
                console.log('delete Result ', result);
                resolve(result);
            })
                .catch(error => {
                    console.log('delete result error ', error);
                    reject(error);
                })
        });
    }

    @api getAcknowldgementSlips(){
        this.enableSave = true;
        getSlipRecords({appId : this.applicationId}).then(result =>{
            if(result.length){
                this.isSave = false;
                this.listOfDocs = result;
            }
        })
        .catch(error =>{
            console.log('Error ',error);
        })
    }

    generateDocument(event){
        this.showSpinner = true;
        generateAcknowledgementSlip({recordId : this.applicationId})
        .then(result =>{
            this.showSpinner = false;
            if(result === 'Success'){
                this.showToast('Success','Success','Acknowledgement Slip Generated Successfully.');
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/apex/AcknowledgementSlipVf' + '?applicationId=' + this.applicationId
                    }
                }).then(generatedUrl => {
                    window.open(generatedUrl);
                });
            }
            else{
                this.showToast('Error','Error','Error while generating Ackowledgement Slip.');
            }
        })
        .catch(error =>{
            this.showSpinner = false;
            this.showToast('Error','Error','Error while generating Ackowledgement Slip.');
        })
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

    // connectedCallback() {
    //     this.getContentVersionRecords();
    // }


    // handleValueChange(event) {
    //     let indexNumber = event.currentTarget.dataset.id;
    //     console.log('indexNumber= ', indexNumber);
    //     let tempData = JSON.parse(JSON.stringify(this.allContentVersionRecord));
    //     tempData[indexNumber].cv[event.target.name] = event.target.value;
    //     this.allContentVersionRecord = JSON.parse(JSON.stringify(tempData));
    // }

    // @api getContentVersionRecords() {
    //     this.showSpinner = true;
    //     this.allContentVersionRecord = undefined;
    //     getContentVersionRecords({ parentId: this.applicationId, stage: this.stageName }).then((result) => {
    //         this.validationObj = true;
    //         this.showSpinner = false;
    //         this.allContentVersionRecord = JSON.parse(JSON.stringify(result));
    //         if(this.allContentVersionRecord && this.allContentVersionRecord.length ){
    //             this.allContentVersionRecord.forEach(currentItem => {
    //                 if(!(currentItem.cv.Agreement_Document_Type__c && currentItem.cv.Document_Condition__c && 
    //                 currentItem.cv.Number_of_Pages__c != undefined && currentItem.cv.Number_of_Pages__c != null && currentItem.cv.Number_of_Pages__c != '')){
    //                     this.validationObj = false;
    //                 }
    //             });
    //         }

    //         this.dispatchEvent(new CustomEvent('docEntryValidation', {
    //             detail: this.validationObj
    //         }));
    //         console.log('getContentVersionRecords result #### ', result);
    //     }).catch((err) => {
    //         console.log('getContentVersionRecords Error #### ', err);
    //     });
    // }

    // handleSave() {
    //     console.log('handle Save = ', JSON.parse(JSON.stringify(this.allContentVersionRecord)));
    //     this.showSpinner = true;    
    //     updateDocuments({ strData: JSON.stringify(this.allContentVersionRecord) }).then((result) => {
    //         console.log('Result updateDocuments= ', result);
    //         if(result == 'success'){
    //             this.getContentVersionRecords();
    //             this.showToast('Success','Success','Record Saved Successfully!!');
    //         }
    //         this.showSpinner = false;
    //     }).catch((err) => {
    //         console.log('Error in updateDocuments= ', err);
    //         this.showSpinner = false;
    //     });
    // }
}