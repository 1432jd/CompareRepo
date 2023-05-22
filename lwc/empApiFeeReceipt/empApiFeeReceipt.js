import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
export default class EmpApiFeeReceipt extends LightningElement {

    @api channel;
    @api apiVersion = '47.0';
    @api recordId;
    @api debug = false;

    subscription = {};

    connectedCallback() {
        this.handleSubscribe();
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        let self = this;
        const messageCallback = function (response) {
            //console.log('New message received : ', JSON.stringify(response));
            let partialCopyData = JSON.parse(JSON.stringify(response));
            self.dispatchEvent(new CustomEvent('message', { detail: { payload: partialCopyData.data.sobject } }));
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channel, -1, messageCallback).then(response => {
            // Response contains the subscription information on successful subscribe call
            //console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            //console.log('record id', this.recordId);
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        let self = this;
        onError(error => {
            self.dispatchEvent(new CustomEvent('error', { detail: { error: error } }));
            // Error contains the server-side error
        });
    }
}