import { LightningElement, track, api, wire } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONSIDER_FIELD from "@salesforce/schema/Loan_Details__c.To_be_considerd_for_DBR__c";
import LOAN_DETAIL_OBJECT from '@salesforce/schema/Loan_Details__c';
import getHighmarkObligations from '@salesforce/apex/fsHighmarkObligationsScreenController.getHighmarkObligations';
import saveObligations from '@salesforce/apex/fsHighmarkObligationsScreenController.saveObligations';
import getRecordTypeId from '@salesforce/apex/fsHighmarkObligationsScreenController.getRecordTypeId';
import getcharacterRepayment from '@salesforce/apex/fsHighmarkObligationsScreenController.getcharacterRepayment';
//import setHMScore from '@salesforce/apex/fsPcAcController.setHMScore';

//Added on 15.05.23
import getHMScore from '@salesforce/apex/fsPcAcController.getHMScore';

export default class FsHighmarkObligationsScreen extends LightningElement {

    @api applicationId;
    @api customerOptions;
    @api stageName;
    @api verificationId;

    @track index;
    @track title;
    @track record = {};
    @track highmarkpcTableData;
    @track highmarkSpinner = false;
    @track considertypeoptions;
    @track highmarkMap = new Map();
    @track isDisabled = true;
    @track buttonLabel = 'Save';
    @track isSingleRecord = false;
    @track recordId;
    @track repaymentRecordId;
    @track characterRecordTypeId;
    _wiredResult;



    connectedCallback() {
        console.log('in repayment ', this.customerOptions);
        this.title = this.stageName + ' - Highmark Obligations';
        console.log('verfId', this.verificationId);
        this.getcharacterRepaymentDetail();
        this.getcharcterRecordTypeId();
        this.showoverallRemarks = true;

    }




    @wire(getHighmarkObligations, { appId: '$applicationId', StageName: '$stageName' })
    wiredObligations(value) {
        //this.handleBureauCreation();
        this.highmarkSpinner = true;
        //this.wiredActivities = value;
        const { data, error } = value;
        this._wiredResult = value;
        if (data) {
            console.log('highmark in wire', data);
            this.highmarkpcTableData = JSON.parse(JSON.stringify(data));
            console.log('this.highmarkmap from apex', this.highmarkpcTableData[0].HighmarkMap);
            if (this.highmarkpcTableData[0].HighmarkMap)
                for (var key in this.highmarkpcTableData[0].HighmarkMap) {
                    this.highmarkMap.set(key, this.highmarkpcTableData[0].HighmarkMap[key]);
                }
            console.log('this.highmarkmap', this.highmarkMap);

            if (this.highmarkpcTableData.length == 1) {
                this.isSingleRecord = true;
            }
            this.highmarkSpinner = false;

        } else if (error) {
            console.error('wiredObligations error => ', JSON.stringify(error));
            this.highmarkSpinner = false;
        }

    }

