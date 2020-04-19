global with sharing class GitHub {

    public static Map<String,String> picklistValueByLabel = new Map<String,String>();

    static{

        Schema.DescribeFieldResult fieldResult = Order_option__mdt.Order_Option__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
		for( Schema.PicklistEntry pickListVal : ple){
            picklistValueByLabel.put(pickListVal.getLabel(), pickListVal.getValue());
		}  

    }


    @future (callout=true) 
    // method to get the repos of a user by username
	public static void getRepos(String username) {
        GithubCallout repoCallout = new GithubCallout('GET', null, 'GET_REPOS', username, null);
        // sending request
        repoCallout.send();
        // we get the response of the request
        HttpResponse resp = repoCallout.response;
        // if response == 200, OK
        if(resp.getStatusCode() == 200) {
            // list where we save the repositories to add in Salesforce
            List<Repository__c> repositoriesToAdd = new List<Repository__c>();
            // replacing string "private" in response 
            String jsonBody = resp.getBody().replace('"private":', '"private_Z":');
            // deserializing response body into a Repository list
            List<GitHubWrappers.Repository> repositories = (List<GitHubWrappers.Repository>)JSON.deserialize(jsonBody, List<GitHubWrappers.Repository>.class);
            // for each deserialized structure
            for(GitHubWrappers.Repository rep : repositories) {
                // we convert the structure into a Repository__c object and we add it into the list
                repositoriesToAdd.add(GithubService.convertRepo(rep));
            }
            // if the repository list is not empty
            if(!repositoriesToAdd.isEmpty()) {
                try{
                    // upserting repositories 
                	Database.upsert(repositoriesToAdd,GitHubService.getExternalFieldToUpdateRecords('Node_Id__c', 'Repository__c'),false);  
                }catch(Exception e){
                    System.debug('EXCEPTION UPSERTING REPOSITORIES: ' + e);
                }
            }
        }       
    }

    @AuraEnabled
    public static List<Repository__c> searchReposByName(String repositoryName, Integer numberOfItems, String repositoryDescription, String orderOption){
        GitHubCallout repoCallout = new GitHubCallout('GET', null, 'SEARCH_REPO', null, new GitHubCallout.Repository(repositoryName,repositoryDescription, orderOption));
        // sending request
        repoCallout.send();
        // we get the response of the request
        HttpResponse resp = repoCallout.response;
        // list where we put the items encountered
        List<Repository__c> itemsToAdd = new List<Repository__c>();
        // if the response = 200, OK
        if(resp.getStatusCode() == 200) {
            // replacing string "private" in response 
            String  jsonBody = resp.getBody().replace('"private":', '"private_Z":');
            // deserializing response body into a RepositorySearch class
            GithubWrappers.RepositorySearch search = (GithubWrappers.RepositorySearch)JSON.deserialize(jsonBody, GithubWrappers.RepositorySearch.class);
            // integer which we are going to use to counter the results
            Integer repositoryCounter = 0;
            for(GitHubWrappers.Repository rep : search.items) {
                // check if we have the number of items specified by param
                if(repositoryCounter == numberOfItems) {
                    break;
                }
                // we add 1 to the counter
                repositoryCounter++;
                // we add the repo into the list
                itemsToAdd.add(GithubService.convertRepo(rep));
            }

            try{
                // upserting the repo by Node_Id__c external field
                Database.upsert(itemsToAdd,GitHubService.getExternalFieldToUpdateRecords('Node_Id__c', 'Repository__c'),false);
            }catch(Exception e){
                System.debug('EXCEPTION UPSERTING SEARCHED REPOS : ' + e);
            }
        }    
        return itemsToAdd;
    }
	
    // get repository information by name (not used)
    public static void getRepoByName(String username, String repositoryName) {
        GithubCallout repoCallout = new GithubCallout('GET', null, 'GET_REPO_BY_NAME', username, new GitHubCallout.Repository(repositoryName));
        // sending request
        repoCallout.send();
        HttpResponse resp = repoCallout.response;
        // if the response = 200, OK
        if(resp.getStatusCode() == 200) {
            String  jsonBody = resp.getBody().replace('"private":', '"private_Z":');
            // deserializing the response body
            GitHubWrappers.Repository repository = (GitHubWrappers.Repository)JSON.deserialize(jsonBody, GitHubWrappers.Repository.class);
            // converting the repo
            Repository__c rep = GithubService.convertRepo(repository);
            
            try{
                // upserting the repo by Node_Id__c external field
                Database.upsert(rep,GitHubService.getExternalFieldToUpdateRecords('Node_Id__c', 'Repository__c'),false);
            }catch(Exception e){
                System.debug('EXCEPTION GETTING REPO BY NAME : ' + e);
            }
        }       
    }
	
    // gets the branches of a repository
    @AuraEnabled
	public static List<Branch__c> getRepoBranches(String username, String repositoryName, String repoId, Boolean isRefresh) { 
        GithubCallout repoCallout = new GithubCallout('GET', null, 'GET_BRANCHES', username, new GitHubCallout.Repository(repositoryName));
        // sending request
        repoCallout.send();
        HttpResponse resp = repoCallout.response;
        // if the response = 200, OK
        if(resp.getStatusCode() == 200) {
            // getting the repository
            Repository__c rep =  GithubService.getCurrentRepository(repoId); 
            // replacing string "commit" in response 
            String  jsonBody = resp.getBody().replace('"commit":', '"commit_Z":');
            // replacing string "protected" in response 
            jsonBody = jsonBody.replace('"protected":', '"protected_Z":');
            // we deserialize the body response to a list of Branch
            List<GitHubWrappers.Branch> branchesStructures = (List<GitHubWrappers.Branch>)JSON.deserialize(jsonBody, List<GitHubWrappers.Branch>.class);
            // list where we add the branches to be inserted
            List<Branch__c> branchesToAdd = new List<Branch__c>();
            
            for(GitHubWrappers.Branch br : branchesStructures) {
                branchesToAdd.add(new Branch__c(
                    Name = br.name,
                    External_Id__c = br.Name + rep.Id, 
                    Repository__c = rep.Id,
                	SHA__c = br.commit_Z.sha,
                    URL__c = br.commit_Z.url
                ));
            }
            // if is a refresh (LC) 
            if(isRefresh == true) {
                // we upsert the branches by External_Id__c external field
                upsert branchesToAdd External_Id__c;
            }
            // if there are some branches -> by default a repo has a master branch
            if(!branchesToAdd.isEmpty() && !isRefresh) {
                // we return the branches list
                return branchesToAdd;
            }
        }       
        return null;
	}
    
    @AuraEnabled
    // gets the commits and trees of a repository 
    public static CommitStructure getCommits(String username, String repositoryName, String repoId, Boolean isRefresh) {
        GithubCallout repoCallout = new GithubCallout('GET', null, 'GET_REPO_COMMITS', username, new GitHubCallout.Repository(repositoryName));
        // sending request
        repoCallout.send();
        HttpResponse resp = repoCallout.response;
        // if the response = 200, OK
        if(resp.getStatusCode() == 200) {
            // getting the repository record in Salesforce
            Repository__c rep = GitHubService.getCurrentRepository(repoId); 
            // replacing string "commit" in response 
            String jsonBody = resp.getBody().replace('"commit":', '"commit_Z":');
            // deserializing the response into a list of commitObjects		
            List<GitHubWrappers.CommitObject> commitsStructures = (List<GitHubWrappers.CommitObject>)JSON.deserialize(jsonBody, List<GitHubWrappers.CommitObject>.class);
            // structure where we save the commits by tree sha code
            Map<String, List<GitHubService.CommitWrapper>> treeByCommitWrapper = new Map<String, List<GitHubService.CommitWrapper>>();
            // structure where we save the tree with sha code
            Map<String, Tree__c> treeMap = new Map<String, Tree__c>();

			// per cada commit deserialitzat             
            for(GitHubWrappers.CommitObject commitApex : commitsStructures) {
                // adding tree information to treeMap structure
                treeMap.put(commitApex.commit_Z.tree.sha, new Tree__c(  SHA__c = commitApex.commit_Z.tree.sha,  URL__c = commitApex.commit_Z.tree.url ));
				// we check if the map treeByCommitWrapper contains the sha of the tree -> a tree can contain more than one commit
                if(!treeByCommitWrapper.containsKey(commitApex.commit_Z.tree.sha)) {
                    // if yes, we add the tree and create a new list of commitWrapper
                    treeByCommitWrapper.put(commitApex.commit_Z.tree.sha, new List<GitHubService.CommitWrapper>());
                }
                // we get the sha code of the tree and we add the commit
                treeByCommitWrapper.get(commitApex.commit_Z.tree.sha).add(GitHubService.createCommitWrapper(commitApex, rep));
            }

            // if is a refresh (LC) 
            if(isRefresh == true) {
                // we have to upsert everything
                // intentar trucar a un metode des del batch
                Util.updateCommitStructure(new CommitStructure(treeMap, treeByCommitWrapper));
                return null;
            }

            // finally, we return the structure created
            return new CommitStructure(treeMap, treeByCommitWrapper);
        }
        // in case sth went bad, return null
        return null;
    }

    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(){
        return new List<String>(picklistValueByLabel.keySet()); 
    }
    
    // COMMITSTRUCTURE INNER CLASS ( this class contains: trees and commit wrappers)
    public class CommitStructure {
        // list where we put the trees
        public List<Tree__c> trees {get;set;}
        // structure where we save commits of each sha tree
        public  Map<String, List<GitHubService.CommitWrapper>> commitWrapperPerTree {get;set;}
        // structure where we save trees sha
        public Set<String> treesSHA {get;set;}

        public CommitStructure(Map<String, Tree__c> trees, Map<String, List<GitHubService.CommitWrapper>> commitWrapperPerTree) {
            // we saved the structure where we have commits for tree
            this.commitWrapperPerTree = commitWrapperPerTree;
            // we get the values of the map (trees)
            this.trees = trees.values();
            // we get the keys of the map (sha trees codes)
            this.treesSHA = trees.KeySet(); 
        }
    }
}