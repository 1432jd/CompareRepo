import { LightningElement, track, api, wire } from 'lwc';
import submitApplications from '@salesforce/apex/fsFileInward.submitApplications';
import getApplicationData from '@salesforce/apex/fsFileInward.getApplicationData';
import saveApplications from '@salesforce/apex/fsFileInward.saveApplications';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import APPLICATION_OBJECT from '@salesforce/schema/Application__c';
import FILEINWARDSTATUS from '@salesforce/schema/Application__c.File_Inward_Status__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BusinessDate from '@salesforce/label/c.Business_Date';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';

export default class FsFileInwardLwc extends NavigationMixin(LightningElement) {

    @api recordId;
    @track fromDate;
    @track toDate;
    @track appName='';
    @track loanNo='';
    @track fileinwardPicklistValues = [];
    @track isSpinner = false;
    @track applicationData;
    @track hasAppData;
    @track todaysDate = BusinessDate;
    @track lastLoginDate;
    @track handleDisable = true;
    @track rowChanged = [];
    @track isSave = false;
    @track stausMap = new Map();
    //@track sumbitDisable = true;
    @track btns = [
        {
            name: 'Submit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small',
            //disable: this.sumbitDisable

        }
    ]


    get disbursalOpts() {
        return [{ label: 'None', value: 'None' },{ label: 'Part Disb', value: 'Part Disb' },{ label: 'Full Disb', value: 'Full Disb' }];
    }

    @wire(getObjectInfo, { objectApiName: APPLICATION_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FILEINWARDSTATUS
    })
    wiredFILEINWARDSTATUSPickListValues({ error, data }) {
        if (data) {
            console.log('gender' + JSON.stringify(data));
            this.fileinwardPicklistValues = [{ label: 'None', value: '' }, ...data.values];
        } else if (error) {
            this.fileinwardPicklistValues = undefined;
            console.log('Picklist values are ${error}');
        }
    }

    connectedCallback() {
        this.initiateData();
    }


    initiateData() {
        this.handleGetLastLoginDate();
    }

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    handleFormValues(event) {
        console.log('event.target.name', event.target.name, 'event.target.value', event.target.value);
        if (event.target.name === 'From Date') {
            this.fromDate = event.target.value;
        }

        if (event.target.name === 'To Date') {
            this.toDate = event.target.value;
        }
        if (event.target.name === 'Application No') {
            this.appName = event.target.value;
        }
        if (event.target.name === 'Loan Account Number') {
            this.loanNo = event.target.value;
        }
    }


    handleClick() {
        this.isSpinner = true;
        //let allValid = this.handleCheckValidity();
        //if (!allValid) {
           // this.isSpinner = false;
            //Added by sangeeta : 19 Dec 22 : if from date and end date is null
          
            console.log('this.fromDate', this.fromDate,'data type', typeof this.fromDate, 'this.toDate', this.toDate, 'data type', typeof this.toDate);
            console.log('inside the handle click >>');
            this.getApplicationData();
            /*      if(this.fromDate == undefined || this.fromDate == null){
                if(this.toDate == undefined || this.toDate == null){
                    this.getApplicationData(null, null);
                }
                else{
                    this.getApplicationData(null, this.toDate);
                }
            }
            else{
                if(this.toDate == undefined || this.toDate == null){
                    this.getApplicationData(this.fromDate, null);
                }
                else{
                    this.getApplicationData(this.fromDate, this.toDate);
                }
            }*/   //by sandeep
            
           // return;
        /*} else {
            this.getApplicationData(this.fromDate, this.toDate);
            //commented by sangeeta: 19 dec 22
           /* getApplicationData({ fromDate: this.fromDate, toDate: this.toDate }).then((result) => {
                if (result.length > 0) {
                    this.applicationData = result;
                    this.hasAppData = false;
                    this.isSpinner = false;
                } else {
                    this.applicationData = undefined;
                    this.hasAppData = true;
                    this.isSpinner = false;
                }
            }).catch((err) => {
                this.isSpinner = false;
                console.log('Error in getExistingRecord= ', err);
            });*/

        //}
    }

