public with sharing class GetEventDetails {

    public class Input {
        @InvocableVariable(required=true)
        public Id eventId;
    }

    public class Output {
        @InvocableVariable
        public Datetime startDateTime;

        @InvocableVariable
        public Datetime endDateTime;

        @InvocableVariable
        public String subject;

        @InvocableVariable
        public String label;
    }

    @InvocableMethod(label='Get Event Details')
    public static List<Output> getDetails(List<Input> inputs) {
        List<Output> results = new List<Output>();

        if (inputs == null || inputs.isEmpty()) return results;

        Id eventId = inputs[0].eventId;

        List<Event> evtList = [
            SELECT StartDateTime, EndDateTime, Subject
            FROM Event
            WHERE Id = :eventId
            LIMIT 1
        ];

        if (!evtList.isEmpty()) {
            Event evt = evtList[0];
            Output o = new Output();
            o.startDateTime = evt.StartDateTime;
            o.endDateTime = evt.EndDateTime;
            o.subject = evt.Subject;

            String startStr = evt.StartDateTime.format('yyyy년 M월 d일 a h:mm', 'ko_KR');
            String endStr = evt.EndDateTime.format('a h:mm', 'ko_KR');
            o.label = startStr + ' ~ ' + endStr + ': ' + evt.Subject;

            results.add(o);
        }

        return results;
    }
}