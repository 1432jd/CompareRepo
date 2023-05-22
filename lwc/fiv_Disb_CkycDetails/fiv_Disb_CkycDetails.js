import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//------------------------------------------------------------------------------
//import getMetaDataFields from '@salesforce/apex/Fiv_Disb_LwcController.getMetaDataFields';
//import saveDisbursalCompData from '@salesforce/apex/Fiv_Disb_LwcController.saveDisbursalCompData';
import initCKyc from '@salesforce/apex/Fiv_Disb_LwcController.initCKyc';
import saveSobjectLists from '@salesforce/apex/Fiv_Disb_LwcController.saveSobjectLists';
//------------------------------------------------------------------------------
//Karan Singh : 29/09/2022 : CH - Making changes in UI

export default class Fiv_Disb_CkycDetails extends LightningElement {
    @api obj_parent_appt_wrapper_data;
    showLoader = false;
    @track arrLoanAppCkyc = [];
    disableSaveEditBtn = false;
    isEdit=false;
    isFirstTimeLoad = false; 
    //@track objCKYCDetails;
    //@track mapAutoPopulateFieldMapping = new Map();

    //--------------------------------------------------------------------------
    connectedCallback() {
        //this.setFieldNameForAutoPopulate();29/09/2022 CH : commented 
        //this.getCKYCDetails();29/09/2022 CH : commented 
        try {

            this.doInit();
        } catch (error) {

            console.log(` Error Doinit Fiv_Disb_CkycDetails - ${error}`)
        }

    }
    doInit() {

        this.arrLoanAppCkyc = [];
        this.isEdit=false;
        var jsonParam = { apptId: this.obj_parent_appt_wrapper_data.objAppt.Id };
        this.disableSaveEditBtn = false;
        initCKyc({
            jsonParamData: JSON.stringify(jsonParam)
        }).then((result) => {

            console.log('Fiv_Disb_CkycDetails Init Data = ', JSON.stringify(result));

            if (result.hasOwnProperty('listSObject') && result.listSObject.length > 0) {
                this.populateCkycData(result);
                this.showLoader = false;
            } else {
                this.arrLoanAppCkyc = undefined;
            }
        }).catch((err) => {

            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_CkycDetails Init Data = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.arrLoanAppCkyc = undefined;
            this.showLoader = false;
        });
    }

    populateCkycData(apexResp) {

        apexResp.listSObject.forEach(element => {

            console.log(element);
            var ckycObj = { Id: element.Id, ckyc: '', existCkyc: '', disbCkyc: '', label: element['Customer_Information__r'].Name + '( ' + element.Customer_Type__c + ' )' };

            if (element.hasOwnProperty('CKYC_ID_Number__c')) {

                ckycObj.ckyc = element.CKYC_ID_Number__c;

                if (element.hasOwnProperty('Disbursal_CKYC_ID_Number_History__c')) {

                    this.isFirstTimeLoad = false;
                    //means if ckyc id was not update by user in loan applicant
                    if (element.CKYC_ID_Number__c == element.Disbursal_CKYC_ID_Number_History__c) {

                        ckycObj.disbCkyc = element.hasOwnProperty('Disbursal_CKYC_ID__c') ? element.Disbursal_CKYC_ID__c : element.CKYC_ID_Number__c;

                    } else {
                        //means there is an update so update to latest ckyc id from loan applicant
                        ckycObj.disbCkyc = element.CKYC_ID_Number__c;
                        ckycObj.existCkyc = element.CKYC_ID_Number__c;
                    }

                } else {
                    ckycObj.disbCkyc = element.CKYC_ID_Number__c;
                    ckycObj.existCkyc = element.CKYC_ID_Number__c;
                    this.isFirstTimeLoad = true;
                }

            } else if (element.hasOwnProperty('Disbursal_CKYC_ID__c')) {

                ckycObj.ckyc = element.Disbursal_CKYC_ID__c;
                ckycObj.existCkyc = element.Disbursal_CKYC_ID__c;
                ckycObj.disbCkyc = element.Disbursal_CKYC_ID__c;
            }
            this.arrLoanAppCkyc.push(ckycObj);
        });

        console.log('this.arrLoanAppCkyc - ' + JSON.stringify(this.arrLoanAppCkyc));
    }


