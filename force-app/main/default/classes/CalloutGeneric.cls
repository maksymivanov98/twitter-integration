public virtual class CalloutGeneric {

    public Object responseObj;
    protected Boolean isSuccess = true;
    public HttpRequest request;
    public HttpResponse response;
    protected IntegrationError error;
    protected Map<String, String> headersMap;
    protected Map<String, String> paramsMap;
    protected Id recordTypeId;

    public static Boolean causeInternalError;

    @testVisible
    protected CalloutGeneric(String rtDevName) {
        headersMap = new Map<String, String>();
        paramsMap = new Map<String, String>();
        request = new HttpRequest();
    }

    public CalloutGeneric setParam(String key, String value) {
        this.paramsMap.put(key, value);
        return this;
    }
    
    public CalloutGeneric setMethod(String method) {
        this.request.setMethod(method);
        return this;
    }

    public CalloutGeneric setHeader(String key, String value) {
        this.headersMap.put(key, value);
        return this;
    }
    
    public CalloutGeneric setBody(String body) {
        this.request.setBody(body);
        return this;
    }

    public CalloutGeneric setEndpoint(String endpoint) {
        this.request.setEndpoint(endpoint);
        return this;
    }
    
    public CalloutGeneric setTimeout(Integer timeout) {
        this.request.setTimeout(timeout);
        return this;
    }
    
    public String getEndpoint() {
        return this.request.getEndpoint();
    }

    public String getResponseBody() {
        return this.response.getBody();
    }

    public Integer getStatusCode() {
        return this.response.getStatusCode();
    }

    public String getStatus() {
        return this.response.getStatus();
    }

    public Boolean isSuccess() {
        return this.isSuccess;
    }

    public void setFail() {
        this.isSuccess = false;
    }

    public virtual IntegrationError getError() {
        return this.error;
    }

    protected void assignHeaders() {
        for (String key : headersMap.keySet()) {
            request.setHeader(key, headersMap.get(key));
        }
    }
    
    protected void assignParams() {
        String finalEndpoint = request.getEndpoint();
       	finalEndpoint = paramsMap.keySet().size() > 0 ? finalEndpoint + '?' : finalEndpoint;
        List<String> paramsKeyList = new List<String>(paramsMap.keySet());
        for (Integer i = 0; i < paramsKeyList.size(); i++){
            String key = paramsKeyList.get(i);
            if (i == 0) {
                finalEndpoint += key + '=' + paramsMap.get(key);
            } else {
                finalEndpoint += '&' + key + '=' + paramsMap.get(key);
            }
        }
        request.setEndpoint(finalEndpoint);
    }

    public virtual CalloutGeneric send() {
        assignHeaders();
        assignParams();
        try {
            if (Test.isRunningTest() && causeInternalError == true && Schema.sObjectType.Account.fields.Name.isCreateable()) {
                insert new Account(Name = 'Cause of error');
            }
                        
            this.response = new Http().send(this.request);
            if (this.response.getStatusCode() >= 400) {
                setFail();
                parseError();
            }

        } catch (Exception ex) {
            this.error = new IntegrationError(ex);
            setFail();
        }
        
        System.debug('request  ===  ' + this.request);
        System.debug('response  ===  ' + this.response);
        System.debug('error  ==  ' + this.error);

        return this;
    }

    public virtual CalloutGeneric send(HttpResponse response) {
        assignHeaders();
        assignParams();
	
        try {
            if (Test.isRunningTest() && causeInternalError == true && Schema.sObjectType.Account.fields.Name.isCreateable()) {
                insert new Account(Name = 'Cause of error');
            }
                        
            this.response = response;
            if (this.response.getStatusCode() >= 400) {
                setFail();
                parseError();
            }

        } catch (Exception ex) {
            this.error = new IntegrationError(ex);
            setFail();
        }
        
        System.debug('request  ===  ' + this.request);
        System.debug('response  ===  ' + this.response);
        System.debug('error  ==  ' + this.error);

        return this;
    }

    protected virtual void parseError() {

    }

}