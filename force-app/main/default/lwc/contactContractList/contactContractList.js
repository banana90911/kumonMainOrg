import { LightningElement, api, wire } from 'lwc';
import getContractsByContact from '@salesforce/apex/ContactContractController.getContractsByContact';
import { getRecord } from 'lightning/uiRecordApi';

const CONTACT_FIELDS = ['Contact.ChildName__c'];

export default class ContactContractList extends LightningElement {
    @api recordId; // Contact Id
    contracts = [];
    contactName = '';
    error;


    formatNumber(value) {
        if (!value && value !== 0) return '0';
        return Number(value).toLocaleString();
    }
    @wire(getContractsByContact, { contactId: '$recordId' })
    wiredContracts({ data, error }) {
        if (data) {
            this.contracts = data.map(c => ({
                ...c,
                promoName: c.Campaign__r?.Name || '없음',
                formattedOriginalAmount: this.formatNumber(c.Original_Total_Amount__c),
                formattedTotalPrice: this.formatNumber(c.Total_Price__c)
            }));
        } else if (error) {
            this.contracts = [];
            this.error = error;
            console.error('계약 로딩 오류:', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: CONTACT_FIELDS })
    wiredContact({ data, error }) {
        if (data) {
            this.contactName = data.fields.ChildName__c.value;
        } else if (error) {
            console.error('아동 이름 로딩 오류:', error);
        }
    }

}