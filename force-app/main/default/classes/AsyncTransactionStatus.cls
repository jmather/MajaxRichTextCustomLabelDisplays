global without sharing class AsyncTransactionStatus {
    global String txnId;
    global Integer count;
    global Boolean isComplete;
    global Boolean isSuccessful;

    public AsyncTransactionStatus() {
        this(Guid.generate(), 0);
    }

    public AsyncTransactionStatus(String txnId, Integer count) {
        this(txnId, count, false, null);
    }

    public AsyncTransactionStatus(String txnId, Integer count, Boolean isComplete, Boolean isSuccessful) {
        this.txnId = txnId;
        this.count = count;
        this.isComplete = isComplete;
        this.isSuccessful = isSuccessful;
    }
}
