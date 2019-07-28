import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getEntries from '@salesforce/apex/AdminAPI.getEntries'

export default class RichTextDisplayList extends LightningElement {
    @track error;
    @track disabled = false;
    @track disabledAction = null;

    @wire(getEntries)
    entries;

    handlePreAction(event) {
        console.log('RichTextDisplayList.handlePreAction', event);
        console.log('RichTextDisplayList.handlePreAction', JSON.stringify(event.detail));
        this.disabled = true;
        this.disabledAction = event.detail.action;
    }

    handlePostAction(event) {
        var controller = this;

        console.log('RichTextDisplayList.handlePostAction', event);
        console.log('RichTextDisplayList.handlePostAction', JSON.stringify(event.detail));

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