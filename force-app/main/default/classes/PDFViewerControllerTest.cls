@isTest
private class PDFViewerControllerTest {

    public static testMethod void getRelatedRecordsById_Test() {
        Repository__c rep = new Repository__c();
        insert rep;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = rep.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.startTest();
            Map<ID, String> relatedDocs = PDFViewerController.getRelatedFilesByRecordId(String.valueOf(rep.Id));
            System.assertNotEquals(0, relatedDocs.size());
            System.assertEquals(true, relatedDocs.containsKey(documents[0].Id));
        Test.stopTest();
    }
}