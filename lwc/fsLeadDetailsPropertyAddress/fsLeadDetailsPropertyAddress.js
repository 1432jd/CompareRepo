import { LightningElement, api, track, wire } from 'lwc';
import saveRecord from '@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import getPropertyDetailsData from '@salesforce/apex/FsLeadDetailsControllerHelper.getPropertyDetailsData';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllApplicantMeta from '@salesforce/apex/FsLeadDetailsControllerHelper.getAllApplicantMeta';
import getPincodeDetails from '@salesforce/apex/DatabaseUtililty.getPincodeDetails';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import getApplicantNames from '@salesforce/apex/FsLeadDetailsControllerHelper.getApplicantNames';
import Add_copy_from_an_existing_Address__c from '@salesforce/schema/Property__c.Add_copy_from_an_existing_Address__c';
import { getRecord } from "lightning/uiRecordApi";
import getApplicantAddress from '@salesforce/apex/FsLeadDetailsControllerHelper.getApplicantAddress';
import Country__c from '@salesforce/schema/Property__c.Country__c';

const Property_FIELDS = [
    'Property__c.Applicant__c',
    'Property__c.Add_copy_from_an_existing_Address__c',
    'Property__c.Country__c'
]


export default class FsLeadDetailsPropertyAddress extends LightningElement {
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
    @api allLoanApplicant;
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
    @api applicationId;
    @track propertyRecordTypeId;
    @track city;
    @track state;
    @track district;
    @track taluka;
    @track applicantsOptions = [];
    @api applicants;
    @track sameAsAddress;
    @track appID;
    @track addressResult;
    @track issameAsAddressDisabled = true;
    @track country = 'India';
    @track applicantChanged = false;

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    getPropertyObjectData({ data, error }) {
        if (data) {
            var recordTypeData = data.recordTypeInfos;
            this.propertyRecordTypeId = Object.keys(recordTypeData).find(rti => recordTypeData[rti].name === 'Lead Detail');
        }
    }
    connectedCallback() {
        this.getPropertyDetailsData(true);
        this.getApplicants();
    }

    @wire(getRecord, { recordId: '$recordIds', fields: Property_FIELDS })
    property({ error, data }) {
        if (data) {
            console.log('dataaaaaasdas ', data.fields.Applicant__c.value);
            if (data.fields.Applicant__c.value != undefined && data.fields.Applicant__c.value != null &&
                data.fields.Applicant__c.value != '') {
                this.applicants = data.fields.Applicant__c.value;
                console.log('applcianttsss ', this.applicants)
            }
            if (data.fields.Add_copy_from_an_existing_Address__c.value != undefined && data.fields.Add_copy_from_an_existing_Address__c.value != null &&
                data.fields.Add_copy_from_an_existing_Address__c.value != '') {
                this.sameAsAddress = data.fields.Add_copy_from_an_existing_Address__c.value;
            }

        } else if (error) {
            console.log('ERR IN WIRE Record Property', error);
        }
    }


    async getApplicants() {
        console.log('id2222 ', this.applicationId)
        let appOptionsList = [];
        let theOptions = await getApplicantNames({ applicationId: this.applicationId });
        console.log('theOptionssss ', theOptions)
        theOptions.forEach(currentItem => {
            appOptionsList.push({ label: currentItem.Customer_Information__r.Name, value: currentItem.Id });
        });

        this.applicantsOptions = [{ label: '--None--', value: '', selected: true }, ...appOptionsList];

        console.log('this.applicantsOptionssss ', this.applicantsOptions);
    }

    @wire(getPicklistValues, {
        recordTypeId: "$propertyRecordTypeId",
        fieldApiName: Add_copy_from_an_existing_Address__c
    })
    getAddressPicklistValues(result) {
        if (result.data) {
            console.log('isnidee pick valll ', JSON.stringify(result.data));
            this.sameAsAddressOptions = [{ label: '--None--', value: '', selected: true }, ...result.data.values];
        }
        else if (result.error) {
            alert('ERROR');
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$propertyRecordTypeId",
        fieldApiName: Country__c
    })
    countryOptions;


