import { api, track, LightningElement } from 'lwc';
import saveRecord from '@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import getEmploymentDetailsData from '@salesforce/apex/FsLeadDetailsControllerHelper.getEmploymentDetailsData';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllApplicantMeta from '@salesforce/apex/FsLeadDetailsControllerHelper.getAllApplicantMeta';
export default class FsLeadDetailsEmploymentDetails extends LightningElement {
@api rowAction;
@api allLoanApplicant;
@track tableData;
@track isRecordEdited = false;
@track recordIds;
@track fieldsContent;
@track objectIdMap = { 'Employment_Details__c': '' };
@track isSpinnerActive = false;
@track recordIdForDelete;
@track isApplicantEdit = true;
@track selectedApplicant;
@api allApplicantData;
@track empCheck = false;
@track labelSave = 'Save';
@track showDeleteModal;
@track appIdOnRadioButton;
connectedCallback() {
    this.getEmploymentDetailsAllData(true);
}
getSectionPageContent(recId) {
    getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Employment_Details' })
        .then(result => {
            this.fieldsContent = result.data;
            this.isSpinnerActive = false;
            var _tempVar = JSON.parse(this.fieldsContent);
            for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Occupation__c') {
                    console.log('fieldsContent valuesssss >> ', _tempVar[0].fieldsContent[i].value)
                    var isSelfEmployed = _tempVar[0].fieldsContent[i].value === 'Self Employed Professional' ? true : false;
                    var isSalaried = _tempVar[0].fieldsContent[i].value === 'Salaried' ? true : false;
                    var isHouseWife = _tempVar[0].fieldsContent[i].value === 'House wife' ? true : false;
                    var isStudent = _tempVar[0].fieldsContent[i].value === 'Student' ? true : false;
                    var isRetired = _tempVar[0].fieldsContent[i].value === 'Retired' ? true : false;
                    var isSelfEmpNonProf = _tempVar[0].fieldsContent[i].value === 'Self Employed Non Professional' ? true : false;

                if(isSelfEmployed)
                    setTimeout(() => {
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isSelfEmployed', isSelfEmployed)));
                        console.log('insde edittt isSelfEmployed ', isSelfEmployed)
                    }, 200);

                    if(isSelfEmpNonProf)
                        setTimeout(() => {
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isSelfEmpNonProf', isSelfEmpNonProf)));
                        console.log('insde edittt isSelfEmpNonProf ', isSelfEmpNonProf)
                    }, 200);
                    
                    if(isSalaried)
                        setTimeout(() => {
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isSalaried', isSalaried)));
                        console.log('insde edittt ', isStudent)
                    }, 200);

                            if(isHouseWife)
                        setTimeout(() => {
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isHouseWife', isHouseWife)));
                        console.log('insde edittt ', isStudent)
                    }, 200);
                    
                    if(isStudent)
                        setTimeout(() => {
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isStudent', isStudent)));
                        console.log('insde edittt ', isStudent)
                    }, 200);

                    
                    if(isRetired)
                        setTimeout(() => {
                        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isRetired', isRetired)));
                        console.log('insde edittt ', isRetired)
                    }, 200);
                }
                
            }
        })
        .catch(error => {
            console.log(error);
        });
}
setValues(_fieldAPIName, _val) {
    console.log('_fieldAPIName #### ', _fieldAPIName, '  _val #### ', _val);
    console.log('_val #### ', _val);
    try {
        var _tempVar = JSON.parse(this.fieldsContent);
        console.log(_tempVar);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {

            if (_fieldAPIName === 'isSalaried' && (_tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Business__c' ) && _val) {
                console.log('_fieldAPINameeeeee field hide salaried ', _fieldAPIName)
                _tempVar[0].fieldsContent[i].value = '';
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = false;
            }
                if (_fieldAPIName === 'isSalaried' && ( _tempVar[0].fieldsContent[i].fieldAPIName === 'Nature_of_Business__c') && _val) {
                console.log('_fieldAPINameeeeee field  ', _fieldAPIName)
                _tempVar[0].fieldsContent[i].value = '';
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = false;
            }
            else if (_fieldAPIName === 'isSalaried' && (_tempVar[0].fieldsContent[i].fieldAPIName === 'No_of_years_Employment_Business__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Employer__c')) {
                _tempVar[0].fieldsContent[i].disabled = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = true;
            }

            if (_fieldAPIName === 'isSelfEmpNonProf' && _tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Employer__c' && _val) {
                _tempVar[0].fieldsContent[i].value = '';
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = false;
            }
            else if (_fieldAPIName === 'isSelfEmpNonProf' && (_tempVar[0].fieldsContent[i].fieldAPIName === 'No_of_years_Employment_Business__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Nature_of_Business__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Business__c')) {
                _tempVar[0].fieldsContent[i].disabled = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = true;
            }

            console.log(' _tempVar[0].fieldsContent[i].fieldAPINameee1111111 ', _tempVar[0].fieldsContent[i].fieldAPIName)
            if (_fieldAPIName === 'isSelfEmployed' && (_tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Employer__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Nature_of_Business__c') && _val) {
                console.log('Name_of_Employer__ccccc ', _tempVar[0].fieldsContent[i].fieldAPIName)
                _tempVar[0].fieldsContent[i].value = '';
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = false;
            }

            else if (_fieldAPIName === 'isSelfEmployed' && (_tempVar[0].fieldsContent[i].fieldAPIName === 'No_of_years_Employment_Business__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Business__c')) {
                _tempVar[0].fieldsContent[i].disabled = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = true;

            }


            if ((_fieldAPIName === 'isHouseWife' || _fieldAPIName === 'isStudent' || _fieldAPIName === 'isRetired')
                && (_tempVar[0].fieldsContent[i].fieldAPIName === 'No_of_years_Employment_Business__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Nature_of_Business__c'
                    || _tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Employer__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Name_of_Business__c') && _val) {

                _tempVar[0].fieldsContent[i].value = '';
                _tempVar[0].fieldsContent[i].disabled = true;
                _tempVar[0].fieldsContent[i].fieldAttribute.isRequired = false;
                _tempVar[0].fieldsContent[i].fieldAttribute.isShowField = false;
            }

        }
        console.log('tempp varrr ', _tempVar)
        this.fieldsContent = JSON.stringify(_tempVar);
        console.log('fieldsContentttt>> ', JSON.parse(JSON.stringify(this.fieldsContent)));
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {	
            if (_tempVar[0].fieldsContent[i].fieldAPIName != 'Occupation__c') {	
                let fName = _tempVar[0].fieldsContent[i].fieldAPIName;	
                let fValue = _tempVar[0].fieldsContent[i].value;	
                let rcId = this.recordIds ? this.recordIds : '1';	
                const selectedEvent = new CustomEvent("handletabvaluechange", {	
                    detail: { tabname: 'Application Information', subtabname: 'Employment Details', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }	
                });	
                this.dispatchEvent(selectedEvent);	
            }	
        }	
    }
    catch (error) { console.log(error) }
    return _tempVar;
}
changedFromChild(event) {
    console.log('changedFromChild ### ', JSON.stringify(event.detail));
    var tempFieldsContent = event.detail;
        var splittedFieldAPIName = tempFieldsContent.CurrentFieldAPIName.split('-');	
    let finalFieldAPIName = splittedFieldAPIName[1];	
    var loandAppId;	
    if (this.recordIds) {	
        loandAppId = this.recordIds;	
    } else if(this.appIdOnRadioButton) {	
        loandAppId = '1';	
    }	

    if(this.appIdOnRadioButton){	
        const selectedEvent = new CustomEvent("handletabvaluechange", {	
        detail : {tabname:'Application Information',subtabname:'Employment Details',fieldapiname:'Loan_Applicant__c', fieldvalue : this.appIdOnRadioButton, recordId:loandAppId}	
    });	
    // Dispatches the event.	
    this.dispatchEvent(selectedEvent);	
}	

    const selectedEvent = new CustomEvent("handletabvaluechange", {	
        detail: { tabname: 'Application Information', subtabname: 'Employment Details', fieldapiname: finalFieldAPIName, fieldvalue: tempFieldsContent.CurrentFieldValue, recordId: loandAppId }	
    });	
    // Dispatches the event.	
    this.dispatchEvent(selectedEvent);
    if (tempFieldsContent.CurrentFieldAPIName === 'Employment_Details__c-Occupation__c') {

        if (tempFieldsContent.CurrentFieldValue === 'Self Employed Professional') {
            var isSelfEmployed = tempFieldsContent.CurrentFieldValue === 'Self Employed Professional' ? true : false
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isSelfEmployed', isSelfEmployed)));
        }
        if (tempFieldsContent.CurrentFieldValue === 'Salaried') {
            var isSalaried = tempFieldsContent.CurrentFieldValue === 'Salaried' ? true : false;
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isSalaried', isSalaried)));
        }

        if (tempFieldsContent.CurrentFieldValue === 'Self Employed Non Professional') {
            var isSelfEmpNonProf = tempFieldsContent.CurrentFieldValue === 'Self Employed Non Professional' ? true : false;
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isSelfEmpNonProf', isSelfEmpNonProf)));
        }

        if (tempFieldsContent.CurrentFieldValue === 'House wife') {
            var isHouseWife = tempFieldsContent.CurrentFieldValue === 'House wife' ? true : false;
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isHouseWife', isHouseWife)));
        }

        if (tempFieldsContent.CurrentFieldValue === 'Student') {
            var isStudent = tempFieldsContent.CurrentFieldValue === 'Student' ? true : false;
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isStudent', isStudent)));
        }

        if (tempFieldsContent.CurrentFieldValue === 'Retired') {
            var isRetired = tempFieldsContent.CurrentFieldValue === 'Retired' ? true : false;
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isRetired', isRetired)));
        }

    }
}
@api getEmploymentDetailsAllData(isPartialSave) {
    getEmploymentDetailsData({ allLoanApplicant: this.allLoanApplicant })
        .then(result => {
            this.tableData = result;
            this.isApplicantEdit = true;
            this.empCheck = false;
            var temp = JSON.parse(result.strDataTableData);
            if (temp.length == 0)
                this.empCheck = false;
            else
                this.empCheck = true;
            const checkValidEmp = new CustomEvent("checkempdetailinfo", {
                detail: this.empCheck
            });
            console.log('empevent ', checkValidEmp);
            this.dispatchEvent(checkValidEmp);
                
            if (result && result.strDataTableData && JSON.parse(result.strDataTableData).length && isPartialSave) {	
                JSON.parse(result.strDataTableData).forEach(element => {	
                    for (let keyValue of Object.keys(element)) {	
                        if (keyValue != 'Id') {	
                            console.log('insideee111 keyValue ', keyValue)	
                            const selectedEvent = new CustomEvent("handletabvaluechange", {	
                                detail: { tabname: 'Application Information', subtabname: 'Employment Details', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }	
                            });	
                            this.dispatchEvent(selectedEvent);	
                        }	
                    }	
                });	
            }
        })
        .catch(error => {
            console.log('error in empdetail ', error);
        })
}

handleSelectedApplication(event) {
    console.log('Edit called #### ', JSON.stringify(event.detail));
    var recordData = event.detail.recordData;
    this.fieldsContent = undefined;
    if (event.detail.ActionName === 'edit') {
        this.isSpinnerActive = true;
        this.labelSave = 'Update';
        this.isRecordEdited = true;
        this.recordIds = recordData.Id;
        this.objectIdMap['Employment_Details__c'] = recordData.Id;
        this.getSectionPageContent(this.recordIds);
        this.isSpinnerActive = false;
        //this.isApplicantEdit = false;
    }
    if (event.detail.ActionName === 'delete') {
        this.recordIdForDelete = event.detail.recordData.Id;
        this.showDeleteModal = true;
    }
}

handleSave() {
    var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
    if (data.length > 0) {
        this.isSpinnerActive = true;
        console.log('this.objectIdMapppp ', JSON.stringify(this.objectIdMap));
        for (var i = 0; i < data.length; i++) {
            console.log('dataaa iiiii >>>>>> ', JSON.stringify(data[i]));

            if (this.selectedApplicant === undefined) {
                data[i].Id = this.objectIdMap[data[i].sobjectType];
            } else {
                data[i].Customer_Information__c = this.selectedApplicant[0].Customer_Information__c;
                data[i].Loan_Applicant__c = this.selectedApplicant[0].Id;
            }
            if (data[i].sobjectType === 'Employment_Details__c' && data[i].Occupation__c === 'House wife' || data[i].Occupation__c === 'Student' || data[i].Occupation__c === 'Retired') {
                data[i].No_of_years_Employment_Business__c = '';
                data[i].Name_of_Employer__c = '';
                data[i].Name_of_Business__c = '';
                data[i].Nature_of_Business__c = '';
            }

            if (data[i].sobjectType === 'Employment_Details__c' && data[i].Occupation__c === 'Self Employed Non Professional') {
                data[i].Name_of_Employer__c = '';
            }
            console.log('dataaa>>>>>> ', JSON.stringify(data));
            saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                .then(result => {
                    this.fieldsContent = undefined;
                    this.isSpinnerActive = false;
                    this.showtoastmessage('Success', 'Success', result);
                    this.tableData = undefined;
                    this.allApplicantData = undefined;
                    this.getEmploymentDetailsAllData(true);
                    this.getAllApplicantMeta();
                    this.selectedApplicant = undefined;
                })
                .catch(error => {
                    console.log(error);
                    this.showtoastmessage('Error', 'Error', JSON.stringify(error));
                });
        }
            
        const removeEvent = new CustomEvent("handletabvalueremove", {	
            detail: { tabname: 'Application Information', subtabname: 'Employment Details' }	
        });	
        // Dispatches the event.	
        this.dispatchEvent(removeEvent);
    } else {
        this.showtoastmessage('Error', 'Error', 'Complete Required Field(s).');
    }
}
handleCancel() {
    this.fieldsContent = undefined;
    this.isApplicantEdit = true;
    this.allApplicantData = undefined;
    this.getAllApplicantMeta();
    this.getEmploymentDetailsAllData(true);
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
                this.getEmploymentDetailsAllData(true);
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
    this.labelSave = 'Save';
    this.getSectionPageContent();
    this.selectedApplicant = event.detail;
    this.appIdOnRadioButton = event.detail[0].Id;
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
handlemodalactions(event) {
    this.showDeleteModal = false;
    if (event.detail === true) {
        this.tableData = undefined;
        this.getEmploymentDetailsAllData(true);
    }
}
}