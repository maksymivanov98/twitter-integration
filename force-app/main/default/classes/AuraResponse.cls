public class AuraResponse {
    @AuraEnabled
    public String message { get; set; }
    
    @AuraEnabled
    public Object responseObj { get; set; }
    
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    
    public AuraResponse() {}
    
    public AuraResponse(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }
    
    public AuraResponse(Boolean isSuccess, Object pResponseObj, String pMessage) {
        this.isSuccess = isSuccess;
        this.responseObj = pResponseObj;
        this.message = pMessage;
    }
    
    public AuraResponse(Boolean isSuccess, String message) {
        this.isSuccess = isSuccess;
        this.message = message;
    }
}