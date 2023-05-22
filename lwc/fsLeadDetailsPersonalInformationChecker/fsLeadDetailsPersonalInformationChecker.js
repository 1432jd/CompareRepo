import { LightningElement, api, track } from 'lwc';
import saveRecord from '@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import getPersonalInformationData from '@salesforce/apex/FsLeadDetailsControllerHelper.getPersonalInformationData';
import doHighmarkCallout from '@salesforce/apex/BureauHighmartAPICalloutController.doHighmarkCallout';
//import kycAPICallout from '@salesforce/apex/KYCAPIController.kycAPICallout';
import getPincodeDetails from '@salesforce/apex/DatabaseUtililty.getPincodeDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDocumentPublicList from '@salesforce/apex/FsPreloginController.getDocumentPublicList';
import checkKYCIdExist from '@salesforce/apex/FsLeadDetailsControllerHelper.checkKYCIdExist';
import kycVerifyAPICallout from '@salesforce/apex/KYCAPIController.kycVerifyAPICallout';
import updateLoanApplicant from '@salesforce/apex/KYCAPIController.updateLoanApplicant';
import getKYCStatusOfLoanApplicant from '@salesforce/apex/KYCAPIController.getKYCStatusOfLoanApplicant';


export default class FsLeadDetailsPersonalInformationChecker extends LightningElement {
    @api rowAction;
    @api applicationId;
    @api allLoanApplicant;
    @api tableData;
    @track isRecordEdited = false;
    @track recordIds;
    @track fieldsContent;
    @track objectIdMap = { 'Account': '', 'Loan_Applicant__c': '' };
    @track isSpinnerActive = false;
    @track isFieldDisplay = false;
    @track showDeletePopup = false;
    @track showMobileVerification = false;
    @track isMobileEdited = false;
    @track isVerified = true;
    @track loanAppId;
    @track loanAppMobileNo;
    @track customerTypeEdit = '';
    @track kycType1Val;
    @track kycType2Val;
    @track constitution = '';
    @track isBureauInitiatedMap = new Map();
    @track isKYCChanged = false;
    @track showKYCDocsPopup = false;
    @track imageLinks = [];
    @track oldKYCId1;
    @track oldKYCId2;
    @track kycId1;
    @track kycId2;
    @track customerId;
    @track passportFileNo1;
    @track passportDOI1;
    @track passportDOE1;
    @track passportFileNo2;
    @track passportDOI2;
    @track passportDOE2;
    @track loanRowActions = [
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
                iconName: 'utility:contract',
                title: 'Initiate Bureau',
                variant: 'border-filled',
                alternativeText: 'Initiate Bureau',
                name: 'bureau_initiate'
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
        }
    ];
    //checkValidity
    @track defLoanAppList = [];
    @track isPincode;

    connectedCallback() {
        this.getPersonalInformationData(false, false);
        console.log('Bureau Map', this.isBureauInitiatedMap);
    }

    async getSectionPageContent(recId) {
        this.isSpinnerActive = true;
        getSectionContent({ recordIds: recId, metaDetaName: 'Lead_Details_Personal_Information' })
            .then(result => {
                this.fieldsContent = result.data;
                console.log('this.fieldsContent ##### ', JSON.stringify(JSON.parse(this.fieldsContent)));
                this.isSpinnerActive = false;
                var kycValue2;
                var field = JSON.parse(this.fieldsContent);
                this.oldKYCId1 = undefined;
                this.kycId1 = undefined;
                this.oldKYCId2 = undefined;
                this.kycId2 = undefined;
                for (var i = 0; i < field[0].fieldsContent.length; i++) {
                    if (field[0].fieldsContent[i].fieldAPIName === 'KYC_ID_Type_2__c') {
                        kycValue2 = field[0].fieldsContent[i].value;
                        this.kycType2Val = field[0].fieldsContent[i].value;

                        var isKYCType2Passport = field[0].fieldsContent[i].value === 'Passport' ? true : false;

                        if (isKYCType2Passport)
                            setTimeout(() => {
                                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isKYCType2Passport', isKYCType2Passport)));
                                console.log('insde edittt isKYCType2Passport ', isKYCType2Passport)
                            }, 200);
                    }
                    else if (field[0].fieldsContent[i].fieldAPIName === 'KYC_ID_Type_1__c') {
                        this.kycType1Val = field[0].fieldsContent[i].value;
                    }
                    else if (field[0].fieldsContent[i].fieldAPIName === 'KYC_Id_1__c') {
                        this.oldKYCId1 = field[0].fieldsContent[i].value;
                    }
                    else if (field[0].fieldsContent[i].fieldAPIName === 'KYC_Id_2__c') {
                        this.oldKYCId2 = field[0].fieldsContent[i].value;
                    }
                    else if (field[0].fieldsContent[i].fieldAPIName === 'KYC_ID_Type_1__c') {
                        var isKYCType1Passport = field[0].fieldsContent[i].value === 'Passport' ? true : false;
                        if (isKYCType1Passport)
                            setTimeout(() => {
                                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isKYCType1Passport', isKYCType1Passport)));
                                console.log('insde edittt isKYCType1Passport ', isKYCType1Passport)
                            }, 200);
                    }
                    else if (field[0].fieldsContent[i].fieldAPIName === 'Passport_File_Number__c') {
                        console.log('tempFieldsContent.CurrentFieldAPIName ', field[0].fieldsContent[i].fieldAPIName);
                        if (this.kycType1Val === 'Passport')
                            this.passportFileNo1 = field[0].fieldsContent[i].value;
                        if (this.kycType2Val === 'Passport')
                            this.passportFileNo2 = field[0].fieldsContent[i].value;
                    }
                    else if (field[0].fieldsContent[i].fieldAPIName === 'Issue_Date__c') {
                        console.log('tempFieldsContent.CurrentFieldAPIName ', field[0].fieldsContent[i].fieldAPIName);
                        if (this.kycType1Val === 'Passport')
                            this.passportDOI1 = field[0].fieldsContent[i].value;
                        if (this.kycType2Val === 'Passport')
                            this.passportDOI2 = field[0].fieldsContent[i].value;
                    }
                    else if (field[0].fieldsContent[i].fieldAPIName === 'Expiry_Date__c') {
                        console.log('tempFieldsContent.CurrentFieldAPIName ', field[0].fieldsContent[i].fieldAPIName);
                        if (this.kycType1Val === 'Passport')
                            this.passportDOE1 = field[0].fieldsContent[i].value;
                        if (this.kycType2Val === 'Passport')
                            this.passportDOE2 = field[0].fieldsContent[i].value;
                    }
                }
                setTimeout(() => {
                    if (kycValue2) {
                        console.log('#### kycValue2 ', kycValue2);
                        console.log('#### constitution ', this.constitution);
                        this.setKYCPattern(this.fieldsContent, kycValue2, 'KYC_Id_2__c', this.constitution);
                    }
                    if (this.kycType1Val) {
                        console.log('#### this.kycType1Val ', this.kycType1Val);
                        console.log('#### constitution ', this.constitution);
                        this.setKYCPattern(this.fieldsContent, this.kycType1Val, 'KYC_Id_1__c', this.constitution);
                    }
                }, 200);
                setTimeout(() => {
                    this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Nationality__c', 'Indian', null)));
                }, 200);
            })
            .catch(error => {
                console.log(error);
                this.isSpinnerActive = false;
            });
    }

    async handleSelectedApplication(event) {
        console.log('Edit called #### ', JSON.parse(JSON.stringify(event.detail)));
        this.constitution = '';
        this.fieldsContent = undefined;
        var recordData = event.detail.recordData;
        this.loanAppId = recordData.Id;
        this.customerId = recordData['Customer_Information__r.Id'];
        this.constitution = recordData.Constitution__c;
        const isMobVerified = recordData.Mobile_Verified__c;
        const isKYCVerified = recordData.Is_KYC_Verified__c;
        console.log('isKYCVerified ', isKYCVerified);
        const isBureauVerified = recordData.Is_Bureau_Verified__c;
        if (event.detail.ActionName === 'edit') {
            this.isRecordEdited = true;
            this.recordIds = recordData.Customer_Information_VALUE.replaceAll('/lightning/_classic/', '') + '_' + recordData.Id;
            this.objectIdMap['Account'] = recordData.Customer_Information_VALUE.replaceAll('/lightning/_classic/', '');
            this.objectIdMap['Loan_Applicant__c'] = recordData.Id;
            this.customerTypeEdit = recordData.Customer_Type__c;
            this.getSectionPageContent(this.recordIds);
        }
        else if (event.detail.ActionName === 'delete') {
            console.log('Delete Called ');
            this.showDeletePopup = true;
        }
        else if (event.detail.ActionName === 'verify') {
            console.log('Mob Verified :: ', isMobVerified);
            this.showMobileVerification = false;
            if (!isMobVerified) {
                //this.isSpinnerActive = true;
                console.log('Verify Called ', recordData.Mobile__c);
                this.loanAppMobileNo = recordData.Mobile__c;
                this.showMobileVerification = true;
                // setTimeout(() => {
                //     this.template.querySelector("c-fs-mobile-verification-l-w-c").sendMobOTP(this.loanAppId, recordData.Mobile__c);
                // }, 200);
                // this.isSpinnerActive = false;
            }
            else {
                this.showtoastmessage('Error', 'Error', 'Mobile Already Verified!!');
            }
        }
        else if (event.detail.ActionName === 'validate') {
            if (isKYCVerified == 'false') {
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
                                    this.showtoastmessage('Success', 'Success', kycType + ', KYC Validate Successfully!!');
                                }
                                else {
                                    isVerified = false;
                                    var kycType = result.split('_')[1]
                                    this.showtoastmessage('Error', 'Error', kycType + ', KYC Validation Failed!!');
                                }
                            }
                            else {
                                isVerified = false;
                            }
                        })
                        .catch(error => {
                            console.log('KYC RESULT ', error);
                            isVerified = false;
                            this.isSpinnerActive = false;
                        })
                }

                // if (isVerified) {

                this.isSpinnerActive = true;
                await updateLoanApplicant({ loanAppId: recordData.Id, isKYCVerified : isVerified }).then(res => {
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
            else {
                this.showtoastmessage('Error', 'Error', 'KYC Already Verified!!');
            }
            // if (isKYCVerified == 'false') {
            //     kycAPICallout({ loanAppId: this.loanAppId })
            //         .then(result => {
            //             if (result != undefined && result != '' && result != null) {
            //                 if (result === 'Success') {
            //                     this.showtoastmessage('Success', 'Success', 'KYC Validate Sucessfully!!');
            //                 }
            //                 else {
            //                     this.showtoastmessage('Error', 'Error', 'KYC Validate Failed!!');
            //                 }
            //             }
            //             else {
            //                 this.showtoastmessage('Error', 'Error', 'KYC Validate Failed!!');
            //             }
            //         })
            //         .catch(error => {
            //             this.showtoastmessage('Error', 'Error', 'KYC Validate Failed!!');
            //         })
            // }
            // else {
            //     this.showtoastmessage('Error', 'Error', 'KYC Already Verified!!');
            // }
        }
        //////////////////////////////////////////// Added by Ajay Kumar
        else if (event.detail.ActionName === 'bureau_initiate') {
            console.log('isBureau Verified', typeof isBureauVerified);
            if (isBureauVerified == false) {
                console.log('Before ###', this.isBureauInitiatedMap);
                this.isSpinnerActive = true;
                console.log('this.loan app Id', this.loanAppId);
                if (this.isBureauInitiatedMap.get(this.loanAppId) == false) {
                    let loanAppList = [];
                    loanAppList.push(this.loanAppId);
                    doHighmarkCallout({ listOfLoanApp: loanAppList }).then(result => {
                        console.log('bureau highmark Result>>>>> ', result);
                        if (!result) {
                            console.log('Bureau Verification failed ');
                            this.showtoastmessage('Error', 'Error', 'Bureau Verification Failed. Please Contact Your System Admin!');
                        }
                        else {
                            console.log('Bureau Verfied Successfully!!');
                            this.showtoastmessage('Success', 'Success', 'Bureau Verfied Successfully!!');
                        }
                        this.getPersonalInformationData(true, false);
                        setTimeout(() => {
                            this.isSpinnerActive = false;
                        }, 900);
                        this.isBureauInitiatedMap.set(this.loanAppId, true);
                        console.log('AFter ###', this.isBureauInitiatedMap);
                    })
                        .catch(err => {
                            console.log('bureau highmark error>>>>> ', err);
                            this.isSpinnerActive = false;
                        })
                }
                else {
                    this.getPersonalInformationData(true, false);
                    this.isSpinnerActive = false;
                }
            }
            else {
                this.showtoastmessage('Error', 'error', 'Bureau Already Verified');
            }

        } else if (event.detail.ActionName === 'preview') {
            this.imageLinks = [];
            getDocumentPublicList({ appId: recordData.Application__c, loanAppId: this.loanAppId })
                .then(result => {
                    console.log('DOC RES ', result);
                    if (result && result.length) {
                        result.forEach(currentFile => {
                            this.imageLinks.push({ link: '/sfc/servlet.shepherd/document/download/' + currentFile.ContentDocumentId, id: currentFile.ContentDocumentId, Title: currentFile.Title });
                        });
                        this.showKYCDocsPopup = true;
                    }
                    else {
                        this.showtoastmessage('Error', 'Error', 'No KYC Document available.');
                    }
                })
                .catch(error => {
                    this.showtoastmessage('Error', 'Error', 'No KYC Document available.');
                    console.log('Error while getting docs!!');
                })
        }
        ////////////////////////////////////////////////////////////////////////
    }

    setAddressValues(tempFieldsContent) {
        var addressValues = {
            flat: '',
            address1: '',
            address2: '',
            landmark: '',
            village: '',
            city: '',
            taluka: '',
            district: '',
            state: '',
            pincode: ''
        }
        if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Same_As_Address_Pernament__c') {
            if (tempFieldsContent.CurrentFieldValue === 'Residence Address') {
                addressValues.flat = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Flat_Plot_Number__c'];
                addressValues.address1 = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Address_Line_1__c'];
                addressValues.address2 = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Address_Line_2__c'];
                addressValues.landmark = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Landmark__c'];
                addressValues.village = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Village__c'];
                addressValues.city = tempFieldsContent.previousData['Loan_Applicant__c-Residence_City__c'];
                addressValues.taluka = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Taluka__c'];
                addressValues.district = tempFieldsContent.previousData['Loan_Applicant__c-Residence_District__c'];
                addressValues.state = tempFieldsContent.previousData['Loan_Applicant__c-Residence_State__c'];
                addressValues.pincode = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Pincode__c'];
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Permanent_Address', addressValues, true)));
            }
            else if (tempFieldsContent.CurrentFieldValue === 'Business Address') {
                addressValues.flat = tempFieldsContent.previousData['Loan_Applicant__c-Business_Flat_Plot_Number__c'];
                addressValues.address1 = tempFieldsContent.previousData['Loan_Applicant__c-Business_Address_Line_1__c'];
                addressValues.address2 = tempFieldsContent.previousData['Loan_Applicant__c-Business_Address_Line_2__c'];
                addressValues.landmark = tempFieldsContent.previousData['Loan_Applicant__c-Business_Landmark__c'];
                addressValues.village = tempFieldsContent.previousData['Loan_Applicant__c-Business_Village__c'];
                addressValues.city = tempFieldsContent.previousData['Loan_Applicant__c-Business_City__c'];
                addressValues.taluka = tempFieldsContent.previousData['Loan_Applicant__c-Business_Taluka__c'];
                addressValues.district = tempFieldsContent.previousData['Loan_Applicant__c-Business_District__c'];
                addressValues.state = tempFieldsContent.previousData['Loan_Applicant__c-Business_State__c'];
                addressValues.pincode = tempFieldsContent.previousData['Loan_Applicant__c-Business_Pincode__c'];
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Permanent_Address', addressValues, true)));
            } else {
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Permanent_Address', addressValues, true)));
            }
        }

        if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Same_As_Address_Business__c') {
            if (tempFieldsContent.CurrentFieldValue === 'Residence Address') {
                addressValues.flat = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Flat_Plot_Number__c'];
                addressValues.address1 = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Address_Line_1__c'];
                addressValues.address2 = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Address_Line_2__c'];
                addressValues.landmark = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Landmark__c'];
                addressValues.village = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Village__c'];
                addressValues.city = tempFieldsContent.previousData['Loan_Applicant__c-Residence_City__c'];
                addressValues.taluka = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Taluka__c'];
                addressValues.district = tempFieldsContent.previousData['Loan_Applicant__c-Residence_District__c'];
                addressValues.state = tempFieldsContent.previousData['Loan_Applicant__c-Residence_State__c'];
                addressValues.pincode = tempFieldsContent.previousData['Loan_Applicant__c-Residence_Pincode__c'];
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Business_Address', addressValues, true)));
            }
            if (tempFieldsContent.CurrentFieldValue === 'Permanent Address') {
                addressValues.flat = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Flat_Plot_Number__c'];
                addressValues.address1 = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Address_Line_1__c'];
                addressValues.address2 = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Address_Line_2__c'];
                addressValues.landmark = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Landmark__c'];
                addressValues.village = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Village__c'];
                addressValues.city = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_City__c'];
                addressValues.taluka = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Taluka__c'];
                addressValues.district = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_District__c'];
                addressValues.state = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_State__c'];
                addressValues.pincode = tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Pincode__c'];
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Business_Address', addressValues, true)));
            } else {
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Business_Address', addressValues, true)));
            }
        }
        let ref = this;
        setTimeout(function () {
            ref.template.querySelector('c-generic-edit-pages-l-w-c').updateData();
        }, 500);
    }

    changedFromChild(event) {
        console.log('event details #### ', JSON.parse(JSON.stringify(event.detail)));
        var tempFieldsContent = event.detail;

        if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_ID_Type_1__c' || tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_ID_Type_2__c' ||
            tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_Id_1__c' || tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_Id_2__c') {
            this.isKYCChanged = true;

            if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_ID_Type_1__c') {
                console.log('*** # inside # ***');
                this.kycType1Val = tempFieldsContent.CurrentFieldValue;
                this.setKYCPattern(this.fieldsContent, tempFieldsContent.CurrentFieldValue, 'KYC_Id_1__c', this.constitution);
                let isKYCType1Passport = tempFieldsContent.CurrentFieldValue === 'Passport' ? true : false
            } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_ID_Type_2__c') {
                console.log('*** # inside # ***');
                this.kycType2Val = tempFieldsContent.CurrentFieldValue;
                console.log('tempFieldsContent.CurrentFieldAPIName ', tempFieldsContent.CurrentFieldValue);
                this.setKYCPattern(this.fieldsContent, tempFieldsContent.CurrentFieldValue, 'KYC_Id_2__c', this.constitution);
                let isKYCType2Passport = tempFieldsContent.CurrentFieldValue === 'Passport' ? true : false
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('isKYCType2Passport', isKYCType2Passport)));
            } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_Id_1__c') {
                console.log('Loan_Applicant__c-KYC_Id_1__c ', tempFieldsContent.CurrentFieldAPIName + ' :: ' + tempFieldsContent.CurrentFieldValue);
                this.kycId1 = tempFieldsContent.CurrentFieldValue;
            } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-KYC_Id_2__c') {
                console.log('Loan_Applicant__c-KYC_Id_2__c ', tempFieldsContent.CurrentFieldAPIName + ' :: ' + tempFieldsContent.CurrentFieldValue);
                this.kycId2 = tempFieldsContent.CurrentFieldValue;
            }
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Account-FirstName' || tempFieldsContent.CurrentFieldAPIName === 'Account-LastName') {
            var nameVal = tempFieldsContent.previousData['Account-FirstName'] + ' ' + tempFieldsContent.previousData['Account-LastName'];
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Full_Name', nameVal)));
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Account-PersonBirthdate') {
            var dob = this.getAge(tempFieldsContent.previousData['Account-PersonBirthdate']);
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Age__c', dob)));
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Same_As_Address_Pernament__c' || tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Same_As_Address_Business__c') {
            this.setAddressValues(tempFieldsContent);
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Account-Nationality__c') {
            this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Nationality__c', 'Indian', null)));
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Residence_Pincode__c' && tempFieldsContent.CurrentFieldValue != true) {
            console.log('inside resi');
            getPincodeDetails({ pinId: tempFieldsContent.previousData['Loan_Applicant__c-Residence_Pincode__c'] }).then(resi => {
                console.log('pincodeee resiii ', resi);
                if (resi.pinCode)
                    this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Residence_Address', resi)));
            }).catch(error => {
                console.log(error);
            })
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Residence_Pincode__c') {
            this.resetAllPincodeFields('Is_Residence_Address');
        }
        else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Constitution__c') {
            this.setKYCPattern(this.fieldsContent, tempFieldsContent.previousData['Loan_Applicant__c-KYC_ID_Type_2__c'], 'KYC_Id_2__c', tempFieldsContent.CurrentFieldValue);
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Permanent_Pincode__c' && tempFieldsContent.CurrentFieldValue != true) {
            console.log('inside permanent');
            getPincodeDetails({ pinId: tempFieldsContent.previousData['Loan_Applicant__c-Permanent_Pincode__c'] }).then(perm => {
                console.log('getPincodeDetails Permanent = ', perm);
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Permanent_Address', perm)));
            }).catch(error => {
                console.log(error);
            })
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Permanent_Pincode__c') {
            this.resetAllPincodeFields('Is_Permanent_Address');
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Business_Pincode__c' && tempFieldsContent.CurrentFieldValue != true) {
            console.log('inside business');
            getPincodeDetails({ pinId: tempFieldsContent.previousData['Loan_Applicant__c-Business_Pincode__c'] }).then(busi => {
                console.log('getPincodeDetails business = ', busi);
                this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Is_Business_Address', busi)));
            }).catch(error => {
                console.log(error);
            })
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Business_Pincode__c') {
            this.resetAllPincodeFields('Is_Business_Address');
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Mobile__c') {
            if (this.isRecordEdited) {
                console.log('tempFieldsContent.CurrentFieldAPIName ', tempFieldsContent.CurrentFieldValue);
                this.isMobileEdited = true;
            }
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Passport_File_Number__c') {
            console.log('tempFieldsContent.CurrentFieldAPIName ', tempFieldsContent.CurrentFieldValue);
            if (this.kycType1Val === 'Passport')
                this.passportFileNo1 = tempFieldsContent.CurrentFieldValue;
            if (this.kycType2Val === 'Passport')
                this.passportFileNo2 = tempFieldsContent.CurrentFieldValue;
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Issue_Date__c') {
            console.log('tempFieldsContent.CurrentFieldAPIName ', tempFieldsContent.CurrentFieldValue);
            if (this.kycType1Val === 'Passport')
                this.passportDOI1 = tempFieldsContent.CurrentFieldValue;
            if (this.kycType2Val === 'Passport')
                this.passportDOI2 = tempFieldsContent.CurrentFieldValue;
        } else if (tempFieldsContent.CurrentFieldAPIName === 'Loan_Applicant__c-Expiry_Date__c') {
            console.log('tempFieldsContent.CurrentFieldAPIName ', tempFieldsContent.CurrentFieldValue);
            if (this.kycType1Val === 'Passport')
                this.passportDOE1 = tempFieldsContent.CurrentFieldValue;
            if (this.kycType2Val === 'Passport')
                this.passportDOE2 = tempFieldsContent.CurrentFieldValue;
        }

        var splittedFieldAPIName = tempFieldsContent.CurrentFieldAPIName.split('-');
        let finalFieldAPIName = splittedFieldAPIName[1];
        let objectAPIName = splittedFieldAPIName[0];
        console.log('objectAPIName=  ', objectAPIName);
        if (objectAPIName == 'Loan_Applicant__c') {
            const selectedEvent = new CustomEvent("handletabvaluechange", {
                detail: { tabname: 'Application Information', subtabname: 'Applicant Information', fieldapiname: finalFieldAPIName, fieldvalue: tempFieldsContent.CurrentFieldValue, recordId: this.loanAppId }
            });
            this.dispatchEvent(selectedEvent);
        } else {
            console.log('customer iddd>>> ', this.customerId)
            if (finalFieldAPIName != 'Name') {
                const selectedEvent = new CustomEvent("handletabvaluechange", {
                    detail: { tabname: 'Application Information', subtabname: 'Customer Information', fieldapiname: finalFieldAPIName, fieldvalue: tempFieldsContent.CurrentFieldValue, recordId: this.customerId }
                });
                this.dispatchEvent(selectedEvent);
            }
        }
    }

    resetAllPincodeFields(type) {
        var resi = {
            city: '',
            taluka: '',
            district: '',
            state: '',
            pinCode: ''
        }
        this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues(type, resi)));
    }


    getAge(dateString) {
        var today = new Date();
        var birthDate = new Date(dateString);
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        console.log('age ### ', age);
        return age;
    }

    setKYCPattern(fieldcontent, kycType, fieldAPIName, constitution) {
        var field = JSON.parse(fieldcontent);
        for (var i = 0; i < field[0].fieldsContent.length; i++) {
            if (field[0].fieldsContent[i].fieldAPIName === fieldAPIName) {
                var regEx;
                var helpText = 'for eg : ';
                var maxLength;
                if (kycType === 'Aadhaar Card') {
                    regEx = '[2-9]{1}[0-9]{3}[0-9]{4}[0-9]{4}';
                    helpText += 'for eg : 234567890123';
                    maxLength = 12;
                }
                if (kycType === 'Voter Id') {
                    //regEx = '([a-zA-Z]){3}([0-9]){7}';
                    regEx = '[A-Za-z0-9_/\\\\-]{0,20}';
                    helpText += 'Max 20 characters allowed.'
                    maxLength = 20;
                }
                if (kycType === 'Pan Card') {
                    console.log('constitution ', constitution);
                    maxLength = 10;
                    if (constitution === 'Non-Individual') {
                        regEx = '[A-Z]{3}[C|G|L|F|T]{1}[A-Z]{1}[0-9]{4}[A-Z]{1}';
                        helpText += 'for eg : ABCDE1234Z'
                    }
                    else if (constitution === 'Individual') {
                        regEx = '[A-Z]{3}[P|H|A|B|J]{1}[A-Z]{1}[0-9]{4}[A-Z]{1}';
                        helpText += 'for eg : ABCDE1234Z'
                    }
                }
                if (kycType === 'Passport') {
                    regEx = '[A-PR-WYa-pr-wy][1-9]\\d\\s?\\d{4}[1-9]';
                    helpText += 'for eg : A1234567'
                    maxLength = 8;
                }
                if (kycType === 'Driving License') {
                    //regEx = '(([A-Z]{2}[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}';
                    regEx = '[A-Za-z0-9_/\\\\-]{0,20}';
                    helpText += 'for eg : RJ1320120123456'
                    //helpText += 'Max 20 characters allowed.'
                    helpText += 'Max 20 characters allowed.'
                    maxLength = 20;
                }
                field[0].fieldsContent[i].validationPattern = regEx;
                field[0].fieldsContent[i].validationPatternMismatched = 'Invalid KYC ID';
                field[0].fieldsContent[i].isHelpText = true;
                field[0].fieldsContent[i].helpMsg = helpText;
                field[0].fieldsContent[i].maxLength = maxLength;
                if (fieldAPIName === 'KYC_Id_2__c') {
                    field[0].fieldsContent[i].fieldAttribute.isRequired = true;
                    if (kycType === '') {
                        field[0].fieldsContent[i].value = '';
                        field[0].fieldsContent[i].fieldAttribute.isRequired = false;
                    }
                }
            }
            console.log('kycType 669?>>> ', kycType, 'kycType1Val n 222>> ', this.kycType1Val, this.kycType2Val)
            if ((field[0].fieldsContent[i].fieldAPIName === 'Expiry_Date__c' || field[0].fieldsContent[i].fieldAPIName === 'Issue_Date__c' || field[0].fieldsContent[i].fieldAPIName === 'Passport_File_Number__c')) {
                console.log('671?????>>>field[0].fieldsContent[i].value', field[0].fieldsContent[i].value)

                if (kycType === 'Passport') {
                    field[0].fieldsContent[i].fieldAttribute.isRequired = true;
                    //field[0].fieldsContent[i].fieldAttribute.isShowField = true;
                    field[0].fieldsContent[i].disabled = false;
                }
                else if (kycType != 'Passport' && ((this.kycType1Val != 'Passport') && (this.kycType2Val != 'Passport'))) {
                    console.log('field[0].fieldsContent[i].value>>>>', field[0].fieldsContent[i].value)
                    field[0].fieldsContent[i].value = '';
                    field[0].fieldsContent[i].fieldAttribute.isRequired = false;
                    field[0].fieldsContent[i].disabled = true;
                    console.log('field[0].fieldsContent[i].value>>>>22222??', field[0].fieldsContent[i].value)
                }
                if (this.kycType1Val === 'Passport') {
                    field[0].fieldsContent[i].disabled = false;
                    field[0].fieldsContent[i].fieldAttribute.isRequired = true;
                    if (field[0].fieldsContent[i].fieldAPIName === 'Expiry_Date__c' && this.passportDOE1)
                        field[0].fieldsContent[i].value = this.passportDOE1;
                    if (field[0].fieldsContent[i].fieldAPIName === 'Issue_Date__c' && this.passportDOI1)
                        field[0].fieldsContent[i].value = this.passportDOI1;
                    if (field[0].fieldsContent[i].fieldAPIName === 'Passport_File_Number__c' && this.passportFileNo1)
                        field[0].fieldsContent[i].value = this.passportFileNo1;
                    console.log('insidee paasportt 694>>>> ', field[0].fieldsContent[i].value)
                }
                if (this.kycType2Val === 'Passport') {
                    field[0].fieldsContent[i].disabled = false;
                    field[0].fieldsContent[i].fieldAttribute.isRequired = true;
                    if (field[0].fieldsContent[i].fieldAPIName === 'Expiry_Date__c' && this.passportDOE2)
                        field[0].fieldsContent[i].value = this.passportDOE2;
                    if (field[0].fieldsContent[i].fieldAPIName === 'Issue_Date__c' && this.passportDOI2)
                        field[0].fieldsContent[i].value = this.passportDOI2;
                    if (field[0].fieldsContent[i].fieldAPIName === 'Passport_File_Number__c' && this.passportFileNo2)
                        field[0].fieldsContent[i].value = this.passportFileNo2;
                    console.log('insidee paasportt 705>>>> ', field[0].fieldsContent[i].value)
                }
            }
        }
        this.fieldsContent = JSON.stringify(field);
        console.log('this.fieldsContent in setkyc >> ', this.fieldsContent)
        let genericedit = this.template.querySelector('c-generic-edit-pages-l-w-c');
        genericedit.refreshData((this.fieldsContent));
    }

    closeKYCPopup(event) {
        this.showKYCDocsPopup = false;
    }

    hideMobilePopup(event){
        this.showMobileVerification = false;
    }

    async handleSave() {
        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        if (data.length > 0) {
            var addressFromDate;
            var addressToDate;

            var cityFromDate;
            var cityToDate;

            var kycId1;
            var kycId2;

            for (var i = 0; i < data.length; i++) {
                if (data[i].sobjectType == 'Loan_Applicant__c' && data[i].Duration_At_This_Address_From__c != '' && data[i].Duration_At_This_Address_To__c != '') {
                    console.log('@@@@ data ', data[i]);
                    addressFromDate = Date.parse(data[i].Duration_At_This_Address_From__c);
                    addressToDate = Date.parse(data[i].Duration_At_This_Address_To__c);
                }
                if (data[i].sobjectType == 'Loan_Applicant__c' && data[i].Duration_At_This_City_From__c != '' && data[i].Duration_At_This_City_To__c != '') {
                    console.log('@@@@ data ', data[i]);
                    cityFromDate = Date.parse(data[i].Duration_At_This_City_From__c);
                    cityToDate = Date.parse(data[i].Duration_At_This_City_To__c);
                }
                if (data[i].sobjectType == 'Loan_Applicant__c' && data[i].KYC_ID_Type_1__c != '' && data[i].KYC_ID_Type_2__c != '') {
                    console.log('@@@@ data ', data[i]);
                    kycId1 = data[i].KYC_ID_Type_1__c;
                    kycId2 = data[i].KYC_ID_Type_2__c;
                }
            }

            var isSameKYC = false;
            console.log('checkKYCIdExist conditions ', this.isRecordEdited, ' :: ', this.isKYCChanged + ' :: ' + this.kycId1 + ' :: ' + this.kycId2 + ' :: ' + this.oldKYCId1 + ' :: ' + this.oldKYCId2)
            if (!this.isRecordEdit || (this.isRecordEdit && this.isKYCChanged && this.oldKYCId1 != this.kycId1 && this.oldKYCId2 != this.kycId2)) {
                var loanAppId = this.isRecordEdited ? this.loanAppId : '';
                console.log('record edited loa app id kyc ', loanAppId)
                await checkKYCIdExist({ kycId1: this.kycId1, kycId2: this.kycId2, appId: this.applicationId, loanAppId: loanAppId })
                    .then(result => {
                        console.log('SAME KYC ID EXIST :: ', result);
                        isSameKYC = result;
                    })
                    .catch(error => {
                        console.log('Error in checking same KYCID');
                    })
            }
            console.log('sameKYC ', isSameKYC);

            if (addressFromDate > addressToDate) {
                this.showtoastmessage('Error', 'Error', 'Duration At This Address From Should Not be Greater Than Duration At This Address To');
                return;
            } else if (cityFromDate > cityToDate) {
                this.showtoastmessage('Error', 'Error', 'Duration At This City From Should Not be Greater Than Duration At This City To');
                return;
            } else if ((kycId1 == kycId2) && kycId2 != null && kycId1 != null) {
                this.showtoastmessage('Error', 'Error', 'KYC ID 1 and KYC ID 2 should not be equal');
                return;
            }
            else if (isSameKYC) {
                this.showtoastmessage('Error', 'error', 'Customer with same kyc id found.');
                // this.closeAction();
                // this.saveDisable = false;
                this.isSpinnerActive = false;
                return;
            }
            else {
                this.isSpinnerActive = true;
                for (var i = 0; i < data.length; i++) {
                    console.log(data[i].sobjectType);
                    if (this.isRecordEdited) {
                        data[i].Id = this.objectIdMap[data[i].sobjectType];
                        if (this.isMobileEdited)
                            data[i].Mobile_Verified__c = false;
                    }
                    data[i].Id = this.objectIdMap[data[i].sobjectType];
                    data[i].Is_Lead_Detail_Done__c = true;
                    if (data[i].sobjectType == 'Account') {
                        delete data[i].Name;
                    }

                    if (this.customerTypeEdit === 'Primary Applicant' && data[i].sobjectType == 'Loan_Applicant__c') {
                        data[i].Relationship_With_Main_Applicant__c = 'Self';
                    }

                    console.log('======= data ========')
                    console.log(JSON.stringify(data[i]));
                    console.log('======= data ========')
                    saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                        .then(result => {
                            this.fieldsContent = '';
                            this.isSpinnerActive = false;
                            this.isKYCChanged = false;
                            this.showtoastmessage('Success', 'Success', 'Information Updated Successfully.');
                            this.getPersonalInformationData(true, false);
                        })
                        .catch(error => {
                            console.log(error);
                            this.showtoastmessage('Error', 'Error', JSON.stringify(error));
                        });
                }
            }

        } else {
            this.showtoastmessage('Error', 'Error', 'Complete Required Field(s).');
        }
    }
    handleCancel() {
        console.log('handle cancel called ###');
        this.fieldsContent = undefined;
        this.isKYCChanged = false;
        this.getPersonalInformationData(true, false);
    }
    showtoastmessage(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    @api getPersonalInformationData(isRefresh, isPartialSave) {
        console.log('::: allLoanApplicant ::: ', JSON.stringify(this.allLoanApplicant));
        if (!isPartialSave) {
            getPersonalInformationData({ allLoanApplicant: this.allLoanApplicant })
                .then(result => {
                    if (isRefresh)
                        this.template.querySelector('c-generic-data-table-l-w-c').init(result);
                    this.tableData = result;
                    //checkValidity
                    this.defLoanAppList = [];
                    console.log('Data###', JSON.stringify(result.strDataTableData));


                    if (result && result.strDataTableData && JSON.parse(result.strDataTableData).length) {
                        JSON.parse(result.strDataTableData).forEach(element => {
                            for (let keyValue of Object.keys(element)) {
                                if (keyValue === 'Customer_Information__r.Id') {
                                    console.log('Customer_Information__rkeyy val ', element[keyValue])
                                    const selectedEvent = new CustomEvent("handletabvaluechange", {
                                        detail: { tabname: 'Application Information', subtabname: 'Applicant Information', fieldapiname: 'Customer_Information__c', fieldvalue: element[keyValue], recordId: element.Id }
                                    });
                                    this.dispatchEvent(selectedEvent);
                                }
                                if (keyValue != 'Id' && !keyValue.includes('Customer_Information_')) {
                                    let value = element[keyValue];
                                    if ((keyValue == 'Duration_At_This_Address_From__c' || keyValue == 'Duration_At_This_Address_To__c' || keyValue == 'Duration_At_This_City_From__c' || keyValue == 'Duration_At_This_City_To__c' || keyValue == 'PersonBirthdate' || keyValue == 'Customer_Information__r.PersonBirthdate') && value && value.trim()) {
                                        value = value.substr(0, 10);
                                    } else if ((keyValue == 'Duration_At_This_Address_From__c' || keyValue == 'Duration_At_This_Address_To__c' || keyValue == 'Duration_At_This_City_From__c' || keyValue == 'Duration_At_This_City_To__c' || keyValue == 'PersonBirthdate' || keyValue == 'Customer_Information__r.PersonBirthdate')) {
                                        value = null;
                                    }
                                    if (keyValue != 'Name') {
                                        const selectedEvent = new CustomEvent("handletabvaluechange", {
                                            detail: { tabname: 'Application Information', subtabname: 'Applicant Information', fieldapiname: keyValue, fieldvalue: value, recordId: element.Id }
                                        });
                                        this.dispatchEvent(selectedEvent);
                                    }
                                } else if (keyValue != 'Id' && keyValue.includes('Customer_Information_')) {
                                    let value = element[keyValue];
                                    console.log('*** CUSTOMER FIELD VALUE = ', keyValue, value, ' = ', keyValue.split('.'));
                                    if (keyValue.includes('.') && keyValue.split('.').length) {
                                        keyValue = keyValue.split('.')[1];
                                        if ((keyValue == 'PersonBirthdate') && value && value.trim()) {
                                            value = value.substr(0, 10);
                                        } else if ((keyValue == 'PersonBirthdate')) {
                                            value = null;
                                        }
                                        console.log('*** CUSTOMER FIELD VALUE After ', keyValue, value)
                                        const selectedEvent = new CustomEvent("handletabvaluechange", {
                                            detail: { tabname: 'Application Information', subtabname: 'Customer Information', fieldapiname: keyValue, fieldvalue: value, recordId: element["Customer_Information__r.Id"] }
                                        });
                                        this.dispatchEvent(selectedEvent);
                                    }
                                }
                            }
                        });

                    }

                    var temp = JSON.parse(result.strDataTableData);
                    console.log('temp #### ', JSON.stringify(temp));

                    var validationList = {
                        'IsAllRecordEdit': '',
                        'IsCoApplicant': false,
                        'IsGuarantor': false,
                        'IsMobileVerified': true,
                        'mobileVerifiedData': [],
                        'isBureauVerified': true,
                        'bureauVerifiedData': [],
                    };
                    var customerType = ['Guarantor', 'Co-Applicant'];
                    for (var i in temp) {
                        var dataResult = temp[i];
                        //if (!isRefresh) {
                        this.isBureauInitiatedMap.set(dataResult['Id'], false);
                        //}
                        if (dataResult['Customer_Type__c'] === 'Co-Applicant' && customerType.includes(dataResult['Customer_Type__c'])) {
                            validationList.IsCoApplicant = true;
                        }
                        if (dataResult['Customer_Type__c'] === 'Guarantor' && customerType.includes(dataResult['Customer_Type__c'])) {
                            validationList.IsGuarantor = true;
                        }
                        if (dataResult['Mobile_Verified__c'] === false) {
                            validationList.IsMobileVerified = false;
                            console.log('validationList.IsMobileVerified==', validationList.IsMobileVerified);
                            validationList.mobileVerifiedData.push(dataResult['Name_LABEL']);
                        }
                        if (dataResult['Is_Bureau_Verified__c'] === false) {
                            validationList.isBureauVerified = false;
                            console.log('validationList.IsMobileVerified==', validationList.isBureauVerified);
                            validationList.bureauVerifiedData.push(dataResult['Name_LABEL']);
                        }

                        /*else{
                            validationList.IsMobileVerified = false;
                            this.isVerified = false;
                        }*/
                        if (dataResult['Is_Lead_Detail_Done__c'] === 'false') {
                            this.defLoanAppList.push(dataResult['Name_LABEL']);
                        }
                    }
                    //validationList.IsMobileVerified = this.isVerified;
                    validationList.IsAllRecordEdit = this.defLoanAppList;
                    const checkValidLoan = new CustomEvent("checkpersonalinfo", {
                        detail: validationList
                    });
                    this.dispatchEvent(checkValidLoan);
                })
                .catch(error => {

                })
        }
    }
    setValues(_fieldAPIName, _val, isAddressCopied) {
        var _tempVar = JSON.parse(this.fieldsContent);
        console.log('_tempVar ##### ', JSON.stringify(JSON.stringify(_tempVar)));
        console.log('SET VALUES _val = ', _val)
        console.log('_fieldAPIName = ', _fieldAPIName)

        var index;
        if (_fieldAPIName == 'Is_Residence_Address') {
            index = 1;
        }
        if (_fieldAPIName == 'Is_Permanent_Address') {
            index = 2;
        }
        if (_fieldAPIName == 'Is_Business_Address') {
            index = 3;
        }
        if (_fieldAPIName == 'Is_Residence_Address' || _fieldAPIName == 'Is_Business_Address' || _fieldAPIName == 'Is_Permanent_Address') {
            for (var i = 0; i < _tempVar[index].fieldsContent.length; i++) {
                if (_fieldAPIName === 'Is_Residence_Address') {
                    console.log('resi ### ', _tempVar[index].fieldsContent[i].fieldAPIName);
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Residence_City__c') {
                        _tempVar[index].fieldsContent[i].value = _val.city;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Residence_Taluka__c') {
                        _tempVar[index].fieldsContent[i].value = _val.taluka;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Residence_District__c') {
                        _tempVar[index].fieldsContent[i].value = _val.district;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Residence_State__c') {
                        _tempVar[index].fieldsContent[i].value = _val.state;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Residence_Pincode__c' && _val.pincode != undefined) {
                        _tempVar[index].fieldsContent[i].lookupVal = _val.pincode;
                        console.log('_tempVar[index].fieldsContent[i].valueeee ', _tempVar[index].fieldsContent[i].value);
                    }
                }
                if (_fieldAPIName === 'Is_Permanent_Address') {

                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_Flat_Plot_Number__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.flat;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_Address_Line_1__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.address1;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_Address_Line_2__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.address2;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_Landmark__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.landmark;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_Village__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.village;
                    }

                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_City__c') {
                        _tempVar[index].fieldsContent[i].value = _val.city;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_Taluka__c') {
                        _tempVar[index].fieldsContent[i].value = _val.taluka;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_District__c') {
                        _tempVar[index].fieldsContent[i].value = _val.district;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_State__c') {
                        _tempVar[index].fieldsContent[i].value = _val.state;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Permanent_Pincode__c' && _val.pincode != undefined) {
                        _tempVar[index].fieldsContent[i].lookupVal = _val.pincode;
                        console.log('permanent _tempVar[index].fieldsContent[i].valueeee ', _tempVar[index].fieldsContent[i].value);
                    }
                }
                if (_fieldAPIName === 'Is_Business_Address') {
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_Flat_Plot_Number__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.flat;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_Address_Line_1__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.address1;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_Address_Line_2__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.address2;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_Landmark__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.landmark;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_Village__c' && isAddressCopied) {
                        _tempVar[index].fieldsContent[i].value = _val.village;
                    }

                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_City__c') {
                        _tempVar[index].fieldsContent[i].value = _val.city;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_Taluka__c') {
                        _tempVar[index].fieldsContent[i].value = _val.taluka;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_District__c') {
                        _tempVar[index].fieldsContent[i].value = _val.district;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_State__c') {
                        _tempVar[index].fieldsContent[i].value = _val.state;
                    }
                    if (_tempVar[index].fieldsContent[i].fieldAPIName === 'Business_Pincode__c' && _val.pincode != undefined) {
                        _tempVar[index].fieldsContent[i].lookupVal = _val.pincode;
                        console.log('business _tempVar[index].fieldsContent[i].valueeee ', _tempVar[index].fieldsContent[i].value);
                    }
                }
            }
        }

        else {
            console.log('_tempVar[0].fieldsContent.lengthhhh ', _tempVar[0].fieldsContent.length)
            for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
                console.log('indian val ', _val)
                console.log('_tempVar[0].fieldsContent[i].fieldAPIName nationnn ?? ', _tempVar[0].fieldsContent[i].fieldAPIName)
                //if (_fieldAPIName === 'Nationality__c')
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Nationality__c') {
                    _tempVar[0].fieldsContent[i].value = _val;

                    console.log('inside setting nationality ', _tempVar[0].fieldsContent[i].value);
                }

                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'PersonBirthdate') {
                    _tempVar[0].fieldsContent[i].maxDate = this.todayDate();
                }
                if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName) {
                    if (_tempVar[0].fieldsContent[i].isCheckbox) {
                        _tempVar[0].fieldsContent[i].checkboxVal = Boolean(_val);
                    } else if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName && _val) {
                        console.log('*** inside ***');
                        _tempVar[0].fieldsContent[i]['fieldAttribute'].isRequired = true;
                    } else if (_tempVar[0].fieldsContent[i].fieldAPIName === _fieldAPIName && !_val) {
                        console.log('*** inside 2 ***');
                        _tempVar[0].fieldsContent[i]['fieldAttribute'].isRequired = false;
                    } else {
                        _tempVar[0].fieldsContent[i].value = _val;
                    }

                }
                if (this.customerTypeEdit !== 'Primary Applicant' && _tempVar[0].fieldsContent[i].fieldAPIName === 'Relationship_With_Main_Applicant__c') {
                    _tempVar[0].fieldsContent[i].disabled = false;
                }
                else if (this.customerTypeEdit === 'Primary Applicant' && _tempVar[0].fieldsContent[i].fieldAPIName === 'Relationship_With_Main_Applicant__c') {
                    _tempVar[0].fieldsContent[i].value = 'Self';
                }
            }
        }
        console.log('Final _tempVar= ', JSON.parse(JSON.stringify(_tempVar)))
        this.fieldsContent = JSON.stringify(_tempVar);

        if (_fieldAPIName == 'Is_Residence_Address' || _fieldAPIName == 'Is_Business_Address' || _fieldAPIName == 'Is_Permanent_Address') {
            for (var i = 0; i < _tempVar[index].fieldsContent.length; i++) {
                if (_tempVar[0].fieldsContent[i].fieldAPIName === 'Business_Pincode__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_State__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_District__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_District__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_Taluka__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_City__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_Village__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_Landmark__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_Address_Line_2__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_Address_Line_1__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Business_Flat_Plot_Number__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Pincode__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_State__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_District__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Taluka__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_City__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Village__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Landmark__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Address_Line_2__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Address_Line_1__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Flat_Plot_Number__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Residence_City__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Residence_Taluka__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Residence_District__c' ||
                    _tempVar[0].fieldsContent[i].fieldAPIName === 'Residence_State__c' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Residence_Pincode__c') {
                    let fName = _tempVar[0].fieldsContent[i].fieldAPIName;
                    let fValue = _tempVar[0].fieldsContent[i].value;
                    let rcId = this.loanAppId ? this.loanAppId : '1';
                    console.log('fName + fValue', fName, ' fValue ', fValue)
                    const selectedEvent = new CustomEvent("handletabvaluechange", {
                        detail: { tabname: 'Application Information', subtabname: 'Applicant Information', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
                    });
                    this.dispatchEvent(selectedEvent);
                }
            }
        }
        for (var i = 0; i < _tempVar[0].fieldsContent.length; i++) {
            if (_tempVar[0].fieldsContent[i].fieldAPIName === 'PersonBirthdate' || _tempVar[0].fieldsContent[i].fieldAPIName === 'Permanent_Flat_Plot_Number__c'
                || _tempVar[0].fieldsContent[i].fieldAPIName === 'Name') {
                let fName = _tempVar[0].fieldsContent[i].fieldAPIName;
                let fValue = _tempVar[0].fieldsContent[i].value;
                console.log('fName222  + fValue', fName, ' fValue ', fValue)
                if (_tempVar[0].fieldsContent[i].objectAPIName == 'Loan_Applicant__c') {
                    let rcId = this.loanAppId ? this.loanAppId : '1';
                    if ((fName == 'Duration_At_This_Address_From__c' || fName == 'Duration_At_This_Address_To__c' || fName == 'Duration_At_This_City_From__c' || fName == 'Duration_At_This_City_To__c') && fValue && fValue.trim()) {
                        fValue = fValue.substr(0, 10);
                    } else if ((fName == 'Duration_At_This_Address_From__c' || fName == 'Duration_At_This_Address_To__c' || fName == 'Duration_At_This_City_From__c' || fName == 'Duration_At_This_City_To__c')) {
                        fValue = null;
                    }
                    const selectedEvent = new CustomEvent("handletabvaluechange", {
                        detail: { tabname: 'Application Information', subtabname: 'Applicant Information', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
                    });
                    this.dispatchEvent(selectedEvent);
                } else if (_tempVar[0].fieldsContent[i].objectAPIName == 'Account') {
                    let rcId = this.customerId ? this.customerId : '1';
                    if ((fName == 'PersonBirthdate') && fValue && fValue.trim()) {
                        fValue = fValue.substr(0, 10);
                    } else if ((fName == 'PersonBirthdate')) {
                        fValue = null;
                    }
                    if (fName != 'Name') {
                        const selectedEvent = new CustomEvent("handletabvaluechange", {
                            detail: { tabname: 'Application Information', subtabname: 'Customer Information', fieldapiname: fName, fieldvalue: fValue, recordId: rcId }
                        });
                        this.dispatchEvent(selectedEvent);
                    }
                }
            }
        }

        return _tempVar;
    }

    handlemodalactions(event) {
        this.showDeletePopup = false;
        if (event.detail === true)
            this.getPersonalInformationData(true, false);
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
                    this.showtoastmessage('Error', 'Error', 'Sourcing Branch Does Not Exist, Please Fill In Application Details Tab');
                }else if(result.length == 1 && result[0] === 'Branch Manager Not Exist'){
                    console.log('result Sent to BM >>',result);
                    this.showToast('Error', 'Error', 'Branch Manager Does Not Exist');
                }else if(result.length == 1 && result[0] === 'Sent to BM'){
                    console.log('result Sent to BM >>',result);
                    this.showtoastmessage('Success', 'Success', 'Applicants Sent to BM for KYC Verification');
                }else if(result.length == 1 && result[0] === 'KCY Already Verified'){
                    console.log('result KCY Already Verified >>',result);
                    this.showtoastmessage('Success', 'Success', 'KCY Already Verified');
                }else{
                    console.log('result >>',result);
                    listOfLoanApplicant = result;
                    this.showtoastmessage('Error', 'Error', 'Please Initiate KYC Verification for these applicants '+listOfLoanApplicant.join());
                }
            }else{
                this.showtoastmessage('Error', 'Error','Failed Sent to BM');
            }
        })
        .catch(error => {
            this.isSpinnerActive = false;
            this.showtoastmessage('Error', 'Error','Failed Sent to BM');
            this.error = error;
        });
        
    } 

    reloadDataTable(event) {
        if (event.detail) {
            this.isSpinnerActive = false;
            this.showMobileVerification = false;
            this.getPersonalInformationData(true, false);
        }
    }
    todayDate() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear() - 18;
        var todayDate = yyyy + '-' + mm + '-' + dd;
        console.log('todayDate ### ', todayDate);
        return todayDate;
    }
}