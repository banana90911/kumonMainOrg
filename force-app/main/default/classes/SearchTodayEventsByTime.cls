public with sharing class SearchTodayEventsByTime {

    public class Input {
        @InvocableVariable(required=true)
        public Datetime referenceTime;
    }

    public class Output {
        @InvocableVariable
        public String subject;

        @InvocableVariable
        public Datetime startDateTime;

        @InvocableVariable
        public Datetime endDateTime;
    }

    @InvocableMethod(label='Search Today Events By Time')
    public static List<Output> search(List<Input> inputs) {
        List<Output> results = new List<Output>();

        if (inputs == null || inputs.isEmpty()) return results;

        Datetime refTime = inputs[0].referenceTime;
        Date today = Date.today();

        List<Event> events = [
            SELECT Subject, StartDateTime, EndDateTime
            FROM Event
            WHERE DAY_ONLY(StartDateTime) = :today
              AND StartDateTime >= :refTime
            ORDER BY StartDateTime ASC
        ];

        for (Event evt : events) {
            Output o = new Output();
            o.subject = evt.Subject;
            o.startDateTime = evt.StartDateTime;
            o.endDateTime = evt.EndDateTime;
            results.add(o);
        }

        return results;
    }
}