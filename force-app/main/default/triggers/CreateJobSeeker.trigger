trigger CreateJobSeeker on CreateJobSeeker__e (after insert) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            List<Id> jobSeekerIds = new List<Id>();
            for (CreateJobSeeker__e event : Trigger.New) {
                if (String.isNotBlank(event.JobSeekerId__c)) {
                    jobSeekerIds.add(event.JobSeekerId__c);                    
                }                
            }
            if (!jobSeekerIds.isEmpty()) {
                List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>(
                    [SELECT OwnerId, Specialization__c FROM JobSeeker__c WHERE Id IN :jobSeekerIds]
                );                
                update JobSeekerChanging.setOwner(jobSeekers);
            }                       
        }
    }
    
}