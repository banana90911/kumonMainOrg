@isTest(SeeAllData=true)
public class LeadTriggerTest {
    @isTest
    static void testWithExistingUser() {
        // 1. 방문교사 UserRole을 가진 유저 조회
        User teacher = [
            SELECT Id, UserRole.Name, Region_Zone__c
            FROM User
            WHERE UserRole.Name = '방문교사'
                AND Region_Zone__c != null
                AND IsActive = true
            LIMIT 1
        ];

        // 2. 테스트 리드 생성 (교사의 지역과 매칭)
        Lead testLead = new Lead(
            Company = 'Kim',
            Phone = '010-1111-2222',
            CityName__c = teacher.Region_Zone__c,
            State__c = '강남구',
            Street__c = '연무장길 11',
            Status = '상담대기',
            LastName = '자녀자녀',
            ChildBirthDate1__c = '070707',
            InterestedSubject__c = '국어',
            MarketingConsent__c = true,
            Upper14Consent__c = true,
            Under14Consent__c = true,
            PrivacyConsent__c = true
        );
        insert testLead;

        // 3. Task 생성 여부 확인 (Is_Lead_Task__c 필터 제거)
        List<Task> leadTasks = [
            SELECT Id, OwnerId, WhoId, Status
            FROM Task
            WHERE WhoId = :testLead.Id
        ];

        System.assertEquals(1, leadTasks.size(), 'Task should be created');
        System.assertEquals(teacher.Id, leadTasks[0].OwnerId, 'Task should be assigned to the teacher');
        System.assertEquals('대기중', leadTasks[0].Status);
    }
}
