public with sharing class ContactContractController {
    @AuraEnabled(cacheable=true)
    public static List<Contract> getContractsByContact(Id contactId) {
        Contact c = [
            SELECT Id, AccountId, FirstName, LastName
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];
        
        if (c.AccountId == null) return new List<Contract>();

        return [
            SELECT Id, StartDate, Original_Total_Amount__c, Discount_Rate__c, Total_Price__c,
                   Campaign__r.Name
            FROM Contract
            WHERE AccountId = :c.AccountId
            ORDER BY StartDate DESC
        ];
    }
}