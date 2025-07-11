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

    // 이름 → ID 매핑
    Map<String, Id> teacherNameToId = new Map<String, Id>();
    for (User u : allTeachers) {
        teacherNameToId.put(u.Name, u.Id);
    }


    Map<Id, Integer> teacherLeadCounts = new Map<Id, Integer>();
    for (AggregateResult ar : [
        SELECT Teacher__c, COUNT(Id) total
        FROM Lead
        WHERE IsConverted = false
        GROUP BY Teacher__c
    ]) {
        String teacherName = (String)ar.get('Teacher__c');
        if (teacherNameToId.containsKey(teacherName)) {
            Id teacherId = teacherNameToId.get(teacherName);
            teacherLeadCounts.put(teacherId, (Integer)ar.get('total'));
        }
    }



    // for each 새로 생성된 잠재고객 레코드
    for (Lead lead : Trigger.new) {
        List<TeacherScoreWrapper> teacherScores = new List<TeacherScoreWrapper>();

        // for each 방문교사
        for (User teacher : allTeachers) {
            // 리드 지역과 교사 지역이 일치하면 1, 아니면 0
            Decimal regionScore = (teacher.Region_Zone__c == lead.State__c) ? 1 : 0;
            
            // 교사 담당 과목이 null이 아니고 리드 과목을 포함한다면 1, 아니면 0
            Boolean subjectMatch = teacher.SubjectInCharge__c != null && teacher.SubjectInCharge__c.contains(lead.InterestedSubject__c);
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
                ActivityDate = System.now().date()
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