global class GetBranchInformationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
    private String query; 
    global Integer recordsProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // getting the repositories which the user wants to monitor
		return Database.getQueryLocator('SELECT ID, Repository_Id__c, Name, GitHubOwner__r.Login__c  FROM Repository__c WHERE IsMonitored__c = true');
	}
    
    global void execute(Database.BatchableContext BC, List<Repository__c> scope) {
        List<Branch__c> allBranches = new List<Branch__c>();
        List<Branch__c> branches = new List<Branch__c>();

        for(Repository__c rep : scope) {
            // getting the branches of each repository
            branches = GitHub.getRepoBranches(rep.GitHubOwner__r.Login__c, rep.Name, rep.Repository_Id__c, false);
            // in case we have branches
            if(branches != null) {
                // we add them in a list to upsert them
                allBranches.addAll(branches);
            }
        }

        try{
            // upserting branches by external_id__c field
            Database.upsert(allBranches,GitHubService.getExternalFieldToUpdateRecords('External_Id__c', 'Branch__c'),false);
            recordsProcessed = allBranches.size();
        }catch(Exception e){
            System.debug('EXCEPTION UPSERTING BRANCHES: ' + e);
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
        
        if(!Test.isRunningTest()){ 
            Database.executeBatch(new GetCommitsInformationBatch(), 100);
        }
    }
}