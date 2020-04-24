@isTest
public class GitHubUserHandlerTest {
    public static testMethod void getReposUsernameTest() {

        GitHub_User__c repoOwner = new GitHub_User__c(
            Login__c = 'jfz94',
            Is_Get_All_Repositories__c = false
        );
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
    }
}