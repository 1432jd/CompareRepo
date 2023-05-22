import { LightningElement, track, api, wire } from 'lwc';
import getLastLoginDate from '@salesforce/apex/DatabaseUtililty.getLastLoginDate';
import APPLICATION_OBJECT from '@salesforce/schema/Application__c';
import FILEINWARDSTATUS from '@salesforce/schema/Application__c.File_Inward_Status__c';
import STORAGEVENDORNAME from '@salesforce/schema/Application__c.Storage_Vendor_Name__c';
import FILESTATUS from '@salesforce/schema/Application__c.File_Status__c';
import NAME from '@salesforce/schema/Application__c.Name';
import { getRecord } from 'lightning/uiRecordApi';
import checkAccess from '@salesforce/apex/FsCustodyController.checkAccess';
import createRecords from '@salesforce/apex/FsCustodyController.createRecords';
import getUsers from '@salesforce/apex/FsCustodyController.getUsers';
import getRepaymentDoc from '@salesforce/apex/FsCustodyController.getRepaymentDoc';
import getSource from '@salesforce/apex/FsCustodyController.getSource';
import getExistingRecord from '@salesforce/apex/FsCustodyController.getExistingRecord';
import getAccess from '@salesforce/apex/FsCustodyController.getAccess';
import BusinessDate from '@salesforce/label/c.Business_Date';
import DocChecker from '@salesforce/label/c.Custody_Document_Checker_Required';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import submitApplications from '@salesforce/apex/FsCustodyController.submitApplications';
//Build 4
import getPendingReasonValidation from '@salesforce/apex/FS_PendingReasonController.getPendingReasonValidation';

