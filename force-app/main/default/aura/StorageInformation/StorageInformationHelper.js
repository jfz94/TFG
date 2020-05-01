({
	getStorageInformation : function(component, event, helper) {
        var action = component.get("c.getStorageInformation");
        
        action.setCallback(this, function(response) {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.storageSettings", response.getReturnValue()); 
                console.log("Storage settings loaded");
            }else {
                console.log("Storage settings failed to load");
            }
    	});
    	$A.enqueueAction(action);
	},
    
    getCurrentStorage: function(component, event, helper) {
        var action = component.get("c.getStorage");
        action.setCallback(this, function(response) {7
            var resultsToast = $A.get("e.force:showToast");
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.storageSettings", response.getReturnValue()); 
                resultsToast.setParams({
                    "title": $A.get("$Label.c.Storage_success_title"),
                    "message": $A.get("$Label.c.Storage_success_message"),
                    type: 'Success'
                });
            }else {
                resultsToast.setParams({
                    "title": $A.get("$Label.c.Storage_error_title"),
                    "message": $A.get("$Label.c.Storage_error_message"),
                    type: 'Error'
                });
            }
            resultsToast.fire();
    	});
    	$A.enqueueAction(action);
    }
})