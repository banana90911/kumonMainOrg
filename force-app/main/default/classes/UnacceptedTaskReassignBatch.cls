public class UnacceptedTaskReassignBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // 방문교사에게 배정된 지 하루가 지난 미수락 Task
        return Database.getQueryLocator([
            SELECT Id, WhoId, OwnerId, CreatedDate
            FROM Task
            WHERE Subject = '신규 잠재고객 대응'
              AND Status = '대기중'
              AND CreatedDate <= :System.now().addDays(-1)
              AND Owner.UserRole.Name = '방문교사'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Task> scope) {
        // related 잠재고객 조회
        Set<Id> leadIds = new Set<Id>();
        for (Task t : scope) {
            if (t.WhoId != null && String.valueOf(t.WhoId).startsWith('00Q')) {
                leadIds.add(t.WhoId);
            }
        }

        // 해당 잠재고객의 지역, 담당자 조회
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, State__c, Teacher__c
            FROM Lead
            WHERE Id IN :leadIds AND IsConverted = false
        ]);

        // 담당지역, 담당지역(시/도) 매핑
        Map<String, String> regionToParent = new Map<String, String>{
            '강남구' => '서울',
            '강동구' => '서울',
            '강북구' => '서울',
            '강서구' => '서울',
            '관악구' => '서울',
            '광진구' => '서울',
            '구로구' => '서울',
            '금천구' => '서울',
            '노원구' => '서울',
            '도봉구' => '서울',
            '동대문구' => '서울',
            '동작구' => '서울',
            '마포구' => '서울',
            '서대문구' => '서울',
            '서초구' => '서울',
            '성동구' => '서울',
            '성북구' => '서울',
            '송파구' => '서울',
            '양천구' => '서울',
            '영등포구' => '서울',
            '용산구' => '서울',
            '은평구' => '서울',
            '종로구' => '서울',
            '중구' => '서울',
            '중량구' => '서울'
            // 필요한 만큼 추가
        };

        // 담당지역(시/도) 지사 매핑
        Map<String, User> branchManagerMap = new Map<String, User>();
        List<User> managers = [
            SELECT Id, Region_Zone__c
            FROM User
            WHERE UserRole.Name = '지사'
              AND IsActive = true
        ];
        for (User u : managers) {
            branchManagerMap.put(u.Region_Zone__c, u);
        }

        List<Task> tasksToUpdate = new List<Task>();
        List<Lead> leadsToUpdate = new List<Lead>();

        for (Task t : scope) {
            Lead lead = leadMap.get(t.WhoId);
            if (lead == null || String.isBlank(lead.State__c)) continue;

            String parentRegion = regionToParent.get(lead.State__c);
            if (parentRegion == null) continue;

            User manager = branchManagerMap.get(parentRegion);
            if (manager == null) continue;

            // Task의 담당자, 잠재고객의 담당교사를 지사로 변경
            t.OwnerId = manager.Id;
            tasksToUpdate.add(t);

            lead.Teacher__c = manager.Name;
            leadsToUpdate.add(lead);
        }

        if (!tasksToUpdate.isEmpty()) update tasksToUpdate;
        if (!leadsToUpdate.isEmpty()) update leadsToUpdate;
    }

    public void finish(Database.BatchableContext bc) {}
}