import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//------------------------------------------------------------------------------
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BusinessDate from '@salesforce/label/c.Business_Date';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import { updateRecord } from 'lightning/uiRecordApi';
import DEDUPE_OBJECT from '@salesforce/schema/Dedupe_Detail__c';
import ACTIVESTATUS from '@salesforce/schema/Dedupe_Detail__c.Active__c';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';
import APPT_STAGE_FIELD from '@salesforce/schema/Application__c.Stage__c';
import APPT_NAME_FIELD from '@salesforce/schema/Application__c.Name';
import LightningConfirm from 'lightning/confirm';
//-----------------------------------------------------------------------------
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import callDedupeAPI from '@salesforce/apex/DedupeAPI.callDedupeAPI';
//--------------------------------------------------------------------------------

import getNewLoanWrapperData from '@salesforce/apex/DedupeDetailsController.getNewLoanWrapperData';
import doEmptyLoanApptData from '@salesforce/apex/DedupeDetailsController.doEmptyLoanApptData';
import getLoanDetails from '@salesforce/apex/DedupeDetailsController.getLoanDetails';
import saveCustomer from '@salesforce/apex/DedupeDetailsController.saveCustomer';
import callApiforOverride from '@salesforce/apex/DedupeDetailsController.callApiforOverride';
import getCustomerData from '@salesforce/apex/DedupeDetailsController.getCustomerData';
import saveData from '@salesforce/apex/DedupeDetailsController.saveData';
import checkSubmitDedupeValidation from '@salesforce/apex/DedupeDetailsController.checkDedupeValidation';
import getLoanDedupeData from '@salesforce/apex/DedupeDetailsController.getLoanDedupeData';
import checkDedupeUser from '@salesforce/apex/DedupeDetailsController.checkDedupeUser';
import getExceptionUserDedupe from '@salesforce/apex/DedupeDetailsController.getExceptionUserDedupe';
import getLoanApplicants from '@salesforce/apex/DedupeDetailsController.getLoanApplicants';
import getButtonStatus from '@salesforce/apex/DedupeDetailsController.getButtonStatus';
import getExceptionLoanApplicants from '@salesforce/apex/DedupeDetailsController.getExceptionLoanApplicants';
import getDedupeUserData from '@salesforce/apex/DedupeDetailsController.getDedupeUserData';
import getApplicantsStatus from '@salesforce/apex/DedupeDetailsController.getApplicantsStatus';
import getDoneDedupeData from '@salesforce/apex/DedupeDetailsController.getDoneDedupeData';
import checkLoanAppt from '@salesforce/apex/DedupeDetailsController.checkLoanAppt';
import callCustomerApi from "@salesforce/apexContinuation/DedupeDetailsController.callCustomerApi"


