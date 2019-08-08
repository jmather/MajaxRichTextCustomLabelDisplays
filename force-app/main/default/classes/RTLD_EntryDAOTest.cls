/**
 * Created by jmather on 2019-08-07.
 */

@IsTest
public with sharing class RTLD_EntryDAOTest {
    @IsTest
    static void GetEntries() {
        Test.startTest();

        List<RTLD_Entry__mdt> entries = RTLD_EntryDAO.getEntries();

        Test.stopTest();

        System.assert(entries.size() > 1);
    }

    @IsTest
    static void GetEntry() {
        Test.startTest();

        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry('Test');

        Test.stopTest();

        System.assertNotEquals(null, entry);
    }

    @IsTest
    static void UpdateEntry() {
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry('Test');
        entry.Content__c = 'Test';

        RTLD_IDeploymentHandlerMock handler = new RTLD_IDeploymentHandlerMock();

        Test.startTest();

        RTLD_EntryDAO.deploymentHandler = handler;

        RTLD_TransactionStatus result = RTLD_EntryDAO.upsertEntry(entry);

        Test.stopTest();

        System.assertEquals(1, handler.container.getMetadata().size());
        Metadata.CustomMetadata md = (Metadata.CustomMetadata) handler.container.getMetadata()[0];
        List<Metadata.CustomMetadataValue> values = md.values;
        System.assertEquals(6, values.size());

        for (Metadata.CustomMetadataValue value : values) {
            System.assertEquals(entry.get(value.field), value.value);
        }

        System.debug('container: ' + JSON.serializePretty(handler.container));
        System.debug('result: ' + JSON.serializePretty(result));
    }

    @IsTest
    static void HideEntry() {
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry('Test');

        RTLD_IDeploymentHandlerMock handler = new RTLD_IDeploymentHandlerMock();

        Test.startTest();

        RTLD_EntryDAO.deploymentHandler = handler;

        RTLD_TransactionStatus result = RTLD_EntryDAO.hideEntry(entry);

        Test.stopTest();

        System.assertEquals(1, handler.container.getMetadata().size());
        Metadata.CustomMetadata md = (Metadata.CustomMetadata) handler.container.getMetadata()[0];
        List<Metadata.CustomMetadataValue> values = md.values;
        System.assertEquals(1, values.size());
        System.assertEquals('IsHidden__c', values[0].field);
        System.assertEquals(true, values[0].value);

        System.debug('container: ' + JSON.serializePretty(handler.container));
        System.debug('result: ' + JSON.serializePretty(result));
    }

    @IsTest
    static void Callback() {
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry('Test');
        entry.Content__c = 'Test';

        RTLD_IDeploymentHandlerMock handler = new RTLD_IDeploymentHandlerMock();

        RTLD_EntryDAO.deploymentHandler = handler;

        RTLD_TransactionStatus result = RTLD_EntryDAO.upsertEntry(entry);

        Metadata.DeployResult res = new Metadata.DeployResult();

        res.done = true;
        res.status = Metadata.DeployStatus.Succeeded;

        TestDeployCallbackContext context = new TestDeployCallbackContext();

        Test.startTest();

        handler.callback.handleResult(res, context);

        Test.stopTest();

        System.assertEquals(handler.callback.txnId, result.txnId);
    }

    class TestDeployCallbackContext extends Metadata.DeployCallbackContext {
        public override Id getCallbackJobId() {
            return '';
        }
    }
}