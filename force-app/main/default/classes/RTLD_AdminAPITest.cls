/**
 * Created by jmather on 2019-08-07.
 */

@IsTest
public with sharing class RTLD_AdminAPITest {
    @IsTest
    static void GetEntries() {
        Test.startTest();

        List<RTLD_Entry__mdt> entries = (List<RTLD_Entry__mdt>) JSON.deserialize(RTLD_AdminAPI.getEntries(false), List<RTLD_Entry__mdt>.class);

        Test.stopTest();

        System.assert(entries.size() > 1);
    }

    @IsTest
    static void GetEntry() {
        Test.startTest();

        RTLD_Entry__mdt entry = (RTLD_Entry__mdt) JSON.deserialize(RTLD_AdminAPI.getEntry('Test', false), RTLD_Entry__mdt.class);

        Test.stopTest();

        System.assertNotEquals(null, entry);
    }

    @IsTest
    static void CreateEntry() {
        RTLD_Entry__mdt entry = new RTLD_Entry__mdt();
        entry.Title__c = 'Foo';
        entry.Content__c = 'Test';
        entry.MasterLabel = 'ML';
        entry.DisplayStyle__c = 'Card';
        entry.DisplayTitle__c = true;
        entry.IsHidden__c = false;

        RTLD_IDeploymentHandlerMock handler = new RTLD_IDeploymentHandlerMock();

        String entryJson = JSON.serialize(entry);

        Test.startTest();

        RTLD_EntryDAO.deploymentHandler = handler;

        String statusJson = RTLD_AdminAPI.createEntry(entryJson, false);
        RTLD_TransactionStatus result = (RTLD_TransactionStatus) JSON.deserialize(statusJson, RTLD_TransactionStatus.class);

        Test.stopTest();

        System.assertNotEquals(entry.DeveloperName, result.txnId);
        System.assertEquals(1, result.count);

        System.debug('container: ' + JSON.serializePretty(handler.container));
        System.debug('result: ' + JSON.serializePretty(result));
    }

    @IsTest
    static void UpdateEntry() {
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry('Test');
        entry.Content__c = 'Test';

        RTLD_IDeploymentHandlerMock handler = new RTLD_IDeploymentHandlerMock();

        String entryJson = JSON.serialize(entry);

        Test.startTest();

        RTLD_EntryDAO.deploymentHandler = handler;

        String statusJson = RTLD_AdminAPI.updateEntry(entryJson, false);
        RTLD_TransactionStatus result = (RTLD_TransactionStatus) JSON.deserialize(statusJson, RTLD_TransactionStatus.class);

        Test.stopTest();

        System.assertEquals(1, handler.container.getMetadata().size());
        Metadata.CustomMetadata md = (Metadata.CustomMetadata) handler.container.getMetadata()[0];
        List<Metadata.CustomMetadataValue> values = md.values;
        System.assertEquals(6, values.size());

        for (Metadata.CustomMetadataValue value : values) {
            System.assertEquals(entry.get(value.field), value.value);
        }

        System.assertEquals(entry.DeveloperName, result.txnId);
        System.assertEquals(1, result.count);

        System.debug('container: ' + JSON.serializePretty(handler.container));
        System.debug('result: ' + JSON.serializePretty(result));
    }

    @IsTest
    static void HideEntry() {
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry('Test');

        RTLD_IDeploymentHandlerMock handler = new RTLD_IDeploymentHandlerMock();

        Test.startTest();

        RTLD_EntryDAO.deploymentHandler = handler;

        String statusJson = RTLD_AdminAPI.hideEntry(entry.DeveloperName, false);
        RTLD_TransactionStatus result = (RTLD_TransactionStatus) JSON.deserialize(statusJson, RTLD_TransactionStatus.class);

        Test.stopTest();

        System.assertEquals(1, handler.container.getMetadata().size());
        Metadata.CustomMetadata md = (Metadata.CustomMetadata) handler.container.getMetadata()[0];
        List<Metadata.CustomMetadataValue> values = md.values;
        System.assertEquals(1, values.size());
        System.assertEquals('IsHidden__c', values[0].field);
        System.assertEquals(true, values[0].value);

        System.assertEquals(entry.DeveloperName, result.txnId);
        System.assertEquals(1, result.count);

        System.debug('container: ' + JSON.serializePretty(handler.container));
        System.debug('result: ' + JSON.serializePretty(result));
    }

    @IsTest
    static void GetTransactionStatus() {
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry('Test');
        entry.Content__c = 'Test';

        RTLD_IDeploymentHandlerMock handler = new RTLD_IDeploymentHandlerMock();

        String entryJson = JSON.serialize(entry);

        RTLD_EntryDAO.deploymentHandler = handler;

        String statusJson = RTLD_AdminAPI.updateEntry(entryJson, false);
        RTLD_TransactionStatus result = (RTLD_TransactionStatus) JSON.deserialize(statusJson, RTLD_TransactionStatus.class);

        System.assertEquals(1, result.count);
        System.assertEquals(false, result.isComplete);
        System.assertEquals(null, result.isSuccessful);

        Test.startTest();

        statusJson = RTLD_AdminAPI.getTransactionStatus(result.txnId, result.count, false);
        result = (RTLD_TransactionStatus) JSON.deserialize(statusJson, RTLD_TransactionStatus.class);

        System.assertEquals(2, result.count);
        System.assertEquals(false, result.isComplete);
        System.assertEquals(null, result.isSuccessful);

        RTLD_AsyncRequest__c cacheEntry = new RTLD_AsyncRequest__c();
        cacheEntry.Name = result.txnId;
        cacheEntry.WasSuccessful__c = true;
        insert cacheEntry;

        statusJson = RTLD_AdminAPI.getTransactionStatus(result.txnId, result.count, false);
        result = (RTLD_TransactionStatus) JSON.deserialize(statusJson, RTLD_TransactionStatus.class);

        Test.stopTest();

        System.assertEquals(2, result.count);
        System.assertEquals(true, result.isComplete);
        System.assertEquals(true, result.isSuccessful);
    }
}