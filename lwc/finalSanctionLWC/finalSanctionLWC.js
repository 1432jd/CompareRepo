import { LightningElement, api, track, wire } from 'lwc';
import getPropertyRecords from '@salesforce/apex/FinalSanctionController.getPropertyRecords';
import updateApplicationOwner from '@salesforce/apex/FinalSanctionController.updateApplicationOwner';
import searchOwner from "@salesforce/apex/FinalSanctionController.searchOwner";
import updateRecordOwner from "@salesforce/apex/FinalSanctionController.updateRecordOwner";
import getApprovalCreditRecord from '@salesforce/apex/FinalSanctionController.getApprovalCreditRecord';
import getApplicationStage from '@salesforce/apex/FinalSanctionController.getApplicationStage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class FinalSanctionLWC extends LightningElement {

  @api recordId;
  @api legalApprovalId;
  @track applicationObj;
  @track recordsList;
  @track searchKey = "";
  @api selectedValue;
  @api selectedRecordId;
  @api iconName;
  @api lookupLabel;
  @track message;
  @api keyfromparent;
  @track currentObjectName;
  @track callOnce = false;
  @track sendNotification = false;
  @track currentId;
  @api objectApiName = 'Legal_Approval__c';
  @api userId;
  @track propertyRec;
  @track ApplicationStage;
  @track propertyList;
  @track titleDeedList;
  @track titleDeedTypeList;
  @track titleDeedDateList;
  @track listOfLandAreaObject = [];
  @track listOfTitleDeedObject = [];
  @track getList;
  @track getListDeed;
  @track isLC = false;
  @track showLcButton;
  @track showAcButton;
  @track showModel = true;

 
  connectedCallback() {
    console.log(this.recordId + ' :: ' + this.objectApiName);
    this.legalApprovalId = 'a0j0w0000025GvgAAE';
    this.currentObjectName = 'Legal_Approval__c';
    console.log('Inside Connected Callback');
    getPropertyRecords({ appId: this.recordId })
      .then(item => {
        console.log('Item', item);
        this.propertyList = item;
        console.log('propertyList', this.propertyList);
        console.log('titleDeedList', this.titleDeedList);
        console.log('titleDeedTypeList', this.titleDeedTypeList);
        console.log('titleDeedDateList ', this.titleDeedDateList);
        console.log('landAreaList.lengt', this.landAreaList[1].length);
        for (let i = 0; i < this.landAreaList.length; i++) {
          console.log('Loop 1');
          this.getList = this.landAreaList[i];
          console.log('getList ', this.getList);
          let variable = 'P' + (i + 1);
          let object = {
            PropertyName: variable,
            AC: '',
            LC: '',
            Result: ''
          }
          for (let j = 0; j < this.getList.length; j++) {
            console.log('Loop 2');
            if (j == 0) {
              object.AC = this.getList[j];
            }
            else if (j == 1) {
              object.LC = this.getList[j];
            }
            else if (j == 2) {
              object.Result = this.getList[j]
            }
          }
          this.listOfLandAreaObject.push(object);
        }
        for (let i = 0; i < this.titleDeedList.length; i++) {
          console.log('Loop 1');
          this.getListDeed = this.titleDeedList[i];
          console.log('getList ', this.getListDeed);
          let variable = 'P' + (i + 1);
          let object = {
            PropertyName: variable,
            AC: '',
            LC: '',
            Result: ''
          }
          for (let j = 0; j < this.getListDeed.length; j++) {
            console.log('Loop 2');
            if (j == 0) {
              object.AC = this.getListDeed[j];
            }
            else if (j == 1) {
              object.LC = this.getListDeed[j];
            }
            else if (j == 2) {
              object.Result = this.getListDeed[j]
            }
          }
          this.listOfTitleDeedObject.push(object);
        }

        console.log('listOfTitleDeedObject', this.listOfTitleDeedObject);
        console.log('listOfLandAreaObject', this.listOfLandAreaObject);
      })
      .catch(error => {
        this.error = error;
      });
    getApplicationStage({ appId: this.recordId }).then(result => {
      console.log('result', JSON.parse(JSON.stringify(result)));
      // console.log('1',result.showAc);
      console.log('LC=', JSON.parse(JSON.stringify(result.showLc)));
      console.log('AC=', JSON.parse(JSON.stringify(result.showAc)));

      this.showAcButton = JSON.parse(JSON.stringify(result.showAc));
      this.showLcButton = JSON.parse(JSON.stringify(result.showLc))
      // console.log('this.showLcButton'+ this.ApplicationStage);

    })
      .catch(error => {
        this.error = error;
      });
  }
  handleChange() {
    updateApplicationOwner({ recordId: this.recordId })
      .then(result => {
        if (result == 'Application successfully updated') {
          console.log(result);
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'owner updated successfully',
              variant: 'success',
            }),
          );
        }
        if (result == 'failed') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: result,
              variant: 'Error',
            }),
          );
        }
      })
      .catch(error => {
        this.message = undefined;
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error creating record',
            message: error.body.message,
            variant: 'error',
          }),
        );
      });
  }
  closeModal() {
    // to close modal set isModalOpen track value as false
    this.isLC = false;
  }
  handleLC(event) {
    this.isLC = true;

  }

  /*@wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
      if (currentPageReference) {
        if (!this.recordId && !this.objectApiName) {
          console.log('Object API Null');
          this.recordId = currentPageReference.state.recordId;
          const apiName = currentPageReference.attributes.apiName;
          this.objectApiName = apiName.split(".")[0];
          console.log(this.objectApiName);
        }
        else{
          console.log(this.objectApiName+' :: '+this.recordId);
        }
      }
    }*/

  /*connectedCallback() {
    console.log(this.recordId+' :: '+this.objectApiName);
    this.currentObjectName = this.objectApiName;
  }*/


