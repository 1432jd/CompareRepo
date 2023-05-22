import { LightningElement,api,track } from 'lwc';
import getFeeCreationData from '@salesforce/apex/FeeCreationComponentHelper.getFeeCreationRecords';
import getApplicationDetail from '@salesforce/apex/FeeCreationComponentHelper.getApplicationDetail';

export default class FeeCreationParent extends LightningElement {
    @api recordId;
    @api preLogInId;
    @api appName;
    @api primaryApplicantName;
    @api stageName;
    @track feeList = true;
    @track stage = false;
    @track showReceipt = false;
    @track isLoading = false;
    
    connectedCallback(){
        setTimeout(() => {
        if(this.stageName != null && this.stageName != '' && this.stageName != undefined)
        console.log('Stage name',this.stageName);
        if(this.stageName == 'Pre Login'){
            this.stage = true;
        }
        
            console.log('app id', this.recordId);
            if (this.recordId) {
                this.getApplicationDetail();
            }
        }, 300);
        
    }
    //while user click on Fee detail tab
    @api showFee(){
        this.isLoading = true;
        //this.feeList = false;
        setTimeout(() => {
            if(this.template.querySelector('c-fee-creation-screen-2')){
                this.feeList = false;
                this.template.querySelector('c-fee-creation-screen-2').getFeeCreationRecords();
            }
        }, 300);       
    }
//From getFeeCreationRecords
    refreshFee(event){
        console.log('parag ',event.detail);
        this.isLoading = false;
        this.feeList = true;
    }

    @api getReceipt(){
        this.template.querySelector('c-prelogin-receipt-screen').getAllReceiptData();
    }
    @api getRecFeeCodeChange(event){
        this.feeList = false;
        console.log('fee code change parent',this.template.querySelector('c-prelogin-receipt-screen'));
        this.template.querySelector('c-prelogin-receipt-screen').getFeeCodeChange();
        this.feeList = true;
        this.template.querySelector('c-prelogin-receipt-screen').handleResetReceipt();
        
    }
    @api feeSubmitted(event){
         this.feeList = false;
         if(this.template.querySelector('c-fee-creation-screen-2')){
             
            this.template.querySelector('c-fee-creation-screen-2').getFeeCreationRecords();
         //this.feeList = true;
         }
         //this.feeList = false;
         if(this.template.querySelector('c-fee-type-insurance-creation')){
            this.template.querySelector('c-fee-type-insurance-creation').getInsuranceRecords();
         
         }
         this.feeList = true;
    }

    getApplicationDetail(){
        getApplicationDetail({recordId : this.recordId}).then(result=>{
            console.log('result in fee parent', result);
            var temp = result;
            if(temp != null && temp != undefined){
                this.preLogInId = temp[0].Pre_Login__c;
                console.log('result in fee parent preLogInId ', temp[0].Pre_Login__c);
                this.appName = temp[0].Name;
                console.log('result in fee parent appName ', temp[0].appName);
                this.primaryApplicantName = temp[0].Applicant_Name__c;
                console.log('  primaryApplicantName ', temp[0].primaryApplicantName);
            }
        }).catch(error => {
            console.log('error', error);
        })
       // SELECT Id, Pre_Login__c, Name, Applicant_Name__c FROM Application__c where Id =: recordId
    }
}