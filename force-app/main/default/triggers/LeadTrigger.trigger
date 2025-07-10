trigger LeadTrigger on Lead (after insert) {
    List<Task> tasksToInsert = new List<Task>();
    String TEACHER_ROLE = '방문교사';

    // 모든 사용자 WHERE Role = 방문교사
    List<User> allTeachers = [
        SELECT Id, Name, SubjectInCharge__c, Region_Zone__c
        FROM User
        WHERE UserRole.Name = :TEACHER_ROLE
            AND IsActive = true
        // Name   SubjectInCharge__c  Region_Zone__c
        // 김세빈   국어	             강남구
        // 정시헌   국어;영어;수학         강남구
        // 정승제   과학                 강남구
    ];

    // 방문교사별 현재 담당 리드 수
    Map<Id, Integer> teacherLeadCounts = new Map<Id, Integer>();
    for (AggregateResult ar : [
        SELECT Teacher__c, COUNT(Id) total
        FROM Lead
        WHERE IsConverted = false
        GROUP BY Teacher__c
        // Teacher__c   count(Id)
        // 정시헌           1
        // 김세빈           6
        // 정승제           1
    ]) {
        // 결과는 Map<교사 Id, 리드 수> 형식으로 저장
        teacherLeadCounts.put((Id)ar.get('Teacher__c'), (Integer)ar.get('total'));
    }

    // for each 새로 생성된 잠재고객 레코드
    for (Lead lead : Trigger.new) {
        List<TeacherScoreWrapper> teacherScores = new List<TeacherScoreWrapper>();

        // for each 방문교사
        for (User teacher : allTeachers) {
            // 리드 지역과 교사 지역이 일치하면 1, 아니면 0
            Decimal regionScore = (teacher.Region_Zone__c == lead.State__c) ? 1 : 0;
            
            // 교사 담당 과목이 null이 아니고 리드 과목을 포함한다면 1, 아니면 0
            Boolean subjectMatch = teacher.SubjectInCharge__c != null && teacher.SubjectInCharge__c.contains(lead.Subject__c);
            Decimal subjectScore = subjectMatch ? 1 : 0;

            // 담당 중인 리드 수에 반비례한 점수 (0~1)
            Integer activeLeadCount = teacherLeadCounts.containsKey(teacher.Id) ? teacherLeadCounts.get(teacher.Id) : 0;
            Decimal loadScore = 1 - Math.min((Decimal)activeLeadCount / 10, 1);

            // Logistic Regression 여기 들어가야함
            
            // 최종 스코어는 위 세 점수에 로지스틱 회귀 기반 가중치를 곱해 합산
            Decimal score = (0.65 * regionScore) + (0.24 * subjectScore) + (0.11 * loadScore);
            teacherScores.add(new TeacherScoreWrapper(teacher.Id, score));
        }

        // 점수 정렬 내림차순
        teacherScores.sort();

        Integer hoursOffset = 0;
        // for each <교사Id, 점수> 리스트
        for (TeacherScoreWrapper tsw : teacherScores) {
            Task t = new Task(
                WhoId = lead.Id,
                OwnerId = tsw.teacherId,
                Subject = '신규 잠재고객 대응',
                Status = '대기중',
                Priority = 'Normal',
                // 한시간 간격 hoursOffset = 한시간
                ActivityDateTime = System.now().addHours(hoursOffset / 20);
            );
            tasksToInsert.add(t);
            hoursOffset++;
        }
    }

    if (!tasksToInsert.isEmpty()) {
        try {
            // 한 번에 bulk insert (성능)
            insert tasksToInsert;
        } catch (Exception e) {
            System.debug('Task insert failed: ' + e.getMessage());
        }
    }
}

// 각 교사와 해당 스코어를 묶어서 관리하는 래퍼 클래스
// 별도로 클래스 만들거나, 접근 제어자 없이 선언
class TeacherScoreWrapper implements Comparable {
    public Id teacherId;
    public Decimal score;

    public TeacherScoreWrapper(Id id, Decimal s) {
        teacherId = id;
        score = s;
    }

    public Integer compareTo(Object obj) {
        TeacherScoreWrapper other = (TeacherScoreWrapper)obj;
        // 내림차순 정렬 (큰 점수가 먼저 오도록)
        if (this.score > other.score) return -1;
        if (this.score < other.score) return 1;
        return 0;
    }
}