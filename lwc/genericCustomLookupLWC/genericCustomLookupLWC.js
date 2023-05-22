import {LightningElement, track, wire, api} from "lwc";
import getAllRecords from "@salesforce/apex/LwcLookupController.getAllRecords";
import getFilterRecords from "@salesforce/apex/LwcLookupController.getFilterRecords";

export default class GenericCustomLookupLWC extends LightningElement {

    @track recordsList;
    @track searchKey = "";
    @api selectedValue;
    @api selectedRecordId;
    @api objectApiName;
    @track iconName = 'standard:account';
    @api lookupLabel;
    @track message;
    @api keyFieldAPI;
    @api searchField;
    @track filteredList;
    @api isRequired;
    @api disabled;

    @track recordId;
    @track className = 'slds-form-element';
    @track isErrorMsgOnUI = false;

    @api
    get predefinedId() {
        return this.recordId;
    }

    set predefinedId(value) {
       this.recordId = value;
        if (!this.recordId) {
            this.removeRecordOnLookup();
        }
       this.connectedCallback();
    }

    @api
    validate() {
        if (this.isRequired !== true || (this.isRequired === true && !this.isValueNullOrBlank(this.selectedValue))) {
            return {
                isValid: true
            };
        } else {
            this.className = 'slds-form-element slds-has-error';
            this.isErrorMsgOnUI = true;
            return {
                isValid: false,
                errorMessage: 'Please enter some valid input. Input is not optional.'
            };
        }
    }

    isValueNullOrBlank(value){
        if(value !== null && value !== undefined && value.trim().length > 0){
            return false;
        }else{
            return true;
        }
    }

    connectedCallback() {
        console.log('getAllRecords')
        getAllRecords({
            objectName: this.objectApiName,
            column: this.searchField,
            keyFieldAPI: this.keyFieldAPI,
            selectedRecordId: this.recordId
        })
        .then((result) => {
            if (result.length === 0) {
                this.recordsList = [];
                this.message = "No Records Found";
            } else {
                this.recordsList = result;
                if (this.recordId !== undefined && this.recordId !== null && this.recordId.trim().length > 0) {
                    this.selectedValue = this.recordsList[0][this.searchField];
                    this.selectedRecordId = this.recordsList[0][this.keyFieldAPI];
                }
                this.message = "";
            }
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.recordsList = undefined;
        });
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  this.selectedRecordId});
        this.dispatchEvent(valueSelectedEvent);
    }

    handleKeyChange(event) {
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        if (event.keyCode === 13) {
            this.filteredList = this.getfilterListServerEnd();
            console.log('1st')
        } else {
            this.filteredList = this.getfilterListClientEnd(this.recordsList);
            console.log('2nd')
        }
    }

    removeRecordOnLookup() {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.filteredList = null;
        const valueSelectedEvent = new CustomEvent('lookupvalueremoved',{detail : true});
        this.dispatchEvent(valueSelectedEvent);
    }

    getfilterListServerEnd() {
        console.log('getFilterRecords')
        getFilterRecords({
            objectName: this.objectApiName,
            column: this.searchField,
            keyFieldAPI: this.keyFieldAPI,
            searchKey: this.searchKey
        })
        .then((result) => {
            if (result.length === 0) {
                this.filteredList = [];
                this.message = "No Records Found";
            } else {
                this.filteredList = this.getfilterListClientEnd(result);
                this.message = "";
            }
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.filteredList = undefined;
        });
    }

    getfilterListClientEnd(recordList) {
        var result = [];
        for (var i = 0; i < recordList.length; i++) {
            if (recordList[i][this.searchField] !== undefined) {
                let value = recordList[i][this.searchField].toLowerCase();
                let searchval = this.searchKey.toLowerCase();
                if (value.indexOf(searchval) !== -1 || this.objectApiName.toLowerCase() == 'user') {
                    let records = {};
                    records.Id = recordList[i][this.keyFieldAPI];
                    records.Name = recordList[i][this.searchField];
                    result.push(records);
                }
            }
        }
        return result;
    }
}