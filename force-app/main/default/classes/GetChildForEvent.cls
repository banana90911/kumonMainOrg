public with sharing class GetChildForEvent {

    public class Input {
        @InvocableVariable(required=true)
        public Id eventId;
    }

    public class Output {
        @InvocableVariable
        public Id contactId;

        @InvocableVariable
        public String name;

        @InvocableVariable
        public Date birthDate;

        @InvocableVariable
        public String phone;

        @InvocableVariable
        public Date visitDate;
    }

    @InvocableMethod(label='Get Child (Contact) from Event')
    public static List<Output> getChild(List<Input> inputs) {
        List<Output> results = new List<Output>();

        if (inputs == null || inputs.isEmpty()) return results;

        Id eventId = inputs[0].eventId;

        List<Event> events = [
            SELECT Id, WhoId
            FROM Event
            WHERE Id = :eventId
            LIMIT 1
        ];

        if (!events.isEmpty() && events[0].WhoId != null && String.valueOf(events[0].WhoId).startsWith('003')) {
            Id contactId = events[0].WhoId;

            Contact child = [
                SELECT Id, Name, BirthDate, Phone, VisitDate__c
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];

            Output o = new Output();
            o.contactId = child.Id;
            o.name = child.Name;
            o.birthDate = child.BirthDate;
            o.phone = child.Phone;
            o.visitDate = child.VisitDate__c;
            results.add(o);
        }

        return results;
    }
}