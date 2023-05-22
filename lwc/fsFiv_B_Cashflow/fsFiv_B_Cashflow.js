import { LightningElement, api, track, wire } from 'lwc';
import saveRecord from '@salesforce/apex/FSFivBLwcController.saveRecord';
import getCashflowData from '@salesforce/apex/FSFivBLwcController.getCashflowData';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllApplicantMeta from '@salesforce/apex/FSFivBLwcController.getAllApplicantMeta';
import getSectionContent from '@salesforce/apex/FSFivBLwcController.getSectionContent';
import ID_FIELD from '@salesforce/schema/Verification__c.Id';
import DBR_FIELD from '@salesforce/schema/Verification__c.DBR__c';
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import TOTAL_NET_INCOME from '@salesforce/schema/Application__c.FIVB_Net_Income__c';
import GROSS_INCOME from '@salesforce/schema/Application__c.FIVB_Gross_Income__c';
import OBLIGATION from '@salesforce/schema/Application__c.FIVB_Obligation__c';
import APPLICATION_ID from '@salesforce/schema/Application__c.Id';

//Added 04.05.23
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASHFLOW_OBJECT from '@salesforce/schema/Cashflow__c';
import SEEN from '@salesforce/schema/Cashflow__c.Seen__c';
import NATURE_OF_BUSINESS from '@salesforce/schema/Cashflow__c.Profile__c';
import CUSTOMER_SEGMENT from '@salesforce/schema/Cashflow__c.Customer_Segment__c';
import CUSTOMER_SUB_SEGMENT from '@salesforce/schema/Cashflow__c.Customer_Sub_Segment__c';

const Verification_FIELDS = [
    'Verification__c.BM_Recommended_Amount__c',
    'Verification__c.Tenor__c',
    'Verification__c.ROI__c'
]

export default class fsFiv_B_Cashflow extends LightningElement {
    @api verificationId;
    @api allLoanApplicant;
    @api rowAction;
    @api applicationId;
    @track isSpinnerActive = true;
    @track tableData;
    @track fieldsContent = undefined;
    @track objectIdMap = { 'Cashflow__c': '' };
    @track recordIds;
    @track showDeleteModal = false;
    @track recordIdForDelete;
    @track isApplicantEdit = true;
    @track selectedApplicant;
    @api allApplicantData;
    @track showDeletePopup = false;
    @api verificationStatus;
    @track verificationObject = { 'bmRecommendedAmount': '', 'tenor': '', 'roi': '' };
    @track totalNetIncomeEmi;
    @track obligation;
    @track totalGrossIncome;

    // Added 03.05.23
    @track seenChoices;
    @track natureOfBusinessChoices;
    @track allCustomerSegments;
    @track customerSegmentChoices = [];
    @track allCustomerSubSegments;
    @track customerSubSegmentChoices = [];
    @api name;
    @api seen;
    @api profile;
    @api customerSegment;
    @api customerSubSegment;
    //@track existingEMI;
    //@track existingPOS;
    //@track showExisting = false;

    @track showForm = false;

    connectedCallback() {
        this.getCashflowData();
        this.verificationStatus == 'Completed' ? true : false;
    }

    @wire(getObjectInfo, { objectApiName: CASHFLOW_OBJECT })
    cashflowObjectInfo;

