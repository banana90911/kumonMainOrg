import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';

export default class CaseDescriptionHighlight extends LightningElement {
    @api recordId;
    caseDescription;

    @wire(getRecord, { recordId: '$recordId', fields: [DESCRIPTION_FIELD] })
    wiredCase({ error, data }) {
        if (data) {
            this.caseDescription = data.fields.Description.value;
        } else if (error) {
            console.error(error);
        }
    }
}