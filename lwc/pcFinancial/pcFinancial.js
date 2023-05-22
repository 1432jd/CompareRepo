import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import getData from '@salesforce/apex/fsPcAcController.getData';
import getIncomeSummary from '@salesforce/apex/fsPcAcController.getIncomeSummary';
import getAccounts from '@salesforce/apex/fsPcAcController.getAccounts';
import geteffectiveIrr from '@salesforce/apex/fsPcAcController.getEffectiveIRR';
import { refreshApex } from '@salesforce/apex';
import handleTrancheApplication from '@salesforce/apex/fsPcAcController.handleTrancheApplication';
import setInsuranceFields from '@salesforce/apex/fsPcAcController.setInsuranceFields';
import generateTopupDetails from '@salesforce/apex/fsPcAcController.generateTopupDetails';
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import Amount_Recommended from '@salesforce/schema/Application__c.Amount_Recommended__c';

// Added on 09.05.23

import getCapabilityIncomeSummary from '@salesforce/apex/fsPcAcController.getCapabilityIncomeSummary';

const APPLICATION_FIELDS = [
    'Application__c.Disbursement_Party_Name__c',
    'Application__c.Discussion_done_with__c',
    'Application__c.Supervisor_recommendation__c',
    'Application__c.Supervisor_Name__c',
    'Application__c.Increased_amount__c',
    'Application__c.Comment_Remarks__c',
    'Application__c.KYC_Risk_Rating__c',
    'Application__c.Loan_Type__c',
    'Application__c.Product_Type__c',
    'Application__c.Customer_Type_PcAc__c',
    'Application__c.Loan_Purpose_1__c',
    'Application__c.Loan_Purpose_2__c',
    'Application__c.Reason_for_change_in_net_income__c',
    'Application__c.Remarks_change_in_net_income__c',
    'Application__c.Customer_Sub_Segment__c',
    'Application__c.Customer_Segment__c',
    'Application__c.Income_Segment_1__c',
    'Application__c.Income_Sub_Segment__c',
    'Application__c.Scheme__c',
    'Application__c.Total_net_income_after_2nd_tranche__c',
    'Application__c.Tranche_Disbursal__c',
    'Application__c.Final_Collateral_value_for_Tranche_2__c',
    'Application__c.Reason_for_change_in_collateral_value__c',
    'Application__c.Remarks_for_change_in_collateral_value__c',
    'Application__c.Amount_Recommended__c',
    'Application__c.Total_Amount_Recommended_PcAc__c',
    'Application__c.Insurance_Premium__c',
    'Application__c.Total_ROI__c',
    'Application__c.Tenor_In_Months__c',
    'Application__c.Tranche_1__c',
    'Application__c.Tranche_2__c',
    'Application__c.Nominee__c',
    'Application__c.Name__c',
    'Application__c.Nominee_Party__c',
    'Application__c.Customer_Communicated__c',
    'Application__c.Margin_ROI__c',
    'Application__c.Group_Valuation__c',
    'Application__c.Transaction_LTV__c',
    'Application__c.Transaction_DBR__c',
    'Application__c.DBR_PC__c',
    'Application__c.NACH_Party_2_ID__c',
    'Application__c.NACH_Party_1_ID__c',
    'Application__c.Staff_Loan__c',
    'Application__c.Effective_IRR__c',
    'Application__c.Emi_PcAc__c',
    'Application__c.Principal_O_S__c',
    'Application__c.Disbursement_party__c',
    'Application__c.Disbursement_party_Id__c',
    'Application__c.Combined_LTV__c',
    'Application__c.EMI_for_Tranche_Amount_2__c',
    'Application__c.Considered_for__c',
    'Application__c.Neighbour_feedback__c',
    'Application__c.Living_style__c',
    'Application__c.HM__c',
    'Application__c.LTV_PCAC__c',
    'Application__c.DBR_PC_AC__c',
    'Application__c.Balance_Transfer__c',
    'Application__c.Borrower_s_Risk_Rating__c',
    'Application__c.Balance_Transfer_Amount__c',
    'Application__c.Guarantor_Networth_Choosen__c',
    'Application__c.Risk_Document__c',
    'Application__c.Nach_Party__c',
    'Application__c.Nach_Party_2__c',
    'Application__c.Group_Total_Exposure_PcAc__c',
    'Application__c.Nominee_Party_Relationship_with_Insured__c',
    'Application__c.Nominee_Relationship_Type__c',
    'Application__c.Number_of_advance_EMI__c',
    'Application__c.Loan_Amount__c',
    'Application__c.Insurance_Requirement__c',
    'Application__c.Insurance_Medical_Test_Result__c',
    'Application__c.Final_Tranche_1_Loan_Amount__c',
    'Application__c.Insurance_Premium_Tranche_1__c',
    'Application__c.Insured_Person__c',
    'Application__c.NomineeName__c',
];
export default class PcFinancial extends LightningElement {

    columns = [{ label: 'Sr No', fieldName: 'Sr_No', type: 'number', cellAttributes: { alignment: 'left' } },
    { label: 'Collateral ID', fieldName: 'Property_ID__c', type: 'text' },
    { label: 'Loan Id', fieldName: 'Application__r.LMS_Response_Reference__c', type: 'text' },
    { label: 'Collateral Address', fieldName: 'Property_Address__c', type: 'text' }];

    @api sectiontitle;
    @api applicationId;
    @api applicationName;
    @api verfId;
    @api loginId;
    @api customerOptions;
    @api recordTypeName;
    @api propertySummary;

    //Added on 09.05.23
    @track incomeMap = new Map();
    @track maxSegmentIncome;
    @track maxSubSegmentIncome;
    @track secondMaxSegmentIncome;
    @track secondMaxSubSegmentIncome;

    @track customerValue;
    @track customerType;
    @track TrancheValue;
    @track loanType;
    @track loanPuropse;
    @track isTopupDetails = false;
    @track isCollateraldetails = false;
    @track isOldloandetails = false;
    @track isApplicationdetails = false;
    @track isLoandetails = false;
    @track isTranche = false;
    @track isInsuranceparty = false;
    @track isDisbursementdetail = false;
    @track isLoanAmount = false;
    @track isEligibilityCalculations = false;
    @track isRiskRating = false;
    @track isOthers = false;
    @track isExecutiveSummary = false;
    @track financialSpinner = false;


    @track RecordType;
    @track error;
    @track record;
    @track topUpSection = false;


    @track disbursementpartyvalue;
    @track disbursementpartyId;
    @track nachpartyvalue2;
    @track nachpartyvalue;
    @track nachpartyId1;
    @track nachpartyId2;
    @track incomeSummaryObj;
    @track beneficiarytypeOption;
    @track showdisbursement = false;
    @track showThirdPartyName = false;
    @track considerforTopupvalue;
    @track oldloanAmount;
    @track groupTotalExposure;


    // loan detail Section
    @track hasRoiValue = false;
    @track hasTenorValue = false;
    @track tenorValue;
    @track roiRate;
    @track totalROI;
    @track marginROI;
    @track effIrr;
    @track iseffIrrDisabled = true;
    @track isRoiDisabled = true;
    @track showModal = false;
    @track advanceEmi = '1';
    @track tenorRoiMap = new Map();
    @track balanceTransferAmountShow = true;
    @track btAmount;
    @track gNetworth;
    @track riskdoc;

    ////////////// Tranche Section
    get Tranche() {
        return (this.isTrancheI || this.isTrancheII);
    }
    get disbOptions() {
        if (this.trancheDisb == 'II' && this.recordTypeName == '4. Tranche loan') {
            return [{ label: 'II', value: 'II' }];
        }
        else if (this.trancheDisb == 'II' && this.recordTypeName == '3. Top-up loan') {
            return [{ label: 'Normal', value: 'Normal' },
            { label: 'I', value: 'I' },
            { label: 'II', value: 'II' }];
        }
        else
            return [{ label: 'Normal', value: 'Normal' },
            { label: 'I', value: 'I' },
            { label: 'II', value: 'II' }];
    }

