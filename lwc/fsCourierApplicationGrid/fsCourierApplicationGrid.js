import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OBJECT_NAME from '@salesforce/schema/Courier_Application__c';
import getCourierApplications from '@salesforce/apex/FsCourierApplicationGrid.getCourierApplications';
import getStatusValues from '@salesforce/apex/FsCourierApplicationGrid.getStatusValues';
import updatedCourierApplications from '@salesforce/apex/FsCourierApplicationGrid.updatedCourierApplications';
import getIconName from '@salesforce/apex/FsCourierApplicationGrid.getIconName';
export default class FsCourierApplicationGrid extends LightningElement {
    @api recordId;
    @track iconName;
    @track courierApplications;
    @track isLoader = false;
    @track isSave = false;
    @track options = [];
    @track numberOfApp;
    @track isChanged = false;
    @track url;
    @track mappedObject = [];
    connectedCallback() {
        this.getAllCourierApplications();
        this.getAllStatusValues();
        this.getObjcetIconName();
        this.url = '/lightning/r/' + this.recordId + '/related/Courier_Applications__r/view';
    }
    getAllCourierApplications() {
        this.isLoader = true;
        getCourierApplications({ courierControlId: this.recordId })
            .then(result => {
                this.courierApplications = result;
                this.numberOfApp = result.length;
                for (let key in this.courierApplications) {
                    this.mappedObject.push({ Index: key, Status: this.courierApplications[key].Status__c });
                }
            })
            .catch(error => {
            })
    }
    getAllStatusValues() {
        getStatusValues()
            .then(result => {
                for (let key in result) {
                    const option = {
                        label: key,
                        value: result[key]
                    };
                    this.options = [...this.options, option];
                }
            })
            .catch(error => {

            });
    }
    handleChange(event) {
        var name = event.target.name;
        console.log('Name', name + ' Value', this.courierApplications[event.target.dataset.index][name]);
        this.courierApplications[event.target.dataset.index][name] = event.target.value;
        if (this.courierApplications[event.target.dataset.index].Status__c != this.mappedObject[event.target.dataset.index].Status) {
            this.isChanged = true;
        }
        if (name === 'Remarks__c') {
            this.isChanged = true;
        }
    }
    handleCancel() {
        // for (let key in this.courierApplications) {
        //     this.courierApplications[key].Status__c = this.mappedObject[key].Status;
        // }
        getCourierApplications({ courierControlId: this.recordId })
        .then(result => {
            this.courierApplications = result;
            this.isLoader = false;
        })
        .catch(error => {
        })
        this.getAllCourierApplications();
        this.isChanged = false;
    }
    handleSave() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if (!isValid) {
            this.toast('Error', 'Error', 'Complete Required Field.');
        }
        else {
            this.isLoader = true;
            this.isSave = true;
            var objectList = [];
            this.courierApplications.forEach(currentItem => {
                objectList.push({ Id: currentItem.Id, Status__c: currentItem.Status__c, Application__c: currentItem.Application__c, Remarks__c: currentItem.Remarks__c });
            });
            updatedCourierApplications({ updatedObjects: JSON.stringify(objectList) })
                .then(result => {
                    console.log('Result ', result);
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Records are saved successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    this.isSave = false;
                    this.isChanged = false;
                    getCourierApplications({ courierControlId: this.recordId })
                    .then(result => {
                        this.courierApplications = result;
                        this.isLoader = false;
                    })
                })
                .catch(error => {
                    console.log('Error ', error);
                    this.isSave = false;
                });
        }
    }
    getObjcetIconName() {
        getIconName({ sObjectName: OBJECT_NAME.objectApiName })
            .then(result => {
                this.iconName = result;
                this.isLoader = false;
            })
            .catch(error => {

            });
    }
}