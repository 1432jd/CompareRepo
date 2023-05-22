import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCharacterTabRecords from '@salesforce/apex/fsPcAcController.getCharacterTabRecords';
import getRecordTypeId from '@salesforce/apex/fsPcAcController.getRecordTypeId';
import getApplicantList from '@salesforce/apex/fsPcAcController.getApplicantList';
import setlivingStyle from '@salesforce/apex/fsPcAcController.setlivingStyle';
import setNeighbourFeedBack from '@salesforce/apex/fsPcAcController.setNeighbourFeedBack';
import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from '@salesforce/schema/Character__c.Id';
import LOAN_APPLIANT_ID from '@salesforce/schema/Character__c.Loan_Applicant__c';
import CUSTOMER_TYPE from '@salesforce/schema/Character__c.Customer_Type__c';
import AFFILIATION_NAME from '@salesforce/schema/Character__c.Affiliation_Name__c';
import AFFILIATION_WITH from '@salesforce/schema/Character__c.Affiliation_with__c';
import CURRENT_POSITION from '@salesforce/schema/Character__c.Current_position_Position_held_in_Past__c';
import PARTY_NAME from '@salesforce/schema/Character__c.Name_of_party__c';
import NO_OF_YEAR from '@salesforce/schema/Character__c.No_of_years_in_politics__c';
import PRESENT_POLITICAL_STATUS from '@salesforce/schema/Character__c.Present_Political_Status__c';
import CHARACTER from '@salesforce/schema/Character__c.Character_Of_Affiliated_Person__c';
import AFFILIATION_REMARKS from '@salesforce/schema/Character__c.Affiliation_Remarks__c';

export default class PcCharacter extends LightningElement {

    @api ispcFamily = false;
    @api ispcNeighbour = false;
    @api ispcAffiliation = false;
    @api ispcLivingStandard = false;
    @api sectionName;
    @api verificationId;
    @api fivCfamilyTableData;
    @api showFIVCCharacter = false;
    @api applicationid;
    @api calledFrom;
    @api loanAmount;

