import { LightningElement, api, wire, track } from 'lwc';
import docallOCRAPI from '@salesforce/apex/FS_PreLoginController.SubmitForOCR';
import insertAccount from '@salesforce/apex/FS_PreLoginController.insertAccount';
import insertPreLogin from '@salesforce/apex/FS_PreLoginController.insertPreLogin';
import getAccData from '@salesforce/apex/FS_PreLoginController.getAccData';
import insertSelfDocuments from '@salesforce/apex/FS_PreLoginController.insertSelfDocuments';
import delAccount from '@salesforce/apex/FS_PreLoginController.delAccount';
import getRecTypeId from '@salesforce/apex/FS_PreLoginController.getRecTypeId';
import SendOTP from '@salesforce/apex/FS_PreLoginControllerMock.SendOTP';
import ValidateOTP from '@salesforce/apex/FS_PreLoginControllerMock.ValidateOTP';
import accMobileVerification from '@salesforce/apex/FS_PreLoginController.accMobileVerification';
import getProperty from '@salesforce/apex/FS_PreLoginController.getProperty';
import getPincodeDetails from '@salesforce/apex/FS_PreLoginController.getPincodeDetails';
import checkAPILogger from '@salesforce/apex/FS_PreLoginController.checkAPILogger';
import updateAccount from '@salesforce/apex/FS_PreLoginController.updateAccount';
import insertApplications from '@salesforce/apex/FS_PreLoginController.insertApplications';
import updateLA from '@salesforce/apex/FS_PreLoginController.updateLA';
import getApplicationId from '@salesforce/apex/FS_PreLoginController.getApplicationId';
import getKYCReport from '@salesforce/apex/KYCAPIController.getKYCReport';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class TempCustomerApp extends NavigationMixin(LightningElement) {

    //CUSTOMER SCREEN ATTRIBUTE
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
    @track recTypeId;
    @track kycIdValues = [];
    @track hashKYC = [];
    @track primaryApplicantName;
    @track oldMobile;
    @track countTrue = 0;
    @track valueSelf = false;
    @track isRelogin = false;
    @track saveOCR = 'Save';
    @track todaysDate = new Date();

    //change picklist to input
    @track isMobile1 = true;
    @track isMobile2 = true;
    @track isfName = true;
    @track islName = true;
    @track isFather = true;
    @track isMother = true;
    @track isSpouse = true;
    @track isCity = true;
    @track isDOB = true;
    @track isDistrict = true;
    @track isPin = true;
    @track isAddress = true;

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
    @api accountWrapper = {preLogInId : '', applicationId : '', applicantTypeList : '', validMobile: '',validApplicant:'',mobVerificationList : [],countprimaryApp:''};

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
                title: 'Verify',
                variant: 'border-filled',
                alternativeText: 'Verify',
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
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Mrs.', value: 'Mrs.' },
            { label: 'Dr.', value: 'Dr.' },
            { label: 'Prof.', value: 'Prof.' }
        ];
    }

    get appTypes() {
        return [
            { label: 'Property Holder', value: 'Property Holder' },
            { label: 'Highest Income Earner', value: 'Highest Income Earner' },
            { label: 'Both', value: 'Both' },
        ];
    }

    get constitutionValues() {
        return [
            { label: 'Individual', value: 'Individual' },
            { label: 'Non-Individual', value: 'Non-Individual' },
        ];
    }

    get incomeConsidered() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ]
    }

    get gender() {
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
            { label: 'Aadhar Card', value: 'Aadhar_Card' },
            { label: 'Voter Id', value: 'Voter_Id' },
            { label: 'Pan Card', value: 'Pan_Card' },
            { label: 'Driving License', value: 'Driving_License' },
            { label: 'Passport', value: 'Passport' }
        ];
    }


    //PROPERTY    
    connectedCallback() {
        console.log('login Id ', this.recordId);
        console.log('Reord Type Id :: ', this.recordTypeId);
        console.log('preAppId :: ', this.preAppId);
        console.log('preAppName :: ', this.preAppName);
        this.appName = this.preAppName;
        this.preLogInId = this.recordId;
        this.applicationId = this.preAppId;
        if (this.applicationId)
            this.getAccountData();
        if (this.recordTypeId)
            this.getRecordTypeName(this.recordTypeId);
        this.getRecordTypeId();
    }
    @track loadCss = false;
   
    @track currentStep;
    @api nextrelogin = 'relogin';
    @api nexttopup = 'topup'
    @api isTopup = false;
    @api recordTypeName;
  
    getRecordTypeId() {
        getRecTypeId()
            .then(result => {
                this.recTypeId = result;
            })
            .catch(error => {
                console.log('error in getrecordtypeid ', error);
            })
    }
    @api hasPrimaryOwner = false;

    @track isPropDataArrived = false;
    @track propData = [];
    @track hasPropertyAcc = false;
    getPropertyAccData() {
        console.log('get property data called!!', this.accountId);
        getProperty({ accountId: this.accountId })
            .then(result => {
                //this.isPropDataArrived = false;
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

    @api hasReceipt = false;
    @api allApproved = false;
    @api pendingReceiptList = [];

    @api isIncomeConsidered = false;
    @api countprimaryApp = 0;
    @api getAccountData() {
        console.log('get Acc data called!!', this.applicationId);
        this.countprimaryApp = 0;
        this.isAccDataArrived = false;
        getAccData({ applicationId: this.applicationId })
            .then(result => {
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
                console.log('temp', temp[0]['Customer_Information__r_FirstName_LABEL']);
                for (var i in temp) {
                    var dataResult = temp[i];
                    console.log('Customer_Type__c ', dataResult['Customer_Type__c']);
                    console.log('FirstName ', dataResult['Customer_Information__r_FirstName_LABEL']);
                    console.log('LastName ', dataResult['Customer_Information__r.LastName']);
                    console.log('Mobile_Verified__c ', dataResult['Customer_Information__r.Mobile_Verified__c']);
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
                    if (dataResult['Customer_Information__r.Income_Considered__c'] === 'Yes') {
                        this.isIncomeConsidered = true;
                    }
                    if (dataResult['Customer_Information__r.Mobile_Verified__c'] === true) {
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
                this.accountWrapper.applicationId = this.applicationId;
                this.accountWrapper.applicantTypeList = this.applicantTypeList;
                this.accountWrapper.validApplicant = this.validApplicant;
                this.accountWrapper.validMobile = this.validMobile;
                this.accountWrapper.isIncomeConsidered = this.isIncomeConsidered;
                this.accountWrapper.mobVerificationList = this.mobVerificationList;
                this.accountWrapper.countprimaryApp = this.countPrimaryType;
                const preloginAccEvent = new CustomEvent("preloginaccevent", {
                    detail: this.accountWrapper
                });
                console.log('dispatch event preloginAccEvent ', preloginAccEvent);
                this.dispatchEvent(preloginAccEvent);
                console.log('json data 1 ====> ' + JSON.stringify(this.accData));
                console.log('DATA ', this.accData);
            })
            .catch(error => {
                console.log('Error In Get ACC Data');
            })
    }

    @track showUploadBtn = false;
    @track cashierType = [];
    @track cashierValue;
    @api receiptScreen = '';
    @api moveNextApp = { screen: '', moveNext: '' };
    @api appScreen;

    @track appNumber;
    @track kycNumber;

  
    @track appResult = [];
    @track isAppDataArrived = false;
    @api hasRelogin = false;
    @api countsearch = 0;
   

    @track isModalOpenDelProp = false;
    @track propId;


    @track accId;
    @track customerType;
    @track mobileno;
    @track disableAppType = false;
    @track editAccount = false;
    async handleSelectedAccount(event) {
        console.log('**1**', JSON.stringify(event));
        console.log('**2**', JSON.stringify(event.detail));
        console.log('**3**', JSON.stringify(event.detail.ActionName));
        var data = event.detail;
        this.accId = data.recordData.Id;
        let text = data.recordData.Customer_Information_VALUE;
        const myArray = text.split("/");
        let word = myArray[3];
        this.accountId = word;
        if (data !== undefined && data !== '') {
            if (event.detail.ActionName === 'edit') {
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
                console.log('Mobile :: ', temp['Customer_Information__r.PersonMobilePhone']);
                console.log('Pincode :: ', temp['Customer_Information__r.PersonMailingPostalCode']);
                this.customerWrapper.incCon = temp['Customer_Information__r.Income_Considered__c'];
                this.customerWrapper.firstName = temp['Customer_Information__r_FirstName_LABEL'];
                this.customerWrapper.lastName = temp['Customer_Information__r.LastName'];
                this.customerWrapper.DOB = temp['Customer_Information__r.PersonBirthdate'];
                this.customerWrapper.mobile_1 = temp['Customer_Information__r.PersonMobilePhone'];
                this.customerWrapper.City = temp['Customer_Information__r.PersonMailingCity'];
                this.customerWrapper.Pincode = temp['Customer_Information__r.PersonMailingPostalCode'];
                this.oldMobile = temp['Customer_Information__r.PersonMobilePhone'];
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
                this.mobileno = temp['Customer_Information__r.PersonMobilePhone'];
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
                getKYCReport({ recordid: this.accountId })
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
                this.showSpinner = false;
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
                            this.getAccountData();
                        })
                }
                else if (msg != '101') {
                    this.showToast('Error', 'Error', description);
                    this.closeAction();
                }
                this.isModalOpen = false;
            })
            .catch(error => {
                console.log('Error ', error);
                this.showToast('Error', 'Validation Failed!!');
                this.closeAction();
                this.showSpinner = false;
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
                    this.getAccountData();
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

    @track salutation;
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

    //@track editMobile = false;
    @track saveAcc = true;
    @track isKYC1Correct = false;
    @track isKYC2Correct = false;
    async handleSubmitAcc(event) {
        this.isKYC1Correct = true;
        this.isKYC2Correct = true;
        this.saveAcc = true;
        console.log(this.applicantTypeValue);
        console.log('Account Submit Called');
        console.log('countPrimaryType in handlesubmitacc ', this.countPrimaryType);
        console.log('Self Save Label ', this.selfSave);
        const fields = event.detail.fields;
        var d1 = new Date();
        var d2 = new Date(fields.PersonBirthdate);
        console.log(fields.KYC_Id_1__c + ' :: ' + fields.KYC_Id_2__c);
        var regEx = /^[0-9a-zA-Z]+$/;
        if (fields.KYC_Id_1__c.match(regEx)) {
            this.isKYC1Correct = true;
        }
        else {
            //c/changeOwneralert("Invalid KYC ID.");
            this.isKYC1Correct = false;
        }
        console.log('fields.KYC_Id_2__c ', fields.KYC_Id_2__c);
        if (fields.KYC_Id_2__c != null && fields.KYC_Id_2__c != undefined && fields.KYC_Id_2__c != '') {
            if (fields.KYC_Id_2__c.match(regEx)) {
                this.isKYC2Correct = true;
            }
            else {
                //c/changeOwneralert("Invalid KYC ID.");
                this.isKYC2Correct = false;
            }
        }

        if (fields.PersonMobilePhone.length != 10 || fields.KYC_Id_1__c == fields.KYC_Id_2__c || d2.getTime() > d1.getTime()
            || this.isKYC1Correct === false || this.isKYC2Correct === false || fields.KYC_ID_Type_1__c == fields.KYC_ID_Type_2__c) {
            if (fields.PersonMobilePhone.length != 10) {
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
            if (d2.getTime() > d1.getTime()) {
                this.showToast('Error', 'error', 'Invalid DOB!!');
                this.closeAction();
                const inputFields = this.template.querySelector('[data-id="selfResetDate"]');
                console.log('ResetKYC ', JSON.stringify(inputFields));
                inputFields.reset();
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
        }
        else {
            console.log(this.countPrimaryType);
            if (this.selfSave != 'Update') {
                if (this.applicantTypeValue === 'Primary Applicant') {
                    this.getAccountData();
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
                    fields.Salutation = this.salutation;
                    fields.RecordTypeId = this.recTypeId;
                    fields.Pre_Login__c = this.preLogInId;
                    console.log('after submit prelogin ', fields.Pre_Login__c);
                    fields.Verification_Type__c = this.verificationDefaultvalue;
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                    console.log('After Submit fields ', JSON.stringify(fields));
                }
                else {
                    this.showToast('Error', 'error', 'Multiple Primary Applicant Found!!');
                    this.closeAction();
                    this.saveAcc = false;
                    //this.handleSelfReset();
                }
            }
            else {
                console.log(this.selfSave);
                const fields = event.detail.fields;
                if (this.editMobile == true) {
                    console.log('edit mobile ', this.editMobile);
                    event.preventDefault();       // stop the form from submitting
                    fields.Mobile_Verified__c = false;
                }
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                console.log('After Submit fields ', JSON.stringify(fields));
            }
        }
    }


    async handleSuccessAcc(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
        const accDetail = event.detail;
        var objJSON = JSON.parse(JSON.stringify(accDetail));
        if (this.saveAcc === true) {
            if (this.selfSave != 'Update') {
                console.log('Doc 1 ', JSON.stringify(this.front64list));
                console.log('Doc 2 ', JSON.stringify(this.back64list));
                console.log('Doc Name 1 ', JSON.stringify(this.frontnmlist));
                console.log('Doc Name 2 ', JSON.stringify(this.backnmlist));
                console.log('KYC Values ', this.KYCTypeValue1 + ' , ' + this.KYCTypeValue2);
                insertSelfDocuments({ frontBase64: this.front64list, backBase64: this.back64list, frontNmList: this.frontnmlist, backNmList: this.backnmlist, accId: event.detail.id });
                // this.showToast('Success', 'Success', 'Record Saved Successfully!!');
                // this.closeAction();
                this.KYCTypeValue1 = '';
                this.KYCTypeValue2 = '';
                await insertApplications({ preLogInId: this.preLogInId, accId: event.detail.id, cutomerType: this.applicantTypeValue })
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
                console.log('Constitution ', this.customerWrapper.constitution);
                await updateLA({ accId: event.detail.id, appId: this.applicationId, cutomerType: this.applicantTypeValue, constitution: this.customerWrapper.constitution })
                    .then(result => {
                        console.log('Loan App Update ', result);
                        this.showToast('Success', 'Success', 'Record Saved Successfully!!');
                        this.closeAction();
                    })
                this.selfSave = 'Save';
                this.saveOCR = 'Save';
                this.handleSelfReset();
                this.ImageNameself = '';
                this.ImageNameself2 = '';
                this.isAccDataArrived = false;
                this.getAccountData();
            }
            else {
                this.editMobile = false;
                if (this.customerWrapper.Applicant_Type != 'Primary Applicant' &&this.isPrimary == true) { //this.applicantTypeValue === 'Primary Applicant' || 
                    this.getAccountData();
                    console.log('yes');
                    this.countPrimaryType = this.countPrimaryType + 1;
                }
                console.log('this.countPrimaryType in handlesucessacc ' + this.countPrimaryType);
                if (this.countPrimaryType === 1) {
                    await insertApplications({ preLogInId: this.preLogInId, accId: event.detail.id, cutomerType: this.applicantTypeValue })
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
                    console.log('Constitution ', this.customerWrapper.constitution);
                    await updateLA({ accId: event.detail.id, appId: this.applicationId, cutomerType: this.applicantTypeValue, constitution: this.customerWrapper.constitution })
                        .then(result => {
                            console.log('Loan App Update ', result);
                            this.showToast('Success', 'Success', 'Record Updated Successfully!!');
                            this.closeAction();
                        })
                    this.selfSave = 'Save';
                    this.saveOCR = 'Save';
                    this.handleSelfReset();
                    this.ImageNameself = '';
                    this.ImageNameself2 = '';
                    this.isAccDataArrived = false;
                    this.getAccountData();
                }
                else {
                    this.showToast('Error', 'error', 'Multiple Primary Applicant Found!!');
                    this.closeAction();
                    this.saveAcc = false;
                }
            }
        }
    }

    @track city;
    @track pincode;
    @track state;
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

    handleSelfReset() {
        //this.template.querySelector('form').reset();
        const inputFields = this.template.querySelectorAll('[data-name="selfreset"]');
        console.log('HandleReset ', JSON.stringify(inputFields));
        if (inputFields) {
            inputFields.forEach(field => {
                console.log('Reset ', JSON.stringify(field));
                field.reset();
            });
        }

        const inputFields1 = this.template.querySelectorAll('[data-name="selfresetkyc"]');
        console.log('HandleReset1 ', JSON.stringify(inputFields1));
        if (inputFields1) {
            inputFields1.forEach(field => {
                console.log('Reset ', JSON.stringify(field));
                field.reset();
            });
        }

        const inputFields2 = this.template.querySelector('[data-name="selfresetmob"]');
        console.log('HandleReset2 ', JSON.stringify(inputFields2));
        inputFields2.reset();

        this.accountId = '';
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
    }

    handleChangeKYC(event) {
        this.frontUpload = 0;
        this.backUPload = 0;
        this.frontImageName = '';
        this.rearImageName = '';
        this.showBreak = false;
        this.valueSelf = false;
        this.isMobile1 = true;
        this.isMobile2 = true;
        this.isfName = true;
        this.islName = true;
        this.isFather = true;
        this.isMother = true;
        this.isSpouse = true;
        this.isCity = true;
        this.isDOB = true;
        this.isDistrict = true;
        this.isPin = true;
        this.isAddress = true;
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

    @track requiredSpouse = false;

    handleOnChangeOCRResult(event) {
        console.log('handleOnChangeOCRResult');
        if (event.target.name == 'kycId') {
            console.log('kycId ', event.detail.value);
            this.customerWrapper.kycId = event.detail.value;
        }
        else if (event.target.name == 'incCon') {
            console.log('incCon ', event.detail.value);
            this.customerWrapper.incCon = event.detail.value;
        }
        else if (event.target.name == 'constitution') {
            console.log('constitution ', event.detail.value);
            this.customerWrapper.constitution = event.detail.value;
        }
        else if (event.target.name == 'appType') {
            console.log('appType ', event.detail.value);
            this.customerWrapper.appType = event.detail.value;
        }
        else if (event.target.name == 'Gender') {
            console.log('Gender ', event.detail.value);
            this.customerWrapper.Gender = event.detail.value;
        }
        else if (event.target.name == 'Salutation') {
            console.log('Salutation ', event.detail.value);
            this.customerWrapper.Salutation = event.detail.value;
        }
        else if (event.target.name == 'firstName') {
            console.log('firstName ', event.detail.value);
            this.customerWrapper.firstName = event.detail.value;
        }
        else if (event.target.name == 'lastName') {
            console.log('lastName ', event.detail.value);
            this.customerWrapper.lastName = event.detail.value;
        }
        else if (event.target.name == 'FathersName') {
            console.log('FathersName ', event.detail.value);
            this.customerWrapper.FathersName = event.detail.value;
        }
        else if (event.target.name == 'MothersName') {
            console.log('MothersName ', event.detail.value);
            this.customerWrapper.MothersName = event.detail.value;
        }
        else if (event.target.name == 'married') {
            console.log('married ', event.detail.value);
            this.customerWrapper.married = event.detail.value;
            if (event.detail.value === 'Yes') {
                this.requiredSpouse = true;
            }
            else {
                this.requiredSpouse = false;
            }
        }
        else if (event.target.name == 'SpouceName') {
            console.log('SpouceName ', event.detail.value);
            this.customerWrapper.SpouceName = event.detail.value;
        }
        else if (event.target.name == 'DOB') {
            console.log('DOB ', event.detail.value);
            this.customerWrapper.DOB = event.detail.value;
        }
        else if (event.target.name == 'mobile_1') {
            console.log('mobile_1 ', event.detail.value);
            this.customerWrapper.mobile_1 = event.detail.value;
        }
        else if (event.target.name == 'mobile_2') {
            console.log('mobile_2 ', event.detail.value);
            this.customerWrapper.mobile_2 = event.detail.value;
        }
        else if (event.target.name == 'City') {
            console.log('City ', event.detail.value);
            this.customerWrapper.City = event.detail.value;
        }
        else if (event.target.name == 'district') {
            console.log('district ', event.detail.value);
            this.customerWrapper.district = event.detail.value;
        }
        else if (event.target.name == 'Pincode') {
            console.log('Pincode ', event.detail.value);
            this.customerWrapper.Pincode = event.detail.value;
        }
        else if (event.target.name == 'kycId1') {
            console.log('kycId1 ', event.detail.value);
            this.customerWrapper.kycId1 = event.detail.value;
        }
        else if (event.target.name == 'kycId2') {
            console.log('kycId2 ', event.detail.value);
            this.customerWrapper.kycId2 = event.detail.value;
        }
    }

    handleOCRSubmit(event) {

        // if(this.customerWrapper.staffLoan === undefined || this.customerWrapper.staffLoan === '' || this.customerWrapper.staffLoan === null)
        //     this.customerWrapper.staffLoan = false;
        let isValidOCRResult = this.isInputValid('.validateOCRResult');
        console.log('count Save ', this.countSave);
        console.log('this.customerWrapper ', JSON.stringify(this.customerWrapper));
        if (isValidOCRResult) {
            //this.applicantTypeList.push(this.applicantTypeValue);
            //console.log('applicant type list values @@ ',this.applicantTypeList);
            console.log('saveOCR ' + this.saveOCR);
            if (
                this.customerWrapper.incCon == '' || this.customerWrapper.firstName == '' || this.customerWrapper.lastName == ''
                || this.customerWrapper.married == '' || this.customerWrapper.DOB == '' || this.customerWrapper.mobile_1 == ''
                || this.customerWrapper.City == '' || this.customerWrapper.Pincode == '' || this.customerWrapper.constitution == ''
            ) {
                this.showToast('Error', 'Error', 'Please Fill Mandatory Details!!');
                this.closeAction();
            }
            else {
                if (this.saveOCR === 'Update') {
                    console.log('CustomerWrapper :: ' + JSON.stringify(this.customerWrapper));
                    console.log(this.accountId);
                    console.log(this.applicationId);
                    console.log(this.applicantTypeValue);
                    if (this.customerWrapper.Applicant_Type != 'Primary Applicant' && this.isPrimary == true) {
                        this.getAccountData();
                        console.log('yes');
                        this.countPrimaryType = this.countPrimaryType + 1;
                    }
                    console.log('this.countPrimaryType' + this.countPrimaryType);
                    if (this.countPrimaryType === 1) {
                        this.customerWrapper.Applicant_Type = this.applicantTypeValue;
                        updateAccount({ listOfApplicants: JSON.stringify(this.customerWrapper), accId: this.accountId, appId: this.applicationId })
                            .then(result => {
                                if (result === 'Success') {
                                    this.showToast('Success', 'Success', 'Record Updated Successfully!!');
                                    this.closeAction();
                                    this.firstNameOption = [];
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
                                    this.requiredSpouse = false;
                                    this.disableAppType = false;
                                    this.saveOCR = 'Save';
                                    this.editAccount = false;
                                    this.customerWrapper = {
                                        incCon: '', appType: '', Gender: '',
                                        Salutation: '', married: '', constitution: ''
                                    };
                                    this.customerWrapper.Applicant_Type = 'Primary Applicant';
                                    this.isAccDataArrived = false;
                                    this.getAccountData();
                                }
                                else {
                                    this.showToast('Error', 'Error', 'Can not update record!!');
                                    this.closeAction();
                                }
                            })
                            .catch(error => {
                                this.showToast('Error', 'Error', 'Can not update record!!');
                                this.closeAction();
                            })
                    }
                    else {
                        this.showToast('Error', 'error', 'Multiple Primary Applicant Found!!');
                        this.closeAction();
                    }
                }
                else {
                    this.countSave = this.countSave + 1;
                    console.log('count Save ', this.countSave);
                    var comboResult = JSON.stringify(this.customerWrapper);
                    console.log(this.countPrimaryType);
                    console.log('comboResult ', comboResult);
                    if (this.applicantTypeValue === 'Primary Applicant') {
                        this.getAccountData();
                        console.log('yes');
                        this.countPrimaryType = this.countPrimaryType + 1;
                    }
                    console.log(this.applicantTypeValue + ' ' + this.countPrimaryType);
                    if (this.countPrimaryType === 1) {
                        console.log('this.preloginId ', this.preLogInId);
                        if ((this.preLogInId == null || this.preLogInId == undefined || this.preLogInId == '')) {
                            insertPreLogin().then(result => {
                                if (result != '' && result != null && result != undefined) {
                                    this.preLogInId = result;
                                    console.log('PRE LOG IN ID ', this.preLogInId);
                                    console.log('PRE LOGIN ID ', this.countSave + ' is ', this.preLogInId);
                                    console.log('comboResult ', comboResult);
                                    this.saveAllCustomers(comboResult, this.preLogInId);
                                    this.isAccDataArrived = false;
                                    this.getAccountData();
                                }
                            })
                                .catch(error => {
                                    console.log(error);
                                })
                        }
                        else {
                            console.log('PRE LOGIN ID ', this.countSave + ' is ', this.preLogInId);
                            this.saveAllCustomers(JSON.stringify(this.customerWrapper), this.preLogInId);
                            this.isAccDataArrived = false;
                            this.getAccountData();
                        }
                        this.customerWrapper = { kycId: '', incCon: '', appType: '', Gender: '', Salutation: '', firstName: '', lastName: '', FathersName: '', MothersName: '', married: '', SpouceName: '', DOB: '', mobile_1: '', mobile_2: '', City: '', district: '', Pincode: '', Address: '', verification: this.verificationDefaultvalue, Applicant_Type: this.applicantTypeValue, kycId1: '', kycId2: '', constitution: '' };
                        if (this.customerWrapper.verification === 'Self') {
                            console.log('Self Reset ');
                            this.ImageNameself = '';
                            this.ImageNameself2 = ''
                            this.handleReset();
                        }
                        this.frontImageName = '';
                        this.rearImageName = '';
                    }
                    else {
                        this.showToast('Error', 'error', 'Multiple Primary Applicant Found!!');
                        this.closeAction();
                    }
                }
            }
        }
        else {
            this.showToast('Error', 'error', 'OCR Result Is Not Valid');
            this.closeAction();
        }
    }

    async saveAllCustomers(customerWrapper, preLogInId) {
        console.log('Saving Customer');
        console.log('list 1 ', JSON.stringify(this.front64list));
        console.log('list 2 ', JSON.stringify(this.back64list));
        console.log('list 3 ', JSON.stringify(this.frontnmlist));
        console.log('list 4 ', JSON.stringify(this.backnmlist));
        console.log('KYC ID List ', JSON.stringify(this.kycIdValues));
        console.log('apiLoggerList ', JSON.stringify(this.apiLoggerList));
        console.log('kycLoggerList ', JSON.stringify(this.kycLoggerList));
        var kyclist = this.kyclist;
        var front64list = this.front64list;
        var back64list = this.back64list;
        var frontnmlist = this.frontnmlist;
        var backnmlist = this.backnmlist;
        var kycIdValues = this.kycIdValues;
        var apiLoggerList = this.apiLoggerList;
        var kycLoggerList = this.kycLoggerList;
        console.log('kycLoggerList ' + kycLoggerList);
        await insertAccount({
            listOfApplicants: customerWrapper, preLogInId: preLogInId,
            kyclist: kyclist, front64list: front64list, back64list: back64list,
            frontnmlist: frontnmlist, backnmlist: backnmlist, kycIdValues: kycIdValues, apiLoggerList: apiLoggerList, ocridList: kycLoggerList
        })
            .then(result => {
                console.log('Accounts Inserted!!!' + result);
                if (result != undefined && result != '' && result != null) {
                    this.applicationId = result;
                    this.showToast('Success', 'Success', 'Record Saved Successfully!!');
                    this.closeAction();
                    getApplicationId({ recordId: this.preLogInId })
                        .then(result => {
                            this.appName = result.appName;
                            console.log('appName', this.appName);
                        })
                        .catch(error => {
                            console.log(error);
                        })
                }
                this.isAccDataArrived = false;
                this.getAccountData();
                this.handleOCRReset();

            })
            .catch(error => {
                console.log('error in populate list', error);
            })
        this.kycIdValues = [];
        this.hashKYC = [];
    }

    handleOCRReset() {
        console.log('Handle OCR Reset Called!!');
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
        this.requiredSpouse = false;
        this.disableAppType = false;
        this.editAccount = false;
        this.isMobile1 = true;
        this.isMobile2 = true;
        this.isfName = true;
        this.islName = true;
        this.isFather = true;
        this.isMother = true;
        this.isSpouse = true;
        this.isCity = true;
        this.isDOB = true;
        this.isDistrict = true;
        this.isPin = true;
        this.isAddress = true;
        this.isPrimary = false;
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
    @track isPrimary = false;
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
            this.resetOCRForm(eve);
        }
        if (this.editAccount === false) {
            //alert('Edit');
            this.resetOCRForm(eve);
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

    @track frontImageUrl;
    @track backImageUrl;
    @track frontFileType;
    @track backFileType;
    @track frontUpload = 0;
    @track backUPload = 0;
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
                if (this.verificationDefaultvalue != 'Self')
                    this.CallOCRFront(this.KYCTypeValue, this.frontbase64, 'front');
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
                if (this.verificationDefaultvalue != 'Self')
                    this.CallOCRFront(this.KYCTypeValue, this.rearbase64, 'back');
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
        }
    }

    @track openFrontImg = false;
    @track openBackImg = false;
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
                        console.log('retuned result ' + JSON.stringify(result));
                        if (result.statusCode != undefined || result.description == undefined) {
                            this.valueSelf = false;
                            this.verificationDefaultvalue = 'OCR';
                            this.resultwrapper = result;
                            //this.OCRResult = true;
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

                                if (this.resultwrapper.firstName != null && this.resultwrapper.firstName != undefined && this.resultwrapper.firstName != '') {
                                    this.isfName = false;
                                    const firstName = {
                                        label: this.resultwrapper.firstName,
                                        value: this.resultwrapper.firstName
                                    };
                                    this.firstNameOption = [...this.firstNameOption, firstName];
                                }
                                if (this.resultwrapper.lastName != null && this.resultwrapper.lastName != undefined && this.resultwrapper.lastName != '') {
                                    this.islName = false;
                                    const lastName = {
                                        label: this.resultwrapper.lastName,
                                        value: this.resultwrapper.lastName
                                    };
                                    this.lastNameOption = [...this.lastNameOption, lastName];
                                }

                                if (this.resultwrapper.FathersName != null && this.resultwrapper.FathersName != undefined && this.resultwrapper.FathersName != '') {
                                    this.isFather = false;
                                    const father = {
                                        label: this.resultwrapper.FathersName,
                                        value: this.resultwrapper.FathersName
                                    };
                                    this.fatherTypeOption = [...this.fatherTypeOption, father];
                                }

                                if (this.resultwrapper.MothersName != null && this.resultwrapper.MothersName != undefined && this.resultwrapper.MothersName != '') {
                                    this.isMother = false;
                                    const mother = {
                                        label: this.resultwrapper.MothersName,
                                        value: this.resultwrapper.MothersName
                                    };
                                    this.motherTypeOption = [...this.motherTypeOption, mother];
                                }

                                if (this.resultwrapper.SpouceName != null && this.resultwrapper.SpouceName != undefined && this.resultwrapper.SpouceName != '') {
                                    this.isSpouse = false;
                                    const spouse = {
                                        label: this.resultwrapper.SpouceName,
                                        value: this.resultwrapper.SpouceName
                                    };
                                    this.spouseTypeOption = [...this.spouseTypeOption, spouse];
                                }

                                if (this.resultwrapper.DOB != null && this.resultwrapper.DOB != undefined && this.resultwrapper.DOB != '') {
                                    this.isDOB = false;
                                    const dob = {
                                        label: this.resultwrapper.DOB,
                                        value: this.resultwrapper.DOB
                                    };
                                    this.dobTypeOption = [...this.dobTypeOption, dob];
                                }

                                if (this.resultwrapper.mobile_1 != null && this.resultwrapper.mobile_1 != undefined && this.resultwrapper.mobile_1 != '') {
                                    this.isMobile1 = false;
                                    const mbl1 = {
                                        label: this.resultwrapper.mobile_1,
                                        value: this.resultwrapper.mobile_1
                                    };
                                    this.mbl1TypeOption = [...this.mbl1TypeOption, mbl1];
                                }

                                if (this.resultwrapper.mobile_2 != '' && this.resultwrapper.mobile_2 != undefined && this.resultwrapper.mobile_2 != null) {
                                    this.isMobile2 = false;
                                    const mbl2 = {
                                        label: this.resultwrapper.mobile_2,
                                        value: this.resultwrapper.mobile_2
                                    };
                                    this.mbl2TypeOption = [...this.mbl2TypeOption, mbl2];
                                }

                                if (this.resultwrapper.City != null && this.resultwrapper.City != undefined && this.resultwrapper.City != '') {
                                    this.isCity = false;
                                    const city = {
                                        label: this.resultwrapper.City,
                                        value: this.resultwrapper.City
                                    };
                                    this.cityTypeOption = [...this.cityTypeOption, city];
                                }

                                if (this.resultwrapper.district != null && this.resultwrapper.district != undefined && this.resultwrapper.district != '') {
                                    this.isDistrict = false;
                                    const district = {
                                        label: this.resultwrapper.district,
                                        value: this.resultwrapper.district
                                    };
                                    this.districtTypeOption = [...this.districtTypeOption, district];
                                }

                                if (this.resultwrapper.Pincode != null && this.resultwrapper.Pincode != undefined && this.resultwrapper.Pincode != '') {
                                    this.isPin = false;
                                    const pin = {
                                        label: this.resultwrapper.Pincode,
                                        value: this.resultwrapper.Pincode
                                    };
                                    this.pinTypeOption = [...this.pinTypeOption, pin];
                                }

                                if (this.resultwrapper.Address != null && this.resultwrapper.Address != undefined && this.resultwrapper.Address != '') {
                                    this.isAddress = false;
                                    const address = {
                                        label: this.resultwrapper.Address,
                                        value: this.resultwrapper.Address
                                    };
                                    this.addressTypeOption = [...this.addressTypeOption, address];
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
                            this.showToast('Error', 'error', 'Issue in OCR Please proceed with self registration');
                            this.closeAction();
                            this.valueSelf = true;
                            this.verificationDefaultvalue = 'Self';
                            this.countApplicantType = this.countApplicantType - 1;
                            if (kycType === 'Aadhar_Card')
                                this.countAdhar = this.countAdhar - 1;
                            if (kycType === 'Voter_Id')
                                this.countVoter = this.countVoter - 1;
                            if (kycType === 'Pan_Card')
                                this.countPan = this.countPan - 1;
                            if (kycType === 'Passport')
                                this.countPassport = this.countPassport - 1;
                            if (kycType === 'Driving_License')
                                this.countDL = this.countDL - 1;
                            this.accountId = '';
                            this.verificationDefaultvalue = 'OCR';
                            //this.applicantTypeValue = 'Primary Applicant';
                            // this.frontImageName = '';
                            // this.rearImageName = '';
                            // this.frontUpload = 0;
                            // this.backUPload = 0;
                            // this.front64list = [];
                            // this.back64list = [];
                            // this.frontnmlist = [];
                            // this.backnmlist = [];
                        }

                    })
                    .catch(error => {
                        console.log('NO Data', error);
                        this.showToast('Error', 'error', 'Error: ' + error);
                        this.closeAction();

                    })
            }
            if (this.applicantTypeValue != '' && kycType != '') {
                if (kycType === 'Pan_Card' || kycType === 'Passport') {
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
            // if (this.countApplicantType >= 2) {
            //     this.disableSubmit = false;
            // }
            // else {
            //     this.disableSubmit = true;
            // }
        }
        else {
            this.showToast('Error', 'error', 'KYC Type Can Not Be Same');
            this.closeAction();
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