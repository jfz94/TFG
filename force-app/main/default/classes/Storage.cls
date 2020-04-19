public with sharing class Storage {
    @AuraEnabled
    public static StorageInformation__c getStorage() {
        HttpRequest req = new HttpRequest();

        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('callout:REST_API/services/data/v48.0/limits/');
        req.setMethod('GET');
        
        // end of each request
        Http h = new Http();
        HttpResponse res = h.send(req);

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        Map<String, Object> dataStorage = (Map<String, Object>)m.get('DataStorageMB');
        Map<String, Object> fileStorage = (Map<String, Object>)m.get('FileStorageMB');

        StorageInformation__c storage = StorageInformation__c.getOrgDefaults();
        
        storage.Data_Storage_Max__c = Integer.valueOf(dataStorage.get('Max'));
        storage.Data_Storage_Remaining__c = Integer.valueOf(dataStorage.get('Remaining'));
        storage.File_Storage_Max__c = Integer.valueOf(fileStorage.get('Max'));
        storage.File_Storage_Remaining__c = Integer.valueOf(fileStorage.get('Remaining'));
        
        update storage;
        
        return storage;
    }
    
    @AuraEnabled
    public static StorageInformation__c getStorageInformation() {
        return StorageInformation__c.getOrgDefaults(); 
    }
}