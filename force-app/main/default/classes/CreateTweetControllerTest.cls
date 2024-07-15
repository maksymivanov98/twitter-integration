@isTest
public class CreateTweetControllerTest {
    
    public static void createContact(){
        Contact contact = new Contact();
        contact.FirstName = 'FirstName';
        contact.LastName = 'LastName';
        contact.Email = 'test@gmail.com';
        insert contact;
    }
    
    public static void createTweet(){
        Tweet__c tweet = new Tweet__c();
        tweet.Tweet_ID__c = '123';
        insert tweet;
    }
    
    @testSetup
    public static void createData() {
        createContact();
        createTweet();
    }
    
    @isTest
    static void getAccessTokenTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        TwitterWrappers wrapper = CreateTweetController.getAccessToken('1234567890', contact.Id);
        Test.stopTest();
        
        System.assertEquals('dE1nM0FDdlZKcWRIRDFnZWRCM1RFTnliMzJtdjFpMGExMlczY0c3WnN0MGdwOjE3MjA1MjE2MDA5NjE6MTowOmF0OjE', wrapper.access_token);
        System.assertEquals('VFhvX05leFZXOHJCNVQ0RnVsNjRTYnp1X3JzSHA3MWp6Ty1SVnA3cXpuZG9wOjE3MjA1MjE2MDA5NjE6MToxOnJ0OjE', wrapper.refresh_token);
        System.assertEquals(7200, wrapper.expires_in);
    }
    
    @isTest
    static void refreshAccessTokenTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.refreshAccessTokenSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Test.startTest();
        TwitterWrappers wrapper = CreateTweetController.refreshAccessToken('1234567890');
        Test.stopTest();
        
        System.assertEquals('dE1nM0FDdlZKcWRIRDFnZWRCM1RFTnliMzJtdjFpMGExMlczY0c3WnN0MGdwOjE3MjA1MjE2MDA5NjE6MTowOmF0OjE', wrapper.access_token);
        System.assertEquals('VFhvX05leFZXOHJCNVQ0RnVsNjRTYnp1X3JzSHA3MWp6Ty1SVnA3cXpuZG9wOjE3MjA1MjE2MDA5NjE6MToxOnJ0OjE', wrapper.refresh_token);
        System.assertEquals(7200, wrapper.expires_in);
    }
    
    @isTest
    static void getUserAccountInformationTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getUserDataSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        TwitterWrappers.GetUserAccountInformationResponse wrapper = CreateTweetController.getUserAccountInformation(contact.Id, '1234567890');
        Test.stopTest();
        
        System.assertEquals('1804082796924731392', wrapper.data.id);
        System.assertEquals('Maksym Ivanov', wrapper.data.name);
        System.assertEquals('MaksymIvan97376', wrapper.data.username);
    }
    
    @isTest
    static void getUserDataTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenSuccess());
        multiMock.mockList.add(new Twitter_API_MultiMock.getUserDataSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.getUserData('1234567890', contact.Id);
        Test.stopTest();
        
        contact = [SELECT Id, Twitter_Access_Token__c, Twitter_Refresh_Token__c, Twitter_Handle__c, Twitter_Name__c FROM Contact LIMIT 1];
        
        System.assertEquals(true, response.isSuccess);
        System.assertEquals('dE1nM0FDdlZKcWRIRDFnZWRCM1RFTnliMzJtdjFpMGExMlczY0c3WnN0MGdwOjE3MjA1MjE2MDA5NjE6MTowOmF0OjE', contact.Twitter_Access_Token__c);
        System.assertEquals('VFhvX05leFZXOHJCNVQ0RnVsNjRTYnp1X3JzSHA3MWp6Ty1SVnA3cXpuZG9wOjE3MjA1MjE2MDA5NjE6MToxOnJ0OjE', contact.Twitter_Refresh_Token__c);
        System.assertEquals('MaksymIvan97376', contact.Twitter_Handle__c);
        System.assertEquals('Maksym Ivanov', contact.Twitter_Name__c);
    }
    
    @isTest
    static void sendTweetTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.sendTweetSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.sendTweet(contact.Id, 'Test Text', '["1810649797235265536"]', '[{"name":"kitty-cat.png","type":"image/png","base64":"imagebody"}]');
        Test.stopTest();
        
        List<Tweet__c> tweetList = [SELECT Id, Tweet_Id__c, Tweet_Text__c FROM Tweet__c WHERE Tweet_Id__c = '1810649803254083689'];
        
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(1, tweetList.size());
        System.assertEquals('Test Text', tweetList.get(0).Tweet_text__c);
    }
    
    @isTest
    static void uploadMediaTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.uploadMediaSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.uploadMedia('imagebody', 'image', 'image/png', contact.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseObj);
    }
    
    @isTest
    static void createTwitterAuthorizationURLTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        String authorizationURL = CreateTweetController.createTwitterAuthorizationURL(contact.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, authorizationURL);
    }
    
    @isTest
    static void isAccessTokenValidTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.refreshAccessTokenSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Test.startTest();
        AuraResponse response = CreateTweetController.isAccessTokenValid('1234567890');
        Test.stopTest();
        
        System.assertEquals(false, response.isSuccess);
    }
    
    @isTest
    static void isAccessTokenValidWithActiveAccessTokenTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        contact.Twitter_Access_Token__c = '123';
        contact.Twitter_Refresh_Token__c = '123';
        contact.Twitter_Access_Token_Refresh_Time__c = DateTime.now().addHours(-1);
        update contact;
        Test.startTest();
        AuraResponse response = CreateTweetController.isAccessTokenValid(contact.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
    }
    
    @isTest
    static void isAccessTokenValidWithInactiveAccessTokenTest() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.refreshAccessTokenSuccess());
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        contact.Twitter_Access_Token__c = '123';
        contact.Twitter_Refresh_Token__c = '123';
        contact.Twitter_Access_Token_Refresh_Time__c = DateTime.now().addHours(-5);
        update contact;
        Test.startTest();
        AuraResponse response = CreateTweetController.isAccessTokenValid(contact.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
    }
    
    @isTest
    static void isAccessTokenValidWithoutAccessTokenTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.isAccessTokenValid(contact.Id);
        Test.stopTest();
        
        System.assertEquals(false, response.isSuccess);
    }
    
    @isTest
    static void getAccessTokenTest_failed() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenFailed());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        TwitterWrappers wrapper = CreateTweetController.getAccessToken('1234567890', contact.Id);
        Test.stopTest();
        
        List <Twitter_Log__c> twitterLogList = [SELECT Id FROM Twitter_Log__c];
        
        System.assertEquals(null, wrapper.access_token);
        System.assertEquals(null, wrapper.refresh_token);
        System.assertEquals(1, twitterLogList.size());
    }
    
    @isTest
    static void refreshAccessTokenTest_failed() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.refreshAccessTokenFailed());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Test.startTest();
        TwitterWrappers wrapper = CreateTweetController.refreshAccessToken('1234567890');
        Test.stopTest();
        
        List <Twitter_Log__c> twitterLogList = [SELECT Id FROM Twitter_Log__c];
        
        System.assertEquals(null, wrapper.access_token);
        System.assertEquals(null, wrapper.refresh_token);
        System.assertEquals(1, twitterLogList.size());
    }
    
    @isTest
    static void getUserAccountInformationTest_failed() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getUserDataFailed());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        TwitterWrappers.GetUserAccountInformationResponse wrapper = CreateTweetController.getUserAccountInformation(contact.Id, '1234567890');
        Test.stopTest();
        
        List <Twitter_Log__c> twitterLogList = [SELECT Id FROM Twitter_Log__c];
        
        System.assertEquals(null, wrapper.data);
        System.assertEquals(1, twitterLogList.size());
    }
    
    @isTest
    static void sendTweetTest_failed() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.sendTweetFailed());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.sendTweet(contact.Id, 'Test Text', '["1810649797235265536"]', '[{"name":"kitty-cat.png","type":"image/png","base64":"imagebody"}]');
        Test.stopTest();
        
        List<Tweet__c> tweetList = [SELECT Id, Tweet_Id__c, Tweet_Text__c FROM Tweet__c WHERE Tweet_Id__c = '1810649803254083689'];
        List <Twitter_Log__c> twitterLogList = [SELECT Id FROM Twitter_Log__c];
        
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(0, tweetList.size());
        System.assertEquals(1, twitterLogList.size());
    }
    
    @isTest
    static void uploadMediaTest_failed() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.uploadMediaFailed());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.uploadMedia('imagebody', 'image', 'image/png', contact.Id);
        Test.stopTest();
        List <Twitter_Log__c> twitterLogList = [SELECT Id FROM Twitter_Log__c];
        
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(1, twitterLogList.size());
    }
    
}