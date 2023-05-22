import { LightningElement, track, wire, api } from 'lwc';
import getEditPageContent from '@salesforce/apex/AgreementExecutionController.getEditPageContent';
import getApplicants from '@salesforce/apex/AgreementExecutionController.getApplicants';
import saveRecord from '@salesforce/apex/AgreementExecutionController.saveRecord';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId'
import getAgDataTable from '@salesforce/apex/AgreementExecutionController.getAgDataTable';
import getPrimaryApplicant from '@salesforce/apex/AgreementExecutionController.getPrimaryApplicant';
import getApplicantAddress from '@salesforce/apex/AgreementExecutionController.getApplicantAddress';
import getProperties from '@salesforce/apex/AgreementExecutionController.getProperties';
import getDGRecordId from '@salesforce/apex/AgreementExecutionController.getDGRecordId';
import checkRecordExist from '@salesforce/apex/AgreementExecutionController.checkRecordExist';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BALANCE_TRANSFER from '@salesforce/schema/Application__c.Balance_Transfer__c';
import TRANCHE_TYPE from '@salesforce/schema/Application__c.Tranche_Disbursal__c';
import INSURED_NAME from '@salesforce/schema/Application__c.Name__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [BALANCE_TRANSFER, TRANCHE_TYPE,INSURED_NAME];

export default class FsAgreementExecutionDG extends NavigationMixin(LightningElement) {

    @api applicationId;
    @api appName;
    @api applicationName;
    
