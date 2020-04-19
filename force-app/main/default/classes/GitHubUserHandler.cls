public without sharing class GitHubUserHandler {

    public static List<GitHub_User__c> usersToGetRepositories  = new List<GitHub_User__c>();


    public GitHubUserHandler(){ 
    }

    public void onBeforeUpdate(List<GitHub_User__c> triggerOld , List<GitHub_User__c> triggerNew , Map<Id, GitHub_User__c> triggerOldMap , Map<Id, GitHub_User__c> triggerNewMap) {
        for(GitHub_User__c user : triggerNew) {
            if(Util.isChangedField(triggerNewMap.get(user.Id), triggerOldMap.get(user.Id),'Is_Get_All_Repositories__c') && user.Is_Get_All_Repositories__c == true) {
                usersToGetRepositories.add(user);
                user.Is_Get_All_Repositories__c = false;
            }
        }
    }

    public void onAfterUpdate(List<GitHub_User__c> triggerOld , List<GitHub_User__c> triggerNew , Map<Id, GitHub_User__c> triggerOldMap , Map<Id, GitHub_User__c> triggerNewMap) {
        if(!usersToGetRepositories.isEmpty()) {
            for(GitHub_User__c u : usersToGetRepositories) {
                GitHub.getRepos(u.Login__c);
            }
        }
    }

    
}