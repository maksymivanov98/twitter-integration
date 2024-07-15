public class TwitterRedirectController {
    public Boolean isAuthorized { get; set; }

    public TwitterRedirectController() {
        isAuthorized = true;
    }

    public PageReference redirectToContact() {
        Logger logger = Logger.getInstance();
        try {
            String contactId = ApexPages.currentPage().getParameters().get('state');
            String code = ApexPages.currentPage().getParameters().get('code');
            
            if (contactId != null && contactId != '') {
                String actionUrl = '/lightning/r/Contact/' + contactId + '/view';
                PageReference actionPage = new PageReference(actionUrl);
                actionPage.setRedirect(true);

                CreateTweetController.getUserData(code, contactId);
                return actionPage;
            }
        } catch(Exception ex) {
            logger.error(null, null, 'TwitterCalloutBuilder', 'redirectToContact', ex.getMessage());
        }
        logger.publish();
        isAuthorized = false;
        return null;
    }

    public PageReference redirectToHome() {
        PageReference homePage = new PageReference('/home/home.jsp');
        homePage.setRedirect(true);
        return homePage;
    }
}