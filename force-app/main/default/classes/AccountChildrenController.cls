public with sharing class AccountChildrenController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getChildren(Id accountId) {
        return [
            SELECT Id, ChildName__c, Birthdate
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY Birthdate ASC
        ];
    }
}