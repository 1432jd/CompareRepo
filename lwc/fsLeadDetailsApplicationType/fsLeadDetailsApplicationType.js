import { api, LightningElement, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONSTITUTION_FIELD from '@salesforce/schema/Loan_Applicant__c.Constitution__c';
import USER_ID from '@salesforce/user/Id'; 
import { getRecord } from 'lightning/uiRecordApi'; 
import EMPLOYEE_FIELD from '@salesforce/schema/User.EmployeeNumber';
import getPrimaryApplicantData from'@salesforce/apex/FsLeadDetailsControllerHelper.getPrimaryApplicantData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from'@salesforce/apex/FsLeadDetailsController.saveRecord';
import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import CONSTITUTION from '@salesforce/schema/Application__c.Constitution__c';

export default class FsLeadDetailsApplicationType extends LightningElement {
    @api applicationId;
    @track isSpinnerActive = false;
    @track constitutionOption;
    @api fullName;
    @track constitution;
    @track data = {
        'applicationType' : '',
        'oldApplicationNo' : '',
        'employeeId' : '',
        'customerType' : '',
        'applicantFirstName' : '',
        'applicantLastName' : '',
        'constitution' : ''
    }
    @track employeeNumber;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [EMPLOYEE_FIELD]
    }) wireuser({error,data}) {
        if (error) {
            this.error = error ; 
        } else if (data) {
            this.employeeNumber = data.fields.EmployeeNumber.value;
        }
    }

@wire(getRecord, {
        recordId: '$applicationId',
        fields: [CONSTITUTION]
    }) wireConstitution({error,data}) {
                this.isSpinnerActive = true;
        if (error) {
            this.isSpinnerActive = false;
            console.log('errorrr', error)
            this.error = error ; 
        } else if (data) {
                    this.isSpinnerActive = false;
            console.log('dataeaaa const ',data);
            this.constitution = data.fields.Constitution__c.value;
			const selectedEvent = new CustomEvent("handletabvaluechange", {	
                detail: { tabname: 'Application Information', subtabname: 'Application Type', fieldapiname: 'Constitution__c', fieldvalue: this.constitution, recordId: this.applicationId }	
            });	
            this.dispatchEvent(selectedEvent);	
            console.log('constitution constitution ', data.fields.Constitution__c.value);
        }
    }


    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: CONSTITUTION_FIELD })
    propertyOrFunction({error, data}) {
        this.isSpinnerActive = true;
        if (data) {
            this.isSpinnerActive = false;
            this.constitutionOption = data.values;
        }
    };
    connectedCallback(){
        getPrimaryApplicantData({applicationId : this.applicationId})
        .then(result => { 
            this.data.applicationType = result[0].Pre_Login__r.RecordType.Name;  
            this.data.oldApplicationNo = result[0].Old_Application_Number__c;
            this.data.employeeId = '';
            this.data.customerType = result[0].Loan_Applicants__r[0].Customer_Type__c;
            this.data.applicantFirstName = result[0].Loan_Applicants__r[0].Customer_Information__r.FirstName;
            this.data.applicantLastName = result[0].Loan_Applicants__r[0].Customer_Information__r.LastName;
            this.data.constitution = result[0].Loan_Applicants__r[0].Constitution__c;
			
			console.log('Data### applicant typeeee ', JSON.stringify(result));	
                if (result && JSON.stringify(result).length) {	
                    console.log('inside result length')	
                    result.forEach(element => {	
                        for (let keyValue of Object.keys(element)) {	
                            console.log('element### a', element)	
                            if (keyValue != 'Id' && keyValue == 'Constitution__c') {	
                                console.log('insideee111 keyValue ', keyValue)	
                                const selectedEvent = new CustomEvent("handletabvaluechange", {	
                                    detail: { tabname: 'Application Information', subtabname: 'Application Type', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }	
                                });	
                                this.dispatchEvent(selectedEvent);	
                            }	
                        }	
                    });	
                }

            //Used For Fee Detail Component//
            this.fullName = this.data.applicantFirstName + ' ' + this.data.applicantLastName;
            console.log('application type full name #### ',this.fullName);
        })
        .catch(error => {
            
        })    
    }
    @api 
    primaryApplicantData(){
        return this.fullName;
    }
    handleSave(){
        console.log('data ### ',JSON.stringify(this.data));
                 console.log('data length ',JSON.stringify(this.data).length);
        this.handleConstitutionUpdation(this.applicationId);
    //     let isValid = true;
    //     let inputFields = this.template.querySelectorAll('.validate');
    //     inputFields.forEach(inputField => {
    //         if(!inputField.checkValidity()) {
    //             inputField.reportValidity();
    //             isValid = false;
    //         }
    //     });
    //  //   if(isValid){
    //       if(JSON.stringify(this.data).length > 0){
    //         this.isSpinnerActive = true;
    //         //this.data[0].Id = this.applicationId;   
    //         saveRecord({dataToInsert : JSON.stringify(this.data[0])})
    //         .then(result => {
              
    //             this.isSpinnerActive = false;
    //             console.log('application typeeee details save called');
    //             this.showToastMessage('Success','Success','Record Saved Successfully.');
    //         })
    //         .catch(error => {
    //             console.log(error);
    //             this.showToastMessage('Error','Error',JSON.stringify(error));
    //         });
    //     } else{
    //         this.showToastMessage('Error','Error','Complete Required Field(s).');
    //     }

       // } 
    }
    handleChange(event){
//        this.data[event.target.name] = event.target.value;
        this.constitution = event.target.value;
		  console.log('this.constitution change called ', this.constitution)	
        var tempFieldsContent = event.detail;	
        console.log('event.target.value changedddd called ', event.target.value)	
        console.log('anmeeeeee ', event.target.name)
        if(event.target.name == 'Constitution__c')	{
        const selectedEvent = new CustomEvent("handletabvaluechange", {	
            detail: { tabname: 'Application Information', subtabname: 'Application Type', fieldapiname: event.target.name, fieldvalue: event.target.value, recordId: this.applicationId }	
        });	
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);
    }
    }

    showToastMessage(title, variant, message){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

     handleConstitutionUpdation(recordId) {
          this.isSpinnerActive = true;
        if (recordId) {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = recordId;
            fields[CONSTITUTION.fieldApiName] = this.constitution;
            const recordInput = { fields };
            console.log('recordInput= ', recordInput);
            updateRecord(recordInput).then(() => {
            this.isSpinnerActive = false;
         this.showToastMessage('Success','Success','Record Updated Successfully.');

                console.log('UPDATE DONE');
            }).catch(error => {
                this.isSpinnerActive = false;
                console.log('Error in Loan Applicant Update = ', error);
            });
        }
    }

}