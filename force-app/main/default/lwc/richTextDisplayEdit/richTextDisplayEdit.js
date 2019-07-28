import { LightningElement, api, wire, track } from 'lwc';
import updateEntry from '@salesforce/apex/AdminAPI.updateEntry'
import hideEntry from '@salesforce/apex/AdminAPI.hideEntry'
import getTransactionStatus from '@salesforce/apex/AdminAPI.getTransactionStatus'

class JobHelper {
    static whenComplete(promise, callback, maxCheckCount = 15) {
        return promise.then(statusJson => {
            var status = JSON.parse(statusJson);
            var nextIteration = () => {
                var check = getTransactionStatus({ txnId: status.txnId, count: status.count });
                return JobHelper.whenComplete(check, callback, maxCheckCount);
            };

            console.log('[richTextDisplayCreate.whenComplete]', { status });

            if (status.isComplete === true) {
                callback(status);
                return null;
            }

            if (status.count > maxCheckCount) {
                console.log('[richTextDisplayCreate.whenComplete] bailing out...');
                return null;
            }

            return new Promise((accept) => {
                setTimeout(accept, 500);
            }).then(nextIteration);
        });
    }
}

export default class RichTextDisplayEdit extends LightningElement {
    @api entry;
    @track disabled = false;
    @track disabledAction = null;

    @track label;
    @track title;
    @track content;

    connectedCallback() {
        this.label = this.entry.MasterLabel || '';
        this.title = this.entry.MAJAX__Title__c || '';
        this.content = this.entry.MAJAX__Content__c || '';
    }

    handleUpdate() {
        var obj = {
            developerName: this.entry.DeveloperName,
            label: this.label,
            title: this.title,
            content: this.content,
        };

        this.handleAction('update', obj, updateEntry);
    }

    handleHide() {
        var obj = {
            developerName: this.entry.DeveloperName,
        };

        this.handleAction('hide', obj, hideEntry);
    }

    handleAction(actionName, obj, action) {
        var controller = this;
        obj.action = actionName;
        
        console.log('[RichTextDisplayEdit.handleAction]', { actionName });
        controller.disabled = true;
        controller.disabledAction = actionName;
        controller.dispatchEvent(new CustomEvent('pre' + actionName, { detail: obj }));

        JobHelper.whenComplete(
            action(obj), 
            (status) => {
                console.log('[RichTextDisplayEdit.handleAction]', { status });
                controller.dispatchEvent(new CustomEvent('post' + actionName, { detail: obj }));
                controller.disabled = false;
            }
        );
    }

    updateName(event) {
        this.label = event.detail.value;
    }

    updateTitle(event) {
        this.title = event.detail.value;
    }

    updateContent(event) {
        this.content = event.detail.value;
    }
}