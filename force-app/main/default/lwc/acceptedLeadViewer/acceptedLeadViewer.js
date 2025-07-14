import { LightningElement, track } from 'lwc';
import getAcceptedLeads from '@salesforce/apex/AcceptedLeadController.getAcceptedLeads';

export default class AcceptedLeadViewer extends LightningElement {
    @track leads = [];

    connectedCallback() {
        getAcceptedLeads()
            .then(result => {
                this.leads = result.map(l => ({
                    ...l,
                    telUrl: l.phone ? `tel:${l.phone}` : null
                }));
            })
            .catch(error => {
                console.error('Error loading accepted leads:', error);
            });
    }

    getTelUrl(phone) {
        return `tel:${phone}`;
    }

}