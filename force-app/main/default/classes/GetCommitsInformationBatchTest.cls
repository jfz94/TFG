@isTest
public class GetCommitsInformationBatchTest {
    static testMethod void getCommitsInformationBatch_Test() {
        GitHub_User__c repoOwner = new GitHub_User__c(
            Login__c = 'jfz94'
        );
        insert repoOwner;
        
        Repository__c rep = new Repository__c( 
            Name = 'repoTest1',
            Repository_Id__c = '83738',
            IsMonitored__c = true,
            GitHubOwner__c = repoOwner.Id
        );
        insert rep;

        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('CommitsMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/xml');
            Test.setMock(HttpCalloutMock.class, mock); 
            GetCommitsInformationBatch batch = new GetCommitsInformationBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }
}