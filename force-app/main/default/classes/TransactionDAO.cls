public without sharing class TransactionDAO {
    public static AsyncTransactionStatus getStatus(String txnId) {
        return getStatus(txnId, 0);
    }

    public static AsyncTransactionStatus getStatus(String txnId, Integer count) {
        MAJAX__AsyncRequest__c cacheEntry = MAJAX__AsyncRequest__c.getInstance(txnId);
        
        Debug.log('[AsyncTransactionAPI.getStatus] cacheEntry: ' + cacheEntry);

        AsyncTransactionStatus response;

        if (cacheEntry != null) {
            response = new AsyncTransactionStatus(txnId, count, true, cacheEntry.MAJAX__WasSuccessful__c);
            Debug.log('[AsyncTransactionAPI.getStatus] response: ' + response);

            delete cacheEntry;

            return response;
        }

        response = new AsyncTransactionStatus(txnId, count + 1);
        Debug.log('[AsyncTransactionAPI.getStatus] response: ' + response);
        return response;
    }

    public static void recordResult(String txnId, Boolean wasSuccessful) {
        MAJAX__AsyncRequest__c cacheEntry = new MAJAX__AsyncRequest__c(Name = txnId);
        cacheEntry.MAJAX__WasSuccessful__c = wasSuccessful;
        insert cacheEntry;
    }
}
