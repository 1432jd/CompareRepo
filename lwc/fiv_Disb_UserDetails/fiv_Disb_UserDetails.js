import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//------------------------------------------------------------------------------
import getAppStage from '@salesforce/apex/Fiv_Disb_LwcController.getAppStage';

import getMetaDataFields from '@salesforce/apex/Fiv_Disb_LwcController.getMetaDataFields';
import saveDisbursalCompData from '@salesforce/apex/Fiv_Disb_LwcController.saveDisbursalCompData';
//------------------------------------------------------------------------------

export default class Fiv_Disb_UserDetails extends LightningElement {

    @api obj_parent_appt_wrapper_data;
    @api applicationBranch='';
    @track objUserDetails;
    @track isReadOnly=false;
    @track fieldOfficerEMPId;
    @track criteria;
    @track appStage='';
    showLoader = false;
    @track mapAutoPopulateFieldMapping = new Map();
    //--------------------------------------------------------------------------
    connectedCallback() {

        this.setFieldNameForAutoPopulate();
        this.getUserDetails();
        console.log('applicationBranch is in user >>>>',this.applicationBranch);
        this.getAppStageName();
    }
    //--------------------------------------------------------------------------

    getAppStageName(){

        getAppStage({
            apptId: this.obj_parent_appt_wrapper_data.objAppt.Id
        }).then((result) => {
            var appValues=JSON.parse(JSON.stringify((result)));
            console.log('appValues >>>',appValues);
            this.appStage=appValues[0].Stage__c;
            this.applicationBranch=appValues[0].Sourcing_Branch__c;
            this.criteria = 'NAME_DM'+'/'+this.applicationBranch;
            if(this.appStage =='Disbursal Author'){
                this.isReadOnly = true;
            }
        }).catch((err) => {
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }



    getUserDetails() {
        this.objUserDetails = undefined;
        this.showLoader = true;
        //this.obj_parent_appt_wrapper_data.disbMetaPrefix will define the component will open for disbursal author or maker ex DISBM_Loan_Parameters
        getMetaDataFields({ recordIds: this.checkExistingDisbursalId(), metaDetaName: this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'User_Details' }).then((result) => {
            console.log('Fiv_Disb_Lwc objUserDetails = ', result);
            this.objUserDetails = result.data;
            console.log('this.objUserDetails in user is >>>',this.objUserDetails);
            this.autoPopulateParameters();
            this.showLoader = false;
        }).catch((err) => {
            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc getUserDetails = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }

    handleSelectedEMPId(event){
       // console.log('fieldOfficerEMPId ',event.detail[0].id);
         if (event.detail.length > 0) {
            this.fieldOfficerEMPId = event.detail[0].id;
        } else {
            this.fieldOfficerEMPId = undefined;
        }
    }

    setFieldNameForAutoPopulate() {

        //For autopopulate other then application record : checking if incase map is not coming empty 
        if (Object.keys(this.obj_parent_appt_wrapper_data.mapExtraParams).length) {

            //converting object to map for setting auto populate
            this.mapAutoPopulateFieldMapping = new Map(Object.entries(this.obj_parent_appt_wrapper_data.mapExtraParams));
        }

        console.log('inside yserdetail >>>',this.mapAutoPopulateFieldMapping);

    }
    //--------------------------------------------------------------------------
    //First initial Auto-Populated fields
    autoPopulateParameters() {

        var _tempVar = JSON.parse(this.objUserDetails);
        console.log('_tempVar in user detail is >>>>',_tempVar);
        console.log('autopopulate map in usrt >>>',this.mapAutoPopulateFieldMapping)

        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            console.log('_tempVar api is >>>>',_tempVar[0].fieldsContent[i].fieldAPIName);
            console.log('_tempVar api is >>>>',_tempVar[0].fieldsContent[i].fieldAPIName);
            if (!_tempVar[0].fieldsContent[i].value
                && this.mapAutoPopulateFieldMapping.has(_tempVar[0].fieldsContent[i].fieldAPIName)) {

                console.log(this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName))
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);
                console.log('_tempVar val in user is two >>>>',_tempVar[0].fieldsContent[i].value);

            }

            if(_tempVar[0].fieldsContent[i].fieldAPIName =='Disbursal_Author_ID__c'){
                console.log('inside officer Id');
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);
                console.log('inside officer Id value one>>>',_tempVar[0].fieldsContent[i].value );
                this.fieldOfficerEMPId = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);
                console.log('inside officer Id value two>>>',this.fieldOfficerEMPId );
            }

            




            console.log('_tempVar val in user is one >>>>',_tempVar[0].fieldsContent[i].value);
        }
        this.objUserDetails = JSON.stringify(_tempVar);
    }
    //-------------------------------------------------------------------------
    handleFieldChanges(event) {
        console.log('handleFieldChanges= ', event.detail.CurrentFieldAPIName);
        //this.handleFormValueChange(event);
    }
    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
    checkExistingDisbursalId() {

        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Disbursals__r')) {
            console.log('this.obj_parent_appt_wrapper_data.Disbursals__r[0].Id ' + this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id);
            return this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id;
        }
        return null;
    }

    @api
    checkBeforeSubmit() {
        console.log('checkBeforeSubmit userDetails');
        var sfObjJSON = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        var custEvt;

        console.log('checkBeforeSubmit called');
        console.log('checkBeforeSubmit sfObjJSON ', JSON.stringify(sfObjJSON));
        console.log(typeof sfObjJSON);
        console.log(typeof sfObjJSON === 'object');
        console.log(Object.keys(sfObjJSON).length == 0);
        //as it might come object as  [] or  object  which is not like this { 0 : {sobjectType: 'Disbursal__c','Field Name' : value}}
        if ((typeof sfObjJSON === 'object' && (Object.keys(sfObjJSON).length == 0 || (sfObjJSON.hasOwnProperty('0') && !sfObjJSON[0].hasOwnProperty('sobjectType')))
        )) {

            console.log('checkBeforeSubmit 2 called');
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: false, msg: 'Please fill the required fields in user details', fieldName: 'userDetails' }
            });

        }
        // else if(!this.fieldOfficerEMPId){

        //     console.log('checkBeforeSubmit 2 called');
        //     custEvt = new CustomEvent("checkbeforesubmit", {
        //         detail: { isValid: false, msg: 'Please fill the required fields in user details', fieldName: 'userDetails' }
        //     });

        // } 
        else {
            console.log('checkBeforeSubmit 21 called');
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: true, msg: '', fieldName: 'userDetails' }
            });
        }
        this.dispatchEvent(custEvt);
    }

    handleSave() {
        // if(!this.fieldOfficerEMPId){
        //     this.showNotification('Error', 'Missing Field Disbursal Author Id!!', 'Error');
        //     return;
        // }
        this.showLoader = true;
        //var sfObjJSON = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        var sfObjJSON = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSaveWithoutOnChange();
        console.log('user json is >>>',JSON.stringify(sfObjJSON));
        if (sfObjJSON.length > 0
            && sfObjJSON[0].hasOwnProperty('sobjectType')
            && sfObjJSON[0].sobjectType == 'Disbursal__c') {

            //since it is coming in array. SO we need only first iteration
            sfObjJSON[0].Application__c = this.obj_parent_appt_wrapper_data.objAppt.Id;
            //sfObjJSON[0].Disbursal_Author_ID__c = this.fieldOfficerEMPId;
            sfObjJSON[0].Id = this.checkExistingDisbursalId(); //this is done to upsert existing disbursal record
            console.log('user json after data is >>>',JSON.stringify(sfObjJSON));
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
        } else if (sfObjJSON.length == 0) {//incase no object is return due to validation check
            this.showLoader = false;
        } else {
            this.showNotification('ERROR', 'Something wrong might happened.', 'error');
            this.showLoader = false;
        }
    }
}