import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//------------------------------------------------------------------------------
import BusinessDate from '@salesforce/label/c.Business_Date';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import { updateRecord } from 'lightning/uiRecordApi';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';
import APPT_STAGE_FIELD from '@salesforce/schema/Application__c.Stage__c';
import APPT_NAME_FIELD from '@salesforce/schema/Application__c.Name';
//-----------------------------------------------------------------------------
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import callDedupeAPI from '@salesforce/apex/DedupeAPI.callDedupeAPI';
import checkDedupeCriteria from '@salesforce/apex/DedupeAPI.checkDedupeCriteria';
//--------------------------------------------------------------------------------
import cifId from '@salesforce/schema/Loan_Applicant__c.cifId__c';
import ID_FIELD from '@salesforce/schema/Loan_Applicant__c.Id';
import DedupeExceptionUser from '@salesforce/apex/DedupeDetailsController.assignDedupeExceptionUser';
//import createCustomerAPI from '@salesforce/apex/FS_LMS_CreateCustomerAPI.createCustomer';
import activeDedupeData from '@salesforce/apex/DedupeDetailsController.saveDedupeData';
import checkSubmitDedupeValidation from '@salesforce/apex/DedupeDetailsController.checkDedupeValidation';


export default class Fs_dedupeDetails_Lwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api source ;
    lastLoginDate;
    todaysDate = BusinessDate;
    @track listLoanApptName = [];
    @track mapLoanApptDedupe = new Map();
    slcdLoanApptName = '';
    @track arrSlcdLoanApptDedupe;
    @track arrSlcdLoanApptDedupeLoans;
    @track arrSlcdLoanApptFieldComparison;
    showData = false;
    showLoader = false;
    showLoanDetailModal = false;
    showFieldComparisonTable = false;
    @track btns = [
        {
            name: 'Re-trigger Dedupe',
            label: 'Re-trigger Dedupe',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }];
    @track dedupeDetailList ;
    @track isApplicantFlag = false;
    @track nonDedupeExecutionUserFlag = false;
    @track dedupeCriteriaFlag = true;
    @track dedupeListSizeFlag = false;
    @track saveDedupeDetailList ;
    @track isOptionDisable = false;
    @track isdedupeDone = false;


    // metgid to getlogin username
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USER_NAME_FIELD]
    }) wireuser({
        error, data
    }) {
        if (error) {
           dis.error = error ; 
        } else if (data) {
            console.log(' LOGIN   USER NAMEEE   ',data.fields.Name.value);
            if(data.fields.Name.value != 'Dedupe Exception User')
                this.nonDedupeExecutionUserFlag = true;
        }
    }

    //--------------------------------------------------------------------------
    @wire(getRecord, { recordId: '$recordId', fields: [APPT_STAGE_FIELD, APPT_NAME_FIELD] })
    objAppt;
    get apptStageName() {
        return getFieldValue(this.objAppt.data, APPT_STAGE_FIELD);
    }
    get apptName() {
        return getFieldValue(this.objAppt.data, APPT_NAME_FIELD);
    }
    get dedupeAnswerOpts() {
        return [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }];
    }

    //--------------------------------------------------------------------------
    connectedCallback() {
        console.log(this.recordId);
        this.handleGetLastLoginDate();
        this.initData();
    }
    
    initData() {
        checkDedupeCriteria({
            "applicationId" : this.recordId
        }).then((result) => {
            console.log('CRITERIA FOR DEDUPE CHECK Button',result);
            if(result === true) {
                this.dedupeCriteriaFlag =  false;
            }
            else {
                activeDedupeData({
                    "applicationId" : this.recordId
                }).then((result) => {
                    this.saveDedupeDetailList =  JSON.parse(result).listSObject ;
                    if(this.saveDedupeDetailList.length != 0)  {
                        this.isdedupeDone = true;
                    }
                    console.log('XXXXXXXXXXxx   ',this.saveDedupeDetailList.listSObject);
                    // when dedupe criteria not found.
                    if(this.isdedupeDone) {
                        this.showNotification('INFO', 'Dedupe already done. ', 'info'); 
                    }
                    else {
                        this.showNotification('INFO', 'Dedupe already done and assigned to  Dedupe Exception User .', 'info'); 
                    }
                    this.lastLoginDate = result;
                }).catch((err) => {
                    console.log('Error in get SAVE DEDUPE DETAILS= ', err);
                });
            }
        }).catch((err) => {
            console.log('Error in Criteriaaa = ', err);
            
        });
    }
    
    callDedupeApiBtnClick() {
        //invoke Dedupe API
        console.log('Application Id   ', this.recordId);
        console.log('Source Invoke  ', this.source);
        try {
            callDedupeAPI({ applicationId: this.recordId,  source : this.source, button : 'Check Dedupe' })
                .then((result) => {
                    this.dedupeDetailList = JSON.parse(result);
                    console.log('Resulttttt   = ', this.dedupeDetailList );
                    console.log('CRITERIAS   ',this.dedupeDetailList.dedupeCriteria);
                    console.log('MATCHING     ',this.dedupeDetailList.noDedupeMatch);
                    if(this.dedupeDetailList.noDedupeMatch ==  true){
                        // code to call Customer Create API
                        /*
                        createCustomerAPI({
                            "loanApptId" : this.recordId
                        }).then((result) => {
                            this.showNotification('Success', 'Create Customer Api call successfully.', 'success'); 
                            console.log('createCustomerAPI   ',result);
                        }).catch((err) => {
                            console.log('Error in createCustomerAPI = ', err);     
                        });
                        */
                        this.showNotification('WARNING', 'No Matching Rule found', 'warning'); 
                        this.showLoader = false;
                    }
                    else if (this.dedupeDetailList.dedupeCriteria ==  false){
                        this.showNotification('ERROR', 'Matching Criteria of Dedupe not found', 'error'); 
                        this.showLoader = false;
                    }
                    else if (this.dedupeDetailList.statusCode !== 200) {
                        this.showNotification('ERROR', this.dedupeDetailList.message, 'error'); 
                        this.showLoader = false;
                    } 
                    else if( this.dedupeDetailList.statusCode == 200 && ( this.dedupeDetailList.noDedupeMatch ==  false || this.dedupeDetailList.noDedupeMatch == null) ) {
                        console.log('RESULT   ',this.dedupeDetailList);
                        this.showData = true;
                        this.listLoanApptName = [];
                        this.isApplicantFlag = true;
                        this.showNotification('SUCCESS', 'Dedupe API Call Successfully.', 'success'); //incase if any apex exception happened it will show notification
                        this.dedupeDetailList.listSObject.forEach(element => {
                            if (!this.mapLoanApptDedupe.has(element.Loan_Applicant__r.Customer_Information__r.Name)) {
                                this.listLoanApptName.push({ label: element.Loan_Applicant__r.Customer_Information__r.Name, value: element.Loan_Applicant__r.Customer_Information__r.Name });
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
                    this.showNotification('ERROR', err.message, 'error');
                    this.showLoader = false;
                }); 
            }
            catch(err) {
                console.log('ERROOOOOOOO  ',err);
            }      
    }

    handleHeaderButton(event) {
        /*
        //invoke Dedupe API
        console.log('calling dedupe apu on button click ', this.recordId);
        callDedupeAPI({ applicationId: this.recordId })
            .then((result) => {

                console.log('Fs_dedupeDetails_Lwc init result = ', JSON.stringify(result));

                if (result.statusCode !== 200) {

                    this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                    this.showLoader = false;
                } else {
                    // handle here
                }
                this.showLoader = false;
            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in Fiv_Disb_Lwc getParentAndRelatedData = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });
        */
    }

    handleComboBoxChange(event) {
        if(this.dedupeDetailList.listSObject.length == 1){
            this.dedupeListSizeFlag = true
        }
        else { 
            this.isOptionDisable = true
        }
        this.slcdLoanApptName = event.target.value;
        this.showLoader = true;
        if (this.mapLoanApptDedupe.has(this.slcdLoanApptName)) {
            this.arrSlcdLoanApptDedupe = [];
            this.mapLoanApptDedupe.get(this.slcdLoanApptName).forEach(element => {
                console.log(JSON.stringify(element));
                this.arrSlcdLoanApptDedupe.push({ Id: element.Id, CustomerNumber: element.CIF_Id__c, Source: 'LMS', YesNo: '' });
            });
        } else {
            this.arrSlcdLoanApptDedupe = undefined;
            this.arrSlcdLoanApptDedupeLoans = undefined;
            this.showNotification('', 'No Dedupe record found.', 'warning');
        }
        console.log(this.arrSlcdLoanApptDedupe);
        this.showLoader = false;
    }


    handleDedupeComboBoxChange(event) {
        // Update select option value in JSon Array.
        if(this.dedupeListSizeFlag) {
            this.dedupeDetailList.listSObject[0]['option'] = event.target.value;
        }
        console.log('UPDATE RESULT   ', this.dedupeDetailList);
    }

    saveDedupeData(){
        if(this.dedupeDetailList.listSObject[0].option == undefined) {
            this.showNotification('WARNING', 'Select Yes/No value from Table ', 'warning');
        }
        else if(this.dedupeDetailList.listSObject[0].option == 'Yes') {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.dedupeDetailList.listSObject[0].Loan_Applicant__c;
            fields[cifId.fieldApiName] = this.dedupeDetailList.listSObject[0].CIF_Id__c;
            const recordInput = { fields };
            
            // code to update Loan Applicant record
            updateRecord(recordInput)
            .then(() => {
            })
            .catch(error => {
                console.log('YESSSSSSSSS   ',error);
            });

            DedupeExceptionUser({ dedupeId: this.dedupeDetailList.listSObject[0].Id , loanApplicantId : this.dedupeDetailList.listSObject[0].Loan_Applicant__c, activeType : this.dedupeDetailList.listSObject[0].option })
            .then((result) => {
                console.log('Resulttttt   = ', result);
                this.showNotification('Success', ' Loan Applicant/ Dedupe  record updated ', 'success');

            }).catch((err) => {
               console.log('ERRROR in DedupeExceptionUser ' + err);
                this.showNotification('Error', 'Error in  Loan Applicant/ Dedupe record ', 'error');
            });
            // component will refresh after 7 second
            this.updateRecordView();
        }
        else if(this.dedupeDetailList.listSObject[0].option == 'No') {
            console.log('DEDUPE ID   ',this.dedupeDetailList.listSObject[0].Id);
            DedupeExceptionUser({ dedupeId: this.dedupeDetailList.listSObject[0].Id , loanApplicantId : this.dedupeDetailList.listSObject[0].Loan_Applicant__c , activeType : this.dedupeDetailList.listSObject[0].option})
            .then((result) => {
                console.log('Resulttttt   = ', result);
                this.showNotification('Success', ' Loan Applicant/ Dedupe record updated ', 'success');

            }).catch((err) => {
               console.log('ERRROR in DedupeExceptionUser ' + err);
                this.showNotification('Error', 'Error in  Loan Applicant/ Dedupe record ', 'error');
            });
            // component will refresh after 7 second
            this.updateRecordView();     
        }
    }

    // code to reload component when save button functionality is done.
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 7000); 
     }

    // this method will check dedupe record validation before proceeding to next stage
    submitDedupeData() {
        checkSubmitDedupeValidation({ applicationId : this.recordId})
        .then((result) => {
            console.log('Resulttttt  VALIDATION     = ', result);

        }).catch((err) => {
           console.log('ERRROR in checkSubmitDedupeValidation ' + err);
            this.showNotification('Error', 'Error in  Loan Applicant record ', 'error');
        });

        
    }

    handleLoandDetailBtnClick(event) {
        this.arrSlcdLoanApptFieldComparison = undefined;
        if (event.target.name == 'loanDetails') {
            if (this.mapLoanApptDedupe.get(this.slcdLoanApptName)[event.target.dataset.targetId].hasOwnProperty('Dedupe_Loan_Details__r')) {
                this.arrSlcdLoanApptDedupeLoans = [];
                this.mapLoanApptDedupe.get(this.slcdLoanApptName)[event.target.dataset.targetId].Dedupe_Loan_Details__r.records.forEach(element => {
                    try {
                        this.arrSlcdLoanApptDedupeLoans.push({
                            Id: element.Id, ApplicationNumber: element.Application_Number__c,
                            ApplicationStatus: element.Application_Status__c, LanStatus: element.Lan_Status__c, Lan: element.Lan__c
                        }); 
                    }
                    catch(err) {
                        console.log('ERROOOOOOOO  ',err);
                    } 
                });
                if (this.arrSlcdLoanApptDedupeLoans.length > 0) {
                    this.showLoanDetailModal = true;
                }
            } else {
                this.arrSlcdLoanApptDedupeLoans = undefined;
                this.showLoanDetailModal = false;
            }
            //now we will get loan details of dedupe
        }
        else if (event.target.name == 'CustomerNumber') {
            this.showFieldComparisonTable = true;
            this.this.arrSlcdLoanApptFieldComparison = [];
        }
    }

    closeModal(event) {
        this.showLoanDetailModal = false;
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
    //-------------------------------------------------------------------------
    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
}