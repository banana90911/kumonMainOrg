public with sharing class ForceLeadConvertHandler {

    public class LeadConvertInput {
        @InvocableVariable(required=true)
        public Id leadId;

        @InvocableVariable(required=true)
        public Id accountId;

        @InvocableVariable(required=true)
        public Id contactId;  // Contact을 Flow에서 직접 지정
    }

    public class LeadConvertOutput {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Lead 전환 (ContactID 직접 지정)')
    public static List<LeadConvertOutput> convertLead(List<LeadConvertInput> inputs) {
        List<LeadConvertOutput> results = new List<LeadConvertOutput>();

        for (LeadConvertInput input : inputs) {
            LeadConvertOutput result = new LeadConvertOutput();

            try {
                Lead leadRecord = [
                    SELECT Id
                    FROM Lead
                    WHERE Id = :input.leadId
                    LIMIT 1
                ];

                Account acc = [
                    SELECT Id
                    FROM Account
                    WHERE Id = :input.accountId
                    LIMIT 1
                ];

                Contact con = [
                    SELECT Id
                    FROM Contact
                    WHERE Id = :input.contactId
                    LIMIT 1
                ];

                // LeadConvert 설정
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(leadRecord.Id);
                lc.setAccountId(acc.Id);
                lc.setContactId(con.Id);
                lc.setConvertedStatus('Closed - Converted');
                lc.setDoNotCreateOpportunity(true);

                Database.LeadConvertResult lcr = Database.convertLead(lc);
                result.success = lcr.isSuccess();
                result.message = lcr.isSuccess() ? 'Lead 전환 성공 (Contact 직접 지정)' : 'Lead 전환 실패';

            } catch (Exception e) {
                result.success = false;
                result.message = '오류 발생: ' + e.getMessage();
            }

            results.add(result);
        }

        return results;
    }
}