trigger LeadAssignmentTrigger on Lead (after insert) {
    for (Lead l : Trigger.new) {
        LeadAssignmentService.assignToQueueWithTopUsers(l);
    }
}