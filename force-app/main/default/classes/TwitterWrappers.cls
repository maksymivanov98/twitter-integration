public class TwitterWrappers {

    public String access_token{get;set;}
    public String token_type{get;set;}
    public String oauth_token{get;set;}
    public String oauth_token_secret{get;set;}
    public String refresh_token{get;set;}
    public String scope{get;set;}
    public Integer expires_in{get;set;}
    public String user_id{get;set;}
    public Boolean isSuccess{get;set;}
    public Object errorResponseObj{get;set;}
    
    public class SendTweetResponse{
        public SendTweetData data{get;set;}        
        public Boolean isSuccess{get;set;}
        public Object errorResponseObj{get;set;}
    }
    
    public class SendTweetData{
        public String text{get;set;}
        public String id{get;set;}
        public list<String> edit_history_tweet_ids{get;set;}
    }
    
    public class GetUserAccountInformationResponse{
        @AuraEnabled 
        public UserData data{get;set;}
        public Boolean isSuccess{get;set;}
        public Object errorResponseObj{get;set;}
    }
    
    public class UserData{
        @AuraEnabled 
        public String username{get;set;}
        @AuraEnabled 
        public String name{get;set;}
        @AuraEnabled 
        public String id{get;set;}
    }
    
    public class UploadMediaResponse{
        @AuraEnabled 
        public Integer size{get;set;}
        @AuraEnabled 
        public Integer expires_after_secs{get;set;}
        @AuraEnabled 
        public String media_id_string{get;set;}
        @AuraEnabled 
        public String media_id_salesforce{get;set;}
        @AuraEnabled 
        public Image image{get;set;}
        @AuraEnabled 
        public Decimal media_id{get;set;}
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled 
        public Object errorResponseObj{get;set;}
    }
    
    public class Image{
        public String image_type{get;set;}
        public Integer h{get;set;}
        public Integer w{get;set;}
    }
    
    public class DeleteTweetResponse{
        public DeleteTweetData data{get;set;}
        public Boolean isSuccess{get;set;}
        public Object errorResponseObj{get;set;}
    }
    
    public class DeleteTweetData{
        public Boolean deleted{get;set;}
    }
    
    public class StatusMediaResponse{
        public Integer expires_after_secs{get;set;}
        public String media_id_string{get;set;}
        public ProcessingInfo processing_info{get;set;}
        public Decimal media_id{get;set;}
        public Boolean isSuccess{get;set;}
        public Object errorResponseObj{get;set;}
    }
    
    public class ProcessingInfo{
        public String state{get;set;}
        public Integer check_after_secs{get;set;}
        public Integer progress_percent{get;set;}
    }
    
    public static TwitterWrappers.GetUserAccountInformationResponse parseGetUserAccountInformationResponse(String json){
        return (TwitterWrappers.GetUserAccountInformationResponse) System.JSON.deserialize(json, TwitterWrappers.GetUserAccountInformationResponse.class);
    }
    
    public static TwitterWrappers parseAccessTokenResponse(String json){
        return (TwitterWrappers) System.JSON.deserialize(json, TwitterWrappers.class);
    }
    
    public static TwitterWrappers.SendTweetResponse parseSendTweetResponse(String json){
        return (TwitterWrappers.SendTweetResponse) System.JSON.deserialize(json, TwitterWrappers.SendTweetResponse.class);
    }
    
    public static TwitterWrappers.UploadMediaResponse parseUploadMediaResponse(String json){
        return (TwitterWrappers.UploadMediaResponse) System.JSON.deserialize(json, TwitterWrappers.UploadMediaResponse.class);
    }
    
    public static TwitterWrappers.DeleteTweetResponse parseDeleteTweetResponse(String json){
        return (TwitterWrappers.DeleteTweetResponse) System.JSON.deserialize(json, TwitterWrappers.DeleteTweetResponse.class);
    }
    
    public static TwitterWrappers.StatusMediaResponse parseStatusMediaResponse(String json){
        return (TwitterWrappers.StatusMediaResponse) System.JSON.deserialize(json, TwitterWrappers.StatusMediaResponse.class);
    }
    
}