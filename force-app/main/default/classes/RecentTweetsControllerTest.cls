@isTest
public class RecentTweetsControllerTest {
    
    public static Contact createContact(){
        Contact contact = new Contact();
        contact.FirstName = 'FirstName';
        contact.LastName = 'LastName';
        contact.Email = 'test@gmail.com';
        insert contact;
        return contact;
    }
    
    public static void createTweet(Id contactId){
        Tweet__c tweet = new Tweet__c();
        tweet.Tweet_ID__c = '123';
        tweet.Contact__c = contactId;
        insert tweet;
    }
    
    @testSetup
    public static void createData() {
        Contact contact = createContact();
        createTweet(contact.Id);
    }
    
    @isTest
    static void deleteTweetTest_success() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.deleteTweetSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Tweet__c tweet = [SELECT Id, Tweet_Id__c FROM Tweet__c LIMIT 1];
        
        Test.startTest();
        AuraResponse response = RecentTweetsController.deleteTweet(tweet.Tweet_Id__c);
        Test.stopTest();
        
        System.assertEquals(true, response.isSuccess);
    }
    
    @isTest
    static void getTweetCountTest() {
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        Integer numberTweet = RecentTweetsController.getTweetCount(contact.Id);
        Test.stopTest();
        
        System.assertEquals(1, numberTweet);
    }
    
    @isTest
    static void getTweetsTest() {
        
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        List<Tweet__c> tweetList = RecentTweetsController.getTweets(contact.Id, 1, 3);
        Test.stopTest();
        
        System.assertEquals(1, tweetList.size());
    }
    
    @isTest
    static void deleteTweetTest_failed() {
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.deleteTweetFailed());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Tweet__c tweet = [SELECT Id, Tweet_Id__c FROM Tweet__c LIMIT 1];
        
        Test.startTest();
        AuraResponse response = RecentTweetsController.deleteTweet(tweet.Tweet_Id__c);
        Test.stopTest();
        
        List <Twitter_Log__c> twitterLogList = [SELECT Id FROM Twitter_Log__c];
        
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(1, twitterLogList.size());
    }
    
    
}