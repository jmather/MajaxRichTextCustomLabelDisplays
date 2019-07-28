public without sharing class AdminAPI {
    @AuraEnabled(Cacheable=true)
    public static List<MAJAX__Display_Text_Entry__mdt> getEntries() {
        return DAO.getEntries();
    }

    @AuraEnabled
    public static AsyncTransactionStatus createEntry(String label, String title, String content) {
        String developerName = Guid.generate();
        MAJAX__Display_Text_Entry__mdt entry = new MAJAX__Display_Text_Entry__mdt(
            MasterLabel = label,
            DeveloperName = developerName,
            MAJAX__Title__c = title,
            MAJAX__Content__c = content
        );

        AsyncTransactionStatus status = DAO.upsertEntry(entry);

        System.debug('[AdminAPI.createEntry] status: ' + status);

        return status;
    }

    @AuraEnabled
    public static AsyncTransactionStatus updateEntry(String developerName, String label, String title, String content) {
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

        return status;
    }

    @AuraEnabled
    public static AsyncTransactionStatus hideEntry(String developerName) {
        MAJAX__Display_Text_Entry__mdt entry = DAO.getEntry(developerName);

        AsyncTransactionStatus status = DAO.hideEntry(entry);

        System.debug('[AdminAPI.hideEntry] status: ' + status);

        return status;
    }

    @AuraEnabled
    public static AsyncTransactionStatus getTransactionStatus(String txnId, Integer count) {
        return AsyncTransactionAPI.getStatus(txnId, count);
    }
}
