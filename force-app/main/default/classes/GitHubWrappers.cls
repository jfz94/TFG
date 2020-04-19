public class GitHubWrappers {

    public class Repository {
        public Integer id {get;set;} 
        public String node_id {get;set;} 
        public String name {get;set;} 
        public Boolean private_Z {get;set;}
        public String html_url {get;set;} 
        public String description {get;set;} 
        public Boolean fork {get;set;} 
        public String url {get;set;} 
        public String forks_url {get;set;}
        public String tags_url {get;set;} 
        public String downloads_url {get;set;}
        public Integer size {get;set;} 
        public Integer stargazers_count {get;set;} 
        public String language {get;set;} 
        public Boolean has_issues {get;set;} 
        public Boolean has_projects {get;set;} 
        public Boolean has_downloads {get;set;} 
        public Boolean has_wiki {get;set;} 
        public Boolean has_pages {get;set;}
        public Boolean archived {get;set;} 
        public Boolean disabled {get;set;} 
        public License license {get;set;} 
        public Integer forks {get;set;} 
        public Integer open_issues {get;set;} 
        public Integer watchers {get;set;} 
        public String default_branch {get;set;}  
        public Author owner {get;set;} 
    }
    
    public class License {
        public String key {get;set;} 
        public String name {get;set;} 
        public String spdx_id {get;set;} 
        public String url {get;set;} 
        public String node_id {get;set;} 
    }
    
    /* BRANCH */
    
    public class Branch {
        public String name {get;set;} 
        public BranchCommit commit_Z {get;set;} 
        public Boolean protected_Z {get;set;} 
    }

    public class BranchCommit {
        public String sha {get;set;} 
        public String url {get;set;} 
    }

    /* COMMIT */

    public class CommitObject {
    
        public String sha {get;set;} 
        public String node_id {get;set;} 
        public String url {get;set;} 
        public String html_url {get;set;}
        public Author author {get;set;} 
        public Author committer {get;set;} 
        public CommitInfo commit_Z {get;set;}
    }

    public class CommitInfo {
        public String message {get;set;} 
        public Tree tree {get;set;} 
    }

    public class Tree {
        public String sha {get;set;} 
        public String url {get;set;}
    }

    /* SEARCHES */

    public class RepositorySearch {
        public List<GitHubWrappers.Repository> items {get;set;} 

    }

    public class Author {
		public String login {get;set;} 
		public Integer id {get;set;} 
		public String node_id {get;set;} 
		public String avatar_url {get;set;} 
		public String url {get;set;} 
		public String html_url {get;set;} 
		public String repos_url {get;set;}
    }
}