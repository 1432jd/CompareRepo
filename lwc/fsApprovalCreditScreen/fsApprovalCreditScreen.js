import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { populateData, removeData, checkValidationPCAC, ac_data_template } from 'c/fsGenericDataSave';

/************************* ALL CUSTOM FIELDS IMPORT STATEMENTS ************************/
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import STAGE_FIELD from '@salesforce/schema/Application__c.Stage__c';
import SUBMISSION_DATE_FIELD from '@salesforce/schema/Application__c.AC_Submission_Date__c';
import GROUP_VALUATION from '@salesforce/schema/Application__c.Group_Valuation__c';
import MORTGAGE_VALUE from '@salesforce/schema/Application__c.Mortgage_property_Collateral_Value__c';
import TOTAL_LAND_AREA from '@salesforce/schema/Application__c.AC_Total_Land_Area__c';
import TOTAL_BUILDING_AREA from '@salesforce/schema/Application__c.AC_Total_Building_Area__c';
import NET_INCOME from '@salesforce/schema/Application__c.Total_Net_Income__c';
import TOTAL_OBLIGATIONS from '@salesforce/schema/Application__c.AC_Total_Obligations__c';
import TOTAL_GROSS_INCOME from '@salesforce/schema/Application__c.AC_Gross_Income__c';
import OWNER_ID from '@salesforce/schema/Application__c.OwnerId';
import LOAN_TYPE from '@salesforce/schema/Application__c.Loan_Type__c';
import SCHEME from '@salesforce/schema/Application__c.Scheme__c';
import APPLICATION_STATUS from '@salesforce/schema/Application__c.application_status__c';
import DECISION_DATE_TIME from '@salesforce/schema/Application__c.Decision_Date_Time__c';

/************************* ALL CLASS METHODS IMPORT STATEMENTS ************************/
import getData from '@salesforce/apex/fsPcAcController.getData';
import sendBackUpdate from '@salesforce/apex/fsPcAcController.sendBackUpdate';
import getCollateralTableRecords from '@salesforce/apex/fsPcAcController.getCollateralTableRecords';
import getFloorTableRecords from '@salesforce/apex/fsPcAcController.getFloorTableRecords';
import getAccounts from '@salesforce/apex/fsPcAcController.getAccounts';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import checkACValidation from '@salesforce/apex/fsPcAcController.checkACValidation';
import checkPCACMobileValidation from '@salesforce/apex/fsPcAcController.checkPCACMobileValidation';
import getCharacterTabRecords from '@salesforce/apex/FIV_C_Controller.getCharacterTabRecords';
import GetCollateralSummary from '@salesforce/apex/fsPcAcController.getCollateralSummary';
import Business_Date from '@salesforce/label/c.Business_Date';
import gettotalBuildingValue from '@salesforce/apex/fsPcAcController.GetBuildingTotalValue';
import getRecordTypeId from '@salesforce/apex/DatabaseUtililty.getRecordTypeId';
import getCapabiltyData from '@salesforce/apex/fsPcAcController.getCapabiltyData';
import getacCapabilitySummary from '@salesforce/apex/fsPcAcController.getacCapabilitySummary';
import getCharacterTableRecords from '@salesforce/apex/fsPcAcController.getCharacterTabRecords';
import getACCollateralTabRecords from '@salesforce/apex/fsPcAcController.getACCollateralTabRecords';
import clonePropertyNew from '@salesforce/apex/FsPreloginController.clonePropertyNew';
import handleFinish from '@salesforce/apex/fsPcAcController.handleFinish';
import savePdf from '@salesforce/apex/FS_DisbursalMemoController.saveDisbursalMemoPDF';
import isDeviationApprovalStage from '@salesforce/apex/pcDeviationController.isDeviationApprovalStage';
import checkInsuranceValidation from '@salesforce/apex/fsPcAcController.checkInsuranceValidation';
import getDecision from '@salesforce/apex/fsPcAcController.getDecision';
import generateCamReport from '@salesforce/apex/CAMReportVfController.generateCamReport';
import checkCAMExistence from '@salesforce/apex/CAMReportVfController.checkCAMExistence';
import getFeeWithoutRepayment from '@salesforce/apex/FeeCreationComponentHelper.getFeeWithoutRepayment';
import saveAllRecordsPCAC from '@salesforce/apex/FS_SaveAndSubmitController.saveAllRecordsPCAC';
import getZeroFee from '@salesforce/apex/FeeCreationComponentHelper.getZeroFee';
import mailResponse from '@salesforce/apex/FS_LMS_CreateCustomerAPI.mailResponse';
import refreshRecords from '@salesforce/apex/FS_DocumentUploadController.refreshRecords';

// Added on 01.05.23 :
import checkBureauVerified from '@salesforce/apex/FsPreloginController.checkBureauVerification';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';

//Added on 15.05.23
import getHMScore from '@salesforce/apex/fsPcAcController.getHMScore';

