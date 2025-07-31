public with sharing class GetChildProductSummary {
    public class Input {
        @InvocableVariable(label='AccountId')
        public Id accountId;
    }

    public class Output {
        @InvocableVariable(label='Child Summary List')
        public String summaryJson;
    }

    @InvocableMethod(label='Get Child Product Summary')
    public static List<Output> getSummary(List<Input> inputs) {
        List<Output> results = new List<Output>();
        if (inputs.isEmpty()) return results;

        Id accountId = inputs[0].accountId;

        List<Contact> contacts = [
            SELECT Id, Name,
                (SELECT Id, ProductId__r.Name
                 FROM Subscriptions__r
                 ORDER BY StartDate__c DESC LIMIT 1)
            FROM Contact
            WHERE AccountId = :accountId
        ];

        Set<Id> productIds = new Set<Id>();
        Map<Id, String> productIdToName = new Map<Id, String>();

        for (Contact c : contacts) {
            if (!c.Subscriptions__r.isEmpty()) {
                Subscription__c sub = c.Subscriptions__r[0];
                if (sub.ProductId__c != null) {
                    productIds.add(sub.ProductId__c);
                    productIdToName.put(sub.ProductId__c, sub.ProductId__r.Name);
                }
            }
        }

        Map<Id, List<String>> productToCurriculums = new Map<Id, List<String>>();
        for (Curriculum__c curri : [
            SELECT Id, Name, CurriProduct__c
            FROM Curriculum__c
            WHERE CurriProduct__c IN :productIds
        ]) {
            if (!productToCurriculums.containsKey(curri.CurriProduct__c)) {
                productToCurriculums.put(curri.CurriProduct__c, new List<String>());
            }
            productToCurriculums.get(curri.CurriProduct__c).add(curri.Name);
        }

        List<Map<String, Object>> summaries = new List<Map<String, Object>>();
        for (Contact c : contacts) {
            String product = '없음';
            List<String> curris = new List<String>();

            if (!c.Subscriptions__r.isEmpty()) {
                Subscription__c sub = c.Subscriptions__r[0];
                Id pid = sub.ProductId__c;
                if (pid != null) {
                    product = productIdToName.get(pid);
                    curris = productToCurriculums.containsKey(pid)
                        ? productToCurriculums.get(pid)
                        : new List<String>();
                }
            }

            summaries.add(new Map<String, Object>{
                'name' => c.Name,
                'product' => product,
                'curriculums' => curris
            });
        }

        Output o = new Output();
        o.summaryJson = JSON.serialize(summaries);
        results.add(o);
        return results;
    }
}