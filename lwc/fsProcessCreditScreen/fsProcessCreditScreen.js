import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { populateData, removeData, checkValidationPCAC, pc_data_template } from 'c/fsGenericDataSave';

/************************* ALL CUSTOM FIELDS IMPORT STATEMENTS ************************/
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import STAGE_FIELD from '@salesforce/schema/Application__c.Stage__c';
import SUBMISSION_DATE_FIELD from '@salesforce/schema/Application__c.PC_Submission_Date__c';
import GROUP_VALUATION from '@salesforce/schema/Application__c.Group_Valuation__c';
import MORTGAGE_VALUE from '@salesforce/schema/Application__c.Mortgage_property_Collateral_Value__c';
import TOTAL_LAND_AREA from '@salesforce/schema/Application__c.AC_Total_Land_Area__c';
import TOTAL_BUILDING_AREA from '@salesforce/schema/Application__c.AC_Total_Building_Area__c';
import NET_INCOME from '@salesforce/schema/Application__c.Total_Net_Income__c';
import TOTAL_OBLIGATIONS from '@salesforce/schema/Application__c.AC_Total_Obligations__c';
import TOTAL_GROSS_INCOME from '@salesforce/schema/Application__c.AC_Gross_Income__c';
import LOAN_TYPE from '@salesforce/schema/Application__c.Loan_Type__c';
import SCHEME from '@salesforce/schema/Application__c.Scheme__c';


/************************* ALL CLASS METHODS IMPORT STATEMENTS ************************/
import getAccounts from '@salesforce/apex/fsPcAcController.getAccounts';
import getCharacterTabRecords from '@salesforce/apex/FIV_C_Controller.getCharacterTabRecords';
import getData from '@salesforce/apex/fsPcAcController.getData';
import getCollateralTableRecords from '@salesforce/apex/fsPcAcController.getCollateralTableRecords';
import getFloorTableRecords from '@salesforce/apex/fsPcAcController.getFloorTableRecords';
import getCapabiltyData from '@salesforce/apex/fsPcAcController.getCapabiltyData';
import checkPCValidation from '@salesforce/apex/fsPcAcController.checkPCValidation';
import checkPCACMobileValidation from '@salesforce/apex/fsPcAcController.checkPCACMobileValidation';
import getCapabilitySummary from '@salesforce/apex/fsPcAcController.getCapabilitySummary';
import ComparePropertyValues from '@salesforce/apex/fsPcAcController.ComparePropertyValues';
import cloneFloorDetails from '@salesforce/apex/fsPcAcController.cloneFloorDetails';
import GetCollateralSummary from '@salesforce/apex/fsPcAcController.getCollateralSummary';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import Business_Date from '@salesforce/label/c.Business_Date';
import gettotalBuildingValue from '@salesforce/apex/fsPcAcController.GetBuildingTotalValue';
import clonePropertyNew from '@salesforce/apex/FsPreloginController.clonePropertyNew';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId';
import handleFinish from '@salesforce/apex/fsPcAcController.handleFinish';
import savePdf from '@salesforce/apex/FS_DisbursalMemoController.saveDisbursalMemoPDF';
import getACUsers from '@salesforce/apex/fsPcAcController.getACUsers';
import checkInsuranceValidation from '@salesforce/apex/fsPcAcController.checkInsuranceValidation';
import getACCollateralTabRecords from '@salesforce/apex/fsPcAcController.getACCollateralTabRecords';
import generateCamReport from '@salesforce/apex/CAMReportVfController.generateCamReport';
import getFeeWithoutRepayment from '@salesforce/apex/FeeCreationComponentHelper.getFeeWithoutRepayment';
import getZeroFee from '@salesforce/apex/FeeCreationComponentHelper.getZeroFee';
import getCharacterTableRecords from '@salesforce/apex/fsPcAcController.getCharacterTabRecords';
import saveAllRecordsPCAC from '@salesforce/apex/FS_SaveAndSubmitController.saveAllRecordsPCAC';
import mailResponse from '@salesforce/apex/FS_LMS_CreateCustomerAPI.mailResponse';
// Added on 01.05.23 :
import checkBureauVerified from '@salesforce/apex/FsPreloginController.checkBureauVerification';
//Added on 15.05.23
import getHMScore from '@salesforce/apex/fsPcAcController.getHMScore';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';
export default class FsProcessCreditScreen extends NavigationMixin(LightningElement) {

