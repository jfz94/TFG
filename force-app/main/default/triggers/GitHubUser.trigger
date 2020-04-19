trigger GitHubUser on GitHub_User__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	GitHubUserHandler handler = new GitHubUserHandler();

    if (Trigger.isBefore) {
		if (Trigger.isUpdate) {
			handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.OldMap, Trigger.NewMap); 
		}
	} else {
		if (Trigger.isUpdate) {
			handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap); 
		}
	}
}