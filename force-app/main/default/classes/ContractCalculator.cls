public class ContractCalculator {

    public class ContractResult {
        public Decimal totalOriginalAmount;
        public Integer totalSubscriptionCount;
        public Integer totalSubscriptionMonths;
        public Decimal discountPercent;
        public Decimal finalPrice;
    }

    @AuraEnabled(cacheable=true)
    public static ContractResult calculateContract(Id contactId) {
        ContractResult result = new ContractResult();

        // 아동을 통해 학부모(Account) 찾기
        Contact child = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId LIMIT 1];
        Id accountId = child.AccountId;

        // 구독내역 조회 (아동 → Account 연결 기준)
        List<Subscription__c> subs = [
            SELECT Id, Term__c, ProductId__c,
                   ProductId__r.MonthlyPrice__c,
                   ContactId__r.AccountId
            FROM Subscription__c
            WHERE ContactId__r.AccountId = :accountId
        ];

        Decimal totalOriginal = 0;
        Integer subjectCount = 0;
        Integer totalMonths = 0;

        for (Subscription__c s : subs) {
            if (s.ProductId__r.MonthlyPrice__c != null && s.Term__c != null) {
                totalOriginal += s.ProductId__r.MonthlyPrice__c * s.Term__c;
                subjectCount++;
                totalMonths += (Integer)s.Term__c;
            }
        }

        result.totalOriginalAmount = totalOriginal;
        result.totalSubscriptionCount = subjectCount;
        result.totalSubscriptionMonths = totalMonths;

        // 활성화된 프로모션 중 조건 충족하는 것 중 가장 큰 할인율
        List<Campaign> campaigns = [
            SELECT DiscountPercent__c, MinMonths__c, EnableMonthDiscount__c, EnableSubjectDiscount__c
            FROM Campaign
            WHERE Campaign_Active__c = true
        ];

        Decimal bestDiscount = 0;
        for (Campaign c : campaigns) {
            Boolean valid = false;
            if (c.EnableMonthDiscount__c && totalMonths >= c.MinMonths__c) {
                valid = true;
            }
            if (c.EnableSubjectDiscount__c && subjectCount >= 2) {
                valid = true;
            }
            if (valid && c.DiscountPercent__c > bestDiscount) {
                bestDiscount = c.DiscountPercent__c;
            }
        }

        result.discountPercent = bestDiscount;

        Decimal finalPrice = totalOriginal * (1 - bestDiscount / 100);
        result.finalPrice = finalPrice.setScale(0); // 소수점 제거

        return result;
    }
}