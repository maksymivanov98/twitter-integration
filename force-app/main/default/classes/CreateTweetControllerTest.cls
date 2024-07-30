@isTest
public class CreateTweetControllerTest {
    
    public static void createContact(){
        Contact contact = new Contact();
        contact.FirstName = 'FirstName';
        contact.LastName = 'LastName';
        contact.Email = 'test@gmail.com';
        contact.Twitter_Id__c = '1804082796924731392';
        contact.Twitter_Access_Token_OAuth1__c = '123';
        contact.Twitter_Refresh_Token_OAuth1__c = '123';
        contact.Twitter_Access_Token_OAuth1_Refresh_Time__c = DateTime.now().addHours(-1);
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
        AuraResponse response = CreateTweetController.getUserData('1234567890', '123', '123', contact.Id);
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
        AuraResponse response = CreateTweetController.sendTweet(contact.Id, 'Test Text', '["1810649797235265536"]');
        Test.stopTest();
        
        List<Tweet__c> tweetList = [SELECT Id, Tweet_Id__c, Tweet_Text__c FROM Tweet__c WHERE Tweet_Id__c = '1810649803254083689'];
        
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(1, tweetList.size());
        System.assertEquals('Test Text', tweetList.get(0).Tweet_text__c);
    }
    
    @isTest
    static void updateContactTwitterOAuth1DataTest_success() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        CreateTweetController.updateContactTwitterOAuth1Data(contact.Id, '12345', '12345', '1804082796924731392');
        Test.stopTest();
        
        contact = [SELECT Id, Twitter_Access_Token_OAuth1__c, Twitter_Refresh_Token_OAuth1__c FROM Contact LIMIT 1];
        System.assertEquals('12345', contact.Twitter_Access_Token_OAuth1__c);
        System.assertEquals('12345', contact.Twitter_Refresh_Token_OAuth1__c);
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
    static void initUploadVideoTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.uploadMediaSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.initUploadVideo('video/mp4', 1000, contact.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseObj);
    }
    
    @isTest
    static void appendUploadVideoTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.uploadMediaSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.appendUploadVideo('123', 'videobody', 0, contact.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
    }
    
    @isTest
    static void finalizeUploadVideoTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.uploadMediaSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.finalizeUploadVideo('123', contact.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseObj);
    }
    
    @isTest
    static void createTwitterAuthorizationURLTest() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenOAuth1Success());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        String authorizationURL = CreateTweetController.createTwitterAuthorizationURL(contact.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, authorizationURL);
    }
    
    @isTest
    static void createTwitterAuthorizationURLOAuth1Test() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getRequestTokenOAuth1Success());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Test.startTest();
        String authorizationURL = CreateTweetController.createTwitterAuthorizationURLOAuth1(contact.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, authorizationURL);
    }
    
    @isTest
    static void getAccessTokenOAuth1Test_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenOAuth1Success());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        TwitterWrappers wrapper = CreateTweetController.getAccessTokenOAuth1('123', '123');
        Test.stopTest();
        
        System.assertNotEquals(null, wrapper);
    }
    
    @isTest
    static void logoutOfTwitterTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        AuraResponse response = CreateTweetController.logoutOfTwitter(contact.Id);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
    }
    
        @isTest
    static void testCreateAttachmentToTweet_Success() {
        Tweet__c tweet = [SELECT Id FROM Tweet__c LIMIT 1];

        String mediaDetailsJSON = JSON.serialize(new Map<String, Object>{
            'name' => 'TestFile.jpg',
            'mediaBase64' => EncodingUtil.base64Encode(Blob.valueOf('Test file content')),
            'type' => 'image/jpeg'
        });

        Test.startTest();
        AuraResponse response = CreateTweetController.createAttachmentToTweet(tweet.Id, mediaDetailsJSON);
        Test.stopTest();

        System.assert(response.isSuccess, 'Expected the response to be successful.');
        System.assertEquals('Success', response.message, 'Expected the success message.');

        Attachment attachment = [SELECT Id, Name, ParentId, Body, ContentType FROM Attachment WHERE Id = :(Id)response.responseObj];
        System.assertEquals('TestFile.jpg', attachment.Name, 'Expected the attachment name to match.');
        System.assertEquals(tweet.Id, attachment.ParentId, 'Expected the attachment ParentId to match the Tweet Id.');
        System.assertEquals('image/jpeg', attachment.ContentType, 'Expected the attachment ContentType to match.');
        System.assertEquals('Test file content', attachment.Body.toString(), 'Expected the attachment body to match the file content.');
    }
    
    @isTest
    static void testCreateAttachmentToTweet_Exception() {
        String mediaDetailsJSON = JSON.serialize(new Map<String, Object>{
            'name' => 'TestFile.jpg',
            'mediaBase64' => 'InvalidBase64String',
            'type' => 'image/jpeg'
        });

        Test.startTest();
        AuraResponse response = CreateTweetController.createAttachmentToTweet(null, mediaDetailsJSON);
        Test.stopTest();

        List<Attachment> attachments = [SELECT Id FROM Attachment];
        System.assertEquals(0, attachments.size());
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
    static void isAccessTokenOAuth1ValidTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        AuraResponse response = CreateTweetController.isAccessTokenOAuth1Valid(contact.Id);
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
        AuraResponse response = CreateTweetController.sendTweet(contact.Id, 'Test Text', '["1810649797235265536"]');
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