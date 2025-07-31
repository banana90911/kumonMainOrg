import { LightningElement, api } from 'lwc';

export default class LearningLogSummarySender extends LightningElement {
    @api recordId;

    isRunning = false;
    isSuccess = false;
    isFailure = false;
    showFlow = false;

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    handleClick() {
        this.isSuccess = false;
        this.isFailure = false;
        this.isRunning = true;
        this.showFlow = true;
    }

    handleStatusChange(event) {
        const status = event.detail.status;

        if (status === 'FINISHED') {
            // 🧼 메시지 초기화 (이 타이밍이 가장 안전함)
            this.isSuccess = false;
            this.isFailure = false;

            const outputVars = event.detail.outputVariables || [];
            const resultVar = outputVars.find(v => v.name === 'emailActuallySent');
            const wasEmailSent = resultVar?.value === true;

            if (wasEmailSent) {
                this.isSuccess = true;
            } else {
                this.isFailure = true;
            }

            // ⏳ 메시지 유지 후 자동 제거 (5초 후)
            setTimeout(() => {
                this.isSuccess = false;
                this.isFailure = false;
            }, 5000);
        }

        if (
            status === 'FAILED' ||
            status === 'ERROR' ||
            status === 'UNKNOWN'
        ) {
            this.isSuccess = false;
            this.isFailure = true;

            setTimeout(() => {
                this.isFailure = false;
            }, 5000);
        }
    }

}