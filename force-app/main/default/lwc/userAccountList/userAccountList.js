import { LightningElement, wire } from 'lwc';
import getMyAccountsWithChildren from '@salesforce/apex/UserAccountController.getMyAccountsWithChildren';
import { NavigationMixin } from 'lightning/navigation';

export default class UserAccountList extends NavigationMixin(LightningElement) {
    accountList = [];
    error;

    @wire(getMyAccountsWithChildren)
    wiredAccounts({ data, error }) {
        if (data) {
            this.accountList = data;
        } else if (error) {
            this.error = error;
            console.error('데이터 로딩 실패:', error);
        }
    }

    handleAccountClick(event) {
        const accountId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    handleChildClick(event) {
        event.stopPropagation(); // 부모 클릭 방지
        const contactId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }
}