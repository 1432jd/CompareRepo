import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from '@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import getLoanDetailsData from '@salesforce/apex/FsLeadDetailsControllerHelper.getLoanDetailsData';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAllApplicantMeta from '@salesforce/apex/FsLeadDetailsControllerHelper.getAllApplicantMeta';
export default class FsLeadDetailsLoanType extends LightningElement {
    @api recordId;
    @track fieldsContent;
    @track isSpinnerActive = false;
    @track reqLoanAmt;
    @track takeOvAmt;

    connectedCallback() {
        console.log('recordiiddd', this.recordId)
        this.getSectionPageContent(this.recordId);
    }

    getSectionPageContent(recId) {
        try {
            this.isSpinnerActive = true;
            getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Loan_Type' })
                .then(result => {
                    this.fieldsContent = result.data;
                    this.isSpinnerActive = false;
                    console.log('this.fieldsContent #### ', this.fieldsContent);

                    this.fieldsContent = result.data;
                    this.isSpinnerActive = false;
                    var _tempVar = JSON.parse(this.fieldsContent);
                    //var reqLoanAmt;
                    //var takeOverAmt;
                    for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {

                        if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Requested_Loan_Amount__c') {
                            this.reqLoanAmt = _tempVar[0].fieldsContent[i].value != null ? _tempVar[0].fieldsContent[i].value : 0;
                            console.log('reqqqqqq sectionnn ', _tempVar[0].fieldsContent[i].value);
                        }

                        if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Take_Over_Amount__c') {
                            this.takeOvAmt = _tempVar[0].fieldsContent[i].value != null ? _tempVar[0].fieldsContent[i].value : 0;
                            console.log('reqqqqqq sectionnn ', _tempVar[0].fieldsContent[i].value);
                            //reqLoanAmt = _tempVar[0].fieldsContent[i].value;
                        }

                        if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Take_Over__c') {
                            var val = _tempVar[0].fieldsContent[i].value === 'Yes' ? true : false;
                            console.log('value #### ', val);
                            setTimeout(() => {
                                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Take_Over_Amount__c', val)));
                            }, 200);
                        }

                        if (this.reqLoanAmt || this.takeOvAmt) {
                            var disbursal = this.reqLoanAmt - this.takeOvAmt;
                            console.log('disbursallll', disbursal)
                            setTimeout(() => {
                                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Customer_Disbursal_amount__c', disbursal)));
                            }, 200);
                        }

                        // setTimeout(() => {
                        //         this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Customer_Disbursal_amount__c', this.reqLoanAmt - this.takeOvAmt)));
                        // }, 200);

                    }
					  for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {	
                        var currentItem = _tempVar[0].fieldsContent[i];	
                        console.log('LOOPINITIATED Field API Name = ', currentItem.fieldAPIName, ' == ', currentItem.value)	
                        const selectedEvent = new CustomEvent("handletabvaluechange", {	
                            detail: { tabname: 'Loan Details', subtabname: 'Loan Type', fieldapiname: currentItem.fieldAPIName, fieldvalue: currentItem.value, recordId: this.recordId }	
                        });	
                        this.dispatchEvent(selectedEvent);	
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        } catch (error) {
            console.log(error);
        }
    }

