/**
 * Created by jmather on 2019-08-07.
 */

@IsTest
public with sharing class RTLD_IDeploymentHandlerMock implements RTLD_EntryDAO.IDeploymentHandler {
    public Metadata.DeployContainer container;
    public RTLD_EntryDAO.Callback callback;

    public void deploy(Metadata.DeployContainer container, Metadata.DeployCallback callback) {
        this.container = container;
        this.callback = (RTLD_EntryDAO.Callback) callback;
    }
}