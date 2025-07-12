public with sharing class VisitorTaskController {

    // 방문교사의 미처리 Task 목록 조회 + 관련 리드 정보 포함
    @AuraEnabled(cacheable=true)
    public static List<VisitorTaskWrapper> getMyPendingTasks() {
        List<Task> taskList = [
            SELECT Id, WhoId, Status
            FROM Task
            WHERE OwnerId = :UserInfo.getUserId()
              AND Status = '대기중'
              AND CreatedDate = LAST_N_DAYS:2
        ];

        Set<Id> leadIds = new Set<Id>();
        for (Task t : taskList) {
            if (t.WhoId != null) {
                leadIds.add(t.WhoId);
            }
        }

        Map<Id, Lead> leadMap = new Map<Id, Lead>(
            [SELECT Id, Company, LastName FROM Lead WHERE Id IN :leadIds]
        );

        List<VisitorTaskWrapper> results = new List<VisitorTaskWrapper>();

        for (Task t : taskList) {
            Lead l = leadMap.get(t.WhoId);
            results.add(new VisitorTaskWrapper(
                t.Id,
                t.Status,
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
        Lead lead = [SELECT Id FROM Lead WHERE Id = :leadId];
        lead.Teacher__c = UserInfo.getUserId(); // 필드가 Lookup(User)일 경우
        update lead;

        // 본인 Task → 수락됨
        task.Status = '수락됨';
        update task;

        // 다른 Task → 수락불가
        List<Task> otherTasks = [
            SELECT Id FROM Task
            WHERE WhoId = :leadId
              AND Id != :task.Id
              AND Status = '대기중'
        ];
        for (Task t : otherTasks) {
            t.Status = '수락불가';
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
        @AuraEnabled public String status;
        @AuraEnabled public String parentName;
        @AuraEnabled public String childName;

        public VisitorTaskWrapper(Id taskId, String status, String parentName, String childName) {
            this.taskId = taskId;
            this.status = status;
            this.parentName = parentName;
            this.childName = childName;
        }
    }
}
