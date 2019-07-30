import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getEntries from '@salesforce/apex/AdminAPI.getEntries'

let enableDebugging = false;

export default class RichTextDisplayList extends LightningElement {
    @api enableDebugging;
    @track error;
    @track disabled = false;
    @track disabledAction = null;
    @track action = null;
    columns = [
        { label: 'Name', fieldName: 'MasterLabel', type: 'string' },
        { label: 'Title', fieldName: 'MAJAX__Title__c', type: 'string' },
    ];

    @wire(getEntries)
    entries;

    static debug() {
        if (enableDebugging) {
            console.log.apply(console, arguments);
        }
    }

    connectedCallback() {
        enableDebugging = this.enableDebugging;
    }

    updateSelection(event) {
        RichTextDisplayList.debug('RichTextDisplayList.updateSelection', event);
    }

    handlePreAction(event) {
        RichTextDisplayList.debug('RichTextDisplayList.handlePreAction', event);
        RichTextDisplayList.debug('RichTextDisplayList.handlePreAction', JSON.stringify(event.detail));
        this.disabled = true;
        this.disabledAction = event.detail.action;
    }

    handlePostAction(event) {
        var controller = this;

        RichTextDisplayList.debug('RichTextDisplayList.handlePostAction', event);
        RichTextDisplayList.debug('RichTextDisplayList.handlePostAction', JSON.stringify(event.detail));

        return refreshApex(this.entries).then(() => {
            var actionDescription = null;
            
            switch(controller.disabledAction) {
                case 'create': 
                    actionDescription = 'Created';
                    break;

                case 'update':
                    actionDescription = 'Updated';
                    break;

                default:
                    actionDescription = 'Deleted';
            }

            controller.disabled = false;
            controller.disabledAction = null;

            const e = new ShowToastEvent({
                title: 'Success!',
                message: 'The Rich Text Display has been successfully {0}.',
                messageData: [
                    actionDescription.toLowerCase(),
                ],
                variant: 'success',
            });
            this.dispatchEvent(e);
        });
    }

    isReady() {
        return this.entries && this.entries.data;
    }
}