import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import { getRecord } from 'lightning/uiRecordApi';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import generatePublicLink from '@salesforce/apex/DatabaseUtililty.generatePublicLink';
//import getRequiredDocuments from '@salesforce/apex/fsGenericUploadDocumentsController.getRequiredDocuments';
import checkCKYCId from '@salesforce/apex/AgreementExecutionController.checkCKYCId';
import checkDocGenerated from '@salesforce/apex/AgreementExecutionController.checkDocGenerated';
import moveApplicationStage from '@salesforce/apex/AgreementExecutionController.moveApplicationStage';
import checkSendBackVaidation from '@salesforce/apex/AgreementExecutionController.checkSendBackVaidation';
import sendBackLegalApproval from '@salesforce/apex/AgreementExecutionController.sendBackLegalApproval';
import sendBackAprovalCredit from '@salesforce/apex/AgreementExecutionController.sendBackAprovalCredit';
import checkPennyDrop from '@salesforce/apex/AgreementExecutionController.checkPennyDrop';
import checkBankDetailsExist from '@salesforce/apex/AgreementExecutionController.checkBankDetailsExist';
import checkDecision from '@salesforce/apex/AgreementExecutionController.checkDecision';
import generateApplicantAgreementExecutionDocs from '@salesforce/apex/ApplicantDocumentGeneratorController.generateApplicantAgreementExecutionDocs';
import generateAgreementExecutionDocs from '@salesforce/apex/DocumentGenerationVFController.generateAgreementExecutionDocs';
import { updateRecord } from 'lightning/uiRecordApi';
import NAME from '@salesforce/schema/Application__c.Name';
import BusinessDate from '@salesforce/label/c.Business_Date';
import APPLICATION_ID from '@salesforce/schema/Application__c.Id';
import STAGE from '@salesforce/schema/Application__c.Stage__c';
import SUB_STAGE_FIELD from "@salesforce/schema/Application__c.Sub_Stage__c";
import checkDOSCondition from '@salesforce/apex/AgreementExecutionController.checkDOSCondition';
import checkInsuranceValidation from '@salesforce/apex/fsPcAcController.checkInsuranceValidation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//Added by Sangeeta : 22/11/22 : for repayment and zero fee validation
import getFeeWithoutRepayment from '@salesforce/apex/FeeCreationComponentHelper.getFeeWithoutRepayment';
import getZeroFee from '@salesforce/apex/FeeCreationComponentHelper.getZeroFee';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';

export default class FsAggrementExecutionLWC extends NavigationMixin(LightningElement) {

    @api recordId;

