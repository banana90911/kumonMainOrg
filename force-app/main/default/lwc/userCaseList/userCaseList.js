import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyCases from '@salesforce/apex/UserCaseController.getMyCases';

export default class UserCaseList extends NavigationMixin(LightningElement) {
    @track cases = [];

    get isEmpty() {
        return this.cases.length === 0;
    }

    connectedCallback() {
        getMyCases()
            .then(result => {
                this.cases = result;
            })
            .catch(error => {
                console.error('❌ 문의 로딩 실패', error);
            });
    }

    handleClick(event) {
        const caseId = event.currentTarget.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }
}