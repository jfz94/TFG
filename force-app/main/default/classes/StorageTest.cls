@isTest
private class StorageTest {
    public static testMethod void getStorage() {
        StorageInformation__c cs = new StorageInformation__c(
            Data_Storage_Max__c = 0,
            Data_Storage_Remaining__c = 0,
            File_Storage_Max__c = 0,
            File_Storage_Remaining__c = 0
        );
        insert cs;
        
        Test.startTest();
            SingleRequestMock StorageMock = new SingleRequestMock(200,'Complete','{"DataStorageMB":{"Max":5,"Remaining":2},"FileStorageMB":{"Max":20,"Remaining":2}}', null);
            Test.setMock(HttpCalloutMock.class, StorageMock); 
            cs = Storage.getStorage();
        Test.stopTest();

        cs = [SELECT Data_Storage_Max__c, Data_Storage_Remaining__c, File_Storage_Max__c, File_Storage_Remaining__c FROM StorageInformation__c LIMIT 1];
        System.assertEquals(5, cs.Data_Storage_Max__c);
        System.assertEquals(2, cs.Data_Storage_Remaining__c);
        System.assertEquals(20, cs.File_Storage_Max__c);
        System.assertEquals(2, cs.File_Storage_Remaining__c);
    }
}