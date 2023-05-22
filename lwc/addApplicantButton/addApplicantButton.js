import { LightningElement, track } from 'lwc';

export default class AddApplicantButton extends LightningElement {
    @track isAddApplicant;
    handleClick(){
        this.isAddApplicant = true;
    }
}