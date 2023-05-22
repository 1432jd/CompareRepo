import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccData from '@salesforce/apex/FetchDataTableRecordsController.getAccData';
//import kycAPICallout from '@salesforce/apex/KYCAPIController.kycAPICallout';
import kycVerifyAPICallout from '@salesforce/apex/KYCAPIController.kycVerifyAPICallout';
import updateLoanApplicant from '@salesforce/apex/KYCAPIController.updateLoanApplicant';
import getKYCStatusOfLoanApplicant from '@salesforce/apex/KYCAPIController.getKYCStatusOfLoanApplicant';

import getDocumentPublicList from '@salesforce/apex/FsPreloginController.getDocumentPublicList';
import { CloseActionScreenEvent } from 'lightning/actions';

//Added on 28.04.23 : For Highmark Callout
import doHighmarkCallout from '@salesforce/apex/BureauHighmartAPICalloutController.doHighmarkCallout';

export default class FsCustomerDetails extends LightningElement {

    @api customerTypeValue;
    @api verificationTypeValue;
    @api ocrTable;
    @api applicationId;
    @api preloginId;
    @api ownerTypeOption = [];
    @api loanAppWrapper = { accountId: '', loanAppId: '' };
    @api recordIds;
    @api loanAppId;
    @api accountId;
    @api loanAppIdList = [];
    @api loanData = [];
    @api recTypeName;
    @api validation;

