public with sharing class UserCaseController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getMyCases() {
        return [
            SELECT Id, Subject, Type, AccountName__c, Description
            FROM Case
            WHERE OwnerId = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
    }
}