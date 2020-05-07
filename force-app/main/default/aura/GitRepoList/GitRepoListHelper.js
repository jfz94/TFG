({
    fetchRepos : function(component) {

        var action = component.get("c.getOwnerName");

        action.setParams({
            "repoId" : component.get('v.recordId')
        });


        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userName = response.getReturnValue();
                component.set("v.userName", userName);
                var params = {
                    'hostingService': component.get('v.hostingService'),
                    'isUser': component.get('v.isUser'),
                    'domain': userName
                };
                this.fetchData(component, 'c.getRepositoriesInDomain', params, 'repos');
            }
        });
        $A.enqueueAction(action);
    }
})