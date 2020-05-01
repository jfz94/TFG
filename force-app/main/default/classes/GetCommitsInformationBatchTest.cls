@isTest
public class GetCommitsInformationBatchTest {
    static testMethod void getCommitsInformationBatch_Test() {
        GitHub_User__c repoOwner = TestDataFactory.createGitHubUser('jfz94', '14350484');
        insert repoOwner;
        
        insert TestDataFactory.createRepository('repoTest1','83738', true, repoOwner);
        
        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('CommitsMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
            GetCommitsInformationBatch batch = new GetCommitsInformationBatch();
            Database.executeBatch(batch);
        Test.stopTest();
        List<Commit__c> commits = [SELECT ID FROM Commit__c];
        System.assertEquals(2, commits.size());
    }
}