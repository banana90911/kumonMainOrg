import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// 필요한 Case 필드
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_NAME from '@salesforce/schema/Case.AccountName__c';
import CASE_PHONE from '@salesforce/schema/Case.SuppliedPhone';
import CASE_EMAIL from '@salesforce/schema/Case.SuppliedEmail';

export default class CaseStatusPanel extends LightningElement {
    @api recordId;

    currentStep;
    customerName = '';
    customerPhone = '';
    customerEmail = '';

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CASE_STATUS, CASE_NAME, CASE_PHONE, CASE_EMAIL]
    })
    wiredCase({ data, error }) {
        if (data) {
            this.currentStep = this.convertStatusToStep(data.fields.Status.value);
            this.customerName = data.fields.AccountName__c?.value || '';
            this.customerPhone = data.fields.SuppliedPhone?.value || '';
            this.customerEmail = data.fields.SuppliedEmail?.value || '';
        } else if (error) {
            console.error('Case 정보 로딩 실패:', error);
        }
    }

    convertStatusToStep(status) {
        switch (status) {
            case 'New': return 'New';
            case 'Working': return 'Working';
            case 'Closed': return 'Closed';
            default: return 'Unknown';
        }
    }

    get isNew() {
        return this.currentStep === 'New';
    }
    get isWorking() {
        return this.currentStep === 'Working';
    }
    get isClosed() {
        return this.currentStep === 'Closed';
    }

    handleCall() {
        if (this.customerPhone) {
            window.open(`tel:${this.customerPhone}`);
        } else {
            alert('연락처 정보가 없습니다.');
        }
    }

    handleSendProgressEmail() {
        alert('진행 상황 이메일 전송 완료');
    }

    handleSendCompletionNotice() {
        alert('처리 완료 알림 발송 완료');
    }

    handleSendFeedbackRequest() {
        alert('피드백 요청 전송 완료');
    }
}