    @track tranchType;
    @track balanceTransfer;
    @track tabName = 'Agreement_DG_Schedule_A';
    @track objectIdMap = { 'Agreement_Execution_Document_Generation__c': '' };
    @track fieldsContent;
    @track recordIds;
    @track showEditPage = false;
    @track isSpinnerActive = false;
    @track showApplicants = false;
    @track applicantOptions = [];
    @track witnessOption = [];
    @track loanAppId;
    @track showDocGeneration = false;
    @track loanApplicantName;
    @track recTypeId;
    @track isDataArrived = false;
    @track showDeletePopup = false;
    @track witnessValue;
    @track witnessId;
    @track dgId;
    @track tableData = [];
    @track propertyOptions = [];
    @track witnessName;
    @track propId;
    @track primaryApplicant = { Name: '', Id: '' };
    @track vernacularWrapper = { borrowerName: '', witnessName: '', witnessAddress: '', witnessMonthsKnown: '', witnessRelation: '' }
    @track docType;
    @track saveDG = true;
    @track applicantValue;
    @track dgRecId;
    @track stampingDate;
    @track modDate;
    @track allApplicantIds = [];
    @track selectedAll = false;
    @track insuredPersonName;
    @track documentWrapper = {
        Agreement_DG_Schedule_A: 'Schedule_A',
        Agreement_DG_DPN: 'DPN',
        Agreement_DG_Form_60: 'Form60',
        Agreement_DG_Vernacular_LTI_Declaratio: 'VernacularVF',
        Agreement_DG_Aadhar_Consent_Form: 'AadharConsentVF',
        Agreement_DG_MSME_Letter: 'End_Use_Declaration',
        Agreement_DG_Insurance_Undertaking_Lette: 'InsuranceUndertakingLetterVF',
        Agreement_DG_Original_Title_Deed_BM_OO: 'OriginalTitleDeedVF',
        Agreement_DG_Signature_Mismatch_Letter: 'SignatureMismatchLetterVf',
        Agreement_DG_MOD_amount_difference_lette: 'MODAmountVf',
        Agreement_DG_Property_Schedule_mismatch: 'PropertySchedulemismatchletter',
        Agreement_DG_RC_Adjustment: 'RCAdjustmentLetterVf',
        Agreement_DG_Loan_Reduction: 'LoanReductionVf',
        Agreement_DG_Insurance_Wavier_Request: 'InsuranceWaiverVf',
        Agreement_DG_No_Objection_Certificate: 'NoObjectionCertificateVf',
        Agreement_DG_Property_Identification: 'PropertyIdentificationUndertakingVf'
    };
    @track showDocWrapper = {
        Agreement_DG_Schedule_A: 'Application',
        Agreement_DG_DPN: 'Application',
        Agreement_DG_Form_60: 'Applicant',
        Agreement_DG_Vernacular_LTI_Declaratio: 'Applicant',
        Agreement_DG_Aadhar_Consent_Form: 'Applicant',
        Agreement_DG_MSME_Letter: 'Application',
        Agreement_DG_Insurance_Undertaking_Lette: 'Application',
        Agreement_DG_Original_Title_Deed_BM_OO: 'Application',
        Agreement_DG_Signature_Mismatch_Letter: 'Applicant',
        Agreement_DG_MOD_amount_difference_lette: 'Application',
        Agreement_DG_Property_Schedule_mismatch: 'Asset',
        Agreement_DG_RC_Adjustment: 'Application',
        Agreement_DG_Loan_Reduction: 'Application',
        Agreement_DG_Insurance_Wavier_Request: 'Application',
        Agreement_DG_No_Objection_Certificate: 'Application',
        Agreement_DG_Property_Identification: 'Asset'
    };
    @track rowAction = [
        /* {
        type: 'button-icon',
        fixedWidth: 50,
        typeAttributes: {
            iconName: 'utility:edit',
            title: 'Edit',
            variant: 'border-filled',
            alternativeText: 'Edit',
            name: 'edit'
        }
        },*/
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:delete',
                title: 'Delete',
                variant: 'border-filled',
                alternativeText: 'Delete',
                name: 'delete'
            }
        }
    ]

    @wire(getRecord, { recordId: '$applicationId', fields : fields })
    application({ error, data }) {
        console.log('applicationDetailsBTTRANCHE = ', data);
        if (data) {
           this.balanceTransfer = data.fields.Balance_Transfer__c.value;
           this.tranchType = data.fields.Tranche_Disbursal__c.value;
           this.insuredPersonName = data.fields.Name__c.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    connectedCallback() {
        this.getAllApplicant();
        this.getAllAgRecordDetails();
        this.getPrimaryApplicantOfApp();
        this.getAllProperties('AC Property Detail');
    }

     @api getAllApplicant() {
        this.applicantOptions = [];
        this.showApplicants = false;
        getApplicants({ applicationId: this.applicationId })
            .then(result => {
                const witnessName = {
                    label: 'Others',
                    value: 'Others'
                };
                if (result) {
                    result.forEach(element => {
                        if (element.Applicant_Name__c) {
                            const applicantName = {
                                label: element.Applicant_Name__c,
                                value: element.Id
                            };
                            this.applicantOptions = [...this.applicantOptions, applicantName];
                            console.log('appopt ', this.applicantOptions);
                            this.showApplicants = true;
                        }
                        this.allApplicantIds.push(element.Id);
                    });
                }
            })
            .catch(error => {
                this.isSpinnerActive = false;
                console.log('Error in getting applicant name ', error)
            })
    }

    async handleActiveTab(event) {
        this.selectedAll = false;
        this.loanAppId = '';
        this.isSpinnerActive = true;
        this.saveDG = true;
        this.tabName = event.target.value;
        console.log('tab ', this.tabName);
        this.loanAppId = '';
        this.loanApplicantName = '';
        console.log('Tab :: ', event.target.label);
        console.log('DG Rec :: ', this.applicationId, ' :: ', event.target.label);
        var recTypeName = event.target.label == 'Aadhaar Consent Form' ? 'Aadhar Consent Form' : (event.target.label == 'End Use Declaration' ? 'MSME Letter' : event.target.label);
        console.log('recType ', recTypeName);
        if(this.tabName === 'Agreement_DG_Property_Schedule_mismatch'){
            this.getAllProperties('AC Property Detail');
        }
        if(this.tabName === 'Agreement_DG_Property_Identification'){
            this.getAllProperties('FIV-C Property Detail');
        }
        this.recTypeId = undefined;
        await getRecordTypeId({ sObjectName: 'Agreement_Execution_Document_Generation__c', recordTypeName: recTypeName })
            .then(result => {
                if (result) {
                    this.recTypeId = result;
                    console.log('recTypeId ', this.recTypeId);
                    if (recTypeName != 'Vernacular / LTI Declaration') {
                        getDGRecordId({ appId: this.applicationId, recTypeName: recTypeName })
                            .then(result => {
                                this.dgRecId = result;
                                console.log('result dg ', this.dgRecId);
                                if (this.dgRecId)
                                    this.saveDG = false;
                                this.getSectionPageContent(this.dgRecId);
                            })
                            .catch(error => {
                                //this.dgRecId = '';
                                this.getSectionPageContent('');
                                console.log(error);
                            })
                    }
                    else {
                        this.getSectionPageContent('');
                    }
                }
                else {
                    this.isSpinnerActive = false;
                }
            })
            .catch(error => {
                this.isSpinnerActive = false;
                console.log(error);
            })
        if ((this.tabName === 'Agreement_DG_Form_60' || this.tabName === 'Agreement_DG_Aadhar_Consent_Form') && this.applicantOptions.length > 1) {
            let all = {
                label: 'All',
                value: 'All'
            };
            let found = false;
            this.applicantOptions.forEach(element => {
                if(element.label === 'All'){ found = true}
            })
            if(!found)
            this.applicantOptions.splice(0, 0, all);
        }
        else{
            let found = false;
            this.applicantOptions.forEach(element => {
                if(element.label === 'All'){ found = true}
            })
            if(found)
            this.applicantOptions.splice(0, 1);
        }
    }

    
    getSectionPageContent(recId) {
        console.log('recIdCalled ',recId,' :: ',this.tabName);
        this.showEditPage = false;
        try {
            getEditPageContent({ recordIds: recId, metaDetaName: this.tabName })
                .then(result => {
                    console.log('data ### ', JSON.parse(result.data));
                    this.fieldsContent = result.data;
                    var rs = JSON.parse(result.data);
                    var loanCategory;
                    rs[0].fieldsContent.forEach(element => {
                            console.log('element :: ', element)
                            console.log('element :: ', element.value)
                            if (element.fieldAPIName === 'Loan_Applicant__c') {
                                console.log('found element :: ', element.value)
                                if(this.selectedAll)
                                    this.applicantValue = 'All';
                                else
                                    this.applicantValue = element.value;
                                this.loanAppId = element.value;
                            }
                            if (element.fieldAPIName === 'Loan_Category__c') {
                                console.log('found element :: ', element.value)
                                loanCategory = element.value;
                            }
                    });
                    var _val;
                    if((this.balanceTransfer === undefined || this.balanceTransfer === 'No') && this.tranchType === 'II'){
                        _val = '2nd Tranche';
                    }
                    else if(this.balanceTransfer != 'No' && this.balanceTransfer){
                        _val = 'Balance Transfer';
                    }
                    else{
                        _val = 'Regular';
                    }
                    if(loanCategory){
                        _val = loanCategory ? (_val === loanCategory ? _val : loanCategory ) : '';
                    }
                    console.log('VALUE 123 ',_val+' :: '+this.balanceTransfer+' :: '+this.tranchType);
                    var className = '.' + this.tabName;
                    if(_val){
                        setTimeout(() =>{
                            let genericedit = this.template.querySelector(className);
                            this.fieldsContent = (JSON.stringify(this.setValues('Loan_Category__c', _val)));
                            genericedit.refreshData((this.fieldsContent));
                        },200)
                    }
                    this.showEditPage = true;
                    this.isSpinnerActive = false;
                })
                .catch(error => {
                    console.log(error);
                });
        } catch (error) {
            console.log(error);
        }
    }

    handleFormValueChange(event) {
        console.log(event.detail);
        var tempFieldsContent = event.detail;
        if (tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-Agreement_Stamping_Date__c' || tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-MOD_Date__c') {
            if(tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-Agreement_Stamping_Date__c'){
                this.stampingDate = tempFieldsContent.CurrentFieldValue;
            }
            if(tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-MOD_Date__c'){
                this.modDate = tempFieldsContent.CurrentFieldValue;
            }
            var d1 = new Date();
            var d2 = new Date(tempFieldsContent.CurrentFieldValue);
            if (d2.getTime() > d1.getTime()) {
                console.log('date ', d2);
                this.showToast('Error', 'error', 'Future Dates Are Not Allowed!!');
                var _val = tempFieldsContent.CurrentFieldValue;
                console.log(' _val #### ',_val);
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues(tempFieldsContent.CurrentFieldAPIName,_val)));
            }
        }
        if (tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-No_of_years_known__c') {
            this.vernacularWrapper.witnessMonthsKnown = tempFieldsContent.CurrentFieldValue;
        }
        if (tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-Relationship_Between_Borrower_And_Witnes__c') {
            this.vernacularWrapper.witnessRelation = tempFieldsContent.CurrentFieldValue;
        }
        if (tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-Witness_Name__c') {
            console.log('Name');
            this.vernacularWrapper.witnessName = tempFieldsContent.CurrentFieldValue;
        }
        if (tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-Witness_Address__c') {
            console.log('Address');
            this.vernacularWrapper.witnessAddress = tempFieldsContent.CurrentFieldValue;
        }
        if (tempFieldsContent.CurrentFieldAPIName === 'Agreement_Execution_Document_Generation__c-Document_Type__c') {
            console.log('Document_Type__c');
            this.docType = tempFieldsContent.CurrentFieldValue;
        }
    }

    getAllAgRecordDetails() {
        this.isDataArrived = false;
        console.log('::: allLoanApplicant ::: ', JSON.stringify(this.applicationId));
        getAgDataTable({ recordId: this.applicationId, metaDataName: 'Agreement_Document_Generation', tabName: 'Doc_Gen' })
            .then(result => {
                console.log('##res', result);
                this.tableData = result;
                this.isDataArrived = true;
                console.log('Tabledata', JSON.stringify(this.tableData));
            })
            .catch(error => {
                console.log('Error', error);
            })
    }

    getPrimaryApplicantOfApp() {
        getPrimaryApplicant({ applicationId: this.applicationId }).then(result => {
            console.log('primary applicant details ', result);
            if (result) {
                this.primaryApplicant.Id = result.Id;
                this.primaryApplicant.Name = result.Applicant_Name__c;
                console.log('primary applicant details ', this.primaryApplicant);
            }
        })
            .catch(error => {
                console.log('error ', error);
            })
    }

    getAllProperties(recType){
        console.log('appID ', this.applicationId);
        console.log('Property DEtails TAB ',this.tabName);
        this.propertyOptions = [];
        getProperties({ applicationId: this.applicationId, recTypeName :recType }).then(result => {
            if (result) {
                result.forEach(element => {
                    if (element.Name) {
                        const propName = {
                            label: element.Property__r.Name,
                            value: element.Id + '_' + element.Title_Deed_Number__c
                        };
                        this.propertyOptions = [...this.propertyOptions, propName];
                        console.log('appopt ', this.propertyOptions);
                    }
                });
            }
        })
            .catch(error => {
                console.log('Error getting properties ', error);
            })
    }

    async handleSelectedApplicant(event) {
        this.selectedAll = false;
        this.saveDG = true;
        console.log('selected applicant ', event.detail.value);
        console.log('selected applicant ', event.target.options.find(opt => opt.value === event.detail.value).label);
        this.loanApplicantName = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.loanAppId = event.detail.value;
        this.vernacularWrapper.borrowerName = this.loanApplicantName;
        this.witnessOption = undefined;
        this.applicantValue = this.loanAppId;
        console.log('tabname ',this.tabName,' :: ', this.loanApplicantName,' :: ',this.loanAppId);
        let temp = [{label: 'Others',value: 'Others'}];
        this.applicantOptions.forEach(currentItem => {
            if (currentItem.value != event.detail.value) {
                temp.push({ label: currentItem.label, value: currentItem.value });
            }
        });
        this.witnessOption = JSON.parse(JSON.stringify(temp));
        if ((this.tabName === 'Agreement_DG_Form_60' || this.tabName === 'Agreement_DG_Aadhar_Consent_Form') && event.target.options.find(opt => opt.value === event.detail.value).label === 'All' ) {
            this.selectedAll = true;
        }
        var tempIdList = [];
        if(this.selectedAll){
            tempIdList = this.allApplicantIds;
        }
        else{
            tempIdList.push(this.loanAppId);
        }
        await checkRecordExist({loanAppIds:tempIdList,recTypeId:this.recTypeId})
            .then(result =>{
                if(result)
                    this.saveDG = false;
                else
                    this.saveDG = true;
            })
            .catch(error =>{

            })

    }

    handleSelectedWitness(event) {
        try {
            this.saveDG = true;
            console.log('selected applicant ', event.detail.value);
            console.log('selected applicant ', event.target.options.find(opt => opt.value === event.detail.value).label);
            this.witnessName = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.witnessId = event.detail.value;
            this.witnessValue = this.witnessId;
            console.log('this.witnessName  ',this.witnessName,' :: ',this.witnessId);
            if (this.witnessId === 'Others') {
                this.setFieldRequired(this.fieldsContent, false);
                var className = '.' + this.tabName;
                let genericedit = this.template.querySelector(className);
                this.fieldsContent = (JSON.stringify(this.setValues('Witness_Name__c', '')));
                genericedit.refreshData((this.fieldsContent));
                this.fieldsContent = (JSON.stringify(this.setValues('Witness_Address__c', '')));
                genericedit.refreshData((this.fieldsContent));
            }
            else {
                getApplicantAddress({ loanAppId: this.witnessId }).then(result => {
                    this.vernacularWrapper.witnessName = this.witnessName;
                    this.vernacularWrapper.witnessAddress = result;
                    this.setFieldRequired(this.fieldsContent, true);
                    var className = '.' + this.tabName;
                    let genericedit = this.template.querySelector(className);
                    this.fieldsContent = (JSON.stringify(this.setValues('Witness_Name__c', this.witnessName)));
                    genericedit.refreshData((this.fieldsContent));
                    this.fieldsContent = (JSON.stringify(this.setValues('Witness_Address__c', result)));
                    genericedit.refreshData((this.fieldsContent));
                })
                    .catch(error => {
                        console.log('Error ', error);
                    })
            }
        }
        catch (exe) {
            console.log('Exception ', exe);
        }
    }

    handleSelectedProperty(event) {
        console.log('selected applicant ', event.detail.value);
        console.log('selected applicant ', event.target.options.find(opt => opt.value === event.detail.value).label);
        let titleDeedNumber = event.detail.value.split('_')[1];
        this.propId = event.detail.value.split('_')[0];
        console.log(titleDeedNumber);
        var className = '.' + this.tabName;
        let genericedit = this.template.querySelector(className);
        this.fieldsContent = (JSON.stringify(this.setValues('Title_Deed_Number__c', titleDeedNumber)));
        genericedit.refreshData((this.fieldsContent));
        this.setFieldRequired(this.fieldsContent, true);
    }

    setFieldRequired(fieldcontent, disabled) {
        console.log('Inside ', fieldcontent);
        var field = JSON.parse(fieldcontent);
        for (var i = 0; i < field[0].fieldsContent.length; i++) {
            if (field[0].fieldsContent[i].fieldAPIName === 'Witness_Name__c') {
                field[0].fieldsContent[i].disabled = disabled;
                console.log('field[0].fieldsContent[i] ', field[0].fieldsContent[i]);
            }
            if (field[0].fieldsContent[i].fieldAPIName === 'Witness_Address__c') {
                field[0].fieldsContent[i].disabled = disabled;
                console.log('field[0].fieldsContent[i] ', field[0].fieldsContent[i]);
            }
            if (field[0].fieldsContent[i].fieldAPIName === 'Title_Deed_Number__c') {
                field[0].fieldsContent[i].disabled = disabled;
                console.log('field[0].fieldsContent[i] ', field[0].fieldsContent[i]);
            }
        }
        this.fieldsContent = JSON.stringify(field);
        var className = '.' + this.tabName;
        let genericedit = this.template.querySelector(className);
        genericedit.refreshData((this.fieldsContent));
        console.log('Outside ', fieldcontent);
    }

    setValues(_fieldAPIName, _val) {
        var _tempVar = JSON.parse(this.fieldsContent);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName) {
                _tempVar[0].fieldsContent[i].value = _val;
            }
        }
        return _tempVar;
    }

    generateAGDocument(){
        if((this.tabName === 'Agreement_DG_Form_60' || this.tabName === 'Agreement_DG_Aadhar_Consent_Form') && this.selectedAll){
            for(var i=0;i<this.allApplicantIds.length;i++){
                this.generateDocument(this.allApplicantIds[i]);
            }
        }
        else{
            this.generateDocument('');
        }
    }

    async generateDocument(recId) {
        console.log('generateDocument called from ', this.tabName,' :: ',recId);
        console.log('generateDocument vf ', this.documentWrapper[this.tabName]);
        console.log('Application/Applicant ', this.showDocWrapper[this.tabName]);
        if (this.showDocWrapper[this.tabName] === 'Applicant' && !this.loanAppId) {
            this.showToast('Error', 'Error', 'Select Applicant First');
            return;
        }
        if (this.showDocWrapper[this.tabName] === 'Asset' && !this.propId) {
            this.showToast('Error', 'Error', 'Select Property First');
            return;
        }
        var recordIdApp;
        if((this.tabName === 'Agreement_DG_Form_60' || this.tabName === 'Agreement_DG_Aadhar_Consent_Form') && this.selectedAll){
            recordIdApp = recId;
        }
        else{
            recordIdApp = this.loanAppId;
        }
        var recordId = this.showDocWrapper[this.tabName] === 'Application' ? this.applicationId : this.showDocWrapper[this.tabName] === 'Applicant' ? recordIdApp : this.propId;
        var vfPageURL = '/apex/' + this.documentWrapper[this.tabName] + '?recordId=' + recordId;
        if (this.tabName == 'Agreement_DG_Vernacular_LTI_Declaratio') {
            vfPageURL += '&borrowerName=' + this.vernacularWrapper.borrowerName
                + '&witnessName=' + this.vernacularWrapper.witnessName
                + '&witnessAddress=' + this.vernacularWrapper.witnessAddress
                + '&witnessMonthsKnown=' + this.vernacularWrapper.witnessMonthsKnown
                + '&witnessRelation=' + this.vernacularWrapper.witnessRelation;
        }
        else if (this.tabName == 'Agreement_DG_Signature_Mismatch_Letter') {
            vfPageURL += '&docType=' + this.docType;
        }
        console.log('vfPageURL ',vfPageURL);
 
        await this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: vfPageURL
            }
        }).then(generatedUrl => {
            console.log('URL GENERATED');
            window.open(generatedUrl);
        });
    }

    async handleSave() {
        console.log('handle Save called from ', this.tabName);
        var className = '.' + this.tabName;
        console.log('querySelector ', this.template.querySelector(className));
        var data = [];
        if((this.tabName === 'Agreement_DG_Form_60' || this.tabName === 'Agreement_DG_Aadhar_Consent_Form') && this.selectedAll){
            for (var i = 0; i < this.allApplicantIds.length; i++) {
                const tempData = {Application__c:this.applicationId,Loan_Applicant__c:this.allApplicantIds[i],RecordTypeId:this.recTypeId,sobjectType:'Agreement_Execution_Document_Generation__c'};
                data.push(tempData);
            }
            console.log('data i ',data);
        }
        else{
            data = this.template.querySelector(className).handleOnSave();
        }
        console.log('data #### ', data);
        if (data.length > 0) {
            console.log('Data entry start');
            this.isSpinnerActive = true;
            if (this.tabName === 'Agreement_DG_Schedule_A') {
                console.log('Agreement_Stamping_Date__c ', this.stampingDate);
                console.log('MOD_Date__c ', this.modDate);
                var d1 = new Date();
                var d2 = new Date(this.stampingDate);
                var d3 = new Date(this.modDate);
                if (d2.getTime() > d1.getTime()) {
                    console.log('date1 ', d2);
                    this.isSpinnerActive = false;
                    this.showToast('Error', 'error', 'Future Dates Are Not Allowed, Agreement Stamping Date');
                    return;
                }
                if (d3.getTime() > d1.getTime()) {
                    console.log('date1 ', d3);
                    this.isSpinnerActive = false;
                    this.showToast('Error', 'error', 'Future Dates Are Not Allowed, MOD Date');
                    return;
                }
            }
            for (var i = 0; i < data.length; i++) {
                console.log('i am in', data[i]);
                if (this.tabName === 'Agreement_DG_Form_60' || this.tabName === 'Agreement_DG_Aadhar_Consent_Form' || this.tabName === 'Agreement_DG_Signature_Mismatch_Letter'){
                    if ((!this.loanAppId || !this.applicantValue) && !this.dgRecId && !this.selectedAll) {
                        this.showToast('Error', 'Error', 'Select Applicant First');
                        this.isSpinnerActive = false;
                        return;
                    }
                }
                data[i].RecordTypeId = this.recTypeId;
                data[i].Application__c = this.applicationId;
                if (this.tabName === 'Agreement_DG_Insurance_Undertaking_Lette') {
                    data[i].Insured_Person__c = this.insuredPersonName; //this.primaryApplicant.Name;
                    //data[i].Loan_Applicant__c = this.primaryApplicant.Id;
                }
                if (this.tabName === 'Agreement_DG_Vernacular_LTI_Declaratio') {
                    if (!this.loanAppId) {
                        this.showToast('Error', 'Error', 'Select Applicant First');
                        this.isSpinnerActive = false;
                        return;
                    }
                    if (!this.witnessId) {
                        this.showToast('Error', 'Error', 'Select Witness First');
                        this.isSpinnerActive = false;
                        return;
                    }
                    data[i].Borrower__c = this.loanApplicantName;
                    data[i].Loan_Applicant__c = this.loanAppId;
                }
                if(!this.selectedAll)
                    data[i].Loan_Applicant__c = this.loanAppId;
                if(this.tabName == 'Agreement_DG_Schedule_A' || this.tabName == 'Agreement_DG_DPN'
                 || this.tabName == 'Agreement_DG_MSME_Letter' || this.tabName == 'Agreement_DG_Insurance_Undertaking_Lette' 
                 || this.tabName == 'Agreement_DG_Original_Title_Deed_BM_OO' || this.tabName == 'Agreement_DG_MOD_amount_difference_lette'
                 || this.tabName == 'Agreement_DG_RC_Adjustment' || this.tabName == 'Agreement_DG_Loan_Reduction'
                 || this.tabName == 'Agreement_DG_Insurance_Wavier_Request' ||this.tabName == 'Agreement_DG_No_Objection_Certificate') {
                    if(this.dgRecId)
                        data[i].Id = this.dgRecId;
                }
                console.log('DATA FOR FORM 60 ',data[i]);
                await saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                        .then(result => {
                            console.log('result ', result);
                            var message;
                            if (result.statusCode === '101') {
                                message = result.message;
                                this.saveDG = false;
                            }
                            else {
                                message = 'Error while saving record, please contact system admin.';
                                this.saveDG = true;
                            }
                            this.showToast(result.variant, result.variant, message);
                            if(this.selectedAll)
                                this.applicantValue = 'All';
                            if (result.recordId) {
                                this.dgRecId = result.recordId;
                                this.getSectionPageContent(result.recordId);
                                this.getAllAgRecordDetails();
                            }
                            //this.fieldsContent = undefined;
                            this.isSpinnerActive = false;
                        })
                        .catch(error => {
                            this.saveDG = true;
                            this.isSpinnerActive = false;
                            console.log(error);
                            this.showToast('Error', 'Error', JSON.stringify(error));
                        });
            }
        } else {
            this.showToast('Error', 'Error', 'Complete Required Field(s).');
        }
    }

    handleSelectedDoc(event) {
        var recordData = event.detail.recordData;
        console.log('recordData ', recordData);
        this.dgId = recordData.Id;
        if (event.detail.ActionName === 'delete') {
            console.log('Delete Called ');
            this.showDeletePopup = true;
        }
    }

    handlemodalactions(event) {
        this.showDeletePopup = false;
        if (event.detail === true)
            this.getAllAgRecordDetails();
    }

    handleCancel() {
        console.log('handle cancel called ###');
        this.getSectionPageContent('');
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
}