    get trancheRemarksSize() {
        return (this.isTrancheII ? 6 : 12);
    }

    @track isTrancheI = false;
    @track isTrancheII = false;
    @track totalIncome;
    @track netIncomeRemarks = false;
    @track netIncomePresent = false;
    @track finalcolPresent = false;
    @track finalCollateralValue;
    @track colRequired = false;
    @track totalTranche;
    @track tranche1;
    @track tranche2;
    @track netIncomeLabel = 'Net income considered for subsequent tranche (INR)';
    @track colValueLabel = 'Considered Collateral value for subsequent Tranche';
    @track showEmi = false;
    @track emiTrancheValue;
    @track emiValue;
    @track totaltranche1amountValue;
    @track finaltranche1;
    @track incomeReason = '';
    @track collateralReason = '';
    @track supervisorRec = '';
    @track fieldOfficerEMPId;


    /////////////////////////////loan Amount Section

    @track amountrecomended;
    @track grpValuation;
    @track totalamountValue;
    @track insuranceamount = 0;
    @track insuranceamounttranche1 = 0;
    @track amountDisabled = false;
    @track groupValuationValue;
    @track loanTypeValue;
    @track hasEmi = false;
    @track principalOs;


    /////////////////// Insurance Party
    @track isInsuranceValid = true;
    @track nomineeOptions;
    @track shownominee = false;
    @track nomineedata;
    @track fakeNominee = false;
    @track nomineeValue;
    @track insuredName;
    @track relationshipType;
    @track relationshipValue;
    @track insurancereq;
    @track insurancemedicalValue;
    @track insurePersonId;
    @track nomineePersonId;
    @track insuredPersonName;
    @track nomineePersonName

    get relationshipOptions() {
        if (this.relationshipType == 'Blood Relative') {
            return [
                { label: 'Husband of', value: 'Husband of' },
                { label: 'Wife of', value: 'Wife of' },
                { label: 'Son of', value: 'Son of' },
                { label: 'Daughter Of', value: 'Daughter Of' },
                { label: 'Father of', value: 'Father of' },
                { label: 'Mother of', value: 'Mother of' },
                { label: 'Brother of', value: 'Brother of' },
                { label: 'Sister of', value: 'Sister of' },
                { label: 'Grandfather of', value: 'Grandfather of' },
                { label: 'Grandmother of', value: 'Grandmother of' },
                { label: 'Grandson of', value: 'Grandson of' },
                { label: 'Granddaughter of', value: 'Granddaughter of' },
            ];
        }
        else if (this.relationshipType == 'Not a Blood Relative') {
            return [
                { label: 'Uncle of', value: 'Uncle of' },
                { label: 'Aunt of', value: 'Aunt of' },
                { label: 'In laws', value: 'In laws ' },
                { label: 'Cousin of', value: 'Cousin of' },
                { label: 'Nephew', value: 'Nephew' },
                { label: 'Neice', value: 'Neice' },
                { label: 'Brother in law of', value: 'Brother in law of' },
            ];
        }
    }

    get insuranceReqOptions() {
        return [
            { label: 'DOGH', value: 'DOGH' },
            { label: 'DOGH + MT', value: 'DOGH + MT' }];
    }

    get showSupervisor(){
        return this.supervisorRec = 'Yes' ? true : false;
    }

    get insurancemedicalOptions() {
        if (this.insurancereq == 'DOGH') {
            return [
                { label: 'Standard', value: 'Standard' }];
        }
        else if (this.insurancereq == 'DOGH + MT') {
            return [
                { label: 'Rated Up', value: 'Rated Up' },
                { label: 'Rejected', value: 'Rejected' }];
        }

    }


    //////////// eligibility Tab
    @track netIncome;
    @track tranchecollateralValue;
    @track tranchenetIncome;
    @track collateralValue;
    @track tarnscLTV;
    @track combinedLTV;
    @track transcDBR;
    @track combinedDBR;
    @track highmarkEmiAmount;

    /// Risk Rating 
    @track lTVScore;
    @track DBRScore;
    @track HMScore;
    @track livingStyleScore;
    @track neighbourFeedBackScore;
    @track brRating = '';
    @api tabName;
    @track trancheDisb;
    @track trancheError = false;
    @track relationOptions;

    _refreshdata;


