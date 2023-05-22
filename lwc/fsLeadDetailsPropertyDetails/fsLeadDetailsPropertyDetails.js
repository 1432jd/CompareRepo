import { LightningElement, api, track, wire } from 'lwc';
import saveRecord from '@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import getPropertyDetailsData from '@salesforce/apex/FsLeadDetailsControllerHelper.getPropertyDetailsData';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllApplicantMeta from '@salesforce/apex/FsLeadDetailsControllerHelper.getAllApplicantMeta';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Nature_Of_Property from '@salesforce/schema/Property__c.Nature_Of_Property__c';

const Property_FIELDS = [
    'Property__c.Property_Type__c',
    'Property__c.Nature_Of_Property__c'
]

export default class FsLeadDetailsPropertyDetails extends LightningElement {
    @track rowAction = [
        {
            //label: 'Edit',
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:edit',
                title: 'Edit',
                variant: 'border-filled',
                alternativeText: 'Edit',
                name: 'edit'
            }
        }
    ]
    @track natureOfProperty;
    @api typeofProperty;
    @api allLoanApplicant;
    @api applicationId;
    @track tableData;
    @track isRecordEdited = false;
    @track recordIds;
    @track fieldsContent;
    @track objectIdMap = { 'Property__c': '' };
    @track isSpinnerActive = false;
    @track showDeleteModal = false;
    @track recordIdForDelete;
    @track isApplicantEdit = true;
    @track selectedApplicant;
    @api allApplicantData;
    @track propertyRecordTypeId;
    @track natureOfPropertyTypeOptions;

    get propertyTypeOptions() {
        if (this.natureOfProperty == 'Vacant Land') {
            return [{ label: 'Vacant Land', value: 'Vacant Land' }];
        }
        else if (this.natureOfProperty == 'Residential') {
            return [{ label: 'Flat', value: 'Flat' },
            { label: 'Vacant Land', value: 'Vacant Land' },
            { label: 'House', value: 'House' }];
        }
        // else if (this.natureOfProperty == 'Institutional') {
        //     return [{ label: 'Office', value: 'Office' },
        //     { label: 'Vacant Land', value: 'Vacant Land' }];
        // }
        else if (this.natureOfProperty == 'Commercial') {
            return [{ label: 'Office', value: 'Office' },
            { label: 'Vacant Land', value: 'Vacant Land' },
            { label: 'Shop', value: 'Shop' }];
        }
    }

    @wire(getRecord, { recordId: '$recordIds', fields: Property_FIELDS })
    property({ error, data }) {
        if (data) {

            if (data.fields.Nature_Of_Property__c.value != undefined && data.fields.Nature_Of_Property__c.value != null &&
                data.fields.Nature_Of_Property__c.value != '') {
                this.natureOfProperty = data.fields.Nature_Of_Property__c.value;
            }
            if (data.fields.Property_Type__c.value != undefined && data.fields.Property_Type__c.value != null &&
                data.fields.Property_Type__c.value != '') {
                this.typeofProperty = data.fields.Property_Type__c.value;
            }
        } else if (error) {
            console.log('ERR IN WIRE Record Property', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getPropertyObjectData({ data, error }) {
        if (data) {
            var recordTypeData = data.recordTypeInfos;
            this.propertyRecordTypeId = Object.keys(recordTypeData).find(rti => recordTypeData[rti].name === 'Lead Detail');
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$propertyRecordTypeId",
        fieldApiName: Nature_Of_Property
    })
    natureOfproperties;

    connectedCallback() {
        this.getPropertyDetailsData();
    }
    @api
    getPropertyVal() {
        console.log('test ### ' + this.tableData);
        var checkLoanType = true;
        var temp = JSON.parse(this.tableData.strDataTableData);
        if (temp.length == 0) {
            checkLoanType = false;
        }
        const checkValidEmp = new CustomEvent("checkpropertyvalidation", {
            detail: checkLoanType
        });
        this.dispatchEvent(checkValidEmp);
        this.dispatchEvent(new CustomEvent("getallleaddetailpropertydata", {
            detail: { 'from': 'Property_Details', data: this.tableData }
        }));
    }
    @api
    refreshAddNewProperty() {
        this.tableData = undefined;
        this.getPropertyDetailsData();
    }
    getPropertyDetailsData() {
        console.log('called ####');
        getPropertyDetailsData({ applicationId: this.applicationId })
            .then(result => {
                console.log('called #### result ', result);
                this.tableData = result;
                this.isApplicantEdit = true;

                if (result && result.strDataTableData && JSON.parse(result.strDataTableData).length) {
                    JSON.parse(result.strDataTableData).forEach(element => {
                        for (let keyValue of Object.keys(element)) {
                            if (keyValue != 'Id') {
                                let value = element[keyValue];
                                if ((keyValue == 'Title_Deed_Date__c' || keyValue == 'Ownership_Date__c') && value) {
                                    value = value.substr(0, 10);
                                }
                                console.log('insideee111 keyValue ', keyValue)
                                const selectedEvent = new CustomEvent("handletabvaluechange", {
                                    detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: keyValue, fieldvalue: value, recordId: element.Id }
                                });
                                this.dispatchEvent(selectedEvent);
                            }
                        }
                    });
                }

            })
            .catch(error => {

            })
    }
    todayDate() {
        var today = new Date();
        var dd = today.getDate() - 1;
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        var todayDate = yyyy + '-' + mm + '-' + dd;
        return todayDate;
    }
    getSectionPageContent(recId) {
        var todayDate = this.todayDate();
        this.isSpinnerActive = true;
        getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Property_Details' })
            .then(result => {
                this.fieldsContent = result.data;
                this.isSpinnerActive = false;
                setTimeout(() => {
                    var _tempVar = JSON.parse(this.fieldsContent);
                    for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
                        if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Title_Deed_Date__c') {
                            _tempVar[0].fieldsContent[i].maxDate = todayDate;
                            break;
                        }
                    }
                    this.fieldsContent = _tempVar;
                    this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.fieldsContent));
                }, 500);
            })
            .catch(error => {
                console.log(error);
            });
    }


    handleSelectedApplication(event) {
        console.log('Edit called #### ', JSON.parse(JSON.stringify(event.detail)));
        this.fieldsContent = undefined;
        var recordData = event.detail.recordData;
        if (event.detail.ActionName === 'edit') {
            this.isSpinnerActive = true;
            this.isApplicantEdit = false;
            this.isRecordEdited = true;
            this.recordIds = recordData.Id;
            this.objectIdMap['Property__c'] = recordData.Id;
            this.getSectionPageContent(this.recordIds);
            this.isSpinnerActive = false;
        }
        if (event.detail.ActionName === 'delete') {
            this.recordIdForDelete = event.detail.recordData.Id;
            this.showDeleteModal = true;
        }
    }

    handleFormValidation(evt) {

        console.log('chnage field>>>> ', evt.target.name);
        console.log('changed value>>>>>> ', evt.target.value);

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: evt.target.name, fieldvalue: evt.target.value, recordId: this.recordIds }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);


        if (this.tableData) {
            if (evt.target.name == 'Nature_Of_Property__c') {
                this.natureOfProperty = evt.target.value;
                this.typeofProperty = undefined;
            }
            else if (evt.target.name == 'Property_Type__c') {
                console.log('Type of Property Type ###', (evt.target.value).length);
                this.typeofProperty = evt.target.value;
            }
        }
    }
    changedFromChild(event) {

        console.log('changedFromChild ### ', JSON.stringify(event.detail));
        this.dataValues = event;
        console.log(this.dataValues);
        var tempFieldsContent = event.detail;

        var splittedFieldAPIName = tempFieldsContent.CurrentFieldAPIName.split('-');
        let finalFieldAPIName = splittedFieldAPIName[1];

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: finalFieldAPIName, fieldvalue: tempFieldsContent.CurrentFieldValue, recordId: this.recordIds }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        /*		
        if (tempFieldsContent.CurrentFieldAPIName === 'Property__c-Title_Deed_Date__c') {
            var d1 = new Date().toISOString().substr(0, 10)
            var d2 = new Date(tempFieldsContent.CurrentFieldValue).toISOString().substr(0, 10);
            console.log('date1 ', d1 + ' :: ' + d2);
            if (d2 >= d1) {
                console.log('date2 ', d2);
                this.showToast('Error', 'error', 'Invalid Date, Future Dates Are Not Allowed!!');
                this.closeAction();
                //var dateVal = null;
                let genericedit = this.template.querySelector('c-generic-edit-pages-l-w-c');
                this.fieldsContent = (JSON.stringify(this.setValues('Title_Deed_Date__c', undefined)));
                console.log('this.fieldsContent  ', JSON.parse(this.fieldsContent));
                genericedit.refreshData((this.fieldsContent));
                //this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Title_Deed_Date__c',null)));   
            }
        }*/
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

        this.fieldsContent = JSON.stringify(_tempVar);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            let fName = _tempVar[0].fieldsContent[i].fieldAPIName;
            let fValue = _tempVar[0].fieldsContent[i].value;
            let rcId = this.recordIds ? this.recordIds : '1';
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent);
        }

        return _tempVar;
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        console.log('insidee propp savvvee ', data)
        let check = this.checkRecordValidity();
        console.log('check= ',check)
        // if (!this.natureOfProperty) {
        //     this.showtoastmessage('Error', 'Error', 'Complete Required Field,Nature Of Property');
        //     return;
        // }
        // if (!this.typeofProperty) {
        //     this.showtoastmessage('Error', 'Error', 'Complete Required Field,Type Of Property');
        //     return;
        // }
        if (data.length > 0 && check) {
            this.isSpinnerActive = true;
            for (var i = 0; i < data.length; i++) {
                if (this.selectedApplicant === undefined) {
                    data[i].Id = this.objectIdMap[data[i].sobjectType];
                } /*else{
            data[i].Customer_Information__c = this.selectedApplicant[0].Customer_Information__c;
            data[i].Loan_Applicant__c = this.selectedApplicant[0].Id;
            data[i].RecordTypeId = this.propertyRecordTypeId;
        }*/

                data[i].Nature_Of_Property__c = this.natureOfProperty;
                data[i].Property_Type__c = this.typeofProperty;
                console.log('save record called = ',data[i]);
                saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                    .then(result => {
                        console.log('saveRecord = ',result);
                        this.fieldsContent = undefined;
                        this.isSpinnerActive = false;
                        this.showtoastmessage('Success', 'Success', result);
                        this.tableData = undefined;
                        this.selectedApplicant = undefined;
                        this.allApplicantData = undefined;
                        this.getPropertyDetailsData();
                        this.getAllApplicantMeta();
                    })
                    .catch(error => {
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


    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }
    handleDelete(event) {
        this.isSpinnerActive = true;
        let label = event.target.label;
        if (label == 'Yes') {
            this.showDeleteModal = false;
            deleteRecord(this.recordIdForDelete)
                .then(() => {
                    this.tableData = undefined;
                    this.getPropertyDetailsData();
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
    handleRadtioButton(event) {
        this.getSectionPageContent();
        this.selectedApplicant = event.detail;
        console.log('event #### ', JSON.stringify(event.detail));
    }
    getAllApplicantMeta() {
        getAllApplicantMeta({ applicationId: this.applicationId })
            .then(result => {
                this.allApplicantData = result;
                this.isSpinnerActive = false;
            })
            .catch(error => {

            })
    }
    checkRecordValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid1;
    }
}