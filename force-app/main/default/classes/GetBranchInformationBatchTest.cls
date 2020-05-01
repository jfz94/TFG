@isTest
private class GetBranchInformationBatchTest {
    static testMethod void getBranchInformationBatch_Test() {
        GitHub_User__c repoOwner = TestDataFactory.createGitHubUser('jfz94', '14350484');
        insert repoOwner;

        insert TestDataFactory.createRepository('repoTest1','83738', true, repoOwner);

        Administrator__mdt admin = new Administrator__mdt(Email__c = 'test@gmail.com');

        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('BranchesMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
            GetBranchInformationBatch batch = new GetBranchInformationBatch();
            Database.executeBatch(batch);
        Test.stopTest();
    }
}