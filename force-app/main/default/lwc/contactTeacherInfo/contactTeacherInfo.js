import { LightningElement, api, wire } from 'lwc';
import getAssignedTeacher from '@salesforce/apex/ContactTeacherController.getAssignedTeacher';

export default class ContactTeacherInfo extends LightningElement {
    @api recordId;
    teacher;

    @wire(getAssignedTeacher, { contactId: '$recordId' })
    wiredTeacher({ data, error }) {
        if (data) {
            this.teacher = data;
        } else if (error) {
            console.error('Error loading teacher info:', error);
        }
    }

    get hasTeacher() {
        return this.teacher !== null && this.teacher !== undefined;
    }
}