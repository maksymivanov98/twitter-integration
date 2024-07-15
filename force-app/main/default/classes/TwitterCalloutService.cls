public class TwitterCalloutService {
    
    TwitterCalloutBuilder builder;
    Twitter_Setting__mdt twitterSetting;
    
    public TwitterCalloutService() {
        this.builder = new TwitterCalloutBuilder();
        List<Twitter_Setting__mdt> twitterSettingList = TwitterMetadataSelector.getTwitterSettingMetadata();
        if (twitterSettingList.isEmpty()) {
            throw new TwitterCalloutServiceException('There is problems with Twitter setting metadata. Check it');
        } else {
            twitterSetting = twitterSettingList.get(0);
        }
    } 
     
    public TwitterWrappers getAccessToken(String code){
        TwitterCallout callout = builder.getAccessToken(code);
        TwitterWrappers wrapper = new TwitterWrappers();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers) callout.responseObj;
        }
        return wrapper;
    }
    
    public TwitterWrappers refreshAccessToken(String refreshToken){
        TwitterCallout callout = builder.refreshAccessToken(refreshToken);
        TwitterWrappers wrapper = new TwitterWrappers();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers) callout.responseObj;
        }
        return wrapper;
    }
    
    public TwitterWrappers.GetUserAccountInformationResponse getUserAccountInformation(String accessToken){
        TwitterCallout callout = builder.getUserAccountInformation(accessToken);
        TwitterWrappers.GetUserAccountInformationResponse wrapper = new TwitterWrappers.GetUserAccountInformationResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.GetUserAccountInformationResponse) callout.responseObj;
        }
        return wrapper;
    }
    
    public TwitterWrappers.SendTweetResponse sendTweet(String accessToken, String tweetText, List<String> mediaTwitterIds){
        System.debug(mediaTwitterIds);
        TwitterCallout callout = builder.sendTweet(accessToken, tweetText, mediaTwitterIds);
        TwitterWrappers.SendTweetResponse wrapper = new TwitterWrappers.SendTweetResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.SendTweetResponse) callout.responseObj;
        }
        return wrapper;
    }
    
    public TwitterWrappers.UploadMediaResponse uploadMedia(String imageBase64){
        TwitterCallout callout = builder.uploadMedia(imageBase64);
        TwitterWrappers.UploadMediaResponse wrapper = new TwitterWrappers.UploadMediaResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.UploadMediaResponse) callout.responseObj;
        }
        return wrapper;
    }
    
    public TwitterWrappers.DeleteTweetResponse deleteTweet(String tweetId, String accessToken){
        TwitterCallout callout = builder.deleteTweet(tweetId, accessToken);
        TwitterWrappers.DeleteTweetResponse wrapper = new TwitterWrappers.DeleteTweetResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.DeleteTweetResponse) callout.responseObj;
        }
        return wrapper;
    }
    
    public class TwitterCalloutServiceException extends Exception {}
    
}