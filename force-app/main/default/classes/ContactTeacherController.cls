// ContactTeacherController.cls
public with sharing class ContactTeacherController {
    @AuraEnabled(cacheable=true)
    public static User getAssignedTeacher(Id contactId) {
        Contact c = [
            SELECT Id, TeacherId__c
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];
        
        User u = [
            SELECT Id, Name, Email, Phone, UserRole.Name
            FROM User
            WHERE Id = :c.TeacherId__c
            LIMIT 1
        ];
        
        if (u.UserRole != null && u.UserRole.Name == '방문교사') {
            return u;
        } else {
            return null; // 방문교사가 아니면 null 반환
        }
    }
}