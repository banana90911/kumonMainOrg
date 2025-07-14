public with sharing class ContractBatchFlowWrapperWithOutput {

    public class ContractResult {
        @InvocableVariable(label='생성된 계약서 ID')
        public Id contractId;
    }

    @InvocableMethod(label='계약 생성 및 ID 반환')
    public static List<ContractResult> createContracts(List<Id> contactIds) {
        List<ContractResult> results = new List<ContractResult>();

        for (Id contactId : contactIds) {
            // 1. 구독 조회
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

            // 2. 가격 계산
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

            // 3. 캠페인 할인 적용
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
            Account acc = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];

            // 4. Contract 생성
            Contract contract = new Contract(
                AccountId = accountId,
                StartDate = Date.today(),
                Original_Total_Amount__c = totalOriginalPrice,
                Discount_Rate__c = discountRate,
                Total_Price__c = discountedTotal,
                Name = '계약 - ' + Date.today().format(),
                Status = 'Draft',
                Campaign__c = matchedCampaign != null ? matchedCampaign.Id : null,
                AccountName__c = acc.Name
            );
            insert contract;

            // 5. Subscription 업데이트
            for (Subscription__c s : subscriptions) {
                s.ContractId__c = contract.Id;
            }
            update subscriptions;

            // 6. Quote 생성 (계산 필드 제외)
            Quote quote = new Quote(
                Name = '견적서 - ' + Date.today().format(),
                ContractId = contract.Id,
                StartDate__c = Date.today(), // ✅ 커스텀 필드 필요
                Status = 'Draft'
            );
            insert quote;

            // 7. 결과 반환
            ContractResult result = new ContractResult();
            result.contractId = contract.Id;
            results.add(result);
        }

        return results;
    }
}