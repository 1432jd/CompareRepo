import { LightningElement, api, wire, track } from 'lwc';
import getData from '@salesforce/apex/FS_PreLoginController.getData';
import deleteProperty from '@salesforce/apex/FS_PreLoginController.deleteProperty';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId';
import getPincodeDetails from '@salesforce/apex/DatabaseUtililty.getPincodeDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class PreLoginPropertyScreen extends LightningElement {

    //API Variables
    @api applicationId;
    @api applicantTypeOption; //Property Owner
    @api preLogInId;
    @api propRecordType; //Pre Login Property Detail
    @api hasPrimaryOwner = false;
    @api hasProperty = false;
    @api propertyWrapper = {hasProperty : false, hasPrimaryOwner : false};
    @api propertyRecordTypeName;
    
    //track variables
    @track isDataArrived = false;
    @track data = [];
    @track isModalOpenDelProp = false;
    @track saveLabel = 'Save';
    @track propId;
    @track collateralId; //Property Record Id
    @track applicantValue;
    @track customerId;
    @track recName;

    //Pincode variables
    @track pinCode;
    @track district;
    @track city;
    @track state;
    @track taluka;

    @track rowAction = [
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:edit',
                title: 'Edit',
                variant: 'border-filled',
                alternativeText: 'Edit',
                name: 'edit'
            }
        },
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:delete',
                title: 'Delete',
                variant: 'border-filled',
                alternativeText: 'Delete',
                name: 'delete'
            }
        }
    ];

    connectedCallback(){
        try{
            this.getPropRecId();
            console.log('application Id in property screen ',this.applicationId);
            if(this.applicationId){
                this.isDataArrived = false;
                this.getData();
            }
        }
        catch(exe){
            console.log('Exception in prelogin property screen ',exe);
        }
    }

    openModal() {
        this.isModalOpenDelProp = true;
    }
    closeModal() {
        this.isModalOpenDelProp = false;
    }

     getPropRecId(){
        if(!this.propertyRecordTypeName){
            this.recName = 'Pre Login Property Detail';
        }
        else{
            this.recName = this.propertyRecordTypeName;
        }
        console.log('Rec Name ',this.recName);
        getRecordTypeId({ sObjectName: 'Property__c', recordTypeName: this.recName})
        .then(result => {
            this.propRecordType = result;
            console.log('this.propRecordType ', this.propRecordType);
        })
        .catch(error => {
            console.log(error);
        })
    }
    
    //get Property related to current application
    @api getData() {
        console.log('get property data called!!', this.applicationId);
        getData({ applicationId: this.applicationId })
            .then(result => {
                console.log('inside property');
                console.log(JSON.stringify(result));
                this.hasPrimaryOwner = false;
                var temp = JSON.parse(result.strDataTableData);
                console.log('temp', temp);
                console.log('property length ', temp.length);
                if (temp.length === 0) {
                    this.hasProperty = false;
                }
                else {
                    this.hasProperty = true;
                }
                temp.forEach(element => {
                    console.log('element ', JSON.stringify(element));
                    var dataResult = element;
                    if (dataResult.isPrimaryApplicant__c === 'true') {
                        this.hasPrimaryOwner = true;
                    }
                });
                console.log('hasPrimaryOwner ', this.hasPrimaryOwner);
                this.propertyWrapper.hasProperty = this.hasProperty;
                this.propertyWrapper.hasPrimaryOwner = this.hasPrimaryOwner;
                
                this.data = [];
                this.data = result;
                 
                this.isDataArrived = true;
                console.log('json data ====> ' + JSON.stringify(result));
                const propertyEvent = new CustomEvent("getpropertyevent", {
                    detail: this.propertyWrapper
                });
                console.log('dispatch event property ', JSON.stringify(propertyEvent));
                this.dispatchEvent(propertyEvent);
            })
            .catch(error => {
                console.log('error in getdata ', error);
            })
    }

    handleApplicantChange(event) {
        console.log('handleApplicantChange ', event);
        console.log(event.target.options.find(opt => opt.value === event.detail.value).label);
        console.log(event.target.options.find(opt => opt.value === event.detail.value).value);
        this.customerId = event.target.options.find(opt => opt.value === event.detail.value).value;
        this.applicantValue = event.detail.value;
    }

    handleSubmit(event) {
        console.log('Property Submit Called');
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
        const fields = event.detail.fields;
        var d1 = new Date();
        var d2 = new Date(fields.Title_Deed_Date__c);
        if (this.applicantValue == undefined || this.applicantValue == '' || this.applicantValue == null || d2.getTime() > d1.getTime()) {
            event.preventDefault();       // stop the form from submitting
            if(this.applicantValue == undefined || this.applicantValue == '' || this.applicantValue == null ){
                this.showToast('Error', 'error', 'Please Select Property Owner!!');
                this.closeAction();
            }
            if (d2.getTime() > d1.getTime()) {
                this.showToast('Error', 'error', 'Invalid Date!!');
                this.closeAction();
            }
        }
        else {
            console.log('fields ', JSON.stringify(fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            if (this.saveLabel == 'Update') {
                this.showToast('Success', 'Success', 'Record Updated Successfully!!');
                this.closeAction();
            }
            this.saveLabel = 'Save';
        }
    }

    handleSuccess(event) {
        console.log('onsuccess event prop recordEditForm', event.detail.id);
        let propertyLIst=[];
        if(this.saveLabel!='Update')
        {
            propertyLIst.push(event.detail.id);
        }
        if(propertyLIst.length>0)
        {
           const propertyDataEvent = new CustomEvent("getupdatedproperties", {
                    detail: propertyLIst
                });
                 this.dispatchEvent(propertyDataEvent);
        }
       
          
        this.applicantValue = '';
        this.isDataArrived = false;
        this.getData();
        this.handleReset();
    }

    handleReset() {
        const inputFields = this.template.querySelectorAll('[data-name="reset"]');
        console.log('HandleReset Property ', JSON.stringify(inputFields));
        if (inputFields) {
            inputFields.forEach(field => {
                console.log('Reset ', JSON.stringify(field));
                field.reset();
            });
        }
        this.collateralId = '';
        this.state = '';
        this.city = '';
        this.district = '';
        this.taluka = '';

    }

    //Data Table Action Functions
    handleSelectedRecords(event) {
        console.log('**2**', JSON.stringify(event.detail));
        var data = event.detail;
        if (data !== undefined && data !== '') {
            if (event.detail.ActionName === 'edit') {
                this.collateralId = data.recordData.Id;
                this.saveLabel = 'Update';
            }
            else if (event.detail.ActionName === 'delete') {
                this.isModalOpenDelProp = true;
                this.propId = data.recordData.Id;
            }
        }

    }

    selectDeleteProp() {
        this.isModalOpenDelProp = false;
        console.log('Prop Id ', this.propId);
        const propId = this.propId;
        this.delSelectedProperty(propId);
    }

    delSelectedProperty(propId) {
        this.isModalOpenDelProp = false;
        console.log('propId ', propId);
        deleteProperty({ propId: propId })
            .then(result => {
                console.log('result :: ', result);
                this.showToast('Success', 'Success', 'Record Deleted Successfully!!');
                this.closeAction();
                this.isDataArrived = false;
                this.getData();
            })
            .catch(error => {
                this.showToast('Error', 'Error', 'Unable to delete record, Please contact System Administrator.');
                this.closeAction();
            })
    }
     handlePincode(event) {
        console.log('pin ', event.target.value);
        const pinId = (event.target.value);
        if (pinId.length === 18) {
            getPincodeDetails({ pinId: pinId })
                .then(result => {
                    console.log(result);
                    this.city = result.city;
                    this.state = result.state;
                    this.pincode = result.pinCode;
                    this.taluka = result.taluka;
                    this.district = result.district;
                })
                .catch(error => {
                    console.log(error);
                })
        }
    }

    // Show Toast Messages Function
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

}