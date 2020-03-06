public with sharing class JobSeekerChanging {

    public static List<JobSeeker__c> setOwner(List<JobSeeker__c> newTrigger) {    
        Id headHRId = getHeadHRDepartmentId();       
        if (String.isNotBlank(headHRId)) { 
            Set<Id> specializations = new Set<Id>();
            for (JobSeeker__c jobSeeker : newTrigger) {
                if (jobSeeker.Specialization__c != null) {
                    specializations.add(jobSeeker.Specialization__c);
                }
            }            
            Map<Id, Id> hrs = new Map<Id, Id>();
            if (!specializations.isEmpty()) {
                for (HRSpecializeItem__c hrsp : [SELECT User__c, User__r.Name, Specialization__c 
                                FROM HRSpecializeItem__c 
                                WHERE Specialization__c IN :specializations
                                LIMIT 10000]) {
                    hrs.put(hrsp.Specialization__c, hrsp.User__c);
                }
            }                     
            for (JobSeeker__c jobSeeker : newTrigger) {                              
                if (hrs.containsKey(jobSeeker.Specialization__c)) {                                       
                    jobSeeker.OwnerId = hrs.get(jobSeeker.Specialization__c);
                } else {                   
                    jobSeeker.OwnerId = headHRId;
                }
            }            
        }
        return newTrigger;
    }  
    
    private static Id getHeadHRDepartmentId() { 
        Id headHrId;       
        List<User> users = new List<User>([
            SELECT Id 
            FROM User 
            WHERE UserRole.Name = 'Head of HR Department'
            LIMIT 1
        ]);
        if (!users.isEmpty()) {
            headHrId = users[0].Id;
        } 
        return headHrId;       
    }

}