//216-end

  onLeave(event) {
    setTimeout(() => {
      this.searchKey = "";
      this.recordsList = null;
    }, 300);
  }


  onRecordSelection(event) {
    this.selectedRecordId = event.target.dataset.key;
    this.selectedValue = event.target.dataset.name;
    this.searchKey = "";
  }

  handleKeyChange(event) {
    const searchKey = event.target.value;
    this.searchKey = searchKey;
    this.getLookupResult();
  }

  removeRecordOnLookup(event) {
    this.searchKey = "";
    this.selectedValue = null;
    this.selectedRecordId = null;
    this.recordsList = null;
  }

  getLookupResult() {
    searchOwner({ searchKey: this.searchKey, objectAPIName: this.objectApiName, recordId: this.recordId }).then(result => {
      console.log('Search Result ', result);
      this.recordsList = result;
    })
      .catch(error => {
        console.log('error ', error);
      })

  }
  onSeletedRecordUpdate() {
    console.log('selectedRecordId', this.selectedRecordId);
    updateRecordOwner({ recordId: this.recordId, userId: this.selectedRecordId, sendNotification: this.sendNotification })
      .then(result => {
        console.log('1', result);
        const event = new ShowToastEvent({
          title: 'Success',
          message: 'Record Owner is changed successfully!',
          variant: 'success',
        });
        this.dispatchEvent(event);
        this.dispatchEvent(new CloseActionScreenEvent());
        eval("$A.get('e.force:refreshView').fire();");
      })
      .catch(error => {
        console.log(error);
      });
  }
  OnCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  handleFinish() {
    getApprovalCreditRecord({ recordId: this.recordId }).then(result => {
      console.log('recordId', this.recordId);
      console.log('result' + result);
      if (result == 'Final Sanction Successfully Completed') {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Final Sanction Successfully Completed',
            variant: 'success',
          }),
        );
      }
      if (result == 'Stage should be Completed') {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: result,
            variant: 'Error',
          }),
        );
      }
    })

      .catch(error => {
        this.message = undefined;
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'final Sanction is not completed',
            message: error.body.message,
            variant: 'error',
          }),
        );
      });
  }

}