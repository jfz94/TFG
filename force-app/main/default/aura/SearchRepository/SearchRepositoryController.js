({
	doInit : function(component) {        
		var action = component.get("c.getPickListValuesIntoList");
		action.setCallback(this, function(response) {
			
			var state = response.getState();
			
			if(state === 'SUCCESS'){
				var list = response.getReturnValue();
				component.set("v.orderOptions", response.getReturnValue());
				component.find("selectOrderOptions").set("v.value"), list[0];
			}
			else if(state === 'ERROR'){
				alert('ERROR OCCURED.');
			}
		})
		$A.enqueueAction(action);
	},
	doSearch: function(component, event, helper) {
		var queryName = component.get("v.queryName");
		var queryDescription = component.get("v.queryDescription");
		var itemsNumber = component.get("v.itemNumber");

		var selectOrderOptionsCmp = component.find("selectOrderOptions"); // getting the component by aura:id
		component.set("v.selectedOrderOption",selectOrderOptionsCmp.get("v.value"));
		var orderOption = component.get("v.selectedOrderOption");

		var isEmptyName = $A.util.isEmpty(component.get("v.queryName"));
		var isEmptyDescription = $A.util.isEmpty(component.get("v.queryDescription"));
		
		if(!(isEmptyName && isEmptyDescription)) {	
			component.set('v.loaded', !component.get('v.loaded'));
			// call to method 
			var searchAction = component.get("c.searchReposByName");		
			
			if(itemsNumber > 15) {
				itemsNumber = 15;
			}
			
			searchAction.setParams({
				"repositoryName" : queryName,
				"numberOfItems" : itemsNumber,
				"repositoryDescription" : queryDescription,
				"orderOption" : orderOption
			});

			searchAction.setCallback(this, function(response) {
				component.set('v.loaded', !component.get('v.loaded'));
				var state = response.getState();
				if(state == 'SUCCESS'){
					component.set("v.repoList", response.getReturnValue());
					var resultsToast = $A.get("e.force:showToast");

					if(response.getReturnValue().length == 0) {
						resultsToast.setParams({
							"title": "Warning",
							"message": "No records have been found in GitHub with that name",
							type: 'warning'
						});
					}else{
						resultsToast.setParams({
							"title": "Success",
							"message": response.getReturnValue().length + " records have been created/ updated and ready for being monitored.",
							type: 'success'
						});
					}
					resultsToast.fire();
				}
			}); 
			$A.enqueueAction(searchAction);
		}else{
			var resultsToast = $A.get("e.force:showToast");
			resultsToast.setParams({
				"title": "Required data missing",
				"message": "Name or description should be filled",
				type: 'error'
			});
			resultsToast.fire();
		}
	},

	toggleForm: function(component, event, helper) {
		// change toggle button icon
		var evtSource = event.getSource();
		if(evtSource.get("v.iconName") === 'utility:chevrondown'){
            evtSource.set("v.iconName" , 'utility:chevronright' );
        } else {
            evtSource.set("v.iconName" , 'utility:chevrondown' );
		}
		//To show/hide form elements
        $A.util.toggleClass(component.find("formDiv"),'slds-hide');
	}
})