public with sharing class QuoteSummaryEmailSender_KH {

    public class EmailRequest {
        @InvocableVariable(required=true)
        public Id quoteId;
    }

    public class EmailResult {
        @InvocableVariable
        public String status;
    }

    @InvocableMethod(label='커몬학습 구독 요약 메일 전송')
    public static List<EmailResult> sendSummary(List<EmailRequest> requests) {
        List<EmailResult> results = new List<EmailResult>();

        for (EmailRequest req : requests) {
            EmailResult res = new EmailResult();

            try {
                // 1. Quote 정보 조회
                Quote q = [
                    SELECT Id, Name, Email, ContractId,
                           AccountName__c, AccountAddress__c, Phone,
                           ChildName__c, ChildBirth__c,
                           OriginalTotal__c, DiscountRate__c, TotalPrice__c
                    FROM Quote
                    WHERE Id = :req.quoteId
                    LIMIT 1
                ];

                // 2. 연결된 Subscription__c 조회
                List<Subscription__c> subs = [
                    SELECT ProductId__r.Name, StartDate__c, EndDate__c
                    FROM Subscription__c
                    WHERE ContractId__c = :q.ContractId
                    ORDER BY StartDate__c ASC
                ];

                // 3. 이메일 유효성 검사
                if (String.isBlank(q.Email)) {
                    res.status = '실패: 이메일 없음 (Quote Id: ' + q.Id + ')';
                    results.add(res);
                    continue;
                }

                // 4. 과정 요약 HTML 조립
                String courseDetails = '';
                Integer idx = 1;

                if (!subs.isEmpty()) {
                    for (Subscription__c sub : subs) {
                        String courseName = sub.ProductId__r != null ? sub.ProductId__r.Name : '과정명 없음';
                        String startStr = sub.StartDate__c != null ? String.valueOf(sub.StartDate__c) : '미정';
                        String endStr = sub.EndDate__c != null ? String.valueOf(sub.EndDate__c) : '미정';

                        courseDetails += idx + '. ' + courseName + '<br/>'
                                       + '&nbsp;&nbsp;- 기간: ' + startStr + ' ~ ' + endStr + '<br/><br/>';
                        idx++;
                    }
                } else {
                    courseDetails = '(신청된 과정이 없습니다)<br/><br/>';
                }

                // 5. Static Resource 로고 이미지 URL 생성
                String logoUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/resource/ComeonLogo';


                // 6. HTML 이메일 본문 조립
                String htmlBody = ''
                    + '<html><body>'
                    + '<img src="' + logoUrl + '" width="180" alt="커몬학습 로고"/><br/><br/>'
                    + '<p>안녕하세요, 커몬학습입니다.</p>'
                    + '<p><strong>' + q.AccountName__c + ' 고객님</strong>,</p>'
                    + '<p>아래는 아이의 학습 구독 요약입니다.</p>'
                    + '<hr/>'
                    + '<p>'
                    + '👦 아동 이름 : ' + q.ChildName__c + '<br/>'
                    + '🎂 생년월일 : ' + String.valueOf(q.ChildBirth__c) + '<br/>'
                    + '📞 연락처 : ' + q.Phone + '<br/>'
                    + '🏠 주소 : ' + q.AccountAddress__c + '<br/><br/>'
                    + '📘 <strong>신청 과정</strong><br/>' + courseDetails                 
                    + '<p>💰 <strong>정가 총액</strong> : ₩' + q.OriginalTotal__c.format() + '<br/>'
                    + '🎁 <strong>할인율</strong> : ' + q.DiscountRate__c + '%<br/>'
                    + '✅ <strong>최종 결제 금액</strong> : ₩' + q.TotalPrice__c.format() + '</p>'
                    + '</p><br/>'
                    + '<p>우리 커몬학습의 가족이 되어주셔서 감사합니다.<br/>'
                    + '앞으로도 아이의 성장을 위해 함께하겠습니다.</p>'
                    + '<p><strong>커몬학습 드림</strong></p>'
                    + '</body></html>';

                // 7. 이메일 전송
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { q.Email });
                mail.setSubject('커몬학습 구독 요약 안내 - ' + q.Name);
                mail.setHtmlBody(htmlBody); // HTML 포맷으로 전송

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                res.status = '성공: ' + q.Email + ' 로 메일 전송됨';
            } catch (Exception e) {
                res.status = '실패: ' + e.getMessage();
            }

            results.add(res);
        }

        return results;
    }
}