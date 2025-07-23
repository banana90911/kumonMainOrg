public with sharing class GetParentForChild {

    public class Input {
        @InvocableVariable(required=true)
        public Id contactId;
    }

    public class Output {
        @InvocableVariable
        public String name;

        @InvocableVariable
        public String phone;

        @InvocableVariable
        public String email;

        @InvocableVariable
        public String city;

        @InvocableVariable
        public String state;

        @InvocableVariable
        public String street;
    }

    @InvocableMethod(label='Get Parent Account from Child Contact')
    public static List<Output> getParent(List<Input> inputs) {
        List<Output> results = new List<Output>();

        if (inputs == null || inputs.isEmpty()) return results;

        Id contactId = inputs[0].contactId;

        Contact child = [
            SELECT AccountId
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        if (child.AccountId == null) return results;

        Account acc = [
            SELECT Name, Phone, Email__c, CityName__c, State__c, Street__c
            FROM Account
            WHERE Id = :child.AccountId
            LIMIT 1
        ];

        Output out = new Output();
        out.name = acc.Name;
        out.phone = acc.Phone;
        out.email = acc.Email__c;
        out.city = acc.CityName__c;
        out.state = acc.State__c;
        out.street = acc.Street__c;

        results.add(out);
        return results;
    }
}
