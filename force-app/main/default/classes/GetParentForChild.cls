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

        List<Contact> contacts = [
            SELECT Account.Id, Account.Name, Account.Phone, Account.Email__c,
                   Account.BillingCity, Account.BillingState, Account.BillingStreet
            FROM Contact
            WHERE Id = :contactId AND AccountId != null
            LIMIT 1
        ];

        if (!contacts.isEmpty()) {
            Account parent = contacts[0].Account;

            Output o = new Output();
            o.name = parent.Name;
            o.phone = parent.Phone;
            o.email = parent.Email__c;
            o.city = parent.BillingCity;
            o.state = parent.BillingState;
            o.street = parent.BillingStreet;
            results.add(o);
        }

        return results;
    }
}