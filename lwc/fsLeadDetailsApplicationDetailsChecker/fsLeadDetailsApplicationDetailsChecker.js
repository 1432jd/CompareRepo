import { LightningElement, api, track, wire } from 'lwc';
import saveRecord from '@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BROKER_NAME from '@salesforce/schema/Application__c.Broker_Name__c';
import { getRecord } from "lightning/uiRecordApi";
const APPLICATION_FIELDS = [
    'Application__c.Broker_Name__c'
];
export default class FsLeadDetailsApplicationDetailsChecker extends LightningElement {
    @api allLoanApplicant;
    @api applicationId;
    @track tableData;
    @track isRecordEdited = false;
    @track recordIds;
    @track fieldsContent;
    @track objectIdMap = { 'Application__c': '' };
    @track isSpinnerActive = false;
    @track fieldOfficerEMPId;
    @track fieldOfficerEMPName;
    @track emptyBroker = false;
    @track isBroker = false;
    @track brokerCode;
    @track brokerName;

    connectedCallback() {

        console.log('appp idddd ', this.applicationId)
        console.log('record idsss ', this.recordIds)
        this.getSectionPageContent(this.applicationId);
    }
    getSectionPageContent(recId) {
        try {
            getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Application_Details' })
                .then(result => {
                    console.log('LeadDetailsApplicationDetailsCkr ### ', JSON.parse(result.data));
                    this.fieldsContent = result.data;
                    var rs = JSON.parse(result.data);
					var _tempVar = JSON.parse(this.fieldsContent);	
                    for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {	
                        var currentItem = _tempVar[0].fieldsContent[i];	
                        console.log('app details LOOPINITIATED Field API Name = ', currentItem.fieldAPIName, ' == ', currentItem.value)	
                        const selectedEvent = new CustomEvent("handletabvaluechange", {	
                            detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: currentItem.fieldAPIName, fieldvalue: currentItem.value, recordId: this.applicationId }	
                        });	
                        this.dispatchEvent(selectedEvent);	
                    }
                    rs[0].fieldsContent.forEach(element => {
                        console.log('elementttttt ', element)
                        console.log('element.fieldAPIName ', element.fieldAPIName + ' :: element.value ', element.value);
                        if (element.fieldAPIName === 'Sourcing_Officer__c') {
                            
                            if (element.value && element.value != ' ') {
                                this.fieldOfficerEMPId = element.value;
                                this.dispatchEvent(new CustomEvent("getallleaddetailapplicationdata", {
                                    detail: { 'from': 'Sourcing_Details', data: element.value }
                                }));
                            }
                        }
                        if (element.fieldAPIName === 'Broker_Code__c') {
                            if (element.value && element.value != ' ')
                                this.brokerCode = element.value;
                                else if(element.value ==  null){
                                    thie.brokerName = null;
                                }
                            if (!this.isBroker) {
                                this.brokerCode = null;
                                this.brokerName = null;
                            }

                        }
                        if (element.fieldAPIName === 'Broker_Name__c') {
                            this.brokerName = element.value;
                        }
                        console.log('broker coddeeededed ',this.brokerCode)
                        if (this.brokerCode == null) {
                            this.brokerName = null;
                        }
                        console.log('brokerrr nameemmee ',this.brokerName)

                        if (element.fieldAPIName === 'Source_Of_Loan__c') {
                            if (element.value === 'Broker' && element.value != ' ') {
                                this.isBroker = true;
                                this.brokerCode = null;
                                this.brokerName = null;
                                console.log('broker issss ', this.isBroker)
                            } else {
                                this.isBroker = false;
                                this.brokerCode = null;
                                this.brokerName = null;
                            }
                        }
                        console.log('broker issss222 ', this.isBroker)
                    });
                })
                .catch(error => {
                    console.log(error);
                });
        } catch (error) {
            console.log(error);
        }
    }


    @wire(getRecord, { recordId: '$applicationId', fields: APPLICATION_FIELDS })
    application({ error, data }) {
        if (data) {

            if (data.fields.Broker_Name__c.value != undefined && data.fields.Broker_Name__c.value != null &&
                data.fields.Broker_Name__c.value != '') {
                this.brokerName = data.fields.Broker_Name__c.value;
            }
        } else if (error) {
            console.log('ERR IN WIRE Record Property', error);
        }
    }

    handleSelectedEMPId(event) {
        console.log('fieldOfficerEMPId >>>>>', event.detail);
        if (event.detail.length > 0) {
            this.fieldOfficerEMPId = event.detail[0].id;
            this.fieldOfficerEMPName = event.detail[0].title;
            console.log('fieldOfficerEMPName >>>>>', this.fieldOfficerEMPName);
           
            this.dispatchEvent(new CustomEvent("getallleaddetailapplicationdata", {
                detail: { 'from': 'Sourcing_Details', data: event.detail[0].id }
            }));

            if (this.fieldOfficerEMPName)
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('fieldOfficerEMPName', this.fieldOfficerEMPName)));
        } else {
            console.log('in undefinedddd')
            this.fieldOfficerEMPId = undefined;
            this.fieldOfficerEMPName = undefined;
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('EmptyFieldOfficerEMPName', this.fieldOfficerEMPName)));
        }
		 if (this.fieldOfficerEMPId) {	
            const selectedEvent = new CustomEvent("handletabvaluechange", {	
                detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: event.target.name, fieldvalue: event.detail[0].id, recordId: this.applicationId }	
            });	
            // Dispatches the event.	
            this.dispatchEvent(selectedEvent);	
        } else {	
            const selectedEvent = new CustomEvent("handletabvaluechange", {	
                detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: event.target.name, fieldvalue: undefined, recordId: this.applicationId }	
            });	
            // Dispatches the event.	
            this.dispatchEvent(selectedEvent);	
        }
    }

    handleSelecteBrokerCode(event) {
        console.log('broker codee >>>>>', event.detail);
        if (event.detail.length > 0) {
            this.brokerCode = event.detail[0].id;
            this.brokerName = event.detail[0].subtitle;

        }
        else {
            this.brokerCode = undefined;
            this.brokerName = undefined;
        }

        console.log(' data[0].Broker_Code__c ', this.brokerCode)
		  if (this.brokerCode) {	
            const selectedBrokerNameEvent = new CustomEvent("handletabvaluechange", {	
                detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: event.target.name, fieldvalue: event.detail[0].id, recordId: this.applicationId }	
            });	
            // Dispatches the event.	
            this.dispatchEvent(selectedBrokerNameEvent);	
        } else {	
            const selectedBrokerNameEvent = new CustomEvent("handletabvaluechange", {	
                detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: event.target.name, fieldvalue: undefined, recordId: this.applicationId }	
            });	
            // Dispatches the event.	
            this.dispatchEvent(selectedBrokerNameEvent);	
        }	
        const selectedEvent = new CustomEvent("handletabvaluechange", {	
            detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: 'Broker_Name__c', fieldvalue: this.brokerName, recordId: this.applicationId }	
        });	
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);
    }

    changedFromChild(event) {
        console.log('changedFromChild ### ', JSON.stringify(event.detail));
        console.log('fieldOfficerEMPName in child >>>>>', this.fieldOfficerEMPName);
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
            detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: finalFieldAPIName, fieldvalue: finalFieldValue, recordId: this.applicationId }	
        });	
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);
        if (tempFieldsContent.CurrentFieldAPIName === 'Application__c-Source_Of_Loan__c') {
            console.log('hello');
            if (tempFieldsContent.CurrentFieldValue === 'Broker') {
                console.log('hi');
                this.isBroker = true;
                this.brokerCode = null;
                this.brokerName = null;
            }
            else {
                this.isBroker = false;
                this.brokerCode = null;
                this.brokerName = null;
            }
        }
    }


    setValues(_fieldAPIName, _val) {
        console.log('_fieldAPIName #### ', _fieldAPIName, '  _val #### ', _val);
        console.log('_val #### ', _val);
        try {
            console.log('fieldsContentttt11111111>> ', JSON.parse(JSON.stringify(this.fieldsContent)));
            var _tempVar = JSON.parse(this.fieldsContent);
            console.log(_tempVar);
            console.log('this.fieldOfficerEMPId>>> ', this.fieldOfficerEMPId)
            for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
                if (_fieldAPIName === 'fieldOfficerEMPName' && _tempVar[0].fieldsContent[i].fieldAPIName === 'Field_Officer_Name__c' && _val) {
                    _tempVar[0].fieldsContent[i].value = _val;
                }
                else if (_fieldAPIName === 'EmptyFieldOfficerEMPName' && _tempVar[0].fieldsContent[i].fieldAPIName === 'Field_Officer_Name__c' && _val == undefined) {
                    _tempVar[0].fieldsContent[i].value = '';
                }
                console.log('outsidee  brokerr ', _tempVar[0].fieldsContent[i].fieldAPIName)

            }
            console.log('tempp varrr ', _tempVar)
            this.fieldsContent = JSON.stringify(_tempVar);
            console.log('fieldsContentttt>> ', JSON.parse(JSON.stringify(this.fieldsContent)));
            this.fieldsContent = JSON.stringify(_tempVar);	
            for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {	
                if (_tempVar[0].fieldsContent[i].fieldAPIName != 'Sourcing_Officer__c') {	
                    let fName = _tempVar[0].fieldsContent[i].fieldAPIName;	
                    let fValue = _tempVar[0].fieldsContent[i].value;	
                    let rcId = this.applicationId ? this.applicationId : '1';	
                    const selectedEvent = new CustomEvent("handletabvaluechange", {	
                        detail: { tabname: 'Sourcing Details', subtabname: 'Application Details', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }	
                    });	
                    this.dispatchEvent(selectedEvent);	
                }	
            }	
        }
        catch (error) { console.log(error) }
        return _tempVar;
    }

    handleSave() {

        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        console.log('data #### ', JSON.stringify(data));
        if (!this.fieldOfficerEMPId) {
            this.showtoastmessage('Error', 'Error', 'Missing Field Officer Employee Id!!');
            return;
        }
        this.dispatchEvent(new CustomEvent("getallleaddetailapplicationdata", {
            detail: { 'from': 'Sourcing_Details', data: this.fieldOfficerEMPId }
        }));

        if (data.length > 0) {
            this.isSpinnerActive = true;
            data[0].Id = this.applicationId;

            if (this.brokerCode == undefined) {
                data[0].Broker_Code__c = null;
            }
            if (this.fieldOfficerEMPId)
                data[0].Sourcing_Officer__c = this.fieldOfficerEMPId;

            if (this.brokerCode)
                data[0].Broker_Code__c = this.brokerCode;

            if (this.fieldOfficerEMPName)
                data[0].Field_Officer_Name__c = this.fieldOfficerEMPName;

            console.log('broker name 22213123123 ', this.brokerName)
            if (this.brokerName)
                data[0].Broker_Name__c = this.brokerName;

            if (!this.isBroker || !this.brokerCode) {
                data[0].Broker_Name__c = null;
                data[0].Broker_Code_L__c = null;
            }
            saveRecord({ dataToInsert: JSON.stringify(data[0]) })
                .then(result => {
                    this.fieldsContent = undefined;
                    this.isSpinnerActive = false;
                    console.log('application details save called');
                    this.showtoastmessage('Success', 'Success', 'Record Saved Successfully.');
                    this.getSectionPageContent(this.applicationId);
                })
                .catch(error => {
                    console.log(error);
                    this.showtoastmessage('Error', 'Error', JSON.stringify(error));
                });	
        } else {
            this.showtoastmessage('Error', 'Error', 'Complete Required Field(s).');
        }
    }


    handleCancel() {
        console.log('handle cancel called ###');
        this.fieldsContent = undefined;
        this.getSectionPageContent(this.applicationId);

    }
    showtoastmessage(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}