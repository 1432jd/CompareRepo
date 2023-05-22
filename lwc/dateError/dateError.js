import { LightningElement,track } from 'lwc';

export default class DateError extends LightningElement {

      @track ocrCustomerWrapper = {
        kycType1:'',kycType2:'', incCon: '', appType: '', Gender: '', Salutation: '',
        firstName: '', lastName: '', FathersName: '', MothersName: '',
        married: '', SpouceName: '', DOB: '', mobile_1: '', mobile_2: '',
        City: '', district: '', Pincode: '', Address: '',
        verification: this.verificationDefaultvalue, Applicant_Type: this.applicantTypeValue,
        kycId1: '', kycId2: '', constitution: ''
    };
}