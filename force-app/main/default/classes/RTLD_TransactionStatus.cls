public without sharing class RTLD_TransactionStatus {
    public String txnId;
    public Integer count;
    public Boolean isComplete;
    public Boolean isSuccessful;
    public Boolean isDebugging = RTLD_Debug.enabled;

    public RTLD_TransactionStatus() {
        this(RTLD_Guid.generate(), 0);
    }

    public RTLD_TransactionStatus(String txnId, Integer count) {
        this(txnId, count, false, null);
    }

    public RTLD_TransactionStatus(String txnId, Integer count, Boolean isComplete, Boolean isSuccessful) {
        this.txnId = txnId;
        this.count = count;
        this.isComplete = isComplete;
        this.isSuccessful = isSuccessful;
    }

    public override String toString() {
        return JSON.serialize(this);
    }
}
