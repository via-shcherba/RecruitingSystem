@isTest
private with sharing class HRConsoleControllerTest {
    @TestSetup
    static void makeData(){
        Specialization__c specialization = new Specialization__c();
        specialization.Name = 'Apex';
        insert specialization;
        JobSeeker__c jobSeeker = new JobSeeker__c();
        jobSeeker.FirstName__c = 'test';
        jobSeeker.LastName__c = 'test';
        jobSeeker.Email__c = 'test@were.here';
        jobSeeker.Phone__c = '1236578';
        jobSeeker.Specialization__c = specialization.Id;
        jobSeeker.Background__c = 'test';
        jobSeeker.Status__c = 'Sent';
        insert jobSeeker;
    }

    @isTest
    static void getJobSeekersTest() {
        test.startTest();
        List<JobSeeker__c> jobSeekers = HRConsoleController.getJobSeekers();
        test.stopTest();
        System.assert(!jobSeekers.isEmpty());
    }

    @isTest
    static void getSpecializationsTest() {
        test.startTest();
        List<Specialization__c> specializations = HRConsoleController.getSpecializations();
        test.stopTest();
        System.assert(!specializations.isEmpty());
    }

    @isTest
    static void getTotalRecordsTest() {
        test.startTest();
        Integer totalRecord = HRConsoleController.getTotalRecords();
        test.stopTest();
        System.assert(totalRecord > 0);
    }

    @isTest
    static void searchJobSeekersTest() {        
        test.startTest();
        List<JobSeeker__c> jobSeekers = HRConsoleController.searchJobSeekers('');           
        test.stopTest();
        System.assert(jobSeekers.isEmpty());
    }

    @isTest
    static void getStatusFieldValuesTest() {
        test.startTest();
        List<String> values = HRConsoleController.getStatusFieldValues();       
        test.stopTest();
        System.assert(!values.isEmpty());
    }

    @isTest
    static void updateJobSeekersTest() {
        List<JobSeeker__c> jobSeekers = [SELECT Id FROM JobSeeker__c];
        test.startTest();
        String jsonData = '[{"id":"'+ jobSeekers[0].Id +'","FirstName__c":"test","LastName__c":"test","Email__c":"test@were.here","Phone__c":"123214","Background__c":"test"}]';        
        Boolean result = HRConsoleController.updateJobSeekers(jsonData);       
        test.stopTest();
        System.assert(result);
    }

    @isTest
    static void deleteJobSeekersTest() {
        List<JobSeeker__c> jobSeekers = [SELECT Id FROM JobSeeker__c];
        test.startTest();
        String jsonData = '["'+ jobSeekers[0].Id +'"]';
        Boolean result = HRConsoleController.deleteJobSeekers(jsonData);       
        test.stopTest();
        System.assert(result);
    }

    @isTest
    static void changeStatusTest() {
        List<JobSeeker__c> jobSeekers = [SELECT Id FROM JobSeeker__c];
        test.startTest();
        String jsonData = '["'+ jobSeekers[0].Id +'"]';
        Boolean result = HRConsoleController.changeStatus(jsonData, 'Invited');       
        test.stopTest();
        System.assert(result);
    }

    @isTest
    static void changeSpecializationTest() {
        List<JobSeeker__c> jobSeekers = [SELECT Id FROM JobSeeker__c];
        List<Specialization__c> specialization = [SELECT Id FROM Specialization__c];
        test.startTest();        
        String result = HRConsoleController.changeSpecialization(jobSeekers[0].Id, specialization[0].Id);       
        test.stopTest();
        System.assert(result == null);
    }

    @isTest
    static void invitePersonsTest() {
        List<JobSeeker__c> jobSeekers = [SELECT Id FROM JobSeeker__c];
        String jsonData = '["'+ jobSeekers[0].Id +'"]';
        test.startTest();        
        Boolean result = HRConsoleController.invitePersons(jsonData);       
        test.stopTest();
        System.assert(result);
    }

    @isTest
    static void sendInterviewTest() {
        List<JobSeeker__c> jobSeekers = [SELECT Id FROM JobSeeker__c];
        String jsonData = '["'+ jobSeekers[0].Id +'"]';
        test.startTest();        
        Boolean result = HRConsoleController.sendInterview(jsonData);       
        test.stopTest();
        System.assert(result);
    }

}
