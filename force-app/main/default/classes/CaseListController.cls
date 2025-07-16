public with sharing class CaseListController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesByAccount(Id accountId) {
        return [
            SELECT Id, Subject, Type, Description
            FROM Case
            WHERE AccountId__c = :accountId
            ORDER BY CreatedDate DESC
        ];
    }
}