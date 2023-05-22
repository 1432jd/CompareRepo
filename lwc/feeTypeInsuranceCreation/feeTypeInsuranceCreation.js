/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Sangeeta Yadav  
* @modifiedBy       Sangeeta Yadav   
* @created          2022-07-21
* @modified         2022-10-03
* @Description      This component is build to display insurance details related to application in fee detail
                     in FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
import { LightningElement, api, track } from 'lwc';
import getInsuranceRecords from '@salesforce/apex/FeeCreationTypeInsuranceNewController.getInsuranceRecords';
import getNewRow from '@salesforce/apex/FeeCreationTypeInsuranceNewController.getNewRow';
import getFeeCodeFromMaster from '@salesforce/apex/FeeCreationTypeInsuranceNewController.getFeeCodeFromMaster';
import getAgencyPicklist from '@salesforce/apex/FeeCreationTypeInsuranceNewController.getAgencyPicklist';
import getLoanApplicant from '@salesforce/apex/FeeCreationTypeInsuranceNewController.getLoanApplicant';
import repaymentTypeFromMaster from '@salesforce/apex/FeeCreationTypeInsuranceNewController.repaymentTypeFromMaster';
import saveInsFeeRecords from '@salesforce/apex/FeeCreationTypeInsuranceNewController.saveInsFeeRecords';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import callKotakCalculateAPI from '@salesforce/apex/FeeCreationTypeInsuranceNewController.callKotakCalculateAPI';
import deleteFee from '@salesforce/apex/FeeCreationTypeInsuranceNewController.deleteFee';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import isApiActive from '@salesforce/apex/FeeCreationTypeInsuranceNewController.isApiActive';
import getSyncError from '@salesforce/apex/FeeCreationTypeInsuranceNewController.getSyncError';
import insuranceRequirement from '@salesforce/apex/FeeCreationTypeInsuranceNewController.insuranceRequirement';

export default class FeeTypeInsuranceCreation extends LightningElement {
    @api recordId;
    @api stageName;
    @track isLoading = false;
    @track data = [];
    @track agencyOptions = [];
    @track showFee = true;
    @track isData = true;
    @track existingfeeOption = [];
    @track feeCodeMap = new Map();
    @track applicant = false;
    @track asset = false;
    @track isApplication = false;
    @track applicantOption = [];
    @track assetOption = [];
    @track isnewRow = false;
    @track forApplicableForSelect = []; //for id of applicant or asset based on selection
    @track options = []; //For repayment type option
    @track repaymentFeeMap = new Map();
    @track repaymentList = [];
    @track isApi = false; //if false API down and if true API up
    @track medicalInsuranceReq = false; // Premium and tax will be non editable if API up
    @track isError = false;
    @track totalRecommendedAmount = 0;
    @track sumAssuredChanged = false; //true if user changes sum assured
    @track fetchPremiumClicked = false; //true if fetch premium clicked
    //@track isChange = false; //if fee is changed it is true and save button will be available instead of fetch premium button

    connectedCallback() {
        console.log('In connected call back of Insurance Details');
        setTimeout(() => {
            console.log('this.application ID ', this.recordId);
            if (this.recordId != undefined) {
                this.isLoading = true;
                // Get Insurance Records
                
                this.getInsuranceRecords();
            }
            console.log('stageName in Insurance Details section', this.stageName);


        }, 300);


    }

    //Check if API is up or down
    isApiActive(){
        console.log('is api ?', this.isApi);
        isApiActive().then(result=>{
            console.log('Api result', result);
            this.isApi = result;
        }).catch(error=>{
            console.log('error in get API status',error);
        })
    }

