import { LightningElement, wire } from 'lwc';
import getSchedulesForLoggedInTeacher from '@salesforce/apex/LearningScheduleController.getSchedulesForLoggedInTeacher';

export default class LearningScheduleCalendar extends LightningElement {
    schedules;

    @wire(getSchedulesForLoggedInTeacher)
    wiredSchedules({ error, data }) {
        if (data) {
            this.schedules = data;
            console.log('📚 일정 데이터:', data);
        } else if (error) {
            console.error('❌ 오류:', error);
        }
    }
}