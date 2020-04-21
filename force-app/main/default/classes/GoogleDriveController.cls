public class GoogleDriveController {
    private static String key = '692844272223-idlgddsk0bf826rq6en5660si0mlv0eb.apps.googleusercontent.com';
    private static String secret = 'QMM4x4wbc-tMQZU4ZHZliUsl';
	private static String redirect_uri = 'https://tfg-jordifelipzayas-dev-ed.my.salesforce.com/services/authcallback/Google_Drive'; //<Your Visual force Page URL>; // Should be //the same URL in authorized URL in your Google Developers Console //Project.
    private static String accesstoken;
    
    @AuraEnabled
    public static String uploadFile(String attachmentId) {
        
        Google_Drive_Token__mdt gd = [SELECT Refresh_Token__c FROM Google_Drive_Token__mdt WHERE DeveloperName =: 'GD_Token']; 
        String refreshtoken = gd.Refresh_Token__c;

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = 'client_id=' + key + '&client_secret=' + secret + '&refresh_token='+refreshtoken+'&redirect_uri=' + redirect_uri + '&grant_type=refresh_token';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);

        Http http = new Http();
        HttpResponse res = http.send(req);

		Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(res.getBody()) ;  
        String accesstoken =  String.valueOf(responseMap.get('access_token'));
        
        List<ContentVersion> cvFile = [SELECT VersionData, Title, FileType,FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: attachmentId];
       	
        Blob myBlob = cvFile[0].VersionData;
        String bodyEncoded = EncodingUtil.base64Encode(myBlob);
        
        if(myBlob.size() < 12000000){
            // google drive folder
            String FolderId= System.Label.GOOGLE_DRIVE_FOLDER_ID;
            String boundary = '----------9889464542212';
            String delimiter = '\r\n--' + boundary + '\r\n';
            String close_delim = '\r\n--' + boundary + '--';
            
            
            try {
                // building body
                String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title" : "' + cvFile[0].Title + '",' + '"parents":[{"id":"'+ FolderId +'"}]}' + delimiter + 'Content-Type: ' + Util.CONTENT_TYPE_BY_EXTENSION.get(cvFile[0].FileExtension.toLowerCase()) + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + close_delim;
                    
                req = new HttpRequest();
                req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart&withLink=true');
                req.setHeader('Authorization', 'Bearer ' + accesstoken);
                req.setHeader('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');
                req.setHeader('Content-length', String.valueOf(body.length()));
                req.setBody(body);
                req.setMethod('POST');
                req.setTimeout(60 * 1000);
                res = http.send(req);
            }catch(Exception e) {
                System.debug('*********EXCEPTION!!!!');
                System.debug(LoggingLevel.ERROR, 'Call exception ' + e.getMessage());
                res.setStatusCode(400);
            }
            System.debug('************* DELETING FILE: ' + attachmentId);
            System.debug('************* CONTENTDOCUMENTID: ' + cvFile[0].ContentDocumentId);    
            //After file was successfully upload we delete the file
            delete new ContentDocument(Id = cvFile[0].ContentDocumentId);
            return String.valueOf(res.getStatuscode());
        }else{
            return '400';
        }
        
    }
	
}