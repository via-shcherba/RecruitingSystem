public without sharing class EventMaker {

    public static List<Database.SaveResult> createEvents(List<JobSeeker__c> jobSeekers) {
        List<CreateJobSeeker__e> events = new List<CreateJobSeeker__e>();
        for (JobSeeker__c jobSeeker : jobSeekers) {
            CreateJobSeeker__e event = new CreateJobSeeker__e(
                JobSeekerId__c = jobSeeker.Id
            );
            events.add(event);
        }
        return EventBus.publish(events);                     
    }

}