export default class FsApprovalCreditScreen extends NavigationMixin(LightningElement) {

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
            name: 'SendBack',
            label: 'Send Back',
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
    @track opensendback = false;
    @track loanApplicantList = [];
    @track ownerOptions = [];
    @track propIdList;
    @track newappIdList;
    @track hasPrimaryApplicant = false;
    @track hasPrimaryOwner = false;
    @track isMobileVerified = false;
    @track isKYCVerified = false;
    @track isIncomeConsidered = false;
    @track acccessResultCame = false;
    @track mobDefList;
    @track kycDefList;
    @track bureauPendingList;
    @track primaryAppName;
    @api recordId;
    @track applicationId;
    @track loginId;
    @track fivCrecordId;
    @track fivBrecordId;
    @track pcrecordId;
    @track customerOptions = [];
    @track pCCombo = false;
    @track showPCSubCombo1 = false;
    @track PCSubOptions = [];
    @track preLoginRecordType;
    @track lastLoginDate;
    @track appName;
    @track businessDate = Business_Date;
    @track acspinner = false;
    @track selectedACUser;
    @track selectedACUserName;
    @track usersList;
    @track isRecommend = false;
    @track isReject = false;
    @track sourcingBranch;
    @track decisionValue;
    @track isVerified = false;
    @track dedupeDetails;
    @track requiredDocuments;
    @track pendingdeviationWrapper;
    @track isDeviationRaise = false;
    @track dateTimeVal;
    @track decisionWrapper;
    @track customerDetails = [];




    get decisionOptions() {
        if (this.decisionWrapper) {
            if (this.decisionWrapper.IsApproved) {
                return [{ label: 'Approve', value: 'Approve' },
                { label: 'Recommend to Another AC', value: 'Recommend to Another AC' },
                { label: 'Reject', value: 'Reject' }];
            }
            else if (this.decisionWrapper.L7Approval) {
                return [{ label: 'Approve', value: 'Approve' },
                { label: 'Reject', value: 'Reject' }];
            }
            else {
                return [
                    { label: 'Recommend to Another AC', value: 'Recommend to Another AC' },
                    { label: 'Reject', value: 'Reject' }];
            }
        }
        else {
            return [
                { label: 'Recommend to Another AC', value: 'Recommend to Another AC' },
                { label: 'Reject', value: 'Reject' }];
        }
    }





    // objects 
    @track ObjectNameC;
    @track loanApplicantId;
    @track CustomerName;
    @track stageName = 'AC';
    @track deviationStageName = 'Approval Credit';



    // for Character Section
    @track isFamilyDetails = false;
    @track isNeighbour = false;
    @track isAffiliation = false;
    @track isLivingStandard = false;
    @track isRepaymentBehaviour = false;
    @track showCharacter = false;
    @track showpcCharacterTable = false;
    @track familyTableData;
    @track characterSpinner = false;
    @track loanAmount;
    ///////////////////////////////////


    // for property
    @track propertyDetailsData;
    @track landDetailsData;
    @track buildingDetailsData;
    @track builidngFloorDetails;
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
    @track fivcpropertyId;
    @track propsubValue;
    @track preloginproperty;
    @track fivCAutoPopFields = {
        'mortgage_property_distance': '', 'mortagage_and_living_property': '', 'person_at_mortgage': '', 'living_property_distance': '',
        'living_pincode': '', 'is_living_is_own': ''
    };
    @track landAreaValues = { 'Land_Area': '', 'Market_Value': '' };
    @track buildingAreaValues = { Building_Area: undefined, Building_Value: undefined };
    @track totalBuildingValue;
    @track propertySummaryObj = {
        propertyList: undefined,
        buildingGrandValue: undefined,
        landGrandValue: undefined,
        collateralGrandValue: undefined
    };
    //////////////////////////

    // for financial
    @track isFinancial = false;
    @track finSpinner = false;
    ///////////////////////////


    //for Capability
    @track isSalaried = false;
    @track isRentalMortgage = false;
    @track isRentalOther = false;
    @track isDailyWages = false;
    @track isPension = false;
    @track isAbroadIncome = false;
    @track isOther = false;
    @track isTransportBusiness = false;
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
    @track capabilityRecordId;
    @track Other_Confirmations;
    @track natureofdocumentProof;
    @track natureOfOwnershipProof;
    @track incomeProof;
    @track Other_Confirmations_Daily_Wages;
    @track proofRemarks;
    @track ownershipProof;
    @track ownershipproofEateries
    @track fcEnquiry;
    @track fivcbusinesspincode;
    @track fivcincomepincode;
    @track grossMonthlyIncome;
    /////////////////////////////////

    // for Validation
    @track validationObj;
    @track mobileValidations;
    @track errorMsg;
    @track showErrorTab = false;
    @track tabName = 'Dedupe_Check';
    @track childtabName = 'Capability_Detail';
    //@track receiptWrapper = { hasReceipt: false, allApproved: false, pendingReceiptList: [], lengthOfDirectRec: 0, existingFeeCodeOption: [] };
    @track loadAll = false;
    @track decisionSpinner = false;

    // for Decision Tab
    @track isRemarkRequired = false;
    @track childTab;

