/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Arnav Chaudhary 
* @modifiedBy       Arnav Chaudhary  
* @created          2022-07-15
* @modified         2022-07-15
* @Description      This component is build to display fee details related to application 
                    in FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import createFeeCreationData from '@salesforce/apex/FeeCreationComponentHelper.createFeeCreationRecords';
import getFeeCreationData from '@salesforce/apex/FeeCreationComponentHelper.getFeeCreationRecords';
import addRow from '@salesforce/apex/FeeCreationComponentHelper.addRow';
import saveRecords from '@salesforce/apex/FeeCreationComponentHelper.saveRecords';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FEE_CREATION_OBJECT from '@salesforce/schema/Fee_Creation__c';
import REPAYMENT_TYPE_FIELD from '@salesforce/schema/Fee_Creation__c.Repayment_Type_2__c';
//import APPLICABLE_ON_FIELD from '@salesforce/schema/Fee_Creation__c.Applicable_on_Loan_Amount_Asset_Value__c';
import FEE_CODE_FIELD from '@salesforce/schema/Fee_Creation__c.Fee_Code__c';
//import STAGE_DUE_FIELD from '@salesforce/schema/Fee_Creation__c.Stage_Due__c';
import getRepaymentPicklist_2 from '@salesforce/apex/FeeCreationComponentHelper.getRepaymentPicklist_2';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';
import getFeeCodeFromMaster from '@salesforce/apex/FeeCreationComponentHelper.getFeeCodeFromMaster';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import getLoanApplicant from '@salesforce/apex/FeeCreationTypeInsuranceNewController.getLoanApplicant';
import repaymentTypeFromMaster from '@salesforce/apex/FeeCreationComponentHelper.repaymentTypeFromMaster';
import calculationUserFee from '@salesforce/apex/FeeCreationComponentHelper.calculationUserFee';
import taxLabel from '@salesforce/label/c.Tax';
export default class FeeCreationScreen extends LightningElement {

@api recordId;
@api stageName;
@track feeCreation = [];
@track lstOptions = [];
@api allValues = [];
@api allValues1 = [];
@api options = [];
@api feeCodeOptions = [];
@api existingFeeCodeOption = [];
@track removeRow;
@track pickValue;
@track stageDue;
@track applicableOn;
@track accountList = [];
@track index = 0;
@track repaymentChange = false;
@track size;
@track data = [];
@track feeCode = [];
@track saveRecordsBtn = true;
@track rowNoChanged;
@track feeType = 'none';
@track feeAmount;
@track taxAmount;
@track totalFee;
@track removeFeeCode = [];
@track isSave = false;
@track isAmount = false;
@track feeList = true;
@track isLoaded = false;
@track feeCodeMap = new Map();
@track masterMap = new Map();
@track valueMasterMap = new Map();
@track stageMap = new Map();
@track applicantOption = [];
@track assetOption = [];
@track isApplicantAsset = false;
@track repaymentFeeMap = new Map();
@track repaymentList = [];
@track repayment = true; //if repayment type is not blank
@track isFeeAmount = false; //if fee amount is null for new row
@track reapymentErrorForMaster = true; //selected repayment is available in master
@track repaymentFeeMapIfChanged = new Map(); //Map of fee id and true/false repayment changed or not
//taxPercent = 18;
taxPercent = parseFloat(taxLabel);
connectedCallback() {
    console.log('In connected call back of fee Details');
    setTimeout(() => {
        console.log('this.application ID ', this.recordId);
        if (this.recordId != undefined) {
            this.isLoaded = true;
            // Get Insurance Records
            
            this.createFeeCreationData();
        }
        console.log('stageName in fee Details section', this.stageName);


    }, 300);
    
}
optionsValue() {
    let feeCodePass;
    let resultCreated = JSON.parse(JSON.stringify(this.data));

    for (let key in this.feeCode) {
        feeCodePass = this.feeCode[key];
        feeCodePass = resultCreated[i].Fee_Code__c;
        console.log('fee code of result is ' + feeCodePass);
        this.lstOptions = [];
        getRepaymentPicklist_2({ feeCode: feeCodePass })
            .then(data => {
                var repayment = data.values;
                console.log('repayment list' + JSON.stringify(data));
                for (let key in data) {
                    console.log('key' + key + data[key]);
                    repayment = data[key];
                    console.log('repayment is' + repayment);
                    this.lstOptions.push({ label: repayment, value: repayment });
                    this.lstOptions = [... this.lstOptions, { key: repayment, value: repayment }];
                    console.log('map data' + JSON.stringify(this.lstOptions));
                }
                //  addressArray = [... addressArray, {key : this.feeCreation[key].repaymentType[data] , value : this.feeCreation[key].repaymentType[data]}];

            })
            .catch(error => {
                console.log('error in repayment' + JSON.stringify(error));
            })
    }
}
/* renderedCallback(){
    getRecordNotifyChange([{recordId: this.recordId}]);
            getFeeCreationData({ applicationId: this.recordId })
            .then(dataGet => {
                console.log('get fee from creation',dataGet);
                this.feeCreation = JSON.parse(dataGet);
                //  console.log('data##' + data);
                // this.refreshData();

            })
            .catch(error => {
                this.error = error;
                console.log('ERRRRRRRRRRRR  ', this.error);
                this.feeCreation = undefined;
            })
        // }
        console.log('feecreation records are',this.feeCreation);
    this.refreshData();
}*/


// Get Fee creration Object Info.
@wire(getObjectInfo, { objectApiName: FEE_CREATION_OBJECT })
feecreationObjectInfo;

// Get Repayment Type  Picklist values.
/*@wire(getPicklistValues, { recordTypeId: '$feecreationObjectInfo.data.defaultRecordTypeId', fieldApiName: REPAYMENT_TYPE_FIELD })
prepaymentMultiPicklist({ error, data }) {
    if (data) {
        this.lstOptions = data.values;
    } else if (error) {
        console.log('ERROR IN PICKLIST  ', error);
    }
};

@wire(getPicklistValues, { recordTypeId: '$feecreationObjectInfo.data.defaultRecordTypeId', fieldApiName: APPLICABLE_ON_FIELD })
setPicklistOptions({ error, data }) {
    if (data) {
        this.options = data.values;
    } else if (error) {
        console.log(error);
    }
}*/

/*   @wire(getPicklistValues, { recordTypeId: '$feecreationObjectInfo.data.defaultRecordTypeId', fieldApiName: FEE_CODE_FIELD })
setFeeCodePicklistOptions({ error, data }) {
    if (data) {
        this.feeCodeOptions = data.values;
        console.log('FEE CODE  ', this.feeCodeOptions);
    } else if (error) {
        console.log(error);
    }
}*/

// @wire(getPicklistValues, { recordTypeId: '$feecreationObjectInfo.data.defaultRecordTypeId', fieldApiName: STAGE_DUE_FIELD })
//  setStageDuePicklistOptions({error, data}) {
//    if (data) {
//      this.stageDueOptions = data.values;
//      console.log('FEE CODE  ',this.feeCodeOptions);
//    } else if (error) {
//      console.log(error);
//    }
// }

handlechange(event) {
    let updatedFeeCreation = [];
    updatedFeeCreation = this.feeCreation;
    for (let key in updatedFeeCreation) {
        var reyPaymentPicklist = [];
        var addressArray = [];
        if (updatedFeeCreation[key].sRNumnber == event.target.id.split('-')[0]) {
            try {
                for (let index in updatedFeeCreation[key].repaymentType) {
                    reyPaymentPicklist.push(updatedFeeCreation[key].repaymentType[index].value);
                }
                if (!reyPaymentPicklist.includes(event.target.value)) {
                    reyPaymentPicklist.push(event.target.value);
                }
                if (reyPaymentPicklist.length > 0) {
                    for (let data in reyPaymentPicklist) {
                        addressArray = [...addressArray, { key: reyPaymentPicklist[data], value: reyPaymentPicklist[data] }];
                    }
                }
            }
            catch (error) {
                console.log('ERRRORRRRR  ', error);
            }
            updatedFeeCreation[key].repaymentType = addressArray;
        }
        this.feeCreation = [...updatedFeeCreation];
        console.log('FINAL  111111  ', this.feeCreation);
    }
}

handleRemove(event) {
}

/*@wire(createFeeCreationData, { applicationId: '$recordId' , eventName : 'Application Login', propertyId : null})
wiredFeeCreation({ data, error }) {
    if (data) {
        this.isLoaded = true;
        //console.log('DATA11111   ',data);
        console.log('create fee from creation',data);
        // this.feeCodeValuesAre();
        // let result = JSON.parse(JSON.stringify(data));
        this.feeCreation = data;
        console.log('this.feeCreation updated to',this.feeCreation);
        //     this.optionsValue();
        console.log('and records get lenght is',data.length, this.feeCreation);
        this.getApplicantAset();
        // if(data.length == 0){
        getRecordNotifyChange([{recordId: this.recordId}]);
        this.getFeeCreationRecords();
            /*  getFeeCreationData({ applicationId: this.recordId })
            .then(dataGet => {
                console.log('get fee from creation',dataGet);
                this.feeCreation = JSON.parse(dataGet);
                //  console.log('data##' + data);
                // this.refreshData();

            })
            .catch(error => {
                this.error = error;
                console.log('ERRRRRRRRRRRR  ', this.error);
                this.feeCreation = undefined;
            })*/
        // }
    /*    console.log('feecreation records are',this.feeCreation);
    this.refreshData();
    this.isLoaded = false;
    }
    else if (error) {
        this.error = error;
        console.log('ERRRRRRRRRRRR  ', this.error);
    }
    
    //  this.feeCreation = this.data;
    
}*/

// to remove future method 
createFeeCreationData(){
    createFeeCreationData({applicationId: this.recordId , eventName : 'Application Login', propertyId : null})
    .then(data => {
        if (data) {
            //this.isLoaded = true;
            
            console.log('create fee from creation',data);
            
            //this.feeCreation = JSON.parse(JSON.stringify(data));
            //console.log('this.feeCreation updated to',this.feeCreation);
            
            console.log('and records get lenght is',data.length, this.feeCreation);
            this.getApplicantAset();
            
            //getRecordNotifyChange([{recordId: this.recordId}]);
            this.getFeeCreationRecords();
               
            console.log('feecreation records are',this.feeCreation);
            //this.refreshData();
           // this.isLoaded = false;
        }
        
        

    })
    .catch(error => {
        if (error) {
            this.error = error;
            console.log('ERRRRRRRRRRRR  ', this.error);
        }
    })
}



//-----------------------------
getApplicantAset() {
    this.applicantSelect('Applicant');
    this.applicantSelect('Asset');
}
applicantSelect(applicableFor) {
    this.applicantOption = [];
    this.assetOption = [];
    console.log('applicable on from prev data', applicableFor);
    getLoanApplicant({ applicationId: this.recordId, applicableFor: applicableFor })
        .then(result => {
            console.log('result from applicable on change', result);

            for (let key in result) {
                console.log('Key', key);
                    console.log('result', result[key]);

                const applicant = {
                    label: result[key],
                    value: key
                }; //console.log('result');
                if (applicableFor == 'Applicant') {
                    // this.applicantOption.push(applicant);
                    ///  this.applicantOption = [... this.applicantOption, { key: applicant.label, value: applicant.value }];
                    //this.applicantOption.push({ label: result[key], value: key });
                    this.applicantOption = [... this.applicantOption, applicant];
                }
                else if (applicableFor == 'Asset') {
                    //  this.assetOption.push(applicant);
                    //   this.assetOption = [... this.assetOption, { key: applicant.label, value: applicant.value }];
                //  this.assetOption.push({ label: result[key], value: key });
                    this.assetOption = [... this.assetOption, applicant];
                }

            }
            console.log('applicant and asset options', this.applicantOption, this.assetOption);
        })
        .catch(error => {
            console.log('error from applicable on change in pc', error);
        })
}
applicableForSelectChange(event){
    console.log('applicable for select value', event.target.value);
    var sRNumber = event.target.id.split('-')[0];
    console.log('row no is', sRNumber);
    if(this.feeCreation[sRNumber-1].applicableFor == 'Asset'){
        var selectedOption = this.assetOption.filter(function (option) {
            return option.value == event.target.value;
        })
        this.feeCreation[sRNumber-1].property = event.target.value;
        console.log('selected property', this.feeCreation[sRNumber-1].property);
        this.feeCreation[sRNumber-1].applicantAssetId = event.target.value;
        this.calculationUserFee(sRNumber-1, this.feeCreation[sRNumber-1].applicantAssetId);
    }
    else if(this.feeCreation[sRNumber-1].applicableFor == 'Applicant'){
        var selectedOption = this.applicantOption.filter(function (option) {
            return option.value == event.target.value;
        })
        this.feeCreation[sRNumber-1].loanApplicant = event.target.value;
        console.log('selected property', this.feeCreation[sRNumber-1].loanApplicant);
        this.feeCreation[sRNumber-1].applicantAssetId = event.target.value;
        this.calculationUserFee(sRNumber-1, null);
    }

    // console.log('applicant', selectedOption, selectedOption[0].label);

    //  this.data[rowNo].applicantOrAssetName = selectedOption[0].label;
    
}

@api getFeeCreationRecords() {
    this.feeCreation = undefined;
    this.existingFeeCodeOption = [];
    //this.applicantOption = [];
    this.feeCodeValuesAre();
    this.getRepaymentMap();
    this.isSave = false;
    this.saveRecordsBtn = false;
    //this.getApplicantAset();
    getFeeCreationData({ applicationId: this.recordId })
        .then(dataGet => {
            console.log('get fee from creation', dataGet);
            this.feeCreation = JSON.parse(dataGet);
            var refresh = new CustomEvent("getrefreshfee", {
                detail: (this.feeCreation && this.feeCreation.length)?true:false,
                bubbles: true,
                composed: true
            });
            console.log('dispatch receiptEvent ', JSON.stringify(refresh));
            this.dispatchEvent(refresh);
            this.isLoaded = false;
        })
        .catch(error => {
            this.error = error;
            console.log('ERRRRRRRRRRRR  ', this.error);
            this.feeCreation = undefined;
            this.isLoaded = false;
        })
}

feeCodeValuesAre(){
    console.log('this.existingFeeCodeOption',this.existingFeeCodeOption);
    this.existingFeeCodeOption = [];
    getFeeCodeFromMaster({applicationId : this.recordId})
    .then(resultCode=>{
        console.log('fee code result is', resultCode);
        this.existingFeeCodeOption = [];
        for (let key in resultCode) {
            console.log('Key', key);
            
            console.log('resultCode', resultCode[key].feeValue.Description__c);
            // for add description from FVM : 22-11-22
           /* const feeCodeList = {
                label: resultCode[key].Fee_Type_Code__c,
                value: resultCode[key].Fee_Type_Code__c
            };*/
            const feeCodeList = {
                label: resultCode[key].feeValue.Description__c,
                //value: resultCode[key].feeMasterFeeCode
                value: resultCode[key].feeValueId
            };
            this.existingFeeCodeOption = [...this.existingFeeCodeOption, feeCodeList];
            //this.feeCodeMap.set(resultCode[key].Fee_Type_Code__c, resultCode[key].Applicable_For__c);
            //this.stageMap.set(resultCode[key].Fee_Type_Code__c, resultCode[key].Stage_Due__c);

            this.feeCodeMap.set(resultCode[key].feeValueId, resultCode[key].feeTypeFromMaster.Applicable_For__c);
            this.stageMap.set(resultCode[key].feeValueId, resultCode[key].feeTypeFromMaster.Stage_Due__c);
            this.masterMap.set(resultCode[key].feeValueId, resultCode[key].feeTypeFromMaster);
            this.valueMasterMap.set(resultCode[key].feeValueId, resultCode[key].feeValue);
           // this.valueMasterMap.set(resultCode[key].feeMasterFeeCode, resultCode[key].feeValue);
            //console.log('dev code applicable for',this.feeCodeMap);
        }
        console.log('dev code applicable for',this.feeCodeMap);
    })
    .catch(error=>{
        console.log('error in fee code',error);
    })
}

// this.isLoaded = true;
// window.setTimeout(() => { this.isLoaded = false;}, 1300);



/*   @wire(getFeeCreationData, {applicationId:'$recordId'})
    wiredGetFeeCreation({ data, error }){
        if(data){
            this.feeCreation = JSON.parse(data);
            console.log('data##' + data)
            this.refreshData();
        //     this.optionsValue();
        //     for(let key in this.feeCreation) {
        //         let addressArray = []
        //         for(let data in this.feeCreation[key].repaymentType) {
                    
        //             addressArray = [... addressArray, {key : this.feeCreation[key].repaymentType[data] , value : this.feeCreation[key].repaymentType[data]}];
        //         }
        //         this.feeCreation[key].repaymentType =addressArray ;
        //     }            
        }
        else if (error) {
            this.error = error;
            console.log('ERRRRRRRRRRRR  ',this.error);
            this.feeCreation = undefined;
        }
        
    }*/
refreshData() {
    console.log('data refreshed',JSON.stringify(this.feeCreation));
    return refreshApex(this.feeCreation);
}

actionClose() {
    this.dispatchEvent(new CloseActionScreenEvent());
}
saveRecords(){
    console.log('to save records');
    // For Unique fee creation based on Fee code and Applicant or Asset
    var isDublicate = false;  
    var duplicateFee = [];
    console.log('fee creation length to save', this.feeCreation.length);
    for(var allFee = 0; allFee < this.feeCreation.length - 1; allFee++){
            //  if(this.feeCreation[allFee].isnewRow == true){
                var feeRecord = this.feeCreation[allFee];
               // console.log('duplicateFee',duplicateFee);
               // if(feeRecord.applicantAssetId !== null || feeRecord.applicantAssetId !== ''){
                    var ubiqueId = this.recordId + '-' + feeRecord.feeCode + '-' + feeRecord.type + '-' + feeRecord.masterId  + '-' + feeRecord.applicantAssetId;
                    duplicateFee.push(ubiqueId);

        


    }
               /* else{
                    var ubiqueId = this.recordId + '-' + feeRecord.feeCode + '-' + feeRecord.type;
                }*/
                var allFee = this.feeCreation.length - 1;
                var feeRecord = this.feeCreation[allFee];
                console.log('duplicateFee',duplicateFee);
                if(feeRecord.isnewRow == true){
                    console.log('feeRecord.applicantAssetId',feeRecord.applicantAssetId);
                    if(feeRecord.applicantAssetId){
                    var ubiqueId = this.recordId + '-' + feeRecord.feeCode + '-' + feeRecord.type + '-' + feeRecord.masterId  + '-' + feeRecord.applicantAssetId;
                    }
                    else{
                        var ubiqueId = this.recordId + '-' + feeRecord.feeCode + '-' + feeRecord.type + '-' + feeRecord.masterId  + '-' + 'null';
                    }
                    console.log('@@## ubiqueId ', ubiqueId, duplicateFee.indexOf(ubiqueId), duplicateFee);
                    
                    if(duplicateFee.indexOf(ubiqueId) === -1){
                        duplicateFee.push(ubiqueId);
                    }else if(duplicateFee.indexOf(ubiqueId) >= 0){
                        // this.isError = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Please Remove Duplidate Fee.',
                                variant: 'error'
                            })
                        );
                        isDublicate = true;
                        this.isSave = true;
                        this.feeList = true;
                    //   }
                }
                }
                
                
      //  }
    if(isDublicate == false){
        console.log('length for save', this.feeCreation.length - 1);
        for(var allFee = 0; allFee <= this.feeCreation.length - 1; allFee++){
            console.log('check repayment');
            //  if(this.feeCreation[allFee].isnewRow == true){
                //To add FVM description: 24/11/22

                
                var feeRecord = this.feeCreation[allFee];
                console.log('repayment value', feeRecord.repaymentType, 'allFee',allFee);
               // console.log('duplicateFee',duplicateFee);
                var repaymentType = feeRecord.repaymentType;
                if(feeRecord.repaymentType != undefined && feeRecord.repaymentType !== null && feeRecord.repaymentType !== ''){
                    this.repayment = true; 
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please Select Repayment Type.',
                            variant: 'error'
                        })
                    );
                    
                    this.isSave = true;
                    this.feeList = true;
                    this.repayment = false; 
                    break;
                }
               // if(this.feeCreation[sRNumber-1].feeAmount)
               // for feeAmount validation
              // if(feeRecord.isnewRow == true){
                    if(feeRecord.feeAmount > 0 && feeRecord.feeAmount !== null && feeRecord.feeAmount !== ''){
                        this.isFeeAmount = true; 
                    }
                    else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Fee Amount can not be blank.',
                                variant: 'error'
                            })
                        );
                
                        this.isSave = true;
                        this.feeList = true;
                        this.isFeeAmount = false; 
                        break;
                    }
              //  }
               //------------------------------
               //this.feeCreation[allFee].description = this.valueMasterMap.get(this.feeCreation[allFee].masterId).Description__c;
            }
            console.log('feeRecord.repaymentFromMaster', this.feeCreation.length - 1);

            //for repayment validation if master changed: 30 Nov 22
            for(var allFeeRepayment = 0 ; allFeeRepayment < this.feeCreation.length ; allFeeRepayment++) {
                
                //  if(this.feeCreation[allFee].isnewRow == true){
                    var feeRecordRepayment = this.feeCreation[allFeeRepayment];
                    console.log('feeRecord.repaymentFromMaster', feeRecordRepayment.repaymentFromMaster);
                    console.log('repaymentFeeMapIfChanged', this.repaymentFeeMapIfChanged.has(feeRecordRepayment.Id));
        if(feeRecordRepayment.repaymentFromMaster == false && this.repaymentFeeMapIfChanged.has(feeRecordRepayment.Id) && this.repaymentFeeMapIfChanged.get(feeRecordRepayment.Id) == true){
            console.log('repayment not avaliable in FTM', feeRecordRepayment.repaymentType);
            
            if(feeRecordRepayment.feeRepayment === feeRecordRepayment.repaymentType){
                console.log('repayment not avaliable in FTM selected');
                this.reapymentErrorForMaster = false;
                console.log('this.reapymentErrorForMaster',this.reapymentErrorForMaster);
               // feeRecord.repaymentType = this.feeCreation[this.rowNoChanged - 1].feeRepayment;
                
                

            }
            else{
              //  this.feeCreation[this.rowNoChanged - 1].repaymentType = event.target.value;
              //  console.log('this.feeCreation[this.rowNoChanged - 1].repaymentType', this.feeCreation[this.rowNoChanged - 1].repaymentType);
                this.reapymentErrorForMaster = true;
            }
        }
        else{
            //  this.feeCreation[this.rowNoChanged - 1].repaymentType = event.target.value;
            //  console.log('this.feeCreation[this.rowNoChanged - 1].repaymentType', this.feeCreation[this.rowNoChanged - 1].repaymentType);
              this.reapymentErrorForMaster = true;
          }
        if(this.reapymentErrorForMaster == false){
            console.log('this.reapymentErrorForMaster', this.reapymentErrorForMaster);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Selected Repayment value for fee name '+ feeRecordRepayment.description +' is depriciated value from Master. Please select different value or contact your System admin',
                    variant: 'error'
                })
            );
           
            this.isSave = true;
            this.feeList = true;
           // this.template.querySelector('.feeCreationFooter').className = ('feeCreationFooter');
            break;
        }
    }
        //---------------------------------------------------------------------
