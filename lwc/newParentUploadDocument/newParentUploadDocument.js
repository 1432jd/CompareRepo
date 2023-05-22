import { api, LightningElement, track, wire } from 'lwc';
import getAllRequiredData from '@salesforce/apex/newParentUploadDocument.getAllRequiredData';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import STATUS_FIELD from '@salesforce/schema/ContentVersion.Status__c';
import TYPE_FIELD from '@salesforce/schema/Document_Master__c.Type__c';
import DEFERAL_STAGE_FIELD from '@salesforce/schema/ContentVersion.Deferal_Stage__c';
import AGREEMENT_DOCUMENT_TYPE_FIELD from '@salesforce/schema/ContentVersion.Agreement_Document_Type__c';
import DOCUMENT_CONDITION_FIELD from '@salesforce/schema/ContentVersion.Document_Condition__c';
import createCVRecord from '@salesforce/apex/newParentUploadDocument.createCVRecord';
import createDeferralRecord from '@salesforce/apex/newParentUploadDocument.createDeferralRecord';

import getUploadedData from '@salesforce/apex/newParentUploadDocument.getUploadedData';

export default class NewParentUploadDocument extends LightningElement {
    @api stageName = 'FIV - B';
    @track applicationId = 'a030w000008J9nuAAC';
    @track recordTypeId = '0120w000001HX9OAAW';
    @track isAgreementExecution = false;
    /**
     * Data Related Variables
     */
    @track listOfDocumentSetCode;
    @track listOfLoanApplicant;
    @track listOfProperty;
    @track listOfEmpoymentDetails;
    @track listOfDeferralDocument;
    @track listOfContentVersion;
    @track listOfUploadedDef;
    @track documentData;

    @track applicationJSON = [];
    @track applicantJSON = [];
    @track propertyJSON = []

