//  UnacceptedTaskReassignBatch 배치 클래스를 매일 자동으로 실행되게 하는 스케줄러 클래스

// 외부에서 호출 가능해야 하므로 global
// Schedulable: 시스템이 지정된 시간에 자동으로 코드를 실행할 수 있게 해주는 인터페이스
global class UnacceptedTaskReassignScheduler implements Schedulable {
    // 예약된 시간이 되었을 때 실행됨
    global void execute(SchedulableContext sc) {
        // UnacceptedTaskReassignBatch 인스턴스를 생성
        UnacceptedTaskReassignBatch batch = new UnacceptedTaskReassignBatch();
        // 생성한 인스턴스를 Database.executeBatch()로 실행
        Database.executeBatch(batch);
    }
}

// Developer Console Debug->anonymous... 에서 아래 코드 실행
// String cronExp = '0 0 9 * * ?'; // 매일 오전 9시
// System.schedule('UnacceptedTaskReassignJob', cronExp, new UnacceptedTaskReassignScheduler());
// Setting의 Scheduled Jobs에서 확인 가능