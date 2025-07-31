import { LightningElement, api, wire } from 'lwc';
import getAccountInfo from '@salesforce/apex/AccountController.getAccountInfo';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountInfoCard extends NavigationMixin(LightningElement) {
    @api recordId;

    name;
    phone;
    email;
    city;
    state;
    street;
    childName;
    childId;
    hasData = false;

    @wire(getAccountInfo, { accountId: '$recordId' })
    wiredAccount({ data, error }) {
        if (data) {
            const acc = data.account;
            this.name = acc.Name;
            this.phone = acc.Phone;
            this.email = acc.Email__c;
            this.city = acc.CityName__c;
            this.state = acc.State__c;
            this.street = acc.Street__c;
            this.childName = data.childName;
            this.childId = data.childId;
            this.hasData = true;
        } else if (error) {
            console.error('❌ Apex 데이터 로딩 실패:', error);
            this.hasData = false;
        }
    }

    handleChildClick() {
        if (!this.childId) return;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.childId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }
}