    @api
    getLoanTypeData() {
        var isRequiredFieldCompleted = true;
        getSectionContent({ recordIds: this.recordId, metaDetaName: 'Lead_Details_Loan_Type' })
            .then(result => {
                var _tempVar = JSON.parse(result.data);
                for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
                    console.log('_tempVar[0].fieldsContent[i].value ', _tempVar[0].fieldsContent[i].value);
                    if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Tenure_Requested__c' && _tempVar[0].fieldsContent[i].value === '') {
                        const checkValidLoan = new CustomEvent("checkloantypeinfo", {
                            detail: false
                        });
                        this.dispatchEvent(checkValidLoan);
                        break;
                    } else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Tenure_Requested__c' && _tempVar[0].fieldsContent[i].value !== '') {
                        const checkValidLoan = new CustomEvent("checkloantypeinfo", {
                            detail: true
                        });
                        this.dispatchEvent(checkValidLoan);
                        break;
                    }
                }
            })
            .catch(error => {
                console.log(error);
            });
        return isRequiredFieldCompleted;
        //this.getSectionPageContent();
    }

    changedFromChild(event) {
        console.log('changedFromChild ### ', JSON.stringify(event.detail));
        var tempFieldsContent = event.detail;


        //if(tempFieldsContent.previousData === 'Application__c-Requested_Loan_Amount__c') {
        this.reqLoanAmt = tempFieldsContent.previousData['Application__c-Requested_Loan_Amount__c'];
        console.log('reqqqqqq ', this.reqLoanAmt);
        //}
        if (tempFieldsContent.CurrentFieldAPIName === 'Application__c-Take_Over_Amount__c') {
            this.takeOvAmt = tempFieldsContent.CurrentFieldValue;
            console.log('takeOvAmttttttt ', this.takeOvAmt);

        }

        console.log('reqLoanAmt ', this.reqLoanAmt, 'takeOvAmt>>>> ')
        if (this.reqLoanAmt || this.takeOvAmt) {
            var disbursal = this.reqLoanAmt - this.takeOvAmt;
            console.log('disbursallll', disbursal)
            //  setTimeout(() => {
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Customer_Disbursal_amount__c', disbursal)));
            // }, 200);
        }

        if (tempFieldsContent.CurrentFieldAPIName === 'Application__c-Take_Over__c') {
            var isTakeOver = tempFieldsContent.CurrentFieldValue == 'Yes' ? true : false;
            setTimeout(() => {
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Take_Over_Amount__c', isTakeOver)));
            }, 200);
            // setTimeout(() => {
            //     this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Take_Over__c', tempFieldsContent.CurrentFieldValue)));
            // }, 210);
        }
        // else {
        //     let apiName = tempFieldsContent.CurrentFieldAPIName.split('-')[1];
        //     setTimeout(() => {
        //         this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues(apiName, tempFieldsContent.CurrentFieldValue )));
        //     }, 200);
        // }
		   var splittedFieldAPIName = tempFieldsContent.CurrentFieldAPIName.split('-');	
        let finalFieldAPIName = splittedFieldAPIName[1];	
        const selectedEvent = new CustomEvent("handletabvaluechange", {	
            detail: { tabname: 'Loan Details', subtabname: 'Loan Type', fieldapiname: finalFieldAPIName, fieldvalue: tempFieldsContent.CurrentFieldValue, recordId: this.recordId }	
        });	
        // Dispatches the event.	
        this.dispatchEvent(selectedEvent);
    }
    handleSave() {
        try {
            var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
            console.log('lengthhhh>>>> ',data.length)
            if (data.length > 0) {
                this.isSpinnerActive = true;
                for (var i = 0; i < data.length; i++) {
                    data[i].Id = this.recordId;
                    console.log('data 2## ', JSON.stringify(data));
                    saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                        .then(result => {
                            this.showToastMessage('Success', 'Success', 'Record Updation Successfully.');
                            this.isSpinnerActive = false;
                        })
                        .catch(error => {
                            console.log(error);
                            this.showToastMessage('Error', 'Error', JSON.stringify(error));
                        });
                }
            } else {
                this.showToastMessage('Error', 'Error', 'Complete Required Field(s).');
            }
        } catch (error) {
            console.log(error);
        }
    }
    showToastMessage(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    setValues(_fieldAPIName, _val) {
        var _tempVar = JSON.parse(this.fieldsContent);
        console.log(_tempVar);
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Take_Over_Amount__c' && _val === true) {
                _tempVar[0].fieldsContent[i].disabled = false;
                console.log('inside if');
            }
            else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Take_Over_Amount__c' && _val === false) {
                _tempVar[0].fieldsContent[i].value = undefined;
                console.log('inside if else');
                _tempVar[0].fieldsContent[i].disabled = true;
            }
            else if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Customer_Disbursal_amount__c' && _val) {
                console.log('inside else of disbursalllll=', _val);
                _tempVar[0].fieldsContent[i].value = _val;
            }
            else if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName) {
                console.log('inside else= ', _tempVar[0].fieldsContent[i].fieldAPIName, ' = ', _val);
                _tempVar[0].fieldsContent[i].value = _val;
            }

        }
        _tempVar = JSON.parse(JSON.stringify(_tempVar));
        console.log(_tempVar);
        this.fieldsContent = JSON.stringify(_tempVar);
			
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {	
            if (_tempVar[0].fieldsContent[i].fieldAPIName == 'Customer_Disbursal_amount__c') {	
                let fName = _tempVar[0].fieldsContent[i].fieldAPIName;	
                let fValue = _tempVar[0].fieldsContent[i].value;	
                let rcId = this.recordId ? this.recordId : '1';	
                const selectedEvent = new CustomEvent("handletabvaluechange", {	
                    detail: { tabname: 'Loan Details', subtabname: 'Loan Type', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }	
                });	
                this.dispatchEvent(selectedEvent);	
            }	
        }
        return _tempVar;
    }
}