trigger JobSeeker on JobSeeker__c (before insert, before update, after insert, after update) {       
    new JobSeekerTriggerHandler(Trigger.new);   
}