    @wire(getRecord, { recordId: '$applicationId', fields: APPLICATION_FIELDS })
    applicationData(value) {
        const { error, data } = value;
        this._refreshdata = value;
        if (data) {
            console.log('application data>>>>>>', data);
            console.log('tranche disbursal callled', data.fields.Tranche_Disbursal__c.value);
            if(!this.fieldOfficerEMPId)
                this.fieldOfficerEMPId = data.fields.Supervisor_Name__c.value;
            this.supervisorRec = data.fields.Supervisor_recommendation__c.value;
            let cmp = this.template.querySelector('c-l-w-c-lookup');
            if(cmp){
                cmp.getPreSelectedRecord(this.fieldOfficer);
            }

            let res = data.fields;
            for (let key of Object.keys(res)) {
                if (key != 'Id') {
                    console.log('insideee111 keyValue ', key)
                    const selectedEvent = new CustomEvent("handletabvaluechange", {
                        detail: { tabname: 'Financial', subtabname: '', fieldapiname: key, fieldvalue: res[key].value, recordId: this.applicationId }
                    });
                    this.dispatchEvent(selectedEvent);
                    this.getMaxIncome();
                }
            }

            if (data.fields.Total_net_income_after_2nd_tranche__c.value != null && data.fields.Total_net_income_after_2nd_tranche__c.value != ''
                && data.fields.Total_net_income_after_2nd_tranche__c.value != undefined) {
                this.netIncomePresent = true;
                this.totalIncome = data.fields.Total_net_income_after_2nd_tranche__c.value;
            }
            if (data.fields.Tranche_1__c.value != null && data.fields.Tranche_1__c.value != undefined) {
                this.tranche1 = data.fields.Tranche_1__c.value;
            }
            if (data.fields.Final_Tranche_1_Loan_Amount__c.value != null && data.fields.Final_Tranche_1_Loan_Amount__c.value != undefined) {
                this.finaltranche1 = data.fields.Final_Tranche_1_Loan_Amount__c.value;
            }
            if (data.fields.Tranche_2__c.value != null && data.fields.Tranche_2__c.value != undefined) {
                this.tranche2 = data.fields.Tranche_2__c.value;
            }
            if (data.fields.Reason_for_change_in_net_income__c.value != null && data.fields.Reason_for_change_in_net_income__c.value != undefined) {
                this.incomeReason = data.fields.Reason_for_change_in_net_income__c.value;
            }
            if (data.fields.Reason_for_change_in_collateral_value__c.value != null && data.fields.Reason_for_change_in_collateral_value__c.value != undefined) {
                this.collateralReason = data.fields.Reason_for_change_in_collateral_value__c.value;
            }
            if (data.fields.Nominee_Relationship_Type__c.value != null && data.fields.Nominee_Relationship_Type__c.value != undefined) {
                this.relationshipType = data.fields.Nominee_Relationship_Type__c.value;
            }
            if (data.fields.Nominee_Party_Relationship_with_Insured__c.value != null && data.fields.Nominee_Party_Relationship_with_Insured__c.value != undefined) {
                this.relationshipValue = data.fields.Nominee_Party_Relationship_with_Insured__c.value;
            }
            this.totalTranche = (this.finaltranche1 ? parseFloat(this.finaltranche1) : 0) + (this.tranche2 ? parseFloat(this.tranche2) : 0);
            if (data.fields.Considered_for__c.value != null && data.fields.Considered_for__c.value != undefined) {
                this.considerforTopupvalue = data.fields.Considered_for__c.value;
            }
            if (data.fields.Insurance_Requirement__c.value != null && data.fields.Insurance_Requirement__c.value != undefined) {
                this.insurancereq = data.fields.Insurance_Requirement__c.value;
            }
            if (data.fields.Insurance_Medical_Test_Result__c.value != null && data.fields.Insurance_Medical_Test_Result__c.value != undefined) {
                this.insurancemedicalValue = data.fields.Insurance_Medical_Test_Result__c.value;
            }
            if (data.fields.Tranche_Disbursal__c.value != null && data.fields.Tranche_Disbursal__c.value != '' &&
                data.fields.Tranche_Disbursal__c.value != undefined) {
                console.log('tranche disbursal callled');
                this.trancheDisb = data.fields.Tranche_Disbursal__c.value;
                if (data.fields.Tranche_Disbursal__c.value == 'I') {
                    //this.isTranche = true;
                    console.log('tranche disbursal callled');
                    //this.netIncomeLabel = 'Total net income after Ist tranche(₹)';
                    //this.colValueLabel = 'Final Collateral value for Tranche 1';
                    this.isTrancheI = true;
                    this.isTrancheII = false;
                    this.showEmi = false;
                    this.amountDisabled = true;
                }
                else if (data.fields.Tranche_Disbursal__c.value == 'II') {
                    //this.isTranche = true;
                    //this.netIncomeLabel = 'Total net income after 2nd tranche(₹)';
                    //this.colValueLabel = 'Final Collateral value for Tranche 2';
                    this.isTrancheII = true;
                    this.isTrancheI = false;
                    this.showEmi = true;
                    this.amountDisabled = true;
                }
                else {
                    //this.isTranche = false;
                    this.isTrancheI = false;
                    this.isTrancheII = false;
                    this.amountDisabled = false;
                }

            }
            if (data.fields.Amount_Recommended__c.value != null && data.fields.Amount_Recommended__c.value != undefined && !this.isTranche) {
                this.amountrecomended = data.fields.Amount_Recommended__c.value;
            }
            if (data.fields.Insurance_Premium__c.value != null && data.fields.Insurance_Premium__c.value != undefined) {
                // if (this.isTrancheII)
                //     this.insuranceamount = 0;
                // else
                this.insuranceamount = data.fields.Insurance_Premium__c.value;
            }
            else
                this.insuranceamount = 0;
            if (data.fields.Insurance_Premium_Tranche_1__c.value != null && data.fields.Insurance_Premium_Tranche_1__c.value != undefined) {
                this.insuranceamounttranche1 = data.fields.Insurance_Premium_Tranche_1__c.value;
            }
            else
                this.insuranceamounttranche1 = 0;
            if (this.tranche2 && this.roiRate && this.tenorValue) { this.emiTrancheValue = Math.ceil((parseFloat(this.tranche2) * parseFloat(this.roiRate / 1200)) * ((Math.pow((1 + parseFloat(this.roiRate / 1200)), parseFloat(this.tenorValue)) / (Math.pow((1 + parseFloat(this.roiRate / 1200)), parseFloat(this.tenorValue)) - 1)))); }

            if (data.fields.EMI_for_Tranche_Amount_2__c.value != null && data.fields.EMI_for_Tranche_Amount_2__c.value != undefined) {
                this.emiTrancheValue = data.fields.EMI_for_Tranche_Amount_2__c.value;
            }
            if (data.fields.Balance_Transfer_Amount__c.value != null && data.fields.Balance_Transfer_Amount__c.value != undefined) {
                this.btAmount = data.fields.Balance_Transfer_Amount__c.value;
            }
            if (data.fields.Guarantor_Networth_Choosen__c.value != null && data.fields.Guarantor_Networth_Choosen__c.value != undefined) {
                this.gNetworth = data.fields.Guarantor_Networth_Choosen__c.value;
            }
            console.log('emi tranche value in handle3 change', this.emiTrancheValue);
            if (data.fields.Final_Collateral_value_for_Tranche_2__c.value != null && data.fields.Final_Collateral_value_for_Tranche_2__c.value != '' &&
                data.fields.Final_Collateral_value_for_Tranche_2__c.value != undefined) {
                this.finalcolPresent = true;
                this.finalCollateralValue = data.fields.Final_Collateral_value_for_Tranche_2__c.value;
            }


            if (data.fields.Tenor_In_Months__c.value != null && data.fields.Tenor_In_Months__c.value != undefined) {
                this.hasTenorValue = true;
                this.tenorValue = data.fields.Tenor_In_Months__c.value;
            }
            if (data.fields.Balance_Transfer__c.value != null && data.fields.Balance_Transfer__c.value != undefined) {
                if (data.fields.Balance_Transfer__c.value == 'No')
                    this.balanceTransferAmountShow = false;
                else
                    this.balanceTransferAmountShow = true;
            }

            if (data.fields.Nominee__c.value != null && data.fields.Nominee__c.value != undefined) {
                if (data.fields.Nominee__c.value == 'No') {
                    this.nomineeValue = '';
                    this.nomineePersonName = '';
                    this.shownominee = true;
                    this.fakeNominee = false;
                }
                else if (data.fields.Nominee__c.value == 'Yes') {
                    this.shownominee = false;
                    this.fakeNominee = true;
                }
                else {
                    this.shownominee = false;
                    this.fakeNominee = false;
                }
            }
            if (data.fields.Nominee_Party__c.value != null && data.fields.Nominee_Party__c.value != undefined) {
                this.nomineePersonName = data.fields.Nominee_Party__c.value;
                if (data.fields.NomineeName__c.value) {
                    this.nomineeValue = data.fields.Nominee_Party__c.value + '_' + data.fields.NomineeName__c.value;
                    this.nomineePersonId = data.fields.NomineeName__c.value;
                }
                else {
                    this.nomineeValue = null;
                    this.nomineePersonId = null;
                }
            }
            if (data.fields.Name__c.value != null && data.fields.Name__c.value != undefined) {
                this.insuredName = data.fields.Name__c.value + '_' + data.fields.Insured_Person__c.value;
                this.insuredPersonName = data.fields.Name__c.value;
            }
            if (data.fields.Customer_Communicated__c.value != null && data.fields.Customer_Communicated__c.value != undefined) {
                this.hasRoiValue = true;
                this.roiRate = data.fields.Customer_Communicated__c.value;
                this.isRoiDisabled = true;
            }
            if (data.fields.Emi_PcAc__c.value != null && data.fields.Emi_PcAc__c.value != undefined) {
                this.hasEmi = true;
                this.emiValue = data.fields.Emi_PcAc__c.value;
            }

            if (data.fields.Margin_ROI__c.value != null && data.fields.Margin_ROI__c.value != undefined)
                this.marginROI = data.fields.Margin_ROI__c.value;

            if (data.fields.HM__c.value != null && data.fields.HM__c.value != undefined)
                this.HMScore = data.fields.HM__c.value;

            if (data.fields.Group_Valuation__c.value != null && data.fields.Group_Valuation__c.value != undefined) {
                console.log('IN GRP Val');
                this.grpValuation = data.fields.Group_Valuation__c.value;
            }
            if (data.fields.Number_of_advance_EMI__c.value != null && data.fields.Number_of_advance_EMI__c.value != undefined)
                this.advanceEmi = data.fields.Number_of_advance_EMI__c.value;

            if (data.fields.Transaction_LTV__c.value != null && data.fields.Transaction_LTV__c.value != undefined)
                this.tarnscLTV = data.fields.Transaction_LTV__c.value;
            if (data.fields.Combined_LTV__c.value != null && data.fields.Combined_LTV__c.value != undefined)
                this.combinedLTV = data.fields.Combined_LTV__c.value;
            if (data.fields.Transaction_DBR__c.value != null && data.fields.Transaction_DBR__c.value != undefined)
                this.transcDBR = data.fields.Transaction_DBR__c.value;
            if (data.fields.DBR_PC__c.value != null && data.fields.DBR_PC__c.value != undefined)
                this.combinedDBR = data.fields.DBR_PC__c.value;
            if (data.fields.Number_of_advance_EMI__c.value != null && data.fields.Number_of_advance_EMI__c.value != undefined)
                this.advanceEmi = data.fields.Number_of_advance_EMI__c.value;

            if (data.fields.LTV_PCAC__c.value != null && data.fields.LTV_PCAC__c.value != undefined)
                this.lTVScore = data.fields.LTV_PCAC__c.value;
            if (data.fields.DBR_PC_AC__c.value != null && data.fields.DBR_PC_AC__c.value != undefined)
                this.DBRScore = data.fields.DBR_PC_AC__c.value;
            if (data.fields.Living_style__c.value != null && data.fields.Living_style__c.value != undefined)
                this.livingStyleScore = data.fields.Living_style__c.value;
            if (data.fields.Neighbour_feedback__c.value != null && data.fields.Neighbour_feedback__c.value != undefined)
                this.neighbourFeedBackScore = data.fields.Neighbour_feedback__c.value;
            if (data.fields.Risk_Document__c.value != null && data.fields.Risk_Document__c.value != undefined)
                this.riskdoc = data.fields.Risk_Document__c.value;
            if (data.fields.Borrower_s_Risk_Rating__c.value != null && data.fields.Borrower_s_Risk_Rating__c.value != undefined)
                this.brRating = data.fields.Borrower_s_Risk_Rating__c.value;
            else
                this.brRating = undefined;
            if (data.fields.NACH_Party_1_ID__c.value != null && data.fields.NACH_Party_1_ID__c.value != undefined)
                this.nachpartyId1 = data.fields.NACH_Party_1_ID__c.value;
            if (data.fields.NACH_Party_2_ID__c.value != null && data.fields.NACH_Party_2_ID__c.value != undefined)
                this.nachpartyId2 = data.fields.NACH_Party_2_ID__c.value;
            if (data.fields.Staff_Loan__c.value != null && data.fields.Staff_Loan__c.value != undefined) {
                if (data.fields.Staff_Loan__c.value == true)
                    this.loanTypeValue = '5S employee';
                else if (data.fields.Staff_Loan__c.value == false)
                    this.loanTypeValue = 'Normal';
            }
            if (data.fields.Effective_IRR__c.value != null && data.fields.Effective_IRR__c.value != undefined) {
                this.iseffIrrDisabled = true;
            }
            if (data.fields.Disbursement_party_Id__c.value != null && data.fields.Disbursement_party_Id__c.value != undefined) {
                this.disbursementpartyId = data.fields.Disbursement_party_Id__c.value;
            }
            if (data.fields.Disbursement_party__c.value != null && data.fields.Disbursement_party__c.value != undefined) {
                if (data.fields.Disbursement_party__c.value == 'Disbursement Party Name') {
                    this.showdisbursement = true;
                    this.showThirdPartyName = false;
                }
                else if (data.fields.Disbursement_party__c.value == 'Third Party') {
                    this.showdisbursement = false;
                    this.showThirdPartyName = true;
                }
            }

            if (data.fields.Total_Amount_Recommended_PcAc__c.value != null && data.fields.Total_Amount_Recommended_PcAc__c.value != null)
                this.totalamountValue = data.fields.Total_Amount_Recommended_PcAc__c.value;

            if (data.fields.Final_Tranche_1_Loan_Amount__c.value != null && data.fields.Final_Tranche_1_Loan_Amount__c.value != null)
                this.totaltranche1amountValue = data.fields.Final_Tranche_1_Loan_Amount__c.value;

            if (data.fields.Principal_O_S__c.value != null && data.fields.Principal_O_S__c.value != null)
                this.principalOs = data.fields.Principal_O_S__c.value;

            if (data.fields.Loan_Amount__c.value != null && data.fields.Loan_Amount__c.value != null)
                this.oldloanAmount = data.fields.Loan_Amount__c.value;

            if (data.fields.Group_Total_Exposure_PcAc__c.value != null && data.fields.Group_Total_Exposure_PcAc__c.value != null)
                this.groupTotalExposure = data.fields.Group_Total_Exposure_PcAc__c.value;

            console.log('totalamountValue value', this.totalamountValue);
            console.log('amountrecomended in wire', this.amountrecomended, 'Tranche Amount in Wire', this.amountrecomended, 'insurance premium value', this.insuranceamount);

            if (this.amountrecomended && this.insuranceamount)
                this.totalamountValue = (this.amountrecomended ? this.amountrecomended : 0) + (Math.ceil(this.insuranceamount / 10000) * 10000);

            if (this.tranche1 && this.insuranceamounttranche1)
                this.totaltranche1amountValue = (this.tranche1 ? this.tranche1 : 0) + (Math.ceil(this.insuranceamounttranche1 / 10000) * 10000);


            console.log('roi value', this.roiRate);
            console.log('combinedLTV value', this.combinedLTV);
            console.log('nach party 1', this.nachpartyId1);
            console.log('nach party 2', this.nachpartyId2);
            console.log('disbursement party id', this.disbursementpartyId);
            console.log('this.customer options in wire', this.customerOptions);
        }
        else if (error) {
            this.error = error;
            console.log('error n wire ', error);
        }
    }