export default class FsCustodyLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track lastLoginDate;
    @track todaysDate = BusinessDate;
    @track documentChecker = DocChecker;
    @api applicationNo = 'App-101';
    @track fileinwardPicklistValues = [];
    @track sourcepik = [];
    @track applicationName;
    @track createCustody = true;
    @track storageVendorPicklistValues = [];
    @track fileStatusPicklistValues = [];
    @track showfooter = false;
    @track tabName;
    @track isSpinner = true;
    @track criteria;
    @api custId;
    @track isloaded = false;
    @track sourceName;
    @track showerrorcustomer = false;
    @track showerrorApp = false;
    @track showerrorBranch = false;
    @track showerrorMakerId = false;
    @track showerrorCheckrId = false;
    @track fileInwardUser = false;
    @track custodyStorageUser = false;
    @track checkerUser = false;
    @track makerUser = false;
    @track docId;
    @track loanAppName;
    @track stageName = 'Document Maker';
    @track disval = false;
    @track vdcMaker = false;
    @track isChanged = false;
    @track vdcMakerStage = false;
    @track vdcCheckerStage = false;
    @track hideSubmit = true;
    @track fieldOfficerEMPId;
    @track isReadOnly = false;
    @track hasAccess = false;
    @track fieldOfficerMakerId;
    @track makerCriteria;
    @track isOnlyRead;

    @track btns = [
        {
            name: 'WelcomeLetter',
            label: 'Welcome Letter',
            variant: 'brand',
            class: 'slds-m-left_x-small'

        },
        {
            name: 'RepaymentSchedule',
            label: 'Repayment Schedule',
            variant: 'brand',
            class: 'slds-m-left_x-small'

        }
    ]
    @track btns1 = [
        {
            name: 'Submit',
            label: 'Submit',
            variant: 'brand',
            class: 'slds-m-left_x-small',
            //disable: this.sumbitDisable

        },
        {
            name: 'pendingReason',
            label: 'Pending Reason',
            variant: 'brand',
            class: 'slds-m-left_x-small'
        }
    ]

    @track showPendingReason = false;



    /* commented to get detail from application: @ Sangeeta yadav : 20 dec 22
        @track wrpObj = {
            Id: undefined,
            Loan_Account_Number__c: undefined,
            State__c: undefined,
            Old_Application_Number__c: undefined,
            File_Inward_Status__c: undefined,
            Disbursement_Date__c: undefined,
            Stage_in_Date__c: undefined,
            Application_Type__c: undefined,
            Remarks__c: undefined,
            Maker__c: undefined,                 //maker remarks
            Checker_Remarks__c: undefined,
            Handoff_Date__c: undefined,
            File__c: undefined,                  //file bar code
            Box_Bar_Code__c: undefined,
            Storage_Vendor_Name__c: undefined,
            File_Status__c: undefined,
            Application_Number__c: undefined,
            Branch_Name__c: undefined,
            Customer_Name__c: undefined,
            Checker_Id__c: undefined,
            Maker_Id__c: undefined,
        };*/

    @track wrpObj = {
        Id: undefined,
        LMS_Response_Reference__c: undefined,
        //State__c: undefined,
        //Old_Application_Number__c: undefined,
        File_Inward_Status__c: undefined,
        Disbursal_Date__c: undefined,
        Stage_in_Date__c: undefined,
        //Application_Type__c: undefined,
        Remarks__c: undefined,
        VDC_Maker_Remarks__c: undefined,                 //maker remarks
        VDC_Checker_Remarks__c: undefined,
        Handoff_Date__c: undefined,
        File_Bar_Code__c: undefined,                  //file bar code
        Box_Bar_Code__c: undefined,
        Storage_Vendor_Name__c: undefined,
        File_Status__c: undefined,
        //Application_Number__c: undefined,
        //Branch_Name__c: undefined,
        //Customer_Name__c: undefined,
        VDC_Checker_Id__c: undefined,
        VDC_Maker_Id__c: undefined,
        Stage__c: undefined
    };

    @track currentDate;

    connectedCallback() {
        this.checkAccess();
        this.isOnlyRead = true;
        this.currentDate = new Date().toISOString();
        //this.wrpObj.Application_Number__c = this.recordId;
        //this.wrpObj.Old_Application_Number__c=this.recordId;
        this.getExistingRecord();
        console.log('vdcMaker', this.vdcMaker);
        this.getSource();
        //   this.getUsers();
        this.getAccess();
        this.handleGetLastLoginDate();
    }


    showHidePendingReasonGrid() {
        this.showPendingReason = (!this.showPendingReason);
    }
    checkAccess() {

        checkAccess({ recordId: this.recordId }).then((result) => {
            console.log('inside the getapp click >>', result);
            if (result != null) {
                this.hasAccess = true;
            }
        }).catch((err) => {
            this.isSpinner = false;
            console.log('Error in getExistingRecord= ', err);
        });

    }

    getAccess() {
        getAccess().then((result) => {
            this.tabName = 'VDC';
            this.makerUser = true;
            this.checkerUser = true;


        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });

    }

    async getExistingRecord() {
        if (this.recordId) {
            await getExistingRecord({ recordId: this.recordId }).then((result) => {
                console.log('record id >>' + this.recordId);
                console.log('inside record')

                console.log('getExistingRecord>>> ', result);
                if (result) {

                    this.wrpObj = JSON.parse(JSON.stringify(result));
                    console.log('this.wrpObj>>> ', this.wrpObj);
                    if (!this.wrpObj.Storage_Vendor_Name__c) {
                        this.wrpObj.Storage_Vendor_Name__c = 'Crown';
                    }
                    //this.wrpObj.Customer_Name__c = result.Primary_Applicant__c;
                    console.log('WrpObj', this.wrpObj);
                    this.wrpObj.Stage__c = result.Stage__c;
                    //if(this.wrpObj.Stage__c =='VDC Checker'){
                    this.isReadOnly = false;
                    // }
                    this.criteria = 'NAME_DC' + '/' + result.Sourcing_Branch__c;
                    this.fieldOfficerEMPId = result.VDC_Checker_Id__c;
                    console.log('result.VDC_Maker_Id__c >>>', result.VDC_Maker_Id__c);
                    if (result.VDC_Maker_Id__c) {
                        this.makerCriteria = 'DocMaker';
                        this.fieldOfficerMakerId = result.VDC_Maker_Id__c;
                        console.log('inside if of getuser', this.fieldOfficerMakerId);
                    } else {
                        console.log('inside else of getuser');
                        this.getUsers();
                    }
                    console.log('the this.fieldOfficerEMPId is >>>>', this.fieldOfficerEMPId);
                    console.log('the criteria is >>>>', this.criteria);
                    //  this.stageName = result.Stage__c;
                    console.log('this.wrpObj.Stage__c', this.wrpObj.Stage__c);
                    //console.log('customer_NAME', this.wrpObj.Customer_Name__c);
                    console.log('application stage', result.Stage__c);
                    //  if(result.Stage__c == 'VDC Maker' || result.Stage__c == 'VDC Checker'){
                    this.vdcMaker = true;
                    // if(result.Stage__c == 'VDC Maker'){
                    this.vdcMakerStage = true;
                    this.vdcCheckerStage = false;
                    //}
                    /* else if(result.Stage__c == 'VDC Checker'){
                         this.vdcCheckerStage = true;
                         this.vdcMakerStage = false;
                     }
                     else{
                         this.vdcMakerStage = false;
                         this.vdcCheckerStage = false;
                     }*/
                    // }
                    /* else if(result.Stage__c == 'Vendor Handoff'){
                         this.vdcMaker = false;
                     }*/
                    this.isSpinner = true;
                } else {
                    this.isSpinner = true;
                } /*else {
                    if(!this.wrpObj.Storage_Vendor_Name__c){
                        this.wrpObj.Storage_Vendor_Name__c='Crown';
                    }
                    this.isloaded = true;

                }*/
            }).catch((err) => {
                this.isloaded = true;
                console.log('Error in getExistingRecord= ', err);
            });
        } else {
            this.isloaded = true;
        }


    }

    getSource() {
        getSource({ recordId: this.recordId }).then((result) => {

            if (result) {

                const appSource = result.split("#");

                /* if (!this.wrpObj.Branch_Name__c) {
                     if (appSource[0] !== 'null') {
                         this.wrpObj.Branch_Name__c = appSource[0];
                     } else {
                         this.showerrorBranch = true;
                     }
                 }*/

                /*if (!this.wrpObj.State__c) {
                    if (appSource[1] !== 'null') {
                        this.wrpObj.State__c = appSource[1];
                    }
                }*/
                /* if (!this.wrpObj.Application_Type__c) {
                     this.wrpObj.Application_Type__c = appSource[2];
                 }*/

                if (!this.wrpObj.LMS_Response_Reference__c) {
                    this.wrpObj.LMS_Response_Reference__c = appSource[3];
                }

                /*if (!this.wrpObj.Customer_Name__c) {
                    if (appSource[4] !== 'null' && appSource[4] != "") {
                        this.wrpObj.Customer_Name__c = appSource[4];
                        this.custId = appSource[4];
                    } else {
                        this.showerrorcustomer = true;
                    }

                } else {
                    this.custId = this.wrpObj.Customer_Name__c;
                }*/
            }
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });

    }

    handleSelectedEMPId(event) {
        // console.log('fieldOfficerEMPId ',event.detail[0].id);
        if (event.detail.length > 0) {
            this.fieldOfficerEMPId = event.detail[0].id;
        } else {
            this.fieldOfficerEMPId = undefined;
        }
    }

    getUsers() {
        getUsers().then((result) => {
            if (result) {
                // const myArray = result.split("#");
                this.wrpObj.VDC_Maker_Id__c = result;
                this.makerCriteria = 'DocMaker';
                this.fieldOfficerMakerId = result;
                // if (!this.wrpObj.VDC_Checker_Id__c) {
                //   this.wrpObj.VDC_Checker_Id__c = myArray[0];
                // }
                // if (!this.wrpObj.VDC_Maker_Id__c) {
                // this.wrpObj.VDC_Maker_Id__c = myArray[1];
                //}
            }
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });
    }




    // This Method Is Used To Get User's Last Login Date From Server Side.
    handleGetLastLoginDate() {
        getLastLoginDate().then((result) => {
            console.log('getLastLoginDate= ', result);
            this.lastLoginDate = result
        }).catch((err) => {
            console.log('Error in getLastLoginDate= ', err);
        });
    }
    @wire(getObjectInfo, { objectApiName: APPLICATION_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FILEINWARDSTATUS
    })
    wiredFILEINWARDSTATUSPickListValues({ error, data }) {
        if (data) {
            console.log('gender' + JSON.stringify(data));
            this.fileinwardPicklistValues = [{ label: 'None', value: '' }, ...data.values];
        } else if (error) {
            this.fileinwardPicklistValues = undefined;
            console.log('Picklist values are ${error}');
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STORAGEVENDORNAME
    })
    wiredSTORAGEVENDORNAMEPickListValues({ error, data }) {
        if (data) {
            console.log('gender' + JSON.stringify(data));
            this.storageVendorPicklistValues = [{ label: 'None', value: '' }, ...data.values];
        } else if (error) {
            this.storageVendorPicklistValues = undefined;
            console.log('Picklist values are ${error}');
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FILESTATUS
    })
    wiredFILESTATUSPickListValues({ error, data }) {
        if (data) {
            console.log('gender' + JSON.stringify(data));
            this.fileStatusPicklistValues = [{ label: 'None', value: '' }, ...data.values];
        } else if (error) {
            this.fileStatusPicklistValues = undefined;
            console.log('Picklist values are ${error}');
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME] })
    applicationDetails({ error, data }) {
        console.log('applicationDetails= ', data);
        if (data) {
            this.applicationName = data.fields.Name.value;
        } else if (error) {
            console.log('error in getting applicationDetails = ', error);
        }
    }

    handleActive(event) {
        this.tabName = event.target.value;
        if (this.tabName === 'VendorHandoff') {
            this.showfooter = true;

        } else {
            this.showfooter = false;
            if (this.tabName === 'VDC') {
                this.hideSubmit = false;
            }
            else {
                this.hideSubmit = true;
            }
        }
    }

    handleFormValues(event) {
        this.wrpObj[event.target.name] = event.target.value;
        this.createCustody = true;
        this.isChanged = true;
    }

    handleOnChangeApp(event) {
        //  this.wrpObj.Application_Number__c = event.detail;
        this.createCustody = true;
        this.showerrorApp = false;
        console.log('this.wrpObj >>>' + JSON.stringify(this.wrpObj));

    }

    handleOnChangeOldApp(event) {

        try {
            //console.log('detail is >>'+event.detail);
            // this.wrpObj.Old_Application_Number__c = event.detail;
            this.createCustody = true;
            console.log('this.wrpObj >>>' + JSON.stringify(this.wrpObj));
        } catch (err) {

            console.log('err is>>' + err.message);
            console.log('detail is >>' + event.detail);
        }

    }


    /*handleOnChangeBranch(event) {
        this.wrpObj.Branch_Name__c = event.detail;
        this.createCustody = true;
        this.showerrorBranch = false;
        console.log('this.wrpObj >>>' + JSON.stringify(this.wrpObj));

    }*/
    handleOnChangeCustomerName(event) {
        //this.wrpObj.Customer_Name__c = event.detail;
        this.createCustody = true;
        this.showerrorcustomer = false;
        console.log('this.wrpObj >>>' + JSON.stringify(this.wrpObj));

    }
    handleOnChangeChecker(event) {
        this.wrpObj.VDC_Checker_Id__c = event.detail;
        this.createCustody = true;
        this.showerrorCheckrId = false;
        console.log('this.wrpObj >>>' + JSON.stringify(this.wrpObj));

    }
    handleOnChangeMaker(event) {
        this.wrpObj.VDC_Maker_Id__c = event.detail;
        this.showerrorMakerId = false;
        this.createCustody = true;
        console.log('this.wrpObj >>>' + JSON.stringify(this.wrpObj));

    }
    removehandleOnChangeCust() {
        this.showerrorcustomer = true;
    }
    removehandleOnChangeOldApp() {
        this.showerrorOldApp = true;
    }

    removehandleOnChangeApp() {
        this.showerrorApp = true;
    }

    removehandleOnChangeMaker() {
        this.showerrorMakerId = true;
    }

    removehandleOnChangeChecker() {
        this.showerrorCheckrId = true;
    }

    removehandleOnChangeBranch() {
        this.showerrorBranch = true;
    }

    handleCheckValidity() {
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
        const allValid3 = [
            ...this.template.querySelectorAll('lightning-dual-listbox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid4 = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return (allValid1 && allValid2 && allValid3 && allValid4);
    }

    handleletterpdf() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/Welcome_Letter?id=' + this.recordId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }

    handlerepaymentpdf() {

        getRepaymentDoc({ recordId: this.recordId }).then((result) => {

            this.docId = result;

            if (this.docId) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state: {
                        recordIds: this.docId
                    }
                });

            } else {

                this.showToast('Error', 'FILE not found', 'error');
            }
        }).catch((err) => {
            console.log('Error in getExistingRecord= ', err);
        });
    }





    handleSave() {
        this.isShowSpinner = false;
        if (!this.fieldOfficerEMPId) {
            this.showToast('Error', 'Checker Id is mandatory', 'Error');
            //   this.showNotification('Error', 'Missing Field Disbursal Author Id!!', 'Error');
            return;
        }
        let allValid = this.handleCheckValidity();
        if (!allValid) {
            return;
        }
        console.log('app' + this.showerrorApp);
        console.log('app' + this.showerrorcustomer);
        console.log('app' + this.showerrorBranch);
        if ((this.tabName === 'VendorHandoff') || (this.tabName === 'VDC' && this.showerrorCheckrId == false && this.showerrorMakerId == false)) {

            this.isSpinner = false;
            console.log('id wrap is >>' + this.wrpObj.Id);
            var tempCourierObject = {
                Id: this.wrpObj.Id,
                LMS_Response_Reference__c: this.wrpObj.LMS_Response_Reference__c,
                //State__c: this.wrpObj.State__c,
                // Old_Application_Number__c: this.wrpObj.Old_Application_Number__c,
                File_Inward_Status__c: this.wrpObj.File_Inward_Status__c,
                Disbursal_Date__c: this.wrpObj.Disbursal_Date__c,
                Stage_in_Date__c: this.wrpObj.Stage_in_Date__c,
                //Application_Type__c: this.wrpObj.Application_Type__c,
                Remarks__c: this.wrpObj.Remarks__c,
                VDC_Maker_Remarks__c: this.wrpObj.VDC_Maker_Remarks__c,
                VDC_Checker_Remarks__c: this.wrpObj.VDC_Checker_Remarks__c,
                Handoff_Date__c: this.wrpObj.Handoff_Date__c,
                File_Bar_Code__c: this.wrpObj.File_Bar_Code__c,
                Box_Bar_Code__c: this.wrpObj.Box_Bar_Code__c,
                Storage_Vendor_Name__c: this.wrpObj.Storage_Vendor_Name__c,
                File_Status__c: this.wrpObj.File_Status__c,
                // Application_Number__c: this.wrpObj.Application_Number__c,
                //Branch_Name__c: this.wrpObj.Branch_Name__c,
                //Customer_Name__c: this.wrpObj.Customer_Name__c,
                VDC_Checker_Id__c: this.fieldOfficerEMPId,
                VDC_Maker_Id__c: this.wrpObj.VDC_Maker_Id__c,
            };
            createRecords({ wrpObject: JSON.stringify(tempCourierObject) })
                .then(result => {
                    console.log('result', result);
                    this.isSpinner = true;
                    this.wrpObj.Id = result;
                    this.showToast('Success', 'Record saved successfully', 'success');
                    console.log('this.recordId', this.recordId);
                    setTimeout(() => {
                        eval("$A.get('e.force:refreshView').fire();");
                    }, 1);
                    this.isChanged = false;
                    //this.tabName = 'VDC;
                })
                .catch(error => {
                    this.showToast('Error', error, 'error');
                    console.log('Error', error);
                    this.isSpinner = true;
                });
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message

        });
        this.dispatchEvent(event);

    }
    rowselectionevent(event) {
        var detail = event.detail;
        if (detail === 'WelcomeLetter') {
            this.handleletterpdf();
        }
        if (detail === 'RepaymentSchedule') {
            this.handlerepaymentpdf();
        }
    }
    rowselectioneventSubmit(event) {
        var detail = event.detail;
        if (detail === 'Submit') {
            var pendingStage = this.stageName === 'Document Maker' ? 'VDC Maker' : 'VDC Checker';
            getPendingReasonValidation({ applicationId: this.recordId, stage: pendingStage }).then(result => {
                console.log('getPendingReasonValidation= !!', result);
                if (result) {
                    console.log('getPendingReasonValidation Message Displayed!!');
                    this.showToast('Error', 'Pending Reasons Not Resolved.', 'error');
                    return;
                }
                else{
                    this.handleSubmit();
                }
            }).catch(error => {
                console.log('Pending Reasons Not Resolved. ', error);
            })
        }
        if (event.detail === 'pendingReason') {
            this.showHidePendingReasonGrid();
        }
    }
    handleSubmit() {
        this.isSpinner = false;
        console.log('dataWrapper', JSON.stringify(this.applicationData), 'checker required', DocChecker);
        var allValid = this.handleCheckValidity();
        if (this.tabName == 'Docs' && (this.vdcCheckerStage == true && (this.wrpObj.VDC_Checker_Remarks__c == null || this.wrpObj.VDC_Checker_Remarks__c == '' || this.wrpObj.VDC_Checker_Remarks__c == undefined)) || (this.vdcMakerStage == true && (this.wrpObj.VDC_Maker_Remarks__c == null || this.wrpObj.VDC_Maker_Remarks__c == '' || this.wrpObj.VDC_Maker_Remarks__c == undefined))) {
            this.showToast('Error', 'Please fill all required details in VDC - Vault Deposit C tab', 'error');
            this.isSpinner = true;
        }
        else {
            if (!allValid) {
                this.showToast('Error', 'Please fill all required details in VDC - Vault Deposit C tab', 'error');
                this.isSpinner = true;
            }
            else {

                if (this.isChanged == true) {
                    this.showToast('Error', 'Please save all the changes', 'error');
                    this.isSpinner = true;
                }
                else {
                    console.log('all valid');
                    var tempCourierObject = {
                        Id: this.wrpObj.Id,
                        Stage__c: this.wrpObj.Stage__c
                    }
                    submitApplications({ dataWrapper: JSON.stringify(tempCourierObject), DocChecker: DocChecker })
                        .then(res => {
                            console.log('saveObligations', res);
                            if (res == 'success') {

                                this.navigateApptList();
                                this.showToast('Success', 'Records Submitted Successfully', 'success');
                                this.isSpinner = true;
                            } else if (res == 'error') {
                                //this.showToast('Error', 'error', 'Error in Saving Records');
                                this.showToast('Error', 'Error in Submit', 'error');
                                this.isSpinner = true;
                            }
                        })
                        .catch(err => {
                            //this.showToast('Error', 'error', 'Error in Saving Records');
                            this.showToast('Error', 'Error in Submit', 'error');
                            this.isSpinner = true;
                        })
                }

            }
        }
    }

    navigateApptList() {
        /* this[NavigationMixin.Navigate]({
             type: 'standard__objectPage',
             attributes: {
                 objectApiName: 'Application__c',
                 actionName: 'list'
             }
         });*/
        window.location.replace('/' + this.recordId);
    }
}