@isTest
private class GetBranchInformationBatchTest {
    static testMethod void getBranchInformationBatch_Test() {
        Repository__c rep = new Repository__c( 
            Name = 'repoTest1',
            Repository_Id__c = '83738',
            IsMonitored__c = true
        );
        insert rep;

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