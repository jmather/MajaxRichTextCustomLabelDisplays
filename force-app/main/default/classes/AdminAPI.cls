public without sharing class AdminAPI {
    @AuraEnabled(Cacheable=true)
    public static List<MAJAX__Display_Entry__mdt> getEntries() {
        return EntryDAO.getEntries();
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean isDebugging() {
        return Debug.enabled;
    }

    @AuraEnabled
    public static String createEntry(String label, String title, String content) {
        String developerName = Guid.generateId();
        MAJAX__Display_Entry__mdt entry = new MAJAX__Display_Entry__mdt(
            MasterLabel = label,
            DeveloperName = developerName,
            MAJAX__Title__c = title,
            MAJAX__Content__c = content
        );

        AsyncTransactionStatus status = EntryDAO.upsertEntry(entry);

        Debug.log('[AdminAPI.createEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String updateEntry(String developerName, String label, String title, String content) {
        MAJAX__Display_Entry__mdt entry = EntryDAO.getEntry(developerName);

        if (label != null) {
            entry.MasterLabel = label;
        }

        if (title != null) {
            entry.MAJAX__Title__c = title;
        }

        if (content != null) {
            entry.MAJAX__Content__c = content;
        }

        AsyncTransactionStatus status = EntryDAO.upsertEntry(entry);

        Debug.log('[AdminAPI.updateEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String hideEntry(String developerName) {
        MAJAX__Display_Entry__mdt entry = EntryDAO.getEntry(developerName);

        AsyncTransactionStatus status = EntryDAO.hideEntry(entry);

        Debug.log('[AdminAPI.hideEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String getTransactionStatus(String txnId, Integer count) {
        Debug.log('[AdminAPI.getTransactionStatus] txnId: ' + txnId);
        AsyncTransactionStatus status = TransactionDAO.getStatus(txnId, count);
        Debug.log('[AdminAPI.getTransactionStatus] status: ' + status);
        return status.toString();
    }
}
