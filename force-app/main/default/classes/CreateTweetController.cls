public class CreateTweetController {
    
    public static Twitter_Setting__mdt twitterSetting;
    
    static {
        initializeTwitterSetting();
    }
    
    public static void initializeTwitterSetting() {
        List<Twitter_Setting__mdt> twitterSettingList = TwitterMetadataSelector.getTwitterSettingMetadata();
        if (twitterSettingList.isEmpty()) {
            throw new CreateTweetControllerException('There is problems with Twitter setting metadata. Check it');
        } else {
            twitterSetting = twitterSettingList.get(0);
        }
    }
    
    @AuraEnabled
    public static String createTwitterAuthorizationURL(String contactId){
        String twitterAuthUrl = 'https://twitter.com/i/oauth2/authorize';
        
        Map<String, String> params = new Map<String, String>();
        params.put('client_id', twitterSetting.Client_Id__c);
        params.put('redirect_uri', twitterSetting.Redirect_Url__c);
        params.put('response_type', 'code');
        params.put('scope', 'users.read tweet.write tweet.read offline.access');
        params.put('user.fields', '(profile_image_url,description)');
        params.put('state', contactId);
        params.put('code_challenge', twitterSetting.Code_Challenge__c);
        params.put('code_challenge_method', 'plain');
        
        String redirectUrl = twitterAuthUrl + '?' + buildQueryString(params);
        return redirectUrl;
    }
    
    @AuraEnabled
    public static String createTwitterAuthorizationURLOAuth1(String contactId){
        TwitterCalloutService calloutService = new TwitterCalloutService();
        String authorizationURL = calloutService.createTwitterAuthorizationURLOAuth1(contactId);
        
        Map<String, String> responseParams = parseResponseParams(authorizationURL);
        String oauthToken = responseParams.get('oauth_token');
        authorizationURL = twitterSetting.Base_API_URL__c + '/oauth/authorize?oauth_token=' + oauthToken;
        return authorizationURL;
    }
    
    @AuraEnabled
    public static TwitterWrappers getAccessTokenOAuth1(String oauthToken, String oauthVerifier){
        TwitterCalloutService calloutService = new TwitterCalloutService();
        TwitterWrappers wrapper = calloutService.getAccessTokenOAuth1(oauthToken, oauthVerifier);
        return wrapper;
    }
    
    private static Map<String, String> parseResponseParams(String response) {
        Map<String, String> responseParams = new Map<String, String>();
        String[] pairs = response.split('&');
        for (String pair : pairs) {
            String[] keyValue = pair.split('=');
            if (keyValue.size() == 2) {
                responseParams.put(keyValue[0], keyValue[1]);
            }
        }
        return responseParams;
    }
    
    private static String buildQueryString(Map<String, String> params) {
        String queryString = '';
        Boolean isFirstParam = true;
        for (String key : params.keySet()) {
            if (!isFirstParam) {
                queryString += '&';
            } else {
                isFirstParam = false;
            }
            queryString += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
        }
        return queryString;
    }
    
    public static TwitterWrappers getAccessToken(String code, String contactId){
        TwitterCalloutService calloutService = new TwitterCalloutService();
        TwitterWrappers wrapper = calloutService.getAccessToken(code);
        return wrapper;
    }
    
    public static TwitterWrappers refreshAccessToken(String refreshToken){
        TwitterCalloutService calloutService = new TwitterCalloutService();
        TwitterWrappers wrapper = calloutService.refreshAccessToken(refreshToken);
        return wrapper;
    }
    
    public static TwitterWrappers.GetUserAccountInformationResponse getUserAccountInformation(String contactId, String accessToken){
        TwitterCalloutService calloutService = new TwitterCalloutService();
        if(!String.isBlank(accessToken)){
            TwitterWrappers.GetUserAccountInformationResponse wrapper = calloutService.getUserAccountInformation(accessToken);
            return wrapper;
        }
        return null;
    }
    
    public static AuraResponse getUserData(String code, String oauthToken, String oauthVerifier, String contactId){
        if (!String.isBlank(code)) {
            TwitterWrappers accessTokenWrapper = getAccessToken(code, contactId);
            if(!String.isBlank(accessTokenWrapper.access_token)){
                TwitterWrappers.GetUserAccountInformationResponse userAccountInformationWrapper = getUserAccountInformation(contactId, accessTokenWrapper.access_token);
                if(!String.isBlank(userAccountInformationWrapper.data.username)){
                    updateContactTwitterData(contactId, accessTokenWrapper, userAccountInformationWrapper);
                    return new AuraResponse(true);
                }
            }
        } else if (!String.isBlank(oauthToken) && !String.isBlank(oauthVerifier)) {
            TwitterWrappers wrapper = getAccessTokenOAuth1(oauthToken, oauthVerifier);
            updateContactTwitterOAuth1Data(contactId, wrapper.oauth_token, wrapper.oauth_token_secret, wrapper.user_id);
        }
        
        return new AuraResponse(false);
    }
    
    public static void updateContactTwitterOAuth1Data(String contactId, String oauthToken, String oauthTokenSecret, String userId){
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }
        contact.Twitter_Access_Token_OAuth1__c = oauthToken;
        contact.Twitter_Refresh_Token_OAuth1__c = oauthTokenSecret;
        contact.Twitter_Id__c = userId;
        contact.Twitter_Access_Token_OAuth1_Refresh_Time__c = DateTime.now();
        update contact;
    }
    
    public static void updateContactTwitterData(String contactId, TwitterWrappers accessTokenWrapper, TwitterWrappers.GetUserAccountInformationResponse userAccountInformationWrapper){
		List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }
        contact.Twitter_Access_Token__c = accessTokenWrapper.access_token;
        contact.Twitter_Refresh_Token__c = accessTokenWrapper.refresh_token;
        contact.Twitter_Access_Token_Refresh_Time__c = DateTime.now();
        contact.Twitter_Access_Token_OAuth1__c = null;
        contact.Twitter_Refresh_Token_OAuth1__c = null;
        contact.Twitter_Access_Token_OAuth1_Refresh_Time__c = null;
        contact.Twitter_Handle__c = userAccountInformationWrapper.data.username;
        contact.Twitter_Name__c = userAccountInformationWrapper.data.name;
        update contact;
    }
    
    @AuraEnabled
    public static AuraResponse isAccessTokenValid(String contactId){
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }else{
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        String accessToken = contact.Twitter_Access_Token__c;
        DateTime accessTokenRefreshTime = contact.Twitter_Access_Token_Refresh_Time__c;
        
        TwitterWrappers.UserData userDataObject = new TwitterWrappers.UserData();
        userDataObject.username = contact.Twitter_Handle__c;
        userDataObject.name = contact.Twitter_Name__c;
        TwitterWrappers.GetUserAccountInformationResponse response = new TwitterWrappers.GetUserAccountInformationResponse();
        response.data = userDataObject;
        
        if(!String.isBlank(accessToken) && accessTokenRefreshTime != null){
            Long timeDifferenceMillis = DateTime.now().getTime() - accessTokenRefreshTime.getTime();
            Long timeDifferenceHours = timeDifferenceMillis / (1000 * 60 * 60);
            
            if (timeDifferenceHours < 2) {
                return new AuraResponse(true, response.data, 'Authorization is active');
            } else {
                if(!String.isBlank(contact.Twitter_Refresh_Token__c)){
                    TwitterWrappers refreshTokenWrapper = refreshAccessToken(contact.Twitter_Refresh_Token__c);
                    if(!String.isBlank(refreshTokenWrapper.access_token)){
                        contact.Twitter_Access_Token__c = refreshTokenWrapper.access_token;
                        contact.Twitter_Refresh_Token__c = refreshTokenWrapper.refresh_token;
                        contact.Twitter_Access_Token_Refresh_Time__c = DateTime.now();
                        update contact;
                        return new AuraResponse(true, response.data, 'Authorization is active');
                    }else{
                        return new AuraResponse(false, 'Need re-authorization to Twitter');
                    }
                }else{
                    return new AuraResponse(false,'Need re-authorization to Twitter'); 
                }
            }
        }else{
            return new AuraResponse(false, 'Need authorization to Twitter');
        }
    }
    
    @AuraEnabled
    public static AuraResponse isAccessTokenOAuth1Valid(String contactId){
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }else{
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        String accessToken = contact.Twitter_Access_Token_Oauth1__c;
        String accessTokenSecret = contact.Twitter_Refresh_Token_Oauth1__c ;
        DateTime accessTokenRefreshTime = contact.Twitter_Access_Token_Oauth1_Refresh_Time__c;
        if(!String.isBlank(accessToken) && !String.isBlank(accessTokenSecret) && accessTokenRefreshTime != null){
            Long timeDifferenceMillis = DateTime.now().getTime() - accessTokenRefreshTime.getTime();
            Long timeDifferenceHours = timeDifferenceMillis / (1000 * 60 * 60);
            if (timeDifferenceHours < 24) {
                return new AuraResponse(true, 'Authorization is active');
            } else {
                return new AuraResponse(false, null, 'Need authorization to Twitter');
            }
        }else{
            return new AuraResponse(false, null, 'Need authorization to Twitter');
        }
    }
    
    @AuraEnabled
    public static AuraResponse sendTweet(String contactId, String tweetText, String mediaTwitterIdsJSON) {
        Logger logger = Logger.getInstance();
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if (!contactList.isEmpty()) {
            contact = contactList.get(0);
        } else {
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        String accessToken = contact.Twitter_Access_Token__c;
        try{
            List<String> mediaTwitterIds = (List<String>) JSON.deserialize(mediaTwitterIdsJSON, List<String>.class);
            TwitterCalloutService calloutService = new TwitterCalloutService();
            TwitterWrappers.SendTweetResponse sendTweetWrapper = calloutService.sendTweet(accessToken, tweetText, mediaTwitterIds);
            if (sendTweetWrapper.isSuccess && !String.isBlank(sendTweetWrapper.data.id)) {
                Tweet__c tweet = new Tweet__c();
                tweet.Tweet_ID__c = sendTweetWrapper.data.id;
                tweet.Contact__c = contactId;
                tweet.Tweet_Date__c = DateTime.now();
                tweet.Tweet_Text__c = tweetText;
                insert tweet;
                contact.Last_Tweet_Post_Date__c = dateTime.now();
                update contact;
                return new AuraResponse(true, tweet.id, 'Success');
            } else {
                return new AuraResponse(false, null, String.valueOf(sendTweetWrapper.errorResponseObj));
            }
        }catch(Exception ex){
            logger.error(null, null, 'CreateTweetController', 'sendTweet', ex.getMessage());
            logger.publish();
            return new AuraResponse(false, null, ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static AuraResponse createAttachmentToTweet(String tweetId, String mediaDetailsJSON) {
        Logger logger = Logger.getInstance();
        try {
            Map<String, Object> mediaDetails = (Map<String, Object>) JSON.deserializeUntyped(mediaDetailsJSON);
            Attachment attachment = new Attachment();
            attachment.ParentId = tweetId;
            attachment.Name = (String) mediaDetails.get('name');
            attachment.Body = EncodingUtil.base64Decode((String) mediaDetails.get('mediaBase64'));
            attachment.ContentType = (String) mediaDetails.get('type');
            insert attachment;
            return new AuraResponse(true, attachment.Id, 'Success');
        } catch(Exception ex) {
            logger.error(null, null, 'CreateTweetController', 'createAttachmentToTweet', ex.getMessage());
            logger.publish();
            return new AuraResponse(false, null, ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static AuraResponse uploadMedia(String mediaBase64, String mediaName, String mediaType, String contactId) {
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }else{
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        
        TwitterCalloutService calloutService = new TwitterCalloutService();
        
        TwitterWrappers.UploadMediaResponse uploadMediaWrapper = calloutService.uploadMedia(mediaBase64, contact.Twitter_Access_Token_OAuth1__c, contact.Twitter_Refresh_Token_OAuth1__c, contact.Twitter_Id__c);
        if(uploadMediaWrapper.isSuccess){
            return new AuraResponse(true, uploadMediaWrapper, 'Success');
        }else{
            return new AuraResponse(false, null, String.valueOf(uploadMediaWrapper.errorResponseObj));
        }
    }
    
    @AuraEnabled
    public static AuraResponse initUploadVideo(String mediaType, Integer totalBytes, String contactId) {
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }else{
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        TwitterCalloutService calloutService = new TwitterCalloutService();
        
        TwitterWrappers.UploadMediaResponse uploadMediaWrapper = calloutService.initUploadVideo(mediaType, totalBytes, contact.Twitter_Access_Token_OAuth1__c, contact.Twitter_Refresh_Token_OAuth1__c);
        if(uploadMediaWrapper.isSuccess){
            return new AuraResponse(true, uploadMediaWrapper, 'Success');
        }else{
            return new AuraResponse(false, null, String.valueOf(uploadMediaWrapper.errorResponseObj));
        }
    }
    
    @AuraEnabled
    public static AuraResponse appendUploadVideo(String mediaId, String videoChunk, Integer segmentIndex, String contactId) {
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }else{
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        
        TwitterCalloutService calloutService = new TwitterCalloutService();
        
        TwitterWrappers uploadMediaWrapper = calloutService.appendUploadVideo(mediaId, videoChunk, segmentIndex, contact.Twitter_Access_Token_OAuth1__c, contact.Twitter_Refresh_Token_OAuth1__c);
        if(uploadMediaWrapper.isSuccess){
            return new AuraResponse(true, uploadMediaWrapper, 'Success');
        }else{
            return new AuraResponse(false, null, String.valueOf(uploadMediaWrapper.errorResponseObj));
        }
    }
    
    @AuraEnabled
    public static AuraResponse finalizeUploadVideo(String mediaId, String contactId) {
        List <Contact> contactList = ContactSelector.getSpecificContact(contactId);
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }else{
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        TwitterCalloutService calloutService = new TwitterCalloutService();
        
        TwitterWrappers.UploadMediaResponse uploadMediaWrapper = calloutService.finalizeUploadVideo(mediaId, contact.Twitter_Access_Token_OAuth1__c, contact.Twitter_Refresh_Token_OAuth1__c);
        if(uploadMediaWrapper.isSuccess){
            return new AuraResponse(true, uploadMediaWrapper, 'Success');
        }else{
            return new AuraResponse(false, null, String.valueOf(uploadMediaWrapper.errorResponseObj));
        }
    }
    
    public class CreateTweetControllerException extends Exception {}
    
}