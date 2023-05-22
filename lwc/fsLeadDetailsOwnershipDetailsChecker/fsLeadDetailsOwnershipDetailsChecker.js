import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getApplicantNames from '@salesforce/apex/FsLeadDetailsControllerHelper.getApplicantNames';
import getPropertyDetailsData from '@salesforce/apex/FsLeadDetailsControllerHelper.getPropertyDetailsData';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import getAllApplicantMeta from '@salesforce/apex/FsLeadDetailsControllerHelper.getAllApplicantMeta';
import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const Property_FIELDS = [
'Property__c.Current_Owner_Name__c',
'Property__c.Co_Owner_Name__c'
]

export default class FsLeadDetailsOwnershipDetailsChecker extends LightningElement {

@track rowAction = [
    {
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

@api applicationId;
@track applicantsOptions = [];
@track isJoint = false;
@track ownershipStatusVal;
@track tableData;
@track isSpinnerActive = false;
@track isRecordEdited = false;
@track isApplicantEdit = true;
@track recordIds;
@track objectIdMap = { 'Property__c': '' };
@track fieldsContent;
@track percentShareVal;
@track disablePercentShare = false;
@api allLoanApplicant;
@track currentOwnerVal;
@track coOwnerVal;
@track showForm = false;
@track coApplicantsOptions;
@track ownershipDateVal;

connectedCallback() {
    this.getApplicants();
    this.getPropertyDetailsData(true);
}

@wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
getPropertyObjectData({ data, error }) {
    if (data) {
        var recordTypeData = data.recordTypeInfos;
        this.propertyRecordTypeId = Object.keys(recordTypeData).find(rti => recordTypeData[rti].name === 'Lead Detail');
    }
}


async getApplicants() {
    console.log('id2222 ', this.applicationId)
    let appOptionsList = [];
    let coAppOptionsList = [];
    let theOptions = await getApplicantNames({ applicationId: this.applicationId });
    console.log('theOptionssss ', theOptions)
    theOptions.forEach(currentItem => {
        appOptionsList.push({ label: currentItem.Customer_Information__r.Name, value: currentItem.Id });
    });

    this.applicantsOptions = [{ label: '--None--', value: '', selected: true }, ...appOptionsList];

    console.log('this.applicantsOptionssss ', this.applicantsOptions);
}

handleOwnershipStatusChange(event) {
    console.log('handleOwnershipStatusChange called #### ', JSON.stringify(event.detail));

    if(event.target.name == 'Ownership_Status__c' && event.target.value == 'SingleOwnership'){
        const selectedEvent = new CustomEvent("handletabvaluechange", {
        detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: event.target.name, fieldvalue: 'Single', recordId: this.recordIds }
    });
    // Dispatches the event.	
    this.dispatchEvent(selectedEvent);
    }
    
    const selectedEvent = new CustomEvent("handletabvaluechange", {
        detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: event.target.name, fieldvalue: event.target.value, recordId: this.recordIds }
    });
    // Dispatches the event.	
    this.dispatchEvent(selectedEvent);

    if (event.detail.value == 'Joint') {
        console.log('is joint ')
        this.isJoint = true;
        this.percentShareVal = 100;
        this.disablePercentShare = true;
        this.currentOwnerVal = '';
        this.coOwnerVal = '';
        this.ownershipDateVal = null;

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: 'Percent_Share__c', fieldvalue: '100', recordId: this.recordIds }
        });
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);

    }
    else {
        this.isJoint = false;
        this.disablePercentShare = false;
        this.percentShareVal = null;
        this.currentOwnerVal = '';
        this.coOwnerVal = '';
        this.ownershipDateVal = null;

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: 'Percent_Share__c', fieldvalue: '', recordId: this.recordIds }
        });
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);
    }
    console.log('this.isJointttt ', this.isJoint)
}

handleApplicantChange(event) {

    const selectedEvent = new CustomEvent("handletabvaluechange", {
        detail: { tabname: 'Loan Details', subtabname: 'Property Details', fieldapiname: event.target.name, fieldvalue: event.target.value, recordId: this.recordIds }
    });
    // Dispatches the event.	
    this.dispatchEvent(selectedEvent);

    if (event.target.name == 'Current_Owner_Name__c') {
        this.currentOwnerVal = event.target.value;
    }
    else if (event.target.name == 'Co_Owner_Name__c') {
        this.coOwnerVal = event.target.value;
    }
    else if (event.target.name == 'Ownership_Date__c') {
        this.ownershipDateVal = event.target.value;
    }

    let ref1 = this.template.querySelector('.currentApp');
    if (this.currentOwnerVal == this.coOwnerVal && this.isJoint) {
        ref1.setCustomValidity('Current owner and Co applicant name can not be same');
    }
    else {
        ref1.setCustomValidity('');
    }
    ref1.reportValidity();

}


