public class TwitterCalloutBuilder {
    
    private String baseOrganizationEndpoint;
    private String uploadMediaEndpoint;
    public Twitter_Setting__mdt twitterSetting;
    
    public TwitterCalloutBuilder() {
        List<Twitter_Setting__mdt> twitterSettingList = TwitterMetadataSelector.getTwitterSettingMetadata();
        if (twitterSettingList.isEmpty()) {
            throw new TwitterCalloutBuilderException('There is problems with Twitter setting metadata. Check it');
        } else {
            twitterSetting = twitterSettingList.get(0);
            baseOrganizationEndpoint = twitterSetting.Base_API_URL__c;
            uploadMediaEndpoint = twitterSetting.Upload_Media_API_URL__c;
        }
    }
    
    public TwitterCallout getAccessToken(String code){
        Logger logger = Logger.getInstance();
        String endPoint = baseOrganizationEndpoint + '/2/oauth2/token?';
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        String base64Message = EncodingUtil.base64Encode(Blob.valueOf(twitterSetting.Client_Id__c + ':' + twitterSetting.Client_Secret__c));
        
        Map<String, String> params = new Map<String, String>();
        params.put('code', code);
        params.put('grant_type', 'authorization_code');
        params.put('redirect_uri', twitterSetting.Redirect_Url__c);
        params.put('code_verifier', twitterSetting.Code_Challenge__c);
        params.put('code_challenge_method', 'plain');
        
        callout.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        callout.setHeader('Authorization', 'Basic ' + base64Message);
        callout.setBody('code=' + EncodingUtil.urlEncode(params.get('code'), 'UTF-8') + 
                        '&grant_type=' + EncodingUtil.urlEncode(params.get('grant_type'), 'UTF-8') + 
                        '&redirect_uri=' + EncodingUtil.urlEncode(params.get('redirect_uri'), 'UTF-8') + 
                        '&code_verifier=' + EncodingUtil.urlEncode(params.get('code_verifier'), 'UTF-8') + 
                        '&code_challenge_method=' + EncodingUtil.urlEncode(params.get('code_challenge_method'), 'UTF-8'));
        
        callout.send();
        if (callout.isSuccess()) { 
            try { 
                callout.responseObj = TwitterWrappers.parseAccessTokenResponse(callout.response.getBody());
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'getAccessToken', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'getAccessToken');
        }
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout refreshAccessToken(String refreshToken){
        Logger logger = Logger.getInstance();
        String endPoint = baseOrganizationEndpoint + '/2/oauth2/token';
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        callout.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        callout.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(twitterSetting.Client_Id__c + ':' + twitterSetting.Client_Secret__c)));
        callout.setBody('grant_type=refresh_token&refresh_token=' + refreshToken);
        callout.send();
        
