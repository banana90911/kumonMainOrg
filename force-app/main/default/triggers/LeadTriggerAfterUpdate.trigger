trigger LeadTriggerAfterUpdate on Lead (after update) {
    List<Task> tasksToUpdate = new List<Task>();

    for (Lead l : Trigger.new) {
        Lead old = Trigger.oldMap.get(l.Id);
        
        if (old.Teacher__c == null && l.Teacher__c != null) {
            List<Task> relatedTasks = [
                SELECT Id, Status
                FROM Task
                WHERE WhoId = :l.Id
                  AND Status = '대기중'
            ];

            for (Task t : relatedTasks) {
                t.Status = '놓침';
            }

            tasksToUpdate.addAll(relatedTasks);
        }
    }

    if (!tasksToUpdate.isEmpty()) {
        update tasksToUpdate;
    }
}
