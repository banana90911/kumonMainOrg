public with sharing class SummarizeEvent {

    public class Input {
        @InvocableVariable(required=true)
        public Id eventId;
    }

    public class Output {
        @InvocableVariable
        public String summary;
    }

    @InvocableMethod(label='Summarize Event Info')
    public static List<Output> summarize(List<Input> inputs) {
        List<Output> results = new List<Output>();

        if (inputs == null || inputs.isEmpty()) return results;

        Id eventId = inputs[0].eventId;

        Event evt = [
            SELECT Subject, StartDateTime, EndDateTime
            FROM Event
            WHERE Id = :eventId
            LIMIT 1
        ];

        String startStr = evt.StartDateTime.format('yyyy년 M월 d일 a h:mm', 'ko_KR');
        String endStr = evt.EndDateTime.format('a h:mm', 'ko_KR');

        Output o = new Output();
        o.summary = '일정 "' + evt.Subject + '"은 ' + startStr + '부터 ' + endStr + '까지 예정되어 있습니다.';
        results.add(o);

        return results;
    }
}