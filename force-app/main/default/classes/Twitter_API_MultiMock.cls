public class Twitter_API_MultiMock implements HttpCalloutMock {
    
    public List<CalloutMock> mockList { get; set; }
    
    public Twitter_API_MultiMock() {
        this.mockList = new List<CalloutMock>();
    }
    
    public Twitter_API_MultiMock(List<CalloutMock> mockList) {
        this.mockList = mockList;
    }
    
    public HTTPResponse respond(HTTPRequest request) {
        for (CalloutMock mock : mockList) {
            if (mock.isCompatible(request)) {
                return mock.respond();
            }
        }
        throw new Twitter_API_MockException('No compatible mock found for request: ' + request);
    }
    
    public abstract class CalloutMock {
        public HttpResponse response;
        public Integer statusCode;
        public String status;
        public String responseBody;
        public String regexCheckExpression;
        public String httpMethod;
        
        public virtual Boolean isCompatible(HTTPRequest request) {         
            return request.getMethod() == this.httpMethod && request.getEndpoint().contains(regexCheckExpression);
        }
        
        public virtual HTTPResponse respond() {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(statusCode);
            if (String.isNotBlank(status)) {
                response.setStatus(status);
            }
            if (String.isNotBlank(responseBody)) {
                response.setBody(responseBody);
            }
            return response;
        }
    }
    
    public class Twitter_API_MockException extends Exception { }
    
    public class getAccessTokenSuccess extends CalloutMock {
        {
            statusCode = 200;
            regexCheckExpression = '/2/oauth2/token';
            httpMethod = 'POST';
            responseBody = '{"token_type":"bearer","expires_in":7200,"access_token":"dE1nM0FDdlZKcWRIRDFnZWRCM1RFTnliMzJtdjFpMGExMlczY0c3WnN0MGdwOjE3MjA1MjE2MDA5NjE6MTowOmF0OjE","scope":"tweet.write users.read tweet.read offline.access","refresh_token":"VFhvX05leFZXOHJCNVQ0RnVsNjRTYnp1X3JzSHA3MWp6Ty1SVnA3cXpuZG9wOjE3MjA1MjE2MDA5NjE6MToxOnJ0OjE"}';
        }
    }
    
    public class refreshAccessTokenSuccess extends CalloutMock {
        {
            statusCode = 200;
            regexCheckExpression = '/2/oauth2/token';
            httpMethod = 'POST';
            responseBody = '{"token_type":"bearer","expires_in":7200,"access_token":"dE1nM0FDdlZKcWRIRDFnZWRCM1RFTnliMzJtdjFpMGExMlczY0c3WnN0MGdwOjE3MjA1MjE2MDA5NjE6MTowOmF0OjE","scope":"tweet.write users.read tweet.read offline.access","refresh_token":"VFhvX05leFZXOHJCNVQ0RnVsNjRTYnp1X3JzSHA3MWp6Ty1SVnA3cXpuZG9wOjE3MjA1MjE2MDA5NjE6MToxOnJ0OjE"}';
        }
    }
    
    public class getUserDataSuccess extends CalloutMock {
        {
            statusCode = 200;
            regexCheckExpression = '/2/users/me';
            httpMethod = 'GET';
            responseBody = '{"data":{"id":"1804082796924731392","name":"Maksym Ivanov","username":"MaksymIvan97376"}}';
        }
    }
    
    public class sendTweetSuccess extends CalloutMock {
        {
            statusCode = 200;
            regexCheckExpression = '/2/tweets';
            httpMethod = 'POST';
            responseBody = '{"data":{"edit_history_tweet_ids":["1810649803254083689"],"id":"1810649803254083689","text":"TestText https://t.co/TINk046wF4"}}';
        }
    }
    
    public class uploadMediaSuccess extends CalloutMock {
        {
            statusCode = 200;
            regexCheckExpression = '/1.1/media/upload.json';
            httpMethod = 'POST';
            responseBody = '{"media_id":1810650546916773888,"media_id_string":"1810650546916773888","size":278589,"expires_after_secs":86400,"image":{"image_type":"image.png","w":500,"h":523}}';
        }
    }
    
    public class deleteTweetSuccess extends CalloutMock {
        {
            statusCode = 200;
            regexCheckExpression = '/2/tweets/123';
            httpMethod = 'DELETE';
            responseBody = '{"data":{"deleted":true}}';
        }
    }
    
    public class getAccessTokenFailed extends CalloutMock {
        {
            statusCode = 400;
            regexCheckExpression = '/2/oauth2/token';
            httpMethod = 'POST';
            responseBody = '{"error":"invalid_request","error_description":"Missing required parameter [grant_type]."}';
        }
    }
    
    public class refreshAccessTokenFailed extends CalloutMock {
        {
            statusCode = 400;
            regexCheckExpression = '/2/oauth2/token';
            httpMethod = 'POST';
            responseBody = '{"error":"invalid_request","error_description":"Missing required parameter [grant_type]."}';
        }
    }
    
    public class getUserDataFailed extends CalloutMock {
        {
            statusCode = 400;
            regexCheckExpression = '/2/users/me';
            httpMethod = 'GET';
            responseBody = '{"error":"invalid_request","error_description":"Missing required parameter [grant_type]."}';
        }
    }
    
    public class sendTweetFailed extends CalloutMock {
        {
            statusCode = 400;
            regexCheckExpression = '/2/tweets';
            httpMethod = 'POST';
            responseBody = '{"error":"invalid_request","error_description":"Missing required parameter [grant_type]."}';
        }
    }
    
    public class uploadMediaFailed extends CalloutMock {
        {
            statusCode = 400;
            regexCheckExpression = '/1.1/media/upload.json';
            httpMethod = 'POST';
            responseBody = '{"error":"invalid_request","error_description":"Missing required parameter [grant_type]."}';
        }
    }
    
    public class deleteTweetFailed extends CalloutMock {
        {
            statusCode = 400;
            regexCheckExpression = '/2/tweets/123';
            httpMethod = 'DELETE';
            responseBody = '{"error":"invalid_request","error_description":"Missing required parameter [grant_type]."}';
        }
    }
    
}