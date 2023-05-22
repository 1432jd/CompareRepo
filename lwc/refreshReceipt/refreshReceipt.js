import { LightningElement, wire, api,track } from 'lwc';
export default class RefreshReceipt extends LightningElement {
    handleStatusOfEmpApi(){
        window.location.reload();
    }
}