import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ID_FIELD from '@salesforce/schema/Case.Id';

const STATUS_LABELS = {
    New: '문의 접수',
    Working: '문의 진행',
    Closed: '처리 완료'
};

export default class CaseStatusUpdate extends LightningElement {
    @api recordId;
    selectedStatus = '';
    currentStatus = '';
    statusOptions = [
        { label: '문의 접수', value: 'New' },
        { label: '문의 진행', value: 'Working' },
        { label: '처리 완료', value: 'Closed' }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    wiredCase({ data, error }) {
        if (data) {
            this.currentStatus = data.fields.Status.value;
            this.selectedStatus = this.currentStatus;
        } else if (error) {
            console.error(error);
        }
    }

    get currentStatusLabel() {
        return STATUS_LABELS[this.currentStatus] || '알 수 없음';
    }

    get currentStatusValue() {
        return this.currentStatus?.toLowerCase(); // ex) new, working, closed
    }

    get computedStatusClass() {
        return `status-badge-${this.currentStatusValue}`;  // ex: 'status-badge-new'
    }

    handleChange(event) {
        this.selectedStatus = event.detail.value;
    }

    handleUpdate() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[STATUS_FIELD.fieldApiName] = this.selectedStatus;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                // 업데이트 성공
                this.dispatchEvent(
                    new CustomEvent('statusupdated')
                );
            })
            .catch(error => {
                console.error('Error updating status:', error);
            });
    }
}