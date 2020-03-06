public without sharing class JobSeekerConsoleController {

    @AuraEnabled(cacheable=true)
    public static JobSeeker__c getJobSeeker(String userId) {       
        List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>(
            [
                SELECT Specialization__c, Phone__c, Background__c, FirstName__c, LastName__c, Email__c 
                FROM JobSeeker__c 
                WHERE CreatedById = :userId
                LIMIT 1
            ]
        );      
        if (!jobSeekers.isEmpty()) {
            return jobSeekers[0];
        } else {
            return null;
        }        
    }

    @AuraEnabled
    public static Boolean deleteJobSeeker(String jobSeekerId) {       
        try {
            delete [Select Id FROM JobSeeker__c WHERE Id = :jobSeekerId];
            return true;
        } catch (DmlException e) {
            ErrorLoger__c errorLoger = new ErrorLoger__c(
                Message__c = (String)e.getMessage(),
                Cause__c = String.valueOf(e.getCause())
            );
            insert errorLoger;
            return false;
        }        
    }

}