    /*@Description: Check if Insurance Medical requirement meet
                    Added based on CR discussion on 9th jan 23
    @Dated: 10 Jan 23*/
    insuranceRequirement(){
        console.log('is insuranceRequirement ?', this.medicalInsuranceReq);
        insuranceRequirement({ applicationId: this.recordId }).then(result=>{
            console.log('medicalInsuranceReq result', result);
            this.medicalInsuranceReq = result;
            // @Description Ticket-0819: 10 Jan 23 : As per discussion with Ashok Premium and Tax will be always editable  on DM stage.
            // @Dated 11 Jan 23
            if(this.stageName == 'Disbursal Maker'){
                this.medicalInsuranceReq = true;
            }

        }).catch(error=>{
            console.log('error in get medicalInsuranceReq',error);
        })
    }
    @api
    async getInsuranceRecords() {
        console.log('Get insurance records called', this.recordId);
        this.isnewRow = false;
        this.sumAssuredChanged = false;
        this.fetchPremiumClicked = false;
        this.existingfeeOption = [];
        this.isSuccess = false;
        this.feeCodeValuesAre();
        this.getAgencyName();
        this.getApplicantAset();
        this.getRepaymentMap();
        this.isError = false;
        var resultGet = [];
        this.agencyOptions = [];
        this.isApiActive();
        this.insuranceRequirement(); //added on 10 Jan 23 if medical requirement : DOGH+MT and rated up

        console.log('call get fee insurance');
        await getInsuranceRecords({ applicationId: this.recordId ,stageName : this.stageName}).then(result => {
            console.log('insurance result from get fee', result);
            resultGet = JSON.parse(JSON.stringify(result));

            if (result.length == 0) {
                console.log('result is null');
                this.isData = false;
                this.isLoading = false;
            }
            else {
                console.log('result==> ' + JSON.stringify(resultGet), result.length);
                var feeLength = resultGet.length;
                console.log('insurance fee length is', JSON.stringify(feeLength));


                for (var i = 0; i < feeLength; i++) {
                    resultGet[i].rowNumber = i + 1;
                }
            }

            this.data = resultGet;
            console.log('this.data', this.data);
            if(this.data != undefined && this.data.length > 0){
                this.totalRecommendedAmount = this.data[0].feeList.Application__r.Total_Amount_Recommended_PcAc__c;
            }
            
            this.showFee = true;
            console.log('data in insurace detail component', this.data);
            this.isLoading = false;
        }).catch(error => {
            console.log('error==> ' + JSON.stringify(error));
        })

        //this.feeCodeValuesAre();
        //   this.getAgencyName();
        //   this.getApplicantAset();
        //   this.getRepaymentMap();
    }

    //Add new row
    createFeeCreationRecordRow(event) {
        this.isnewRow = true;
        getNewRow({ applicationId: this.recordId, stageName: this.stageName })
            .then(result => {
                console.log('New row created', JSON.parse(JSON.stringify(result)));
                var newData = JSON.parse(JSON.stringify(result));
                newData.rowNumber = this.data.length + 1;
                this.data.push(newData);
                console.log('this.data for insurance afer row add', this.data.length, this.data);
                this.isData = true;
                //this.totalRecommendedAmount = result.feeList.Sum_Assured__c;
                console.log('recommended amount',this.totalRecommendedAmount);
                // console.log('row added',newData.isChange);
                //  this.isRaise = false;
            })
            .catch(error => {
                console.log('error in new row creation', error);
            })
    }

    // changes for Fee code name
    feeCodeValuesAre() {
        console.log('this.existingfeeOption', this.existingfeeOption);
        this.existingfeeOption = [];
        console.log('application id to get master code', this.recordId)
        getFeeCodeFromMaster({ applicationId: this.recordId })
            .then(resultCode => {
                console.log('fee code result is', resultCode);
                this.existingfeeOption = [];
                for (let key in resultCode) {
                    console.log('Key', key);
                    console.log('resultCode', resultCode[key]);
                    console.log('resultCode', resultCode[key].feeValue.Description__c);
                    //changes for FVM 26-11-22
                    //this.feeCodeMap.set(key, resultCode[key]);
                    this.feeCodeMap.set(resultCode[key].feeValueId, resultCode[key]);
                    console.log('map for fee value master code', this.feeCodeMap);
                    /*const feeList = {
                        label: resultCode[key].Fee_Type_Code__c,
                        value: key
                    };*/

                    const feeList = {
                        label: resultCode[key].feeValue.Description__c,
                        //value: resultCode[key].feeMasterFeeCode
                        value: resultCode[key].feeValueId
                    };

                    this.existingfeeOption = [...this.existingfeeOption, feeList];


                }

            })
            .catch(error => {
                console.log('error in dev code', error);
            })
    }

