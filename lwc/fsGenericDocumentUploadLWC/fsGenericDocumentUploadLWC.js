import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import formFactorName from '@salesforce/client/formFactor';
import siteURL from '@salesforce/label/c.Site_URL';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import TYPE_FIELD from '@salesforce/schema/Document_Master__c.Type__c';
import STATUS_FIELD from '@salesforce/schema/ContentVersion.Status__c'
import AGREEMENT_DOCUMENT_TYPE_FIELD from '@salesforce/schema/ContentVersion.Agreement_Document_Type__c';
import DOCUMENT_CONDITION_FIELD from '@salesforce/schema/ContentVersion.Document_Condition__c';
import businessDate from '@salesforce/label/c.Business_Date';
import { setDeferralPicklistValue } from './FsGenericDocumentUploadLWCHelper';
import { stringToDate } from './FsGenericDocumentUploadLWCHelper';
import getApplicantAndProperty from '@salesforce/apex/FS_DocumentUploadController.getApplicantAndProperty';
import getAllDocuments from '@salesforce/apex/FS_DocumentUploadController.getAllDocuments';
import updateDeferralRecordDetail from '@salesforce/apex/FS_DocumentUploadController.updateDeferralRecordDetail';
import uploadPhotos from '@salesforce/apex/FS_DocumentUploadController.uploadPhotos';
import ConVerTYPE_FIELD from '@salesforce/schema/ContentVersion.Type__c'

export default class FsGenericDocumentUploadLWC extends LightningElement {
    @api stageName;
    @api applicationId;
    @api recordTypeId;
    @api isAgreementExecution;

