public without sharing class RichTextDisplays {
    @AuraEnabled(Cacheable=true)
    public static List<MAJAX__Display_Text_Entry__mdt> getEntries() {
        List<MAJAX__Display_Text_Entry__mdt> entries = [
            SELECT
                Id,
                MasterLabel,
                DeveloperName,
                MAJAX__Content__c
            FROM MAJAX__Display_Text_Entry__mdt
            WHERE MAJAX__IsDeleted__c = FALSE
            ORDER BY MasterLabel
        ];

        for (MAJAX__Display_Text_Entry__mdt entry : entries) {
            System.debug('[RichTextDisplays.getEntries] entry: ' + entry);
        }

        return entries;
    }

    @AuraEnabled(Cacheable=true)
    public static String renderContent(String value) {
        System.debug('[RichTextDisplays.render] value: ' + value);
        String safeValue = EncodingUtil.urlEncode(value, 'UTF-8');
        String url = '/apex/RenderRichTextDisplay?content=' + safeValue;

        return getRenderedContent(url);
    }

    @AuraEnabled(Cacheable=true)
    public static String renderDeveloperName(String developerName) {
        System.debug('[RichTextDisplays.render] developerName: ' + developerName);
        String url = '/apex/RenderRichTextDisplay?developerName=' + developerName;

        return getRenderedContent(url);
    }

    @AuraEnabled
    public static String createEntry(String developerName, String label, String content) {
        MAJAX__Display_Text_Entry__mdt entry = new MAJAX__Display_Text_Entry__mdt(
            MasterLabel = label,
            DeveloperName = developerName,
            MAJAX__Content__c = content
        );

        String guid = updateEntryMetaData(entry);

        System.debug('[RichTextDisplays.createEntry] guid: ' + guid);

        String response = JSON.serialize(new JobStatus(guid));

        System.debug('[RichTextDisplays.createEntry] response: ' + response);

        return response;
    }

    @AuraEnabled
    public static String updateEntry(String developerName, String label, String content) {
        List<MAJAX__Display_Text_Entry__mdt> entries = [SELECT Id, MasterLabel, DeveloperName, MAJAX__Content__c FROM MAJAX__Display_Text_Entry__mdt WHERE DeveloperName = :developerName AND MAJAX__IsDeleted__c = FALSE];

        if (entries.isEmpty()) {
            return null;
        }

        MAJAX__Display_Text_Entry__mdt entry = entries[0];

        if (label != null) {
            entry.MasterLabel = label;
        }

        if (content != null) {
            entry.MAJAX__Content__c = content;
        }

        String guid = updateEntryMetaData(entry);

        System.debug('[RichTextDisplays.createEntry] guid: ' + guid);

        String response = JSON.serialize(new JobStatus(guid));

        System.debug('[RichTextDisplays.createEntry] response: ' + response);

        return response;
    }

    @AuraEnabled
    public static String deleteEntry(String developerName) {
        List<MAJAX__Display_Text_Entry__mdt> entries = [SELECT Id, MasterLabel, DeveloperName FROM MAJAX__Display_Text_Entry__mdt WHERE DeveloperName = :developerName];

        if (entries.isEmpty()) {
            return null;
        }

        MAJAX__Display_Text_Entry__mdt entry = entries[0];

        String guid = deleteEntryMetaData(entry);

        System.debug('[RichTextDisplays.createEntry] guid: ' + guid);

        String response = JSON.serialize(new JobStatus(guid));

        System.debug('[RichTextDisplays.createEntry] response: ' + response);

        return response;
    }

    @AuraEnabled
    public static String isJobComplete(String guid, Integer count) {
        MAJAX__MetadataRequestCache__c cacheEntry = MAJAX__MetadataRequestCache__c.getInstance(guid);
        
        System.debug('[RichTextDisplays.isJobComplete] cacheEntry: ' + cacheEntry);

        String response;

        if (cacheEntry != null) {
            response = JSON.serialize(new JobStatus(guid, count, cacheEntry.MAJAX__IsComplete__c, cacheEntry.MAJAX__IsSuccessful__c));
            System.debug('[RichTextDisplays.isJobComplete] response: ' + response);

            if (cacheEntry.MAJAX__IsComplete__c) {
                delete cacheEntry;
            }

            return response;
        }

        response = JSON.serialize(new JobStatus(guid, count));
        System.debug('[RichTextDisplays.isJobComplete] response: ' + response);
        return response;
    }

    private static String getRenderedContent(String url) {
        PageReference ref = new PageReference(url);
        String content = ref.getContent().toString();

        System.debug('[RichTextDisplays.getRenderedContent] response: ' + content);

        Pattern p = Pattern.compile('\\<\\!--\\*+--\\>(.*)\\<\\!--\\*+--\\>');
        Matcher m = p.matcher(content);

        if (m.find()) {
            String rendered = m.group(1);
            System.debug('[RichTextDisplays.getRenderedContent] rendered: ' + rendered);
            return rendered;
        }
        
        return 'We encountered an error processing the output.';
    }

    private static String updateEntryMetaData(MAJAX__Display_Text_Entry__mdt entry) {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'MAJAX__Display_Text_Entry__mdt.' + entry.DeveloperName;
        customMetadata.label = entry.MasterLabel;
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'MAJAX__Content__c';
        customField.value = entry.MAJAX__Content__c;

        customMetadata.values.add(customField);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        return deployMetadata(mdContainer);
    }

    private static String deleteEntryMetaData(MAJAX__Display_Text_Entry__mdt entry) {
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'MAJAX__Display_Text_Entry__mdt.' + entry.DeveloperName;
        customMetadata.label = entry.MasterLabel;

        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'MAJAX__IsDeleted__c';
        customField.value = true;

        customMetadata.values.add(customField);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        return deployMetadata(mdContainer);
    }

    private static String deployMetadata(Metadata.DeployContainer mdContainer) {
        String guid = generateGuid();

        CustomMetadataCallback callback = new CustomMetadataCallback(guid);

        Metadata.Operations.enqueueDeployment(mdContainer, callback);

        return guid;
    }

    private static String generateGuid() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }

    class CustomMetadataCallback implements Metadata.DeployCallback {
        private String guid;

        public CustomMetadataCallback(String guid) {
            this.guid = guid;
        }

        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            System.debug('[RichTextDiplays.CustomMetadataCallback.handleResult] result: ' + JSON.serializePretty(result));
            
            if (result.done) {
                MAJAX__MetadataRequestCache__c cacheEntry = new MAJAX__MetadataRequestCache__c(Name = guid);
                cacheEntry.MAJAX__IsComplete__c = true;
                cacheEntry.MAJAX__IsSuccessful__c = result.status == Metadata.DeployStatus.Succeeded;
                insert cacheEntry;
                System.debug('[RichTextDiplays.CustomMetadataCallback.handleResult] cacheEntry: ' + cacheEntry);                
            }

            if (result.status == Metadata.DeployStatus.Succeeded) {
                System.debug('[RichTextDiplays.CustomMetadataCallback.handleResult] success');
            } else {
                System.debug('[RichTextDiplays.CustomMetadataCallback.handleResult] failure');
            }
        }
    }

    public class JobStatus {
        String guid;
        Integer count;
        Boolean isComplete;
        Boolean isSuccessful;

        public JobStatus(String guid) {
            this(guid, 0, false, null);
        }

        public JobStatus(String guid, Integer count) {
            this(guid, count, false, null);
        }

        public JobStatus(String guid, Integer count, Boolean isComplete) {
            this(guid, count, isComplete, null);
        }

        public JobStatus(String guid, Integer count, Boolean isComplete, Boolean isSuccessful) {
            this.guid = guid;
            this.count = count;
            this.isComplete = isComplete;
            this.isSuccessful = isSuccessful;
        }
    }
}
