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
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public TwitterWrappers refreshAccessToken(String refreshToken){
        TwitterCallout callout = builder.refreshAccessToken(refreshToken);
        TwitterWrappers wrapper = new TwitterWrappers();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
     
    public TwitterWrappers.GetUserAccountInformationResponse getUserAccountInformation(String accessToken){
        TwitterCallout callout = builder.getUserAccountInformation(accessToken);
        TwitterWrappers.GetUserAccountInformationResponse wrapper = new TwitterWrappers.GetUserAccountInformationResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.GetUserAccountInformationResponse) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public TwitterWrappers.SendTweetResponse sendTweet(String accessToken, String tweetText, List<String> mediaTwitterIds){
        System.debug(mediaTwitterIds);
        TwitterCallout callout = builder.sendTweet(accessToken, tweetText, mediaTwitterIds);
        TwitterWrappers.SendTweetResponse wrapper = new TwitterWrappers.SendTweetResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.SendTweetResponse) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public TwitterWrappers.UploadMediaResponse uploadMedia(String imageBase64, String accessToken, String accessTokenSecret, String userId){
        TwitterCallout callout = builder.uploadMedia(imageBase64, accessToken, accessTokenSecret, userId);
        TwitterWrappers.UploadMediaResponse wrapper = new TwitterWrappers.UploadMediaResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.UploadMediaResponse) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }

    public TwitterWrappers.UploadMediaResponse initUploadVideo(String mediaType, Integer totalBytes, String accessToken, String accessTokenSecret){
        TwitterCallout callout = builder.initUploadVideo(mediaType, totalBytes, accessToken, accessTokenSecret);
        TwitterWrappers.UploadMediaResponse wrapper = new TwitterWrappers.UploadMediaResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.UploadMediaResponse) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public TwitterWrappers appendUploadVideo(String mediaId, String videoChunk, Integer segmentIndex, String accessToken, String accessTokenSecret){
        TwitterCallout callout = builder.appendUploadVideo(mediaId, videoChunk, segmentIndex, accessToken, accessTokenSecret);
        TwitterWrappers wrapper = new TwitterWrappers();
        if(callout.isSuccess()){
            wrapper.isSuccess = true;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public TwitterWrappers.UploadMediaResponse finalizeUploadVideo(String mediaId, String accessToken, String accessTokenSecret){
        TwitterCallout callout = builder.finalizeUploadVideo(mediaId, accessToken, accessTokenSecret);
        TwitterWrappers.UploadMediaResponse wrapper = new TwitterWrappers.UploadMediaResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.UploadMediaResponse) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public TwitterWrappers.DeleteTweetResponse deleteTweet(String tweetId, String accessToken){
        TwitterCallout callout = builder.deleteTweet(tweetId, accessToken);
        TwitterWrappers.DeleteTweetResponse wrapper = new TwitterWrappers.DeleteTweetResponse();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers.DeleteTweetResponse) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public String createTwitterAuthorizationURLOAuth1(String contactId){
        TwitterCallout callout = builder.createTwitterAuthorizationURLOAuth1(contactId);
        if(callout.isSuccess()){
            return (String)callout.responseObj;
        }
        return null;
    }
    
    public TwitterWrappers getAccessTokenOAuth1(String oauthToken, String oauthVerifier){
        TwitterCallout callout = builder.getAccessTokenOAuth1(oauthToken, oauthVerifier);
        TwitterWrappers wrapper = new TwitterWrappers();
        if(callout.isSuccess()){
            wrapper = (TwitterWrappers) callout.responseObj;
            wrapper.isSuccess = true;
        }else{
            wrapper.errorResponseObj = callout.responseObj;
            wrapper.isSuccess = false;
        }
        return wrapper;
    }
    
    public class TwitterCalloutServiceException extends Exception {}
    
}