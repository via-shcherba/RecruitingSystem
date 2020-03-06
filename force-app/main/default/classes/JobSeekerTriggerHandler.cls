public without sharing class JobSeekerTriggerHandler {
		
	public JobSeekerTriggerHandler(List<JobSeeker__c> newTrigger) {	   
		if (Trigger.isBefore) {
			if (Trigger.isInsert) {
				JobSeekerChanging.setOwner(newTrigger);			   
			}
			if (Trigger.isUpdate) {
				JobSeekerChanging.setOwner(newTrigger); 
			}
		}
		if (Trigger.isAfter) {
			if (Trigger.isInsert) {			   
				EventMaker.createEvents(newTrigger);
			}
		}
	}
	
}