    @track todaysDate = BusinessDate;
    @track lastLoginDate;
    @track applicationName;
    @track tabName = 'CKYC';
    @track errorMsgs = [];
    @track showErrorTab = false;
    @track isRequired = false;
    @track hasDocVerified = false;
    @track hasCKYCVerified = false;
    @track hasNACHVerified = false;
    @track hasPennyVerified = false;
    @track hasBankDetails = false;
    @track hasDecision = false;
    @track hasDocGeneratedVerified = false;
    @track hasListOfDocVerified = false;
    @track showSpinner = false;
    @track _allPreviousStageDone = false;
    @track showRepaymentSchedule = false;
    @track propRecTypeId;
    @track requiredDocuments = [];
    @track isFeeWithoutRepayment = false;
    @track isZeroFee = false;
    @track receiptWrapper = { hasReceipt: false, allApproved: false, pendingReceiptList: [], lengthOfDirectRec: 0, existingFeeCodeOption: [] };
    @track button = [
        {
            name: 'Submit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'SendBack',
            label: 'Send Back',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'Generate_Repayment_Schedule',
            label: 'Generate Repayment Schedule',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'pendingReason',
            label: 'Pending Reason',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ];

    @track showPendingReason = false;
    @track openSendBack = false;
    loadAll = false;


    @wire(getRecord, { recordId: '$recordId', fields: [NAME] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.stringify(data));
            const rtis = data.recordTypeInfos;
            this.propRecTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'AC Property Detail');
        } else if (error) {

        }
    }

    connectedCallback() {
        //this.getPropRecTypeId();
        this.handleGetLastLoginDate();
        //this.checkAllCKYCId(); //Uncomment After CYCID API Working 
        this.checkAllPennyDrop();
        this.checkAllBankDetail();
        this.checkDecisionApp();
        //  this.checkSendBackVaidation();
        console.log('appId', this.recordId);
    }

    renderedCallback() {
        if (this.loadAll == false) {
            //this.getPropRecTypeId();
            console.log('i am in check validity');
            let currentTab = this.tabName;
            console.log('currentTab= ', currentTab);
            let tabs = this.template.querySelectorAll('lightning-tab');
            console.log('tabs ', tabs);
            tabs.forEach(element => {
                element.loadContent();
            });
            console.log('currentTab= ', currentTab);
            this.tabName = currentTab;
            if (tabs && tabs.length == 8) {         
                this.loadAll = true;
            }
        }
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }

    getPropRecTypeId() {
        getRecordTypeId({ sObjectName: 'Property__c', recordTypeName: 'AC Property Detail' })
            .then(result => {
                if (result)
                    this.propRecTypeId = result;
            })
            .catch(error => {
                console.log(error);
            })
    }

    handleActive(event) {
        this.tabName = event.target.value;
        if (this.tabName === 'CKYC') {
            setTimeout(() => {
                this.template.querySelector('c-fs-aggrement-execution-c-k-y-c').getAllApplicant();
            }, 300);
        }
        if (this.tabName === 'Doc_Gen') {
            setTimeout(() => {
                this.template.querySelector('c-fs-aggrement-execution-d-g').getAllApplicant();
            }, 300);
        }
        if (this.tabName === 'DocList') {
            setTimeout(() => {
                this.template.querySelector('c-fs-agreement-execution-list-of-documents').getContentVersionRecords();
            }, 300);
        }
        if (this.tabName === 'Fee_Details') {
            setTimeout(() => {
                if (this.template.querySelector('c-fee-creation-parent')) {
                    this.template.querySelector('c-fee-creation-parent').showFee();
                }
            }, 300);
        }
    }

    handleFileUplaod(event) {
        generatePublicLink({ contentVersionId: event.detail[0].contentVersionId, uploadedFrom: 'LegalOpinion' }).then((result) => {
            console.log('handleFileUplaod= ', result);
            this.template.querySelector('c-generic-view-documents').getDocuments();
        }).catch((err) => {
            console.log('Error in handle File upload= ', err);
        });
    }

    checkAppStatus(event) {
        console.log(event.target.value);
        if (event.target.value === 'Pending')
            this.isRequired = true;
        else
            this.isRequired = false;
    }

    handleRequiredDocument(event) {
        console.log('Testing 5');
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        console.log('Testing 6');
        this.requiredDocumentValidation();
    }

    requiredDocumentValidation() {
        console.log('Testing 7');
        console.log('requiredDocuments ', JSON.stringify(this.requiredDocuments));
        if (this.requiredDocuments.length > 0) {
            console.log('Testing 8');
            this.requiredDocuments.forEach(element => {
                //console.log('Testing 9');
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.errorMsgs.push(' Upload Application Document ' + element.documentName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Applicant') {
                    this.errorMsgs.push(' Upload Document ' + element.documentName + ' For ' + element.customerName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Asset') {
                    this.errorMsgs.push(' Upload Document ' + element.documentName + ' For ' + element.propertyName + ' In Document Upload Tab');
                }
            });
            console.log('Testing 9');
        }
        console.log('Testing 10');
        this.handleSubmit();
        console.log('Testing 11');
    }

    getReceiptPendingList(event) {
        console.log('Receipt data approved ', event.detail);
        this.receiptWrapper.hasReceipt = event.detail.hasReceipt;
        this.receiptWrapper.allApproved = event.detail.allApproved;
        this.receiptWrapper.pendingReceiptList = event.detail.pendingReceiptList;
        this.receiptWrapper.lengthOfDirectRec = event.detail.lengthOfDirectRec;
        this.receiptWrapper.existingFeeCodeOption = event.detail.existingFeeCodeOption;
    }

    async handleAgreementExecutionSubmit() {
        console.log('Testing 1');
        this.showSpinner = true;
        this.errorMsgs = [];
        this.showErrorTab = false;
        try {
            console.log('Testing 2');
            this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
            console.log('Testing 3');
        } catch (error) {
            console.log('c-fs-generic-upload-documents error ', error)
        }
        console.log('Testing 4');
    }

    async handleSubmit() {
        console.log('Testing 12');
        var checkValid = await this.checkValidations();
        console.log('Testing 13', checkValid);
        await getPendingReasonValidation({applicationId: this.recordId, stage: 'Agreement Execution' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsgs.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            console.log('Pending Reasons Not Resolved. ', error);
        })
        if (this.errorMsgs.length == 0 && this.requiredDocuments.length == 0 && this.hasPennyVerified && this.hasBankDetails && this.hasDecision && (this.receiptWrapper.pendingReceiptList.length == 0 && (this.receiptWrapper.hasReceipt == true || this.receiptWrapper.lengthOfDirectRec == 0)) && this.receiptWrapper.existingFeeCodeOption.length == 0
            && !this.isFeeWithoutRepayment && !this.isZeroFee) {
            this.showSpinner = false;
            this.redirectApplication();
        }
        else {
            if (this.receiptWrapper.lengthOfDirectRec > 0 && this.receiptWrapper.hasReceipt == false) {
                this.errorMsgs.push('Please Add Receipt in Fee Details Tab');
            }
            else {
                console.log('Receipt Defaulter List ', this.receiptWrapper.pendingReceiptList.length);
                if (this.receiptWrapper.pendingReceiptList.length > 0) {
                    this.receiptWrapper.pendingReceiptList.forEach(element => {
                        if (element.RecStatus != 'Rejected') {
                            this.errorMsgs.push(element.name + '- Kindly Approve/Reject the submitted receipt in Fee Details');
                        }
                    });
                }
            }
            if (this.receiptWrapper.existingFeeCodeOption.length > 0) {
                this.receiptWrapper.existingFeeCodeOption.forEach(element => {
                    this.errorMsgs.push('Please Add Receipt in Fee Details Tab for Fee Code: ' + element.label);
                    console.log('this.receiptWrapper.existingFeeCodeOption', element.label);
                });
            }
            this.showSpinner = false;
            this.showErrorTab = true;
            setTimeout(() => {
                this.tabName = 'Error';
            }, 300);
        }

    }

    handleDecisionSuccess(event) {
        this.showToast('Success', 'Success', 'Record Saved Successfully!!');
    }

    async checkValidations() {
        console.log('Testing 14');
        //this.checkAllCKYCId(); //Uncomment After CYCID API Working
        var checkPenny = await this.checkAllPennyDrop();
        console.log('Testing 15');
        var checkBank = await this.checkAllBankDetail();
        console.log('Testing 16');
        var checkDecision = await this.checkDecisionApp();
        console.log('Testing 17');
        var checkInsurance = await this.checkInsuranceValidationReceipt();
        console.log('Testing 18');
        var checkFee = await this.getFeeWithoutRepayment();
        console.log('Testing 19');
        var checkZero = await this.getZeroFee(); 
        return new Promise((resolve, reject) => {
            if (checkPenny && checkBank && checkDecision && checkInsurance && checkFee && checkZero)
                resolve(true)
            else
                reject(false)
            console.log('Testing 20');
        });
    }

    async redirectApplication() {
        console.log('Testing 21');
        console.log('app Id ', this.recordId);
        this.showSpinner = true;
        await checkDOSCondition({ recordId: this.recordId }).then(result => {
            if (result) {
                this.showToast('', 'Info', 'DOS is mendatory for this application!!');
            }
            else {
                this.showToast('', 'Info', 'DOS is not mendatory for this application!!');
            }
        })
            .catch(error => {
                console.log(error);
            })
        moveApplicationStage({ applicationId: this.recordId }).then(result => {
            console.log('res ', result);
            this.showSpinner = false;
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: this.recordId,
            //         actionName: 'view'
            //     }
            // });
            window.location.replace('/'+this.recordId);
        })
            .catch(error => {
                this.showSpinner = false;
                console.log('Error', error);
            })
    }

    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }


    /* ----------------- All the apex method below --------------------- */

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    checkRequiredDocs() {
        console.log('call check required');
    }

    checkAllCKYCId() {
        checkCKYCId({ applicationId: this.recordId })
            .then(result => {
                console.log('ckyccheck result ', result);
                if (result.length > 0) {
                    this.errorMsgs.push('Update CKYC Id Of ' + result.join() + ' In CKYC Tab');
                    this.hasCKYCVerified = false;
                }
                else {
                    this.hasCKYCVerified = true;
                }
            })
            .catch(error => {
                console.log('ckyc get error ', error)
            })
    }

    checkAllPennyDrop() {
        return new Promise((resolve, reject) => {
            checkPennyDrop({ applicationId: this.recordId }).then(result => {
                console.log('penny check result = ', result);
                if (result.length > 0) {
                    this.errorMsgs.push(result);
                    this.hasPennyVerified = false;
                }
                else {
                    this.hasPennyVerified = true;
                }
                resolve('checkPennyDrop');
            })
                .catch(error => {
                    console.log('penny get error ', error)
                    reject(error);
                })
        });
    }

    checkAllBankDetail() {
        return new Promise((resolve, reject) => {
            checkBankDetailsExist({ applicationId: this.recordId }).then(result => {
                console.log('bank check result = ', result);
                if (result.length > 0) {
                    this.errorMsgs.push(result);
                    this.hasBankDetails = false;
                }
                else {
                    this.hasBankDetails = true;
                }
                resolve('checkBankDetailsExist');
            })
                .catch(error => {
                    console.log('hasBankDetails get error ', error)
                    reject(error);
                })
        });
    }

    /*checkAlldocumentGenerated() {
        checkDocGenerated({ applicationId: this.recordId })
            .then(result => {
                console.log('checkDocGenerated result ', result);
                if (result) {
                    this.errorMsgs.push('ADD Record For ' + result.join() + ' In Document Generation Tab');
                    this.hasDocGeneratedVerified = false;
                }
                else {
                    this.hasDocGeneratedVerified = true;
                }
            })
            .catch(error => {
                console.log('doc gen get error ', error)
            })
    }*/

    checkInsuranceValidationReceipt() {
        return new Promise((resolve, reject) => {
            checkInsuranceValidation({ applicationId: this.recordId })
                .then(res => {
                    console.log('Result Of Insurance Validation ###', res);
                    if (res)
                        this.errorMsgs.push('Please Invoke Insurance Api First');
                    resolve('checkInsuranceValidation');
                })
                .catch(err => {
                    console.log('Error %%%', err);
                    reject(err);
                })
        });
    }

    checkDecisionApp() {
        return new Promise((resolve, reject) => {
            checkDecision({ applicationId: this.recordId }).then(result => {
                console.log('dcision preset ', result);
                if (!result) {
                    this.errorMsgs.push('Decision Pending in Decision Tab');
                    this.hasDecision = false;
                }
                else {
                    this.hasDecision = true;
                }
                resolve('checkDecision');
            })
                .catch(error => {
                    console.log('hasDecision gen get error ', error)
                    reject(error);
                })
        });
    }

    // Added by Sangeeta yadav : 23/11/22 for fee validation
    //Sangeeta Yadav : Added on : 22/11/22 : fee repayment type validation
    getFeeWithoutRepayment() {
        console.log('in getFeeWithoutRepayment');
        console.log('pendingFeeAndReceiptForDA Stage - this.stageName in pending receipt ' + this.recordId);
        return new Promise((resolve, reject) => {
            getFeeWithoutRepayment({ recordId: this.recordId })
                .then(result => {
                    console.log('::: fee ::: ', result);
                    this.isFeeWithoutRepayment = result;
                    if (result) {
                        console.log('inside repayment value', result);
                        this.errorMsgs.push('Please Select Repayment Type in Fee Details section of Fee details tab');
                    }
                    resolve('getFeeWithoutRepayment');
                })
                .catch(error => {
                    console.log('error on inside repayment value -> ' + JSON.stringify(error));
                    reject(error);
                })
        });
    }

    //Sangeeta Yadav : Added on : 22/11/22 : fee amount not null
    getZeroFee() {
        console.log('in getZeroFee');
        console.log('getZeroFee Stage - this.stageName in pending receipt ' + this.recordId);
        return new Promise((resolve, reject) => {
            getZeroFee({ recordId: this.recordId })
                .then(result => {
                    console.log('::: getZeroFee ::: ', result);
                    this.isZeroFee = result;
                    if (result) {
                        console.log('inside getZeroFee', result);
                        this.errorMsgs.push('Total Fee can not be 0 in Fee Details section of Fee details tab');
                    }
                    resolve('getZeroFee');
                })
                .catch(error => {
                    console.log('error on inside repayment value -> ' + JSON.stringify(error));
                    reject(error);
                })
        });
    }

    /*-------------------SendBack Implementation------------------------*/
    rowselectionevent(event) {
        var detail = event.detail;
        if (detail === 'SendBack') {
            this.openSendBack = true;
        }
        if (detail === 'Generate_Repayment_Schedule') {
            this.showRepaymentSchedule = true;
        }
        if (detail === 'Submit') {
            this.handleAgreementExecutionSubmit();
        }
        if (event.detail === 'pendingReason'){
            this.showHidePendingReasonGrid();
        }
    }

    closeModal() {
        this.showRepaymentSchedule = false;
    }

    handleSendBackClose(event) {
        if (event.detail == true) {
            this.openSendBack = false;
        }
    }

    handleSendBackSubmit(event) {
        let value = event.detail;
        console.log('value' + value);
        if (value != null) {
            if (value == "Approval Credit") {
                sendBackAprovalCredit({ applicationId: this.recordId })
                    .then(result => {
                        console.log('result' + result);
                        this.updateApplication(value);
                    })
                    .catch(error => {
                        console.log('Error', error)
                    })
            }
            if (value == 'Legal Approval') {
                sendBackLegalApproval({ applicationId: this.recordId })
                    .then(result => {
                        this.updateApplication(value);
                    })
                    .catch(error => {
                        console.log('Error', error)
                    })
            }

        }
    }
    navigateToApplication() {
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.recordId,
        //         actionName: 'view',
        //     }
        // });
        window.location.replace('/'+this.recordId);
    }

    updateApplication(stageValue) {
        const fields = {};
        fields[APPLICATION_ID.fieldApiName] = this.recordId;
        if (stageValue === 'Legal Approval') {
            fields[SUB_STAGE_FIELD.fieldApiName] = stageValue;
            fields[STAGE.fieldApiName] = 'Awaiting Legal Approval';
        } else {
            if (stageValue === 'Approval Credit') {
                fields[STAGE.fieldApiName] = stageValue;
                console.log('fields' + fields[STAGE.fieldApiName]);
            }
        }
        const recordInput = {
            fields: fields
        };

        console.log('fields To Upddate ', recordInput);
        updateRecord(recordInput)
            .then((record) => {
                this.showToast('Success', 'success', 'Agreement Execution moved to ' + stageValue + ' successfully.');
                this.navigateToApplication();
            })
            .catch(error => {
                this.showToast('Error', 'error', error.body.message);
            });
    }
}