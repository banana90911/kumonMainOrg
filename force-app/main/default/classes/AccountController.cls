public with sharing class AccountController {
    public class AccountWrapper {
        @AuraEnabled public Account account;
        @AuraEnabled public String childName;
        @AuraEnabled public Id childId;
    }

    @AuraEnabled(cacheable=true)
    public static AccountWrapper getAccountInfo(Id accountId) {
        AccountWrapper result = new AccountWrapper();

        result.account = [
            SELECT Id, Name, Phone, Email__c, CityName__c, State__c, Street__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        List<Contact> children = [
            SELECT Id, ChildName__c
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        if (!children.isEmpty()) {
            result.childName = children[0].ChildName__c;
            result.childId = children[0].Id;
        }

        return result;
    }
}