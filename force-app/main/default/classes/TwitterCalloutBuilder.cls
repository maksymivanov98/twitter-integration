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
        params.put('redirect_uri', 'https://companysandbox-29e-dev-ed.develop.lightning.force.com/apex/TwitterRedirectPage');
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
    
    public TwitterCallout uploadMedia(String imageBase64){
        Logger logger = Logger.getInstance();
        String endPoint = uploadMediaEndpoint + '/1.1/media/upload.json';
        
        TwitterCallout callout = new TwitterCallout('POST', endPoint);
        
        Map<String, String> headers = generateOAuth1Headers(endPoint, 'POST', new Map<String, String>{ 'media_data' => imageBase64 });
        for (String key : headers.keySet()) {
            callout.setHeader(key, headers.get(key));
        }
        callout.setBody('media_data=' + EncodingUtil.urlEncode(imageBase64, 'UTF-8'));
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
    
    private String oauth1SignatureBaseString(String method, String url, Map<String, String> params) {
        String sortedParams = oauth1SortedParams(params);
        String baseString = method.toUpperCase() + '&' + EncodingUtil.urlEncode(url, 'UTF-8') + '&' + EncodingUtil.urlEncode(sortedParams, 'UTF-8');
        return baseString;
    }
    
    private String oauth1SortedParams(Map<String, String> params) {
        List<String> keys = new List<String>(params.keySet());
        keys.sort();
        List<String> sortedParams = new List<String>();
        for (String key : keys) {
            sortedParams.add(EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8'));
        }
        return String.join(sortedParams, '&');
    }
    
    private String oauth1Sign(String baseString, String signingKey) {
        Blob mac = Crypto.generateMac('HmacSHA1', Blob.valueOf(baseString), Blob.valueOf(signingKey));
        return EncodingUtil.base64Encode(mac);
    }
    
    private Map<String, String> generateOAuth1Headers(String url, String method, Map<String, String> params) {
        Map<String, String> oauthParams = new Map<String, String>();
        oauthParams.put('oauth_consumer_key', twitterSetting.Consumer_Key__c);
        oauthParams.put('oauth_nonce', 'DywblabChh4Oh0nR3iX675xWfOBaeJvO');
        oauthParams.put('oauth_signature_method', 'HMAC-SHA1');
        oauthParams.put('oauth_timestamp', String.valueOf(DateTime.now().getTime()/1000));
        oauthParams.put('oauth_token', twitterSetting.Access_Token__c);
        oauthParams.put('oauth_version', '1.0');
        
        Map<String, String> allParams = new Map<String, String>(params);
        allParams.putAll(oauthParams);
        
        String baseString = oauth1SignatureBaseString(method, url, allParams);
        String signingKey = EncodingUtil.urlEncode(twitterSetting.Consumer_Secret__c, 'UTF-8') + '&' + EncodingUtil.urlEncode(twitterSetting.Access_Token_Secret__c, 'UTF-8');
        oauthParams.put('oauth_signature', oauth1Sign(baseString, signingKey));
        
        Map<String, String> headers = new Map<String, String>();
        List<String> headerStrings = new List<String>();
        for (String key : oauthParams.keySet()) {
            headerStrings.add(EncodingUtil.urlEncode(key, 'UTF-8') + '="' + EncodingUtil.urlEncode(oauthParams.get(key), 'UTF-8') + '"');
        }
        headers.put('Authorization', 'OAuth ' + String.join(headerStrings, ', '));
        return headers;
    }
    
    public class TwitterCalloutBuilderException extends Exception {}
    
}