/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Kuldeep Sahu  
* @modifiedBy       Kuldeep Sahu   
* @created          2022-05-03
* @modified         2022-07-21
* @Description      This component is build to handle all the operations related to 
                    Capability Tab In Verification-C in FiveStar.              
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
import { LightningElement, api, track } from 'lwc';
import getCapabiltyData from '@salesforce/apex/FIV_C_Controller.getCapabiltyData';
import getApplicantList from '@salesforce/apex/FIV_C_Controller.getApplicantList';
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

export default class FivcCapabilityLWC extends LightningElement {
    @api applicationId;
    @api verificationId;

    @track rowAction = rowAction;

    @track capabilityRecordId;
    @track capabilityTableData;
    @track customerList;
    @track customerMap;
    @track loanApplicantId;
    @track customerLoanApplicantMap;

    @track isSalaried = false;
    @track isRentalMortgage = false;
    @track isRentalOther = false;
    @track isDailyWages = false;
    @track isPension = false;
    @track isAbroadIncome = false;
    @track isOther = false;
    @track isSelfEmployedOrBusiness = false;
    @track isEateriesAndOthers = false;
    @track isTransport = false;
    @track isDayBasis = false;
    @track isMarginBasis = false;
    @track showLoader = false;
    @track showForm = true;

    @track salesPerMonth;
    @track marginInAmount;
    @track grossMonthlyIncome;
    @track shwoDeleteModal = false;
    @track fivCRecordType;

    @track empDocProof;
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
    @track numberOfUnits; // done
    @track rentalIncome; // done
    @track employerName; // done

    @track dbrValue;// done
    @track dbrIncomePerMonth;// done
    @track feedback1;// done
    @track feedback2;// done
    @track refContactNumber;// done
    @track refContactNumber2;// done
    @track busRefContactNumber;// done
    @track busRefContactNumber2;// done
    @track incRefContactNumber;// done
    @track proof;

    get DocProofRequired() {
        return (this.empDocProof == 'Yes');
    }

    get isProofRemarkMandatory() {
        console.log('isProofRemarkMandatory = ', this.proof)
        return (this.proof == 'yes') ? true : false;
    }

    get isRemarkMandatory() {
        if (this.isEateriesAndOthers) {
            return (this.feedback1 == 'Positive' && this.feedback2 == 'Positive') ? false : true;
        } else if (this.isSelfEmployedOrBusiness) {
            return (this.feedback1 == 'Positive' && this.feedback2 == 'Positive') ? false : true;
        } else if (this.isDailyWages) {
            return (this.feedback1 == 'Positive' && this.feedback2 == 'Positive') ? false : true;
        } else if (this.isAbroadIncome) {
            return (this.feedback1 == 'Positive') ? false : true;
        } else if (this.isTransport) {
            return (this.feedback1 == 'Positive' && this.feedback2 == 'Positive') ? false : true;
        }
        return false;
    }

    // This Method Is Used To Get All Data At Initial Level(Loading)
    connectedCallback() {
        this.handleGetApplicantList();
        this.handleGetFIVCRecordType();
    }

