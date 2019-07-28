import { LightningElement, track } from 'lwc';
import createEntry from '@salesforce/apex/AdminAPI.createEntry'
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

export default class RichTextDisplayCreate extends LightningElement {
    @track label;
    @track developerName = '';
    @track title = '';
    @track content = '';
    @track disabled = false;

    updateLabel(event) {
        this.label = event.detail.value;
    }

    updateDeveloperName(event) {
        this.developerName = event.detail.value;
    }

    updateTitle(event) {
        this.title = event.detail.value;
    }

    updateContent(event) {
        this.content = event.detail.value;
    }

    handleCreate() {
        var obj = {
            label: this.label,
            developerName: this.developerName,
            title: this.title,
            content: this.content,
            action: 'create',
        };

        var controller = this;

        controller.disabled = true;

        controller.dispatchEvent(new CustomEvent('precreate', { detail: obj }));
        
        JobHelper.whenComplete(
            createEntry(obj), 
            (status) => {
                console.log('[richTextDisplayCreate.handleCreate]', { status });
                controller.dispatchEvent(new CustomEvent('postcreate', { detail: obj }));

                controller.label = '';
                controller.developerName = '';
                controller.title = '';
                controller.content = ''; 
                controller.disabled = false;   
            }
        );
    }
}