    handleInputChanges(event) {

        console.log(`index - ${event.target.dataset.index} field - ${event.target.dataset.field} - value ${event.detail.value}`);
        this.arrLoanAppCkyc[event.target.dataset.index][event.target.dataset.field] = event.detail.value;
        this.isEdit=true;
    }
    handleSave(event) {

        this.showLoader = true;
        this.disableSaveEditBtn = true;
        var allDataValid = true;
        var arrLoanApp = [];
        this.template.querySelectorAll("lightning-input").forEach(element => {

            console.log('element Input Name ' + element.label + ' Value : ' + element.value + ' index ' + element.dataset.index);
            if (!element.value) {

                element.setCustomValidity('Complete this field.');
                element.reportValidity();
                allDataValid = false;
            } else {

                element.setCustomValidity('');
                element.reportValidity();
                arrLoanApp.push({
                    'sobjectType': 'Loan_Applicant__c', 'Id': this.arrLoanAppCkyc[element.dataset.index].Id,
                    'Disbursal_CKYC_ID_Number_History__c': this.arrLoanAppCkyc[element.dataset.index].existCkyc,
                    'Disbursal_CKYC_ID__c': this.arrLoanAppCkyc[element.dataset.index].disbCkyc
                });
            }
        });

        if (allDataValid) {

            saveSobjectLists({
                listSobjects: arrLoanApp
            }).then((result) => {


                console.log('Fiv_Disb_CkycDetails Saved listSobjects = ', JSON.stringify(result));

                if (result.statusCode !== 200) {

                    this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                    this.delaySaveAndSaveReset(false, false);

                } else {

                    this.showNotification('SUCCESS', result.message, 'success');


                    var custEvt = new CustomEvent("reloadapplicationdata", {
                        detail: {}
                    });
                    this.dispatchEvent(custEvt);
                    this.doInit();//this will show the data table;

                }

            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in Fiv_Disb_CkycDetails Save Data = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.delaySaveAndSaveReset(false, false);
            });

        } else {
            this.delaySaveAndSaveReset(false, false);
        }

    }

