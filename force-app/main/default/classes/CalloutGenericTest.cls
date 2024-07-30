@isTest
private class CalloutGenericTest {

    @isTest
    static void calloutTest_success() {
        CalloutGeneric callout = new CalloutGeneric('RecordTypeName');

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setBody('{"message": "Success"}');

        callout.setEndpoint('https://mockservice.com/api');
        callout.setParam('key', 'value');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        CalloutGeneric response = callout.send(mockResponse);

        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('OK', response.getStatus());
        System.assertEquals('{"message": "Success"}', response.getResponseBody());
        System.assertEquals(null, response.getError());
    }

    @isTest
    static void handlingTest_error() {
        CalloutGeneric callout = new CalloutGeneric('RecordTypeName');

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setStatus('Internal Server Error');
        mockResponse.setBody('{"error": "Server error"}');

        callout.setEndpoint('https://mockservice.com/api');
        callout.setParam('key', 'value');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        CalloutGeneric response = callout.send(mockResponse);

        System.assertEquals(500, response.getStatusCode());
        System.assertEquals('Internal Server Error', response.getStatus());
        System.assertEquals('{"error": "Server error"}', response.getResponseBody());
    }
    
    @isTest
    static void calloutWithoutParamTest_success() {
        CalloutGeneric callout = new CalloutGeneric('RecordTypeName');

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setBody('{"message": "Success"}');

        callout.setEndpoint('https://mockservice.com/api');
        callout.setParam('key', 'value');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        CalloutGeneric response = callout.send();

        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('OK', response.getStatus());
        System.assertEquals('{"message": "Success"}', response.getResponseBody());
        System.assertEquals(null, response.getError());
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        HttpResponse mockResponse;

        MockHttpResponseGenerator(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
        }

        public HttpResponse respond(HttpRequest request) {
            return this.mockResponse;
        }
    }
}