    fileData;
    /**
     * Picklist Related Variables
     */
    @track typePicklistOption;
    @track statusPicklistOption;
    @track deferalPicklistOption;
    @track applicantPicklistOption;
    @track assetPicklistOption;
    @track agreementDocumentTypePicklistOption;
    @track documentConditionPicklistOption
    @track originalPicklistOption = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ]
    /**
     * Other Variables
     */
    @track isSpinnerActive;
    @track isTypeApplicant;
    @track isTypeAsset;
    @track isButtonFlag;
    @track selectOptionTypeValue;
    @track isAddtionalDocument;
    @track headerDetails;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: DOCUMENT_CONDITION_FIELD })
    picklistDocumentConditionValues({ error, data }) {
        if (data) {
            console.log(data);
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
            this.typePicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: STATUS_FIELD })
    picklistStatusValues({ error, data }) {
        if (data) {
            this.statusPicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: DEFERAL_STAGE_FIELD })
    picklistDeferalValues({ error, data }) {
        if (data) {
            console.log(data);
            this.deferalPicklistOption = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    connectedCallback() {
        this.getAllRequiredData();
    }

    getAllRequiredData() {
        getAllRequiredData({ stageName: this.stageName, applicationId: this.applicationId, recordTypeId: this.recordTypeId })
            .then(result => {
                console.log('result :: Required Data :: ', JSON.stringify(result));
                this.listOfDocumentSetCode = result.listOfDocumentSetCode;
                this.listOfLoanApplicant = result.listOfLoanApplicant;
                this.listOfProperty = result.listOfProperty;
                this.listOfEmpoymentDetails = result.listOfEmpoymentDetails;
                //this.listOfContentVersion = result.listOfContentVersion;
                if (result.listOfDeferralSetCode.length) {
                    result.listOfDeferralSetCode.forEach(element => {
                        var defDoc = element;
                        defDoc['isDeferalRecord'] = true;
                        defDoc['deferalRecordId'] =
                            this.listOfDocumentSetCode.push(defDoc);
                    });
                    //this.listOfDocumentSetCode.push(...result.listOfDeferralSetCode);
                }
                console.log(':: listOfDocumentSetCode ## :: ', JSON.stringify(this.listOfDocumentSetCode));


            }).catch(error => {

            }).finally(() => {
                this.setApplicantPicklistValues();
                this.setPropertyPicklistValues();
                this.setAllData();
            });
    }
    handleSaveVariousDocument(event) {
        console.log(':: saved called ::');
        var isValidInputText = this.handleEditValidation();
        var isValidInputTextArea = this.handleTextAreaValidation();
        var isValidCombo = this.handleComboValidation();

        console.log('isValidInputText ### ', isValidInputText);
        console.log('isValidInputTextArea ### ', isValidInputTextArea);
        console.log('isValidCombo ### ', isValidCombo);

        if (!isValidInputText || !isValidInputTextArea || !isValidCombo) {
            this.toast('Error', 'Error', 'Complete Required Field.');
        } else {
            var actualData;
            if (this.selectOptionTypeValue === 'Application') {
                actualData = this.applicationJSON
            }
            if (this.selectOptionTypeValue === 'Applicant') {
                console.log(' :: applicantJSON :: ', JSON.stringify(this.applicantJSON));
                actualData = this.applicantJSON
            }
            if (this.selectOptionTypeValue === 'Asset') {
                console.log(' :: propertyJSON :: ', JSON.stringify(this.propertyJSON));
                actualData = this.propertyJSON
            }
            actualData.forEach(element => {
                if (element.status === 'Received' && element.fileData !== '') {
                    console.log('save element :: ', JSON.stringify(element));
                    this.isSpinnerActive = true;
                    createCVRecord({ data: JSON.stringify(element), currentStageName: this.stageName })
                        .then(result => {
                            this.isSpinnerActive = false;
                            this.toast('Success', 'Success', 'Document Uploaded Successfully');
                        })
                } else if ((element.status === 'Deferred' || element.status === 'Waived') && element.fileData === null) {
                    console.log(':: deffered called :: ' + JSON.stringify(element));
                    createDeferralRecord({ data: JSON.stringify(element), currentStageName: this.stageName, recordId: this.applicationId })
                        .then(result => {
                            this.isSpinnerActive = false;
                            this.toast('Success', 'Success', 'Document Uploaded Successfully');
                        });
                }
            });
        }
    }

    handleComboboxChange(event) {
        console.log('name :: ', event.target.name);
        console.log('value :: ', event.target.value);
        var name = event.target.name;
        var value = event.target.value;

        this.isTypeApplicant = false;
        this.isButtonFlag = true;
        this.documentData = undefined;
        this.headerDetails = undefined;
        /**
         * Use For Application Type Picklist
         */
        if (name === 'type-picklist' && value === 'Application') {
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
        /**
         * Use For Applicant Type Picklist
         */
        else if (name === 'type-picklist' && value === 'Applicant') {
            this.isTypeApplicant = true;
            this.isTypeAsset = false;
            this.isButtonFlag = false;
            this.documentData = undefined;
            this.selectOptionTypeValue = '';
            this.selectOptionTypeValue = value;
        }
        else if (name === 'applicant-picklist') {
            this.isTypeApplicant = true;
            this.isButtonFlag = true;
            var counter = 0;
            var tempApplicantJSON = []
            this.applicantJSON.forEach(element => {
                if (element.applicantId === value) {
                    console.log(':: element :: ', JSON.stringify(element));
                    this.headerDetails = element.customerType + ' - ' + element.customerName;
                    element.serialNumber = Number(counter) + Number(1)
                    tempApplicantJSON.push(element);
                    counter++;
                }
            })
            this.documentData = tempApplicantJSON;
        }

        /**
         * Use For Asset Type Picklist
         */
        else if (name === 'type-picklist' && value === 'Asset') {
            this.isTypeApplicant = false;
            this.isTypeAsset = true;
            this.isButtonFlag = false;
            this.documentData = undefined;
            this.selectOptionTypeValue = '';
            this.selectOptionTypeValue = value;
        }
        else if (name === 'asset-picklist') {
            this.isButtonFlag = true;
            var counter = 0;
            var tempApplicantJSON = []
            console.log('propertyJSON :: ', JSON.stringify(this.propertyJSON));
            this.propertyJSON.forEach(element => {
                if (element.propertyId === value) {
                    console.log(':: element :: ', JSON.stringify(element));
                    this.headerDetails = element.propertyType + '-' + element.propertyName;
                    element.serialNumber = Number(counter) + Number(1)
                    tempApplicantJSON.push(element);
                    counter++;
                }
            })
            this.documentData = tempApplicantJSON;
        }
    }


    selectOptionChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        var rowNo = event.target.getAttribute("data-row-index");

        console.log('name from select Option:: ', name);
        console.log('rowNo from select Option:: ', value);
        console.log('rowNo from select Option:: ', rowNo);
        if (this.selectOptionTypeValue === 'Application') {
            this.documentData[rowNo]['applicationId'] = this.applicationId;
        }
        if (this.selectOptionTypeValue === 'Applicant') {
            this.documentData[rowNo]['applicationId'] = this.applicationId;
            //this.documentData[rowNo]['applicantId'] = this.applicantId;
        }
        if (this.selectOptionTypeValue === 'Asset') {
            console.log(' :: propertyJSON :: ', JSON.stringify(this.propertyJSON));
        }

        if (name === 'application-status' && value === 'Received') {
            /*Received Date Related Functionality */
            this.documentData[rowNo]['receivedDateDisable'] = false;
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
            this.documentData[rowNo]['isFileUploadRequired'] = false;

            /*Received Date && No Pages Related Functionality */
            this.documentData[rowNo]['receivedDate'] = null;
            this.documentData[rowNo]['noOfPages'] = '';
            this.documentData[rowNo]['receivedDateDisable'] = true;
            this.documentData[rowNo]['isReceivedDateRequired'] = false;
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
            this.documentData[rowNo]['deferredStageDisable'] = true;
            this.documentData[rowNo]['deferredRequired'] = false;
            this.documentData[rowNo]['stage'] = '';
            this.documentData[rowNo]['deferredDate'] = null;


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
        this.documentData[rowNo][name.split('-')[1]] = value;
        console.log('after from select Option:: ', JSON.stringify(this.documentData));
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

        console.log('name :: ', event.target.name);
        console.log('actual data :: ', JSON.stringify(actualData));
        if (event.target.name === 'addNewDocument-application') {
            var isValidInputText = this.handleEditValidation();
            var isValidInputTextArea = this.handleTextAreaValidation();
            var isValidCombo = this.handleComboValidation();

            console.log('isValidInputText ### ', isValidInputText);
            console.log('isValidInputTextArea ### ', isValidInputTextArea);
            console.log('isValidCombo ### ', isValidCombo);

            if (!isValidInputText || !isValidInputTextArea || !isValidCombo) {
                this.toast('Error', 'Error', 'Complete Required Field.');
            } else {
                if (actualData.length > 0 || this.documentData.length > 0) {
                    var tempRow = JSON.parse(JSON.stringify(this.newRowDocumentRecord));
                    tempRow.serialNumber = Number(this.documentData.length) + Number(1);
                    tempRow.isNewRowAdded = true;
                    this.documentData.push(tempRow);
                } else {
                    this.documentData = [];
                    var tempRow = JSON.parse(JSON.stringify(this.newRowDocumentRecord));
                    tempRow.serialNumber = Number(1);
                    tempRow.isNewRowAdded = true;
                    this.documentData.push(tempRow);
                }
            }
        }
        else if (event.target.name === 'deleteDocument-application') {
            console.log(':: applicant data :: ', JSON.stringify(actualData.length));

            if (actualData.length >= this.documentData.length) {
                this.documentData.pop();
            } else {
                this.toast('Warning', 'Warning', 'User Don\'t Have Access To Delete Record.');
            }
        } else {
            this.isAddtionalDocument = true;
        }

    }
    handleSaveAddNewDocument() {
        this.isAddtionalDocument = false;
    }
    handleAdditionalCancel() {
        this.isAddtionalDocument = false;
    }
    /**
     *  ====== Checking Input Field Vallidation ======
     */
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
    /**
     *  ====== Set All Static Data ======
     */
    setApplicantPicklistValues() {
        this.applicantPicklistOption = [];
        this.listOfLoanApplicant.forEach(element => {
            this.applicantPicklistOption.push({ label: element.Applicant_Name__c, value: element.Customer_Information__c });
        })
    }
    setPropertyPicklistValues() {
        this.assetPicklistOption = [];
        this.listOfProperty.forEach(element => {
            this.assetPicklistOption.push({ label: element.Name, value: element.Id });
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

                this.listOfUploadedDef.forEach(def => {
                    if (def.Type__c === 'Application') {
                        cvApplicationIds.push(def.Application__c);
                    }
                    if (def.Type__c === 'Applicant') {
                        cvApplicantIds.push(def.Current_Record_Id__c);
                    }
                    if (def.Type__c === 'Asset') {
                        cvAssetIds.push(def.Current_Record_Id__c);
                    }
                });

                this.applicationJSON.forEach(element => {
                    if (element.mandatory === 'Yes' && !cvApplicationIds.includes(element.applicationId)) {
                        var requireData = {
                            'documentName': element.documentName,
                            'documentType': element.documentType,
                        }
                        applicationValidation.push(requireData);
                    }
                });
                //Applicant Related Validation
                this.applicantJSON.forEach(element => {
                    if (element.mandatory === 'Yes' && !cvApplicantIds.includes(element.applicantId)) {
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
                console.log('this.propertyJSON ',JSON.stringify(this.propertyJSON))
                console.log('this.cvAssetIds ',JSON.stringify(cvAssetIds))
                this.propertyJSON.forEach(element => {
                    if (element.mandatory === 'Yes' && !cvAssetIds.includes(element.propertyId)) {
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
                return finalValidation;
            });
    }

    setAllData() {
        this.applicationJSON = [];
        this.applicantJSON = [];
        this.propertyJSON = []
        this.listOfDocumentSetCode.forEach(element => {
            console.log('document set code element ', JSON.stringify(element));
            /**
             * Set Application JSON
             */

            if (element.Type__c === 'Application') {
                var newRowDocumentRecord = {
                    'docSetCodeId': element.Id,
                    'applicationId': this.applicationId,
                    'serialNumber': '',
                    'documentName': element.Name,
                    'documentFamily': element.Family__c,
                    'mandatory': element.Mandatory__c,
                    'documentType': element.Type__c,
                    'status': '',
                    'stage': 'Not Received',
                    'deferredStageDisable': true,
                    'deferredRequired': false,
                    'deferredDate': '',
                    'receivedDate': '',
                    'isReceivedDateRequired': false,
                    'receivedDateDisable': true,
                    'noOfPages': '',
                    'waiverReason': '',
                    'isWaiverRequired': false,
                    'waiverReasonDisable': true,
                    'remarks': '',
                    'isNewRowAdded': '',
                    'fileName': '',
                    'isFileUploadDisabled': true,
                    'isFileUploadRequired': true,
                    'original': '',
                    'isoriginalDisabled': true,
                    'fileData': '',
                    'isAgreementExecution': this.isAgreementExecution,
                }
                this.applicationJSON.push(newRowDocumentRecord);
            }

            /**
             * Set Applicant JSON
             */
            if (element.Type__c === 'Applicant') {
                if (element.Applicable_For__c === 'All' && element.Income_Type__c === 'All') {
                    console.log('** Inside first case **');
                    this.listOfLoanApplicant.forEach(loan => {
                        var newRowDocumentRecord = {
                            'docSetCodeId': element.Id,
                            'serialNumber': '',
                            'documentName': element.Name,
                            'documentFamily': element.Family__c,
                            'applicableFor': element.Applicable_For__c,
                            'mandatory': 'Yes',
                            'documentType': element.Type__c,
                            'status': '',
                            'stage': 'Not Received',
                            'deferredStageDisable': true,
                            'deferredRequired': false,
                            'deferredDate': '',
                            'receivedDate': '',
                            'isReceivedDateRequired': false,
                            'receivedDateDisable': true,
                            'noOfPages': '',
                            'waiverReason': '',
                            'isWaiverRequired': false,
                            'waiverReasonDisable': true,
                            'remarks': '',
                            'isNewRowAdded': '',
                            'fileName': '',
                            'isFileUploadDisabled': true,
                            'isFileUploadRequired': true,
                            'original': '',
                            'isoriginalDisabled': true,
                            'fileData': '',
                            'isAgreementExecution': this.isAgreementExecution,
                            'applicantId': loan.Customer_Information__c,
                            'customerType': loan.Customer_Type__c,
                            'customerName': loan.Applicant_Name__c,
                        }
                        this.applicantJSON.push(newRowDocumentRecord);
                    });

                } else {
                    if (element.Applicable_For__c === "All" && element.Income_Type__c !== "All" && !this.listOfEmpoymentDetails.length) {
                        console.log('** Inside second case ** ' + JSON.stringify(this.listOfLoanApplicant));
                        this.listOfLoanApplicant.forEach(loan => {
                            var newRowDocumentRecord = {
                                'docSetCodeId': element.Id,
                                'serialNumber': '',
                                'documentName': element.Name,
                                'documentFamily': element.Family__c,
                                'applicableFor': element.Applicable_For__c,
                                'mandatory': element.Applicable_For__c === loan.Customer_Type__c ? 'Yes' : 'No',
                                'documentType': element.Type__c,
                                'status': '',
                                'stage': 'Not Received',
                                'deferredStageDisable': true,
                                'deferredRequired': false,
                                'deferredDate': '',
                                'receivedDate': '',
                                'isReceivedDateRequired': false,
                                'receivedDateDisable': true,
                                'noOfPages': '',
                                'waiverReason': '',
                                'isWaiverRequired': false,
                                'waiverReasonDisable': true,
                                'remarks': '',
                                'isNewRowAdded': '',
                                'fileName': '',
                                'isFileUploadDisabled': true,
                                'isFileUploadRequired': true,
                                'original': '',
                                'isoriginalDisabled': true,
                                'fileData': '',
                                'isAgreementExecution': this.isAgreementExecution,
                                'applicantId': loan.Customer_Information__c,
                                'customerType': loan.Customer_Type__c,
                                'customerName': loan.Applicant_Name__c,
                            }
                            this.applicantJSON.push(newRowDocumentRecord);
                        });

                    }
                    else if (element.Applicable_For__c !== "All" && element.Income_Type__c === "All" && !this.listOfEmpoymentDetails.length) {
                        console.log('** Inside third case **');
                        this.listOfLoanApplicant.forEach(loan => {
                            var newRowDocumentRecord = {
                                'docSetCodeId': element.Id,
                                'serialNumber': '',
                                'documentName': element.Name,
                                'documentFamily': element.Family__c,
                                'applicableFor': element.Applicable_For__c,
                                'mandatory': element.Applicable_For__c === loan.Customer_Type__c ? 'Yes' : 'No',
                                'documentType': element.Type__c,
                                'status': '',
                                'stage': 'Not Received',
                                'deferredStageDisable': true,
                                'deferredRequired': false,
                                'deferredDate': '',
                                'receivedDate': '',
                                'isReceivedDateRequired': false,
                                'receivedDateDisable': true,
                                'noOfPages': '',
                                'waiverReason': '',
                                'isWaiverRequired': false,
                                'waiverReasonDisable': true,
                                'remarks': '',
                                'isNewRowAdded': '',
                                'fileName': '',
                                'isFileUploadDisabled': true,
                                'isFileUploadRequired': true,
                                'original': '',
                                'isoriginalDisabled': true,
                                'fileData': '',
                                'isAgreementExecution': this.isAgreementExecution,
                                'applicantId': loan.Customer_Information__c,
                                'customerType': loan.Customer_Type__c,
                                'customerName': loan.Applicant_Name__c,
                            }
                            this.applicantJSON.push(newRowDocumentRecord);
                        });

                    }
                    else if (element.Applicable_For__c !== "All" && element.Income_Type__c !== "All" && !this.listOfEmpoymentDetails.length) {
                        console.log('** Inside fourth case **');
                        this.listOfLoanApplicant.forEach(loan => {
                            var newRowDocumentRecord = {
                                'docSetCodeId': element.Id,
                                'serialNumber': '',
                                'documentName': element.Name,
                                'documentFamily': element.Family__c,
                                'applicableFor': element.Applicable_For__c,
                                'mandatory': 'No',
                                'documentType': element.Type__c,
                                'status': '',
                                'stage': 'Not Received',
                                'deferredStageDisable': true,
                                'deferredRequired': false,
                                'deferredDate': '',
                                'receivedDate': '',
                                'isReceivedDateRequired': false,
                                'receivedDateDisable': true,
                                'noOfPages': '',
                                'waiverReason': '',
                                'isWaiverRequired': false,
                                'waiverReasonDisable': true,
                                'remarks': '',
                                'isNewRowAdded': '',
                                'fileName': '',
                                'isFileUploadDisabled': true,
                                'isFileUploadRequired': true,
                                'original': '',
                                'isoriginalDisabled': true,
                                'fileData': '',
                                'isAgreementExecution': this.isAgreementExecution,
                                'applicantId': loan.Customer_Information__c,
                                'customerType': loan.Customer_Type__c,
                                'customerName': loan.Applicant_Name__c,
                            }
                            this.applicantJSON.push(newRowDocumentRecord);
                        });
                    }


                    //
                    else if (element.Applicable_For__c === "All" && element.Income_Type__c !== "All" && this.listOfEmpoymentDetails.length) {
                        console.log('** Inside five case **');
                        var loanApplicantIds = [];
                        this.listOfLoanApplicant.forEach(loan => {
                            this.listOfEmpoymentDetails.forEach(emp => {
                                if (emp.Loan_Applicant__c === loan.Id) {
                                    loanApplicantIds.push(loan.Id);
                                    var newRowDocumentRecord = {
                                        'docSetCodeId': element.Id,
                                        'serialNumber': '',
                                        'documentName': element.Name,
                                        'documentFamily': element.Family__c,
                                        'applicableFor': element.Applicable_For__c,
                                        'mandatory': emp.Occupation__c === element.Income_Type__c ? 'Yes' : 'No',
                                        'documentType': element.Type__c,
                                        'status': '',
                                        'stage': 'Not Received',
                                        'deferredStageDisable': true,
                                        'deferredRequired': false,
                                        'deferredDate': '',
                                        'receivedDate': '',
                                        'isReceivedDateRequired': false,
                                        'receivedDateDisable': true,
                                        'noOfPages': '',
                                        'waiverReason': '',
                                        'isWaiverRequired': false,
                                        'waiverReasonDisable': true,
                                        'remarks': '',
                                        'isNewRowAdded': '',
                                        'fileName': '',
                                        'isFileUploadDisabled': true,
                                        'isFileUploadRequired': true,
                                        'original': '',
                                        'isoriginalDisabled': true,
                                        'fileData': '',
                                        'isAgreementExecution': this.isAgreementExecution,
                                        'applicantId': loan.Customer_Information__c,
                                        'customerType': loan.Customer_Type__c,
                                        'customerName': loan.Applicant_Name__c,
                                    }
                                    this.applicantJSON.push(newRowDocumentRecord);
                                }
                            })
                            if (!loanApplicantIds.includes(loan.Id)) {
                                var newRowDocumentRecord = {
                                    'docSetCodeId': element.Id,
                                    'serialNumber': '',
                                    'documentName': element.Name,
                                    'documentFamily': element.Family__c,
                                    'applicableFor': element.Applicable_For__c,
                                    'mandatory': 'No',
                                    'documentType': element.Type__c,
                                    'status': '',
                                    'stage': 'Not Received',
                                    'deferredStageDisable': true,
                                    'deferredRequired': false,
                                    'deferredDate': '',
                                    'receivedDate': '',
                                    'isReceivedDateRequired': false,
                                    'receivedDateDisable': true,
                                    'noOfPages': '',
                                    'waiverReason': '',
                                    'isWaiverRequired': false,
                                    'waiverReasonDisable': true,
                                    'remarks': '',
                                    'isNewRowAdded': '',
                                    'fileName': '',
                                    'isFileUploadDisabled': true,
                                    'isFileUploadRequired': true,
                                    'original': '',
                                    'isoriginalDisabled': true,
                                    'fileData': '',
                                    'isAgreementExecution': this.isAgreementExecution,
                                    'applicantId': loan.Customer_Information__c,
                                    'customerType': loan.Customer_Type__c,
                                    'customerName': loan.Applicant_Name__c,
                                }
                                this.applicantJSON.push(newRowDocumentRecord);
                            }
                        })
                    }
                    else if (element.Applicable_For__c !== "All" && element.Income_Type__c === "All" && this.listOfEmpoymentDetails.length) {
                        console.log('** Inside six case **');
                        var loanApplicantIds = [];
                        this.listOfLoanApplicant.forEach(loan => {
                            this.listOfEmpoymentDetails.forEach(emp => {
                                if (emp.Loan_Applicant__c === loan.Id) {
                                    loanApplicantIds.push(loan.Id);
                                    var newRowDocumentRecord = {
                                        'docSetCodeId': element.Id,
                                        'serialNumber': '',
                                        'documentName': element.Name,
                                        'documentFamily': element.Family__c,
                                        'applicableFor': element.Applicable_For__c,
                                        'mandatory': loan.Customer_Type__c === element.Applicable_For__c ? 'Yes' : 'No',
                                        'documentType': element.Type__c,
                                        'status': '',
                                        'stage': 'Not Received',
                                        'deferredStageDisable': true,
                                        'deferredRequired': false,
                                        'deferredDate': '',
                                        'receivedDate': '',
                                        'isReceivedDateRequired': false,
                                        'receivedDateDisable': true,
                                        'noOfPages': '',
                                        'waiverReason': '',
                                        'isWaiverRequired': false,
                                        'waiverReasonDisable': true,
                                        'remarks': '',
                                        'isNewRowAdded': '',
                                        'fileName': '',
                                        'isFileUploadDisabled': true,
                                        'isFileUploadRequired': true,
                                        'original': '',
                                        'isoriginalDisabled': true,
                                        'fileData': '',
                                        'isAgreementExecution': this.isAgreementExecution,
                                        'applicantId': loan.Customer_Information__c,
                                        'customerType': loan.Customer_Type__c,
                                        'customerName': loan.Applicant_Name__c,
                                    }
                                    this.applicantJSON.push(newRowDocumentRecord);
                                }
                            })
                            if (!loanApplicantIds.includes(loan.Id)) {
                                var newRowDocumentRecord = {
                                    'docSetCodeId': element.Id,
                                    'serialNumber': '',
                                    'documentName': element.Name,
                                    'documentFamily': element.Family__c,
                                    'applicableFor': element.Applicable_For__c,
                                    'mandatory': 'No',
                                    'documentType': element.Type__c,
                                    'status': '',
                                    'stage': 'Not Received',
                                    'deferredStageDisable': true,
                                    'deferredRequired': false,
                                    'deferredDate': '',
                                    'receivedDate': '',
                                    'isReceivedDateRequired': false,
                                    'receivedDateDisable': true,
                                    'noOfPages': '',
                                    'waiverReason': '',
                                    'isWaiverRequired': false,
                                    'waiverReasonDisable': true,
                                    'remarks': '',
                                    'isNewRowAdded': '',
                                    'fileName': '',
                                    'isFileUploadDisabled': true,
                                    'isFileUploadRequired': true,
                                    'original': '',
                                    'isoriginalDisabled': true,
                                    'fileData': '',
                                    'isAgreementExecution': this.isAgreementExecution,
                                    'applicantId': loan.Customer_Information__c,
                                    'customerType': loan.Customer_Type__c,
                                    'customerName': loan.Applicant_Name__c,
                                }
                                this.applicantJSON.push(newRowDocumentRecord);
                            }
                        })
                    }
                    else if (element.Applicable_For__c !== "All" && element.Income_Type__c !== "All" && this.listOfEmpoymentDetails.length) {
                        console.log('** Inside seven case **');
                        var loanApplicantIds = [];
                        this.listOfLoanApplicant.forEach(loan => {
                            console.log('loan applicant id', loan.Customer_Information__c);
                            this.listOfEmpoymentDetails.forEach(emp => {
                                if (emp.Loan_Applicant__c === loan.Id) {
                                    loanApplicantIds.push(loan.Id);
                                    var newRowDocumentRecord = {
                                        'docSetCodeId': element.Id,
                                        'serialNumber': '',
                                        'documentName': element.Name,
                                        'documentFamily': element.Family__c,
                                        'applicableFor': element.Applicable_For__c,
                                        'mandatory': emp.Occupation__c === element.Income_Type__c && loan.Customer_Type__c === element.Applicable_For__c ? 'Yes' : 'No',
                                        'documentType': element.Type__c,
                                        'status': '',
                                        'stage': 'Not Received',
                                        'deferredStageDisable': true,
                                        'deferredRequired': false,
                                        'deferredDate': '',
                                        'receivedDate': '',
                                        'isReceivedDateRequired': false,
                                        'receivedDateDisable': true,
                                        'noOfPages': '',
                                        'waiverReason': '',
                                        'isWaiverRequired': false,
                                        'waiverReasonDisable': true,
                                        'remarks': '',
                                        'isNewRowAdded': '',
                                        'fileName': '',
                                        'isFileUploadDisabled': true,
                                        'isFileUploadRequired': true,
                                        'original': '',
                                        'isoriginalDisabled': true,
                                        'fileData': '',
                                        'isAgreementExecution': this.isAgreementExecution,
                                        'applicantId': loan.Customer_Information__c,
                                        'customerType': loan.Customer_Type__c,
                                        'customerName': loan.Applicant_Name__c,
                                    }
                                    this.applicantJSON.push(newRowDocumentRecord);
                                }
                            });
                            if (!loanApplicantIds.includes(loan.Id)) {
                                var newRowDocumentRecord = {
                                    'docSetCodeId': element.Id,
                                    'serialNumber': '',
                                    'documentName': element.Name,
                                    'documentFamily': element.Family__c,
                                    'applicableFor': element.Applicable_For__c,
                                    'mandatory': 'No',
                                    'documentType': element.Type__c,
                                    'status': '',
                                    'stage': 'Not Received',
                                    'deferredStageDisable': true,
                                    'deferredRequired': false,
                                    'deferredDate': '',
                                    'receivedDate': '',
                                    'isReceivedDateRequired': false,
                                    'receivedDateDisable': true,
                                    'noOfPages': '',
                                    'waiverReason': '',
                                    'isWaiverRequired': false,
                                    'waiverReasonDisable': true,
                                    'remarks': '',
                                    'isNewRowAdded': '',
                                    'fileName': '',
                                    'isFileUploadDisabled': true,
                                    'isFileUploadRequired': true,
                                    'original': '',
                                    'isoriginalDisabled': true,
                                    'fileData': '',
                                    'isAgreementExecution': this.isAgreementExecution,
                                    'applicantId': loan.Customer_Information__c,
                                    'customerType': loan.Customer_Type__c,
                                    'customerName': loan.Applicant_Name__c,
                                }
                                this.applicantJSON.push(newRowDocumentRecord);
                            }
                        });
                    }
                }
            }
            /**
             * Set Asset JSON
             */
            if (element.Type__c === 'Asset') {
                this.listOfProperty.forEach(property => {
                    if (element.Asset_Type__c === 'All') {
                        var newRowDocumentRecord = {
                            'docSetCodeId': element.Id,
                            'serialNumber': '',
                            'documentName': element.Name,
                            'documentFamily': element.Family__c,
                            'documentType': element.Type__c,
                            'mandatory': 'Yes',
                            'status': '',
                            'stage': 'Not Received',
                            'deferredStageDisable': true,
                            'deferredRequired': false,
                            'deferredDate': '',
                            'receivedDate': '',
                            'isReceivedDateRequired': false,
                            'receivedDateDisable': true,
                            'noOfPages': '',
                            'waiverReason': '',
                            'isWaiverRequired': false,
                            'waiverReasonDisable': true,
                            'remarks': '',
                            'isNewRowAdded': '',
                            'fileName': '',
                            'isFileUploadDisabled': true,
                            'isFileUploadRequired': true,
                            'original': '',
                            'isoriginalDisabled': true,
                            'fileData': '',
                            'isAgreementExecution': this.isAgreementExecution,
                            'propertyId': property.Id,
                            'propertyName': property.Name,
                            'propertyType': property.Property_Type__c
                        }
                        this.propertyJSON.push(newRowDocumentRecord);
                    } else if (element.Asset_Type__c !== 'All') {
                        var newRowDocumentRecord = {
                            'docSetCodeId': element.Id,
                            'serialNumber': '',
                            'documentName': element.Name,
                            'documentFamily': element.Family__c,
                            'mandatory': element.Asset_Type__c === property.Property_Type__c ? 'Yes' : 'No',
                            'documentType': element.Type__c,
                            'status': '',
                            'stage': 'Not Received',
                            'deferredStageDisable': true,
                            'deferredRequired': false,
                            'deferredDate': '',
                            'receivedDate': '',
                            'isReceivedDateRequired': false,
                            'receivedDateDisable': true,
                            'noOfPages': '',
                            'waiverReason': '',
                            'isWaiverRequired': false,
                            'waiverReasonDisable': true,
                            'remarks': '',
                            'isNewRowAdded': '',
                            'fileName': '',
                            'isFileUploadDisabled': true,
                            'isFileUploadRequired': true,
                            'original': '',
                            'isoriginalDisabled': true,
                            'fileData': '',
                            'isAgreementExecution': this.isAgreementExecution,
                            'propertyId': property.Id,
                            'propertyName': property.Name,
                            'propertyType': property.Property_Type__c
                        }
                        this.propertyJSON.push(newRowDocumentRecord);
                    }
                })
            }
        })
        setTimeout(() => {
            this.checkAllRequiredDocument();
        }, 3000);

    }

    mandatoryDocumentValidation() {
        console.log('application data :: ', JSON.stringify(this.applicationJSON));
        var mandatoryDocuments = [];
        this.applicationJSON(element => {
            if (element.mandatory === 'Yes' && element.stage !== 'Deferred' && element.stage !== 'Waived') {
                var details = 'Upload Application Type Document - ' + element.documentName;
                mandatoryDocuments.push(details);
            }
        })
        console.log('mandatoryDocuments #### ' + mandatoryDocuments);
    }
    toast(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: variant,
            message: message
        })
        this.dispatchEvent(toastEvent)
    }
    @track newRowDocumentRecord = {
        'serialNumber': '',
        'documentName': '',
        'documentFamily': '',
        'mandatory': '',
        'status': '',
        'stage': 'Not Received',
        'deferredStageDisable': true,
        'deferredRequired': false,
        'deferredDate': '',
        'receivedDate': '',
        'isReceivedDateRequired': false,
        'receivedDateDisable': true,
        'noOfPages': '',
        'waiverReason': '',
        'isWaiverRequired': false,
        'waiverReasonDisable': true,
        'original': '',
        'isoriginalDisabled': true,
        'remarks': '',
        'isNewRowAdded': '',
        'fileName': '',
        'isAgreementExecution': this.isAgreementExecution,
    }
    /**
     *  ====== File Upload Functionality ======
     */
    openfileUpload(event) {
        var rowNo = event.target.getAttribute("data-row-index");
        var sr = Number(rowNo) + Number(1);

        if (this.documentData[rowNo]['documentName'] === '' && this.documentData[rowNo]['isNewRowAdded'] === true) {
            this.toast('Warning', 'Warning', 'Enter Document Name On Serial No ' + sr + '.');
            return;
        } else {
            const file = event.target.files[0]
            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                this.fileData = {
                    'filename': this.documentData[rowNo].documentName + '.' + file.name.substr(file.name.lastIndexOf('.') + 1),
                    'base64': base64,
                    'recordId': this.applicationId
                }
                this.documentData[rowNo].fileName = this.fileData.filename;
                this.documentData[rowNo].fileData = this.fileData;
                console.log('this.documentRequiredData[rowNo] ', this.documentData[rowNo])
            }
            reader.readAsDataURL(file)
        }
    }
}