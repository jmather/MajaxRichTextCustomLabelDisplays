global without sharing class AsyncTransactionAPI {
    global static AsyncTransactionStatus getStatus(String txnId) {
        return getStatus(txnId, 0);
    }

    global static AsyncTransactionStatus getStatus(String txnId, Integer count) {
        MAJAX__MetadataRequestCache__c cacheEntry = MAJAX__MetadataRequestCache__c.getInstance(txnId);
        
        System.debug('[AsyncTransactionAPI.getStatus] cacheEntry: ' + cacheEntry);

        AsyncTransactionStatus response;

        if (cacheEntry != null) {
            response = new AsyncTransactionStatus(txnId, count, true, cacheEntry.MAJAX__WasSuccessful__c);
            System.debug('[AsyncTransactionAPI.getStatus] response: ' + response);

            delete cacheEntry;

            return response;
        }

        response = new AsyncTransactionStatus(txnId, count + 1);
        System.debug('[AsyncTransactionAPI.getStatus] response: ' + response);
        return response;
    }

    global static void recordResult(String txnId, Boolean wasSuccessful) {
        MAJAX__MetadataRequestCache__c cacheEntry = new MAJAX__MetadataRequestCache__c(Name = txnId);
        cacheEntry.MAJAX__WasSuccessful__c = wasSuccessful;
        insert cacheEntry;
    }
}