    @wire(getPicklistValues, { recordTypeId: "$cashflowObjectInfo.data.defaultRecordTypeId", fieldApiName: SEEN })
    seenPicklistInfo({ data, error }) {
        this.seenChoices = [];
        console.log('natureOfBusinessPicklistInfo data= ', data);
        if (data) {
            this.seenChoices = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$cashflowObjectInfo.data.defaultRecordTypeId", fieldApiName: NATURE_OF_BUSINESS })
    natureOfBusinessPicklistInfo({ data, error }) {
        this.natureOfBusinessChoices = [];
        console.log('natureOfBusinessPicklistInfo data= ', data);
        if (data) {
            this.natureOfBusinessChoices = data.values;
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$cashflowObjectInfo.data.defaultRecordTypeId", fieldApiName: CUSTOMER_SEGMENT })
    customerSegmentPicklistInfo({ data, error }) {
        this.customerSegmentChoices = [];
        if (data) {
            this.allCustomerSegments = data;
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$cashflowObjectInfo.data.defaultRecordTypeId", fieldApiName: CUSTOMER_SUB_SEGMENT })
    customerSubSegmentPicklistInfo({ data, error }) {
        this.customerSubSegmentChoices = [];
        if (data) {
            console.log('customerSubSegmentPicklistInfo = ', data);
            this.allCustomerSubSegments = data;
        }
    }

    @wire(getRecord, { recordId: '$verificationId', fields: Verification_FIELDS })
    verification({ error, data }) {
        if (data) {
            if (data.fields.BM_Recommended_Amount__c.value != undefined && data.fields.BM_Recommended_Amount__c.value != null &&
                data.fields.BM_Recommended_Amount__c.value != '') {
                this.verificationObject.bmRecommendedAmount = data.fields.BM_Recommended_Amount__c.value;
            }
            if (data.fields.ROI__c.value != undefined && data.fields.ROI__c.value != null &&
                data.fields.ROI__c.value != '') {
                this.verificationObject.roi = data.fields.ROI__c.value;
            }
            if (data.fields.Tenor__c.value != undefined && data.fields.Tenor__c.value != null &&
                data.fields.Tenor__c.value != '') {
                this.verificationObject.tenor = data.fields.Tenor__c.value;
            }
        } else if (error) {
            console.log('ERR IN WIRE Record Property', error);
        }
    }

    getFilteredPicklistValues(data, controllingValue) {
        let stageValue = data.controllerValues[controllingValue];
        let tempList = [];
        data.values.forEach(element => {
            if (element.validFor.includes(stageValue)) {
                tempList.push({ label: element.label, value: element.value });
            }
        });
        console.log('getPicklistValues tempList = ', tempList);
        return JSON.parse(JSON.stringify(tempList));
    }

    getCashflowData() {
        console.log('called ##### ', JSON.stringify(this.allLoanApplicant));
        getCashflowData({ allLoanApplicant: this.allLoanApplicant }).then(result => {
            if (result && result.strDataTableData) {
                this.totalNetIncomeEmi = 0;
                this.obligation = 0;
                this.totalGrossIncome = 0;
                JSON.parse(result.strDataTableData).forEach(element => {
                    console.log(' elemnntttt element.Net_Income__c ', element.Net_Income__c)
                    if (element.Net_Income__c) {
                        this.totalNetIncomeEmi += Number(element.Net_Income__c);
                    }
                    if (element.Obligations__c != undefined) {
                        this.obligation += Number(element.Obligations__c);
                    }
                    if (element.Gross_Income__c != undefined) {
                        this.totalGrossIncome += Number(element.Gross_Income__c);
                    }

                });
            }
            console.log('result ##### ', JSON.stringify(result));
            this.isApplicantEdit = true;
            this.tableData = result;
            this.isSpinnerActive = false;
            this.getDBR();
            this.getTotalIncome();
            this.handleDBRCalculation();
            this.handleApplicationUpdation();
        }).catch(error => {

        })
    }

    handleFormValidation(evt) {
        console.log('change field>>>> ', evt.target.name);
        console.log('changed value>>>>>> ', evt.target.value);
        if (evt.target.name == 'Profile__c') {
            console.log('Customer Segement ###', evt.target.value);
            this.profile = evt.target.value;
            this.customerSegmentChoices = this.getFilteredPicklistValues(this.allCustomerSegments, evt.target.value);
        } else if (evt.target.name == 'Customer_Segment__c') {
            console.log('Customer Segement ###', evt.target.value);
            this.customerSegment = evt.target.value;
            this.customerSubSegmentChoices = this.getFilteredPicklistValues(this.allCustomerSubSegments, evt.target.value);
        } else if (evt.target.name == 'Customer_Sub_Segment__c') {
            console.log('Customer Sub Segment ###', evt.target.value);
            this.customerSubSegment = evt.target.value;
            let newJSON = JSON.parse(JSON.stringify(this.fieldsContent));
            this.fieldsContent = this.showNonMandatory(newJSON);
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(this.fieldsContent);
        } else if (evt.target.name == 'Name__c') {
            this.name = evt.target.value;
        } else if (evt.target.name == 'Seen__c') {
            this.seen = evt.target.value;
        }

        this.fieldsContent = JSON.stringify(this.setValues(evt.target.name, evt.target.value));
        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(this.fieldsContent);
    }

    @api
    async getDBR() {
        var obligation = 0;
        var totalNetIncome = 0;
        if (this.tableData && this.tableData.strDataTableData) {
            var data = JSON.parse(this.tableData.strDataTableData);
            data.forEach(currentItem => {
                if (currentItem.Obligations__c != undefined) {
                    obligation += Number(currentItem.Obligations__c);
                }
                if (currentItem.Gross_Income__c != undefined) {
                    totalNetIncome += Number(currentItem.Gross_Income__c);
                }
                console.log('Current Item ', currentItem);
            });
        }
        let dbrValue = totalNetIncome > 0 && obligation > 0 ? ((obligation / totalNetIncome) * 100).toFixed(2) + '%' : 0;
        console.log('dbrValue= ', dbrValue);
        this.dispatchEvent(new CustomEvent('updatesummary', { detail: dbrValue }));
        return dbrValue;
    }

    handleApplicationUpdation() {
        const fields = {};
        fields[APPLICATION_ID.fieldApiName] = this.applicationId;
        fields[TOTAL_NET_INCOME.fieldApiName] = this.totalNetIncomeEmi;
        fields[OBLIGATION.fieldApiName] = this.obligation;
        fields[GROSS_INCOME.fieldApiName] = this.totalGrossIncome;

        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            console.log('fivbbbb  NET INCOME Updated ###');
        }).catch(error => {
            console.log('Error in updating fivbbb NET INCOME ###', error);
        });
    }

    checkObligationValue(result, value) {
        console.log('checkObligationValue= ', JSON.parse(result))
        var _tempVar = JSON.parse(result);
        let isRequired = true;
        if (!value) {
            isRequired = false;
        }
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "Existing_POS_With_Five_Star__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
        }
        console.log('Obligation _tempVar #### ', _tempVar);
        return JSON.stringify(_tempVar);
    }

    showNonMandatory(result) {
        console.log('showNonMandatory= ', JSON.parse(result))
        var _tempVar = JSON.parse(result);
        let isRequired = true;
        if (this.customerSubSegment === 'Retired' || this.customerSubSegment === 'Housewife' || this.customerSubSegment === 'Student' || this.customerSubSegment === 'Unemployed') {
            isRequired = false;
        }

        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "Gross_Income__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "Obligations__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "Existing_EMI_with_Five_Star__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "Existing_POS_With_Five_Star__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "HM_Score__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "Pincode__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "BM_Comments_for_Cashflow__c") {
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = isRequired;
            }
        }
        console.log('_tempVar #### ', _tempVar);
        return JSON.stringify(_tempVar);
    }

    setValuesForPrimaryApplicant(result) {
        console.log('setValuesForPrimaryApplicant result= ', JSON.parse(result))
        var _tempVar = JSON.parse(result);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === "Existing_EMI_with_Five_Star__c") {
                _tempVar[0].fieldsContent[i].disabled = true;
            } else if (_tempVar[0].fieldsContent[i].fieldAPIName === "Existing_POS_With_Five_Star__c") {
                _tempVar[0].fieldsContent[i].disabled = true;
            }
        }
        console.log('_tempVar #### ', _tempVar);
        return JSON.stringify(_tempVar);
    }

    getSectionPageContent(recId) {
        this.isSpinnerActive = true;
        console.log('RECORD DATA ###');
        this.fieldsContent = undefined;
        //this.name = undefined;
        getSectionContent({ recordIds: recId, metaDetaName: 'Fs_FIV_B_Cashflow' }).then(result => {
            var recordContent = JSON.parse(result.data);
            console.log('Record Content ###', recordContent);
            let tempArr = [];
            recordContent[0].fieldsContent.forEach(element => {
                console.log('element ## ', element)
                if (element.fieldAPIName === 'Name__c') {
                    this.name = element.value;
                } else if (element.fieldAPIName === 'Seen__c') {
                    this.seen = element.value;
                } else if (element.fieldAPIName === 'Profile__c') {
                    this.profile = element.value;
                } else if (element.fieldAPIName === 'Customer_Segment__c') {
                    this.customerSegment = element.value;
                } else if (element.fieldAPIName === 'Customer_Sub_Segment__c') {
                    this.customerSubSegment = element.value;
                } else if (element.fieldAPIName === 'Loan_Applicant__c') {
                    console.log('element.fieldAPIName  = ', element.fieldAPIName, element.value);
                    if (this.allApplicantData && this.allApplicantData.strDataTableData && JSON.parse(this.allApplicantData.strDataTableData)) {
                        console.log('IN IF   = ', JSON.parse(this.allApplicantData.strDataTableData));
                        JSON.parse(this.allApplicantData.strDataTableData).forEach(currentItem => {
                            console.log('element Ids = ', element.value, currentItem.Id, (element.value == currentItem.Id))
                            if (element.value == currentItem.Id) {
                                tempArr.push(currentItem);
                            }
                        });
                    }
                }
            });

            if (this.profile) {
                this.customerSegmentChoices = this.getFilteredPicklistValues(this.allCustomerSegments, this.profile);
            }
            if (this.customerSegment) {
                this.customerSubSegmentChoices = this.getFilteredPicklistValues(this.allCustomerSubSegments, this.customerSegment);
            }

            if (tempArr && tempArr.length) {
                this.selectedApplicant = JSON.parse(JSON.stringify(tempArr))
            }

            console.log('this.selectedApplicant = ', this.selectedApplicant);
            console.log('this.name= ', this.name);
            console.log('this.seen= ', this.seen);
            console.log('this.customerSegment= ', this.customerSegment);
            console.log('this.customerSubSegment= ', this.customerSubSegment);

            if (this.selectedApplicant && this.selectedApplicant.length && this.selectedApplicant[0].Customer_Type__c != 'Primary Applicant') {
                console.log('Not Primary Applicant ###')
                this.fieldsContent = this.setValuesForPrimaryApplicant(result.data);
                let newJSON = JSON.parse(JSON.stringify(this.fieldsContent));
                this.fieldsContent = this.showNonMandatory(newJSON);
            } else {
                this.fieldsContent = result.data;
                let newJSON = JSON.parse(JSON.stringify(this.fieldsContent));
                this.fieldsContent = this.showNonMandatory(newJSON);
            }

            console.log('RECORD DATA ###', result.data)
            this.showForm = true;
            this.isSpinnerActive = false;
        }).catch(error => {
            console.log(error);
        });
    }

    handleSelectedApplication(event) {
        console.log('Edit called #### ', JSON.stringify(event.detail));
        this.isSpinnerActive = true;
        var recordData = event.detail.recordData;
        if (event.detail.ActionName === 'edit') {
            this.isApplicantEdit = false;
            this.recordIds = recordData.Id;
            this.objectIdMap['Cashflow__c'] = this.recordIds
            this.showForm = false;
            this.getSectionPageContent(this.recordIds);
            this.isSpinnerActive = false;
        }
        if (event.detail.ActionName === 'delete') {
            this.recordIdForDelete = event.detail.recordData.Id;
            //this.showDeleteModal = true;
            console.log('Delete Called ');
            this.showDeletePopup = true;
        }
    }

    changedFromChild(event) {
        var tempFieldsContent = event.detail;
        console.log('tempFieldsContent = ', tempFieldsContent);
        if (tempFieldsContent.CurrentFieldAPIName == 'Cashflow__c-Gross_Income__c' || tempFieldsContent.CurrentFieldAPIName == 'Cashflow__c-Obligations__c') {
            var totalNetIncome = Number(tempFieldsContent.previousData['Cashflow__c-Gross_Income__c']) - Number(tempFieldsContent.previousData['Cashflow__c-Obligations__c']);
            console.log('totalNetIncome ### ', totalNetIncome);
            this.fieldsContent = JSON.stringify(this.setValues('Net_Income__c', totalNetIncome));
            if (tempFieldsContent.CurrentFieldAPIName == 'Cashflow__c-Obligations__c') {
                let newJSON = JSON.parse(JSON.stringify(this.fieldsContent));
                this.fieldsContent = this.checkObligationValue(newJSON, tempFieldsContent.CurrentFieldValue);
            }
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(this.fieldsContent);
        }
    }

    handleDBRCalculation() {
        if (this.verificationObject) {
            var emi = this.getEMICalculation(this.verificationObject.bmRecommendedAmount, this.verificationObject.roi, this.verificationObject.tenor);
        }
        console.log('emiii casshflowww ', emi);
        if (this.totalNetIncomeEmi && emi) {
            var dbr = ((emi / this.totalNetIncomeEmi) * 100).toFixed(2);
        }
        console.log('dbrrrrrr >> cashflow ', dbr)
        if (this.verificationId) {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.verificationId;
            fields[DBR_FIELD.fieldApiName] = dbr;
            const recordInput = { fields };
            console.log('recordInput= ', recordInput);
            updateRecord(recordInput).then(() => {
                console.log('UPDATE DONE');
            }).catch(error => {
                console.log('Error in Verification Update = ', error);
            });
        }
    }

    getEMICalculation(p, r, t) {
        let emi;

        r = r / (12 * 100); // one month interest	
        //t = t*12; // one month period	
        emi = (p * r * Math.pow(1 + r, t)) / (Math.pow(1 + r, t) - 1);
        console.log('emiValue ### ', Number(emi + 0.000414));
        return Number(emi + 0.000414);
    }

    handleSave() {
        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        console.log('data #### ', JSON.stringify(data));
        if (data.length > 0) {
            this.isSpinnerActive = true;
            for (var i = 0; i < data.length; i++) {

                console.log('this.selectedApplicant = ', this.selectedApplicant);
                if (this.recordIds) {
                    data[i].Id = this.recordIds;
                } else {
                    data[i].Customer_Information__c = this.selectedApplicant[0].Customer_Information__c;
                    data[i].Loan_Applicant__c = this.selectedApplicant[0].Id;
                    data[i].Application__c = this.applicationId;
                }

                data[i].Is_Fiv_B_Completed__c = true;
                if (this.seen) {
                    data[i].Seen__c = this.seen;
                }
                if (this.name) {
                    data[i].Name__c = this.name;
                }
                if (this.profile) {
                    data[i].Profile__c = this.profile;
                }
                if (this.customerSegment) {
                    data[i].Customer_Segment__c = this.customerSegment;
                }
                if (this.customerSubSegment) {
                    data[i].Customer_Sub_Segment__c = this.customerSubSegment;
                }
                console.log('data 2## ', JSON.stringify(data));
                saveRecord({ dataToInsert: JSON.stringify(data[i]) }).then(result => {
                    this.fieldsContent = undefined;
                    this.showtoastmessage('Success', 'Success', result);
                    this.tableData = undefined;
                    this.selectedApplicant = undefined;
                    this.allApplicantData = undefined;
                    this.getCashflowData();
                    this.handleDBRCalculation();
                    this.handleCancel();
                    console.log('updateSummary called');
                }).catch(error => {
                    console.log(error);
                    this.showtoastmessage('Error', 'Error', JSON.stringify(error));
                });
            }
        } else {
            this.showtoastmessage('Error', 'Error', 'Complete Required Field(s).');
        }
    }
    handleCancel() {
        console.log('handle cancel called ###');
        this.fieldsContent = undefined;
        this.showForm = false;
        this.isApplicantEdit = true;
        this.allApplicantData = undefined;
        this.getAllApplicantMeta();
    }
    showtoastmessage(title, variant, message) {
        var selectedEvent = new CustomEvent('showtoastmessage', {
            detail: {
                'title': title,
                'variant': variant,
                'message': message,
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    handleDelete(event) {
        this.isSpinnerActive = true;
        let label = event.target.label;
        if (label == 'Yes') {
            this.showDeleteModal = false;
            deleteRecord(this.recordIdForDelete)
                .then(() => {
                    this.tableData = undefined;
                    this.getCashflowData();
                    this.isSpinnerActive = false;
                })
                .catch(error => {
                    console.log(error);
                });
        } else if (label == 'No') {
            this.showDeleteModal = false;
            this.isSpinnerActive = false;
        }
    }
    handlemodalactions(event) {
        this.showDeletePopup = false;
        if (event.detail === true) {
            this.tableData = undefined;
            this.getCashflowData();
        }
    }
    handleRadtioButton(event) {
        this.showForm = false;
        this.recordIds = undefined
        this.getSectionPageContent();
        this.selectedApplicant = event.detail;
        console.log('event #### ', JSON.stringify(event.detail));
    }

    getAllApplicantMeta() {
        getAllApplicantMeta({ applicationId: this.applicationId }).then(result => {
            this.allApplicantData = result;
            this.isSpinnerActive = false;
        }).catch(error => {

        })
    }

    setValues(_fieldAPIName, _val) {
        var _tempVar = JSON.parse(this.fieldsContent);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName) {
                if (_tempVar[0].fieldsContent[i].isCheckbox) {
                    _tempVar[0].fieldsContent[i].checkboxVal = Boolean(_val);
                } else {
                    _tempVar[0].fieldsContent[i].value = _val;
                }
            }
        }
        console.log('_tempVar #### ', _tempVar);
        return _tempVar;
    }

    @api
    getTotalIncome() {
        var TNI = 0;
        if (this.tableData && this.tableData.strDataTableData) {
            var data = JSON.parse(this.tableData.strDataTableData);
            data.forEach(element => {
                if (element.Net_Income__c !== undefined) {
                    TNI += Number(element.Net_Income__c);
                }
            });
            console.log('TNI #### ', TNI);
        }
        return TNI;
    }
}