@isTest
private with sharing class EventMakerTest {
    @isTest
    static void createEventsTest() {
        List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>();
        JobSeeker__c jobSeeker = new JobSeeker__c();
        jobSeeker.LastName__c = 'test';
        jobSeeker.Email__c = 'test@were.here';
        jobSeekers.add(jobSeeker);
        insert jobSeekers;
        test.startTest();
        List<Database.SaveResult> results = EventMaker.createEvents(jobSeekers);
        test.stopTest();
        System.assert(results[0].isSuccess());
    }
}
