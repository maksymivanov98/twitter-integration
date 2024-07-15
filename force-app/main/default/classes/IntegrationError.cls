public virtual class IntegrationError {

    @testVisible
    protected String errorMessage;

    public IntegrationError() {

    }

    public IntegrationError(Exception ex) {
        this.errorMessage = ex.getMessage();
    }

    public String getMessage() {
        return errorMessage;
    }
}