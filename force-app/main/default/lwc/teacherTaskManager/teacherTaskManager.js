import { LightningElement, track } from 'lwc';
import getMyPendingTasks from '@salesforce/apex/VisitorTaskController.getMyPendingTasks';
import acceptTask from '@salesforce/apex/VisitorTaskController.acceptTask';
import rejectTask from '@salesforce/apex/VisitorTaskController.rejectTask';

export default class VisitorTaskManager extends LightningElement {
    @track tasks = [];
    
    // LWC가 DOM에 삽입될 때 자동 호출 || 컴포넌트가 표시되자마자 할당된 Task를 불러옴
    connectedCallback() {
        this.loadTasks();
    }

    loadTasks() {
        // 캐시 우회를 위해 더미 파라미터 추가
        const dummy = new Date().getTime().toString();
        getMyPendingTasks({ dummy })
            .then(result => {
                // 반환된 각 Task에 leadUrl이라는 필드를 추가하여 링크 생성
                this.tasks = result.map(task => ({ ...task, leadUrl: `/lightning/r/Lead/${task.leadId}/view` }));
            })
            .catch(error => {
                console.error('Error loading tasks:', error);
            });
    }

    handleAccept(event) {
        // 버튼에 연결된 taskId 추출
        const taskId = event.target.dataset.id;
        // Apex 메서드 acceptTask 호출
        acceptTask({ taskId })
            .then(() => {
                // 리렌더링을 위해 다시 불러오기
                this.loadTasks(); 
            })
            .catch(error => {
                console.error('Error accepting task:', error);
            });
    }

    handleReject(event) {
        const taskId = event.target.dataset.id;
        rejectTask({ taskId })
            .then(() => {
                // 거절 처리 후 화면 갱신
                this.loadTasks();
            })
            .catch(error => {
                console.error('Error rejecting task:', error);
            });
    }

    // 리드 상세페이지 URL 생성
    getLeadUrl(leadId) {
        return `/lightning/r/Lead/${leadId}/view`;
    }
}