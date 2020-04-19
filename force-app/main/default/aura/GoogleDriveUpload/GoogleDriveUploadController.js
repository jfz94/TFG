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
                if(responseCode == '200'){
                    alert('File Uploaded successfully');
                }else{
                    alert('There was some error');
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})