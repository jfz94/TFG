@isTest
global without sharing class  TestDataFactory {

    global static Repository__c createRepository(String repoName, String repoId, Boolean isMonitored, GitHub_User__c user){
        return new Repository__c(
            Name = repoName,
            Repository_Id__c = repoId,
            IsMonitored__c = isMonitored,
            GitHubOwner__c = user.Id
        );
    }

    global static GitHub_User__c createGitHubUser(String loginName, String externalId) {
        return new GitHub_User__c(
            Login__c = loginName,
            External_Id__c = externalId
        );
    }

    global static ContentVersion createContentVersion(String title,  String path, String version){
        return new ContentVersion(
            Title= title,
            PathOnClient = path + '.pdf',
            VersionData = EncodingUtil.base64Decode(version)
        );
    }
}