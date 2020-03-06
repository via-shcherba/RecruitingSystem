public class HRConsoleController {

    @AuraEnabled(cacheable=true)
    public static List<JobSeeker__c> getJobSeekers() {
        return [SELECT Id, FirstName__c, LastName__c, Phone__c, Email__c, Background__c,
                Specialization__c, Owner.Name, CreatedDate, Status__c 
                FROM  JobSeeker__c 
                LIMIT 50000];
    }

    @AuraEnabled(cacheable=true)
    public static List<Specialization__c> getSpecializations() {
        return [SELECT Id, Name FROM  Specialization__c LIMIT 50000];
    }

    @AuraEnabled
    public static Integer getTotalRecords() {
        return [SELECT COUNT() FROM JobSeeker__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<JobSeeker__c> searchJobSeekers(String searchKey) {
        return Database.query(
            ' SELECT Id, FirstName__c, LastName__c, Phone__c, Email__c, Background__c, ' +
            ' Specialization__c, Owner.Name, CreatedDate, Status__c ' +
            ' FROM  JobSeeker__c ' + 
            ' WHERE FirstName__c LIKE \''+ searchKey +'%\' ' +
            ' OR LastName__c LIKE \''+ searchKey +'%\' ' +
            ' OR Phone__c LIKE \''+ searchKey +'%\' ' +
            ' OR Email__c LIKE \''+ searchKey +'%\' ' +
            ' OR Background__c LIKE \''+ searchKey +'%\' ' +
            ' OR Specialization__r.Name LIKE \''+ searchKey +'%\' ' +
            ' OR Owner.Name LIKE \''+ searchKey +'%\' ' +
            ' OR Status__c LIKE \''+ searchKey +'%\' ' +
            ' LIMIT 50000');
    }

    @AuraEnabled
    public static Boolean updateJobSeekers(String jsonData) {        
        Map<Id, JobSeeker__c> data = new Map<Id, JobSeeker__c>(
            (List<JobSeeker__c>)JSON.deserialize(jsonData, List<JobSeeker__c>.class)
        );
        List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>([
            SELECT Id, FirstName__c, LastName__c, Phone__c, Email__c, Background__c                                                
            FROM  JobSeeker__c 
            WHERE Id IN :data.KeySet()
            LIMIT 50000 
        ]);                   
        for (JobSeeker__c jobSeeker : jobSeekers) {
            jobSeeker.FirstName__c = data.get(jobSeeker.Id).FirstName__c;
            jobSeeker.LastName__c = data.get(jobSeeker.Id).LastName__c;
            jobSeeker.Email__c = data.get(jobSeeker.Id).Email__c;
            jobSeeker.Phone__c = data.get(jobSeeker.Id).Phone__c;
            jobSeeker.Background__c = data.get(jobSeeker.Id).Background__c;
        }
        try {
            update jobSeekers;
            return true;
        } catch(DmlException e) {
            ErrorLoger__c errorLoger = new ErrorLoger__c(
                Message__c = (String)e.getMessage(),
                Cause__c = String.valueOf(e.getCause())
            );
            insert errorLoger;
            return false;
        }                
    }

    @AuraEnabled
    public static Boolean deleteJobSeekers(String jsonData) {        
        List<String> ids = (List<String>)JSON.deserialize(jsonData, List<String>.class);
        List<JobSeeker__c > jobSeekers =  [
            SELECT Id 
            FROM  JobSeeker__c 
            WHERE Id IN :ids
            LIMIT 10000
        ];    
        try {        
            delete jobSeekers;           
            return true;
        } catch(DmlException e) {
            ErrorLoger__c errorLoger = new ErrorLoger__c(
                Message__c = (String)e.getMessage(),
                Cause__c = String.valueOf(e.getCause())
            );
            insert errorLoger;
            return false;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getStatusFieldValues() { 
        List<String> values = new List<String>();    
        for (Schema.PicklistEntry item : getStatusFieldPickList()) {
            values.add(item.getValue());
        }
        return values;
    }

    @AuraEnabled
    public static Boolean changeStatus(String jsonData, String status) {  
        List<String> ids = (List<String>)JSON.deserialize(jsonData, List<String>.class);              
        List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>(
            [
                SELECT Id, Status__c 
                FROM JobSeeker__c 
                WHERE Id IN :ids 
                LIMIT 10000
            ]
        );
        if (!jobSeekers.isEmpty()) {
            for (JobSeeker__c jobSeeker : jobSeekers) {
                jobSeeker.Status__c = status;
            }
        }        
        try {
            update jobSeekers;     
            return true;     
        } catch(DmlException e) {
            ErrorLoger__c errorLoger = new ErrorLoger__c(
                Message__c = (String)e.getMessage(),
                Cause__c = String.valueOf(e.getCause())
            ); 
            insert errorLoger;
            return false;         
        }
    }

    @AuraEnabled
    public static String changeSpecialization(String recordId, String value) {        
        List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>([
            SELECT Id, Specialization__c, Owner.Name 
            FROM JobSeeker__c 
            WHERE Id=:recordId 
            LIMIT 1
        ]);        
        jobSeekers[0].Specialization__c = value;
        try {
            update jobSeekers;                           
            return getOwnerName(jobSeekers[0].Id);
        } catch(DmlException e) {           
            ErrorLoger__c errorLoger = new ErrorLoger__c(
                Message__c = (String)e.getMessage(),
                Cause__c = String.valueOf(e.getCause())
            );
            insert errorLoger;
            return null;
        }
    }

    private static String getOwnerName(Id rowId) {
        String ownerName;
        List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>([
            SELECT Owner.Name 
            FROM JobSeeker__c 
            WHERE Id=:rowId 
            LIMIT 1
        ]);     
        if (!jobSeekers.isEmpty()) {
            ownerName = jobSeekers[0].Owner.Name;
        }
        return ownerName;
    }

    private static List<Schema.PicklistEntry> getStatusFieldPickList() {
        Schema.DescribeFieldResult describe = JobSeeker__c.Status__c.getDescribe();
        Map<String, String> statusValues = new Map<String, String>();
        return describe.getPicklistValues();
    }

    @AuraEnabled
    public static Boolean invitePersons(String jsonData) {
        Boolean sendResult = false;              
        List<String> ids = (List<String>)JSON.deserialize(jsonData, List<String>.class);       
        List<EmailTemplate> templates =  new List<EmailTemplate>(
            [SELECT Id FROM EmailTemplate WHERE Name = 'InvateTemplate' LIMIT 1]
        );       
        return sendEmails(ids, templates[0].Id);
    }

    @AuraEnabled
    public static Boolean sendInterview(String jsonData) {
        Boolean sendResult = false;
        List<String> ids = (List<String>)JSON.deserialize(jsonData, List<String>.class);
        List<EmailTemplate> templates =  new List<EmailTemplate>(
            [SELECT Id FROM EmailTemplate WHERE Name = 'sendInterviewTemplate' LIMIT 1]
        );
        return sendEmails(ids, templates[0].Id);
    }

    private static Boolean sendEmails(List<String> jobSeekerIds, Id emailTemplateId) {
        Boolean sendResult = false;
        List<JobSeeker__c> jobSeekers = new List<JobSeeker__c>(
            [
                SELECT Id, Email__c, FirstName__c, LastName__c 
                FROM JobSeeker__c 
                WHERE Id IN :jobSeekerIds 
                LIMIT 10000
            ]
        );
        List<Contact> contacts = new List<Contact>();        
        if (!jobSeekers.isEmpty()) {
            for (JobSeeker__c jobSeeker : jobSeekers) {
                Contact contact = new Contact(
                    Email = jobSeeker.email__c,
                    FirstName = jobSeeker.FirstName__c,
                    LastName = jobSeeker.LastName__c
                );
                contacts.add(contact);
            }
            insert contacts;
        }             
        List<Messaging.SingleEmailMessage> emails = new  List<Messaging.SingleEmailMessage>();
        if (String.isNotBlank(emailTemplateId) && !contacts.isEmpty()) {
            for (Contact contact : contacts) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplateId);
                email.setTargetObjectId(contact.Id);               
                email.setSaveAsActivity(true);
                emails.add(email);               
            }
        }           
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);                 
        if(results[0].success) {            
            sendResult = true;
        } else {           
            ErrorLoger__c errorLoger = new ErrorLoger__c(
                Message__c = (String)results[0].errors[0].message,
                Cause__c = 'sendEmails method'
            );
            insert errorLoger;
            sendResult = false;
        }               
        delete contacts;
        return sendResult;
    }

}