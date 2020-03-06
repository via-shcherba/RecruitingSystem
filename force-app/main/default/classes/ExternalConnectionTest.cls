@isTest
private with sharing class ExternalConnectionTest {

    @testSetup
    private static void dataFactory() {
        ExternalData__c data = new ExternalData__c();
        data.userPassword__c = '29051983Slash';
        data.clientKey__c = '3MVG9n_HvETGhr3CThJ4THHSHsqY1mHBwqy2_La9nglSVpJZvLCN0zfpMKu_VHFvTcYShHtsaPWhbdDYXwToQ';
        data.authUrl__c = 'https://login.salesforce.com/services/oauth2/token';
        data.clientSecret__c = '2066ECB3995934F28207E332E6165BAE921A8D5C997EEC6A0F2E35E25FCE4EBB';
        data.operationUrl__c = 'https://ap16.salesforce.com/services/apexrest/JobSeekerWebService/';
        data.securityToken__c = 'zuUniSj5Htca15qwzhKoI7fE0';
        data.userName__c = 'third-party@system.com';
        insert data;          
    }

    @isTest
    static void getExternalJobSeekersTest() {     
        Integer countBefore = [SELECT COUNT() FROM JobSeeker__c];   
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new TokenCalloutMock());
        ExternalConnection.getExternalJobSeekers();
        test.stopTest();
        Integer countAfter = [SELECT COUNT() FROM JobSeeker__c];
        System.assert(countAfter > countBefore);
    }
}
