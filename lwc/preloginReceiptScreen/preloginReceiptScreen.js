import { LightningElement, api, wire, track } from 'lwc';
import getReceiptData from '@salesforce/apex/FeeReceiptController.getReceiptData';
import getCashiers from '@salesforce/apex/FeeReceiptController.getCashiers';
import submitReceiptForApproval from '@salesforce/apex/FeeReceiptController.submitReceiptForApproval';
import getExistingFeeCodeRec from '@salesforce/apex/FeeReceiptController.getExistingFeeCodeRec';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import updateReceiptFee from '@salesforce/apex/FeeReceiptController.updateReceiptFee';
import getRecFeeRepayment from '@salesforce/apex/FeeReceiptController.getRecFeeRepayment';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';
import getApplicationBranchCode from '@salesforce/apex/FeeReceiptController.getApplicationBranchCode';
import getReceiptFeeStage from '@salesforce/apex/FeeReceiptController.getReceiptFeeStage';
import getApplicationPrimaryApplicantName from '@salesforce/apex/FeeReceiptController.getApplicationPrimaryApplicantName';
import roundRobinByStage from '@salesforce/apex/AllocationHandler.roundRobinByStage';
import pullUserId from '@salesforce/label/c.Pull_Queue_User';
import CASHIER from '@salesforce/schema/Application__c.Cashier__c';
import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import { getRecord } from 'lightning/uiRecordApi';
// Example :- import greeting from '@salesforce/label/c.greeting';

export default class PreloginReceiptScreen extends NavigationMixin(LightningElement) {

    @api applicationId;
    @api preLogInId;
    @api appName;
    @api primaryApplicantName;
    @api existingFeeCodeOption = [];
    @track existingFeeCodeAmount;
    @api stageName;
    @track receiptWrapper = { hasReceipt: false, allApproved: false, pendingReceiptList: [], lengthOfDirectRec : 0, existingFeeCodeOption: []};
    @track hasReceipt = false;
    @track allApproved = false;
    @track pendingReceiptList = [];
    @track isReceiptDataArrived = false;
    @track dataReceipt = [];
    @track cashierType = [];
    @track isSaveClicked = false;
    @track receiptId;
    @track cashierValue;
    @track receiptDateValue; 
    @track feeCodeValue;
    @track existingFeeCodeAmount;
    @track feeId = 0;
    @track lengthOfDirectRec = 0;
    @track isSave = false;
    @track showReceipt = true;
    @track todayDateValue = new Date().toISOString();
    @track branchCode = false;
    @track btnDisable = 'brandEnable';// save button class
    //@track btnEnable = 'brandEnable'; 

