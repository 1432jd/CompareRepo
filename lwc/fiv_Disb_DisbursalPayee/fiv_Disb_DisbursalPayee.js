import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import PAYMENT_TYPE from '@salesforce/schema/Disbursal_Payee__c.Payment_Type__c';
import BENEFICIARY_ACCOUNT_TYPE from '@salesforce/schema/Disbursal_Payee__c.Beneficiary_Account_Type__c';
import DISBURSAL_PAYEE_OBJECT from '@salesforce/schema/Disbursal_Payee__c';
//------------------------------------------------------------------------------
import getPennyDropStatus from '@salesforce/apex/Fiv_Disb_LwcController.getPennyDropStatus';
import getDisbursalData from '@salesforce/apex/Fiv_Disb_LwcController.getDisbursalData';
import saveDisbursalCompData from '@salesforce/apex/Fiv_Disb_LwcController.saveDisbursalPayeeData';
import initData from '@salesforce/apex/Fiv_Disb_LwcController.initDisbursalPayee';
import getIfscDetails from '@salesforce/apex/Fiv_Disb_LwcController.getIfscDetails';
import getDocumentId from '@salesforce/apex/Fiv_Disb_LwcController.getDocumentId';
import getAppStage from '@salesforce/apex/Fiv_Disb_LwcController.getAppStage';
import callPennyDropAPI from '@salesforce/apex/Fiv_Disb_LwcController.callPennyDropAPI';
import saveSobjectLists from '@salesforce/apex/Fiv_Disb_LwcController.saveSobjectLists'; //Karan Singh : 24/09/2022 : CH - incase of changes in the selection of deduct from checkbox
import getDeductionAmount from '@salesforce/apex/Fiv_Disb_LwcController.getDeductionAmount'; //Karan Singh : 03-10-2022 : CH
import deleteRecords from '@salesforce/apex/Fiv_Disb_LwcController.deleteRecords'; //Karan Singh : 27/09/2022 : CH
//------------------------------------------------------------------------------
/* *Changes 
 * Karan Singh : 11-10-2022 : CH01 - changed the Beneficiary IFSC Code from lookup to text field and change in IFSC API
*/
//------------------------------------------------------------------------------
export default class Fiv_Disb_DisbursalPayee extends NavigationMixin(LightningElement) {

    @track setDisbTypeVal = '';
    @api obj_parent_appt_wrapper_data;
    @api objdeductiondetails; //Karan Singh : 03-10-2022 - CH
    @track listExistDisbursalPayees = [];
    @track objDisbursalPayee = {};
    showLoader = false;
    currentEditDisbPayeeId = null; //this will store current editing disbursal payee detail Id
    @track rowAction = [{
        type: 'button-icon', fixedWidth: 50,
        typeAttributes: { iconName: 'utility:edit', title: 'Edit', variant: 'border-filled', alternativeText: 'Edit', name: 'edit' }
    }];
    @track acceptedFormats = ['.png', '.jpg', '.pdf'];
    @track stageName='';
    @track isShow=true;
    @track isNewRecord = false;
    @track fileData = {};
    fileErrMsg = '';
    isExistDisbPayee = false;
    @track listBenificiaryType = [];
    showUI = false;
    @track mapAppltTypeName = new Map();
    enableDisbPayeeEdit = false;
    tempAccntNumber = '';
    reEnterAccntNumber = '';
    accMisMatchMsg1 = '';
    accMisMatchMsg2 = ''; //border : 2px solid red
    disbErrorMsg1 = '';
    disbErrorMsg2 = '';
    isfcCodeMissErr = '';
    existBenificiaryAmt = 0;
    finalDIsbAmount = 0;
    isAccntEntered = false;
    addNewBeneficiary = false; //incase all loan applicant have been added
    @track mapDisbPayeeIdWithDocumentId;
    tempAddedBenificiaryType = '';
    sanctionLoanAmt = 0;
    insurancePremium = 0;
    insuranceTotalFee = 0;
    enableSaveAmtBtn = false;
    isBennifAmtMatchDisbAmt = false; //checking error for amount greater
    @track disableSaveEditBtn = true;
    timeId = '';
    @track listLoanApptTypeBankDetails = [];
    showIsfcComp = true; // Karan Singh : 26/09/2022 : CH - This is done so that the lookup component can be rerender with new values
    @track setFieldChanges = new Set(); // Karan Singh : 27/09/2022 : CH - to track in which fields the data has been changed
    isValidBankAccntDetails = true;
    existBankAccntDetailMatchName = '';
    disableEditDel = false;//Karan Singh : 13-10-2022 : CH - This is done so that while selecting Deduct from Edit and Delete should be disable
    //--------------------------------------------------------------------------
    @wire(getObjectInfo, { objectApiName: DISBURSAL_PAYEE_OBJECT })

    disbPayeeMetadata;

    // now retriving the StageName picklist values of Opportunity

    @wire(getPicklistValues, {
        recordTypeId: '$disbPayeeMetadata.data.defaultRecordTypeId',
        fieldApiName: PAYMENT_TYPE
    }
    ) disbPayeePayTypePickVal;
    //Karan Singh : 26/09/2022 : CH
    @wire(getPicklistValues, {
        recordTypeId: '$disbPayeeMetadata.data.defaultRecordTypeId',
        fieldApiName: BENEFICIARY_ACCOUNT_TYPE
    }
    ) disbPayeeAcctTypePickVal;
    //--------------------------------------------------------------------------
    get uploadedfileName() {
        return this.fileData.hasOwnProperty('filename') ? this.fileData.filename : 'Bank Proof Image Upload';
    }
    get isExistPayeeExists() {
        return this.listExistDisbursalPayees.length > 0 ? true : false;
    }
    //--------------------------------------------------------------------------
    connectedCallback() {
        console.log('Fiv_Disb_Lwc Fiv_Disb_DisbursalPayee init');
        try {

            this.initData();

        } catch (error) {
            console.log(` Error init ${error}`);
        }

    }

    reInitDisbPayee() {
        console.log('inside 110', this.objDisbursalPayee);
        this.objDisbursalPayee = undefined;
        this.objDisbursalPayee = { 'sobjectType': 'Disbursal_Payee__c', "Id": '', 'Beneficiary_Amount__c': 0, 'Beneficiary_Bank_Account_Number__c': '', 'Beneficiary_Bank_Name__c': '', 'Beneficiary_Branch_Name__c': '', 'Beneficiary_IFSC_Code__c': '', 'Beneficiary_Name__c': '', 'Beneficiary_Type__c': '', 'Disbursal__c': this.checkExistingDisbursalId(), 'Payment_Type__c': '', 'Adjusted_Beneficiary_Amount__c': 0, 'Beneficiary_Account_Type__c': '', 'Loan_Applicant__c': '','IsDisbIdCheck__c':'' };

        if(this.isNewRecord){
            this.objDisbursalPayee.IsDisbIdCheck__c='true';
        }else if(!this.isNewRecord){
            this.objDisbursalPayee.IsDisbIdCheck__c='';
        }


        this.fileData = {};
        this.fileErrMsg = '';
        this.setFieldChanges = new Set();
        this.objDisbursalPayee.Id = null;
        console.log('inside 114', this.objDisbursalPayee);
    }

    getAppStageName(){	
        getAppStage({	
            apptId: this.obj_parent_appt_wrapper_data.objAppt.Id	
        }).then((result) => {	
            var appValues=JSON.parse(JSON.stringify((result)));
            this.stageName=appValues[0].Stage__c;  
            //this.stageName=result;	
             console.log('consolwa dekhtara >>>',this.stageName);
            if(this.stageName == 'Disbursal Author'){	
                console.log('consolwa dekhtara >>>');
                this.isShow = false;	
            }else{	
                this.isShow = true;	
            }	
        }).catch((err) => {	
            console.log('Error in Fiv_Disb_DisbursalParams getDeductionAmount = ', err);	
            this.showLoader = false;	
        });	
    }