    handleChildTab(event) {
        console.log('handleChildTab = ', event.detail);
        this.childTab = event.detail;
    }

    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }


    //check PC Validation
    @api checkAllValidation() {
        console.log('verfId ', this.recordId);
        checkACValidation({ verfId: this.recordId, appId: this.applicationId })
            .then(result => {
                console.log(' Validation result', result);
                this.validationObj = result;
                this.acspinner = false;
            })
            .catch(err => {
                console.log('error in validation', err);
                this.acspinner = false;
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


    // handle Tab Activation --------------------------------
    handleTabActivation(event) {
        this.tabName = event.target.value;
        this.PCSubOptions = undefined;
        this.template.querySelectorAll('.mycombobox').forEach(each => { each.value = null; });
        if (event.target.value == 'Character_Screen') {
            this.showCharacter = false;
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
            this.showPCSubCombo1 = true;
            this.isCollateralSummary = false;
            this.showProperty = true;
        } else if (event.target.value == 'Financial_screen') {
            this.finSpinner = true;
            this.getcollateralSummaryTable();
            if (this.preLoginRecordType == '3. Top-up loan' || this.preLoginRecordType == '4. Tranche loan')
                this.childTab = 'Topup_Details';
            else
                this.childTab = 'Application_details';
            this.isFinancial = true;
        } else if (event.target.value == 'Capability_screen') {
            this.childtabName = 'Capability_Detail';
            // this.handleCapbilitySummary();
        } else if (event.target.value == 'Decision') {
            this.decisionSpinner = true;
            this.handleDecision();
        }
        else if (event.target.value == 'Insurance_Fee') {
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

        } else if (event.target.value == 'Carousal_View') {
        } else if (event.target.value == 'Dedupe_Check') {
            setTimeout(() => {
                this.template.querySelector('c-fsdedupe-details-lwc').getCurrentAppsLoanApp();

            }, 300);
        }
    }

    // handle Tab activation for Capability Section Tabset
    handleCapabilityTabActivation(event) {
        this.childtabName = event.target.value;
        if (event.target.value == 'Capability_Detail') {
            this.capabilitySpinner = true;
            this.capabilityTableData = undefined;
            getRecordTypeId({ sObjectName: 'Capability__c', recordTypeName: 'AC Capability' })
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

    connectedCallback() {
        //code
        this.acspinner = true;
        this.handleRefreshTemplateOnLoad();
        this.getPropertyRecordTypeId();
        this.handleDeviationApproval();
        this.handlegetData(true);
    }

    handleDeviationApproval() {
        isDeviationApprovalStage({ verificationId: this.recordId }).then(result => {
            console.log('Current Record Id ', result);
            if (result) {
                this.isDeviationRaise = true;
                if (this.isDeviationRaise) {
                    this.stageName = 'Deviation Approval';
                    this.btns = this.btns.slice(1, 6);
                }
                this.tabName = 'Deviation';
            }
            console.log('@@## this.isDeviationRaise ', this.isDeviationRaise);
        })
    }

    handleCapbilitySummary() {
        getacCapabilitySummary({ applicationId: this.applicationId })
            .then(res => {
                console.log('CAp Summary>>> ', res);
                let loanType;
                this.HandleHMScoreUpdation();
                console.log('HM Score Called>>>>');
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
                    console.log('FIELDS ###', recordInput);
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


    HandleHMScoreUpdation() {
        //method updated from setHMScore to getHMScore to implement updated logic
        getHMScore({ appId: this.applicationId })
            .then(result => {
                console.log('HM Score Updation method called', result);
            })
            .catch(error => {
                console.log('Error in HM Score Updation', result);
            })
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

    // method used to get Verification Data
    handlegetData(param) {
        getData({ CustomerId: this.recordId, ObjName: 'Verification__c' })
            .then(result => {
                console.log('result>>>>' + JSON.stringify(result[0]));
                result.forEach(element => {
                    if (this.isDeviationRaise)
                        this.deviationStageName = (element.Application__r.Stage__c ? element.Application__r.Stage__c : 'Approval Credit');
                    this.applicationId = element.Application__c;
                    this.loginId = element.Application__r.Pre_Login__c;
                    this.preLoginRecordType = element.Application__r.Pre_Login__r.RecordType.Name;
                    this.appName = element.Application__r.Name;
                    this.loanAmount = element.Application__r.Requested_Loan_Amount__c;
                    this.sourcingBranch = element.Application__r.Sourcing_Branch__c;
                    this.selectedACUser = element.Application__r.AC_User__c;
                    this.selectedACUserName = ( element.Application__r.AC_User__c ? element.Application__r.AC_User__r.Name :'');
                    this.decisionValue = element.Application__r.AC_Decision__c;
                    this.isVerified = element.Application__r.Verified_UN_sanctions_list_and_no_match__c;
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'AC_Decision__c', fieldvalue: this.decisionValue, recordId: this.applicationId });
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'AC_User__c', fieldvalue: this.selectedACUser, recordId: this.applicationId });
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'AC_Remarks__c', fieldvalue: element.Application__r.AC_Remarks__c, recordId: this.applicationId });
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'Verified_UN_sanctions_list_and_no_match__c', fieldvalue: element.Application__r.Verified_UN_sanctions_list_and_no_match__c, recordId: this.applicationId });
                    this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: 'Rejection_Reason__c', fieldvalue: element.Application__r.Rejection_Reason__c, recordId: this.applicationId });

                    if (this.decisionValue == 'Approve') {
                        this.isRemarkRequired = false;
                        this.isRecommend = false;
                        this.isReject = false;
                    }
                    else if (this.decisionValue == 'Recommend to Another AC') {
                        this.isRemarkRequired = false;
                        this.isRecommend = true;
                        this.isReject = false;
                    }
                    else if (this.decisionValue == 'Reject') {
                        this.isRemarkRequired = true;
                        this.isReject = true;
                        this.isRecommend = false;
                    } else {
                        this.isRemarkRequired = false;
                        this.isRecommend = false;
                        this.isReject = false;
                    }
                    if (param == true) {
                        this.getCharacterRecords('PC_Table_Family_Details', 'Family Detail');
                        this.getCharacterRecords('PC_Neighbour_Table', 'Neighbour Detail');
                        this.getCharacterRecords('PC_Affiliation_Table', 'Affiliation Detail');
                        this.getCharacterRecords('PC_LivingStandard_Table', 'Living Standard Detail');
                        this.getCapabilityRecords();
                        this.getAllCollateralRecords();
                        this.handleCapbilitySummary();
                        this.getcollateralSummaryTable();
                        this.fetchLastLoginDate();
                    }
                });
            })
            .catch(error => {
                console.log('errror', error);

            });
    }

    // get the dedupe Details
    getdedupedetails(event) {
        let result = event.detail;
        this.dedupeDetails = JSON.parse(result);
        console.log('Dedupe Details', this.dedupeDetails);
        if (this.dedupeDetails.errorFlag)
            this.errorMsg.push(this.dedupeDetails.message);

    }



    // header buttons selection Event-------------------
    rowselectionevent(event) {
        var detail = event.detail;
        console.log('detail ### ', JSON.stringify(detail));
        if (detail === 'submit') {
            // this.handleACSubmit();
            this.tempSubmit();
        }
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
        if (detail === 'SendBack') {
            this.opensendback = true;
        }
        if (detail === 'Generate_CAM_Report') {
            console.log('Generate CAM Called');
            generateCamReport({ currentApplicationId: this.applicationId, stage: 'Approval Credit' })
                .then(result => {
                    console.log('Cam Report Generated Successfully');
                })
                .catch(error => {
                    console.log('err in generating CAM Report', JSON.parse(JSON.stringify(error)));
                });
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/CAMReportVf?id=' + this.applicationId + '&Generated_From=AC'
                }
            }).then(vfURL => {
                window.open(vfURL);
            });
        }
        if (event.detail === 'pendingReason'){
            this.showHidePendingReasonGrid();
        }
    }

    handlesendbackclose(event) {
        if (event.detail == true)
            this.opensendback = false;
    }

    handlenewlyaddedApplicant(event) {
        console.log('new app id List>>>>>> ', this.newappIdList);
        if (event.detail != undefined)
            this.newappIdList = event.detail;

    }

    checkBureau(event) {
        console.log('check Bureau Verified List', event.detail);
        this.bureauPendingList = event.detail;
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


    // add Property close Event-----

    addpropertyclose() {
        this.isAddProperty = false;
        //this.handlecloneNewPropety();
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
    }

    // ownerValidation close event-----------
    handleclose(event) {
        this.openOwnerValidation = event.detail;
    }

    // handleSendBack Method
    handleSendBack(event) {
        let value = event.detail;
        console.log('value from send Back component');
        if (value != null) {
            this.handlesendBackUpdate();
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.applicationId;
            fields[STAGE_FIELD.fieldApiName] = 'Process Credit';
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    console.log('Send Back Called');
                    this.opensendback = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            variant: 'success',
                            message: 'Application has been Send Back to Process Credit Successfully'
                        })
                    );
                    this.navigateToApplication();
                })
                .catch(error => {
                    console.log(error);
                });
        }
    }

    handlesendBackUpdate() {
        sendBackUpdate({ appId: this.applicationId })
            .then(result => {
                console.log('pc verification status has been changed to pending');
            })
            .catch(error => {
                console.log('Error while doing pc verification status has been changed to pending');
            })
    }



    // event method to get the Total Building Value
    handlegetValue(event) {
        if (event.detail == true)
            this.gettotalValue();

    }

    @api gettotalValue() {
        console.log('total value called!!');
        gettotalBuildingValue({ appId: this.applicationId, recordTypeName: 'AC Property Detail' })
            .then(result => {
                console.log(' total building Values', result);
                if (result)
                    this.totalBuildingValue = result;
            })
            .catch(error => {
                console.log('Error in getting total building Values', error);
            });
    }






    handlePCSubChange(event) {
        console.log('pc sub change called>>>> ' + event.target.value);
        let value = event.target.value;
        this.showCharacter = false;
        this.isFamilyDetails = false;
        this.isNeighbour = false;
        this.isAffiliation = false;
        this.isLivingStandard = false;
        this.isRepaymentBehaviour = false;
        this.isGeneralDetails = false;
        this.isLandAreaAndValuation = false;
        this.isBuildingAreaAndValuation = false;
        this.isCollateralSummary = false;

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
            this.showProperty = true;
            this.showPropertyForm = true;
            this.isGeneralDetails = true;
        }
        else if (value == 'Land_Area_And_Valuation') {
            this.propsubValue = value;
            this.showProperty = true;
            this.showPropertyForm = true;
            this.isLandAreaAndValuation = true;
        }
        else if (value == 'Building_Area_Valuation') {
            this.propsubValue = value;
            this.gettotalValue();
            this.showProperty = true;
            this.showPropertyForm = true;
            this.isBuildingAreaAndValuation = true;
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


    // row selection method for Capability Table
    handleSelectedRow(event) {
        console.log('selected row>>>>> ', JSON.stringify(event.detail));
        this.capabilitySpinner = true;
        let row = event.detail[0];
        this.CustomerName = row.Loan_Applicant__c;
        this.segmentValue = row.Income_segment__c;
        this.subSegmentValue = row.Subsegment__c;
        this.dayorMarginBasis = row.Day_Margin_Basis__c;
        this.fivCrecordId = row.Id;
        this.fivcbusinesspincode = row.BusinessPincode__c;
        this.fivcincomepincode = row.IncomePincode__c;
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

        console.log(this.segmentValue + '<>>>>>>>' + this.subSegmentValue + '<><<<<<' + this.dayorMarginBasis + '>>>>>>>><<<<<<' + this.fivCrecordId);
        if (this.segmentValue != null || this.segmentValue != undefined) {
            this.isSalaried = false;
            this.isDailyWages = false;
            this.isPension = false;
            this.isAbroadIncome = false;
            this.isOther = false;
            this.isSelfEmployedOrBusiness = false;
            this.isEateriesAndOthers = false;
            this.isTransportBusiness = false;
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
                this.isMarginBasis = false;
            } else if (this.dayorMarginBasis == 'Margin Basis') {
                this.isMarginBasis = true;
                this.isDayBasis = false;
            }
        }
        this.showCapability = true;
        this.capabilitySpinner = false;
    }





    handleCustomerChange(event) {
        console.log('LAId' + event.target.value);
        if (event.target.name == 'Customer Info') {
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
            this.getCapabilityTableRecords();
            console.log('cap data', this.capabilityTableData);
        }

    }

    // get collateral summary Table
    getcollateralSummaryTable() {
        GetCollateralSummary({ applicationId: this.applicationId, recTypeName: 'AC Property Detail' })
            .then(result => {
                console.log('in collateral summary result', result);
                if (result && result.length) {
                    var grandcollateralvalue = 0, totalLandValue = 0, totalBuildingValue = 0, totalLandArea = 0, totalBuildingArea = 0;
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
                        grandcollateralvalue += (element.Final_Land_Value__c + (element.Total_Floor_Value__c != undefined ? element.Total_Floor_Value__c : 0));

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





    // to fetch the last Login Date of Logged In User
    fetchLastLoginDate() {
        getLastLoginDate().then(result => {
            console.log('login date ', result);
            if (this.loadAll == false) {
                console.log('i am in check validity');
                let currentTab = this.tabName;
                console.log('currentTab= ', currentTab);
                let tabs = this.template.querySelectorAll('lightning-tab');
                console.log('tabs ', tabs);
                tabs.forEach(element => {
                    if (element.value == 'Insurance_Fee' || element.value == 'Document_Upload' || element.value == 'Deviation' || element.value == 'Financial_screen')
                        element.loadContent();
                });
                console.log('currentTab= ', currentTab);
                this.tabName = currentTab;
                if (tabs && tabs.length) {
                    this.loadAll = true;
                }
            }
            this.lastLoginDate = result;
            this.getAllApplicants();
        })
            .catch(error => {
                console.log('error', error);
                this.getAllApplicants();
            })
    }



    // to get all applicant names of Application
    getAllApplicants() {
        getAccounts({ appId: this.applicationId }).then(result => {
            this.loanApplicantList = [];
            this.customerOptions = [];
            this.ownerOptions = [];
            let data = [];
            let laList = [];
            let owneroptions = [];
            result.forEach(app => {
                data.push({ label: app.Customer_Information__r.Name, value: app.Id });
                laList.push(app.Id);
                owneroptions.push({ label: app.Customer_Information__r.Name, value: app.Id + '_' + app.Customer_Type__c });

                if (app.Customer_Type__c == 'Primary Applicant')
                    this.primaryAppName = app.Customer_Information__r.Name;
            });
            this.customerOptions = data;
            this.loanApplicantList = laList;
            this.ownerOptions = owneroptions;
            console.log('this.CustomerOptions>>>>' + JSON.stringify(this.loanApplicantList));
            console.log('priary App Name', this.primaryAppName);
            this.checkAllValidation();
        })
            .catch(error => {
                console.log('error in getting all Applicants', error);
                this.checkAllValidation();
            });
    }

    // for getting the property table records for property details Section-------
    handleGetCollateralGeneralDetails() {
        this.propertyDetailsData = undefined;
        getCollateralTableRecords({ appId: this.applicationId, metadataName: 'PC_Col_GenDetails' }).then((result) => {
            console.log('handleGetCollateralGeneralDetails= ', JSON.parse(JSON.stringify(result)));
            this.propertyDetailsData = JSON.parse(JSON.stringify(result));
            this.propertyDetailsData.showCheckboxes = false;
            this.propertyDetailsData.treatCheckboxesAsRadio = false;
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
            this.landDetailsData.showCheckboxes = false;
            this.landDetailsData.treatCheckboxesAsRadio = false;
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
            this.buildingDetailsData.showCheckboxes = false;
            this.buildingDetailsData.treatCheckboxesAsRadio = false;
            this.handleGetFloorTableRecords();
            this.propertySpinner = false;
        }).catch((err) => {
            console.log('Error in handleGetCollateralBuildingAreaDetails= ', err);
            this.handleGetFloorTableRecords();
            this.propertySpinner = false;
        });
    }



    // to get the Capability Table Records-----
    getCapabilityTableRecords() {
        this.capabilityTableData = undefined;
        getCapabiltyData({ appId: this.applicationId, recTypeName: 'FIV - C', metadataName: 'PC_Capabilty', caprecordTypeName: 'FIV-C Capability' }).then((result) => {
            console.log('getCapabilityTableRecords= ', result);
            // if (result && result.strDataTableData && JSON.parse(result.strDataTableData).length) {
            this.capabilityTableData = result

            // }
            console.log('cap data', JSON.parse(JSON.stringify(result)));
            this.capabilitySpinner = false;
        }).catch((err) => {
            this.capabilityTableData = undefined;
            console.log('getCapabilityTableRecords Error= ', err);
            this.capabilitySpinner = false;
        });
    }

    // handle change method for Decision Tab
    handleChange(event) {
        let fName = event.target.fieldName ? event.target.fieldName : event.target.name;
        let fValue = event.target.value;
        console.log('value in handle change', fValue);
        if (event.target.fieldName == 'AC_Decision__c') {
            this.decisionValue = fValue;
            if (fValue == 'Approve') {
                this.isRemarkRequired = false;
                this.isRecommend = false;
                this.isReject = false;
            }
            else if (fValue == 'Recommend to Another AC') {
                this.isRemarkRequired = false;
                this.isRecommend = true;
                this.isReject = false;
            }
            else if (fValue == 'Reject') {
                this.isRemarkRequired = true;
                this.isRecommend = false;
                this.isReject = true;
            } else {
                this.isRemarkRequired = false;
                this.isRecommend = false;
                this.isReject = false;
            }
        }
        if (event.target.name == 'AC_User__c') {
            this.selectedACUser = fValue;
            console.log('this selected AC  User', this.selectedACUser);
        }
        this.handlepopulateData({ tabname: 'Decision', subtabname: '', fieldapiname: fName, fieldvalue: fValue, recordId: this.applicationId });

    }


    handleGetFloorTableRecords() {
        this.builidngFloorDetails = undefined;
        getFloorTableRecords({ appId: this.applicationId, propId: '', metadataName: 'PC_Collateral_Floor_Details', calledFrom: 'AC' }).then(result => {
            console.log('handleGetFloorTableRecords= ', JSON.parse(JSON.stringify(result)));
            this.builidngFloorDetails = JSON.parse(JSON.stringify(result));
            this.propertySpinner = false;
        }).catch((err) => {
            console.log('Error in handleGetFloorTableRecords= ', err);
            this.propertySpinner = false;
        });
    }

    handlecheckInputValidity() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    // onsubmit and Onsuccess Method for AC Decision Form
    handleDecisionSubmit(event) {
        this.acspinner = true;
        let checkValidation = this.handlecheckInputValidity();
        console.log('checkValidation --->', checkValidation);
        if (!checkValidation) {
            event.preventDefault();
        }
        else if (this.isRecommend && (this.selectedACUser == undefined && this.selectedACUser == null)) {
            event.preventDefault();
            this.showToast('', 'error', 'You haven\'t Selected any User');
        }
        else {
            let date = new Date().toISOString();
            this.dateTimeVal = date;
        }
        console.log('AC Decision Submit Called');
    }

    handleDecisionSuccess(event) {
        console.log('AC Decision Success Called', event.detail.Id);
        this.showToast('', 'success', 'Decision Submitted Successfully');
        this.checkAllValidation();
        this.handlegetData(false);
        if (this.decisionValue == 'Recommend to Another AC') {
            handleFinish({ appId: this.applicationId, stage: 'AC', verfId: this.recordId, DecisionValue: this.decisionValue }).then(result => {
                console.log('ac recommeded successfully called', result);
                this.acspinner = false;
                this.showToast('', 'success', 'Application has been recommended to another User : ' + this.selectedACUserName);
                this.navigateToApplication();
            })
            .catch(error => {
                console.log(error);
                this.acspinner = false;
            });
        }
        else if (this.decisionValue == 'Reject') {
            var today = new Date().toISOString().slice(0, 10);
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.applicationId;
            fields[STAGE_FIELD.fieldApiName] = 'Approval Credit';
            fields[SUBMISSION_DATE_FIELD.fieldApiName] = today;
            fields[APPLICATION_STATUS.fieldApiName] = 'Rejected';
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                console.log('ac Reject successfully called');
                this.acspinner = false;
                this.showToast('', 'error', 'Application has been Rejected');
                this.navigateToApplication();
            })
            .catch(error => {
                this.acspinner = false;
                console.log(error);
            });
        }

    }

    handleCheckCAMGeneration() {
        checkCAMExistence({ applicationId: this.applicationId, stageName: 'PC' })
            .then(response => {
                console.log('Result of CAM Generation', response);
                if (response)
                    this.isReportGenerated.isCAMGenerated = response;
            })
            .catch(glitch => {
                console.log('Err in checking CAM generation', glitch);
            })

    }




    handlePendingDeviation(event) {
        if (event.detail != null)
            this.pendingdeviationWrapper = event.detail;
        if (this.pendingdeviationWrapper && this.pendingdeviationWrapper.PendingDeviationsExist) {
            if (this.pendingdeviationWrapper.pendingDeviationsList.length) {
                // this.pendingdeviationWrapper.pendingDeviationsList.forEach(dev => {
                this.errorMsg.push('All Deviations are not approved');
                // })
            }
        }
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


    async tempSubmit() {
        this.acspinner = true;
        this.errorMsg = [];
        this.errorMsg = checkValidationPCAC('AC');
        console.log('checkValidationPCAC = ', this.errorMsg);
        // Added on 01.05.23 :
        await checkBureauVerified({appId: this.applicationId }).then(result => {
            console.log('checkBureauVerified= !!',result);
            if (result && result.length) {
                console.log('Push Message Displayed!!');
                result.forEach(applicantName => {
                    this.errorMsg.push('Bureau Verfication Pending For '+applicantName+'!!');
                });                
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Bureau Verification failed ', error);
        })

        await getPendingReasonValidation({applicationId: this.applicationId, stage: 'Approval Credit' }).then(result => {
            console.log('getPendingReasonValidation= !!',result);
            if (result) {
                console.log('getPendingReasonValidation Message Displayed!!');
                this.errorMsg.push('Pending Reasons Not Resolved.');
            }
        }).catch(error => {
            this.isLoading = false;
            console.log('Pending Reasons Not Resolved. ', error);
        })
        await this.handleRerunDeviation();
        this.HandleInsuranceValidation();
        this.dedupeDetails = undefined;
        let dedupeResult = this.template.querySelector('c-fsdedupe-details-lwc').submitDedupeData();
        console.log('dedupeResult ###', dedupeResult);
        this.getFeeWithoutRepayment();
        this.getZeroFee();
        let PendingDeviation = this.template.querySelector('c-pc-deviation');
        if (PendingDeviation)
            PendingDeviation.checkPendingDeviations();

        console.log('Pending Deviations ###', this.pendingdeviationWrapper);
        try {
            this.template.querySelector('c-fs-generic-document-upload-l-w-c').checkAllRequiredDocument();
            console.log('required docs List', this.requiredDocuments);
        } catch (error) {
            console.log(error)
        }

        // setTimeout(() => {
        //this.requiredDocumentValidation();
        // }, 3000);

    }



    handleACSubmit(event) {

        this.acspinner = false;
        let myCmp = this.template.querySelector('c-fee-insurance-parent-p-c-screen');
        console.log('submit called myCmp', myCmp);
        if (myCmp)
            myCmp.getReceipt();
        console.log('Decision Value', this.decisionValue);

        console.log('submit called', this.validationObj);
        //this.errorMsg = [];
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
        console.log('CHK 01');
        // /* Collateral Validation Check */
        // if (this.validationObj.colWrap.PropertyDetails) {
        //     this.errorMsg.push('Please Complete Entry In Property Details Sub Section In Collateral Section');
        // }
        // if (this.validationObj.colWrap.LandArea) {
        //     this.errorMsg.push('Please Complete Entry In Land Area And Valuation Sub Section In Collateral Section');
        // }
        // if (this.validationObj.colWrap.BuildingValuation) {
        //     this.errorMsg.push('Please Complete Entry In Building Area And Extent Sub Section In Collateral Section');
        // }

        // /* Capability Validation Check */
        // if (!this.validationObj.capabilityValidation) {
        //     this.errorMsg.push('Please Complete Entry In Capability Section');
        // }

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
        console.log('CHK 02');


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

        console.log('CHK 03');
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

        console.log('CHK 04');

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

        // decision Validation Error Message
        if (this.decisionValue == null && this.decisionValue == undefined) {
            if (!this.errorMsg.includes('Please Complete Entry In Decision Section'))
                this.errorMsg.push('Please Complete Entry In Decision Section');
        }
        console.log('CHK 05');



        console.log('dedupedetails', this.dedupeDetails);

        console.log('showErrorTab errorMsg = ', this.errorMsg);
        if (this.errorMsg && this.errorMsg.length) {
            this.showErrorTab = true;
            let ref = this;
            setTimeout(() => {
                ref.tabName = 'Error';
            }, 300);
        } else {
            this.showErrorTab = false;
            this.acspinner = true;
            this.handleacSubmission();
        }
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

    callLmsApiClass() {
        mailResponse({ responseData: JSON.stringify(this.customerDetails) })
            .then(result => {
                console.log('inside mail method');
            })
            .catch(error => {
                console.log('Error', error);
                this.acspinner = false;
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
                this.acspinner = false;
                this.callLmsApiClass(); //incase if error occurs create apilogger 
            }
        }

    }

    updateStageAfterCustomerCreation() {
       
        this.showErrorTab = false;
        this.handleDiscussionMemoGeneration();
        this.submitAcStage(); // errors are over submit pc stage
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

    handleacSubmission() {
        this.acspinner = true;
        this.callCreateCustomerAPi();
    }




    // ac submission to next stage
    submitAcStage() {
        console.log('data $$$', ac_data_template);
        saveAllRecordsPCAC({ jsonStr: JSON.stringify(ac_data_template) }).then((result) => {
            console.log('saveAllRecordsPCAC success = ', result);
            if (result == 'success') {
                var today = new Date().toISOString().slice(0, 10);
                console.log('today date', today);
                if (this.decisionValue == 'Approve') {
                    handleFinish({ appId: this.applicationId, stage: 'AC', verfId: this.recordId, DecisionValue: this.decisionValue }).then(result => {
                        console.log('ac finish successfully called', result);
                        const fields = {};
                        fields[ID_FIELD.fieldApiName] = this.applicationId;
                        fields[SUBMISSION_DATE_FIELD.fieldApiName] = today;
                        if (this.validationObj.isLegalApprovalCompleted) {
                            fields[STAGE_FIELD.fieldApiName] = 'Final Sanction';
                            const recordInput = { fields };
                            updateRecord(recordInput)
                                .then(() => {
                                    console.log('ac finish successfully called', result);
                                    if (this.decisionValue == 'Approve')
                                        this.showToast('Success', 'success', 'Approval Credit Completed Successfully');
                                    this.acspinner = false;
                                    this.navigateToApplication();
                                })
                                .catch(error => {
                                    console.log(error);
                                    this.acspinner = false;
                                });
                        }
                        else {
                            console.log('ac finish successfully called', result);
                            fields[STAGE_FIELD.fieldApiName] = 'Awaiting Legal Approval';
                            if (this.validationObj.LegalApprovalOnwer != null && this.validationObj.LegalApprovalOnwer != undefined && this.validationObj.LegalApprovalOnwer != '')
                                fields[OWNER_ID.fieldApiName] = this.validationObj.LegalApprovalOnwer;
                            const recordInput = { fields };
                            updateRecord(recordInput)
                                .then(() => {
                                    console.log('ac finish successfully called', result);
                                    if (this.decisionValue == 'Approve')
                                        this.showToast('Success', 'success', 'Approval Credit Completed Successfully');
                                    this.acspinner = false;
                                    this.navigateToApplication();
                                })
                                .catch(error => {
                                    console.log(error);
                                    this.acspinner = false;
                                });
                        }
                        this.handleRefreshAllDocuments();

                    })
                        .catch(err => {
                            this.acspinner = false;
                            console.log('ac finish error called', err);
                        })
                }
            }
        }).catch((err) => {
            this.acspinner = false;
            console.log('saveAllRecordsPCAC Error = ', err);
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

    // document upload Validation Methods
    handleRequiredDocument(event) {
        console.log('required doc list :: ', JSON.stringify(event.detail));
        this.requiredDocuments = event.detail;

        this.requiredDocumentValidation();
        setTimeout(() => {
            this.handleACSubmit();
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

    // method used to check the loan Approval Access to submit Decision
    handleDecision() {
        getDecision({ SourcingBranch: this.sourcingBranch, appId: this.applicationId })
            .then(result => {
                console.log('Decision result #=>', result);
                let acuserOptions = [];
                if (result)
                    this.decisionWrapper = result;
                if (this.decisionWrapper.ACUserList) {
                    this.decisionWrapper.ACUserList.forEach(curr => {
                        acuserOptions.push({ label: curr.Name, value: curr.Id });
                    })
                }
                this.usersList = acuserOptions;
                this.decisionSpinner = false;
            })
            .catch(error => {
                console.log('error ', error);
                this.decisionSpinner = false;
            })
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

    //Method to Update Decision Date Time Field to rerun Deviation...
    async handleRerunDeviation() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.applicationId;
        fields[DECISION_DATE_TIME.fieldApiName] = new Date().toISOString();
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('Decision Date Time Updated Sucessfully..');
            })
            .catch(error => {
                console.log('Error in Decision Date Time Updated Sucessfully..', error);
            });

    }

    // Method used to generate the Discussion memo at the time of submission
    handleDiscussionMemoGeneration() {
        savePdf({ applicationId: this.applicationId, stageName: 'Approval Credit' }).then(result => {
            console.log('Discussion Memo Generated Successfully', result);
        })
            .catch(err => {
                console.log('Error in Discussion Memo Generation', err);
            })

    }



    // Methods to handle Population of Data in the Data Template used in Partial Save and Save on Submit.....

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
        populateData('AC', data.tabname, data.subtabname, data.fieldapiname, fValue, 'Id', data.recordId);
        console.log('populate dataaa', ac_data_template);
    }

    handleRemoveData(data) {
        removeData('AC', data.tabname, data.subtabname);
        console.log('removee111 dataaa', ac_data_template);
    }

    handleRefreshAllDocuments(){
        refreshRecords({applicationId : this.recordId}).then((result) => {
            console.log('Result RefreshRecords = ',result);
        }).catch((err) => {
            console.log('Handle Error RefreshRecords = ',err);
        });
    }

    // for getting the character table records------
    getCharacterRecords(metadataName, secName) {
        this.charTableData = undefined;
        getCharacterTableRecords({ appId: this.applicationId, metadataName: metadataName, sectionName: secName, recType: 'AC' }).then((result) => {
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
        getCapabiltyData({ appId: this.applicationId, recTypeName: 'AC', metadataName: 'PC_Capabilty_Table', caprecordTypeName: 'AC Capability' }).then((result) => {
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
        getACCollateralTabRecords({ appId: this.applicationId, recordTypeName: 'AC Property Detail' }).then(result => {
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