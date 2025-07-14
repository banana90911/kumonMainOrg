public with sharing class PromotionUtils {

    public class PromotionRequest {
        @InvocableVariable(label='총 개월 수')
        public Integer totalMonths;

        @InvocableVariable(label='과목 개수')
        public Integer subjectCount;
    }

    public class PromotionResponse {
        @InvocableVariable(label='할인율')
        public Decimal discountPercent;
    }

    @InvocableMethod(label='Calculate Promotion Discount')
    public static List<PromotionResponse> calculate(List<PromotionRequest> requestList) {
        List<PromotionResponse> responses = new List<PromotionResponse>();
        for (PromotionRequest request : requestList) {
            Decimal discount = 0;
            // 여기 로직: 조건 기반 할인 계산
            if (request.totalMonths >= 6) discount += 5;
            if (request.subjectCount >= 2) discount += 5;

            PromotionResponse res = new PromotionResponse();
            res.discountPercent = discount;
            responses.add(res);
        }
        return responses;
    }
}