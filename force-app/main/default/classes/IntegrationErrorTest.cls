@isTest
public class IntegrationErrorTest {
    
    @IsTest
    static void testConstructorWithException() {
        String mockMessage = 'Test Exception';
        IntegrationError error = new IntegrationError(new MockException(mockMessage));
        
        System.assertEquals(mockMessage, error.getMessage(), 'Error message should match the exception message');
    }
    
    @IsTest
    static void testGetMessage() {
        IntegrationError error = new IntegrationError();
        error.errorMessage = 'Custom Error Message';
        
        System.assertEquals('Custom Error Message', error.getMessage(), 'Should return the custom error message');
    }
    
    private class MockException extends Exception {}
    
}