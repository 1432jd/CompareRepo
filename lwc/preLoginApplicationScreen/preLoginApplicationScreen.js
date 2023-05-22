import { LightningElement, api, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMP_FIELD from '@salesforce/schema/User.EmployeeNumber';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getApplicationRecord from '@salesforce/apex/FS_PreLoginController.getApplicationRecord';
import getBranchName from '@salesforce/apex/FS_PreLoginController.getBranchName';
export default class PreLoginApplicationScreen extends LightningElement {

    @api applicationId;
    @api hasAllFields;
    @api isRelogin;
    @api isTopup;
    @api appName;
    @track showOldApp;
    @track isStaffLoan = false;
    @track loadOnes = false;
    @track appSave = 'Save';
    @track empName;
    @track empId;
    @track error;
    @track fieldOfficerId;
    @track branchName;

    @wire(getRecord, { recordId: Id, fields: [NAME_FIELD, EMP_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            this.empName = data.fields.Name.value;
            this.empId = data.fields.EmployeeNumber.value;
            this.fieldOfficerId = this.empName + '-' + this.empId;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        try{
            console.log('Application Id @@@@ ',this.applicationId);
            if (this.applicationId) {
               this.getUpdatedApplicationRecords();
               getBranchName().then(result=>{
                   console.log('result'+result);
                   this.branchName= result;
               })
               .catch(error =>{
                   console.log('error in branch master ',error);
               })
            }
        }
        catch(exe){
            console.log('Exception in application screen ',exe);
        }
    }

    @api showOldAppNumber(){
        console.log('isRelogin isTopup ',this.isRelogin+' , '+this.isTopup);
        console.log('app-Name ',this.appName);
        if(this.isRelogin || this.isTopup)
            this.showOldApp = true;
        else
            this.showOldApp = false;
    }

    @api getUpdatedApplicationRecords(){
        getApplicationRecord({ applicationId: this.applicationId })
        .then(result => {
            console.log('getApplicationRecord Result ', result);
            if (result != null && result != undefined && result != '') {
                this.hasAllFields = false;
                console.log('Staff Loan App ', result.Staff_Loan__c);
                if (result.Alternate_Channel_Mode__c && result.Channel__c && result.Customer_Visit_date__c && result.Field_Officer_Employee_ID__c
                    && result.Requested_Loan_Amount__c) {
                        this.appSave = 'Update';
                    if (result.Staff_Loan__c === true) {
                        this.isStaffLoan = true;
                        if (result.Employee_ID__c) {  
                            this.hasAllFields = true;
                        }
                        else {
                            this.hasAllFields = false;
                        }
                    }
                    else{
                        this.hasAllFields = true;
                        this.isStaffLoan = false;
                    }
                }
                else {
                    this.appSave = 'Save';
                    this.hasAllFields = false;
                }
            }
            console.log('this.hasAllFields ', this.hasAllFields);
            const allsaveevent = new CustomEvent("allsaveevent", {
                detail: this.hasAllFields
            });
            console.log('dispatch event allsaveevent ', allsaveevent);
            this.dispatchEvent(allsaveevent);
        })
        .catch(error => {
            console.log('Catched error in getApplicationRecords ',error);
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

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleStaffLoan(event) {
        console.log('staffLoan ', event.target.value);
        if (event.target.value === true)
            this.isStaffLoan = true;
        else
            this.isStaffLoan = false;
    }

    handleSuccessApp(event) {
        console.log('On Success Application ', event.detail.id);
        this.showToast('Success', 'Success', 'Application Saved Successfully!!');
        this.closeAction();
        this.appSave = 'Update';
        this.hasAllFields = true;
        console.log('this.hasAllFields ', this.hasAllFields);
        const allsaveevent = new CustomEvent("allsaveevent", {
            detail: this.hasAllFields
        });
        console.log('dispatch event allsaveevent ', allsaveevent);
        this.dispatchEvent(allsaveevent);
    }

    handleSubmitApp(event) {
        this.hasAllFields = false;
        const fields = event.detail.fields;
        var d1 = new Date();
        var d2 = new Date(fields.Customer_Visit_date__c);
        event.preventDefault();
        if (d2.getTime() > d1.getTime()) {
            this.showToast('Error', 'error', 'Invalid Date!!');
            this.closeAction();
            const inputFields = this.template.querySelector('[data-id="visitDate"]');
            console.log('ResetDate ', JSON.stringify(inputFields));
            inputFields.reset();
        }
        else {
            console.log('Application Id ', this.applicationId);
            console.log('on submit application ', JSON.stringify(event.detail.fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            console.log('After Submit fields ', JSON.stringify(fields));
        }
    }

    handleResetApp() {
        //this.template.querySelector('form').reset();
        const inputFields = this.template.querySelectorAll('[data-name="resetApp"]');
        console.log('HandleReset ', JSON.stringify(inputFields));
        if (inputFields) {
            inputFields.forEach(field => {
                console.log('Reset ', JSON.stringify(field));
                field.reset();
            });
        }
        //this.applicationId = '';
    }

}