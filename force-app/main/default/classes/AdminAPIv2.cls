/**
 * Created by jmather on 2019-08-03.
 */

public with sharing class AdminAPIv2 {
    @AuraEnabled
    public static String getEntries(Boolean enableDebugging) {
        Debug.enabled = enableDebugging;
        return JSON.serialize(EntryDAO.getEntries());
    }

    @AuraEnabled
    public static String getEntry(String developerName, Boolean enableDebugging) {
        Debug.enabled = enableDebugging;
        return JSON.serialize(EntryDAO.getEntry(developerName));
    }

    @AuraEnabled
    public static String createEntry(String entryJson, Boolean enableDebugging) {
        Debug.enabled = enableDebugging;
        String developerName = EntryDAO.generateId();
        Display_Entry__mdt entry = (Display_Entry__mdt) JSON.deserialize(entryJson, Display_Entry__mdt.class);
        entry.DeveloperName = developerName;

        AsyncTransactionStatus status = EntryDAO.upsertEntry(entry);

        Debug.log('[AdminAPI.createEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String updateEntry(String entryJson, Boolean enableDebugging) {
        Debug.enabled = enableDebugging;

        Display_Entry__mdt entry = (Display_Entry__mdt) JSON.deserialize(entryJson, Display_Entry__mdt.class);

        AsyncTransactionStatus status = EntryDAO.upsertEntry(entry);

        Debug.log('[AdminAPI.updateEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String hideEntry(String developerName, Boolean enableDebugging) {
        Debug.enabled = enableDebugging;
        Display_Entry__mdt entry = EntryDAO.getEntry(developerName);

        AsyncTransactionStatus status = EntryDAO.hideEntry(entry);

        Debug.log('[AdminAPI.hideEntry] status: ' + status);

        return status.toString();
    }

    @AuraEnabled
    public static String getTransactionStatus(String txnId, Integer count, Boolean enableDebugging) {
        Debug.enabled = enableDebugging;
        Debug.log('[AdminAPI.getTransactionStatus] txnId: ' + txnId);
        AsyncTransactionStatus status = TransactionDAO.getStatus(txnId, count);
        Debug.log('[AdminAPI.getTransactionStatus] status: ' + status);
        return status.toString();
    }
}