public with sharing class LearningScheduleController {
    @AuraEnabled(cacheable=true)
    public static List<LearningSchedule__c> getSchedulesForLoggedInTeacher() {
        Id currentUserId = UserInfo.getUserId();

        // 해당 유저가 담당한 아동(Contact) 목록
        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE TeacherId__c = :currentUserId
        ];

        List<Id> childIds = new List<Id>();
        for (Contact c : contacts) {
            childIds.add(c.Id);
        }

        // 아동들의 학습일정 가져오기
        return [
            SELECT Id, Name, StartTime__c, EndTime__c, Child__r.Name
            FROM LearningSchedule__c
            WHERE Child__c IN :childIds
        ];
    }
}