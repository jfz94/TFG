@isTest
private class GitHubTest {
    public static testMethod void getReposUsernameTest() {
        
        GitHub_User__c repoOwner = new GitHub_User__c(
            Login__c = 'jfz94',
            External_Id__c = '14350484'
        );
        insert repoOwner; 
        
    	Test.startTest();
        	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ReposMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
        	GitHub.getRepos(repoOwner.Login__c);
        Test.stopTest();
    }
    
    public static testMethod void getRepoByNameTest() {
        Test.startTest();
        	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('RepoByNameMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
        	GitHub.getRepoByName('jfz94','jfz94.github.io');
        Test.stopTest();
    }
    
    public static testMethod void searchRepoByNameTest() {
        Test.startTest();
        	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('SearchRepoByNameMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
        	GitHub.searchReposByName('github',1, null, 'interactions-asc');
        Test.stopTest();
    }

    public static testMethod void refreshCommitsTest() {

        GitHub_User__c repoOwner = new GitHub_User__c(
            Login__c = 'jfz94'
        );
        insert repoOwner;

        Repository__c rep = new Repository__c( 
            Name = 'jfz94.github.io',
            Repository_Id__c = '83738',
            IsMonitored__c = true,
            GitHubOwner__c = repoOwner.Id
        );
        insert rep;

        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('CommitsMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 

        	GitHub.getCommits('jfz94', 'jfz94.github.io', rep.Repository_Id__c, true);
        Test.stopTest();
    }
}