public with sharing class AcceptedLeadController {
    @AuraEnabled(cacheable=true)
    public static List<AcceptedLeadWrapper> getAcceptedLeads() {
        List<Task> acceptedTasks = [
            SELECT Id, WhoId
            FROM Task
            WHERE OwnerId = :UserInfo.getUserId()
              AND Status = '수락됨'
              AND WhoId != null
              AND Who.Type = 'Lead'
        ];
        
        Set<Id> leadIds = new Set<Id>();
        for (Task t : acceptedTasks) {
            leadIds.add(t.WhoId);
        }

        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, Company, LastName, ChildBirthDate1__c, InterestedSubject__c, Street__c, Phone
            FROM Lead
            WHERE Id IN :leadIds
        ]);

        List<AcceptedLeadWrapper> results = new List<AcceptedLeadWrapper>();
        for (Task t : acceptedTasks) {
            Lead l = leadMap.get(t.WhoId);
            if (l != null) {
                results.add(new AcceptedLeadWrapper(
                    t.Id, l.Id, l.Company, l.LastName, l.ChildBirthDate1__c,
                    l.InterestedSubject__c, l.Street__c, l.Phone
                ));
            }
        }

        return results;
    }

    public class AcceptedLeadWrapper {
        @AuraEnabled public Id taskId;
        @AuraEnabled public Id leadId;
        @AuraEnabled public String parentName;
        @AuraEnabled public String childName;
        @AuraEnabled public String childBirthdate;
        @AuraEnabled public String subject;
        @AuraEnabled public String address;
        @AuraEnabled public String phone;

        public AcceptedLeadWrapper(
            Id taskId, Id leadId, String parentName, String childName,
            String childBirthdate, String subject, String address, String phone
        ) {
            this.taskId = taskId;
            this.leadId = leadId;
            this.parentName = parentName;
            this.childName = childName;
            this.childBirthdate = childBirthdate;
            this.subject = subject;
            this.address = address;
            this.phone = phone;
        }
    }
}