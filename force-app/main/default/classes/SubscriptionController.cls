public with sharing class SubscriptionController {
    @AuraEnabled(cacheable=true)
    public static List<Subscription__c> getSubscriptions(Id contactId) {
        return [
            SELECT Id, Term__c, StartDate__c, EndDate__c,
                   ProductId__r.Name
            FROM Subscription__c
            WHERE ContactId__c = :contactId
            ORDER BY StartDate__c DESC
        ];
    }
}