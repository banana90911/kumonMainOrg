import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getParentCases from '@salesforce/apex/CaseListController.getCasesByAccount'; // Apex 클래스 경로
import { getRecord } from 'lightning/uiRecordApi'; //이건 recordId->AccountId로 가려고

const FIELDS = ['Case.AccountId__c']; //AccountId가져오기 위한 설정

export default class CaseListByAccount extends NavigationMixin(LightningElement) {
    @api recordId;
    accountId;
    parentCases = [];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            this.accountId = data.fields.AccountId__c.value;
        } else if (error) {
            console.error('❌ Case 레코드 조회 오류:', error);
        }
    }

    @wire(getParentCases, { accountId: '$accountId' })
    wiredParentCases({ error, data }) {
        if (data) {
            this.parentCases = data.map(c => ({
                ...c,
                emoji: this.getEmoji(c.Type)
            }));
        } else if (error) {
            console.error('❌ 문의 내역 조회 오류:', error);
        }
    }

    handleCaseClick(event) {
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

    getEmoji(type) {
        switch (type) {
            case '학습/평가':
                return '🎓';
            case '태블릿':
                return '📱';
            case '결제':
                return '💳';
            case '기타':
                return '🗂️';
            case '시스템장애':
                return '🛠️';
            default:
                return '❓';
        }
    }
}