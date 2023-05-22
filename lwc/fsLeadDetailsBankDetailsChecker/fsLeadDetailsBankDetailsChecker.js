import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from '@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import getBankDetailsData from '@salesforce/apex/FsLeadDetailsControllerHelper.getBankDetailsData';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllApplicantMeta from '@salesforce/apex/FsLeadDetailsControllerHelper.getAllApplicantMeta';
import getIFSCData from '@salesforce/apex/FsIFSCController.getIFSCData';

export default class FsLeadDetailsBankDetailsChecker extends LightningElement {
    @api rowAction;
    @api allLoanApplicant;
    @track tableData;
    @track isRecordEdited = false;
    @track recordIds;
    @track fieldsContent;
    @track objectIdMap = { 'Bank_Detail__c': '' };
    @track isSpinnerActive = false;
    @track showDeleteModal = false;
    @track recordIdForDelete;
    @track isApplicantEdit = true;
    @track selectedApplicant;
    @api allApplicantData;
    @track bankCheck = false;
    @track labelSave = 'Save';
    @track IFSCData;
    @track appIdOnRadioButton;

    connectedCallback() {
        this.getBankDetailsData();
    }
    @api getBankDetailsData() {
        getBankDetailsData({ allLoanApplicant: this.allLoanApplicant })
            .then(result => {
                this.tableData = result;
                this.isApplicantEdit = true;
                this.bankCheck = false;
                var temp = JSON.parse(result.strDataTableData);
                if (temp.length == 0)
                    this.bankCheck = false;
                else
                    this.bankCheck = true;
                const checkValidBank = new CustomEvent("checkbankdetailinfo", {
                    detail: this.bankCheck
                });
                console.log('bankCheck ', checkValidBank);
                this.dispatchEvent(checkValidBank);
                if (result && result.strDataTableData && JSON.parse(result.strDataTableData).length) {
                    JSON.parse(result.strDataTableData).forEach(element => {
                        for (let keyValue of Object.keys(element)) {
                            if (keyValue != 'Id') {
                                console.log('insideee111 keyValue ', keyValue)
                                const selectedEvent = new CustomEvent("handletabvaluechange", {
                                    detail: { tabname: 'Application Information', subtabname: 'Bank Details', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                                });
                                this.dispatchEvent(selectedEvent);
                            }
                        }
                    });
                }
            })
            .catch(error => {

            })
    }
    todayDate() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        var todayDate = yyyy + '-' + mm + '-' + dd;
        return todayDate;
    }
    getSectionPageContent(recId) {
        var todayDate = this.todayDate();
        getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Bank_Details' })
            .then(result => {
                console.log('result.data #### ', result.data);
                this.fieldsContent = result.data;
                this.isSpinnerActive = false;
                this.setValues(todayDate);
            })
            .catch(error => {
                console.log(error);
            });
    }


