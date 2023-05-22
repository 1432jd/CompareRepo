import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//------------------------------------------------------------------------------
import getDueDateError from '@salesforce/apex/Fiv_Disb_LwcController.getDueDateError';
import getAppStage from '@salesforce/apex/Fiv_Disb_LwcController.getAppStage';
import getMetaDataFields from '@salesforce/apex/Fiv_Disb_LwcController.getMetaDataFields';
import getDeductionAmount from '@salesforce/apex/Fiv_Disb_LwcController.getDeductionAmount'; //Karan Singh : 03-10-2022 : CH
import saveDisbursalCompData from '@salesforce/apex/Fiv_Disb_LwcController.saveDisbursalCompData';
//------------------------------------------------------------------------------

export default class Fiv_Disb_DisbursalParams extends LightningElement {
    
    @api obj_parent_appt_wrapper_data;
    @track disbursalDateData;
    @api objdeductiondetails;//Karan Singh : 03-10-2022 - CH
    @track objDisbursalParamaters;
    @track disbursalData;
    @track stageName='';
    showLoader = false;
    @track uiDataMap = new Map();
    @track mapAutoPopulateFieldMapping = new Map();
    sanctionLoanAmt = 0;
    totalDeduction = 0;
    finalDisbAmount = 0;
    //--------------------------------------------------------------------------
    connectedCallback() {

        this.doInit();
        console.log('stage name ios >>>>',this.stagename);
    }
    //Karan SIngh : 03-10-2022 : Added this @api method
    @api
    doInit() {
        console.log('inside do init first');
        this.setFieldNameForAutoPopulate();
        console.log('inside do init second');
        this.getDisbursalParamaters();
        console.log('inside do init third');
        this.getDueDate();
        this.getAppStageName();
    }

    getDueDate(){
        getDueDateError({ apptId: this.obj_parent_appt_wrapper_data.objAppt.Id }).then((result) => {
            this.disbursalDateData=JSON.parse(JSON.stringify(result));
            console.log('this.disbursalDateData >>>',this.disbursalDateData);
            console.log('this.disbursalDateData length is >>>',this.disbursalDateData.length);
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });
    }

    getAppStageName(){

        getAppStage({
            apptId: this.obj_parent_appt_wrapper_data.objAppt.Id
        }).then((result) => {
            this.stageName=result;
        }).catch((err) => {
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }



    //--------------------------------------------------------------------------
    setFieldNameForAutoPopulate() {

        console.log('this.stageName >>>>',this.stageName);

        console.log('obj_parent_appt_wrapper_data >>>',this.obj_parent_appt_wrapper_data);

        //For autopopulate other then application record : checking if incase map is not coming empty 
        if (Object.keys(this.obj_parent_appt_wrapper_data.mapExtraParams).length) {

            //converting object to map for setting auto populate
            this.mapAutoPopulateFieldMapping = new Map(Object.entries(this.obj_parent_appt_wrapper_data.mapExtraParams));
        }
        //----------------------------------------------------------------------
        //var finalDisbAmnt = 0; //sanction loan amount - total  deduction
        //For autopopulate other then application record
        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Emi_PcAc__c')
            && this.obj_parent_appt_wrapper_data.objAppt.Emi_PcAc__c) {

            this.mapAutoPopulateFieldMapping.set('Monthly_Installment_EMI_Rs__c', this.obj_parent_appt_wrapper_data.objAppt.Emi_PcAc__c);
        } else {
            this.mapAutoPopulateFieldMapping.set('Monthly_Installment_EMI_Rs__c', 0);
        }

        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Total_Amount_Recommended_PcAc__c')
            && this.obj_parent_appt_wrapper_data.objAppt.Total_Amount_Recommended_PcAc__c) {
                console.log('ac pc amount is >>',this.obj_parent_appt_wrapper_data.objAppt.Total_Amount_Recommended_PcAc__c);
            this.mapAutoPopulateFieldMapping.set('Sanctioned_Loan_Amount__c', this.obj_parent_appt_wrapper_data.objAppt.Total_Amount_Recommended_PcAc__c);
            //finalDisbAmnt = this.obj_parent_appt_wrapper_data.objAppt.Total_Amount_Recommended_PcAc__c;
            console.log('ac pc map amount is >>', this.mapAutoPopulateFieldMapping.get('Sanctioned_Loan_Amount__c'));

        } else {
            this.mapAutoPopulateFieldMapping.set('Sanctioned_Loan_Amount__c', 0);
        }

        /*
        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Total_Deductions__c')
            && this.obj_parent_appt_wrapper_data.objAppt.Total_Deductions__c) {


            this.mapAutoPopulateFieldMapping.set('Total_Deductions__c', this.obj_parent_appt_wrapper_data.objAppt.Total_Deductions__c);
            finalDisbAmnt = finalDisbAmnt - this.obj_parent_appt_wrapper_data.objAppt.Total_Deductions__c;
            console.log('finalDisbAmnt 2 ' + finalDisbAmnt);
        } else {
            this.mapAutoPopulateFieldMapping.set('Total_Deductions__c', 0);
        }*/

        //console.log(finalDisbAmnt);
        //this.mapAutoPopulateFieldMapping.set('Final_Disbursal_Amount__c', finalDisbAmnt);
        console.log('inside 4');
        console.log('this.mapAutoPopulateFieldMapping in param >>',this.mapAutoPopulateFieldMapping);
    }

