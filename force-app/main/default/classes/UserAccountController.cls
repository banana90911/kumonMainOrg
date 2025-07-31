public with sharing class UserAccountController {
    public class AccountWithChildren {
        @AuraEnabled public Account account;
        @AuraEnabled public List<Contact> children;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountWithChildren> getMyAccountsWithChildren() {
        Id userId = UserInfo.getUserId();

        List<Account> accounts = [
            SELECT Id, Name, Phone, CityName__c, State__c, Street__c
            FROM Account
            WHERE OwnerId = :userId
        ];

        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        Map<Id, List<Contact>> accountIdToChildren = new Map<Id, List<Contact>>();
        for (Contact c : [
            SELECT Id, ChildName__c, Birthdate, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY Birthdate ASC
        ]) {
            if (!accountIdToChildren.containsKey(c.AccountId)) {
                accountIdToChildren.put(c.AccountId, new List<Contact>());
            }
            accountIdToChildren.get(c.AccountId).add(c);
        }

        List<AccountWithChildren> result = new List<AccountWithChildren>();
        for (Account acc : accounts) {
            AccountWithChildren wrap = new AccountWithChildren();
            wrap.account = acc;
            wrap.children = accountIdToChildren.get(acc.Id);
            result.add(wrap);
        }

        return result;
    }
}