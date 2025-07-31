import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import FULL_CALENDAR from '@salesforce/resourceUrl/fullcalendar';

export default class TeacherCalendar extends LightningElement {
    fullCalendarInitialized = false;

    renderedCallback() {
        if (this.fullCalendarInitialized) return;
        this.fullCalendarInitialized = true;

        loadScript(this, FULL_CALENDAR)
            .then(() => {
                console.log('✅ FullCalendar 스크립트 로딩 완료');
                this.initializeCalendar();
            })
            .catch(error => {
                console.error('❌ FullCalendar 로딩 실패:', error);
            });
    }

    initializeCalendar() {
        const calendarEl = this.template.querySelector('#calendar');

        if (!calendarEl || typeof FullCalendar === 'undefined') {
            console.error('❌ FullCalendar 객체 없음 또는 DOM 로딩 실패');
            return;
        }

        console.log('📅 FullCalendar 초기화 시작');

        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            locale: 'ko',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: ''
            },
            events: [
                {
                    title: '예시 일정',
                    start: new Date().toISOString().slice(0, 10)
                }
            ]
        });

        calendar.render();
    }
}