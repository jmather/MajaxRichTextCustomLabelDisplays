/**
 * Created by jmather on 2019-08-03.
 */

public with sharing class RTLD_AdminAPI {
    @AuraEnabled
    public static String getEntries(Boolean enableDebugging) {
        RTLD_Debug.enabled = enableDebugging;
        return JSON.serialize(RTLD_EntryDAO.getEntries());
    }

    @AuraEnabled
    public static String getEntry(String developerName, Boolean enableDebugging) {
        RTLD_Debug.enabled = enableDebugging;
        return JSON.serialize(RTLD_EntryDAO.getEntry(developerName));
    }

    @AuraEnabled
    public static String createEntry(String entryJson, Boolean enableDebugging) {
        RTLD_Debug.enabled = enableDebugging;
        String developerName = RTLD_EntryDAO.generateId();
        RTLD_Entry__mdt entry = (RTLD_Entry__mdt) JSON.deserialize(entryJson, RTLD_Entry__mdt.class);
        entry.DeveloperName = developerName;

        RTLD_TransactionStatus status = RTLD_EntryDAO.upsertEntry(entry);

        RTLD_Debug.log('[AdminAPI.createEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String updateEntry(String entryJson, Boolean enableDebugging) {
        RTLD_Debug.enabled = enableDebugging;

        RTLD_Entry__mdt entry = (RTLD_Entry__mdt) JSON.deserialize(entryJson, RTLD_Entry__mdt.class);

        RTLD_TransactionStatus status = RTLD_EntryDAO.upsertEntry(entry);

        RTLD_Debug.log('[AdminAPI.updateEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String hideEntry(String developerName, Boolean enableDebugging) {
        RTLD_Debug.enabled = enableDebugging;
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry(developerName);

        RTLD_TransactionStatus status = RTLD_EntryDAO.hideEntry(entry);

        RTLD_Debug.log('[AdminAPI.hideEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String getTransactionStatus(String txnId, Integer count, Boolean enableDebugging) {
        RTLD_Debug.enabled = enableDebugging;
        RTLD_Debug.log('[AdminAPI.getTransactionStatus] txnId: ' + txnId);
        RTLD_TransactionStatus status = RTLD_TransactionDAO.getStatus(txnId, count);
        RTLD_Debug.log('[AdminAPI.getTransactionStatus] status: ' + status);
        return status.toString();
    }
}