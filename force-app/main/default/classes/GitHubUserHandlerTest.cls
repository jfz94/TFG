@isTest
public class GitHubUserHandlerTest {
    public static testMethod void getReposUsernameTest() {

        GitHub_User__c repoOwner = TestDataFactory.createGitHubUser('jfz94','14350484');
        repoOwner.Is_Get_All_Repositories__c = false;
        insert repoOwner;

        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ReposMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
            repoOwner.Is_Get_All_Repositories__c = true;
            update repoOwner;
        Test.stopTest();
        List<Repository__c> reps = [SELECT ID, GitHubOwner__c FROM Repository__c WHERE GitHubOwner__r.Login__c =: repoOwner.Login__c];

        System.assertNotEquals(0, reps.size());
        System.assertEquals(2, reps.size());
    }
}