    @wire(getRecord, { recordId: '$applicationId', fields: [CASHIER] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.cashierValue = data.fields.Cashier__c.value;
            if (!this.cashierValue) {
                this.getCashierValue();
            }
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    connectedCallback() {
        try {
            console.log('ApplicationId in receipt screen ', this.applicationId, 'stage is', this.stageName);
            console.log('applicant name', this.primaryApplicantName);
            //this.getAllCashier(); commented by Kuldeep
            // Added by Navin on 30-July-2022. 
            setTimeout(() => {
                console.log('app id', this.applicationId);
                if (this.applicationId) {
                    this.getPrimaryApplicant();
                    this.getFeeCodeChange();
                }
            }, 300);
            
            if (this.applicationId) {
                this.getAllReceiptData();
                this.getApplicationBranchCode();
            }
        }
        catch (exe) {
            console.log('Exception in receipt screen ', exe);
        }
    }

    getApplicationBranchCode(){
        getApplicationBranchCode({applicationId : this.applicationId})
            .then(result =>{
                console.log('branch code ', result);
                if(result === 'Fail'){
                    this.branchCode = false;
                }
                else{
                    this.branchCode = true;
                }
                
            })
    }

    //commented by Kuldeep
    // getAllCashier() {
    //     getCashiers()
    //         .then(result => {
    //             console.log('cashiers ', result);
    //             for (let key in result) {
    //                 const cashier = {
    //                     label: result[key],
    //                     value: key
    //                 };
    //                 this.cashierType = [...this.cashierType, cashier];
    //             }
    //             console.log('Map ', this.cashierType);
    //             console.log('Map length ', this.cashierType.length);
    //             if (this.cashierType.length === 1) {
    //                 console.log('Value ', this.cashierType[0]);
    //                 console.log('stringify ', JSON.stringify(this.cashierType[0]));
    //                 console.log('stringify ', this.cashierType[0].value);
    //                 this.cashierValue = this.cashierType[0].value;
    //             }

    //         })
    //         .catch(error => {
    //             console.log('error in getcashier ', error);
    //         })
    // }


    @api getAllReceiptData() {
        console.log('get receipt data called!!', this.applicationId, this.stageName);
        getReceiptData({ applicationId: this.applicationId, stage: this.stageName})
            .then(result => {
                this.hasReceipt = false;
                this.allApproved = false;
                this.pendingReceiptList = [];
                var temp = JSON.parse(result.strDataTableData);
                console.log('temp', temp);
                console.log('Receipt length ', temp.length);
                if (temp.length === 0) {
                    this.hasReceipt = false;
                }
                else {
                    this.hasReceipt = true;
                }
                var pendingReceiptListStageBase = [];
                temp.forEach(element => {
                    console.log('element for receipt pending list', JSON.stringify(element));
                    var dataResult = element;
                    if (dataResult.Approval_Status__c === 'Approved') {
                        this.allApproved = true;
                    }
                    else {
                        if(dataResult.Approval_Status__c != 'Rejected' && dataResult.Approval_Status__c != 'Approved'){
                            this.pendingReceiptList.push({name : dataResult.Name, RecStatus : dataResult.Approval_Status__c});
                        }
                        else if(dataResult.Approval_Status__c == 'Rejected'){
                            console.log('fee code in receipt');
                            getRecFeeRepayment({recId : dataResult.Id})
                            .then(result=>{
                                console.log('repayment arrived',result);
                                if(result == 'Direct Receipt'){
                                this.pendingReceiptList.push({name : dataResult.Name, RecStatus : dataResult.Approval_Status__c});
                                }
                            })
                            
                        }
                        
                        this.allApproved = false;
                    }
                });

                //To get pending receipt based on stage due
        
                        var receiptNameList = [];
        
        
                        if((this.pendingReceiptList != null || this.pendingReceiptList != undefined) && this.pendingReceiptList.length > 0){
                            this.pendingReceiptList.forEach(element => {
                                console.log('pending receipt list name is ',element);
                                receiptNameList.push(element.name);
                            });
                        
                        }
                        console.log('pending receipt list in receipt screen ',receiptNameList);
                        if((receiptNameList != null || receiptNameList != undefined) && receiptNameList.length > 0){
                            console.log('pending receipt list in receipt screen in if',receiptNameList);
                        getReceiptFeeStage({receiptNameList : receiptNameList, stageName : this.stageName}).then(result => {
                            
                            console.log('result of receipt based on stage due', result);
                            var tempRec = result;
                            console.log('receipt from get receipt fee stage', tempRec);
                            if(tempRec){
                            tempRec.forEach(element => {
                                console.log('add receipt in receipt list based on stagedue ', element);
                                var dataResult = element;
                                pendingReceiptListStageBase.push({name : dataResult.Name, RecStatus : dataResult.Approval_Status__c});
                        });}
                       // this.receiptWrapper.pendingReceiptList = pendingReceiptListStageBase;
                        console.log('pendingReceiptList in fsprelogin', pendingReceiptListStageBase);
                        }).catch(error =>{
                            console.log('error of receipt based on stage due', error);
                        })}
                        //---------------------------------
                this.receiptWrapper.allApproved = this.allApproved;
                this.receiptWrapper.hasReceipt = this.hasReceipt;
                //this.receiptWrapper.pendingReceiptList = this.pendingReceiptList;
                this.receiptWrapper.pendingReceiptList = pendingReceiptListStageBase;
                console.log('this.receiptWrapper.pendingReceiptList', this.receiptWrapper.pendingReceiptList);
                this.receiptWrapper.lengthOfDirectRec =this.lengthOfDirectRec;
                this.dataReceipt = [];
                this.dataReceipt = result;
                this.isReceiptDataArrived = true;
                console.log('json data ====> ' + JSON.stringify(result));
                const receiptEvent = new CustomEvent("getreceiptevent", {
                    detail: this.receiptWrapper,
                    bubbles: true,
                    composed: true
                });
                console.log('dispatch receiptEvent ', JSON.stringify(receiptEvent));
                this.dispatchEvent(receiptEvent);
            })
            .catch(error => {
                console.log('error while retreiving receipt :: ', error);
            })
    }

    buttonClick(event){
        console.log('cashierValue', this.cashierValue);
        this.isSaveClicked = true;
        if(!this.cashierValue){
            this.showToast('Error', 'error', 'Please fill all details!!');
            this.closeAction();
        }
        console.log('receiptDateValue', this.receiptDateValue);
        if(this.receiptDateValue == null){
            this.showToast('Error', 'error', 'Please fill all details!!');
            this.closeAction();
        }
    }

    handleDateChange(event){
        this.dataValues = event;
        console.log('event onchange ',this.dataValues);
        console.log(this.dataValues);
        var tempFieldsContent = event.target;
        console.log('tempFieldsContent',tempFieldsContent);
        var d1 = new Date();
        var d2 = new Date(tempFieldsContent.value);
        console.log('date is',d2, 'd1',d1);    
        if (d2.getTime() > d1.getTime()) {
            console.log('date ',d2);
            this.showToast('Error', 'error', 'Invalid Date, Future Dates Are Not Allowed!!');
               // this.closeAction();
                var dateVal = null;
                console.log('field-name="Receipt_Date__c"',this.template.querySelectorAll('[data-name="resetReceipt"]'));   
                this.template.querySelectorAll('[data-name="resetReceipt"]').forEach(field => {
                    if(field.fieldName == 'Receipt_Date__c'){
                        console.log('Reset ', JSON.stringify(field.fieldName));
                        
                        field.value = '';
                        //field.reset();
                    }
                })
            }
        else if(d2.getTime() < d1.getTime()){
            console.log('date is ok',d2);
        }
    }
    handleSubmitReceipt(event) {
        console.log('Receipt Submit Called');
        this.isSaveClicked = true;
        this.btnDisable = 'brandbtn';
        const fields = event.detail.fields;
        console.log('receipt fields',JSON.stringify(fields.Cashier__c));
        var d1 = new Date();
        var d2 = new Date(fields.Receipt_Date__c);
        event.preventDefault();
        if (d2.getTime() > d1.getTime() || d2 == 'Invalid Date') {
            this.showToast('Error', 'error', 'Invalid Date!!');
            this.closeAction();
            const inputFields = this.template.querySelector('[data-id="receiptDate"]');
            // console.log('ResetDate ', JSON.stringify(inputFields));
            inputFields.reset();
        }
        else {
            
            if(this.feeCodeValue == null){
                console.log('this.feecode', this.feeCodeValue);
                this.showToast('Error', 'error', 'Invalid Amount. Please select Fee Code!!');
                this.closeAction();
            }
            else{
                if(this.branchCode == false){
                    console.log('this.branchCode', this.branchCode);
                    this.showToast('Error', 'error', 'Sourcing Branch/ Branch Code is blank!!');
                    this.closeAction();
                }
                else{
            console.log('on submit application ', JSON.stringify(event.detail.fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            console.log('After Submit fields ', JSON.stringify(fields));
                }
            }
        }
    }

    async handleSuccessReceipt(event) {
        this.isSave = true;
        console.log('On Success Receipt Id :: ', event.detail.id);
        console.log('Fields ', JSON.stringify(event.detail.fields.Cashier__c));
        console.log('Fields ', JSON.stringify(event.detail.fields.Cashier__c.value));
        console.log('fee for receipt', this.feeId);
        if (this.feeId != 0) {
            updateReceiptFee({ receiptId: event.detail.id, feeId: this.feeId, stage: this.stageName }).then(result => {
                console.log('result from update', result);
            }).catch(error => {
                console.log('error in receipt update', error);
            })
        }

        //this.receiptId = event.detail.id;
        this.showToast('Success', 'Success', 'Receipt Created Successfully And Submitted For Approval!!');
        //this.isSaveClicked = false;
        this.closeAction();
        await submitReceiptForApproval({ receiptId: event.detail.id, approverId: event.detail.fields.Cashier__c.value })
            .then(result => {
                console.log('Approval Result ', result);
                if (result === 'Failed') {
                    this.showToast('Error', 'Error', 'Failed To Submit Receipt For Approval, Contact System Administrator!!');
                    this.closeAction();
                }
            })
            .catch(error => {
                console.log('Error ', error);
                this.showToast('Error', 'Error', 'Failed To Submit Receipt For Approval, Contact System Administrator!!');
                this.closeAction();
            })
        this.isReceiptDataArrived = false;
        this.getAllReceiptData();
        this.handleResetReceipt();
        //window.location.reload();
        this.getFeeCodeChange();
        this.isSave = false;
        
    }

    //commented by Kuldeep
    // handleCashier(event) {
    //     console.log(event.target.value);
    //     this.cashierValue = event.target.value;
    // }

    handleReceiptDate(event){
        console.log(event.target.value);
        this.receiptDateValue = event.target.value;
    }

    @api handleResetReceipt() {
        //this.template.querySelector('form').reset();
        this.cashierValue = null;
        this.feeCodeValue = null;
        this.feeId = null;
        this.existingFeeCodeAmount = null;
        this.receiptDateValue = null;
        const inputFields = this.template.querySelectorAll('[data-name="resetReceipt"]');
        console.log('HandleReset ', JSON.stringify(inputFields));
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName == 'Mode_of_payment__c'){
                    console.log('Reset ', JSON.stringify(field.fieldName));
                    field.value = 'Cash';
                }
                else{
                console.log('Reset ', JSON.stringify(field.fieldName));
                field.reset();
                }
            });
        }
        this.receiptId = undefined;

    }

