import { LightningElement, api, wire, track } from 'lwc';
import docallOCRAPI from '@salesforce/apex/FS_PreLoginController.SubmitForOCR';
import insertPreLogin from '@salesforce/apex/FS_PreLoginController.insertPreLogin';
import getAccData from '@salesforce/apex/FS_PreLoginController.getAccData';
import insertSelfDocuments from '@salesforce/apex/FS_PreLoginController.insertSelfDocuments';
import delAccount from '@salesforce/apex/FS_PreLoginController.delAccount';
import SendOTP from '@salesforce/apex/FS_PreLoginControllerMock.SendOTP';
import ValidateOTP from '@salesforce/apex/FS_PreLoginControllerMock.ValidateOTP';
import accMobileVerification from '@salesforce/apex/FS_PreLoginController.accMobileVerification';
import getProperty from '@salesforce/apex/FS_PreLoginController.getProperty';
import getPincodeDetails from '@salesforce/apex/FS_PreLoginController.getPincodeDetails';
import getPincode from '@salesforce/apex/FS_PreLoginController.getPincode';
import checkAPILogger from '@salesforce/apex/FS_PreLoginController.checkAPILogger';
import insertApplications from '@salesforce/apex/FS_PreLoginController.insertApplications';
import updateLA from '@salesforce/apex/FS_PreLoginController.updateLA';
import getApplicationId from '@salesforce/apex/FS_PreLoginController.getApplicationId';
import getKYCReport from '@salesforce/apex/KYCAPIController.getKYCReport';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CustomerApplicationScreen extends NavigationMixin(LightningElement) {

    //CUSTOMER SCREEN ATTRIBUTE
    @track tooltip = 'KYC ID 1';
    @track tooltip2 = 'KYC ID 2'
    @api nextPrelogin = 'prelogin';
    @api nextProperty;
    @api preLogInId;
    @api applicantTypeOption = [];
    @api accountId;
    @api applicantTypeList = []; // NIU
    @api mobVerificationList = [];
    @api recordId;
    @api validApplicant = false;
    @api validMobile = false;
    @api hasProperty = false;
    @api recordTypeId;
    @api preAppId;
    @api preAppName;
    @api hasAllFieldApp;
    @api oldAppName;
    @api initiateFrom;
    @api loanAppId;

    @track showKYCTable = false;
    @track appName;
    @track reloginApp;
    @track reloginKYC;
    @track applicantTypeValue = 'Primary Applicant';
    @track KYCTypeValue = 'Aadhar_Card';
    @track KYCTypeValue1;
    @track KYCTypeValue2;
    @track verificationDefaultvalue = 'OCR';
    @track showFrontUpload = true;
    @track showRearUpload = true;
    @track countPrimaryType = 0;
    @track listOfApplicants = []; // NIU
    @track frontbase64;
    @track rearbase64;
    @track countApplicantType = 0;
    // For Getting OCR Response
    @track resultwrapper = { kycId: '', Name: '', firstName: '', lastName: '', FathersName: '', MothersName: '', SpouceName: '', DOB: '', mobile_1: '', mobile_2: '', City: '', Pincode: '', Address: '' };
    // For Storing Customer Details
    @track customerWrapper = {
        kycId: '', incCon: '', appType: '', Gender: '', Salutation: '',
        firstName: '', lastName: '', FathersName: '', MothersName: '',
        married: '', SpouceName: '', DOB: '', mobile_1: '', mobile_2: '',
        City: '', district: '', Pincode: '', Address: '',
        verification: this.verificationDefaultvalue, Applicant_Type: this.applicantTypeValue,
        kycId1: '', kycId2: '', constitution: ''
    };

    @track ocrCustomerWrapper = {
        kycType1: '', kycType2: '', incCon: '', appType: '', Gender: '', Salutation: '',
        firstName: '', lastName: '', FathersName: '', MothersName: '',
        married: '', SpouceName: '', DOB: '', mobile_1: '', mobile_2: '',
        City: '', district: '', Pincode: '', Address: '',
        verification: this.verificationDefaultvalue, Applicant_Type: this.applicantTypeValue,
        kycId1: '', kycId2: '', constitution: ''
    };

    @track kycIdTypeOption = [];
    @track nameTypeOption = [];
    @track firstNameOption = [];
    @track lastNameOption = [];
    @track fatherTypeOption = [];
    @track motherTypeOption = [];
    @track spouseTypeOption = [];
    @track dobTypeOption = [];
    @track mbl1TypeOption = [];
    @track mbl2TypeOption = [];
    @track cityTypeOption = [];
    @track districtTypeOption = [];
    @track apiLogger;
    @track kycOcrLogger;
    @track apiLoggerList = [];
    @track kycLoggerList = [];
    @track pinTypeOption = [];
    @track addressTypeOption = [];
    @track frontImageName;
    @track rearImageName;
    @track ImageNameself;
    @track ImageNameself2;
    @track disableSubmit = true;
    @track kycValue; // NIU
    @track countAdhar = 0;
    @track countVoter = 0;
    @track countPan = 0;
    @track countDL = 0;
    @track countPassport = 0;
    @track showBreak = false;
    @track countSave = 0;
    @track kyclist = [];
    @track front64list = [];
    @track back64list = [];
    @track frontnmlist = [];
    @track backnmlist = [];
    @api recTypeId;
    @track kycIdValues = [];
    @track hashKYC = [];
    @track primaryApplicantName;
    @track oldMobile;
    @track countTrue = 0;
    @track valueSelf = false;
    @track isRelogin = false;
    @track saveOCR = 'Save';
    @track todaysDate = new Date();
    @track loadCss = false;
    @api hasReceipt = false;
    @api allApproved = false;
    @api pendingReceiptList = [];
    @track showUploadBtn = false;
    @track cashierType = [];
    @track cashierValue;
    @api receiptScreen = '';
    @api moveNextApp = { screen: '', moveNext: '' };
    @api appScreen;
    @track frontImageUrl;
    @track backImageUrl;
    @track frontFileType;
    @track backFileType;
    @track frontUpload = 0;
    @track backUPload = 0;
    @track appNumber;
    @track kycNumber;
    @track isPrimary = false;
    @track requiredSpouse = false;
    @track appResult = [];
    @track isAppDataArrived = false;
    @api hasRelogin = false;
    @api countsearch = 0;
    @track city;
    @track pincode;
    @track state;
    @track district;
    @track laFields;
    @track isModalOpenDelProp = false;
    @track propId;
    @track salutation = '';
    @track constitutionValue;
    //@track editMobile = false;
    @track saveAcc = false;
    @track isKYC1Correct = false;
    @track isKYC2Correct = false;
    @track accId;
    @track customerType;
    @track mobileno;
    @track disableAppType = false;
    @track editAccount = false;
    @track openFrontImg = false;
    @track openBackImg = false;

    @api isIncomeConsidered = false;
    @api countprimaryApp = 0;

    @track currentStep;
    @api nextrelogin = 'relogin';
    @api nexttopup = 'topup'
    @api isTopup = false;
    @api recordTypeName;
    @api hasPrimaryOwner = false;
    @track isPropDataArrived = false;
    @track propData = [];
    @track hasPropertyAcc = false;

    //PROPERTY SCREEN ATTRIBUTE
    @api
    myRecordId;
    value = '';
    Propertytypevalue = '';
    @api collateralId;
    @api applicantValue;
    @api applicationId;
    @api collateralRecords = { subType: '', purchaseType: '', titleNo: '', titleDate: '', propertySch: '', nature: '', propCost: '', Applicants: '', Current_Usage: '', Property_Type: '', preLogin: '', ApplicationId: '' };

    @track propRecordType;
    @track customerId;
    @track saveLabel = 'Save';
    @track validate = 'Validate';
    @track otp;
    @track requestId;
    @track showSpinner = false;
    @track isModalOpenDel = false;
    @track delRecord = false;
    @track isModalOpen = false;
    @track listOfAccounts;
    @track data = [];
    @track accData = [];
    @track dataReceipt = [];
    @track statusReceipt = [];
    @track isAccDataArrived = false;
    @track isDataArrived = false;
    @track isReceiptDataArrived = false;
    @track siteURL;
    @track selfSave = 'Save';
    @track showselfonly = false;
    @api accountWrapper = { preLogInId: '', applicationId: '', applicantTypeList: '', validMobile: '', validApplicant: '', mobVerificationList: [], countprimaryApp: '', primaryApplicantName: '', applicantTypeOption: [] };
    @api ocrdata = [];
    @track ocrDataMap = {
        Aadhar_Card: {},
        Voter_Id: {},
        Pan_Card: {},
        Driving_License: {},
        Passport: {},
    };
    @track accountRecordWrapper = { firstName: '', lastName: '', gender: '', salutation: '', dob: '', fatherName: '', motherName: '' };
    @track loanWrapper = {}

    @track columns = [
        { label: 'KYC Type', fieldName: 'kycType', type: 'text', wrapText: true },
        { label: 'KYC ID', fieldName: 'kycNo', type: 'text', wrapText: true },
        { label: 'First Name', fieldName: 'firstName', type: 'text', wrapText: true },
        { label: 'Last Name', fieldName: 'lastName', type: 'text', wrapText: true },
        { label: 'Father\'s Name', fieldName: 'FathersName', type: 'text', wrapText: true },
        { label: 'Mother\'s Name', fieldName: 'MothersName', type: 'text', wrapText: true },
        { label: 'Spouse Name', fieldName: 'SpouceName', type: 'text', wrapText: true },
        {
            label: 'Date Of Birth', fieldName: 'DOB', type: 'date-local', wrapText: true
        },
        { label: 'Mobile Number', fieldName: 'mobile_1', type: 'text', wrapText: true },
        { label: 'City', fieldName: 'City', type: 'text', wrapText: true },
        { label: 'Pincode', fieldName: 'Pincode', type: 'text', wrapText: true },
        {
            type: "button", typeAttributes: {
                label: 'Select',
                name: 'Select',
                title: 'Select',
                disabled: false,
                value: 'Select',
                iconPosition: 'left'
            }
        }
    ];

    @track accRowAction = [
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
        },
        {
            //label: 'Mobile Verification',
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
            //label: 'Validate KYC',
            type: 'button-icon',
            fixedWidth: 50,
            typeAttributes: {
                iconName: 'utility:asset_audit',
                title: 'Validate KYC',
                variant: 'border-filled',
                alternativeText: 'Validate KYC',
                name: 'validate'
            }
        }
    ];

    handleRowAction(event) {
        const row = event.detail.row;
        console.log('row data ', JSON.stringify(row));
        this.ocrCustomerWrapper = (JSON.parse(JSON.stringify(row)));
        console.log(JSON.stringify(this.ocrCustomerWrapper));

        this.accountRecordWrapper.firstName = row.firstName;
        this.accountRecordWrapper.lastName = row.lastName;
        this.accountRecordWrapper.gender = row.Gender;
        //this.accountRecordWrapper.salutation = row.firstName;
        this.accountRecordWrapper.dob = row.DOB;
        this.accountRecordWrapper.fatherName = row.FathersName;
        this.accountRecordWrapper.motherName = row.MothersName;

        this.ocrCustomerWrapper.kycType1 = row.kycType;
        this.ocrCustomerWrapper.kycId1 = this.kycIdValues[0];
        if (this.kycIdValueslength > 1)
            this.ocrCustomerWrapper.kycId2 = this.kycIdValues[1];
        console.log('pincode row ', row.Pincode);
        this.ocrCustomerWrapper.Pincode = null;
        if (row.Pincode) {
            getPincode({ pincode: row.Pincode }).then(result => {
                console.log('result pincode ', result);
                if (result != null && result != undefined && result != '') {
                    this.ocrCustomerWrapper.Pincode = result.pinId;
                    this.city = result.city;
                    this.state = result.state;
                    this.district = result.district;
                }
                else {
                    console.log('this.ocrCustomerWrapper.Pincode ', this.ocrCustomerWrapper.Pincode);
                    this.ocrCustomerWrapper.Pincode = null;
                }
            })
                .catch(error => {
                    this.ocrCustomerWrapper.Pincode = null;
                    console.log('error in pincode ', error);
                })
        }

    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.isModalOpenDel = false;
        this.openFrontImg = false;
        this.openBackImg = false;
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    get SalutationOption() {
        return [
            { label: '--None--', value: '' },
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Mrs.', value: 'Mrs.' }
        ];
    }

    get genderOption() {
        return [
            { label: 'Male', value: 'Male' },
            { label: 'Female', value: 'Female' },
            { label: 'Other', value: 'Other' },
        ]
    }

    get getMarriedStatus() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ]
    }

    get applicantTypePicklistValue() {
        return [
            { label: 'Primary Applicant', value: 'Primary Applicant' },
            { label: 'Co-Applicant', value: 'Co-Applicant' },
            { label: 'Guarantor', value: 'Guarantor' },
        ];
    }

    get KYCTypePicklistValue() {
        return [
            { label: 'Aadhaar Card', value: 'Aadhar_Card' },
            { label: 'Voter ID', value: 'Voter_Id' },
            { label: 'PAN', value: 'Pan_Card' },
            { label: 'Driving License', value: 'Driving_License' },
            { label: 'Passport', value: 'Passport' }
        ];
    }

    //PROPERTY    
    connectedCallback() {
        try {
            console.log('step 1 screen running');
            console.log('login Id ', this.recordId);
            console.log('Reord Type Id :: ', this.recordTypeId);
            console.log('Application id ', this.applicationId);
            if (this.applicationId) {
                this.getAccountData(this.applicationId);
            }
        }
        catch (exe) {
            console.log('Exception in customer application screen ', exe);
        }
    }

    getPropertyAccData() {
        console.log('get property data called!!', this.accountId);
        getProperty({ accountId: this.accountId })
            .then(result => {
                var temp = JSON.parse(result.strDataTableData);
                console.log('temp', temp);
                console.log('property length ', temp.length);
                if (temp.length === 0) {
                    this.hasPropertyAcc = false;
                }
                else {
                    this.hasPropertyAcc = true;
                }
                console.log('haspropertyacc ', this.hasPropertyAcc);
                this.propData = [];
                this.propData = result;
                this.isPropDataArrived = true;
                console.log('json data ====> ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('error in getproprtyaccdata ', error);
            })
    }

    @api getAccountData(applicationId) {
        console.log('get Acc data called!!', applicationId);
        this.countprimaryApp = 0;
        getAccData({ applicationId: applicationId })
            .then(result => {
                console.log('getacc data in customer screen');
                this.isIncomeConsidered = false;
                this.applicantTypeOption = [];
                this.mobVerificationList = [];
                this.countTrue = 0;
                this.validMobile = false;
                this.validApplicant = false;
                this.countPrimaryType = 0;
                console.log('json data ====> ' + JSON.stringify(result));
                var temp = JSON.parse(result.strDataTableData);
                console.log('temp', temp);
                console.log('temp length', temp.length);
                //console.log('temp', temp[0]['Customer_Information__r_FirstName_LABEL']);
                for (var i in temp) {
                    var dataResult = temp[i];
                    console.log('Customer_Type__c ', dataResult['Customer_Type__c']);
                    console.log('FirstName ', dataResult['Customer_Information__r_FirstName_LABEL']);
                    console.log('LastName ', dataResult['Customer_Information__r.LastName']);
                    console.log('Mobile_Verified__c ', dataResult['Mobile_Verified__c']);
                    console.log('Id ', dataResult['Id']);
                    console.log('Account Id  ', dataResult['Customer_Information_VALUE']);
                    // let text = dataResult['Customer_Information_VALUE'];
                    // const myArray = text.split("/");
                    // let word = myArray[3];
                    const accId = dataResult['Id'];
                    //this.accountId = word;
                    console.log('accId ', accId);
                    const fName = dataResult['Customer_Information__r_FirstName_LABEL'];
                    const lName = dataResult['Customer_Information__r.LastName'];
                    if (dataResult['Customer_Type__c'] === 'Primary Applicant') {
                        this.countPrimaryType = this.countPrimaryType + 1;
                        this.countprimaryApp = this.countprimaryApp + 1;
                        this.validApplicant = true;
                        this.primaryApplicantName = dataResult['Customer_Information__r_FirstName_LABEL'] + ' ' + dataResult['Customer_Information__r.LastName'];
                    }
                    console.log('validApplicant :: ', this.validApplicant);
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
                    console.log('validMobile :: ', this.validMobile);
                    const applicants = {
                        label: fName + ' ' + lName,
                        value: accId
                    };
                    this.applicantTypeOption = [...this.applicantTypeOption, applicants];
                    console.log('Applicant Values ', this.applicantTypeOption);
                }
                console.log('counttrue :: ', this.countTrue + ' :: ', temp.length);
                if (this.countTrue == temp.length) {
                    this.validMobile = true;
                }
                this.accData = [];
                this.accData = result;
                this.isAccDataArrived = true;
                this.accountWrapper.preLogInId = this.preLogInId;
                this.accountWrapper.applicationId = applicationId;
                //this.accountWrapper.applicantTypeList = this.applicantTypeList;
                this.accountWrapper.validApplicant = this.validApplicant;
                this.accountWrapper.validMobile = this.validMobile;
                this.accountWrapper.isIncomeConsidered = this.isIncomeConsidered;
                this.accountWrapper.mobVerificationList = this.mobVerificationList;
                this.accountWrapper.countprimaryApp = this.countPrimaryType;
                this.accountWrapper.primaryApplicantName = this.primaryApplicantName;
                this.accountWrapper.applicantTypeOption = this.applicantTypeOption;
                const preloginAccEvent = new CustomEvent("preloginaccevent", {
                    detail: this.accountWrapper
                });
                console.log('dispatch event preloginAccEvent ', preloginAccEvent);
                this.dispatchEvent(preloginAccEvent);
                console.log('json data 1 ====> ' + JSON.stringify(this.accData));
                console.log('DATA ', this.accData);
            })
            .catch(error => {
                console.log('Error In Get ACC Data ', error);
            })
    }

    handleAccRecord(event) {
        if (event.target.name == 'gender') {
            console.log('gender ', event.detail.value);
            this.accountRecordWrapper.gender = event.detail.value;
        }
        else if (event.target.name == 'firstName') {
            console.log('firstName ', event.detail.value);
            this.accountRecordWrapper.firstName = event.detail.value;
        }
        else if (event.target.name == 'lastName') {
            console.log('lastName ', event.detail.value);
            this.accountRecordWrapper.lastName = event.detail.value;
        }
        else if (event.target.name == 'dob') {
            console.log('dob ', event.detail.value);
            var d1 = new Date();
            var d2 = new Date(event.detail.value);
            var age = d1.getFullYear() - d2.getFullYear();
            console.log('age ', age);
            //event.target.value = '';
            if (d2.getTime() > d1.getTime() || age < 1) {
                if (d2.getTime() > d1.getTime()) {
                    this.showToast('Error', 'error', 'Invalid DOB, Future Dates Are Not Allowed!!');
                    this.closeAction();
                    const inputFields = this.template.querySelector('[data-id="selfResetDate"]');
                    console.log('ResetKYC ', JSON.stringify(inputFields));
                    inputFields.reset();
                }
                if (age < 1) {
                    this.showToast('Error', 'error', 'Invalid Birth Date, Age should be minimum of 1 year!!');
                    this.closeAction();
                }
            }
            else
                this.accountRecordWrapper.dob = event.detail.value;
        }
        else if (event.target.name == 'fatherName') {
            console.log('fatherName ', event.detail.value);
            this.accountRecordWrapper.fatherName = event.detail.value;
        }
        else if (event.target.name == 'motherName') {
            console.log('motherName ', event.detail.value);
            this.accountRecordWrapper.motherName = event.detail.value;
        }
    }

    async handleSelectedAccount(event) {
        console.log('**2**', JSON.stringify(event.detail));
        var data = event.detail;
        this.accId = data.recordData.Id;
        let text = data.recordData.Customer_Information_VALUE;
        const myArray = text.split("/");
        let word = myArray[3];
        this.accountId = word;
        console.log('Account ID ', this.accountId);
        this.showselfonly = false;
        this.loanAppId = data.recordData.Id;
        if (data !== undefined && data !== '') {
            if (event.detail.ActionName === 'edit') {
                this.showselfonly = true;
                this.editAccount = true;
                this.saveAcc = false;
                console.log('Acc Id On Selection ', this.accountId);
                this.disableSubmit = false;
                // if (this.isRelogin === true || this.isTopup === true) {
                //     this.applicantTypeValue = '';
                //     this.disableAppType = true;
                // }
                this.applicantTypeValue = data.recordData.Customer_Type__c;
                await checkAPILogger({ accountId: this.accountId })
                    .then(result => {
                        console.log('APILOGGER RESULT :: ', result);
                        if (result != null && result != undefined && result != '') {
                            console.log('API LOGGER RECORD FOUND!!');
                            console.log('Result :: 1  ', result);
                            this.editRecordOCR(result);
                        }
                        else {
                            this.valueSelf = true;
                            this.selfSave = 'Update';
                            this.saveOCR = 'Update';
                        }
                    })
                    .catch(error => {
                        console.log('Inside Catch');
                        this.valueSelf = true;
                        this.selfSave = 'Update';
                        this.saveOCR = 'Update';
                    })
                console.log('Edit Record Called');
                var temp = JSON.parse(JSON.stringify(data.recordData));
                console.log('parsed ', temp);

                //Fill LA Details On Click Edit
                this.applicantTypeValue = temp.Customer_Type__c;
                this.ocrCustomerWrapper.constitution = temp['Constitution__c'];
                this.ocrCustomerWrapper.incCon = temp['Income_Considered__c'];
                this.ocrCustomerWrapper.kycType1 = temp['KYC_ID_Type_1__c'];
                this.ocrCustomerWrapper.kycId1 = temp['KYC_Id_1__c'];
                this.ocrCustomerWrapper.kycType2 = temp['KYC_ID_Type_2__c'];
                if (temp['KYC_ID_Type_2__c'] === ' ') {
                    console.log('Yes type empty');
                    this.ocrCustomerWrapper.kycType2 = null;
                }
                else
                    this.ocrCustomerWrapper.kycType2 = temp['KYC_ID_Type_2__c'];
                if (temp['KYC_Id_2__c'] === ' ') {
                    console.log('Yes id empty');
                    this.ocrCustomerWrapper.kycId2 = '';
                }
                else
                    this.ocrCustomerWrapper.kycId2 = temp['KYC_Id_2__c'];
                this.ocrCustomerWrapper.appType = temp['Applicant_Type__c'];
                this.ocrCustomerWrapper.Gender = temp['Customer_Information__r.Gender__c'];
                this.salutation = temp['Customer_Information__r.Salutation']
                this.ocrCustomerWrapper.firstName = temp.Customer_Information__r_FirstName_LABEL;
                this.ocrCustomerWrapper.lastName = temp['Customer_Information__r.LastName'];
                this.ocrCustomerWrapper.FathersName = temp['Customer_Information__r.Father_s_Name__c'];
                this.ocrCustomerWrapper.MothersName = temp['Customer_Information__r.Mother_s_Name__c'];
                this.ocrCustomerWrapper.married = temp['Married__c'];
                this.ocrCustomerWrapper.SpouceName = temp['Husband_Wife_s_Name__c'];
                this.ocrCustomerWrapper.DOB = temp['Customer_Information__r.PersonBirthdate'];
                this.ocrCustomerWrapper.mobile_1 = temp['Mobile__c'];
                this.ocrCustomerWrapper.mobile_2 = temp['Phone_Residence__c'];
                this.ocrCustomerWrapper.Address = temp['Residence_Address_Line_1__c'];
                this.ocrCustomerWrapper.Pincode = temp['Residence_Pincode__c']; //Residence_Pincode__r.Name
                this.city = temp['Residence_City__c'];
                this.ocrCustomerWrapper.district = temp['Residence_District__c'];
                this.state = temp['Residence_State__c'];

                //Fill Account Details On Click Edit
                this.accountRecordWrapper.gender = temp['Customer_Information__r.Gender__c'];
                this.accountRecordWrapper.firstName = temp['Customer_Information__r_FirstName_LABEL'];
                this.accountRecordWrapper.lastName = temp['Customer_Information__r.LastName'];
                this.accountRecordWrapper.fatherName = temp['Customer_Information__r.Father_s_Name__c'];
                this.accountRecordWrapper.dob = temp['Customer_Information__r.PersonBirthdate'];
                this.accountRecordWrapper.motherName = temp['Customer_Information__r.Mother_s_Name__c'];

                this.customerWrapper.constitution = temp.Constitution__c;
                this.customerWrapper.incCon = temp['Income_Considered__c'];
                this.customerWrapper.firstName = temp['Customer_Information__r_FirstName_LABEL'];
                this.customerWrapper.lastName = temp['Customer_Information__r.LastName'];
                this.customerWrapper.DOB = temp['Customer_Information__r.PersonBirthdate'];
                this.customerWrapper.mobile_1 = temp['Mobile__c'];
                this.customerWrapper.City = temp['Residence_City__c'];
                this.customerWrapper.Pincode = temp['Residence_Pincode__r.Name'];
                this.oldMobile = temp['Mobile__c'];
                this.customerWrapper.Applicant_Type = temp['Customer_Type__c'];

                console.log('Old Mobile ', this.oldMobile);
                if (this.verificationDefaultvalue === 'Self')
                    this.selfSave = 'Update';
                else
                    this.saveOCR = 'Update';
            }
            else if (event.detail.ActionName === 'delete') {
                console.log('Delete Record Called');
                this.isModalOpenDel = true;
                console.log('del modal ', this.isModalOpenDel);
                this.customerType = data.recordData.Customer_Type__c;
                console.log('Customer_Type__c ', this.customerType);
                this.isPropDataArrived = true;
                this.getPropertyAccData();
            }
            else if (event.detail.ActionName === 'verify') {
                console.log('Verify Called');
                var temp = JSON.parse(JSON.stringify(data.recordData));
                this.mobileno = temp['Mobile__c'];
                if (this.mobileno.length == 10) {
                    console.log(this.mobileno + ' ' + this.mobileno.length);
                    console.log('accId ', this.accountId);
                    this.sendMobOTP(this.accountId, this.mobileno);
                }
                else {
                    console.log('error ');
                    this.showToast('Error', 'Error', 'Invalid Mobile Number!!');
                    this.closeAction();
                }
            }
            else if (event.detail.ActionName === 'validate') {
                //alert('Validate KYC Called!!');
                getKYCReport({ recordId: this.accountId })
                    .then(result => {
                        if (result != undefined && result != '' && result != null) {
                            console.log(result);
                            if (result.errorMSG === undefined || result.errorMSG === '' || result.errorMSG === null) {
                                this.showToast('Success', 'Success', 'KYC Validate Sucessfully!!');
                                this.closeAction();
                            }
                            else {
                                this.showToast('Error', 'Error', 'KYC Validate Failed!!');
                                this.closeAction();
                            }
                        }
                        else {
                            this.showToast('Error', 'Error', 'KYC Validate Failed!!');
                            this.closeAction();
                        }
                    })
                    .catch(error => {
                        this.showToast('Error', 'Error', 'KYC Validate Failed!!');
                        this.closeAction();
                    })
            }
        }
    }

    editRecordOCR(accountRecords) {
        this.editAccount = true;
        this.saveAcc = false;
        console.log('Account Record OCR :: ', accountRecords);
        this.firstNameOption = [];
        this.lastNameOption = [];
        this.fatherTypeOption = [];
        this.motherTypeOption = [];
        this.spouseTypeOption = [];
        this.dobTypeOption = [];
        this.mbl1TypeOption = [];
        this.cityTypeOption = [];
        this.pinTypeOption = [];
        console.log('Account Record OCR :: ', JSON.stringify(accountRecords));
        accountRecords.forEach(element => {
            console.log('Temp Element ', element);
            if (element.First_Name__c != null && element.First_Name__c != undefined && element.First_Name__c != '') {
                const firstName = {
                    label: element.First_Name__c,
                    value: element.First_Name__c
                };
                this.firstNameOption = [...this.firstNameOption, firstName];
            }
            if (element.Last_Name__c != null && element.Last_Name__c != undefined && element.Last_Name__c != '') {
                const lastName = {
                    label: element.Last_Name__c,
                    value: element.Last_Name__c
                };
                this.lastNameOption = [...this.lastNameOption, lastName];
            }

            if (element.Fathers_Name__c != null && element.Fathers_Name__c != undefined && element.Fathers_Name__c != '') {
                const father = {
                    label: element.Fathers_Name__c,
                    value: element.Fathers_Name__c
                };
                this.fatherTypeOption = [...this.fatherTypeOption, father];
            }

            if (element.Mothers_Name__c != null && element.Mothers_Name__c != undefined && element.Mothers_Name__c != '') {
                const mother = {
                    label: element.Mothers_Name__c,
                    value: element.Mothers_Name__c
                };
                this.motherTypeOption = [...this.motherTypeOption, mother];
            }

            if (element.Spouce_Name__c != null && element.Spouce_Name__c != undefined && element.Spouce_Name__c != '') {
                const spouse = {
                    label: element.Spouce_Name__c,
                    value: element.Spouce_Name__c
                };
                this.spouseTypeOption = [...this.spouseTypeOption, spouse];
            }

            if (element.DOB__c != null && element.DOB__c != undefined && element.DOB__c != '') {
                const dob = {
                    label: element.DOB__c,
                    value: element.DOB__c
                };
                this.dobTypeOption = [...this.dobTypeOption, dob];
            }

            if (element.Phone__c != null && element.Phone__c != undefined && element.Phone__c != '') {
                const mbl1 = {
                    label: element.Phone__c,
                    value: element.Phone__c
                };
                this.mbl1TypeOption = [...this.mbl1TypeOption, mbl1];
            }


            if (element.City__c != null && element.City__c != undefined && element.City__c != '') {
                const city = {
                    label: element.City__c,
                    value: element.City__c
                };
                this.cityTypeOption = [...this.cityTypeOption, city];
            }

            if (element.Pincode__c != null && element.Pincode__c != undefined && element.Pincode__c != '') {
                //alert(element.Pincode__c);
                const pin = {
                    label: element.Pincode__c,
                    value: element.Pincode__c
                };
                this.pinTypeOption = [...this.pinTypeOption, pin];
                console.log('pinType Option ', this.pinTypeOption);
                this.customerWrapper.Pincode = element.Pincode__c;
            }
        });
    }

    resendMobOTP(event) {
        console.log(this.accountId, this.mobileno)
        this.sendMobOTP(this.accountId, this.mobileno);
    }

    sendMobOTP(accountId, mobileNo) {
        console.log('SEND OTP CALLED Acc Id :: ', accountId + ' , Mobile :: ', mobileNo);
        SendOTP({ AccountId: accountId, MobileNo: mobileNo })
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
                    this.closeAction();
                    this.isModalOpen = false;
                }

            })
            .catch(error => {
                console.log('error ', error);
                this.showToast('Error', 'Error', 'Mobile Verification Failed!!');
                this.closeAction();
                this.isModalOpen = false;
            })
    }

    handleOTP(event) {
        console.log('OTP ', event.detail.value);
        this.otp = event.detail.value;
    }

    validateOTP(event) {
        console.log('Validate!!');
        if (this.otp != undefined && this.otp != null && this.otp != '') {
            console.log('OTP ', this.otp);
            this.validate = 'Verifying';
            //this.showSpinner = true;
            console.log('accId ', this.accountId);
            this.validateMobOtp(this.accountId, this.requestId, this.otp);
        }
    }

    validateMobOtp(accId, requestId, otp) {
        console.log('accId :: ', accId + ' Request id :: ', requestId + ' otp :: ', otp);
        ValidateOTP({ AccountId: accId, requestId: requestId, OTP: otp })
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
                    console.log('Account Id ', accId);
                    accMobileVerification({ accountId: accId })
                        .then(result => {
                            console.log('Account Updated Result ', result);
                            // this.mobVerificationList.push(result);
                            this.isAccDataArrived = false;
                            this.getAccountData(this.applicationId);
                        })
                }
                else if (msg != '101') {
                    this.showToast('Error', 'Error', ' :: ' + description);
                    this.closeAction();
                }
                this.isModalOpen = false;
            })
            .catch(error => {
                console.log('Error ', error);
                this.showToast('Error', 'Validation Failed!!');
                this.closeAction();
                //this.showSpinner = false;
                this.isModalOpen = false;
            })
    }

    selectDelete() {
        this.isModalOpenDel = false;
        console.log('Acc Id ', this.accountId);
        const accId = this.accountId;
        this.delSelectedAccount(accId);
    }

    delSelectedAccount(accountId) {
        this.isModalOpenDel = false;
        console.log('Account Id ', accountId);
        if ((this.isTopup == true || this.isRelogin == true) && this.customerType === 'Primary Applicant') {
            this.showToast('Error', 'Error', 'You can not delete Primary Applicant!!');
            this.closeAction();
        }
        else {
            delAccount({ accountId: accountId, customerType: this.customerType, preloginId: this.preLogInId, appId: this.applicationId })
                .then(result => {
                    console.log('AccDel ', result);
                    if (result === 'Deleted') {
                        this.showToast('Success', 'Success', 'Record Deleted Successfully!!');
                        this.closeAction();
                        this.validApplicant = false;
                        this.isAccDataArrived = false;
                        this.getAccountData(this.applicationId);
                        //this.isDataArrived = false;
                        //this.getData();
                    }
                    else if (result === 'Receipt') {
                        this.showToast('Error', 'Error', 'Can not delete record, Receipt record found!!');
                        this.closeAction();
                    }
                    else {
                        this.showToast('Error', 'Error', 'Unable to delete record, please contact System Administrator!!');
                        this.closeAction();
                    }
                })
                .catch(error => {
                    this.showToast('Error', 'Error', 'Unable to delete record, please contact System Administrator!!', error);
                    this.closeAction();
                })
        }
    }

    handleSalutation(event) {
        this.salutation = event.detail.value;
        console.log('Salutation ', this.salutation);
    }

    handleMarried(event) {
        console.log(event.target.value);
        if (event.target.value === 'Yes') {
            this.requiredSpouse = true;
        }
        else {
            this.requiredSpouse = false;
        }
    }

    async handleaccsuccess(event) {
        console.log('accID ', event.detail.id);
        this.accountId = event.detail.id;
        const newaccevent = new CustomEvent("newaccevent", {
            detail: event.detail.id
        });
        console.log('dispatch event newaccevent ', newaccevent);
        this.dispatchEvent(newaccevent);
        console.log('apiLoggerList ', this.apiLoggerList);
        console.log('kycLoggerList ', this.kycLoggerList);
        if (this.saveAcc === true) {
            if (this.selfSave != 'Update') {
                console.log('Doc 1 ', JSON.stringify(this.front64list));
                console.log('Doc 2 ', JSON.stringify(this.back64list));
                console.log('Doc Name 1 ', JSON.stringify(this.frontnmlist));
                console.log('Doc Name 2 ', JSON.stringify(this.backnmlist));
                console.log('KYC Values ', this.KYCTypeValue1 + ' , ' + this.KYCTypeValue2);
                insertSelfDocuments({ frontBase64: this.front64list, backBase64: this.back64list, frontNmList: this.frontnmlist, backNmList: this.backnmlist, accId: event.detail.id });
                this.KYCTypeValue1 = '';
                this.KYCTypeValue2 = '';
                await insertApplications({ preLogInId: this.preLogInId, accId: this.accountId, cutomerType: this.applicantTypeValue })
                    .then(result => {
                        console.log('Save Applications');
                        this.applicationId = result;
                        getApplicationId({ recordId: this.preLogInId })
                            .then(result => {
                                this.appName = result.appName;
                                console.log('appName', this.appName);
                            })
                            .catch(error => {
                                console.log(error);
                            })
                    })
                console.log('APPLICATION ID ', this.applicationId);
                this.laFields["Customer_Information__c"] = this.accountId;
                this.laFields["Application__c"] = this.applicationId;
                this.laFields["Customer_Type__c"] = this.applicantTypeValue;
                this.laFields["Initiate_From__c"] = this.initiateFrom;
                console.log('this.laFields', JSON.stringify(this.laFields));
                await updateLA({ fields: JSON.stringify(this.laFields) }).then(result => {
                    console.log('la result ', result);
                    this.showToast('Success', 'Success', 'Record Saved Successfully!!');
                    this.closeAction();
                    this.showSpinner = false;

                })
                    .catch(error => {
                        console.log('error in la ', error);
                    })
                this.selfSave = 'Save';
                this.saveOCR = 'Save';
                this.handleSelfReset();
                this.ImageNameself = '';
                this.ImageNameself2 = '';
                this.isAccDataArrived = false;
                this.getAccountData(this.applicationId);
            }
            else {
                this.editMobile = false;
                if (this.customerWrapper.Applicant_Type != 'Primary Applicant' && this.isPrimary == true) { //this.applicantTypeValue === 'Primary Applicant' || 
                    this.getAccountData(this.applicationId);
                    console.log('yes');
                    this.countPrimaryType = this.countPrimaryType + 1;
                }
                console.log('this.countPrimaryType in handlesucessacc ' + this.countPrimaryType);
                if (this.countPrimaryType === 1) {
                    await insertApplications({ preLogInId: this.preLogInId, accId: this.accountId, cutomerType: this.applicantTypeValue })
                        .then(result => {
                            console.log('Save Applications');
                            this.applicationId = result;
                            getApplicationId({ recordId: this.preLogInId })
                                .then(result => {
                                    this.appName = result.appName;
                                    console.log('appName', this.appName);
                                })
                                .catch(error => {
                                    console.log(error);
                                })
                        })
                    console.log('APPLICATION ID ', this.applicationId);
                    this.laFields["Customer_Information__c"] = this.accountId;
                    this.laFields["Application__c"] = this.applicationId;
                    this.laFields["Customer_Type__c"] = this.applicantTypeValue;
                    this.laFields["Initiate_From__c"] = this.initiateFrom;
                    console.log('this.laFields', JSON.stringify(this.laFields));
                    await updateLA({ fields: JSON.stringify(this.laFields) }).then(result => {
                        console.log('la result ', result);
                        this.showToast('Success', 'Success', 'Record Updated Successfully!!');
                        this.closeAction();
                        this.showSpinner = false;
                    })
                        .catch(error => {
                            console.log('error in la ', error);
                        })
                    this.selfSave = 'Save';
                    this.saveOCR = 'Save';
                    this.handleSelfReset();
                    this.ImageNameself = '';
                    this.ImageNameself2 = '';
                    this.isAccDataArrived = false;
                    this.getAccountData(this.applicationId);
                }
                else {
                    this.showToast('Error', 'error', 'Multiple Primary Applicant Found!!');
                    this.closeAction();
                    this.saveAcc = false;
                }
            }
        }
    }

    async handleSubmitAcc(event) {
        this.isKYC1Correct = true;
        this.isKYC2Correct = true;
        this.saveAcc = true;
        console.log(this.applicantTypeValue);
        console.log('Account Submit Called');
        console.log('countPrimaryType in handlesubmitacc ', this.countPrimaryType);
        console.log('Self Save Label ', this.selfSave);
        const fields = event.detail.fields;
        this.laFields = fields;
        console.log('LA Fields ', JSON.stringify(fields));
        console.log(fields.KYC_Id_1__c + ' :: ' + fields.KYC_Id_2__c);
        if (this.valueSelf === true) {
            console.log('Value Self True');
            var regEx = /^[0-9a-zA-Z]+$/;
            if (fields.KYC_ID_Type_1__c === 'Aadhaar Card')
                regEx = /^[2-9]{1}[0-9]{3}[0-9]{4}[0-9]{4}$/;
            else if (fields.KYC_ID_Type_1__c === 'Voter ID')
                regEx = /^([a-zA-Z]){3}([0-9]){7}?$/;
            else if (fields.KYC_ID_Type_1__c === 'PAN')
                regEx = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
            else if (fields.KYC_ID_Type_1__c === 'Passport')
                regEx = /^[A-Z]{1}[0-9]{7}$/;
            else if (fields.KYC_ID_Type_1__c === 'Driving License')
                regEx = /^(([A-Z]{2}[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}$/;
            if (fields.KYC_Id_1__c.match(regEx)) {
                this.isKYC1Correct = true;
            }
            else {
                this.isKYC1Correct = false;
            }
            console.log('fields.KYC_Id_2__c ', fields.KYC_Id_2__c);
            if (fields.KYC_Id_2__c != null && fields.KYC_Id_2__c != undefined && fields.KYC_Id_2__c != '' && fields.KYC_Id_2__c && (fields.KYC_Id_2__c).length > 0) {
                console.log('Inside KYC ID 2');
                if (fields.KYC_ID_Type_2__c === 'Aadhaar Card')
                    regEx = /^[2-9]{1}[0-9]{3}[0-9]{4}[0-9]{4}$/;
                else if (fields.KYC_ID_Type_2__c === 'Voter ID')
                    regEx = /^([a-zA-Z]){3}([0-9]){7}?$/;
                else if (fields.KYC_ID_Type_2__c === 'PAN')
                    regEx = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
                else if (fields.KYC_ID_Type_2__c === 'Passport')
                    regEx = /^[A-Z]{1}[0-9]{7}$/;
                else if (fields.KYC_ID_Type_2__c === 'Driving License')
                    regEx = /^(([A-Z]{2}[0-9]{2}))((19|20)[0-9][0-9])[0-9]{7}$/;
                if (fields.KYC_Id_2__c.match(regEx)) {
                    this.isKYC2Correct = true;
                }
                else {
                    //c/changeOwneralert("Invalid KYC ID.");
                    this.isKYC2Correct = false;
                }
            }
        }
        console.log('ocrWrapper ', this.accountRecordWrapper);
        if (fields.Mobile__c.length != 10 || fields.KYC_Id_1__c == fields.KYC_Id_2__c ||
            this.isKYC1Correct === false || this.isKYC2Correct === false || fields.KYC_ID_Type_1__c == fields.KYC_ID_Type_2__c ||
            this.accountRecordWrapper.firstName.length === 0 || this.accountRecordWrapper.lastName.length === 0 ||
            this.accountRecordWrapper.gender.length === 0 || this.salutation == null || this.accountRecordWrapper.fatherName.length === 0 ||
            this.accountRecordWrapper.dob.length === 0) {
            console.log('Enter in Validation Failed Method');
            if (fields.Mobile__c.length != 10) {
                this.showToast('Error', 'error', 'Invalid Mobile Number!!');
                this.closeAction();
                const mobField = this.template.querySelector('[data-name="selfresetmob"]');
                console.log(mobField);
                mobField.reset();
            }
            if (fields.KYC_Id_1__c == fields.KYC_Id_2__c) {
                this.showToast('Error', 'error', 'KYC Ids can not be same!!');
                this.closeAction();
                const inputFields = this.template.querySelectorAll('[data-name="selfresetkyc"]');
                console.log('ResetKYC ', JSON.stringify(inputFields));
                if (inputFields) {
                    inputFields.forEach(field => {
                        console.log('Reset ', JSON.stringify(field));
                        field.reset();
                    });
                }
            }
            if (fields.KYC_ID_Type_1__c == fields.KYC_ID_Type_2__c) {
                this.showToast('Error', 'error', 'KYC Ids Type Can Not Be Same!!');
                this.closeAction();
            }
            if (this.isKYC1Correct === false) {
                this.showToast('Error', 'error', 'Invalid KYC ID 1 !!');
                this.closeAction();
                const inputFields = this.template.querySelector('[data-id="incorrectKYC1"]');
                console.log('ResetKYC ', JSON.stringify(inputFields));
                inputFields.reset();
            }
            if (this.isKYC2Correct === false) {
                this.showToast('Error', 'error', 'Invalid KYC ID 2 !!');
                this.closeAction();
                const inputFields = this.template.querySelector('[data-id="incorrectKYC2"]');
                console.log('ResetKYC ', JSON.stringify(inputFields));
                inputFields.reset();
            }
            if (this.accountRecordWrapper.firstName.length === 0 || this.accountRecordWrapper.lastName.length === 0 ||
                this.accountRecordWrapper.gender.length === 0 || this.salutation || this.accountRecordWrapper.fatherName.length === 0 ||
                this.accountRecordWrapper.dob.length === 0) {
                this.showToast('Error', 'error', 'Please Fill All Required Fields !!');
                this.closeAction();
            }
        }
        else {
            console.log('Enter in Save Method');
            this.showSpinner = true;
            console.log(this.countPrimaryType);
            if (this.selfSave != 'Update') {
                if (this.applicantTypeValue === 'Primary Applicant') {
                    this.getAccountData(this.applicationId);
                    this.countPrimaryType = this.countPrimaryType + 1;
                }
                console.log('countPrimaryType hsa ', this.countPrimaryType);
                if (this.countPrimaryType === 1) { // || this.applicantTypeValue != 'Primary Applicant'
                    event.preventDefault();       // stop the form from submitting
                    console.log('fields ', JSON.stringify(fields));
                    console.log('This Count Save ', this.countSave);
                    console.log('Pre Login Id ', this.preLogInId);
                    console.log('this.applicantTypeValue; ', this.applicantTypeValue);
                    if (this.countSave === 0 && (this.preLogInId == null || this.preLogInId == undefined || this.preLogInId == '')) {
                        await insertPreLogin().then(result => {
                            if (result != '' && result != null && result != undefined) {
                                this.preLogInId = result;
                                console.log('PRE LOG IN ID ', this.preLogInId);
                                this.countSave = this.countSave + 1;
                            }
                        }).catch(error => {
                            console.log(error);
                        })
                    }
                    this.template.querySelector('[data-id="accRecordForm"]').submit();
                    console.log('After Submit fields ', JSON.stringify(fields));
                }
                else {
                    this.showToast('Error', 'error', 'Multiple Primary Applicant Found!!');
                    this.closeAction();
                    this.saveAcc = false;
                    this.showSpinner = false;
                    //this.handleSelfReset();
                }
            }
            else {
                console.log(this.selfSave);
                const fields = event.detail.fields;
                event.preventDefault();       // stop the form from submitting
                if (this.editMobile == true) {
                    console.log('edit mobile ', this.editMobile);
                    fields.Mobile_Verified__c = false;
                    this.laFields = fields;
                }
                await this.template.querySelector('[data-id="accRecordForm"]').submit();
                //this.template.querySelector('lightning-record-edit-form').submit(fields);
                console.log('After Submit fields ', JSON.stringify(fields));
            }
        }
    }

    async handleSuccessLA(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.loanAppId = event.detail.id;
    }

    handlePincode(event) {
        console.log('pin ', event.target.value);
        const pinId = (event.target.value);
        if (pinId.length === 18) {
            getPincodeDetails({ pinId: pinId })
                .then(result => {
                    console.log(result);
                    this.city = result.city;
                    this.state = result.state;
                    this.pincode = result.pinCode;
                })
                .catch(error => {
                    console.log(error);
                })
        }
        else if (pinId.length === 0) {
            console.log('pin id not exist');
            this.city = '';
            this.state = '';
        }
    }

    editMobileCalled(event) {
        if (this.selfSave === 'Update') {
            console.log(event.detail.value);
            console.log('OLD Mobile ', this.oldMobile);
            if (this.oldMobile === event.detail.value) {
                console.log('No Edit');
                this.editMobile = false;
            }
            else {
                console.log('Yes Edit');
                this.editMobile = true;
            }
        }
    }

    onCancel(event) {
        console.log(JSON.stringify(event.detail));
        this.handleSelfReset();
        this.showselfonly = false;
        this.selfSave = 'Save';
    }

    handleSelfReset() {
        console.log('Handle Self Reset Called!!!!');
        this.showKYCTable = false;
        this.pincode = null;
        this.ocrCustomerWrapper = {
            kycType1: '', kycType2: '', incCon: '', appType: '', Gender: '', Salutation: '',
            firstName: '', lastName: '', FathersName: '', MothersName: '',
            married: '', SpouceName: '', DOB: '', mobile_1: '', mobile_2: '',
            City: '', district: '', Pincode: '', Address: '',
            verification: this.verificationDefaultvalue, Applicant_Type: this.applicantTypeValue,
            kycId1: '', kycId2: '', constitution: ''
        };
        this.accountId = '';
        this.loanAppId = '';
        this.customerWrapper.constitution = '';
        this.salutation = '';
        this.requiredSpouse = false;
        this.disableAppType = false;
        this.valueSelf = false;
        this.frontImageName = '';
        this.front64list = [];
        this.back64list = [];
        this.rearImageName = '';
        this.applicantTypeValue = 'Primary Applicant';
        this.customerWrapper.Applicant_Type = 'Primary Applicant';
        this.KYCTypeValue = 'Aadhar_Card';
        this.showFrontUpload = true;
        this.showRearUpload = true;
        this.editAccount = false;
        this.showselfonly = false;
        this.city = '';
        this.state = '';
        this.constitutionValue = null;
        this.verificationDefaultvalue = 'OCR'
    }

    handleChangeKYC(event) {
        this.showselfonly = false;
        this.frontUpload = 0;
        this.backUPload = 0;
        this.frontImageName = '';
        this.rearImageName = '';
        this.showBreak = false;
        this.valueSelf = false;
        console.log('Count Value ', +this.countApplicantType);
        if (event.detail.value == 'Pan_Card') {
            this.showRearUpload = false;
        } else {
            this.showRearUpload = true;
        }
        this.KYCTypeValue = event.target.value;
        console.log('kyctype' + this.KYCTypeValue);
    }

    handleChangeKYC1(event) {
        this.ImageNameself = '';
        this.showBreak = false;
        if (event.target.value === this.KYCTypeValue2) {
            this.showToast('Error', 'Error', 'Select Different KYC Type!!');
            this.closeAction();
        }
        else if (event.target.value != this.KYCTypeValue2)
            this.KYCTypeValue1 = event.target.value;
        console.log('kyctype' + this.KYCTypeValue1);
    }

    handleChangeKYC2(event) {
        this.ImageNameself2 = '';
        if (event.target.value === this.KYCTypeValue1) {
            this.showToast('Error', 'Error', 'Select Different KYC Type!!');
            this.closeAction();
        }
        else if (event.target.value != this.KYCTypeValue1)
            this.KYCTypeValue2 = event.target.value;
        console.log('kyctype' + this.KYCTypeValue2);
    }

    handleSelfKYC1(event) {
        console.log(event.target.value);
        if (this.valueSelf === true) {
            console.log('validate kyc id called ');
            if (event.target.value === 'Aadhaar Card')
                this.tooltip = '912345678901';
            else if (event.target.value === 'Voter ID')
                this.tooltip = 'ABC1234567';
            else if (event.target.value === 'PAN')
                this.tooltip = 'ABCDE0123F';
            else if (event.target.value === 'Passport')
                this.tooltip = 'A2096457';
            else if (event.target.value === 'Driving License')
                this.tooltip = 'HR0619850034761';
        }
    }

    capitalize(event) {
        console.log(event.target.value);
        event.target.value = event.target.value.toUpperCase();
        console.log(event.target.value);
    }

    handleSelfKYC2(event) {
        console.log(event.target.value);
        if (this.valueSelf === true) {
            console.log('validate kyc id called ');
            if (event.target.value === 'Aadhaar Card')
                this.tooltip2 = '912345678901';
            else if (event.target.value === 'Voter ID')
                this.tooltip2 = 'ABC1234567';
            else if (event.target.value === 'PAN')
                this.tooltip2 = 'ABCDE0123F';
            else if (event.target.value === 'Passport')
                this.tooltip2 = 'A2096457';
            else if (event.target.value === 'Driving License')
                this.tooltip2 = 'HR0619850034761';
        }
    }

    handleOnChangeOCRResult(event) {
        console.log('handleOnChangeOCRResult');
        if (event.target.name == 'constitution') {
            console.log('constitution ', event.detail.value);
            this.customerWrapper.constitution = event.detail.value;
        }
    }

    //HELPERS
    isInputValid(classname) {
        try {
            let isValid = true;
            let inputFields = this.template.querySelectorAll(classname);
            inputFields.forEach(inputField => {
                if (!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                }
            });
            return isValid;
        } catch (error) {
            console.log('is input valid error ', error);
        }
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('No. of files uploaded : ' + uploadedFiles.length);
    }

    handleChange(event) {
        var eve = event;
        console.log('I am in handle change');
        this.verificationDefaultvalue = 'OCR';
        this.applicantTypeValue = event.detail.value;
        if (this.applicantTypeValue === 'Primary Applicant')
            this.isPrimary = true;
        else
            this.isPrimary = false;
        console.log(this.applicantTypeValue);
        console.log('this.save and this.edit ', this.saveAcc + ' ' + this.editAccount);
        if (this.countPrimaryType > 0 && this.applicantTypeValue == 'Primary Applicant') {
            this.countPrimaryType = this.countPrimaryType - (this.countPrimaryType - 1);
        }
        if (this.saveAcc === true) {
            //alert('Save');
            this.ocrdata = [];
            this.resetOCRForm(eve);
            //this.handleSelfReset();
        }
        if (this.editAccount === false) {
            //alert('Edit');
            this.ocrdata = [];
            this.resetOCRForm(eve);
            //this.handleSelfReset();
        }
    }

    resetOCRForm(event) {
        console.log(event.target.value);
        this.valueSelf = false;
        this.frontUpload = 0;
        this.backUPload = 0;
        this.KYCTypeValue = 'Aadhar_Card';
        this.showRearUpload = true;
        this.frontImageName = '';
        this.rearImageName = '';
        this.showBreak = false;
        this.disableSubmit = true;
        this.countApplicantType = 0;
        this.kyclist = [];
        this.front64list = [];
        this.back64list = [];
        this.frontnmlist = [];
        this.backnmlist = [];
        this.kycIdTypeOption = [];
        this.kycIdValues = [];
        this.hashKYC = [];
        this.firstNameOption = [];
        this.apiLoggerList = [];
        this.kycLoggerList = [];
        this.lastNameOption = [];
        this.fatherTypeOption = [];
        this.motherTypeOption = [];
        this.spouseTypeOption = [];
        this.dobTypeOption = [];
        this.mbl1TypeOption = [];
        this.mbl2TypeOption = [];
        this.cityTypeOption = [];
        this.districtTypeOption = [];
        this.pinTypeOption = [];
        this.addressTypeOption = [];
        this.countAdhar = 0;
        this.countVoter = 0;
        this.countPan = 0;
        this.countDL = 0;
        this.countPassport = 0;
        this.isPrimary = false;
        this.resultwrapper = { kycId: '', Name: '', firstName: '', lastName: '', FathersName: '', MothersName: '', SpouceName: '', DOB: '', mobile_1: '', mobile_2: '', City: '', Pincode: '', Address: '' };
        console.log('Result Wrapper on changing applicant type ', this.resultwrapper);
        console.log(this.firstNameOption + ' , ' + this.lastNameOption);
        this.value = event.detail.value;
        this.applicantTypeValue = event.detail.value;
        console.log(this.applicantTypeValue);
        console.log('at last of handle change');
        this.collateralRecords.Current_Usage = this.value;
        this.customerWrapper = {
            kycId: '', incCon: '', appType: '', Gender: '',
            Salutation: '', firstName: '', lastName: '',
            FathersName: '', MothersName: '', married: '',
            SpouceName: '', DOB: '', mobile_1: '', mobile_2: '',
            City: '', district: '', Pincode: '', Address: '',
            verification: this.verificationDefaultvalue, Applicant_Type: this.applicantTypeValue,
            kycId1: '', kycId2: '', constitution: ''
        };
    }

    UploadHadlerFront(event) {
        const file = event.target.files[0];
        var reader = new FileReader();
        reader.readAsDataURL(file);
        this.frontFileType = file.type;
        console.log('file details ', file);
        console.log('FILE 3 ', file.name);
        this.frontImageName = file.name;
        reader.onload = () => {
            console.log('file result ', reader.result);
            this.frontbase64 = reader.result.split(',')[1];
            console.log('frontbase64 ' + this.frontbase64);
            if (this.frontbase64 != undefined) {
                this.frontUpload = this.frontUpload + 1;
                console.log('this.KYCTypeValue ', this.KYCTypeValue);
                if (this.verificationDefaultvalue != 'Self') {
                    this.CallOCRFront(this.KYCTypeValue, this.frontbase64, 'front');
                    this.showSpinner = true;
                }
                if (this.frontImageName != null && this.frontImageName != '' && this.frontImageName != undefined) {
                    this.showBreak = true;
                    this.showToast('Success', 'Success', 'Image Uploaded Successfully!!');
                    this.closeAction();
                    console.log('KYC TYPE ', this.KYCTypeValue);
                    if (this.KYCTypeValue != 'Aadhar_Card') {
                        this.front64list.push(this.frontbase64);
                        this.frontnmlist.push(this.frontImageName);
                        console.log('Uploaded ' + this.front64list);
                        console.log('Uploaded ' + this.frontnmlist);
                    }
                }
                else {
                    this.showBreak = false;
                    this.showToast('Error', 'error', 'Error in uploading image!!');
                    this.closeAction();
                }
            }
        }
    }

    UploadHadlerRear(event) {
        const file = event.target.files[0];
        var reader = new FileReader();
        reader.readAsDataURL(file);
        this.backFileType = file.type;
        this.rearImageName = file.name;
        reader.onload = () => {
            this.rearbase64 = reader.result.split(',')[1];
            console.log('file.name name Rear ++++++ --> ' + this.rearbase64);
            if (this.rearbase64 != undefined) {
                this.backUPload = this.backUPload + 1;
                console.log('this.KYCTypeValue ', this.KYCTypeValue);
                if (this.verificationDefaultvalue != 'Self') {
                    this.CallOCRFront(this.KYCTypeValue, this.rearbase64, 'back');
                    this.showSpinner = true;
                }
                if (this.rearImageName != null && this.rearImageName != '' && this.rearImageName != undefined) {
                    this.showBreak = true;
                    this.showToast('Success', 'Success', 'Image Uploaded Successfully!!');
                    this.closeAction();
                    console.log('KYC TYPE ', this.KYCTypeValue);
                    if (this.KYCTypeValue != 'Aadhar_Card') {
                        this.back64list.push(this.rearbase64);
                        this.backnmlist.push(this.rearImageName);
                        console.log('Uploaded ' + this.rearbase64);
                        console.log('Uploaded ' + this.rearImageName);
                    }
                }
                else {
                    this.showBreak = false;
                    this.showToast('Error', 'error', 'Error in uploading image!!');
                    this.closeAction();
                }
            }
            this.showSpinner = true;
        }
    }

    previewFrontImage() {
        this.openFrontImg = true;
        this.frontImageUrl = 'data:' + this.frontFileType + ';base64,' + this.frontbase64;
        console.log('ImageURL: ', this.frontImageUrl);
    }

    previewBackImage() {
        this.openBackImg = true;
        this.backImageUrl = 'data:' + this.backFileType + ';base64,' + this.rearbase64;
        console.log('ImageURL: ', this.backFileType);
    }

    CallOCRFront(kycType, base64, ocrType) {
        console.log(kycType);
        console.log(base64);
        console.log(ocrType);
        //this.OCRResult = false;
        console.log('OCR API CALLED!!');
        if (this.frontUpload >= 1 && this.backUPload >= 1) {
            this.disableSubmit = false;
        }
        else {
            this.disableSubmit = true;
        }
        if (this.KYCTypeValue === 'Aadhar_Card' && (this.frontUpload >= 1 || this.backUPload >= 1)) {
            this.countAdhar = this.countAdhar + 1;
        }
        else if (this.KYCTypeValue === 'Voter_Id' && (this.frontUpload >= 1 || this.backUPload >= 1)) {
            this.countVoter = this.countVoter + 1;
        }
        else if (this.KYCTypeValue === 'Pan_Card' && this.frontUpload >= 1) {
            this.countPan = this.countPan + 1;
        }
        else if (this.KYCTypeValue === 'Driving_License' && (this.frontUpload >= 1 || this.backUPload >= 1)) {
            this.countDL = this.countDL + 1;
        }
        else if (this.KYCTypeValue === 'Passport' && (this.frontUpload >= 1 || this.backUPload >= 1)) {
            this.countPassport = this.countPassport + 1;
        }
        if (this.countAdhar < 3 || this.countVoter < 3 || this.countPan < 3 || this.countDL < 3 || this.countPassport < 3) {
            if (this.frontUpload >= 1 || this.backUPload >= 1) {
                docallOCRAPI({ kycType: kycType, base64: base64, Documentside: ocrType, apiLogger: this.apiLogger, ocrid: this.kycOcrLogger })
                    .then(result => {
                        this.showSpinner = false;
                        this.showselfonly = true;
                        console.log('retuned result ', result);
                        if (result.statusCode != undefined || result.description == undefined) {
                            this.showKYCTable = true;
                            this.fillDataTable(JSON.parse(JSON.stringify(result)), kycType);
                            this.valueSelf = false;
                            this.verificationDefaultvalue = 'OCR';
                            this.resultwrapper = result;
                            console.log('apiResponseID @@@ ', result.apilogger);
                            this.apiLogger = result.apilogger;
                            console.log('apiResponseID @@@ ', result.ocrId);
                            this.kycOcrLogger = result.ocrId;
                            if (this.resultwrapper != null && this.resultwrapper != '' && this.resultwrapper != undefined) {
                                const option = {
                                    label: this.resultwrapper.Name,
                                    value: this.resultwrapper.Name
                                };
                                this.nameTypeOption = [...this.nameTypeOption, option];

                                if (this.resultwrapper.apilogger != null && this.resultwrapper.apilogger != undefined && this.resultwrapper.apilogger != '') {
                                    const apiloggerId = this.resultwrapper.apilogger;
                                    this.apiLoggerList = [...this.apiLoggerList, apiloggerId];
                                }

                                if (this.resultwrapper.ocrId != null && this.resultwrapper.ocrId != undefined && this.resultwrapper.ocrId != '') {
                                    const kycloggerId = this.resultwrapper.ocrId;
                                    this.kycLoggerList = [...this.kycLoggerList, kycloggerId];
                                }


                                if (this.resultwrapper.kycNo != null && this.resultwrapper.kycNo != undefined && this.resultwrapper.kycNo != '') {
                                    const kyctypeId = {
                                        label: this.resultwrapper.kycNo,
                                        value: this.resultwrapper.kycNo
                                    };
                                    this.kycIdTypeOption = [...this.kycIdTypeOption, kyctypeId];
                                    this.kycIdValues.push(this.resultwrapper.kycNo);
                                    const str = this.resultwrapper.kycNo;
                                    console.log('@@@@@@@@@2 ', str);
                                    var word = str;
                                    if (word.length <= 4) {
                                        console.log('if');
                                        this.hashKYC.push(word);
                                    }
                                    else {
                                        console.log('else');
                                        var masked = word.substring(0, word.length - 4).replace(/[a-z\d]/gi, "X") +
                                            word.substring(word.length - 4, word.length)
                                        this.hashKYC.push(masked);
                                        console.log('1', masked);
                                    }
                                    console.log('XXXXXXXX :: ', this.hashKYC);
                                }

                                console.log('result wrapper ', this.resultwrapper);
                                this.showToast('Success', 'Success', 'OCR Verified Successfully!!');
                                this.closeAction();
                            }
                            else {
                                this.showToast('Error', 'error', 'Invalid Data');
                                this.closeAction();
                            }
                        }
                        else {
                            this.showSpinner = false;
                            this.showselfonly = true;
                            this.showToast('Error', 'error', 'Issue in OCR Please proceed with self registration');
                            this.closeAction();
                            this.switchSelf();
                        }

                    })
                    .catch(error => {
                        this.showSpinner = false;
                        this.showselfonly = true;
                        console.log('NO Data', error);
                        this.showToast('Error', 'error', 'Issue in OCR Please proceed with self registration');
                        this.closeAction();
                        this.switchSelf();
                    })
            }
            if (this.applicantTypeValue != '' && kycType != '') {
                if (kycType === 'Pan_Card') {
                    if (this.frontUpload >= 1) {
                        this.countApplicantType = this.countApplicantType + 1;
                        console.log('After KYC OCR  ', this.countApplicantType);
                    }
                }
                else {
                    if (this.frontUpload >= 1 && this.backUPload >= 1) {
                        this.countApplicantType = this.countApplicantType + 1;
                        console.log('After KYC OCR  ', this.countApplicantType);
                    }
                }
            }
        }
        else {
            this.showToast('Error', 'error', 'KYC Type Can Not Be Same');
            this.closeAction();
            //this.showSpinner = false;
        }
    }

    switchSelf() {
        this.showSpinner = false;
        this.showKYCTable = false;
        console.log('handleswitchself');
        this.valueSelf = true;
        this.verificationDefaultvalue = 'Self';
        this.countApplicantType = this.countApplicantType - 1;
        if (this.KYCTypeValue === 'Aadhar_Card')
            this.countAdhar = this.countAdhar - 1;
        if (this.KYCTypeValue === 'Voter_Id')
            this.countVoter = this.countVoter - 1;
        if (this.KYCTypeValue === 'Pan_Card')
            this.countPan = this.countPan - 1;
        if (this.KYCTypeValue === 'Passport')
            this.countPassport = this.countPassport - 1;
        if (this.KYCTypeValue === 'Driving_License')
            this.countDL = this.countDL - 1;
        this.accountId = '';
        this.loanAppId = '';
    }

    fillDataTable(result) {
        console.log('filldatatable = ', result)
        this.ocrdata = [];
        if (result) {
            let tempObj = {
                City: "", DOB: "", FathersName: "", Gender: "", MothersName: "", Pincode: "",
                SpouceName: "", apilogger: "", description: "", firstName: "", kycId: "",
                kycNo: "", lastName: "", mobile_1: "", ocrId: "", statusCode: "",
            };

            if (this.ocrDataMap[this.KYCTypeValue] && this.ocrDataMap[this.KYCTypeValue].kycNo) {
                console.log('OCR Exist ', this.ocrDataMap[this.KYCTypeValue]);
                tempObj = JSON.parse(JSON.stringify(this.ocrDataMap[this.KYCTypeValue]));
                console.log('Existing data ', tempObj);
                for (let keyValue of Object.keys(result)) {
                    console.log('Keys ', keyValue);
                    console.log('Keys Value', result[keyValue]);
                    if (result[keyValue]) {
                        tempObj[keyValue] = result[keyValue];
                    }
                }
                this.ocrDataMap[this.KYCTypeValue] = JSON.parse(JSON.stringify(tempObj));
                console.log('tempobj Existing ', tempObj);
            } else {
                for (let keyValue of Object.keys(result)) {
                    tempObj[keyValue] = result[keyValue];
                }
                console.log('tempobj New ', tempObj);
                this.ocrDataMap[this.KYCTypeValue] = tempObj;
            }

            let tempList = [];
            for (let keyValue of Object.keys(this.ocrDataMap)) {
                if (this.ocrDataMap[keyValue] && this.ocrDataMap[keyValue].kycNo) {
                    let kycRecord = JSON.parse(JSON.stringify(this.ocrDataMap[keyValue]));
                    tempList.push(kycRecord);
                }
            }
            this.ocrdata = JSON.parse(JSON.stringify(tempList))

            console.log('this.ocrdata= ', JSON.parse(JSON.stringify(this.ocrdata)));
        }
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