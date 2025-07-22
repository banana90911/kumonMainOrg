import { LightningElement, api, track } from 'lwc';

export default class LearningLogFlowLauncher extends LightningElement {
    @api recordId;
    @track isRunning = false;
    @track isSuccess = false;
    @track isFailure = false;

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    startFlow() {
        this.isRunning = true;
        this.isSuccess = false;
        this.isFailure = false;
    }

    handleStatusChange(event) {
        this.isRunning = false;

        if (event.detail.status === 'FINISHED') {
            this.isSuccess = true;
        } else if (
            event.detail.status === 'FAILED' ||
            event.detail.status === 'ERROR' ||
            event.detail.status === 'UNKNOWN'
        ) {
            this.isFailure = true;
        }
    }
}