        if (callout.isSuccess()) { 
            try { 
                callout.responseObj = TwitterWrappers.parseAccessTokenResponse(callout.response.getBody());
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'refreshAccessToken', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'refreshAccessToken');
        } 
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout getUserAccountInformation(String accessToken){
        Logger logger = Logger.getInstance();
        String endPoint = baseOrganizationEndpoint + '/2/users/me?';
        
        TwitterCallout callout = new TwitterCallout('GET', endPoint);
        
        callout.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        callout.setHeader('Authorization', 'Bearer ' + accessToken);
        callout.send();
        
        if (callout.isSuccess()) { 
            try { 
                callout.responseObj = TwitterWrappers.parseGetUserAccountInformationResponse(callout.response.getBody());
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'getUserAccountInformation', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'getUserAccountInformation');
        }
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout sendTweet(String accessToken, String tweetText, List<String> mediaTwitterIds) {
        Logger logger = Logger.getInstance();
        String endPoint = baseOrganizationEndpoint + '/2/tweets';
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        callout.setHeader('Content-Type', 'application/json');
        callout.setHeader('Authorization', 'Bearer ' + accessToken);
        
        Map<String, Object> tweetBody = new Map<String, Object>();
        tweetBody.put('text', tweetText);
        
        if (mediaTwitterIds != null && !mediaTwitterIds.isEmpty()) {
            Map<String, Object> media = new Map<String, Object>();
            media.put('media_ids', mediaTwitterIds);
            tweetBody.put('media', media);
        }
        callout.setBody(JSON.serialize(tweetBody));
        callout.send();
        
        if (callout.isSuccess()) { 
            try { 
                callout.responseObj = TwitterWrappers.parseSendTweetResponse(callout.response.getBody());
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'sendTweet', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'sendTweet');
        }
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout deleteTweet(String tweetId, String accessToken) {
        Logger logger = Logger.getInstance();
        String endPoint = baseOrganizationEndpoint + '/2/tweets/' + tweetId;
        
        TwitterCallout callout = new TwitterCallout('DELETE', endPoint);
        
        callout.setHeader('Authorization', 'Bearer ' + accessToken);
        callout.send();
        
        if (callout.isSuccess()) { 
            try { 
                callout.responseObj = TwitterWrappers.parseDeleteTweetResponse(callout.response.getBody());
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'deleteTweet', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'deleteTweet');
        }
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout uploadMedia(String imageBase64, String accessToken, String accessTokenSecret, String userId){
        Logger logger = Logger.getInstance();
        String endPoint = uploadMediaEndpoint + '/1.1/media/upload.json';
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        Map<String, String> oauthParams = new Map<String, String>();
        oauthParams.put('oauth_consumer_key', twitterSetting.Consumer_Key__c);
        oauthParams.put('oauth_nonce', String.valueOf(Crypto.getRandomInteger()));
        oauthParams.put('oauth_signature_method', 'HMAC-SHA1');
        oauthParams.put('oauth_timestamp', String.valueOf(DateTime.now().getTime()/1000));
        oauthParams.put('oauth_token', accessToken);
        oauthParams.put('oauth_version', '1.0');
        
        Map<String, String> allParams = new Map<String, String>();
        allParams.put('media_data', imageBase64);
        allParams.put('additional_owners', userId);
        allParams.putAll(oauthParams);
        
        String baseString = createBaseString(endPoint, 'POST', allParams);
        
        
        oauthParams.put('oauth_signature', generateSignature(baseString, accessTokenSecret));
        
        callout.setHeader('Authorization', createAuthorizationHeader(oauthParams));
        callout.setBody('media_data=' + EncodingUtil.urlEncode(imageBase64, 'UTF-8') + '&additional_owners=' + EncodingUtil.urlEncode(userId, 'UTF-8'));
        callout.send();
        
        if (callout.isSuccess()) { 
            try { 
                callout.responseObj = TwitterWrappers.parseUploadMediaResponse(callout.response.getBody());
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'uploadMedia', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'uploadMedia');
        }
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout initUploadVideo(String mediaType, Integer totalBytes, String accessToken, String accessTokenSecret) {
        Logger logger = Logger.getInstance();
        String endPoint = uploadMediaEndpoint + '/1.1/media/upload.json';
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        Map<String, String> oauthParams = new Map<String, String>();
        oauthParams.put('oauth_consumer_key', twitterSetting.Consumer_Key__c);
        oauthParams.put('oauth_nonce', String.valueOf(Crypto.getRandomInteger()));
        oauthParams.put('oauth_signature_method', 'HMAC-SHA1');
        oauthParams.put('oauth_timestamp', String.valueOf(DateTime.now().getTime()/1000));
        oauthParams.put('oauth_token', accessToken);
        oauthParams.put('oauth_version', '1.0');
        
        Map<String, String> allParams = new Map<String, String>();
        allParams.put('command', 'INIT');
        allParams.put('media_category', 'amplify_video');
        allParams.put('total_bytes', String.valueOf(totalBytes));
        allParams.putAll(oauthParams);
        
        String baseString = createBaseString(endPoint, 'POST', allParams);
        
        oauthParams.put('oauth_signature', generateSignature(baseString, accessTokenSecret));
        
        callout.setHeader('Authorization', createAuthorizationHeader(oauthParams));
        callout.setBody('command=INIT&media_category=' + 'amplify_video' + '&total_bytes=' + String.valueOf(totalBytes));
        callout.send();
        
        if (callout.isSuccess()) {
            try {
                callout.responseObj = TwitterWrappers.parseUploadMediaResponse(callout.response.getBody());
                TwitterWrappers.UploadMediaResponse wrapper = (TwitterWrappers.UploadMediaResponse) callout.responseObj;
            } catch(Exception ex) {
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'initUploadVideo', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        } else {
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'initUploadVideo');
        }
        
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout appendUploadVideo(String mediaId, String videoChunk, Integer segmentIndex, String accessToken, String accessTokenSecret) {
        Logger logger = Logger.getInstance();
        String endPoint = uploadMediaEndpoint + '/1.1/media/upload.json';
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        Map<String, String> oauthParams = new Map<String, String>();
        oauthParams.put('oauth_consumer_key', twitterSetting.Consumer_Key__c);
        oauthParams.put('oauth_nonce', String.valueOf(Crypto.getRandomInteger()));
        oauthParams.put('oauth_signature_method', 'HMAC-SHA1');
        oauthParams.put('oauth_timestamp', String.valueOf(DateTime.now().getTime()/1000));
        oauthParams.put('oauth_token', accessToken);
        oauthParams.put('oauth_version', '1.0');
        
        Map<String, String> allParams = new Map<String, String>();
        allParams.put('command', 'APPEND');
        allParams.put('media_id', mediaId);
        allParams.put('segment_index', String.valueOf(segmentIndex));
        allParams.put('media_data', String.valueOf(videoChunk));
        allParams.putAll(oauthParams);
        
        String baseString = createBaseString(endPoint, 'POST', allParams);
        
        oauthParams.put('oauth_signature', generateSignature(baseString, accessTokenSecret));
        
        callout.setHeader('Authorization', createAuthorizationHeader(oauthParams));
        callout.setBody('command=APPEND&media_id=' + mediaId + '&segment_index=' + String.valueOf(segmentIndex) + '&media_data=' + EncodingUtil.urlEncode(videoChunk, 'UTF-8'));
        callout.send();
        
        if (!callout.isSuccess()) {
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'appendUploadVideo');
        }
        
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout finalizeUploadVideo(String mediaId, String accessToken, String accessTokenSecret) {
        Logger logger = Logger.getInstance();
        String endPoint = uploadMediaEndpoint + '/1.1/media/upload.json';
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        Map<String, String> oauthParams = new Map<String, String>();
        oauthParams.put('oauth_consumer_key', twitterSetting.Consumer_Key__c);
        oauthParams.put('oauth_nonce', String.valueOf(Crypto.getRandomInteger()));
        oauthParams.put('oauth_signature_method', 'HMAC-SHA1');
        oauthParams.put('oauth_timestamp', String.valueOf(DateTime.now().getTime()/1000));
        oauthParams.put('oauth_token', accessToken);
        oauthParams.put('oauth_version', '1.0');
        
        Map<String, String> allParams = new Map<String, String>();
        allParams.put('command', 'FINALIZE');
        allParams.put('media_id', mediaId);
        allParams.putAll(oauthParams);
        
        String baseString = createBaseString(endPoint, 'POST', allParams);
        
        oauthParams.put('oauth_signature', generateSignature(baseString, accessTokenSecret));
        
        callout.setHeader('Authorization', createAuthorizationHeader(oauthParams));
        callout.setBody('command=FINALIZE&media_id=' + mediaId);
        callout.send();
        
        if (callout.isSuccess()) {
            try {
                callout.responseObj = TwitterWrappers.parseUploadMediaResponse(callout.response.getBody());
            } catch(Exception ex) {
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'finalizeUploadVideo', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        } else {
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'finalizeUploadVideo');
        }
        
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout createTwitterAuthorizationURLOAuth1(String contactId){
        Logger logger = Logger.getInstance();
        String endPoint = baseOrganizationEndpoint + '/oauth/request_token';
        
        Map<String, String> params = new Map<String, String>();
        params.put('oauth_callback', twitterSetting.Redirect_Url__c + '?state=' + contactId);
        params.put('oauth_consumer_key', twitterSetting.Consumer_Key__c);
        params.put('oauth_nonce', EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(Math.random())))));
        params.put('oauth_signature_method', 'HMAC-SHA1');
        params.put('oauth_timestamp', String.valueOf(DateTime.now().getTime() / 1000));
        params.put('oauth_version', '1.0');
        
        String baseString = createBaseString(endPoint, 'POST', params);
        String signature = generateSignature(baseString, null);
        params.put('oauth_signature', signature);
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        callout.setHeader('Authorization', createAuthorizationHeader(params));
        callout.send();
        
        if (callout.isSuccess()) { 
            try { 
                callout.responseObj = callout.response.getBody();
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'deleteTweet', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'deleteTweet');
        }
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    public TwitterCallout getAccessTokenOAuth1(String oauthToken, String oauthVerifier) {
        Logger logger = Logger.getInstance();
        String endPoint = baseOrganizationEndpoint + '/oauth/access_token';
        
        Map<String, String> params = new Map<String, String>();
        params.put('oauth_token', oauthToken);
        params.put('oauth_verifier', oauthVerifier);
        params.put('oauth_consumer_key', twitterSetting.Consumer_Key__c);
        params.put('oauth_nonce', EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(Math.random())))));
        params.put('oauth_signature_method', 'HMAC-SHA1');
        params.put('oauth_timestamp', String.valueOf(DateTime.now().getTime() / 1000));
        params.put('oauth_version', '1.0');
        
        String baseString = createBaseString(endPoint, 'POST', params);
        String signature = generateSignature(baseString, null);
        params.put('oauth_signature', signature);
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        callout.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        callout.setHeader('Authorization', createAuthorizationHeader(params));
        callout.setBody('oauth_token=' + EncodingUtil.urlEncode(oauthToken, 'UTF-8') + '&oauth_verifier=' + EncodingUtil.urlEncode(oauthVerifier, 'UTF-8'));
        callout.send();
        if (callout.isSuccess()) { 
            try { 
                Map<String, String> responseMap = new Map<String, String>();
                for (String param : callout.response.getBody().split('&')) {
                    List<String> keyValue = param.split('=');
                    if (keyValue.size() == 2) {
                        responseMap.put(keyValue[0], keyValue[1]);
                    }
                }
                TwitterWrappers wrapper = new TwitterWrappers();
                wrapper.oauth_token = responseMap.get('oauth_token');
                wrapper.oauth_token_secret = responseMap.get('oauth_token_secret');
                wrapper.user_id = responseMap.get('user_id');
                callout.responseObj = wrapper;     
            } catch(Exception ex){
                logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'getAccessToken', ex.getMessage());
                callout.responseObj = ex.getCause() + ex.getTypeName() + ex.getMessage() + ex.getLineNumber();
            }
        }else{
            logger.error(callout.request, callout.response, 'TwitterCalloutBuilder', 'getAccessToken');
        }
        System.debug(callout.request.getEndpoint());
        System.debug(callout.response.getBody());
        logger.publish();
        return callout;
    }
    
