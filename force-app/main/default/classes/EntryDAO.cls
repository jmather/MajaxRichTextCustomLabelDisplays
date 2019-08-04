public without sharing class EntryDAO {
    public static List<Display_Entry__mdt> getEntries() {
        return getEntries(false);
    }

    public static List<Display_Entry__mdt> getEntries(Boolean hiddenEntries) {
        List<Display_Entry__mdt> entries = [
            SELECT
                Id,
                MasterLabel,
                DeveloperName,
                Title__c,
                Content__c,
                DisplayTitle__c,
                DisplayStyle__c,
                URL__c,
                Icon__c,
                IsHidden__c
            FROM Display_Entry__mdt
            WHERE IsHidden__c = :hiddenEntries
            ORDER BY MasterLabel
        ];

        for (Display_Entry__mdt entry : entries) {
            Debug.log('[DAO.getEntries] entry: ' + entry);
        }

        return entries;
    }

    public static Display_Entry__mdt getEntry(String developerName) {
        List<Display_Entry__mdt> entries = [
                SELECT
                        Id,
                        MasterLabel,
                        DeveloperName,
                        Title__c,
                        Content__c,
                        DisplayTitle__c,
                        DisplayStyle__c,
                        URL__c,
                        Icon__c,
                        IsHidden__c
                FROM Display_Entry__mdt
                WHERE DeveloperName = :developerName AND IsHidden__c = FALSE
        ];
        
        if (entries.isEmpty()) {
            return null;
        }

        return entries[0];
    }

    public static AsyncTransactionStatus upsertEntry(Display_Entry__mdt entry) {
        Callback cb = new Callback(entry.DeveloperName);

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'Display_Entry__mdt.' + entry.DeveloperName;
        customMetadata.label = entry.MasterLabel;

        List<String> fields = new List<String> {
                'Title__c',
                'Content__c',
                'DisplayTitle__c',
                'DisplayStyle__c',
                'URL__c',
                'Icon__c'
        };

        for (String field : fields) {
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = field;
            customField.value = entry.get(field);

            customMetadata.values.add(customField);
        }

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata((Metadata.Metadata) customMetadata);

        Metadata.Operations.enqueueDeployment(mdContainer, cb);

        return TransactionDAO.getStatus(cb.txnId);
    }

    public static AsyncTransactionStatus hideEntry(Display_Entry__mdt entry) {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'Display_Entry__mdt.' + entry.DeveloperName;
        customMetadata.label = entry.MasterLabel;

        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'IsHidden__c';
        customField.value = true;

        customMetadata.values.add(customField);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata((Metadata.Metadata) customMetadata);

        Callback cb = new Callback(entry.DeveloperName);

        Metadata.Operations.enqueueDeployment(mdContainer, cb);

        return TransactionDAO.getStatus(cb.txnId);
    }

    public static String generateId() {
        return 'I' + Guid.generateId().replace('-', '_');
    }

    class Callback implements Metadata.DeployCallback {
        public String txnId;

        public Callback(String txnId) {
            this.txnId = txnId;
        }

        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            Debug.log('[DAO.Callback.handleResult] done: ' + result.done);
            Debug.log('[DAO.Callback.handleResult] status: ' + result.status);
            Debug.log('[DAO.Callback.handleResult] result: ' + JSON.serializePretty(result));

            if (result.done) {
                TransactionDAO.recordResult(txnId, result.status == Metadata.DeployStatus.Succeeded);
            }
        }
    }
}