    handleEffectiveIrr() {
        geteffectiveIrr({ appId: this.applicationId, Tenure: parseInt(this.tenorValue), loanType: this.loanTypeValue, numofEmi: this.advanceEmi, riskDocument: this.riskdoc, recordTypeName: this.sectiontitle })
            .then(result => {
                console.log('eff Irr', result);
                if (result) {
                    this.effIrr = (result.EffIrr != null ? result.EffIrr : null);
                    this.roiRate = (result.Rate != null ? result.Rate : null);
                    this.totalROI = this.roiRate - this.marginROI;
                }
                const selectedEvent1 = new CustomEvent("handletabvaluechange", {
                    detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'Customer_Communicated__c', fieldvalue: this.roiRate, recordId: this.applicationId }
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent1);
                const selectedEvent2 = new CustomEvent("handletabvaluechange", {
                    detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'Effective_IRR__c', fieldvalue: this.effIrr, recordId: this.applicationId }
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent2);
            })
            .catch(err => {
                console.log('erro', err);
            })
    }

    refreshData() {
        refreshApex(this._refreshdata);
    }



    connectedCallback() {
        this.financialSpinner = true;
        this.handlegetIncomeSummary('');
        console.log('this.applicationId', this.applicationId);
        //if (this.recordTypeName == '3. Top-up loan' || this.recordTypeName == '4. Tranche loan' || this.recordTypeName == '1. New loan') {
        (async () => {
            try {
                await generateTopupDetails({ applicationId: this.applicationId });
                if (this.recordTypeName == '3. Top-up loan' || this.recordTypeName == '4. Tranche loan')
                    await handleTrancheApplication({ appId: this.applicationId });
                console.log('Topup and Tranche Case Handled Successfully');
            } catch (error) {
                console.log('Error in Topup and Tranche Case Handled Successfully', error);
            } finally {
                this.getAllApplicants();
                this.topUpSection = true;
                this.financialSpinner = false;
            }
        })();
        // }
        // else {
        //     this.topUpSection = false;
        //     this.financialSpinner = false;
        // }

    }


