import { LightningElement, track, api, wire } from 'lwc';
import submitApplications from '@salesforce/apex/fsVendorhandoff.submitApplications';
import getApplicationData from '@salesforce/apex/fsVendorhandoff.getApplicationData';
import saveApplications from '@salesforce/apex/fsVendorhandoff.saveApplications';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import APPLICATION_OBJECT from '@salesforce/schema/Application__c';
import getRepaymentDoc from '@salesforce/apex/fsVendorhandoff.getRepaymentDoc';
import STORAGEVENDOR from '@salesforce/schema/Application__c.Storage_Vendor_Name__c';
import FILEINWARDSTATUS from '@salesforce/schema/Application__c.File_Status__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BusinessDate from '@salesforce/label/c.Business_Date';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';

export default class FsVendorHandoff extends NavigationMixin(LightningElement) {

    @api recordId;
    @track fromDate;
    @track toDate;
    @track appName='';
    @track loanNo='';
    @track fileinwardPicklistValues = [];
    @track storagePicklistValues = [];
    @track isSpinner = false;
    @track applicationData;
    @track hasAppData = false;
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

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STORAGEVENDOR
    })
    wiredSTORAGEVENDORPickListValues({ error, data }) {
        if (data) {
            console.log('gender' + JSON.stringify(data));
            this.storagePicklistValues = [{ label: 'None', value: '' }, ...data.values];
        } else if (error) {
            this.storagePicklistValues = undefined;
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
        console.log('loan no is >>>',this.loanNo);
        console.log('this.appName no is >>>',this.appName);
        this.getApplicationData();         
    }

    getApplicationData(){
        getApplicationData({ fromDate: this.fromDate, toDate: this.toDate,applicationName:this.appName,loanNumber:this.loanNo}).then((result) => {
            console.log('inside the getApplicationData is >>>'+result);
            if (result !=null) {
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
        });

    }
    

    saveApplication() {

        try{
        console.log('inside save');
        this.isSpinner = true;
        var count=0;
        var isChnaged = false;
        
            if(this.applicationData.length>0){
                for(let i=0;i<this.applicationData.length;i++){

                    if((this.applicationData[i].handoffDate) ||  (this.applicationData[i].handoffDate) ||(this.applicationData[i].handoffDate)
                    || (this.applicationData[i].handoffDate) || (this.applicationData[i].handoffDate)){

                        if(!this.applicationData[i].handoffDate){
                            isChnaged = true;
                            this.applicationData[i].handoffDateError = true;
                        }
                        if(!this.applicationData[i].fileBarCode){
                            isChnaged = true;
                            this.applicationData[i].fileBarCodeError = true;
                        }
                        if(!this.applicationData[i].boxBarCode){
                            isChnaged = true;
                            this.applicationData[i].boxBarCodeError = true;
                        }
                        if(!this.applicationData[i].storageVendorName){
                            isChnaged = true;
                            this.applicationData[i].storageVendorNameError = true;
                        }
                        if(!this.applicationData[i].fileStatus){
                            isChnaged = true;
                            this.applicationData[i].fileStatusError = true;
                        }
                    }
                    
                    if(i==this.applicationData.length-1 && isChnaged){
                        console.log('inside handle return');
                        this.isSpinner = false;
                        this.showToast('Error', 'error', 'Complete required field first');
                        return;
                    }else if(i==this.applicationData.length-1 && !isChnaged){
                        this.handleSave();
                    }
                        
                }
            }else{
                console.log('inside else of save');
            }
            
        }catch(e){
            console.log('error uis >>>',e.message);
        }
    }

    handleSave(){

        saveApplications({ dataWrapper: JSON.stringify(this.applicationData) })
        .then(res => {
            console.log('saveObligations', res);
            if (res == 'success') {
                this.showToast('Success', 'success', 'Records Saved Successfully');
                this.handleDisable = true;
                this.isSpinner = false;
            } else if (res == 'error') {
                this.showToast('Error', 'error', 'Error in Saving Records');
                this.isSpinner = false;
            }
        })
        .catch(err => {
            this.showToast('Error', 'error', 'Error in Saving Records');
            this.isSpinner = false;
        })

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
        if (event.target.name === 'Handoff Date') {
            this.applicationData[event.currentTarget.dataset.index].handoffDate = event.target.value;
            this.applicationData[event.currentTarget.dataset.index].handoffDateError = false;
        } else if (event.target.name === 'FileBar Code') {
            this.applicationData[event.currentTarget.dataset.index].fileBarCode = event.target.value;
            this.applicationData[event.currentTarget.dataset.index].fileBarCodeError = false;
        }
        else if (event.target.name === 'BoxBar Code') {
            this.applicationData[event.currentTarget.dataset.index].boxBarCode = event.target.value;
            this.applicationData[event.currentTarget.dataset.index].boxBarCodeError = false;
        }
        else if (event.target.name === 'Storage Vendor Name') {
            this.applicationData[event.currentTarget.dataset.index].storageVendorName = event.target.value;
            this.applicationData[event.currentTarget.dataset.index].storageVendorNameError = false;
        }
        else if (event.target.name === 'File Status') {
            this.applicationData[event.currentTarget.dataset.index].fileStatus = event.target.value;
            this.applicationData[event.currentTarget.dataset.index].fileStatusError = false;
        }
        this.handleDisable = false;
        this.applicationData[event.currentTarget.dataset.index].isChanged = true;
        console.log('application data i edit is >>',this.applicationData);
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
       
       
        submitApplications({ dataWrapper: JSON.stringify(this.applicationData) })
                .then(res => {
                    console.log('saveObligations', res);
                    if (res == 'success') {
                        this.applicationData = undefined;
                        this.navigateApptList();
                        this.showToast('Success', 'success', 'Records Submitted Successfully');
                        
                        this.isSpinner = false;
                    } else if (res == 'error') {
                        
                        this.showToast('Error', 'error', 'No record found to submit the stage');
                        this.isSpinner = false;
                    }
                })
                .catch(err => {
                    
                    this.showToast('Error', 'error', 'Error in Saving Records');
                    this.isSpinner = false;
                })
           

    }

    handleletterpdf(event){
        this.isSpinner = true;
        var appRecordId = event.target.dataset.id;

        console.log('apprecord is iss>>',appRecordId);

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/Welcome_Letter?id=' + appRecordId
            }
        }).then(generatedUrl => {
            this.isSpinner = false;
            window.open(generatedUrl);
        });


    }

    handlerepaymentpdf(event){
        this.isSpinner = true;
        var appRecordId = event.target.dataset.id;
        console.log('appid is >>',appRecordId);
        getRepaymentDoc({ recordId: appRecordId }).then((result) => {
            console.log('appid is inside >>');
            this.docId = result;
            
            if (this.docId) {
                console.log('appid ibss inside >>');
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state: {
                        recordIds: this.docId
                    }
                });
                this.isSpinner = false;
            } else {
                console.log('else ibss inside >>');
                this.isSpinner = false;
                this.showToast('Error', 'error', 'File not found');
            }
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getExistingRecord= ', err);
        });


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