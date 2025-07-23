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
    }

    @InvocableMethod(label='Get Event Details')
    public static List<Output> getDetails(List<Input> inputs) {
        List<Output> results = new List<Output>();

        if (inputs == null || inputs.isEmpty()) {
            return results;
        }

        Id eventId = inputs[0].eventId;

        Event evt = [
            SELECT StartDateTime, EndDateTime, Subject
            FROM Event
            WHERE Id = :eventId
            LIMIT 1
        ];

        Output result = new Output();
        result.startDateTime = evt.StartDateTime;
        result.endDateTime = evt.EndDateTime;
        result.subject = evt.Subject;

        results.add(result);
        return results;
    }
}
