import { LightningElement, api, track, wire } from 'lwc';
import SendOTP from '@salesforce/apex/MobileVerificationController.SendOTP';
import ValidateOTP from '@salesforce/apex/MobileVerificationController.ValidateOTP';
import loanAppMobileVerification from '@salesforce/apex/MobileVerificationController.loanAppMobileVerification';
import { updateRecord } from 'lightning/uiRecordApi';
import Mobile_Verification_Type from '@salesforce/schema/Loan_Applicant__c.Mobile_Verification_Type__c';
import Mobile_Verified from '@salesforce/schema/Loan_Applicant__c.Mobile_Verified__c';
import PC_Mobile_Verified from '@salesforce/schema/Loan_Applicant__c.PC_Mobile_Verified__c';
import AC_Mobile_Verified from '@salesforce/schema/Loan_Applicant__c.AC_Mobile_Verified__c';
import Loan_Applicant_Id from '@salesforce/schema/Loan_Applicant__c.Id';
import Manual_Confirmation_Text from '@salesforce/label/c.Manual_Mobile_Verification_Confirmation_Text';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class FsMobileVerificationLWC extends LightningElement {

    @api stage;
    @api loanApplicantId;
    @api mobileNumber;

    @track isModalOpen = false;
    @track requestId;
    @track otp;
    @track validate = 'Validate';
    @track loanAppId;
    @track mobileno;
    @track isLogin = false;
    @track showManualScreen = false;
    @track selectedVerType;
    @track manualVerifyButton = false;
    @track systemVerifyButton = false;
    @track sendOTPButton = false;
    @track showCheckbox = false;
    @track isSpinnerActive = false;
    @track confirmationText = Manual_Confirmation_Text;
    @track options = [
        { value: "System", label: "System" },
        { value: "Manual", label: "Manual" }
    ];


    connectedCallback() {
        console.log('Stage == ', this.stage);
        this.isModalOpen = true;
        this.isLogin = this.stage === 'Login' || this.stage === 'Lead Detail Maker' || this.stage === 'Lead Detail Checker'  ? true : false;
        if (this.isLogin) {
            this.sendMobOTP(this.loanApplicantId, this.mobileNumber);
            this.systemVerifyButton = true;
        }
        this.showManualScreen = this.isLogin ? false : true;
    }

    handleChange(event) {
        console.log(event.detail);
        this.showCheckbox = event.target.dataset.id === 'mobVerify' && event.detail.value === 'System' ? false : true;
        this.sendOTPButton = !this.showCheckbox;
        this.manualVerifyButton = event.target.dataset.id === 'confirm' && event.detail.checked ? true : false;
    }

    handleSendOTP() {
        this.showManualScreen = false;
        this.sendMobOTP(this.loanApplicantId, this.mobileNumber);
        this.systemVerifyButton = true;
        this.sendOTPButton = false;
    }

    @api sendMobOTP(loanAppId, mobileNo) {
        this.loanAppId = loanAppId;
        this.mobileno = mobileNo;
        console.log('SEND OTP CALLED Acc Id :: ', loanAppId + ' , Mobile :: ', mobileNo);
        SendOTP({ loanAppId: loanAppId, MobileNo: mobileNo })
            .then(result => {
                console.log('Result ', result);
                const wrapper = result;
                const description = wrapper.description;
                this.requestId = wrapper.requestId;
                const msg = wrapper.msg;
                console.log(wrapper + ' ' + description + ' ' + this.requestId);
                if (msg === '101') {
                    this.showToast('', 'Success', 'OTP Has Been Sent On Your Mobile Number!!');
                    this.closeAction();
                    this.isModalOpen = true;
                }
                else if (msg != '101') {
                    this.showToast('Error', 'Error', description);
                    this.closeModal();
                }

            })
            .catch(error => {
                console.log('error ', error);
                this.showToast('Error', 'Error', 'Mobile Verification Failed!!');
                this.closeModal();
            })
    }

    handleOTP(event) {
        console.log('OTP ', event.detail.value);
        this.otp = event.detail.value;
    }

    validateOTP(event) {
        console.log('this.otp ', this.otp);
        console.log('Validate!!');
        if (this.otp) {
            console.log('OTP ', this.otp);
            this.validate = 'Verifying';
            //this.showSpinner = true;
            console.log('loanAppId ', this.loanAppId);
            this.validateMobOtp(this.loanAppId, this.requestId, this.otp);
        }
        else {
            this.showToast('Error', 'Error', 'Please Enter OTP!!');
            this.closeAction();
        }
    }

    verifyMobManually() {
        this.validate = 'Verifying..';
        this.isSpinnerActive = true;
        const fields = {};
        fields[Loan_Applicant_Id.fieldApiName] = this.loanApplicantId;
        fields[Mobile_Verified.fieldApiName] = true;
        if(this.stage === 'Process Credit')
            fields[PC_Mobile_Verified.fieldApiName] = true;
        if(this.stage === 'Approval Credit')
            fields[AC_Mobile_Verified.fieldApiName] = true;
        fields[Mobile_Verification_Type.fieldApiName] = 'Manual';
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            const reloadTable = new CustomEvent("reloaddatatable", {
                detail: true
            });
            console.log('dispatch event ', reloadTable);
            this.dispatchEvent(reloadTable);
            this.showToast('Success', 'Success', 'Mobile Number Verified Successfully');
            this.isSpinnerActive = false;
            this.closeModal();
        })
            .catch(error => {
                console.error('ERROR ', error);
                this.showToast('Error', 'Error', 'Error :: ' + error);
                this.isSpinnerActive = false;
                this.closeModal();
            })
    }

    validateMobOtp(loanAppId, requestId, otp) {
        console.log('loanAppId :: ', loanAppId + ' Request id :: ', requestId + ' otp :: ', otp);
        ValidateOTP({ loanAppId: loanAppId, requestId: requestId, OTP: otp })
            .then(result => {
                console.log('OTP RESULT ', result);
                //this.showSpinner = false;
                const wrapper = result;
                const description = wrapper.description;
                const msg = wrapper.msg;
                console.log(wrapper + ' ' + description + ' ' + requestId);
                if (msg === '101') {
                    this.showToast('Success', 'Success', 'Mobile Number Verified Successfully');
                    this.closeAction();
                    console.log('loanAppId Id ', loanAppId);
                    loanAppMobileVerification({ loanAppId: loanAppId })
                        .then(result => {
                            console.log('Account Updated Result ', result);
                            const reloadTable = new CustomEvent("reloaddatatable", {
                                detail: result
                            });
                            console.log('dispatch event ', reloadTable);
                            this.dispatchEvent(reloadTable);
                        })
                        .catch(error => {
                            this.showToast('Error', 'Error', 'Error :: ' + error);
                            this.closeAction();
                        })
                    this.closeModal();
                }
                else if (msg != '101') {
                    this.showToast('Error', 'Error', 'Error :: ' + description);
                    this.closeAction();
                }
                this.validate = 'Validate';
            })
            .catch(error => {
                console.log('Error ', error);
                this.showToast('Error', 'Validation Failed!!');
                //this.showSpinner = false;
                this.closeModal();
            })
    }

    resendMobOTP(event) {
        console.log(this.loanAppId, this.mobileno)
        this.sendMobOTP(this.loanAppId, this.mobileno);
    }

    closeModal() {
        this.isModalOpen = false;
        const hideMobilePopup = new CustomEvent("hidemobilepopup", {
            detail: false
        });
        console.log('dispatch event ', hideMobilePopup);
        this.dispatchEvent(hideMobilePopup);
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