    getApplicationData(){
        console.log('xcalling getdata>>');
        getApplicationData({ fromDate: this.fromDate, toDate: this.toDate,applicationName:this.appName,loanNumber:this.loanNo }).then((result) => {
            console.log('inside the getapp click >>',result);
            if (result!=null && result.length>0) {
                this.applicationData = result;
                this.hasAppData = false;
                this.isSpinner = false;
            } else {
                console.log('inside the getapp click >>');

                this.applicationData = undefined;
                this.hasAppData = true;
                this.isSpinner = false;
            }
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getExistingRecord= ', err);
        });

    }
    

    saveApplication() {
        console.log('inside save');
        this.isSpinner = true;
        let checkvar = this.handleCheckValidity();
        console.log('checkvar is >>>', checkvar);
        console.log('this.rowChanged==>', JSON.stringify(this.rowChanged));
        //if (this.handleCheckValidity()) {
            if (this.rowChanged != undefined && this.rowChanged != null && this.rowChanged != '' && this.rowChanged.length > 0) {
                for (var rowNo = 0; rowNo < this.rowChanged.length; rowNo++) {
                    if (this.applicationData[this.rowChanged[rowNo]].fileInwardStatus == '' || this.applicationData[this.rowChanged[rowNo]].fileInwardStatus == null || this.applicationData[this.rowChanged[rowNo]].fileInwardStatus == undefined){
                        var combobox = this.template.querySelectorAll('lightning-combobox')
                        combobox[this.rowChanged[rowNo]].className = 'slds-form-element slds-has-error';
                    }
                    
                }
                for (var rowNo = 0; rowNo < this.rowChanged.length; rowNo++) {
                    
                    if (this.applicationData[this.rowChanged[rowNo]].fileInwardStatus == '' || this.applicationData[this.rowChanged[rowNo]].fileInwardStatus == null || this.applicationData[this.rowChanged[rowNo]].fileInwardStatus == undefined) {
                        this.handleDisable = true;
                        this.isSave = false;
                        const toast = new ShowToastEvent({
                            message: "Review all error messages below to correct your data.",
                            variant: "error",
                        });
                        //console.log(this.template.querySelector('.classText').getAttribute('data-index'));
                        //console.log('class',this.template.querySelector('[data-index="this.rowChanged[rowNo]"]').className);
                        console.log('class',this.template.querySelectorAll('lightning-combobox'));
                        //var i = 0;
                       // var combobox = this.template.querySelectorAll('lightning-combobox')
                        //combobox[this.rowChanged[rowNo]].className = 'slds-form-element slds-has-error';
                       /* this.template.querySelectorAll('lightning-combobox').forEach(element => {
                           // this.stausMap.set(i, element.value);
                           // i++;
                           console.log('element.rowNo',element.rowNo);
                            if(this.applicationData[this.rowChanged[rowNo]].fileInwardStatus == element.value && (element.value == null || element.value == '' || element.value == undefined )){
                                console.log('element', element.value, 'value', element.className);
                                //element.classList.add('slds-has-error')
                                element.className = 'slds-form-element slds-has-error';
                            }
                            
                        });*/

                        console.log('class',this.stausMap, 'rowNo', rowNo);
                        this.dispatchEvent(toast);
                        this.isSpinner = false;
                        break;
                        //return;
                    }
                    else {
                        this.isSave = true;
                    }

                }
            }

        //}
        if (this.isSave == true) {
            console.log('inside handle save');
            saveApplications({ dataWrapper: JSON.stringify(this.applicationData) })
                .then(res => {
                    console.log('saveObligations', res);
                    if (res == 'success') {
                        this.showToast('Success', 'success', 'Records Saved Successfully');
                        this.handleDisable = true;
                        this.isSpinner = false;
                        this.rowChanged = [];
                    } else if (res == 'error') {
                        this.showToast('Error', 'error', 'Error in Saving Records');
                        
                        this.isSpinner = false;
                    }
                })
                .catch(err => {
                    console.log('errror is >>>',err.message);
                    this.showToast('Error', 'error', 'Error in Saving Records');
                    this.isSpinner = false;
                })
        }


    }

