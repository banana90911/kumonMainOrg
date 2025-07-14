trigger LeadTriggerAfterUpdate on Lead (after update) {
    // 방문교사가 Task 수락했을 때, 
    // >>> 다른 교사들에게 배정된 같은 리드에 대한 Task들 선별
    // >>> 상태를 놓침으로 업데이트 하는 트리거.

    // Task 레코드들을 모아 한 번에 update하기 위해 리스트 사용
    List<Task> tasksToUpdate = new List<Task>();

    // for each Trigger.new (이번에 업데이트된 최신 잠재고객 레코드들)
    for (Lead l : Trigger.new) {
        // Trigger.oldMap: 업데이트 전
        Lead old = Trigger.oldMap.get(l.Id);
        
        // 담당자 없었음 && 지금은 있음
        if (old.Teacher__c == null && l.Teacher__c != null) {
            // 대기중 상태인 Task 모두 찾음
            List<Task> relatedTasks = [
                SELECT Id, Status
                FROM Task
                WHERE WhoId = :l.Id
                  AND Status = '대기중'
            ];

            // 해당 Task의 상태를 놓침으로 업데이트 리스트에 추가
            for (Task t : relatedTasks) {
                t.Status = '놓침';
            }
            tasksToUpdate.addAll(relatedTasks);
        }
    }

    // 한 번에 업데이트
    if (!tasksToUpdate.isEmpty()) {
        update tasksToUpdate;
    }
}