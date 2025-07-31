public with sharing class CustomQuoteMakerV2 {

    public class QuoteRequest {
        @InvocableVariable(required=true)
        public Id contractId;
    }

    public class QuoteResult {
        @InvocableVariable
        public String resultMessage;
 

    @InvocableVariable
    public Id quoteId; // quoteId 받기
    }

    @InvocableMethod(label='Create Quote From Contract')
    public static List<QuoteResult> createQuote(List<QuoteRequest> requests) {
        List<QuoteResult> results = new List<QuoteResult>();

        for (QuoteRequest req : requests) {
            QuoteResult res = new QuoteResult();

            try {
                if (req.contractId == null) {
                    res.resultMessage = 'Error: Contract ID is null.';
                    results.add(res);
                    continue;
                }

                // 1. 계약 조회
                List<Contract> contractList = [
                    SELECT Id, Name, StartDate,
                           Original_Total_Amount__c, Total_Price__c, Discount_Rate__c,
                           CustomerSignedId, AccountId
                    FROM Contract
                    WHERE Id = :req.contractId
                    LIMIT 1
                ];

                if (contractList.isEmpty()) {
                    res.resultMessage = 'Error: Contract not found.';
                    results.add(res);
                    continue;
                }

                Contract contract = contractList[0];

                // 2. 아동(Contact) 조회
                
                Contact child = null;
                
                // 우선 Contract에 연결된 Contact 사용
                
                if (contract.CustomerSignedId != null) {
                    
                    List<Contact> childList = [
                        SELECT Id, Name, Birthdate
                        FROM Contact
                        WHERE Id = :contract.CustomerSignedId
                        LIMIT 1
                    ];
                    if (!childList.isEmpty()) {
                        child = childList[0];
                    }
                }
                // 대체 Contact 로직 추가
                if (child == null) {
                    List<Contact> accountContacts = [
                        SELECT Id, Name, Birthdate
                        FROM Contact
                        WHERE AccountId = :contract.AccountId
                        LIMIT 1
                    ];
                    if (!accountContacts.isEmpty()) {
                        child = accountContacts[0];
                    }
                }
                // 여전히 없으면 에러 처리
                   if (child == null) {
                       res.resultMessage = 'Error: Child Contact not found.';
                       results.add(res);
                       continue;
                   }

                // 3. 학부모(Account) 조회
                Account acc = null;
                if (contract.AccountId != null) {
                    List<Account> accList = [
                        SELECT Id, Name, Phone, Email__c, CityName__c, 	State__c, Street__c
                        FROM Account
                        WHERE Id = :contract.AccountId
                        LIMIT 1
                    ];
                    if (!accList.isEmpty()) {
                        acc = accList[0];
                    }
                }

                if (acc == null) {
                    res.resultMessage = 'Error: Parent Account not found.';
                    results.add(res);
                    continue;
                }

                // 4. Quote 이름 조합 (YYYY-MM-DD_아동이름_학부모이름)
                String quoteName = '';
                if (contract.StartDate != null) {
                    quoteName += String.valueOf(contract.StartDate);
                }
                quoteName += ' ' + child.Name + ' ' + acc.Name;

                // 5. Quote 생성
                Quote quote = new Quote();
                quote.Name = quoteName;
                quote.ContractId = contract.Id;
                quote.ContactId = child.Id;
                quote.AccountName__c = acc.Name;
                quote.AccountAddress__c = acc.CityName__c + ' ' + acc.State__c + ' ' + acc.Street__c;
                quote.Email = acc.Email__c;
                quote.Phone = acc.Phone;
                quote.ChildName__c = child.Name;
                quote.ChildBirth__c = child.Birthdate;
                quote.ContractDate__c = contract.StartDate;
                quote.OriginalTotal__c = contract.Original_Total_Amount__c;
                quote.TotalPrice__c = contract.Total_Price__c;
                quote.DiscountRate__c = contract.Discount_Rate__c;

                insert quote;
                res.quoteId = quote.Id; // subflow에 id 보내주기

                // 6. 구독내역 조회 (최대 2개)
                List<Subscription__c> subs = [
                    SELECT Id, ProductId__c, StartDate__c, EndDate__c
                    FROM Subscription__c
                    WHERE ContractId__c = :contract.Id
                    LIMIT 2
                ];

                // 7. Quote Line Item 생성
                List<QuoteLineItem> qlis = new List<QuoteLineItem>();
                for (Subscription__c sub : subs) {
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.QuoteId = quote.Id;
                    qli.Product2Id = sub.ProductId__c;
                    qli.Description = '과정: ' + String.valueOf(sub.ProductId__c)
                                    + ', 시작일: ' + String.valueOf(sub.StartDate__c)
                                    + ', 종료일: ' + String.valueOf(sub.EndDate__c);
                    qlis.add(qli);
                }

                if (!qlis.isEmpty()) {
                    insert qlis;
                }

                res.resultMessage = '견적 생성 완료 (Quote Id: ' + quote.Id + ')';
            } catch (Exception e) {
                res.resultMessage = 'Error: ' + e.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}