    //Insurance Agency List
    getAgencyName() {
        getAgencyPicklist()
            .then(data => {
                this.agencyOptions = [];
                //  console.log('data for repayment',JSON.stringify(data));
                for (let key in data) {
                    console.log('data for approval Agency', data, data[key]);
                    var repayment = data[key];
                    console.log('repayment is' + repayment);
                    this.agencyOptions = [... this.agencyOptions, { key: key, value: repayment }];
                }
            })
            .catch(error => {
                console.log('error in repayment', error);
            })
    }

    updatefeeCodeValue(event) {
        console.log('updatefeeCodeValue called', event.target.value, this.feeCodeMap.get(event.target.value));
        var rowNo = event.target.getAttribute("data-row-index");
        this.applicant = false;
        this.asset = false;
        this.isApplication = false;
        console.log('applicant and asset', this.applicantOption, this.assetOption);
        //this.data[rowNo].feeList.Fee_Type_Master__c = event.target.value;
        this.applicantSelect(this.feeCodeMap.get(event.target.value).feeTypeFromMaster.Applicable_For__c);
        this.data[rowNo].feeList.Fee_Value_Master__c = this.feeCodeMap.get(event.target.value).feeValueId;
        //Added for FVM : 26 Nov 22
        this.data[rowNo].feeList.Fee_Type_Master__c = this.feeCodeMap.get(event.target.value).feeMasterId;
        //feeMasterId
        this.data[rowNo].feeList.Repayment_Type_2__c = '';
        if (this.feeCodeMap != null && this.feeCodeMap.size > 0) {
            console.log('fee code selected');
            //this.data[rowNo].feeList.Fee_Code__c = this.feeCodeMap.get(event.target.value).Fee_Type_Code__c;
            //Added for FVM : 26 Nov 22
            this.data[rowNo].feeList.Fee_Code__c = this.feeCodeMap.get(event.target.value).feeTypeFromMaster.Fee_Type_Code__c;
            this.data[rowNo].feeList.Applicable_For__c = this.feeCodeMap.get(event.target.value).feeTypeFromMaster.Applicable_For__c;
            console.log('value updateds in row', this.data[rowNo].feeList.Fee_Code__c, this.data[rowNo].feeList.Applicable_For__c);
            if (this.data[rowNo].feeList.Applicable_For__c == 'Application') {

                this.applicant = false;
                this.asset = false;
                this.isApplication = true;
                console.log('is application', this.isApplication);
            }
            else if (this.data[rowNo].feeList.Applicable_For__c == 'Applicant') {

                this.applicant = true;
                this.asset = false;
                this.isApplication = false;
                console.log('is applicant', this.applicant);
            }
            else if (this.data[rowNo].feeList.Applicable_For__c == 'Asset') {

                this.applicant = false;
                this.asset = true;
                this.isApplication = false;
                console.log('is asset', this.asset);
            }
        }
        //repayment list of new row
        if (this.repaymentFeeMap != null && this.repaymentFeeMap.size > 0) {
            this.repaymentList = [];
            for (var key in this.repaymentFeeMap.get(this.data[rowNo].feeList.Fee_Code__c)) {
                console.log('in repayment list set for loop for vs 2', key);
                const approval = {
                    label: this.repaymentFeeMap.get(this.data[rowNo].feeList.Fee_Code__c)[key],
                    value: this.repaymentFeeMap.get(this.data[rowNo].feeList.Fee_Code__c)[key]
                };
                this.repaymentList = [...this.repaymentList, approval];
            }
            this.data[rowNo].repaymentDetail = this.repaymentList;
        }

    }
/*@Description: Ticket-1259 (To Hide Insurance agency column)
   @Dated: 04 jan 2023

    handleAgencyNameChange(event) {
        console.log('handleAgencyNameChange called', event.target.value);
        var rowNo = event.target.getAttribute("data-row-index");
        this.data[rowNo].feeList.External_Agency_Master__c = event.target.value;
        this.data[rowNo].isChange = true;

    }*/