    initData() {
        this.getAppStageName();
        console.log('inside 123');
        this.enableSaveAmtBtn = false;
        this.mapDisbPayeeIdWithDocumentId = new Map();
        this.showUI = false;
        this.showLoader = true;
        this.listExistDisbursalPayees = [];
        this.enableDisbPayeeEdit = false;
        this.disableSaveEditBtn = true;
        this.existBenificiaryAmt = 0;
        this.sanctionLoanAmt = 0;
        this.isBennifAmtMatchDisbAmt = false;
        this.insurancePremium = 0;
        this.insuranceTotalFee = 0;
        this.reInitDisbPayee();
        this.listBenificiaryType = [];
        this.timeId = '';
        this.listLoanApptTypeBankDetails = [];
        this.isValidBankAccntDetails = true;
        this.existBankAccntDetailMatchName = '';
        this.setFieldChanges = new Set();
        this.disableEditDel = false;//Karan Singh : 13-10-2022 : CH - This is done so that while selecting Deduct from Edit and Delete should be disable
        //======================================================================

        var jsonParam = { apptId: this.obj_parent_appt_wrapper_data.objAppt.Id };

        if (this.checkExistingDisbursalId()) {
            jsonParam.existDisbId = this.checkExistingDisbursalId();
        }
        console.log('Fiv_Disb_Lwc Fiv_Disb_DisbursalPayee jsonParam ' + JSON.stringify(jsonParam));
        initData({
            jsonParamData: JSON.stringify(jsonParam)
        }).then((result) => {

            console.log('Fiv_Disb_Lwc Fiv_Disb_DisbursalPayee = ', JSON.stringify(result));

            if (result.statusCode !== 200) {

                this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                this.showLoader = false;
            } else {

                try {
                    console.log(result.mapExtraParams.hasOwnProperty('listApptNameType'));

                    if (result.mapExtraParams.hasOwnProperty('Final_Disbursal_Amount')) {
                        this.finalDIsbAmount = parseFloat(result.mapExtraParams.Final_Disbursal_Amount);
                    }
                    if (result.mapExtraParams.hasOwnProperty('sanctionLoanAmt')) {
                        this.sanctionLoanAmt = parseFloat(result.mapExtraParams.sanctionLoanAmt);
                    }
                    /*if (result.mapExtraParams.hasOwnProperty('insuranceCalc')) {
                        console.log('Fiv_Disb_DisbursalPayee insuranceCalc ' + result.mapExtraParams.insuranceCalc);
                        console.log('Fiv_Disb_DisbursalPayee insuranceCalc premium ' + result.mapExtraParams.insuranceCalc.premium);
                        this.insurancePremium = JSON.parse(result.mapExtraParams.insuranceCalc).premium;
                        this.insuranceTotalFee = JSON.parse(result.mapExtraParams.insuranceCalc).fee;
                    }*/
                    //var setExistApptType = new Set();Karan Singh : 27/06/2022 : CH - (NP-17-09-22) - H

                    console.log('Fiv_Disb_DisbursalPayee Init Data exist lenght ' + result.listSObject.length)
                    //Showing exisitng records
                    if (result.listSObject.length > 0) {

                        result.listSObject.forEach(element => {

                            if (element.Beneficiary_Type__c == 'BT Bank') {

                                //this.listExistDisbursalPayees.push({ sobject: element, isChecked: false, isVisible: false, isDisable: false, verifyNeed: false });
                                //Karan Singh : 04-10-2022 : CH- Added verifyNeed: false as not to invoke PennydropAPI
                                this.listExistDisbursalPayees.push({ sobject: element, isChecked: false, isVisible: false, isDisable: false, byPassVerify: true });
                            }
                            else if (element.Beneficiary_Type__c == 'Third Party') { //Karan Singh : 04-10-2022 : CH- Added as not to invoke PennydropAPI

                                this.listExistDisbursalPayees.push({ sobject: element, isChecked: false, isVisible: true, isDisable: false, byPassVerify: true });
                            } else {
                                this.listExistDisbursalPayees.push({ sobject: element, isChecked: false, isVisible: true, isDisable: false, byPassVerify: false });
                            }

                            //Karan : 23/09/2022 : CH
                            console.log(`is Deduct ${element.Is_Deduct_From__c} , benif adjust ${element.Adjusted_Beneficiary_Amount__c} , benif ${element.Beneficiary_Amount__c} `);

                            if (element.Is_Deduct_From__c) {
                                console.log('Benif adjust - ' + element.Adjusted_Beneficiary_Amount__c);
                                this.existBenificiaryAmt += element.Adjusted_Beneficiary_Amount__c ? (Math.round(parseFloat(element.Adjusted_Beneficiary_Amount__c) * 100) / 100) : 0;

                            } else {
                                console.log('Benif Normal - ' + element.Beneficiary_Amount__c);
                                this.existBenificiaryAmt += element.Beneficiary_Amount__c ? (Math.round(parseFloat(element.Beneficiary_Amount__c) * 100) / 100) : 0;

                            }
                            //setExistApptType.add(element.Beneficiary_Type__c);Karan Singh : 27/06/2022 : CH - (NP-17-09-22) - H
                        });
                        console.log('listExistDisbursalPayees - ' + JSON.stringify(this.listExistDisbursalPayees));
                        this.showUI = true;
                        //this.listExistDisbursalPayees = result.listSObject;
                    } else {
                        this.enableDisbPayeeEdit = true;
                        this.disableSaveEditBtn = false;
                        this.reInitDisbPayee();

                        /*if (this.isBeneficaryAmntGreaterThanLoanAmt) {

                            this.showNotification('ERROR', 'Total beneficiary amount is greater than sanction loan amount. Please select a record to adjust', 'error');
                        }*/
                        //this.objDisbursalPayee.Beneficiary_Amount__c = this.finalDIsbAmount - this.existBenificiaryAmt;
                    }
                    console.log('this.existBenificiaryAmt ', this.existBenificiaryAmt);
                    console.log('this.sanctionLoanAmt ', this.sanctionLoanAmt);
                    //console.log('this.insurancePremium ', this.insurancePremium);
                    //console.log('this.insuranceTotalFee ', this.insuranceTotalFee);
                    //=========================================================
                    //this.finalDIsbAmount = this.sanctionLoanAmt - this.insurancePremium - this.insuranceTotalFee;
                    //console.log('this.this.finalDIsbAmount ' + this.finalDIsbAmount);
                    //console.log('this.this.finalDIsbAmount type of ' + typeof this.finalDIsbAmount);

                    //this.isBennifAmtMatchDisbAmt = this.existBenificiaryAmt === this.finalDIsbAmount ? true : false;

                    //console.log('this.isBennifAmtMatchDisbAmt' + this.isBennifAmtMatchDisbAmt);
                    //console.log(' setExistApptType ' + setExistApptType);Karan Singh : 27/06/2022 : CH - (NP-17-09-22) - H
                    //for populating Loan Applicant Names
                    if (result.mapExtraParams.hasOwnProperty('listApptNameType')) {

                        //incase more than  one match
                        if (result.mapExtraParams.listApptNameType.includes(',')) {

                            result.mapExtraParams.listApptNameType.split(',').forEach(element => {

                                //if (!setExistApptType.has(element.split('---')[0])) {Karan Singh : 27/06/2022 : CH - (NP-17-09-22) - H
                                this.listBenificiaryType.push({ label: element.split('---')[0], value: element.split('---')[0] });
                                //this.mapAppltTypeName.set(result.mapExtraParams.listApptNameType.split('---')[0], result.mapExtraParams.listApptNameType.split('---')[1])//Karan Singh : 04-10-2022 : CH
                                this.mapAppltTypeName.set(element.split('---')[0], { 'loanApptName': element.split('---')[1], 'loanApptId': element.split('---')[2] });
                                //}

                            });

                        } else {
                            //if (!setExistApptType.has(element.split('---')[0])) {Karan Singh : 27/06/2022 : CH - (NP-17-09-22) - H
                            //this.mapAppltTypeName.set(result.mapExtraParams.listApptNameType.split('---')[0], result.mapExtraParams.listApptNameType.split('---')[1])//Karan Singh : 04-10-2022 : CH
                            this.mapAppltTypeName.set(element.split('---')[0], { 'loanApptName': element.split('---')[1], 'loanApptId': element.split('---')[2] });
                            this.listBenificiaryType.push({ label: result.mapExtraParams.listApptNameType.split('---')[0], value: result.mapExtraParams.listApptNameType.split('---')[0] });
                            //}
                        }
                        if (this.listBenificiaryType.length > 0) {
                            this.showUI = true;
                            this.addNewBeneficiary = true;
                        } else {
                            this.addNewBeneficiary = false;
                        }
                    }

                    //console.log('existBenificiaryAmt ' + this.existBenificiaryAmt);
                    //console.log('finalDIsbAmount' + this.finalDIsbAmount);
                    //console.log('listExistDisbursalPayees' + this.listExistDisbursalPayees);

                    //Karan Singh : 26-09-2022 : CH - Getting Loan Applicant verified Bank Details
                    if (result.hasOwnProperty('listSObject2')) {
                        this.listLoanApptTypeBankDetails = result.listSObject2;
                    }
                    //==============================================================================
                    this.showLoader = false;
                } catch (error) {
                    console.log('Error in Fiv_Disb_DisbursalPayee Init Data result= ', error);
                    this.showNotification('ERROR', error.message, 'error');
                    this.showLoader = false;
                }
                this.getDeductionAmount(); //Karan SIngh : 03-10-2022 : CH
            }

        }).catch((err) => {

            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_DisbursalPayee Init Data = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }

    checkExistingDisbursalId() {
        console.log('inside 300');
        if (this.obj_parent_appt_wrapper_data.objAppt.hasOwnProperty('Disbursals__r')) {
            console.log('this.obj_parent_appt_wrapper_data.Disbursals__r[0].Id ' + this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id);
            return this.obj_parent_appt_wrapper_data.objAppt.Disbursals__r[0].Id;
        }
        return null;
    }
    //CH01 : added API support in this
    fetchIfscDetails(ifscCodeId) {
        console.log('inside 309');
        this.showLoader = true;
        getIfscDetails({
            ifscCodeId: ifscCodeId
        }).then((result) => {

            console.log('getIfscDetails  = ', JSON.stringify(result));

            if (result.statusCode !== 200
                && result.statusCode !== 201) {

                this.objDisbursalPayee.Beneficiary_Bank_Name__c = '';
                this.objDisbursalPayee.Beneficiary_Branch_Name__c = '';
                this.showNotification('', result.message, 'warning'); //incase if any apex exception happened it will show notification
            } else {

                var objIfscApiResult = JSON.parse(result.message); //CH01
                console.log(`objIfscApiResult - ${JSON.stringify(objIfscApiResult)}`);
                this.showIsfcComp = true;

                this.objDisbursalPayee.Beneficiary_Bank_Name__c = objIfscApiResult.hasOwnProperty('BANK') ? objIfscApiResult.BANK : '';
                this.objDisbursalPayee.Beneficiary_Branch_Name__c = objIfscApiResult.hasOwnProperty('BRANCH') ? objIfscApiResult.BRANCH : '';
                this.disbErrorMsg1 = '';
                this.disbErrorMsg2 = '';
            }
            this.showLoader = false;

        }).catch((err) => {

            //incase if any Salesforce exception happened it will show notification
            console.log('Error in getIfscDetails = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });
    }
    onOpenfileUpload(event) {
        console.log('inside 345');
        this.fileErrMsg = '';
        //console.log(this.obj_parent_appt_wrapper_data.disbMetaPrefix);
        try {

            const file = event.target.files[0];

            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                //console.log('data' + JSON.stringify(reader.result));
                this.fileData = {
                    'filename': this.obj_parent_appt_wrapper_data.disbMetaPrefix + 'BankProof- ' + file.name,
                    'base64': base64,
                }
                console.log('File name - ' + this.fileData.filename);
                //this.uploadedfileName = this.fileData.filename;
            }
            reader.readAsDataURL(file)
        } catch (error) {
            console.log('error -' + error.message);
            this.fileErrMsg = error.message;
            this.fileData = {};
        }

    }
    //--------------------------------------------------------------------------
    handleComboBoxChange(event) {
        console.log('inside 373');
        try {


            console.log(event.detail.value);
            console.log(event.target.dataset.id);
            console.log(this.mapAppltTypeName);
            this.objDisbursalPayee[event.target.dataset.field] = event.detail.value;

            if (event.target.dataset.id == 'BeneficiaryType') {

                if (this.mapAppltTypeName.has(event.detail.value)) {

                    console.log(JSON.stringify(this.mapAppltTypeName.get(event.detail.value)));
                    //this.objDisbursalPayee.Beneficiary_Name__c = this.mapAppltTypeName.get(event.detail.value)Karan SIngh : 04-10-2022 : CH
                    this.objDisbursalPayee.Beneficiary_Name__c = this.mapAppltTypeName.get(event.detail.value).loanApptName;//Karan SIngh : 04-10-2022 : CH
                    this.objDisbursalPayee.Loan_Applicant__c = this.mapAppltTypeName.get(event.detail.value).loanApptId;//Karan SIngh : 04-10-2022 : CH
                    //Karan Singh 26-09-2022: CH : Incase of populating from Benificiary type, if value then disabled else reverse scenerio
                    this.template.querySelector(`[data-field="Beneficiary_Name__c"]`).disabled = this.objDisbursalPayee.Beneficiary_Name__c ? true : false;

                }
                this.template.querySelector(`[data-field="Beneficiary_Name__c"]`).setCustomValidity('');
                this.template.querySelector(`[data-field="Beneficiary_Name__c"]`).reportValidity();

                this.tempAccntNumber = undefined;
                this.template.querySelector(`[data-label="BeneficiaryBankAccountNumber"]`).value = '';
                this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c = '';

                console.log('1');
                var dataFound = false;
                //Karan Singh 26-09-2022: CH : AutoPopulating Verified Bank Detail Data's
                if (this.objDisbursalPayee.Beneficiary_Name__c
                    && this.objDisbursalPayee.Beneficiary_Type__c) {

                    console.log('2');

                    this.listLoanApptTypeBankDetails.forEach(element => {


                        console.log(` element Loan Applicant - ${JSON.stringify(element['Loan_Applicant__r'])}`);

                        if (element['Loan_Applicant__r'].Customer_Type__c == this.objDisbursalPayee.Beneficiary_Type__c
                            && element['Loan_Applicant__r']['Customer_Information__r'].Name == this.objDisbursalPayee.Beneficiary_Name__c) {

                            dataFound = true;
                            console.log(` element Loan Applicant Match - ${JSON.stringify(element)}`);
                            this.objDisbursalPayee.Beneficiary_IFSC_Code__c = undefined;
                            this.showIsfcComp = false;
                            this.objDisbursalPayee.Beneficiary_Account_Type__c = element.hasOwnProperty('Account_Type__c') ? element.Account_Type__c : '';
                            this.template.querySelector(`[data-field="Beneficiary_Account_Type__c"]`).value = this.objDisbursalPayee.Beneficiary_Account_Type__c;

                            this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c = element.hasOwnProperty('Account_Number__c') ? element.Account_Number__c : '';

                            this.template.querySelector(`[data-field="Beneficiary_Bank_Account_Number__c"]`).value = this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c;

                            this.objDisbursalPayee.Beneficiary_IFSC_Code__c = element.hasOwnProperty('IFSC_Code__c') ? element.IFSC_Code__c : ''; //CH01 - addedIFSC_Code__c
                            //this.showIsfcComp = true;
                        }
                    });
                }
                if (!dataFound) {

                    console.log('No Auto Populate data found')
                    //if no match then reset
                    this.objDisbursalPayee.Beneficiary_Account_Type__c = '';
                    this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c = '';

                    this.objDisbursalPayee.Beneficiary_IFSC_Code__c = '';
                    this.objDisbursalPayee.Beneficiary_Bank_Name__c = '';
                    this.objDisbursalPayee.Beneficiary_Branch_Name__c = '';
                    if (this.template.querySelector(`[data-field="Beneficiary_Bank_Account_Number__c"]`)) {
                        this.template.querySelector(`[data-field="Beneficiary_Bank_Account_Number__c"]`).value = '';
                    }
                    if (this.template.querySelector(`[data-field="Beneficiary_Account_Type__c"]`)) {
                        console.log('account type nullified');
                        this.template.querySelector(`[data-field="Beneficiary_Account_Type__c"]`).value = '';

                    }
                    console.log(`no match - ${JSON.stringify(this.objDisbursalPayee)}`)

                    this.showIsfcComp = false;
                    this.showLoader = true;
                    setTimeout(() => {
                        this.showLoader = false;
                        this.showIsfcComp = true;
                    }, 500);
                }
                //CH01
                if (this.objDisbursalPayee.Beneficiary_IFSC_Code__c
                    && this.objDisbursalPayee.Beneficiary_IFSC_Code__c != '') {
                    this.fetchIfscDetails(this.objDisbursalPayee.Beneficiary_IFSC_Code__c);
                }
                console.log(` this.objDisbursalPayee final- ${JSON.stringify(this.objDisbursalPayee)}`);
                //==============================================================
            }
        } catch (error) {
            console.log(error);
        }
    }
    handleInputChange(event) {
        console.log('inside 473');
        console.log('this.objDisbursalPayee is 469 >>>', this.objDisbursalPayee);
        console.log(`Input change - ${event.target.dataset.field} and value ${event.detail.value}`);
        this.setFieldChanges.add(event.target.dataset.field);
        this.objDisbursalPayee[event.target.dataset.field] = event.detail.value;

        if (event.target.dataset.field == 'Beneficiary_Amount__c') {

            this.objDisbursalPayee[event.target.dataset.field] = Math.round(this.objDisbursalPayee[event.target.dataset.field] * 100) / 100;
        }
        //CH01
        if (event.target.dataset.field == 'Beneficiary_IFSC_Code__c') {

            this.objDisbursalPayee.Beneficiary_Bank_Name__c = '';
            this.objDisbursalPayee.Beneficiary_Branch_Name__c = '';

        }
        console.log('this.objDisbursalPayee is 485 >>>', this.objDisbursalPayee);


        console.log(this.setFieldChanges);
    }
    //CH01
    handleKeyUp(event) {
        console.log('inside 497');
        console.log(`handleKeyUp change - ${event.target.dataset.field}`);

        if (event.target.dataset.field == 'Beneficiary_IFSC_Code__c') {

            console.log(`keycode ${event.keyCode} - ${this.objDisbursalPayee.Beneficiary_IFSC_Code__c}`);

            if (event.keyCode === 13) {

                var htmlElementIfsc = this.template.querySelector(`[data-field="Beneficiary_IFSC_Code__c"]`);
                console.log('checkValidity ' + htmlElementIfsc.checkValidity());

                if (this.objDisbursalPayee.Beneficiary_IFSC_Code__c
                    && this.objDisbursalPayee.Beneficiary_IFSC_Code__c != ''
                    && htmlElementIfsc.checkValidity()) {
                    this.fetchIfscDetails(this.objDisbursalPayee.Beneficiary_IFSC_Code__c);
                }
            }
        }
    }
    handleBtnClick(event) {
        console.log('inside 518');
        console.log('checkbox index' + event.target.dataset.index);
        console.log('checkbox name' + event.target.dataset.name);
        console.log('checkbox checked' + event.target.dataset.checked);
        if (event.target.dataset.name == 'enableDisbPayeeEdit') {
            this.isNewRecord = true;
            console.log('inside 514', this.objDisbursalPayee);
            console.log('inside me');
            this.objDisbursalPayee = {};
            this.enableDisbPayeeEdit = true;
            this.disableSaveEditBtn = false;
            this.reInitDisbPayee();

        } else if (event.target.dataset.name == 'checkboxBtn') {

            console.log('checkbox index 521' + event.target.dataset.index);
            this.listExistDisbursalPayees[event.target.dataset.index].sobject.Is_Deduct_From__c = !this.listExistDisbursalPayees[event.target.dataset.index].sobject.Is_Deduct_From__c;

            /* Karan Singh : 29-09-2022 : This is commented so that user can create multiple records after amount is balance else if amount is balance and checkbox is trur then even we change amount it will be balance in the deducted record 
            if (this.listExistDisbursalPayees[event.target.dataset.index].sobject.Is_Deduct_From__c) {
                this.enableSaveAmtBtn = true;
            } else {
                this.enableSaveAmtBtn = false;
            }*/
            this.enableSaveAmtBtn = true;
            this.disableEditDel = true;//Karan Singh : 13-10-2022 : CH - This is done so that while selecting Deduct from Edit and Delete should be 
            this.listExistDisbursalPayees.forEach(element => {
                console.log(element);
                if (element.sobject.Id != this.listExistDisbursalPayees[event.target.dataset.index].sobject.Id) {
                    element.sobject.Is_Deduct_From__c = false;
                }
            });
        } else if (event.target.dataset.name == 'pennydrop') {
            console.log('the Id of the check is >>',this.listExistDisbursalPayees[event.target.dataset.index].sobject.Id);
            this.showLoader = true;
            callPennyDropAPI({
                disbPayee: this.listExistDisbursalPayees[event.target.dataset.index].sobject.Id
            }).then((result) => {

                console.log('callPennyDropAPI  = ', JSON.stringify(result));
                if (result) {
                    this.showNotification('', 'Penny Drop - ' + result, 'info');
                }
                this.showLoader = false;
                this.initData();

            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in getIfscDetails = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });

        }
    }
    handleBlurChange(event) {
        console.log('inside 574');
        console.log('Blur Change');
        console.log(event.target.dataset.label);
        console.log(event.target.dataset.field)
        this.isAccntEntered = true;
        this.setFieldChanges.add(event.target.dataset.field);
        if (event.target.dataset.label == 'BeneficiaryBankAccountNumber') {

            var value = this.template.querySelector(`[data-label="BeneficiaryBankAccountNumber"]`).value;
            console.log('BeneficiaryBankAccountNumber Value ' + value);
            this.objDisbursalPayee[event.target.dataset.field] = value;
            this.tempAccntNumber = value;
            this.reEnterAccntNumber = undefined;
            if (this.tempAccntNumber) {
                this.template.querySelector(`[data-label="BeneficiaryBankAccountNumber"]`).value = 'xxxxxxxxxxxxxxxx';

                setTimeout(() => {
                    this.template.querySelector(`[data-label="BeneficiaryBankAccountNumberCheck"]`).focus();
                }, 500);
                this.accMisMatchMsg1 = '';
                this.template.querySelector(`[data-label="BeneficiaryBankAccountNumber"]`).style = '';
            } else {
                this.accMisMatchMsg1 = 'Complete this field.';
            }
        }
        if (event.target.dataset.label == 'BeneficiaryBankAccountNumberCheck') {
            var value = this.template.querySelector(`[data-label="BeneficiaryBankAccountNumberCheck"]`).value;
            console.log('BeneficiaryBankAccountNumberCheck Value ' + value);
            this.reEnterAccntNumber = value;
            if (this.reEnterAccntNumber) {
                this.accMisMatchMsg2 = '';
                this.template.querySelector(`[data-label="BeneficiaryBankAccountNumberCheck"]`).style = ''
            } else {
                this.accMisMatchMsg1 = 'Complete this field.';
            }

        }
        console.log(this.setFieldChanges);
    }
    /*CH01 : Deprecated
    handleLookupChange(event) {

        console.log(event.detail);
        console.log(typeof event.detail);
        if (event.detail && typeof event.detail == typeof '') {
            this.fetchIfscDetails(event.detail);
            this.objDisbursalPayee.Beneficiary_IFSC_Code__c = event.detail;
            this.isfcCodeMissErr = '';
        } else {
            this.objDisbursalPayee.Beneficiary_Bank_Name__c = undefined;
            this.objDisbursalPayee.Beneficiary_Branch_Name__c = undefined;
            this.objDisbursalPayee.Beneficiary_IFSC_Code__c = undefined;
            this.isfcCodeMissErr = 'Complete this field.';
        }
        this.setFieldChanges.add('Beneficiary_IFSC_Code__c');
        console.log(this.setFieldChanges);
    }*/
    handleEditRecord(event) {
        console.log('inside 632');
        this.showLoader = true;
        console.log(event.target.dataset.index);
        console.log(JSON.stringify(this.listExistDisbursalPayees[event.target.dataset.index]));
        this.reInitDisbPayee();
        for (const key in this.objDisbursalPayee) {

            if (this.listExistDisbursalPayees[event.target.dataset.index].sobject.hasOwnProperty(key)) {
                this.objDisbursalPayee[key] = this.listExistDisbursalPayees[event.target.dataset.index].sobject[key];
            }
        }

        //Karan : CH : 23/09/2022 : if deduct record is edited then replace the beneficiary amount with adjusted amount
        if (this.listExistDisbursalPayees[event.target.dataset.index].sobject.Is_Deduct_From__c) {
            this.objDisbursalPayee['Beneficiary_Amount__c'] = this.listExistDisbursalPayees[event.target.dataset.index].sobject.Adjusted_Beneficiary_Amount__c;
            this.objDisbursalPayee['Adjusted_Beneficiary_Amount__c'] = null;
            this.objDisbursalPayee['Is_Deduct_From__c'] = false;
        }
        console.log('this.objDisbursalPayee in edit ' + JSON.stringify(this.objDisbursalPayee));
        this.tempAccntNumber = '';
        this.reEnterAccntNumber = '';
        this.accMisMatchMsg1 = '';
        this.accMisMatchMsg2 = ''; //border : 2px solid red
        this.disbErrorMsg1 = '';
        this.disbErrorMsg2 = '';
        this.isfcCodeMissErr = '';
        this.isAccntEntered = false;
        this.currentEditDisbPayeeId = this.objDisbursalPayee.Id;
        this.enableDisbPayeeEdit = true;
        this.disableSaveEditBtn = false;
        this.tempAddedBenificiaryType = this.objDisbursalPayee.Beneficiary_Type__c;
        //this.listBenificiaryType.push({ label: this.objDisbursalPayee.Beneficiary_Type__c, value: this.objDisbursalPayee.Beneficiary_Type__c }); Karan Singh : 27/09/2022 : CH

        setTimeout(() => {
            this.template.querySelector(`[data-label="BeneficiaryBankAccountNumber"]`).value = this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c;
            this.reEnterAccntNumber = this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c;
            this.isAccntEntered = false;
            console.log('After  ' + JSON.stringify(this.objDisbursalPayee));

            console.log('this.addNewBeneficiary - ' + this.addNewBeneficiary);
            console.log('this.listBenificiaryType - ' + JSON.stringify(this.listBenificiaryType));

            //incase if all beneficary is added ,so give current record option of beneficary type
            //if (!this.addNewBeneficiary) {
            //this.listBenificiaryType = [];
            //}
            console.log('this.listBenificiaryType After - ' + JSON.stringify(this.listBenificiaryType));

            if (this.objDisbursalPayee.hasOwnProperty('Beneficiary_Type__c')
                && this.objDisbursalPayee.Beneficiary_Type__c != 'BT Bank'
                && this.objDisbursalPayee.Beneficiary_Type__c != 'Third Party') {

                this.template.querySelector(`[data-field="Beneficiary_Name__c"]`).disabled = true;

            } else {
                this.template.querySelector(`[data-field="Beneficiary_Name__c"]`).disabled = false;
            }
            this.showLoader = false;
        }, 500);
    }
    handleCancel() {
        this.isNewRecord = false;
        console.log('inside 693');
        var index = 0;
        var benifIndex = null;
        this.listBenificiaryType.forEach(element => {
            if (element.label == this.tempAddedBenificiaryType) {
                benifIndex = index;
            }
            index++;
        });
        if (benifIndex) {
            this.listBenificiaryType.splice(benifIndex, 1);
        }
        this.objDisbursalPayee = null;
        this.currentEditDisbPayeeId = null;
        this.enableDisbPayeeEdit = false;
        this.disableSaveEditBtn = true;
    }
    handleAmtAdjust(event) {
        console.log('inside 711');
        console.log('handleAmtAdjust called');
        var listSobjects = [];
        try {


            this.listExistDisbursalPayees.forEach(element => {

                console.log(JSON.stringify(element));
                console.log(`is Deduct ${element.sobject.Is_Deduct_From__c} , benif adjust ${element.sobject.Adjusted_Beneficiary_Amount__c} , benif ${element.sobject.Beneficiary_Amount__c} `);


                var objJsonDisbPayee = { 'sobjectType': 'Disbursal_Payee__c', "Id": element.sobject.Id, "Is_Deduct_From__c": element.sobject.Is_Deduct_From__c, "Adjusted_Beneficiary_Amount__c": null };

                //==================================================================
                if (element.sobject.Is_Deduct_From__c) {
                    var benifAmt = element.sobject.Beneficiary_Amount__c;
                    console.log('Before benifAmt ' + benifAmt);
                    console.log('this.finalDIsbAmount ' + this.finalDIsbAmount);
                    this.calcTotalBenificiaryAmt(element.sobject.Id); //this is done recalculate the exisitng beneficiary amount
                    console.log('this.existBenificiaryAmt ' + this.existBenificiaryAmt);
                    //benifAmt = benifAmt + (this.finalDIsbAmount - this.existBenificiaryAmt); Karan Singh :CH : 24/09/2022
                    benifAmt = (this.finalDIsbAmount - this.existBenificiaryAmt);
                    console.log('After benifAmt 1' + benifAmt);
                    objJsonDisbPayee['Adjusted_Beneficiary_Amount__c'] = benifAmt;
                    console.log('objJsonDisbPayee - ' + JSON.stringify(objJsonDisbPayee));

                    //Karan Singh : 27/09/2022 : CH - Adjusted amount cannot be zero.
                    if (benifAmt <= 0) {
                        this.showNotification('ERROR', 'Benficiary amount of selected record is not sufficient to adjust. Please select another record.', 'error');
                        return;
                    }
                }

                listSobjects.push(objJsonDisbPayee);
            });
        } catch (error) {
            console.log('error ' + error);
        }
        console.log('listSobjects - ' + JSON.stringify(listSobjects));
        if (listSobjects.length > 0) {
            this.showLoader = true;
            this.enableSaveAmtBtn = true;
            this.listExistDisbursalPayees = [];
            if (event == null) {
                this.saveBulkRecords(listSobjects, false); //incase edit is done then rebalance occured, then no need to show two toast message
            } else {
                this.saveBulkRecords(listSobjects, true);
            }

        }
    }
    //--------------------------------------------------------------------------
    viewDocument(event) {
        console.log('inside 765');
        console.log(this.listExistDisbursalPayees[event.target.dataset.index].sobject.Id);
        var disbPayeeId = this.listExistDisbursalPayees[event.target.dataset.index].sobject.Id;
        if (this.mapDisbPayeeIdWithDocumentId.has(disbPayeeId)) {

            this.navigateDocument(this.mapDisbPayeeIdWithDocumentId.get(disbPayeeId));
        } else {

            this.showLoader = true;
            getDocumentId({
                parentId: this.mapDisbPayeeIdWithDocumentId.get(disbPayeeId),
                documentPrefix: this.obj_parent_appt_wrapper_data.disbMetaPrefix
            }).then((result) => {

                console.log('getDocumentId  = ', JSON.stringify(result));
                if (result.length > 0) {
                    this.navigateDocument(result[0].ContentDocumentId);
                    this.mapDisbPayeeIdWithDocumentId.set(disbPayeeId, result[0].ContentDocumentId);
                }
                this.showLoader = false;

            }).catch((err) => {

                //incase if any Salesforce exception happened it will show notification
                console.log('Error in getDocumentId = ', err);
                this.showNotification('ERROR', err.message, 'error');
                this.showLoader = false;
            });
        }

    }
    //Karan Singh : 27/09/2022 : CH
    deleteRecord(event) {
        console.log('inside 798');
        console.log(this.listExistDisbursalPayees[event.target.dataset.index].sobject.Id);
        var arrDeleteSobjects = [];
        arrDeleteSobjects.push({ 'sobjectType': 'Disbursal_Payee__c', 'Id': this.listExistDisbursalPayees[event.target.dataset.index].sobject.Id });
        this.showLoader = true;
        deleteRecords({
            listSobjects: arrDeleteSobjects
        }).then((result) => {

            console.log(`deleteRecord result - ${JSON.stringify(result)}`);
            if (result.statusCode !== 200
                && result.statusCode !== 201) {

                this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification

            } else {
                this.showNotification('SUCCESS', 'Record deleted successfully.', 'success');
                this.initData();
            }
            this.showLoader = false;

        }).catch((err) => {

            //incase if any Salesforce exception happened it will show notification
            console.log('Error in deleteRecord = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.showLoader = false;
        });

    }
    navigateDocument(contentDocId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: contentDocId
            }
        })

    }
    //==========================================================================
    /** Karan Singh : 03-10-2022 : CH */
    @api
    getDeductionAmount() {
        console.log('inside 845');
        this.true = false;
        getDeductionAmount({
            apptId: this.obj_parent_appt_wrapper_data.objAppt.Id
        }).then((result) => {

            console.log('Fiv_Disb_DisbursalPayee getDeductionAmount = ', JSON.stringify(result));
            this.objdeductiondetails = result.mapExtraParams;
            console.log(`result ${typeof this.objdeductiondetails} and objDeduction - ${JSON.stringify(this.objdeductiondetails)}`);
            this.checkTotalBenifAmtCalc();


            this.showLoader = false;
        }).catch((err) => {

            console.log('Error in Fiv_Disb_DisbursalPayee getDeductionAmount = ', err);
            this.showLoader = false;
        });
    }
    /** Karan Singh : 03-10-2022 : CH */
    checkTotalBenifAmtCalc() {
        console.log('inside 866');
        this.finalDIsbAmount = 0;
        this.insurancePremium = this.objdeductiondetails.totalInsurancePremium;
        this.insuranceTotalFee = this.objdeductiondetails.totalFeeDeduction;

        console.log('checkTotalBenifAmtCalc.existBenificiaryAmt ', this.existBenificiaryAmt);
        console.log('checkTotalBenifAmtCalc.sanctionLoanAmt ', this.sanctionLoanAmt);
        console.log('checkTotalBenifAmtCalc.insurancePremium ', this.insurancePremium);
        console.log('checkTotalBenifAmtCalc.insuranceTotalFee ', this.insuranceTotalFee);

        this.finalDIsbAmount = this.sanctionLoanAmt - this.insurancePremium - this.insuranceTotalFee;
        this.finalDIsbAmount = Math.round(this.finalDIsbAmount * 100) / 100;

        console.log('checkTotalBenifAmtCalc.finalDIsbAmount ' + this.finalDIsbAmount);
        this.isBennifAmtMatchDisbAmt = this.existBenificiaryAmt === this.finalDIsbAmount ? true : false;

        console.log('checkTotalBenifAmtCalc.isBennifAmtMatchDisbAmt' + this.isBennifAmtMatchDisbAmt);
        if (this.isBennifAmtMatchDisbAmt) {
            this.enableSaveAmtBtn = false;
        } else {
            this.enableSaveAmtBtn = true;
        }
        if (this.listExistDisbursalPayees.length == 0) {
            this.isBennifAmtMatchDisbAmt = true;
        }
        console.log('checkTotalBenifAmtCalc isBennifAmtMatchDisbAmt' + this.isBennifAmtMatchDisbAmt);

    }
    //==========================================================================

    @api
    checkBeforeSubmit() {
        console.log('inside 898');
        var custEvt;
        if (!this.isBennifAmtMatchDisbAmt) {

            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: false, msg: 'Disbursal Payee : Total beneficiary amount is not matching with disbursement amount.Please select a record to adjust.', fieldName: 'disbPayee' }
            });
        } else if (this.listExistDisbursalPayees.length = 0) {
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: false, msg: 'Disbursal Payee : Please add atleast one beneficiary.', fieldName: 'disbPayee' }
            });
        } else {
            custEvt = new CustomEvent("checkbeforesubmit", {
                detail: { isValid: true, msg: '', fieldName: 'disbPayee' }
            });
        }

        this.dispatchEvent(custEvt);
    }

    checkDisbTypeVal() {
        this.showLoader = true;
        console.log('inside 919');
        console.log('inside 912', this.objDisbursalPayee);        
        getDisbursalData({ appId: this.obj_parent_appt_wrapper_data.objAppt.Id }).then((result) => {
            console.log('result setDisbTypeVal is >>>>', result);
            if (result) {
                this.setDisbTypeVal = result;
                this.handleSave();
                console.log('this.setDisbTypeVal is >>>>', this.setDisbTypeVal);

            } else {
                console.log('result else setDisbTypeVal is >>>>', result);
                console.log('inside 923', this.objDisbursalPayee);
                this.handleSave();
            }
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });
    }

    handleSave() {
        if (this.isNewRecord) {
            console.log('inside 943', this.objDisbursalPayee);
            let tempRecord = JSON.parse(JSON.stringify(this.objDisbursalPayee));
            tempRecord.Id = undefined;
            this.objDisbursalPayee = undefined;
            this.objDisbursalPayee = JSON.parse(JSON.stringify(tempRecord));
            this.objDisbursalPayee.Id = undefined;
            console.log('inside 948', this.objDisbursalPayee);

            let tempRecord2 = JSON.parse(JSON.stringify(this.objDisbursalPayee));
            this.objDisbursalPayee = JSON.parse(JSON.stringify(tempRecord2));
            console.log('inside 948', this.objDisbursalPayee);
        }

        console.log('inside 924', this.objDisbursalPayee);
        this.showLoader = true;
        this.disableSaveEditBtn = true;
        this.fileErrMsg = '';
        try {

            var allDataChecked = this.validateDisbData();
            var validAccntNum = this.validateAccntNumber();
            //now checking the disbursal record
            console.log(' allDataChecked - ' + allDataChecked);
            console.log(' validAccntNum - ' + validAccntNum);

            if (!this.fileData.hasOwnProperty('filename') && !this.currentEditDisbPayeeId) {

                //that means the file is not uploaded
                this.fileErrMsg = 'Please upload Bank Proof.';
                this.delaySaveAndSaveReset(false, false);
                return;
            }

            if (allDataChecked && validAccntNum) {

                var htmlElement = this.template.querySelector(`[data-field="Beneficiary_Amount__c"]`);

                if (this.objDisbursalPayee.Beneficiary_Amount__c <= 0) {

                    htmlElement.setCustomValidity('Beneficiary Amount cannot be 0.');
                    htmlElement.reportValidity();
                    this.delaySaveAndSaveReset(false, false);
                    return;
                }
                else {
                    htmlElement.setCustomValidity('');
                    htmlElement.reportValidity();

                }

                //only for new Disbursal Payee record 
                if (!this.objDisbursalPayee.Id) {
                    console.log('inside 963', this.objDisbursalPayee);
                    console.log('inside 938');
                    this.objDisbursalPayee.Disbursal__c = this.checkExistingDisbursalId();
                    console.log('inside 940', this.objDisbursalPayee.Disbursal__c);
                    this.objDisbursalPayee["Application__c"] = this.obj_parent_appt_wrapper_data.objAppt.Id;//Karan SIngh : 05-10-2022 : CH
                    console.log('inside 942', this.objDisbursalPayee["Application__c"]);
                    console.log('inside 943', this.objDisbursalPayee);
                    delete this.objDisbursalPayee['Id'];
                    console.log('inside 944', this.objDisbursalPayee);
                }
                //for edit scenario
                if (this.currentEditDisbPayeeId) {
                    console.log('inside 944', this.currentEditDisbPayeeId);
                    this.objDisbursalPayee.Id = this.currentEditDisbPayeeId;
                    console.log('inside 951', this.objDisbursalPayee);
                }
                console.log(` Save this.reEnterAccntNumber - ${this.reEnterAccntNumber} `);
                console.log(` Save this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c - ${this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c} `);

                //Karan Singh : 27/09/2022 : CH - incase of bank number autopopulate, user may not re-enter it.
                if (this.reEnterAccntNumber && this.reEnterAccntNumber != undefined) {

                    this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c = this.reEnterAccntNumber;
                } else {
                    this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c = this.template.querySelector(`[data-label="BeneficiaryBankAccountNumber"]`).value;
                }
                //==============================================================
                //resetting adjusted amount field
                this.objDisbursalPayee.Adjusted_Beneficiary_Amount__c = null;

                console.log(JSON.stringify(this.objDisbursalPayee));


                //==============================================================
                //Karan Singh : 27/09/2022 : CH - (NP-17-09-22) - H
                this.validateBankdetails()
                console.log(` isValidBankAccntDetails ${this.isValidBankAccntDetails} with ${this.existBankAccntDetailMatchName}`);
                if (!this.isValidBankAccntDetails) {

                    this.showNotification('ERROR', 'Bank Details are matching with - ' + this.existBankAccntDetailMatchName, 'error');
                    this.delaySaveAndSaveReset(false, false);
                    return;
                }
                //Karan Singh : 27/09/2022 : CH - (NP-17-09-22) - L
                if (!this.validateBenifAmount()) {

                    this.showNotification('ERROR', 'Total Benificairy amount is greater disbursement amount', 'error');
                    this.delaySaveAndSaveReset(false, false);
                    return;
                }

                //this is done so that penny drop should be done again for new record (Earlier Logic)
                if (!this.objDisbursalPayee.hasOwnProperty('Id')) {
                    console.log('1056 inside check penny >>>');
                    this.objDisbursalPayee.Is_Verified__c = false;
                }

                //Karan Singh : 27/09/2022 : CH - (NP-17-09-22) - I
                else {
                    console.log('1062 inside check penny >>>',this.setFieldChanges);

                    if (this.setFieldChanges.has("Beneficiary_Account_Type__c")
                        || this.setFieldChanges.has("Beneficiary_Bank_Account_Number__c")
                        || this.setFieldChanges.has("Beneficiary_IFSC_Code__c")
                    ) {
                        console.log('inside check penny 1067 >>>');
                        var isverified = 'false'; 
                        this.objDisbursalPayee.Is_Verified__c = false;
                        this.checkPennyDropStatus(this.objDisbursalPayee.Id,isverified);
                    }
                    else {
                        var isverified = 'true'; 
                        console.log('inside check penny Id 1073 >>>',this.objDisbursalPayee.Id);
                        this.checkPennyDropStatus(this.objDisbursalPayee.Id,isverified);
                        //this.objDisbursalPayee.Is_Verified__c = true;
                    }
                }
                //Karan SIngh : 04-10-2022 : CH : Incase of this , No loan appt should be link
                if (this.objDisbursalPayee.Beneficiary_Type__c == 'BT Bank'
                    || this.objDisbursalPayee.Beneficiary_Type__c == 'Third Party') {
                    console.log('removing loan appt id');
                    this.objDisbursalPayee.Loan_Applicant__c = "";
                }
                console.log('this.objDisbursalPayee before Save ' + JSON.stringify(this.objDisbursalPayee));
                //=================================================
                this.saveApex();
            }
            else {
                this.delaySaveAndSaveReset(false, false);
            }
        } catch (error) {
            console.log('Error disbPayee - ' + error);
            this.delaySaveAndSaveReset(false, true);
        }

    }

    checkPennyDropStatus(DisbursalPayeeId,isverified){
        console.log('DisbursalPayeeId 1099 is >>>>',DisbursalPayeeId);
        console.log('isverified 1099 is >>>>',isverified);
        getPennyDropStatus({ DisbPayeeId: DisbursalPayeeId,checkVerify:isverified }).then((result) => {
            console.log('result is >>>>',result);
            if(result){
                console.log('true result is >>>>',result);
                this.objDisbursalPayee.Is_Verified__c = true;
            }else if(!(result)){
                console.log('false result is >>>>',result);
                this.objDisbursalPayee.Is_Verified__c = false;
            }
        }).catch((err) => {
            this.isloaded = true;
            console.log('Error in getExistingRecord= ', err);
        });

    }




    //Karan Singh : 27/09/2022 : CH - (NP-17-09-22) - H ?: This method is used to check the bank details does not match with exisitng beneficiary bank details
    validateBankdetails() {
        console.log('Invoked validateBankdetails');
        //Karan Singh : 27/09/2022 : CH - (NP-17-09-22) - H
        //will be checked for both new and edit record case
        this.isValidBankAccntDetails = true;
        this.existBankAccntDetailMatchName = '';
        if (this.listExistDisbursalPayees
            && this.listExistDisbursalPayees.length > 0) {

            this.listExistDisbursalPayees.forEach(element => {

                console.log(this.objDisbursalPayee.hasOwnProperty('Id'));
                console.log(element.sobject.Beneficiary_Account_Type__c == this.objDisbursalPayee.Beneficiary_Account_Type__c);
                console.log(element.sobject.Beneficiary_Bank_Account_Number__c == this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c);
                //CH01 - console.log(element.sobject["Beneficiary_IFSC_Code__r"].Id == this.objDisbursalPayee.Beneficiary_IFSC_Code__c);
                //CH01 - console.log(element.sobject["Beneficiary_IFSC_Code__r"].Id);
                console.log(this.objDisbursalPayee.Beneficiary_IFSC_Code__c);

                if (this.objDisbursalPayee.hasOwnProperty('Id')) {
                    //Edit record Case    
                    if (this.setDisbTypeVal != 'Part Disb' && element.sobject.Id != this.objDisbursalPayee.Id
                        && element.sobject.Beneficiary_Account_Type__c == this.objDisbursalPayee.Beneficiary_Account_Type__c
                        && element.sobject.Beneficiary_Bank_Account_Number__c == this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c
                        /*CH01 - && element.sobject["Beneficiary_IFSC_Code__r"].Id == this.objDisbursalPayee.Beneficiary_IFSC_Code__c*/
                        && element.sobject.Beneficiary_IFSC_Code__c == this.objDisbursalPayee.Beneficiary_IFSC_Code__c
                    ) {

                        this.isValidBankAccntDetails = false;
                        this.existBankAccntDetailMatchName = element.sobject.Beneficiary_Name__c + ' - ' + element.sobject.Beneficiary_Type__c;
                    }
                } else {
                    //New case
                    if (this.setDisbTypeVal != 'Part Disb' && element.sobject.Beneficiary_Account_Type__c == this.objDisbursalPayee.Beneficiary_Account_Type__c
                        && element.sobject.Beneficiary_Bank_Account_Number__c == this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c
                        /*CH01 - && element.sobject["Beneficiary_IFSC_Code__r"].Id == this.objDisbursalPayee.Beneficiary_IFSC_Code__c*/
                        && element.sobject.Beneficiary_IFSC_Code__c == this.objDisbursalPayee.Beneficiary_IFSC_Code__c
                    ) {

                        this.isValidBankAccntDetails = false;
                        this.existBankAccntDetailMatchName = element.sobject.Beneficiary_Name__c + ' - ' + element.sobject.Beneficiary_Type__c;
                    }
                }
            });
        }
    }
    //Karan Singh : 27/09/2022 : CH - (NP-17-09-22) - L
    validateBenifAmount() {
        console.log('Invoked validateBenifAmount');
        console.log(` this.finalDIsbAmount - ${this.finalDIsbAmount} and disb payee - ${JSON.stringify(this.objDisbursalPayee.Beneficiary_Amount__c)} `);
        //this.finalDIsbAmount

        //incase exisitng records found
        if (this.listExistDisbursalPayees
            && this.listExistDisbursalPayees.length > 0) {

            var existBenifAmount = 0;
            //fetching exisitng disbursal payee amounts
            this.listExistDisbursalPayees.forEach(element => {

                //incase if exist record is being edit then skip as we will calc new value of it
                if (this.objDisbursalPayee.hasOwnProperty('Id')
                    && element.sobject.Id == this.objDisbursalPayee.Id) {
                    //skipp
                } else {
                    //if deduct is selected then we will use adjusted amount
                    existBenifAmount += element.sobject.Is_Deduct_From__c ? element.sobject.Adjusted_Beneficiary_Amount__c : element.sobject.Beneficiary_Amount__c
                }
            });

            console.log(`existBenifAmount - ${existBenifAmount}`);
            return this.finalDIsbAmount >= (this.objDisbursalPayee.Beneficiary_Amount__c + existBenifAmount) ? true : false;

        } else {
            //new record
            return this.finalDIsbAmount >= this.objDisbursalPayee.Beneficiary_Amount__c ? true : false;
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
    saveApex() {

        console.log('in save apex this.objDisbursalPayee >>>', this.objDisbursalPayee);

        //================================= Calling Saving Method ===============================
        saveDisbursalCompData({
            objDisbursal: this.objDisbursalPayee,
            base64: this.fileData.hasOwnProperty('base64') ? this.fileData.base64 : '',
            filename: this.fileData.hasOwnProperty('filename') ? this.fileData.filename : '',
            prntRecordId: ''

        }).then((result) => {

            console.log('Fiv_Disb_Lwc Saved sfObjJSON = ', JSON.stringify(result));

            if (result.statusCode !== 200
                && result.statusCode !== 201) {

                this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                this.delaySaveAndSaveReset(false, false);
            } else {
                this.isNewRecord = false;
                this.showNotification('SUCCESS', result.message, 'success');
                var custEvt = new CustomEvent("reloadapplicationdata", {
                    detail: {}
                });
                this.dispatchEvent(custEvt);

                //Karan : 23/09/2022 : Incase if there is any amount change in current record and there is already deduct from selected then need to update the amount on the selected deduct from record
                console.log('Fiv_Disb_Lwc Saved listExistDisbursalPayees = ', JSON.stringify(this.listExistDisbursalPayees));
                if (this.listExistDisbursalPayees && this.listExistDisbursalPayees.length > 0
                    && this.objDisbursalPayee.hasOwnProperty("Id")) {

                    console.log('Fiv_Disb_Lwc Saved this.objDisbursalPayee = ', JSON.stringify(this.objDisbursalPayee));
                    //for existing record
                    if (this.objDisbursalPayee.hasOwnProperty("Id")) {

                        //  FIRST WE WILL upddate the latest changes in the list then we will recalcuate it
                        this.listExistDisbursalPayees.forEach(element => {

                            if (element.sobject.Id == this.objDisbursalPayee.Id) {

                                //we will update that particular record in the list
                                for (const key in this.objDisbursalPayee) {

                                    if (element.sobject.hasOwnProperty(key)) {
                                        element.sobject[key] = this.objDisbursalPayee[key];
                                    }
                                }
                                console.log()
                            }
                        });
                        this.handleAmtAdjust(null);
                    }

                } else {
                    this.initData();//this will show the data table;
                }
            }
            //this.showLoader = false; //this is removed as loader will be  false once data is load
        }).catch((err) => {

            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc handleSave = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.delaySaveAndSaveReset(false, false);
        });

        //=================================  Saving Method END ===============================
    }
    //Karan Singh : 24/09/2022 : CH - incase of changes in the selection of deduct from checkbox
    saveBulkRecords(listSobjects, showMsg) {
        console.log('inside 1230');
        saveSobjectLists({
            listSobjects: listSobjects
        }).then((result) => {

            console.log('Fiv_Disb_Lwc Saved listSobjects = ', JSON.stringify(result));

            if (result.statusCode !== 200) {

                this.showNotification('ERROR', result.message, 'error'); //incase if any apex exception happened it will show notification
                this.delaySaveAndSaveReset(false, false);

            } else {

                if (showMsg) {
                    this.showNotification('SUCCESS', result.message, 'success');
                }

                var custEvt = new CustomEvent("reloadapplicationdata", {
                    detail: {}
                });
                this.dispatchEvent(custEvt);
                this.listExistDisbursalPayees = [];
                this.initData();//this will show the data table;

            }
            //this.showLoader = false; //this is removed as loader will be  false once data is load
        }).catch((err) => {

            //incase if any Salesforce exception happened it will show notification
            console.log('Error in Fiv_Disb_Lwc listSobjects = ', err);
            this.showNotification('ERROR', err.message, 'error');
            this.delaySaveAndSaveReset(false, false);
        });
    }
    validateDisbData() {
        console.log('inside 1266');
        var isValidData = true;
        this.disbErrorMsg1 = '';
        this.disbErrorMsg2 = '';
        this.accMisMatchMsg1 = '';
        this.accMisMatchMsg2 = ''; //border : 2px solid red
        this.isfcCodeMissErr = '';
        //checking input fields 
        this.template.querySelectorAll("lightning-input").forEach(element => {
            console.log('element Input Name ' + element.label + ' Value : ' + element.value);
            if (element.label == 'Beneficiary Bank Name') {

                if (!element.value) {
                    console.log('False ' + element.label);
                    this.disbErrorMsg1 = 'Complete this field.';
                    isValidData = false; //CH01
                    //element.style = 'border : 2px solid red;';
                } else {
                    this.disbErrorMsg1 = '';
                    element.style = '';
                }

            } else if (element.label == 'Beneficiary Branch Name') {

                if (!element.value) {
                    console.log('False ' + element.label);
                    this.disbErrorMsg2 = 'Complete this field.';
                    isValidData = false; //CH01
                    //element.style = 'border : 2px solid red;';
                } else {
                    this.disbErrorMsg2 = '';
                    element.style = '';
                }
            } else if (element.label &&
                (element.label == 'Bank Proof Image Upload' || element.label.includes('DISBM_BankProof')
                    || element.label.includes('DISBA_BankProof'))) {
                console.log('False ' + element.label);
                //element.setCustomValidity('Please upload Bank Proof.');
                //Tells the lightning-input to show the error right away without needing interaction 
                //element.reportValidity();
            }
            else if (!element.value && element.label) {
                console.log('False ' + element.label);
                element.reportValidity();
                console.log(element.label + ' false.');
                isValidData = false;

            }
        });
        console.log('Input valid Data ' + isValidData);
        //checking combobox
        this.template.querySelectorAll("lightning-combobox").forEach(element => {
            console.log('element Combo Name ' + element.label + ' Value : ' + element.value);
            if (!element.value) {
                console.log('False ' + element.label);
                element.reportValidity();
                isValidData = false;
            }
        });
        console.log('combobox valid Data ' + isValidData);
        this.template.querySelectorAll("input").forEach(element => {
            console.log('element html input Name ' + element.label + ' Value : ' + element.value);
            if (!element.value) {
                console.log('False ' + element.label);
                this[element.dataset.errormsg] = 'Complete this field.';
                element.style = "border : 2px solid red;";
                isValidData = false;
            } else {
                element.style = "";
            }
        });
        console.log('Html input valid Data ' + isValidData);

        console.log('ISFC Id ' + this.objDisbursalPayee.Beneficiary_IFSC_Code__c);
        if (!this.objDisbursalPayee.Beneficiary_IFSC_Code__c) {

            this.isfcCodeMissErr = 'Complete this field.';
            isValidData = false;
        } else {
            this.isfcCodeMissErr = '';
        }
        return isValidData;
    }

    validateAccntNumber() {
        console.log('inside 1351');
        console.log(this.isAccntEntered);
        if (!this.isAccntEntered) {//incase of edit, user didnot re-entered accnt number so bypass it
            return true;
        }
        else if (this.tempAccntNumber == this.reEnterAccntNumber) {
            console.log('valid accnt number');
            this.objDisbursalPayee.Beneficiary_Bank_Account_Number__c = this.reEnterAccntNumber;
            return true;
        } else {
            this.reEnterAccntNumber = undefined;
            this.accMisMatchMsg2 = 'Entered account number does not matched';
            console.log('invalid accnt number');
            return false;
        }
    }
    //skipId : this id amount will be skipped. Mainly for edt case as exist record is choose to edit to it will have new Beneficiary value
    calcTotalBenificiaryAmt(skipId) {
        console.log('inside 1369');
        this.existBenificiaryAmt = 0;
        if (this.listExistDisbursalPayees.length > 0) {

            this.listExistDisbursalPayees.forEach(element => {

                console.log('Recalculate record - ' + JSON.stringify(element));
                if (skipId && element.sobject.Id == skipId) {
                    //for future code purpose
                    console.log('skipId ' + skipId);
                } else {
                    this.existBenificiaryAmt += element.sobject.Beneficiary_Amount__c ? (Math.round(parseFloat(element.sobject.Beneficiary_Amount__c) * 100) / 100) : 0;
                }
            });
        } else {
            this.existBenificiaryAmt = 0;
        }
        console.log(' Recalulated existBenificiaryAmt ' + this.existBenificiaryAmt);
    }
    //--------------------------------------------------------------------------
    showNotification(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }
}