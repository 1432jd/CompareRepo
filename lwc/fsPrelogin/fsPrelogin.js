import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import BusinessDate from '@salesforce/label/c.Business_Date';
import Mobile_Verification_Mandatory from '@salesforce/label/c.Mobile_Verification_Mandatory';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import { getRecord } from 'lightning/uiRecordApi';
import clonePropertyNew from '@salesforce/apex/FsPreloginController.clonePropertyNew';
import createVerificationRecords from '@salesforce/apex/VerificationRecordCreator.createVerificationRecords';
import getRecordTypeName from '@salesforce/apex/FsPreloginController.getRecordTypeName';
import getApplicationId from '@salesforce/apex/FsPreloginController.getApplicationId';
import updateHistory from '@salesforce/apex/FsPreloginController.updateHistory';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId';
import doHighmarkCallout from '@salesforce/apex/BureauHighmartAPICalloutController.doHighmarkCallout';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import APPLICATION_ID from '@salesforce/schema/Application__c.Id';
import STAGE from '@salesforce/schema/Application__c.Stage__c';
//Added by Sangeeta : 22/11/22 : for repayment and zero fee validation
import getFeeWithoutRepayment from '@salesforce/apex/FeeCreationComponentHelper.getFeeWithoutRepayment';
import getZeroFee from '@salesforce/apex/FeeCreationComponentHelper.getZeroFee';
// Added on 28.04.23 :
import checkBureauVerified from '@salesforce/apex/FsPreloginController.checkBureauVerification';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';


export default class FsPreLogin extends NavigationMixin(LightningElement) {

    @api applicationId;
    @api preloginId;
    @api recordId;
    @api recordTypeId;
    @api preAppId;
    @api preAppName;
    @api loanAppIdList = [];
    @api hasPrimaryApplicant = false;
    @api hasPrimaryOwner = false;
    @api isMobileVerified = false;
    @api isKYCVerified = false;
    @api isIncomeConsidered = false;

