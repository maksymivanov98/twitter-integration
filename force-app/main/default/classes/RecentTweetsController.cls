public class RecentTweetsController {
    
    @AuraEnabled
    public static Integer getTweetCount(Id contactId) {
        return [SELECT COUNT() FROM Tweet__c WHERE Contact__c = :contactId];
    }
    
    @AuraEnabled
    public static List<Tweet__c> getTweets(Id contactId, Integer pageNumber, Integer pageSize) {
        Integer offset = (pageNumber - 1) * pageSize;
        return [
            SELECT Id
            , Tweet_Text__c
            , Tweet_Date__c
            , Tweet_Id__c
            FROM Tweet__c 
            WHERE Contact__c = :contactId 
            ORDER BY Tweet_Date__c DESC
            LIMIT :pageSize OFFSET :offset
        ];
    }
    
    @AuraEnabled
    public static AuraResponse deleteTweet(String tweetId) {
        Logger logger = Logger.getInstance();
        Tweet__c tweet = [SELECT Id, Tweet_Id__c, Contact__r.Twitter_Access_Token__c FROM Tweet__c WHERE Tweet_Id__c = :tweetId LIMIT 1];
        TwitterCalloutService calloutService = new TwitterCalloutService();
        
        TwitterWrappers.DeleteTweetResponse deleteTweetWrapper = calloutService.deleteTweet(tweetId, tweet.Contact__r.Twitter_Access_Token__c);
        
        try{
            if (deleteTweetWrapper.data.deleted) {
                delete tweet;
                return new AuraResponse(true, deleteTweetWrapper, 'Success');
            }else{
                return new AuraResponse(false, deleteTweetWrapper.errorResponseObj, 'Failed');
            }
        }catch(Exception ex){
            logger.error(null, null, 'RecentTweetsController', 'deleteTweet', ex.getMessage());
            logger.publish();
            return new AuraResponse(false, ex.getMessage());
        }
    }
    
}