    handleRefresh() {
        this.isReceiptDataArrived = false;
        this.getAllReceiptData();
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


   @api getFeeCodeChange() {
       this.existingFeeCodeOption = [];
        getRecordNotifyChange([{recordId: this.applicationId}]);
        console.log('get fee Code Change called!!', this.applicationId);
        // getExistingFeeCode({ applicationId: this.applicationId })
       
        if (this.stageName == 'Pre Login' || this.stageName == 'Lead Detail' || this.stageName == 'Process Credit' || this.stageName == 'Approval Credit' || this.stageName == 'Disbursal Maker' || this.stageName == 'Disbursal Author' || this.stageName == 'Agreement Execution'){
        getExistingFeeCodeRec({ applicationId: this.applicationId, stageName : this.stageName })
            .then(result => {
                console.log('existing fee code result is',JSON.stringify(result), this.stageName, this.applicationId);
                //console.log('result', event.target.value);
               var feeCodeStageBase = [];
                var length = 0;
                var lengthStageBase = 0;
                for (let key in result) {
                    //console.log('Key', key);
                    console.log('result', result[key]);
                    length++;
                    const feeCode = {
                        //label: result[key].Fee_Code__c,
                        //added for FVM : 27/11/22
                        label: result[key].Description__c,
                        value: result[key].Id
                    };
                    this.existingFeeCodeOption = [...this.existingFeeCodeOption, feeCode];
                    if(result[key].Stage__c != null && result[key].Stage__c != undefined ){
                        if(this.stageName == 'Pre Login'){
                            if(result[key].Stage__c == this.stageName){
                                lengthStageBase++;
                                feeCodeStageBase.push(feeCode);
                            }}
                            else if(this.stageName == 'Process Credit'){
                                if(result[key].Stage__c == this.stageName || result[key].Stage__c == 'Pre Login'){
                                lengthStageBase++;
                                feeCodeStageBase.push(feeCode);
                            }
                            }
                            else if(this.stageName == 'Disbursal Author'){
                                if(result[key].Stage__c == 'Disbursement' || result[key].Stage__c == 'Pre Login' || result[key].Stage__c == 'Process Credit' || result[key].Stage__c == 'Pre Disbursement'){
                                lengthStageBase++;
                                feeCodeStageBase.push(feeCode);
                            }
                            }
                            else if(this.stageName == 'Agreement Execution'){
                                if(result[key].Stage__c == 'Pre Disbursement' || result[key].Stage__c == 'Pre Login' || result[key].Stage__c == 'Process Credit'){
                                lengthStageBase++;
                                feeCodeStageBase.push(feeCode);
                            }
                            }
                    }
                }console.log('existing fee code result length is',length);
                console.log('feeCodeStageBase', feeCodeStageBase, lengthStageBase);
                this.lengthOfDirectRec = length;
                this.getAllReceiptData();
                if(this.lengthOfDirectRec == 0){
                    this.showReceipt = false;
                }
                else if(this.lengthOfDirectRec > 0){
                    this.showReceipt = true;
                }
                //this.receiptWrapper.lengthOfDirectRec = this.lengthOfDirectRec;
                //this.receiptWrapper.existingFeeCodeOption = this.existingFeeCodeOption;
                // To show fee code validation based on stage of fee
                this.receiptWrapper.existingFeeCodeOption = feeCodeStageBase;
                this.receiptWrapper.lengthOfDirectRec = lengthStageBase;
                //----------------------------------------------------//
                console.log('this.receiptWrapper.lengthOfDirectRec in pre login',this.receiptWrapper.lengthOfDirectRec);
            })
            .catch(error => {
                console.log('error while retreiving receipt :: ', error);
            })
        }
        
    }

    feeCodeChanged(event) {
        
        getRecordNotifyChange([{recordId: this.applicationId}]);
        console.log('get fee Code Change called!!', this.applicationId);
        console.log('stage name is' + this.stageName);
        if (this.stageName == 'Pre Login' || this.stageName == 'Lead Detail' || this.stageName == 'Process Credit' || this.stageName == 'Approval Credit' || this.stageName == 'Disbursal Maker' || this.stageName == 'Disbursal Author' || this.stageName == 'Agreement Execution' ) {

            console.log('get fee code in fee details');
            getExistingFeeCodeRec({ applicationId: this.applicationId, stageName : this.stageName })
                .then(result => {
                    console.log('Select value ', JSON.stringify(event));
                    console.log('Select value ', event.detail.value);
                    this.feeCodeValue = event.detail.value;
                    console.log('feecode',this.feeCodeValue);
                    for (let key in result) {
                        const feeCode = {
                           label: result[key].Description__c,
                            value: result[key].Id
                        };
                        if (result[key].Id == event.detail.value) {
                            console.log('Key', key);
                            console.log('result', result[key]);
                            console.log('and the amount is', result[key].RecordType.Name, 'collection', result[key].Fee_Collection__c);
                            if (result[key].RecordType.Name == 'Fee') {
                              //  this.existingFeeCodeAmount = result[key].Fee_Collection__c;
                              this.existingFeeCodeAmount = result[key].Total_Fee__c;
                            }
                            else if (result[key].RecordType.Name == 'Insurance') {
                                this.existingFeeCodeAmount = result[key].Total_Fee__c;
                            }

                            this.feeId = key;
                            console.log('feeId', this.feeId);
                        }
                    }
                })
                .catch(error => {
                    console.log('error while retreiving receipt :: ', error);
                })
        }
        
    }  

    getCashierValue(){
        roundRobinByStage({applicationId : this.applicationId, stage : 'Cashier'}).then((result) => {
            console.log('getCashier Value = ',result);
            if(result){
                this.cashierValue = result;
            }else{
                this.cashierValue = pullUserId;
            }     
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.applicationId;                
            fields[CASHIER.fieldApiName] = this.cashierValue;            
            const recordInput = { fields };       
            updateRecord(recordInput).then(() => {
                console.log('Cashier Saved Successfully ');
            }).catch(error => {
                console.log('Error in Cashier Save = ',error);
            });
        }).catch((err) => {
            console.log('Error in getCashier = ',err);
        });
    }

    getPrimaryApplicant(){
        getApplicationPrimaryApplicantName({applicationId : this.applicationId})
            .then(applicantName =>{
                console.log('applicantName ', applicantName);
                if(applicantName != null || applicantName != '' || applicantName != undefined){
                    this.primaryApplicantName = applicantName;
                }
                
                
            }).catch(error => {
                console.log('error in get applicant name ', error);
            })
    }

}