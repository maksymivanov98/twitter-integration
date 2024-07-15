@isTest
public class LoggerTest {
    
    @IsTest
    static void loggerTests() {
        HttpRequest mockRequest = new HttpRequest();
        HttpResponse mockResponse = new HttpResponse();
        
        String className = 'TestClass';
        String classMethod = 'testMethod';
        String component = 'TestComponent';
        String userFriendlyMessage = 'User friendly error message';
        
        Logger logger = Logger.getInstance();
       
        logger.debug('Debug message', classMethod, component);
        logger.error(mockRequest, mockResponse, className, classMethod);
        logger.error(mockRequest, mockResponse, className, classMethod, userFriendlyMessage);
        logger.error('Error message', classMethod, component);

        Test.startTest();
        logger.publish();
        Test.stopTest();
        
        List <Twitter_Log__c> twitterLogList = [SELECT Id FROM Twitter_Log__c];
        
        System.assertEquals(4, twitterLogList.size());
    }
    
}