import { LightningElement, api, track } from 'lwc';
import getEducationData from'@salesforce/apex/FsLeadDetailsControllerHelper.getEducationData';
import { deleteRecord } from 'lightning/uiRecordApi';
export default class LeadDetailsEducation extends LightningElement {
    @api loandata;
    @api childData;
    @api rowAction;
    @api isRecordSelected = false
    @api allApplicants;
    @api allLoanApplicant;
    @track educationOptionList= [];
    @track applicantId;
    @track childRecordId;
    @track isEditActive = false;
    @track isApplicantActive = false
    

    @api
    handleAddButton(){
        this.isApplicantActive = true;
    }
    @api
    handleCancelButton(){
        this.isApplicantActive = false;
        this.isEditActive = false;
        this.applicantId = '';
    }
    handleComboChange(event){
        if(event.target.name === 'Customer_Information__c'){
            this.applicantId = event.target.value; 
            this.childRecordId = '';
        } 
    }
    handleSuccess(){
        this.handleReset();
        this.educationOptionList = [];
        this.childRecordId = '';
        this.isApplicantActive = false;
        this.applicantId = '';
        this.isEditActive = false;
        this.handleparentcancel(true);
        this.getEducationData(true);
        var selectedEvent = new CustomEvent('toastmessages', { detail: {type : 'Success', message : 'Record Saved Successfully.'}});
        this.dispatchEvent(selectedEvent);  
        
    }
    handleSubmit(event){
        const fields = event.detail.fields;
        var loanapplicantId = '';
        this.loandata.Loan_Applicants__r.forEach(element =>{
            if(element.Customer_Information__c === this.applicantId){
                loanapplicantId = element.Id;
            }
        });
        fields.Loan_Applicant__c = loanapplicantId;
        this.template.querySelector('[data-id="education__c"]').submit(fields);
    }
    handleError(event){
        var errorDetails = event.detail
        console.log('errorDetails @@@@ '+JSON.stringify(errorDetails));

        var selectedEvent = new CustomEvent('toastmessages', { detail: {type : 'Error', message : errorDetails.message}});
        this.dispatchEvent(selectedEvent);  
    }
    getEducationData(isRefresh){
        getEducationData({allLoanApplicant : this.allLoanApplicant})
        .then(result => { 
            if(isRefresh)
                this.template.querySelector('c-generic-data-table-l-w-c').init(result);    
            this.childData.Education = result;    
        })
        .catch(error => {
            
        })
    }
    handleReset() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if ( inputFields ) {
            inputFields.forEach( field => {
                field.reset();
            } );
        }   
    }
    handleSelectedApplication(event){
        console.log('Edit called #### ',JSON.stringify(event.detail));
        var details = event.detail;
        if(details.ActionName === 'edit'){
            this.childRecordId = details.recordData.Id;  
            this.applicantId = details.recordData.Loan_Applicant__r_Customer_Information__c_VALUE.replace('/lightning/_classic/','');
            this.isEditActive = true;
            this.isApplicantActive = true;
            this.handleparentcancel(false);
        }
        if(details.ActionName === 'delete'){
            let deleteId = details.recordData.Id;;
            deleteRecord(deleteId)
            .then(() => {
                this.getEducationData(true);
            })
            .catch(error => {
                console.log(error);
            });
        }
    }
    handleparentcancel(step){
        var selectedEvent = new CustomEvent('handleparentcancel', { detail: {type : step}});
        this.dispatchEvent(selectedEvent); 
    }
}