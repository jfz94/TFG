@isTest
private class GitHubTest {
    public static testMethod void getReposUsernameTest() {
        
        GitHub_User__c repoOwner = TestDataFactory.createGitHubUser('jfz94','14350484');
        insert repoOwner; 
        
    	Test.startTest();
        	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ReposMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
        	GitHub.getRepos(repoOwner.Login__c);
        Test.stopTest();
        List<Repository__c> reps = [SELECT ID FROM Repository__c];
        System.assertEquals(2, reps.size());
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
            Repository__c rep = [SELECT Id, Description__c FROM Repository__c LIMIT 1];
            System.assertEquals('this is a description', rep.Description__c);
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
            List<Repository__c> reps = [SELECT ID FROM Repository__c];
            System.assertEquals(1, reps.size());
    }

    public static testMethod void refreshCommitsTest() {

        GitHub_User__c repoOwner = TestDataFactory.createGitHubUser('jfz94','14350484');
        insert repoOwner;

        Repository__c rep = TestDataFactory.createRepository('jfz94.github.io','83738', true, repoOwner);
        insert rep;

        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('CommitsMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 

        	GitHub.getCommits('jfz94', 'jfz94.github.io', rep.Repository_Id__c, true);
        Test.stopTest();
        List<Commit__c> commits = [SELECT ID FROM Commit__c];
        System.assertEquals(2, commits.size());
    }
}