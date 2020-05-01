public class GoogleDriveController {
    private static String accesstoken;
    
    @AuraEnabled
    public static String uploadFile(String attachmentId) {
        
        Google_Drive__mdt gd = [SELECT Refresh_Token__c, Folder_Id__c, Key__c, Secret__c, Redirect_URI__c FROM Google_Drive__mdt WHERE DeveloperName =: 'GD_Token']; 
        String refreshtoken = gd.Refresh_Token__c;

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(System.Label.GoogleDrive_URL_Token);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = 'client_id=' + gd.Key__c + '&client_secret=' + gd.Secret__c + '&refresh_token='+refreshtoken+'&redirect_uri=' + gd.Redirect_URI__c + '&grant_type=refresh_token';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);

        Http http = new Http();
        HttpResponse res = http.send(req);

		Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(res.getBody()) ;  
        String accesstoken =  String.valueOf(responseMap.get('access_token'));

        // Represents a specific version of a document in Salesforce CRM Content or Salesforce Files
        List<ContentVersion> cvFile = [SELECT VersionData, Title, FileType,FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: attachmentId];
       	
        Blob myBlob = cvFile[0].VersionData;
        String bodyEncoded = EncodingUtil.base64Encode(myBlob);
        
        if(myBlob.size() < 12000000){
            String FolderId= gd.Folder_Id__c;
            String boundary = '----------9889464542212';
            String delimiter = '\r\n--' + boundary + '\r\n';
            String close_delim = '\r\n--' + boundary + '--';

            try {
                // building body
                String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title" : "' + cvFile[0].Title + '",' + '"parents":[{"id":"'+ FolderId +'"}]}' + delimiter + 'Content-Type: ' + Util.CONTENT_TYPE_BY_EXTENSION.get(cvFile[0].FileExtension.toLowerCase()) + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + close_delim;
                    
                req = new HttpRequest();
                req.setEndpoint(System.Label.GoogleDrive_URL_Upload);
                req.setHeader('Authorization', 'Bearer ' + accesstoken);
                req.setHeader('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');
                req.setHeader('Content-length', String.valueOf(body.length()));
                req.setBody(body);
                req.setMethod('POST');
                req.setTimeout(60 * 1000);
                res = http.send(req);
            }catch(Exception e) {
                System.debug(LoggingLevel.ERROR, 'Call exception ' + e.getMessage());
                res.setStatusCode(400);
            }  
            //After file was successfully upload we delete the file
            delete new ContentDocument(Id = cvFile[0].ContentDocumentId);
            return String.valueOf(res.getStatuscode());
        }else{
            return '400';
        }        
    }
	
}