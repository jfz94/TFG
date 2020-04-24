@isTest
public class GoogleDriveControllerTest {
    public static testMethod void uploadFileTest() {

        ContentVersion cv=new Contentversion();
        cv.Title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.VersionData=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.PathOnClient = cv.Title + '.pdf';
        insert cv;

        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('GDTokenMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 

            ContentDocument doc = [SELECT ID FROM ContentDocument LIMIT 1];
            GoogleDriveController.uploadFile(doc.Id);
        Test.stopTest();
    }
}