    // show toast Method
    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
                
            })
        );
    }

    handleEditValues(event) {
        if (event.target.name === 'File Inward Status') {
            this.applicationData[event.currentTarget.dataset.index].fileInwardStatus = event.target.value;

            //Added by Sangeeta yadav: 15 dec 22
            this.applicationData[event.currentTarget.dataset.index].isError = false;
            console.log('handleEditValues', event.target.getAttribute("data-index"));
            if (this.rowChanged.indexOf(event.target.getAttribute("data-index")) >= 0) {
                console.log('alreday has row', event.target.getAttribute("data-index"));
            }
            else {
                console.log('add row in list', event.target.getAttribute("data-index"));
                this.rowChanged.push(event.target.getAttribute("data-index"));
            }

            //--------------------------------------------------------------------
            this.handleDisable = false;
        } else if (event.target.name === 'Remarks') {
            this.applicationData[event.currentTarget.dataset.index].remarks = event.target.value;
            
            if (this.applicationData[event.currentTarget.dataset.index].fileInwardStatus == '' || this.applicationData[event.currentTarget.dataset.index].fileInwardStatus == null || this.applicationData[event.currentTarget.dataset.index].fileInwardStatus == undefined){
                var combobox = this.template.querySelectorAll('lightning-combobox');
                combobox[event.currentTarget.dataset.index].className = 'slds-form-element slds-has-error';
                this.applicationData[event.currentTarget.dataset.index].isError = true;
            }
            else{
                this.applicationData[event.currentTarget.dataset.index].isError = false;
            }
            if (this.rowChanged.indexOf(event.target.getAttribute("data-index")) >= 0) {
                console.log('alreday has row', event.target.getAttribute("data-index"));
            }
            else {
                console.log('add row in list', event.target.getAttribute("data-index"));
                this.rowChanged.push(event.target.getAttribute("data-index"));
            }

            this.handleDisable = false;
        } if (event.target.name === 'Disbursal Type') {
            this.applicationData[event.currentTarget.dataset.index].disbursalType = event.target.value;
            this.applicationData[event.currentTarget.dataset.index].disbursalTypeChnaged = true;

            //Added by Sangeeta yadav: 15 dec 22
            this.applicationData[event.currentTarget.dataset.index].isError = false;
            console.log('handleEditValues', event.target.getAttribute("data-index"));
            if (this.rowChanged.indexOf(event.target.getAttribute("data-index")) >= 0) {
                console.log('alreday has row', event.target.getAttribute("data-index"));
            }
            else {
                console.log('add row in list', event.target.getAttribute("data-index"));
                this.rowChanged.push(event.target.getAttribute("data-index"));
            }

            //--------------------------------------------------------------------
            this.handleDisable = false;
        } 
        this.applicationData[event.currentTarget.dataset.index].isChanged = true;
    }

    handleCheckValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid1) {
            console.log('allValid1 in if ', allValid1);
        } else {
            console.log('allValid1 in else ', allValid1);
        }
        return (allValid1);
    }

    rowselectionevent(event){
        var detail = event.detail;
        if(detail === 'Submit'){
            this.handleSubmit();
        }
    }

    handleSubmit(){
        this.isSpinner = true;
        console.log('dataWrapper',JSON.stringify(this.applicationData));
        if(this.rowChanged != null && this.rowChanged.length > 0){
            this.showToast('Error', 'error', 'Please save all the changes');
            this.isSpinner = false;
        }
        else{
        submitApplications({ dataWrapper: JSON.stringify(this.applicationData) })
                .then(res => {
                    console.log('saveObligations', res);
                    if (res == 'success') {
                        this.applicationData = undefined;
                        this.navigateApptList();
                        this.showToast('Success', 'success', 'Records Submitted Successfully');
                        
                        this.isSpinner = false;
                    } else if (res == 'pendingerror') {
                        //this.showToast('Error', 'error', 'Error in Saving Records');
                        this.showToast('Error', 'error', 'Pending file status applications cannot move further stage');
                        this.isSpinner = false;
                    }else if (res == 'disberror') {
                        //this.showToast('Error', 'error', 'Error in Saving Records');
                        this.showToast('Error', 'error', 'Part Disbursement Applications cannot move further stage');
                        this.isSpinner = false;
                    }else{
                        this.showToast('Error', 'error', 'No records available to submit the stage');
                        this.isSpinner = false;
                    }
                })
                .catch(err => {
                    //this.showToast('Error', 'error', 'Error in Saving Records');
                    this.showToast('Error', 'error', 'Records are not available to update');
                    this.isSpinner = false;
                })}

    }

    navigateApptList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Application__c',
                actionName: 'list'
            }
        });
    }


}