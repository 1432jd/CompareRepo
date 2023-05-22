import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCapabiltyData from '@salesforce/apex/fsPcAcController.getCapabiltyData';
export default class PcCapability extends LightningElement {

    @api isSalaried = false;
    @api isRentalMortgage = false;
    @api isRentalOther = false;
    @api isDailyWages = false;
    @api isPension = false;
    @api isAbroadIncome = false;
    @api isOther = false;
    @api isSelfEmployedOrBusiness = false;
    @api isEateriesAndOthers = false;
    @api isDayBasis = false;
    @api isMarginBasis = false;
    @api isDisabled = false;
    @api isTransportBusiness = false;
    @api sectiontitle;
    @api capabilityRecordId;
    @api verificationId;
    @api capabilityRecordTypeId;
    @api applicationId;
    @api relationshipId;
    @api otherConfirmation;
    @api natureofdocumentProof;
    @api ownershipproofEateries;
    @api proofRemarks;
    @api otherConfirmationsDailyWages;
    @api natureOfOwnershipProof;
    @api ownershipProof;
    @api fcEnquiry;
    @api customerList;
    @api fivCDayBasis;
    @api fivCSegment;
    @api fivCSubSegment;
    @api isfivCDayBasis;
    @api isfivCMarginBasis;
    @api incomeProof;
    @api appId;
    @api loanApplicantId;

    @track segMentValue;
    @track pcSegment;
    @track pcSubSegment;
    @track subSegMentValue;
    @track dayOrMaginValue;
    @track salesPerMonth;
    @track marginInAmount;
    @api grossMonthlyIncome;
    @track capabilitychildSpinner = false;
    @track capabilitypcTableData;
    @track showDeleteModal = false;
    @track capRecordId;
    @track capaccheck;
    @track showAcCapabilityForm = false;
    @track labelSave = 'Save';
    @track isAc = false;
    @track isFIVC = true;
    @track percentageOfIncome; // done
    @track yearOfBusiness; // done
    @track totalExpInBusiness; // done
    @track yearOfServiceWidEmp; // done
    @track totalWorkExp; // done
    @track monthlySalary; // done
    @track yearOfOccupation; // done
    @track incomePerDayVal; // done
    @track numberOfDays; // done
    @track incomePerMonth; // done
    @track considerforDBrValue; // done
    @track incomepermonthXConsiderforDBR; // done
    @track numberOfUnits; // done
    @track rentalIncome; // done
    @track employerName; // done
    @track natureofJob;
    @track overallRemarks;
    @track tableTitle;
    @track rentalpropertyaddress;
    @track remarksValue;
    @track incomeRemarksValue;
    @track assumptionRemark;
    @track proofRemarks;
    @track overallRemarksRegardingBusiness;
    @track salesPerDay;
    @track electricity;
    @track salary;
    @track rent;
    @track others;
    @track businessName;
    @track businessNature;
    @track businessPincode;
    @track incomePincode;
    get showDayorMarginBasis() {
        return (this.isEateriesAndOthers || this.isSelfEmployedOrBusiness);
    }

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


    connectedCallback() {
        console.log('segmentValue>>>>>in child ### ', this.segmentValue);
        console.log('dayOrMaginValue>>>>>in child ### ', this.dayOrMaginValue);
        console.log('subSegMentValue>>>>>in child ### ', this.subSegMentValue);
        console.log('loan applicant id>>>>> ', this.loanApplicantId);
        console.log('loan applicant id>>>>> ', this.verificationId);
        console.log('track loan applicant id>>>>> ', this.laId);
        console.log('Capability Record Type Id', this.capabilityRecordTypeId);
        console.log('Capability relationship Id', this.relationshipId);
        console.log('Capability Id for AC', this.capabilityRecordId);
        this.tableTitle = this.sectiontitle + ' - List of Capabilities';
        this.capabilitychildSpinner = true;
        if (this.sectiontitle == 'PC') {
            this.showAcCapabilityForm = true;
            this.isFIVC = false;
        }
        else if (this.sectiontitle == 'AC') {
            this.isAc = true;
            this.showAcCapabilityForm = true;
            this.isFIVC = false;
        }
        else if (this.sectiontitle == 'FIV-C') {
            this.showAcCapabilityForm = true;
        }
        this.getCapabilityTableRecords();
    }

