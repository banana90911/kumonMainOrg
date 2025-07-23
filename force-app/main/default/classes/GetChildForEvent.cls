public with sharing class GetChildForEvent {
    
    public class Input {
        @InvocableVariable(required=true)
        public Id eventId;
    }

    public class Output {
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

        if (inputs == null || inputs.isEmpty()) {
            return results;
        }

        Id eventId = inputs[0].eventId;

        Event evt = [
            SELECT WhoId
            FROM Event
            WHERE Id = :eventId
            LIMIT 1
        ];

        if (evt.WhoId == null) {
            return results;
        }

        Contact child = [
            SELECT Name, Birthdate, Phone, VisitDate__c
            FROM Contact
            WHERE Id = :evt.WhoId
            LIMIT 1
        ];

        Output out = new Output();
        out.name = child.Name;
        out.birthDate = child.Birthdate;
        out.phone = child.Phone;
        out.visitDate = child.VisitDate__c;

        results.add(out);
        return results;
    }
}