    // Method used to Calculate the Borrower's Risk Rating
    GetborrowerRiskRating(ltv, dbr, hm, livingStyle, NeighburFeedBack) {

        console.log('LTV ##', ltv, 'DBR ##', dbr, 'HM ##', hm, 'LIvingStyle ##', livingStyle, 'NeighbourFeedBack ##', NeighburFeedBack);
        let borrowerRiskRating;
        let ScoreOBj = new Object();
        if (ltv != null) { ScoreOBj.ltvScore = ((ltv <= 50) ? 'Low' : ((ltv > 50 && ltv <= 60) ? 'Medium' : ((ltv > 60) ? 'High' : undefined))); }
        if (dbr != null) { ScoreOBj.dbrScore = ((dbr <= 45) ? 'Low' : ((dbr > 45 && dbr <= 65) ? 'Medium' : ((dbr > 65) ? 'High' : undefined))); }
        if (hm != null) { ScoreOBj.hmScore = ((hm < 350 && hm >= 300) ? 'High' : ((hm >= 350 && hm <= 500) ? 'Medium' : ((hm > 500 || isNaN(hm) || hm < 300) ? 'Low' : undefined))); }
        if (livingStyle != null) { ScoreOBj.livingStyleScore = (livingStyle == 'Good' ? 'Low' : (livingStyle == 'Average' ? 'Medium' : (livingStyle == 'Below Average' ? 'High' : undefined))); }
        if (NeighburFeedBack != null) { ScoreOBj.neighbourFeedBackScore = (NeighburFeedBack == 'Positive' ? 'Low' : (NeighburFeedBack == 'Neutral' ? 'Medium' : (NeighburFeedBack == 'Negative' ? 'High' : undefined))); }


        // if ((isNaN(hm) || hm < 300) && hm != null)
        //     borrowerRiskRating = 'Low';
        // else {
        let countMap = new Map();
        for (let keyValue of Object.keys(ScoreOBj)) {
            if (!countMap.has(ScoreOBj[keyValue]))
                countMap.set(ScoreOBj[keyValue], 1);
            else
                countMap.set(ScoreOBj[keyValue], countMap.get(ScoreOBj[keyValue]) + 1);
        }
        if (countMap.size) {
            console.log('hello count Map $$$', countMap);
            if (countMap.has('Low') && countMap.get('Low') >= 3)
                borrowerRiskRating = 'Low';
            else if (countMap.has('Medium') && countMap.get('Medium') >= 3)
                borrowerRiskRating = 'Medium';
            else if (countMap.has('High') && countMap.get('High') >= 3)
                borrowerRiskRating = 'High';
            else if (countMap.has('Low') && countMap.get('Low') == 2 && countMap.has('Medium') && countMap.get('Medium') == 2 && countMap.has('High') && countMap.get('High') == 1)
                borrowerRiskRating = 'Medium';
            else if (countMap.has('High') && countMap.get('High') == 2 && countMap.has('Medium') && countMap.get('Medium') == 2 && countMap.has('Low') && countMap.get('Low') == 1)
                borrowerRiskRating = 'High';
            else if (countMap.has('Low') && countMap.get('Low') == 2 && countMap.has('High') && countMap.get('High') == 2 && countMap.has('Medium') && countMap.get('Medium') == 1)
                borrowerRiskRating = 'High';
        }
        //}
        console.log('borrowerRiskRating ###', borrowerRiskRating)
        return borrowerRiskRating;

    }





    handleTabActivation(event) {
        console.log('handleTabActivation= ', event.target.value);
        this.tabName = event.target.value;
        this.dispatchEvent(new CustomEvent('tabchange', { detail: event.target.value }));
        this.isTopupDetails = false;
        this.isCollateraldetails = false;
        this.isOldloandetails = false;
        this.isApplicationdetails = false;
        this.isLoandetails = false;
        this.isInsuranceparty = false;
        this.isDisbursementdetail = false;
        this.isLoanAmount = false;
        this.isEligibilityCalculations = false;
        this.isRiskRating = false;
        this.isOthers = false;
        this.isExecutiveSummary = false;

        if (event.target.value == 'Topup_Details') {
            this.isTopupDetails = true;
        } else if (event.target.value == 'Collateral details') {
            this.isCollateraldetails = true;
        } else if (event.target.value == 'Old loan details') {
            this.isOldloandetails = true;
        } else if (event.target.value == 'Application_details') {
            this.financialSpinner = true;
            this.handlegetIncomeSummary('Application Details');
            this.isApplicationdetails = true;
        } else if (event.target.value == 'Loan details') {
            this.isLoandetails = true;
            console.log('tenor Value', this.tenorValue, 'loan type value', this.loanTypeValue, 'advance emi', this.advanceEmi, 'sectionTitle', this.sectiontitle);
            this.handleEffectiveIrr();
            getData({ CustomerId: this.applicationId, ObjName: 'Financial' })
                .then(result => {
                    console.log('ROI result>>>>' + result[0]);
                    let res = JSON.parse(JSON.stringify(result));
                    console.log('ROI result>>>>' + JSON.stringify(res[0]));
                    if (res.length > 0) {
                        if (!this.hasRoiValue)
                            this.roiRate = res[0].ROI__c;
                        if (!this.hasTenorValue)
                            this.tenorValue = res[0].Tenor__C;
                    }
                })
                .catch(error => {
                    console.log('errror in ROI', error);
                });



        } else if (event.target.value == 'Tranche') {
            this.financialSpinner = true;
            if (!this.netIncomePresent)
                this.totalIncome = this.incomeSummaryObj.totalMonthlyIncome;
            if (!this.finalcolPresent && (this.propertySummary.collateralGrandValue != undefined || this.propertySummary.collateralGrandValue != null)) {
                console.log('inside this');
                this.finalCollateralValue = this.propertySummary.collateralGrandValue;
            }
            console.log(parseFloat(this.tranche1), '<><><>', parseFloat(this.tranche2), '<><>', parseFloat(this.tenorValue), '<><>', this.roiRate);
            if (this.tranche2 && this.roiRate && this.tenorValue) { this.emiTrancheValue = Math.ceil((parseFloat(this.tranche2) * parseFloat(this.roiRate / 1200)) * ((Math.pow((1 + parseFloat(this.roiRate / 1200)), parseFloat(this.tenorValue)) / (Math.pow((1 + parseFloat(this.roiRate / 1200)), parseFloat(this.tenorValue)) - 1)))); }
            console.log('emi tranche 2 value', this.emiTrancheValue);
            if (this.tranch1)
                this.totaltranche1amountValue = (this.tranche1 ? this.tranche1 : 0) + (Math.ceil(this.insuranceamounttranche1 / 10000) * 10000);
            this.financialSpinner = false;
            console.log('roi value ', this.roiRate, ' Tenor >>>> ');
        } else if (event.target.value == 'Insurance party') {
            this.isInsuranceparty = true;
        } else if (event.target.value == 'Disbursement/Repayment detail') {
            this.isDisbursementdetail = true;
        }
        else if (event.target.value == 'Loan Amount') {
            this.isLoanAmount = true;
            console.log('this.amountrecomended in loan amount', this.amountrecomended, 'TrancheAmt %%', this.amountrecomended, 'insuranceamount %%', this.insuranceamount);
            if (this.amountrecomended)
                this.totalamountValue = (this.amountrecomended ? parseFloat(this.amountrecomended) : 0) + Math.ceil(this.insuranceamount / 10000) * 10000;

            console.log('totalamountValue in loan amount', this.totalamountValue);
            if (this.propertySummary.collateralGrandValue != null && this.propertySummary.collateralGrandValue != '' && this.propertySummary.collateralGrandValue != undefined) { this.grpValuation = this.propertySummary.collateralGrandValue; }

        } else if (event.target.value == 'Eligibility Calculations') {
            console.log('Eligibility Calculations>>> ', this.isEligibilityCalculations);
            this.financialSpinner = true;
            this.handlegetIncomeSummary('Eligibility Calculations');
            this.isEligibilityCalculations = true;
            console.log('Eligibility Calculations>>> ', this.isEligibilityCalculations);
        } else if (event.target.value == 'Risk Rating') {
            this.isRiskRating = true;
        } else if (event.target.value == 'Others') {
            this.isOthers = true;
        } else if (event.target.value == 'Executive Summary') {
            this.isExecutiveSummary = true;
        }
    }


