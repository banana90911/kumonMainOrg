public with sharing class EventFetcher {
    @AuraEnabled(cacheable=true)
    public static List<Event> getWeekEvents() {
        Date today = Date.today();

        // ✅ 'u'를 써야 요일 숫자 (월=1 ~ 일=7) 정상 동작
        DateTime todayDateTime = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        Integer dow = Integer.valueOf(todayDateTime.format('u', 'en_US'));

        Integer offsetToMonday = dow - 1;
        Date monday = today.addDays(-offsetToMonday);
        Date friday = monday.addDays(4);

        return [
            SELECT Id, Subject, StartDateTime, EndDateTime
            FROM Event
            WHERE StartDateTime >= :monday AND StartDateTime < :friday.addDays(1)
            AND OwnerId = :UserInfo.getUserId()
            ORDER BY StartDateTime ASC
        ];
    }
}