public with sharing class QuoteGeneratorFromContract {
    
    @InvocableMethod(label='Quote 생성 실행')
    public static void generateQuotes(List<Id> contractIds) {
        List<Quote> quotesToInsert = new List<Quote>();

        for (Id contractId : contractIds) {
            Contract con = [
                SELECT Id, Name, StartDate, AccountId
                FROM Contract
                WHERE Id = :contractId
                LIMIT 1
            ];

            // Quote 생성
            Quote q = new Quote(
                Name = '견적 - ' + con.Name,
                ContractId = con.Id,
                StartDate__c = con.StartDate,
                Status = 'Draft'
            );

            quotesToInsert.add(q);
        }

        insert quotesToInsert;
    }
}