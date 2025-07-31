import { LightningElement, api, track, wire} from 'lwc';
import createEvents from '@salesforce/apex/LearningScheduleController.createEvents';
import getSubscriptions from '@salesforce/apex/LearningScheduleController.getSubscriptions';

export default class LearningScheduleForm extends LightningElement {
  @api recordId; // 현재 Contact(아동)의 레코드 ID

  // UI에서 사용될 상태 변수들
  @track childName = '아동';
  @track selectedProductId;       // 선택한 과정(Product2)의 ID
  @track selectedProductName;     // UI에 표시할 과정명
  @track selectedWeekday;         // 선택한 요일 ("월" ~ "금")
  @track selectedStartTime;       // 선택한 수업 시작 시간 ("HH:mm")
  @track selectedEndTime;         // 선택한 수업 종료 시간 (자동 설정 또는 수동 변경)
  @track repeatUntil;             // 반복 종료일 (선택 사항)

  @track productOptions = [];     // 구독내역 기반 과정명 옵션

  // 요일 콤보박스 옵션
  weekdayOptions = [
    { label: '월', value: '월' },
    { label: '화', value: '화' },
    { label: '수', value: '수' },
    { label: '목', value: '목' },
    { label: '금', value: '금' }
  ];

  // 수업 시간 옵션: 08:00 ~ 22:00 까지 30분 간격 생성
  timeSlotOptions = this.generateTimeSlots();

  // Apex에서 구독내역 불러오기
  @wire(getSubscriptions, { contactId: '$recordId' })
  wiredSubscriptions({ error, data }) {
    if (data) {
      this.productOptions = data.map(item => ({
        label: item.ProductName__c,
        value: item.ProductId__c
      }));
    } else if (error) {
      console.error('Subscription 로딩 오류:', error);
    }
  }

  // 30분 간격 시간 옵션 생성 함수
  generateTimeSlots() {
    const slots = [];
    for (let h = 8; h <= 22; h++) {
      slots.push({ label: `${h.toString().padStart(2, '0')}:00`, value: `${h.toString().padStart(2, '0')}:00` });
      slots.push({ label: `${h.toString().padStart(2, '0')}:30`, value: `${h.toString().padStart(2, '0')}:30` });
    }
    return slots;
  }

  // 과정명 선택 시 처리
  handleProductChange(event) {
    this.selectedProductId = event.detail.value;
    this.selectedProductName = this.productOptions.find(opt => opt.value === this.selectedProductId)?.label;
  }

  // 요일 선택 시 처리
  handleWeekdayChange(event) {
    this.selectedWeekday = event.detail.value;
  }

  // 시작 시간 선택 시 종료 시간 자동 설정
  handleStartTimeChange(event) {
    this.selectedStartTime = event.detail.value;
    this.autoSetEndTime();
  }

  // 종료 시간 수동 변경 시 처리
  handleEndTimeChange(event) {
    this.selectedEndTime = event.detail.value;
  }

  // 시작 시간 + 30분 → 종료 시간 자동 계산
  autoSetEndTime() {
    if (this.selectedStartTime) {
      const [hour, minute] = this.selectedStartTime.split(':').map(Number);
      let endMin = minute + 30;
      let endHour = hour;
      if (endMin >= 60) {
        endHour += 1;
        endMin -= 60;
      }
      this.selectedEndTime = `${endHour.toString().padStart(2, '0')}:${endMin.toString().padStart(2, '0')}`;
    }
  }

  // 반복 종료일 변경 처리
  handleRepeatUntilChange(event) {
    this.repeatUntil = event.detail.value;
  }

  // 일정 생성 버튼 클릭 → Apex 호출
  async handleCreateSchedule() {
    if (!this.recordId || !this.selectedProductId || !this.selectedWeekday || !this.selectedStartTime || !this.selectedEndTime) {
      alert('모든 필드를 입력해 주세요.');
      return;
    }

    // 시작 시간 문자열을 Date 객체로 변환 (Apex Datetime 매핑용)
    const now = new Date();
    const [h, m] = this.selectedStartTime.split(':');
    const startTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), h, m);

    try {
      await createEvents({
        contactId: this.recordId,
        productId: this.selectedProductId,
        weekday: this.selectedWeekday,
        startTime,
        durationMinutes: 30,
        repeatUntil: this.repeatUntil || null
      });
      alert('일정이 성공적으로 생성되었습니다.');
    } catch (e) {
      console.error(e);
      alert('일정 생성 중 오류가 발생했습니다.');
    }
  }
}