    // buttons for add property/applicant and retrigger verifications
    @track btns = [
        {
            name: 'submit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'AddApplicant',
            label: 'Add/Modify Applicant',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'AddProperty',
            label: 'Add/Modify Property',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'InitiateRetrigger',
            label: 'Initiate Retrigger',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'OwnerValidation',
            label: 'Owner Validation',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'Generate_CAM_Report',
            label: 'Generate CAM Report',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        },
        {
            name: 'pendingReason',
            label: 'Pending Reason',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ];

    @track showPendingReason = false;
    @track applicanttobeCheck = false;
    @track propertytobeCheck = false;
    @track isAddApplicant = false;
    @track isAddProperty = false;
    @track initiateRetrigger = false;
    @track openOwnerValidation = false;
    @track loanApplicantList = [];
    @track ownerOptions = [];
    @track propIdList;
    @track newappIdList;
    @track hasPrimaryApplicant = false;
    @track hasPrimaryOwner = false;
    @track isMobileVerified = false;
    @track isKYCVerified = false;
    @track isIncomeConsidered = false;
    @track mobDefList;
    @track kycDefList;
    @track bureauPendingList;
    @track sourcingBranch;
    @track usersList;
    @track selectedACUser;
    @track requiredDocuments;
    @track decisionValue;
    @track isVerified = false;
    @track dedupeDetails;



    @api recordId;
    @track currentPageReference;
    @track applicationId;
    @track loginId;
    @track appName;
    @track showThis = true;
    @track businessDate = Business_Date;
    @track lastLoginDate;

    @track CustomerOptions = [];
    @track PCSubOptions = [];

    @track callOnce = false;
    @track showPCSubCombo1 = false;
    @track pcSpinner = false;

    @track PCCombo = true;
    @track PropertyCombo = false;
    @track CapibilityCombo = false;
    @track CharacterCombo = false;
    @track customerCombo = false;
    @track pcsubcombovalue;

    @track showCapability = false;
    @track IncomeSegmentValue;
    @track SubpcSelectedValue;
    @track segmentValue;
    @track subSegmentValue;
    @track CustomerName;
    @track dayorMarginBasis;


    //for Capability'
    @track capabilitypcTableData;
    @track isSalaried = false;
    @track isRentalMortgage = false;
    @track isRentalOther = false;
    @track isDailyWages = false;
    @track isPension = false;
    @track isTransportBusiness = false;
    @track isAbroadIncome = false;
    @track isOther = false;
    @track isSelfEmployedOrBusiness = false;
    @track isEateriesAndOthers = false;
    @track isDayBasis = false;
    @track isMarginBasis = false;
    @track capabilityRecordTypeId;
    @track capabilityTableData;
    @track capabilitySpinner = false;
    @track SecondcapabilitySpinner = false;
    @track loanAppId;
    @track IncomeSummary;
    @track capRelationshipId;
    @track Other_Confirmations;
    @track natureofdocumentProof;
    @track incomeProof;
    @track Other_Confirmations_Daily_Wages;
    @track natureOfOwnershipProof;
    @track proofRemarks;
    @track ownershipProof;
    @track ownershipproofEateries;
    @track fcEnquiry;
    @track fivcbusinesspincode;
    @track fivcincomepincode;
    @track grossMonthlyIncome;

    // for character
    @track isFamilyDetails = false;
    @track isNeighbour = false;
    @track isAffiliation = false;
    @track isLivingStandard = false;
    @track isRepaymentBehaviour = false;
    @track showCharacter = false;
    @track characterRecordTypeId;
    @track familyTableData;
    @track sectionType;
    @track showFivCCharacterTable = false;
    @track characterSpinner = false;
    @track loanAmount;
    @track dateTimeVal;
    @track charTableData;

    //
    @track propertyMarketValueMap;

    // for property
    @track collateralTable;
    @track preselectedRow = [];
    @track propertyDetailsData;
    @track landDetailsData;
    @track buildingDetailsData;
    @track builidngFloorDetails
    @track typeofProperty;
    @track showProperty = false;
    @track showPropertyForm = false;
    @track isGeneralDetails = false;
    @track isLandAreaAndValuation = false;
    @track isBuildingAreaAndValuation = false;
    @track isCollateralSummary = false;
    @track propertyRecordTypeId;
    @track propertyRecordId;
    @track isFIVBProperty = false;
    @track parentProperty;
    @track propertyTableData;
    @track propertySpinner;
    @track preloginproperty;
    @track propsubValue;
    @track pcfivcRelationId;
    @track fivcTitleDeedNumber;
    @track fivCAutoPopFields = {
        'mortgage_property_distance': '', 'mortagage_and_living_property': '', 'person_at_mortgage': '', 'living_property_distance': '',
        'living_pincode': '', 'is_living_is_own': ''
    };
    @track landAreaValues = { Land_Area: undefined, Market_Value: undefined, FinalLandValue: undefined };
    @track buildingAreaValues = { Building_Area: undefined, Building_Value: undefined, Total_Building_Value: undefined };
    @track totalBuildingValue;
    @track propertySummaryObj = {
        propertyList: undefined,
        buildingGrandValue: undefined,
        landGrandValue: undefined,
        collateralGrandValue: undefined
    };
    ////////////////////////////////

    // for financial
    @track isFinancial = false;
    @track finSpinner = false;
    @track highmarkEmiAmount;

    // for Validation
    @track validationObj;
    @track mobileValidations;
    @track errorMsg;
    @track showErrorTab = false;
    @track tabName = 'Dedupe_Check';
    @track childTabName = 'Capability_Detail';
    @track primaryAppName;
    @track receiptWrapper = { hasReceipt: false, allApproved: false, pendingReceiptList: [], lengthOfDirectRec: 0, existingFeeCodeOption: [] };
    @track loadAll = false;
    @track childTab;
    @track customerDetails = [];

    handleChildTab(event) {
        console.log('handleChildTab = ', event.detail);
        this.childTab = event.detail;
    }



    connectedCallback() {
        console.log('Record ID ###', this.recordId);
        this.pcSpinner = true;
        this.handleRefreshTemplateOnLoad();
        this.handlegetData(true);
        this.getPropertyRecordTypeId();        
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }
    // method used to get the Property Record Type Id for Document Upload
    getPropertyRecordTypeId() {
        getRecordTypeId({ sObjectName: 'Property__c', recordTypeName: 'PC Property Detail' })
            .then(result => {
                console.log('propertyRecordTypeId ### ', result);
                if (result)
                    this.propertyRecordTypeId = result;
            })
            .catch(error => {
                console.log(error);
            })
    }


    handlegetData(param) {
        getData({ CustomerId: this.recordId, ObjName: 'Verification__c' })
            .then(result => {
                console.log('result>>>>' + JSON.stringify(result[0]));
                result.forEach(element => {
                    this.applicationId = element.Application__c;
                    console.log('this applicationid in parent >>>>', this.applicationId);
                    this.loginId = element.Application__r.Pre_Login__c;
                    this.preLoginRecordType = element.Application__r.Pre_Login__r.RecordType.Name;
                    this.appName = element.Application__r.Name;
                    this.loanAmount = element.Application__r.Requested_Loan_Amount__c;
                    this.sourcingBranch = element.Application__r.Sourcing_Branch__c;
                    this.selectedACUser = element.Application__r.Recommended_AC_User__c;
                    this.decisionValue = element.Application__r.PC_Decision__c;
                    this.isVerified = element.Application__r.Verified_UN_sanctions_list_and_no_match__c;
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'PC_Decision__c', fieldvalue: this.decisionValue, recordId: this.applicationId });
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'Recommended_AC_User__c', fieldvalue: this.selectedACUser, recordId: this.applicationId });
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'PC_Remarks__c', fieldvalue: element.Application__r.PC_Remarks__c, recordId: this.applicationId });
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'Verified_UN_sanctions_list_and_no_match__c', fieldvalue: element.Application__r.Verified_UN_sanctions_list_and_no_match__c, recordId: this.applicationId });
                    if (param == true) {
                        this.getCharacterRecords('PC_Table_Family_Details', 'Family Detail');
                        this.getCharacterRecords('PC_Neighbour_Table', 'Neighbour Detail');
                        this.getCharacterRecords('PC_Affiliation_Table', 'Affiliation Detail');
                        this.getCharacterRecords('PC_LivingStandard_Table', 'Living Standard Detail');
                        this.getCapabilityRecords();
                        this.getAllCollateralRecords();
                        this.fetchLastLoginDate();
                        this.handlegetAcUsers();
                    }
                });
            })
            .catch(error => {
                console.log('errror', error);
            });
    }



    get showCharacterForm() {
        return (this.isRepaymentBehaviour || this.isFamilyDetails || this.isAffiliation || this.isLivingStandard || this.isNeighbour) ? true : false;
    }

    // get the dedupe Details
    getdedupedetails(event) {
        let result = event.detail;
        this.dedupeDetails = JSON.parse(result);
        console.log('Dedupe Details', this.dedupeDetails);
        if (this.dedupeDetails.errorFlag)
            this.errorMsg.push(this.dedupeDetails.message);
    }


    handleCapabilityTabActivation(event) {
        this.childTabName = 'Capability_Detail';
        if (event.target.value == 'Capability_Detail') {
            this.capabilitySpinner = true;
            this.capabilityTableData = undefined;
            getRecordTypeId({ sObjectName: 'Capability__c', recordTypeName: 'PC Capability' })
                .then(result => {
                    console.log('result ids ', result);
                    if (result)
                        this.capabilityRecordTypeId = result;
                })
                .catch(error => {
                    console.log(error);
                })
            this.getCapabilityTableRecords();

        }
        else if (event.target.value == 'Capability_Summary') {
            this.capabilitySpinner = true;
            this.handleCapbilitySummary();
        }
    }

    handleCapbilitySummary() {
        console.log('Appliaction Id ###', this.applicationId);
        getCapabilitySummary({ applicationId: this.applicationId })
            .then(res => {
                console.log('CAp Summary>>> ', res);
                this.HandleHMScoreUpdation();
                let loanType;
                this.IncomeSummary = JSON.parse(JSON.stringify(res));
                console.log('IncomeSummary>> ', this.IncomeSummary);
                if (this.preLoginRecordType == '3. Top-up loan') {
                    if (this.IncomeSummary.totalPCbusincomeIncome != null && this.IncomeSummary.totalPCMonthlyIncome != null) {
                        if (parseInt(this.IncomeSummary.totalPCbusincomeIncome) > (parseInt(this.IncomeSummary.totalPCMonthlyIncome) * (25 / 100)))
                            loanType = 'FSBL Business Loan Top up';
                        else
                            loanType = 'FSBL Mortgage Loan Top up';
                    }
                }
                else {
                    if (this.IncomeSummary.totalPCbusincomeIncome != null && this.IncomeSummary.totalPCMonthlyIncome != null) {
                        if (parseInt(this.IncomeSummary.totalPCbusincomeIncome) > (parseInt(this.IncomeSummary.totalPCMonthlyIncome) * (25 / 100)))
                            loanType = 'FSBL Business Loan';
                        else
                            loanType = 'FSBL Mortgage Loan';
                    }
                }
                if (this.IncomeSummary.pcnetMonthlyIncome) {
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.applicationId;
                    fields[NET_INCOME.fieldApiName] = parseFloat(this.IncomeSummary.pcnetMonthlyIncome);
                    fields[TOTAL_GROSS_INCOME.fieldApiName] = parseFloat(this.IncomeSummary.totalPCMonthlyIncome);
                    fields[TOTAL_OBLIGATIONS.fieldApiName] = parseFloat(this.IncomeSummary.allpCObligations);
                    fields[LOAN_TYPE.fieldApiName] = loanType;
                    fields[SCHEME.fieldApiName] = loanType;
                    const recordInput = { fields };
                    updateRecord(recordInput)
                        .then(() => {
                            console.log('### NET INCOME Updated ###');
                        })
                        .catch(error => {
                            console.log('Error in updating NET INCOME ###', error);
                        });
                }
                this.capabilitySpinner = false;
            })
            .catch(
                err => {
                    console.log('CAp Summary error >>> ', err);
                    this.capabilitySpinner = false;
                }
            )
    }


    // handle tab Activations
    handleTabActivation(event) {
        this.tabName = event.target.value;
        this.PCSubOptions = undefined;
        this.template.querySelectorAll('.mycombobox').forEach(each => { each.value = null; });
        if (event.target.value == 'Character_Screen') {
            this.PCSubOptions = [{ label: 'Family Details', value: 'Family Detail' },
            { label: 'Neighbour Check-Living & Mortgage Property', value: 'Neighbour Detail' },
            { label: 'Affiliations', value: 'Affiliation Detail' },
            { label: 'Living Standard', value: 'Living Standard Detail' },
            { label: 'Repayment Behaviour', value: 'Repayment Behaviour Detail' }
            ];
            this.showPCSubCombo1 = true;
        } else if (event.target.value == 'Collateral_Screen') {
            console.log('collateral screen callled');
            this.propertySpinner = true;
            this.showProperty = false;
            this.showPropertyForm = false;
            this.handleGetCollateralGeneralDetails();
            this.PCSubOptions = [{ label: 'Property Details', value: 'General_Details' },
            { label: 'Land Area And Valuation', value: 'Land_Area_And_Valuation' },
            { label: 'Building Extent & Valuation', value: 'Building_Area_Valuation' },
            { label: 'Collateral Summary', value: 'Collateral_Summary' }
            ];
            //this.showPCSubCombo1 = true;
            this.isCollateralSummary = false;
            this.showProperty = true;
        } else if (event.target.value == 'Financial_screen') {
            this.finSpinner = true;
            this.getcollateralSummaryTable();
            if (this.preLoginRecordType == '3. Top-up loan' || this.preLoginRecordType == '4. Tranche loan')
                this.childTab = "Topup_Details";
            else
                this.childTab = "Application_details";
            this.isFinancial = true;
        } else if (event.target.value == 'Capability_screen') {
            this.childTabName = ''
            //this.handleCapbilitySummary();
        } else if (event.target.value == 'Insurance_Fee') {
            setTimeout(() => {
                if (this.template.querySelector('c-fee-insurance-parent-p-c-screen')) {
                    this.template.querySelector('c-fee-insurance-parent-p-c-screen').showFee();
                }
            }, 300);

        } else if (event.target.value == 'Deviation') {
            setTimeout(() => {
                if (this.template.querySelector('c-pc-deviation')) {
                    this.template.querySelector('c-pc-deviation').showDev();
                }
            }, 300);

        } else if (event.target.value == 'Sanction_Condition') {

        } else if (event.target.value == 'Dedupe_Check') {
            setTimeout(() => {
                this.template.querySelector('c-fsdedupe-details-lwc').getCurrentAppsLoanApp();
            }, 300);
        }
    }


    getReceiptPendingList(event) {
        console.log('Receipt data approved ', event.detail);
        this.receiptWrapper.hasReceipt = event.detail.hasReceipt;
        this.receiptWrapper.allApproved = event.detail.allApproved;
        this.receiptWrapper.pendingReceiptList = event.detail.pendingReceiptList;
        this.receiptWrapper.lengthOfDirectRec = event.detail.lengthOfDirectRec;
        this.receiptWrapper.existingFeeCodeOption = event.detail.existingFeeCodeOption;
    }

    renderedCallback() {
        // if (!this.callOnce) {
        //     const style = document.createElement('style');
        //     style.innerText = `.slds-form-element__label{
        //     font-weight: bold;}`;
        //     this.template.querySelector('[data-id="pcTest"]').appendChild(style);
        //     const label = this.template.querySelectorAll('label');
        //     label.forEach(element => {
        //         element.classList.add('bold');
        //     });
        //     console.log('renderedCallback()');
        //     this.callOnce = true;
        // }
        if (this.loadAll == false) {
            console.log('i am in check validity');
            let currentTab = this.tabName;
            console.log('currentTab= ', currentTab);
            let tabs = this.template.querySelectorAll('lightning-tab');
            console.log('tabs ', tabs);
            tabs.forEach(element => {
                console.log('element.value', element.value);
                if (element.value == 'Financial_screen' || element.value == 'Insurance_Fee' || element.value == 'Document_Upload')
                    element.loadContent();
            });
            console.log('currentTab= ', currentTab);
            this.tabName = currentTab;
            if (tabs && tabs.length) {
                this.loadAll = true;
            }

        }

    }

    handleclose(event) {
        this.openOwnerValidation = event.detail;
    }

    // to get all applicant names of Application
    getAllApplicants() {
        getAccounts({ appId: this.applicationId }).then(result => {
            this.loanApplicantList = [];
            this.CustomerOptions = [];
            this.ownerOptions = [];
            let data = [];
            let laList = [];
            let owneroptions = [];
            // let invisibleappList = [];
            // let localMap = new Map();
            // let coappindex = 1, guarantorindex = 1;

            // result.forEach(app => {
            //     if (app.Customer_Type__c != null && !localMap.has(app.Customer_Type__c)) {
            //         localMap.set(app.Customer_Type__c, 0);
            //     }
            //     else if (app.Customer_Type__c != null && localMap.has(app.Customer_Type__c)) {
            //         let count = localMap.get(app.Customer_Type__c);
            //         localMap.set(app.Customer_Type__c, count++);
            //     }
            // })
            //console.log('local map ^^^', localMap);
            result.forEach(app => {
                // if (app.Customer_Type__c == 'Primary Applicant') {
                //     invisibleappList.push({ label: app.Customer_Information__r.Name + ' - App', value: app.Id });
                // }
                // else if (app.Customer_Type__c == 'Co-Applicant') {
                //     invisibleappList.push({ label: app.Customer_Information__r.Name + ' - Co-App'+((localMap.has(app.Customer_Type__c)&&localMap.get(app.Customer_Type__c)>0)?' '+coappindex:''), value: app.Id });
                //     coappindex++;
                // }
                // else if (app.Customer_Type__c == 'Guarantor') {
                //     invisibleappList.push({ label: app.Customer_Information__r.Name + ' - Guarantor'+((localMap.has(app.Customer_Type__c)&&localMap.get(app.Customer_Type__c)>0)?' '+guarantorindex:''), value: app.Id });
                //     guarantorindex++;
                // }

                data.push({ label: app.Customer_Information__r.Name, value: app.Id });
                laList.push(app.Id);
                owneroptions.push({ label: app.Customer_Information__r.Name, value: app.Id + '_' + app.Customer_Type__c });

                if (app.Customer_Type__c == 'Primary Applicant')
                    this.primaryAppName = app.Customer_Information__r.Name;
            });
            //console.log('INvisible options ####', invisibleappList);
            this.CustomerOptions = data;
            this.loanApplicantList = laList;
            this.ownerOptions = owneroptions;
            console.log('this.CustomerOptions>>>>' + JSON.stringify(this.loanApplicantList));
            this.checkAllValidation();
        })
            .catch(error => {
                console.log('error in getting all Applicants', error);
                this.checkAllValidation();
            });
    }

    // to fetch the last Login Date of Logged In User
    fetchLastLoginDate() {
        getLastLoginDate().then(result => {
            console.log('login date ', result);
            this.lastLoginDate = result;
            this.getAllApplicants();
        })
            .catch(error => {
                console.log('error', error);
                this.getAllApplicants();
            })
    }




    // header buttons selection Event-------------------
    rowselectionevent(event) {
        var detail = event.detail;
        console.log('detail ### ', JSON.stringify(detail));
        if (detail === 'AddApplicant') {
            this.applicanttobeCheck = true;
            this.isAddApplicant = true;
            //this.allLoanApplicant.push();
        }
        if (detail === 'AddProperty') {
            this.getAllApplicants();
            this.isAddProperty = true;
            this.propertytobeCheck = true;
            let ref = this.template.querySelector('c-fspc-addand-modify-property');
            console.log('property child called', ref);
            setTimeout(() => {
                if (this.template.querySelector('c-fspc-addand-modify-property')) {
                    console.log('loanaPPlist ', this.loanApplicantList);
                    console.log('application Id', this.applicationId);
                    this.template.querySelector('c-fspc-addand-modify-property').getApplicationId(this.applicationId);
                    this.template.querySelector('c-fspc-addand-modify-property').getLoanAppList(this.loanApplicantList);
                    this.template.querySelector('c-fspc-addand-modify-property').getPropertyOwnersName(this.applicationId);
                    this.template.querySelector('c-fspc-addand-modify-property').getPropertyOwnersList(this.ownerOptions);
                }
            }, 300);

        }
        if (detail === 'InitiateRetrigger') {
            this.initiateRetrigger = true;
        }
        if (detail === 'OwnerValidation') {
            this.openOwnerValidation = true;
        }
        if (detail === 'submit') {
            this.tempsubmit();
            //this.handlePCSubmit();
        }
        if (detail === 'Generate_CAM_Report') {
            console.log('Generate CAM Called');
            generateCamReport({ currentApplicationId: this.applicationId, stage: 'Process Credit' })
                .then(result => {
                    console.log('Cam Report Generated Successfully');
                })
                .catch(error => {
                    console.log('err in generating CAM Report', JSON.parse(JSON.stringify(error)));
                });
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/CAMReportVf?id=' + this.applicationId + '&Generated_From=PC'
                }
            }).then(vfURL => {
                window.open(vfURL);
            });
        }
        if (event.detail === 'pendingReason') {
            this.showHidePendingReasonGrid();
        }
    }

    // add applicant close Event--------

    handleApplicantModal() {
        this.isAddApplicant = false;
        this.getAllApplicants();
    }

    checkSubmit(event) {
        console.log('check ', event.detail);
        this.hasPrimaryApplicant = event.detail.hasPrimaryApplicant;
        this.mobDefList = event.detail.mobDefList;
        this.isMobileVerified = event.detail.isMobileVerified;
        this.isIncomeConsidered = event.detail.isIncomeConsidered;
        this.isKYCVerified = event.detail.isKYCVerified;
        this.kycDefList = event.detail.kycDefList;
    }

    checkBureau(event) {
        console.log('check Bureau Verified List', event.detail);
        this.bureauPendingList = event.detail;
    }

    handlenewlyaddedApplicant(event) {
        console.log('new app id List>>>>>> ', this.newappIdList);
        if (event.detail != undefined)
            this.newappIdList = event.detail;

    }

    // add Property close Event-----

    addpropertyclose() {
        this.isAddProperty = false;
        this.handlecloneNewPropety();
    }

    handlenewlyaddedProperty(event) {
        console.log('newly created property', event.detail);
        if (event.detail != undefined)
            this.propIdList = event.detail;
        this.handlecloneNewPropety();

    }


    checkProperty(event) {
        this.hasPrimaryOwner = event.detail;
        console.log('check property running', this.hasPrimaryOwner);
    }

    // retrigger close Event---------

    handleRetriggerClose() {
        this.initiateRetrigger = false;
        this.checkAllValidation();
    }




    // on change method for PC Combobox
    handlePCSubChange(event) {
        console.log('pc sub change called>>>> ' + event.target.value);
        let value = event.target.value;
        this.showCharacter = true;
        this.isFamilyDetails = false;
        this.isNeighbour = false;
        this.isAffiliation = false;
        this.isLivingStandard = false;
        this.isRepaymentBehaviour = false;
        this.isGeneralDetails = false;
        this.isLandAreaAndValuation = false;
        this.isBuildingAreaAndValuation = false;
        this.isCollateralSummary = false;
        this.showProperty = false;
        this.showPropertyForm = false;
        console.log('IN handle change propertyDetailsData ###', this.propertyDetailsData, 'landDetailsData ###', this.landDetailsData, 'buildingDetailsData ###', this.buildingDetailsData);
        if (value == 'Family Detail' || value == 'Neighbour Detail' || value == 'Affiliation Detail' || value == 'Living Standard Detail') {
            let refreshcontrol = this.template.querySelector('c-pc-character');
            if (refreshcontrol)
                refreshcontrol.refreshForm();
        }

        if (value == 'Family Detail') {
            console.log('before this.isFamilyDetails', this.isFamilyDetails);
            this.characterSpinner = true;
            this.showCharacter = true;
            this.getCharacterTableRecords('PC_Family_Details', value);
            this.isFamilyDetails = true;
            this.showFivCCharacterTable = true;
            console.log('after this.isFamilyDetails', this.isFamilyDetails);
        }
        else if (value == 'Neighbour Detail') {
            this.characterSpinner = true;
            this.showCharacter = true;
            this.getCharacterTableRecords('PC_Neighbour', value);
            this.isNeighbour = true;
            this.showFivCCharacterTable = true;
        }
        else if (value == 'Affiliation Detail') {
            this.characterSpinner = true;
            this.showCharacter = true;
            this.getCharacterTableRecords('PC_Affiliation', value);
            this.isAffiliation = true;
            this.showFivCCharacterTable = true;
        }
        else if (value == 'Living Standard Detail') {
            this.characterSpinner = true;
            this.showCharacter = true;
            this.getCharacterTableRecords('PC_LivingStandard', value);
            this.isLivingStandard = true;
            this.showFivCCharacterTable = true;
        }
        else if (value == 'Repayment Behaviour Detail') {
            this.isRepaymentBehaviour = true;
        }
        else if (value == 'General_Details') {
            this.propsubValue = value;
            this.isGeneralDetails = true;
            this.showProperty = true;
            this.showPropertyForm = true;

        }
        else if (value == 'Land_Area_And_Valuation') {
            this.propsubValue = value;
            this.isLandAreaAndValuation = true;
            this.showProperty = true;
            this.showPropertyForm = true;

        }
        else if (value == 'Building_Area_Valuation') {
            this.propsubValue = value;
            this.gettotalValue();
            this.isBuildingAreaAndValuation = true;
            this.showProperty = true;
            this.showPropertyForm = true;

        }
        else if (value == 'Collateral_Summary') {
            this.propertySpinner = true;
            this.showProperty = false;
            this.getcollateralSummaryTable();
            this.isCollateralSummary = true;
        }
    }

    handleCapabilityRefresh(event) {
        if (event.detail) {
            this.isSalaried = false;
            this.isDailyWages = false;
            this.isPension = false;
            this.isAbroadIncome = false;
            this.isOther = false;
            this.isSelfEmployedOrBusiness = false;
            this.isEateriesAndOthers = false;
            this.isRentalMortgage = false;
            this.isRentalOther = false;
            this.isDayBasis = false;
            this.isMarginBasis = false;
            this.CustomerName = null;
            this.fivCrecordId = null;
            this.showCapability = false;
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


    // row selection method for Capability Table
    handleSelectedRow(event) {
        console.log('selected row>>>>> ', JSON.stringify(event.detail));
        this.capabilitySpinner = true;
        let row = event.detail[0];
        this.capRelationshipId = row.Id;
        this.CustomerName = row.Loan_Applicant__c;
        this.segmentValue = row.Income_segment__c;
        this.subSegmentValue = row.Subsegment__c;
        this.dayorMarginBasis = row.Day_Margin_Basis__c;
        this.fivCrecordId = row.Id;
        this.fivcbusinesspincode = row.BusinessPincode__c;
        this.fivcincomepincode = row.IncomePincode__c;
        console.log(this.segmentValue + '<>>>>>>>' + this.subSegmentValue + '<><<<<<' + this.dayorMarginBasis + '>>>>>>>><<<<<<' + this.fivCrecordId);
        this.Other_Confirmations = row.Other_Confirmations__c != null ? row.Other_Confirmations__c : null;
        this.natureofdocumentProof = row.Nature_of_Document_Proof__c != null ? row.Nature_of_Document_Proof__c : null;
        this.Other_Confirmations_Daily_Wages = row.Other_Confirmations_Daily_Wages__c != null ? row.Other_Confirmations_Daily_Wages__c : null;
        this.proofRemarks = row.Proof_Remarks__c != null ? row.Proof_Remarks__c : null;
        this.fcEnquiry = row.FC_Enquiry_with__c != null ? row.FC_Enquiry_with__c : null;
        this.ownershipProof = row.Proof_of_Ownership__c != null ? row.Proof_of_Ownership__c : null;
        this.ownershipproofEateries = row.Ownership_proof__c != null ? row.Ownership_proof__c : null;
        this.natureOfOwnershipProof = row.Nature_of_Ownership_Proof__c != null ? row.Nature_of_Ownership_Proof__c : null;
        this.incomeProof = row.Income_Proof_Pension__c != null ? row.Income_Proof_Pension__c : null;
        this.grossMonthlyIncome = row.Gross_Monthly_Income__c != null ? row.Gross_Monthly_Income__c : null;
        this.makeAllFalse();
        if (this.segmentValue != null || this.segmentValue != undefined) {
            if (this.segmentValue == 'Salaried') {
                this.isSalaried = true;
            } else if (this.segmentValue == 'Pension') {
                this.isPension = true;
            } else if (this.segmentValue == 'Daily wages') {
                this.isDailyWages = true;
            } else if (this.segmentValue == 'Income from Abroad') {
                this.isAbroadIncome = true;
            } else if (this.segmentValue == 'Eateries' || this.segmentValue == 'Food business' ||
                this.segmentValue == 'Manufacturing' || this.segmentValue == 'Shop owner' ||
                this.segmentValue == 'Milk business' || this.segmentValue == 'General shops' ||
                this.segmentValue == 'Vegetables/Fruits/Flower/Vendor') {
                this.isEateriesAndOthers = true;
            } else if (this.segmentValue == 'Self Employed') {
                this.isSelfEmployedOrBusiness = true;
            } else if (this.segmentValue == 'Housewife' || this.segmentValue == 'Retired' ||
                this.segmentValue == 'Unemployed' || this.segmentValue == 'Others') {
                this.isOther = true;
            }
            else if (this.segmentValue == 'Transport business') {
                this.isTransportBusiness = true;
            }
        }
        if (this.subSegmentValue != null || this.subSegmentValue != undefined) {
            this.isRentalMortgage = false;
            this.isRentalOther = false;
            if (this.subSegmentValue == 'Commercial - mortgage proeprty' || this.subSegmentValue == 'Residential - Mortgage property') {
                this.isRentalMortgage = true;
            } else if (this.subSegmentValue == 'Commercial - Other property' || this.subSegmentValue == 'Residential - Other proeprty') {
                this.isRentalOther = true;
            }
        }
        if (this.dayorMarginBasis != null || this.dayorMarginBasis != undefined) {
            if (this.dayorMarginBasis == 'Day Basis') {
                this.isDayBasis = true;
            } else if (this.dayorMarginBasis == 'Margin Basis') {
                this.isMarginBasis = true;
            }
        }

        this.showCapability = true;
        this.capabilitySpinner = false;

    }

    handlegetValue(event) {
        if (event.detail == true)
            this.gettotalValue();
    }


    @api gettotalValue() {
        gettotalBuildingValue({ appId: this.applicationId, recordTypeName: 'PC Property Detail' })
            .then(result => {
                console.log(' total building Values', result);
                if (result)
                    this.totalBuildingValue = result;
                else
                    this.totalBuildingValue = undefined;
            })
            .catch(error => {
                console.log('Error in getting total building Values', error);
            });
    }


    handleSelectedPropertyRow(event) {
        this.propertySpinner = true;
        //this.showPropertyForm = false;
        this.fivCAutoPopFields = {};
        this.propertyRecordId = undefined;
        console.log(' this.fivCAutoPopFields>>>>> ', JSON.stringify(this.fivCAutoPopFields));
        console.log('selected property row>>>>> ', event.detail);
        let record = JSON.parse(JSON.stringify(event.detail));
        this.preloginproperty = record[0].Property_VALUE.split('/')[3];
        this.fivcTitleDeedNumber = record[0].Title_Deed_Number__c;
        let selectedId = [];
        selectedId.push(record[0].Id);
        this.preselectedRow = selectedId;
        console.log('pre login property', this.preloginproperty);
        getData({ CustomerId: this.preloginproperty, ObjName: 'Property__c' })
            .then(result => {
                console.log('Property result>>>>' + JSON.stringify(result[0]));
                if (result && result.length) {
                    this.propertyRecordId = result[0].Id;
                    this.typeofProperty = result[0].Type_Of_Property__c;
                    console.log('Type Of Property in parent', this.typeofProperty);
                    if (this.propsubValue == 'Building_Area_Valuation')
                        this.handleBuildingFloorsCloning(record[0].Id, this.propertyRecordId);
                }
            })
            .catch(error => {
                console.log('errror', error);
            });

        if (this.propsubValue == 'General_Details') {
            if (record[0].Mortgage_property_Living_property_are__c == ' ') {
                console.log('inside if');
                //this.fivCAutoPopFields.mortagage_and_living_property = '--None--';
            }
            else {
                console.log('inside else');
                this.fivCAutoPopFields.mortagage_and_living_property = record[0].Mortgage_property_Living_property_are__c;
            }
            if (record[0].Mortgage_property_distance_from_branch__c == ' ') {
                console.log('inside if');
                this.fivCAutoPopFields.mortgage_property_distance = null;
            }
            else {
                console.log('inside else');
                this.fivCAutoPopFields.mortgage_property_distance = record[0].Mortgage_property_distance_from_branch__c;
            }
            if (record[0].Person_residing_at_Mortgage_property__c == ' ') {
                console.log('inside if');
                //this.fivCAutoPopFields.person_at_mortgage = '--None--';
            }
            else {
                console.log('inside else');
                this.fivCAutoPopFields.person_at_mortgage = record[0].Person_residing_at_Mortgage_property__c;
            }
            if (record[0].Living_property_Distance_from_Branch__c == ' ') {
                console.log('inside if');
                this.fivCAutoPopFields.living_property_distance = null;
            }
            else {
                console.log('inside else');
                this.fivCAutoPopFields.living_property_distance = record[0].Living_property_Distance_from_Branch__c;
            }
            if (record[0].Pincode__c == ' ') {
                console.log('inside if');
                this.fivCAutoPopFields.living_pincode = null;
            }
            else {
                console.log('inside else');
                this.fivCAutoPopFields.living_pincode = record[0].Pincode__c;
            }
            if (record[0].Is_living_property_is_own_property__c == ' ') {
                console.log('inside if');
                //this.fivCAutoPopFields.is_living_is_own = '--None--';
            }
            else {
                console.log('inside else');
                this.fivCAutoPopFields.is_living_is_own = record[0].Is_living_property_is_own_property__c;
            }
            //this.isGeneralDetails = true;
        }
        else if (this.propsubValue == 'Land_Area_And_Valuation') {
            ComparePropertyValues({ parentPropertyId: this.preloginproperty })
                .then(result => {
                    console.log('ComparePropertyValues= ', result);
                    if (result && result.length) {
                        this.landAreaValues = JSON.parse(result);
                    } console.log('result land values', this.landAreaValues);
                    //this.showPropertyForm = true;
                    this.propertySpinner = false;
                })
                .catch(error => {
                    //this.showPropertyForm = true;
                    this.propertySpinner = false;
                    console.log('Error in getting land Values', error);
                });
            //this.isLandAreaAndValuation = true;
        }
        else if (this.propsubValue == 'Building_Area_Valuation') {
            this.handleGetFloorTableRecords(record[0].Id);
            this.gettotalValue();
        }
        console.log('autopop_fields', JSON.stringify(this.fivCAutoPopFields));
        this.showPCSubCombo1 = true;
        setTimeout(() => {
            //  this.showPropertyForm = true;
            this.propertySpinner = false;
        }, 200);
    }


    handleBuildingFloorsCloning(propIdtobeclone, propIdforClone) {
        let tempId = propIdforClone;
        this.propertyRecordId = undefined;
        cloneFloorDetails({ appId: this.applicationId, propertyIdtobeclone: propIdtobeclone, propertyIdforclone: propIdforClone })
            .then(result => {
                this.propertyRecordId = tempId;
                console.log('Result of Cloning Building Floors ##', result);
            })
            .catch(err => {
                this.propertyRecordId = tempId;
                console.log('Error in Result of Cloning Building Floors ##', err);
            })

    }

    handleCustomerChange(event) {
        console.log('LAId' + event.target.value);
        this.capabilitySpinner = true;
        this.showCapability = false;
        this.showCapability = false;
        this.isSalaried = false;
        this.isDailyWages = false;
        this.isPension = false;
        this.isAbroadIncome = false;
        this.isOther = false;
        this.isSelfEmployedOrBusiness = false;
        this.isEateriesAndOthers = false;
        this.isRentalMortgage = false;
        this.isRentalOther = false;
        this.isDayBasis = true;
        this.isMarginBasis = false;
        this.loanAppId = event.target.value;
        //this.getCapabilityTableRecords();
        console.log('cap data', this.capabilityTableData);
    }


    // onsubmit and Onsuccess Method for PC Decision Form
    handleDecisionSubmit(event) {
        this.pcSpinner = true;
        if (this.selectedACUser == null && this.selectedACUser == undefined) {
            event.preventDefault();
            this.showToast('', 'error', 'You haven\'t Selected any User');
        } else {
            let date = new Date().toISOString();
            this.dateTimeVal = date;
        }

        console.log('PC Decision Submit Called');
    }

    handleDecisionSuccess(event) {
        this.pcSpinner = false;
        console.log('PC Decision Success Called', event.detail.Id);
        this.showToast('', 'success', 'Decision Submitted Successfully');
        this.handlegetData(false);
    }

    // get All Ac Users for Recommend
    handlegetAcUsers() {
        console.log('Sourcing Branch', this.sourcingBranch);
        this.usersList = [];
        getACUsers({ SourcingBranch: this.sourcingBranch })
            .then(result => {
                console.log('users list', result);
                if (result) {
                    let tempList = [];
                    result.forEach(element => {
                        tempList.push({ value: element.Id, label: element.Name });
                    })
                    this.usersList = JSON.parse(JSON.stringify(tempList));
                    console.log('after user list', JSON.stringify(this.usersList));
                }

                this.pcSpinner = false;
            })
            .catch(err => {
                console.log('error in users list', err);
                this.pcSpinner = false;
            })
    }




    // handle change method for Decision Tab
    handleChange(event) {
        let fName = event.target.fieldName ? event.target.fieldName : event.target.name;
        let fValue = event.target.value;

        console.log('value in handle change', fValue);
        if (event.target.name == 'Recommended_AC_User__c') {
            this.selectedACUser = fValue;
        }
        else if (event.target.fieldName == 'PC_Decision__c') {
            this.decisionValue = fValue;
        }
        this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: this.applicationId });
        console.log('this selected AC  User', this.selectedACUser);
    }


    // for getting the character table records------
    getCharacterTableRecords(metadataName, secName) {
        this.familyTableData = undefined;
        getCharacterTabRecords({ appId: this.applicationId, metadataName: metadataName, sectionName: secName }).then((result) => {
            console.log('getFamilyDetailTableRecords= ', JSON.parse(JSON.stringify(result)));
            this.familyTableData = JSON.parse(JSON.stringify(result));
            this.characterSpinner = false;
        }).catch((err) => {
            this.familyTableData = undefined;
            console.log('getFamilyDetailTableRecords Error= ', err);
            this.characterSpinner = false;
        });
    }


    // for getting the property table records for property details Section-------
    handleGetCollateralGeneralDetails() {
        this.propertyDetailsData = undefined;
        getCollateralTableRecords({ appId: this.applicationId, metadataName: 'PC_Col_GenDetails' }).then((result) => {
            console.log('handleGetCollateralGeneralDetails= ', JSON.parse(JSON.stringify(result)));
            this.propertyDetailsData = JSON.parse(JSON.stringify(result));
            this.isGeneralDetails = true;
            this.handleGetCollateralLandAreaDetails();
            //this.propertySpinner = false;
        }).catch((err) => {
            console.log('Error in handleGetCollateralGeneralDetails= ', err);
            this.handleGetCollateralLandAreaDetails();
            //this.propertySpinner = false;
        });
    }

    // for getting the property table records for Land Area and Valuation Section-------
    handleGetCollateralLandAreaDetails() {
        this.landDetailsData = undefined;
        getCollateralTableRecords({ appId: this.applicationId, metadataName: 'PC_Col_LandArea' }).then((result) => {
            console.log('handleGetCollateralLandAreaDetails= ', JSON.parse(JSON.stringify(result)));
            this.landDetailsData = JSON.parse(JSON.stringify(result));
            //this.propertySpinner = false;
            this.handleGetCollateralBuildingAreaDetails();
        }).catch((err) => {
            console.log('Error in handleGetCollateralLandAreaDetails= ', err);
            this.handleGetCollateralBuildingAreaDetails();
            //this.propertySpinner = false;
        });
    }

    // for getting the property table records for Building Area Exent and Valuation Section-------
    handleGetCollateralBuildingAreaDetails() {
        this.buildingDetailsData = undefined;
        getCollateralTableRecords({ appId: this.applicationId, metadataName: 'PC_Col_BuildAreaVal' }).then((result) => {
            console.log('handleGetCollateralBuildingAreaDetails= ', JSON.parse(JSON.stringify(result)));
            this.buildingDetailsData = JSON.parse(JSON.stringify(result));
            this.propertySpinner = false;
        }).catch((err) => {
            console.log('Error in handleGetCollateralBuildingAreaDetails= ', err);
            this.propertySpinner = false;
        });
    }


    handleGetFloorTableRecords(recordId) {
        this.builidngFloorDetails = undefined;
        getFloorTableRecords({ appId: this.applicationId, propId: recordId, metadataName: 'PC_Collateral_Floor_Details', calledFrom: 'PC' }).then(result => {
            console.log('handleGetFloorTableRecords= ', JSON.parse(JSON.stringify(result)));
            this.builidngFloorDetails = JSON.parse(JSON.stringify(result));
            this.propertySpinner = false;
        }).catch((err) => {
            console.log('Error in handleGetFloorTableRecords= ', err);
            this.propertySpinner = false;
        });
    }


    // to get the Capability Table Records-----
    getCapabilityTableRecords() {
        this.capabilityTableData = undefined;
        getCapabiltyData({ appId: this.applicationId, recTypeName: 'FIV - C', metadataName: 'PC_Capabilty', caprecordTypeName: 'FIV-C Capability' }).then((result) => {
            console.log('getCapabilityTableRecords= ', result);
            this.capabilityTableData = result;
            console.log('cap data', JSON.parse(JSON.stringify(result)));
            this.capabilitySpinner = false;
        }).catch((err) => {
            this.capabilityTableData = undefined;
            console.log('getCapabilityTableRecords Error= ', err);
            this.capabilitySpinner = false;
        });
    }



    // get collateral summary Table
    getcollateralSummaryTable() {
        GetCollateralSummary({ applicationId: this.applicationId, recTypeName: 'PC Property Detail' })
            .then(result => {
                console.log('in collateral summary result', result);
                if (result && result.length) {
                    var grandcollateralvalue = 0, totalBuildingValue = 0, totalLandValue = 0, totalLandArea = 0, totalBuildingArea = 0;
                    this.propertySummaryObj = JSON.parse(JSON.stringify(this.propertySummaryObj));
                    this.propertySummaryObj.propertyList = [];
                    result.forEach(element => {
                        this.propertySummaryObj.propertyList.push({
                            Name: element.Property__r.Name,
                            Land_Area_Sq_Ft__c: (element.Land_Area_Sq_Ft__c != undefined) ? element.Land_Area_Sq_Ft__c : 0,
                            Valuation_Market_Value_Per_SqFt__c: (element.Valuation_Market_Value_Per_SqFt__c != undefined) ? element.Valuation_Market_Value_Per_SqFt__c : 0,
                            Final_Land_Value__c: element.Final_Land_Value__c,
                            Building_Area_Sq_Ft__c: (element.Total_Floor_Area__c != undefined) ? element.Total_Floor_Area__c : 0,
                            Building_Value_per_Sq_ft__c: element.Avg_Floor_Value_Per_Sq_Ft__c,
                            Building_Value__c: (element.Total_Floor_Value__c != undefined ? element.Total_Floor_Value__c : 0),
                            Total_Collateral_Value: element.Final_Land_Value__c + (element.Total_Floor_Value__c != undefined ? element.Total_Floor_Value__c : 0)
                        });
                        totalLandArea += (element.Land_Area_Sq_Ft__c != undefined ? element.Land_Area_Sq_Ft__c : 0);
                        totalBuildingArea += (element.Total_Floor_Area__c != undefined ? element.Total_Floor_Area__c : 0);
                        totalLandValue += element.Final_Land_Value__c;
                        totalBuildingValue += (element.Total_Floor_Value__c != undefined ? element.Total_Floor_Value__c : 0);
                        grandcollateralvalue += (element.Final_Land_Value__c != undefined ? element.Final_Land_Value__c : 0) + (element.Total_Floor_Value__c != undefined ? element.Total_Floor_Value__c : 0);
                    });
                    this.propertySummaryObj.collateralGrandValue = grandcollateralvalue;
                    this.propertySummaryObj.landGrandValue = totalLandValue;
                    this.propertySummaryObj.buildingGrandValue = totalBuildingValue;
                }
                if (this.propertySummaryObj.collateralGrandValue) {
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.applicationId;
                    fields[GROUP_VALUATION.fieldApiName] = parseFloat(this.propertySummaryObj.collateralGrandValue);
                    fields[MORTGAGE_VALUE.fieldApiName] = parseFloat(this.propertySummaryObj.collateralGrandValue);
                    fields[TOTAL_LAND_AREA.fieldApiName] = totalLandArea;
                    fields[TOTAL_BUILDING_AREA.fieldApiName] = totalBuildingArea;
                    const recordInput = { fields };
                    updateRecord(recordInput)
                        .then(() => {
                            console.log('### Group Valuation Updated ###');
                        })
                        .catch(error => {
                            console.log('Error in updating group Valuation ###', error);
                        });
                }
                this.propertySpinner = false;
                this.finSpinner = false;
            })
            .catch(error => {
                this.propertySpinner = false;
                this.finSpinner = false;
                console.log('in collateral summary error', error);
            })
    }

    HandleHMScoreUpdation() {
        //method updated from setHMScore to getHMScore to implement updated logic
        getHMScore({ appId: this.applicationId })
            .then(result => {
                console.log('HM Score Updation method called', result);
                //this.capabilitySpinner = false;
            })
            .catch(error => {
                console.log('Error in HM Score Updation', error);
                //this.capabilitySpinner = false;
            })
    }

    // re check all the Validation since there are some change occured on child components
    handleValidation(event) {
        console.log('check validation pc character', event.detail);
        if (event.detail == true)
            this.checkAllValidation();
        if (this.showPropertyForm)
            this.getcollateralSummaryTable();
        if (this.showCapability)
            this.handleCapbilitySummary();
    }



    //check PC Validation
    @api checkAllValidation() {
        console.log('verfId ', this.recordId);
        checkPCValidation({ verfId: this.recordId, appId: this.applicationId }).then(result => {
            console.log(' Validation result', result);
            this.validationObj = result;
            this.pcSpinner = false;
        }).catch(err => {
            console.log('error in validation', err);
            this.pcSpinner = false;
        })

        checkPCACMobileValidation({ verfId: this.recordId, appId: this.applicationId }).then(result => {
            console.log(' Validation result', result);
            this.mobileValidations = result;
            this.acspinner = false;
        }).catch(err => {
            console.log('error in validation', err);
            this.acspinner = false;
        })
    }

    // Handle Insurance Validation
    HandleInsuranceValidation() {
        checkInsuranceValidation({ applicationId: this.applicationId })
            .then(res => {
                console.log('Result Of Insurance Validation ###', res);
                if (res)
                    this.errorMsg.push('Please Invoke Insurance Api First');
            })
            .catch(err => {
                console.log('Error %%%', err);
            })
    }


    async tempsubmit() {
        this.pcSpinner = true;
        this.errorMsg = [];
        this.errorMsg = checkValidationPCAC('PC');
        console.log('checkValidationPCAC = ', this.errorMsg);

        // Added on 01.05.23 :
        await checkBureauVerified({ appId: this.applicationId }).then(result => {
            console.log('checkBureauVerified= !!', result);
            if (result && result.length) {
                console.log('Push Message Displayed!!');
                result.forEach(applicantName => {
                    this.errorMsg.push('Bureau Verfication Pending For ' + applicantName + '!!');
                });
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Bureau Verification failed ', error);
        })

        await getPendingReasonValidation({ applicationId: this.applicationId, stage: 'Process Credit' }).then(result => {
            console.log('getPendingReasonValidation= !!', result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsg.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })

        let myCmp = this.template.querySelector('c-fee-insurance-parent-p-c-screen');
        if (myCmp)
            myCmp.getReceipt();
        this.getFeeWithoutRepayment();
        this.getZeroFee();
        this.HandleInsuranceValidation();
        this.dedupeDetails = undefined;
        let dedupeResult = this.template.querySelector('c-fsdedupe-details-lwc');
        console.log('dedupeResult ###', dedupeResult);
        if (dedupeResult)
            dedupeResult.submitDedupeData();

        console.log('submit called', this.validationObj);

        try {
            this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
            console.log('required docs List', this.requiredDocuments);
        } catch (error) {
            console.log(error)
        }
    }

    handlePCSubmit(event) {

        var tempValue = 'test';
        const pcEvent = new CustomEvent("refreshpc", { detail: tempValue });
        this.dispatchEvent(pcEvent);


        this.pcSpinner = false;
        console.log('Decision Value', this.decisionValue);

        /* Character Validation Check */
        if (this.validationObj.charWrap.familyDetail) {
            this.errorMsg.push('Each Applicant Must Have One Family Member Record In Character Section');
        }
        if (this.validationObj.charWrap.NeighbourDetail) {
            this.errorMsg.push('Please Complete Entry In Neighbour Check Sub Section In Character Section');
        }
        if (this.validationObj.charWrap.AffiliationDetail) {
            this.errorMsg.push('Please Complete Entry In Affiliation Detail Sub Section In Character Section');
        }
        if (this.validationObj.charWrap.LivingStandardDetail) {
            this.errorMsg.push('Please Complete Entry In Living Standard Detail Sub Section In Character Section');
        }

        /* Collateral Validation Check */
        if (this.validationObj.colWrap.PropertyDetails) {
            this.errorMsg.push('Please Complete Entry In Property Details Sub Section In Collateral Section');
        }
        if (this.validationObj.colWrap.LandArea) {
            this.errorMsg.push('Please Complete Entry In Land Area And Valuation Sub Section In Collateral Section');
        }
        if (this.validationObj.colWrap.BuildingValuation) {
            this.errorMsg.push('Please Complete Entry In Building Area And Extent Sub Section In Collateral Section');
        }

        /* Capability Validation Check */
        if (!this.validationObj.capabilityValidation) {
            this.errorMsg.push('Please Complete Entry In Capability Section');
        }

        /* Financial Validation Check */
        if (this.validationObj.finWrap.ApplicationDetail) {
            this.errorMsg.push('Please Complete Entry In Application Detail Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.LoanDetail) {
            this.errorMsg.push('Please Complete Entry In Loan Detail Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.InsuranceDetail) {
            this.errorMsg.push('Please Complete Entry In Insurance Party Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.DisbursementDetail) {
            this.errorMsg.push('Please Complete Entry In Disbursement/Repayment detail Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.LoanAmtDetail) {
            this.errorMsg.push('Please Complete Entry In Loan Amount Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.EligibilityDetail) {
            this.errorMsg.push('Please Complete Entry In Eligibility Calculations Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.RiskDetail) {
            this.errorMsg.push('Please Complete Entry In Risk Rating Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.OtherDetail) {
            this.errorMsg.push('Please Complete Entry In Other Detail Sub Section In Financial Section');
        }
        if (this.validationObj.finWrap.ExecutiveDetail) {
            this.errorMsg.push('Please Complete Entry In Executive Summary Sub Section In Financial Section');
        }
        if (!this.isVerified) {
            this.errorMsg.push('Checking Verified UN sanctions list and no match in Decision Tab is mandatory');
        }

        if (!this.validationObj.isPrimaryOwner) {
            this.errorMsg.push('Add Atleast One Property Of Primary Applicant from Add/Modify Property Button');
        }


        // property Validation
        // if (!this.validationObj.isonlineECinitiated && this.validationObj.isPropertyAdded) {
        //     if (!this.errorMsg.includes('Initiating Online EC is Mandatory'))
        //         this.errorMsg.push('Initiating Online EC is Mandatory');
        // }
        // if (!this.validationObj.isfivcInitiated && this.validationObj.isPropertyAdded) {
        //     if (!this.errorMsg.includes('Initiating FIV-C is Mandatory'))
        //         this.errorMsg.push('Initiating FIV-C is Mandatory');
        // }

        if (this.validationObj.kycVerificationList != null && this.validationObj.kycVerificationList.length > 0) {
            if (!this.errorMsg.includes('Verify KYC Of ' + this.validationObj.kycVerificationList.join() + ' from Add/Modify Applicant Button'))
                this.errorMsg.push('Verify KYC Of ' + this.validationObj.kycVerificationList.join() + ' from Add/Modify Applicant Button');
        }
        if (this.mobileValidations != null && this.mobileValidations.length > 0) {
            if (!this.errorMsg.includes('Verify Mobile Of Highest Income Earner ' + this.mobileValidations.join() + ' from Add/Modify Applicant Button'))
                this.errorMsg.push('Verify Mobile Of Highest Income Earner ' + this.mobileValidations.join() + ' from Add/Modify Applicant Button');
        }
        // if (this.validationObj.bureauList.length > 0) {
        //     if (!this.errorMsg.includes('Verify Bureau of ' + this.validationObj.bureauList.join() + ' from Add/Modify Applicant Button'))
        //         this.errorMsg.push('Verify Bureau of ' + this.validationObj.bureauList.join() + ' from Add/Modify Applicant Button');
        // }
        if (this.validationObj.pendingLeadDetailList.length > 0) {
            if (!this.errorMsg.includes('Please Complete Lead Detail for the newly Added Applicant(s)'))
                this.errorMsg.push('Please Complete Lead Detail for the newly Added Applicant(s)');
        }
        if (this.validationObj.paramList.length > 0) {
            this.errorMsg.push('Case can not be move forward as ' + this.validationObj.paramList.join() + ' is greater than 80%');
        }

        if (this.validationObj.isGaurantorNetworthMissing) {
            if (!this.errorMsg.includes('Please fill Guarantor Networth In Loan Detail Sub Section In Financial Section'))
                this.errorMsg.push('Please fill Guarantor Networth In Loan Detail Sub Section In Financial Section');
        }
        if (this.validationObj.isLoanAmountNotValid) {
            if (!this.errorMsg.includes('Total Amount Recommended can not be greater than the Requested Loan Amount'))
                this.errorMsg.push('Total Amount Recommended can not be greater than the Requested Loan Amount');
        }
        // if (this.validationObj.isKYCorNameorDOBChanged) {
        //     if (!this.errorMsg.includes('Please Click Submit Button on Lead Detail to Invoke Customer API'))
        //         this.errorMsg.push('Please Click Submit Button on Lead Detail to Invoke Customer API');
        // }


        // applicant Validation
        // if (this.validationObj.isLoanApplicantAdded) {
        //     if (!this.validationObj.kycVerificationList.length && !this.validationObj.mobileverificationList.length && !this.validationObj.bureauList.length && !this.validationObj.isfivcInitiated) {
        //         if (!this.errorMsg.includes('Initiating FIV-C is Mandatory'))
        //             this.errorMsg.push('Initiating FIV-C is Mandatory');
        //     }
        // }


        if (this.applicanttobeCheck) {
            if (!this.hasPrimaryApplicant) {
                this.errorMsg.push('Add An Primary Applicant from Add/Modify Applicant Button');
            }
            if (!this.isIncomeConsidered) {
                this.errorMsg.push('Add Atleast One Income Considered Applicant from Add/Modify Applicant Button');
            }
        }

        if (!this.validationObj.isfivbCompleted && this.validationObj.isfivbInitiated) {
            if (!this.errorMsg.includes('FIV-B Verification is pending'))
                this.errorMsg.push('FIV-B Verification is pending');
        }
        if (!this.validationObj.isfivcCompleted && this.validationObj.isfivcInitiated) {
            if (!this.errorMsg.includes('FIV-C Verification is pending'))
                this.errorMsg.push('FIV-C Verification is pending');
        }
        if (!this.validationObj.isonlineECCompleted && this.validationObj.isonlineECinitiated) {
            if (!this.errorMsg.includes('Online EC Verification is pending'))
                this.errorMsg.push('Online EC Verification is pending');
        }

        console.log('receipt wrapper in PC Submit', this.receiptWrapper);
        // Fee and Insurance Validations
        if (this.receiptWrapper.lengthOfDirectRec > 0 && this.receiptWrapper.hasReceipt == false) {
            this.errorMsg.push('Please Add Receipt in Insurance/Fee Details Tab');
        }
        else {
            console.log('Receipt Defaulter List ', this.receiptWrapper.pendingReceiptList.length);
            if (this.receiptWrapper.pendingReceiptList.length > 0) {
                this.receiptWrapper.pendingReceiptList.forEach(element => {
                    if (element.RecStatus != 'Rejected') {
                        //  this.errorMsgs.push('Approve Receipts ' + this.receiptWrapper.pendingReceiptList.join() + ' In Fee Details Tab');
                        this.errorMsg.push('Get Approve ' + element.RecStatus + ' Receipts ' + element.name + ' In Insurance/Fee Details Tab');
                    }
                });

            }
        }
        if (this.receiptWrapper.existingFeeCodeOption.length > 0) {
            this.receiptWrapper.existingFeeCodeOption.forEach(element => {
                this.errorMsg.push('Please Add Receipt in Fee Details Tab for Fee Code: ' + element.label);
                console.log('this.receiptWrapper.existingFeeCodeOption', element.label);
            });
        }

        // decision Validation Error Message
        if ((this.decisionValue == null && this.decisionValue == undefined) || (this.selectedACUser == null && this.selectedACUser == undefined)) {
            if (!this.errorMsg.includes('Please Complete Entry In Decision Section'))
                this.errorMsg.push('Please Complete Entry In Decision Section');
        }

        console.log('showErrorTab errorMsg = ', this.errorMsg)

        if (this.errorMsg && this.errorMsg.length) {
            this.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.tabName = 'Error';
            }, 300);
        } else {
            this.pcSpinner = true;
            this.showErrorTab = false;
            this.handlepcSubmission();
        }
    }

    // cloning newly Added Property
    handlecloneNewPropety() {
        clonePropertyNew({ appId: this.applicationId })
            .then(result => {
                console.log('result in clone property ', result);
            })
            .catch(error => {
                console.log('error in clone property ', error);
            });
    }

    callLmsApiClass() {

        mailResponse({ responseData: JSON.stringify(this.customerDetails) })
            .then(result => {
                console.log('inside mail method');
            })
            .catch(error => {
                console.log('Error', error);
                this.pcSpinner = false;
            });

    }

    async callCreateCustomerAPi() {
        if (this.template.querySelector('c-fsdedupe-details-lwc')) {
            var executeCustApi = await this.template.querySelector('c-fsdedupe-details-lwc').executeCustomerApi();
            console.log('inside call customer async', executeCustApi);
        }
        console.log('executeCustApi in saync is >>>', executeCustApi);
    }

    updateStagePc() {
        console.log('isndei update stage');
        var boolvar = false;
        for (let i = 0; i < this.customerDetails.length; i++) {
            var strVal = JSON.parse(this.customerDetails[i]);
            if (strVal.errorDescription != '' && strVal.errorDescription != null) {
                var errormessage = 'Customer API failed for { ' + strVal.userName + ' }' + ' and error is : ' + strVal.errorDescription;
                this.errorMsg.push(errormessage);
                boolvar = true;
            }
            if (i == this.customerDetails.length - 1 && !boolvar) {
                this.updateStageAfterCustomerCreation();
            } else if (i == this.customerDetails.length - 1 && boolvar) {
                this.showErrorTab = true;
                let ref = this;
                setTimeout(() => {
                    ref.tabName = 'Error';
                }, 300);
                this.pcSpinner = false;
                this.callLmsApiClass(); //incase if error occurs create apilogger 
            }
        }

    }

    updateStageAfterCustomerCreation() {

        this.showErrorTab = false;
        this.handleDiscussionMemoGeneration();
        this.submitPcStage(); // errors are over submit pc stage
        this.callLmsApiClass();//incase if success occurs create apilogger 
    }

    getcustomerdetails(event) {
        let result = event.detail;
        this.customerDetails = result;
        //this.processCustomerData=result;
        console.log('result of customer api data is >>>>', this.customerDetails);
        console.log('result of customer api data length is >>>>', this.customerDetails.length);
        if (this.customerDetails.length > 0) {
            this.updateStagePc();
        } else {
            this.updateStageAfterCustomerCreation();
        }

    }


    handlepcSubmission() {
        this.callCreateCustomerAPi();
    }


    // pc submission to next stage - added by sandeep
    submitPcStage() {
        saveAllRecordsPCAC({ jsonStr: JSON.stringify(pc_data_template) }).then((result) => {
            console.log('saveAllRecordsPCAC success = ', result);
            if (result == 'success') {
                handleFinish({ appId: this.applicationId, stage: 'PC', verfId: this.recordId }).then(result => {
                    console.log('pc finish successfully called', result);
                    var today = new Date().toISOString().slice(0, 10);
                    console.log('today date', today);
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.applicationId;
                    fields[STAGE_FIELD.fieldApiName] = 'Approval Credit';
                    fields[SUBMISSION_DATE_FIELD.fieldApiName] = today;
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        console.log('pc finish successfully called', result);
                        this.showToast('Success', 'success', 'Process Credit Completed Successfully');
                        this.pcSpinner = false;
                        this.navigateToApplication();
                    }).catch(error => {
                        this.pcSpinner = false;
                        console.log(error);
                    });
                }).catch(err => {
                    this.pcSpinner = false;
                    console.log('pc finish error called', err);
                })
            }
        }).catch((err) => {
            this.pcSpinner = false;
            console.log('saveAllRecordsPCAC Error = ', err);
        });
    }

    // navigate to Application Record Page
    navigateToApplication() {
        console.log('navigate called' + this.applicationId);
        window.location.replace('/' + this.applicationId);
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.applicationId,
        //         actionName: 'view',
        //     }
        // });
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

    // document upload Validation Methods
    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;
        this.requiredDocumentValidation();

        setTimeout(() => {
            this.handlePCSubmit();
        }, 3000);
    }


    requiredDocumentValidation() {
        console.log('requiredDocuments ', JSON.stringify(this.requiredDocuments));
        if (this.requiredDocuments.length > 0) {
            this.requiredDocuments.forEach(element => {
                console.log('element #### ', JSON.stringify(element));
                if (element.documentType === 'Application') {
                    this.errorMsg.push(' Upload Application Document ' + element.documentName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Applicant') {
                    this.errorMsg.push(' Upload Document ' + element.documentName + ' For ' + element.customerName + ' In Document Upload Tab');
                }
                if (element.documentType === 'Asset') {
                    this.errorMsg.push(' Upload Document ' + element.documentName + ' For ' + element.propertyName + ' In Document Upload Tab');
                }
            });
        }
    }


    getFeeWithoutRepayment() {
        getFeeWithoutRepayment({ recordId: this.applicationId })
            .then(result => {
                console.log('::: fee ::: ', result);
                if (result) {
                    if (!this.errorMsg.includes('Please Select Repayment Type in Fee Details section of Fee details tab'))
                        this.errorMsg.push('Please Select Repayment Type in Fee Details section of Fee details tab');
                }
            })
            .catch(error => {
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })
    }


    getZeroFee() {
        getZeroFee({ recordId: this.applicationId })
            .then(result => {
                console.log('::: getZeroFee ::: ', result);
                if (result) {
                    if (!this.errorMsg.includes('Total Fee can not be 0 in Fee Details section of Fee details tab'))
                        this.errorMsg.push('Total Fee can not be 0 in Fee Details section of Fee details tab');
                }
            })
            .catch(error => {
                console.log('error on inside repayment value -> ' + JSON.stringify(error));
            })

    }

    // Method used to generate the Discussion memo at the time of submission
    handleDiscussionMemoGeneration() {
        savePdf({ applicationId: this.applicationId, stageName: 'Process Credit' }).then(result => {
            console.log('Discussion Memo Generated Successfully', result);
        })
            .catch(err => {
                console.log('Error in Discussion Memo Generation', err);
            })

    }


    // Methods to handle Population of Data in the Data Template used in Partial Save and Submit.....

    handleRefreshTemplateOnLoad() {
        this.handleRemoveData({ tabname: 'Character', subtabname: 'Family Detail' });
        this.handleRemoveData({ tabname: 'Character', subtabname: 'Neighbour Detail' });
        this.handleRemoveData({ tabname: 'Character', subtabname: 'Affiliation Detail' });
        this.handleRemoveData({ tabname: 'Character', subtabname: 'Living Standard Detail' });
        this.handleRemoveData({ tabname: 'Capability', subtabname: '' });
    }

    handleTabValueChange(event) {
        console.log('partaiall save  eventtt ', event.detail)
        var data = event.detail;
        this.handlepopulateData(data);
    }

    handleTabValueRemove(event) {
        console.log('partaiall removee  eventtt ', event.detail)
        var data = event.detail;
        this.handleRemoveData(data);
    }


    handlepopulateData(data) {
        let fValue = data.fieldvalue;
        if ((data.fieldapiname == 'Title_Deed_Date__c') && fValue && fValue.trim()) {
            fValue = fValue.substr(0, 10);
        } else if ((data.fieldapiname == 'Title_Deed_Date__c' || data.fieldapiname == 'Revisit_date__c') && (!fValue || !fValue.trim())) {
            fValue = null;
        }
        populateData('PC', data.tabname, data.subtabname, data.fieldapiname, fValue, 'Id', data.recordId);
        console.log('populate dataaa', pc_data_template);
    }

    handleRemoveData(data) {
        removeData('PC', data.tabname, data.subtabname);
        console.log('removee111 dataaa', pc_data_template);
    }



    // for getting the character table records------
    getCharacterRecords(metadataName, secName) {
        this.charTableData = undefined;
        console.log('app Id in character table', this.applicationId);
        getCharacterTableRecords({ appId: this.applicationId, metadataName: metadataName, sectionName: secName, recType: 'PC' }).then((result) => {
            console.log('getFamilyDetailTableRecords in child= ', JSON.parse(JSON.stringify(result)));
            this.charTableData = JSON.parse(JSON.stringify(result));
            JSON.parse(result.strDataTableData).forEach(element => {
                for (let keyValue of Object.keys(element)) {
                    if (keyValue != 'Id') {
                        console.log('insideee111 keyValue ', keyValue)
                        this.handlepopulateData({ tabname: 'Character', subtabname: secName, fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id });
                    }
                }
            });
        }).catch((err) => {
            this.charTableData = undefined;
        });
    }

    // to get the Capability Table Records  -----
    getCapabilityRecords() {
        this.capabilitypcTableData = undefined;
        console.log('app Id in capability table', this.applicationId);
        getCapabiltyData({ appId: this.applicationId, recTypeName: 'PC', metadataName: 'PC_Capabilty_Table', caprecordTypeName: 'PC Capability' }).then((result) => {
            console.log('getCapabilityTableRecords in pc= ', result);
            this.capabilitypcTableData = JSON.parse(JSON.stringify(result));
            if (this.capabilitypcTableData && this.capabilitypcTableData.strDataTableData && JSON.parse(this.capabilitypcTableData.strDataTableData).length) {
                JSON.parse(result.strDataTableData).forEach(element => {
                    for (let keyValue of Object.keys(element)) {
                        if (keyValue != 'Id') {
                            this.handlepopulateData({ tabname: 'Capability', subtabname: '', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id });
                        }
                    }
                });
            }

        }).catch((err) => {
            this.capabilitypcTableData = undefined;
            console.log('getCapabilityTableRecords in pc Error= ', err);
        });
    }

    // to get the Collateral Table Records  -----
    getAllCollateralRecords() {
        this.collateralTable = undefined;
        console.log('app Id in collateral table', this.applicationId);
        getACCollateralTabRecords({ appId: this.applicationId, recordTypeName: 'PC Property Detail' }).then(result => {
            if (result) {
                console.log('data refreshed ', result);
                this.collateralTable = JSON.parse(JSON.stringify(result));
                if (this.collateralTable && this.collateralTable.strDataTableData && JSON.parse(this.collateralTable.strDataTableData).length) {
                    JSON.parse(result.strDataTableData).forEach(element => {
                        for (let keyValue of Object.keys(element)) {
                            if (keyValue != 'Id') {
                                this.handlepopulateData({ tabname: 'Collateral', subtabname: '', fieldapiname: keyValue, fieldvalue: element[keyValue], recordId: element.Id });
                            }
                        }
                    });
                }
            }
        })
            .catch(error => {
                console.log(' collateral table error', error);
                this.collateralTable = undefined;
            })
    }

     
}