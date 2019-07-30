import { LightningElement, track, api } from 'lwc';
import createEntry from '@salesforce/apex/AdminAPI.createEntry'
import getTransactionStatus from '@salesforce/apex/AdminAPI.getTransactionStatus'

class JobHelper {
    static whenComplete(promise, callback, maxCheckCount = 15) {
        return promise.then(statusJson => {
            const status = JSON.parse(statusJson);
            const nextIteration = () => {
                const check = getTransactionStatus({ txnId: status.txnId, count: status.count, enableDebugging });
                return JobHelper.whenComplete(check, callback, maxCheckCount);    
            };

            RichTextDisplayCreate.log('[richTextDisplayCreate.whenComplete]', { status: JSON.stringify(status) });
    
            if (status.isComplete === true) {
                callback(status);
                return null;
            }

            if (status.count > maxCheckCount) {
                RichTextDisplayCreate.log('[richTextDisplayCreate.whenComplete] bailing out...');
                return null;
            }

            return new Promise((accept) => {
                setTimeout(accept, 500);
            }).then(nextIteration);
        });
    }
}

let enableDebugging = false;

export default class RichTextDisplayCreate extends LightningElement {
    @api enableDebugging = false;
    @track label;
    @track developerName = '';
    @track title = '';
    @track content = '';
    @track disabled = false;

    static log() {
        if (enableDebugging) {
            console.log.apply(console, arguments);
        }
    }

    connectedCallback() {
        enableDebugging = this.enableDebugging;
    }

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
        const obj = {
            enableDebugging,
            label: this.label,
            developerName: this.developerName,
            title: this.title,
            content: this.content,
            action: 'create',
        };

        const controller = this;

        controller.disabled = true;

        controller.dispatchEvent(new CustomEvent('precreate', { detail: obj }));
        
        JobHelper.whenComplete(
            createEntry(obj), 
            (status) => {
                RichTextDisplayCreate.log('[richTextDisplayCreate.handleCreate]', { status });
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