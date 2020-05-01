({
    handleFilesChange : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var attachmentId = uploadedFiles[0].documentId;
        var action  = component.get("c.uploadFile");
        
        action.setParams({
            "attachmentId": attachmentId,
        });

        action.setCallback(this, function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var responseCode = response.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");

                if(responseCode == '200'){
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.Google_Drive_success_title"),
                        "message": $A.get("$Label.c.Google_Drive_success_message"),
                        type: 'Success'
                    });
                }else{
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.Google_Drive_error_title"),
                        "message": $A.get("$Label.c.Google_Drive_error_message"),
                        type: 'Error'
                    });
                }
                resultsToast.fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})