    // For Applicant and asset
    getApplicantAset() {
        this.applicantSelect('Applicant');
        this.applicantSelect('Asset');
    }
    applicantSelect(applicableFor) {
        //   var rowNo = event.target.getAttribute("data-row-index");
        // this.applicantAssetOption = [];
        this.applicantOption = [];
        this.assetOption = [];
        console.log('applicable on from prev data', applicableFor);
        getLoanApplicant({ applicationId: this.recordId, applicableFor: applicableFor })
            .then(result => {
                console.log('result from applicable on change', result);
                this.applicantOption = [];
                this.assetOption = [];
                for (let key in result) {
                    //console.log('Key', key);
                    // console.log('result', result[key]);

                    const applicant = {
                        label: result[key],
                        value: key
                    }; //console.log('result');
                    if (applicableFor == 'Applicant') {
                        
        
                        this.applicantOption.push(applicant);
                    }
                    else if (applicableFor == 'Asset') {
                        
                        this.assetOption.push(applicant);
                    }

                }

            })
            .catch(error => {
                console.log('error from applicable on change in pc', error);
            })
    }

    //Handle selection of applicant or asset

    applicableForSelectChange(event) {
        var forApplicableForSelect = event.target.value;
        var rowNo = event.target.getAttribute("data-row-index");
        console.log('target applicable value', forApplicableForSelect, rowNo, event.target.value);
        this.forApplicableForSelect[rowNo] = event.target.value;
        console.log('forapplicatble', this.forApplicableForSelect[rowNo]);

        if (this.data[rowNo].isNewRow == false) {
            console.log('for old row applicant or property');
            this.data[rowNo].isChange = true;
            if (this.data[rowNo].applicantAsset == true) {
                console.log('applicant', this.data[rowNo].applicantAsset);
                this.data[rowNo].feeList.Loan_Applicant__c = event.target.value;
                var selectedOption = this.applicantOption.filter(function (option) {
                    return option.value == event.target.value;
                })
                console.log('applicant', selectedOption);

                this.data[rowNo].applicantOrAssetName = selectedOption[0].label;
                console.log('applicant is ', this.data[rowNo].applicantOrAssetName);
            }
            else if (this.data[rowNo].applicantAsset == false && this.data[rowNo].isApplication == false) {
                console.log('property', this.data[rowNo].applicantAsset);
                this.data[rowNo].feeList.Property__c = event.target.value;
                var selectedOption = this.assetOption.filter(function (option) {
                    return option.value == event.target.value;
                })
                console.log('applicant', selectedOption);
                this.data[rowNo].applicantOrAssetName = selectedOption[0].label;
                console.log('Property is ', this.data[rowNo].applicantOrAssetName);
            }
        }
        else if (this.data[rowNo].isNewRow == true) {
            //this.applicableForUpdate.set(this.data[rowNo].devList.Id, this.forApplicableForSelect[rowNo]);
            if (this.applicant == true) {
                this.data[rowNo].feeList.Loan_Applicant__c = event.target.value;
            }
            else if (this.asset == true) {
                this.data[rowNo].feeList.Property__c = event.target.value;
            }
        }
        // this.handleShowSave();

    }

    //Get Repayment map with fee code based on master
    getRepaymentMap() {
        console.log('getRepaymentMap called');
        repaymentTypeFromMaster({ feeRecordType: 'Insurance' })
            .then(result => {
                console.log('result from get repayment key', JSON.stringify(result));
                for (let key in result) {
                    console.log('result from get repayment key', JSON.stringify(result[key]), key);
                    this.repaymentFeeMap.set(key, result[key]);
                    console.log('result from get user', this.repaymentFeeMap);

                }
            })
            .catch(error => {
                console.log('error from get user', JSON.stringify(error));
            })
    }

    // handle repayment select
    handleGetSelectedValue(event) {
        var rowNo = event.target.getAttribute("data-row-index");
        console.log('handle select repayment', rowNo, event.target.value);
        this.data[rowNo].feeList.Repayment_Type_2__c = event.target.value;
        this.data[rowNo].isChange = true;

    }