    handleSelectedApplication(event) {
        console.log('Edit called #### ', JSON.stringify(event.detail));
        this.fieldsContent = undefined;
        var recordData = event.detail.recordData;
        if (event.detail.ActionName === 'edit') {
            this.isSpinnerActive = true;
            this.labelSave = 'Update';
            this.isApplicantEdit = false;
            this.isRecordEdited = true;
            this.recordIds = recordData.Id;
            this.objectIdMap['Bank_Detail__c'] = recordData.Id;
            this.getSectionPageContent(this.recordIds);
            this.isSpinnerActive = false;
        }
        if (event.detail.ActionName === 'delete') {
            this.recordIdForDelete = event.detail.recordData.Id;
            this.showDeleteModal = true;
        }

    }
    changedFromChild(event) {
        console.log('changedFromChild ### ', JSON.stringify(event.detail));
        var tempFieldsContent = event.detail;
        var splittedFieldAPIName = tempFieldsContent.CurrentFieldAPIName.split('-');
        let finalFieldAPIName = splittedFieldAPIName[1];
        var loandAppId;
        if (this.recordIds) {
            loandAppId = this.recordIds;
        } else if (this.appIdOnRadioButton) {
            loandAppId = '1';
        }

        if (this.appIdOnRadioButton) {
            const selectedEvent2 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Application Information', subtabname: 'Bank Details', fieldapiname: 'Loan_Applicant__c', fieldvalue: this.appIdOnRadioButton, recordId: loandAppId }
            });
            // Dispatches the event.	
            this.dispatchEvent(selectedEvent2);
        }

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Application Information', subtabname: 'Bank Details', fieldapiname: finalFieldAPIName, fieldvalue: tempFieldsContent.CurrentFieldValue, recordId: loandAppId }
        });
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);

    }
    setIFSCDetails(_fieldAPIName, _val) {
        var _tempVar = JSON.parse(this.fieldsContent);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName) {
                _tempVar[0].fieldsContent[i].value = _val
            }
        }
        this.fieldsContent = JSON.stringify(_tempVar);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            let fName = _tempVar[0].fieldsContent[i].fieldAPIName;
            let fValue = _tempVar[0].fieldsContent[i].value;
            let rcId = this.recordIds ? this.recordIds : '1';
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Application Information', subtabname: 'Bank Details', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent);
        }
        return _tempVar;
    }
    handleSave() {
        try {
            var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
            if (data.length > 0) {
                this.isSpinnerActive = true;
                for (var i = 0; i < data.length; i++) {
                    console.log('data #### ', JSON.stringify(data[i]));
                    if (data[i].Account_Number__c != data[i].Account_Number_with_masking_digits__c) {
                        this.showtoastmessage('Error', 'Error', 'Account No Should Be Equal With Re-Account No');
                        this.isSpinnerActive = false;
                        return;
                    }
                    else if (this.selectedApplicant === undefined) {
                        data[i].Id = this.objectIdMap[data[i].sobjectType];
                    } else {
                        data[i].Customer_Information__c = this.selectedApplicant[0].Customer_Information__c;
                        data[i].Loan_Applicant__c = this.selectedApplicant[0].Id;
                    }
                    // if(this.IFSCData === undefined){
                    //     this.showtoastmessage('Error', 'Error', 'Find IFSC Code');
                    //     this.isSpinnerActive = false;
                    //     return;
                    // } else
                    if (this.IFSCData != undefined) {
                        data[i].IFSC_Code__c = this.IFSCData.IFSC;
                        data[i].Name = this.IFSCData.BANK;
                        data[i].Branch_Name__c = this.IFSCData.BRANCH;
                        data[i].Bank_Code__c = this.IFSCData.BANKCODE;
                    }

                    console.log('data 2## ', JSON.stringify(data));
                    saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                        .then(result => {
                            this.fieldsContent = undefined;
                            this.isSpinnerActive = false;
                            this.showtoastmessage('Success', 'Success', 'Bank Details Saved Successfully.');
                            this.tableData = undefined;
                            this.selectedApplicant = undefined;
                            this.allApplicantData = undefined;
                            this.getBankDetailsData();
                            this.getAllApplicantMeta();
                        })
                        .catch(error => {
                            console.log(error);
                            this.showtoastmessage('Error', 'Error', JSON.stringify(error));
                        });

                }
                const removeEvent = new CustomEvent("handletabvalueremove", {
                    detail: { tabname: 'Application Information', subtabname: 'Bank Details' }
                });
                // Dispatches the event.	
                this.dispatchEvent(removeEvent);
            } else {
                this.showtoastmessage('Error', 'Error', 'Complete Required Field(s).');
            }
        } catch (error) {
            console.log(error);
        }
    }
    handleCancel() {
        console.log('handle cancel called ###');
        this.fieldsContent = undefined;
        this.isApplicantEdit = true;
        this.allApplicantData = undefined;
        this.getAllApplicantMeta();
        this.getBankDetailsData();
    }
    showtoastmessage(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    handleDelete(event) {
        this.isSpinnerActive = true;
        let label = event.target.label;
        if (label == 'Yes') {
            this.showDeleteModal = false;
            deleteRecord(this.recordIdForDelete)
                .then(() => {
                    this.tableData = undefined;
                    this.getBankDetailsData();
                    this.isSpinnerActive = false;
                })
                .catch(error => {
                    console.log(error);
                });
        } else if (label == 'No') {
            this.showDeleteModal = false;
            this.isSpinnerActive = false;
        }
    }
    handleRadtioButton(event) {
        this.labelSave = 'Save';
        this.getSectionPageContent();
        this.selectedApplicant = event.detail;
        this.appIdOnRadioButton = event.detail[0].Id;
        console.log('event #### ', JSON.stringify(event.detail));
    }
    getAllApplicantMeta() {
        getAllApplicantMeta({ allLoanApplicant: this.allLoanApplicant })
            .then(result => {
                this.allApplicantData = result;
                this.isSpinnerActive = false;
            })
            .catch(error => {

            })
    }
    handlemodalactions(event) {
        this.showDeleteModal = false;
        if (event.detail === true) {
            this.tableData = undefined;
            this.getBankDetailsData();
        }
    }
    setValues(_val) {
        var _tempVar = JSON.parse(this.fieldsContent);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Account_Opening_Date__c') {
                _tempVar[0].fieldsContent[i].maxDate = _val;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Account_Number_with_masking_digits__c') {
                _tempVar[0].fieldsContent[i].fieldAttribute.dataType = 'password';
            }
        }
        this.fieldsContent = JSON.stringify(_tempVar);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            let fName = _tempVar[0].fieldsContent[i].fieldAPIName;
            let fValue = _tempVar[0].fieldsContent[i].value;
            let rcId = this.recordIds ? this.recordIds : '1';
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Application Information', subtabname: 'Bank Details', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent);
        }

        return _tempVar;
    }
    enterpressed(event) {
        console.log('enterpressed changeddd  ### ', JSON.stringify(event.detail));
        var ifscCode = event.detail;
        if (ifscCode.length === 11) {
            getIFSCData({ ifscCode: ifscCode })
                .then(data => {
                    console.log('### result ### ', data);
                    if (data.isSuccess) {
                        this.IFSCData = {};
                        this.IFSCData = JSON.parse(data.result);
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('IFSC_Code__c', this.IFSCData.IFSC)));
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('Name', this.IFSCData.BANK)));
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('Branch_Name__c', this.IFSCData.BRANCH)));
                        this.template.querySelector('c-generic-edit-pages-l-w-c').isSearchLoading = false;
                    } else {
                        this.showtoastmessage('Error', 'Error', 'Enter A Valid IFSC Code.');
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('IFSC_Code__c', '')));
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('Name', '')));
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('Branch_Name__c', '')));
                        this.template.querySelector('c-generic-edit-pages-l-w-c').isSearchLoading = false;
                    }
                })
                .catch(error => {

                })
        } else {
            this.showtoastmessage('Error', 'Error', 'Enter A Valid IFSC Code.');
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('IFSC_Code__c', '')));
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('Name', '')));
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setIFSCDetails('Branch_Name__c', '')));
            this.template.querySelector('c-generic-edit-pages-l-w-c').isSearchLoading = false;
        }

    }
}