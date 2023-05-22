import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import getApplicantRecords from '@salesforce/apex/DatabaseUtililty.getApplicantRecords';
import getApplicationDetails from '@salesforce/apex/DatabaseUtililty.getApplicationDetails';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId';
import getPropertyTableData from '@salesforce/apex/LegalOpinionApprovalController.getPropertyTableData';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import getPropertyDetails from '@salesforce/apex/LegalOpinionApprovalController.getPropertyDetails';
import saveLegalApprovalProperty from '@salesforce/apex/LegalOpinionApprovalController.saveLegalApprovalProperty';
import handleLegalApprovalSubmit from '@salesforce/apex/LegalOpinionApprovalController.handleLegalApprovalSubmit';
import generateLegalCamReport from '@salesforce/apex/LegalOpinionApprovalController.generateLegalCamReport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import ApplicationId from '@salesforce/schema/Legal_Approval__c.Application__c';
import FileType from '@salesforce/schema/Application__c.File_Type__c';
import AnyApprovalToBeObtained from '@salesforce/schema/Application__c.Any_Approval_to_be_Obtained__c';
import SanctionAmountRestriction from '@salesforce/schema/Application__c.Sanction_Amount_Restriction__c';
import PendingCategory from '@salesforce/schema/Application__c.Pending_Category__c';
import LegalPending from '@salesforce/schema/Application__c.Legal_Pending__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import DOC_TYPE from '@salesforce/schema/Property__c.Document_Type__c';
import LINK_DOC_STATUS from '@salesforce/schema/Property__c.Link_Doc_Status__c';
import LINK_DOC_TYPES from '@salesforce/schema/Property__c.Link_Document_Type__c';
import SUPPORTING_DOCS from '@salesforce/schema/Property__c.Supporting_Document_SD__c';
import SD_IN_NAMES from '@salesforce/schema/Property__c.SD_in_name_of__c';
import ONLINE_GUIDELINE_VALUE_SEARCH from '@salesforce/schema/Property__c.Online_Guideline_Value_Search__c';
import LOGIN_EC_TYPE from '@salesforce/schema/Property__c.Login_EC_Type__c';
import ONLINE_EC_STATUS from '@salesforce/schema/Property__c.Online_EC_Status__c';
import EXISTING_ENCUMBERANCES from '@salesforce/schema/Property__c.Existing_Encumberances__c';
import BusinessDate from '@salesforce/label/c.Business_Date';
import requiredDocs from '@salesforce/label/c.Legal_Approval_Required_Docs';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';
import USER_ID from '@salesforce/user/Id';
import EMPLOYEE_ID_FIELD from '@salesforce/schema/User.EmployeeNumber';

const rowAction = [{
    label: 'Action',
    type: 'button-icon',
    typeAttributes: {
        iconName: 'utility:edit',
        title: 'Edit',
        variant: 'border-filled',
        alternativeText: 'Edit',
        name: 'edit'
    }
}];

export default class LegalApprovalLWC extends NavigationMixin(LightningElement) {
    @api applicationId;
    @api recordId;

    @track customerMap;
    @track customerList;
    @track propertyMap;
    @track propertyList;
    @track loanApplicantMap;
    @track applicationObj;
    @track requiredDocuments;

    @track propertyTableData;

    @track selectedCustomerId;
    @track loanApplicantId;
    @track newPropertyId;
    @track recordTypeId;
    @track loginId;
    @track todaysDate1 = BusinessDate;
    @track applicationName;
    @track lastLoginDate;
    @track recordTypeName;
    @track isDisable = false;
    @track isDisabled = false;
    @track isDisable1 = false;
    @track isRequired = false;
    @track pendingDisabled = false;

    @track showMultiPicklist = true;
    @track callOnce = false;
    @track showLoader = false;
    @track rowAction = rowAction;
    @track LegalApprovalDocs;
    @track legalApValidation = {
        firstFromValid: false,
        secondFromValid: false,
        thirdFromValid: false,
        fourthFromValid: false,
        isReportGenerated: false,
        allDocUploaded: true
    };