    //if premium and tax is zero onclick remove zero
    handlePremClick(event) {
        var element = event.target.getAttribute("data-row-index");
        console.log('handle prem click', element);

        if (this.data[element].feeList.Premium__c == 0) {
            this.data[element].feeList.Premium__c = '';
        }
    }
    handleTaxClick(event) {
        var element = event.target.getAttribute("data-row-index");
        console.log('handle tax click', element);
        if (this.data[element].feeList.Tax_Amount__c == 0) {
            this.data[element].feeList.Tax_Amount__c = '';
        }
    }

    handlePremChange(event) {
        var element = event.target.getAttribute("data-row-index");
        console.log('handle prem change', element, event.target.value);
        this.data[element].feeList.Premium__c = event.target.value;

        if (this.data[element].feeList.Premium__c != null && this.data[element].feeList.Tax_Amount__c != null) {
            console.log('update total fee');
            this.data[element].feeList.Total_Fee__c = parseFloat(this.data[element].feeList.Premium__c) + parseFloat(this.data[element].feeList.Tax_Amount__c);
        }
        else if (this.data[element].feeList.Premium__c != null) {
            console.log('update total fee');
            this.data[element].feeList.Total_Fee__c = this.data[element].feeList.Premium__c;
        }
        else if (this.data[element].feeList.Tax_Amount__c != null) {
            console.log('update total fee');
            this.data[element].feeList.Total_Fee__c = this.data[element].feeList.Tax_Amount__c;
        }
        this.data[element].isChange = true;
    }

    handleTaxChange(event) {
        var element = event.target.getAttribute("data-row-index");
        console.log('handle prem change', element, event.target.value);
        this.data[element].feeList.Tax_Amount__c = event.target.value;
        if (this.data[element].feeList.Premium__c != null && this.data[element].feeList.Tax_Amount__c != null) {
            console.log('update total fee');
            this.data[element].feeList.Total_Fee__c = parseFloat(this.data[element].feeList.Premium__c) + parseFloat(this.data[element].feeList.Tax_Amount__c);
        }
        else if (this.data[element].feeList.Premium__c != null) {
            console.log('update total fee');
            this.data[element].feeList.Total_Fee__c = this.data[element].feeList.Premium__c;
        }
        else if (this.data[element].feeList.Tax_Amount__c != null) {
            console.log('update total fee');
            this.data[element].feeList.Total_Fee__c = this.data[element].feeList.Tax_Amount__c;
        }
        this.data[element].isChange = true;
    }

    //handle sum assured change
    handleSumAssuredChange(event) {
        var element = event.target.getAttribute("data-row-index");
        console.log('handle sum assured change', element, event.target.value);
        this.data[element].feeList.Sum_Assured__c = event.target.value;
        this.data[element].isChange = true;
        this.sumAssuredChanged = true;
    }