//-------------------------------------
    if(this.repayment == true && this.isFeeAmount == true && this.reapymentErrorForMaster == true){
        console.log('save record in fee');
        
    saveRecords({
            wrapperData: JSON.stringify(this.feeCreation),
            applicationId: this.recordId
        })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record  Created/Update  Sucessfully.',
                        variant: 'success'
                    })
                );
                // window.location.reload();
                
                //this.feeCodeValuesAre();
                this.getFeeCreationRecords();
            /*    getFeeCreationData({ applicationId: this.recordId })
            .then(dataGet => {
                console.log('get fee from creation',dataGet);
                this.feeCreation = JSON.parse(dataGet);
                //  console.log('data##' + data);
                // this.refreshData();

            })
            .catch(error => {
                this.error = error;
                console.log('ERRRRRRRRRRRR  ', JSON.stringify(this.error));
                this.feeCreation = undefined;
            })*/
                this.feeList = true;
                console.log('before dispatch event');
                var feeEvent = new CustomEvent("getfeechangeevent", {
                detail: 'this.feeList',
                bubbles: true,
                composed: true
            });
            console.log('dispatch receiptEvent ', JSON.stringify(feeEvent));
            this.dispatchEvent(feeEvent);
            }).catch(error => {
                this.error = error;
                console.log('ERRRRRRRRRRRR  ', JSON.stringify(this.error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        // message: this.error.body,
                        message: JSON.stringify(this.error),
                        variant: 'error'
                    })
                );
            });}}
}

