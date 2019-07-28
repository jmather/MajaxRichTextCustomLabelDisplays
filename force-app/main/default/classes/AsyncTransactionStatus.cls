public without sharing class AsyncTransactionStatus {
    public String txnId;
    public Integer count;
    public Boolean isComplete;
    public Boolean isSuccessful;

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

    public override String toString() {
        return JSON.serialize(this);
    }
}
