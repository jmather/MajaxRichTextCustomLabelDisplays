public without sharing class AdminAPI {
    @AuraEnabled(Cacheable=true)
    public static List<MAJAX__Display_Text_Entry__mdt> getEntries() {
        return DAO.getEntries();
    }

    @AuraEnabled
    public static String createEntry(String label, String title, String content) {
        String developerName = Guid.generateId();
        MAJAX__Display_Text_Entry__mdt entry = new MAJAX__Display_Text_Entry__mdt(
            MasterLabel = label,
            DeveloperName = developerName,
            MAJAX__Title__c = title,
            MAJAX__Content__c = content
        );

        AsyncTransactionStatus status = DAO.upsertEntry(entry);

        System.debug('[AdminAPI.createEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String updateEntry(String developerName, String label, String title, String content) {
        MAJAX__Display_Text_Entry__mdt entry = DAO.getEntry(developerName);

        if (label != null) {
            entry.MasterLabel = label;
        }

        if (title != null) {
            entry.MAJAX__Title__c = title;
        }

        if (content != null) {
            entry.MAJAX__Content__c = content;
        }

        AsyncTransactionStatus status = DAO.upsertEntry(entry);

        System.debug('[AdminAPI.updateEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String hideEntry(String developerName) {
        MAJAX__Display_Text_Entry__mdt entry = DAO.getEntry(developerName);

        AsyncTransactionStatus status = DAO.hideEntry(entry);

        System.debug('[AdminAPI.hideEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String getTransactionStatus(String txnId, Integer count) {
        System.debug('[AdminAPI.getTransactionStatus] txnId: ' + txnId);
        AsyncTransactionStatus status = AsyncTransactionAPI.getStatus(txnId, count);
        System.debug('[AdminAPI.getTransactionStatus] status: ' + status);
        return status.toString();
    }
}
