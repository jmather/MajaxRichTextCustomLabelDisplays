public without sharing class TransactionDAO {
    public static AsyncTransactionStatus getStatus(String txnId) {
        return getStatus(txnId, 0);
    }

    public static AsyncTransactionStatus getStatus(String txnId, Integer count) {
        AsyncRequest__c cacheEntry = AsyncRequest__c.getInstance(txnId);
        
        Debug.log('[AsyncTransactionAPI.getStatus] cacheEntry: ' + cacheEntry);

        AsyncTransactionStatus response;

        if (cacheEntry != null) {
            response = new AsyncTransactionStatus(txnId, count, true, cacheEntry.WasSuccessful__c);
            Debug.log('[AsyncTransactionAPI.getStatus] response: ' + response);

            delete cacheEntry;

            return response;
        }

        response = new AsyncTransactionStatus(txnId, count + 1);
        Debug.log('[AsyncTransactionAPI.getStatus] response: ' + response);
        return response;
    }

    public static void recordResult(String txnId, Boolean wasSuccessful) {
        AsyncRequest__c cacheEntry = new AsyncRequest__c(Name = txnId);
        cacheEntry.WasSuccessful__c = wasSuccessful;
        insert cacheEntry;
    }
}
