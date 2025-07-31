import { LightningElement, api, wire } from 'lwc';
import getSubjectFamilies from '@salesforce/apex/ChildProfileController.getSubjectFamilies';
import getRelatedInfo from '@salesforce/apex/ChildProfileController.getRelatedInfo';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Contact.ChildName__c', 'Contact.Birthdate'];

export default class ContactInfo extends LightningElement {
    @api recordId;

    childName;
    birthdate;
    subjects = [];

    parentName;
    teacherName;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredContact({ data, error }) {
        if (data) {
            this.childName = data.fields.ChildName__c.value;
            this.birthdate = data.fields.Birthdate.value;
        } else if (error) {
            console.error('❌ Contact 필드 로딩 오류:', error);
        }
    }

    @wire(getSubjectFamilies, { contactId: '$recordId' })
    wiredSubjects({ data, error }) {
        if (data) {
            this.subjects = data;
        } else if (error) {
            console.error('❌ 과목 로딩 오류:', error);
        }
    }

    @wire(getRelatedInfo, { contactId: '$recordId' })
    wiredRelated({ data, error }) {
        if (data) {
            this.parentName = data.Account?.Name || '정보 없음';
            this.parentId = data.Account?.Id;
            this.teacherName = data.TeacherId__r?.Name || '정보 없음';
            this.teacherId = data.TeacherId__r?.Id;
        } else if (error) {
            console.error('❌ 학부모/교사 정보 오류:', error);
        }
    }


    get age() {
        if (!this.birthdate) return '';
        const birth = new Date(this.birthdate);
        const today = new Date();
        let age = today.getFullYear() - birth.getFullYear();
        const m = today.getMonth() - birth.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) {
            age--;
        }
        return age;
    }

    get subjectString() {
        return this.subjects.join(', ');
    }
    get parentUrl() {
        return this.parentId ? `/lightning/r/Account/${this.parentId}/view` : '#';
    }

    get teacherUrl() {
        return this.teacherId ? `/lightning/r/User/${this.teacherId}/view` : '#';
    }


}