export default class fsdedupeDetailsLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api source;
    @api loadDedupe;
    lastLoginDate;
    todaysDate = BusinessDate;
    @track activeTab = false;
    @track apptStageName = 'Exception Stage';
    @track cifId;
    @track tempvar;
    @track cifDedupeData = [];
    @track dedupePicklistValues = [];
    @track listLoanApptName;
    @track listExceptionUserDedupe = [];
    @track exceptionUserDedupe;
    @track exceptionUserDedupeMap = new Map();
    @track exceptionUserapplicantMap = new Map();
    @track hasLmsNumber = false;
    @track mapLoanApptDedupe = new Map();
    @track disableSubmit = false;
    slcdLoanApptName = '';
    exceptionUserLoanApptName = '';
    isActiveType = '';
    @track arrSlcdLoanApptDedupe;
    @track onchangeExceptionDedupe;
    @track applicantsForApi;
   // @track customerData;
    @track exceptionUserDedupeLoans;
    @track arrSlcdLoanApptDedupeLoans;
    @track arrSlcdLoanApptFieldComparison;
    @track myDedupeRecords = [];
    @track myCustomerRecords = [];
    @track disablededupeButton = false;
    @track showDedupeButton = true;
    @track loanApptName;
    @track hasDedupeRecord = false;
    @track showDedupeResult = true;
    @track disableOverRide;
    @track keepCustId='';
    @track customerData = {
        Id: undefined,
        LMS_Customer_Info_File_Number__c:undefined,
		Customer_Name__c:undefined,
		Override__c:undefined,
		Override_Remarks__c:undefined,
        Old_Customer_Number__c:undefined,
        Old_Override_Remarks__c:undefined,
        Application__c:undefined,
    };

    voterId = '';
    pasport = '';
    driving = '';
    pan = '';
    adhar = '';
    lanId = '';
    showData = false;
    showLoader = false;
    showLoanDetailModal = false;
    showFieldComparisonTable = false;
    @track trackSource='';
    @track btns = [
        {
            name: 'Re-trigger Dedupe',
            label: 'Re-trigger Dedupe',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }];
    @track dedupeDetailList;
    @track showExceptionUser = false;
    @track isApplicantFlag = false;
    @track dedupeCriteriaFlag = false;
    @track showtext = false;
    @track dedupeListSizeFlag = false;
    @track loanApptId2;
    @track saveDedupeDetailList;
    @track isOptionDisable = false;
    @track isYesNoDisable = true;
    @track isdedupeDone = false;
    @track showModal = false;
    @track LoanDedupeWrapper;
    @track getPickVal;
    @track loanappIdExpnUser;
    @track cifIdExpnUser;
    @track dedupeNonExpnApptId;
    @track isOverrideCustId;
    @track isload = false;
    showButtonLabel = '';
    @track isSpinner = false;
    @track showdropdown = false;
    @track showSaveData = false;
    @track loanApptId;
    @track isOverride=false;
    @track custIdNumber='';
    @track custName='';
    @track sourceName='';
    @track custOverride='None';
    @track disableOverride;
    @track custRemarks='';
    branchName = '';
    yesNoVal = '';
    @track allDedupechild=[];
    @track currentCustomer=[];
    @track ExistingCustomer=[];

    loadAll;

    @wire(getObjectInfo, { objectApiName: DEDUPE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ACTIVESTATUS
    })
    wiredACTIVESTATUSPickListValues({ error, data }) {
        if (data) {
            console.log('gender' + JSON.stringify(data));
            this.dedupePicklistValues = [{ label: 'None', value: '' }, ...data.values];
        } else if (error) {
            this.dedupePicklistValues = undefined;
            console.log('Picklist values are ${error}');
        }
    }

    //--------------------------------------------------------------------------
    @wire(getRecord, { recordId: '$recordId', fields: [APPT_STAGE_FIELD, APPT_NAME_FIELD] })
    objAppt;
    get apptName() {
        return getFieldValue(this.objAppt.data, APPT_NAME_FIELD);
    }
    get dedupeAnswerOpts() {
        return [{ label: 'None', value: 'None' },{ label: 'Override', value: 'Override' }];
    }

    get dedupeExceptionAnswerOpts() {
        return [{ label: 'None', value: 'None' },{ label: 'Yes', value: 'Yes' }];
    }

    //--------------------------------------------------------------------------
    connectedCallback() {
        this.disableOverRide=true;
        this.loadDedupe = true;
        console.log('connected id is >>>', this.recordId);
        this.handleGetLastLoginDate();
        this.checkUser();
    }

    @api getCurrentAppsLoanApp() {
        this.loadDedupe = false;
        if (!this.showExceptionUser) {
            try {
                getLoanApplicants({ applicationId: this.recordId }).then((result) => {
                    this.loadDedupe = true;
                    this.applicantsForApi = result;
                    this.listLoanApptName = result;
                    this.exceptionUserLoanApptName = this.listLoanApptName[0].Applicant_Name__c;
                    this.activeTab = true;
                }).catch((err) => {
                    console.log('Error in getExistingRecord= ', err);
                });
            } catch (e) {
                console.log('error is >>', e.message);
            }
        } else if (this.showExceptionUser) {
            try {
                getExceptionLoanApplicants({ applicationId: this.recordId }).then((result) => {
                    this.applicantsForApi = result;
                    this.listLoanApptName = result;
                    this.loadDedupe = true;
                    this.exceptionUserLoanApptName = this.listLoanApptName[0].Applicant_Name__c;
                    this.activeTab = true;
                }).catch((err) => {
                    console.log('Error in getExistingRecord= ', err);
                });
            } catch (e) {
                console.log('error is >>', e.message);
            }
        }
    }

    checkUser() {
        checkDedupeUser({appId : this.recordId}).then((result) => {
            if (result) {
                this.showData = true;
                this.showExceptionUser = true;
                this.getCurrentAppsLoanApp();
            } else {
                this.getCurrentAppsLoanApp();
            }
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });
    }

    checkExceptionUserData() {
        this.onchangeExceptionDedupe=undefined;
        this.exceptionUserDedupeMap.clear();
        if ((!(this.showExceptionUser))) {
            getDoneDedupeData({ applicationId: this.recordId, applicantName: this.exceptionUserLoanApptName, applicantId: this.loanApptId }).then((result) => {
                this.exceptionUserDedupe = result;
                if (this.exceptionUserDedupe.length == 1) {
                    this.hasDedupeRecord = false;
                    console.log('this.hasDedupeRecord 292>>',this.hasDedupeRecord);
                    this.isYesNoDisable = false;
                    this.dedupeListSizeFlag = false;
                    this.showSaveData = true;
                   // this.showtext = true;
                    this.yesNoVal = this.exceptionUserDedupe[0].Active__c;
                    this.showdropdown = false;
                    this.listExceptionUserDedupe = [];
                    var i=0;
                if(this.exceptionUserDedupeMap.size==0){
                    console.log('this.hasDedupeRecord 297>>',i);
                    this.exceptionUserDedupe.forEach(element => {
                       // ++i;
                        if (!this.exceptionUserDedupeMap.has(element.Loan_Applicant__c)) {
                            this.listExceptionUserDedupe.push({ label: element.Loan_Applicant__r.Applicant_Name__c, value: element.Loan_Applicant__r.Applicant_Name__c });
                            this.exceptionUserDedupeMap.set(element.Loan_Applicant__c, []);
                        }
                        this.exceptionUserDedupeMap.get(element.Loan_Applicant__c).push(element);
                        this.isload = true;
                       
                        if (!this.isYesNoDisable) {
                            this.dedupeNonExpnApptId = element.Id;
                            this.loanappIdExpnUser = element.Loan_Applicant__c;
                            this.cifIdExpnUser = element.CIF_Id__c;
                        }

                        if (this.isload && i == this.exceptionUserDedupe.length-1) {
                            console.log('this.hasDedupeRecord 314>>',i);
                            this.getApptDedupeData();
                        }else if(i != this.exceptionUserDedupe.length-1){
                            ++i;
                            console.log('this.hasDedupeRecord 318>>',i);
                        }

                    });
                    this.isSpinner = false;
                }
                    
                } else {
                    this.checkExceptionUserDataLog();
                }


            }).catch((err) => {
                console.log('Error in getExistingRecord= ', err);
            });


        } else {
            this.checkExceptionUserDataLog();
        }
    }

    checkExceptionUserDataLog() {
        if ((!(this.showExceptionUser))) {
            getButtonStatus({ applicationId: this.recordId, applicantName: this.exceptionUserLoanApptName, apptLoanId: this.loanApptId }).then((result) => {
                if (result.length>0) {
                    this.showButtonLabel = result;
                    if (this.showButtonLabel.includes('Dedupe')) {
                        this.hasDedupeRecord = true;
                        console.log('this.hasDedupeRecord 347>>',this.hasDedupeRecord);

                        this.hasLmsNumber = false;
                        console.log('this.hasLmsNumber 353>>',this.hasLmsNumber);
                        this.isSpinner = false;
                    } else {
                         
                        console.log('this.hasDedupeRecord 353>>',this.hasDedupeRecord);
                        
                        console.log('this.hasDedupeRecord 356>>',this.hasLmsNumber);
                        this.getCustomerData();
                        
                    }
                }else if(result.length == 0){
                    this.callDedupeRecords();
                }
            }).catch((err) => {
                console.log('Error in getExistingRecord= ', err);
            });
        }else if(((this.showExceptionUser))){
            this.callDedupeRecords();
        }
    }

    handleActive2(event){
        this.loanApptId2 = event.target.value;
    }

    getCustomerData(){

        getCustomerData({ applicationId: this.recordId, applicantName: this.exceptionUserLoanApptName, apptLoanId: this.loanApptId }).then((result) => {
            console.log('this.result on load  is >>>',result );
            this.customerData = result;
            if (result!=null) {
                this.hasDedupeRecord = false;
                this.hasLmsNumber = true;
                console.log('this.customerData on load  is >>>',this.customerData[0].LMS_Customer_Info_File_Number__c );
                if(typeof this.customerData[0].LMS_Customer_Info_File_Number__c!=undefined && this.customerData[0].LMS_Customer_Info_File_Number__c!='' && this.customerData[0].LMS_Customer_Info_File_Number__c){
                  console.log('inside ander');
                    this.custIdNumber = this.customerData[0].LMS_Customer_Info_File_Number__c;
                    if(this.custIdNumber){
                        if(this.customerData[0].Override__c!='Override' && ((this.customerData[0].Application__r.Pre_Login__r.RecordType.Name=='1. New login') || 
                        (((this.customerData[0].Application__r.Pre_Login__r.RecordType.Name=='3. Top-up loan')||(this.customerData[0].Application__r.Pre_Login__r.RecordType.Name=='4. Tranche loan')) && !this.customerData[0].Old_Applicant_Id__c))){
                            this.sourceName = 'New LMS Customer';
                            this.trackSource='New LMS Customer';
                        }else{
                            this.sourceName = 'LMS';
                            this.trackSource='LMS';
                        }
                        
                        this.isOverrideCustId=false;
                    }else{
                        this.sourceName = '';
                        this.isOverrideCustId=true;
                    }
                    
                }else{
                    this.custIdNumber='';
                    this.sourceName = '';
                    this.isOverrideCustId=true;
                }
                if(typeof this.customerData[0].Customer_Name__c!=undefined){
                    this.custName = this.customerData[0].Customer_Name__c;
                }else{
                    this.custName=''
                }
                if(typeof this.customerData[0].Override__c!=undefined){
                    this.custOverride = this.customerData[0].Override__c;
                    if(this.custOverride =='Override'){
                        this.disableOverride=true;
                        
                    }else{
                        this.disableOverride=false;
                    }
                }else{
                    this.custOverride='';
                }
                if(typeof this.customerData[0].Override_Remarks__c!=undefined){
                    this.custRemarks = this.customerData[0].Override_Remarks__c;
                }else{
                    this.custRemarks='';
                }
            }
            this.isSpinner = false;
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getExistingRecord= ', err);
        });
    }

    handleCustIdPopUp(){
        this.showNotification('WARNING', 'No record found', 'warning');
    }

    handleCustomerChange(event){
         
        if(event.target.name == 'dedupeYesNo'){
            if(event.target.value == 'Override'){
                console.log('this.custIdNumber is if >>',this.custIdNumber);
                if(this.custIdNumber){
                    this.keepCustId = this.custIdNumber;
                    this.trackSource=this.sourceName;
                    console.log('keepCustId is if >>',this.keepCustId );
                }
                this.disableOverRide = false;
                this.dedupeListSizeFlag=true;
                this.isOverrideCustId=true;
                this.customerData[0].Override__c = event.target.value;
                this.customerData[0].Application__c = this.recordId;
                this.custOverride = this.customerData[0].Override__c;
            }else{
                this.disableOverRide = true;
                this.dedupeListSizeFlag=false;
               
                if(this.keepCustId ){
                    this.custIdNumber=this.keepCustId;
                    this.sourceName = this.trackSource;
                }else{
                    console.log('keepCustId is in else >>',this.keepCustId );
                    this.custIdNumber = '';
                    this.sourceName = '';
                }
                
                if(this.custIdNumber){
                    this.sourceName = this.trackSource;
                    this.isOverrideCustId=false;
                }
            }
        }
        if(event.target.name == 'Remarks'){
            this.disableOverRide = true;
            this.dedupeListSizeFlag=true;
            var oldremrks = this.customerData[0].Override_Remarks__c;
            this.customerData[0].Old_Override_Remarks__c = oldremrks;
            this.customerData[0].Override_Remarks__c = event.target.value;
            this.customerData[0].Application__c = this.recordId;
            this.custRemarks = this.customerData[0].Override_Remarks__c;
        }

        if(event.target.name == 'CustomerNumber'){
           // this.disableOverRide = true;
            this.dedupeListSizeFlag=true;
            var oldno = this.customerData[0].Override_Remarks__c;
            this.customerData[0].Old_Customer_Number__c = oldno;
            this.customerData[0].LMS_Customer_Info_File_Number__c = event.target.value;
            this.customerData[0].Application__c = this.recordId;
            this.custIdNumber = this.customerData[0].LMS_Customer_Info_File_Number__c;
        }
    }

   async saveCustomer(){
        this.isSpinner = true;
        var alertOk;
        if(this.customerData[0].Override__c == 'Override' && this.customerData[0].LMS_Customer_Info_File_Number__c){
            await    LightningConfirm.open({
                message: 'Are you sure to override the existing customer number ?',
                theme: 'error', // a red theme intended for error states
                label: 'Alert!', // this is the header text
            }).then((result) => {
                console.log('Result: '+ result);
                alertOk = result;
                if(alertOk){
                    this.callSaveCustomer();
                }else if(!alertOk){
                    this.isSpinner = false;
                }

            });
        }else/* if(this.customerData[0].Override__c == 'Override' && !this.customerData[0].LMS_Customer_Info_File_Number__c)*/{
            this.showNotification('Error', 'Blank customer number is not allowed', 'Error');
            this.isSpinner=false;
        }
    }

    callSaveCustomer(){
        saveCustomer({ applicantList : (JSON.stringify(this.customerData))}).then((result) => {
            if(result.length>0 && result.includes('customer')){
                console.log('inside check');
                this.showNotification('Warning', result, 'Warning');
                //this.showDedupeResult = true;
                this.isSpinner = false;
                
            }else if(result.length>0){
                this.customerData[0].Customer_Name__c=result;
                this.custName = result;
                this.sourceName='LMS';
                this.showNotification('Success', 'Applicant record updated successfully', 'success');
                this.disableOverride=true;
                //this.showDedupeResult = true;
                this.dedupeListSizeFlag = false;
                this.isSpinner = false;
                this.isOverrideCustId=false;
            }else{
                console.log('inside check else');
                this.showNotification('Success', 'Applicant record updated successfully', 'success');
                this.disableOverride=true;
                this.sourceName='LMS';
                //this.showDedupeResult = true;
                this.dedupeListSizeFlag = false;
                this.isSpinner = false;
                this.isOverrideCustId=false;
            }
            
        }).catch((err) => {
            this.isOverrideCustId=false;
            this.isSpinner = false;
            console.log('Error in getExistingRecord= ', err);
        });
        
    }

     
     callDedupeRecords(){
        this.exceptionUserDedupeMap.clear();
        if ((!(this.showExceptionUser))) {
            this.hasLmsNumber = false;
            console.log('this.hasLmsNumber 537>>',this.hasLmsNumber);
            getExceptionUserDedupe({ applicationId: this.recordId, applicantName: this.exceptionUserLoanApptName, apptLoanId: this.loanApptId }).then((result) => {
                if (result) {
                    this.exceptionUserDedupe = result;
                    var i=0;
                    if (this.exceptionUserDedupe.length == 1 && (this.exceptionUserDedupe[0].Active__c === 'Yes' || this.exceptionUserDedupe[0].Active__c === 'No')) {
                        this.isYesNoDisable = false;
                        this.dedupeListSizeFlag = false;
                        this.yesNoVal = this.exceptionUserDedupe[0].Active__c;
                        this.showdropdown = false;
                    } else if (this.exceptionUserDedupe.length == 1 && this.exceptionUserDedupe[0].Active__c != 'Yes' && this.exceptionUserDedupe[0].Active__c != 'No') {
                        this.isYesNoDisable = false;
                        this.showdropdown = true;
                        this.dedupeListSizeFlag = true;

                    } else {
                        this.isYesNoDisable = true;
                        this.dedupeListSizeFlag = false;
                        this.showdropdown = true;
                    }
                    this.listExceptionUserDedupe = [];
                    var i=0;
                if(this.exceptionUserDedupeMap.size==0){
                    this.exceptionUserDedupe.forEach(element => {
                        
                        if (!this.exceptionUserDedupeMap.has(element.Loan_Applicant__c)) {
                            this.listExceptionUserDedupe.push({ label: element.Loan_Applicant__r.Applicant_Name__c, value: element.Loan_Applicant__r.Applicant_Name__c });
                            this.exceptionUserDedupeMap.set(element.Loan_Applicant__c, []);
                        }
                        this.exceptionUserDedupeMap.get(element.Loan_Applicant__c).push(element);
                        this.isload = true;
                        if (!this.isYesNoDisable) {
                            this.dedupeNonExpnApptId = element.Id;
                            this.loanappIdExpnUser = element.Loan_Applicant__c;
                            this.cifIdExpnUser = element.CIF_Id__c;
                        }

                        if (this.isload && i == this.exceptionUserDedupe.length-1) {
                            this.getApptDedupeData();
                        }else if(i != this.exceptionUserDedupe.length-1){
                            ++i;
                        }
                    });
                    
                }
            }
            }).catch((err) => {
                console.log('Error in getExistingRecord= ', err);
            });
        } else if (this.showExceptionUser) {
            getDedupeUserData({ applicationId: this.recordId, applicantName: this.exceptionUserLoanApptName, apptLoanId: this.loanApptId }).then((result) => {
                if (result) {
                    this.exceptionUserDedupe = result;
                    if (this.exceptionUserDedupe.length == 1 /*&& (this.exceptionUserDedupe[0].Active__c === 'Yes')*/) {
                        this.isYesNoDisable = false;
                        this.dedupeListSizeFlag = false;
                        this.yesNoVal = this.exceptionUserDedupe[0].Active__c;
                        this.showdropdown = false;
                    } else {
                        console.log('inside the exception user');
                        this.isYesNoDisable = true;
                        this.dedupeListSizeFlag = false;
                        this.showdropdown = true;
                    }
                    this.listExceptionUserDedupe = [];
                    var i=0;
                if(this.exceptionUserDedupeMap.size==0){
                    this.exceptionUserDedupe.forEach(element => {
                       // ++i;
                        if (!this.exceptionUserDedupeMap.has(element.Loan_Applicant__c)) {
                            this.listExceptionUserDedupe.push({ label: element.Loan_Applicant__r.Applicant_Name__c, value: element.Loan_Applicant__r.Applicant_Name__c });
                            this.exceptionUserDedupeMap.set(element.Loan_Applicant__c, []);
                        }
                        this.exceptionUserDedupeMap.get(element.Loan_Applicant__c).push(element);
                        this.isload = true;
                        if (!this.isYesNoDisable) {
                            this.dedupeNonExpnApptId = element.Id;
                            this.loanappIdExpnUser = element.Loan_Applicant__c;
                            this.cifIdExpnUser = element.CIF_Id__c;
                        }

                        if (this.isload && this.exceptionUserDedupe.length-1 == i) {
                            this.getApptDedupeData();
                        }else if(i != this.exceptionUserDedupe.length-1){
                            ++i;
                        }

                    });
                }
                    
                }
            }).catch((err) => {
                console.log('Error in getExistingRecord= ', err);
            });
        }
    }

    

   async callPopUpModal(){
        var alertOk;
        await    LightningConfirm.open({
            message: 'Are you sure to override the existing screen ?',
            theme: 'error', // a red theme intended for error states
            label: 'Alert!', // this is the header text
        }).then((result) => {
            console.log('Result: '+ result);
            alertOk = result;
            if(alertOk){
                this.callApiforOverride();
            }else if(!alertOk){
                this.isSpinner = false;
            }

        });
    }

   async checkOverride(){

    if(this.customerData){
        var alertOk;
        if(this.customerData[0].Override__c == 'Override'){
            this.callPopUpModal();
        }else{
            this.callApiforOverride();
        }

        console.log('this.customerData[0].Override__c is >>>',this.customerData[0].Override__c);
    }else if(this.onchangeExceptionDedupe){
        if(this.onchangeExceptionDedupe[0].YesNo == 'Override'){
            this.callPopUpModal();
        }else{
            this.callApiforOverride();
        }
    }else{
        this.callApiforOverride();
    }

    }

    callApiforOverride(){

        callApiforOverride({ applicantId: this.loanApptId,appId:this.recordId }).then((result) => {
            
            console.log('result in oberride is >>>',result);
            
            if (result!=null) {
                this.applicantsForApi = result;
                console.log('this.applicantsForApi in oberride is >>>',this.applicantsForApi);
                this.callDedupeApiBtnClick();
            }else{
                this.showNotification('WARNING', 'No record found to execute the API', 'warning');
                this.isSpinner=false;
            }
            
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getExistingRecord= ', err);
        });     


    }

    isDedupeAlreadyDone() {
        
        this.isSpinner = true;
        this.checkOverride();
          
    }

    
    callDedupeApiBtnClick() {
        this.isSpinner = true;
         this.hasDedupeRecord = false;
         console.log('this.hasDedupeRecord 709>>',this.hasDedupeRecord);

         this.hasLmsNumber = false;
         console.log('this.hasLmsNumber 715>>',this.hasLmsNumber);
        this.activeTab=false;
        this.showDedupeResult = false;
        //invoke Dedupe API
        console.log('Application Id   ', this.recordId);
        console.log('Source Invoke  ', this.source);
        try {
            console.log('before calling api checking the applicants>>>',this.applicantsForApi);
            callDedupeAPI({ applicationId: this.recordId, source: this.source, button: 'Check Dedupe', loanApplicantList: this.applicantsForApi })
                .then((result) => {
                    console.log('dedupeDetailList result = ',result)
                    this.dedupeDetailList = JSON.parse(result);
                    console.log('dedupe is >>>' + JSON.stringify(this.dedupeDetailList))
                    console.log('Resulttttt   = ', this.dedupeDetailList);
                    console.log('CRITERIAS   ', this.dedupeDetailList.dedupeCriteria);
                    console.log('MATCHING     ', this.dedupeDetailList.noDedupeMatch);
                    console.log('msg is >>>   = ', this.dedupeDetailList.message);
                    console.log('status code  is >>>   = ', this.dedupeDetailList.statusCode);
                    
                    this.showDedupeResult = true;
                    if (this.dedupeDetailList.noDedupeMatch == true) {
                       // this.hasDedupeRecord = false;
                       this.doEmptyLoanApptData();
                       //this.makeTrueIsDedupe();
                        this.showButtonLabel = '';
                       this.getCurrentAppsLoanApp();
                       
                        const refersherroronpcacEvent = new CustomEvent("refersherroronpcac", { detail: true });
                        this.dispatchEvent(refersherroronpcacEvent);
                        this.showNotification('WARNING', 'No Matching Rule found', 'warning');
                        
                        console.log('this.hasLmsNumber 750>>',this.hasLmsNumber);
                    }
                    else if (this.dedupeDetailList.dedupeCriteria == false) {

                        console.log('inside no match ound');
                        const refersherroronpcacEvent = new CustomEvent("refersherroronpcac", { detail: true });
                        this.dispatchEvent(refersherroronpcacEvent);

                        this.showNotification('ERROR', 'Matching Criteria of Dedupe not found', 'error');
                        this.showLoader = false;

                        this.isSpinner = false;
                    }
                    else if (this.dedupeDetailList.statusCode !== 200) {

                        //window.location.reload();

                        this.showNotification('ERROR', this.dedupeDetailList.message, 'error');
                        this.showLoader = false;

                        this.isSpinner = false;
                    }
                    else if (this.dedupeDetailList.statusCode == 200 && (this.dedupeDetailList.noDedupeMatch == false || this.dedupeDetailList.noDedupeMatch == null)) {
                        console.log('RESULT   ', this.dedupeDetailList);
                        this.makeTrueIsDedupe();
                        this.showData = true;
                        this.isApplicantFlag = true;
                        this.showDedupeResult = true;
                        
                        const refersherroronpcacEvent = new CustomEvent("refersherroronpcac", { detail: true });
                        this.dispatchEvent(refersherroronpcacEvent);
                        this.hasDedupeRecord = false;
                        console.log('this.hasDedupeRecord 783>>',this.hasDedupeRecord);

                        this.hasLmsNumber = false;
                        console.log('this.hasLmsNumber 791>>',this.hasLmsNumber);
                        this.activeTab=true;
                        this.showButtonLabel='';
                        this.getCurrentAppsLoanApp();
                        this.showNotification('SUCCESS', 'Dedupe API Call Successfully.', 'success'); //incase if any apex exception happened it will show notification
                        this.dedupeCriteriaFlag = true;
                       // this.handleActive();

                        this.dedupeDetailList.listSObject.forEach(element => {
                            if (!this.mapLoanApptDedupe.has(element.Loan_Applicant__r.Customer_Information__r.Name)) {
                                //this.listLoanApptName.push({ label: element.Loan_Applicant__r.Customer_Information__r.Name, value: element.Loan_Applicant__r.Customer_Information__r.Name });
                                // this.listLoanApptName.push({Name:element.Loan_Applicant__r.Customer_Information__r.Name});
                                this.mapLoanApptDedupe.set(element.Loan_Applicant__r.Customer_Information__r.Name, []);
                            }
                            this.mapLoanApptDedupe.get(element.Loan_Applicant__r.Customer_Information__r.Name).push(element);
                        });

                        console.log('Applicant  ', JSON.stringify(this.listLoanApptName));
                        console.log('this.mapLoanApptDedupe ', this.mapLoanApptDedupe);
                        if (this.listLoanApptName.length > 0) {
                            this.showData = true;
                        }

                        
                    }
                }).catch((err) => {
                    console.log('Error in callDedupeAPI Calling  = ', err);
                    //window.location.reload();
                    this.showDedupeResult = true;
                    this.showNotification('ERROR', 'Invalid JSON found', 'error');
                    this.showLoader = false;

                    this.isSpinner = false;
                });
        }
        catch (err) {
            this.showDedupeResult = true;
            console.log('ERROOOOOOOO  ', err);
        }
    }

    doEmptyLoanApptData(){

        doEmptyLoanApptData({
            loanApptId: this.loanApptId,applicationId: this.recordId
        }).then((result) => {
            if(result){
                this.custIdNumber='';
                this.custName='';
                this.sourceName='';
                this.custOverride='';
                this.custRemarks='';
                this.hasDedupeRecord = false;
                this.hasLmsNumber = true;
                this.disableOverride=false;
                this.isOverrideCustId=true;
                this.isSpinner=false;
            }else if(!result){
                this.isSpinner=false;
            }
            
           // this.makeTrueIsDedupe();
        }).catch((err) => {
            this.isSpinner=false;
            console.log('Error in createCustomerAPI = ', err);
        });

    }

    makeTrueIsDedupe(){
        checkLoanAppt({
            "loanApplicantList": this.listLoanApptName
        }).then((result) => {
            this.checkExceptionUserDataLog();
            console.log('createCustomerAPI   ', result);
        }).catch((err) => {
            this.isSpinner=false;
            console.log('Error in createCustomerAPI = ', err);
        });

    }

    handleHeaderButton(event) {
        this.showDedupeResult = false;
        this.isSpinner = true;
        //invoke Dedupe API
        console.log('calling dedupe apu on button click ', this.recordId);
        callDedupeAPI({ applicationId: this.recordId, source: this.source, button: 'Re-Trigger Dedupe', loanApplicantList: this.listLoanApptName })
            .then((result) => {
                this.dedupeDetailList = JSON.parse(result);
                console.log('Fs_dedupeDetails_Lwc init result = ', JSON.stringify(result));
                console.log('status code is >>', this.dedupeDetailList.statusCode);
                if (this.dedupeDetailList.statusCode !== 200) {

                    this.showNotification('ERROR', this.dedupeDetailList.message, 'error'); //incase if any apex exception happened it will show notification
                    // window.location.reload();
                    this.showDedupeResult = true;
                    this.showLoader = false;
                    this.isSpinner = false;
                } else if (this.dedupeDetailList.statusCode == 200) {
                    this.showNotification('SUCCESS', 'Dedupe API Call Successfully.', 'success'); //incase if any apex exception happened it will show notification
                    // window.location.reload();
                    this.showDedupeResult = true;
                    this.isSpinner = false;
                }
                this.showLoader = false;
            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in Fiv_Disb_Lwc getParentAndRelatedData = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showDedupeResult = true;
                this.showLoader = false;
                this.isSpinner = false;
            });

    }

    handleExcptionComboBoxChange(event) {
        this.exceptionUserLoanApptName = event.target.value;
        this.getApptDedupeData();
    }

    handleActive(event) {
        this.keepCustId ='';
     //   this.onchangeExceptionDedupe=[];
     this.onchangeExceptionDedupe = undefined;
     this.customerData = undefined;
        this.isOverride = false;
        this.isSpinner = true;
        this.showButtonLabel = '';
        this.cifDedupeData = [];
        this.exceptionUserLoanApptName = event.target.label;
        console.log('this.exceptionUserLoanApptName handle  >>>', this.exceptionUserLoanApptName);
        this.loanApptId = event.target.value;
        console.log('this.loanApptId at handle active is >>>', this.loanApptId );
        this.checkExceptionUserData();
        this.activeTab = true;
    }


    getApptDedupeData() {

        console.log('this.exceptionUserDedupeMap is >>', this.exceptionUserDedupeMap);
        this.showLoader = true;
        if (this.exceptionUserDedupeMap.has(this.loanApptId)) {
            this.onchangeExceptionDedupe = [];
            this.hasDedupeRecord = false;
            console.log('this.hasDedupeRecord 891>>',this.hasDedupeRecord);

            this.hasLmsNumber = false;
            console.log('this.hasLmsNumber 990>>',this.hasLmsNumber);
            this.exceptionUserDedupeMap.get(this.loanApptId).forEach(element => {
                console.log(JSON.stringify(element));
                this.onchangeExceptionDedupe.push({ Id: element.Id, CustomerNumber: element.CIF_Id__c, Source: 'LMS', YesNo:element.Active__c,Remarks :element.Remarks__c,Application:element.Loan_Applicant__r.Application__c,
                CustomerName:element.Customer_Name__c,oldCustomerNo : element.Old_Customer_Number__c,oldRemarks:element.Old_Remarks__c});
            });

            console.log('onchangeExceptionDedupe >>>' + this.onchangeExceptionDedupe);
            console.log('onchangeExceptionDedupe >>>' + JSON.stringify(this.onchangeExceptionDedupe));
            this.isSpinner = false;
        } else {
            this.onchangeExceptionDedupe = undefined;
            if (this.showButtonLabel.includes('Dedupe')) {
                this.hasDedupeRecord = true;
                console.log('this.hasDedupeRecord 907>>',this.hasDedupeRecord);

            } else {
                this.hasLmsNumber = true;
                console.log('this.hasLmsNumber 917>>',this.hasLmsNumber);
            }

            this.isSpinner = false;
            //this.showNotification('', 'No Dedupe record found.', 'warning');
        }
        console.log(this.onchangeExceptionDedupe);
        this.showLoader = false;
    }

    handleCustIdChange(event){

        console.log('event.target.name is >>>',event.target.name);
        console.log('on change event.target.name is >>>',this.onchangeExceptionDedupe);

        if(event.target.name == 'CustomerNumber'){

            var oldCustId = this.onchangeExceptionDedupe[0].CustomerNumber;
            this.onchangeExceptionDedupe[0].oldCustomerNo = oldCustId;
            this.onchangeExceptionDedupe[event.currentTarget.dataset.index].CustomerNumber = event.target.value;
            console.log('customer number is >>>',this.onchangeExceptionDedupe[event.currentTarget.dataset.index].CustomerNumber);
        }else if(event.target.name == 'Remarks'){
            var oldrmrks = this.onchangeExceptionDedupe[0].Remarks;
            this.onchangeExceptionDedupe[0].oldRemarks = oldrmrks;
            this.onchangeExceptionDedupe[event.currentTarget.dataset.index].Remarks = event.target.value;
            console.log('customer number is >>>',this.onchangeExceptionDedupe[event.currentTarget.dataset.index].Remarks);

        }else if(event.target.name == 'dedupeYesNo'){

            this.getPickVal = event.target.value;
            if(this.getPickVal =='Override'){
                if(this.onchangeExceptionDedupe[0].CustomerNumber){
                    this.keepCustId = this.onchangeExceptionDedupe[0].CustomerNumber;
                    console.log('keepCustId is if >>',this.keepCustId );
                }
                this.dedupeListSizeFlag = true;
                this.isOverride = true;
                this.onchangeExceptionDedupe[event.currentTarget.dataset.index].YesNo = event.target.value;
                console.log('customer number is >>>',this.onchangeExceptionDedupe[event.currentTarget.dataset.index].YesNo);

            }else if (this.getPickVal == 'Yes' || this.getPickVal == 'No') {
                if(this.keepCustId){
                    this.onchangeExceptionDedupe[0].CustomerNumber = this.keepCustId;
                    console.log('keepCustId is if >>',this.keepCustId );
                }
                this.dedupeListSizeFlag = true;
                this.isOverride = false;
                this.onchangeExceptionDedupe[event.currentTarget.dataset.index].YesNo = event.target.value;
                console.log('customer number is >>>',this.onchangeExceptionDedupe[event.currentTarget.dataset.index].YesNo);
            } else {
                if(this.keepCustId){
                    this.onchangeExceptionDedupe[0].CustomerNumber = this.keepCustId;
                    console.log('keepCustId is if >>',this.keepCustId );
                }
                this.dedupeListSizeFlag = false;
                this.isOverride = false;
               /* this.isOverride = false;
                if (this.showExceptionUser) {
                    this.dedupeListSizeFlag = false;
                } else {
                    this.dedupeListSizeFlag = true;
                }*/
            }
        }
    }

   async callSave(){
        this.isSpinner = true;
        let listOfDocs = []; 
        let listOfDOcObject = {};
        var alertOk;
        
       var objData = JSON.parse(JSON.stringify(this.onchangeExceptionDedupe));
       console.log('objdata is >>>',objData);
       listOfDOcObject.Id = objData[0].Id;
       listOfDOcObject.CIF_Id__c = objData[0].CustomerNumber;
       listOfDOcObject.Remarks__c = objData[0].Remarks;
       listOfDOcObject.Active__c = objData[0].YesNo;
       listOfDOcObject.Source__c = objData[0].Source;
       listOfDOcObject.Application__c = objData[0].Application;
       listOfDOcObject.Old_Customer_Number__c = objData[0].oldCustomerNo;
       listOfDOcObject.Old_Remarks__c = objData[0].oldRemarks;
       listOfDocs.push(listOfDOcObject);
       if(objData[0].YesNo == 'Override' && objData[0].CustomerNumber){
            await    LightningConfirm.open({
                message: 'Are you sure to override the existing customer number ?',
                theme: 'error', // a red theme intended for error states
                label: 'Alert!', // this is the header text
            }).then((result) => {
                console.log('Result: '+ result);
                alertOk = result;
                if(alertOk){
                    let checksave =  this.handleSave(listOfDocs);
                }else{
                    this.isSpinner=false;
                }

            });
       }else if(objData[0].YesNo == 'Override' && !objData[0].CustomerNumber){
            this.showNotification('Error', 'Blank customer number is not allowed', 'Error');
            this.isSpinner=false;
        }else{
            let checksave = await this.handleSave(listOfDocs);
       }
       
       console.log('listOfDOcObject is >>>',listOfDOcObject);
       console.log('listOfDocs is >>>',listOfDocs); 
    }

    handleSave(listOfDocs){
        if(listOfDocs.length>0){
            saveData({ dedupeList : (JSON.stringify(listOfDocs))}).then((result) => {
                if(result.length>0 && result.includes('customer')){
                    console.log('inside check');
                    this.showNotification('Warning', result, 'Warning');
                    this.showDedupeResult = true;
                    this.isSpinner = false;
                    
                }else if(result.length>0){
                    this.onchangeExceptionDedupe[0].CustomerName=result;
                    this.showNotification('Success', 'Dedupe record updated successfully', 'success');
                    this.showDedupeResult = true;
                    this.dedupeListSizeFlag = false;
                    this.isSpinner = false;
                    this.isOverride = false;
                }else{
                    console.log('inside check else');
                    this.showNotification('Success', 'Dedupe record updated successfully', 'success');
                    this.showDedupeResult = true;
                    this.dedupeListSizeFlag = false;
                    this.isSpinner = false;
                    this.isOverride = false;
                }
                
            }).catch((err) => {
                this.isOverride = false;
                this.isSpinner = false;
                console.log('Error in getExistingRecord= ', err);
            });
        }else{
            this.showNotification('Warning', 'No record found to update', 'Warning');
            this.isSpinner = false;
            this.showDedupeResult = true;
        }

    }


    // this method will check dedupe record validation before proceeding to next stage
    @api submitDedupeData() {
        console.log('submit dedupe id is >>', this.recordId);

        console.log('source after resuly is >>', this.source);

        var checkSource = this.source;

        checkSubmitDedupeValidation({ applicationId: this.recordId, checkDedupeSource: checkSource })
            .then((result) => {
                console.log('Resulttttt  VALIDATION     = ', result);


                if (result) {
                    const dedupeDetailsEvent = new CustomEvent("fetchdedupedetails", { detail: result });
                    this.dispatchEvent(dedupeDetailsEvent);
                }

            }).catch((err) => {
                console.log('ERRROR in checkSubmitDedupeValidation ' + err);
                this.showNotification('Error', 'Error in  Loan Applicant record ', 'error');
            });
    }


    @api executeCustomerApi() {
        console.log('inside cuystomer');
        callCustomerApi({
            applicationId: this.recordId
        }).then((result) => {
                console.log('inside customer event');
                const dedupeDetailsEvent = new CustomEvent("fetchcustomerdetails", { detail: result });
                this.dispatchEvent(dedupeDetailsEvent); 
        }).catch((err) => {
            console.log('Error in createCustomerAPI = ', err);
        });
    }

    filldedupeLoansWrapper(){
        this.allDedupechild = [];
        for(let i=0;i<this.myDedupeRecords.length;i++){
            var dedupeLoanDetailObj = {  "Id": '', 'appNo': '', 'appStatus': '', 'lanStatus': '', 'lan': '','Name':'','BranchName':'','Applicant Type':''};
            dedupeLoanDetailObj.Id = this.myDedupeRecords[i].Id;
            if(this.myDedupeRecords[i].First_Name__c){
                dedupeLoanDetailObj.Name = this.myDedupeRecords[i].First_Name__c;
                if(this.myDedupeRecords[i].Last_Name__c){
                    dedupeLoanDetailObj.Name=dedupeLoanDetailObj.Name+''+this.myDedupeRecords[i].Last_Name__c;
                }
            }
            
            dedupeLoanDetailObj.BranchName = this.myDedupeRecords[i].Branch_Name__c;
            dedupeLoanDetailObj.ApplicantType = this.myDedupeRecords[i].Applicant_Type__c;
            dedupeLoanDetailObj.appNo = this.myDedupeRecords[i].Application_Number__c;
            dedupeLoanDetailObj.appStatus = this.myDedupeRecords[i].Application_Status__c;
            dedupeLoanDetailObj.lanStatus = this.myDedupeRecords[i].Lan_Status__c;
            dedupeLoanDetailObj.lan = this.myDedupeRecords[i].Lan__c;
            this.allDedupechild.push(dedupeLoanDetailObj);

            if(i==this.myDedupeRecords.length-1 && this.allDedupechild.length>0){
                this.isSpinner=false;
                this.showLoanDetailModal = true;

            }
        }
    }

    fillAppsWrapper(){
        this.allDedupechild = [];
        for(let i=0;i<this.myDedupeRecords.length;i++){
            var dedupeLoanDetailObj = {  "Id": '', 'appNo': '', 'appStatus': '', 'lanStatus': '', 'lan': '','Name':'','BranchName':'','ApplicantType':''};
            dedupeLoanDetailObj.Id = this.myDedupeRecords[i].Id;
            dedupeLoanDetailObj.Name = this.myDedupeRecords[i].Applicant_Name__c;
            dedupeLoanDetailObj.BranchName = this.myDedupeRecords[i].Application__r.Sourcing_Branch__r.Name;
            dedupeLoanDetailObj.ApplicantType = this.myDedupeRecords[i].Customer_Type__c;
            dedupeLoanDetailObj.appNo = this.myDedupeRecords[i].Application__r.Name;
            if(this.myDedupeRecords[i].Application__r.Created_From_Batch__c){
                dedupeLoanDetailObj.appStatus = 'Disbursed';
            }else{
                dedupeLoanDetailObj.appStatus = this.myDedupeRecords[i].Application__r.Stage__c;
            }
            
            dedupeLoanDetailObj.lan = this.myDedupeRecords[i].Application__r.LMS_Response_Reference__c;
            this.allDedupechild.push(dedupeLoanDetailObj);

            if(i==this.myDedupeRecords.length-1 && this.allDedupechild.length>0){
                this.isSpinner=false;
                this.showLoanDetailModal = true;
            }
        }
    }

    getBatchAppData(){
        getLoanDetails({applicationId: this.recordId, apptLoanId: this.loanApptId  }).then((result) => {
                if(result!=null){
                    this.myDedupeRecords=result;
                    this.fillAppsWrapper();
                }else{
                    this.isSpinner=false;
                    this.showNotification('WARNING', 'No record found ', 'warning');
                }
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getExistingRecord= ', err);
        });

    }

    handleDedupeChild(event) {
        
        this.isSpinner=true;
        this.myDedupeRecords=undefined;
        if (event.target.name == 'DedupeloanDetails' && this.onchangeExceptionDedupe) {

            if(this.onchangeExceptionDedupe[0].YesNo == 'Override'){
                this.getBatchAppData();
            }else{
                var i=0;
                let index = event.target.dataset.id;
                let custId = event.target.dataset.customerid;
                console.log('custId is >>>',custId);
                let selectedObj = JSON.parse(JSON.stringify(this.onchangeExceptionDedupe[index]));            
                this.exceptionUserDedupe.forEach(currentItem => {
                    
                    if (custId == currentItem.Id) {
                        if (currentItem.Dedupe_Loan_Details__r) {
                            this.myDedupeRecords = JSON.parse(JSON.stringify(currentItem.Dedupe_Loan_Details__r));
                        }
                        else {
                            this.myDedupeRecords = [];
                            this.showNotification('WARNING', 'No record found ', 'warning');
                            this.isSpinner=false;
                        }
                    }

                    if(i == this.exceptionUserDedupe.length-1 && this.myDedupeRecords.length>0){
                        this.filldedupeLoansWrapper();
                    }else if(i == this.exceptionUserDedupe.length-1 && this.myDedupeRecords.length==0){
                        this.myDedupeRecords = undefined;
                        this.showLoanDetailModal = false;
                    }else{
                        ++i;
                    }   

                });
            }
        }else if (event.target.name == 'DedupeloanDetails' && this.customerData) {
            if(this.customerData[0].Override__c == 'Override' || this.customerData[0].Override__c != 'Override'){
                this.getBatchAppData();
            }else{
                this.showNotification('WARNING', 'No record found', 'warning');
                this.isSpinner=false;
            }
        }
    }

    getLoanDedupeData(currentcifId,custId,decision){
        
        console.log('currentcifId is getLoanDedupeData >>',currentcifId);
        console.log('custId is getLoanDedupeData >>',custId);
        console.log('decision is getLoanDedupeData >>',decision);
        getLoanDedupeData({ applicationId: this.recordId, CustomerNumber: currentcifId, apptLoanId: this.loanApptId,DedupeId :custId,isOverride: decision }).then((result) => {    
            if(result!=null){
                this.ExistingCustomer = result;
                this.showModal = true;
                this.isSpinner = false;
            }else{ 
                this.ExistingCustomer = [];
                this.showModal = false;
              //  this.showNotification('WARNING', 'No record found', 'warning');
                this.isSpinner=false;
            }
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getLastLoginDate= ', err);
            console.log('cifDedupeData', this.cifDedupeData);
        });
    }

    
    getDedupeApptData(currentcifId,custId,decision){
        this.currentCustomer = [];
        this.ExistingCustomer=[];
        var existingCif = currentcifId;
        var existingcustId = currentcifId;
        var existingdecision = currentcifId;
        console.log('currentcifId is >>',currentcifId);
        console.log('custId is >>',custId);
        console.log('decision is >>',decision);
        getNewLoanWrapperData({ applicationId: this.recordId, CustomerNumber: currentcifId, apptLoanId: this.loanApptId,DedupeId :custId,isOverride: decision }).then((result) => {    
            if(result!=null){
                this.currentCustomer = result;
                console.log('this.currentCustomer >>>',this.currentCustomer);
                console.log('existingCif >>>',existingCif);
                console.log('existingcustId >>>',existingcustId);
                console.log('existingdecision >>>',existingdecision);
               // this.showModal = true;
                this.getLoanDedupeData(currentcifId,custId,decision);
               // this.isSpinner = false;
            }else{ 
                console.log('else this.currentCustomer >>>',this.currentCustomer);
                this.currentCustomer = [];
                //this.showModal = false;
                this.getLoanDedupeData(currentcifId,custId,decision);
                //this.showNotification('WARNING', 'No record found', 'warning');
                //this.isSpinner=false;
            }
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getLastLoginDate= ', err);
            console.log('cifDedupeData', this.cifDedupeData);
        });
        
    }


    handleLoandDetailBtnClick(event) {

        try{
            this.isSpinner = true;
        if (event.target.name == 'CustomerNumber' && this.onchangeExceptionDedupe) {
            this.cifId = event.target.label;
            let custId = event.target.dataset.customerid;
            
            if(this.onchangeExceptionDedupe[0].YesNo == 'Override'){
                this.myCustomerRecords = undefined;
                this.exceptionUserapplicantMap.clear();
                this.showFieldComparisonTable = true;
                this.arrSlcdLoanApptFieldComparison = [];
                this.cifDedupeData = [];
                var decision = 'Yes';
                this.getDedupeApptData(this.cifId,custId,decision);
            }else{
                var decision = 'No';
                this.getDedupeApptData(this.cifId,custId,decision);
            }
        }else if(event.target.name == 'CustomerNumber' && this.customerData){
            this.isSpinner=true;
           // this.showModal = true;
            if(this.customerData[0].Override__c == 'Override' && this.customerData[0].LMS_Customer_Info_File_Number__c){
                this.cifId = this.customerData[0].LMS_Customer_Info_File_Number__c;
                var decision = 'Yes';
                console.log('inside customer wala');
                this.getDedupeApptData(this.cifId,'',decision);
            }else if(this.customerData[0].Override__c != 'Override' && this.customerData[0].LMS_Customer_Info_File_Number__c){
                this.cifId = this.customerData[0].LMS_Customer_Info_File_Number__c;
                var decision = 'No';
                console.log('inside customer wala');
                this.getDedupeApptData(this.cifId,'',decision);
            }
                else{
                this.showNotification('WARNING', 'No record found', 'warning');
                this.isSpinner=false;
            }
        }
        }catch(e){
            this.isSpinner = false;
            console.log('error us >>>',e.message);
        }
    }

    dedupeUserSubmit(event) {
        this.isSpinner = true;
        console.log('this.listLoanApptName is >>', this.listLoanApptName);
        console.log('appid check is >>',this.recordId);
        getApplicantsStatus({ apptList: this.listLoanApptName,applicationId:this.recordId }).then((result) => {
            if (result.includes('Successfully')) {
                this.navigateToViewLafPage();
                this.showNotification('Success', result, 'success');
                this.disableSubmit = true;
            }else if (result.includes('applicationId')) {
                this.showNotification('ERROR', result, 'error');
                this.disableSubmit = true;
                this.isSpinner = false;
            } else {
                this.showNotification('WARNING', result, 'warning');                
                this.disableSubmit = true;
                this.isSpinner = false;
            }
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
            this.isSpinner = false;
        });


    }

    navigateToViewLafPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Application__c',
                actionName: 'view'
            },
        });
        this.isSpinner = false;
    }

    closeModal(event) {
        this.showLoanDetailModal = false;
        this.showModal = false;
    }
    //--------------------------------------------------------------------------

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result;
            let currentTab = this.exceptionUserLoanApptName;
            console.log('currentTab= ', currentTab);
            let tabs = this.template.querySelectorAll('lightning-tab');
            console.log('tabs = ', tabs)
            tabs.forEach(element => {
                element.loadContent();
            });

            console.log('currentTab= ', currentTab);
            this.exceptionUserLoanApptName = currentTab;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }
    //-------------------------------------------------------------------------
    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
}