    handlegetIncomeSummary(stage) {
        let capType, verfType;
        if (this.sectiontitle == 'PC') {
            capType = 'PC Capability';
            verfType = 'PC';
        }
        else if (this.sectiontitle == 'AC') {
            capType = 'AC Capability';
            verfType = 'AC';
        }
        getIncomeSummary({ applicationId: this.applicationId, caprecordtypeName: capType, VerfRecordTypeName: verfType }).then((result) => {
            console.log('handleGetIncomeSummary= ', result);
            this.incomeSummaryObj = JSON.parse(JSON.stringify(result));
            if (stage == 'Application Details') {
                if (this.recordTypeName == '3. Top-up loan') {
                    this.isTopupDetails = true;
                    // let value = this.considerforTopupvalue;
                    // console.log('conisder>>>> ', value);

                    // if (value == 'Yes') {
                    //     this.customerType = 'Existing';
                    //     //this.loanType = 'topup related scheme';
                    // }
                    // else if (value == 'No') {
                    //     this.customerType = 'Repeat';
                    // }
                }
                // else {
                //     this.customerType = 'New';
                // }
            }
            else if (stage == 'Eligibility Calculations') {
                if (this.incomeSummaryObj) {
                    if (this.incomeSummaryObj.netMonthlyIncome != null && this.incomeSummaryObj.netMonthlyIncome != undefined && this.incomeSummaryObj.netMonthlyIncome != '')
                        this.netIncome = this.incomeSummaryObj.netMonthlyIncome;
                    if (this.propertySummary.collateralGrandValue != null && this.propertySummary.collateralGrandValue != undefined && this.propertySummary.collateralGrandValue != '')
                        this.collateralValue = this.propertySummary.collateralGrandValue;
                    if (this.showEmi) {
                        if (this.incomeSummaryObj.netMonthlyIncome != null && this.incomeSummaryObj.netMonthlyIncome != undefined && this.incomeSummaryObj.netMonthlyIncome != '')
                            this.tranchenetIncome = this.incomeSummaryObj.netMonthlyIncome;
                        if (this.propertySummary.collateralGrandValue != null && this.propertySummary.collateralGrandValue != undefined && this.propertySummary.collateralGrandValue != '')
                            this.tranchecollateralValue = this.propertySummary.collateralGrandValue;
                    }
                }
            }
            this.financialSpinner = false;
        }).catch((err) => { 
            console.log('Error in handleGetIncomeSummary= ', err);
            this.financialSpinner = false;
        });
    }

