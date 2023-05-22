import { LightningElement, track } from 'lwc';
import getUnassignedApplications from '@salesforce/apex/FS_ApplicationPullAssignmentHandler.getUnassignedApplications';
import handleApplicationReassignment from '@salesforce/apex/FS_ApplicationPullAssignmentHandler.handleApplicationReassignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ApplicationAssignmentCmp extends LightningElement {
    @track recordList;
    @track updatedList = [];
    @track showSpinner = false;
    @track isDataChanged = false;

    connectedCallback(){
        this.handleGetSearchResult();
    }

    handleCheckboxValue(event){
        console.log('handleCheckboxValue = ',event.target.checked);
        console.log('handleCheckboxValue = ',event.target.name);
        this.updatedList = undefined;
        if(event.target.name == 'selectAll'){
            let tempList = JSON.parse(JSON.stringify(this.recordList));
            this.recordList = undefined;
            if(event.target.checked){                
                tempList.forEach(element => {
                    element.checked = true;
                });
            }else{                
                tempList.forEach(element => {
                    element.checked = false;
                });
            }
            this.recordList = JSON.parse(JSON.stringify(tempList));
        } else if(event.target.name == 'selectItem'){
            let tempList = JSON.parse(JSON.stringify(this.recordList));
            this.recordList = undefined;
            let index = event.target.dataset.index;
            tempList[index].checked = event.target.checked;
            this.recordList = JSON.parse(JSON.stringify(tempList));
        }

        let tempList = [];
        this.recordList.forEach(element => {
            if(element.checked){
                tempList.push(element);
            }
        });

        if(tempList && tempList.length){
            this.updatedList = JSON.parse(JSON.stringify(tempList));
        }
        console.log('this.updatedList = ',this.updatedList);
    }

    handleApplicationSearch(evt){
        let text = evt.target.value;
        console.log('handleApplicationSearch = ',text);
        if(text){
            text = text.toLocaleLowerCase();
            this.recordList = undefined;
            let tempArr = this.recordListFixed.filter(element => (element.applicationNumber.toLocaleLowerCase().includes(text) || element.branchName.toLocaleLowerCase().includes(text) || element.stage.toLocaleLowerCase().includes(text)));
            console.log('tempArr = ',tempArr);
            this.recordList = JSON.parse(JSON.stringify(tempArr));
        } else {
            this.recordList = undefined;
            this.recordList = JSON.parse(JSON.stringify(this.recordListFixed));
        }
    }

    handleClaim(){
        if(this.updatedList && this.updatedList.length){
            this.handleReassignment();
        }else{
            this.showNotifications('','Please select any item first.','error');
        }
    }

    // This Method Is Used To Show Toast Notifications
    showNotifications(title, msg, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        }));
    }

    // This method is used to refresh page content
    handleReset(){
        eval("$A.get('e.force:refreshView').fire();");
    }

    handleGetSearchResult(){
        this.showSpinner = true;
        getUnassignedApplications().then((result) => {
            console.log('handleGetSearchResult = ',result);
            this.recordList = JSON.parse(JSON.stringify(result));
            this.recordListFixed = JSON.parse(JSON.stringify(result));
            this.showSpinner = false;
        }).catch((err) => {
            console.log('Error in handleGetSearchResult = ',err);
            this.showSpinner = false;
        });
    } 

    handleReassignment(){
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
            this.showNotifications('','Error in Task Assignment, Kindly Contact Your System Admin!','error');
            this.showSpinner = false;
            console.log('Error in handleApplicationReassignment = ',err);
        });
    }
}