handleSave() {
    this.feeList = false;
    this.repaymentChange = false;

    // console.log('testtttttttttt');
    // for(let index in this.feeCreation) {
    //     let  prePaymentArray = [];
    //      for(let key in  this.feeCreation[index].repaymentType) {
    //          prePaymentArray.push(this.feeCreation[index].repaymentType[key].key);
    //      }
    //      this.feeCreation[index].repaymentType = prePaymentArray;
    //      console.log('OBJECTTTTTT  ', this.feeCreation[index].repaymentType);
    //  }
    //  for (let i = 0; i < this.feeCreation.length; i++) {
    //      console.log('srNumber######' + this.feeCreation[i].sRNumnber + 'and fee code'+this.feeCreation[i].feeCode);
    console.log('handle save called',this.feeType);
    if(this.isAmount == true && this.feeType == 'none' && this.isSave == false){
        console.log('this.isAmount in save',this.isAmount);
        //Validate Applicant/Asset
        //this.validateApplicantAsset();
        if(this.isApplicantAsset == false){
            this.saveRecords();
        }  
    }
    this.isSave = false;
    this.isAmount = false;
    /*if(this.isAmount == true && this.feeType == 'none'){
        console.log('this.isAmount in save',this.isAmount);
        //  this.saveRecords();
    }*/
    //console.log(this.template.querySelector('.td-currency-fee').getAttribute('selected') ) ;
    if (this.feeType != 'none' && this.feeType == 'System') {
        console.log('in fee repayment changed save',this.feetype);
        if(this.feeCreation[this.feeCreation.length - 1].feeCode == null || this.feeCreation[this.feeCreation.length - 1].feeCode == ''){
            console.log('fill fee code');
            this.saveRecordsBtn = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Fee Code in new row.',
                    variant: 'error'
                })
            );
            this.isSave = true;
            this.feeList = true;
        }
        else {
            
            console.log('only save records');
            //check applicant and asset
            this.validateApplicantAsset();
            if(this.isApplicantAsset == false){
                this.saveRecords();
            }
            else{
                this.isApplicantAsset = false;
            }
        }
        

        
    }
    else if(this.feeType == 'none' && this.feeType != 'System'){
        let combobox = this.template.querySelector("[data-id='Controlling Picklist Type']");
        console.log('fee code combobox is' + combobox.value);
        if (combobox.value == null || combobox.value == '') {
            console.log('fee code is null' + this.saveRecordsBtn);
            this.saveRecordsBtn = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Fee Code.',
                    variant: 'error'
                })
            );
            this.isSave = true;
            this.feeList = true;
            // this.template.querySelector('.td-currency-fee').className = ('.td-currency-fee.error');
            // combobox.className = ('td-currency-fee error');
            // console.log('class name',combobox.className);

        }

        //  }

        
        else if (combobox.value != null) {
            console.log('save record', this.saveRecordsBtn);
            //Validate Applicant/Asset
            this.validateApplicantAsset();
            if(this.isApplicantAsset == false){
                this.saveRecords();
            }
            else{
                this.isApplicantAsset = false;
            }
            
        }
    }
    
    this.isAmount = false;
    this.template.querySelector('.feeCreationFooter').className = ('feeCreationFooter visible');
    console.log('EXITTTTTTTTTTT++++++');
    // this.feeList = true;

}

