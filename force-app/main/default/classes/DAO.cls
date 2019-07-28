public without sharing class DAO {
    public static List<MAJAX__Display_Text_Entry__mdt> getEntries() {
        List<MAJAX__Display_Text_Entry__mdt> entries = [
            SELECT
                Id,
                MasterLabel,
                DeveloperName,
                MAJAX__Title__c,
                MAJAX__Content__c,
                MAJAX__IsHidden__c
            FROM MAJAX__Display_Text_Entry__mdt
            WHERE MAJAX__IsHidden__c = FALSE
            ORDER BY MasterLabel
        ];

        for (MAJAX__Display_Text_Entry__mdt entry : entries) {
            System.debug('[DAO.getEntries] entry: ' + entry);
        }

        return entries;
    }

    public static MAJAX__Display_Text_Entry__mdt getEntry(String developerName) {
        List<MAJAX__Display_Text_Entry__mdt> entries = [SELECT Id, MasterLabel, DeveloperName, MAJAX__Title__c, MAJAX__Content__c, MAJAX__IsHidden__c FROM MAJAX__Display_Text_Entry__mdt WHERE DeveloperName = :developerName AND MAJAX__IsHidden__c = FALSE];
        
        if (entries.isEmpty()) {
            return null;
        }

        return entries[0];
    }

    public static AsyncTransactionStatus upsertEntry(MAJAX__Display_Text_Entry__mdt entry) {
        Callback cb = new Callback(entry.DeveloperName);

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'MAJAX__Display_Text_Entry__mdt.' + entry.DeveloperName;
        customMetadata.label = entry.MasterLabel;

        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'MAJAX__Content__c';
        customField.value = entry.MAJAX__Content__c;

        customMetadata.values.add(customField);

        customField = new Metadata.CustomMetadataValue();
        customField.field = 'MAJAX__Title__c';
        customField.value = entry.MAJAX__Title__c;

        customMetadata.values.add(customField);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata((Metadata.Metadata) customMetadata);

        Metadata.Operations.enqueueDeployment(mdContainer, cb);

        return AsyncTransactionAPI.getStatus(cb.txnId);
    }

    public static AsyncTransactionStatus hideEntry(MAJAX__Display_Text_Entry__mdt entry) {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'MAJAX__Display_Text_Entry__mdt.' + entry.DeveloperName;
        customMetadata.label = entry.MasterLabel;

        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'MAJAX__IsHidden__c';
        customField.value = true;

        customMetadata.values.add(customField);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata((Metadata.Metadata) customMetadata);

        Callback cb = new Callback(entry.DeveloperName);

        Metadata.Operations.enqueueDeployment(mdContainer, cb);

        return AsyncTransactionAPI.getStatus(cb.txnId);
    }

    class Callback implements Metadata.DeployCallback {
        public String txnId;

        public Callback(String txnId) {
            this.txnId = txnId;
        }

        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            System.debug('[DAO.Callback.handleResult] done: ' + result.done);
            System.debug('[DAO.Callback.handleResult] status: ' + result.status);
            System.debug('[DAO.Callback.handleResult] result: ' + JSON.serializePretty(result));

            if (result.done) {
                AsyncTransactionAPI.recordResult(txnId, result.status == Metadata.DeployStatus.Succeeded);
            }
        }
    }
}
