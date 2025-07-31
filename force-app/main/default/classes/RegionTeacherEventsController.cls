public with sharing class RegionTeacherEventsController {
    @AuraEnabled(cacheable=true)
    public static List<Event> getRegionTeacherEvents() {
        Id currentUserId = UserInfo.getUserId();

        // 현재 로그인 유저의 Region 정보 조회
        User currentUser = [
            SELECT Region_Zone__c
            FROM User
            WHERE Id = :currentUserId
            LIMIT 1
        ];

        if (currentUser.Region_Zone__c == null) {
            return new List<Event>();
        }

        // 동일한 Region + 방문교사 Role 유저들의 Id
        List<User> teachers = [
            SELECT Id
            FROM User
            WHERE Region_Zone__c = :currentUser.Region_Zone__c
              AND UserRole.Name = '방문교사'
        ];

        if (teachers.isEmpty()) return new List<Event>();

        // 📅 월~금 일정 조회
        Date today = Date.today();
        Integer dayOfWeek = today.toStartOfWeek().daysBetween(today); // 월=0 ~ 일=6
        Date monday = today.addDays(-1 * dayOfWeek);
        Date friday = monday.addDays(4);

        return [
            SELECT Id, Subject, StartDateTime, EndDateTime,
                   Owner.Name   // ✅ 담당 교사 이름 포함
            FROM Event
            WHERE OwnerId IN :teachers
              AND StartDateTime >= :monday
              AND StartDateTime <= :friday
            ORDER BY StartDateTime ASC
        ];
    }
}