    //handle fetch premium click
    async handleClick(event) {
        var element = event.target.getAttribute("data-row-index");
        this.fetchPremiumClicked = true;
        console.log('fetchPremiumClicked',this.fetchPremiumClicked);
        var alertOk = false;
        if(this.isApi == false){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Currently API is down',
                    variant: 'error'
                })
            );
        }
        else if(this.isApi == true){
            if(this.isChange == true){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please save all the changes',
                        variant: 'error'
                    })
                );
            }
            else if(this.isError == false){
                console.log('Call Kotak API');
                this.isLoading = true;
                this.showFee = false;
                var totalSumAssured = 0;
                if(this.totalRecommendedAmount != null && this.totalRecommendedAmount != undefined){
                    //To calculated sum of fee insurance of same fee code

                    if(this.data != null && this.data != undefined){
                        console.log('this.data',this.data[element].feeList.Fee_Code__c, this.data.length);
                        for(var fee = 0; fee < this.data.length; fee++){
                            console.log('iteration',fee, 'prem calculated', this.data[fee].feeList.Pending_Premium_Calculation__c );
                            //this.isLoading = false;
                            if(this.data[fee].feeList.Pending_Premium_Calculation__c === false){
                                if(this.data[fee].feeList.Sum_Assured__c != null ){
                                    totalSumAssured += this.data[fee].feeList.Sum_Assured__c;
                                }
                                else{
                                    totalSumAssured = totalSumAssured;
                                }
                                
                            }
                            else if(fee == element){
                                if(this.data[fee].feeList.Sum_Assured__c != null ){
                                    totalSumAssured += this.data[fee].feeList.Sum_Assured__c;
                                }
                                else{
                                    totalSumAssured = totalSumAssured;
                                }
                            }
                        }
                        console.log('totalSumAssured',totalSumAssured);
                    }
                    //--------------------------------------------------------------
                    
                    var sumAssuredDiff = this.totalRecommendedAmount - this.data[element].feeList.Sum_Assured__c;
                    var totalSumAssuredDiff = this.totalRecommendedAmount - totalSumAssured;
                    //if(sumAssuredDiff < 0){
                    if(totalSumAssuredDiff < 0){
                        // sum assured is greater than total recommended amount
                    await    LightningConfirm.open({
                            message: 'Total Sum Assured Amount is greater than Total Recommended Amount',
                            theme: 'error', // a red theme intended for error states
                            label: 'Alert!', // this is the header text
                        }).then((result) => {
                            console.log('Result: '+ result);
                            alertOk = result;
            
                        });
                    }
                    //else if(sumAssuredDiff > 0){
                    else if(totalSumAssuredDiff > 0){
                        // sum assured is smaller than total recommended amount
                    await    LightningConfirm .open({
                            message: 'Total Sum Assured Amount is smaller than Total Recommended Amount',
                            theme: 'error', // a red theme intended for error states
                            label: 'Alert!', // this is the header text
                        }).then((result) => {
                            console.log('Result: '+ result);
                            alertOk = result;
                        });
                    }
                    else {
                        console.log('equal');
                        alertOk = true;
                    }
                }
                console.log('id to fetch premium for',this.data[element].feeList.Id);
                if(alertOk === true){
                await callKotakCalculateAPI({ feeId: this.data[element].feeList.Id, sumAssured: this.data[element].feeList.Sum_Assured__c})
                        .then(data => {
                            let premium;
                            console.log('Premium Details list ' + JSON.stringify(data) );
                            if(data === null){
                                //Get error from fetch Premium
                                getSyncError({feeId : this.data[element].feeList.Id})
                                .then(result=>{
                                    var msg = result;
                                    console.log('msg',msg);
                                    if(msg != 'null' || msg != 'Success'){
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error',
                                            message: msg,
                                            variant: 'error'
                                        })
                                    );
                                    this.isSuccess = false;
                                    }
                                   /* else if(msg != 'null' ){
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Success',
                                                message: msg,
                                                variant: 'Success'
                                            })
                                        );
                                    }*/
                                }).catch(error =>{
                                    console.log('error',error);
                                })
                                this.showFee = true;
                                this.isLoading = false;
                            }
                            else{
                                console.log('Job Id ' + data[0].Job_Id__c);
                                if(data[0].Job_Id__c != null && data[0].Job_Id__c != '' && data[0].Job_Id__c != undefined){
                                    this.isSuccess = true;
                                }
                            }
                           // this.isSuccess = false;
                           if(this.isSuccess == true){
                            this.data[element].feeList.Pending_Premium_Calculation__c = false;
                            for (let key in data) {
                                console.log('key' + key);
                                premium = JSON.parse(JSON.stringify(data[key]));
                                console.log('Premium Details is' + premium);
                                console.log('premium' + premium.Premium__c);
                                this.premiumValue = premium.Premium__c;
                                console.log('service tax' + premium.Service_Tax__c);
                                this.taxAmount = premium.Service_Tax__c;
                                console.log('tax amount' + this.taxAmount);
                                this.finalAmountValue = premium.Total_Premium__c;
                            }
                            console.log('tax amount outside' + typeof this.taxAmount);

                            
                            this.data[element].feeList.Tax_Amount__c = this.taxAmount;
                            console.log('tax amount', this.data[element].feeList.Tax_Amount__c);
                            this.data[element].feeList.Premium__c = this.premiumValue;
                            console.log('result[i].Premium__c', this.data[element].feeList.Premium__c);
                            this.data[element].feeList.Total_Fee__c = this.finalAmountValue;
                            this.data[element].feeList.Fetch_Premium__c  = true;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Premium fetched successfully',
                                    variant: 'Success'
                                })
                            );
                            this.saveInsuranceFee(element);
                            this.showFee = true;
                            this.isLoading = false;
                        }

                        })
                        .catch(error => {
                            console.log('error in repayment', error);
                            this.showFee = true;
                            this.isLoading = false;
                        })
                }
                else{
                    console.log('alertOk',alertOk, 'save is cancelled');
                    this.showFee = true;
                    this.isLoading = false;
                }
            }
        }
    }
    //handle save buttons click
    async handleSave(event) {
        var element = event.target.getAttribute("data-row-index");
        
        console.log('handle save called');
        this.isLoading = true;
        this.isError = false;
        console.log('fee to update', this.data[element].feeList);
        // if(this.data[element].isNewRow == true){
       // console.log('fee code for new row', this.data[element].isNewRow, this.data[element].feeList.Fee_Code__c, 'agency', this.data[element].feeList.External_Agency_Master__c);
        console.log('isAPI', this.isApi, this.data[element].feeList.Premium__c, this.data[element].feeList.Tax_Amount__c);
        this.validation(element);
        if (this.isError == false) {
            console.log('no error');
            this.showFee = false;
            if(this.isApi == true){
                this.data[element].feeList.Pending_Premium_Calculation__c = true;
                if(this.sumAssuredChanged == true){
                    this.data[element].feeList.Premium__c = 0;
                    this.data[element].feeList.Tax_Amount__c = 0;
                    this.data[element].feeList.Total_Fee__c = 0;
                }
            }
            await this.saveInsuranceFee(element);
           /* for (var i = 0; i < this.data.length; i++) {
                if (i == element) {
                    var insFee = '[';
                    insFee += JSON.stringify(this.data[i]);
                    insFee += ']';
                }
            }
            console.log('insFee', insFee);
            //Insert New Row
            await saveInsFeeRecords({ insWrapperList: insFee })
                .then(result => {
                    this.getInsuranceRecords();
                    console.log('result after insurance fee insert', result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Fee Updated successfully',
                            variant: 'Success'
                        })
                    );


                    // this.data[element].isChange = false;
                    getRecordNotifyChange([{ recordId: this.recordId }]);
                    //this.getInsuranceRecords();

                })
                .catch(error => {
                    console.log('error after insurance fee insert', error);
                    this.isLoading = false;
                })*/

            // this.getInsuranceRecords();
            //this.showFee = true;
        }
        else {
            this.isLoading = false;
        }
    }

    //save insurance fee
