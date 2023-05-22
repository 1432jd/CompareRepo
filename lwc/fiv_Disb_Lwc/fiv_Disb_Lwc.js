import { LightningElement,wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//------------------------------------------------------------------------------
import BusinessDate from '@salesforce/label/c.Business_Date';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
//------------------------------------------------------------------------------

import checkLoggedInUser from '@salesforce/apex/Fiv_Disb_LwcController.checkLoggedInUser';
import getAllocatedUser from '@salesforce/apex/Fiv_Disb_LwcController.getAllocatedUser';
import trackUser from '@salesforce/apex/Fiv_Disb_LwcController.trackUser';
import checkDisbursalMemo from '@salesforce/apex/Fiv_Disb_LwcController.checkDisbursalMemo';
import getAppStage from '@salesforce/apex/Fiv_Disb_LwcController.getAppStage';
import setDisbursalDate from '@salesforce/apex/Fiv_Disb_LwcController.setDisbursalDate';
import getParentAndRelatedData from '@salesforce/apex/Fiv_Disb_LwcController.getParentAndRelatedData';
import allocateUser from '@salesforce/apex/Fiv_Disb_LwcController.allocateUser';
import updateApptStageFromDA from '@salesforce/apex/Fiv_Disb_LwcController.updateApptStageFromDA';
import chechExistDeviaitons from '@salesforce/apex/Fiv_Disb_LwcController.chechExistDeviaitons';
import getDeductionAmount from '@salesforce/apex/Fiv_Disb_LwcController.getDeductionAmount'; //Karan Singh : 03-10-2022 : CH
import changeDisbursalRecTypeId from '@salesforce/apex/Fiv_Disb_LwcController.changeDisbursalRecTypeId'; //Karan Singh : 04-10-2022 : CH
//import getRequiredDocuments from '@salesforce/apex/fsGenericUploadDocumentsController.getRequiredDocuments'; CH01
//------------------------------------------------------------------------------
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import STAGE_FIELD from '@salesforce/schema/Application__c.Stage__c';
import SUB_STAGE from '@salesforce/schema/Application__c.Sub_Stage__c';
import Disbursal_Author_Decision_FIELD from '@salesforce/schema/Application__c.Disbursal_Author_Decision__c';
import Disbursal_Author_Decision_Remarks_FIELD from '@salesforce/schema/Application__c.Disbursal_Author_Decision_Remarks__c';
//import Disbursal_Author_CompleteDate_FIELD from '@salesforce/schema/Application__c.Disbursal_Author_Completion_Date__c'; //done in Apex
import Disbursal_Maker_CompleteDate_FIELD from '@salesforce/schema/Application__c.Disbursal_Maker_Completion_Date__c';
import Decision_Date_Time__FIELD from '@salesforce/schema/Application__c.Decision_Date_Time__c';
import Disbursal_Date from '@salesforce/schema/Application__c.Disbursal_Date__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
//------------------------------------------------------------------------------
//CH01 : Karan : 12-09-2022 : Commented as this comp is not ready as per Yogendra
import getPropertyRecords from '@salesforce/apex/FS_LMS_CreateColletralAPI.getPropertyRecords';
import createColletral from '@salesforce/apex/FS_LMS_CreateColletralAPI.createColletral';
import createLoan from '@salesforce/apex/FS_LMS_BookLoanAPI.createLoan';
import getRepaySchedule from '@salesforce/apex/FS_LMS_GetRepayScheduleAPI.getRepaySchedule';
import checkInsuranceValidation from '@salesforce/apex/fsPcAcController.checkInsuranceValidation';
//Added by sangeeta : 04/11/22 : for fee and receipt validation
import pendingFeeAndReceiptForDA from '@salesforce/apex/FeeReceiptController.pendingFeeAndReceiptForDA';

//Added by Sangeeta : 22/11/22 : for repayment and zero fee validation
import getFeeWithoutRepayment from '@salesforce/apex/FeeCreationComponentHelper.getFeeWithoutRepayment';
import getZeroFee from '@salesforce/apex/FeeCreationComponentHelper.getZeroFee';
import getAdvanceInstallmentAmt from '@salesforce/apex/Fiv_Disb_LwcController.getAdvanceInstallmentAmt';
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';

//---------------------------------------------------------------------------------------------

//Added By Kuldeep Sahu : 17/05/23 : for sendback to legal approval and approval credit
import sendBackAprovalCredit from '@salesforce/apex/PostApprovalController.sendBackAprovalCredit';
import { getRecord } from 'lightning/uiRecordApi';
//---------------------------------------------------------------------------------------------

export default class Fiv_Disb_Lwc extends NavigationMixin(LightningElement) {

    @api recordId;
    @track subStage;
    @track showPendingReason = false;
    @track checkIsAllocated = false;
    @track propertyarr = [];
    @track checkApprovalStatus = '';
    @track isCreateColletralFailed = false;
    @track isRepayScheduledFailed = false;
    @track isBookLoanFailed = false;
    todaysDate = BusinessDate;
    lastLoginDate;
    @track objApptWrapperData;
    @track appBranch = '';
    showLoader = false;
    stageName = '';
    loadAll = false;
    apptPrimaryApplicantName = '';
    @track objValidateChildComps = {};
    @track arrValidateErrorMsgs = [];
    showErrorTab = false;
    isDmScreen = false;
    activeTabName = 'Loan Parameters';
    disableSubmit = false;
    sendback = false;
    showApprovalmodal = false;
    @track approvalOptions = [{ label: "Approve", value: "Approve" }, { label: "Reject", value: "Reject" }];
    slcdApprvalOpt = '';
    approvalRemarks = '';
    showapprovalRemarks = false;
    @track btns = [];
    @track arrReqDocNames = [];
    @track checkBookLoanNumber = '';
    @track checkrepayschedule = '';
    acRecordId = '';
    currentDate = undefined;
    @track objdeductiondetails = {};//Karan Singh : 03-10-2022 - CH
    countAmtChangeNotif = 0;//Karan Singh : 03-10-2022 - CH - this is done so that at inital load no notification should be send
    //--------------------------------------------------------------------------
    
    @wire(getRecord, { recordId: '$recordId', fields: [SUB_STAGE] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            if (data.fields.Sub_Stage__c && data.fields.Sub_Stage__c.value) {
                this.subStage = data.fields.Sub_Stage__c.value;
            }
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }
    
    connectedCallback() {
        console.log('STAGE_FIELD is >>>', STAGE_FIELD);
        this.init();

    }

    //this method is used to re-initialize track variable with data after save or load functionality
    init() {
        this.checkAllocatedUser();
        let dateTime = new Date();//Karan Singh 26-09-2022: CH : Used to completion date of DM
        this.currentDate = dateTime.getFullYear() + '-' + (dateTime.getMonth() + 1) + '-' + dateTime.getDate();
        this.countAmtChangeNotif = 0;//Karan Singh : 03-10-2022 - CH 
        this.slcdApprvalOpt = '';
        this.approvalRemarks = '';
        this.arrReqDocNames = [];
        this.acRecordId = '';
        this.showapprovalRemarks = false;
        this.getParentAndRelatedData(true);
        this.handleGetLastLoginDate();
        this.getAppStageName();
        this.getDeductionAmount(); //Karan SIngh : 03-10-2022 : CH
        this.disableSubmit = true;
    }
    //application  data refreshed to get latest dibursal record

    checkAllocatedUser() {

        console.log('record id wile allocat>>>', this.recordId);

        getAllocatedUser({
            apptId: this.recordId
        }).then((result) => {
            console.log('before checking allocatio >>>', result);
            if (result) {
                this.checkIsAllocated = true;
            } else if (!result) {
                console.log('checking allocatio >>>', this.checkIsAllocated);
                this.checkIsAllocated = false;
            }
        }).catch((err) => {
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });

    }

    getAppStageName() {

        getAppStage({
            apptId: this.recordId
        }).then((result) => {
            var appValues = JSON.parse(JSON.stringify((result)));
            console.log('appValues >>>', appValues);
            this.appStage = appValues[0].Stage__c;
            this.appBranch = appValues[0].Sourcing_Branch__c;
            console.log('this.appStage >>>>', this.appStage);
            console.log('this.appBranch >>>>', this.appBranch);
        }).catch((err) => {
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }

    reloadApplicationData() {

        console.log('Fiv_Disb_Lwc reload Appt Data ');
        this.disableSubmit = true;
        this.getParentAndRelatedData(false);
        this.getDeductionAmount(); //Karan SIngh : 03-10-2022 : CH
    }
    //once the data is fetched then load the other tabs,reloadTab willtrue for first time only
    getParentAndRelatedData(reloadTab) {

        //if (!isTabFuncInvoke) { //for first time it should be null else if will re-render the whole screen html line 13 : template if:true={objApptWrapperData}
        //  this.objApptWrapperData = undefined;
        //}
        this.showLoader = true;
        console.log(this.recordId);
        getParentAndRelatedData({
            recordId: this.recordId
        }).then((result) => {

            console.log('Fiv_Disb_Lwc objApptWrapperData = ', JSON.stringify(result));

            if (result.statusCode !== 200) {

                this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                this.showLoader = false;
            } else {

                this.objApptWrapperData = result;
                console.log('objap data check is >>', this.objApptWrapperData);
                console.log(typeof this.objApptWrapperData.mapExtraParams);

                if (this.objApptWrapperData.mapExtraParams.hasOwnProperty('apptPrimaryApplicantName')) {
                    this.apptPrimaryApplicantName = this.objApptWrapperData.mapExtraParams.apptPrimaryApplicantName;
                }

                if (this.objApptWrapperData.mapExtraParams.hasOwnProperty('acRecordId')) {

                    this.acRecordId = this.objApptWrapperData.mapExtraParams.acRecordId;
                }

                //this.apptPrimaryApplicantName = this.objApptWrapperData.
                //if (isTabFuncInvoke) { //once the data is load it should reload current data 
                //  this['get' + this.currentTabName]();//this will call method dynamically as per tabName
                //} else {
                //  this.showLoader = false; //this is done so that once reloading of all data done then only it will false, else spinner handle in above if
                //}
                //----------------------------------------------------------------------------------
                //this is done so that all the tabs been loaded so that we can invoke their methods for Submit validations
                try {
                    if (reloadTab && this.showTabsData) {
                        setTimeout(() => {
                            this.showLoader = true;
                            let tabs = this.template.querySelectorAll('lightning-tab');
                            console.log('tabs ', tabs);
                            console.log('tabs ', tabs.length);
                            tabs.forEach(element => {
                                console.log('element -> ' + JSON.stringify(element));
                                element.loadContent();
                            });
                            setTimeout(() => {
                                this.disableSubmit = false;
                                this.showLoader = false;
                            }, 5000);//load when all tabs been loaded
                        }, 2000);
                    } else {
                        this.disableSubmit = false;
                        this.showLoader = false;
                    }
                } catch (error) {
                    console.log('Error in lwc tab load', error.message);
                    this.disableSubmit = false;
                    this.showLoader = false;
                }
                //this.getRequiredDocuments(); CH01
            }

        }).catch((err) => {

            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc getParentAndRelatedData = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }
    //==========================================================================
    /** Karan Singh : 03-10-2022 : CH */
    getDeductionAmount() {
        getDeductionAmount({
            apptId: this.recordId
        }).then((result) => {

            console.log('Fiv_Disb_Lwc getDeductionAmount = ', JSON.stringify(result));
            this.objdeductiondetails = result.mapExtraParams;
            console.log(`result ${typeof this.objdeductiondetails} and objDeduction - ${JSON.stringify(this.objdeductiondetails)}`);
        }).catch((err) => {

            console.log('Error in Fiv_Disb_Lwc getDeductionAmount = ', err);
        });
    }
    checkExistingDisbursalId() {

        if (this.objApptWrapperData.objAppt.hasOwnProperty('Disbursals__r')) {
            console.log('this.objApptWrapperData.Disbursals__r[0].Id ' + this.objApptWrapperData.objAppt.Disbursals__r[0].Id);
            return this.objApptWrapperData.objAppt.Disbursals__r[0].Id;
        }
        return null;
    }
    //==========================================================================
    //--------------------------------------------------------------------------
    //only show Tabs if the stage is Disbursal Maker/Author
    get showTabsData() {


        if (this.objApptWrapperData && this.objApptWrapperData.disbMetaPrefix) {
            this.stageName = this.objApptWrapperData.disbMetaPrefix == 'DISBM_' ? 'Disbursal Maker' : 'Disbursal Author';
            this.isDmScreen = this.objApptWrapperData.disbMetaPrefix.includes('DISB') ? true : false;

            if (this.isDmScreen && this.btns.length == 0) {
                this.btns.push({
                    name: 'Send Back',
                    label: 'Send Back',
                    variant: 'brand',
                    class: 'slds-m-left_x-small'
                });
                this.btns.push({
                    name: 'Generate_CAM_Report',
                    label: 'Generate CAM Report',
                    variant: 'brand',
                    class: 'slds-m-left_x-small'
                });
                this.btns.push({
                    name: 'Submit',
                    label: 'Submit',
                    variant: 'brand',
                    class: 'slds-m-left_x-small'
                });
                this.btns.push({
                    name: 'pendingReason',
                    label: 'Pending Reason',
                    variant: 'brand',
                    class: 'slds-m-left_x-small'
                });
            }
            return true;
        } else {
            console.log('isnide else checl');
            return false;
        }
    }
    //--------------------------------------------------------------------------
    handleHeaderButton(event) {
        var detail = event.detail;
        console.log('detail ### ', JSON.stringify(detail));

        if (detail === 'Submit') {
            this.showErrorTab = false;
            getPendingReasonValidation({ applicationId: this.recordId, stage: this.appStage }).then(result => {
                console.log('getPendingReasonValidation= !!', result);
                if (result) {
                    console.log('getPendingReasonValidation Message Displayed!!');
                    this.showErrorTab = true;
                    this.arrValidateErrorMsgs.push('Pending Reasons Not Resolved.');
                    let thisRef = this;
                    setTimeout(() => {
                        thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                    }, 300);
                    
                } else {
                    this.checkDisbDate();
                }
            }).catch(error => {
                this.isLoading = false;
                console.log('Pending Reasons Not Resolved. ', error);
            })
        }

        if (detail === 'Send Back') {
            this.sendback = true;
        }
        if (event.detail === 'pendingReason') {
            this.showHidePendingReasonGrid();
        }

        if (detail === 'Generate_CAM_Report') {
            console.log('Generate CAM Called');
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/CAMReportVf?id=' + this.recordId + '&Generated_From=AC'
                }
            }).then(vfURL => {
                window.open(vfURL);
            });
        }

    }
    handleTabActivation(event) {

        console.log('handleTabActivation= ', event.target.value);
        // Added by Sangeeta to refresh Deviation Detail on Tab click
        var tab = event.target.value;
        if (tab === 'Deviation Details') {
            console.log('Active tab name', tab);
            setTimeout(() => {
                if (this.template.querySelector('c-pc-deviation')) {
                    this.template.querySelector('c-pc-deviation').showDev();
                }
            }, 300);
        }

    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }

    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
    handleChangeInFeeInsurance(event) {
        console.log('New record added in Fee Insurance. Refresh Application Data');
        this.init();
        //Karan SIngh : 07-10-2022 : CH This means if the event was fire after creating a record in the Insurance Record, then check the deduction logic
        this.getDeductionAmount();
        if (this.template.querySelector('c-fiv_-disb_-disbursal-params')) {
            this.template.querySelector('c-fiv_-disb_-disbursal-params').doInit();
        } if (this.template.querySelector('c-fiv_-disb_-disbursal-payee')) {
            this.template.querySelector('c-fiv_-disb_-disbursal-payee').getDeductionAmount();
        }
    }

    //--------------------------------------------------------------------------

    getReceiptPendingList(event) {
        console.log('Receipt data approved ', JSON.stringify(event.detail));
        //this.receiptWrapper.hasReceipt = event.detail.hasReceipt;
        //this.receiptWrapper.allApproved = event.detail.allApproved;
        //this.receiptWrapper.pendingReceiptList = event.detail.pendingReceiptList;
    }
    //--------------------------------------------------------------------------
    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }
    handleBeforeSubmitCustmEvt(event) {

        console.log('handleBeforeSubmitCustmEvt ', JSON.stringify(event.detail));
        if (this.objValidateChildComps.hasOwnProperty(event.detail.fieldName)) {
            console.log('inside first if ');
            this.objValidateChildComps[event.detail.fieldName] = event.detail.isValid
            if (event.detail.msg) {
                this.arrValidateErrorMsgs.push(event.detail.msg);
            }


        } else if (event.detail.hasOwnProperty('hasReceipt')
            && this.objValidateChildComps.hasOwnProperty('feeInsDetails')) {
            console.log('second first if ');
            var errorFound = false;
            //sangeet feereciept logic below
            //example event.detail :  {"hasReceipt":true,"allApproved":true,"pendingReceiptList":[],"lengthOfDirectRec":1}
            if (!event.detail.hasReceipt && event.detail.lengthOfDirectRec > 0) {
                console.log('1');
                console.log('third first if ');
                // errorFound = true;
                // this.objValidateChildComps['feeInsDetails'] = false;

                //  for (var element in event.detail.existingFeeCodeOption) {
                //@Author : Sangeeta 
                //@ Description : using element.value was giving undefined so changed to event.detail.existingFeeCodeOption[element].value
                //  this.arrValidateErrorMsgs.push('Please Add Receipt in Fee Details Tab for Fee Code : ' + event.detail.existingFeeCodeOption[element].value);
                // }
            }
            if (!event.detail.allApproved && event.detail.hasReceipt) {
                console.log('2');
                console.log('four first if ');
                // errorFound = true;
                // this.objValidateChildComps['feeInsDetails'] = false;
                // this.arrValidateErrorMsgs.push('Please check if all receipts are approved');
            }
            if (event.detail.pendingReceiptList.length > 0 && event.detail.hasReceipt) {
                console.log('3');
                console.log('five first if ');
                //  errorFound = true;
                //  this.objValidateChildComps['feeInsDetails'] = false;
                //  this.arrValidateErrorMsgs.push('Please check if there are any pending receipts');
            }
            console.log('errorFound ', errorFound);
            console.log('after first if ', this.objValidateChildComps['feeInsDetails']);
            //if all above conditions are false then 
            if (!errorFound) {
                console.log('else first if ');
                this.objValidateChildComps['feeInsDetails'] = true;
                //   console.log('else first if ',this.objValidateChildComps['feeInsDetails']);
            }

        }
        /** Karan Singh : 03-10-2022 : CH */
        if (event.detail.hasOwnProperty('hasReceipt')) {

            //This means if the event was fire after creating a record in the Fee Creation Record, then check the deduction logic
            this.getDeductionAmount();
            if (this.template.querySelector('c-fiv_-disb_-disbursal-params')) {
                this.template.querySelector('c-fiv_-disb_-disbursal-params').doInit();
            } if (this.template.querySelector('c-fiv_-disb_-disbursal-payee')) {
                this.template.querySelector('c-fiv_-disb_-disbursal-payee').getDeductionAmount();
            }
            console.log('this.countAmtChangeNotif - ' + this.countAmtChangeNotif);
            if (this.countAmtChangeNotif >= 2) {

                //this.showNotification('', 'There might be changes in Disbursal Parameters and Disbursal Payee Details. Please review them before proceeding.', 'warning');

            } else {
                this.countAmtChangeNotif++;
            }

        }
        //======================================================================
    }
    //============================================================================
    //By : Suresh
    //Date : 19/08/ 2022

    handleSubmitClick(event) {

        console.log('handleSubmitClick ', JSON.stringify(event.detail));
        let value = event.detail;

        if(value){
            sendBackAprovalCredit({ applicationId: this.recordId }).then((result) => {
                console.log('sendBackAprovalCredit = ',result)                
                if(result == 'Success'){
                    const fields = {};   
                    if(value == 'Approval Credit'){
                        fields[STAGE_FIELD.fieldApiName] = event.detail;
                    } else if(value == 'Legal Approval'){
                        fields[STAGE_FIELD.fieldApiName] = 'Awaiting Legal Approval';
                        fields[SUB_STAGE.fieldApiName] = 'Legal Approval';
                    }   
                    fields[ID_FIELD.fieldApiName] = this.objApptWrapperData.objAppt.Id;                         
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        this.showNotification('Success', 'Send Back Successful..', 'success');
                        this.changeDisbursalRecTypeId(JSON.stringify({ 'disbId': this.checkExistingDisbursalId(), 'disbRecTypeName': 'Disbursal Maker' }));                
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.objApptWrapperData.objAppt.Id,
                                objectApiName: 'Application__c',
                                actionName: 'view'
                            }
                        });
                    }).catch(error => {
                        console.log('error on stage save -> ' + error);
                        this.showNotification('Error', error.body.message, 'error');
                    });
                } else {
                    console.log('Error in sendBackAprovalCredit = ', result)
                }       
            }).catch((err) => {
                console.log('Error in sendBackAprovalCredit = ', err)
            });
        }        
    }
    handlesendbackclose(event) {
        this.sendback = false;
    }
    //===========================================================================================================
    getRequiredDocuments() {
        this.arrReqDocNames = [];
        getRequiredDocuments({ stage: this.stageName, parentId: this.objApptWrapperData.objAppt.Id })
            .then(result => {
                console.log('::: result ::: ', JSON.stringify(result));
                this.arrReqDocNames = result;
            })
            .catch(error => {
                console.log('error doc upload ', error);
            })
    }

    /*handleCheckRequiredDocs() {
        if (this.arrReqDocNames.length > 0) {
            this.arrReqDocNames.forEach(element => {
                this.arrValidateErrorMsgs.push('Upload Required Document ' + element + ' In Document Upload Tab');
            });
        }
    }*/

    requiredDocumentValidation() {
        console.log('arrReqDocNames', JSON.stringify(this.arrReqDocNames));
        if (this.arrReqDocNames.length > 0) {
            this.arrReqDocNames.forEach(element => {
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.arrValidateErrorMsgs.push('Upload Application Document ' + element.documentName + ' In Document Upload Tab');
                    this.showErrorTab = true;
                }
                if (element.documentType === 'Applicant') {
                    this.arrValidateErrorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.customerName + ' In Document Upload Tab');
                    this.showErrorTab = true;
                }
                if (element.documentType === 'Asset') {
                    this.arrValidateErrorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.propertyName + ' In Document Upload Tab');
                    this.showErrorTab = true;
                }
            });
        } else {
            this.showErrorTab = false;
        }
    }
    //Karan Singh : Added : 17-09-2022 : Deviation validation only for DA
    checkExistDeviation() {

        if (this.stageName !== 'Disbursal Author') {
            return;
        }
        console.log('chechExistDeviaitons Stage - this.stageName ' + this.objApptWrapperData.objAppt.Id);
        chechExistDeviaitons({ apptId: this.objApptWrapperData.objAppt.Id })
            .then(result => {
                console.log('::: chechExistDeviaitons result ::: ', JSON.stringify(result));

                if (result.statusCode !== 200) {

                    this.objValidateChildComps['allApprvDeviaiton'] = false;
                    this.arrValidateErrorMsgs.push(result.message);
                }
            })
            .catch(error => {
                this.showNotification('Error', error.body.message, 'error');
                console.log('error on checkExistDeviation save -> ' + JSON.stringify(error.body.message));
            })

    }

    // added  by sandeep kumar
    checkInsuranceApi() {
        console.log('inside insirance api log');
        checkInsuranceValidation({ applicationId: this.recordId })
            .then(result => {
                if (result) {
                    this.arrValidateErrorMsgs.push('Please Invoke Insurance Api First');
                }
            })
            .catch(err => {
                console.log('Error %%%', err);
            })
    }


    //Sangeeta Yadav : Added : 23/12/22 : to check if advance installment fee = Emi* no of installment
    getAdvanceInstallmentAmt() {
        console.log('inside getAdvanceInstallmentAmt');
        getAdvanceInstallmentAmt({ applicationId: this.recordId })
            .then(result => {
                console.log('inside getAdvanceInstallmentAmt result ' + result);
                if (result) {
                    this.arrValidateErrorMsgs.push(result);
                    // this.arrValidateErrorMsgs.push('Advance Installment Fee amount is not same as EMI amount times number of installments');
                }
            })
            .catch(err => {
                console.log('Error %%%', err);
            })
    }

    //Sangeeta Yadav : Added : 04/11/22 : Fee and Receipt validation only for DA
    getPendingFeeAndReceiptForDA() {
        console.log('in getPendingFeeAndReceiptForDA');
        if (this.stageName !== 'Disbursal Author') {
            return;
        }
        console.log('pendingFeeAndReceiptForDA Stage - this.stageName in pending receipt ' + this.objApptWrapperData.objAppt.Id);
        pendingFeeAndReceiptForDA({ applicationId: this.objApptWrapperData.objAppt.Id })
            .then(result => {
                console.log('::: pendingFeeAndReceiptForDA result ::: ', result, Object.keys(result).length);
                var resultLen = Object.keys(result).length;
                if (resultLen == undefined || resultLen == null || resultLen == 0) {
                    console.log('inside undefine da');
                } else {
                    this.objValidateChildComps['feeInsDetails'] = false;
                    for (let key in result) {
                        console.log('key in fee and receipt pending', result[key], key);
                        if (result[key] != null && result[key].length > 0) {
                            var errorList = result[key]
                            console.log('error list of pending receipt', errorList);

                            if (key == 'Receipt') {
                                errorList.forEach(element => {
                                    console.log('element for receipt pending list', JSON.stringify(element));
                                    this.arrValidateErrorMsgs.push(element + '- Kindly Approve/Reject the submitted receipt in Fee Details');
                                });
                            }
                            if (key == 'Fee') {
                                errorList.forEach(element => {
                                    console.log('element for receipt pending list', JSON.stringify(element));
                                    this.arrValidateErrorMsgs.push('Please Add Receipt in Fee Details Tab for Fee Code : ' + element);
                                });
                            }
                        }
                    }
                    //this.arrValidateErrorMsgs.push(result.message);
                }

            })
            .catch(error => {
                // this.showNotification('Error', error.body.message, 'error');
                console.log('error on checkExistDeviation save -> ' + JSON.stringify(error));
            })

    }


    //Sangeeta Yadav : Added on : 22/11/22 : fee repayment type validation
    getFeeWithoutRepayment() {
        console.log('in getFeeWithoutRepayment');

        console.log('pendingFeeAndReceiptForDA Stage - this.stageName in pending receipt ' + this.objApptWrapperData.objAppt.Id);
        getFeeWithoutRepayment({ recordId: this.objApptWrapperData.objAppt.Id })
            .then(result => {
                console.log('::: fee ::: ', result);

                if (result) {
                    console.log('inside repayment value', result);

                    this.objValidateChildComps['feeInsDetails'] = false;


                    this.arrValidateErrorMsgs.push('Please Select Repayment Type in Fee Details section of Fee Insurance details tab');
                }

            })
            .catch(error => {
                // this.showNotification('Error', error.body.message, 'error');
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })

    }

    //Sangeeta Yadav : Added on : 22/11/22 : fee amount not null
    getZeroFee() {
        console.log('in getZeroFee');

        console.log('getZeroFee Stage - this.stageName in pending receipt ' + this.objApptWrapperData.objAppt.Id);
        getZeroFee({ recordId: this.objApptWrapperData.objAppt.Id })
            .then(result => {
                console.log('::: getZeroFee ::: ', result);

                if (result) {
                    console.log('inside getZeroFee', result);

                    this.objValidateChildComps['feeInsDetails'] = false;


                    this.arrValidateErrorMsgs.push('Total Fee can not be 0 in Fee Details section of Fee Insurance details tab');
                }

            })
            .catch(error => {
                // this.showNotification('Error', error.body.message, 'error');
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })

    }

    // added  by sandeep kumar




    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.arrReqDocNames = event.detail;
    }
    //==========================================================================
    //===========================================================================================================
    changeDisbursalRecTypeId(strJson) {
        console.log('changeDisbursalRecTypeId invoked');
        changeDisbursalRecTypeId({ jsonParamData: strJson }).then(result => {
            console.log('::: changeDisbursalRecTypeId result ::: ', JSON.stringify(result));
        }).catch(error => {
            console.log('error changeDisbursalRecTypeId ', error);
        })
    }

    //==============================================================================================

    callCollateralApi(propertyId) {
        console.log('propertyId in promise >>', propertyId);
        return new Promise((resolve, reject) => {

            createColletral({ propertyRecordId: propertyId })
                .then(result => {
                    resolve(result);
                })
                .catch(error => {
                    console.log(error);
                    reject(error);
                });

        });
    }

    async callfun() {

        console.log('inside call fun');
        this.arrValidateErrorMsgs = [];
        this.showLoader = true;

        if (this.propertyarr.length > 0) {

            console.log('this.propertyarr in callfun is >>>', JSON.stringify(this.propertyarr));

            for (let i = 0; i < this.propertyarr.length; i++) {
                console.log('property id is >>>', this.propertyarr[i].Id);
                var rslt = await this.callCollateralApi(this.propertyarr[i].Id);

                console.log('collateral fist api error', rslt);
                if (rslt != null) {
                    if (rslt.includes('Error')) {
                        console.log('insidr first api error');
                        this.arrValidateErrorMsgs.push('Colletral api failed : ' + '' + rslt);
                        this.isCreateColletralFailed = true;
                    } else if (rslt.includes('Success') && this.arrValidateErrorMsgs.length == 0 && i == (this.propertyarr.length - 1)) {
                        this.callBookLoanMethod();
                    }
                }

                if (i == (this.propertyarr.length - 1) && this.isCreateColletralFailed) {
                    this.showErrorTab = true;
                    console.log('insidr toast mesage api error');
                    //this.showLoader = false;
                    let thisRef = this;
                    setTimeout(() => {
                        thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                        thisRef.showLoader = false;
                        thisRef.disableSubmit = false;
                    }, 300);
                    // this.showNotification('Error', 'Required Field Missing Colletral api', 'error');

                }
            }
        } else if (this.propertyarr.length == 0) {
            console.log('callBookLoanMethod call fun');
            this.callBookLoanMethod();
        }
    }


    async callBookLoanMethod() {
        console.log('inside callBookLoanMethod call fun');
        if (!this.isCreateColletralFailed) {
            console.log('this.checkBookLoanNumber >>>' + this.checkBookLoanNumber);
            if (this.checkBookLoanNumber == 'false') {
                var createLoanResult = await this.callcreateLoan();
                console.log('insode createLoan');
                console.log('book loan fist api error', createLoanResult);
                if (createLoanResult != null) {
                    if (createLoanResult.includes('Error')) {
                        this.showErrorTab = true;
                        this.isBookLoanFailed = true;
                        this.arrValidateErrorMsgs.push('Book Loan api failed : ' + '' + createLoanResult);
                        let thisRef = this;
                        setTimeout(() => {
                            thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                            thisRef.showLoader = false;
                            thisRef.disableSubmit = false;
                        }, 300);
                        // this.showLoader = false;
                        //this.showNotification('Error', 'Required Field Missing in book loan api', 'error');
                    } else if (createLoanResult.includes('Success')) {
                        this.callRepayApi();
                    }
                } else {
                    this.isBookLoanFailed = true;
                    this.showErrorTab = true;
                    this.arrValidateErrorMsgs.push('Book loan API Failed');
                    let thisRef = this;
                    setTimeout(() => {
                        thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                        thisRef.showLoader = false;
                        thisRef.disableSubmit = false;
                    }, 300);
                    //this.showLoader = false;
                    //this.showNotification('Error', 'Book loan API Failed', 'error');
                }
            } else if (this.checkBookLoanNumber != 'false' && this.checkBookLoanNumber) {
                this.callRepayApi();
            }
        }
    }

    async callRepayApi() {
        console.log('callRepayApi call fun');
        if (!this.isBookLoanFailed && !this.isCreateColletralFailed) {
            console.log('this.checkrepayschedule 613', this.checkrepayschedule);

            if (this.checkrepayschedule && this.checkrepayschedule == 'false') {

                var rsResult = await this.callRepaySchedule();
                console.log('insode reapu loan', rsResult);
                if (rsResult != null && rsResult != undefined) {
                    if (rsResult.includes('Error')) {
                        this.showErrorTab = true;
                        this.isRepayScheduledFailed = true;
                        // this.showLoader = false;
                        // this.showNotification('Error', 'Required Field Missing in Receipt api', 'error');
                        this.arrValidateErrorMsgs.push('Repay Schedule api failed : ' + '' + rsResult);
                        let thisRef = this;
                        setTimeout(() => {
                            thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                            thisRef.showLoader = false;
                            thisRef.disableSubmit = false;
                        }, 300);
                    } else if (rsResult.includes('Success')) {
                        this.callSuccessMsg();
                    }
                } else {
                    this.isRepayScheduledFailed = true;
                    this.showErrorTab = true;
                    this.arrValidateErrorMsgs.push('Repay schedule API failed');
                    let thisRef = this;
                    setTimeout(() => {
                        thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                        thisRef.showLoader = false;
                        thisRef.disableSubmit = false;
                    }, 300);
                    //this.showLoader = false;
                    //this.showNotification('Error', 'Repay schedule API failed', 'error');
                }
            } else if (this.checkrepayschedule == 'true' && this.checkrepayschedule) {
                this.callSuccessMsg();
            }
            else if (!this.checkrepayschedule) {
                console.log('inside else of repays scddule');
                this.isRepayScheduledFailed = true;
                this.showErrorTab = true;
                this.arrValidateErrorMsgs.push('Repay schedule API failed');
                console.log('arra ys is >>', this.arrValidateErrorMsgs);
                let thisRef = this;
                setTimeout(() => {
                    thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                    thisRef.showLoader = false;
                    thisRef.disableSubmit = false;
                    console.log('ionside tyhe settimeout');
                }, 300);
                //this.showLoader = false;
                //this.showNotification('Error', 'Repay schedule API failed', 'error');
            }
        }
    }


    callSuccessMsg() {

        if (!this.isRepayScheduledFailed && !this.isBookLoanFailed && !this.isCreateColletralFailed) {
            // this.showLoader = false;
            // this.checkDisbursalMemoValidation();
            this.checkDisbursalMemoValidation();
            this.handleStages();
            this.showNotification('Success', 'Api executed successfully', 'success');
        }
    }


    callRepaySchedule() {

        console.log('record is in rapys is >>' + this.recordId);
        return new Promise((resolve, reject) => {
            getRepaySchedule({ apptId: this.recordId })
                .then(result => {
                    resolve(result);
                })
                .catch(error => {
                    console.log(error);
                    reject(error);
                });

        });
    }

    callcreateLoan() {

        return new Promise((resolve, reject) => {
            createLoan({ applicationRecordId: this.recordId })
                .then(result => {
                    resolve(result);
                })
                .catch(error => {
                    console.log(error);
                    reject(error);
                });

        });


    }

    trackAllocateUser(stageName, apptId) {

        trackUser({
            stageName: stageName,
            apptId: apptId
        }).then((result) => {
            console.log('resulyt if allocate>>' + result);
            if (!result) {
                console.log('inside resulyt if allocate>>' + result);
                this.checkIsAllocated = false;
                this.showLoader = false;
            } else if (result) {
                console.log('oiutside resulyt if allocate>>' + result);
                this.checkIsAllocated = true;
                this.navigateApptList();
                this.showLoader = false;
            }


        }).catch((err) => {
            this.showLoader = false;
        });



    }

    /*starting of code by sandeep kumar*/
    checkDisbDate() {
        this.showLoader = true;
        this.showErrorTab = false;
        console.log('inside the checkDisbDate');
        setDisbursalDate({ appId: this.recordId }).then((result) => {
            if (result) {
                console.log('result repay >>>', result);
                const myArray = result.split("+");
                this.checkBookLoanNumber = myArray[0];
                this.checkrepayschedule = myArray[1];
                this.checkApprovalStatus = myArray[2];
                this.handleDisbSubmit();
                console.log('this.checkBookLoanNumber 684', this.checkBookLoanNumber);
                console.log('this.checkrepayschedule 685', this.checkrepayschedule);
                console.log('this.checkApprovalStatus 954', this.checkApprovalStatus);
            }
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });
    }
    /*ending of code by sandeep kumar*/

    //------------------------------------------
    handleDisbSubmit(event) {

        //    this.checkDisbDate(); // added by sandeep kumar


        this.arrValidateErrorMsgs = [];
        // this.disableSubmit = true;

        this.objValidateChildComps = { 'loanParam': null, 'disbParam': null, 'disbPayee': null, /*'ckycDetails': null,*/ 'userDetails': null, 'feeInsDetails': null, 'insuranceDetails': null, 'repayDetails': null };
        setTimeout(() => {
            try {
                //this.handleCheckRequiredDocs(); will implement later
                this.template.querySelector('c-fiv_-disb_-loan-Params').checkBeforeSubmit();
                this.template.querySelector('c-fee-creation-parent').getReceipt();
                this.template.querySelector('c-fiv_-disb_-disbursal-params').checkBeforeSubmit();
                this.template.querySelector('c-fiv_-disb_-disbursal-payee').checkBeforeSubmit();
                this.template.querySelector('c-fiv_-disb_-insurance-details').checkBeforeSubmit();
                this.template.querySelector('c-fiv_-disb_-repayment-details').checkBeforeSubmit();
                // this.template.querySelector('c-fiv_-disb_-ckyc-details').checkBeforeSubmit();
                this.template.querySelector('c-fiv_-disb_-user-details').checkBeforeSubmit();
                //this.handleCheckRequiredDocs(); //for the Document Tab 'documents': null,

                //checking for required document
                if (this.arrReqDocNames.length > 0) {

                    //this.objValidateChildComps['reqDocs'] = false; //CH01
                    //this.handleCheckRequiredDocs(); //CH01

                }
                try {
                    this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
                    this.checkExistDeviation();
                    this.checkInsuranceApi();//added by sandeep kumar
                    this.getAdvanceInstallmentAmt();
                    console.log('get pending receipt called');
                    this.getPendingFeeAndReceiptForDA();
                    this.getFeeWithoutRepayment();
                    this.getZeroFee();
                } catch (error) {
                    console.log(error)
                }
                setTimeout(() => {
                    this.requiredDocumentValidation();
                }, 3000);
            } catch (error) {

                console.log('error handleDisbSubmit - > ', error);
                //this.showNotification('ERROR', error.message, 'error');
            }
            //this is done so that all the events can be captured from childs
            setTimeout(() => {

                console.log('Handle Submit checked');
                console.log('Handle Submit objValidateChildComps ', JSON.stringify(this.objValidateChildComps));

                var allDataFilled = true;
                //check if all data have been filled
                for (const key in this.objValidateChildComps) {

                    console.log('this.objValidateChildComps ' + key + '  ' + this.objValidateChildComps[key]);
                    if (!this.objValidateChildComps[key]) {
                        allDataFilled = false;
                        break;
                    }
                }
                console.log(`allDataFilled ${allDataFilled} and showErrorTab ${this.showErrorTab} `); //Karan Singh : 11-10-2022 : CH added condition

                if (!allDataFilled || this.showErrorTab) { //Karan Singh : 11-10-2022 : CH this.showErrorTab condition

                    console.log('all data not filed ');
                    this.showErrorTab = true;
                    //this is done as as it take some time to render the error tab so immediatly it will not focus on error tabs
                    let thisRef = this;
                    setTimeout(() => {
                        thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                        thisRef.showLoader = false;
                        thisRef.disableSubmit = false;
                        console.log('inside dm setimeout');
                    }, 300);
                } else {

                    console.log('all data filed ');
                    if (this.objApptWrapperData.disbMetaPrefix == 'DISBM_') {
                        //move to disbursal author update the stage of application
                        console.log('all data filed DM');
                        let date = new Date().toISOString();
                        const fields = {};
                        fields[ID_FIELD.fieldApiName] = this.objApptWrapperData.objAppt.Id;
                        let stageValue = 'Disbursal Author';
                        if(this.subStage == 'DOS'){
                            stageValue = 'Awaiting DOS';
                        }
                        fields[STAGE_FIELD.fieldApiName] = stageValue;
                        fields[Disbursal_Maker_CompleteDate_FIELD.fieldApiName] = this.currentDate; //Karan Singh 26-09-2022: CH : Populating DM Completion date
                        fields[Decision_Date_Time__FIELD.fieldApiName] = date; // Ajay Kumar 20-10-2022: CH:  update Decision date time field on decision save 
                        var busDate = new date(BusinessDate);
                        fields[Disbursal_Date.fieldApiName] = busDate; // changes on 04/05/2023
                        const recordInput = { fields };
                        updateRecord(recordInput)
                            .then(() => {
                                this.showNotification('Success', 'Disbursal Maker Stage Submitted Successfully.', 'success');
                                this.changeDisbursalRecTypeId(JSON.stringify({ 'disbId': this.checkExistingDisbursalId(), 'disbRecTypeName': 'Disbursal Author' }));
                                // if(stageValue == 'Disbursal Author'){
                                //     this.trackAllocateUser('Disbursal Author', this.objApptWrapperData.objAppt.Id);
                                //     
                                // }                                                    
                                this.disableSubmit = false;                                
                            })
                            .catch(error => {

                                console.log('error on stage save -> ' + error);
                                this.showNotification('Error', error.body.message, 'error');
                                this.showLoader = false;
                                this.disableSubmit = false;
                            });
                    } else {

                        console.log('inside else of what');

                        if ((this.approvalRemarks && this.slcdApprvalOpt) || (this.checkApprovalStatus == 'Reject' || this.checkApprovalStatus == 'Approve')) {
                            console.log('inside else of what if');
                            if ((this.approvalRemarks && this.slcdApprvalOpt)) {
                                console.log('inside else of what if else');
                                if (this.checkrepayschedule != 'true' || this.checkrepayschedule) {
                                    this.showApprovalmodal = false;
                                    this.handleDASave();
                                }/*else if (this.checkrepayschedule =='true'){
                                        this.checkDisbursalMemoValidation();
                                    }*/
                            } else {
                                console.log('inside else of what  else');
                                console.log('inside schele of what  else', this.checkrepayschedule);
                                console.log('inside approval status of what  else', this.checkApprovalStatus);
                                this.slcdApprvalOpt = this.checkApprovalStatus;
                                if (this.checkrepayschedule != 'true' || this.checkrepayschedule) {
                                    this.showApprovalmodal = false;
                                    this.handleDASave();
                                }/*else if (this.checkrepayschedule =='true'){
                                        console.log('inside memo dev');
                                        this.checkDisbursalMemoValidation();
                                    }*/
                            }


                        } else if ((!this.approvalRemarks || !this.slcdApprvalOpt) || (this.checkApprovalStatus == '')) {
                            console.log('inside else of else');
                            this.showApprovalmodal = true;
                            let thisRef = this;
                            setTimeout(() => {
                                thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Decision';
                                thisRef.showLoader = false;
                                let allValid = this.handleCheckValidity();
                                if (!allValid) {
                                    return;
                                }
                                console.log('inside dm setimeout');
                            }, 300);
                            console.log('insie approval');
                            // this.handleDASave();
                        }
                    }
                }
            }, 3000);
        }, 3000);
    }

    checkDisbursalMemoValidation() {
        console.log('inside mem generate');
        checkDisbursalMemo({ apptId: this.recordId }).then((result) => {
            console.log('memo result is >>>', result);
            // if(result){
            // console.log('memo if is >>>');
            //  this.handleStages();
            /* }else if(!result){
                 console.log('memo else is >>>');
                this.showErrorTab = true;
                this.arrValidateErrorMsgs.push('Disbursal memo not generated yet');
                console.log('arra ys is >>',this.arrValidateErrorMsgs);
                     let thisRef = this;
                     setTimeout(() => {
                     thisRef.template.querySelector('lightning-tabset').activeTabValue = 'Error';
                     thisRef.showLoader = false;
                     //thisRef.disableSubmit = false;
                     console.log('ionside tyhe settimeout');
                 }, 300);

             }*/
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });

    }

    handleCheckValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid3 = [
            ...this.template.querySelectorAll('lightning-dual-listbox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid4 = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return (allValid1 && allValid2 && allValid3 && allValid4);
    }

    handleInputChange(event) {
        this.approvalRemarks = event.detail.value;
    }
    handleComboBoxChange(event) {
        this.slcdApprvalOpt = event.target.value;
        if (this.slcdApprvalOpt == 'Reject') {
            this.showapprovalRemarks = true;
        } else {
            this.showapprovalRemarks = false;
            this.approvalRemarks = '';
        }
    }
    handleApprovalBtnClk() {
        this.handleDASave();
    }
    handleSubmitCancel() {
        this.slcdApprvalOpt = '';
        this.apprvalRemarks = '';
        this.showApprovalmodal = false;
        this.showLoader = false;
        this.disableSubmit = false;

    }
    handleDASave() {
        console.log('all data filed DA');
        console.log('Save slcdApprvalOpt data jkl' + this.slcdApprvalOpt);
        if (!this.slcdApprvalOpt || this.slcdApprvalOpt == '') {
            this.showLoader = false;
            this.showNotification('Error', 'Please select an option.', 'error');
            return;
        } else if (this.slcdApprvalOpt != 'Approve' && !this.approvalRemarks) {
            this.showLoader = false;
            this.showNotification('Error', 'Remarks mandatory for reject decision.', 'error');
            return;
        } else if (this.slcdApprvalOpt != 'Approve') {

            this.handleStages();

        } else if (this.slcdApprvalOpt == 'Approve') {
            console.log('inside else of da');
            this.showLoader = true;
            getPropertyRecords({ applicatoinIds: this.recordId })
                .then(result => {
                    this.propertyarr = result;
                    console.log('this.propertyarr length is >>', this.propertyarr);
                    this.callfun();
                    //this.showLoader=false;
                })
                .catch(error => {
                    console.log(error);
                    this.showLoader = false;
                });
        }
    }

    handleStages() {
        //  this.disableSubmit = false;
        var fields = {};
        fields[ID_FIELD.fieldApiName] = this.objApptWrapperData.objAppt.Id;
        if (this.slcdApprvalOpt != 'Approve' || this.checkApprovalStatus == 'Reject') {
            fields[STAGE_FIELD.fieldApiName] = 'Disbursal Maker';
            var stage = fields[STAGE_FIELD.fieldApiName];
            fields[Disbursal_Author_Decision_FIELD.fieldApiName] = this.slcdApprvalOpt;
            fields[Disbursal_Author_Decision_Remarks_FIELD.fieldApiName] = this.approvalRemarks;
            fields[Disbursal_Maker_CompleteDate_FIELD.fieldApiName] = this.currentDate;
            var recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    //   this.allocateUser(stage, this.objApptWrapperData.objAppt.Id);

                    this.showNotification('Success', 'Disbursal Author completed.', 'success');
                    this.navigateApptList();
                })
                .catch(error => {

                    this.showNotification('Error', error.body.message, 'error');
                    console.log('error on stage save -> ' + JSON.stringify(error.body.message));
                    this.showLoader = false;
                    this.disableSubmit = false;
                });
        }
        //Incase of Approve will check the document defferal conditions
        else if (this.slcdApprvalOpt == 'Approve' || this.checkApprovalStatus == 'Approve') {

            this.showLoader = true;

            updateApptStageFromDA({
                apptId: this.objApptWrapperData.objAppt.Id, ApprovalStatus: this.slcdApprvalOpt, approvalRemarks: this.approvalRemarks
            }).then((result) => {

                console.log('Fiv_Disb_Lwc Saved sfObjJSON = ', JSON.stringify(result));

                if (result !== 'Success') {
                    this.showNotification('ERROR', result, 'error'); //incase if any apex exception happened it will show notification
                } else {

                    this.navigateApptList();
                    this.showNotification('Success', 'Disbursal Author completed.', 'success');
                }
                this.showLoader = false;
                //this.showLoader = false; //this is removed as loader will be  false once data is load
            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in Fiv_Disb_Lwc handleSave = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });
        }




    }

    //this is used till the allocation master is not implemented
    allocateUser(stageName, apptId) {
        allocateUser({
            stageName: stageName,
            apptId: apptId
        }).then((result) => {
            this.showLoader = false;

            console.log('Fiv_Disb_Lwc Saved sfObjJSON = ', JSON.stringify(result));
            //this.showLoader = false; //this is removed as loader will be  false once data is load
        }).catch((err) => {
            this.showLoader = false;
            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc handleSave = ', err);
            //this.showNotification('ERROR', err.message, 'error');
            //this.showLoader = false;
        });
    }
    navigateApptList() {
        window.location.replace('/' + this.recordId);
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',// type: 'standard__recordPage',
            attributes: {
                //recordId: this.objApptWrapperData.objAppt.Id,
                objectApiName: 'Application__c',
                //actionName: 'view'
                actionName: 'list'
            }
        });*/
    }
}