    @track button = [
        {
            name: 'Submit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'Legal Cam Report',
            label: 'Legal Cam Report',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'pendingReason',
            label: 'Pending Reason',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ];
    @track titleDocValues;
    @track documentTypes;
    @track linkDocStatusValues;
    @track linkDocumentTypes;
    @track sdNames;
    @track supportingDocuments;
    @track onlineGuideLineValues;
    @track loginECTypes;
    @track onlineECStatusValues;
    @track existingEncumberances;
    @track formObj = {
        Title_Document_in_Name_of__c: undefined,
        Title_Deed_Number__c: undefined,
        Title_Deed_Date__c: undefined,
        Document_Type__c: undefined,
        Survey_Number__c: undefined,
        Plot_No__c: undefined,
        House_Door_No__c: undefined,
        Property_Number__c: undefined,
        Village__c: undefined,
        District__c: undefined,
        MS_Pincode__c: undefined,
        Extent_Sqft__c: undefined,
        Supporting_Document_SD__c: undefined,
        SD_in_name_of__c: undefined,
        SD_Date__c: undefined,
        Link_Doc_Status__c: undefined,
        Link_Document_Type__c: undefined,
        Link_Doc_Date__c: undefined,
        Link_Documents_in_Name_of__c: undefined,
        Login_EC_Type__c: undefined,
        Login_EC_Number__c: undefined,
        Login_EC_Date_From__c: undefined,
        Login_EC_Date_Till__c: undefined,
        Online_EC_Status__c: undefined,
        Online_EC_Date_From__c: undefined,
        Online_EC_Date_Till__c: undefined,
        GuidelineValue_SqFt_asPer_LegalOpinion__c: undefined,
        Online_Guideline_Value_Search__c: undefined,
        Online_Guidelive_Value__c: undefined,
        Existing_Encumberances__c: undefined,
        Remarks_In_Encumberance__c: undefined,
    };

    @track sanctionAmountVal = undefined;
    @track fileType = undefined;
    @track anyApproval = undefined;
    @track legalPending = undefined;
    @track titleDeedDate = undefined;
    @track encumRemarks = undefined;
    @track loginEcDateTill;
    @track onlineEcDateTill;
    @track linkDocDate;
    @track userId = USER_ID;
    @track employeeId;

    @track errorMsgs;
    @track showErrorTab = false;
    @track tabName = "Property";
    @track sanctionAmountValue;
    @track showPendingReason = false;

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getRecordType({ data, error }) {
        if (data) {
            console.log(':: data :: ', JSON.stringify(data));
            const rtis = data.recordTypeInfos;
            this.recordTypeName = Object.keys(rtis).find(rti => rtis[rti].name === 'Legal Approval');
        } else if (error) {

        }
    }
    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: DOC_TYPE })
    documentTypePicklistInfo({ data, error }) {
        if (data) this.documentTypes = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: LINK_DOC_STATUS })
    linkDocStatuPicklistInfo({ data, error }) {
        if (data) this.linkDocStatusValues = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: LINK_DOC_TYPES })
    linkDocTypePicklistInfo({ data, error }) {
        if (data) this.linkDocumentTypes = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: SUPPORTING_DOCS })
    supportingDocsPicklistInfo({ data, error }) {
        if (data) this.supportingDocuments = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: SD_IN_NAMES })
    sdNamesOfPicklistInfo({ data, error }) {
        if (data) this.sdNames = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: ONLINE_GUIDELINE_VALUE_SEARCH })
    onlineGuideLineValuesPicklistInfo({ data, error }) {
        if (data) this.onlineGuideLineValues = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: ONLINE_EC_STATUS })
    onlineECStatusValuesPicklistInfo({ data, error }) {
        if (data) this.onlineECStatusValues = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: LOGIN_EC_TYPE })
    loginECTypesPicklistInfo({ data, error }) {
        if (data) this.loginECTypes = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: EXISTING_ENCUMBERANCES })
    existingEncumberancesPicklistInfo({ data, error }) {
        if (data) this.existingEncumberances = data.values;
    }

    @wire(getRecord, { recordId: '$userId', fields: [EMPLOYEE_ID_FIELD] })
    UserDetails({ error, data }) {
        console.log('UserDetails = ', data);
        console.log('userId= ', this.userId)
        if (data) {
            if (data && data.fields && data.fields.EmployeeNumber) {
                this.employeeId = data.fields.EmployeeNumber.value;
            }
        } else if (error) {
            console.log('error in getting UserDetails = ', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ApplicationId] })
    LegalApprovalDetails({ error, data }) {
        if (data) {
            if (!this.applicationId) {
                this.applicationId = data.fields.Application__c.value;
                console.log('this.applicationId = ', this.applicationId);
                this.handleGetAppllicationDetails();
                this.handleGetApplicantRecords();
                this.handleGetPropertyTableData();
            }
        } else if (error) {
            console.log('error in getting LegalApprovalDetails = ', error);
        }
    }

    @wire(getRecord, { recordId: '$applicationId', fields: [FileType, SanctionAmountRestriction, LegalPending, AnyApprovalToBeObtained, PendingCategory] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails = ', data);
        if (data) {
            if (data.fields.File_Type__c && data.fields.File_Type__c.value) {
                this.legalApValidation.secondFromValid = true;
                this.fileType = data.fields.File_Type__c.value;
            }
            if (data.fields.Any_Approval_to_be_Obtained__c && data.fields.Any_Approval_to_be_Obtained__c.value) {
                this.legalApValidation.secondFromValid = true;
                this.anyApproval = data.fields.Any_Approval_to_be_Obtained__c.value;
            }
            if (data.fields.Sanction_Amount_Restriction__c && data.fields.Sanction_Amount_Restriction__c.value) {
                this.legalApValidation.thirdFromValid = true;
                this.sanctionAmountVal = data.fields.Sanction_Amount_Restriction__c.value;
            }
            if (data.fields.Legal_Pending__c && (data.fields.Legal_Pending__c.value == 'Yes')) {
                this.legalApValidation.fourthFromValid = false;
                this.legalPending = data.fields.Legal_Pending__c.value;
            } else if (data.fields.Legal_Pending__c && (data.fields.Legal_Pending__c.value == 'No')) {
                this.legalApValidation.fourthFromValid = true;
                this.legalPending = data.fields.Legal_Pending__c.value;
            }
            console.log('this.legalApValidation= ', JSON.parse(JSON.stringify(this.legalApValidation)));
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    get showForm() {
        return (this.newPropertyId) ? true : false;
    }

    get showSanctionAmountUpTo() {
        let ref = this;
        console.log('showSanctionAmountUpTo = ', this.sanctionAmountVal)
        if (this.sanctionAmountVal == 'Yes') {
            console.log('Yes')
            this.sanctionAmountValue = null;
        } else if (this.sanctionAmountVal == 'No' && this.applicationObj) {
            console.log('No = ', this.applicationObj.Total_Amount_Recommended_PcAc__c)
            this.sanctionAmountValue = this.applicationObj.Total_Amount_Recommended_PcAc__c;
        }
        console.log('showSanctionAmountUpTo = ', this.applicationObj, this.sanctionAmountValue)
        return this.sanctionAmountVal == 'Yes';
    }

    get showOldLoanFields() {
        return (this.fileType == 'Normal' || this.fileType == 'II or III Tranche');
    }

    get showAnyApproval() {
        return (this.anyApproval == 'No');
    }

    get showEncumRemarks() {
        if (this.formObj && this.formObj.Existing_Encumberances__c == 'No') {
            this.formObj.Remarks_In_Encumberance__c = '';
        }
        return (this.encumRemarks == 'No');
    }

    get disableOnlineECFields() {
        if (this.formObj && (this.formObj.Online_EC_Status__c == 'Website Down' || this.formObj.Online_EC_Status__c == 'Not Available')) {
            this.formObj.Online_EC_Date_From__c = null;
            this.formObj.Online_EC_Date_Till__c = null;
        }
        return this.formObj && (this.formObj.Online_EC_Status__c == 'Website Down' || this.formObj.Online_EC_Status__c == 'Not Available') ? true : false;
    }

    get disableLinkDocFields() {
        if (this.formObj && this.formObj.Link_Doc_Status__c == 'Single Document') {
            this.formObj.Link_Document_Type__c = '';
            this.formObj.Link_Doc_Date__c = null;
            this.formObj.Link_Documents_in_Name_of__c = '';
        }
        return (this.formObj && this.formObj.Link_Doc_Status__c == 'Single Document') ? true : false;
    }

    get disableSupportingDocFields() {
        if (this.formObj && this.formObj.Supporting_Document_SD__c == 'None') {
            this.formObj.SD_in_name_of__c = '';
            this.formObj.SD_Date__c = null;
        }
        return (this.formObj && this.formObj.Supporting_Document_SD__c == 'None') ? true : false;
    }

    get disableLegalPending() {
        console.log('this.legalPending = ',this.legalPending)
        if (this.legalPending == 'No') {
            let val = this.template.querySelector("[data-id='Pending_User_Id__c']");
            let val1 = this.template.querySelector("[data-id='Pending_Date__c']");
            let val2 = this.template.querySelector("[data-id='Pending_Category__c']");
            let val3 = this.template.querySelector("[data-id='Legal_Pending_Remarks__c']");
            console.log('Innputs = ',val , val1 , val2 , val3)
            if (val && val1 && val2 && val3) {
                val.reset();
                val1.reset();
                val2.reset();
                val3.reset();
            }
        }
        return (this.legalPending == 'No');
    }

    get disableOnlineECTypeFields() {
        if (this.formObj && (this.formObj.Login_EC_Type__c == 'Not Applicable')) {
            this.formObj.Login_EC_Number__c = '';
            this.formObj.Login_EC_Date_From__c = null;
            this.formObj.Login_EC_Date_Till__c = null;
        }
        return this.formObj && (this.formObj.Login_EC_Type__c == 'Not Applicable') ? true : false;
    }

    get disableOnlineGuideFields() {
        if ((this.formObj && (this.formObj.Online_Guideline_Value_Search__c == 'Not Available' || this.formObj.Online_Guideline_Value_Search__c == 'Not applicable' || this.formObj.Online_Guideline_Value_Search__c == 'Website Down'))) {
            this.formObj.Online_Guidelive_Value__c = '';
        }
        return (this.formObj && (this.formObj.Online_Guideline_Value_Search__c == 'Not Available' || this.formObj.Online_Guideline_Value_Search__c == 'Not applicable' || this.formObj.Online_Guideline_Value_Search__c == 'Website Down'));
    }

    connectedCallback() {
        console.log('Verification Id', this.recordId);
        this.LegalApprovalDocs = requiredDocs.split(',');
        this.handleGetLastLoginDate();
        this.handleGetRecordTypeId();
    }

    renderedCallback() {
        if (!this.callOnce) {
            const style = document.createElement('style');
            style.innerText = `.slds-form-element__label{
            font-weight: bold;
        }`;
            this.template.querySelector('[data-id="legalApproval"]').appendChild(style);
            const label = this.template.querySelectorAll('label');
            label.forEach(element => {
                element.classList.add('bold');
            });
            console.log('renderedCallback()');
        }
    }

    handleFormValues(event) {
        console.log('Name##' + event.target.name);
        this.formObj[event.target.name] = event.target.value;
        if (event.target.name == 'Title_Deed_Date__c' && event.target.value) {
            this.setMaxDate(event.target.value);
        }
        if (event.target.name == 'Existing_Encumberances__c') {
            this.encumRemarks = event.target.value;
        }
        if (event.target.name == 'Login_EC_Date_Till__c') {
            var today = new Date(this.formObj.Login_EC_Date_From__c);
            this.loginEcDateTill = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + (today.getDate() + 1);
        }
        if (event.target.name == 'Login_EC_Date_From__c') {
            var today = new Date(this.formObj.Login_EC_Date_Till__c);
            this.loginEcDateTill = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + (today.getDate() - 1);
        }

        if (event.target.name == 'Online_EC_Date_Till__c') {
            var today = new Date(this.formObj.Online_EC_Date_From__c);
            this.onlineEcDateTill = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + (today.getDate() + 1);
        }
        if (event.target.name == 'Online_EC_Date_From__c') {
            var today = new Date(this.formObj.Online_EC_Date_Till__c);
            this.onlineEcDateTill = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + (today.getDate() - 1);
        }
        console.log(this.disableLinkDocFields);
        console.log(this.disableSupportingDocFields);
        console.log(this.disableOnlineECFields);
        console.log(this.disableOnlineGuideFields);
        console.log(this.showEncumRemarks);
        console.log(this.disableOnlineECTypeFields);
    }

    // setMaxDate(titleDeedDateVal) {
    //     var today = new Date(this.formObj.Title_Deed_Date__c);
    //     this.titleDeedDate = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
    //     this.titleDeedDate = new Date(new Date(titleDeedDateVal) - 1 * 24 * 60 * 60 * 1000).toISOString().substring(0, 10);
    //     console.log('this.titleDeedDate= ', this.titleDeedDate);
    // }
    setMaxDate() {
        var today = new Date(this.formObj.Title_Deed_Date__c);
        this.titleDeedDate = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
    }

    get todaysDate() {
        var today = new Date();
        var dt = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        return dt;
    }

    // todayDate(){
    //     var today = new Date();
    //     var dd = today.getDate();
    //     var mm = today.getMonth() + 1;
    //     var yyyy = today.getFullYear();
    //     var todayDate = yyyy + '-' + mm + '-' + dd;
    //     return todayDate;
    // }

    handleMODTSummaryChange(event) {
        if (event.target.fieldName == 'Sanction_Amount_Restriction__c') {
            this.sanctionAmountVal = event.target.value;
            console.log('showSanctionAmountUpTo = ', this.showSanctionAmountUpTo);
        } else if (event.target.fieldName == 'File_Type__c') {
            this.fileType = event.target.value;
        }
        else if (event.target.fieldName == 'Any_Approval_to_be_Obtained__c') {
            this.anyApproval = event.target.value;
        }
    }

    handlePendingTabChange(event) {
        // if (event.target.fieldName == 'Legal_Pending__c' && event.target.value === 'No') {
        //     this.legalPending = true;
        // } else if (event.target.fieldName == 'Legal_Pending__c' && event.target.value === 'Yes') {
        //     this.pendingDisabled = false;
        // }
        // console.log('Legal Pending#####', this.pendingDisabled);
        if (event.target.fieldName == 'Legal_Pending__c') {
            this.legalPending = event.target.value;
        }
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
        return (allValid1 && allValid2 && allValid3);
    }

    handlePropertySave() {
        console.log('Before handlePropertySave= ', JSON.parse(JSON.stringify(this.formObj)))
        let allValid = this.handleCheckValidity();
        if (!allValid) {
            return;
        }
        let propertyObj = JSON.parse(JSON.stringify(this.formObj));
        propertyObj.Id = this.newPropertyId;
        propertyObj.Supporting_Document_SD__c = ((this.formObj.Supporting_Document_SD__c && this.formObj.Supporting_Document_SD__c.length) ? this.formObj.Supporting_Document_SD__c.join(';') : '');
        propertyObj.Title_Document_in_Name_of__c = ((this.formObj.Title_Document_in_Name_of__c && this.formObj.Title_Document_in_Name_of__c.length) ? this.formObj.Title_Document_in_Name_of__c.join(';') : '');
        console.log('After handlePropertySave= ', JSON.parse(JSON.stringify(propertyObj)));

        this.handleSaveLegalApprovalProperty(propertyObj);
    }

    cancelForm() {
        if (this.tabName == 'Property') {
            this.newPropertyId = undefined;
            this.formObj = {
                Title_Document_in_Name_of__c: undefined,
                Title_Deed_Number__c: undefined,
                Title_Deed_Date__c: undefined,
                Document_Type__c: undefined,
                Survey_Number__c: undefined,
                Plot_No__c: undefined,
                House_Door_No__c: undefined,
                Property_Number__c: undefined,
                Village__c: undefined,
                District__c: undefined,
                MS_Pincode__c: undefined,
                Extent_Sqft__c: undefined,
                Supporting_Document_SD__c: undefined,
                SD_in_name_of__c: undefined,
                SD_Date__c: undefined,
                Link_Doc_Status__c: undefined,
                Link_Document_Type__c: undefined,
                Link_Doc_Date__c: undefined,
                Link_Documents_in_Name_of__c: undefined,
                Login_EC_Type__c: undefined,
                Login_EC_Number__c: undefined,
                Login_EC_Date_From__c: undefined,
                Login_EC_Date_Till__c: undefined,
                Online_EC_Status__c: undefined,
                Online_EC_Date_From__c: undefined,
                Online_EC_Date_Till__c: undefined,
                GuidelineValue_SqFt_asPer_LegalOpinion__c: undefined,
                Online_Guideline_Value_Search__c: undefined,
                Online_Guidelive_Value__c: undefined,
                Existing_Encumberances__c: undefined,
                Remarks_In_Encumberance__c: undefined,
            };
        }
    }

    showTemporaryLoader() {
        this.showLoader = true;
        let ref = this;
        setTimeout(function () {
            ref.showLoader = false;
        }, 500);
    }

    handleFileUplaod(event) {
        console.log('handleFileUplaod= ', event.detail);
    }

    handleSelectedProperty(evt) {
        console.log('handleSelectedRevisit= ', JSON.stringify(evt.detail));
        var data = evt.detail;
        if (data && data.ActionName == 'edit') {
            this.newPropertyId = data.recordData.Id;
            this.handleGetPropertyDetail(this.newPropertyId);
        }
    }

    handleApplicationSubmit(event) {
        console.log('handleApplicationSubmit');
    }

    handleApplicationSuccess() {
        console.log('handleApplicationSuccess');
        let stepName = this.tabName
        if (stepName == 'MODTInstruction') {
            this.legalApValidation.secondFromValid = true;
        } else if (stepName == 'Summary') {
            this.legalApValidation.thirdFromValid = true;
        } else if (stepName == 'Pending Reasons') {
            this.legalApValidation.fourthFromValid = true;
        }
        this.showNotifications('', 'Values Saved Successfully!', 'success');
    }

    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    handleActive(event) {
        console.log('handleActive= ', event.target.value);
        this.tabName = event.target.value;
    }

    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        this.showLoader = false;
        this.handleLegalApprovalSubmit();
    }

    requiredDocumentValidation() {
        console.log('requiredDocuments ', JSON.stringify(this.requiredDocuments));
        if (this.requiredDocuments.length > 0) {
            this.requiredDocuments.forEach(element => {
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.errorMsgs.push('Upload Application Document ' + element.documentName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Applicant') {
                    this.errorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.customerName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Asset') {
                    this.errorMsgs.push('Upload Document ' + element.documentName + ' For ' + element.propertyName + ' In Document Upload Tab');
                }
            });
        }
    }

    handleSubmit() {
        this.showLoader = true;
        this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
        // setTimeout(() => {
        //     this.showLoader = false;
        //     this.handleLegalApprovalSubmit();
        // }, 3000);
    }

    async handleLegalApprovalSubmit() {
        this.errorMsgs = [];
        this.requiredDocumentValidation();

        await getPendingReasonValidation({applicationId: this.applicationId, stage: 'Legal Approval' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsgs.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.showLoader = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })

        if (!this.legalApValidation.firstFromValid) {
            this.errorMsgs.push('Please complete all the details in Property Section');
        }
        if (!this.legalApValidation.secondFromValid) {
            this.errorMsgs.push('Please complete all the details in MODT Instruction Section');
        }
        if (!this.legalApValidation.thirdFromValid) {
            this.errorMsgs.push('Please complete all the details in Summary Section');
        }
        if (!this.legalApValidation.fourthFromValid) {
            this.errorMsgs.push('Legal Approval cannot move to next stage as Legal Pending is Yes');
        }
        if (!this.legalApValidation.isReportGenerated) {
            this.errorMsgs.push('Please generate Legal Approval Cam Report.');
        }

        if (this.errorMsgs && this.errorMsgs.length) {
            this.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.tabName = 'Error';
            }, 300);
        } else {
            this.showErrorTab = false;
            handleLegalApprovalSubmit({
                applicationId: this.applicationId,
                legalApId: this.recordId
            }).then((result) => {
                console.log('handleLegalApprovalSubmit= ', result);
                if (result == 'success') {
                    this.showNotifications('', 'Legal Approval is completed successfully!', 'success');
                    this.preventBack();
                }
            }).catch((err) => {
                console.log('Error in handleLegalApprovalSubmit= ', err);
            });
        }
    }

    preventBack() {
        console.log('preventback called');
        window.location.replace('/' + this.applicationId);
    }

    /* -------------------- All the server methods -------------------- */
    handleGetRecordTypeId() {
        getRecordTypeId({
            sObjectName: "Property__c",
            recordTypeName: "Legal Approval",
        }).then((result) => {
            console.log('handleGetRecordTypeId= ', result);
            this.recordTypeId = result;
            console.log('recordname', this.recordTypeId);
        }).catch((err) => {
            console.log('getRecordTypeId= ', err);
        });
    }

    handleGetAppllicationDetails() {
        getApplicationDetails({ appId: this.applicationId }).then((result) => {
            this.applicationObj = JSON.parse(JSON.stringify(result))[0];
            this.loginId = this.applicationObj.Pre_Login__c;
            this.applicationName = this.applicationObj.Name;
            this.sanctionAmountValue = this.applicationObj.Total_Amount_Recommended_PcAc__c;
        }).catch((err) => {
            console.log('getApplicationDetails= ', err);
        });
    }

    handleGetApplicantRecords() {
        getApplicantRecords({ appId: this.applicationId }).then((result) => {
            this.customerMap = JSON.parse(JSON.stringify(result))
            let tempList = [];

            for (let keyValue of Object.keys(this.customerMap)) {
                let element = JSON.parse(JSON.stringify(this.customerMap[keyValue]))
                tempList.push({ label: element.Name, value: element.Name });
            }
            this.titleDocValues = JSON.parse(JSON.stringify(tempList));
        }).catch((err) => {
            console.log('getApplicantRecords= ', err);
        });
    }

    handleGetPropertyTableData() {
        console.log('handleGetPropertyTableData called');
        getPropertyTableData({ appId: this.applicationId }).then((result) => {
            console.log('handleGetPropertyTableData =', result);
            this.propertyTableData = result;
            if (this.propertyTableData && this.propertyTableData.strDataTableData && JSON.parse(this.propertyTableData.strDataTableData).length) {
                let allValid = true;
                JSON.parse(this.propertyTableData.strDataTableData).forEach(element => {
                    if (!element.Is_Legal_Updated__c) {
                        allValid = false;
                    } else if (!JSON.parse(element.Is_Legal_Updated__c)) {
                        allValid = false;
                    }
                });
                this.legalApValidation.firstFromValid = allValid;
            }
            console.log('this.legalApValidation.firstFromValid= ', this.legalApValidation.firstFromValid);
        }).catch((err) => {
            console.log('getPropertyTableData= ', err);
        });
    }

    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result;

            let currentTab = this.tabName;
            console.log('currentTab= ', currentTab);
            let tabs = this.template.querySelectorAll('lightning-tab');
            console.log('tabs= ', tabs);
            tabs.forEach(element => {
                element.loadContent();
            });
            console.log('currentTab= ', currentTab);
            this.tabName = currentTab;
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }

    handleGetPropertyDetail(selectedId) {
        this.showLoader = true;
        getPropertyDetails({ propertyId: selectedId }).then((result) => {
            this.showLoader = false;
            console.log('handleGetPropertyDetail = ', result);
            if (result) {
                console.log('FIRST IF');
                if (result.Is_Legal_Updated__c) {
                    console.log('SECOND IF');
                    this.formObj.Title_Document_in_Name_of__c = ((result.Title_Document_in_Name_of__c) ? result.Title_Document_in_Name_of__c.split(';') : undefined);
                    this.formObj.Title_Deed_Number__c = result.Title_Deed_Number__c;
                    this.formObj.Title_Deed_Date__c = result.Title_Deed_Date__c;
                    if (this.formObj.Title_Deed_Date__c) {
                        this.setMaxDate(this.formObj.Title_Deed_Date__c);
                    }
                    this.formObj.Document_Type__c = result.Document_Type__c;
                    this.formObj.Survey_Number__c = result.Survey_Number__c;
                    this.formObj.Plot_No__c = result.Plot_No__c;
                    this.formObj.House_Door_No__c = result.House_Door_No__c;
                    this.formObj.Property_Number__c = result.Property_Number__c;
                    this.formObj.Village__c = result.Village__c;
                    this.formObj.District__c = result.District__c;
                    this.formObj.MS_Pincode__c = result.MS_Pincode__c;
                    this.formObj.Extent_Sqft__c = result.Extent_Sqft__c;
                    this.formObj.Supporting_Document_SD__c = ((result.Supporting_Document_SD__c) ? result.Supporting_Document_SD__c.split(';') : undefined);
                    this.formObj.SD_in_name_of__c = result.SD_in_name_of__c;
                    this.formObj.SD_Date__c = result.SD_Date__c;
                    this.formObj.Link_Doc_Status__c = result.Link_Doc_Status__c;
                    this.formObj.Link_Document_Type__c = result.Link_Document_Type__c;
                    this.formObj.Link_Doc_Date__c = result.Link_Doc_Date__c;
                    this.formObj.Link_Documents_in_Name_of__c = result.Link_Documents_in_Name_of__c;
                    this.formObj.Login_EC_Type__c = result.Login_EC_Type__c;
                    this.formObj.Login_EC_Number__c = result.Login_EC_Number__c;
                    this.formObj.Login_EC_Date_From__c = result.Login_EC_Date_From__c;
                    this.formObj.Login_EC_Date_Till__c = result.Login_EC_Date_Till__c;
                    this.formObj.Online_EC_Status__c = result.Online_EC_Status__c;
                    this.formObj.Online_EC_Date_From__c = result.Online_EC_Date_From__c;
                    this.formObj.Online_EC_Date_Till__c = result.Online_EC_Date_Till__c;
                    this.formObj.GuidelineValue_SqFt_asPer_LegalOpinion__c = result.GuidelineValue_SqFt_asPer_LegalOpinion__c;
                    this.formObj.Online_Guideline_Value_Search__c = result.Online_Guideline_Value_Search__c;
                    this.formObj.Online_Guidelive_Value__c = result.Online_Guidelive_Value__c;
                    this.formObj.Existing_Encumberances__c = result.Existing_Encumberances__c;
                    this.formObj.Remarks_In_Encumberance__c = result.Remarks_In_Encumberance__c;
                } else {
                    console.log('SECOND ELSE');
                    this.formObj = JSON.parse(JSON.stringify(result));
                    if (this.formObj.Title_Deed_Date__c) {
                        this.setMaxDate(this.formObj.Title_Deed_Date__c);
                    }
                }
            }
        }).catch((err) => {
            this.showLoader = false;
            console.log('Erorr in handleGetPropertyDetail = ', err);
        });
    }

    handleSaveLegalApprovalProperty(propertyObj) {
        this.showLoader = true;
        saveLegalApprovalProperty({ legalApprovalSt: JSON.stringify(propertyObj) }).then((result) => {
            this.showLoader = false;
            console.log('handleSaveLegalApprovalProperty= ', result);
            if (result == 'success') {
                this.showNotifications('', 'Property Updated Successfully!', 'success');
                this.newPropertyId = undefined;
                this.propertyTableData = undefined;
                let ref = this;
                this.cancelForm();
                setTimeout(() => {
                    ref.handleGetPropertyTableData();
                }, 400);
            }
        }).catch((err) => {
            this.showLoader = false;
            console.log('Error in handleSaveLegalApprovalProperty= ', err);
        });
    }

    rowselectionevent(event) {
        var detail = event.detail;
        if (detail === 'Submit') {
            this.handleSubmit();
        }
        if (detail === 'Legal Cam Report') {
            this.handleLegaLCam();
        } else if (event.detail === 'pendingReason') {
            this.showHidePendingReasonGrid();
        }
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }

    handleLegaLCam() {
        this.legalApValidation.isReportGenerated = true;
        generateLegalCamReport({ applicationId: this.applicationId })
            .then(result => {
                this.validationObj.isReportGenerated = true;
                this.toastMessage('', 'Legal Approval Cam Report Generated Successfully.', 'success');
            })
            .catch(error => {
                console.log('err' + error);
            })
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/LegalCamReport_VfPage?id=' + this.applicationId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });

    }
}