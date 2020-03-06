public with sharing class jobSeekerMainMenuController {

    @AuraEnabled(cacheable=true)
    public static User getUserInfo(String userId) {        
        List<User> users = new List<User>(
            [SELECT Name, FirstName, LastName, Email FROM User WHERE Id= :userId LIMIT 1]
        );        
        if (!users.isEmpty()) {
            return users[0];
        } else {
            return null;
        }       
    }
    
}