    @track typePicklistOption = [];
    @track statusPicklistOption = [];
    @track applicantPicklistOption = [];
    @track assetPicklistOption = [];
    @track additionalUploadPhotos = [];
    @track isTypeApplicant = false;
    @track isSpinnerActive = false;
    @track isTypeAsset = false;
    @track isShowApplicableName = true;
    @track isShowPage = false;
    @track tabName = 'Upload';
    @track value = 'All';
    @track userName;
    @track addtionalDocData = {};
    @track documentType;
    @track documentTypeId;
    @track documentData;
    @track headerDetails;
    @track masterDocuments;
    @track listOfLoanApplicant;
    @track listOfProperties;
    @track documentMasterOptions = [];
    @track deferalPicklistOption;
    @track agreementDocumentTypePicklistOption;
    @track documentConditionPicklistOption;
    @track deferalPicklistOption;
    @track originalPicklistOption = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ]

    @track businessDate;
    @track isButtonFlag = false;
    @track isChecked = false;
    @track isSaveDisabled = true;
    @track isStageFIVBorFIVC = false;
    @track isLoading = false;
    @track isUploadPhoto = false;
    @track isAddtionalDocument = false;
    @track chunkSize = 2000000;
    @track collectedDocuments = [];
    @track indexNumber = 0
    
    @track conVerTypePicklistOption = [];
    selectedConVerType = '';
    disableSave = true;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: TYPE_FIELD })
    picklistTypeValues({ error, data }) {
        if (data) {
            this.typePicklistOption = [];
            this.typePicklistOption.push({ label: 'All', value: 'All' });
            data.values.forEach(element => {
                this.typePicklistOption.push({ label: element.label, value: element.value });
            });
            this.typePicklistOption.push({ label: 'Mandatory', value: 'Mandatory' });
        }
        else if (error) {
            console.log('Error In Type Picklist Option', error);
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: STATUS_FIELD })
    picklistStatusValues({ error, data }) {
        if (data) {
            var options = [];
            data.values.forEach(item => {

                if (item.value != 'Deferred' && item.value != 'Waived') {
                    options.push({ label: item.label, value: item.value });
                }
                else if (item.value === 'Deferred' && (this.stageName === 'Disbursal Maker' || this.stageName === 'Disbursal Author')) {
                    options.push({ label: item.label, value: item.value });
                }
                else if (item.value === 'Waived' && (this.stageName === 'Disbursal Maker' || this.stageName === 'Disbursal Author' || this.stageName === 'Document Deferral')) {
                    options.push({ label: item.label, value: item.value });
                }

                /*if (this.stageName === 'Document Deferral') {
                    this.statusPicklistOption.push({ label: item.label, value: item.value });
                }
                else {
                    if (item.value != 'Waived') {
                        this.statusPicklistOption.push({ label: item.label, value: item.value });
                    }
                }*/

            });
            this.statusPicklistOption = options;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ConVerTYPE_FIELD })
    conVerTYPEPicklistInfo({ data, error }) {
        if (data) {
            let stageValue = data.controllerValues[this.stageName];
            let tempList = [];
            data.values.forEach(element => {
                if(element.validFor.includes(stageValue)){
                    tempList.push({label : element.label,value : element.value});
                }
            });
            this.conVerTypePicklistOption = tempList
        }
        else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: AGREEMENT_DOCUMENT_TYPE_FIELD })
    picklistAgreementDocumentValues({ error, data }) {
        if (data) {
            this.agreementDocumentTypePicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: DOCUMENT_CONDITION_FIELD })
    picklistDocumentConditionValues({ error, data }) {
        if (data) {
            this.documentConditionPicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userName = data.fields.Name.value;
        }
    }

    get todayDate() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        var todayDate = yyyy + '-' + mm + '-' + dd;
        return todayDate;
    }

    get iFrameClass() {
        return this.isShowPage ? 'slds-show' : 'slds-hide';
    }

    handleComboboxChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        this.isSaveDisabled = true;
        if (name === 'type-picklist' && value === 'Applicant') {
            this.isTypeApplicant = true;
            this.isTypeAsset = false;
            this.isButtonFlag = false;
            this.documentType = value;
            this.headerDetails = null;
            this.isChecked = false;
        }
        if (name === 'type-picklist' && value === 'Asset') {
            this.isButtonFlag = false;
            this.isTypeApplicant = false;
            this.isTypeAsset = true;
            this.documentType = value;
            this.headerDetails = null;
            this.isChecked = false;
        }
        if (name === 'type-picklist' && (value === 'Application' || value === 'All' || value === 'Mandatory')) {
            this.isButtonFlag = true;
            this.isTypeApplicant = false;
            this.isTypeAsset = false;
            this.isShowApplicableName = value === 'Application' ? false : true;
            this.documentType = value;
            this.isChecked = false;
            this.headerDetails = null;
            this.getDocuments(this.documentType, null, null);
        }
        if (name == 'applicant-picklist' && this.isTypeApplicant) {
            this.isButtonFlag = true;
            this.isShowApplicableName = true;
            this.documentTypeId = value;
            this.isChecked = false;
            this.setHeaderDetails(this.documentType, this.documentTypeId);
            this.getDocuments(this.documentType, this.documentTypeId, null);
        }
        if (name === 'asset-picklist' && this.isTypeAsset) {
            this.isButtonFlag = true;
            this.isShowApplicableName = true;
            this.documentTypeId = value;
            this.isChecked = false;
            this.setHeaderDetails(this.documentType, this.documentTypeId);
            this.getDocuments(this.documentType, this.documentTypeId, null);
        }
    }

    connectedCallback() {
        this.handleReset();
    }

    getApplicantProperty() {
        this.isSpinnerActive = true;
        getApplicantAndProperty({ applicationId: this.applicationId, stageName: this.stageName, recordTypeId: this.recordTypeId })
            .then((result) => {
                console.log('Result ', result);
                if (result.listOfLoanApplicant) {
                    this.listOfLoanApplicant = result.listOfLoanApplicant;
                    result.listOfLoanApplicant.forEach(element => {
                        if (element.Customer_Information__r) {
                            this.applicantPicklistOption.push({ label: element.Customer_Information__r.Name, value: element.Id });
                        }
                    });
                }
                if (result.listOfProperties) {
                    this.listOfProperties = result.listOfProperties;
                    result.listOfProperties.forEach(element => {
                        this.assetPicklistOption.push({ label: element.Name, value: element.Id });
                    });
                }
                this.getDocuments(this.value, null, null);
            }).catch((err) => {
                console.log('Error In getAllDetails ', err);
                this.isSpinnerActive = false;
            });
    }

    @api
    getDocuments(documentType, documentTypeId, stageName) {
        this.isSpinnerActive = true;
        this.documentMasterOptions = [];
        getAllDocuments({ applicationId: this.applicationId, documentType: documentType, documentTypeId: documentTypeId, stageName: stageName })
            .then(result => {
                var serialNumber = 1
                if (result.setCodeRecoords) {
                    result.setCodeRecoords.forEach(element => {
                        element.serialNumber = serialNumber
                        element.isNewRowAdded = false;
                        if (element.Status__c === 'Received') {
                            element.isStatusDisabled = true;
                            element.isFileUploadDisabled = false;
                            element.isNoOfPagesDisbaled = true;
                            element.isStageDisabled = true;
                            element.isOriginalDisabled = true;
                            element.isStageDisabled = true;
                            element.isReceivedDateDisabled = true;
                            element.isDeferredDateDisabled = true;
                            element.isWaiverReasonDisabled = true;
                            element.isStageDisabled = true;
                            element.isDocumentConstionDisabled = true;
                        }
                        if (element.Status__c === 'Deferred') {
                            element.isStatusDisabled = false;
                            element.isFileUploadDisabled = true;
                            element.isNoOfPagesDisbaled = true;
                            element.isStageDisabled = false;
                            element.isOriginalDisabled = true;
                            element.isWaiverReasonDisabled = true;
                            element.isReceivedDateDisabled = true;
                            element.isStageDisabled = true;
                            element.isDeferredDateDisabled = true;
                        }
                        if (element.Status__c === 'Not Received') {
                            element.isStatusDisabled = false;
                            element.isFileUploadDisabled = true;
                            element.isReceivedDateDisabled = true;
                            element.isNoOfPagesDisbaled = true;
                            element.isOriginalDisabled = true;
                            element.isStageDisabled = true;
                            element.isWaiverReasonDisabled = true;
                            element.isFileUploadRequired = true;
                            element.isReceivedDateRequired = true;
                            element.isNoOfPagesRequired = true
                            element.isStageRequired = true;
                            element.isDeferredDateDisabled = true;
                        }
                        if (element.Status__c === 'Waived') {
                            element.isStatusDisabled = true;
                            element.isFileUploadDisabled = true;
                            element.isStageDisabled = true;
                            element.isReceivedDateDisabled = true;
                            element.isNoOfPagesDisbaled = true;
                            element.isOriginalDisabled = true;
                            element.isDeferredDateDisabled = true;
                            element.isWaiverReasonDisabled = true;
                        }
                        serialNumber++;
                    });
                }
                if (result.masterRecords) {
                    this.masterDocuments = result.masterRecords;
                    console.log('this.masterDocuments', this.masterDocuments);
                    result.masterRecords.forEach(element => {
                        element.isFileUploadDisabled = true
                        element.isReceivedDateDisabled = true;
                        element.isNoOfPagesDisbaled = true;
                        element.isOriginalDisabled = true;
                        element.isDeferredDateDisabled = true;
                        element.isWaiverReasonDisabled = true;
                        element.isStageRequired = true;
                        element.isStageDisabled = false;
                        this.documentMasterOptions.push({ label: element.Document_Name__c, value: element.Id })
                    });
                }
                this.documentData = JSON.parse(JSON.stringify(result.setCodeRecoords));
                console.log('documentData ', JSON.stringify(this.documentData));
                this.isSpinnerActive = false;
            }).catch(error => {
                console.log('Error In getAllDocuments ', error);
                this.isSpinnerActive = false;
            })
    }

    openfileUpload(event) {
        this.isSaveDisabled = false;
        var rowNo = event.target.getAttribute("data-row-index");
        var sr = Number(rowNo) + Number(1);

        if (!this.documentData[rowNo].Document_Name__c && this.documentData[rowNo].isNewRowAdded) {
            this.toast('Warning', 'Warning', 'Enter Document Name On Serial No ' + sr + '.');
            return;
        } else {
            const file = event.target.files[0]
            if (Math.round((file.size / 1024)) <= 35840) {
                console.log(file.size);
                var reader = new FileReader()
                reader.onload = () => {
                    var base64 = reader.result.split(',')[1]
                    this.fileData = {
                        'filename': this.documentData[rowNo].Document_Name__c + '.' + file.name.substr(file.name.lastIndexOf('.') + 1),
                        'base64': base64,
                        'recordId': this.applicationId,
                        'stageName': this.stageName
                    }
                    this.documentData[rowNo].fileData = JSON.parse(JSON.stringify(this.fileData));
                    this.documentData[rowNo].isReceivedDateDisabled = false;
                    this.documentData[rowNo].isOriginalDisabled = false;
                    this.documentData[rowNo].isReceivedDateRequired = true;
                    this.documentData[rowNo].isNoOfPagesDisbaled = false;
                    this.documentData[rowNo].isNoOfPagesRequired = true;
                }
                reader.readAsDataURL(file)
            }
            else {
                this.toast('Error', 'Error', 'please select a file less than 35 MB');
            }
        }
    }

    handleCheckbox(event) {
        this.isChecked = event.target.checked;
        if (event.target.checked) {
            this.getDocuments(this.documentType, this.documentTypeId, this.stageName);
        }
        if (!event.target.checked) {
            this.getDocuments(this.documentType, this.documentTypeId, null);
        }
    }

    handleEditValidation() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleTextAreaValidation() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-textarea');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    handleComboValidation() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-combobox');
        inputFields.forEach(inputField => {
            console.log('inputField #### ', inputField.disabled);
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleSaveVariousDocument() {
        var isValidInputText = this.handleEditValidation();
        var isValidInputTextArea = this.handleTextAreaValidation();
        var isValidCombo = this.handleComboValidation();
        if (!isValidInputText || !isValidInputTextArea || !isValidCombo) {
            this.toast('Error', 'Error', 'Complete Required Field.');
        } else {
            this.collectedDocuments = [];
            this.finalSubmit(this.documentData, 0);
        }
    }

    finalSubmit(actualData, indexNumber) {
        this.isLoading = true;
        this.isSaveDisabled = true;
        var element = actualData[indexNumber];
        if (element.Status__c === 'Received' && element.fileData && element.fileData.filename) {
            this.getAllCollectedDocuments(element, actualData, indexNumber);
        } else if ((element.Status__c === 'Deferred' || element.Status__c === 'Waived' || element.Status__c === 'Not Received') && !element.fileData) {
            console.log('INDISE ELSE');
            var data = JSON.parse(JSON.stringify(element));
            delete data.isFileUploadRequired;
            delete data.isFileUploadDisabled;
            delete data.selectOptions;
            delete data.fileData;
            delete data.isDeferredDateDisabled;
            delete data.fileName;
            delete data.isDeferredDateRequired;
            delete data.isNewRowAdded;
            delete data.isNoOfPagesDisbaled;
            delete data.isNoOfPagesRequired;
            delete data.isOriginalDisabled;
            delete data.isReceivedDateDisabled;
            delete data.isReceivedDateRequired;
            delete data.isStageDisabled;
            delete data.isStageRequired;
            delete data.isStatusDisabled;
            delete data.isWaiverReasonDisabled;
            delete data.isWaiverReasonRequired;
            delete data.serialNumber;
            delete data.isChange;
            console.log('Data ', data);
            updateDeferralRecordDetail({ data: JSON.stringify(data) })
                .then(result => {
                    console.log(result);
                    element.isNewRowAdded = false;
                    this.toast('Success', 'Success', 'Document Waived Or Deferred Successfully');
                    this.updateRecordDetails(data);
                    indexNumber++;
                    if (indexNumber < actualData.length) {
                        this.isLoading = true;
                        this.finalSubmit(actualData, indexNumber);
                    }
                    else {
                        this.isLoading = false;
                        this.fireToPage();
                    }
                }).catch(error => {
                    console.log('Error in updateDeferralRecordDetail', error);
                })
            element.isStatusDisabled = false;
        }
        else {
            indexNumber++;
            if (indexNumber < actualData.length) {
                this.isLoading = true;
                this.finalSubmit(actualData, indexNumber);
            }
            else {
                this.isLoading = false;
                this.fireToPage();
            }
        }
    }

    getAllCollectedDocuments(element, actualData, indexNumber) {
        this.isShowPage = true;
        this.collectedDocuments.push(element);
        console.log('collectedDOcuments', this.collectedDocuments);
        indexNumber++;
        if (actualData.length > indexNumber) {
            this.finalSubmit(actualData, indexNumber);
        }
        else {
            this.fireToPage();
        }
    }

    fireToPage() {
        var count = 0;
        if (this.collectedDocuments && this.collectedDocuments.length) {
            this.template.querySelector('iframe').contentWindow.postMessage(JSON.stringify(this.collectedDocuments), '*');
            window.addEventListener('message', (message) => {
                console.log(message.data);
                if (message.data && this.collectedDocuments && this.collectedDocuments.length) {
                    this.isShowPage = false;
                    this.toast('Success', 'Success', 'Document uploaded Successfully');
                    this.collectedDocuments.forEach(element => {
                        this.isLoading = false;
                        this.updateRecordDetails(element);
                    });
                }
            });
        }
    }

    setHeaderDetails(documentType, documentTypeId) {
        if (documentType === 'Asset') {
            this.listOfProperties.forEach(element => {
                if (element.Id === documentTypeId) {
                    this.headerDetails = element.Property_Type__c + ' - ' + element.Name;
                }
            });
        }
        if (documentType === 'Applicant') {
            this.listOfLoanApplicant.forEach(element => {
                if (element.Id === documentTypeId) {
                    this.headerDetails = element.Customer_Type__c + ' - ' + element.Customer_Information__r.Name;
                }
            });
        }
        console.log('Header Details ', this.headerDetails);
    }

    toast(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: variant,
            message: message
        })
        this.dispatchEvent(toastEvent)
    }

    handleAddNewDocument(event) {
        var actualData = this.documentData;
        if (event.target.name === 'addNewDocument') {
            var isValidInputText = this.handleEditValidation();
            var isValidInputTextArea = this.handleTextAreaValidation();
            var isValidCombo = this.handleComboValidation();
            if (!isValidInputText || !isValidInputTextArea || !isValidCombo) {
                this.toast('Error', 'Error', 'Complete Required Field.');
            } else {
                if (actualData.length > 0 || this.documentData.length > 0) {
                    var tempRow = JSON.parse(JSON.stringify(this.newRecord));
                    tempRow.serialNumber = Number(this.documentData[this.documentData.length - 1]['serialNumber']) + Number(1);
                    tempRow.isNewRowAdded = true;
                    this.documentData.push(tempRow);
                    this.toast('Success', 'Success', 'New Row added successfully');
                } else {
                    this.documentData = [];
                    var tempRow = JSON.parse(JSON.stringify(this.newRecord));
                    tempRow.serialNumber = Number(1);
                    tempRow.isNewRowAdded = true;
                    this.documentData.push(tempRow);
                    console.log('documentData', this.documentData);
                    this.toast('Success', 'Success', 'New Row added successfully');
                }
            }
        }
        else if (event.target.name === 'deleteDocument') {
            var len = 0;
            if (this.documentData.length) {
                len = this.documentData.length - Number(1);
            }
            if (this.documentData[len].isNewRowAdded === true) {
                this.documentData.pop();
                this.toast('Success', 'success', 'New Row deleted successfully');
            } else {
                this.toast('Warning', 'Warning', 'User Don\'t Have Access To Delete Record.');
            }
        }
        else if (event.target.name === 'uploadPhotos') {
            this.isUploadPhoto = true;
            if (formFactorName === 'Small' || formFactorName === 'Medium') {
                this.isUploadPhoto = false;
                window.open(siteURL + '?recordId=' + this.applicationId + '&uploadedFrom=' + this.stageName + '&userId=' + USER_ID);
            }
        } else {
            this.isAddtionalDocument = true;
        }
    }

    selectOptionChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        var rowNo = event.target.getAttribute("data-row-index");
        this.isSaveDisabled = false;

        if (name === 'Status__c' && value === 'Received') {
            this.documentData[rowNo].isFileUploadRequired = true;
            this.documentData[rowNo].isFileUploadDisabled = false;
            this.documentData[rowNo].isReceivedDateRequired = true;
            this.documentData[rowNo].isReceivedDateDisabled = false;
            this.documentData[rowNo].isNoOfPagesDisbaled = false;
            this.documentData[rowNo].isNoOfPagesRequired = true;
            this.documentData[rowNo].isOriginalDisabled = false;
            if(this.isAgreementExecution){
                this.documentData[rowNo].isDocumentConditionRequired = true;
                this.documentData[rowNo].isDocumentConditionDisabled = false;
            }
            this.documentData[rowNo].isDeferredDateDisabled = true;
            this.documentData[rowNo].isDeferredDateRequired = false;
            this.documentData[rowNo].isStageDisabled = true;
            this.documentData[rowNo].isStageRequired = false;
            this.documentData[rowNo].isWaiverReasonDisabled = true;
            this.documentData[rowNo].isWaiverReasonRequired = false;

            this.documentData[rowNo].Received_Date__c = this.businessDate;
            this.documentData[rowNo].Deferred_Date__c = null;
            this.documentData[rowNo].Deferral_Stage__c = null
            this.documentData[rowNo].Waiver_Reason__c = null;
        }

        if (name === 'Status__c' && value === 'Not Received') {
            this.documentData[rowNo].isFileUploadDisabled = true;
            this.documentData[rowNo].isFileUploadRequired = false;
            this.documentData[rowNo].isNoOfPagesDisbaled = true;
            this.documentData[rowNo].isNoOfPagesRequired = false;
            this.documentData[rowNo].isOriginalDisabled = true;
            this.documentData[rowNo].isDeferredDateDisabled = true;
            this.documentData[rowNo].isDeferredDateRequired = false;
            this.documentData[rowNo].isWaiverReasonDisabled = true;
            this.documentData[rowNo].isWaiverReasonRequired = false;
            this.documentData[rowNo].isReceivedDateDisabled = true;
            this.documentData[rowNo].isReceivedDateRequired = false;
            this.documentData[rowNo].isStageDisabled = true;
            this.documentData[rowNo].isStageRequired = this.documentData[rowNo].isNewRowAdded ? true : false;
            this.documentData[rowNo].isDocumentConditionRequired = false;
            this.documentData[rowNo].isDocumentConditionDisabled = true;

            this.documentData[rowNo].fileData = null;
            this.documentData[rowNo].Received_Date__c = null;
            this.documentData[rowNo].No_of_Pages__c = null
            this.documentData[rowNo].Original__c = null;
            this.documentData[rowNo].Waiver_Reason__c = null;
            this.documentData[rowNo].Document_Condition__c = null;
        }

        if (name === 'Status__c' && value === 'Deferred') {
            this.documentData[rowNo].isFileUploadDisabled = true;
            this.documentData[rowNo].isFileUploadRequired = false;
            this.documentData[rowNo].isStageDisabled = false;
            this.documentData[rowNo].isStageRequired = true;
            this.documentData[rowNo].isDeferredDateDisabled = false;
            this.documentData[rowNo].isDeferredDateRequired = true;

            this.documentData[rowNo].isReceivedDateDisabled = true;
            this.documentData[rowNo].isReceivedDateRequired = false;
            this.documentData[rowNo].isNoOfPagesDisbaled = true;
            this.documentData[rowNo].isNoOfPagesRequired = false;
            this.documentData[rowNo].isOriginalDisabled = true;
            this.documentData[rowNo].isWaiverReasonDisabled = true;
            this.documentData[rowNo].isWaiverReasonRequired = false;
            this.documentData[rowNo].isDocumentConditionRequired = false;
            this.documentData[rowNo].isDocumentConditionDisabled = true;

            this.documentData[rowNo].fileData = null;
            this.documentData[rowNo].Received_Date__c = null;
            this.documentData[rowNo].No_of_Pages__c = null;
            this.documentData[rowNo].Original__c = null;
            this.documentData[rowNo].Waiver_Reason__c = null;
            this.documentData[rowNo].Document_Condition__c = null;
        }

        if (name === 'Status__c' && value === 'Waived') {
            this.documentData[rowNo].isWaiverReasonDisabled = false;
            this.documentData[rowNo].isWaiverReasonRequired = true;

            this.documentData[rowNo].isStageDisabled = true;
            this.this.documentData[rowNo].isStageRequired = false;
            this.documentData[rowNo].isReceivedDateDisabled = true;
            this.documentData[rowNo].isReceivedDateRequired = false;
            this.documentData[rowNo].isNoOfPagesDisbaled = true;
            this.documentData[rowNo].isNoOfPagesRequired = false;
            this.documentData[rowNo].isOriginalDisabled = true;
            this.documentData[rowNo].isDeferredDateDisabled = true;
            this.documentData[rowNo].isDeferredDateRequired = false;
            this.documentData[rowNo].isDocumentConditionRequired = false;
            this.documentData[rowNo].isDocumentConditionDisabled = true;

            this.documentData[rowNo].fileData = null;
            this.documentData[rowNo].Received_Date__c = null;
            this.documentData[rowNo].Deferral_Stage__c = null;
            this.documentData[rowNo].No_of_Pages__c = null;
            this.documentData[rowNo].Original__c = null;
            this.documentData[rowNo].Deferred_Date__c = null;
            this.documentData[rowNo].Document_Condition__c = null;
        }
        if (this.documentData[rowNo].isNewRowAdded && name === 'Document_Name__c') {
            console.log('masterDocuments', JSON.stringify(this.masterDocuments));
            if (this.masterDocuments && this.masterDocuments.length) {
                console.log('Document Id ', value);
                this.masterDocuments.forEach(element => {
                    if (element.Id === value) {
                        console.log('ELEMENT ', element);
                        element.isNewRowAdded = true;
                        element.serialNumber = this.documentData[rowNo].serialNumber;
                        element.ShowOnUI__c = true;
                        element.isStageRequired = true;
                        this.documentData[rowNo] = element;
                    }
                });
            }
        }
        else {
            this.documentData[rowNo][name] = value;
        }
        console.log('Document Data', JSON.stringify(this.documentData[rowNo]));
    }

    updateRecordDetails(uploadedElement) {
        this.documentData.forEach(element => {
            if (uploadedElement.Status__c === 'Received' && element.Id === uploadedElement.Id) {
                element.isFileUploadDisabled = false;
                element.isStatusDisabled = true;
                element.isNoOfPagesDisbaled = true;
                element.isReceivedDateDisabled = true;
                element.isOriginalDisabled = true;
                element.fileData = null;
            }
            if (uploadedElement.Status__c === 'Deferred' && element.Id === uploadedElement.Id) {
                element.isStageDisabled = true;
                element.isDeferredDateDisabled = true;
            }
            if (uploadedElement.Status__c === 'Waived' && element.Id === uploadedElement.Id) {
                element.isWaiverReasonDisabled = true;
            }
        });
    }

    handleAdditionalCancel() {
        this.isUploadPhoto = false;
        this.isAddtionalDocument = false;
    }

    handleConVerChnage(event)
    {
        this.selectedConVerType = event.target.value; 
        this.disableSave = false;
    }

    @api
    handleReset(){
        this.isTypeApplicant = false;
        this.isTypeAsset = false;
        this.isChecked = false;
        let tempValue = this.template.querySelector("[data-id='docsettype']");
        if(tempValue){
            tempValue.value = 'All';
        }
        this.additionalUploadPhotos = [];
        this.assetPicklistOption = [];
        this.applicantPicklistOption = [];
        this.addtionalDocData = {};
        this.documentMasterOptions = [];
        this.isStageFIVBorFIVC = this.stageName === 'FIV - C' || this.stageName === 'FIV - B' ? true : false;
        this.deferalPicklistOption = setDeferralPicklistValue(this.stageName);
        this.businessDate = stringToDate(businessDate, "dd-mm-yyyy", "/", "-");
        this.documentType = this.value;
        this.getApplicantProperty();
        this.isButtonFlag = true;
    }

    handleUploadPhotos(event) {
        this.additionalUploadPhotos = [];
        if (event.target.files.length > 0) {
            for (var i = 0; i < event.target.files.length; i++) {
                if (Math.round((event.target.files[i].size / 1024)) <= 4403) {
                    let file = event.target.files[i];
                    let reader = new FileReader();
                    reader.onload = e => {
                        var fileContents = reader.result.split(',')[1]
                        this.additionalUploadPhotos.push({ 'fileName': file.name, 'base64': fileContents, 'recordId': this.applicationId, 'stagName': this.stageName });
                    };
                    reader.readAsDataURL(file);
                }
            }
        }
    }

    handleSavePhotso() {
        var isValid = true;
        let inputFields = this.template.querySelectorAll('.validatePhoto');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if (isValid) {
            if (this.additionalUploadPhotos.length > 35) {
                this.toast('Error', 'Error', 'You can not select more than 35 Photos');
            }
            else {
                if (this.additionalUploadPhotos.length) {
                    this.indexNumber = 0;
                    this.isSpinnerActive = true;
                    var actualBase64Data = this.additionalUploadPhotos[0].base64;
                    if (this.chunkSize > actualBase64Data.length) {
                        this.uploadPhoto(this.additionalUploadPhotos[0], null, null, this.chunkSize, actualBase64Data);
                    }
                    else {
                        var photoData = this.additionalUploadPhotos[0];
                        photoData.base64 = photoData.base64.substring(0, this.chunkSize);
                        this.uploadPhoto(photoData, null, null, this.chunkSize, actualBase64Data);
                    }
                }
            }
        }
    }

    handleAddtionalDocumentChange(event) {
        var name = event.target.name;
        if (name === 'Description') {
            this.addtionalDocData.description = event.target.value;
        }
        if (name === 'Addtional Document') {
            const file = event.target.files[0]
            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                var additionalFileData = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.applicationId
                }
                this.addtionalDocData.additionalDocument = additionalFileData;
            }
            reader.readAsDataURL(file)
        }
        console.log('addtionalDocData ', JSON.stringify(this.addtionalDocData));
    }

    uploadPhoto(jsonData, base64, recordId, chunkSize, actualBase64Data) {
        uploadPhotos({ jsonPhotoData: JSON.stringify(jsonData), base64: JSON.stringify(base64), recordId: recordId, conVerType: this.selectedConVerType })
            .then(result => {
                this.isUploadPhoto = false;
                if (actualBase64Data.length > chunkSize) {
                    var proviousChunkSize = chunkSize;
                    chunkSize = actualBase64Data.length > chunkSize + chunkSize ? chunkSize + chunkSize : actualBase64Data.length;
                    console.log('chunk range ', proviousChunkSize + ' - ', chunkSize + ' - ' + result);
                    this.uploadPhoto(null, actualBase64Data.substring(proviousChunkSize, chunkSize), result, chunkSize, actualBase64Data);
                }
                else {
                    this.indexNumber++;
                    if (this.additionalUploadPhotos.length > this.indexNumber) {
                        actualBase64Data = this.additionalUploadPhotos[this.indexNumber].base64;
                        if (this.additionalUploadPhotos[this.indexNumber].base64.length > this.chunkSize) {
                            this.additionalUploadPhotos[this.indexNumber].base64 = this.additionalUploadPhotos[this.indexNumber].base64.substring(0, this.chunkSize);
                        }
                        this.uploadPhoto(this.additionalUploadPhotos[this.indexNumber], null, null, this.chunkSize, actualBase64Data);
                    }
                    else {
                        this.toast('Success', 'Success', 'All Photos Uploaded Successfully');
                        this.indexNumber = 0;
                        this.isSpinnerActive = false;
                    }
                }
            })
            .catch(error => {
                console.log('getting Error', error);
                this.isSpinnerActive = false;
            })
    }

    handleSaveAddNewDocument() {
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
            var additionalDocs = [];
            console.log('addtionalDocData ', JSON.stringify(this.addtionalDocData));
            this.isSpinnerActive = true;
            this.addtionalDocData.uploadedFrom = this.stageName;
            additionalDocs.push(JSON.parse(JSON.stringify(this.addtionalDocData)));
            console.log('addtionalDocData ', JSON.stringify(additionalDocs));
            this.template.querySelector('iframe').contentWindow.postMessage(JSON.stringify(additionalDocs), '*');
            window.addEventListener('message', (message) => {
                if (message.data) {
                    this.isAddtionalDocument = false;
                    this.isSpinnerActive = false;
                    this.addtionalDocData.additionalDocument = null;
                    this.addtionalDocData.description = null;
                    this.toast('Success', 'Success', 'Document Uploaded Successfully');
                }
            });
        }
    }

    @api
    checkAllRequiredDocument() {
        var finalValidation = [];
        var applicationValidation = [];
        var applicantValidation = [];
        var assetValidation = [];
        var applicantFamily = [];
        var assetFamily = [];
        getAllDocuments({ applicationId: this.applicationId, documentType: 'All', documentTypeId: null, stageName: this.stageName })
            .then(result => {
                if (result && result.setCodeRecoords) {
                    result.setCodeRecoords.forEach(element => {
                        if(element.Status__c === 'Received' && element.Document_Family__c && element.Type__c === 'Applicant' && !applicantFamily.includes(element.Document_Family__c+'-'+element.Loan_Applicant__c)){
                            applicantFamily.push(element.Document_Family__c+'-'+element.Loan_Applicant__c);
                        }
                        if(element.Status__c === 'Received' && element.Document_Family__c && element.Type__c === 'Asset' && !assetFamily.includes(element.Document_Family__c+'-'+element.Property__c)){
                            assetFamily.push(element.Document_Family__c+'-'+element.Property__c);
                        }
                        if (element.Type__c === 'Application' && element.Mandatory__c === 'Yes' && (element.Status__c === 'Not Received' || (element.Status__c === 'Deferred' && element.Deferral_Stage__c === this.stageName))) {
                            applicantValidation.push({ 'documentName': element.Document_Name__c, 'documentType': element.Type__c });
                        }
                        if (!applicantFamily.includes(element.Document_Family__c+'-'+element.Loan_Applicant__c) && element.Type__c === 'Applicant' && element.Mandatory__c === 'Yes' && (element.Status__c === 'Not Received' || (element.Status__c === 'Deferred' && element.Deferral_Stage__c === this.stageName))) {
                            applicantValidation.push({ 'documentName': element.Document_Name__c, 'documentType': element.Type__c,'customerType': element.Loan_Applicant__r.Customer_Type__c,'customerName': element.Applicable_Name__c});
                        }
                        if (!assetFamily.includes(element.Document_Family__c+'-'+element.Property__c) && element.Type__c === 'Asset' && element.Mandatory__c === 'Yes' && (element.Status__c === 'Not Received' || (element.Status__c === 'Deferred' && element.Deferral_Stage__c === this.stageName))) {
                            assetValidation.push({ 'documentName': element.Document_Name__c, 'documentType': element.Type__c, 'propertyType': element.Property_Type__c, 'propertyName': element.Property__r.Name});
                        }
                    });
                }
                finalValidation.push(...applicationValidation);
                finalValidation.push(...applicantValidation);
                finalValidation.push(...assetValidation);
                console.log(':: finalValidation :: ', JSON.stringify(finalValidation));
                const docEvent = new CustomEvent("requireddocument", {
                    detail: finalValidation
                });
                this.dispatchEvent(docEvent);
            }).catch(error => {
                console.log('Error In checkAllRequiredDocument', error);
            });
    }

    @track newRecord = {
        Document_Name__c: null,
        Status__c: 'Not Received',
        isNewRowAdded: true,
        Mandatory__c: null,
        fileData: null,
        Deferral_Stage__c: null,
        Stage__c: null,
        isFileUploadDisabled: true,
        isStageDisabled: false,
        isStageRequired: true,
        isReceivedDateDisabled: true,
        isNoOfPagesDisbaled: true,
        isOriginalDisabled: true,
        isDeferredDateDisabled: true,
        isWaiverReasonDisabled: true
    }
}