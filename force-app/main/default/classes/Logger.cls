public class Logger {
    private static Logger instance = null;
    private Logger(){}
    
    public static Logger getInstance(){
        if(instance == null){
            instance = new Logger();
        }
        return instance;
    }
    
    public void debug(String message, String classMethod, String component){
        LogService.addLog(message, classMethod, component, LoggingLevel.DEBUG);
    }
    
    public void error(HttpRequest request, HttpResponse response, String className, String classMethod){
        LogService.addLog(request, response, className, classMethod, LoggingLevel.ERROR, null);
    }
    
    public void error(HttpRequest request, HttpResponse response, String className, String classMethod, String userFriendlyMessage){
        LogService.addLog(request, response, className, classMethod, LoggingLevel.ERROR, userFriendlyMessage);
    }
    
    public void error(String message, String classMethod, String component){
        LogService.addLog(message, classMethod, component, LoggingLevel.ERROR);
    }
    
    public void publish(){
        LogService.publish();
    }
}