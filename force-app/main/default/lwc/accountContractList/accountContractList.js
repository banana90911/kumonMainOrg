import { LightningElement, api, wire } from 'lwc';
import getContractsByAccount from '@salesforce/apex/AccountContractController.getContractsByAccount';

export default class AccountContractList extends LightningElement {
    @api recordId; // Account Id
    contracts = [];
    error;

    formatNumber(value) {
        if (!value && value !== 0) return '0';
        return Number(value).toLocaleString();
    }

    @wire(getContractsByAccount, { accountId: '$recordId' })
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
}