    handleCapabiltySubmit(event) {
        console.log('capability submit called');

        if (this.sectiontitle == 'AC') {
            this.capaccheck = true;
        }
        let validInputs = this.checkRecordValidity();
        if (!this.loanApplicantId) {
            event.preventDefault();
            this.showToast('Missing values', 'error', 'You haven\'t selected any customer');
        }
        else
            if (!validInputs) {
                event.preventDefault();
                this.showToast('Invalid Values', 'error', 'Please enter correct values');
            }
            else {
                console.log('ALL OK');
                this.showTemporaryLoader();
            }

    }
    renderedCallback() {
        console.log('verfid in rendered', this.verificationId);

    }



    checkRecordValidity() {
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid1 && allValid2)
            return true;
        else
            return false;
    }


    handleCapabiltySuccess(event) {
        this.showAcCapabilityForm = false;
        console.log('handleCapabilitySubmit called');
        console.log(event.detail.id);
        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Capability', subtabname: '' }
        });
        this.dispatchEvent(removeEvent);
        if (this.labelSave == 'Save') {
            this.showToast('Success', 'success', 'Record Created Successfully');
        }
        if (this.labelSave == 'Update') {
            this.showToast('Success', 'success', 'Record Updated Successfully');
        }
        const changeEvent = new CustomEvent('checkcapabilityvalidation', {
            detail: true
        });
        this.dispatchEvent(changeEvent);
        const inputFields = this.template.querySelectorAll(
            '.capable'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = "";
            });
        }
        this.handleReset();
        setTimeout(() => {
            this.capabilityRecordId = undefined;
            this.showAcCapabilityForm = true;
        }, 200);
        this.labelSave = 'Save';
        this.capabilitychildSpinner = true;
        this.getCapabilityTableRecords();
    }

    // This Method Is Used To Handle Customer Selection
    handleCustomerSelection(evt) {
        console.log('handleCustomer Selection =', evt.target.value);
        this.resetFormValues();
        this.loanApplicantId = evt.target.value;
         let rcId = this.capabilityRecordId ? this.capabilityRecordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability', subtabname: '', fieldapiname: 'Loan_Applicant__c', fieldvalue: this.loanApplicantId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);
    }

    // This Method Is Used To Handle Form Values
    handleFormValue(evt) {
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
        if (evt.target.fieldName == 'Income_segment__c') {
            this.resetFormValues();
            this.pcSegment = evt.target.value;
            this.isSalaried = false;
            this.isDailyWages = false;
            this.isPension = false;
            this.isAbroadIncome = false;
            this.isOther = false;
            this.isSelfEmployedOrBusiness = false;
            this.isEateriesAndOthers = false;
            this.isDayBasis = false;
            this.isMarginBasis = false;
            this.isTransportBusiness = false;
            let dayMarginBasis = this.template.querySelector('[data-id="Day_Margin_Basis__c"]');
            if (dayMarginBasis) {
                dayMarginBasis.value = '';
            }
            if (evt.target.value == 'Salaried') {
                this.isSalaried = true;
            } else if (evt.target.value == 'Pension') {
                this.isPension = true;
            } else if (evt.target.value == 'Daily wages') {
                this.isDailyWages = true;
            } else if (evt.target.value == 'Income from Abroad') {
                this.isAbroadIncome = true;
            } else if (evt.target.value == 'Eateries' || evt.target.value == 'Food business' ||
                evt.target.value == 'Manufacturing' || evt.target.value == 'Shop owner' ||
                evt.target.value == 'Milk business' || evt.target.value == 'General shops' ||
                evt.target.value == 'Vegetables/Fruits/Flower/Vendor'
            ) {
                this.isEateriesAndOthers = true;
            } else if (evt.target.value == 'Self Employed') {
                this.isSelfEmployedOrBusiness = true;
            } else if (evt.target.value == 'Housewife' || evt.target.value == 'Retired' ||
                evt.target.value == 'Unemployed' || evt.target.value == 'Others') {
                this.isOther = true;
            }
            else if (evt.target.value == 'Transport business') {
                this.isTransportBusiness = true;
            }
        } else if (evt.target.fieldName == 'Subsegment__c') {
            this.resetFormValues();
            if (this.isEateriesAndOthers) {
                this.isEateriesAndOthers = false;
                setTimeout(() => {
                    this.isEateriesAndOthers = true;
                    this.isDayBasis = false;
                    this.isMarginBasis = false;
                }, 100);
            }
            this.pcSubSegment = evt.target.value;
            this.isRentalMortgage = false;
            this.isRentalOther = false;
            if (evt.target.value == 'Commercial - mortgage proeprty' || evt.target.value == 'Residential - Mortgage property') {
                this.isRentalMortgage = true;
            } else if (evt.target.value == 'Commercial - Other property' || evt.target.value == 'Residential - Other proeprty') {
                this.isRentalOther = true;
            }
        } else if (evt.target.fieldName == 'Day_Margin_Basis__c') {
            this.resetFormValues();
            if (evt.target.value == 'Day Basis') {
                this.isDayBasis = true;
                this.isMarginBasis = false;
            } else if (evt.target.value == 'Margin Basis') {
                this.isMarginBasis = true;
                this.isDayBasis = false;
            }
        }
        else if (evt.target.name == 'of_income_transacted_through_bank_acco__c') {
            this.percentageOfIncome = evt.target.value;
        } else if (evt.target.name == 'Monthly_Salary__c') {
            this.monthlySalary = evt.target.value;
        } else if (evt.target.name == 'Year_of_Business__c') {
            this.yearOfBusiness = evt.target.value;
        } else if (evt.target.name == 'Total_experience_in_this_business_yrs__c') {
            this.totalExpInBusiness = evt.target.value;
        } else if (evt.target.name == 'Year_of_Service_With_Employer__c') {
            this.yearOfServiceWidEmp = evt.target.value;
        } else if (evt.target.name == 'Total_Work_Experience__c') {
            this.totalWorkExp = evt.target.value;
        } else if (evt.target.name == 'Year_of_Occupation__c') {
            this.yearOfOccupation = evt.target.value;
        } else if (evt.target.name == 'No_of_Units__c') {
            this.numberOfUnits = evt.target.value;
        } else if (evt.target.name == 'Rental_Income__c') {
            this.rentalIncome = evt.target.value;
        } else if (evt.target.name == 'Name_of_the_Employer__c') {
            this.employerName = evt.target.value;
        } else if (evt.target.name == 'Nature_of_Job__c') {
            this.natureofJob = evt.target.value;
        } else if (evt.target.name == 'Business_name__c') {
            this.businessName = evt.target.value;
        } else if (evt.target.name == 'Business_Nature__c') {
            this.businessNature = evt.target.value;
        }
        else if (evt.target.name == 'IncomePincode__c') {
            this.incomePincode = evt.target.value;
        }
        else if (evt.target.name == 'BusinessPincode__c') {
            this.businessPincode = evt.target.value;
        }
        else if (evt.target.name == 'Overall_Remarks__c') {
            this.overallRemarks = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Rental_income_property_address__c') {
            this.rentalpropertyaddress = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Remarks__c') {
            this.remarksValue = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Income_Remarks__c') {
            this.incomeRemarksValue = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Assumptions_for_Income__c') {
            this.assumptionRemark = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Proof_Remarks_Daily_Wages__c') {
            this.proofRemarks = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Nature_of_Document_Proof_Self_Employed__c') {
            this.natureofdocumentProof = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Other_Confirmation_Self_Employed__c') {
            this.otherConfirmation = evt.target.value;
            console.log('gone inside overall change')
        }
        else if (evt.target.name == 'Overall_Remarks_Regarding_Business__c') {
            this.overallRemarksRegardingBusiness = evt.target.value;
            console.log('gone inside overall change')
        }
        let rcId = this.capabilityRecordId ? this.capabilityRecordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);
        const selectedEvent1 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability', subtabname: '', fieldapiname: 'Loan_Applicant__c', fieldvalue: this.loanApplicantId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent1);
        const selectedEvent2 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability', subtabname: '', fieldapiname: 'RecordTypeId', fieldvalue: this.capabilityRecordTypeId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent2);
         const selectedEvent3 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability', subtabname: '', fieldapiname: 'Application__c', fieldvalue: this.appId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent3);

    }


    // This Method Is Used To Handle All Calculations
    handleCalculations(evt) {
        console.log('name ##', evt.target.name);
        console.log('value ##', evt.target.value, 'length', evt.target.value.length);
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
        let incomeSegment = this.template.querySelector('[data-id="Income_segment__c"]').value;
        console.log('incomesegment ->', incomeSegment, 'value length', incomeSegment.length);
        this.grossMonthlyIncome = undefined;
        this.salesPerMonth = undefined;
        this.marginInAmount = undefined;
        if (incomeSegment == 'Daily wages' || incomeSegment == 'Transport business') {
            this.incomePerDayVal = (evt.target.name == 'Income_per_day__c') ? (evt.target.value ? evt.target.value : 0) : this.incomePerDayVal;
            this.numberOfDays = (evt.target.name == 'Number_of_days__c') ? (evt.target.value ? evt.target.value : 0) : this.numberOfDays;
            this.incomePerDayVal = parseFloat(this.incomePerDayVal);
            this.numberOfDays = parseFloat(this.numberOfDays);
            this.grossMonthlyIncome = this.incomePerDayVal * this.numberOfDays;
        } else if (incomeSegment == 'Eateries' || incomeSegment == 'Food business' ||
            incomeSegment == 'Manufacturing' || incomeSegment == 'Shop owner' ||
            incomeSegment == 'Milk business' || incomeSegment == 'General shops' ||
            incomeSegment == 'Vegetables/Fruits/Flower/Vendor' || incomeSegment == 'Self Employed') {
            let dayMarginBasis = this.template.querySelector('[data-id="Day_Margin_Basis__c"]').value;
            if (dayMarginBasis == 'Day Basis') {
                this.incomePerDayVal = (evt.target.name == 'Income_per_day__c') ? (evt.target.value ? evt.target.value : 0) : this.incomePerDayVal;
                this.numberOfDays = (evt.target.name == 'Number_of_days__c') ? (evt.target.value ? evt.target.value : 0) : this.numberOfDays;
                this.incomePerDayVal = parseFloat(this.incomePerDayVal);
                this.numberOfDays = parseFloat(this.numberOfDays);
                this.grossMonthlyIncome = this.incomePerDayVal * this.numberOfDays;
            } else if (dayMarginBasis == 'Margin Basis') {
                console.log('inside margin');
                this.salesPerDay = (evt.target.name == 'Sales_per_day__c') ? (evt.target.value ? evt.target.value : 0) : this.salesPerDay;
                this.numberOfDays = (evt.target.name == 'Number_of_days__c') ? (evt.target.value ? evt.target.value : 0) : this.numberOfDays;
                let margin = this.template.querySelector('[data-id="Margin__c"]').value !== undefined ? this.template.querySelector('[data-id="Margin__c"]').value : 0;
                this.electricity = (evt.target.name == 'Electricity__c') ? (evt.target.value ? evt.target.value : 0) : this.electricity;;
                this.salary = (evt.target.name == 'Salary__c') ? (evt.target.value ? evt.target.value : 0) : this.salary;
                this.rent = (evt.target.name == 'Rent__c') ? (evt.target.value ? evt.target.value : 0) : this.rent;
                this.others = (evt.target.name == 'Others__c') ? (evt.target.value ? evt.target.value : 0) : this.others;
                this.salesPerDay = parseFloat(this.salesPerDay);
                this.numberOfDays = parseFloat(this.numberOfDays);
                this.electricity = parseFloat(this.electricity);
                this.salary = parseFloat(this.salary);
                this.rent = parseFloat(this.rent);
                this.others = parseFloat(this.others);
                this.salesPerMonth = this.salesPerDay * this.numberOfDays;
                console.log('salespermonth ###', this.salesPerMonth)
                this.marginInAmount = this.salesPerMonth / 100 * margin;
                this.grossMonthlyIncome = (this.marginInAmount - (this.electricity + this.salary + this.rent + this.others));
            }
        }
        else if (incomeSegment == 'Pension' || incomeSegment == 'Income from Abroad' || incomeSegment == 'Others') {
            this.considerforDBrValue = (evt.target.name == 'considered_for_DBR__c') ? (evt.target.value ? evt.target.value : 0) : this.considerforDBrValue;
            this.incomePerMonth = (evt.target.name == 'Income_per_month__c') ? (evt.target.value ? evt.target.value : 0) : this.incomePerMonth;
            console.log('income per month', this.incomePerMonth, 'consider for dbr', this.considerforDBrValue);
            this.considerforDBrValue = parseFloat(this.considerforDBrValue);
            this.incomepermonthXConsiderforDBR = this.incomePerMonth * (this.considerforDBrValue / 100);
            console.log('incomepermonthXConsiderforDBR->', this.incomepermonthXConsiderforDBR);
        }
        let rcId = this.capabilityRecordId ? this.capabilityRecordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);
    }

    //method used to clear the Form
    handleReset(event) {
        this.capabilityRecordId = undefined;
        this.loanApplicantId = undefined;
        this.segMentValue = undefined;
        this.subSegMentValue = undefined;
        this.dayOrMaginValue = undefined;
        this.incomePincode = undefined;
        this.businessPincode = undefined;
        this.resetFormValues();
        this.makeAllFalse();
        this.labelSave = 'Save';
        this.resetLogic();
    }

    // helper method used to clear all the calculation Variables and form values
    resetFormValues() {
        this.incomePerDayVal = undefined;
        this.numberOfDays = undefined;
        this.percentageOfIncome = undefined;
        this.salesPerDay = undefined;
        this.electricity = undefined;
        this.salary = undefined;
        this.others = undefined;
        this.rent = undefined;
        this.salesPerMonth = undefined;
        this.marginInAmount = undefined;
        this.grossMonthlyIncome = undefined;
        this.incomePerMonth = undefined;
        this.considerforDBrValue = undefined;
        this.incomepermonthXConsiderforDBR = undefined;
        this.monthlySalary = undefined;
        this.yearOfBusiness = undefined;
        this.totalExpInBusiness = undefined;
        this.yearOfOccupation = undefined;
        this.totalWorkExp = undefined;
        this.yearOfServiceWidEmp = undefined;
        this.numberOfUnits = undefined;
        this.rentalIncome = undefined;
        this.employerName = undefined;
        this.natureofJob = undefined;
        this.businessName = undefined;
        this.businessNature = undefined;
        this.remarksValue = undefined;
        this.rentalpropertyaddress = undefined;
        this.overallRemarks = undefined;
        this.incomeRemarksValue = undefined;
        this.assumptionRemark = undefined;
        this.proofRemarks = undefined;
        this.natureofdocumentProof = undefined;
        this.overallRemarksRegardingBusiness = undefined;
        this.otherConfirmation = undefined;
    }


    handleSelectedCapabilityMember(event) {
        var data = event.detail;
        console.log('CAP DATA ###', data);
        this.capRecordId = data.recordData.Id;
        if (data && data.ActionName == 'delete') {
            console.log('char id', data.recordData.Id);
            this.showDeleteModal = true;
        }
        if (data && data.ActionName == 'edit') {
            this.labelSave = 'Update';
            this.showAcCapabilityForm = false;
            setTimeout(() => {
                this.capabilityRecordId = data.recordData.Id;
                this.showAcCapabilityForm = true;
            }, 200);
            this.loanApplicantId = data.recordData.Loan_Applicant__c;
            this.percentageOfIncome = data.recordData.of_income_transacted_through_bank_acco__c;
            this.monthlySalary = data.recordData.Monthly_Salary__c;
            this.yearOfBusiness = data.recordData.Year_of_Business__c;
            this.totalExpInBusiness = data.recordData.Total_experience_in_this_business_yrs__c;
            this.yearOfServiceWidEmp = data.recordData.Year_of_Service_With_Employer__c;
            this.totalWorkExp = data.recordData.Total_Work_Experience__c;
            this.yearOfOccupation = data.recordData.Year_of_Occupation__c;
            this.incomePerDayVal = data.recordData.Income_per_day__c;
            this.numberOfDays = data.recordData.Number_of_days__c;
            this.incomePerMonth = data.recordData.Income_per_month__c;
            this.numberOfUnits = data.recordData.No_of_Units__c;
            this.rentalIncome = data.recordData.Rental_Income__c;
            this.employerName = data.recordData.Name_of_the_Employer__c;
            this.businessPincode = data.recordData.BusinessPincode__c;
            this.incomePincode = data.recordData.IncomePincode__c;
            this.natureofJob = data.recordData.Nature_of_Job__c;
            this.overallRemarks = data.recordData.Overall_Remarks__c;
            this.considerforDBrValue = data.recordData.considered_for_DBR__c;
            this.rentalpropertyaddress = data.recordData.Rental_income_property_address__c;
            this.remarksValue = data.recordData.Remarks__c;
            this.incomeRemarksValue = data.recordData.Income_Remarks__c;
            this.assumptionRemark = data.recordData.Assumptions_for_Income__c;
            this.proofRemarks = data.recordData.Proof_Remarks_Daily_Wages__c;
            this.salesPerDay = data.recordData.Sales_per_day__c;
            this.electricity = data.recordData.Electricity__c;
            this.salary = data.recordData.Salary__c;
            this.others = data.recordData.Others__c;
            this.rent = data.recordData.Rent__c;
            this.overallRemarksRegardingBusiness = data.recordData.Overall_Remarks_Regarding_Business__c;
            this.natureofdocumentProof = data.recordData.Nature_of_Document_Proof_Self_Employed__c;
            this.otherConfirmation = data.recordData.Other_Confirmation_Self_Employed__c;
            this.businessName = data.recordData.Business_name__c;
            this.businessNature = data.recordData.Business_Nature__c;
            this.grossMonthlyIncome = data.recordData.Gross_Monthly_Income__c;
            console.log('char id', data.recordData.Id);
            this.makeAllFalse();

            if (data.recordData.Income_segment__c == 'Salaried') {
                this.isSalaried = true;
            } else if (data.recordData.Income_segment__c == 'Pension') {
                this.isPension = true;
            } else if (data.recordData.Income_segment__c == 'Daily wages') {
                this.isDailyWages = true;
            } else if (data.recordData.Income_segment__c == 'Income from Abroad') {
                this.isAbroadIncome = true;
            } else if (data.recordData.Income_segment__c == 'Eateries' || data.recordData.Income_segment__c == 'Food business' ||
                data.recordData.Income_segment__c == 'Manufacturing' || data.recordData.Income_segment__c == 'Shop owner' ||
                data.recordData.Income_segment__c == 'Milk business' || data.recordData.Income_segment__c == 'General shops' ||
                data.recordData.Income_segment__c == 'Vegetables/Fruits/Flower/Vendor'
            ) {
                this.isEateriesAndOthers = true;
            } else if (data.recordData.Income_segment__c == 'Self Employed') {
                this.isSelfEmployedOrBusiness = true;
            } else if (data.recordData.Income_segment__c == 'Housewife' || data.recordData.Income_segment__c == 'Retired' ||
                data.recordData.Income_segment__c == 'Unemployed' || data.recordData.Income_segment__c == 'Others') {
                this.isOther = true;
            }
            else if (data.recordData.Income_segment__c == 'Transport business') {
                this.isTransportBusiness = true;
            }
            if (data.recordData.Subsegment__c == 'Commercial - mortgage proeprty' || data.recordData.Subsegment__c == 'Residential - Mortgage property') {
                this.isRentalMortgage = true;
            } else if (data.recordData.Subsegment__c == 'Commercial - Other property' || data.recordData.Subsegment__c == 'Residential - Other proeprty') {
                this.isRentalOther = true;
            }
            if (data.recordData.Day_Margin_Basis__c == 'Day Basis') {
                this.isDayBasis = true;
            } else if (data.recordData.Day_Margin_Basis__c == 'Margin Basis') {
                this.isMarginBasis = true;
            }

        }
    }


    // This Method Is Used To Make All Falgs False.
    makeAllFalse() {
        this.isSalaried = false;
        this.isRentalMortgage = false;
        this.isRentalOther = false;
        this.isDailyWages = false;
        this.isPension = false;
        this.isAbroadIncome = false;
        this.isOther = false;
        this.isSelfEmployedOrBusiness = false;
        this.isEateriesAndOthers = false;
        this.isMarginBasis = false;
        this.isDayBasis = false;
        this.isTransportBusiness = false;
    }

    handlemodalactions(event) {
        this.showDeleteModal = false;
        console.log('event.detail>>>>> ', event.detail);
        if (event.detail === true) {
            this.capabilitychildSpinner = true;
            const removeEvent = new CustomEvent("handletabvalueremove", {
                detail: { tabname: 'Capability', subtabname: '' }
            });
            this.dispatchEvent(removeEvent);
            this.getCapabilityTableRecords();
        }
    }

    // to reset the form fields;
    resetLogic() {
        const inputFields = this.template.querySelectorAll('.capable');
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = "";
            });
        }
    }

    // to get the Capability Table Records for PC/AC -----
    getCapabilityTableRecords() {
        console.log('loan applicant data in pc capanbility>>>> ', this.loanApplicantId);
        let vefType, capType;
        if (this.sectiontitle == 'PC') {
            vefType = 'PC';
            capType = 'PC Capability';
        }
        else if (this.sectiontitle == 'AC') {
            vefType = 'AC';
            capType = 'AC Capability';

        }
        console.log('vef type', vefType, 'capType', capType);
        this.capabilitypcTableData = undefined;
        getCapabiltyData({ appId: this.appId,  recTypeName: vefType, metadataName: 'PC_Capabilty_Table', caprecordTypeName: capType }).then((result) => {
            console.log('getCapabilityTableRecords in pc= ', result);
            //this.capabilitypcTableData = result;
            this.capabilitypcTableData = JSON.parse(JSON.stringify(result));
            if (this.capabilitypcTableData && this.capabilitypcTableData.strDataTableData && JSON.parse(this.capabilitypcTableData.strDataTableData).length) {
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            const selectedEvent = new CustomEvent("handletabvaluechange", {
                                detail: { tabname: 'Capability', subtabname: '', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
                });
            }
            console.log('cap data', JSON.parse(JSON.stringify(result)));
            const changeEvent = new CustomEvent('checkcapabilityvalidation', {
                detail: true
            });
            this.dispatchEvent(changeEvent);
            this.capabilitychildSpinner = false;
        }).catch((err) => {
            this.capabilitypcTableData = undefined;
            console.log('getCapabilityTableRecords in pc Error= ', err);
            this.capabilitychildSpinner = false;
        });
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

    // This Method Is Used To Show Loader For Short Time
    showTemporaryLoader() {
        this.capabilitychildSpinner = true;
        let ref = this;
        setTimeout(function () {
            ref.capabilitychildSpinner = false;
        }, 500);
    }

}