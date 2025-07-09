trigger LeadTrigger on Lead (after insert) {
    List<Task> tasksToInsert = new List<Task>();
    String TEACHER_ROLE = '방문교사';

    for (Lead lead : Trigger.new) {
        List<User> matchedTeachers = [
            SELECT Id, Name
            FROM User
            WHERE Profile.Name = :TEACHER_ROLE
              AND Region_Zone__c = :lead.CityName__c
              AND IsActive = true
        ];

        for (User teacher : matchedTeachers) {
            tasksToInsert.add(new Task(
                WhatId = lead.Id,
                OwnerId = teacher.Id,
                Subject = '신규 리드 대응',
                Status = '대기중',
                Priority = 'Normal',
                ActivityDate = Date.today()
            ));
        }
    }

    if (!tasksToInsert.isEmpty()) {
        insert tasksToInsert;
    }
}
