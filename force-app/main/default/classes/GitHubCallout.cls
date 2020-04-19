public class GitHubCallout extends HttpCallout{
	private String accessToken;

    public static Github__c githubSettings = Github__c.getOrgDefaults();
    private static final String AUTHORIZATION = 'Authorization';
	private static final String BEARER = 'Bearer ';
    
    public GitHubCallout(String method, String body, String methodName, String username, GitHubCallout.Repository rep) {
        super(method, buildEndpoint(methodName, username, rep));
        setAccessToken();
        
        setAuthorizationHeader(this.accessToken);
        if (body != null){
            setRequestBody(body);
        }
    }

    private void setAccessToken() {
        this.accessToken = githubSettings.Oauth_Token__c;
    }

    private void setRequestBody(String body) {
        this.request.setBody(body);
    }

    public void setAuthorizationHeader(String accessToken) {
        this.request.setHeader(AUTHORIZATION, BEARER + accessToken);
    }
    
    private static String buildEndpoint(String methodName, String username, GitHubCallout.Repository rep) {
        String repoName;
        String repoDescription;
        
        if(rep != null) {
            repoName = rep.Name;
            repoDescription = rep.Description;
        }
        

        String endpoint = githubSettings.Base_URL__c;
        switch on methodname {
            when 'GET_REPO_BY_NAME' {
                endpoint += '/repos/' + username + '/' + repoName; 
            }
            when 'GET_REPOS'{
                endpoint +=  '/users/' + username+ '/repos';
            }
            when 'GET_REPO_COMMITS' {
                endpoint += '/repos/' + username + '/' + repoName + '/commits';
            }
            when 'GET_BRANCHES' {
                endpoint += '/repos/' + username + '/' + repoName + '/branches';
            }
            when 'SEARCH_REPO' {
                List<String> words = new List<String>();
                endpoint += '/search/repositories?q=';
                if(repoName != null) {
                    words = repoName.split(' ');
                    String queryName = '';
                    for(String word: words) {
                        queryName += word + '+';
                    }
                    endpoint += queryName + 'in:name';
                
                }
                
                if(repoDescription != null) {
                    if(repoName != null){
                        endpoint += '+';
                    }
                    words = repoDescription.split(' ');
                    String queryDescription = '';
                    for(String word: words) {
                        queryDescription += word + '+';
                    }
                    endpoint +=  queryDescription + 'in:description';
                }

                if(rep.orderOption != null) {
                    endpoint += '+sort:'  +rep.orderOption;
                }
            }
                
        }
        return endpoint;
    }

    public class Repository {
        public String name {get; set;}
        public String description {get; set;}
        public String orderOption {get;set;}

        public Repository(String name){
            this.name = name;
        }

        public Repository(String name, String description) {
            this.name = name;
            this.description = description;
        }

        public Repository(String name, String description, String orderOption) {
            this.name = name;
            this.description = description;
            this.orderOption = orderOption;
        }
    }
}