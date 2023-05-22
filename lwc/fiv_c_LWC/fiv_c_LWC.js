/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-04-05
* @modified         2022-07-21
* @Description      This component is build to handle all the operations related to 
                    Verification-C in FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import getVerification from '@salesforce/apex/FIV_C_Controller.getVerification';
import generateFIVCPdf from '@salesforce/apex/FIVCReportVfController.generateFIVCPdf';
import generatePublicLink from '@salesforce/apex/FIV_C_Controller.generatePublicLink';
import getIncomeSummary from '@salesforce/apex/FIV_C_Controller.getIncomeSummary';
import getCollateralSummary from '@salesforce/apex/FIV_C_Controller.getCollateralSummary';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import checkFIVCReport from '@salesforce/apex/FIV_C_Controller.checkFIVCReport';
import saveAllRecordsFIVC from '@salesforce/apex/FS_SaveAndSubmitController.saveAllRecordsFIVC';
// import getRequiredDocuments from '@salesforce/apex/fsGenericUploadDocumentsController.getRequiredDocuments';
import BusinessDate from '@salesforce/label/c.Business_Date';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { updateRecord } from 'lightning/uiRecordApi';
import VERIFICATION_ID from '@salesforce/schema/Verification__c.Id';
import STATUS from '@salesforce/schema/Verification__c.Status__c';
import { populateData, removeData, checkValidationFIVC, fivc_datatemplete } from 'c/fsGenericDataSave';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';


