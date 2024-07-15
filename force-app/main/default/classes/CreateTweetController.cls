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
    
    public static AuraResponse getUserData(String code, String contactId){
        TwitterWrappers accessTokenWrapper = getAccessToken(code, contactId);
        if(!String.isBlank(accessTokenWrapper.access_token)){
            TwitterWrappers.GetUserAccountInformationResponse userAccountInformationWrapper = getUserAccountInformation(contactId, accessTokenWrapper.access_token);
            if(!String.isBlank(userAccountInformationWrapper.data.username)){
                updateContactTwitterData(contactId, accessTokenWrapper, userAccountInformationWrapper);
                return new AuraResponse(true);
            }
        }
        return new AuraResponse(false);
    }
    
    public static void updateContactTwitterData(String contactId, TwitterWrappers accessTokenWrapper, TwitterWrappers.GetUserAccountInformationResponse userAccountInformationWrapper){
        List <Contact> contactList = [SELECT Id, Twitter_Handle__c, Twitter_Name__c, Twitter_Access_Token__c, Twitter_Refresh_Token__c, Twitter_Access_Token_Refresh_Time__c FROM Contact WHERE Id =: contactId];
        Contact contact;
        if(!contactList.isEmpty()){
            contact = contactList.get(0);
        }
        contact.Twitter_Access_Token__c = accessTokenWrapper.access_token;
        contact.Twitter_Refresh_Token__c = accessTokenWrapper.refresh_token;
        contact.Twitter_Access_Token_Refresh_Time__c = DateTime.now();
        contact.Twitter_Handle__c = userAccountInformationWrapper.data.username;
        contact.Twitter_Name__c = userAccountInformationWrapper.data.name;
        update contact;
    }
    
    @AuraEnabled
    public static AuraResponse isAccessTokenValid(String contactId){
        List <Contact> contactList = [SELECT Id
                                      , Twitter_Access_Token__c
                                      , Twitter_Access_Token_Refresh_Time__c
                                      , Twitter_Refresh_Token__c 
                                      , Twitter_Handle__c
                                      , Twitter_Name__c
                                      FROM Contact WHERE Id =: contactId];
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
    public static AuraResponse sendTweet(String contactId, String tweetText, String mediaTwitterIdsJSON, String mediaDetailsJSON) {
        Logger logger = Logger.getInstance();
        List<Contact> contactList = [SELECT Id, Twitter_Access_Token__c, Last_Tweet_Post_Date__c, Twitter_Access_Token_Refresh_Time__c, Twitter_Refresh_Token__c FROM Contact WHERE Id = :contactId];
        Contact contact;
        if (!contactList.isEmpty()) {
            contact = contactList.get(0);
        } else {
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        String accessToken = contact.Twitter_Access_Token__c;

        try{
            List<String> mediaTwitterIds = (List<String>) JSON.deserialize(mediaTwitterIdsJSON, List<String>.class);
            List<Object> mediaDetailsUntyped = (List<Object>) JSON.deserializeUntyped(mediaDetailsJSON);
            List<Map<String, String>> mediaDetails = new List<Map<String, String>>();
            
            for (Object obj : mediaDetailsUntyped) {
                Map<String, Object> mapObj = (Map<String, Object>) obj;
                Map<String, String> stringMap = new Map<String, String>();
                for (String key : mapObj.keySet()) {
                    stringMap.put(key, String.valueOf(mapObj.get(key)));
                }
                mediaDetails.add(stringMap);
            }
            
            TwitterCalloutService calloutService = new TwitterCalloutService();
            TwitterWrappers.SendTweetResponse sendTweetWrapper = calloutService.sendTweet(accessToken, tweetText, mediaTwitterIds);
            
            if (!String.isBlank(sendTweetWrapper.data.id)) {
                Tweet__c tweet = new Tweet__c();
                tweet.Tweet_ID__c = sendTweetWrapper.data.id;
                tweet.Contact__c = contactId;
                tweet.Tweet_Date__c = DateTime.now();
                tweet.Tweet_Text__c = tweetText;
                insert tweet;
                contact.Last_Tweet_Post_Date__c = dateTime.now();
                update contact;
                if (mediaDetails != null && !mediaDetails.isEmpty()) {
                    List<Attachment> attachmentList = new List<Attachment>();
                    for (Map<String, String> mediaDetail : mediaDetails) {
                        Attachment attachment = new Attachment();
                        attachment.ParentId = tweet.Id;
                        attachment.Name = mediaDetail.get('name');
                        attachment.Body = EncodingUtil.base64Decode(mediaDetail.get('base64'));
                        attachment.ContentType = mediaDetail.get('type');
                        attachmentList.add(attachment);
                    }
                    insert attachmentList;
                }
                return new AuraResponse(true);
            }
        }catch(Exception ex){
            logger.error(null, null, 'CreateTweetController', 'sendTweet', ex.getMessage());
        }
        logger.publish();
        return new AuraResponse(false);
    }
    
    @AuraEnabled
    public static AuraResponse uploadMedia(String mediaBase64, String mediaName, String mediaType, String contactId) {
        List<Contact> contactList = [SELECT Id FROM Contact WHERE Id = :contactId];
        Contact contact;
        if (!contactList.isEmpty()) {
            contact = contactList.get(0);
        } else {
            return new AuraResponse(false, 'There is no contact with this ID');
        }
        
        TwitterCalloutService calloutService = new TwitterCalloutService();
        
        TwitterWrappers.UploadMediaResponse uploadMediaWrapper = calloutService.uploadMedia(mediaBase64);
        if (!String.isBlank(uploadMediaWrapper.media_id_string)) {
            return new AuraResponse(true, uploadMediaWrapper, 'Success');
        }
        return new AuraResponse(false);
    }
    
    public class CreateTweetControllerException extends Exception {}
    
}