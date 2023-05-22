import { LightningElement,api,wire,track } from 'lwc';
//import saveRecord from'@salesforce/apex/FsLeadDetailsController.saveRecord';
import getSectionContent from '@salesforce/apex/FsLeadDetailsController.getSectionContent';
import { CloseActionScreenEvent } from 'lightning/actions';
import createFeeCreationData from '@salesforce/apex/FeeCreationComponentHelper.createFeeCreationRecords';
//import getFeeCreationData from '@salesforce/apex/FeeCreationComponentHelper.getFeeCreationRecords';
import addRow from '@salesforce/apex/FeeCreationComponentHelper.addRow';
import saveRecord from'@salesforce/apex/FsPreloginController.saveRecord';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getFeeCreationDataIns from '@salesforce/apex/FeeCreationInsuranceType.getFeeCreationDataIns';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFeeCreationDataTable from '@salesforce/apex/FeeCreationInsuranceType.getFeeCreationDataTable';
import getAllFeeMeta from '@salesforce/apex/FeeCreationInsuranceType.getAllFeeMeta';
export default class FeeCreationScreen extends LightningElement {

    @api recordId;
    @track isFeeDataArrived = false;
    @track tableData = false;
    @api feeCreationId;
    @api allValues1 = [];
    @api options = [];
    @api feeCodeOptions = [];
    @api stageDueOptions = [];
    @track removeRow;
    @track pickValue;
    @track stageDue;
    @track applicableOn;
    @track accountList = []; 
    @track index = 0;
    @api applicationId;
    @api allLoanApplicant;
    @track tableData2;
    @track isRecordEdited = false;
    @api rowAction;
    @track fieldsContent;
    @track objectIdMap = {'Fee_Creation__c':''};
    @track isSpinnerActive = false;
    @api result
    @track selectedApplicant;
    @track recordIds;
   // @track isLoaded = false;
    // @track size;
    @track rowAction = [
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
    ]