    @track submitWrapper = { hasPrimaryApplicant: '', isMobileVerified: '', isKYCVerified: '', isIncomeConsidered: '', mobDefList: '', kycDefList: '' }
    @track isAccDataArrived = false;
    @track showCustomerInfoForm = false;
    @track accData = [];
    @track showDeletePopup = false;
    @track showMobileVerification = false;
    @track hasPrimaryApplicant = false;
    @track isIncomeConsidered = false;
    @track countTrue = 0;
    @track countKYCTrue = 0;
    @track mobVerificationList = [];
    @track kycVerificationList = [];
    @track validMobile = false;
    @track validKYC = false;
    @track isSpinnerActive = false;
    @track showKYCDocsPopup = false;
    @track imageLinks = [];
    @track kycNotExecutedLoanApplicants = [];
    @track loanAppMobile;
    @track accRowAction = [
        {
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
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:delete',
                title: 'Delete',
                variant: 'border-filled',
                alternativeText: 'Delete',
                name: 'delete'
            }
        },
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:live_message',
                title: 'Verify Mobile',
                variant: 'border-filled',
                alternativeText: 'Verify Mobile',
                name: 'verify'
            }
        },
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:asset_audit',
                title: 'Validate KYC',
                variant: 'border-filled',
                alternativeText: 'Validate KYC',
                name: 'validate'
            }
        },
        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:preview',
                title: 'Preview KYC Docs',
                variant: 'border-filled',
                alternativeText: 'Preview KYC Docs',
                name: 'preview'
            }
        },

        //Added on 28.04.23 : Intiate Bureau Button

        {
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:contract',
                title: 'Initiate Bureau',
                variant: 'border-filled',
                alternativeText: 'Initiate Bureau',
                name: 'initiate'
            }
        }
    ];

    connectedCallback() {
        console.log('fsCustomerDetailsCalled!!', this.applicationId);
        if (this.applicationId)
            this.getAccountData(this.applicationId);
    }

    @api getRecordType(recType) {
        this.recTypeName = recType;
    }

    @api getAccountData(applicationId) {
        console.log('get Acc data called!!', applicationId);
        this.isAccDataArrived = false;

        getAccData({ applicationId: applicationId })
            .then(result => {
                var primaryAppName = '';
                this.ownerTypeOption = [];
                this.hasPrimaryApplicant = false;
                this.isIncomeConsidered = false;
                this.countTrue = 0;
                this.countKYCTrue = 0;
                this.mobVerificationList = [];
                this.kycVerificationList = [];
                this.validMobile = false;
                this.validKYC = false;
                console.log('getacc data in customer screen');
                console.log('json data ====> ' + JSON.stringify(result));
                this.accData = [];
                this.accData = result;
                this.isAccDataArrived = true;
                var temp = JSON.parse(result.strDataTableData);
                this.loanData = temp;
                if (this.template.querySelector('c-fs-loan-applicant-information'))
                    this.template.querySelector('c-fs-loan-applicant-information').getDataTableInfo(JSON.parse(result.strDataTableData));
                for (var i in temp) {
                    var dataResult = temp[i];
                    console.log('Loan App Id ', dataResult['Id']);
                    if (!this.loanAppIdList.includes(dataResult['Id'])) {
                        this.loanAppIdList.push(dataResult['Id']);
                    }
                    if (dataResult['Customer_Type__c'] === 'Primary Applicant') {
                        this.hasPrimaryApplicant = true;
                        primaryAppName = dataResult['Customer_Information__r_FirstName_LABEL'] + ' ' + dataResult['Customer_Information__r.LastName'];
                    }
                    if (dataResult['Income_Considered__c'] === 'Yes') {
                        this.isIncomeConsidered = true;
                    }
                    if (dataResult['Mobile_Verified__c'] === true) {
                        this.countTrue = this.countTrue + 1;
                    }
                    else {
                        var defName = dataResult['Customer_Information__r_FirstName_LABEL'] + ' ' + dataResult['Customer_Information__r.LastName'];
                        console.log('defName ', defName);
                        this.mobVerificationList.push(defName);
                    }
                    if (dataResult['Is_KYC_Verified__c'] === true) {
                        this.countKYCTrue = this.countKYCTrue + 1;
                    }
                    else {
                        var defKYCName = dataResult['Customer_Information__r_FirstName_LABEL'] + ' ' + dataResult['Customer_Information__r.LastName'];
                        console.log('defKYCName ', defKYCName);
                        this.kycVerificationList.push(defKYCName);
                    }
                    const applicants = {
                        label: dataResult['Customer_Information__r_FirstName_LABEL'] + ' ' + dataResult['Customer_Information__r.LastName'],
                        value: dataResult['Id'] + '_' + dataResult['Customer_Type__c']
                    };
                    this.ownerTypeOption = [...this.ownerTypeOption, applicants];
                    console.log('Applicant Values ', this.ownerTypeOption);
                }
                if (this.countTrue > 0 /*== temp.length*/) {
                    this.validMobile = true;
                }
                if (this.countKYCTrue == temp.length) {
                    this.validKYC = true;
                }
                var defList = this.mobVerificationList.join();
                var defKYCList = this.kycVerificationList.join();
                this.submitWrapper.hasPrimaryApplicant = this.hasPrimaryApplicant;
                this.submitWrapper.isMobileVerified = this.validMobile;
                this.submitWrapper.mobDefList = defList;
                this.submitWrapper.isIncomeConsidered = this.isIncomeConsidered;
                this.submitWrapper.isKYCVerified = this.validKYC;
                this.submitWrapper.kycDefList = defKYCList;
                const getprimaryappname = new CustomEvent("getprimaryapplicantname", {
                    detail: primaryAppName
                });
                console.log('dispatch event getprimaryappname ', getprimaryappname);
                this.dispatchEvent(getprimaryappname);
                const checkSubmit = new CustomEvent("checksubmit", {
                    detail: this.submitWrapper
                });
                console.log('dispatch event checkSubmit ', checkSubmit);
                this.dispatchEvent(checkSubmit);
                const ownerFillEvent = new CustomEvent("getowners", {
                    detail: this.loanAppIdList
                });
                console.log('dispatch event ownerFillEvent ', ownerFillEvent);
                this.dispatchEvent(ownerFillEvent);
                const propOwn = new CustomEvent("getownerstype", {
                    detail: this.ownerTypeOption
                });
                console.log('dispatch event ownerFillEvent ', propOwn);
                this.dispatchEvent(propOwn);
            })
            .catch(error => {
                console.log('Error In Get ACC Data ', error);
            })
    }

    async handleSelectedApplicant(event) {
        console.log('on selected applicant ', event);
        console.log('Edit called #### ', JSON.stringify(event.detail));
        var recordData = event.detail.recordData;
        console.log('recordData ', recordData);
        this.loanAppId = recordData.Id;
        console.log('loanAppId ', this.loanAppId);
        this.accountId = recordData.Customer_Information__c;
        const isMobVerified = recordData.Mobile_Verified__c;
        const isKYCVerified = recordData.Is_KYC_Verified__c;
        const applicantType = recordData.Customer_Type__c;
        const kyc_Id = recordData.KYC_Id_1__c;
        const mobile = recordData.Mobile__c;
        const address = recordData.Residence_Address_Line_1__c;
        const gender = recordData['Customer_Information__r.Gender__c'];
        const LoanApplicantName = recordData.Applicant_Name__c;
        const dob = recordData.Dob__c;
        const isBureauVerified = JSON.parse(recordData.Is_Bureau_Verified__c);
        console.log('recordData.Application__c ', recordData.Application__c);
        if (event.detail.ActionName === 'edit') {
            this.showCustomerInfoForm = true;
            console.log('loan ', this.template.querySelector("c-fs-loan-applicant-information"));
            setTimeout(() => {
                if (this.template.querySelector("c-fs-loan-applicant-information")) {
                    console.log('in child functions');
                    this.recordIds = recordData.Customer_Information__c + '_' + recordData.Id;
                    console.log('recId ', this.recordIds);
                    this.customerTypeValue = recordData.Customer_Type__c;
                    this.loanAppWrapper.accountId = recordData.Customer_Information__c;
                    this.loanAppWrapper.loanAppId = recordData.Id;
                    this.template.querySelector("c-fs-loan-applicant-information").getRecordType(recordData.Pre_Login_Record_Type__c);
                    this.template.querySelector("c-fs-loan-applicant-information").getSectionPageContent(this.recordIds);
                    this.template.querySelector("c-fs-loan-applicant-information").getIdsOnEdit(this.loanAppWrapper);
                    this.template.querySelector("c-fs-loan-applicant-information").getCustomerTypeOndit(recordData.Customer_Type__c);
                }
            }, 200);
        }
        else if (event.detail.ActionName === 'delete') {
            console.log('Delete Called ');
            console.log(this.validation, ' :: ', applicantType);
            if ((recordData.Pre_Login_Record_Type__c === '2. Re-login' || recordData.Pre_Login_Record_Type__c === '3. Top-up loan') && applicantType === 'Primary Applicant') {
                this.showToast('Error', 'Error', 'Primary Applicant Can Not Be Deleted!!');
            }
            else if (recordData.Pre_Login_Record_Type__c === '4. Tranche loan') {
                this.showToast('Error', 'Error', 'Record can not be deleted!!');
            }
            else
                this.showDeletePopup = true;
        }
        else if (event.detail.ActionName === 'verify') {
            console.log('Mob Verified :: ', isMobVerified);
            
            if (!isMobVerified && mobile) {
                console.log('Verify Called ', recordData.Mobile__c);
                this.loanAppMobile = recordData.Mobile__c;
                this.showMobileVerification = true;
                //this.isSpinnerActive = true;
                // setTimeout(() => {
                //     this.template.querySelector("c-fs-mobile-verification-l-w-c").sendMobOTP(this.loanAppId, recordData.Mobile__c);
                //     //this.isSpinnerActive = false;
                // }, 200);
            }
            else if (isMobVerified) {
                this.showToast('Error', 'Error', 'Mobile Already Verified!!');
            }
            else {
                this.showToast('Error', 'Error', 'Mobile Number Does Not Exist!!');
            }
        }
        else if (event.detail.ActionName === 'validate') {
            if (isKYCVerified == false && kyc_Id) {
                var kycList = [];
                if (recordData.KYC_Id_1__c)
                    kycList.push({ [recordData.KYC_ID_Type_1__c]: recordData.KYC_Id_1__c });
                if (recordData.KYC_Id_2__c)
                    kycList.push({ [recordData.KYC_ID_Type_2__c]: recordData.KYC_Id_2__c });
                console.log('kycList @@ ', kycList, 'dob ', recordData.Dob__c);
                var isVerified = false;
                this.isSpinnerActive = true;
                for (let i = 0; i < kycList.length; i++) {
                    isVerified = false;
                    console.log(Object.keys(kycList[i])[0]);
                    console.log(Object.values(kycList[i])[0]);
                    var kycType = Object.keys(kycList[i])[0];
                    var kycId = Object.values(kycList[i])[0];
                    var applicantName = recordData.Applicant_Name__c;
                    await kycVerifyAPICallout({ kycType: kycType, kycId: kycId, applicantName: applicantName, dob: recordData.Dob__c.substring(0, 10), loanAppId: recordData.Id })
                        .then(result => {
                            console.log('KYC RESULT ', result);
                            if (result != undefined && result != '' && result != null) {
                                if (result.includes('Success')) {
                                    var kycType = result.split('_')[1]
                                    isVerified = true;
                                    this.showToast('Success', 'Success', kycType + ', KYC Validate Successfully!!');
                                }
                                else {
                                    isVerified = false;
                                    var kycType = result.split('_')[1]
                                    this.showToast('Error', 'Error', kycType + ', KYC Validation Failed!!');
                                }
                            }
                            else {
                                isVerified = false;
                            }
                            //this.isSpinnerActive = false;
                        })
                        .catch(error => {
                            console.log('KYC RESULT ', error);
                            isVerified = false;
                            this.isSpinnerActive = false;
                        })
                }

                // if (isVerified) {
                this.isSpinnerActive = true;
                await updateLoanApplicant({ loanAppId: recordData.Id, isKYCVerified: isVerified }).then(res => {
                    //this.showToast('Success', 'Success', 'KYC Validate Sucessfully!!');
                    this.getAccountData(this.applicationId);
                    this.isSpinnerActive = false;
                })
                    .catch(error => {
                        this.isSpinnerActive = false;
                    })
                // }
                // else {
                //     this.isSpinnerActive = false;
                //     //this.showToast('Error', 'Error', 'KYC Validate Failed!!');
                // }
            }
            else if (isKYCVerified) {
                this.showToast('Error', 'Error', 'KYC Already Verified!!');
            }
            else {
                this.showToast('Error', 'Error', 'KYC Id Does Not Exist!!');

            }
        }
        else if (event.detail.ActionName === 'preview') {
            this.imageLinks = [];
            getDocumentPublicList({ appId: recordData.Application__c, loanAppId: this.loanAppId })
                .then(result => {
                    console.log('DOC RES ', result);
                    this.imageLinks = [];
                    if (result && result.length) {
                        result.forEach(currentFile => {
                            this.imageLinks.push({ link: '/sfc/servlet.shepherd/document/download/' + currentFile.ContentDocumentId, id: currentFile.ContentDocumentId, Title: currentFile.Title });
                        });
                        this.showKYCDocsPopup = true;
                    }
                    else {
                        this.showToast('Error', 'Error', 'No KYC Document available.');
                    }
                })
                .catch(error => {
                    this.showToast('Error', 'Error', 'No KYC Document available.');
                    console.log('Error while getting docs!!');
                })
        }

        //Added on 28-04-23 : For HighMarkCallout

        else if (event.detail.ActionName === 'initiate') {
            console.log(' Intiate Bureau Called ');
            if ( !mobile || !kyc_Id || !LoanApplicantName || !dob || !address || !gender){               
                this.showToast('Error', 'Error', 'Please Fill Required Fields First!!');
            }
            else if (!isBureauVerified) {
                let tempList = [recordData.Id];
                this.isSpinnerActive = true;
                await doHighmarkCallout({ listOfLoanApp: tempList }).then(result => {
                    this.isSpinnerActive = false;
                    console.log('checkBureauVerified= !!', result);
                    if (!result) {
                        console.log('Bureau Verification failed ');
                        this.showToast('Error', 'Error', 'Bureau Verification Failed. Please Contact Your System Admin!');
                    }
                    else {
                        console.log('Bureau Verfied Successfully!!');
                        this.showToast('Success', 'Success', 'Bureau Verfied Successfully!!');
                        this.getAccountData(this.applicationId);
                    }
                })
                .catch(error => {
                    this.isSpinnerActive = false;
                    this.isLoading = false;
                    this.showToast ('Error', 'Error', 'Bureau Verification Failed. Please Contact Your System Admin!');
                    console.log('Bureau Verification failed ', error);
                })
            }
            else if(isBureauVerified) {
                this.showToast ('Error', 'Error', 'Bureau Already Verified!');
            }
        }
    }

    handlemodalactions(event) {
        this.showDeletePopup = false;
        if (event.detail === true)
            this.getAccountData(this.applicationId);
    }

    handleClickOnBMVerification(event){
        var listOfLoanApplicant = [];
        console.log(' handleClickOnBMVerification event >> ', event);
        this.isSpinnerActive = true;
        getKYCStatusOfLoanApplicant({applicationId : this.applicationId})
        .then(result => {
            this.isSpinnerActive = false;
            if(result && result.length > 0){
                if(result.length == 1 && result[0] === 'Sourcing Branch is Empty'){
                    console.log('result Sent to BM >>',result);
                    this.showToast('Error', 'Error', 'Sourcing Branch Does Not Exist, Please Fill In Application Details Tab');
                }else if(result.length == 1 && result[0] === 'Branch Manager Not Exist'){
                    console.log('result Sent to BM >>',result);
                    this.showToast('Error', 'Error', 'Branch Manager Does Not Exist');
                }else if(result.length == 1 && result[0] === 'Sent to BM'){
                    console.log('result Sent to BM >>',result);
                    this.showToast('Success', 'Success', 'Applicants Sent to BM for KYC Verification');
                }else if(result.length == 1 && result[0] === 'KCY Already Verified'){
                    console.log('result KCY Already Verified >>',result);
                    this.showToast('Success', 'Success', 'KCY Already Verified');
                }else{
                    console.log('result >>',result);
                    listOfLoanApplicant = result;
                    this.showToast('Error', 'Error', 'Please Initiate KYC Verification for these applicants '+listOfLoanApplicant.join());
                }
            }else{
                this.showToast('Error', 'Error','Failed Sent to BM');
            }
        })
        .catch(error => {
            this.isSpinnerActive = false;
            this.showToast('Error', 'Error','Failed Sent to BM');
            this.error = error;
        });
        
    }

    closeKYCPopup(event) {
        this.showKYCDocsPopup = false;
    }

    hideMobilePopup(event){
        this.showMobileVerification = false;
    }

    /* Child Custom Event Handler */

    getAppName(event) {
        console.log('getAppName 5 ', event.detail);
        var sendAppName = new CustomEvent('getappname', {
            detail: event.detail
        });
        this.dispatchEvent(sendAppName);
    }

    handleApplicationId(event) {
        console.log('App Id Get EVENT ', event.detail);
        this.applicationId = event.detail;
        this.getAccountData(this.applicationId);
        var sendAppId = new CustomEvent('getapplicationid', {
            detail: this.applicationId
        });
        this.dispatchEvent(sendAppId);
    }

    handlePreloginId(event) {
        console.log('Prelogin Id Get EVENT ', event.detail);
        var sendPreloginId = new CustomEvent('getpreloginid', {
            detail: event.detail
        });
        this.dispatchEvent(sendPreloginId);
    }

    handleOCREvent(event) {
        console.log('OCR EVENT ', event.detail);
        this.showCustomerInfoForm = event.detail;
    }

    handleCustomerType(event) {
        console.log('Cus EVENT ', event.detail);
        this.customerTypeValue = event.detail;
    }

    handleVerificationValue(event) {
        console.log('Verification EVENT ', event.detail);
        this.verificationTypeValue = event.detail;
        if (this.verificationTypeValue === 'Self') {
            this.isSpinnerActive = false;
            setTimeout(() => {
                this.template.querySelector("c-fs-loan-applicant-information").getSectionPageContent('');
            }, 200);
        }
    }

    handleOCRTable(event) {
        console.log('OCR Table EVENT ', event.detail);
        this.ocrTable = event.detail;
        console.log('queryselector ', this.template.querySelector('c-fs-loan-applicant-information'));
        if (this.showCustomerInfoForm) {
            console.log('call child method');
            setTimeout(() => {
                this.template.querySelector("c-fs-loan-applicant-information").getOCRTableInfo(this.ocrTable);
            }, 200);
        }
    }

    getOCRDocs(event) {
        console.log('ocr docs ', event.detail);
        setTimeout(() => {
            this.template.querySelector("c-fs-loan-applicant-information").getOCRDocs(event.detail);
        }, 200);
    }

    hideOCRTable(event) {
        this.template.querySelector('c-fs-o-c-r').hideOcrTable(event.detail);
    }

    reloadDataTable(event) {
        if (event.detail) {
            this.isSpinnerActive = false;
            this.showMobileVerification = false;
            this.getAccountData(this.applicationId);
        }
    }

    refreshOCR(event) {
        if (event.detail) {
            this.template.querySelector('c-fs-o-c-r').handleRefreshOCR();
        }
    }

    showToastMessage(event) {
        console.log('event #### ', event.detail)
        const evt = new ShowToastEvent({
            title: event.detail.title,
            message: event.detail.message,
            variant: event.detail.variant
        });
        this.dispatchEvent(evt);
    }

    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}