public without sharing class RTLD_EntryDAO {
    @TestVisible
    static IDeploymentHandler deploymentHandler = new DeploymentHandler();

    @TestVisible
    interface IDeploymentHandler {
        void deploy(Metadata.DeployContainer container, Metadata.DeployCallback callback);
    }

    public static List<RTLD_Entry__mdt> getEntries() {
        return getEntries(false);
    }

    public static List<RTLD_Entry__mdt> getEntries(Boolean hiddenEntries) {
        List<RTLD_Entry__mdt> entries = [
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
            FROM RTLD_Entry__mdt
            WHERE IsHidden__c = :hiddenEntries
            ORDER BY MasterLabel
        ];

        for (RTLD_Entry__mdt entry : entries) {
            RTLD_Debug.log('[DAO.getEntries] entry: ' + entry);
        }

        return entries;
    }

    public static RTLD_Entry__mdt getEntry(String developerName) {
        List<RTLD_Entry__mdt> entries = [
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
                FROM RTLD_Entry__mdt
                WHERE DeveloperName = :developerName AND IsHidden__c = FALSE
        ];
        
        if (entries.isEmpty()) {
            return null;
        }

        return entries[0];
    }

    public static RTLD_TransactionStatus upsertEntry(RTLD_Entry__mdt entry) {
        Callback cb = new Callback(entry.DeveloperName);

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'RTLD_Entry__mdt.' + entry.DeveloperName;
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

        deploymentHandler.deploy(mdContainer, cb);

        return RTLD_TransactionDAO.getStatus(cb.txnId);
    }

    public static RTLD_TransactionStatus hideEntry(RTLD_Entry__mdt entry) {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'RTLD_Entry__mdt.' + entry.DeveloperName;
        customMetadata.label = entry.MasterLabel;

        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'IsHidden__c';
        customField.value = true;

        customMetadata.values.add(customField);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata((Metadata.Metadata) customMetadata);

        Callback cb = new Callback(entry.DeveloperName);

        deploymentHandler.deploy(mdContainer, cb);

        return RTLD_TransactionDAO.getStatus(cb.txnId);
    }

    public static String generateId() {
        return 'I' + RTLD_Guid.generateId().replace('-', '_');
    }

    class DeploymentHandler implements IDeploymentHandler {
        public void deploy(Metadata.DeployContainer container, Metadata.DeployCallback callback) {
            Metadata.Operations.enqueueDeployment(container, callback);
        }
    }

    @TestVisible
    class Callback implements Metadata.DeployCallback {
        public String txnId;

        public Callback(String txnId) {
            this.txnId = txnId;
        }

        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            RTLD_Debug.log('[DAO.Callback.handleResult] done: ' + result.done);
            RTLD_Debug.log('[DAO.Callback.handleResult] status: ' + result.status);
            RTLD_Debug.log('[DAO.Callback.handleResult] result: ' + JSON.serializePretty(result));

            if (result.done) {
                RTLD_TransactionDAO.recordResult(txnId, result.status == Metadata.DeployStatus.Succeeded);
            }
        }
    }
}