    // This Method Is Used To Handle Form Values
    handleFormValue(evt) {
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
        if (evt.target.fieldName == 'Income_segment__c') {
            this.makeReferenceDetailsBlank();
            this.isTransport = false;
            this.isSalaried = false;
            this.isDailyWages = false;
            this.isPension = false;
            this.isAbroadIncome = false;
            this.isOther = false;
            this.isSelfEmployedOrBusiness = false;
            this.isEateriesAndOthers = false;
            this.isDayBasis = false;
            this.isMarginBasis = false;
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
            } else if (evt.target.value == 'Self Employed') {
                this.isSelfEmployedOrBusiness = true;
            } else if (evt.target.value == 'Others') {
                this.isOther = true;
            } else if (evt.target.value == 'Transport business') {
                this.isTransport = true;
            } else if (evt.target.value == 'Rental Income') {
                // this.isTransport = true;
            } else {
                this.isEateriesAndOthers = true;
            }

            // else if (evt.target.value == 'Eateries' || evt.target.value == 'Food business' ||
            //     evt.target.value == 'Manufacturing' || evt.target.value == 'Shop owner' ||
            //     evt.target.value == 'Milk business' || evt.target.value == 'General shops' ||
            //     evt.target.value == 'Vegetables/Fruits/Flower/Vendor') {
            //     this.isEateriesAndOthers = true;
            // }
        } else if (evt.target.fieldName == 'Subsegment__c') {
            this.isRentalMortgage = false;
            this.isRentalOther = false;
            if (evt.target.value == 'Commercial - mortgage proeprty' || evt.target.value == 'Residential - Mortgage property') {
                this.isRentalMortgage = true;
            } else if (evt.target.value == 'Commercial - Other property' || evt.target.value == 'Residential - Other proeprty') {
                this.isRentalOther = true;
            }
        } else if (evt.target.fieldName == 'Day_Margin_Basis__c') {
            if (evt.target.value == 'Day Basis') {
                this.isDayBasis = true;
                this.isMarginBasis = false;
            } else if (evt.target.value == 'Margin Basis') {
                this.isMarginBasis = true;
                this.isDayBasis = false;
            }
            this.makeReferenceDetailsBlank();
        } else if (evt.target.fieldName == 'Employment_Document_Proof__c') {
            this.empDocProof = evt.target.value;
        } else if (evt.target.name == 'of_income_transacted_through_bank_acco__c') {
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
        } else if (evt.target.name == 'Income_per_month__c') {
            this.incomePerMonth = evt.target.value;
            if (this.dbrValue && this.incomePerMonth) {
                this.dbrIncomePerMonth = (this.incomePerMonth * this.dbrValue) / 100;
            }
        } else if (evt.target.name == 'No_of_Units__c') {
            this.numberOfUnits = evt.target.value;
        } else if (evt.target.name == 'Rental_Income__c') {
            this.rentalIncome = evt.target.value;
        } else if (evt.target.name == 'Name_of_the_Employer__c') {
            this.employerName = evt.target.value;
        } else if (evt.target.name == 'considered_for_DBR__c') {
            this.dbrValue = evt.target.value;
            if (this.dbrValue && this.incomePerMonth) {
                this.dbrIncomePerMonth = (this.incomePerMonth * this.dbrValue) / 100;
            }
        } else if (evt.target.fieldName == 'Feedback__c') {
            this.feedback1 = evt.target.value;
        } else if (evt.target.fieldName == 'Feedback_2__c') {
            this.feedback2 = evt.target.value;
        } else if (evt.target.name == 'Reference_Contact_Number__c') {
            this.refContactNumber = evt.target.value;
        } else if (evt.target.name == 'Reference_Contact_Number_2__c') {
            this.refContactNumber2 = evt.target.value;
        } else if (evt.target.name == 'Business_Reference_Contact_Number__c') {
            this.busRefContactNumber = evt.target.value;
        } else if (evt.target.name == 'Business_Reference_Contact_Number_2__c') {
            this.busRefContactNumber2 = evt.target.value;
        } else if (evt.target.name == 'Income_reference_Contact_Number__c') {
            this.incRefContactNumber = evt.target.value;
        } else if (evt.target.fieldName == 'Proof__c') {
            this.proof = evt.target.value;
        }

        let rcId = this.capabilityRecordId ? this.capabilityRecordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability__c', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);

        const selectedEvent2 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability__c', subtabname: '', fieldapiname: 'Verification__c', fieldvalue: this.verificationId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent2);

