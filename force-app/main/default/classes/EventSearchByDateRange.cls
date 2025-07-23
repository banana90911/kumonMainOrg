public with sharing class EventSearchByDateRange {
    
    public class Input {
        @InvocableVariable(required=true)
        public Date startDate;

        @InvocableVariable(required=true)
        public Date endDate;
    }

    public class Output {
        @InvocableVariable
        public Datetime startDateTime;

        @InvocableVariable
        public Datetime endDateTime;

        @InvocableVariable
        public String subject;
    }

    @InvocableMethod(label='Search Events By Date Range')
    public static List<List<Output>> searchEvents(List<Input> inputList) {
        List<Output> results = new List<Output>();

        if (inputList == null || inputList.isEmpty()) {
            return new List<List<Output>> { results };
        }

        Input criteria = inputList[0];

        List<Event> events = [
            SELECT StartDateTime, EndDateTime, Subject
            FROM Event
            WHERE StartDateTime >= :criteria.startDate
              AND EndDateTime <= :criteria.endDate
            ORDER BY StartDateTime ASC
        ];

        for (Event evt : events) {
            Output record = new Output();
            record.startDateTime = evt.StartDateTime;
            record.endDateTime = evt.EndDateTime;
            record.subject = evt.Subject;
            results.add(record);
        }

        return new List<List<Output>> { results };
    }
}
