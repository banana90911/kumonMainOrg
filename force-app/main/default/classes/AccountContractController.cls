public with sharing class AccountContractController {

    @AuraEnabled(cacheable=true)
    public static List<Contract> getContractsByAccount(Id accountId) {
        if (accountId == null) return new List<Contract>();

        return [
            SELECT Id,
                   StartDate,
                   Original_Total_Amount__c,
                   Total_Price__c,
                   Discount_Rate__c,
                   Campaign__r.Name
            FROM Contract
            WHERE AccountId = :accountId
            ORDER BY StartDate DESC
        ];
    }
}