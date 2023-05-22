import { LightningElement, track, api, wire } from 'lwc';
import searchOwner from "@salesforce/apex/OwnerChnageController.searchOwner";
import updateRecordOwner from "@salesforce/apex/OwnerChnageController.updateRecordOwner";
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class ChangeOwner extends LightningElement {

  @api recordId;
  @track recordsList;
  @track searchKey = "";
  @api selectedValue;
  @api selectedRecordId;
  @api objectApiName;
  @api iconName;
  @api lookupLabel;
  @track message;
  @api keyfromparent;
  @track currentObjectName;
  @track callOnce = false;
  @track sendNotification= true;

  @wire(CurrentPageReference)
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
  }

  connectedCallback() {
    console.log(this.recordId+' :: '+this.objectApiName);
    this.currentObjectName = this.objectApiName;
  }

  // renderedCallback() {
  //       if (!this.callOnce) {
  //           const style = document.createElement('style');
  //           style.innerText = `.uiModal--medium .modal-container{
  //             width: 50%;
  //             max-width: 840px;
  //             min-width: 480px;
  //           }`;
  //           this.template.querySelector("div .modal-container").appendChild(style);
  //           // const label = this.template.querySelectorAll('label');
  //           // label.forEach(element => {
  //           //     element.classList.add('bold');
  //           // });
  //           console.log('renderedCallback()');
  //       }
  //   }

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

    searchOwner({ searchKey: this.searchKey, objectAPIName: this.objectApiName, recordId: this.recordId }).then(result =>{
      console.log('Search Result ',result);
      this.recordsList = result;
    })
    .catch(error =>{
      console.log('error ',error);
    })
  //  findRecords({ searchKey: this.searchKey, objectName: this.objectApiName, recordId: this.recordId })
  //     .then((result) => {
  //       if (result.length === 0) {
  //         this.recordsList = [];
  //         this.message = "No Records Found";
  //       } else {
  //         this.recordsList = result;
  //         this.message = "";
  //       }
  //       this.error = undefined;
  //     })
  //     .catch((error) => {
  //       this.error = error;
  //       this.recordsList = undefined;
  //     });
  }

  // handleChange(event){
  //   this.sendNotification=event.target.checked;
  //   console.log('this.sendNotification:'+this.sendNotification);
  // }

  onSeletedRecordUpdate() {
    console.log('selectedRecordId', this.selectedRecordId);
    updateRecordOwner({ recordId: this.recordId, userId: this.selectedRecordId,objectAPIName: this.currentObjectName,sendNotification:this.sendNotification})
      .then(result => {      
        console.log(result);
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
  
}