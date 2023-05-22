import { LightningElement, api } from 'lwc';

export default class TestNotes extends LightningElement {
    @api recordId;
    @api objectApiName;
}