        const selectedEvent3 = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability__c', subtabname: '', fieldapiname: 'Application__c', fieldvalue: this.applicationId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent3);
    }

    makeReferenceDetailsBlank() {
        this.feedback1 = undefined;
        this.feedback2 = undefined;
        this.refContactNumber = undefined;
        this.refContactNumber2 = undefined;
        this.incRefContactNumber = undefined;
        this.busRefContactNumber = undefined;
        this.busRefContactNumber2 = undefined;
    }

    // This Method Is Used To Handle All Calculations
    handleCalculations(evt) {
        let incomeSegment = this.template.querySelector('[data-id="Income_segment__c"]').value;
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;
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
                let salesPerDay = this.template.querySelector('[data-id="Sales_per_day__c"]').value !== undefined ? this.template.querySelector('[data-id="Sales_per_day__c"]').value : 0;
                this.numberOfDays = (evt.target.name == 'Number_of_days__c') ? (evt.target.value ? evt.target.value : 0) : this.numberOfDays;
                let margin = this.template.querySelector('[data-id="Margin__c"]').value !== undefined ? this.template.querySelector('[data-id="Margin__c"]').value : 0;
                let electricity = this.template.querySelector('[data-id="Electricity__c"]').value !== undefined ? this.template.querySelector('[data-id="Electricity__c"]').value : 0;
                let salary = this.template.querySelector('[data-id="Salary__c"]').value !== undefined ? this.template.querySelector('[data-id="Salary__c"]').value : 0;
                let rent = this.template.querySelector('[data-id="Rent__c"]').value !== undefined ? this.template.querySelector('[data-id="Rent__c"]').value : 0;
                let others = this.template.querySelector('[data-id="Others__c"]').value !== undefined ? this.template.querySelector('[data-id="Others__c"]').value : 0;
                salesPerDay = parseFloat(salesPerDay);
                this.numberOfDays = parseFloat(this.numberOfDays);
                electricity = parseFloat(electricity);
                salary = parseFloat(salary);
                rent = parseFloat(rent);
                others = parseFloat(others);

                this.salesPerMonth = salesPerDay * this.numberOfDays;
                this.marginInAmount = this.salesPerMonth / 100 * margin;
                this.grossMonthlyIncome = (this.marginInAmount - (electricity + salary + rent + others));
            }
        }

        let rcId = this.capabilityRecordId ? this.capabilityRecordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability__c', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);
    }

    // This Method Is Used To Handle Customer Selection
    handleCustomerSelection(evt) {
        console.log('handleCustomer Selection =', evt.target.value)
        this.loanApplicantId = evt.target.value;

        let rcId = this.capabilityRecordId ? this.capabilityRecordId : '1';
        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Capability__c', subtabname: '', fieldapiname: 'Loan_Applicant__c', fieldvalue: this.loanApplicantId, recordId: rcId }
        });
        this.dispatchEvent(selectedEvent);
    }

    // This Method Is Used To Check Capability Validation
    @api
    checkCapabilityValidation() {
        let allValid = true;
        let tempMap = {};
        let tempListError = [];
        this.customerList.forEach(currentItem => {
            console.log('validation loop= ', this.customerMap[currentItem.value])
            if (this.customerMap[currentItem.value] && this.customerMap[currentItem.value].Income_Considered__c == 'Yes') {
                tempMap[currentItem.value] = 'Not Exist';
            }
        });

        console.log('incomeConsideredLength= ', tempMap);
        if ((this.capabilityTableData && this.capabilityTableData.strDataTableData && JSON.parse(this.capabilityTableData.strDataTableData).length > 0)) {
            JSON.parse(this.capabilityTableData.strDataTableData).forEach(element => {
                if (tempMap[element.Loan_Applicant__c] == 'Not Exist') {
                    tempMap[element.Loan_Applicant__c] = 'Exist';
                }
            });

            for (let keyValue of Object.keys(tempMap)) {
                let element = JSON.parse(JSON.stringify(tempMap[keyValue]))
                if (element == 'Not Exist') {
                    let msg = this.customerMap[keyValue].Customer_Information__r.Name + "'s Capability Record Is Missing."
                    tempListError.push(msg);
                }
            }
        } else if (JSON.stringify(tempMap) != {}) {
            tempListError.push('Add Capabilities For Applicants Whose Income Are Considered');
            console.log('2');
        }

        console.log('tempListError = ', tempListError);

        this.dispatchEvent(new CustomEvent('capabilityvalidation', {
            detail: tempListError
        }));
    }

    // This Method Is Used To Handle Capability Table Selection Event
    handleSelectedCapability(evt) {
        console.log('handleSelectedCapability= ', JSON.stringify(evt.detail));
        var data = evt.detail;

        if (data && data.ActionName == 'edit') {
            this.capabilityRecordId = data.recordData.Id;
            this.loanApplicantId = data.recordData.Loan_Applicant__c;
            this.empDocProof = data.recordData.Employment_Document_Proof__c;
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
            this.dbrIncomePerMonth = data.recordData.Income_per_month_Pension__c;
            this.dbrValue = data.recordData.considered_for_DBR__c;
            this.feedback1 = data.recordData.Feedback__c;
            this.feedback2 = data.recordData.Feedback_2__c;
            this.refContactNumber = data.recordData.Reference_Contact_Number__c;
            this.refContactNumber2 = data.recordData.Reference_Contact_Number_2__c;
            this.busRefContactNumber = data.recordData.Business_Reference_Contact_Number__c;
            this.busRefContactNumber2 = data.recordData.Business_Reference_Contact_Number_2__c;
            this.incRefContactNumber = data.recordData.Income_reference_Contact_Number__c;
            this.proof = data.recordData.Proof__c;

            this.makeAllFalse();

            if (data.recordData.Income_segment__c == 'Salaried') {
                this.isSalaried = true;
            } else if (data.recordData.Income_segment__c == 'Pension') {
                this.isPension = true;
            } else if (data.recordData.Income_segment__c == 'Daily wages') {
                this.isDailyWages = true;
            } else if (data.recordData.Income_segment__c == 'Income from Abroad') {
                this.isAbroadIncome = true;
            } else if (data.recordData.Income_segment__c == 'Self Employed') {
                this.isSelfEmployedOrBusiness = true;
            } else if (data.recordData.Income_segment__c == 'Others') {
                this.isOther = true;
            } else if (data.recordData.Income_segment__c == 'Transport business') {
                this.isTransport = true;
            } else if (data.recordData.Income_segment__c) {
                this.isEateriesAndOthers = true;
            }

            if (data.recordData.Subsegment__c == 'Commercial - mortgage proeprty' || data.recordData.Subsegment__c == 'Residential - Mortgage property') {
                this.isSelfEmployedOrBusiness = false;
                this.isEateriesAndOthers = false;
                this.isRentalMortgage = true;
            } else if (data.recordData.Subsegment__c == 'Commercial - Other property' || data.recordData.Subsegment__c == 'Residential - Other proeprty') {
                this.isSelfEmployedOrBusiness = false;
                this.isEateriesAndOthers = false;
                this.isRentalOther = true;
            }

            if (data.recordData.Day_Margin_Basis__c == 'Day Basis') {
                this.isDayBasis = true;
            } else if (data.recordData.Day_Margin_Basis__c == 'Margin Basis') {
                this.isMarginBasis = true;
            }
        } else if (data && data.ActionName == 'delete') {
            this.makeAllFalse();
            this.showDeleteModal = true;
            this.capabilityRecordId = data.recordData.Id;
        }
    }

    // This Method Is Used To Handle Cancel Action On Form
    onCancel() {
        this.capabilityRecordId = undefined;
        this.loanApplicantId = undefined;
        this.empDocProof = undefined;
        this.percentageOfIncome = undefined;
        this.monthlySalary = undefined;
        this.yearOfBusiness = undefined;
        this.totalExpInBusiness = undefined;
        this.yearOfServiceWidEmp = undefined;
        this.totalWorkExp = undefined;
        this.yearOfOccupation = undefined;
        this.incomePerDayVal = undefined;
        this.numberOfDays = undefined;
        this.incomePerMonth = undefined;
        this.numberOfUnits = undefined;
        this.rentalIncome = undefined;
        this.dbrValue = undefined;
        this.dbrIncomePerMonth = undefined;
        this.employerName = undefined;
        this.feedback1 = undefined;
        this.feedback2 = undefined;
        this.refContactNumber = undefined;
        this.refContactNumber2 = undefined;
        this.busRefContactNumber = undefined;
        this.busRefContactNumber2 = undefined;
        this.incRefContactNumber = undefined;
        this.proof = undefined;

        this.makeReferenceDetailsBlank();
        this.makeAllFalse();
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
        this.isTransport = false;
    }

    // This Method Is Used To Show Loader For Short Time
    showTemporaryLoader() {
        this.showLoader = true;
        let ref = this;
        setTimeout(function () {
            ref.showLoader = false;
        }, 500);
    }

    checkRecordValidity() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    }

    // This Method Is Used To Handle Actions Post Submit
    handleCapabiltySubmit(event) {
        console.log('handleCapabiltySubmit called');
        let validInputs = this.checkRecordValidity();
        if (!this.loanApplicantId) {
            event.preventDefault();
            this.showNotifications('Missing values', 'You haven\'t selected any customer', 'error');
        } else if (!validInputs) {
            event.preventDefault();
            this.showNotifications('Invalid Values', 'Please enter correct values', 'error');
        } else {
            this.showTemporaryLoader();
        }
    }

    // This Method Is Used To Handle Actions Post Success
    handleCapabiltySuccess() {
        console.log('handleCapabiltySuccess= ');
        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Capability__c', subtabname: '' }
        });
        this.dispatchEvent(removeEvent);
        this.showNotifications('Success', 'Capability Saved Successfully', 'success');
        this.onCancel();
        this.grossMonthlyIncome = undefined;
        this.salesPerMonth = undefined;
        this.marginInAmount = undefined;
        this.capabilityRecordId = undefined;
        this.showForm = false;
        this.capabilityTableData = undefined;
        let ref = this;
        setTimeout(() => {
            ref.showForm = true;
            ref.capabilityRecordId = undefined;
        }, 200);
        this.getCapabilityTableRecords();
    }

    // This Method Is Used To Handle Delete Actions
    handleDelete(event) {
        console.log('handleDelete= ', event.target.label)
        let label = event.target.label;
        if (label == 'Yes') {
            this.showDeleteModal = false;
            this.handleDeleteRecord(this.capabilityRecordId);
        } else if (label == 'No') {
            this.showDeleteModal = false;
            this.makeAllFalse();
            this.capabilityRecordId = undefined;
        }
    }

    // This Method Is Used To Show Toast Notificatin
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    /*=================  All server methods  ====================*/

    // This Method Is Used To Get All The Capability Table Records
    getCapabilityTableRecords() {
        this.showLoader = true;
        this.capabilityTableData = undefined;
        getCapabiltyData({ recordId: this.applicationId }).then((result) => {
            console.log('getCapabilityTableRecords= ', result);
            this.capabilityTableData = JSON.parse(JSON.stringify(result));
            if (this.capabilityTableData && this.capabilityTableData.strDataTableData && JSON.parse(this.capabilityTableData.strDataTableData).length) {
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            const selectedEvent = new CustomEvent("handletabvaluechange", {
                                detail: { tabname: 'Capability__c', subtabname: '', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id }
                            });
                            this.dispatchEvent(selectedEvent);
                        }
                    }
                });
            }
            this.showLoader = false;
            this.checkCapabilityValidation();
        }).catch((err) => {
            this.capabilityTableData = undefined;
            console.log('getCapabilityTableRecords Error= ', err);
            this.showLoader = false;
            this.checkCapabilityValidation();
        });
    }

    // This Method Is Used To Get Account List
    handleGetApplicantList() {
        getApplicantList({ appId: this.applicationId }).then((result) => {
            console.log('Capability handleGetApplicantList = ', result);
            if (result) {
                let tempList = [];
                this.customerMap = JSON.parse(JSON.stringify(result));

                for (let keyValue of Object.keys(this.customerMap)) {
                    let element = JSON.parse(JSON.stringify(this.customerMap[keyValue]))
                    tempList.push({ label: element.Customer_Information__r.Name, value: element.Id });
                }
                this.customerList = JSON.parse(JSON.stringify(tempList));
                this.getCapabilityTableRecords();
            }
        }).catch((err) => {
            console.log('Error in handleGetApplicantList = ', err);
            this.getCapabilityTableRecords();
        });
    }

    // This Method Is Used To Delete Capability Record
    handleDeleteRecord(recordIdToDelete) {
        this.showTemporaryLoader();
        deleteRecord({ recordId: recordIdToDelete }).then((result) => {
            console.log('handleDeleteRecord = ', result);
            if (result == 'success') {
                this.showNotifications('', 'Record deleted successfully', 'success');
                this.capabilityRecordId = undefined;
                this.capabilityTableData = undefined;
                let ref = this;
                setTimeout(() => {
                    ref.getCapabilityTableRecords();
                }, 400);
            }
        }).catch((err) => {
            console.log('Error in handleDeleteRecord = ', err);
        });
    }

    // This Method Is Used To Get FIV-C RecordTypeId For Capability Object
    handleGetFIVCRecordType() {
        getRecordTypeId({
            sObjectName: 'Capability__c',
            recordTypeName: 'FIV-C Capability'
        }).then((result) => {
            console.log('handleGetFIVCRecordType = ', result);
            this.fivCRecordType = result
        }).catch((err) => {
            console.log('Error in handleGetFIVCRecordType = ', err);
        });
    }
}