 connectedCallback(){
        this.getSectionPageContent(this.applicationId);
        this.getFeeCreationDataIns();
      //  this.getFeeCreationDataTable() ;
    }
    previous(){
        prevData({recordIds : recordId})
        .then(result => {
            //  console.log('data ### ',JSON.parse(result.data));
              this.fieldsContent = result.data;
              console.log('field content'+this.fieldsContent);
          })
          .catch(error => {
              console.log(error);
          });
    }
    handleSelectedApplication(event) {
        console.log('Edit called #### ', JSON.stringify(event.detail));
        this.isSpinnerActive = true;
        var recordData = event.detail.recordData;
        console.log('record data in handle selected'+JSON.stringify(recordData));
        if (event.detail.ActionName === 'edit') {
            this.isApplicantEdit = false;
            this.recordIds = recordData.Id;
            this.objectIdMap['Fee_Creation__c'] = this.recordIds
            this.getSectionPageContent(this.recordIds);
            this.isSpinnerActive = false;
        }
        if (event.detail.ActionName === 'delete') {
            this.recordIdForDelete = event.detail.recordData.Id;
            this.showDeleteModal = true;
        }
    }
    getSectionPageContent(recId){
        try{
            getSectionContent({recordIds : recId, metaDetaName : 'Fee_c_Fee_Creation_Type_Insurance'})
            .then(result => {
              //  console.log('data ### ',JSON.parse(result.data));
                this.fieldsContent = result.data;
                console.log('field content'+this.fieldsContent);
            })
            .catch(error => {
                console.log(error);
            });
        }catch(error){
            console.log(error);
        }
    }
    changedFromChild(event){
        var recordData = event.detail.recordData;
        console.log('changedFromChild ### ',recordData);
        var tempFieldsContent = event.detail;
        if(tempFieldsContent.CurrentFieldAPIName == 'Fee_Creation__c-Premium__c' || tempFieldsContent.CurrentFieldAPIName == 'Fee_Creation__c-Fee_Collection__c'){
            
            console.log('in if of get from child ');
           // this.template.querySelector('c-generic-edit-pages-l-w-c').refreshData(JSON.stringify(this.setValues('Net_Income__c',totalNetIncome)));
        }
    }
    handleTable() {
        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        console.log('data #### ', JSON.stringify(data)+'and data length'+ data.length);
        if (data.length > 0) {
            this.isSpinnerActive = true;
            for (var i = 0; i < data.length; i++) {
                console.log('selected applicant in handle save'+this.selectedApplicant);
                if(this.selectedApplicant === undefined){
                    data[i].Id = this.objectIdMap[data[i].sobjectType];
                 // data[i].Id = Application__c;
                 data[i].Application__c = this.recordId;
                    console.log('and the id is'+data[i].id);
                    
                } else{
                    data[i].Application__c = this.selectedApplicant[0].Application__c;
                   
                }
                
                console.log('data 2## ', JSON.stringify(data));
                saveRecord({ dataToInsert: JSON.stringify(data[i]) })
                .then(result => {
                    console.log('in then from save record');
                    this.fieldsContent = {};
                    this.feeCreationId = result;
                    this.showtoastmessage('Success', 'Success', result);
                    this.tableData2= undefined;
                    this.selectedApplicant = undefined;
                    this.allApplicantData = undefined;
                    this.getFeeCreationDataIns();
                    this.getAllFeeMeta();
                })
                .catch(error => {
                    console.log(error);
                    this.showtoastmessage('Error', 'Error', JSON.stringify(error));
                });
            }
        } else {
            this.showtoastmessage('Error', 'Error', 'Complete Required Field(s).');
        }
    }
    getFeeCreationDataIns() {
       // console.log('called ##### ',JSON.stringify(this.allLoanApplicant));
        getFeeCreationDataIns({ allLoanApplicant: this.recordId })
        .then(result => {
            console.log('result in fee creation data##### ',JSON.stringify(result));
            this.isApplicantEdit = true;
            this.tableData2 = result;
            this.isSpinnerActive = false;
        })
        .catch(error => {

        })
    }
    getAllFeeMeta(){
        getAllFeeMeta({ applicationId: this.recordId })
        .then(result => {
            this.allApplicantData = result;
            this.isSpinnerActive = false;
        })
        .catch(error => {

        })
    }
    handleSave(){
        console.log('recordId:'+this.recordId);
        this.isSpinnerActive = true;
        var data = this.template.querySelector("c-generic-edit-pages-l-w-c").handleOnSave();
        console.log('data #### ',JSON.stringify(data));
        if(data.length > 0){
            //data[0].Id = Application__c;
            //console.log('Id####' + Id);
            data[0].Application__c = this.recordId;   
            console.log('data #### in handle save ',JSON.stringify(data));
            saveRecord({dataToInsert : JSON.stringify(data[0])})
            .then(result => {
                console.log('data #### to show messege ',result);
                this.fieldsContent = {};
                this.isSpinnerActive = false;
                this.feeCreationId = result;
                //getFeeCreationData();
                this.getFeeCreationDataTable();
                
                this.dispatchEvent(
                   new ShowToastEvent({
                              title: 'Success',
                              message: 'Success.',
                              variant: 'Success'
                          })
                          
                 );
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                               title: 'Error',
                               message: 'Error',
                               variant: JSON.stringify(error)
                           })
                           
                  );
            //    this.showtoastmessage('Error','Error',JSON.stringify(error));
            });
        } else{
            this.dispatchEvent(
                new ShowToastEvent({
                           title: 'Error',
                           message: 'Error',
                           variant: 'Complete Required Field(s).'
                       })
                       
              );
           // this.showtoastmessage('Error','Error','Complete Required Field(s).');
        }
    }
     handleCancel(){
        console.log('handle cancel called ###');
        this.fieldsContent = {};
    }
    showtoastmessage(title, variant, message){
        const selectedEvent = new CustomEvent('showtoastmessage', { 
            detail : {
                'title':title,
                'variant':variant,
                'message':message,
            }
        });    
        this.dispatchEvent(selectedEvent);
    }
    //get Fee Creation related to current application
    getFeeCreationDataTable() {
        
        console.log('get fee creation called');
        getFeeCreationDataTable({ applicationId: this.feeCreationId })
        .then(result => {
            console.log('result returned'+ result);
            console.log('api called from fee',JSON.stringify(result));
          //  this.isApplicantEdit = true;
            this.tableData = result;
            this.isSpinnerActive = false;
        })
        .catch(error => {

        })
    }
    
   
}