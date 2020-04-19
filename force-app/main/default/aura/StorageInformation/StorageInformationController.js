({
	doInit : function(component, event, helper) {
		helper.getStorageInformation(component, event, helper);
	},
    
    refreshStorageValues: function(component, event, helper) {
        helper.getCurrentStorage(component, event, helper);
    }
})