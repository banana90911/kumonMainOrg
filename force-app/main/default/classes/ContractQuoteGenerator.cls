public class ContractQuoteGenerator {

    public static void createContractsGroupedByContact() {
        List<Subscription__c> allSubs = [
            SELECT Id, Term__c, StartDate__c, EndDate__c,
                   ContactId__c, ContactId__r.AccountId,
                   ProductId__r.MonthlyPrice__c, ProductId__r.Name
            FROM Subscription__c
            WHERE ContractId__c = NULL
              AND Status__c != '취소됨'
        ];

        if (allSubs.isEmpty()) {
            System.debug('계약되지 않은 구독내역이 없습니다.');
            return;
        }

        Map<Id, List<Subscription__c>> subsByContact = new Map<Id, List<Subscription__c>>();
        for (Subscription__c sub : allSubs) {
            if (!subsByContact.containsKey(sub.ContactId__c)) {
                subsByContact.put(sub.ContactId__c, new List<Subscription__c>());
            }
            subsByContact.get(sub.ContactId__c).add(sub);
        }

        List<Contract> contractsToInsert = new List<Contract>();
        Map<Id, Id> contactToContractIdMap = new Map<Id, Id>();

        for (Id contactId : subsByContact.keySet()) {
            List<Subscription__c> subs = subsByContact.get(contactId);
            Id accountId = subs[0].ContactId__r.AccountId;

            Decimal totalOriginal = 0;
            for (Subscription__c s : subs) {
                Decimal unitPrice = s.ProductId__r.MonthlyPrice__c;
                Integer term = s.Term__c != null ? s.Term__c.intValue() : 0;
                totalOriginal += unitPrice * term;
            }

            // 할인율 없이 계약 생성
            Contract newContract = new Contract(
                AccountId = accountId,
                Status = 'Draft',
                Original_Total_Amount__c = totalOriginal
                // Total_Price__c은 Formula, Discount_Rate__c도 생략
            );
            contractsToInsert.add(newContract);
        }

        insert contractsToInsert;

        Integer index = 0;
        for (Id contactId : subsByContact.keySet()) {
            contactToContractIdMap.put(contactId, contractsToInsert[index++].Id);
        }

        List<Subscription__c> toUpdate = new List<Subscription__c>();
        for (Subscription__c sub : allSubs) {
            sub.ContractId__c = contactToContractIdMap.get(sub.ContactId__c);
            toUpdate.add(sub);
        }
        update toUpdate;

        System.debug('✅ 계약 생성 및 구독 연결 완료 (캠페인 제외 버전)');
    }
}