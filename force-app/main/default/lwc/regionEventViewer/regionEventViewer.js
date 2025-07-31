import { LightningElement, track, wire } from 'lwc';
import getRegionTeacherEvents from '@salesforce/apex/RegionTeacherEventsController.getRegionTeacherEvents';

export default class RegionEventViewer extends LightningElement {
    @track events = [];
    @track selectedDay = '월';

    // 📅 요일 계산 동일
    get weekdays() {
        const today = new Date();
        const currentDay = today.getDay();
        const mondayOffset = currentDay === 0 ? -6 : 1 - currentDay;

        const dayNames = ['일', '월', '화', '수', '목', '금', '토'];
        const result = [];

        for (let i = 0; i < 5; i++) {
            const date = new Date(today);
            date.setDate(today.getDate() + mondayOffset + i);

            const month = date.getMonth() + 1;
            const day = date.getDate();
            const label = `${dayNames[(i + 1) % 7]} (${month}/${day})`;

            result.push({
                label,
                value: dayNames[(i + 1) % 7],
                dateObj: date
            });
        }
        return result;
    }

    get decoratedWeekdays() {
        return this.weekdays.map(day => ({
            ...day,
            className: this.selectedDay === day.value ? 'day-button selected' : 'day-button'
        }));
    }

    @wire(getRegionTeacherEvents)
    wiredEvents({ data, error }) {
        if (data) {
            this.events = data;
        } else if (error) {
            console.error('이벤트 로딩 오류:', error);
        }
    }

    handleDayClick(event) {
        this.selectedDay = event.currentTarget.dataset.value;
    }

    get formattedEvents() {
        const dayMap = { '일': 0, '월': 1, '화': 2, '수': 3, '목': 4, '금': 5, '토': 6 };

        return this.events
            .filter(ev => {
                const localDate = new Date(ev.StartDateTime);
                return localDate.getDay() === dayMap[this.selectedDay];
            })
            .map(ev => {
                const start = new Date(ev.StartDateTime);
                const end = new Date(ev.EndDateTime);
                return {
                    ...ev,
                    timeRange: `${this.formatTime(start)} ~ ${this.formatTime(end)}`,
                    ownerName: ev.Owner?.Name ?? ''
                };
            });
    }

    formatTime(dateObj) {
        return dateObj.toLocaleTimeString('ko-KR', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });
    }
}