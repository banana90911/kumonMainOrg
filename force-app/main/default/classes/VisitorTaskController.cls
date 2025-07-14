public with sharing class VisitorTaskController {

    // 방문교사의 미처리 Task 목록 조회 + 관련 리드 정보 포함
    @AuraEnabled(cacheable=true)
    public static List<VisitorTaskWrapper> getMyPendingTasks() {
        // 대기중 상태이고 생성된지 2일이내인 Task
        List<Task> taskList = [
            SELECT Id, WhoId, Status
            FROM Task
            WHERE OwnerId = :UserInfo.getUserId()
              AND Status = '대기중'
              AND CreatedDate = LAST_N_DAYS:2
        ];

        // Task에서 잠재고객 ID 추출
        Set<Id> leadIds = new Set<Id>();
        for (Task t : taskList) {
            if (t.WhoId != null) {
                leadIds.add(t.WhoId);
            }
        }
        
        // 잠재고객의 학부모, 자녀 조회
        Map<Id, Lead> leadMap = new Map<Id, Lead>(
            [SELECT Id, Company, LastName FROM Lead WHERE Id IN :leadIds]
        );

        // Task + Lead 정보를 VisitorTaskWrapper로 포장해 리턴
        List<VisitorTaskWrapper> results = new List<VisitorTaskWrapper>();
        for (Task t : taskList) {
            Lead l = leadMap.get(t.WhoId);
            results.add(new VisitorTaskWrapper(
                t.Id,
                l != null ? l.Id : null,
                l != null ? l.Company : '',
                l != null ? l.LastName : ''
            ));
        }

        return results;
    }

    // 방문교사가 Task 수락
    @AuraEnabled
    public static void acceptTask(Id taskId) {
        Task task = [SELECT Id, WhoId FROM Task WHERE Id = :taskId LIMIT 1];
        Id leadId = task.WhoId;

        // 리드 담당자 설정
        User currentUser = [SELECT Id, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE Id = :leadId];
        lead.Teacher__c = currentUser.LastName;
        update lead;

        // 본인 Task -> 수락됨
        task.Status = '수락됨';
        update task;

        // 다른 Task 상태 업데이트: 놓침
        List<Task> otherTasks = [
            SELECT Id FROM Task
            WHERE WhoId = :leadId
              AND Id != :task.Id
              AND Status = '대기중'
        ];
        for (Task t : otherTasks) {
            t.Status = '놓침';
        }
        update otherTasks;
    }

    // 방문교사가 Task 거절
    @AuraEnabled
    public static void rejectTask(Id taskId) {
        Task t = [SELECT Id FROM Task WHERE Id = :taskId];
        t.Status = '거절됨';
        update t;
    }

    // LWC에 전달할 Task+Lead 정보 묶음
    public class VisitorTaskWrapper {
        @AuraEnabled public Id taskId;
        @AuraEnabled public Id leadId;
        @AuraEnabled public String parentName;
        @AuraEnabled public String childName;

        public VisitorTaskWrapper(Id taskId, Id leadId, String parentName, String childName) {
            this.taskId = taskId;
            this.leadId = leadId;
            this.parentName = parentName;
            this.childName = childName;
        }
    }
}