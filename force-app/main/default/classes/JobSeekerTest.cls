@isTest
private class JobSeekerTest {

    @TestSetup
    static void dataFactory(){
        UserRole userRoleHR = [SELECT Id FROM userRole WHERE Name = 'Hr' LIMIT 1];    
        UserRole userRoleHead = [SELECT Id FROM userRole WHERE Name = 'Head of HR Department' LIMIT 1];   
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];    
        List<User> users = new List<User>();
        User newUser1 = new User(
            Alias = 'testuser', Email = 'testuser@test.com', 
            EmailEncodingKey = 'UTF-8', FirstName = 'ABC', LastName ='Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey ='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testuser123212321@test.com',
            UserRoleId = userRoleHR.Id
        );
        users.add(newUser1);        
        insert users;                   
    }

    @isTest
    static void insertJobSeekerTestWithExistSpecialization() {         
        Specialization__c specialization = new Specialization__c();
        specialization.Name = 'F#';
        insert specialization;    
        User user = [SELECT Id FROM User WHERE LastName ='Test'];
        HRSpecializeItem__c hR = new HRSpecializeItem__c();
        hR.Specialization__c = specialization.Id;
        hR.User__c = user.Id;                
        insert hR;
        JobSeeker__c jobSeekerBefore = new JobSeeker__c();
        jobSeekerBefore.LastName__c = 'test';
        jobSeekerBefore.Email__c = 'test@ds.com';
        jobSeekerBefore.Specialization__c = specialization.Id;
        test.startTest();
        insert jobSeekerBefore;
        test.stopTest();
        JobSeeker__c jobSeekerAfter = [SELECT OwnerId FROM JobSeeker__c WHERE Id = :jobSeekerBefore.Id LIMIT 1];               
        System.assertNotEquals(UserInfo.getUserId(), jobSeekerAfter.OwnerId); 
        System.assertEquals(user.Id, jobSeekerAfter.OwnerId);
    }

    @isTest
    static void insertJobSeekerTestWithoutExistSpecialization() {
        Specialization__c specialization = new Specialization__c();
        specialization.Name = 'Apex';
        insert specialization;                               
        JobSeeker__c jobSeekerBefore = new JobSeeker__c();
        jobSeekerBefore.LastName__c = 'test';
        jobSeekerBefore.Email__c = 'test@ds.com';
        jobSeekerBefore.Specialization__c = specialization.Id;
        test.startTest();
        insert jobSeekerBefore;       
        test.stopTest();
        JobSeeker__c jobSeekerAfter = [SELECT OwnerId, Owner.Name FROM JobSeeker__c WHERE Id = :jobSeekerBefore.Id LIMIT 1];                                   
        System.assertNotEquals(UserInfo.getUserId(), jobSeekerAfter.OwnerId); 
        User user = [SELECT Id FROM User WHERE LastName ='Test'];
        System.assertNotEquals(user.Id, jobSeekerAfter.OwnerId);       
    }

    @isTest
    static void updateJobSeekerTest() {
        List<Specialization__c> specializations = new List<Specialization__c>();
        Specialization__c specialization1 = new Specialization__c();
        specialization1.Name = 'Apex';
        specializations.add(specialization1);
        Specialization__c specialization2 = new Specialization__c();
        specialization2.Name = 'PHP';
        specializations.add(specialization2);
        insert specializations;       
        User user = [SELECT Id FROM User WHERE LastName ='Test']; 
        HRSpecializeItem__c hR = new HRSpecializeItem__c();
        hR.Specialization__c = specializations[0].Id;
        hR.User__c = user.Id;                
        insert hR;                      
        JobSeeker__c jobSeeker = new JobSeeker__c();
        jobSeeker.LastName__c = 'test';
        jobSeeker.Email__c = 'test@ds.com';
        jobSeeker.Specialization__c = specializations[0].Id;       
        insert jobSeeker;   
        JobSeeker__c jobSeekerUpdate = [SELECT OwnerId, Specialization__c  FROM JobSeeker__c WHERE Id = :jobSeeker.Id LIMIT 1];
        test.startTest();
        jobSeekerUpdate.Specialization__c = specializations[1].Id;
        update jobSeekerUpdate;
        test.stopTest();
        JobSeeker__c jobSeekerUpdated = [SELECT OwnerId, Specialization__c  FROM JobSeeker__c WHERE Id = :jobSeeker.Id LIMIT 1];
        System.assertNotEquals(UserInfo.getUserId(), jobSeekerUpdated.OwnerId); 
        System.assertNotEquals(user.Id, jobSeekerUpdated.OwnerId);
    }

}