@isTest public class LeadTriggerTest {
    @isTest static void testLeadCreatesTasksForTeachers() {
        // 1. 방문교사 프로필 조회
        Profile teacherProfile = [SELECT Id FROM Profile WHERE Name = '방문교사' LIMIT 1];

        // 2. 교사 유저 생성
        User teacher = new User(
            Username = 'teacher1@example.com',
            Email = 'teacher1@example.com',
            LastName = 'TeacherOne',
            Alias = 'tchr1',
            ProfileId = teacherProfile.Id,
            TimeZoneSidKey = 'Asia/Seoul',
            LocaleSidKey = 'ko_KR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'ko',
            Region_Zone__c = '서울'
        );
        insert teacher;

        // 3. 테스트용 리드 생성
        Lead testLead = new Lead(
            Company = 'Kim', //학부모이름
            Phone = '010-1111-2222', //연락처
            CityName__c = '서울', //지역
            State__c = '강남구', //자치구
            Street__c = '연무장길 11', //상세주소
            Status = '상담대기', //상태
            LastName = '자녀자녀', //자녀1이름
            ChildBirthDate1__c = '070707', //자녀1생년월일
            InterestedSubject__c = '국어', //관심과목
            MarketingConsent__c = true, //마케팅 동의
            Upper14Consent__c = true, //상담정보입력자 만14세 이상 동의
            Under14Consent__c = true, //만 14세 미만 아동정보 동의
            PrivacyConsent__c = true //개인정보 동의
        );
        insert testLead;

        // 4. Task가 잘 생성됐는지 확인
        List<Task> relatedTasks = [
            SELECT Id, OwnerId, WhatId, Status
            FROM Task
            WHERE WhatId = :testLead.Id
        ];

        System.assertEquals(1, relatedTasks.size(), 'Task should be created for teacher');
        System.assertEquals(teacher.Id, relatedTasks[0].OwnerId, 'Task should be assigned to the teacher');
        System.assertEquals('대기중', relatedTasks[0].Status, 'Task status should be 대기중');
    }
}
