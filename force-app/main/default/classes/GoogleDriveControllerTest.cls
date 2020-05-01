@isTest
public class GoogleDriveControllerTest {
    public static testMethod void uploadFileTest() {
        insert TestDataFactory.createContentVersion('ABC','test','Unit Test Attachment Body');

        Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('GDTokenMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 

            ContentDocument doc = [SELECT ID FROM ContentDocument LIMIT 1];
            String result = GoogleDriveController.uploadFile(doc.Id);
            System.assertEquals('200', result);
        Test.stopTest();
    }
}