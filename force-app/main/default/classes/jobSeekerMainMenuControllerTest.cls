@isTest
private with sharing class jobSeekerMainMenuControllerTest {

    @isTest
    static void getUserNameTest() {
        Id currentUserId = UserInfo.getUserId();
        test.startTest();
        User result = jobSeekerMainMenuController.getUserInfo(currentUserId);
        test.stopTest();
        System.assert(result != null);
    }
}
