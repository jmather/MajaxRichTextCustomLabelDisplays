public without sharing class RTLD_TransactionDAO {
    public static RTLD_TransactionStatus getStatus(String txnId) {
        return getStatus(txnId, 0);
    }

    public static RTLD_TransactionStatus getStatus(String txnId, Integer count) {
        RTLD_AsyncRequest__c cacheEntry = RTLD_AsyncRequest__c.getInstance(txnId);
        
        RTLD_Debug.log('[AsyncTransactionAPI.getStatus] cacheEntry: ' + cacheEntry);

        RTLD_TransactionStatus response;

        if (cacheEntry != null) {
            response = new RTLD_TransactionStatus(txnId, count, true, cacheEntry.WasSuccessful__c);
            RTLD_Debug.log('[AsyncTransactionAPI.getStatus] response: ' + response);

            delete cacheEntry;

            return response;
        }

        response = new RTLD_TransactionStatus(txnId, count + 1);
        RTLD_Debug.log('[AsyncTransactionAPI.getStatus] response: ' + response);
        return response;
    }

    public static void recordResult(String txnId, Boolean wasSuccessful) {
        RTLD_AsyncRequest__c cacheEntry = new RTLD_AsyncRequest__c(Name = txnId);
        cacheEntry.WasSuccessful__c = wasSuccessful;
        insert cacheEntry;
    }
}
