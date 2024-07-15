@isTest
public class TwitterRedirectControllerTest {
    
    @isTest 
    static void redirectToContactTest() {
        Contact testContact = new Contact(LastName = 'Test', Email = 'test@test.com');
        insert testContact;
        
        PageReference pageRef = Page.TwitterRedirectPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('state', testContact.Id);
        ApexPages.currentPage().getParameters().put('code', 'test_code');
        
        TwitterRedirectController controller = new TwitterRedirectController();
        
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenSuccess());
        multiMock.mockList.add(new Twitter_API_MultiMock.getUserDataSuccess());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Test.startTest();
        PageReference resultPage = controller.redirectToContact();
        Test.stopTest();
        
        System.assertEquals('/lightning/r/Contact/' + testContact.Id + '/view', resultPage.getUrl());
    }
    
    @isTest 
    static void redirectToHomeTest() {
        PageReference pageRef = Page.TwitterRedirectPage;
        Test.setCurrentPage(pageRef);
        
        TwitterRedirectController controller = new TwitterRedirectController();
        
        Test.startTest();
        PageReference resultPage = controller.redirectToHome();
        Test.stopTest();
        
        System.assertEquals('/home/home.jsp', resultPage.getUrl());
    }
    
    @isTest 
    static void errorHandlingTest() {
        PageReference pageRef = Page.TwitterRedirectPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('state', null);
        ApexPages.currentPage().getParameters().put('code', null);
        
        TwitterRedirectController controller = new TwitterRedirectController();
        
        Twitter_API_MultiMock multiMock = new  Twitter_API_MultiMock();
        multiMock.mockList.add(new Twitter_API_MultiMock.getAccessTokenFailed());
        multiMock.mockList.add(new Twitter_API_MultiMock.getUserDataFailed());
        Test.setMock(HttpCalloutMock.class, multiMock);
        
        Test.startTest();
        PageReference resultPage = controller.redirectToContact();
        Test.stopTest();
        
        System.assertEquals(false, controller.isAuthorized);
        System.assertEquals(null, resultPage);
    }
}