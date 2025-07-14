public class SingleContactContractGenerator {

    public static void createContractForContact(Id contactId) {
        List<Subscription__c> subs = [
            SELECT Id, Term__c, StartDate__c, EndDate__c,
                   ContactId__c, ContactId__r.AccountId,
                   ProductId__r.MonthlyPrice__c, ProductId__r.Name
            FROM Subscription__c
            WHERE ContactId__c = :contactId
              AND ContractId__c = NULL
              AND Status__c != '취소됨'
        ];

        if (subs.isEmpty()) {
            System.debug('📭 계약되지 않은 구독내역이 없습니다.');
            return;
        }

        Id accountId = subs[0].ContactId__r.AccountId;
        if (accountId == null) {
            System.debug('❗ Contact에 학부모(Account)가 연결되지 않았습니다.');
            return;
        }

        Decimal total = 0;
        for (Subscription__c s : subs) {
            Decimal unit = s.ProductId__r.MonthlyPrice__c;
            Integer months = s.Term__c != null ? s.Term__c.intValue() : 0;
            total += unit * months;
        }

        Contract con = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            Original_Total_Amount__c = total
        );
        insert con;

        for (Subscription__c s : subs) {
            s.ContractId__c = con.Id;
        }
        update subs;

        System.debug('✅ 계약 생성 완료! ContractId: ' + con.Id);
    }
}