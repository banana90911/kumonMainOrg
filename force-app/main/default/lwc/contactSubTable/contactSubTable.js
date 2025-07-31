import { LightningElement, api, wire } from 'lwc';
import getSubscriptions from '@salesforce/apex/SubscriptionController.getSubscriptions';

export default class SubscriptionTable extends LightningElement {
    @api recordId; // Contact Id
    subscriptions = [];
    error;

    @wire(getSubscriptions, { contactId: '$recordId' })
    wiredSubscriptions({ error, data }) {
        if (data) {
            this.subscriptions = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.subscriptions = [];
        }
    }

    handleRowClick(event) {
        const recordId = event.currentTarget.dataset.id;
        window.open(`/lightning/r/Subscription__c/${recordId}/view`, '_blank');
    }
}