import { LightningElement, track, wire } from 'lwc';
import getWeekEvents from '@salesforce/apex/EventFetcher.getWeekEvents';

export default class WeekdayEventViewer extends LightningElement {
    @track events = [];
    @track selectedDay = '월';

    // 📅 이번 주 월~금 날짜 + 라벨 계산
    get weekdays() {
        const today = new Date();
        const currentDay = today.getDay(); // 일=0 ~ 토=6
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
                value: dayNames[(i + 1) % 7], // "월", "화", ...
                dateObj: date
            });
        }
        return result;
    }

    // 요일 버튼 클래스 설정
    get decoratedWeekdays() {
        return this.weekdays.map(day => ({
            ...day,
            className: this.selectedDay === day.value ? 'day-button selected' : 'day-button'
        }));
    }

    // Apex에서 로그인 사용자 기준 이벤트 가져오기
    @wire(getWeekEvents)
    wiredEvents({ data, error }) {
        if (data) {
            this.events = data;
            console.log('✅ [Apex] 불러온 이벤트:', data);
        } else if (error) {
            console.error('❌ Event 로딩 오류:', error);
        }
    }

    // 요일 클릭 시 선택 변경
    handleDayClick(event) {
        const value = event.currentTarget.dataset.value;
        this.selectedDay = value;
    }

    // 선택된 요일의 이벤트만 필터링하여 시간 포맷 포함
    get formattedEvents() {
        const dayMap = { '일': 0, '월': 1, '화': 2, '수': 3, '목': 4, '금': 5, '토': 6 };

        return this.events
            .filter(ev => {
                const localDate = new Date(ev.StartDateTime); // 🔥 브라우저가 자동 KST로 변환
                const day = localDate.getDay(); // 일=0 ~ 토=6
                return day === dayMap[this.selectedDay];
            })
            .map(ev => {
                const start = new Date(ev.StartDateTime);
                const end = new Date(ev.EndDateTime);
                return {
                    ...ev,
                    timeRange: `${this.formatTime(start)} ~ ${this.formatTime(end)}`
                };
            });
    }

    // HH:mm 포맷 (24시간제)
    formatTime(dateObj) {
        return dateObj.toLocaleTimeString('ko-KR', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });
    }
}