    @track isMobileVerMandatory = Mobile_Verification_Mandatory;
    @track todaysDate = BusinessDate;
    @track lastLoginDate;
    @track showErrorTab = false;
    @track errorMsgs = [];
    @track activeError = 'step-1';
    @track mobDefList;
    @track kycDefList;
    @track hasAllFields = false;
    @track recTypeName;
    @track isRelogin = false;
    @track isTopup = false;
    @track isTranche = false;
    @track isNewlogin = true;
    @track ownerOptions = [];
    @track primaryAppName;
    @track isReceiptPending = false;
    @track receiptWrapper = { hasReceipt: false, allApproved: false, pendingReceiptList: [], lengthOfDirectRec: 0, existingFeeCodeOption: [] };
    @track isLoading = false;
    @track buttonClick = false;
    @track propRecTypeId;
    @track dedupeDetails;
    @track requiredDocuments = [];
    @track oldAppNumber;
    @track validation = false;
    @track headerLabel;
    @track isFeeWithoutRepayment = false;
    @track isZeroFee = false;
    @track showPendingReason = false;
    @track showDocumentTab = true;
    @track button = [
        {
            name: 'Submit',
            label: 'Submit',
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
    loadAll = false;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('pageReferenece @@ ', currentPageReference.state.recordTypeId);
            if (currentPageReference.state.recordTypeId) {
                console.log('getRecTypeName');
                this.getRecTypeName(currentPageReference.state.recordTypeId);
            }
        }
    }

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.stringify(data));
            const rtis = data.recordTypeInfos;
            this.propRecTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Pre Login Property Detail');
        } else if (error) {

        }
    }

    async connectedCallback() {
        this.disablePullToRefresh();
        this.handleGetLastLoginDate();
        console.log('Values ', this.applicationId, this.recordId, this.recordTypeId, this.preAppId, this.preAppName, this.recTypeName);
        this.applicationId = this.preAppId;
        if (this.recordId)
            this.preloginId = this.recordId;
        if (!this.recTypeName) {
            console.log('getRecTypeName 1');
            this.isLoading = true;
            await getApplicationId({ recordId: this.recordId })
                .then(result => {
                    this.isLoading = false;
                    console.log('resuly in connected callback ', result)
                    this.applicationId = result.appId;
                    this.recordTypeId = result.recTypeId;
                    this.recTypeName = result.recTypeName;
                    console.log('recName ', this.recTypeName);
                    setTimeout(() => {
                        this.template.querySelector('c-fs-customer-details').getRecordType(this.recTypeName);
                    }, 300);
                    if (!this.recordId) { //!this.recordId 
                        if (this.recTypeName === '2. Re-login') {
                            this.isRelogin = true;
                            this.isNewlogin = false;
                            this.validation = true;
                            this.headerLabel = 'Re-Login'
                        }
                        else if (this.recTypeName === '3. Top-up loan') {
                            this.isTopup = true;
                            this.isNewlogin = false;
                            this.validation = true;
                            this.headerLabel = 'Top-Up Loan'
                        }
                        else if (this.recTypeName === '1. New login') {
                            this.isNewlogin = true;
                            this.validation = false;
                            this.headerLabel = 'New Login'
                        }
                        else {
                            this.isTranche = true;
                            this.isNewlogin = false;
                            this.validation = true;
                            this.headerLabel = 'Tranche Loan'
                        }
                    }
                    else {
                        if (this.recTypeName === '2. Re-login') {
                            this.isNewlogin = true;
                            this.validation = true;
                            this.headerLabel = 'Re-Login'
                        }
                        else if (this.recTypeName === '3. Top-up loan') {
                            this.isNewlogin = true;
                            this.validation = true;
                            this.headerLabel = 'Top-Up Loan'
                        }
                        else if (this.recTypeName === '1. New login') {
                            this.isNewlogin = true;
                            this.validation = false;
                            this.headerLabel = 'New Login'
                        }
                        else {
                            this.isNewlogin = true;
                            this.validation = true;
                            this.headerLabel = 'Tranche Loan'
                        }
                    }
                })
                .catch(error => {
                    console.log('error', error);
                })
            console.log('Values  this.recTypeName  ', this.applicationId, this.recordId, this.recordTypeId, this.preAppId, this.preAppName, this.recTypeName);
        }
    }

    renderedCallback() {
        if (this.loadAll == false) {
            console.log('i am in check validity');
            let currentTab = this.activeError;
            console.log('currentTab= ', currentTab);
            let tabs = this.template.querySelectorAll('lightning-tab');
            console.log('tabs ', tabs);
            tabs.forEach(element => {
                element.loadContent();
            });
            console.log('currentTab= ', currentTab);
            this.activeError = currentTab;
            if (this.recTypeName === '1. New login') {
                if (tabs && tabs.length == 6) {
                    this.loadAll = true;
                }
            }
            else {
                if (tabs && tabs.length == 7) {
                    this.loadAll = true;
                }
            }
        }
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
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

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    getdedupedetails(event) {
        let result = event.detail;
        console.log('dedupe result ', JSON.parse(result));
        var dedupeResult = JSON.parse(result);
        if (dedupeResult.message != null)
            this.dedupeDetails = JSON.parse(result);
        console.log('dedupeDetails= ', this.dedupeDetails);
        setTimeout(() => {

            this.handlePreloginSubmit();
        }, 3000);
    }

    getRecTypeName(recTypeId) {
        getRecordTypeName({ recTypeId: recTypeId })
            .then(result => {
                if (result) {
                    this.recTypeName = result;
                    console.log('recName ', this.recTypeName);
                    if (result === '2. Re-login') {
                        this.isRelogin = true;
                        this.isNewlogin = false;
                        this.validation = true;
                        this.headerLabel = 'Re-Login'
                    }
                    else if (result === '3. Top-up loan') {
                        this.isTopup = true;
                        this.isNewlogin = false;
                        this.validation = true;
                        this.headerLabel = 'Top-Up Loan'
                    }
                    else if (result === '1. New login') {
                        this.isNewlogin = true;
                        this.validation = false;
                        this.headerLabel = 'New Login'
                    }
                    else {
                        this.isTranche = true;
                        this.isNewlogin = false;
                        this.validation = true;
                        this.headerLabel = 'Tranche Loan'
                    }
                }
            })
            .catch(error => {
                console.log('error getting recTypeName ', error);
            })
    }

    showNewLogin(event) {
        console.log('shownewlogin prelogin screen ', event.detail);
        this.isNewlogin = event.detail.isNewLogin;
        this.applicationId = event.detail.newAppId;
        this.preloginId = event.detail.preloginId;
        this.preAppName = event.detail.newAppName;
        this.oldAppNumber = event.detail.oldAppName;
        setTimeout(() => {
            this.template.querySelector('c-fs-customer-details').getAccountData(this.applicationId);
        }, 300);
        this.showToast('Success', 'Success', 'Application Initiated Successfully!!');
        this.closeAction();
        let ref = this;
        setTimeout(() => {
            ref.activeError = 'step-1';
        }, 300);
    }

    handleActive(event) {
        const tab = event.target.value;
        console.log('tab ', tab);
        if (tab === 'step-2') {
            setTimeout(() => {
                if (this.template.querySelector('c-fs-property-details')) {
                    console.log('loanaPPlist ', this.loanAppIdList);
                    this.template.querySelector('c-fs-property-details').getApplicationId(this.applicationId);
                    this.template.querySelector('c-fs-property-details').getLoanAppList(this.loanAppIdList);
                    this.template.querySelector('c-fs-property-details').getPropertyOwnersName(this.applicationId);
                    this.template.querySelector('c-fs-property-details').getPropertyOwnersList(this.ownerOptions);
                }
            }, 300);
        }
        if (tab === 'step-3') {
            console.log('step 3');
            setTimeout(() => {
                if (this.template.querySelector('c-fs-pre-login-application-detail')) {
                    console.log('appid step 3 ', this.applicationId);
                    this.template.querySelector('c-fs-pre-login-application-detail').getApplicationId(this.applicationId);
                }
            }, 300);
        }
        if (tab === 'DocumentUpload') {
            try {
                setTimeout(() => {
                    if (this.template.querySelector('c-fs-generic-document-upload-l-w-c'))
                        this.template.querySelector('c-fs-generic-document-upload-l-w-c').handleReset();
                }, 300);
            } catch (error) {
                this.showDocumentTab = true;
                console.log('error :: ', error);
            }
        }
        if (tab === 'step-5') {
            setTimeout(() => {
                if (this.template.querySelector('c-fsdedupe-details-lwc')) {
                    this.template.querySelector('c-fsdedupe-details-lwc').getCurrentAppsLoanApp();
                }
            }, 300);
        }
        if (tab === 'step-4') {
            setTimeout(() => {
                if (this.template.querySelector('c-fee-creation-parent')) {
                    this.template.querySelector('c-fee-creation-parent').showFee();
                }
            }, 300);
        }
    }

    refreshDocTab(event) {
        console.log('DOC TAB EVENT ', event.detail);
        this.showDocumentTab = false;
        setTimeout(() => {
            this.showDocumentTab = event.detail;
        }, 100);
    }

    handleApplicationId(event) {
        console.log('appid event called ', event.detail);
        this.applicationId = event.detail;
        if (this.template.querySelector('c-fs-pre-login-application-detail'))
            this.template.querySelector('c-fs-pre-login-application-detail').getApplicationId(this.applicationId);
    }

    handleAppName(event) {
        console.log('getAppName 6 ', event.detail);
        this.preAppName = event.detail;
    }

    handlePreloginId(event) {
        this.preloginId = event.detail;
    }

    getPropertyOwners(event) {
        console.log('owner event called ', event.detail);
        this.loanAppIdList = event.detail;
        console.log('laList ', this.loanAppIdList);
    }

    getPrimaryApplicantName(event) {
        console.log('getPrimaryApplicantName ', event.detail);
        this.primaryAppName = event.detail;
    }
    fillOwner(event) {
        console.log('fillownerlist ', event.detail);
        this.ownerOptions = event.detail;
    }

    checkAllRequired(event) {
        this.hasAllFields = event.detail;
    }

    checkSubmit(event) {
        console.log('check ', event.detail);
        this.hasPrimaryApplicant = event.detail.hasPrimaryApplicant;
        this.mobDefList = event.detail.mobDefList;
        this.isMobileVerified = event.detail.isMobileVerified;
        this.isIncomeConsidered = event.detail.isIncomeConsidered;
        this.isKYCVerified = event.detail.isKYCVerified;
        this.kycDefList = event.detail.kycDefList;
    }

    checkProperty(event) {
        this.hasPrimaryOwner = event.detail;
        console.log('check property running', this.hasPrimaryOwner);
    }

    getReceiptPendingList(event) {
        console.log('Receipt data approved ', event.detail);
        this.receiptWrapper.hasReceipt = event.detail.hasReceipt;
        this.receiptWrapper.allApproved = event.detail.allApproved;
        this.receiptWrapper.pendingReceiptList = event.detail.pendingReceiptList;
        this.receiptWrapper.lengthOfDirectRec = event.detail.lengthOfDirectRec;
        this.receiptWrapper.existingFeeCodeOption = event.detail.existingFeeCodeOption;
    }

    redirectApplication() {
        console.log('app Id ', this.applicationId);
        console.log('preventback called');

        if ('ontouchstart' in document.documentElement) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.applicationId,
                    objectApiName: 'Application__c',
                    actionName: 'view'
                }
            });
        } else {
            window.location.replace('/' + this.applicationId);
        }
    }

    tempsubmit() {
        this.errorMsgs = [];
        this.isLoading = true;
        this.dedupeDetails = undefined;
        if (this.applicationId) {
            try {
                this.getFeeWithoutRepayment();
                this.getZeroFee();
                var dedupeResult = this.template.querySelector('c-fsdedupe-details-lwc').submitDedupeData();
                console.log('dedupeResult in submit is >>>', dedupeResult);
                this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
            } catch (error) {
                console.log(error)
            }
        }
        else {
            this.isLoading = false;
            this.handlePreloginSubmit();
        }
    }

    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        this.requiredDocumentValidation();
    }

    requiredDocumentValidation() {
        console.log('requiredDocuments ', JSON.stringify(this.requiredDocuments));
        if (this.requiredDocuments.length > 0) {
            this.requiredDocuments.forEach(element => {
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.errorMsgs.push('Upload Application Document ' + element.documentName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Applicant') {
                    this.errorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.customerName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Asset') {
                    this.errorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.propertyName + ' In Document Upload Tab');
                }
            });
        }
    }

    rowselectionevent(event) {
        if (event.detail === 'pendingReason') {
            if (this.applicationId)
                this.showHidePendingReasonGrid();
            else
                this.showToast('Error', 'error', 'Application does not exist!!')
        }
        else
            this.tempsubmit();
    }

    async handlePreloginSubmit() {
        this.isLoading = false;
        if (this.buttonClick) {
            return;
        }

        if(this.isMobileVerMandatory.toUpperCase() === 'NO'){
            this.isMobileVerified = true;
        }

        // Added on 28.04.23 :
        await checkBureauVerified({appId: this.applicationId }).then(result => {
            console.log('checkBureauVerified= !!',result);
            if (!result) {
                console.log('Push Message Displayed!!');
                this.errorMsgs.push('Bureau Verfication Pending on Loan Applicants!!');
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Bureau Verification failed ', error);
        })

        await getPendingReasonValidation({applicationId: this.applicationId, stage: 'Login' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsgs.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })

        this.buttonClick = true;
        let reference = this;
        //reference.errorMsgs = [];
        console.log('this.hasPrimaryApplicant', reference.hasPrimaryApplicant, reference.hasPrimaryOwner, reference.isMobileVerified, reference.isKYCVerified, reference.isIncomeConsidered, reference.applicationId && reference.hasAllFields);
        console.log('this.receiptWrapper.lengthOfDirectRec', this.receiptWrapper.lengthOfDirectRec);
        //&& (this.receiptWrapper.hasReceipt == true || this.receiptWrapper.lengthOfDirectRec == 0)
        if (reference.errorMsgs.length == 0 && reference.hasAllFields && this.requiredDocuments.length == 0 && (!this.dedupeDetails || this.dedupeDetails.message.includes('Dedupe Exception found')) && reference.hasPrimaryApplicant && reference.hasPrimaryOwner && reference.isMobileVerified && reference.isKYCVerified && reference.isIncomeConsidered && reference.applicationId && (this.receiptWrapper.pendingReceiptList.length == 0) && this.receiptWrapper.existingFeeCodeOption.length == 0
            && !this.isFeeWithoutRepayment && !this.isZeroFee) {
            reference.showErrorTab = false;
            this.isLoading = true;
            
            await clonePropertyNew({ appId: reference.applicationId })
                .then(result => {
                    console.log('result ', result);
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('result ', error);
                })
            //alert(this.recTypeName);
            if (this.recTypeName == '1. New login') {
                console.log('Create Verfication Record');
                await createVerificationRecords({ applicationId: reference.applicationId })
                    .then(result => {
                        this.isLoading = false;
                        updateHistory({ appId: this.applicationId }).then((result) => {
                        }).catch((err) => {
                            console.log('Error in updateHistory = ', err);
                        });
                        console.log(result + 'from verification');
                        if (this.dedupeDetails && this.dedupeDetails.message.includes('Dedupe Exception found'))
                            reference.showToast('Success', 'Success', 'Dedupe Exception Found, Stage moved from Pre-Login to Pre Login Dedupe Exception!!');
                        else
                            reference.showToast('Success', 'Success', 'Loan Submitted Successfully from Pre-Login to Verification Stage!!');
                        reference.closeAction();
                        reference.redirectApplication();
                    })
                    .catch(error => {
                        this.isLoading = false;
                        console.log(error + 'from verification');
                    })
            }
            else {
                const fields = {};
                fields[APPLICATION_ID.fieldApiName] = this.applicationId;
                if (this.dedupeDetails && this.dedupeDetails.message.includes('Dedupe Exception found'))
                    fields[STAGE.fieldApiName] = 'Pre Login Dedupe Exception';
                else
                    fields[STAGE.fieldApiName] = 'Verification';
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {

                    updateHistory({ appId: this.applicationId }).then((result) => {
                    }).catch((err) => {
                        console.log('Error in updateHistory = ', err);
                    });
                    this.isLoading = false;
                    if (this.dedupeDetails && this.dedupeDetails.message.includes('Dedupe Exception found'))
                        reference.showToast('Success', 'Success', 'Dedupe Exception Found, Stage moved from Pre-Login to Pre Login Dedupe Exception!!');
                    else
                        reference.showToast('Success', 'Success', 'Loan Submitted Successfully from Pre-Login to Verification Stage!!');
                    reference.closeAction();
                    reference.redirectApplication();
                }).catch(error => {
                    console.log('Error in send back.', error);
                });
            }
        }
        else {
            this.buttonClick = false;
            console.log('error tab occur');
            if (!reference.applicationId) {
                reference.errorMsgs.push('Application ID does not exist, Add Customer in "Customer Detail" tab');
            }
            else {
                if (!reference.hasPrimaryApplicant) {
                    reference.errorMsgs.push('Add An Primary Applicant In Customer Details Tab');
                }
                if (!reference.hasPrimaryOwner) {
                    reference.errorMsgs.push('Add Atleast One Property Of Primary Applicant');
                }
                if (!reference.isMobileVerified) {
                    reference.errorMsgs.push('Verify Mobile Of Atleast One Applicant In Customer Details Tab');
                    //reference.errorMsgs.push('Verify Mobile Of ' + reference.mobDefList + ' In Customer Details Tab');
                }
                if (!reference.isKYCVerified) {
                    reference.errorMsgs.push('Verify KYC Of ' + reference.kycDefList + ' In Customer Details Tab');
                }
                if (!reference.isIncomeConsidered) {
                    reference.errorMsgs.push('Add Atleast One Income Considered Applicant In Customer Details Tab');
                }
                if (!reference.hasAllFields) {
                    reference.errorMsgs.push('Fill All Required Fields In Application Details Tab');
                }
                console.log('Receipt Defaulter List ', reference.receiptWrapper.pendingReceiptList.length);
                if (reference.receiptWrapper.pendingReceiptList.length > 0) {
                    reference.receiptWrapper.pendingReceiptList.forEach(element => {
                        if (element.RecStatus != 'Rejected') {
                            //  reference.errorMsgs.push('Approve Receipts ' + reference.receiptWrapper.pendingReceiptList.join() + ' In Fee Details Tab');
                            //reference.errorMsgs.push('Get Approve ' + element.RecStatus + ' Receipts ' +  element.name + ' In Fee Details Tab');
                            reference.errorMsgs.push(element.name + '- Kindly Approve/Reject the submitted receipt in Fee Details');
                        }
                    });
                }
                // if (reference.receiptWrapper.lengthOfDirectRec > 0 && reference.receiptWrapper.hasReceipt == false) {
                //     //reference.errorMsgs.push('Please Add Receipt in Fee Details Tab');
                // }
                // else {

                // }
                if (reference.receiptWrapper.existingFeeCodeOption.length > 0) {
                    reference.receiptWrapper.existingFeeCodeOption.forEach(element => {
                        reference.errorMsgs.push('Please Add Receipt in Fee Details Tab for Fee Code: ' + element.label);
                        console.log('reference.receiptWrapper.existingFeeCodeOption', element.label);
                    });
                }
                if (this.isFeeWithoutRepayment) {
                    reference.errorMsgs.push('Select Repayment Type in Fee Details section of Fee details tab');
                }
                if (this.isZeroFee) {
                    reference.errorMsgs.push('Total Fee can not be 0 in Fee Details section of Fee details tab');
                }
                console.log('dedupe is >>', this.dedupeDetails);
                if (this.dedupeDetails) {
                    if (!this.dedupeDetails.message.includes('Dedupe Exception found')) {
                        console.log('dedupe message is >>', this.dedupeDetails.message);
                        reference.errorMsgs.push(this.dedupeDetails.message);
                    }
                }
            }
            reference.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.activeError = 'Error';
            }, 300);
        }
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

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Added by Sangeeta yadav : 23/11/22 for fee validation
    //Sangeeta Yadav : Added on : 22/11/22 : fee repayment type validation
    getFeeWithoutRepayment() {
        console.log('in getFeeWithoutRepayment');
        console.log('pendingFeeAndReceiptForDA Stage - this.stageName in pending receipt ' + this.applicationId);
        getFeeWithoutRepayment({ recordId: this.applicationId })
            .then(result => {
                console.log('::: fee ::: ', result);
                this.isFeeWithoutRepayment = result;
                if (result) {
                    console.log('inside repayment value', result);
                    //this.arrValidateErrorMsgs.push('Please Select Repayment Type in Fee Details section of Fee Insurance details tab');
                }
            })
            .catch(error => {
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })
    }

    //Sangeeta Yadav : Added on : 22/11/22 : fee amount not null
    getZeroFee() {
        console.log('in getZeroFee');
        console.log('getZeroFee Stage - this.stageName in pending receipt ' + this.applicationId);
        getZeroFee({ recordId: this.applicationId })
            .then(result => {
                console.log('::: getZeroFee ::: ', result);
                this.isZeroFee = result;
                if (result) {
                    console.log('inside getZeroFee', result);
                    //this.arrValidateErrorMsgs.push('Total Fee can not be 0 in Fee Details section of Fee Insurance details tab');
                }
            })
            .catch(error => {
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })
    }
}