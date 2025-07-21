import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import flowName from '@salesforce/label/c.Send_LearningLogSummaryEmail';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import { FlowInterview } from 'lightning/flowSupport';

export default class LearningLogSummarySender extends LightningElement {
    @api recordId; // Contact Id
    isSending = false;
    isSent = false;

    async handleSendEmail() {
        this.isSending = true;
        const flowName = 'Send_LearningLogSummaryEmail';

        const flow = await FlowInterview.create(flowName, {
            inputVariables: [
                {
                    name: 'contactId',
                    type: 'String',
                    value: this.recordId
                }
            ]
        });

        flow.onDone(() => {
            this.isSending = false;
            this.isSent = true;
        });

        await flow.start();
    }
}