    @api
    refreshAddNewProperty(isPartialSave) {
        this.tableData = undefined;
        this.getPropertyDetailsData(isPartialSave);
    }
    getPropertyDetailsData(isPartialSave) {
        getPropertyDetailsData({ applicationId: this.applicationId })
            .then(result => {
                console.log('Property Dtaa %%%%', result);

                this.tableData = result;
                this.isApplicantEdit = true;
                this.dispatchEvent(new CustomEvent("getallleaddetailpropertydata", {
                    detail: { 'from': 'Property_Address', data: this.tableData }
                }));
				
				if (result && result.strDataTableData && JSON.parse(result.strDataTableData).length && isPartialSave) {	
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
    getSectionPageContent(recId) {
        this.isSpinnerActive = true;
        getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Property_Address' })
            .then(result => {
                this.fieldsContent = result.data;
                this.isSpinnerActive = false;
                console.log('this.fieldsContenttt ', this.fieldsContent)

                var rs = JSON.parse(result.data);
                rs[0].fieldsContent.forEach(element => {
                    console.log('element.fieldAPIName ', element.fieldAPIName + ' :: element.value ', element.value);
                  //  if (element.fieldAPIName === 'Add_copy_from_an_existing_Address__c') {
                                            console.log('this.sameAsAddress1111 ',this.sameAsAddress)
                        if (this.sameAsAddress === 'Residence Address' || this.sameAsAddress === 'Permanent Address' || this.sameAsAddress === 'Business Address' || this.sameAsAddress === '') {
                            console.log('inside adddd ', this.appID)
                            this.setAddressValues(this.sameAsAddress, this.appID);
                            console.log('inside adddd this.sameAsAddress', this.sameAsAddress)
                        }
                   // }
                    if (element.fieldAPIName === 'MS_Pincode__c') {
                        console.log('element.fieldAPINameeeekoekoasdf12 ', element.fieldAPIName);
                        this.getAllPincodeDetails(element.value);
                    }
                });
            })
            .catch(error => {
                console.log(error);
            });
    }

    async setAddressValues(sameAsAddress, appID) {
        var addressValues = {
            flat: '',
            address1: '',
            address2: '',
            landmark: '',
            village: '',
            city: '',
            taluka: '',
            district: '',
            state: '',
            pincode: ''
        }
        console.log('settt .sameAsAddress', sameAsAddress)

        console.log('recordiddddss ', appID)
        await getApplicantAddress({ applicantId: appID })
            .then(result => {
                console.log('resultsssss ', result)
                this.addressResult = result[0];
                console.log('resultsssss addressResult', this.addressResult)

            })
            .catch(err => {
                console.log(err)
            })

            console.log('this.isRecordEdited && this.applicantChanged ',this.isRecordEdited ,' >>> ',this.applicantChanged)
        
        if (sameAsAddress === 'Residence Address') {
            console.log('inside address ', this.addressResult)
            if (this.addressResult) {
                addressValues.flat = this.addressResult.Residence_Flat_Plot_Number__c;
                addressValues.address1 = this.addressResult.Residence_Address_Line_1__c;
                addressValues.address2 = this.addressResult.Residence_Address_Line_2__c;
                addressValues.village = this.addressResult.Residence_Village__c;
                addressValues.city = this.addressResult.Residence_City__c;
                addressValues.state = this.addressResult.Residence_State__c;
                addressValues.taluka = this.addressResult.Residence_Taluka__c;
                addressValues.district = this.addressResult.Residence_District__c;
                addressValues.pincode = this.addressResult.Residence_Pincode__c;
                console.log('addressValues.flattttt ', addressValues.pincode)
                this.setValues('Is_Residence_Address', addressValues)
            }
        } else if (sameAsAddress === 'Permanent Address') {
            console.log('inside address Permanent')
            addressValues.flat = this.addressResult.Permanent_Flat_Plot_Number__c;
            addressValues.address1 = this.addressResult.Permanent_Address_Line_1__c;
            addressValues.address2 = this.addressResult.Permanent_Address_Line_2__c;
            addressValues.village = this.addressResult.Permanent_Village__c;
            addressValues.city = this.addressResult.Permanent_City__c;
            addressValues.state = this.addressResult.Permanent_State__c;
            addressValues.taluka = this.addressResult.Permanent_Taluka__c;
            addressValues.district = this.addressResult.Permanent_District__c;
            addressValues.pincode = this.addressResult.Permanent_Pincode__c;
            this.setValues('Is_Permanent_Address', addressValues);
        } else if (sameAsAddress === 'Business Address') {
            console.log('inside address Business')
            addressValues.flat = this.addressResult.Business_Flat_Plot_Number__c;
            addressValues.address1 = this.addressResult.Business_Address_Line_1__c;
            addressValues.address2 = this.addressResult.Business_Address_Line_2__c;
            addressValues.village = this.addressResult.Business_Village__c;
            addressValues.city = this.addressResult.Business_City__c;
            addressValues.state = this.addressResult.Business_State__c;
            addressValues.taluka = this.addressResult.Business_Taluka__c;
            addressValues.district = this.addressResult.Business_Village__c;
            addressValues.pincode = this.addressResult.Business_Pincode__c;
            this.setValues('Is_Business_Address', addressValues);
        } else if (sameAsAddress === '' && this.applicantChanged) {
            addressValues.flat = null;
            addressValues.address1 = null;
            addressValues.address2 = null;
            addressValues.village = null;
            addressValues.city = null;
            addressValues.state = null;
            addressValues.taluka = null;
            addressValues.district = null;
            addressValues.pincode = null;
            this.setValues('Is_Null', addressValues);
        }
        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(this.fieldsContent);
        let ref = this;
        setTimeout(function () {
            ref.template.querySelector('c-generic-edit-pages-l-w-c').updateData();
        }, 500);
    }

    handleSelectedApplication(event) {
        console.log('Edit called #### ', JSON.stringify(event.detail));
        this.fieldsContent = undefined;
        var recordData = event.detail.recordData;
        if (event.detail.ActionName === 'edit') {
            this.applicantChanged = false;
            this.isSpinnerActive = true;
            this.isRecordEdited = true;
            this.isApplicantEdit = false;
            this.recordIds = recordData.Id;
            this.objectIdMap['Property__c'] = recordData.Id;
            this.getSectionPageContent(this.recordIds);
            this.isSpinnerActive = false;
            if (recordData.Applicant__c != '') {
                this.applicants = recordData.Applicant__c;
                this.issameAsAddressDisabled = false;
                this.appID = recordData.Applicant__c;
            }
            else {
                this.applicants = '';
                this.issameAsAddressDisabled = true;
                this.sameAsAddress = '';
            }
            if (recordData.Add_copy_from_an_existing_Address__c != '')
                this.sameAsAddress = recordData.Add_copy_from_an_existing_Address__c;
            else {
                this.sameAsAddress = '';
            }
        }
        if (event.detail.ActionName === 'delete') {
            this.recordIdForDelete = event.detail.recordData.Id;
            this.showDeleteModal = true;
        }
    }


    changedFromChild(event) {
        console.log('changedFromChild ### ', JSON.stringify(event.detail));
        var tempFieldsContent = event.detail;
		
			
        if (tempFieldsContent.CurrentFieldAPIName)	
            var splittedFieldAPIName = tempFieldsContent.CurrentFieldAPIName.split('-');	
        let finalFieldAPIName;	
        let finalFieldValue;	
        if (splittedFieldAPIName) {	
            finalFieldAPIName = splittedFieldAPIName[1];	
            finalFieldValue = tempFieldsContent.CurrentFieldValue;	
        }	
        else {	
            finalFieldAPIName = event.target.name;	
            finalFieldValue = event.target.value;	
        }	
        const selectedEvent = new CustomEvent("handletabvaluechange", {	
            detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: finalFieldAPIName, fieldvalue: finalFieldValue, recordId: this.recordIds }	
        });	
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);
		
		
        console.log('111tempFieldsContent.CurrentFieldAPIName111111 ', tempFieldsContent);
        if (tempFieldsContent.CurrentFieldAPIName === 'Property__c-MS_Pincode__c') {
            console.log('tempFieldsContent.CurrentFieldAPIName ', tempFieldsContent.CurrentFieldValue);
            // this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Pincode Change', true)));
            if (tempFieldsContent.CurrentFieldValue != true)
                this.getAllPincodeDetails(tempFieldsContent.CurrentFieldValue);

        }

        if (this.tableData) {

            if (event.target.name == 'Applicant__c') {
                this.applicantChanged = true;
                this.applicants = event.target.value;
                this.appID = event.target.value;
                this.sameAsAddress = '';
                if (this.sameAsAddress === '')
                    this.setAddressValues(this.sameAsAddress, this.appID);
                if (event.target.value === '') {
                    this.issameAsAddressDisabled = true;
                }
                else {
                    this.issameAsAddressDisabled = false;
                }
            } else if (event.target.name == 'Add_copy_from_an_existing_Address__c') {
                this.sameAsAddress = event.target.value;
                if (this.sameAsAddress === 'Residence Address' || this.sameAsAddress === 'Permanent Address' || this.sameAsAddress === 'Business Address' || this.sameAsAddress === '') {
                    console.log('inside adddd ')
                    this.setAddressValues(this.sameAsAddress, this.appID);
                    console.log('inside adddd this.sameAsAddress', this.sameAsAddress)
                }
            }

        }
    }

    getAllPincodeDetails(pinId) {
        getPincodeDetails({ pinId: pinId })
            .then(result => {
                console.log('getPincodeDetails= ', result);
                if (result) {
                    this.city = result.city;
                    this.state = result.state;
                    this.district = result.district;
                    this.taluka = result.taluka;

                    console.log('field ', this.fieldsContent);
                    console.log('check ', this.setValues('City__c', this.city));
                    this.setValues('City__c', this.city);
                    this.setValues('District__c', this.district);
                    this.setValues('State__c', this.state);
                    this.setValues('Taluka__c', this.taluka);
                    this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(this.fieldsContent);
                }
                // this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('City__c', this.city)));
                // this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('District__c', this.district)));
                // this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('State__c', this.state)));
                // this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Taluka__c', this.taluka)));
            })
            .catch(error => {
                console.log(error);
            })
    }

    setValues(_fieldAPIName, _val) {
        var _tempVar = JSON.parse(this.fieldsContent);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            console.log('_fieldAPIName, _val ', _fieldAPIName, _val)
            console.log('_tempVar[0].fieldsContent[i].fieldAPIName 111111 ', _tempVar[0].fieldsContent[i].fieldAPIName)


            if (_fieldAPIName == 'City__c') {
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'City__c') {
                    _tempVar[0].fieldsContent[i].value = _val;
                }
            } else if (_fieldAPIName == 'District__c') {
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'District__c') {
                    _tempVar[0].fieldsContent[i].value = _val;
                }
            } else if (_fieldAPIName == 'State__c') {
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'State__c') {
                    _tempVar[0].fieldsContent[i].value = _val;
                }
            } else if (_fieldAPIName == 'Taluka__c') {
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Taluka__c') {
                    _tempVar[0].fieldsContent[i].value = _val;
                }
            } else if ((_fieldAPIName == 'Is_Residence_Address' || _fieldAPIName == 'Is_Permanent_Address' || _fieldAPIName == 'Is_Business_Address' || _fieldAPIName == 'Is_Null') && _val) {
                console.log('errorrr inside ', _fieldAPIName, 'valll ', _val)

                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Flat_Plot_Number__c') {
                    _tempVar[0].fieldsContent[i].value = _val.flat;
                    if(_fieldAPIName != 'Is_Null')
                    _tempVar[0].fieldsContent[i].disabled = true;
                    else{
                        _tempVar[0].fieldsContent[i].disabled = false;
                    }
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Address_Line_2__c') {
                    _tempVar[0].fieldsContent[i].value = _val.address1;
                    if(_fieldAPIName != 'Is_Null')
                    _tempVar[0].fieldsContent[i].disabled = true;
                    else{
                        _tempVar[0].fieldsContent[i].disabled = false;
                    }
                }
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Address_Line_3__c') {
                    _tempVar[0].fieldsContent[i].value = _val.address2;
                    if(_fieldAPIName != 'Is_Null')
                    _tempVar[0].fieldsContent[i].disabled = true;
                    else{
                        _tempVar[0].fieldsContent[i].disabled = false;
                    }
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Village__c') {
                    _tempVar[0].fieldsContent[i].value = _val.village;
                    if(_fieldAPIName != 'Is_Null')
                    _tempVar[0].fieldsContent[i].disabled = true;
                    else{
                        _tempVar[0].fieldsContent[i].disabled = false;
                    }
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Survey_Number__c') {
                    //  _tempVar[0].fieldsContent[i].value = _val.flat;
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'MS_Pincode__c') {
                    _tempVar[0].fieldsContent[i].lookupVal = _val.pincode;
                    _tempVar[0].fieldsContent[i].value = _val.pincode;
                    if(_fieldAPIName != 'Is_Null'){
                    _tempVar[0].fieldsContent[i].fieldAttribute.disabled = true;
                    console.log('pincodee disabled ', _tempVar[0].fieldsContent[i].disabled)
                    }
                    else{
                        _tempVar[0].fieldsContent[i].disabled = false;
                    }
                    console.log('mss pincodeee ', _tempVar[0].fieldsContent[i].lookupVal)
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'City__c') {
                    _tempVar[0].fieldsContent[i].value = _val.city;
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Taluka__c') {
                    _tempVar[0].fieldsContent[i].value = _val.taluka;
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'State__c') {
                    _tempVar[0].fieldsContent[i].value = _val.state;
                }
                else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'District__c') {
                    _tempVar[0].fieldsContent[i].value = _val.district;
                }
            }
        }
        console.log('Final _tempVar= ', JSON.parse(JSON.stringify(_tempVar)))
        this.fieldsContent = JSON.stringify(_tempVar);
		 for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {	
            if (_tempVar[0].fieldsContent[i].fieldAPIName != 'Add_copy_from_an_existing_Address__c') {	
                let fName = _tempVar[0].fieldsContent[i].fieldAPIName;	
                let fValue = _tempVar[0].fieldsContent[i].value;	
                let rcId = this.recordIds ? this.recordIds : '1';	
                const selectedEvent = new CustomEvent("handletabvaluechange", {	
                    detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }	
                });	
                this.dispatchEvent(selectedEvent);	
            }	
        }
        return _tempVar;
    }

    handleSave() {

        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        console.log('data before save 1= ', data);
        if (data.length > 0) {
            this.isSpinnerActive = true;
            for (var i = 0; i < data.length; i++) {
                if (this.selectedApplicant === undefined) {
                    data[i].Id = this.objectIdMap[data[i].sobjectType];
                }/* else{
                    data[i].Customer_Information__c = this.selectedApplicant[0].Customer_Information__c;
                    data[i].Loan_Applicant__c = this.selectedApplicant[0].Id;
                    data[i].RecordTypeId = this.propertyRecordTypeId;
                }*/
                data[i].Applicant__c = this.applicants;
                data[i].Add_copy_from_an_existing_Address__c = this.sameAsAddress;
                data[i].Country__c = 'India';
                console.log('data before save 2= ', data);
                saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                    .then(result => {
                        this.fieldsContent = undefined;
                        this.isSpinnerActive = false;
                        this.showtoastmessage('Success', 'Success', result);
                        this.tableData = undefined;
                        this.selectedApplicant = undefined;
                        this.allApplicantData = undefined;
                        this.getPropertyDetailsData(true);
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
    handleDelete(event) {
        this.isSpinnerActive = true;
        let label = event.target.label;
        if (label == 'Yes') {
            this.showDeleteModal = false;
            deleteRecord(this.recordIdForDelete)
                .then(() => {
                    this.tableData = undefined;
                    this.getPropertyDetailsData(true);
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
        getAllApplicantMeta({ allLoanApplicant: this.allLoanApplicant })
            .then(result => {
                this.allApplicantData = result;
                this.isSpinnerActive = false;
            })
            .catch(error => {

            })
    }
}