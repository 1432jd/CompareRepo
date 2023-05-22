/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-05-02
* @modified         2022-07-21
* @Description      This component is build to handle all the operations related to 
                    Verification-C Character Tab in FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
import { LightningElement, api, track } from 'lwc';
import getApplicantList from '@salesforce/apex/FIV_C_Controller.getApplicantList';
import getCharacterTabRecords from '@salesforce/apex/FIV_C_Controller.getCharacterTabRecords';
import deleteRecord from '@salesforce/apex/Utility.deleteRecord';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const rowAction = [{
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
},
{
    //label: 'Delete',
    type: 'button-icon',
    fixedWidth: 50,
    typeAttributes: {
        iconName: 'utility:delete',
        title: 'Delete',
        variant: 'border-filled',
        alternativeText: 'Delete',
        name: 'delete'
    }
}];

const rowAction2 = [{
    label: 'Action',
    type: 'button-icon',
    fixedWidth: 50,
    typeAttributes: {
        iconName: 'utility:live_message',
        title: 'Verify Mobile',
        variant: 'border-filled',
        alternativeText: 'Verify Mobile',
        name: 'verify'
    }
}];

export default class FivcCharacterLWC extends LightningElement {
    @api applicationId;
    @api verificationId;
    @api loginId;
    @api preLoginRecordType;
    @api loanAmount;

    @track rowAction = rowAction;
    @track rowAction2 = rowAction2;
    @track customerList;
    @track customerData;

    @track familyMemberCustomers;
    @track affiliationCustomers;

    @track familyTableData;
    @track neighbourTableData;
    @track affiliationTableData;
    @track livingStandardTableData;
    @track repaymentTableData;

    @track customerId;
    @track loanApplicantIdFamily;
    @track loanApplicantIdAffiliation;
    @track familyMemberId;
    @track neighbourId;
    @track affiliationId;
    @track livingStandardId;
    @track repaymentId;

    @track familyApplicantType;
    @track affiliationApplicantType;

    @track characterRecordTypeFIVC;

    @track disableFields = false;
    @track isFamilyTab = true;
    @track isNeighbourDetail = false;
    @track isAffiliationDetail = false;
    @track isLivingDetail = false;
    @track isRepaymentDetail = false;

    @track showLoader = false;;

    @track isInvolvedValue;
    @track neighbourName;
    @track neighbourNumber;
    @track familyMemberName;
    @track neighbourFeedback;
    @track affiliationName;
    @track customerTypeValAff;

    @track otherFamilyMemberList;

    @track showDeleteModal = false;
    @track characterValidation = {
        familyDetail: false,
        neighbourInfo: false,
        affiliationDetail: false,
        livingStandardInfo: false,
        repaymentInfo: false
    };

    @track affiliationWithVal;
    @track isOtherApplicantFamily = false;
    @track isOtherApplicantAffiliation = false;
    @track selectedTab = "";

    @track lifeStyle1;
    @track lifeStyle2;
    @track lifeStyle3;
    @track lifeStyle4;
    @track relationship;


    @track showForm = true;

    get modalClasses() {
        return 'slds-modal slds-fade-in-open slds-modal_large';
    }

    get modalStyle() {
        return this.isOtpSend ? 'max-width: 7rem !important;' : '';
    }

    get familyCustomerTypes() {
        return [
            { label: 'Primary Applicant', value: 'Primary Applicant' },
            { label: 'Co-Applicant', value: 'Co-Applicant' },
            { label: 'Guarantor', value: 'Guarantor' },
            { label: 'Others', value: 'Others' },
        ];
    }

    get disableFamilyMemberList() {
        return (this.familyMemberCustomers && this.familyMemberCustomers.length) ? false : true;
    }

    get disableAffiliationList() {
        return (this.affiliationCustomers && this.affiliationCustomers.length) ? false : true;
    }

    get isAffiliationFieldRequired() {
        return this.isInvolvedValue == 'Yes' ? true : false;
    }

    get isNeighbourRemarkRequired() {
        return (this.neighbourFeedback == 'Negative' || this.neighbourFeedback == 'Neutral') ? true : false;
    }

    get isPolitics() {
        return this.affiliationWithVal && this.affiliationWithVal.includes('Politics') ? true : false;
    }

    get isPoliceOrLawyer() {
        return this.affiliationWithVal && (this.affiliationWithVal.includes('Police') || this.affiliationWithVal.includes('Advocate')) ? true : false;
    }