//Check if applicant/asset is not null
validateApplicantAsset(){
    console.log('validateApplicantAsset called');
    if(this.feeCreation[this.feeCreation.length - 1].isnewRow == true){
        if(this.feeCreation[this.feeCreation.length - 1].applicableFor == 'Applicant' || this.feeCreation[this.feeCreation.length - 1].applicableFor == 'Asset'){
            if(this.feeCreation[this.feeCreation.length - 1].applicantAssetId == null || this.feeCreation[this.feeCreation.length - 1].applicantAssetId == ''){
                console.log('please select Applicant/Asset');
                this.saveRecordsBtn = false;
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Applicant/Asset.',
                    variant: 'error'
                })
            );
            this.isApplicantAsset = true;
            this.isSave = true;
            this.feeList = true;
            }
        }
    }
}

selectapplicant(event){
    this.validateApplicantAsset();
}
updateAmount(event){
    console.log('update amount');
    var sRNumber = event.target.id.split('-')[0];
    
    var value = event.target.value;
    console.log(value);
    var name = event.target.name;
    console.log(name);
    
    if(this.isApplicantAsset == false){
    if (name == 'feeAmount'){
        this.feeAmount = parseFloat(value);
        this.feeCreation[sRNumber-1].feeAmount = this.feeAmount;
        console.log('feeamount',this.feeAmount);
        //To make tax amount non editable
        this.taxAmount = parseFloat(this.feeAmount * this.taxPercent * .01).toFixed(2);
    }
    /*  else if(name == 'taxAmount'){
        this.taxAmount = parseFloat(value);
        this.feeCreation[sRNumber-1].taxAmount = this.taxAmount;
        console.log('taxamount',this.taxAmount);
    }*/
    else if(name == 'feeAmountGet') {
        this.isAmount = true;
        this.feeAmount = parseFloat(value);
        this.feeCreation[sRNumber-1].feeAmount = this.feeAmount;
        console.log('feeamountGet',this.feeAmount);
        //this.taxAmount = this.feeCreation[sRNumber-1].taxAmount;
        this.taxAmount = parseFloat(this.feeAmount * this.taxPercent * .01).toFixed(2);
        this.handleValueChange();
    } 
    //added for total fee to be editable if tax from master is inclusive: 22-Nov-22
    else if(name == 'feeAmountGetTotal')  {
        this.isAmount = true;
        this.totalFee = parseFloat(value);
        //this.feeCreation[sRNumber-1].totalFee = Math.round(this.totalFee);
        //13 march 2023
        //for total fee not to be roundoff if user changes the value
        this.feeCreation[sRNumber-1].totalFee = this.totalFee;
        console.log('feeamountGetTotal',this.totalFee);
        //this.taxAmount = this.feeCreation[sRNumber-1].taxAmount;
        //this.taxAmount = parseFloat(this.feeAmount * this.taxPercent * .01).toFixed(2);
        if(this.feeCreation[sRNumber-1].tax == 'No'){	
            this.feeAmount = this.totalFee;	
            this.feeCreation[sRNumber-1].feeAmount = (parseFloat(this.feeAmount)).toFixed(2);	
        }	
        if(this.feeCreation[sRNumber-1].tax == 'Inclusive'){
        let divideBy = (1 + (this.taxPercent * .01));
        this.feeAmount = this.totalFee/divideBy ;
        this.feeCreation[sRNumber-1].feeAmount = (parseFloat(this.feeAmount)).toFixed(2);
        this.taxAmount = this.feeCreation[sRNumber-1].totalFee - this.feeCreation[sRNumber-1].feeAmount;
        this.feeCreation[sRNumber-1].taxAmount = (parseFloat(this.taxAmount)).toFixed(2);
        }
        this.handleValueChange();
    }   
    //-------------------------------------     
    console.log(this.feeAmount,this.taxAmount );
    if((name == 'feeAmountGet' || name == 'feeAmount') && this.feeAmount != null && this.taxAmount != null){
        console.log(this.feeAmount,this.taxAmount );
        //To make tax non editable
        this.feeCreation[sRNumber-1].taxAmount = this.taxAmount;
        this.feeCreation[sRNumber-1].totalFee = (parseFloat(this.feeAmount) + parseFloat(this.taxAmount)).toFixed(2);
        //Round off total fee as per discussion with QA
    this.feeCreation[sRNumber-1].totalFee = Math.round(this.feeCreation[sRNumber-1].totalFee);
        console.log('this.feeCreation[sRNumber-1].totalFee',this.feeCreation[sRNumber-1].totalFee, this.feeType);
        //  this.feeCreation[sRNumber-1].feeCollection = this.feeCreation[sRNumber-1].totalFee;
        this.feeCreation[sRNumber-1].feeCollection = 0;
    }
    for (let record in this.feeCreation) {
        for (let key in this.feeCreation[record]) {
            if (key == name && this.feeCreation[record].sRNumnber == sRNumber) {
                this.feeCreation[record][key] = value;
            }
        }
    }
}
    //  this.refreshData();
}
/*  updateFeeValue(event){
    let sRNumber = event.target.id.split('-')[0];
    console.log('SR NUM ###' + sRNumber);
    let value = event.target.value;
    console.log('Value##' + value);
    let name = event.target.name;
    this.feeCreation[sRNumber-1].feeCode = event.target.value;
    this.updateValue(event);
}*/