    //--------------------------------------------------------------------------
    getDisbursalParamaters() {
        this.objDisbursalParamaters = undefined;
        this.showLoader = true;
        this.objdeductiondetails = {};//Karan Singh : 03-10-2022 : CH
        //this.obj_parent_appt_wrapper_data.disbMetaPrefix will define the component will open for disbursal author or maker ex DISBM_Loan_Parameters
        getMetaDataFields({ recordIds: this.checkExistingDisbursalId(), metaDetaName: this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'Disbursal_Parameters' }).then((result) => {

            console.log('Fiv_Disb_DisbursalParams objDisbursalParamaters = ', result);
            this.objDisbursalParamaters = result.data;
            console.log('this.objDisbursalParamaters in getdisb is >>>',this.objDisbursalParamaters);
            //this.autoPopulateDisbParameters();
            this.showLoader = false;
            this.getDeductionAmount(); //Karan SIngh : 03-10-2022 : CH
        }).catch((err) => {
            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_DisbursalParams getDisbursalParamaters = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }

    //--------------------------------------------------------------------------
    //First initial Auto-Populated fields
    autoPopulateDisbParameters() {
         console.log('before autoPopulateDisbParameters map >>>',this.mapAutoPopulateFieldMapping)
        console.log('autoPopulateDisbParameters invoked ' + JSON.stringify(this.objdeductiondetails));
        console.log('this.objDisbursalParamaters in params >>',this.objDisbursalParamaters);
        this.disbursalData = JSON.parse(this.objDisbursalParamaters);
        var _tempVar = JSON.parse(this.objDisbursalParamaters);
        console.log('after autoPopulateDisbParameters map >>>',this.mapAutoPopulateFieldMapping)

        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {


            if (!_tempVar[0].fieldsContent[i].value
                && this.mapAutoPopulateFieldMapping.has(_tempVar[0].fieldsContent[i].fieldAPIName)) {
                    console.log('_tempVar[0].fieldsContent[i].fieldAPIName',_tempVar[0].fieldsContent[i].fieldAPIName);
                    console.log('_tempVar[0].fieldsContent[i].value',_tempVar[0].fieldsContent[i].value);
                    console.log('map val is >>',this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName));

                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);

            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Sanctioned_Loan_Amount__c') {
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);

                console.log('_tempVar[0].fieldsContent[i].value in param >>',_tempVar[0].fieldsContent[i].value);
                this.sanctionLoanAmt = _tempVar[0].fieldsContent[i].value;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Total_Deductions__c') {

                //Karan Singh : 03-09-2022 : CH : will update the Latestvalues
                if (this.objdeductiondetails.hasOwnProperty('totalFeeDeduction')) {
                    console.log('param 136 ',this.objdeductiondetails.totalFeeDeduction);
                    console.log('param 137 ',this.objdeductiondetails.totalInsurancePremium);
                    //_tempVar[0].fieldsContent[i].value = this.objdeductiondetails.totalFeeDeduction;//Karan Singh  : 07-10-2022 : CH : As per client need to add insurance premium
                    _tempVar[0].fieldsContent[i].value = parseFloat(this.objdeductiondetails.totalFeeDeduction) + parseFloat(this.objdeductiondetails.totalInsurancePremium); //Karan Singh  : 07-10-2022 : CH : As per client need to add insurance premium
                    this.totalDeduction = _tempVar[0].fieldsContent[i].value;
                    console.log('this.totalDeduction = ',this.totalDeduction);
                    this.totalDeduction =   Number(this.totalDeduction.toFixed(2));
                    console.log('param 141 ',_tempVar[0].fieldsContent[i].value);
                     console.log('param 142 ',this.totalDeduction);
                }
                console.log('this.totalDeduction Init' + this.totalDeduction);
                console.log(_tempVar[0].fieldsContent[i].fieldAPIName + ' - ' + _tempVar[0].fieldsContent[i].value);
            }
            //Karan Singh : 03-09-2022 : CH : will update the Latestvalues

            /*if ((!_tempVar[0].fieldsContent[i].value || _tempVar[0].fieldsContent[i].value == 0)
                && _tempVar[0].fieldsContent[i].fieldAPIName == 'Final_Disbursal_Amount__c') {

                _tempVar[0].fieldsContent[i].value = this.sanctionLoanAmt - this.totalDeduction;
            }*/
            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Final_Disbursal_Amount__c' ) {

                _tempVar[0].fieldsContent[i].value = this.sanctionLoanAmt - this.totalDeduction;
            }

            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Monthly_Installment_EMI_Rs__c') {
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Disbursal_Beneficiary_Type__c' && this.stageName=='Disbursal Author') {
                _tempVar[0].fieldsContent[i].disabled = true;
                
            }else if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Disbursal_Beneficiary_Type__c' && this.stageName!='Disbursal Author') {
                _tempVar[0].fieldsContent[i].disabled = false;

            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Disbursal_Type__c' && this.stageName=='Disbursal Author') {
                _tempVar[0].fieldsContent[i].disabled = true;
            }else if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Disbursal_Type__c' && this.stageName!='Disbursal Author') {
                _tempVar[0].fieldsContent[i].disabled = false;
            }

            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Due_Date__c') {
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);

            }

            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'First_Installment_Date__c') {
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);

            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Interest_Start_Date__c') {
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].value = this.mapAutoPopulateFieldMapping.get(_tempVar[0].fieldsContent[i].fieldAPIName);

            }
            this.uiDataMap.set(_tempVar[0].fieldsContent[i].fieldAPIName, _tempVar[0].fieldsContent[i].value);

            

        }
        console.log('this.sanctionLoanAmt Init' + this.sanctionLoanAmt);
        console.log('this.totalDeduction Init' + this.totalDeduction);
        this.objDisbursalParamaters = JSON.stringify(_tempVar);
        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(this.objDisbursalParamaters);
    }
    //--------------------------------------------------------------------------
    handleFieldChanges(event) {
        try {


            console.log('handleFieldChanges= ', JSON.stringify(event.detail));
            console.log('handleFieldChanges= ', JSON.stringify(event.detail.CurrentFieldValue));
            var _tempVar = JSON.parse(this.objDisbursalParamaters);

            if (event.detail.CurrentFieldAPIName == 'Disbursal__c-Sanctioned_Loan_Amount__c') {
                this.sanctionLoanAmt = event.detail.CurrentFieldValue ? parseFloat(event.detail.CurrentFieldValue) : 0;
            }
            if (event.detail.CurrentFieldAPIName == 'Disbursal__c-Total_Deductions__c') {
                this.totalDeduction = event.detail.CurrentFieldValue ? parseFloat(event.detail.CurrentFieldValue) : 0;
            }

            console.log(';handleparam 180',this.totalDeduction);

            this.calculateFinalDisbAmt(event.detail.CurrentFieldAPIName, event.detail.CurrentFieldValue);
        } catch (error) {
            console.log(error.message);
        }
        //console.log( _tempVar. )
        //this.handleFormValueChange(event);
    }
    calculateFinalDisbAmt(fieldName, value) {
        console.log('this.sanctionLoanAmt ' + this.sanctionLoanAmt);
        console.log('this.totalDeduction ' + this.totalDeduction);
        this.finalDisbAmount = this.sanctionLoanAmt - this.totalDeduction;
        this.finalDisbAmount = this.finalDisbAmount ? this.finalDisbAmount : 0;
        console.log('finalDisbAmount ' + this.finalDisbAmount);
        var _tempVar = JSON.parse(this.objDisbursalParamaters);

        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {

            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Final_Disbursal_Amount__c') {

                _tempVar[0].fieldsContent[i].value = this.finalDisbAmount;
            }
            else if (_tempVar[0].fieldsContent[i].fieldAPIName == fieldName) {

                _tempVar[0].fieldsContent[i].value = value;
            }
        }

        this.objDisbursalParamaters = JSON.stringify(_tempVar);
        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(this.objDisbursalParamaters);
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
    //==========================================================================
    /** Karan Singh : 03-10-2022 : CH */
    @api
    getDeductionAmount() {
        this.showLoader = true;
        getDeductionAmount({
            apptId: this.obj_parent_appt_wrapper_data.objAppt.Id
        }).then((result) => {

            console.log('Fiv_Disb_DisbursalParams getDeductionAmount IN PARAM = ', JSON.stringify(result));
            this.objdeductiondetails = result.mapExtraParams;
            console.log('get deductiom amount is <<<',this.objdeductiondetails);
            console.log(`result ${typeof this.objdeductiondetails} and objDeduction - ${JSON.stringify(this.objdeductiondetails)}`);
            this.autoPopulateDisbParameters();
            this.showLoader = false;
        }).catch((err) => {

            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }
    //==========================================================================
    @api
    checkBeforeSubmit() {

        console.log('checkBeforeSubmit Disbursal Param');
        var sfObjJSON = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        var custEvt;

        console.log('checkBeforeSubmit called');
        console.log('checkBeforeSubmit sfObjJSON ', JSON.stringify(sfObjJSON));
        console.log(typeof sfObjJSON);
        console.log(typeof sfObjJSON === 'object');
        console.log(Object.keys(sfObjJSON).length == 0);
        console.log('Fiv_Disb_DisbursalParams this.objdeductiondetails - ' + JSON.stringify(this.objdeductiondetails));
        //as it might come object as  [] or  object  which is not like this { 0 : {sobjectType: 'Disbursal__c','Field Name' : value}}
        if ((typeof sfObjJSON === 'object' && (Object.keys(sfObjJSON).length == 0 || (sfObjJSON.hasOwnProperty('0') && !sfObjJSON[0].hasOwnProperty('sobjectType')))
        )) {

            console.log('checkBeforeSubmit 2 called');
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: false, msg: 'Please fill the required fields in Disbursal Parameters', fieldName: 'disbParam' }
            });

        }
        else if (this.objdeductiondetails.disbTotalDeduct != parseFloat(this.objdeductiondetails.totalFeeDeduction) + parseFloat(this.objdeductiondetails.totalInsurancePremium)) { //Karan Singh  : 07-10-2022 : CH : As per client need to add insurance premium
            console.log('checkBeforeSubmit deduction not same',this.objdeductiondetails.disbTotalDeduct);
            console.log('checkBeforeSubmit deduction not same two',parseFloat(this.objdeductiondetails.totalFeeDeduction) + parseFloat(this.objdeductiondetails.totalInsurancePremium));
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: false, msg: 'There is change in Disbursal Parameters record.Please save before proceeding.', fieldName: 'disbParam' }
            });
        }else if(this.disbursalDateData.length>0){

            var checkval=false;

            for (var i = 0; i < this.disbursalData[0].fieldsContent.length; i++) {

                

                if (this.disbursalData[0].fieldsContent[i].fieldAPIName == 'Due_Date__c' && this.uiDataMap.has(this.disbursalData[0].fieldsContent[i].fieldAPIName)){                  
                    console.log('check date of disb>>,',this.disbursalDateData[0].Due_Date__c);
                    console.log('check map date of disb>>,',this.uiDataMap.has(this.disbursalData[0].fieldsContent[i].fieldAPIName));
                    if(this.disbursalDateData[0].Due_Date__c !=this.uiDataMap.get(this.disbursalData[0].fieldsContent[i].fieldAPIName) && !checkval){
                        checkval=true;
                        console.log('inside the due date call event');
                        custEvt = new CustomEvent("checkbeforesubmit", {
                            detail: { isValid: false, msg: 'There is change in Business Date . Please save before proceeding.', fieldName: 'disbParam' }
                        });
                    }
                }else if (this.disbursalData[0].fieldsContent[i].fieldAPIName == 'Interest_Start_Date__c'){
                    console.log('check date of disb>>,',this.disbursalDateData[0].Due_Date__c);
                    console.log('check map date of disb>>,',this.uiDataMap.has(this.disbursalData[0].fieldsContent[i].fieldAPIName));
                   
                    if(this.disbursalDateData[0].Interest_Start_Date__c !=this.uiDataMap.get(this.disbursalData[0].fieldsContent[i].fieldAPIName) && !checkval){
                        checkval=true;
                        console.log('inside interest the call event');
                        custEvt = new CustomEvent("checkbeforesubmit", {
                            detail: { isValid: false, msg: 'There is change in Business Date . Please save before proceeding.', fieldName: 'disbParam' }
                        });
                    }
                }else if (this.disbursalData[0].fieldsContent[i].fieldAPIName == 'First_Installment_Date__c'){
                    console.log('check date of disb>>,',this.disbursalDateData[0].Due_Date__c);
                    console.log('check map date of disb>>,',this.uiDataMap.has(this.disbursalData[0].fieldsContent[i].fieldAPIName));
                   
                    if(this.disbursalDateData[0].First_Installment_Date__c !=this.uiDataMap.get(this.disbursalData[0].fieldsContent[i].fieldAPIName) && !checkval){
                        checkval=true;
                        console.log('inside fisrt the call event');
                        custEvt = new CustomEvent("checkbeforesubmit", {
                            detail: { isValid: false, msg: 'There is change in Business Date . Please save before proceeding.', fieldName: 'disbParam' }
                        });
                    }
                }else if(i == this.disbursalData[0].fieldsContent.length-1 && !checkval){
                    console.log('inside else else of disbursal');
                    custEvt = new CustomEvent("checkbeforesubmit", {
                        detail: { isValid: true, msg: '', fieldName: 'disbParam' }
                    });
                }
            }
        }
        
        this.dispatchEvent(custEvt);
    }

    handleSave() {
        this.showLoader = true;

        var sfObjJSON = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSaveWithoutOnChange();
        console.log(JSON.stringify(sfObjJSON));
        if (sfObjJSON.length > 0
            && sfObjJSON[0].hasOwnProperty('sobjectType')
            && sfObjJSON[0].sobjectType == 'Disbursal__c') {

            //since it is coming in array. SO we need only first iteration
            sfObjJSON[0].Application__c = this.obj_parent_appt_wrapper_data.objAppt.Id;
            sfObjJSON[0].Id = this.checkExistingDisbursalId(); //this is done to upsert existing disbursal record

            //doing this again for recalculation
            sfObjJSON[0].Final_Disbursal_Amount__c = parseFloat(sfObjJSON[0].Sanctioned_Loan_Amount__c) - parseFloat(sfObjJSON[0].Total_Deductions__c);
            sfObjJSON[0].Final_Disbursal_Amount__c = '' + sfObjJSON[0].Final_Disbursal_Amount__c;

            console.log('@@@ ' + JSON.stringify(sfObjJSON));

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
                    this.doInit();

                }
                this.showLoader = false;
                eval("$A.get('e.force:refreshView').fire();")
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