    checkInputValidity() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    }

    handleInsuranceSubmit(event) {
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log('ALL VALID for Insurance %%%', allValid);
        console.log('application submit called', event.target.id);
        if (!allValid) {
            event.preventDefault();
        }

    }


    handleApplicationSubmit(event) {
        let isValid = this.checkInputValidity();
        if (!isValid) {
            event.preventDefault();
        }
        console.log('application submit called', this.applicationId, event.detail);

        if (this.isTrancheI || this.isTrancheII)
            this.UpdateNormalCase(this.applicationId);
        // console.log('Tranche Error Found', this.trancheError);
        // if (this.trancheError && this.isTrancheII) {
        //     event.preventDefault();
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: '',
        //             variant: 'error',
        //             message: 'Total Tranche Amount should be Equal to Sanctioned Loan Amount'
        //         })
        //     );
        // }

        if (this.isDisbursementdetail) {
            const allValid = [
                ...this.template.querySelectorAll('lightning-combobox'),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (!allValid) {
                event.preventDefault();
            }
            else {
                console.log('application submit called', this.applicationId);
            }

        }


    }

    handleApplicationSuccess(event) {
        console.log('handle success called' + event.detail);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Sucess',
                variant: 'success',
                message: 'Record Saved Successfully'
            })
        );
        const removeEvent = new CustomEvent("handletabvalueremove", {
            detail: { tabname: 'Collateral', subtabname: '' }
        });
        this.dispatchEvent(removeEvent);
        if (this.isInsuranceparty)
            this.handleInsuranceFieldsUpdation();
        const validationEvent = new CustomEvent('checkfinancialvalidation', {
            detail: true
        });
        this.dispatchEvent(validationEvent);

    }

    handleInsuranceFieldsUpdation() {
        setInsuranceFields({ applicationId: this.applicationId })
            .then(result => {
                console.log('Insurance Object Fields Updated Successfully', result);
            })
            .catch(err => {
                console.log('err in updating insurance Fields', err);
            })
    }

    // Added on 09.05.23

    getMaxIncome() {
        let capType;
        if (this.sectiontitle == 'PC') {
            capType = 'PC Capability';
        }
        else if (this.sectiontitle == 'AC') {
            capType = 'AC Capability';
        }
        //this.incomeMap = new Map();
        getCapabilityIncomeSummary({ applicationId: this.applicationId, recordTypeName: capType }).then((result) => {
            console.log('Capabilty Monthly Income ###', result);
            if (result) {
                this.incomeMap = result;
                console.log('Income Map',this.incomeMap);
                let highestKey;
                let secondHighestKey;
                for (let key in result) {
                    let value = result[key];
                    if (!highestKey || value > result[highestKey]) {
                        secondHighestKey = highestKey;
                        highestKey = key;
                    } 
                }
                for (let key in result) {
                    let value = result[key];
                    if ((!secondHighestKey && result[highestKey] > value ) || ((value > result[secondHighestKey]) && result[highestKey] > value)) {
                        secondHighestKey = key;
                        console.log('### secondHighestKey Key = ',secondHighestKey);
                    }
                }
                console.log('HighestKey ####',this.incomeMap[highestKey]);
                console.log('secondHighestKey ####',this.incomeMap[secondHighestKey]);
                let [segment1, subSegment1] = highestKey && highestKey.includes('-') ? highestKey.split('-') : [highestKey, ''];
                let [segment2, subSegment2] = secondHighestKey && secondHighestKey.includes('-') ? secondHighestKey.split('-') : [secondHighestKey, ''];
                this.maxSegmentIncome = segment1;
                this.maxSubSegmentIncome = subSegment1;
                this.secondMaxSegmentIncome = segment2;
                this.secondMaxSubSegmentIncome = subSegment2;
            }
            else {
                console.error('Invalid data structure in the result:', result);
            }
        })
            .catch((error) => {
                console.error('Error in getCapabilityIncomeSummary:', error);
            });
    }

    handleSelectedEMPId(event){
        console.log('fieldOfficerEMPId ',event);
         if (event.detail.length > 0) {
            this.fieldOfficerEMPId = event.detail[0].id;
        } else {
            this.fieldOfficerEMPId = undefined;
        }
        console.log('fieldOfficerEMPId ',this.fieldOfficerEMPId);
    }

    handleChange(evt) {
        console.log('handleFormValue= ', evt.target.value);
        console.log('handleFormValue= ', evt.target);
        console.log('handleFormValue= ', evt.target.fieldName);
        let fName = evt.target.fieldName ? evt.target.fieldName : evt.target.name;
        let fValue = evt.target.value;

        if (evt.target.fieldName == 'Nominee__c') {
            if (evt.target.value == 'No') {
                this.nomineeValue = '';
                this.nomineePersonName = '';
                this.shownominee = true;
                this.fakeNominee = false;
                console.log('nominee data from No>>> ', this.nomineedata);
            }
            else if (evt.target.value == 'Yes') {
                this.shownominee = false;
                this.fakeNominee = true;
                console.log('nominee data from yes>>> ', this.nomineedata);
            }
            else {
                this.shownominee = false;
                this.fakeNominee = false;
            }
        }
        else if (evt.target.fieldName == 'Balance_Transfer__c') {
            if (evt.target.value == 'No')
                this.balanceTransferAmountShow = false;
            else
                this.balanceTransferAmountShow = true;
        }
        else if (evt.target.name == 'Balance_Transfer_Amount__c') {
            this.btAmount = evt.target.value;
        }
        else if (evt.target.fieldName == 'Risk_Document__c') {
            this.riskdoc = evt.target.value;
        }
        else if (evt.target.fieldName == 'Margin_ROI__c') {
            this.marginROI = evt.target.value;
        }
        else if (evt.target.name == 'HM__c') {
            this.HMScore = evt.target.value;
        }
        else if (evt.target.fieldName == 'Considered_for__c') {
            this.considerforTopupvalue = evt.target.value;
        }
        else if (evt.target.fieldName == 'Customer_Communicated__c') {
            this.roiRate = evt.target.value;
        }
        else if (evt.target.name == 'Total_net_income_after_2nd_tranche__c') {
            this.totalIncome = evt.target.value;
            if ((evt.target.value != null && evt.target.value != '') && this.totalIncome != null) {
                if (evt.target.value != this.totalIncome) {
                    this.netIncomeRemarks = true;
                }
            }

        }

        else if (evt.target.name == 'Final_Collateral_value_for_Tranche_2__c') {
            console.log('hello col');
            this.finalCollateralValue = evt.target.value;
            if ((evt.target.value != null && evt.target.value != '') && this.finalCollateralValue != null) {
                if (evt.target.value != this.finalCollateralValue) {
                    console.log('hello col');
                    this.colRequired = true;
                }
            }

        }

        else if (evt.target.name == 'Tranche_1__c') {
            this.tranche1 = parseFloat(this.template.querySelector('[data-id="t1"]').value) !== undefined ? parseFloat(this.template.querySelector('[data-id="t1"]').value) : 0;
            if (this.isTrancheI)
                this.amountrecomended = this.tranche1;


        }
        else if (evt.target.name == 'Tranche_2__c') {
            this.tranche2 = parseFloat(this.template.querySelector('[data-id="t2"]').value) !== undefined ? parseFloat(this.template.querySelector('[data-id="t2"]').value) : 0;
            if (this.isTrancheII)
                this.amountrecomended = this.tranche2;
        }
        else if (evt.target.fieldName == 'Tenor_In_Months__c') {
            this.tenorValue = evt.target.value;
        }
        else if (evt.target.name == 'Guarantor_Networth_Choosen__c') {
            this.gNetworth = evt.target.value;
        }
        else if (evt.target.name == 'Amount_Recommended__c') {
            this.amountrecomended = (evt.target.value != null ? evt.target.value : 0);
        }
        else if (evt.target.fieldName == 'Nominee_Relationship_Type__c') {
            this.relationshipType = evt.target.value;
        }
        else if (evt.target.name == 'Insurance_Requirement__c') {
            this.insurancereq = evt.target.value;
        }
        else if (evt.target.name == 'Insurance_Medical_Test_Result__c') {
            this.insurancemedicalValue = evt.target.value;
        }

        //Added on 16.05.23
        else if (evt.target.fieldName == 'Supervisor_recommendation__c') {
            this.supervisorRec = evt.target.value;
        }
        else if (evt.target.name == 'Tranche_Disbursal__c') {
            this.trancheDisb = evt.target.value;
            if (evt.target.value == 'I') {
                this.isTranche = true;
                this.isTrancheI = true;
                //this.netIncomeLabel = 'Total net income after Ist tranche(₹)';
                //this.colValueLabel = 'Final Collateral value for Tranche 1';
                this.showEmi = false;
                this.isTrancheII = false;
                this.amountDisabled = true;
            }
            else if (evt.target.value == 'II') {
                this.isTranche = true;
                this.isTrancheII = true;
                this.totalTranche = null;
                //this.netIncomeLabel = 'Total net income after 2nd tranche(₹)';
                //this.colValueLabel = 'Final Collateral value for Tranche 2';
                this.showEmi = true;
                this.isTrancheI = false;
                this.amountDisabled = false;
            }
            else {
                this.isTranche = false;
                this.isTrancheI = false;
                this.isTrancheII = false;
                this.tranch1 = undefined;
                this.tranche2 = undefined;
                this.amountDisabled = false;
            }

        }
        else if (evt.target.name == 'Nominee_Party__c') {
            this.nomineeValue = evt.target.value;
            this.nomineePersonName = evt.target.value;
            if (this.isInsuranceparty) {
                this.handleInsuranceValidation();
            }
        }
        else if (evt.target.name == 'Nominee_Party_Relationship_with_Insured__c') {
            this.relationshipValue = evt.target.value;
        }
        else if (evt.target.fieldName == 'Number_of_advance_EMI__c') {
            this.advanceEmi = evt.target.value;
            if (evt.target.value != '1') {
                this.showModal = true;
            }
        }

        console.log('amt recommended', this.amountrecomended, 'insurance amt >>>>>', this.insuranceamount);
        if (this.amountrecomended)
            this.totalamountValue = (this.amountrecomended ? parseFloat(this.amountrecomended) : 0) + Math.ceil(this.insuranceamount / 10000) * 10000;

        if (this.tranch1)
            this.totaltranche1amountValue = (this.tranche1 ? this.tranche1 : 0) + (Math.ceil(this.insuranceamounttranche1 / 10000) * 10000);


        if (this.tranche1 || this.tranche2)
            this.totalTranche = (this.finaltranche1 ? parseFloat(this.finaltranche1) : 0) + (this.tranche2 ? parseFloat(this.tranche2) : 0);

        if (this.tranche2 && this.roiRate && this.tenorValue) { this.emiTrancheValue = Math.ceil((parseFloat(this.tranche2) * parseFloat(this.roiRate / 1200)) * ((Math.pow((1 + parseFloat(this.roiRate / 1200)), parseFloat(this.tenorValue)) / (Math.pow((1 + parseFloat(this.roiRate / 1200)), parseFloat(this.tenorValue)) - 1)))); }
        console.log('emi tranche value in handle3 change', this.emiTrancheValue);

        if (this.considerforTopupvalue == 'Yes' && this.topUpSection) {
            this.groupTotalExposure = (this.principalOs != undefined ? this.principalOs : 0) + (this.totalamountValue ? this.totalamountValue : 0);
            console.log('groupTotalExposure value in wire 1', this.groupTotalExposure);
        }
        else if (this.isTrancheI) {
            this.groupTotalExposure = (this.tranche2 != undefined ? this.tranche2 : 0) + (this.considerforTopupvalue == 'Yes' ? (this.principalOs != undefined ? this.principalOs : 0) : 0) + (this.totalamountValue ? this.totalamountValue : 0);
            console.log('groupTotalExposure value in wire 2', this.groupTotalExposure);
        }
        else if (this.isTrancheII) {
            this.groupTotalExposure = (this.finaltranche1 != undefined ? this.finaltranche1 : 0) + (this.considerforTopupvalue == 'Yes' ? (this.principalOs != undefined ? this.principalOs : 0) : 0) + (this.totalamountValue ? this.totalamountValue : 0);
            console.log('groupTotalExposure value in wire 3', this.groupTotalExposure);
        }
        else {
            this.groupTotalExposure = (this.totalamountValue ? this.totalamountValue : 0);
            console.log('groupTotalExposure value in wire 4', this.groupTotalExposure);
        }
        console.log('Group Total Exposure ###', this.groupTotalExposure);

        if (this.lTVScore && this.DBRScore && this.HMScore && this.livingStyleScore && this.neighbourFeedBackScore && this.isRiskRating);
        {
            this.brRating = this.GetborrowerRiskRating(this.lTVScore, this.DBRScore, this.HMScore, this.livingStyleScore, this.neighbourFeedBackScore);
            console.log('B Rating', this.brRating);
        }
        console.log('IN chnage tenor Value', this.tenorValue, 'loan type value', this.loanTypeValue, 'advance emi', this.advanceEmi, 'risk doc', this.riskdoc);
        if (this.isLoandetails) {
            this.handleEffectiveIrr();
        }

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Financial', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: this.applicationId }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }


    handleCustomerSelection(event) {
        console.log('handleFormValue= ', event.target.value);
        console.log('handleFormValue= ', event.target);
        console.log('handleFormValue= ', event.target.name);
        let fName = event.target.fieldName ? event.target.fieldName : event.target.name;
        let fValue = event.target.value;
        if (event.target.name == 'Name__c') {
            this.insuredName = event.detail.value;
            this.insuredPersonName = event.detail.value.split('_')[0];
            this.insurePersonId = event.detail.value.split('_')[1];
        }
        else if (event.target.name == 'Nominee_Party__c') {
            if (event.target.dataset.type === 'combobox') {
                this.nomineeValue = event.detail.value;
                this.nomineePersonName = event.detail.value.split('_')[0];
                this.nomineePersonId = event.detail.value.split('_')[1];
            }
            else {
                this.nomineePersonName = event.detail.value;
                this.nomineePersonId = null;
            }
        }
        else if (event.target.name == 'Nach_Party__c') {
            console.log('hello nach');
            this.nachpartyvalue = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.nachpartyId1 = event.target.value;
            const selectedEventN = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'Nach_Party__c', fieldvalue: this.nachpartyvalue, recordId: this.applicationId }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEventN);
            const selectedEvent1 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'NACH_Party_1_ID__c', fieldvalue: this.nachpartyId1, recordId: this.applicationId }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent1);

        }
        else if (event.target.name == 'Nach_Party_2__c') {
            console.log('hello nach2');
            this.nachpartyvalue2 = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.nachpartyId2 = event.target.value;
            const selectedEventN2 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'Nach_Party_2__c', fieldvalue: this.nachpartyvalue2, recordId: this.applicationId }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEventN2);
            const selectedEvent2 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'NACH_Party_2_ID__c', fieldvalue: this.nachpartyId2, recordId: this.applicationId }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent2);
        }
        else if (event.target.fieldName == 'Disbursement_party__c') {
            console.log('hello disbursement');
            if (event.target.value == 'Disbursement Party Name') {
                this.showdisbursement = true;
                this.showThirdPartyName = false;
            }
            else if (event.target.value == 'Third Party') {
                this.showdisbursement = false;
                this.showThirdPartyName = true;
            }
            console.log('show disbursement', this.showdisbursement, 'show third party name', this.showThirdPartyName);
        }
        else if (event.target.name == 'Disbursement_Party_Name__c') {
            this.disbursementpartyvalue = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.disbursementpartyId = event.target.value;
            const selectedEventD = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'Disbursement_Party_Name__c', fieldvalue: this.disbursementpartyvalue, recordId: this.applicationId }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEventD);
            const selectedEvent3 = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Financial', subtabname: '', fieldapiname: 'Disbursement_party_Id__c', fieldvalue: this.disbursementpartyId, recordId: this.applicationId }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent3);
        }
        // check Validation for Nach 1 and Nach 2 
        if (this.isDisbursementdetail) {
            let ref1 = this.template.querySelector('.nach1');
            if (this.nachpartyId1 == this.nachpartyId2) {
                ref1.setCustomValidity('Nach Party 1 and Nach party 2 Can not be same');
            }
            else {
                ref1.setCustomValidity('');
            }
            ref1.reportValidity();

            let ref2 = this.template.querySelector('.nach2');
            if (this.nachpartyId1 == this.nachpartyId2) {
                ref2.setCustomValidity('Nach Party 1 and Nach party 2 Can not be same');
            }
            else {
                ref2.setCustomValidity('');
            }
            ref2.reportValidity();
        }

        else if (this.isInsuranceparty) {
            this.handleInsuranceValidation();
        }

        const selectedEvent = new CustomEvent("handletabvaluechange", {
            detail: { tabname: 'Financial', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: this.applicationId }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        ///////////////////////////////////////////
        console.log(this.nachpartyvalue + '>>>>>>' + this.nachpartyvalue2 + '<<<<<<>>>>>>>>' + this.disbursementpartyvalue);
        console.log(this.customerValue);
        console.log(this.nomineedata);
    }


    handleInsuranceValidation() {
        console.log('insurance party insured name', this.insuredName, 'Nominee value', this.nomineeValue);
        console.log('Relationship Value ###', this.relationship);
        let ref1 = this.template.querySelector('.insurance');
        if (this.insuredName && this.nomineeValue && this.nomineeValue != '') {
            if ((this.nomineeValue.includes('_') && this.insuredName.split('_')[0] == this.nomineeValue.split('_')[0]) || this.insuredName.split('_')[0] == this.nomineeValue) {
                ref1.setCustomValidity('Name of Insured and Nominee party Can not be same');
            }
            else {
                ref1.setCustomValidity('');
            }
            ref1.reportValidity();


            let ref2 = this.template.querySelector(this.fakeNominee ? '.fakeNominee' : '.shownominee');
            if ((this.nomineeValue.includes('_') && this.insuredName.split('_')[0] == this.nomineeValue.split('_')[0]) || this.insuredName.split('_')[0] == this.nomineeValue) {
                ref2.setCustomValidity('Name of Insured and Nominee party Can not be same');
            }
            else {
                ref2.setCustomValidity('');
            }
            ref2.reportValidity();
        }
    }

    handleTopupSuccess(event) {
        console.log('Topup Success called', event.target.value);
        console.log(event.detail.value);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Sucess',
                variant: 'success',
                message: 'Record Saved Successfully'
            })
        );

    }






    // this method is used to Update the Tranche Disbursal Values
    UpdateNormalCase(recordId) {
        if (recordId) {
            const fields = {};
            fields[ID_FIELD.fieldApiName] = recordId;
            fields[Amount_Recommended.fieldApiName] = this.amountrecomended;
            //fields[INSURANCE_PREMIUM.fieldApiName] = this.insuranceamount;
            const recordInput = { fields };
            console.log('recordInput= ', recordInput);
            updateRecord(recordInput).then(() => {
                console.log('UPDATE DONE');
            }).catch(error => {
                console.log('Error in Loan Applicant Update = ', error);
            });
        }
    }

    // to get all applicant names of Application
    getAllApplicants() {
        getAccounts({ appId: this.applicationId }).then(result => {
            let data = [];
            //let isTopupDetailsGenerated = false;
            result.forEach(app => {
                //isTopupDetailsGenerated = app.Application__r.IsTopupDetailsGenerated__c;
                data.push({ label: app.Customer_Information__r.Name, value: app.Customer_Information__r.Name + '_' + app.Id });
            });
            //console.log('IsTopupDetailsGenerated__c ##',isTopupDetailsGenerated);
            //this.topUpSection = (!['3. Top-up loan' ,'4. Tranche loan'].includes(this.recordTypeName))? isTopupDetailsGenerated : true;
            this.nomineeOptions = data;
        })
            .catch(error => {
                console.log('error in getting all Applicants', error);
            });
    }

}