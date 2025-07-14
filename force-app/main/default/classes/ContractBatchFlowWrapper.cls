public with sharing class ContractBatchFlowWrapper {
    @InvocableMethod(label='계약 생성 실행')
    public static void createContracts(List<Id> recordIds) {
        List<Contract> contractsToInsert = new List<Contract>();
        List<Subscription__c> allSubscriptionsToUpdate = new List<Subscription__c>();

        for (Id contactId : recordIds) {
            List<Subscription__c> subscriptions = [
                SELECT Id, Term__c, ProductId__c,
                       ProductId__r.MonthlyPrice__c, ProductId__r.Family,
                       StartDate__c, EndDate__c, Status__c,
                       ContactId__r.AccountId
                FROM Subscription__c
                WHERE ContactId__c = :contactId
                AND (ContractId__c = NULL OR ContractId__c = '')
                AND Status__c != '취소'
            ];

            if (subscriptions.isEmpty()) continue;

            Decimal totalOriginalPrice = 0;
            Integer totalMonths = 0;
            Set<String> subjectSet = new Set<String>();

            for (Subscription__c sub : subscriptions) {
                if (sub.Term__c != null && sub.ProductId__r.MonthlyPrice__c != null) {
                    totalOriginalPrice += sub.Term__c * sub.ProductId__r.MonthlyPrice__c;
                    totalMonths += Integer.valueOf(sub.Term__c);
                    if (sub.ProductId__r.Family != null) {
                        subjectSet.add(sub.ProductId__r.Family);
                    }
                }
            }

            // 활성화된 캠페인 조회
            List<Campaign> campaigns = [
                SELECT Id, Name, DiscountPercent__c, MinMonths__c,
                       EnableSubjectDiscount__c, EnableMonthDiscount__c, ProductFamily__c
                FROM Campaign
                WHERE Campaign_Active__c = true
                AND StartDate <= TODAY AND EndDate >= TODAY
                ORDER BY DiscountPercent__c DESC
            ];

            Campaign matchedCampaign;
            Decimal discountRate = 0;

            for (Campaign c : campaigns) {
                Boolean subjectOk = !c.EnableSubjectDiscount__c ||
                    (c.ProductFamily__c != null && subjectSet.contains(c.ProductFamily__c));

                Boolean monthOk = !c.EnableMonthDiscount__c ||
                    (c.MinMonths__c != null && totalMonths >= c.MinMonths__c);

                if (subjectOk && monthOk) {
                    matchedCampaign = c;
                    discountRate = c.DiscountPercent__c != null ? c.DiscountPercent__c : 0;
                    break;
                }
            }

            Decimal discountedTotal = totalOriginalPrice * (1 - (discountRate / 100));
            Id accountId = subscriptions[0].ContactId__r.AccountId;

            // 계약 생성
            Contract contract = new Contract(
                AccountId = accountId,
                StartDate = Date.today(),
                Original_Total_Amount__c = totalOriginalPrice,
                Discount_Rate__c = discountRate,
                Total_Price__c = discountedTotal,
                Name = '계약 - ' + Date.today().format(),
                Status = 'Draft'
            );
            if (matchedCampaign != null) {
                contract.Campaign__c = matchedCampaign.Id;
            }

            contractsToInsert.add(contract);
        }

        insert contractsToInsert;

        // Subscription 업데이트
        for (Contract c : contractsToInsert) {
            List<Contact> contacts = [
                SELECT Id FROM Contact WHERE AccountId = :c.AccountId LIMIT 1
            ];

            if (contacts.isEmpty()) continue;

            Id contactId = contacts[0].Id;

            List<Subscription__c> subsToUpdate = [
                SELECT Id FROM Subscription__c
                WHERE ContactId__c = :contactId
                AND (ContractId__c = NULL OR ContractId__c = '')
                AND Status__c != '취소'
            ];

            for (Subscription__c s : subsToUpdate) {
                s.ContractId__c = c.Id;
                allSubscriptionsToUpdate.add(s);
            }
        }

        update allSubscriptionsToUpdate;
    }
}