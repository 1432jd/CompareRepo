import { LightningElement, api, wire, track } from 'lwc';
import getBuildingFloorRecords from '@salesforce/apex/FS_BuildingFloorController.getBuildingFloorRecords';
import saveBuildingRecords from '@salesforce/apex/FS_BuildingFloorController.saveBuildingRecords';
import deleteBuildingRecord from '@salesforce/apex/FS_BuildingFloorController.deleteBuildingRecord';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import COMMON_OBJECT from '@salesforce/schema/CommonObject__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BUILDING_FLOOR from '@salesforce/schema/CommonObject__c.Building_Floor__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FsBuildingFloorCmp extends LightningElement {

    currentPropertyId;
    @api applicationId;
    @api isVacantProperty = false;
    @api
    get propertyId() {
        return this.currentPropertyId;
    }

    set propertyId(value) {
        console.log('value Set');
        this.currentPropertyId = value;
        this.getRecords(false);
    }

    @track floorOptions;
    @track recordToDeleteId;
    @track recordList = [];
    @track showSpinner = false;
    @track showDeleteModal = false;

    get disableDelete() {
        return (this.recordList && this.recordList.length == 1) ? true : false;
    }

    @wire(getObjectInfo, { objectApiName: COMMON_OBJECT })
    commobjObjectInfo;

    @wire(getPicklistValues, { recordTypeId: "$commobjObjectInfo.data.defaultRecordTypeId", fieldApiName: BUILDING_FLOOR })
    floorPicklistInfo({ data, error }) {
        this.floorOptions = [];
        if (data)
            this.floorOptions = data.values;
    }

    pushRecord() {
        let newList = JSON.parse(JSON.stringify(this.recordList));
        this.recordList = undefined;
        //let floorNo = (newList && newList.length) ? (newList.length + 1) : 1;
        let tempObj = {
            Application__c: this.applicationId,
            Object_Type__c: "Building Floors",
            Property__c: this.currentPropertyId,
            Building_Floor__c: undefined,
            Length_ft__c: undefined,
            Width_ft__c: undefined,
            Area_Extent_Sq_ft__c: undefined,
            Value_per_Sq_ft__c: undefined,
            Total_Value__c: undefined
        };
        newList.push(tempObj);
        this.recordList = JSON.parse(JSON.stringify(newList));
    }

    handleFormValues(evt) {
        let index = evt.currentTarget.dataset.index;
        console.log('handleFormValues Index = ', index)
        let newList = JSON.parse(JSON.stringify(this.recordList));
        if (evt.target.name) {
            newList[index][evt.target.name] = evt.target.value;
            if (newList[index].Length_ft__c && newList[index].Width_ft__c) {
                newList[index].Area_Extent_Sq_ft__c = parseFloat(newList[index].Length_ft__c) * parseFloat(newList[index].Width_ft__c);
            } else {
                newList[index].Area_Extent_Sq_ft__c = 0;
            }
            if (newList[index].Area_Extent_Sq_ft__c && newList[index].Value_per_Sq_ft__c) {
                newList[index].Total_Value__c = parseFloat(newList[index].Area_Extent_Sq_ft__c) * parseFloat(newList[index].Value_per_Sq_ft__c);
            } else {
                newList[index].Total_Value__c = 0;
            }
        }
        this.recordList = JSON.parse(JSON.stringify(newList));
    }

    removeRow(evt) {
        this.recordToDeleteId = evt.currentTarget.dataset.index;
        this.showDeleteModal = true;
    }

    @api
    handleSave() {
        let recordValid = this.checkInputValidity();
        if (!recordValid) {
            this.showNotifications('', 'Please fill all the data correctly', 'error');
            return;
        } else {
            this.saveRecords();
        }
    }

    // This Method Is Used To Handle Delete Action On Enquiry Table.
    handleDelete(event) {
        console.log('handleDelete= ', event.target.label)
        let label = event.target.label;
        this.showDeleteModal = false;
        if (label == 'Yes') {
            let newList = JSON.parse(JSON.stringify(this.recordList));
            this.recordList = undefined;
            let recordIdToDelete = newList[this.recordToDeleteId].Id;
            newList.splice(this.recordToDeleteId, 1);
            if (recordIdToDelete) {
                this.handleDeleteRecord(recordIdToDelete);
            } else {
                this.recordList = JSON.parse(JSON.stringify(newList));
            }
        } else if (label == 'No') {
            this.recordToDeleteId = undefined;
        }
    }

    checkInputValidity() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    // This Method Is Used To Show Toast Notification.
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    saveRecords() {
        this.showSpinner = true;
        saveBuildingRecords({ jsonData: JSON.stringify(this.recordList) }).then((result) => {
            console.log('saveBuildingRecords= ', result);
            if (result == 'success') {
                // this.showNotifications('', 'Records Saved Successfully', 'success');
                this.getRecords(true);
            }
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in saveBuildingRecords= ', err);
            this.showSpinner = false;
        });
    }

    getRecords(fireEvt) {
        this.showSpinner = true;
        getBuildingFloorRecords({ propertyId: this.currentPropertyId }).then((result) => {
            console.log('getRecords = ', result);
            let totalValueSqFt = 0;
            let totalArea = 0;
            let avgValue = 0;
            let totalValue = 0;
            if (result && result.length) {
                this.recordList = JSON.parse(JSON.stringify(result));
                this.recordList.forEach(element => {
                    totalValueSqFt = totalValueSqFt + element.Value_per_Sq_ft__c;
                    totalArea = totalArea + element.Area_Extent_Sq_ft__c;
                    totalValue = totalValue + element.Total_Value__c;
                });

                avgValue = totalValueSqFt / this.recordList.length;
            } else {
                this.recordList = [];
                this.pushRecord();
            }
            const selectEvent = new CustomEvent('floorvalues', {
                detail: {
                    totalArea: totalArea,
                    averageValuePerSqFt: avgValue,
                    totalValue: totalValue
                }
            });
            if (fireEvt)
                this.dispatchEvent(selectEvent);
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in getRecords = ', err);
            this.showSpinner = false;
        });
    }

    handleDeleteRecord(recordToDeleteId) {
        console.log('handleDeleteRecord = ', recordToDeleteId);
        this.showSpinner = true;
        deleteBuildingRecord({ recordToDelete: recordToDeleteId }).then((result) => {
            console.log('handleDeleteRecord Result = ', result);
            if (result == 'success') {
                this.showNotifications('', 'Records Deleted Successfully', 'success');
                this.getRecords(true);
            }
            this.showSpinner = false;
        }).catch((err) => {
            this.showSpinner = false;
            console.log('Error in handleDeleteRecord = ', err);
        });
    }
}