import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExistingFeeTypeMaster from '@salesforce/apex/DynamicFeeMasterCreationController.getExistingFeeTypeMaster';
import getExistingFeeValueMaster from '@salesforce/apex/DynamicFeeMasterCreationController.getExistingFeeValueMaster';
import insertFeeValueMaster from '@salesforce/apex/DynamicFeeMasterCreationController.insertFeeValueMaster';

export default class DynamicRecordCreationRows extends NavigationMixin(LightningElement) {

    @track FeeTypeMasterList;
    @track FeeValueMasterList;

    @track FeeTypecolumns = [
        { label: 'Fee Code', fieldName: 'Fee_Type_Code__c' },
        { label: 'Description', fieldName: 'Description__c'},
        { label: 'Applicable on', fieldName: 'Value__c'},
        { label: 'Type', fieldName: 'Fee_Type__c'},
        { label: 'Fee Amount', fieldName: 'Amount__c'},
        { label: 'Tax Amount', fieldName: 'Amount__c'},
        { label: 'Total Fee', fieldName: 'Amount__c'},
        { label: 'Stage Due', fieldName: 'Stage_Due__c'},
        { label: 'Repayment Type', fieldName: 'Repayment_of_Fee__c'},
        { label: 'Fee Collection', fieldName: 'Description__c'}
    ];

    @track FeeValuecolumns = [
        { label: 'Fee Type Master', fieldName: 'Fee_Type_Master__c' },
        { label: 'Fee Type Code', fieldName: 'Fee_Type_Code__c'},
        { label: 'Fee Type', fieldName: 'Fee_Type__c'},
        { label: 'Description', fieldName: 'Description__c'},
        { label: 'Amount', fieldName: 'Amount__c'},
        { label: 'Floor', fieldName: 'Floor__c'},
        { label: 'Cap', fieldName: 'Cap__c'},
        { label: 'Range', fieldName: 'Range__c'},
        { label: 'Max waiver amount without Approval', fieldName: 'Max_waiver_amount_without_Approval__c'}
    ];

    @wire (getExistingFeeTypeMaster) wiredFeeTypeMasters({data, error}){
        if (data) {
            this.FeeTypeMasterList = data;
            console.log(data); 
        } else if (error) {
            console.log(error);
        }
    }

    @wire (getExistingFeeValueMaster) wiredFeeValueMasters({data, error}){
        if (data) {
            this.FeeValueMasterList = data;
            console.log(data); 
        } else if (error) {
            console.log(error);
        }
    }

    @track listOfAccounts;
    @track listOfFeeValueMasters;

    connectedCallback() {
        this.initData();
    }

    initData() {
        let listOfFeeValueMasters = [];
        this.createRow(listOfFeeValueMasters);
        this.listOfFeeValueMasters = listOfFeeValueMasters;
    }

    createRow(listOfFeeValueMasters) {
        let accountObject = {};
        if(listOfFeeValueMasters.length > 0) {
            accountObject.index = listOfFeeValueMasters[listOfFeeValueMasters.length - 1].index + 1;
        } else {
            accountObject.index = 1;
        }
        accountObject.Name = null;
        accountObject.Website = null;
        accountObject.Phone = null;
        listOfFeeValueMasters.push(accountObject);
    }

    /**
     * Adds a new row
     */
    addNewRow() {
        this.createRow(this.listOfFeeValueMasters);
    }

    /**
     * Removes the selected row
     */
    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;

        let listOfFeeValueMasters = [];
        for(let i = 0; i < this.listOfFeeValueMasters.length; i++) {
            let tempRecord = Object.assign({}, this.listOfFeeValueMasters[i]); //cloning object
            if(tempRecord.index !== toBeDeletedRowIndex) {
                listOfFeeValueMasters.push(tempRecord);
            }
        }

        for(let i = 0; i < listOfFeeValueMasters.length; i++) {
            listOfFeeValueMasters[i].index = i + 1;
        }

        this.listOfFeeValueMasters = listOfFeeValueMasters;
    }

    /**
     * Removes all rows
     */
    removeAllRows() {
        let listOfFeeValueMasters = [];
        this.createRow(listOfFeeValueMasters);
        this.listOfFeeValueMasters = listOfFeeValueMasters;
    }

    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        for(let i = 0; i < this.listOfFeeValueMasters.length; i++) {
            if(this.listOfFeeValueMasters[i].index === parseInt(index)) {
                this.listOfFeeValueMasters[i][fieldName] = value;
            }
        }
    }

    createFeeValues() {
        insertFeeValueMaster({
            jsonOfFeeValueMaster: JSON.stringify(this.listOfFeeValueMasters)
        })
        .then(data => {
            this.initData();
            let event = new ShowToastEvent({
                message: "Accounts successfully created!",
                variant: "success",
                duration: 2000
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            console.log(error);
        });
    }

}