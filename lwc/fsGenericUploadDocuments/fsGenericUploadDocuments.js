import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import businessDate from '@salesforce/label/c.Business_Date';
import siteURL from '@salesforce/label/c.Site_URL';
import { setDeferralPicklistValue } from './fsGenericUploadDocumentsHelper';
import { handleUploadPhotos } from './fsGenericUploadDocumentsHelper';
import { documentMasterOption } from './fsGenericUploadDocumentsHelper';
import { assignStatusField } from './fsGenericUploadDocumentsHelper';
import { currentStageDocuments } from './fsGenericUploadDocumentsHelper';
import { stringToDate } from './fsGenericUploadDocumentsHelper';
import { removeDuplicate } from './fsGenericUploadDocumentsHelper';
import { newRowDocumentRecord } from './fsGenericUploadDocumentsHelper';
import { setAllRecordData } from './fsGenericUploadDocumentsHelper';
import getAllRequiredData from '@salesforce/apex/fsGenericUploadDocumentsController.getAllRequiredData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import STATUS_FIELD from '@salesforce/schema/ContentVersion.Status__c';
import TYPE_FIELD from '@salesforce/schema/Document_Master__c.Type__c';
import AGREEMENT_DOCUMENT_TYPE_FIELD from '@salesforce/schema/ContentVersion.Agreement_Document_Type__c';
import DOCUMENT_CONDITION_FIELD from '@salesforce/schema/ContentVersion.Document_Condition__c';
import createDeferralRecord from '@salesforce/apex/fsGenericUploadDocumentsController.createDeferralRecord';
import getUploadedData from '@salesforce/apex/fsGenericUploadDocumentsController.getUploadedData';
import uploadAddtionalDocument from '@salesforce/apex/fsGenericUploadDocumentsController.uploadAddtionalDocument';
import uploadPhotos from '@salesforce/apex/fsGenericUploadDocumentsController.uploadPhotos';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import formFactorName from '@salesforce/client/formFactor';
import updateContentVersion from '@salesforce/apex/fsGenericUploadDocumentsController.updateContentVersion';
import uploadedDocuments from '@salesforce/apex/fsGenericUploadDocumentsController.uploadedDocuments';


export default class FsGenericUploadDocuments extends NavigationMixin(LightningElement) {
    @api stageName;
    @api applicationId;
    @api recordTypeId;
    @api isAgreementExecution;

    @track value = 'Mandatory';
    @track additionalUploadPhotos = [];
    @track addtionalDocData = {}
    @track listOfDocumentMaster;
    @track listOfDocumentSetCode;
    @track listOfLoanApplicant;
    @track listOfProperty;
    @track listOfEmpoymentDetails;
    @track listOfDeferralDocument;
    @track listOfContentVersion;
    @track listOfUploadedDef;
    @track documentData;
    @track mapOfContentVersion;
    @track mapOfDeferralDocument;
    @track listOfDeferralMasterDocumentDocument;
    @track applicationJSON = [];
    @track applicantJSON = [];
    @track propertyJSON = []
    @track documentMasterIds = [];
    @track picklistOption = [];
    fileData;
    additionalFileData;

