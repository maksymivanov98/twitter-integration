public class TwitterMetadataSelector {
    
    private static final String TWITTER_SETTING_API_NAME = 'Twitter_Setting';
    
    public static List<Twitter_Setting__mdt> getTwitterSettingMetadata() {
        return [SELECT Id 
                , Base_API_URL__c
                , Upload_Media_API_URL__c
                , Consumer_Key__c
                , Consumer_Secret__c
                , Client_Id__c
                , Client_Secret__c
                , Code_Challenge__c
                , Redirect_Url__c
                , Access_Token__c
                , Access_Token_Secret__c
                FROM Twitter_Setting__mdt 
                WHERE DeveloperName = : TWITTER_SETTING_API_NAME
               ];
    }
    
    
}