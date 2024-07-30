public class LogService {
    
    public static List<Twitter_Log__c> quickBooksLogs = new List<Twitter_Log__c>();
    
    public static void addLog(HttpRequest request, HttpResponse response, String className, String classMethod, System.LoggingLevel logLevel, String userFriendlyMessage){
        try {
            String reqBody = '';
            String resBody = '';
            try {
                reqBody = request.getBody();
            } catch(Exception ex) {}
            
            try {
                resBody = response.getBody();
            } catch(Exception ex) {}
            
            Twitter_Log__c log = new Twitter_Log__c(
                Request_Body__c = reqBody != null ? (reqBody.length() > 131072 ? reqBody.substring(0, 131072) : reqBody) : null,
                Response_body__c = resBody != null ? (resBody.length() > 131072 ? resBody.substring(0, 131072) : resBody) : null,
                Endpoint__c = request != null ? request.getEndpoint() : null,
                Class_Name__c = className != null ? className : null,
                Logging_Level__c = logLevel != null ? String.valueOf(logLevel) : null,
                StackTrace__c = classMethod != null ? classMethod : null,
                Message__c = resBody != null ? (resBody.length() > 131072 ? resBody.substring(0, 131072) : resBody) : null,
                User_Friendly_Message__c = userFriendlyMessage != null ? (userFriendlyMessage.length() > 131072 ? userFriendlyMessage.substring(0, 131072) : userFriendlyMessage) : null
            );
            quickBooksLogs.add(log);
        } catch(Exception ex) {
            System.debug('LogService: ' + ex.getLineNumber() + ' , ' + ex.getMessage());
            addLog(ex.getMessage(), 'LogService', 'addLog', LoggingLevel.ERROR);
        }
    }
    
    public static void addLog(String message, String classMethod, String component, System.LoggingLevel logLevel){
        try {
            Twitter_Log__c log = new Twitter_Log__c(
                Message__c = message != null ? (message.length() > 131072 ? message.substring(0, 131072) : message) : null,
                Class_Name__c = classMethod,
                Logging_Level__c = String.valueOf(logLevel),
                StackTrace__c = classMethod
            );
            quickBooksLogs.add(log);
        } catch(Exception ex) {
            System.debug('Error on addLog - LogService: ' + ex.getLineNumber() + ' , ' + ex.getMessage());
        }
    }
    
    
    public static void publish(){
        try {
            if(!quickBooksLogs.isEmpty()){
                insert quickBooksLogs;
                quickBooksLogs = new List<Twitter_Log__c>();
            } 
        } catch (Exception ex) {
            System.debug('Error on publish - LogService: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

}