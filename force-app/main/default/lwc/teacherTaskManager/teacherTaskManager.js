import { LightningElement, track } from 'lwc';
import getMyPendingTasks from '@salesforce/apex/VisitorTaskController.getMyPendingTasks';
import acceptTask from '@salesforce/apex/VisitorTaskController.acceptTask';
import rejectTask from '@salesforce/apex/VisitorTaskController.rejectTask';

export default class VisitorTaskManager extends LightningElement {
    @track tasks = [];

    connectedCallback() {
        this.loadTasks();
    }

    loadTasks() {
        // 캐시 우회를 위해 더미 파라미터 추가
        const dummy = new Date().getTime().toString();
        getMyPendingTasks({ dummy })
            .then(result => {
                this.tasks = [...result]; // 강제 리렌더링
            })
            .catch(error => {
                console.error('Error loading tasks:', error);
            });
    }

    handleAccept(event) {
        const taskId = event.target.dataset.id;
        acceptTask({ taskId })
            .then(() => {
                this.loadTasks(); // 리렌더링을 위해 다시 불러오기
            })
            .catch(error => {
                console.error('Error accepting task:', error);
            });
    }

    handleReject(event) {
        const taskId = event.target.dataset.id;
        rejectTask({ taskId })
            .then(() => {
                this.loadTasks(); // 다시 목록 조회
            })
            .catch(error => {
                console.error('Error rejecting task:', error);
            });
    }
}
