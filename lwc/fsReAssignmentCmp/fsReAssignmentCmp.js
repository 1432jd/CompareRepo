import { LightningElement,track } from 'lwc';
import getPendingApplicationTasks from '@salesforce/apex/FS_ApplicationReassignmentController.getPendingApplicationTasks';
import handleApplicationReassignment from '@salesforce/apex/FS_ApplicationReassignmentController.handleApplicationReassignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FsReAssignmentCmp extends LightningElement {
    @track applicationId;
    @track recordList;
    @track recordListFixed;
    @track updatedList = [];
    @track showSpinner = false;
    @track isDataChanged = false;


    handleSelect(event){
        console.log('handleSelect = ',event);    
        if(event && event.detail && event.detail.length){
            this.applicationId = event.detail[0].id;
        }else{
            this.applicationId = undefined;
        }
        console.log('applicationId = ',this.applicationId);        
    }

    handleOwnerChange(event){
        let index = event.target.dataset.index;
        console.log('handleOwnerChange = ',index, event.target.value);
        let tempJSON = JSON.parse(JSON.stringify(this.recordList));
        this.recordList = undefined;
        tempJSON[index].ownerId = event.target.value;
        this.recordList = JSON.parse(JSON.stringify(tempJSON));    
        this.handleCheckTrackChanges();
    }

    handleCheckTrackChanges(){
        this.isDataChanged = false;
        this.updatedList = [];
        let tempList = [];
        for(let i=0; i< this.recordList.length; i++){
            console.log('New Owner = ',this.recordList[i].ownerId ,' OldOwner ', this.recordListFixed[i].ownerId)
            if(this.recordList[i].ownerId != this.recordListFixed[i].ownerId){
                this.isDataChanged = true;
                tempList.push(this.recordList[i]);
            }
        }
        this.updatedList = JSON.parse(JSON.stringify(tempList));    
        console.log('handleCheckTrackChanges updatedList = ',this.updatedList);
        console.log('handleCheckTrackChanges = ',this.isDataChanged);
    }

    handleSearch(event){
        console.log('handle search = ',event);
        if(this.applicationId){
            this.handleGetSearchResult();
        }else{
            this.recordList = undefined
        }
    }

    handleReassigning(){
        this.showSpinner = true;
        handleApplicationReassignment({updatedListStr :JSON.stringify(this.updatedList)}).then((result) => {
            console.log('handleApplicationReassignment = ',result);
            this.showNotifications('','Tasks Reassigned Successfully!','success');
            this.showSpinner = false;
            let ref = this;
            setTimeout(() => {
                ref.handleReset();
            }, 300);
        }).catch((err) => {
            this.showNotifications('','Error in Task Reassignment, Kindly Contact Your System Admin!','error');
            this.showSpinner = false;
            console.log('Error in handleApplicationReassignment = ',err);
        });
    }

    // This Method Is Used To Show Toast Notifications
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    handleReset(){
        // document.dispatchEvent(new CustomEvent("aura://refreshView"));
        eval("$A.get('e.force:refreshView').fire();");
    }

    handleGetSearchResult(){
        this.showSpinner = true;
        getPendingApplicationTasks({applicationId : this.applicationId}).then((result) => {
            console.log('handleGetSearchResult = ',result);
            this.recordList = JSON.parse(JSON.stringify(result));
            this.recordListFixed = JSON.parse(JSON.stringify(result));
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in handleGetSearchResult = ',err);
            this.showSpinner = false;
        });
    }
}