@isTest
public class TwitterWrappersTest {
    
    @IsTest
    static void parseGetUserAccountInformationResponseTest() {
        String json = '{"data": {"username": "testuser", "name": "Test User", "id": "12345"}}';
        TwitterWrappers.GetUserAccountInformationResponse response = TwitterWrappers.parseGetUserAccountInformationResponse(json);
        
        System.assertNotEquals(null, response);
        System.assertEquals('testuser', response.data.username);
        System.assertEquals('Test User', response.data.name);
        System.assertEquals('12345', response.data.id);
    }
    
    @IsTest
    static void parseAccessTokenResponseTest() {
        String json = '{"access_token": "testtoken", "token_type": "Bearer", "refresh_token": "testrefreshtoken", "scope": "read", "expires_in": 3600}';
        TwitterWrappers response = TwitterWrappers.parseAccessTokenResponse(json);
        
        System.assertNotEquals(null, response);
        System.assertEquals('testtoken', response.access_token);
        System.assertEquals('Bearer', response.token_type);
        System.assertEquals('testrefreshtoken', response.refresh_token);
        System.assertEquals('read', response.scope);
        System.assertEquals(3600, response.expires_in);
    }
    
    @IsTest
    static void parseSendTweetResponseTest() {
        String json = '{"data": {"text": "Hello World", "id": "12345", "edit_history_tweet_ids": ["12345", "67890"]}}';
        TwitterWrappers.SendTweetResponse response = TwitterWrappers.parseSendTweetResponse(json);
        
        System.assertNotEquals(null, response);
        System.assertEquals('Hello World', response.data.text);
        System.assertEquals('12345', response.data.id);
        System.assertEquals(2, response.data.edit_history_tweet_ids.size());
        System.assertEquals('12345', response.data.edit_history_tweet_ids[0]);
        System.assertEquals('67890', response.data.edit_history_tweet_ids[1]);
    }
    
    @IsTest
    static void parseUploadMediaResponseTest() {
        String json = '{"size": 1024, "expires_after_secs": 3600, "media_id_string": "67890", "media_id_salesforce": "sf12345", "image": {"image_type": "image/jpeg", "h": 800, "w": 600}, "media_id": 67890}';
        TwitterWrappers.UploadMediaResponse response = TwitterWrappers.parseUploadMediaResponse(json);
        
        System.assertNotEquals(null, response);
        System.assertEquals(1024, response.size);
        System.assertEquals(3600, response.expires_after_secs);
        System.assertEquals('67890', response.media_id_string);
        System.assertEquals('sf12345', response.media_id_salesforce);
        System.assertEquals('image/jpeg', response.image.image_type);
        System.assertEquals(800, response.image.h);
        System.assertEquals(600, response.image.w);
        System.assertEquals(67890, response.media_id);
    }
    
    @IsTest
    static void parseDeleteTweetResponseTest() {
        String json = '{"data": {"deleted": true}}';
        TwitterWrappers.DeleteTweetResponse response = TwitterWrappers.parseDeleteTweetResponse(json);
        
        System.assertNotEquals(null, response);
        System.assertEquals(true, response.data.deleted);
    }
    
}