export default class Fiv_c_LWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @api applicationId;
    @track recordTypeName;
    @track verficationObj;
    @track recordTypeId;
    @track loanAmount;
    @track loginId;
    @track preLoginRecordType;
    @track lastLoginDate;
    @track todaysDate = BusinessDate;
    @track incomeSummaryObj;
    @track propertySummaryObj = {
        propertyList: undefined,
        buildingGrandValue: undefined,
        landGrandValue: undefined,
        collateralGrandValue: undefined
    };

    @track showConfirmationModal = false;
    @track callOnce = false;
    @track showSpinner = false;

    @track showErrorTab = false;
    @track errorMsg;
    @track tabName = 'Character';
    @track fivcValidationObj = {
        character: {
            familyDetail: false,
            neighbourInfo: false,
            affiliationDetail: false,
            livingStandardInfo: false,
            repaymentInfo: false
        },
        collateral: {
            generalDetail: false,
            landAreaVal: false,
            docBoundries: false,
            enquiry: false,
            buildingAreaVal: false,
            landMeasurement: false,
            valuation: false
        },
        capability: false,
        revisit: false,
        seniorRevisit: false,
        docUpload: true,
        reportGenerated: false,
        decision: false
    };

    @track isRelatedToFCO;
    @track isRelatedToFS;
    @track verificationResult;

    @track requiredDocuments;
    @track showPendingReason = false;

    @track btns = [
        {
            name: 'submit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'report',
            label: 'Generate Report',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'pendingReason',
            label: 'Pending Reason',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ]


    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.parse(JSON.stringify(data)));
            const rtis = data.recordTypeInfos;
            this.recordTypeName = Object.keys(rtis).find(rti => rtis[rti].name === 'FIV-C Property Detail');
        } else if (error) {

        }
    }

    get isDecRemarkRequired() {
        return (this.isRelatedToFCO == 'Yes' || this.isRelatedToFS == 'Yes');
    }

    get isRemarkRequired() {
        return (this.verificationResult == 'Negative' || this.verificationResult == 'Neutral');
    }

    // This Method Is Used To Get All Data At Initial Level(Loading)
    connectedCallback() {
        console.log('recordId in connected callback- ', this.recordId);
        this.disablePullToRefresh();
        this.handleGetLastLoginDate();
        this.getVerificationObject();
    }

    disablePullToRefresh() {
        const disableRefresh = new CustomEvent("updateScrollSettings", {
            detail: {
                isPullToRefreshEnabled: false
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(disableRefresh);
    }

    // This Method Is Used To Set All Labels As Bold
    renderedCallback() {
        /*
        if (!this.callOnce) {
            const style = document.createElement('style');
            style.innerText = `.slds-form-element__label{
            font-weight: bold;
        }`;
            this.template.querySelector('[data-id="fivC"]').appendChild(style);
            const label = this.template.querySelectorAll('label');
            label.forEach(element => {
                element.classList.add('bold');
            });
            console.log('renderedCallback()')   ;
        }
        */
    }

    // This Method Is Used To Handle Tab Activation Event
    handleActive(event) {
        this.tabName = event.target.value;
        if (this.tabName == 'CapSummary') {
            this.showTemporaryLoader();
            this.handleGetIncomeSummary();
        } else if (this.tabName == 'ColSummary') {
            this.showTemporaryLoader();
            this.handleGetCollateralSummary();
        } else if (this.tabName === 'DocUpload'){
            let tempCmp = this.template.querySelector('c-fs-generic-document-upload-l-w-c');
            if(tempCmp){
                tempCmp.handleReset();
            }
        }
    }

    // This Method Is Used To Handle Form Values
    handleFormValues(event) {
        let fName = event.target.fieldName ? event.target.fieldName : event.target.name;
        let fValue = event.target.value;
        if (event.target.fieldName == 'Is_applic_co_applic_related__c') {
            this.isRelatedToFS = event.target.value;
        } else if (event.target.fieldName == 'Is_applicant_co_applicant_related_kn__c') {
            this.isRelatedToFCO = event.target.value;
        } else if (event.target.fieldName == 'Result__c') {
            this.verificationResult = event.target.value;
        }

        populateData('FIV-C', 'Decision', '', fName, fValue, 'Id', this.verficationObj.Id);
    }

    handleRequiredDocument(event) {
        console.log('required doc list :: ', event.detail);
        this.requiredDocuments = event.detail;
        this.showSpinner = false;
        
        this.handleFIVCSubmit();
    }

    requiredDocumentValidation() {
        console.log('requiredDocuments ', JSON.stringify(this.requiredDocuments));
        if (this.requiredDocuments.length > 0) {
            this.requiredDocuments.forEach(element => {
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.errorMsg.push('Upload Application Document ' + element.documentName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Applicant') {
                    this.errorMsg.push('Upload Document ' + element.documentName + ' For ' + element.customerName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Asset') {
                    this.errorMsg.push('Upload Document ' + element.documentName + ' For ' + element.propertyName + ' In Document Upload Tab');
                }
            });
        }
    }

    handleRequiredDocuments() {
        // this.showSpinner = true;
        console.log('Application Id in FIVc', this.applicationId);
        console.log('handleRequireDocuments = ', this.template.querySelector('c-fs-generic-document-upload-l-w-c'));
        this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
    }

    // This Method Is Used To Check All Validation On FIV-C Submit.
    async handleFIVCSubmit() {
        console.log('handleFIVCSubmit = ', JSON.parse(JSON.stringify(this.fivcValidationObj)));        
        
        this.errorMsg = checkValidationFIVC();
        console.log('checkValidationFIVC = ', this.errorMsg);

        /* Pending Reason Validation */
        await getPendingReasonValidation({applicationId: this.applicationId, stage: 'FIV - C' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsg.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.showSpinner = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })
        /* Character Validation Check */
        if (!this.fivcValidationObj.character.familyDetail) {
            this.errorMsg.push('Complete Entry In Family Details Sub Section In Character Section');
        }
        if (!this.fivcValidationObj.character.neighbourInfo) {
            this.errorMsg.push('Minimum 3 Neighbour References Are Mandatory.');
        }
        if (!this.fivcValidationObj.character.affiliationDetail) {
            this.errorMsg.push('Complete Entry In Affiliation Sub Section In Character Section');
        }
        if (!this.fivcValidationObj.character.livingStandardInfo) {
            this.errorMsg.push('Living Standard Sub Section In Character Section Can Have Only One Record.');
        }
        if (!this.fivcValidationObj.character.repaymentInfo) {
            this.errorMsg.push('Complete Entry In Repayment Behavior Sub Section In Character Section');
        }
        /* Collateral Validation Check */
        if (!this.fivcValidationObj.collateral.generalDetail) {
            this.errorMsg.push('Complete Entry In Property Details Sub Section In Collateral Section');
        }
        if (!this.fivcValidationObj.collateral.landAreaVal) {
            this.errorMsg.push('Complete Entry In Land Area And Valuation Sub Section In Collateral Section');
        }
        if (!this.fivcValidationObj.collateral.docBoundries) {
            this.errorMsg.push('Complete Entry In As Per Document Boundries Sub Section In Collateral Section');
        }
        if (!this.fivcValidationObj.collateral.enquiry) {
            this.errorMsg.push('Minimum 3 Entries Are Required In Enquiry Sub Section In Collateral Section');
        }
        if (!this.fivcValidationObj.collateral.buildingAreaVal) {
            this.errorMsg.push('Complete Entry In Building Area And Valuation Sub Section In Collateral Section');
        }
        if (!this.fivcValidationObj.collateral.landMeasurement) {
            this.errorMsg.push('Complete Entry In Land Measurement Sub Section In Collateral Section');
        }
        if (!this.fivcValidationObj.collateral.valuation) {
            this.errorMsg.push('Complete Entry In Valuation Sub Section In Collateral Section');
        }
        /* Capability Validation Check */
        if (this.fivcValidationObj.capability && this.fivcValidationObj.capability.length) {
            console.log('this.fivcValidationObj.capability= ', this.fivcValidationObj.capability)
            this.fivcValidationObj.capability.forEach(element => {
                this.errorMsg.push(element);
            });
            this.errorMsg.push('Complete Entry In Capability Section');
        }
        /* Revisit Validation Check */
        if (!this.fivcValidationObj.revisit) {
            this.errorMsg.push('Please Complete Entry In Revisit Section');
        }
        /* Senior Revisit Validation Check */
        if (!this.fivcValidationObj.seniorRevisit) {
            this.errorMsg.push('Please Complete Entry In Senior/Auditor Confirmation Visit Section');
        }
        /* Capability Validation Check */
        if (!this.fivcValidationObj.docUpload) {
            this.errorMsg.push('Please Upload All Required Documents in Document Upload Section');
        }
        /* Capability Validation Check */
        if (!this.fivcValidationObj.decision) {
            this.errorMsg.push('Please Complete Entry In Decision Section');
        }

        this.requiredDocumentValidation();
        /* FIV-C Report Generation Check */
        // if (!this.fivcValidationObj.reportGenerated) {
        //     this.errorMsg.push('FIV-C Report Is Not Generated Yet.');
        // }

        console.log('showErrorTab errorMsg = ', this.errorMsg)

        if (this.errorMsg && this.errorMsg.length) {
            this.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.tabName = 'Error';
            }, 300);
        } else {
            this.showErrorTab = false;
            let ref = this;
            this.showSpinner = true;
            this.handleGenerateReport();
            saveAllRecordsFIVC({ jsonStr: JSON.stringify(fivc_datatemplete) }).then((result) => {
                if (result == 'success') {
                    const fields = {};
                    fields[VERIFICATION_ID.fieldApiName] = this.recordId;
                    fields[STATUS.fieldApiName] = 'Completed';
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        this.showNotifications('', 'FIV-C Verification Is Done Successfully.', 'success');
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.applicationId,
                                objectApiName: 'Application__c',
                                actionName: 'view'
                            }
                        });
                    }).catch(error => {
                        console.log('Error in update Status=.', error);
                    });
                }
                this.showSpinner = false;
            }).catch((err) => {
                console.log('Error in saveAllRecordsFIVC= ', err);
                this.showSpinner = false;
            });
        }
    }

    headerBtnClick(event) {
        if (event.detail === 'submit') {
            //this.handleFIVCSubmit();
            this.handleRequiredDocuments();
        } else if (event.detail === 'report') {
            this.handleFinish();
        } else if (event.detail === 'pendingReason'){
            this.showHidePendingReasonGrid();
        }
    }
    /*
    generateReport() {
        this.handleFinish();
    }
    */
    // This Method Is Used To Show Loader For Short Time.
    showTemporaryLoader() {
        this.showSpinner = true;
        let ref = this;
        setTimeout(function () {
            ref.showSpinner = false;
        }, 500);
    }

    // This Method Is Used To Show Modal On Submit Button
    handleFinish() {
        this.showConfirmationModal = true;
    }

    // This Method Is Used To Handle Modal Action On Submit Button
    handleConfirmation(event) {
        if (event.target.label === 'Yes') {
            this.showConfirmationModal = false;
            this.showSpinner = true;
            this.handleGenerateReport();
        } else {
            this.showConfirmationModal = false;
        }
    }

    handleGenerateReport() {
        generateFIVCPdf({ verificationId: this.recordId, applicationId: this.applicationId }).then(result => {
            console.log('generateFIVCPdf= ', result)
            this.showSpinner = false;
            this.fivcValidationObj.reportGenerated = true;
            this.showNotifications('', 'FIV-C Report Generated Successfully.', 'success');
        }).catch(error => {
            console.log('Error in generateFIVCPdf= ', error)
            this.showSpinner = false;
        })
    }

    // This Method Is Used To Handle Character Tab Validation
    checkCharacterValidation(event) {
        console.log('checkCharacterValidation= ', event.detail)
        this.fivcValidationObj.character = event.detail;
    }

    // This Method Is Used To Handle Collateral Tab Validation
    checkCollateralValidation(event) {
        console.log('checkCollateralValidation= ', event.detail)
        this.fivcValidationObj.collateral = event.detail;
    }

    // This Method Is Used To Handle Capability Tab Validation
    checkCapabilityValidation(event) {
        console.log('checkCapabilityValidation= ', event.detail)
        this.fivcValidationObj.capability = event.detail;
    }

    // This Method Is Used To Handle Revisit Tab Validation
    handleRevisitValidation(event) {
        console.log('handleRevisitValidation= ', event.detail)
        this.fivcValidationObj.revisit = event.detail;
    }

    // This Method Is Used To Handle Senior Revisit Tab Validation
    handleSeniorRevisitValidation(event) {
        console.log('handleRevisitValidation= ', event.detail)
        this.fivcValidationObj.seniorRevisit = event.detail;
    }

    // This Method Is Used To Show Toast Notifications
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    showHidePendingReasonGrid(){
        this.showPendingReason = (!this.showPendingReason);
    }

    /*=================  All submit methods  ====================*/

    // This Method Is Used To Handle Post Submit Actions Of Decition Tab.
    handleDecisionSubmit(event) {
        console.log('handleDecisionSubmit called');
        this.showTemporaryLoader();
    }

    /*=================  All success methods  ====================*/

    // This Method Is Used To Handle Post Success Actions Of Decition Tab.
    handleDecisionSuccess() {
        console.log('handleDecisionSuccess= ');
        this.showNotifications('', 'Verification is completed successfully', 'success');
        this.fivcValidationObj.decision = true;
    }

    /*=================  All server methods  ====================*/

    // This Method Is Used To Verification Object Details From Server Side.
    getVerificationObject() {
        getVerification({ recordId: this.recordId }).then((result) => {
            console.log('GetVerificationObject Result= ', result);
            if (result && result.length) {
                this.verficationObj = JSON.parse(JSON.stringify(result))[0];
                this.applicationId = this.verficationObj.Application__c;
                // this.handleRequiredDocuments();
                this.handleCheckFIVCReport();
                this.recordTypeId = this.verficationObj.RecordTypeId;
                this.loanAmount = this.verficationObj.Application__r.Requested_Loan_Amount__c;
                this.preLoginRecordType = this.verficationObj.Application__r.Pre_Login__r.RecordTypeId;
                this.loginId = this.verficationObj.Application__r.Pre_Login__c;
                this.isRelatedToFS = this.verficationObj.Is_applic_co_applic_related__c;
                populateData('FIV-C', 'Decision', '', 'Is_applic_co_applic_related__c', this.verficationObj.Is_applic_co_applic_related__c, 'Id', this.verficationObj.Id);
                this.isRelatedToFCO = this.verficationObj.Is_applicant_co_applicant_related_kn__c;
                populateData('FIV-C', 'Decision', '', 'Is_applicant_co_applicant_related_kn__c', this.verficationObj.Is_applicant_co_applicant_related_kn__c, 'Id', this.verficationObj.Id);
                this.verificationResult = this.verficationObj.Result__c;
                populateData('FIV-C', 'Decision', '', 'Result__c', this.verficationObj.Result__c, 'Id', this.verficationObj.Id);
                populateData('FIV-C', 'Decision', '', 'Remarks_Declaration__c', this.verficationObj.Remarks_Declaration__c, 'Id', this.verficationObj.Id);
                populateData('FIV-C', 'Decision', '', 'Remarks__c', this.verficationObj.Remarks__c, 'Id', this.verficationObj.Id);
                if (this.verificationResult) {
                    this.fivcValidationObj.decision = true;
                }
                let currentTab = this.tabName;
                console.log('currentTab= ', currentTab);
                let tabs = this.template.querySelectorAll('lightning-tab');
                console.log('tabs= ', tabs);
                tabs.forEach(element => {
                    element.loadContent();
                });

                console.log('currentTab= ', currentTab);
                this.tabName = currentTab;
            }
        }).catch((err) => {
            console.log('Error getVerificationObject= ', err);
        });
    }

    // This Method Is Used To Generate Public Link Of Uploaded File On File Upload Section.
    handleFileUplaod(event) {
        console.log('handleFileUplaod= ', event.detail);

        generatePublicLink({ contentVersionId: event.detail[0].contentVersionId }).then((result) => {
            console.log('handleFileUplaod= ', result);
            this.template.querySelector('c-generic-view-documents').getDocuments();
        }).catch((err) => {
            console.log('Error in handle File upload= ', err);
        });
    }

    // This Method Is Used To Get Capabilty Summary From Server Side.
    handleGetIncomeSummary() {
        getIncomeSummary({
            applicationId: this.applicationId,
            verificationId: this.recordId
        }).then((result) => {
            console.log('handleGetIncomeSummary= ', result);
            this.incomeSummaryObj = JSON.parse(JSON.stringify(result));
        }).catch((err) => {
            console.log('Error in handleGetIncomeSummary= ', err);
        });
    }

    // This Method Is Used To Get Collateral Summary From Server Side.
    handleGetCollateralSummary() {
        getCollateralSummary({ applicationId: this.applicationId }).then((result) => {
            console.log('getCollateralSummary= ', result);
            if (result && result.length) {
                let totalBuildingValue = 0;
                let totalLandValue = 0;
                let collateralGrandValue = 0;
                result.forEach(element => {
                    if (element.Valuation_Final_land_value__c) {
                        totalLandValue += element.Valuation_Final_land_value__c;
                    }
                    if (element.Total_Floor_Value__c) {
                        totalBuildingValue += element.Total_Floor_Value__c;
                    }
                    if (element.Total_Collateral_Value__c) {
                        collateralGrandValue += element.Total_Collateral_Value__c;
                    }
                });

                this.propertySummaryObj = JSON.parse(JSON.stringify(this.propertySummaryObj));
                this.propertySummaryObj.propertyList = JSON.parse(JSON.stringify(result));
                this.propertySummaryObj.buildingGrandValue = totalBuildingValue;
                this.propertySummaryObj.landGrandValue = totalLandValue;
                this.propertySummaryObj.collateralGrandValue = collateralGrandValue;
            }
        }).catch((err) => {
            console.log('Error in getCollateralSummary= ', err);
        });
    }

    // This Method Is Used To Get User's Last Login Date From Server Side.
    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    // This Method Is Used To Check That FIV-C Report IS Generated Or Not.
    handleCheckFIVCReport() {
        checkFIVCReport({ appId: this.applicationId }).then((result) => {
            console.log('checkFIVCReport= ', result);
            this.fivcValidationObj.reportGenerated = result;
        }).catch((err) => {
            console.log('Error in checkFIVCReport= ', err);
        });
    }

    handleTabValueChange(event) {
        console.log('partaiall save  eventtt ', event.detail)
        var data = event.detail;
        let fValue = data.fieldvalue;
        if ((data.fieldapiname == 'Title_Deed_Date__c' || data.fieldapiname == 'Revisit_date__c') && fValue && fValue.trim()) {
            fValue = fValue.substr(0, 10);
        } else if ((data.fieldapiname == 'Title_Deed_Date__c' || data.fieldapiname == 'Revisit_date__c') && (!fValue || !fValue.trim())) {
            fValue = null;
        }
        populateData('FIV-C', data.tabname, data.subtabname, data.fieldapiname, fValue, 'Id', data.recordId);
        console.log('populate dataaa', fivc_datatemplete);
    }

    handleTabValueRemove(event) {
        console.log('partaiall removee  eventtt ', event.detail)
        var data = event.detail;
        removeData('FIV-C', data.tabname, data.subtabname);
        console.log('removee111 dataaa', fivc_datatemplete);
    }
}