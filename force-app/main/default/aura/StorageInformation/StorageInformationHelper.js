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
        action.setCallback(this, function(response) {
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.storageSettings", response.getReturnValue()); 
                console.log("Storage settings reloaded");
            }else {
                console.log("Storage settings failed to reload");
            }
    	});
    	$A.enqueueAction(action);
    }
})