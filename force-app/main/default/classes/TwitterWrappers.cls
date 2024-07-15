public class TwitterWrappers {

	public String access_token{get;set;}
	public String token_type{get;set;}
    public String refresh_token{get;set;}
    public String scope{get;set;}
    public Integer expires_in{get;set;}
		
    public class SendTweetResponse{
        public SendTweetData data{get;set;}
    }
    
    public class SendTweetData{
        public String text{get;set;}
        public String id{get;set;}
        public list<String> edit_history_tweet_ids{get;set;}
    }
    
    public class GetUserAccountInformationResponse{
        @AuraEnabled 
        public UserData data{get;set;}
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
        
    }
    
    public class Image{
        public String image_type{get;set;}
        public Integer h{get;set;}
        public Integer w{get;set;}
    }
    
    public class DeleteTweetResponse{
        public DeleteTweetData data{get;set;}
    }
    
    public class DeleteTweetData{
        public Boolean deleted{get;set;}
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
    
}