async  saveInsuranceFee(element){
        for (var i = 0; i < this.data.length; i++) {
            if (i == element) {
                var insFee = '[';
                insFee += JSON.stringify(this.data[i]);
                insFee += ']';
            }
        }
        console.log('insFee', insFee);
        //Insert New Row
        await saveInsFeeRecords({ insWrapperList: insFee })
            .then(result => {
                this.getInsuranceRecords();
                console.log('result after insurance fee insert', result);
                console.log('fetchPremiumClicked',this.fetchPremiumClicked);
                if(this.fetchPremiumClicked === false){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Fee Updated successfully',
                            variant: 'Success'
                        })
                    );
                }
                var feeEvent = new CustomEvent("getinsfeechangeevent", {
                    detail: 'this.showFee',
                    bubbles: true,
                    composed: true
                });
                console.log('dispatch receiptEvent ', JSON.stringify(feeEvent));
                this.dispatchEvent(feeEvent);

                // this.data[element].isChange = false;
                getRecordNotifyChange([{ recordId: this.recordId }]);
                //this.getInsuranceRecords();

            })
            .catch(error => {
                console.log('error after insurance fee insert', error);
                this.isLoading = false;
            })
    }

    validation(element) {
        if (this.data[element].feeList.Fee_Code__c === undefined || this.data[element].feeList.Fee_Code__c === null || this.data[element].feeList.Fee_Code__c === '') {
            console.log('fee code for ', this.data[element].feeList.Fee_Code__c);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Fee Code',
                    variant: 'error'
                })
            );

            this.isError = true;
        }
        // }
        /*@Description: Ticket-1259 (To Hide Insurance agency column)
            @Dated: 04 jan 2023
        
        else if (this.data[element].feeList.External_Agency_Master__c === undefined || this.data[element].feeList.External_Agency_Master__c === null || this.data[element].feeList.External_Agency_Master__c === '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Agency',
                    variant: 'error'
                })
            );

            this.isError = true;
        }*/
        else if (this.data[element].feeList.Applicable_For__c == 'Applicant') {
            if (this.data[element].feeList.Loan_Applicant__c == null || this.data[element].feeList.Loan_Applicant__c == '' || this.data[element].feeList.Loan_Applicant__c == undefined) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select Applicant',
                        variant: 'error'
                    })
                );

                this.isError = true;
            }
        }
        else if (this.data[element].feeList.Applicable_For__c == 'Asset') {
            if (this.data[element].feeList.Property__c == null || this.data[element].feeList.Property__c == '' || this.data[element].feeList.Property__c == undefined) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select Asset',
                        variant: 'error'
                    })
                );

                this.isError = true;
            }
        }
        if (this.isError == false) {
            if (this.isApi == false) {
                console.log('for premium and tax');
                if (this.data[element].feeList.Premium__c == null || this.data[element].feeList.Premium__c == '' || this.data[element].feeList.Premium__c <= 0 || this.data[element].feeList.Premium__c == undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Premium can not be blank',
                            variant: 'error'
                        })
                    );
                    this.isError = true;
                }
                else if (this.data[element].feeList.Tax_Amount__c == null || this.data[element].feeList.Tax_Amount__c == '' || this.data[element].feeList.Tax_Amount__c <= 0 || this.data[element].feeList.Tax_Amount__c == undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Tax Amount can not be blank',
                            variant: 'error'
                        })
                    );
                    this.isError = true;
                }
            }
            else if (this.data[element].feeList.Sum_Assured__c == null || this.data[element].feeList.Sum_Assured__c == '' || this.data[element].feeList.Sum_Assured__c <= 0 || this.data[element].feeList.Sum_Assured__c == undefined) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Sum Assured can not be blank',
                        variant: 'error'
                    })
                );
                this.isError = true;
            }

        }
        if (this.isError == false) {
            if (this.data[element].feeList.Repayment_Type_2__c == null || this.data[element].feeList.Repayment_Type_2__c == '' || this.data[element].feeList.Repayment_Type_2__c == undefined) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Select Mode',
                        variant: 'error'
                    })
                );
                this.isError = true;
            }
        }

    }
    testclick(event){
        console.log('Delete called');
        console.log('event of delete',event.target.name);
    }
    //handle delete
    handleDelete(event){
        console.log('Delete called');
        console.log('event of delete',event);
        console.log('event of delete',event.target.name);
        var rowNo = event.target.getAttribute("data-row-index");
        
        console.log('rowNo',rowNo);
        if(this.data[rowNo].isNewRow == true){
            this.showFee = false;
            this.isnewRow = false;
            this.data.splice(rowNo, 1);
           // this.getInsuranceRecords();
           console.log(this.isnewRow);
           this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Row Deleted Successfully',
                variant: 'success'
            })
            
        );  this.getInsuranceRecords();
           this.showFee = true;
          // this.isLoading = false;
        }
        else if(this.data[rowNo].isNewRow == false){
            this.showFee = false;
            this.isnewRow = false;
            
            for (var i = 0; i < this.data.length; i++) {
                if (i == rowNo) {
                    var insFee = '[';
                    insFee += JSON.stringify(this.data[i]);
                    insFee += ']';
                }
            }
            deleteFee({insWrapperList: insFee}).then(result=>{
                console.log('result on delete',result);
                //this.data.splice(element, 1);
                this.getInsuranceRecords();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Row Deleted Successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error=>{
                console.log('error on delete',error);
            })
           // this.getInsuranceRecords();
           console.log(this.isnewRow);
           this.showFee = true;
        }

    }

}