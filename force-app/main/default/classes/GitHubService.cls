public class GitHubService {
    
    // method where we do the mapping between a Repository and a Repository__c Salesforce record 
    public static Repository__c convertRepo(GitHubWrappers.Repository rep) {
        // we get the value of the license
		GitHubWrappers.License lic = rep.license;
        License__c license;
        // we check if the value is null
        if(lic != null) {
            // if not, we get the license__c and we check if we have it in Salesforce
            license = GitHubService.getLicense(lic);
            // in case we don't have it 
            if(license == null) {
                // we create and insert the license
                license = GitHubService.createLicense(lic);
                insert license;
            }
        }
        // we get the value of the repository owner
        GitHubWrappers.Author gitHubOwner = rep.owner;
        GitHub_User__c repositoryOwner;
        // we check if the value is null
        if(gitHubOwner != null) {
            // if not, we get the Github_User__c and we check if we have it in Salesforce
            repositoryOwner = GitHubService.getUser(gitHubOwner);
            // in case we don't have it
            if(repositoryOwner == null) {
                // we create and insert the owner
                repositoryOwner = GitHubService.createUser(gitHubOwner);
                insert repositoryOwner;
            }
        }
        // finally, we return the repository__c object
        return createRepository(rep, license, repositoryOwner);
    }

    public static CommitWrapper createCommitWrapper(GitHubWrappers.CommitObject com, Repository__c repository) {
        GitHubWrappers.Author author = com.author;
        GitHubWrappers.Author committer = com.committer;
        
        GitHub_User__c userAuthor;
        GitHub_User__c userCommitter;
        
        Commit__c c = new Commit__c (
            SHA__c = com.sha,
            Node_Id__c = com.node_id,
            URL__c = com.url,
            HTML_URL__c = com.html_url,
            Repository__c = repository.Id,
            Message__c = com.commit_Z.message
        );
        
        if(author != null) {
            userAuthor = GitHubService.createUser(author);
        }
        
        if(committer != null) {
            userCommitter = GitHubService.createUser(committer);
        }
        
        return new CommitWrapper(c, userAuthor, userCommitter);
    }    

    // returns a repository__c record from Repository, License__c and GitHub_User__c variables
    public static Repository__c createRepository(GitHubWrappers.Repository rep, License__c lic, GitHub_User__c repositoryOwner) {
        return new Repository__c( 
        	Repository_Id__c = String.valueOf(rep.id),
            Node_Id__c = rep.node_id,
            Name = rep.name,
            IsPrivate__c = rep.private_Z,
            GitHub_URL__c = rep.html_url,
            Description__c = rep.description,
            IsFork__c = rep.fork,
            API_URL__c = rep.url,
            Forks_URL__c = rep.forks_url,
            Tags_URL__c = rep.tags_url,
            Downloads_URL__c = rep.downloads_url,
            Size__c = rep.size,
            Number_of_Favourites__c = rep.stargazers_count,
            Language__c = rep.Language,
            Has_Issues__c = rep.has_issues,
            Has_Projects__c = rep.has_projects,
            Has_Downloads__c = rep.has_downloads,
            Has_Wiki__c = rep.has_wiki,
            Has_Pages__c = rep.has_pages,
            IsArchived__c = rep.archived,
            IsDisabled__c = rep.disabled, 
            Number_of_Forks__c = rep.forks,
            Number_of_Open_Issues__c = rep.open_issues,
            Number_of_Watchers__c = rep.watchers,
            Default_Branch__c = rep.default_branch,
            License__c = lic == null ? null : lic.Id,
            GitHubOwner__c = repositoryOwner == null ? null : repositoryOwner.Id
        );
    }
    //returns a GitHub_User__c record from Author variable
    public static GitHub_User__c createUser(GitHubWrappers.Author author) {
        return new GitHub_User__c(
            Name = author.login,
            External_Id__c =String.valueOf(author.id),
            Node_Id__c = author.node_id,
            HTML_URL__c = author.html_url,
            Avatar_URL__c = author.avatar_url,
            Repositories_URL__c = author.repos_url,
            URL__c = author.url,
            Login__c = author.login
        );
    }

    //returns a License__c record from License variable
    public static License__c createLicense(GitHubWrappers.License lic) {
        return new License__c(
            Key__c = lic.key,
            License_Id__c = lic.spdx_id,
            Name = lic.name,
            Node_Id__c = lic.node_id,
            URL__c = lic.url
        );
    }

    // returns a Repository__c record from Salesforce if exists
    public static Repository__c getCurrentRepository(String repoId) {
        return [SELECT Id, Name FROM Repository__c WHERE Repository_Id__c =: repoId];
    }

    // returns a License__c record from Salesforce if exists
    public static License__c getLicense(GitHubWrappers.License license) {
        try{
            return [SELECT Id, Node_Id__c FROM License__c WHERE Node_Id__c =: license.node_id];
        }catch(Exception e){
            System.debug('Exception: ' + e);
        }
        return null; 
    }
    
    // returns a GitHub_User__c record from Salesforce if exists
    public static Github_User__c getUser(GitHubWrappers.Author user) {
        try{
            return [SELECT Id, External_Id__c FROM GitHub_User__c WHERE External_Id__c =: String.valueOf(user.id)];
        }catch(Exception e){
            System.debug('Exception: ' + e);
        }
        return null; 
    }
    
    public static Schema.SObjectField getExternalFieldToUpdateRecords(String fieldName, String objectName){
		return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
    }

    // INNER CLASSES

    public class CommitWrapper {
        public Commit__c commitRecord {get;set;}
        public GitHub_User__c author {get;set;}
        public GitHub_User__c committer {get;set;}

        public CommitWrapper(Commit__c commitRecord, GitHub_User__c author, GitHub_User__c committer) {
            this.commitRecord = commitRecord;
            this.author = author;
            this.committer = committer;
        }
    }
}