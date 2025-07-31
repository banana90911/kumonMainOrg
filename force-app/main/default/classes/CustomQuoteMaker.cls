public with sharing class CustomQuoteMaker {

    public class QuoteRequest {
        @InvocableVariable(required=true)
        public Id contractId;
    }

    public class QuoteResult {
        @InvocableVariable
        public String resultMessage;
    }

    @InvocableMethod(label='Create Quote From Contract')
    public static List<QuoteResult> createQuoteFromContract(List<QuoteRequest> requests) {
        List<QuoteResult> results = new List<QuoteResult>();

        for (QuoteRequest req : requests) {
            QuoteResult res = new QuoteResult();

            try {
                Id contractId = req.contractId;

                // 1. 계약 정보 조회
                Contract contract = [
                    SELECT Id, Name, StartDate,
                           Original_Total_Amount__c, Total_Price__c, Discount_Rate__c,
                           CustomerSignedId, AccountId
                    FROM Contract
                    WHERE Id = :contractId
                    LIMIT 1
                ];

                // 2. 아동(Contact) 정보 조회
                Contact child = [
                    SELECT Id, Name, Birthdate
                    FROM Contact
                    WHERE Id = :contract.CustomerSignedId
                    LIMIT 1
                ];

                // 3. 학부모(Account) 정보 조회
                Account acc = [
                    SELECT Id, Name, Phone, Email__c, BillingCity, BillingState, BillingStreet
                    FROM Account
                    WHERE Id = :contract.AccountId
                    LIMIT 1
                ];

                // 4. Quote 생성
                Quote quote = new Quote();
                quote.Name = contract.Name;
                quote.ContractId = contract.Id;
                quote.ContactId = child.Id;
                quote.AccountName__c     = acc.Name;
                quote.AccountAddress__c  = acc.BillingCity + ' ' + acc.BillingState + ' ' + acc.BillingStreet;
                quote.Email              = acc.Email__c;
                quote.Phone              = acc.Phone;
                quote.ChildName__c       = child.Name;
                quote.ChildBirth__c      = child.Birthdate;
                quote.ContractDate__c    = contract.StartDate;
                quote.OriginalTotal__c   = contract.Original_Total_Amount__c;
                quote.TotalPrice__c      = contract.Total_Price__c;
                quote.DiscountRate__c    = contract.Discount_Rate__c;

                insert quote;

                // 5. 구독내역 불러오기
                List<Subscription__c> subs = [
                    SELECT Id, ProductId__c, StartDate__c, EndDate__c
                    FROM Subscription__c
                    WHERE ContractId__c = :contract.Id
                    LIMIT 2
                ];

                List<QuoteLineItem> qlis = new List<QuoteLineItem>();

                for (Subscription__c sub : subs) {
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.QuoteId = quote.Id;
                    qli.Product2Id = sub.ProductId__c;
                    qli.Description =
                        '과정: ' + String.valueOf(sub.ProductId__c) +
                        ', 시작일: ' + String.valueOf(sub.StartDate__c) +
                        ', 종료일: ' + String.valueOf(sub.EndDate__c);
                    qlis.add(qli);
                }

                if (!qlis.isEmpty()) {
                    insert qlis;
                }

                res.resultMessage = '견적서가 생성되었습니다.';

            } catch (Exception e) {
                res.resultMessage = '오류 발생: ' + e.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}