    @track typePicklistOption = [];
    @track statusPicklistOption = [];
    @track deferalPicklistOption;
    @track applicantPicklistOption;
    @track assetPicklistOption;
    @track agreementDocumentTypePicklistOption;
    @track documentConditionPicklistOption;
    @track documentMasterOptions;
    @track originalPicklistOption = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ]

    @track propertyIds = [];
    @track applicantId;
    @track isSaveDisabled = true;
    @track isSpinnerActive = true;
    @track currentDocumentType;
    @track tabName = 'Upload';
    @track isTypeApplicant;
    @track isTypeAsset;
    @track isButtonFlag;
    @track selectOptionTypeValue;
    @track isAddtionalDocument;
    @track headerDetails;
    @track userName;
    @track isStageFIVBorFIVC = false
    @track isUploadPhoto = false;
    @track isTypeAllorMandatory = false;
    @track isRecordSelected = false;
    @track isApplicantSelected = false;
    @track isAssetSelected = false;
    @track customerName;
    @track customerType;
    @track isChecked = false;
    @track allAvailableDocuments;
    @track businessDate;
    @track isLoading = false;
    @track indexNumber = 0;
    @track collectedDocuments = [];
    @track isShowPage = false;
    @track chunkSize = 2000000;

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userName = data.fields.Name.value;
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
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: AGREEMENT_DOCUMENT_TYPE_FIELD })
    picklistAgreementDocumentValues({ error, data }) {
        if (data) {
            this.agreementDocumentTypePicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: TYPE_FIELD })
    picklistTypeValues({ error, data }) {
        if (data) {
            let temp = { label: 'All', value: 'All' };
            let tempobj = { label: 'Mandatory', value: 'Mandatory' };
            this.typePicklistOption = data.values;
            this.typePicklistOption = [...this.typePicklistOption, temp];
            this.typePicklistOption = [...this.typePicklistOption, tempobj];
            this.typePicklistOption.sort((a, b) => (a.label > b.label) ? 1 : ((b.label > a.label) ? -1 : 0));
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: STATUS_FIELD })
    picklistStatusValues({ error, data }) {
        if (data) {
            data.values.forEach(item => {
                this.statusPicklistOption.push({ label: item.label, value: item.value, disabled: item.value === 'Waived' && this.stageName != 'Document Deferral' ? true : null });
            });
            if (this.statusPicklistOption && this.statusPicklistOption.length) {
                this.assignStatus();
            }
        } else if (error) {
            console.log(error);
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

    connectedCallback() {
        this.getAllRequiredData();
        this.deferalPicklistOption = [];
        this.businessDate = stringToDate(businessDate, "dd-mm-yyyy", "/", "-");
        this.deferalPicklistOption = setDeferralPicklistValue(this.stageName);
        if (this.stageName === 'FIV - B' || this.stageName === 'FIV - C') {
            this.isStageFIVBorFIVC = true;
        }
    }

    @api
    getAllRequiredData() {
        getAllRequiredData({ stageName: this.stageName, applicationId: this.applicationId, recordTypeId: this.recordTypeId })
            .then(result => {
                console.log('getAllRequiredData Result ', result);
                this.listOfDocumentMaster = result.listOfDocumentMaster;
                this.listOfDocumentSetCode = result.listOfDocumentSetCode;
                this.listOfLoanApplicant = result.listOfLoanApplicant;
                this.listOfProperty = result.listOfProperty;
                this.listOfEmpoymentDetails = result.listOfEmpoymentDetails;
                this.mapOfContentVersion = result.mapOfContentVersion;
                this.mapOfDeferralDocument = result.mapOfDeferralDocument;
                this.listOfDeferralMasterDocumentDocument = result.listOfDeferralMasterDocumentDocument;
            }).catch(error => {
                console.log('Error in getAllRequiredData', error);
            }).finally(() => {
                this.setApplicantPicklistValues();
                this.setPropertyPicklistValues();
                this.setAllData();
                if (this.listOfDocumentMaster && this.listOfDocumentMaster.length) {
                    this.documentMasterOptions = JSON.parse(JSON.stringify(documentMasterOption(this.listOfDocumentMaster, this.value, this.documentMasterIds)));
                }
            });
    }
    handleSaveVariousDocument() {
        var isValidInputText = this.handleEditValidation();
        var isValidInputTextArea = this.handleTextAreaValidation();
        var isValidCombo = this.handleComboValidation();
        if (!isValidInputText || !isValidInputTextArea || !isValidCombo) {
            this.toast('Error', 'Error', 'Complete Required Field.');
        } else {
            this.isLoading = true;
            // setTimeout(() => {
            //     this.finalSubmit(this.documentData, this.indexNumber);  
            // }, 500);       
            this.finalSubmit(this.documentData, this.indexNumber);
        }
    }

    finalSubmit(actualData, indexNumber) {
        this.isSaveDisabled = true;
        var element = actualData[indexNumber];
        if ((element.status === 'Received') && element.fileData && element.fileData.base64) {
            this.isLoading = true;
            if (element.versionNumber) {
                element.versionNumber = Number(element.versionNumber) + 1;
            }
            else {
                element.versionNumber = 1;
            }
            element.deferredDate = element.deferredDate ? element.deferredDate : null;
            this.listOfProperty.forEach(property => {
                if (element.propertyId == property.Id && property.Property__c) {
                    element.parentPropertyId = property.Property__c;
                }
            });
            element.currentStageName = this.stageName;
            this.fireToComponent(element, actualData, indexNumber);
            element.isNewRowAdded = false;
            element.isStatusDisabled = true;
        } else if ((element.status === 'Deferred' || element.status === 'Waived' || element.status === 'Not Received') && element.fileData === null) {
            this.isLoading = true;
            if (element.status === 'Deferred' || element.status === 'Waived') {
                element.isDeferred = true;
            }
            if (element.status === 'Not Received' && element.isNewRowAdded) {
                element.status = 'Deferred';
                element.isDeferred = false;
                element.receivedDate = null;
                element.deferredRequired = true;
                element.deferredDate = this.todayDate;
                element.applicantId = null;
                element.propertyId = null;
            }
            this.listOfProperty.forEach(property => {
                if (element.propertyId == property.Id && property.Property__c) {
                    element.parentPropertyId = property.Property__c;
                }
            });

            console.log('ELEMENT ', JSON.stringify(element));
            createDeferralRecord({ data: JSON.stringify(element), currentStageName: this.stageName, recordId: this.applicationId })
                .then(result => {
                    element.deferredStageDisable = true;
                    element.deferredRequired = false;
                    element.isReceivedDateRequired = false;
                    element.receivedDateDisable = true;
                    element.isWaiverRequired = false;
                    element.waiverReasonDisable = true;
                    element.isFileUploadDisabled = true;
                    element.isFileUploadRequired = false;
                    if (element.status === 'Waived') {
                        element.isStatusDisabled = true;
                    }
                    if (!element.isDeferred) {
                        element.deferredDate = null;
                    }
                    element.isoriginalDisabled = true;
                    element.fileName = '';
                    element.deferalRecordId = result.deferalRecordId;
                    this.savedDocumentsRecords(element);
                    this.toast('Success', 'Success', 'Document Waived Or Deferred Successfully');
                    indexNumber++;
                    if (indexNumber < actualData.length) {
                        this.isLoading = true;
                        this.finalSubmit(actualData, indexNumber);
                    }
                    else {
                        this.isLoading = false;
                        this.fireToPage();
                    }
                })
                .catch(error => {
                    console.log('error', error);
                    indexNumber++;
                    if (indexNumber < actualData.length) {
                        this.finalSubmit(actualData, indexNumber);
                    }
                    else {
                        this.isLoading = false;
                        this.fireToPage();
                    }
                });
            element.isNewRowAdded = false;
            element.isStatusDisabled = false;
        }
        else if (element.status === 'Received' && !element.fileData && element.contentDocumentId && element.remarks) {
            updateContentVersion({ contentDocumentId: element.contentDocumentId, remarks: element.remarks })
                .then(result => {
                    //this.toast('Success', 'Success', 'Document updated Successfully');
                    indexNumber++;
                    this.savedDocumentsRecords(element);
                    if (indexNumber < actualData.length) {
                        this.isLoading = true;
                        this.finalSubmit(actualData, indexNumber);
                    }
                    else {
                        this.isLoading = false;
                        this.fireToPage();
                    }
                });
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

    handleComboboxChange(event) {
        console.log('name :: ', event.target.name);
        console.log('value :: ', event.target.value);
        var name = event.target.name;
        var value = event.target.value;
        var allDocuments = [];

        this.isTypeApplicant = false;
        this.isTypeAsset = false;
        this.isButtonFlag = true;
        this.documentData = undefined;
        this.headerDetails = undefined;
        this.isTypeAllorMandatory = false;
        this.isChecked = false;

        if (name === 'type-picklist' || name === 'applicant-picklist' || name === 'asset-picklist') {
            this.isSpinnerActive = true;
            setTimeout(() => {
                this.isSpinnerActive = false;
            }, 1000);
        }

        if (value === 'Application' || value === 'Applicant' || value === 'Asset' || value === 'All' || value === 'Mandatory') {
            this.currentDocumentType = value;
            this.documentMasterOptions = [];
            this.documentMasterOptions = JSON.parse(JSON.stringify(documentMasterOption(this.listOfDocumentMaster, value, this.documentMasterIds)));
        }
        if (name === 'type-picklist' && value === 'Application') {
            this.isSaveDisabled = true;
            this.selectOptionTypeValue = '';
            this.selectOptionTypeValue = value;
            if (this.applicationJSON.length > 0) {
                var counter = 0;
                this.applicationJSON.forEach(element => {
                    element.serialNumber = Number(counter) + Number(1)
                    counter++;
                })
                this.documentData = this.applicationJSON;
            }

        }
        else if (name === 'type-picklist' && value === 'Applicant') {
            this.isTypeApplicant = true;
            this.isTypeAsset = false;
            this.isButtonFlag = false;
            this.documentData = undefined;
            this.selectOptionTypeValue = '';
            this.selectOptionTypeValue = value;
        }
        else if (name === 'applicant-picklist') {
            this.isSaveDisabled = true;
            this.isTypeApplicant = true;
            this.isButtonFlag = true;
            var counter = 0;
            var tempApplicantJSON = []
            this.applicantId = value;
            this.applicantJSON.forEach(element => {
                if (element.applicantId === value && (element.customerType === element.applicableFor || element.applicableFor === 'All' || element.isDocumentMaster)) {
                    this.headerDetails = element.customerType + ' - ' + element.customerName;
                    element.serialNumber = Number(counter) + Number(1)
                    tempApplicantJSON.push(element);
                    counter++;
                }
            })
            this.documentData = tempApplicantJSON;
        }

        else if (name === 'type-picklist' && value === 'Asset') {
            this.isTypeApplicant = false;
            this.isTypeAsset = true;
            this.isButtonFlag = false;
            this.documentData = undefined;
            this.selectOptionTypeValue = '';
            this.selectOptionTypeValue = value;
        }
        else if (name === 'asset-picklist') {
            this.isSaveDisabled = true;
            this.isButtonFlag = true;
            this.isTypeAsset = true;
            var counter = 0;
            var tempAssetJSON = []
            this.propertyIds = value.split('-');
            var propertyName;
            var propertyType;
            this.listOfProperty.forEach(element => {
                if (element.Id === this.propertyIds[0]) {
                    propertyName = element.Name;
                    propertyType = element.Property_Type__c;
                }
            })
            this.propertyJSON.forEach(element => {
                if (element.propertyId === this.propertyIds[0] || element.parentPropertyId === this.propertyIds[1]) {
                    if (element.applicableFor === propertyType || element.applicableFor === 'All' || element.isDocumentMaster) {
                        this.headerDetails = propertyType + '-' + propertyName;
                        element.serialNumber = Number(counter) + Number(1),
                            element.propertyId = this.propertyIds[0];
                        element.parentPropertyId = this.propertyIds[1];
                        tempAssetJSON.push(element);
                        counter++;
                    }
                }
            })
            this.documentData = tempAssetJSON;
        }
        else if (value === 'All') {
            this.isSaveDisabled = true;
            this.isButtonFlag = true;
            this.isTypeAllorMandatory = true;
            this.selectOptionTypeValue = '';
            this.selectOptionTypeValue = (value === undefined ? this.value : value);
            if (this.applicationJSON.length > 0) {
                var counter = 0;
                this.applicationJSON.forEach(element => {
                    element.serialNumber = Number(counter) + Number(1)
                    allDocuments.push(element);
                    counter++;
                })
            }
            this.applicantJSON.forEach(element => {
                element.serialNumber = Number(counter) + Number(1);
                allDocuments.push(element);
                counter++;
            })
            this.propertyIds = value.split('-');
            var propertyName;
            var propertyType;
            this.listOfProperty.forEach(element => {
                if (element.Id === this.propertyIds[0]) {
                    propertyName = element.Name;
                    propertyType = element.Property_Type__c;
                }
            })
            this.propertyJSON.forEach(element => {
                element.serialNumber = Number(counter) + Number(1);
                allDocuments.push(element);
                counter++;
            })
            this.documentData = allDocuments;
        }
        else if (value === 'Mandatory') {
            this.isButtonFlag = true;
            this.mandatoryDocuments();
        }
        this.assignStatus();
    }

    assignStatus() {
        if (this.documentData && this.documentData.length) {
            this.documentData = JSON.parse(JSON.stringify(assignStatusField(this.documentData, this.statusPicklistOption, this.stageName)));
            this.documentData.forEach(element => {
                if (element.status === 'Received') {
                    element.isFileUploadDisabled = false;
                    element.isFileUploadRequired = false;
                    element.isRemarksDisbable = true;
                }
                if (element.status === 'Deferred') {
                    element.isStatusDisabled = false;
                }
            });
            this.allAvailableDocuments = JSON.parse(JSON.stringify(this.documentData))
        }
    }

    selectOptionChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        var rowNo = event.target.getAttribute("data-row-index");
        this.isSaveDisabled = false;
        //console.log('rowNo from select Option:: ', value);
        //console.log('rowNo from select Option:: ', JSON.stringify(this.documentData[rowNo]));

        if (this.documentData[rowNo]['isNewRowAdded'] && (this.selectOptionTypeValue === 'All' || this.selectOptionTypeValue === 'Mandatory')) {
            this.listOfDocumentMaster.forEach(item => {
                if (item.Id === value.split('-')[0] && (item.Type__c === 'Applicant' || item.Type__c === 'Asset')) {
                    this.isRecordSelected = true;
                    this.currentDocumentType = item.Type__c;
                    this.isApplicantSelected = item.Type__c === 'Applicant' ? true : false;
                    this.isAssetSelected = item.Type__c === 'Asset' ? true : false;
                }
                else if (name === 'application-documentName' && item.Type__c === 'Application') {
                    this.customerName = null;
                    this.customerType = null;
                    this.currentDocumentType = item.Type__c;
                }
            });
        }
        if(this.documentData[rowNo]['isNewRowAdded']){
            if(this.isTypeApplicant){
                this.documentData[rowNo]['applicableName'] = this.headerDetails.split(' - ')[0];
            }
            if(this.isTypeAsset){
                this.documentData[rowNo]['applicableName'] = this.headerDetails.split('-')[1]+'-'+this.headerDetails.split('-')[2];
            }
        }

        if (this.selectOptionTypeValue === 'Application' || (!this.isApplicantSelected && !this.isAssetSelected)) {
            this.documentData[rowNo]['applicationId'] = this.applicationId;
        }
        if (this.selectOptionTypeValue === 'Applicant' || (this.isApplicantSelected && !this.isAssetSelected)) {
            var splitedData = [];
            if (this.headerDetails) {
                splitedData = this.headerDetails.split(' - ');
            }
            this.documentData[rowNo]['applicationId'] = this.applicationId;
            this.documentData[rowNo]['applicantId'] = this.applicantId;
            this.documentData[rowNo]['customerName'] = splitedData.length > 0 ? splitedData[1] : this.customerName;
            this.documentData[rowNo]['customerType'] = splitedData.length > 0 ? splitedData[0] : this.customerType;
            this.documentData[rowNo]['applicableName'] = splitedData.length > 0 ? splitedData[1] : this.customerName;
        }
        if (this.selectOptionTypeValue === 'Asset' || (this.isAssetSelected && !this.isApplicantSelected)) {
            this.documentData[rowNo]['applicationId'] = this.applicationId;
            this.documentData[rowNo]['propertyId'] = this.isAssetSelected ? this.propertyId : this.propertyIds[0];
            this.documentData[rowNo]['parentPropertyId'] = this.isAssetSelected ? this.parentPropertyId : this.propertyIds[1];
            console.log('This.PropertyIds ', this.propertyIds);
        }

        if (name === 'application-status' && value === 'Received') {
            /*Received Date Related Functionality */
            this.documentData[rowNo]['receivedDateDisable'] = false;
            this.documentData[rowNo]['receivedDate'] = this.businessDate;
            this.documentData[rowNo]['isReceivedDateRequired'] = true;
            this.documentData[rowNo]['isoriginalDisabled'] = false;

            /*File Related Functionality */
            this.documentData[rowNo]['isFileUploadDisabled'] = false;
            this.documentData[rowNo]['isFileUploadRequired'] = true;

            /*Waiver Related Functionality */
            this.documentData[rowNo]['waiverReason'] = '';
            this.documentData[rowNo]['waiverReasonDisable'] = true;
            this.documentData[rowNo]['isWaiverRequired'] = false;
            /*Deferred Stage Related Funtionality*/
            this.documentData[rowNo]['deferredStageDisable'] = true;
            this.documentData[rowNo]['deferredRequired'] = false;
            this.documentData[rowNo]['stage'] = '';
            this.documentData[rowNo]['deferredDate'] = null;
        }
        if (name === 'application-status' && value === 'Waived') {
            /*Waiver Related Functionality */
            this.documentData[rowNo]['waiverReasonDisable'] = false;
            this.documentData[rowNo]['isWaiverRequired'] = true;

            /*File Related Functionality */
            this.documentData[rowNo]['fileData'] = null;
            this.documentData[rowNo]['fileName'] = '';
            this.documentData[rowNo]['isFileUploadDisabled'] = true;
            // this.documentData[rowNo]['isFileUploadDisabled'] = false;
            this.documentData[rowNo]['isFileUploadRequired'] = false;
            // this.documentData[rowNo]['isFileUploadRequired'] = true;

            /*Received Date && No Pages Related Functionality */
            this.documentData[rowNo]['receivedDate'] = null;
            //this.documentData[rowNo]['receivedDate'] = this.businessDate;
            this.documentData[rowNo]['noOfPages'] = '';
            this.documentData[rowNo]['receivedDateDisable'] = true;
            this.documentData[rowNo]['isReceivedDateRequired'] = false;
            // this.documentData[rowNo]['receivedDateDisable'] = false;
            // this.documentData[rowNo]['isReceivedDateRequired'] = true;
            this.documentData[rowNo]['original'] = '';
            this.documentData[rowNo]['isoriginalDisabled'] = true;

            /*Deferred Stage Related Funtionality*/
            this.documentData[rowNo]['deferredStageDisable'] = true;
            this.documentData[rowNo]['deferredRequired'] = false;
            this.documentData[rowNo]['stage'] = '';
            this.documentData[rowNo]['deferredDate'] = null;

        }
        if (name === 'application-status' && value === 'Deferred') {
            /*Deferral Related Functionality */
            this.documentData[rowNo]['deferredStageDisable'] = false;
            this.documentData[rowNo]['deferredRequired'] = true;

            /*File Related Functionality */
            this.documentData[rowNo]['fileData'] = null;
            this.documentData[rowNo]['fileName'] = '';
            this.documentData[rowNo]['isFileUploadDisabled'] = true;
            this.documentData[rowNo]['isFileUploadRequired'] = false;

            /*Received Date && No Pages Related Functionality */
            this.documentData[rowNo]['receivedDate'] = null;
            this.documentData[rowNo]['noOfPages'] = '';
            this.documentData[rowNo]['receivedDateDisable'] = true;
            this.documentData[rowNo]['isReceivedDateRequired'] = false;
            this.documentData[rowNo]['original'] = '';
            this.documentData[rowNo]['isoriginalDisabled'] = true;
            this.documentData[rowNo]['isDeferredDateRequired'] = true;

            /*Waiver Related Functionality */
            this.documentData[rowNo]['waiverReason'] = '';
            this.documentData[rowNo]['waiverReasonDisable'] = true;
            this.documentData[rowNo]['isWaiverRequired'] = false;
        }
        if (name === 'application-status' && value == 'Not Received') {
            /*File Related Functionality */
            this.documentData[rowNo]['fileData'] = null;
            this.documentData[rowNo]['fileName'] = '';
            this.documentData[rowNo]['isFileUploadDisabled'] = true;
            this.documentData[rowNo]['isFileUploadRequired'] = false;

            /*Deferred Stage Related Funtionality*/
            this.documentData[rowNo]['deferredStageDisable'] = this.documentData[rowNo]['isNewRowAdded'] ? false : true;
            this.documentData[rowNo]['deferredRequired'] = false;
            this.documentData[rowNo]['stage'] = '';
            this.documentData[rowNo]['deferredDate'] = null;
            this.documentData[rowNo]['isDeferredDateRequired'] = false;
            this.documentData[rowNo]['deferredRequired'] = his.documentData[rowNo]['isNewRowAdded'] ? true : false;

            /*Received Date && No Pages Related Functionality */
            this.documentData[rowNo]['receivedDate'] = null;
            this.documentData[rowNo]['noOfPages'] = '';
            this.documentData[rowNo]['receivedDateDisable'] = true;
            this.documentData[rowNo]['isReceivedDateRequired'] = false;
            this.documentData[rowNo]['original'] = '';
            this.documentData[rowNo]['isoriginalDisabled'] = true;

            /*Waiver Related Functionality */
            this.documentData[rowNo]['waiverReason'] = '';
            this.documentData[rowNo]['waiverReasonDisable'] = true;
            this.documentData[rowNo]['isWaiverRequired'] = false;
        }
        if (this.documentData[rowNo].isNewRowAdded === true && name === 'application-documentName') {
            this.documentData[rowNo]['documentName'] = this.documentMasterOptions.find(item => item.value === value).label;
            this.documentData[rowNo].documentCode = value.split('-')[1];
            this.documentData[rowNo].documentType = this.currentDocumentType;
            this.documentData[rowNo].docSetCodeId = value.split('-')[0];
            this.documentData[rowNo].isDocumentMaster = true;
            this.documentData[rowNo].isNewRowAdded = true;
        } else {
            this.documentData[rowNo][name.split('-')[1]] = value;
        }

    }
    handleAddNewDocument(event) {
        var actualData;
        if (this.selectOptionTypeValue === 'Application') {
            actualData = this.applicationJSON;
        }
        if (this.selectOptionTypeValue === 'Applicant') {
            actualData = this.applicantJSON;
        }
        if (this.selectOptionTypeValue === 'Asset') {
            actualData = this.propertyJSON;
        }
        if (this.selectOptionTypeValue === 'All' || this.selectOptionTypeValue === 'Mandatory') {
            actualData = this.documentData;
        }
        if (event.target.name === 'addNewDocument-application') {
            var isValidInputText = this.handleEditValidation();
            var isValidInputTextArea = this.handleTextAreaValidation();
            var isValidCombo = this.handleComboValidation();
            if (!isValidInputText || !isValidInputTextArea || !isValidCombo) {
                this.toast('Error', 'Error', 'Complete Required Field.');
            } else {
                if (actualData.length > 0 || this.documentData.length > 0) {
                    var tempRow = JSON.parse(JSON.stringify(newRowDocumentRecord(this.currentDocumentType, this.businessDate, this.isAgreementExecution)));
                    tempRow.serialNumber = Number(this.documentData[this.documentData.length - 1]['serialNumber']) + Number(1);
                    tempRow.localSerialNumber = Number(this.documentData[this.documentData.length - 1]['localSerialNumber']) + Number(1);
                    tempRow.isNewRowAdded = true;
                    this.documentData.push(tempRow);
                    this.assignStatus();
                    this.toast('Success', 'Success', 'New Row added successfully');
                } else {
                    this.documentData = [];
                    var tempRow = JSON.parse(JSON.stringify(newRowDocumentRecord(this.currentDocumentType, this.businessDate, this.isAgreementExecution)));
                    tempRow.serialNumber = Number(1);
                    tempRow.localSerialNumber = Number(1);
                    tempRow.isNewRowAdded = true;
                    this.documentData.push(tempRow);
                    this.assignStatus();
                    this.toast('Success', 'Success', 'New Row added successfully');
                }
            }
        }

        else if (event.target.name === 'deleteDocument-application') {
            var len = 0;
            if (this.documentData.length) {
                len = this.documentData.length - Number(1);
            }
            if (this.documentData[len].isNewRowAdded === true) {
                this.documentData.pop();
                this.allAvailableDocuments.pop();
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
    setApplicantPicklistValues() {
        this.applicantPicklistOption = [];
        console.log('this.listOfLoanApplicant #### ', JSON.stringify(this.listOfLoanApplicant));
        this.listOfLoanApplicant.forEach(element => {
            this.applicantPicklistOption.push({ label: element.Applicant_Name__c, value: element.Customer_Information__c });
        })
    }
    setPropertyPicklistValues() {
        this.assetPicklistOption = [];
        this.listOfProperty.forEach(element => {
            if (this.stageName !== 'Login') {
                this.assetPicklistOption.push({ label: element.Name, value: element.Id + '-' + element.Property__c });
            } else {
                this.assetPicklistOption.push({ label: element.Name, value: element.Id + '-' + element.Id });
            }

        })
    }
    @api
    checkAllRequiredDocument() {
        var finalValidation = [];
        var applicationValidation = [];
        var applicantValidation = [];
        var assetValidation = [];

        getUploadedData({ stageName: this.stageName, applicationId: this.applicationId })
            .then(result => {
                this.listOfContentVersion = result.listOfContentVersion;
                this.listOfUploadedDef = result.listOfDeferralDocument;
            }).catch(error => {

            }).finally(() => {
                var cvApplicationIds = []
                var cvApplicantIds = []
                var cvAssetIds = []
                this.listOfContentVersion.forEach(cv => {
                    if (cv.Document_Type__c === 'Application') {
                        cvApplicationIds.push(cv.Parent_Id__c);
                    }
                    if (cv.Document_Type__c === 'Applicant') {
                        cvApplicantIds.push(cv.Current_Record_Id__c);
                    }
                    if (cv.Document_Type__c === 'Asset') {
                        cvAssetIds.push(cv.Current_Record_Id__c);
                    }
                });

                console.log('listOfUploadedDef ', JSON.stringify(this.listOfUploadedDef));
                this.listOfUploadedDef.forEach(def => {
                    if (def.Type__c === 'Application') {
                        cvApplicationIds.push(def.Application__c);
                    }
                    if (def.Type__c === 'Applicant' && def.Current_Record_Id__c && !cvApplicantIds.includes(def.Current_Record_Id__c)) {
                        cvApplicantIds.push(def.Current_Record_Id__c);
                    }
                    if (def.Type__c === 'Asset' && def.Current_Record_Id__c && !cvApplicantIds.includes(def.Current_Record_Id__c)) {
                        cvAssetIds.push(def.Current_Record_Id__c);
                    }
                });
                console.log('this.applicationJSON $$$$$ ', JSON.stringify(this.applicationJSON));
                console.log('cvApplicationIds ', cvApplicationIds);
                console.log('cvApplicantIds ', cvApplicantIds);
                this.applicationJSON.forEach(element => {
                    if ((element.status === 'Not Received' && element.mandatory === 'Yes' && element.docReceivedStage === this.stageName) || (element.mandatory === 'Yes' && this.stageName === element.stage && element.status === 'Deferred')) {
                        var requireData = {
                            'documentName': element.documentName,
                            'documentType': element.documentType,
                        }
                        applicationValidation.push(requireData);
                    }
                });
                //Applicant Related Validation
                this.applicantJSON.forEach(element => {
                    if ((element.status === 'Not Received' && element.mandatory === 'Yes' && !cvApplicantIds.includes(element.applicantId) && element.docReceivedStage === this.stageName) || (element.mandatory === 'Yes' && this.stageName === element.stage && element.status === 'Deferred')) {
                        var requireData = {
                            'documentName': element.documentName,
                            'documentType': element.documentType,
                            'customerType': element.customerType,
                            'customerName': element.customerName,
                        }
                        applicantValidation.push(requireData);
                    }
                });
                //Property Related Validation
                console.log('this.propertyJSON ', JSON.stringify(this.propertyJSON))
                console.log('this.cvAssetIds ', JSON.stringify(cvAssetIds))
                this.propertyJSON.forEach(element => {
                    if ((element.status === 'Not Received' && element.mandatory === 'Yes' && !cvAssetIds.includes(element.propertyId) && element.docReceivedStage === this.stageName) || (element.mandatory === 'Yes' && this.stageName === element.stage && element.status === 'Deferred')) {
                        var requireData = {
                            'documentName': element.documentName,
                            'documentType': element.documentType,
                            'propertyType': element.propertyType,
                            'propertyName': element.propertyName,
                        }
                        assetValidation.push(requireData);
                    }
                });
                finalValidation.push(...applicationValidation);
                finalValidation.push(...applicantValidation);
                finalValidation.push(...assetValidation);
                console.log(':: finalValidation :: ', JSON.stringify(finalValidation));
                const docEvent = new CustomEvent("requireddocument", {
                    detail: finalValidation
                });
                this.dispatchEvent(docEvent);
            });
    }

    setAllData() {
        this.applicationJSON = [];
        this.applicantJSON = [];
        this.propertyJSON = []
        /** For Show All Document Master Record */
        this.documentMasterIds = []

        var dataobject = setAllRecordData(this.listOfDeferralMasterDocumentDocument, this.stageName, this.isAgreementExecution, this.mapOfDeferralDocument, this.mapOfContentVersion, this.listOfDocumentSetCode, this.applicationId, this.listOfLoanApplicant, this.listOfEmpoymentDetails, this.listOfProperty);

        this.applicationJSON = JSON.parse(JSON.stringify(dataobject.applicationJSON));
        this.applicantJSON = JSON.parse(JSON.stringify(dataobject.applicantJSON));
        this.propertyJSON = JSON.parse(JSON.stringify(dataobject.propertyJSON));
        this.documentMasterIds = JSON.parse(JSON.stringify(dataobject.documentMasterIds));

        this.applicationJSON.sort((a, b) => (a.docReceivedStage > b.docReceivedStage) ? 1 : ((b.docReceivedStage > a.docReceivedStage) ? -1 : 0));
        this.applicantJSON.sort((a, b) => (a.docReceivedStage > b.docReceivedStage) ? 1 : ((b.docReceivedStage > a.docReceivedStage) ? -1 : 0));
        this.propertyJSON.sort((a, b) => (a.docReceivedStage > b.docReceivedStage) ? 1 : ((b.docReceivedStage > a.docReceivedStage) ? -1 : 0));

        this.applicationJSON = JSON.parse(JSON.stringify(removeDuplicate(this.applicationJSON)));
        this.applicantJSON = JSON.parse(JSON.stringify(removeDuplicate(this.applicantJSON)));
        this.propertyJSON = JSON.parse(JSON.stringify(removeDuplicate(this.propertyJSON)));

        setTimeout(() => {
            this.mandatoryDocuments();
            this.isSpinnerActive = false;
        }, 500);
    }

    mandatoryDocumentValidation() {
        var mandatoryDocuments = [];
        this.applicationJSON(element => {
            if (element.mandatory === 'Yes' && element.stage !== 'Deferred' && element.stage !== 'Waived') {
                var details = 'Upload Application Type Document - ' + element.documentName;
                mandatoryDocuments.push(details);
            }
        })
    }
    toast(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: variant,
            message: message
        })
        this.dispatchEvent(toastEvent)
    }
    /**
     *  ====== File Upload Functionality ======
     */
    openfileUpload(event) {
        this.isSaveDisabled = false;
        var rowNo = event.target.getAttribute("data-row-index");
        var sr = Number(rowNo) + Number(1);

        if (this.documentData[rowNo]['documentName'] === '' && this.documentData[rowNo]['isNewRowAdded'] === true) {
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
                        'filename': this.documentData[rowNo].documentName + '.' + file.name.substr(file.name.lastIndexOf('.') + 1),
                        'base64': base64,
                        'recordId': this.applicationId
                    }
                    this.documentData[rowNo].fileName = this.fileData.filename;
                    this.documentData[rowNo].fileData = JSON.parse(JSON.stringify(this.fileData));
                    this.documentData[rowNo].receivedDateDisable = false;
                    this.documentData[rowNo].isoriginalDisabled = false;
                    this.documentData[rowNo].isReceivedDateRequired = true;
                    this.documentData[rowNo].isRemarksDisbable = false;
                }
                reader.readAsDataURL(file)
            }
            else {
                this.toast('Error', 'Error', 'please select a file less than 35 MB');
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
                this.additionalFileData = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.applicationId
                }
                this.addtionalDocData.additionalDocument = this.additionalFileData;
            }
            reader.readAsDataURL(file)
        }
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
            var addiotionalDocs = [];
            this.isSpinnerActive = true;
            var cvData = this.addtionalDocData;
            cvData.uploadedFrom = this.stageName;
            addiotionalDocs.push(JSON.parse(JSON.stringify(cvData)));
            console.log('this.addtionalDocData.additionalDocument ', cvData);
            this.template.querySelector('iframe').contentWindow.postMessage(JSON.stringify(addiotionalDocs), '*');
            window.addEventListener('message', (message) => {
                if(message.data){
                    this.fileData = null
                    this.isAddtionalDocument = false;
                    this.isSpinnerActive = false;
                    //this.addtionalDocData = null;
                    this.toast('Success', 'Success', 'Document Uploaded Successfully');
                }
            });

            // uploadAddtionalDocument({ base64: cvData.base64, filename: cvData.filename, recordId: cvData.recordId, description: this.addtionalDocData.description, uploadedFrom: this.stageName })
            //     .then(result => {
            //         this.fileData = null
            //         this.isAddtionalDocument = false;
            //         this.isSpinnerActive = false;
            //         //this.addtionalDocData = null;
            //         this.toast('Success', 'Success', 'Document Uploaded Successfully');
            //     })
        }
    }
    handleUploadPhotos(event) {
        this.additionalUploadPhotos = [];
        this.additionalUploadPhotos = handleUploadPhotos(event, this.applicationId, this.stageName);
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
                    var actualBase64Data = this.additionalUploadPhotos[this.indexNumber].base64;
                    if (this.chunkSize > actualBase64Data.length) {
                        this.uploadPhoto(this.additionalUploadPhotos[this.indexNumber], null, null, this.chunkSize, actualBase64Data);
                    }
                    else {
                        var photoData = this.additionalUploadPhotos[this.indexNumber];
                        photoData.base64 = photoData.base64.substring(0, this.chunkSize);
                        this.uploadPhoto(photoData, null, null, this.chunkSize, actualBase64Data);
                    }
                }
            }
        }
    }

    uploadPhoto(jsonData, base64, recordId, chunkSize, actualBase64Data) {
        uploadPhotos({ jsonPhotoData: JSON.stringify(jsonData), base64: JSON.stringify(base64), recordId: recordId })
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

    handleAdditionalCancel() {
        this.isAddtionalDocument = false;
        this.isUploadPhoto = false;
        this.isRecordSelected = false;
        if (!this.isRecordSelected) {
            this.propertyId = null;
            this.parentPropertyId = null;
            this.customerName = null;
            this.customerType = null;
            this.documentData[this.documentData.length - 1]['applicableName'] = null;
        }
    }
    mandatoryDocuments() {
        var allDocuments = [];
        var value;
        this.isSaveDisabled = true;
        this.isTypeAllorMandatory = true;
        this.isButtonFlag = true;
        this.selectOptionTypeValue = '';
        this.selectOptionTypeValue = (value != undefined ? value : this.value);
        if (this.applicationJSON.length > 0) {
            var counter = 0;
            this.applicationJSON.forEach(element => {
                if (element.mandatory === 'Yes' && element.docSetCodeId) {
                    element.serialNumber = Number(counter) + Number(1)
                    allDocuments.push(element);
                    counter++;
                }
            })
        }
        this.applicantJSON.forEach(element => {
            if (element.mandatory === 'Yes' && element.docSetCodeId) {
                element.serialNumber = Number(counter) + Number(1);
                allDocuments.push(element);
                counter++;
            }
        })
        this.propertyJSON.forEach(element => {
            if (element.mandatory === 'Yes' && element.docSetCodeId) {
                element.serialNumber = Number(counter) + Number(1);
                allDocuments.push(element);
                counter++;
            }
        })
        this.documentData = allDocuments;
        if (this.documentData && this.documentData.length) {
            this.assignStatus();
        }
    }
    handleNext() {
        var isValid = true;
        let inputFields = this.template.querySelectorAll('[data-id="selectedRecord"]');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if (isValid) {
            this.isRecordSelected = false;
        }
    }
    handleRecordId(event) {
        if (this.isApplicantSelected) {
            this.applicantId = event.target.value;
            this.listOfLoanApplicant.forEach(item => {
                if (item.Customer_Information__c === this.applicantId) {
                    this.customerName = item.Applicant_Name__c;
                    this.customerType = item.Customer_Type__c;
                    this.documentData[this.documentData.length - 1]['applicableName'] = this.customerName;
                }
            });
        }
        if (this.isAssetSelected) {
            this.propertyId = event.target.value.split('-')[0];
            this.parentPropertyId = event.target.value.split('-')[1];
            this.assetPicklistOption.forEach(currentItem => {
                if (currentItem.value === event.target.value) {
                    this.documentData[this.documentData.length - 1]['applicableName'] = currentItem.label;
                }
            });
        }
    }

    handleCheckbox(event) {
        this.isSpinnerActive = true;
        this.isChecked = event.target.checked;
        if (this.isChecked) {
            this.documentData = JSON.parse(JSON.stringify(currentStageDocuments(this.stageName, this.documentData)));
            this.isSpinnerActive = false;
        }
        if (!this.isChecked) {
            this.documentData = JSON.parse(JSON.stringify(this.allAvailableDocuments));
            setTimeout(() => {
                this.isSpinnerActive = false;
            }, 1000);
        }
    }

    savedDocumentsRecords(element) {
        if (element.documentType === 'Application') {
            this.applicationJSON.forEach(currentelement => {
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Received') {
                    currentelement.isStatusDisabled = true;
                    currentelement.status = element.status;
                    currentelement.receivedDate = element.receivedDate;
                    currentelement.noOfPages = element.noOfPages;
                    currentelement.isFileUploadDisabled = false
                    currentelement.original = element.original;
                    currentelement.remarks = element.remarks;
                    currentelement.versionNumber = element.versionNumber;
                }
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Deferred') {
                    currentelement.remarks = element.remarks;
                    currentelement.status = element.status;
                    currentelement.deferredDate = element.deferredDate;
                    currentelement.stage = element.stage;
                }
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Waived') {
                    currentelement.isStatusDisabled = true;
                    currentelement.status = element.status;
                    currentelement.waiverReason = element.waiverReason;
                    currentelement.remarks = element.remarks;
                    currentelement.deferredDate = element.deferredDate
                    currentelement.stage = element.stage;
                }
            });
        }
        if (element.documentType === 'Applicant') {
            this.applicantJSON.forEach(currentelement => {
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Received' && currentelement.applicantId === element.applicantId) {
                    currentelement.isStatusDisabled = true;
                    currentelement.status = element.status;
                    currentelement.receivedDate = element.receivedDate;
                    currentelement.noOfPages = element.noOfPages;
                    currentelement.isFileUploadDisabled = false
                    currentelement.original = element.original;
                    currentelement.remarks = element.remarks;
                    currentelement.versionNumber = element.versionNumber;
                }
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Deferred' && currentelement.applicantId === element.applicantId) {
                    currentelement.remarks = element.remarks;
                    currentelement.status = element.status;
                    currentelement.deferredDate = element.deferredDate;
                    currentelement.stage = element.stage;
                }
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Waived') {
                    currentelement.isStatusDisabled = true;
                    currentelement.status = element.status;
                    currentelement.waiverReason = element.waiverReason;
                    currentelement.remarks = element.remarks;
                    currentelement.deferredDate = element.deferredDate
                    currentelement.stage = element.stage;
                }
            });
        }
        if (element.documentType === 'Asset') {
            this.propertyJSON.forEach(currentelement => {
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Received' && element.propertyId === currentelement.propertyId) {
                    currentelement.isStatusDisabled = true;
                    currentelement.status = element.status;
                    currentelement.receivedDate = element.receivedDate;
                    currentelement.noOfPages = element.noOfPages;
                    currentelement.isFileUploadDisabled = false
                    currentelement.original = element.original;
                    currentelement.remarks = element.remarks;
                    currentelement.versionNumber = element.versionNumber;

                }
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Deferred' && element.propertyId === currentelement.propertyId) {
                    currentelement.remarks = element.remarks;
                    currentelement.status = element.status;
                    currentelement.deferredDate = element.deferredDate;
                    currentelement.stage = element.stage;
                }
                if (currentelement.docSetCodeId === element.docSetCodeId && element.status === 'Waived') {
                    currentelement.isStatusDisabled = true;
                    currentelement.status = element.status;
                    currentelement.waiverReason = element.waiverReason;
                    currentelement.remarks = element.remarks;
                    currentelement.deferredDate = element.deferredDate
                    currentelement.stage = element.stage;
                }
            });
        }
    }

    fireToComponent(element, actualData, indexNumber) {
        this.isLoading = true;
        this.isShowPage = true;
        element.indexNumber = indexNumber; 
        element.documentFamily = element.documentFamily;
        this.collectedDocuments.push(JSON.parse(JSON.stringify(element)));
        indexNumber++;
        if (actualData.length > indexNumber) {
            this.finalSubmit(actualData, indexNumber);
        }
        else {
            this.isLoading = false;
            this.fireToPage();
        }
    }

    fireToPage() {
        var count = 0;
        if (this.collectedDocuments && this.collectedDocuments.length) {
            this.isLoading = true;
            this.template.querySelector('iframe').contentWindow.postMessage(JSON.stringify(this.collectedDocuments), '*');
            window.addEventListener('message', (message) => {
                if (message.data && this.collectedDocuments && this.collectedDocuments.length) {
                    uploadedDocuments({ recordId: this.applicationId })
                        .then(result => {
                            this.isShowPage = false;
                            this.isLoading = false;
                            this.collectedDocuments.forEach(element => {
                                if (result && result.hasOwnProperty(element.docSetCodeId + '-' + element.versionNumber + '-' + element.documentName)) {
                                    count++;
                                    this.toast('Success', 'Success', 'All Documents uploaded Successfully');
                                    element.deferredStageDisable = true;
                                    element.deferredRequired = false;
                                    element.isReceivedDateRequired = false;
                                    element.receivedDateDisable = true;
                                    element.isWaiverRequired = false;
                                    element.waiverReasonDisable = true;
                                    element.isFileUploadDisabled = false;
                                    element.isFileUploadRequired = false;
                                    element.isoriginalDisabled = true;
                                    element.isRemarksDisbable = false
                                    element.fileName = '';
                                    element.isStatusDisabled = true;
                                    element.deferalRecordId = '';
                                    element.fileData = null;
                                    this.fileData = null;
                                    this.documentData[element.indexNumber] = JSON.parse(JSON.stringify(element));
                                    this.savedDocumentsRecords(element);
                                    if (this.collectedDocuments.length === count) {
                                        this.collectedDocuments = [];
                                    }
                                }
                            });
                        });
                }
            });
        }
    }
}