    // importing the id type field from Loan_detail__C 
    @wire(getObjectInfo, { objectApiName: LOAN_DETAIL_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CONSIDER_FIELD })
    considertype({ data, error }) {
        if (data) {
            this.considertypeoptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    // method used to Perform add Row Action
    handleaddRow(event) {
        let index = this.highmarkpcTableData.length + 1;
        let record = {
            srNo: index, id: '', applicantName: '', typeofloan: '', ownership: '', currentDPD: '', remarks: '', tobeconsiderValue: '', maxdpd: '',
            overdueAmount: 0, osAmt: 0, obligations: 0, loanAmt: 0, type: 'Self', IsSelfType: true, highmarkScore: '', bureauId: '', isChanged: false, stageName: this.stageName
        };
        let data = this.highmarkpcTableData;
        console.log('data', data);
        data.push(record);
        this.highmarkpcTableData = data;
        this.showToast('', 'success', 'Row Added Successfully');
        if (this.highmarkpcTableData.length == 1) {
            this.isSingleRecord = true;
        }
        else {
            this.isSingleRecord = false;
        }
    }

    // method used to perform delete Row Action
    handledeleteRow(event) {
        this.highmarkSpinner = true;
        console.log('this.highmarkpcTableData', this.highmarkpcTableData);
        if (event.currentTarget.dataset.id) {
            let recordId = event.currentTarget.dataset.id;
            console.log('record ID to be Deleted', recordId);
            deleteRecord(recordId)
                .then(() => {
                    this.showToast('', 'success', 'Record Deleted Successfully');
                    this.highmarkSpinner = false;
                    refreshApex(this._wiredResult);
                })
                .catch(error => {
                    this.showToast('', 'error', error.body.message);
                    this.highmarkSpinner = false;
                });
        }
        else {
            this.showToast('', 'success', 'Row Deleted Successfully');
        }

        let toBeDeletedRowIndex = event.currentTarget.dataset.index;
        console.log('toBeDeletedRowIndex :', toBeDeletedRowIndex);
        let listOfObligations = [];
        for (let i = 0; i < this.highmarkpcTableData.length; i++) {
            let tempRecord = Object.assign({}, this.highmarkpcTableData[i]); //cloning object
            if (tempRecord.srNo != toBeDeletedRowIndex) {
                listOfObligations.push(tempRecord);
            }
        }
        for (let i = 0; i < listOfObligations.length; i++) {
            listOfObligations[i].srNo = i + 1;
        }
        this.highmarkpcTableData = listOfObligations;
        this.highmarkSpinner = false;
        console.log('after pop this.highmarkpcTableData', this.highmarkpcTableData);

    }

    // handle change method to capture changed values of Grid Fields
    handleChange(evt) {
        this.isDisabled = false;
        console.log('this.highmarkmap in customer change', this.highmarkMap);
        console.log('value ==>', evt.target.className);
        console.log('index', evt.currentTarget.dataset.index);
        if (evt.target.name === 'Applicant Name') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].loanApplicantId = evt.target.value;
            this.highmarkpcTableData[evt.currentTarget.dataset.index].applicantName = this.customerOptions.find(opt => opt.value === evt.target.value).label;
            if (this.highmarkMap.has(evt.target.value)) {
                console.log('highmark score', this.highmarkMap.get(evt.target.value));
                this.highmarkpcTableData[evt.currentTarget.dataset.index].highmarkScore = (this.highmarkMap.get(evt.target.value).Highmark_Score__c != null) ? this.highmarkMap.get(evt.target.value).Highmark_Score__c : null;
                this.highmarkpcTableData[evt.currentTarget.dataset.index].bureauId = (this.highmarkMap.get(evt.target.value).Id != null) ? this.highmarkMap.get(evt.target.value).Id : null;
                console.log(this.highmarkpcTableData[evt.currentTarget.dataset.index]);
            }
            if (this.highmarkpcTableData[evt.currentTarget.dataset.index].loanApplicantId != '') {
                this.handleOnChangeValidation('select', evt.target.name, evt.currentTarget.dataset.index);
            }
        }
        else if (evt.target.name === 'typeOfloan') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].typeofloan = evt.target.value;
        }
        else if (evt.target.name === 'Ownership__c') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].ownership = evt.target.value;
        }
        else if (evt.target.name === 'loanAmt') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].loanAmt = evt.target.value;
        }
        else if (evt.target.name === 'osAmt') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].osAmt = evt.target.value;
        }
        else if (evt.target.name === 'overdueAmt') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].overdueAmount = evt.target.value;
        }
        else if (evt.target.name === 'obligation') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].obligations = evt.target.value;
        }
        else if (evt.target.name === 'currentDPD') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].currentDPD = evt.target.value;
        }
        else if (evt.target.name === 'maxDPD') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].maxdpd = evt.target.value;
        }
        else if (evt.target.name === 'consider-Type') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].tobeconsiderValue = evt.target.value;
            if (this.highmarkpcTableData[evt.currentTarget.dataset.index].tobeconsiderValue != '') {
                this.handleOnChangeValidation('select', evt.target.name, evt.currentTarget.dataset.index);
            }
        }
        else if (evt.target.name === 'remarks') {
            this.highmarkpcTableData[evt.currentTarget.dataset.index].remarks = evt.target.value;
            if (this.highmarkpcTableData[evt.currentTarget.dataset.index].remarks != '')
                this.handleOnChangeValidation('lightning-textarea', evt.target.name, evt.currentTarget.dataset.index);
        }
        this.highmarkpcTableData[evt.currentTarget.dataset.index].isChanged = true;
        console.log('changed row', this.highmarkpcTableData[evt.currentTarget.dataset.index]);
        console.log('changed wrapper', this.highmarkpcTableData);
    }

    // submit button to save the Highmark Obligations
    handleHighmark(event) {
        //let checkerror = true;
        let ref = this.template.querySelectorAll('.slds-select');
        console.log('refs', ref);
        ref.forEach(element => {
            console.log('element &&', element);
            if (element.value == '') {
                element.classList.add('slds-has-error');
                element.style.border ='3px solid red';
                console.log('class Name', element.className);
            }
            /*if (element.name == 'consider-Type') {
                if (element.value == 'No') {
                    console.log('inside NO ###');
                    console.log('element index', element.dataset.index);
                    let req = this.template.querySelectorAll(`[data-index="${element.dataset.index}"]`);
                    req.forEach((item, index, arr) => {
                        console.log('index', item.dataset.index);
                        console.log('index', item.name);
                        console.log('item.required', item.required)
                        if (item.name == 'remarks') {
                            arr[index].setAttribute("required", "true");
                            arr[index].required = 'true';
                            if (item.value == null || item.value == undefined || item.value == '') {
                                console.log('element.value->', element.value);
                                //checkerror = false;
                                arr[index].setCustomValidity('Complete this field.');
                            } else {
                                //checkerror = true;
                                arr[index].setCustomValidity('');
                            }
                            arr[index].reportValidity();
                        }
                    });
                }

                else if (element.value == 'Yes') {
                    console.log('inside YES ###');
                    let req = this.template.querySelectorAll(`[data-index="${element.dataset.index}"]`);
                    req.forEach((item, index, arr) => {
                        if (item.name == 'remarks') {
                            arr[index].removeAttribute('required');
                            arr[index].required = false;
                            //checkerror = true;
                            arr[index].setCustomValidity('');
                            arr[index].reportValidity();
                        }

                    });
                }
            }*/
        })

        let checkValidity = this.handleCheckValidity();
        console.log('Handle Highmark Called=', checkValidity);
        if (!checkValidity /*|| !checkerror*/) {
            this.showToast('', 'error', 'Complete all Required Validations');
            return;
        }
        if (checkValidity /*&& checkerror */) {
            this.highmarkSpinner = true;
            this.highmarkpcTableData[0].HighmarkMap = null;
            console.log('hello data', this.highmarkpcTableData);
            saveObligations({ dataWrapper: JSON.stringify(this.highmarkpcTableData) })
                .then(res => {
                    console.log('saveObligations', res);
                    if (res == 'success') {
                        this.showToast('', 'success', 'Records Saved Successfully');
                        refreshApex(this._wiredResult);
                        console.log('refersh Apex', this.highmarkpcTableData);
                        this.HandleHMScoreUpdation();
                        this.isDisabled = true;
                    }
                    else if (res == 'error') {
                        this.showToast('', 'error', 'Error in Saving Records');
                    }
                    this.highmarkSpinner = false;
                })
                .catch(err => {
                    console.log('err in saveObligations', err);
                    this.showToast('', 'error', 'Error in Saving Records');
                    this.highmarkSpinner = false;
                })
        }
    }


    // method used to check Validation 
    handleCheckValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('.slds-select'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid3 = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid4 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid1 && allValid2 && allValid3 && allValid4) {
            return true;
        }
        else {
            return false;
        }
    }


    // method used to get the Reayment PC Record
    getcharacterRepaymentDetail() {
        let rcType;
        if (this.stageName == 'PC')
            rcType = 'PC Character';
        else if (this.stageName == 'AC')
            rcType = 'AC Character';
        else if (this.stageName == 'FIV - C')
            rcType = 'FIV-C Character';
        console.log('verfId', this.verificationId);
        getcharacterRepayment({ verfId: this.verificationId, recTypeName: rcType }).then(res => {
            console.log('repaymentId >>>> ', res);
            if (res) {
                this.repaymentRecordId = res;
                this.buttonLabel = 'Update';
            }
        }).catch(err => {
            console.log('repaymentId error>>>> ', err);
        })
    }


    // on success and on submit method for the PC Repayment Overall Remarks Form
    handlecharacterSubmit(event) {
        console.log('character submit Called', event.detail);
    }


    handleCharacterSuccess(event) {
        this.repaymentRecordId = event.detail.id;
        console.log('handle Sucesss detailId', this.repaymentRecordId);
        if (this.buttonLabel == 'Save')
            this.showToast('', 'success', 'Record Created Successfully');
        if (this.buttonLabel == 'Update')
            this.showToast('', 'success', 'Record Updated Successfully');
        if (this.repaymentRecordId != null)
            this.buttonLabel = 'Update';

    }

    // method used to handle validation class removal on onchange of input elements
    handleOnChangeValidation(elementType, elementName, elementIndex) {
        console.log('item index', elementIndex);
        console.log('item name', elementName);
        console.log('elementType', elementType);
        let refernceString = (elementType == 'select' ? `${elementType}[data-index="${elementIndex}"][name="${elementName}"]` : `${elementType}[data-index="${elementIndex}"]`);
        let ref = this.template.querySelectorAll(refernceString)[0];
        console.log('item  ', ref);
        if (ref && ref.classList.contains('slds-has-error')) {
            ref.classList.remove('slds-has-error');
            ref.style.border = '';
            if (elementType == 'lightning-textarea') {
                ref.setCustomValidity('');
                ref.reportValidity();
            }
            console.log('item class Name ', ref.className);
        }
        if (elementType == 'select' && ref.name == 'consider-Type') {
            let req = this.template.querySelectorAll(`lightning-textarea[data-index="${elementIndex}"]`)[0];
            if (ref.value == 'No') {
                req.setAttribute("required", "true");
                req.required = 'true';
                if (req.value == null || req.value == undefined || req.value == '') {
                    req.setCustomValidity('Complete this field.');
                } else {
                    req.setCustomValidity('');
                }
                req.reportValidity();
            }
            else if (ref.value == 'Yes') {
                req.removeAttribute('required');
                req.required = false;
                req.setCustomValidity('');
                req.reportValidity();
            }
        }
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

    // get the character recordTypeId
    getcharcterRecordTypeId() {
        let rectypeName;
        if (this.stageName == 'AC')
            rectypeName = 'AC Character';
        if (this.stageName == 'PC')
            rectypeName = 'PC Character';
        else if (this.stageName == 'FIV - C')
            rectypeName = 'FIV-C Character';
        getRecordTypeId({ objName: 'Character__c', recordTypeName: rectypeName })
            .then(res => {
                if (res)
                    this.characterRecordTypeId = res;
                console.log('character record type id >>>> ', JSON.stringify(res));
            })
            .catch(err => {
                console.log('errr occured in getting record type id for character', err);
            })
    }

    // Method to update the HM Score on the Application
    HandleHMScoreUpdation() {
        //method updated from setHMScore to getHMScore to implement updated logic
        getHMScore({ appId: this.applicationId})
            .then(result => {
                console.log('HM Score Updation method called', result);
            })
            .catch(error => {
                console.log('Error in HM Score Updation', result);
            })
    }

}