public class SingleContactFlowWrapper {

    public class ContactInput {
        @InvocableVariable(label='Contact Id')
        public Id contactId;
    }

    @InvocableMethod(label='Contact 기준 계약 생성')
    public static void runForOneContact(List<ContactInput> inputs) {
        for (ContactInput input : inputs) {
            if (input.contactId != null) {
                SingleContactContractGenerator.createContractForContact(input.contactId);
            }
        }
    }
}