    @track childSpinner = false;
    @track characterRecordTypeId;
    @track isRemarksReq;
    @track familyTableData;
    @track affTableData;
    @track neighbourTableData;
    @track livingStandardTableData;
    @track charRecordId;
    @track showDeleteModal = false;
    @track customerId;
    @track customerName;
    @track labelSave = 'Save';
    @track customerTypeVal;
    @track idtobedeleted;
    @track primaryOptions;
    @track coOptions;
    @track guarantorOptions;
    @track isothers = false;
    @track isFamilyMemberNameDisabled = true;
    @track affiliationWithVal;
    @track islivingDisabled = false;
    @track isNeighbourDisabled = false;
    @track familyMemberMap = new Map();
    @track affiliationMap = new Map();
    @track fields;
    @track otherFamilyMemberList;




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
        }
    ];


    get iscustomerRequired() {
        if (this.customerTypeVal == 'Primary Applicant' && this.primaryOptions.length > 0) {
            return true;
        }
        else if (this.customerTypeVal == 'Co-Applicant' && this.coOptions.length > 0) {
            return true;
        }
        else if (this.customerTypeVal == 'Guarantor' && this.guarantorOptions.length > 0) {
            return true;
        }
        else if (this.customerTypeVal == 'Others' && this.otherFamilyMemberList.length > 0 && this.ispcAffiliation) {
            return true;
        }
        else {
            return false;
        }

    }

    get selectedTab() {
        if (this.ispcFamily)
            return 'Family Detail';
        else if (this.ispcNeighbour)
            return 'Neighbour Detail';
        else if (this.ispcAffiliation)
            return 'Affiliation Detail';
        else if (this.ispcLivingStandard)
            return 'Living Standard Detail';
    }


    @track familyautoData = {
        Family_memeber_Name: undefined, Customer_Type: undefined, Relationship: undefined, Living_with_Applicant: undefined
        , Overall_Remarks: undefined, Remarks__c: undefined
    };

    @track neighbourautoData = {
        Feedback: undefined, Remarks: undefined
    };

    @track affautoData = {
        Customer_Type: undefined, Name: undefined, Is_Involved: undefined, Affiliation_with: undefined, Current_Position: undefined, Party_Name: undefined, No_Of_Years_In_Politics: undefined, Political_status: undefined,
        Charactor_Of: undefined, Affiliation_Remarks: undefined
    };

    @track livingAutoData = {
        Applicant_Name: undefined, LifeStyle: undefined, FourthLifestyle: undefined, ThirdLifestyle: undefined, SecondLifestyle: undefined,
        Consumer_Durables: undefined, Remarks: undefined
    };

    get showCharacter() {
        return (this.ispcFamily || this.ispcNeighbour || this.ispcAffiliation || this.ispcLivingStandard) ? true : false;
    }


    get isAffiliationFieldRequired() {
        return this.affautoData.Is_Involved == 'Yes' ? true : false;
    }

    get isPolitics() {
        return this.affautoData.Affiliation_with && this.affautoData.Affiliation_with.includes('Politics') ? true : false;
    }

    get isPoliceOrLawyer() {
        return this.affautoData.Affiliation_with && (this.affautoData.Affiliation_with.includes('Police') || this.affautoData.Affiliation_with.includes('Advocate') || this.affautoData.Affiliation_with.includes('Others')) ? true : false;
    }

    get pcFamilyTable() {
        return (this.ispcFamily) ? true : false;
    }

    get pcNeighbourTable() {
        return (this.ispcNeighbour) ? true : false;
    }

    get pcAffiliationTable() {
        return (this.ispcAffiliation) ? true : false;
    }

    get pcLivingStandardTable() {
        return (this.ispcLivingStandard) ? true : false;
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

    get customerTypeOptions() {
        return [{ label: 'Primary Applicant', value: 'Primary Applicant' },
        { label: 'Co-Applicant', value: 'Co-Applicant' },
        { label: 'Guarantor', value: 'Guarantor' },
        { label: 'Others', value: 'Others' }
        ];
    }


    get customerOptions() {
        if (this.customerTypeVal == 'Primary Applicant') {
            this.isFamilyMemberNameDisabled = (this.primaryOptions.length > 0 ? false : true);
            return (this.primaryOptions.length > 0 ? this.primaryOptions : this.showToast('', 'error', 'No Primary Applicant Found!!'));
        }
        else if (this.customerTypeVal == 'Co-Applicant') {
            this.isFamilyMemberNameDisabled = (this.coOptions.length > 0 ? false : true);
            return (this.coOptions.length > 0 ? this.coOptions : this.showToast('', 'error', 'No Co-Applicant Found!!'));
        }
        else if (this.customerTypeVal == 'Guarantor') {
            this.isFamilyMemberNameDisabled = (this.guarantorOptions.length > 0 ? false : true);
            return (this.guarantorOptions.length > 0 ? this.guarantorOptions : this.showToast('', 'error', 'No Guarantor Found!!'));
        }
        else if (this.customerTypeVal == 'Others' && this.ispcAffiliation) {
            this.isFamilyMemberNameDisabled = (this.otherFamilyMemberList.length > 0 ? false : true);
            return (this.otherFamilyMemberList.length > 0 ? this.otherFamilyMemberList : this.showToast('', 'error', 'No Other Member Found!!'));
        }
    }


    connectedCallback() {
        console.log('applicationid', this.applicationid);
        console.log('fam', this.ispcFamily);
        console.log('neg', this.ispcNeighbour);
        console.log('Verification Id', this.verificationId);
        console.log('called FROM >>>> ', this.calledFrom);
        console.log('Loan amount in char', this.loanamount)
        this.childSpinner = true;
        this.getcharcterRecordTypeId();
        this.getExistingApplicants();
        this.familyTableData = undefined;
        this.getCharacterTableRecords('PC_Table_Family_Details', 'Family Detail');
        this.neighbourTableData = undefined;
        this.getCharacterTableRecords('PC_Neighbour_Table', 'Neighbour Detail');
        this.affTableData = undefined;
        this.getCharacterTableRecords('PC_Affiliation_Table', 'Affiliation Detail');
        this.livingStandardTableData = undefined;
        this.getCharacterTableRecords('PC_LivingStandard_Table', 'Living Standard Detail');
        console.log('this.family table data ', this.familyTableData, 'this.called from', this.calledFrom, 'show pc familty table', this.pcFamilyTable);
    }


    // refresh form method called from Parent on PC Sub options Change
    @api refreshForm() {
        console.log('refresh form method called');
        this.resetLogic();
        this.labelSave = 'Save';
        this.charRecordId = undefined;
        console.log('## JSON.parse(this.livingStandardTableData.strDataTableData).length ', JSON.parse(this.livingStandardTableData.strDataTableData).length);
        if (JSON.parse(this.livingStandardTableData.strDataTableData).length >= 1) {
            this.islivingDisabled = true;
        }
        else {
            this.islivingDisabled = false;
        }
        if (JSON.parse(this.neighbourTableData.strDataTableData).length >= 1) {
            this.isNeighbourDisabled = true;
        }
        else {
            this.isNeighbourDisabled = false;
        }
    }

    // form submit method for Process Credit / Approval Credit Character Form
    handleCharacterSubmit(event) {
        console.log('customer type val>', this.customerTypeVal);
        let checkValidation = this.checkInputValidity();
        console.log('handleSubmit checkValidation= ', checkValidation);
        if (!checkValidation) {
            event.preventDefault();
            this.showToast('Invalid input', 'error', 'You haven\'t entered correct data');
        }
        else if (this.ispcAffiliation) {
            let isInvolved = this.template.querySelector('[data-id="Is_Involved__c"]');
            if (this.affTableData && this.affTableData.strDataTableData && JSON.parse(this.affTableData.strDataTableData).length && JSON.parse(this.affTableData.strDataTableData)[0].Is_Involved__c == 'No') {
                this.showToast('', 'error', 'Already one record with No Affiliation, if you want to add please delete the old one.');
                event.preventDefault();
                return;
            } else if (isInvolved.value == 'No' && this.affTableData && this.affTableData.strDataTableData && JSON.parse(this.affTableData.strDataTableData).length && JSON.parse(this.affTableData.strDataTableData)[0].Is_Involved__c == 'Yes') {
                this.showToast('', 'error', 'Already Affilaited records are there, if you want to add please delete the old one.');
                event.preventDefault();
                return;
            }
        }
        else if (this.ispcFamily || (this.ispcAffiliation && this.isAffiliationFieldRequired)) {

           /* if (this.customerTypeVal == undefined || this.customerTypeVal == '' || this.customerTypeVal == null || this.customerTypeVal == '--None--') {
                event.preventDefault();
                this.showToast('', 'error', 'Please Select Customer Type');
            }
            else*/ if (this.customerTypeVal == 'Co-Applicant' && !this.coOptions.length) {
                event.preventDefault();
                this.showToast('', 'error', 'No Co-Applicant Found!!');
            }
            else if (this.customerTypeVal == 'Guarantor' && !this.guarantorOptions.length) {
                event.preventDefault();
                this.showToast('', 'error', 'No Guarantor Found!!');
            }
            /*else if (!this.isothers) {
                console.log('inside it');
                console.log('customer ID->', this.customerId);
                if (!this.customerId && ((this.coOptions.length > 0 && this.customerTypeVal == 'Co-Applicant') || (this.guarantorOptions.length > 0 && this.customerTypeVal == 'Guarantor'))) {
                    event.preventDefault();
                    this.showToast('', 'error', 'You haven\'t selected any Family Member !!');
                }
            }*/
            else {
                this.showTemporaryLoader();
            }
        }
        else {
            this.showTemporaryLoader();
        }

        console.log('handle PC character called');
    }


    // This Method Is Used To Handle Check Validations For Form
    checkInputValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid1 && allValid2)
            return true;
        else
            return false;
    }

    // pc family detail handle success method
    handleFamilySuccess(event) {
        console.log('handleCharacterSubmit called');
        console.log('hello ID ####', event.detail.id);
        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Character', subtabname: this.selectedTab }
        });
        this.dispatchEvent(removeEvent);
        if (this.labelSave == 'Save')
            this.showToast('Success', 'success', 'Record Created Successfully');
        else if (this.labelSave == 'Update')
            this.showToast('Success', 'success', 'Record Updated Successfully');
        if (this.customerTypeVal == 'Others' && (this.ispcFamily || this.ispcAffiliation))
            this.handleCustomerIdUpdation(event.detail.id);
        this.resetLogic();
        this.childSpinner = true;
        if (this.ispcFamily) {
            this.ispcFamily = false;
            this.getCharacterTableRecords('PC_Table_Family_Details', 'Family Detail');
            setTimeout(() => {
                this.ispcFamily = true;
            }, 200);
        }

        if (this.ispcNeighbour) {
            this.ispcNeighbour = false;
            this.getCharacterTableRecords('PC_Neighbour_Table', 'Neighbour Detail');
            setTimeout(() => {
                this.HandleNeighbourFeedBackUpdation();
                this.ispcNeighbour = true;
            }, 200);
        }

        if (this.ispcAffiliation) {
            this.ispcAffiliation = false;
            this.handleAffiliationUpdation(this.fields);
            this.getCharacterTableRecords('PC_Affiliation_Table', 'Affiliation Detail');
            setTimeout(() => {
                this.ispcAffiliation = true;
            }, 200);
        }

        if (this.ispcLivingStandard) {
            this.ispcLivingStandard = false;
            this.getCharacterTableRecords('PC_LivingStandard_Table', 'Living Standard Detail');
            setTimeout(() => {
                this.HandleLivingStandardUpdation();
                this.ispcLivingStandard = true;
            }, 200);
        }
        this.charRecordId = undefined;
        this.labelSave = 'Save';
    }










    // FIV-C Data Table radio Button Selection Method
    handleSelectedRow(event) {
        this.childSpinner = true;
        let row = event.detail[0];
        //if (this.calledFrom == 'PC') {
        console.log('selected row>>>>> ', JSON.stringify(event.detail));
        console.log('is pc family>>>>', row.Family_Member_Name__c);
        console.log('fivc recordId>>>>', row.Id);
        if (row.Loan_Applicant__c == ' ') {
            this.customerId = null;
        }
        else {
            console.log('inside else');
            this.customerId = row.Loan_Applicant__c;
        }
        if (this.ispcFamily) {

            if (this.familyMemberMap.has(this.customerId)) {
                this.charRecordId = this.familyMemberMap.get(this.customerId);
                this.labelSave = 'Update';
            }
            else if (!this.familyMemberMap.has(this.customerId)) {
                this.charRecordId = undefined;
                this.labelSave = 'Save';
                this.familyautoData.Relationship = (row.Relationship__c != ' ' ? row.Relationship__c : '');
                this.familyautoData.Living_with_Applicant = (row.Living_with_Applicant__c != ' ' ? row.Living_with_Applicant__c : '--None--');
                this.familyautoData.Remarks__c = (row.Overall_Remarks__c != ' ' ? row.Overall_Remarks__c : null);
            }
            this.customerName = (row.Family_Member_Name__c != ' ' ? row.Family_Member_Name__c : null);
            this.customerTypeVal = (row.Customer_Type__c != ' ' ? row.Customer_Type__c : '--None--');
            this.isothers = (this.customerTypeVal == 'Others' ? true : false);
        }
        else if (this.ispcNeighbour) {
            this.neighbourautoData.Feedback = (row.FeedBack__c != '--None--' ? row.FeedBack__c : null);
            this.neighbourautoData.Remarks = (row.Remarks__c != ' ' ? row.Remarks__c : null);
        }
        else if (this.ispcAffiliation) {
            if (this.affiliationMap.has(this.customerId)) {
                this.charRecordId = this.affiliationMap.get(this.customerId).Id;
                this.affautoData.Affiliation_with = this.affiliationMap.get(this.customerId).Affiliation_with__c;
                this.affautoData.Is_Involved = this.affiliationMap.get(this.customerId).Is_Involved__c;
                this.labelSave = 'Update';
            }
            else {
                this.charRecordId = undefined;
                this.labelSave = 'Save';
                this.affautoData.Is_Involved = (row.Is_Involved__c != '--None--' ? row.Is_Involved__c : null);
                this.affautoData.Affiliation_with = (row.Affiliation_with__c != '--None--' ? row.Affiliation_with__c : null);
                this.affautoData.Current_Position = (row.Current_position_Position_held_in_Past__c != ' ' ? row.Current_position_Position_held_in_Past__c : null);
                this.affautoData.Party_Name = (row.Name_of_party__c != ' ' ? row.Name_of_party__c : null);
                this.affautoData.No_Of_Years_In_Politics = (row.No_of_years_in_politics__c != ' ' ? row.No_of_years_in_politics__c : null);
                this.affautoData.Political_status = (row.Present_Political_Status__c != ' ' ? row.Present_Political_Status__c : null);
                this.affautoData.Charactor_Of = (row.Character_Of_Affiliated_Person__c != ' ' ? row.Character_Of_Affiliated_Person__c : null);
                this.affautoData.Affiliation_Remarks = (row.Affiliation_Remarks__c != ' ' ? row.Affiliation_Remarks__c : null);
            }
            this.customerTypeVal = (row.Customer_Type__c != ' ' ? row.Customer_Type__c : '--None--');
            this.isothers = (this.customerTypeVal == 'Others' ? true : false);
            this.customerName = (row.Affiliation_Name__c != ' ' ? row.Affiliation_Name__c : null);
            this.handleAffiliationChange();
        }
        else if (this.ispcLivingStandard) {
            this.livingAutoData.LifeStyle = (row.Lifestyle__c != ' ' ? row.Lifestyle__c : null);
            //this.livingAutoData.SecondLifestyle = (row.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c != ' ' ? row.Lifestyle_Loan_Amount_2L_to_4_Lakhs__c : null);
            //this.livingAutoData.ThirdLifestyle = (row.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c != ' ' ? row.Lifestyle_Loan_Amount_4L_to_8_Lakhs__c : null);
            //this.livingAutoData.FourthLifestyle = (row.Lifestyle_Loan_Amount_8Lakhs__c != ' ' ? row.Lifestyle_Loan_Amount_8Lakhs__c : null);
            this.livingAutoData.Remarks = (row.Living_Standard_Remarks__c != ' ' ? row.Living_Standard_Remarks__c : null);
            this.livingAutoData.Consumer_Durables = (row.Consumer_Durables__c != ' ' ? row.Consumer_Durables__c : null);
        }
        this.childSpinner = false;
    }

    // data table row selection Action Method
    handleSelectedFamilyMember(event) {
        var data = event.detail;
        console.log('data ##', data);

        if (data && data.ActionName == 'delete') {
            console.log('char id', this.charRecordId);
            this.idtobedeleted = data.recordData.Id;;
            this.showDeleteModal = true;
        }
        if (data && data.ActionName == 'edit') {
            this.charRecordId = data.recordData.Id;
            this.labelSave = 'Update';
            this.customerTypeVal = data.recordData.Customer_Type__c;
            this.customerId = data.recordData.Loan_Applicant__c;
            if (this.customerTypeVal == 'Others') {
                this.customerName = undefined;
                this.customerId = undefined;
                this.isothers = true;
            }
            else
                this.isothers = false;
            console.log('Customer Type Options ### ', this.customerTypeOptions);
            console.log('Customer Options ### ', this.customerOptions);

            if (this.ispcFamily) {
                this.customerName = data.recordData.Family_Member_Name__c;
            }
            if (this.ispcLivingStandard)
                this.islivingDisabled = false;
            if (this.ispcNeighbour)
                this.isNeighbourDisabled = false;
            if (this.ispcAffiliation) {
                this.customerName = data.recordData.Affiliation_Name__c;
                this.affautoData.Affiliation_with = data.recordData.Affiliation_with__c;
                this.affautoData.Is_Involved = data.recordData.Is_Involved__c;
                this.handleAffiliationChange();
            }
        }
    }



    // This Method Is Used To Handle Form Values
    handleFormValues(event) {
        let fName = event.target.fieldName ? event.target.fieldName : event.target.name;
        let fValue = event.target.value;
        let rcId = this.charRecordId ? this.charRecordId : '1';
        console.log('fname->', fName, 'value->', fValue);
        if (this.ispcNeighbour) {
            if (event.target.fieldName == "FeedBack__c") {
                this.neighbourautoData.neighbourFeedback = event.target.value;
                if (this.neighbourautoData.neighbourFeedback == 'Negative' || this.neighbourautoData.neighbourFeedback == 'Neutral')
                    this.isRemarksReq = true;
                else
                    this.isRemarksReq = false;
            }
        }
        else if (this.ispcFamily || this.ispcAffiliation) {
            if (event.target.name == "Customer_Type__c") {
                this.customerName = undefined;
                this.customerTypeVal = event.target.value;
                if (this.customerTypeVal == 'Others') {
                    this.customerName = undefined;
                    this.customerId = undefined;
                    this.isothers = true;
                }
                else if (this.customerTypeVal == 'Primary Applicant') {
                    this.customerId = (this.primaryOptions.length > 0 ? (this.primaryOptions[0].value != undefined ? this.primaryOptions[0].value : undefined) : undefined);
                    this.familyautoData.Relationship = 'Self';
                    this.customerName = (this.primaryOptions.length > 0 ? (this.primaryOptions[0].label != undefined ? this.primaryOptions[0].label : undefined) : undefined);
                    this.checkExistence();
                }
                else {
                    this.isothers = false;
                    this.customerId = undefined;
                    this.familyautoData.Relationship = '';
                }
            }
        }
        if (this.ispcAffiliation) {
            if (event.target.fieldName == 'Is_Involved__c') {
                this.affautoData.Is_Involved = event.target.value;
            } else if (event.target.fieldName == 'Affiliation_with__c') {
                console.log('this.affautoData.Affiliation_with= ', this.affautoData.Affiliation_with);
                this.affautoData.Affiliation_with = event.target.value;
            }
            this.handleAffiliationChange();
            console.log('this affdata', this.affautoData);
        }

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);

        const selectedEvent2 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: 'Verification__c', fieldvalue: this.verificationId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent2);

        const selectedEvent3 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: 'Application__c', fieldvalue: this.applicationid, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent3);

        const selectedEvent4 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: 'Section_Type__c', fieldvalue: this.selectedTab, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent4);

        const selectedEvent5 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: 'RecordTypeId', fieldvalue: this.characterRecordTypeId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent5);

    }

    // method to handle Deletion Event
    handlemodalactions(event) {
        this.showDeleteModal = false;
        console.log('event.detail>>>>> ', event.detail);
        if (event.detail === true) {
            this.childSpinner = true;
            const removeEvent = new CustomEvent("handletabvalueremove", {
                detail: { tabname: 'Character', subtabname: this.selectedTab }
            });
            this.dispatchEvent(removeEvent);
            var charEvent = new CustomEvent('characterchangeevent', { detail: true })
            this.dispatchEvent(charEvent);
            if (this.ispcFamily)
                this.getCharacterTableRecords('PC_Table_Family_Details', 'Family Detail');
            if (this.ispcNeighbour) {
                this.getCharacterTableRecords('PC_Neighbour_Table', 'Neighbour Detail');
                this.HandleNeighbourFeedBackUpdation();
            }
            if (this.ispcAffiliation)
                this.getCharacterTableRecords('PC_Affiliation_Table', 'Affiliation Detail');
            if (this.ispcLivingStandard) {
                this.getCharacterTableRecords('PC_LivingStandard_Table', 'Living Standard Detail');
                this.HandleLivingStandardUpdation();
            }

        }
    }

    // method to handle customer Selection
    handleCustomerChange(event) {
        console.log('customer change callled', event.target.value);
        if (!this.isothers) {
            this.customerId = event.target.value;
            this.checkExistence();
        }

        this.customerName = event.target.options.find(opt => opt.value === event.detail.value).label;
        let rcId = this.charRecordId ? this.charRecordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: 'Loan_Applicant__c', fieldvalue: this.customerId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);
        if (this.selectedTab == 'Family Detail') {
            const selectedEvent2 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: 'Family_Member_Name__c', fieldvalue: this.customerName, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent2);
        }
        else if (this.selectedTab == 'Affiliation Detail') {
            const selectedEvent3 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Character', subtabname: this.selectedTab, fieldapiname: 'Affiliation_Name__c', fieldvalue: this.customerName, recordId: rcId }
            });
            this.dispatchEvent(selectedEvent3);
        }
        console.log('cstomer', this.customerName);
    }

    // method used to check if record already exists if exists it will autopop it...
    checkExistence() {
        if (this.familyMemberMap.has(this.customerId) && this.ispcFamily) {
            this.charRecordId = this.familyMemberMap.get(this.customerId);
            this.labelSave = 'Update';
            console.log('char record id', this.charRecordId);
        }
        if (this.affiliationMap.has(this.customerId) && this.ispcAffiliation) {
            this.charRecordId = this.affiliationMap.get(this.customerId).Id;
            this.affautoData.Affiliation_with = this.affiliationMap.get(this.customerId).Affiliation_with__c;
            this.affautoData.Is_Involved = this.affiliationMap.get(this.customerId).Is_Involved__c;
            this.labelSave = 'Update';
            console.log('char record id', this.charRecordId);
        }
    }

    // method used to frame the Affiliation Record
    handleAffiliationChange() {
        this.fields = {};
        this.fields[ID_FIELD.fieldApiName] = this.charRecordId;
        if (this.affautoData.Is_Involved == 'No') {
            this.fields[LOAN_APPLIANT_ID.fieldApiName] = null;
            this.fields[CUSTOMER_TYPE.fieldApiName] = null;
            this.fields[AFFILIATION_NAME.fieldApiName] = null;
            this.fields[AFFILIATION_WITH.fieldApiName] = null;
            this.fields[CURRENT_POSITION.fieldApiName] = null;
            this.fields[PARTY_NAME.fieldApiName] = null;
            this.fields[NO_OF_YEAR.fieldApiName] = null;
            this.fields[PRESENT_POLITICAL_STATUS.fieldApiName] = null;
            this.fields[CHARACTER.fieldApiName] = null;
            this.fields[AFFILIATION_REMARKS.fieldApiName] = null;
        }
        if (this.affautoData.Affiliation_with) {
            if (!this.affautoData.Affiliation_with.includes('Politics') && (this.affautoData.Affiliation_with.includes('Police') || this.affautoData.Affiliation_with.includes('Advocate') || this.affautoData.Affiliation_with.includes('Others'))) {
                this.fields[CURRENT_POSITION.fieldApiName] = null;
                this.fields[PARTY_NAME.fieldApiName] = null;
                this.fields[NO_OF_YEAR.fieldApiName] = null;
                this.fields[PRESENT_POLITICAL_STATUS.fieldApiName] = null;
                this.fields[CHARACTER.fieldApiName] = null;
            }
        }
    }



    // This Method Is Used To Show Loader For Short Time
    showTemporaryLoader() {
        this.showLoader = true;
        let ref = this;
        setTimeout(function () {
            ref.showLoader = false;
        }, 500);
    }


    // method to Handle Reset
    handleReset(event) {
        // if (this.calledFrom == 'AC')
        //     this.showacCharacter = false;
        if (this.labelSave == 'Update') {
            this.charRecordId = undefined;
        }
        this.labelSave = 'Save';
        this.resetLogic();
    }

    // to reset the form fields;
    resetLogic() {
        const inputFields = this.template.querySelectorAll('.character');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.customerName = null;
        this.customerId = null;
        this.customerTypeVal = null;
        if (this.ispcFamily) {
            this.familyautoData = {
                Family_memeber_Name: undefined, Customer_Type: undefined, Relationship: undefined, Living_with_Applicant: undefined
                , Overall_Remarks: undefined, Remarks__c: undefined
            };
            this.isothers = false;
        }
        if (this.ispcNeighbour) {
            this.neighbourautoData = {
                Feedback: undefined, Remarks: undefined
            };
        }
        if (this.ispcAffiliation) {
            this.affautoData = {
                Customer_Type: undefined, Name: undefined, Is_Involved: undefined, Affiliation_with: undefined, Current_Position: undefined, Party_Name: undefined, No_Of_Years_In_Politics: undefined, Political_status: undefined,
                Charactor_Of: undefined, Affiliation_Remarks: undefined
            }
        }
        if (this.ispcLivingStandard) {
            this.livingAutoData = {
                Applicant_Name: undefined, LifeStyle: undefined, FourthLifestyle: undefined, ThirdLifestyle: undefined, SecondLifestyle: undefined,
                Consumer_Durables: undefined, Remarks: undefined
            };
            console.log('living in reset Logic ', this.livingAutoData);
        }


    }



    // for getting the character table records------
    @api getCharacterTableRecords(metadataName, secName) {
        if (secName == 'Family Detail')
            this.familyTableData = undefined;
        else if (secName == 'Neighbour Detail')
            this.neighbourTableData = undefined;
        else if (secName == 'Affiliation Detail')
            this.affTableData = undefined;
        else if (secName == 'Living Standard Detail')
            this.livingStandardTableData = undefined;
        getCharacterTabRecords({ appId: this.applicationid, metadataName: metadataName, sectionName: secName, recType: this.calledFrom }).then((result) => {
            console.log(this.calledFrom, ':::::', secName, 'getFamilyDetailTableRecords in child= ', JSON.parse(JSON.stringify(result)));
            if (secName == 'Family Detail') {
                this.otherFamilyMemberList = [];
                let tempList = [];
                this.familyTableData = JSON.parse(JSON.stringify(result));
                let data = JSON.parse(this.familyTableData.strDataTableData);
                let famMap = new Map();
                for (var i in data) {
                    if (data[i].Loan_Applicant__c != ' ' && data[i].Loan_Applicant__c != '' && data[i].Loan_Applicant__c != null)
                        famMap.set(data[i].Loan_Applicant__c, data[i].Id);
                    if (data[i].Customer_Type__c == 'Others')
                        tempList.push({ label: data[i].Family_Member_Name__c, value: data[i].Family_Member_Name__c });
                }
                this.familyMemberMap = famMap;
                this.otherFamilyMemberList = tempList;
                console.log('Temp List ##',tempList);
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            console.log('insideee111 keyValue ', keyValue)
                            const selectedEvent = new CustomEvent("handletabvaluechange", {
                                detail: { tabname: 'Character', subtabname: 'Family Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
                });
                console.log('Family Member Map ###', this.familyMemberMap);
            }
            else if (secName == 'Neighbour Detail') {
                this.neighbourTableData = JSON.parse(JSON.stringify(result));
                if (JSON.parse(this.neighbourTableData.strDataTableData).length >= 1) {
                    this.isNeighbourDisabled = true;
                }
                else {
                    this.isNeighbourDisabled = false;
                }
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            console.log('insideee111 keyValue ', keyValue)
                            const selectedEvent = new CustomEvent("handletabvaluechange", {
                                detail: { tabname: 'Character', subtabname: 'Neighbour Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
                });
            }
            else if (secName == 'Affiliation Detail') {
                this.affTableData = JSON.parse(JSON.stringify(result));
                let affdata = JSON.parse(this.affTableData.strDataTableData);
                let affMap = new Map();
                for (var i in affdata) {
                    if (affdata[i].Loan_Applicant__c != ' ' && affdata[i].Loan_Applicant__c != '' && affdata[i].Loan_Applicant__c != null)
                        affMap.set(affdata[i].Loan_Applicant__c, affdata[i]);
                }
                this.affiliationMap = affMap;
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            console.log('insideee111 keyValue ', keyValue)
                            const selectedEvent = new CustomEvent("handletabvaluechange", {
                                detail: { tabname: 'Character', subtabname: 'Affiliation Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
                });
                console.log('affiliation Map ###', this.affiliationMap);
            }
            else if (secName == 'Living Standard Detail') {
                this.livingStandardTableData = JSON.parse(JSON.stringify(result));
                if (JSON.parse(this.livingStandardTableData.strDataTableData).length >= 1) {
                    this.islivingDisabled = true;
                }
                else {
                    this.islivingDisabled = false;
                }
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            console.log('insideee111 keyValue ', keyValue)
                            const selectedEvent = new CustomEvent("handletabvaluechange", {
                                detail: { tabname: 'Character', subtabname: 'Living Standard Detail', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
                });
            }
            var charEvent = new CustomEvent('characterchangeevent', { detail: true })
            this.dispatchEvent(charEvent);
            this.childSpinner = false;
        }).catch((err) => {
            if (secName == 'Family Detail')
                this.familyTableData = undefined;
            else if (secName == 'Neighbour Detail')
                this.neighbourTableData = undefined;
            else if (secName == 'Affiliation Detail')
                this.affTableData = undefined;
            else if (secName == 'Living Standard Detail')
                this.livingStandardTableData = undefined;
            console.log('getFamilyDetailTableRecords in child Error= ', err);
            this.childSpinner = false;
        });
    }



    // get the character recordTypeId
    getcharcterRecordTypeId() {
        let rectypeName;
        if (this.calledFrom == 'AC')
            rectypeName = 'AC Character';
        if (this.calledFrom == 'PC')
            rectypeName = 'PC Character';
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


    // Method used to get Existing Applicants 
    getExistingApplicants() {
        getApplicantList({ appId: this.applicationid })
            .then(result => {
                let primaryoptions = [];
                let coAppOptions = [];
                let guarantorOptions = [];
                console.log('get applicants in compare docs####', result)
                if (result) {
                    for (var key in result) {
                        if (result[key].Customer_Type__c == 'Primary Applicant')
                            primaryoptions.push({ label: result[key].Customer_Information__r.Name, value: result[key].Id });
                        if (result[key].Customer_Type__c == 'Co-Applicant')
                            coAppOptions.push({ label: result[key].Customer_Information__r.Name, value: result[key].Id });
                        if (result[key].Customer_Type__c == 'Guarantor')
                            guarantorOptions.push({ label: result[key].Customer_Information__r.Name, value: result[key].Id });
                    }
                    this.primaryOptions = primaryoptions;
                    this.coOptions = coAppOptions;
                    this.guarantorOptions = guarantorOptions;
                    console.log('Primary Options %%%', this.primaryOptions, 'Co Applicant Options %%%', this.coOptions, ' Guarantor Options %%%', this.guarantorOptions);
                }
            })
            .catch(error => {
                console.log('ERR in compare docs Applicant options', error);
            })
    }


    // method used to update customer Id When others is selected in customer type picklist
    handleCustomerIdUpdation(recordId) {
        if (recordId) {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = recordId;
            fields[LOAN_APPLIANT_ID.fieldApiName] = null;
            const recordInput = { fields };
            console.log('recordInput= ', recordInput);
            updateRecord(recordInput).then(() => {
                console.log('UPDATE DONE');
            }).catch(error => {
                console.log('Error in Loan Applicant Update = ', error);
            });
        }
    }

    // method used to update Affiliation Record on Record Updation...
    handleAffiliationUpdation(fields) {
        if (fields) {
            const recordInput = { fields };
            console.log('recordInput= ', recordInput);
            if (recordInput.fields.Id) {
                updateRecord(recordInput).then(() => {
                    console.log('UPDATE DONE');
                }).catch(error => {
                    console.log('Error in Affiliation Updation = ', error);
                });
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


    // Living Standard Updation method
    HandleLivingStandardUpdation() {
        setlivingStyle({ appId: this.applicationid, verificationId: this.verificationId })
            .then(result => {
                console.log('Living Standard Updated Successfully', result);
            })
            .catch(err => {
                console.log('Error Occured in Living Standard Updation', err);
            });
    }

    // Neighbour Feedback Upation Method 
    HandleNeighbourFeedBackUpdation() {
        setNeighbourFeedBack({ appId: this.applicationid, verificationId: this.verificationId })
            .then(result => {
                console.log('Neighbour Feedback Updated Successfully', result);
            })
            .catch(err => {
                console.log('Error Occured in Neighbour Feedback Updation', err);
            });
    }


}