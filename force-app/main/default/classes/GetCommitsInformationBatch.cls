global class GetCommitsInformationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
    private String query;
    global Integer recordsProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // getting the repositories which the user wants to monitor
        return Database.getQueryLocator('SELECT ID, Name, GitHubOwner__r.Login__c, Repository_Id__c  FROM Repository__c WHERE IsMonitored__c = true');
	}
    
    global void execute(Database.BatchableContext BC, List<Repository__c> scope) {
        
        // list where we will put the trees to insert in Salesforce
        List<Tree__c> treesToInsert = new List<Tree__c>();
        // structure where we will put the wrapper with the commit structure
        Map<String, List<GitHubService.CommitWrapper>> commitWrapperPerTree = new Map<String,List<GitHubService.CommitWrapper>>();
        // set where we will put the SHA codes of the commits
        Set<String> treesSHA = new Set<String>();
        // list where we add the commits to be upserted
        List<Commit__c> commitsToAdd = new List<Commit__c>();
        
        for(Repository__c rep : scope) {
            // for each repository we call the method which we get the commits
            GitHub.CommitStructure structure = GitHub.getCommits(rep.GitHubOwner__r.Login__c, rep.Name, rep.Repository_Id__c, false);
            // if we have information
            if(structure != null) {
                // for each structure we get the trees and we add it to the list
                treesToInsert.addAll(structure.trees); 
                // for each structure we put the commits by tree
                commitWrapperPerTree.putAll(structure.commitWrapperPerTree);
                // we add the sha codes of the trees
                treesSHA.addAll(structure.treesSHA);
            }
        }

        // if we have trees
        if(!treesToInsert.isEmpty()) {
            try{
                // we upsert the trees by SHA__c external field
                upsert treesToInsert SHA__c;
                recordsProcessed += treesToInsert.size();
            }catch(Exception e) {
                System.debug('EXCEPTION UPSERTING TREES: ' + e);
            }

            // structure where we will put salesforce id by sha tree code  
            Map<String,ID> treeIDsBySHA = new Map<String, ID>();

            // for each tree upserted, we fill the map
            for(Tree__c t : [SELECT Id, SHA__c FROM Tree__c WHERE SHA__c IN :treesSHA]){
                treeIDsBySHA.put(t.SHA__c, t.Id);
            }

            // structure which we will put all GitHub_User__c to upsert
            Map<String,GitHub_User__c> users = new Map<String, GitHub_User__c>(); //Util.fillUsersMap(commitWrapperPerTree);
            Util.fillUserMap(users, commitWrapperPerTree);

            try{
                List<GitHub_User__c> usersValues = users.values();
                // we upsert the github users by external_id__c field
                upsert usersValues External_Id__c;
                recordsProcessed += usersValues.size();
            }catch(Exception e) {
                System.debug('EXCEPTION UPSERTING GITHUB USERS: ' + e);
            }
            
            // if we had users
            if(!users.values().isEmpty()) {
                
                // we create a structure to put GitHub_User__c record by external_id
                Map<String, GitHub_User__c> usersById = new Map<String, GitHub_User__c>();
                // we fill the previous map
                for(GitHub_User__c user : [SELECT Id, External_Id__c FROM GitHub_User__c WHERE External_Id__c IN :users.keyset()]){
                    usersById.put(user.External_Id__c, user);
                }

                Util.fillCommitsMap(commitsToAdd, treeIDsBySHA, usersById, commitWrapperPerTree);
                
                try {
                    // we upsert te commits by SHA__c external field
                    upsert commitsToAdd SHA__c;
                    recordsProcessed += commitsToAdd.size();
                }catch(Exception e){
                    System.debug('EXCEPTION UPSERTING COMMITS: ' + e);
                }
            }
        }
        
    }
    
    global void finish (Database.BatchableContext BC) { 
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                JobItemsProcessed, ApexClassId, ApexClass.Name, 
                TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :BC.getJobId()];
        
        List<String> emails = new List<String>();
        for (Administrator__mdt admin : [SELECT Email__c FROM Administrator__mdt]) {
            emails.add(admin.Email__c);
        }
        
        if(Limits.getEmailInvocations() + 1 < Limits.getLimitEmailInvocations() && !Test.isRunningTest()){
            Util.sendMessage(job, recordsProcessed, emails);
        }
    }
}