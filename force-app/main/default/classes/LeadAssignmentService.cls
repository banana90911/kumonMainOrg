public class LeadAssignmentService {
    public class UserScoreWrapper implements Comparable {
        public Id userId;
        public Decimal score;

        public UserScoreWrapper(Id userId, Decimal score) {
            this.userId = userId;
            this.score = score;
        }

        public Integer compareTo(Object o) {
            UserScoreWrapper other = (UserScoreWrapper)o;
            if (this.score == other.score) return 0;
            return (this.score > other.score) ? -1 : 1; // 내림차순
        }

    }

    public static void assignToQueueWithTopUsers(Lead lead) {
        List<User> candidates = [
            SELECT Id, Region_Zone__c, SubjectInCharge__c, HireDate__c
            FROM User
            WHERE UserRole.Name = '방문교사'
        ];

        // 리드 수 집계
        Map<Id, Integer> userLeadCounts = new Map<Id, Integer>();
        AggregateResult[] results = [
            SELECT OwnerId, COUNT(Id) leadCount
            FROM Lead
            WHERE OwnerId IN :candidates AND Status != 'Closed'
            GROUP BY OwnerId
        ];
        for (AggregateResult ar : results) {
            userLeadCounts.put((Id)ar.get('OwnerId'), (Integer)ar.get('leadCount'));
        }

        // 점수 계산
        List<UserScoreWrapper> scoredUsers = new List<UserScoreWrapper>();
        for (User u : candidates) {
            Decimal score = 0;

            if (u.Region_Zone__c == lead.State__c) score += 0.65;
            if (u.SubjectInCharge__c == lead.InterestedSubject__c) score += 0.25;

            Integer leadCount = userLeadCounts.containsKey(u.Id) ? userLeadCounts.get(u.Id) : 0;
            Decimal leadScore = Math.max(0, 1 - (Decimal.valueOf(leadCount) / 10));
            score += leadScore * 0.06;

            if (u.HireDate__c != null) {
                Long days = Date.today().daysBetween(u.HireDate__c);
                Decimal hireScore = Math.max(0, 1 - (Decimal.valueOf(days) / 365));
                score += hireScore * 0.05;
            }

            scoredUsers.add(new UserScoreWrapper(u.Id, score));
        }

        // 상위 10% (최소 1명) 추출
        scoredUsers.sort();
        Integer topN = Math.max(1, Math.ceil(scoredUsers.size() * 0.1).intValue());
        List<Id> topUserIds = new List<Id>();
        for (Integer i = 0; i < topN; i++) {
            topUserIds.add(scoredUsers[i].userId);
        }

        // 세미콜론 구분된 문자열 저장
        String topUserStr = String.join(topUserIds, ';');

        // Lead 업데이트
        Group queue = [SELECT Id FROM Group WHERE Name = 'Lead_Queue' LIMIT 1];

        Lead leadToUpdate = new Lead(
            Id = lead.Id,
            MultiRecommendedUsers__c = topUserStr,
            OwnerId = queue.Id
        );

        update leadToUpdate;
    }
}