async updateValue(event) {
    //    this.isLoaded = true;
    let sRNumber = event.target.id.split('-')[0];
    console.log('SR NUM only value update###' + sRNumber);
    let feeValueId = event.target.value;
    console.log('resultCode[key].feeMasterFeeCode in update value', feeValueId);
    //console.log('Value##' + JSON.stringify(value));
    let name = event.target.name;
    var value = feeValueId;
    //modifiable
    //feeAmountModify
    //totalFeeModify
    console.log('Name##' + name);
    for (let i = 0; i < this.feeCreation.length; i++) {
        console.log('srNumber######' + this.feeCreation[i].sRNumnber);
        if (this.feeCreation[i].sRNumnber == sRNumber) {
            if (name == 'feeCode'){
            if(this.masterMap != null){
            console.log('this.masterMap.master.tax', this.masterMap.get(feeValueId).Tax__c, this.masterMap.get(feeValueId).Modifiable_at_run_Time__c);
            //this.feeCreation[i].modifiable = this.masterMap.get(feeValueId).Modifiable_at_run_Time__c;
            console.log('is modify', this.feeCreation[i].modifiable);
            if(this.masterMap.get(feeValueId).Modifiable_at_run_Time__c == 'Yes'){
                this.feeCreation[i].modifiable = true;
                this.feeCreation[i].tax = this.masterMap.get(feeValueId).Tax__c;
                if(this.masterMap.get(feeValueId).Tax__c == 'Inclusive'){
                    this.feeCreation[i].totalFeeModify = true;
                    this.feeCreation[i].feeAmountModify = false;
                }
                else if(this.masterMap.get(feeValueId).Tax__c == 'Exclusive'){
                    this.feeCreation[i].feeAmountModify = true;
                    this.feeCreation[i].totalFeeModify = false;
                }
                else if(this.masterMap.get(feeValueId).Tax__c == 'No'){	
                    this.feeCreation[i].totalFeeModify = true;	
                    this.feeCreation[i].feeAmountModify = false;	
                }
                console.log('fee amount total fee', this.feeCreation[i].totalFeeModify, this.feeCreation[i].feeAmountModify);

            }
            else{
                this.feeCreation[i].modifiable = false;
                
                    this.feeCreation[i].totalFeeModify = false;
                    this.feeCreation[i].feeAmountModify = false;
               
                    
                
                console.log('fee amount total fee', this.feeCreation[i].totalFeeModify, this.feeCreation[i].feeAmountModify);
            }
            value = this.masterMap.get(feeValueId).Fee_Type_Code__c;
            this.feeCreation[i].applicableFor = this.feeCodeMap.get(event.target.value);
            this.feeCreation[i].stage = this.stageMap.get(event.target.value);
           // this.feeCreation[i].description = this.valueMasterMap.get(feeValueId).Description__c;
           this.feeCreation[i].description = event.target.value;
           console.log('this.feeCreation[i].description', this.feeCreation[i].description);
            this.feeCreation[i].masterId = feeValueId;
            console.log('applicable for for fee', this.feeCreation[i].applicableFor, this.feeCreation[i].stage);
            if(this.feeCreation[i].applicableFor != null && this.feeCreation[i].applicableFor !=''){
                this.feeCreation[i].loanApplicant = '';
                this.feeCreation[i].property = '';
                this.feeCreation[i].applicantAssetId = '';
                if(this.feeCreation[i].applicableFor == 'Application'){
                    this.feeCreation[i].isApplication = true;
                    this.feeCreation[i].isApplicant = false;
                    this.feeCreation[i].isAsset = false;
                    //To calculate fee from master : 24-11-22
                    this.calculationUserFee(i, null);
                    
                }
                else if(this.feeCreation[i].applicableFor == 'Applicant'){
                    this.feeCreation[i].isApplicant = true;
                    this.feeCreation[i].isApplication = false;
                    this.feeCreation[i].isAsset = false;
                    
                }
                else if(this.feeCreation[i].applicableFor == 'Asset'){
                    this.feeCreation[i].isAsset = true;
                    this.feeCreation[i].isApplication = false;
                    this.feeCreation[i].isApplicant = false;
                }
            }
            this.feeCreation[i].repaymentType = '';
            //set repayment based on selected fee code
            //repayment list of new row
        if(this.repaymentFeeMap != null && this.repaymentFeeMap.size > 0){
            this.repaymentList = [];
            //var repaymentKey = event.target.value;
            var repaymentKey = this.masterMap.get(feeValueId).Fee_Type_Code__c;
           /* for (var key in this.repaymentFeeMap.get(repaymentKey)) {
                console.log('in repayment list set for loop for vs 2', key, this.repaymentFeeMap.get(repaymentKey), typeof this.repaymentFeeMap.get(repaymentKey));
                
                const approval = {
                    label: this.repaymentFeeMap.get(repaymentKey)[key],
                    value: this.repaymentFeeMap.get(repaymentKey)[key]
                };
                this.repaymentList = [...this.repaymentList, approval];
            }*/

            try{
                console.log('repaymentKey',repaymentKey);
                console.log('this.repaymentFeeMap.get(repaymentKey)', this.repaymentFeeMap.get(repaymentKey));
            for (var k = 0; k < this.repaymentFeeMap.get(repaymentKey).length; k++) {
               // console.log('in repayment list set for loop for vs 2', key, this.repaymentFeeMap.get(i), typeof this.repaymentFeeMap.get(i));
               console.log('this.repaymentFeeMap.get(repaymentKey)[k]',this.repaymentFeeMap.get(repaymentKey)[k]);
               this.repaymentList.push({
                    label: this.repaymentFeeMap.get(repaymentKey)[k],
                    value: this.repaymentFeeMap.get(repaymentKey)[k]
               });
              /*  var approval = {
                    label: this.repaymentFeeMap.get(repaymentKey)[k],
                    value: this.repaymentFeeMap.get(repaymentKey)[k]
                };
                console.log('approval',approval);
               // this.repaymentList = [...this.repaymentList, approval];

               this.repaymentList = approval;*/
                console.log('this.repaymentList',JSON.stringify(this.repaymentList));
            }
            this.feeCreation[i].repaymentDetail = this.repaymentList;
        }
        catch(err){
            console.log('err in try catch', err);
        }
            
        }

    }
        
            }
           /* if (name == 'feeCode' && value == 'Usr-Cersai') {
                this.feeCreation[i].applicableOn = 'Loan Amount';
                //  this.feeCreation[i].repaymentType = 'Direct Receipt';
            } else if (name == 'feeCode' && value == 'Usr-Technical') {
                this.feeCreation[i].applicableOn = 'EMI';
                //  this.feeCreation[i].repaymentType = 'Deduct from Disbursement';
            } else if (name == 'feeCode' && value == 'Usr-LegaL') {
                this.feeCreation[i].applicableOn = 'Asset Value';
                //  this.feeCreation[i].repaymentType = 'Add to Loan Amount';
            } else if (name == 'feeCode' && value == 'Usr-IMD') {
                this.feeCreation[i].applicableOn = 'Asset Value';
                //  this.feeCreation[i].repaymentType = 'Direct Receipt';
            } else if (name == 'feeCode' && value == 'Usr-PRC_FEE_Type') {
                this.feeCreation[i].applicableOn = 'EMI';
                // this.feeCreation[i].repaymentType = 'Add to Loan Amount';
            }*/
            

        }

    }

    for (let record in this.feeCreation) {
        for (let key in this.feeCreation[record]) {
            if (key == name && this.feeCreation[record].sRNumnber == sRNumber) {
                //this.feeCreation[record][key] = value;
                this.feeCreation[record][key] = value;
            }
        }
    }
    console.log('FINAL  0000  ', JSON.stringify(this.feeCreation));
    //     this.isLoaded = false;
    //     window.setTimeout(() => { this.isLoaded = false;}, 1000);
    //this.removeFeeCode.push(event.target.value);
    //console.log(this.removeFeeCode);
}


