({	
	getCommitsFromGitHub : function(component, event, helper) {
		var recId = $A.get("$SObjectType.CurrentUser.Id");

		var recordName = component.get("v.simpleRecord").Name;
		var githubUsername = component.get("v.simpleRecord").GitHubOwner__r.Name;
		var repoId = component.get("v.simpleRecord").Repository_Id__c;

		var isEmptyOwner = $A.util.isEmpty(component.get("v.simpleRecord").GitHubOwner__r.Name);
		var isEmptyName = $A.util.isEmpty(component.get("v.simpleRecord").Name);
		var isEmptyRecordId = $A.util.isEmpty(component.get("v.simpleRecord").Repository_Id__c);


		if(!isEmptyOwner && !isEmptyName && !isEmptyRecordId) {
			var action = component.get("c.getCommits");

			action.setParams({
				"username" : githubUsername,
				"repositoryName" : recordName,
				"repoId" : repoId,
				"isRefresh" : true
			});

			action.setCallback(this, function(response) {
				var state = response.getState();
				var resultsToast = $A.get("e.force:showToast");
				if (state === "SUCCESS") {
					resultsToast.setParams({
						"title": "Success",
						"message": $A.get("$Label.c.Commits_succesfully_updated"),
						type: 'success'
					});
					resultsToast.fire();
					helper.refreshDelayed();
				}else{
					resultsToast.setParams({
						"title": "Error",
						"message": $A.get("$Label.c.Commits_not_succesfully_updated"), 
						type: 'error'
					});
					resultsToast.fire();
				}
			});
			$A.enqueueAction(action);
		}else{
			var resultsToast = $A.get("e.force:showToast");
			resultsToast.setParams({
				"title": "Warning",
				"message": $A.get("$Label.c.Required_data_missing"),
				type: 'warning'
			});
			resultsToast.fire();
			helper.refreshDelayed();
		}
    }
})