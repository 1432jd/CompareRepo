import { LightningElement,api,track,wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation'
export default class FsDisplayKYCDocs extends NavigationMixin(LightningElement){

    @api imgLinks;

    @track isModalOpen = true;

    previewHandler(event){
        console.log('fileId ',event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }

    closeModal(){
        this.isModalOpen = false;
        const closeKYCPopup = new CustomEvent("closekycpopup", {
            detail: this.isModalOpen
        });
        console.log('dispatch event ', closeKYCPopup);
        this.dispatchEvent(closeKYCPopup);
    }


}