@api
refreshAddNewProperty(isPartialSave) {
    this.tableData = undefined;
    this.getPropertyDetailsData(isPartialSave);
}
getPropertyDetailsData(isPartialSave) {
    getPropertyDetailsData({ applicationId: this.applicationId })
        .then(result => {
            this.tableData = result;
            console.log('tableeee datttaa666 ', this.tableData)
            this.isApplicantEdit = true;
            this.dispatchEvent(new CustomEvent("getallleaddetailpropertydata", {
                detail: { 'from': 'Property_Ownership', data: this.tableData }
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
    getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Ownership_Details_Checker' })
        .then(result => {

            this.isSpinnerActive = false;
            this.fieldsContent = result.data;
            var _tempVar = JSON.parse(this.fieldsContent);
            console.log('this.fieldsContent ', this.fieldsContent)
            var rs = JSON.parse(result.data);
            rs[0].fieldsContent.forEach(element => {
                console.log('element.fieldAPIName ', element.fieldAPIName + ' :: element.value ', element.value);
                if (element.fieldAPIName === 'Ownership_Status__c' && element.value == 'Joint') {
                    this.disablePercentShare = true;
                    this.percentShareVal = 100;
                    this.isJoint = true;
                    this.currentOwnerVal = '';
                    this.coOwnerVal = '';
                    this.ownershipDateVal = null;
                }
                else if (element.fieldAPIName === 'Ownership_Status__c' && element.value != 'Joint') {
                    this.percentShareVal = null;
                    this.currentOwnerVal = '';
                    this.coOwnerVal = '';
                    this.ownershipDateVal = null;
                    this.isJoint = false;

                }
                if (element.fieldAPIName === 'Percent_Share__c' && element.value) {
                    this.percentShareVal = element.value;
                }
                if (element.fieldAPIName === 'Current_Owner_Name__c' && element.value) {
                    this.currentOwnerVal = element.value;
                }
                if (element.fieldAPIName === 'Ownership_Date__c' && element.value) {
                    this.ownershipDateVal = element.value;
                }
                else if (element.fieldAPIName === 'Co_Owner_Name__c' && element.value) {
                    this.coOwnerVal = element.value;
                }
            });

        })
        .catch(error => {
            console.log(error);
        });
}

handleSelectedApplication(event) {
    console.log('Edit called #### ', JSON.stringify(event.detail));
    this.showForm = true;
    this.fieldsContent = undefined;
    var recordData = event.detail.recordData;
    if (event.detail.ActionName === 'edit') {
        this.isSpinnerActive = true;
        this.isRecordEdited = true;
        this.isApplicantEdit = false;
        this.recordIds = recordData.Id;
        this.objectIdMap['Property__c'] = recordData.Id;
        this.getSectionPageContent(this.recordIds);
        this.isSpinnerActive = false;

        recordData.Current_Owner_Name__c = this.currentOwnerVal;
        recordData.Co_Owner_Name__c = this.coOwnerVal;
    }

}

getAllApplicantMeta() {
    getAllApplicantMeta({ allLoanApplicant: this.allLoanApplicant })
        .then(result => {
            this.allApplicantData = result;
            console.log('this.allApplicantData ', this.allApplicantData)
            this.isSpinnerActive = false;
        })
        .catch(error => {

        })
}
handleOwnershipDetailsSubmit(event) {
    //event.preventDefault();
    const fields = event.detail.fields;
    console.log('receipt fields', JSON.stringify(fields.Current_Owner_Name__c));
    fields.Current_Owner_Name__c = this.currentOwnerVal;
    fields.Co_Owner_Name__c = this.coOwnerVal;

    //this.template.querySelector('lightning-record-edit-form').submit(fields);
}
handleOwnershipDetailSuccess(event) {
    console.log('handleCharacterSubmit called');
    console.log('hello ID ####', event.detail.id);
    this.showToast('Success', 'success', 'Record Updated Successfully');

    this.showForm = false;

}


handleCancel() {
    console.log('handle cancel called ###');
    this.fieldsContent = undefined;
    this.isApplicantEdit = true;
    this.allApplicantData = undefined;
    this.getAllApplicantMeta();
}

// show toast Method
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