//Calculate fee for Manual fee : 24/11/22
async calculationUserFee(i, propId){
    var feeAmount;
    var taxAmount;
    var totalFee;
    console.log('applicationId', this.recordId, 'FeeValueId', this.feeCreation[i].masterId, 'propId', propId);
    await calculationUserFee({applicationId : this.recordId, FeeValueId : this.feeCreation[i].masterId, propId : propId})
    .then(result=>{
        console.log('result after manual fee calculation', result);
        if(result != null && result != undefined){
            for(let key in result){
                console.log('key for calculations', key, result[key]);
                feeAmount = parseFloat(result[key].feeAmount).toFixed(2);
                taxAmount = parseFloat(result[key].taxAmount).toFixed(2);
                totalFee = Math.round(parseFloat(result[key].totalFee).toFixed(2));
            }
        }
        this.feeCreation[i].feeAmount = feeAmount;
        this.feeCreation[i].taxAmount = taxAmount;
        this.feeCreation[i].totalFee = totalFee;
        
    })
    .catch(error => {
        console.log('error in manual fee calculation', error);
    })
}

createFeeCreationRecordRow(event) {
    this.isSave = true;
    console.log('before add row',this.feeCreation.length);
    console.log('target is',event.target.name);
    if (event.target.name === 'add') {
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'New row added sucessfully.',
                variant: 'success'
            })
        );

    }      
    this.handleValueChange();
    console.log('YES CALL   ', JSON.stringify(this.feeCreation));
    if (event.target.name === 'remove' && this.repaymentChange === false ) {
        this.isSave = false;
        if(this.isAmount === false){
        console.log('on delete', event.target.name, this.repaymentChange);
        console.log('class name of save',this.template.querySelector('.feeCreationFooter').className);
        this.template.querySelector('.feeCreationFooter').className = ('feeCreationFooter');
        console.log('class name of save',this.template.querySelector('.feeCreationFooter').className);}
    }
    // for(let index in this.feeCreation) {
    //    let  prePaymentArray = [];
    //     for(let key in  this.feeCreation[index].repaymentType) {
    //         prePaymentArray.push(this.feeCreation[index].repaymentType[key].key);
    //     }
    //     this.feeCreation[index].repaymentType = prePaymentArray;
    //     console.log('OBJECTTTTTT  ', this.feeCreation[index].repaymentType);
    // }
    addRow({
        wrapperData: JSON.stringify(this.feeCreation),
        typeOf: event.target.name,
        //valuesOf: event.currentTarget.dataset.id,
        valuesOf: JSON.stringify(this.feeCreation.length),
        stageName: this.stageName
    })
        .then(result => {
            this.feeCreation = JSON.parse(result);
            console.log('add row fee creation' + JSON.stringify(this.feeCreation));
            if (this.feeCreation.feeCode == null || this.feeCreation.feecode == '') {
                this.saveRecordsBtn = false;
            }
            else {
                this.saveRecordsBtn = true;
            }
            // for(let key in this.feeCreation) {
            //     let addressArray = []
            //     for(let data in this.feeCreation[key].repaymentType) {

            //         addressArray = [... addressArray, {key : this.feeCreation[key].repaymentType[data] , value : this.feeCreation[key].repaymentType[data]}];
            //     }
            //     this.feeCreation[key].repaymentType =addressArray ;
            // }

            console.log("RESULTTTTTTTT after add row", this.feeCreation, this.feeCreation.length);
            


        }).catch(error => {
            this.error = error;
            console.log('ERRRRRRRRRRRR  ', this.error);
        });

}
/*@ Author: changes done by Sangeeta*/
/*@ Description: To show save button on repayment change*/
handleValueChange() {
    // event.target.classList.add('visible');

    const adobeButton = this.template.querySelector('.feeCreationFooter').className;
    console.log('adobeButton', JSON.stringify(adobeButton));
    this.template.querySelector('.feeCreationFooter').className = ('feeCreationFooter visible');


}
handleRepaymentValueChange(event) {
    // event.target.classList.add('visible');
    this.repaymentChange = true;
    console.log('handle change', event.target.getAttribute("id").split('-')[0]);
    this.rowNoChanged = event.target.getAttribute("id").split('-')[0];
    this.feeType = this.feeCreation[this.rowNoChanged - 1].type;
    console.log('this.feeType', this.feeType);
    if (this.feeType = 'System') {
        
        
            this.feeCreation[this.rowNoChanged - 1].repaymentType = event.target.value;
            console.log('this.feeCreation[this.rowNoChanged - 1].repaymentType', this.feeCreation[this.rowNoChanged - 1].repaymentType);
            //this.reapymentErrorForMaster = true;
            //Map to check if repayment changed or not
            console.log('this.feeCreation[this.rowNoChanged - 1].Id', this.feeCreation[this.rowNoChanged - 1].Id);
            this.repaymentFeeMapIfChanged.set(this.feeCreation[this.rowNoChanged - 1].Id, true);
    
    }

    this.handleValueChange();


}
//Get Repayment map with fee code based on master
getRepaymentMap(){
    console.log('getRepaymentMap called');
    repaymentTypeFromMaster({feeRecordType : 'Fee'})
        .then(result => {
            console.log('result from get repayment key', JSON.stringify(result));
            for (let key in result) {
                console.log('result from get repayment key', JSON.stringify(result[key]), key);
                this.repaymentFeeMap.set(key, result[key]);
                console.log('result from get user', this.repaymentFeeMap, result[key]);

            }
        })
        .catch(error => {
            console.log('error from get user', JSON.stringify(error));
        })
    }

    
}