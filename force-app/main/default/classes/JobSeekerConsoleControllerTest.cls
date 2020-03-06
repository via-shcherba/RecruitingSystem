@isTest
private with sharing class JobSeekerConsoleControllerTest {
    
    @TestSetup
    static void makeData() {
        JobSeeker__c jobSeeker = new JobSeeker__c();
        jobSeeker.LastName__c = 'test';
        jobSeeker.Email__c = 'test@were.here';
        insert jobSeeker;
    }
    
    @isTest
    private static void getJobSeekerTest() {
        Id currentUser = UserInfo.getUserId();
        test.startTest();
        JobSeeker__c jobSeeker = JobSeekerConsoleController.getJobSeeker(currentUser);
        test.stopTest();       
        System.assert(jobSeeker != null);
    }

    @isTest
    private static void deleteJobSeekerTest() {
        JobSeeker__c jobSeeker = [SELECT Id FROM JobSeeker__c LIMIT 1];
        test.startTest();
        Boolean result = JobSeekerConsoleController.deleteJobSeeker(jobSeeker.Id);
        test.stopTest();     
        System.assert(result);
    }

}
