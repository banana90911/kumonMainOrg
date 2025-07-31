public with sharing class LearningScheduleController {

    /**
     * 아동의 구독내역 중 선택된 과정에 대해 반복 스케줄(Event)을 생성합니다.
     * 반복은 지정한 요일 기준으로, 구독 기간 내 또는 반복 종료일까지 생성됩니다.
     *
     * @param contactId 아동 ID (LWC의 recordId)
     * @param productId 과정명(Product2)의 ID
     * @param weekday 반복 요일 ("월", "화", "수", "목", "금")
     * @param startTime 수업 시작 시각 (시간만 사용)
     * @param durationMinutes 수업 시간 (기본 30분)
     * @param repeatUntil 반복 종료일 (null이면 구독 종료일까지만 반복)
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSubscriptions(String contactId) {
        List<Subscription__c> subs = [
            SELECT ProductId__c, ProductId__r.Name
            FROM Subscription__c
            WHERE ContactId__c = :contactId
        ];

        List<Map<String, String>> result = new List<Map<String, String>>();
        for (Subscription__c s : subs) {
            result.add(new Map<String, String>{
                'ProductId__c' => s.ProductId__c,
                'ProductName__c' => s.ProductId__r.Name
            });
        }
        return result;
    }

    @AuraEnabled
    public static void createEvents(
        String contactId,
        String productId,
        String weekday,
        Datetime startTime,
        Integer durationMinutes,
        Date repeatUntil
    ) {
        // 1. Contact 정보 조회 (담당 교사 ID 포함)
        Contact child = [
            SELECT Id, TeacherId__c
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        // 2. Product 정보 조회 (과정 이름 가져오기)
        Product2 course = [
            SELECT Name
            FROM Product2
            WHERE Id = :productId
            LIMIT 1
        ];

        // 3. 구독 기간 가져오기
        Subscription__c subscription = [
            SELECT StartDate__c, EndDate__c
            FROM Subscription__c
            WHERE ContactId__c = :contactId
              AND ProductId__c = :productId
            LIMIT 1
        ];

        Date startDate = subscription.StartDate__c;
        Date endDate = subscription.EndDate__c;
        Date untilDate = (repeatUntil != null) ? repeatUntil : endDate;

        // 4. 생성할 Event 목록
        List<Event> eventsToInsert = new List<Event>();

    // 요일 매핑 선언 (루프 밖에 한 번만)
    Map<String, String> weekdayMap = new Map<String, String>{
        '1' => '월', '2' => '화', '3' => '수', '4' => '목', '5' => '금', '6' => '토', '7' => '일'
    };

    // 5. 날짜 반복: 시작일 ~ 종료일까지
    for (Date d = startDate; d <= untilDate; d = d.addDays(1)) {
        // Date → Datetime 변환
        Datetime dt = Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        String weekdayCode = dt.format('u'); // 1 = Monday, 7 = Sunday
        String currentWeekday = weekdayMap.get(weekdayCode);

        if (currentWeekday == weekday) {
            // 시작/종료 시간 계산
            Datetime eventStart = Datetime.newInstance(d, startTime.time());
            Datetime eventEnd = eventStart.addMinutes(durationMinutes);

            eventsToInsert.add(new Event(
                Subject = course.Name,
                StartDateTime = eventStart,
                EndDateTime = eventEnd,
                WhoId = child.Id,
                OwnerId = child.TeacherId__c
            ));
        }
    }

        // 6. Event 일괄 생성
        if (!eventsToInsert.isEmpty()) {
            insert eventsToInsert;
        }
    }
}