    get showSecondLifestyle() {
        return (this.loanAmount > 200000) ? true : false;
    }

    get showThirdLifestyle() {
        return (this.loanAmount > 400000) ? true : false;
    }

    get showFourthLifestyle() {
        return (this.loanAmount > 800000) ? true : false;
    }

    get isLivingStandardRemarkMandatory() {
        if (this.showFourthLifestyle) {
            return (this.lifeStyle1 == 'Good' && this.lifeStyle2 == 'Good' && this.lifeStyle3 == 'Good' && this.lifeStyle4 == 'Good') ? false : true;
        } else if (this.showThirdLifestyle) {
            return (this.lifeStyle1 == 'Good' && this.lifeStyle2 == 'Good' && this.lifeStyle3 == 'Good') ? false : true;
        } else if (this.showSecondLifestyle) {
            return (this.lifeStyle1 == 'Good' && this.lifeStyle2 == 'Good') ? false : true;
        } else {
            return (this.lifeStyle1 == 'Good') ? false : true;
        }
    }

    get isRelationshipDisable() {
        return this.customerTypeVal == 'Primary Applicant' ? true : false;
    }

    get isSelfRelation() {
        return this.relationship == 'Self' ? false : true;
    }

    get showOtherFamilyMembers() {
        return (this.otherFamilyMemberList && this.otherFamilyMemberList.length) ? true : false;
    }

    // This Method Is Used To Get All Data At Initial Level(Loading)
    connectedCallback() {
        this.showLoader = true;
        this.handleGetCharacterRecordType();
        this.handleGetApplicantList(true);
    }

    // This Method Is Used To Handle Tab Activation Event
    handleTabActivation(event) {
        console.log('handleTabActivation= ', event.target.value);
        this.isFamilyTab = false;
        this.isNeighbourDetail = false;
        this.isAffiliationDetail = false;
        this.isLivingDetail = false;
        this.isRepaymentDetail = false;

        this.selectedTab = event.target.value;
        if (event.target.value == 'Neighbour Detail') {
            this.isNeighbourDetail = true;
        } else if (event.target.value == 'Affiliation Detail') {
            this.isAffiliationDetail = true;
        } else if (event.target.value == 'Living Standard Detail') {
            this.isLivingDetail = true;
        } else if (event.target.value == 'repayment') {
            this.isRepaymentDetail = true;
        } else if (event.target.value == 'Family Detail') {
            this.isFamilyTab = true;
        }
    }

    // This Method Is Used To Handle Form Values
    handleFormValues(event) {
        let fName = event.target.fieldName ? event.target.fieldName : event.target.name;
        let fValue = event.target.value;
        let rcId;

        if (this.isNeighbourDetail) {
            if (event.target.name == "Neighbour_Name__c") {
                this.neighbourName = event.target.value;
            } else if (event.target.name == "Neighbour_Number__c") {
                this.neighbourNumber = event.target.value;
            } else if (event.target.fieldName == "FeedBack__c") {
                this.neighbourFeedback = event.target.value;
            }
            rcId = this.neighbourId ? this.neighbourId : '1';
        } else if (this.isFamilyTab) {
            if (event.target.name == "Family_Member_Name__c") {
                this.familyMemberName = event.target.value;
            } else if (event.target.name == "Customer_Type__c") {
                this.customerId = null;
                this.loanApplicantIdFamily = null;
                this.customerTypeVal = event.target.value;
                if (event.target.value == 'Primary Applicant') {
                    this.relationship = 'Self';
                } else {
                    this.relationship = '';
                }
                if (this.customerTypeVal == 'Others') {
                    this.isOtherApplicantFamily = true;
                } else {
                    this.setCustomerList(this.customerTypeVal);
                    this.isOtherApplicantFamily = false;
                }
            } else if (event.target.fieldName == "Relationship__c") {
                this.relationship = event.target.value;
            }
            rcId = this.familyMemberId ? this.familyMemberId : '1';
        } else if (this.isAffiliationDetail) {
            let fName = event.target.fieldName ? event.target.fieldName : event.target.name;
            if (event.target.fieldName == "Customer_Type__c") {
                this.customerTypeValAff = event.target.value;
                this.customerId = null;
                this.loanApplicantIdAffiliation = null;
                if (this.customerTypeValAff == 'Others') {
                    this.isOtherApplicantAffiliation = true;
                } else {
                    this.setCustomerList(this.customerTypeValAff);
                    this.isOtherApplicantAffiliation = false;
                }
            } else if (event.target.name == "Affiliation_Name__c") {
                this.affiliationName = event.target.value;
            }
            rcId = this.affiliationId ? this.affiliationId : '1';
        } else if (this.isLivingDetail) {
            if (event.target.fieldName == 'Lifestyle__c') {
                this.lifeStyle1 = event.target.value;
            } else if (event.target.fieldName == 'Lifestyle_Loan_Amount_2L_to_4_Lakhs__c') {
                this.lifeStyle2 = event.target.value;
            } else if (event.target.fieldName == 'Lifestyle_Loan_Amount_4L_to_8_Lakhs__c') {
                this.lifeStyle3 = event.target.value;
            } else if (event.target.fieldName == 'Lifestyle_Loan_Amount_8Lakhs__c') {
                this.lifeStyle4 = event.target.value;
            }
            rcId = this.livingStandardId ? this.livingStandardId : '1';
        }

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);

