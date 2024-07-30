public class TwitterCallout extends CalloutGeneric{
    
    public String responseCode;
    public Object responseObj;
    public Twitter_Setting__mdt twitterSetting;
 
    public TwitterCallout() {
        super('Twitter');
        List<Twitter_Setting__mdt> twitterSettingList = TwitterMetadataSelector.getTwitterSettingMetadata();
        if (twitterSettingList.isEmpty()) {
            throw new TwitterCalloutException('Twitter Setting is undefined');
        }else{
            twitterSetting = twitterSettingList[0];
        }
                
        this.setTimeout(60000);
    }

    public TwitterCallout(String method, String endpoint) {
        this();
        this.setMethod(method);
        this.setEndpoint(endpoint);
    }
    
    public override CalloutGeneric send() {
        assignHeaders();
        assignParams();
        Logger logger = Logger.getInstance();
        
        this.response = new Http().send(this.request);
        if (this.response.getStatusCode() >= 300) {
            setFail();
            parseError();
        }
       
        return this;
        
    }
    
    /*public override CalloutGeneric send() {
        assignHeaders();
		assignParams();
		Logger logger = Logger.getInstance();
        try {
            System.debug(this.request.getEndPoint());
            this.response = new Http().send(this.request);
            if (this.response.getStatusCode() >= 300) {
                setFail();
                parseError();
            }
        } catch (Exception ex) {
            System.debug('---> ERROR: ' + ex.getMessage());
            logger.error(null, null, 'TwitterCallout', 'send', ex.getMessage());
            logger.publish();
            this.error = new IntegrationError(ex);
            setFail();
        }

        return this;
    
    }*/

    
    public class TwitterCalloutException extends Exception{}
    
    
}