import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Contact.Account.Name',
    'Contact.Account.Email__c',
    'Contact.Account.Phone',
    'Contact.Account.CityName__c',
    'Contact.Account.State__c',
    'Contact.Account.Street__c',
    'Contact.Account.Marketing_Consent__c',
    'Contact.Account.Privacy_Consent__c'
];

export default class ContactAccountInfo extends LightningElement {
    @api recordId; // Contact Id

    account = {};

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredContact({ data, error }) {
        if (data) {
            const acc = data.fields.Account.value.fields;
            this.account = {
                name: acc.Name.value,
                email: acc.Email__c?.value,
                phone: acc.Phone?.value,
                city: acc.CityName__c?.value,
                state: acc.State__c?.value,
                street: acc.Street__c?.value,
                marketingConsent: acc.Marketing_Consent__c?.value,
                privacyConsent: acc.Privacy_Consent__c?.value
            };
        } else if (error) {
            console.error('Account 정보 로딩 오류:', error);
        }
    }
    get privacyConsentText() {
        return this.account.privacyConsent ? '✔' : '❌';
    }
    get marketingConsentText() {
        return this.account.marketingConsent ? '✔' : '❌';
    }



}