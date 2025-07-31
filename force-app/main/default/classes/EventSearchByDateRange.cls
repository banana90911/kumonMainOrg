public with sharing class EventSearchByDateRange {

    public class Input {
        @InvocableVariable(required=true)
        public Datetime referenceTime;
    }

    public class Output {
        @InvocableVariable
        public Id eventId;

        @InvocableVariable
        public String subject;

        @InvocableVariable
        public Datetime startDateTime;

        @InvocableVariable
        public Datetime endDateTime;

        @InvocableVariable
        public String label; // 사용자 응답용
    }

    @InvocableMethod(label='Search Today Events By Time')
    public static List<List<Output>> search(List<Input> inputList) {
        List<Output> results = new List<Output>();

        if (inputList == null || inputList.isEmpty()) return new List<List<Output>> { results };

        Datetime refTime = inputList[0].referenceTime;

        Date today = refTime.date();
        Datetime startOfDay = Datetime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        Datetime endOfDay = Datetime.newInstance(today, Time.newInstance(23, 59, 59, 999));

        List<Event> events = [
            SELECT Id, Subject, StartDateTime, EndDateTime
            FROM Event
            WHERE StartDateTime >= :refTime
              AND StartDateTime <= :endOfDay
            ORDER BY StartDateTime ASC
        ];

        for (Event evt : events) {
            Output o = new Output();
            o.eventId = evt.Id;
            o.subject = evt.Subject;
            o.startDateTime = evt.StartDateTime;
            o.endDateTime = evt.EndDateTime;
            o.label = evt.StartDateTime.format('a h:mm', 'ko_KR') + ' ~ ' +
                      evt.EndDateTime.format('a h:mm', 'ko_KR') + ': ' + evt.Subject;
            results.add(o);
        }

        return new List<List<Output>> { results };
    }
}