    //this is done so that user cannot hit multiple save button 
    delaySaveAndSaveReset(showLoader, disableSaveEditBtn) {
        setTimeout(() => {
            //this is done so that user cannot hit multiple save button 
            this.showLoader = showLoader;
            this.disableSaveEditBtn = disableSaveEditBtn;
        }, 500);
    }

    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
    @api
    checkBeforeSubmit() {

        console.log('checkBeforeSubmit ckycDetails');
        var custEvt;

        console.log('checkBeforeSubmit arrLoanAppCkyc ', JSON.stringify(this.arrLoanAppCkyc));
        //as it might come object as  [] or  object  which is not like this { 0 : {sobjectType: 'Disbursal__c','Field Name' : value}}
        if ( this.isEdit || this.isFirstTimeLoad ) {

            console.log('checkBeforeSubmit 2 called');
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: false, msg: 'Please fill and save the required fields in ckyc details', fieldName: 'ckycDetails' }
            });

        } else {
            console.log('checkBeforeSubmit 21 called');
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: true, msg: '', fieldName: 'ckycDetails' }
            });
        }
        this.dispatchEvent(custEvt);
    }
    /* 29/09/2022 CH : commented 
    setFieldNameForAutoPopulate() {

        //For autopopulate other then application record : checking if incase map is not coming empty 
        if (Object.keys(this.obj_parent_appt_wrapper_data.mapExtraParams).length) {

            //converting object to map for setting auto populate
            this.mapAutoPopulateFieldMapping = new Map(Object.entries(this.obj_parent_appt_wrapper_data.mapExtraParams));
        }

        console.log('CKYC this.mapAutoPopulateFieldMapping ', this.mapAutoPopulateFieldMapping);
    }*/
    //--------------------------------------------------------------------------
    //First initial Auto-Populated fields

    /*29/09/2022 CH : commented 
    autoPopulateDisbParameters() {

        var _tempVar = JSON.parse(this.objCKYCDetails);
        console.log(this.mapAutoPopulateFieldMapping)

        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {

            console.log('CKYC - ' + _tempVar[0].fieldsContent[i].fieldAPIName);
            if (!_tempVar[0].fieldsContent[i].value
                && this.mapAutoPopulateFieldMapping.has(_tempVar[0].fieldsContent[i].fieldAPIName)) {

                console.log(this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName))
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);

            }

            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'CKYC_ID_Number__c'
                && !_tempVar[0].fieldsContent[i].value
                && this.mapAutoPopulateFieldMapping.has('apptPrimaryApplicantCkyc')) {

                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get('apptPrimaryApplicantCkyc');
            }

            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'CKYC_ID_Number__c') {

                console.log('CKYC - 1');
                console.log(this.mapAutoPopulateFieldMapping.has('apptPrimaryApplicantCkyc'));
                console.log(this.mapAutoPopulateFieldMapping.has('ckycOriginal'));

                if (this.mapAutoPopulateFieldMapping.has('apptPrimaryApplicantCkyc')
                    && this.mapAutoPopulateFieldMapping.has('ckycOriginal')) {

                    console.log('ckyc main', this.mapAutoPopulateFieldMapping.get('apptPrimaryApplicantCkyc'));
                    console.log('ckyc main prev', this.mapAutoPopulateFieldMapping.get('ckycOriginal'));
                    if (this.mapAutoPopulateFieldMapping.get('apptPrimaryApplicantCkyc') != this.mapAutoPopulateFieldMapping.get('ckycOriginal')) {

                        _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get('apptPrimaryApplicantCkyc');

                    }
                }
            }
        }
        this.objCKYCDetails = JSON.stringify(_tempVar);
    }*/
    //--------------------------------------------------------------------------
    /*29/09/2022 CH : commented
    getCKYCDetails() {
        this.objCKYCDetails = undefined;
        this.showLoader = true;
        //this.obj_parent_appt_wrapper_data.disbMetaPrefix will define the component will open for disbursal author or maker ex DISBM_Loan_Parameters

        getMetaDataFields({ recordIds: this.checkExistingDisbursalId(), metaDetaName: this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'CKYC_Details' }).then((result) => {
            console.log('Fiv_Disb_Lwc objCKYCDetails = ', result);
            this.objCKYCDetails = result.data;
            this.autoPopulateDisbParameters();
            this.showLoader = false;
        }).catch((err) => {
            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc getCKYCDetails = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }*/

    /*29/09/2022 CH : commented
    checkExistingDisbursalId() {

        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Disbursals__r')) {
            console.log('this.obj_parent_appt_wrapper_data.Disbursals__r[0].Id ' + this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id);
            return this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id;
        }
        return null;
    }*/


    /*29/09/2022 CH : commented
    handleSave() {
        this.showLoader = true;
        //var sfObjJSON = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        var sfObjJSON = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSaveWithoutOnChange();
        console.log('111 ' + JSON.stringify(sfObjJSON));
        if (sfObjJSON.length > 0
            && sfObjJSON[0].hasOwnProperty('sobjectType')
            && sfObjJSON[0].sobjectType == 'Disbursal__c') {

            //since it is coming in array. SO we need only first iteration
            sfObjJSON[0].Application__c = this.obj_parent_appt_wrapper_data.objAppt.Id;
            sfObjJSON[0].Id = this.checkExistingDisbursalId(); //this is done to upsert existing disbursal record

            if (this.mapAutoPopulateFieldMapping.has('apptPrimaryApplicantCkyc')) {

                sfObjJSON[0].CKYC_Original__c = this.mapAutoPopulateFieldMapping.get('apptPrimaryApplicantCkyc');
            }

            console.log(JSON.stringify(sfObjJSON));
            saveDisbursalCompData({
                objDisbursal: sfObjJSON[0]
            }).then((result) => {

                console.log('Fiv_Disb_Lwc Saved sfObjJSON = ', JSON.stringify(result));

                if (result.statusCode !== 200
                    && result.statusCode !== 201) {

                    this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                } else {
                    this.showNotification('SUCCESS', result.message, 'success');
                    var custEvt = new CustomEvent("reloadapplicationdata", {
                        detail: {}
                    });
                    this.dispatchEvent(custEvt);
                }
                this.showLoader = false;
                //this.showLoader = false; //this is removed as loader will be  false once data is load
            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in Fiv_Disb_Lwc handleSave = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });
        } else if (sfObjJSON.length == 0) { //incase no object is return due to validation check
            this.showLoader = false;
        }
        else {
            this.showNotification('ERROR', 'Something wrong might happened.', 'error');
            this.showLoader = false;
        }
    }*/
}