        const selectedEvent2 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'Verification__c', fieldvalue: this.verificationId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent2);

        const selectedEvent3 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'Application__c', fieldvalue: this.applicationId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent3);

        const selectedEvent4 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'Section_Type__c', fieldvalue: this.selectedTab, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent4);

        const selectedEvent5 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'RecordTypeId', fieldvalue: this.characterRecordTypeFIVC, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent5);
    }

    setCustomerList(customerType) {
        if (this.isFamilyTab) {
            let tempList = [];
            for (let keyValue of Object.keys(this.customerData)) {
                let element = JSON.parse(JSON.stringify(this.customerData[keyValue]))
                if (element.Customer_Type__c == customerType) {
                    tempList.push({ label: element.Customer_Information__r.Name, value: element.Id });
                }
            }
            this.familyMemberCustomers = JSON.parse(JSON.stringify(tempList));
            console.log('tempList= ', tempList);
            if (!(tempList && tempList.length)) {
                this.showNotifications('', 'No Applicant with this customer type please select another value', 'error');
            }

        } else if (this.isAffiliationDetail) {
            let tempList = [];
            for (let keyValue of Object.keys(this.customerData)) {
                let element = JSON.parse(JSON.stringify(this.customerData[keyValue]))
                if (element.Customer_Type__c == customerType) {
                    tempList.push({ label: element.Customer_Information__r.Name, value: element.Id });
                }
            }
            console.log('tempList= ', tempList);
            if (!(tempList && tempList.length)) {
                this.showNotifications('', 'No Applicant with this customer type please select another value', 'error');
            }
            this.affiliationCustomers = JSON.parse(JSON.stringify(tempList));
        }
    }

    // This Method Is Used To Handle Check Validations For Form
    checkInputValidity() {
        console.log('checkInputValidity called')
        if (this.isFamilyTab) {
            const allValid = [
                ...this.template.querySelectorAll(".familyGrp"),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            return allValid;
        } else if (this.isNeighbourDetail) {
            const allValid = [
                ...this.template.querySelectorAll(".neighborGrp"),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            return allValid;
        } else if (this.isAffiliationDetail) {
            const allValid = [
                ...this.template.querySelectorAll(".affGrp"),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            return allValid;
        } else if (this.isLivingDetail) {
            return true;
        }
    }

    // This Method Is Used To Handle Customer Selection
    handleCustomerSelection(evt) {
        this.customerId = evt.target.value;
        console.log('handleCustomerSelection = ', JSON.parse(JSON.stringify(this.customerData[this.customerId])));
        if (this.isFamilyTab) {
            this.loanApplicantIdFamily = this.customerData[this.customerId].Id;
            this.familyMemberName = this.customerData[this.customerId].Customer_Information__r.Name;
            if (this.familyTableData && this.familyTableData.strDataTableData && JSON.parse(this.familyTableData.strDataTableData).length) {
                JSON.parse(this.familyTableData.strDataTableData).forEach(currentItem => {
                    if (currentItem.Loan_Applicant__c == this.customerId) {
                        this.familyMemberId = currentItem.Id;
                        this.familyMemberName = currentItem.Family_Member_Name__c;
                        this.customerTypeVal = currentItem.Customer_Type__c;
                    }
                });

                let rcId = this.familyMemberId ? this.familyMemberId : '1';
                const selectedEvent = new CustomEvent("handletabvaluechange", {
                    detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'Loan_Applicant__c', fieldvalue: this.customerId, recordId: rcId }
                });
                this.dispatchEvent(selectedEvent);

                const selectedEvent2 = new CustomEvent("handletabvaluechange", {
                    detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'Family_Member_Name__c', fieldvalue: this.familyMemberName, recordId: rcId }
                });
                this.dispatchEvent(selectedEvent2);
            }
        } else if (this.isAffiliationDetail) {
            console.log('1. this.customerTypeValAff = ', this.customerTypeValAff)
            this.loanApplicantIdAffiliation = this.customerData[this.customerId].Id;
            this.affiliationName = this.customerData[this.customerId].Customer_Information__r.Name;
            if (this.affiliationTableData && this.affiliationTableData.strDataTableData && JSON.parse(this.affiliationTableData.strDataTableData).length) {
                JSON.parse(this.affiliationTableData.strDataTableData).forEach(currentItem => {
                    if (currentItem.Loan_Applicant__c == this.customerId) {
                        this.affiliationId = currentItem.Id;
                        this.isInvolvedValue = currentItem.Is_Involved__c;
                        this.affiliationWithVal = currentItem.Affiliation_with__c;
                        this.affiliationName = currentItem.Affiliation_Name__c;
                        this.customerTypeValAff = currentItem.Customer_Type__c;
                    }
                });
            }
            console.log('2. this.customerTypeValAff = ', this.customerTypeValAff)

            let rcId = this.affiliationId ? this.affiliationId : '1';
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'Loan_Applicant__c', fieldvalue: this.customerId, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent);

            const selectedEvent2 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Character__c', subtabname: this.selectedTab, fieldapiname: 'Affiliation_Name__c', fieldvalue: this.affiliationName, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent2);
        }
    }

    // This Method Is Used To Handle Affiliation Form Values
    handleAffiliationFormValues(evt) {
        if (evt.target.fieldName == 'Is_Involved__c') {
            this.isInvolvedValue = evt.target.value;
        } else if (evt.target.fieldName == 'Affiliation_with__c') {
            console.log('this.affiliationWithVal= ', this.affiliationWithVal);
            this.affiliationWithVal = evt.target.value;
        }
    }

    // This Method Is Used To Handle Table Row Selection Event
    handleTableSelection(evt) {
        console.log('handleTableSelection= ', JSON.stringify(evt.detail));
        var data = evt.detail;

        if (data && data.recordData && data.recordData.Loan_Applicant__c) {
            let loanApplicant = data.recordData.Loan_Applicant__c;
            this.customerId = loanApplicant;
            console.log('Customer Id = ', this.customerId)
        }
        if (this.isFamilyTab) {
            if (data && data.ActionName == 'edit') {
                this.familyMemberId = data.recordData.Id;
                this.familyMemberName = data.recordData.Family_Member_Name__c;
                this.customerTypeVal = data.recordData.Customer_Type__c;
                this.loanApplicantIdFamily = this.customerId;
                if (this.customerTypeVal == 'Others') {
                    this.isOtherApplicantFamily = true;
                } else {
                    this.setCustomerList(this.customerTypeVal);
                    this.isOtherApplicantFamily = false;
                }
            } else if (data && data.ActionName == 'delete') {
                this.familyMemberId = data.recordData.Id;
                this.showDeleteModal = true;
            }
        } else if (this.isNeighbourDetail) {
            if (data && data.ActionName == 'edit') {
                this.neighbourId = data.recordData.Id;
                this.neighbourName = data.recordData.Neighbour_Name__c;
                this.neighbourNumber = data.recordData.Neighbour_Number__c;
                this.neighbourFeedback = data.recordData.FeedBack__c;
            } else if (data && data.ActionName == 'delete') {
                this.neighbourId = data.recordData.Id;
                this.showDeleteModal = true;
            }
        } else if (this.isAffiliationDetail) {
            if (data && data.ActionName == 'edit') {
                this.affiliationId = data.recordData.Id;
                this.affiliationWithVal = data.recordData.Affiliation_with__c;
                this.customerTypeValAff = data.recordData.Customer_Type__c;
                this.affiliationName = data.recordData.Affiliation_Name__c;
                this.isInvolvedValue = data.recordData.Is_Involved__c;
                this.loanApplicantIdAffiliation = this.customerId;
                if (this.customerTypeValAff == 'Others') {
                    this.isOtherApplicantAffiliation = true;
                } else {
                    this.setCustomerList(this.customerTypeValAff);
                    this.isOtherApplicantAffiliation = false;
                }
            } else if (data && data.ActionName == 'delete') {
                this.affiliationId = data.recordData.Id;
                this.showDeleteModal = true;
            }
        } else if (this.isLivingDetail) {
            if (data && data.ActionName == 'edit') {
                this.livingStandardId = data.recordData.Id;
                this.lifeStyle1 = data.recordData.Lifestyle__c;
                this.lifeStyle2 = data.recordData.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c;
                this.lifeStyle3 = data.recordData.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c;
                this.lifeStyle4 = data.recordData.Lifestyle_Loan_Amount_8Lakhs__c;
            } else if (data && data.ActionName == 'delete') {
                this.livingStandardId = data.recordData.Id;
                this.showDeleteModal = true;
            }
        }
    }

    // This Method Is Used To Check Character Tab Validations
    @api
    checkCharacterValidation() {
        console.log('checkCharacterValidation')
        this.characterValidation = {
            familyDetail: true,
            neighbourInfo: true,
            affiliationDetail: true,
            livingStandardInfo: true,
            repaymentInfo: true
        };
        console.log('this.neighbourTableData.strDataTableData = ', this.neighbourTableData);

        if (!this.familyTableData || !this.familyTableData.strDataTableData || this.familyTableData.strDataTableData == '[]') {
            this.characterValidation.familyDetail = false;
            console.log('1');
        } else {
            let customerMap = [];
            JSON.parse(this.familyTableData.strDataTableData).forEach(fam => {
                let parentId = fam.Loan_Applicant__c;
                console.log('validation parentId = ', parentId);
                if (parentId && parentId.trim() && !customerMap.includes(parentId)) {
                    customerMap.push(parentId);
                }
            });
            console.log('validation this.customerList.length = ', this.customerList.length, customerMap.length);
            if (this.customerList && this.customerList.length != customerMap.length) {
                this.characterValidation.familyDetail = false;
                console.log('validation 1.5');
            }
        }

        if (!this.neighbourTableData || !this.neighbourTableData.strDataTableData || this.neighbourTableData.strDataTableData == '[]' || JSON.parse(this.neighbourTableData.strDataTableData).length < 3) {
            this.characterValidation.neighbourInfo = false;
            console.log('2');
        }

        if (!this.affiliationTableData || !this.affiliationTableData.strDataTableData || this.affiliationTableData.strDataTableData == '[]') {
            this.characterValidation.affiliationDetail = false;
            console.log('3');
        }

        if (!this.livingStandardTableData || !this.livingStandardTableData.strDataTableData || this.livingStandardTableData.strDataTableData == '[]') {
            this.characterValidation.livingStandardInfo = false;
            console.log('4');
        } else if (this.livingStandardTableData && this.livingStandardTableData.strDataTableData && JSON.parse(this.livingStandardTableData.strDataTableData).length > 1) {
            this.characterValidation.livingStandardInfo = false;
        }
        console.log('checkCharacterValidation = ', JSON.parse(JSON.stringify(this.characterValidation)));

        this.dispatchEvent(new CustomEvent('charactervalidation', {
            detail: this.characterValidation
        }));
    }

    // This Method Is Used To Show Loader For Short Time
    showTemporaryLoader() {
        this.showLoader = true;
        let ref = this;
        setTimeout(function () {
            ref.showLoader = false;
        }, 500);
    }

    // This Method Is Used To Handle Post Submit Actions
    handleSubmit(event) {
        let checkValidation = this.checkInputValidity();
        console.log('handleSubmit checkValidation= ', checkValidation)

        if (this.isAffiliationDetail) {
            let isInvolved = this.template.querySelector('[data-id="Is_Involved__c"]');
            if (this.affiliationTableData && this.affiliationTableData.strDataTableData && JSON.parse(this.affiliationTableData.strDataTableData).length && JSON.parse(this.affiliationTableData.strDataTableData)[0].Is_Involved__c == 'No') {
                this.showNotifications('', 'Already one record with No Affiliation, if you want to add please delete the old one.', 'error');
                event.preventDefault();
                return;
            } else if (isInvolved.value == 'No' && this.affiliationTableData && this.affiliationTableData.strDataTableData && JSON.parse(this.affiliationTableData.strDataTableData).length && JSON.parse(this.affiliationTableData.strDataTableData)[0].Is_Involved__c == 'Yes') {
                this.showNotifications('', 'Already Affilaited records are there, if you want to add please delete the old one.', 'error');
                event.preventDefault();
                return;
            }
        }

        if (!checkValidation) {
            event.preventDefault();
            this.showNotifications('Invalid input', 'You haven\'t entered correct data', 'error');
        } else {
            this.showTemporaryLoader();
        }
    }

    // This Method Is Used To Handle Post Success Actions
    handleSuccess(event) {
        console.log('HandleSuccess = ', JSON.parse(JSON.stringify(event.detail)));
        let ref = this;
        this.customerId = undefined;
        this.onCancel();
        this.showForm = false;
        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Character__c', subtabname: this.selectedTab }
        });
        this.dispatchEvent(removeEvent);
        if (this.isFamilyTab) {
            this.loanApplicantIdFamily = undefined;
            this.familyMemberId = undefined;
            this.familyTableData = undefined;
            this.familyMemberName = undefined;
            this.customerTypeVal = undefined;
            this.isFamilyTab = false;
            setTimeout(() => {
                ref.familyMemberId = undefined;
                ref.isFamilyTab = true;
                ref.showForm = true;
            }, 200);
            this.getFamilyDetailTableRecords();
        } else if (this.isNeighbourDetail) {
            this.neighbourId = undefined;
            this.neighbourName = undefined;
            this.neighbourNumber = undefined;
            this.neighbourFeedback = undefined;
            this.neighbourTableData = undefined;
            this.isNeighbourDetail = false;
            setTimeout(() => {
                ref.neighbourId = undefined;
                ref.isNeighbourDetail = true;
                ref.showForm = true;
            }, 200);
            this.getNeighbourTableRecords();
        } else if (this.isAffiliationDetail) {
            this.loanApplicantIdAffiliation = undefined;
            this.affiliationId = undefined;
            this.affiliationTableData = undefined;
            this.isAffiliationDetail = false;
            this.affiliationWithVal = undefined;
            setTimeout(() => {
                ref.affiliationId = undefined;
                ref.isAffiliationDetail = true;
                ref.showForm = true;
            }, 200);
            this.getAffiliationTableRecords();
        } else if (this.isLivingDetail) {
            this.livingStandardId = undefined;
            this.livingStandardTableData = undefined;
            setTimeout(() => {
                ref.livingStandardId = undefined;
                ref.isLivingDetail = true;
                ref.showForm = true;
            }, 200);
            this.getLivingStandardTableRecords();
        } else if (this.isRepaymentDetail) {
            this.repaymentId = undefined;
            this.repaymentTableData = undefined;
            setTimeout(() => {
                ref.repaymentId = undefined;
                ref.isRepaymentDetail = true;
                ref.showForm = true;
            }, 200);
            this.getRepaymentTableRecords();
        }
    }

    // This Method Is Used To Handle Cancel Event On Form
    onCancel() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName != 'Application__c' && field.fieldName != 'Verification__c' && field.fieldName != 'Section_Type__c') {
                    console.log('Name= ', field.fieldName)
                    field.reset();
                }
            });
        }
        this.customerId = undefined;
        if (this.isFamilyTab) {
            this.familyMemberId = undefined;
            this.familyMemberName = undefined;
            this.customerTypeVal = undefined;
            this.loanApplicantIdFamily = undefined;
        } else if (this.isNeighbourDetail) {
            this.neighbourId = undefined;
            this.neighbourName = undefined;
            this.neighbourNumber = undefined;
            this.neighbourFeedback = undefined;
        } else if (this.isAffiliationDetail) {
            this.isInvolvedValue = undefined;
            this.affiliationId = undefined;
            this.affiliationWithVal = undefined;
            this.loanApplicantIdAffiliation = undefined;
            this.affiliationName = undefined;
            this.customerTypeValAff = undefined;
        } else if (this.isLivingDetail) {
            this.livingStandardId = undefined;
        } else if (this.isRepaymentDetail) {
            this.repaymentId = undefined;
        }
    }

    // This Method Is Used To Show Toast Notification
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    // This Method Is Used To Handle Delete Operation
    handleDelete(event) {
        console.log('handleDelete= ', event.target.label)
        let label = event.target.label;
        if (label == 'Yes') {
            this.showDeleteModal = false;
            if (this.isFamilyTab) {
                this.handleDeleteRecord(this.familyMemberId);
            } else if (this.isNeighbourDetail) {
                this.handleDeleteRecord(this.neighbourId);
            } else if (this.isAffiliationDetail) {
                this.handleDeleteRecord(this.affiliationId);
            } else if (this.isLivingDetail) {
                this.handleDeleteRecord(this.livingStandardId);
            } else if (this.isRepaymentDetail) {
                this.handleDeleteRecord(this.repaymentId);
            }
        } else if (label == 'No') {
            this.showDeleteModal = false;
            this.repaymentId = undefined;
            this.livingStandardId = undefined;
            this.familyMemberId = undefined;
            this.neighbourId = undefined;
            this.affiliationId = undefined;
        }
    }

    /*=================  All server methods  ====================*/

    // This Method Is Used To Get Applicant List From Server Side
    handleGetApplicantList(callOthers) {
        this.showLoader = true;
        getApplicantList({ appId: this.applicationId }).then((result) => {
            console.log('handleGetApplicantList = ', result);
            if (result) {
                let tempList = [];
                this.customerData = JSON.parse(JSON.stringify(result));

                for (let keyValue of Object.keys(this.customerData)) {
                    let element = JSON.parse(JSON.stringify(this.customerData[keyValue]))
                    tempList.push({ label: element.Customer_Information__r.Name, value: element.Id });
                }

                this.customerList = JSON.parse(JSON.stringify(tempList));
                if (callOthers) {
                    this.getFamilyDetailTableRecords();
                }
            }
        }).catch((err) => {
            if (callOthers) {
                this.getFamilyDetailTableRecords();
            }
            console.log('handleGetApplicantList Error= ', err)
        });
    }

    // This Method Is Used To Get Records For Family Detail Tab From Server Side
    getFamilyDetailTableRecords() {
        this.otherFamilyMemberList = [];
        getCharacterTabRecords({ appId: this.applicationId, metadataName: "FIV_C_Family_Details", sectionName: "Family Detail" }).then((result) => {
            console.log('getFamilyDetailTableRecords= ', result);
            this.familyTableData = JSON.parse(JSON.stringify(result));

            if (this.familyTableData && this.familyTableData.strDataTableData && JSON.parse(this.familyTableData.strDataTableData).length) {
                let tempList = []
                JSON.parse(this.familyTableData.strDataTableData).forEach(element => {
                    if (element.Customer_Type__c == 'Others') {
                        tempList.push({ label: element.Family_Member_Name__c, value: element.Family_Member_Name__c });
                    }
                });
                this.otherFamilyMemberList = JSON.parse(JSON.stringify(tempList));
            }

            JSON.parse(result.strDataTableData).forEach(element => {
                for (let keyValue of Object.keys(element)) {
                    if (keyValue != 'Id') {
                        console.log('insideee111 keyValue ', keyValue)
                        const selectedEvent = new CustomEvent("handletabvaluechange", {
                            detail: { tabname: 'Character__c', subtabname: 'Family Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                        });
                        this.dispatchEvent(selectedEvent);
                    }
                }
            });
            this.getNeighbourTableRecords();
        }).catch((err) => {
            this.familyTableData = undefined;
            console.log('getFamilyDetailTableRecords Error= ', err);
            this.getNeighbourTableRecords();
        });
    }

    // This Method Is Used To Get Records For Neighbour Detail Tab From Server Side
    getNeighbourTableRecords() {
        this.neighbourTableData = undefined;
        getCharacterTabRecords({ appId: this.applicationId, metadataName: "FIV_C_Neighbour", sectionName: "Neighbour Detail" }).then((result) => {
            console.log('getNeighbourTableRecords= ', result);
            this.neighbourTableData = JSON.parse(JSON.stringify(result));
            JSON.parse(result.strDataTableData).forEach(element => {
                for (let keyValue of Object.keys(element)) {
                    if (keyValue != 'Id') {
                        console.log('insideee111 keyValue ', keyValue)
                        const selectedEvent = new CustomEvent("handletabvaluechange", {
                            detail: { tabname: 'Character__c', subtabname: 'Neighbour Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                        });
                        this.dispatchEvent(selectedEvent);
                    }
                }
            });
            this.getAffiliationTableRecords();
        }).catch((err) => {
            this.neighbourTableData = undefined;
            console.log('getNeighbourTableRecords Error= ', err);
            this.getAffiliationTableRecords();
        });
    }

    // This Method Is Used To Get Records For Affiliation Tab From Server Side
    getAffiliationTableRecords() {
        this.affiliationTableData = undefined;
        getCharacterTabRecords({ appId: this.applicationId, metadataName: "FIV_C_Affiliation", sectionName: "Affiliation Detail" }).then((result) => {
            console.log('getAffiliationTableRecords= ', result);
            this.affiliationTableData = JSON.parse(JSON.stringify(result));
            JSON.parse(result.strDataTableData).forEach(element => {
                for (let keyValue of Object.keys(element)) {
                    if (keyValue != 'Id') {
                        console.log('insideee111 keyValue ', keyValue)
                        const selectedEvent = new CustomEvent("handletabvaluechange", {
                            detail: { tabname: 'Character__c', subtabname: 'Affiliation Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                        });
                        this.dispatchEvent(selectedEvent);
                    }
                }
            });
            this.getLivingStandardTableRecords();
        }).catch((err) => {
            this.affiliationTableData = undefined;
            console.log('getAffiliationTableRecords Error= ', err);
            this.getLivingStandardTableRecords();
        });
    }

    // This Method Is Used To Get Records For Living Standard Tab From Server Side
    getLivingStandardTableRecords() {
        this.livingStandardTableData = undefined;
        getCharacterTabRecords({ appId: this.applicationId, metadataName: "FIV_C_LivingStandard", sectionName: "Living Standard Detail" }).then((result) => {
            console.log('getLivingStandardTableRecords= ', result);
            this.livingStandardTableData = JSON.parse(JSON.stringify(result));
            JSON.parse(result.strDataTableData).forEach(element => {
                for (let keyValue of Object.keys(element)) {
                    if (keyValue != 'Id') {
                        console.log('insideee111 keyValue ', keyValue)
                        const selectedEvent = new CustomEvent("handletabvaluechange", {
                            detail: { tabname: 'Character__c', subtabname: 'Living Standard Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                        });
                        this.dispatchEvent(selectedEvent);
                    }
                }
            });

            this.checkCharacterValidation();
            this.showLoader = false;
        }).catch((err) => {
            this.livingStandardTableData = undefined;
            console.log('getLivingStandardTableRecords Error= ', err);
            this.showLoader = false;
            this.checkCharacterValidation();
        });
    }

    // This Method Is Used To Delete Record From Server Side
    handleDeleteRecord(recordIdToDelete) {
        this.showTemporaryLoader();
        deleteRecord({ recordId: recordIdToDelete }).then((result) => {
            console.log('handleDeleteRecord = ', result);
            if (result == 'success') {
                this.showNotifications('', 'Record deleted successfully', 'success');
                if (this.isFamilyTab) {
                    this.familyTableData = undefined;
                    this.familyMemberId = undefined;
                    this.getFamilyDetailTableRecords();
                } else if (this.isNeighbourDetail) {
                    this.neighbourId = undefined;
                    this.neighbourTableData = undefined;
                    this.getNeighbourTableRecords();
                } else if (this.isAffiliationDetail) {
                    this.affiliationTableData = undefined;
                    this.affiliationId = undefined;
                    this.getAffiliationTableRecords();
                } else if (this.isLivingDetail) {
                    this.livingStandardId = undefined;
                    this.livingStandardTableData = undefined;
                    this.getLivingStandardTableRecords();
                } else if (this.isRepaymentDetail) {
                    this.repaymentId = undefined;
                    this.repaymentTableData = undefined;
                    this.getRepaymentTableRecords();
                }
            }
        }).catch((err) => {
            console.log('Error in handleDeleteRecord = ', err);
        });
    }

    // This Method Is Used To Get Character RecordTypeId From Server Side
    handleGetCharacterRecordType() {
        getRecordTypeId({
            sObjectName: 'Character__c',
            recordTypeName: 'FIV-C Character'
        }).then((result) => {
            console.log('handleGetPersonRecordTypeId = ', result);
            this.characterRecordTypeFIVC = result
        }).catch((err) => {
            console.log('Error in handleGetPersonRecordTypeId = ', err);
        });
    }
}