    private String createBaseString(String url, String method, Map<String, String> params) {
        List<String> sortedKeys = new List<String>(params.keySet());
        sortedKeys.sort();
        
        List<String> parameterString = new List<String>();
        for (String key : sortedKeys) {
            parameterString.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8'));
        }
        
        String paramString = String.join(parameterString, '&');
        return method + '&' + EncodingUtil.urlEncode(url, 'UTF-8') + '&' + EncodingUtil.urlEncode(paramString, 'UTF-8');
    }
    
    private String generateSignature(String baseString, String tokenSecret) {
        tokenSecret = (tokenSecret == null) ? '' : tokenSecret;
        String signingKey = EncodingUtil.urlEncode(twitterSetting.Consumer_Secret__c, 'UTF-8') + '&' + EncodingUtil.urlEncode(tokenSecret, 'UTF-8');
        Blob signature = Crypto.generateMac('HMACSHA1', Blob.valueOf(baseString), Blob.valueOf(signingKey));
        return EncodingUtil.base64Encode(signature);
    }
    
    private String createAuthorizationHeader(Map<String, String> params) {
        List<String> headerParams = new List<String>();
        for (String key : params.keySet()) {
            headerParams.add(key + '="' + EncodingUtil.urlEncode(params.get(key), 'UTF-8') + '"');
        }
        
        return 'OAuth ' + String.join(headerParams, ', ');
    }
    
    public class TwitterCalloutBuilderException extends Exception {}
    
}