public virtual class HttpCallout {
    protected Http callout { get; set;}
    protected HttpRequest request { get; set; }
    
    public HttpResponse response { get; set; }

    public HttpCallout(String method, String endpoint) {
        this.callout = new Http();
        this.request = new HttpRequest();
        this.request.setEndpoint(endpoint);
        this.request.setMethod(method);
    }

    public void send() {
        this.response = this.callout.send(this.request);
    }
}