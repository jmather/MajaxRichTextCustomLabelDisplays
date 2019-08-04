import { LightningElement, api, track } from 'lwc';
import debug from 'c/debug';
import { RtldDAO } from 'c/rtldDAO';

export default class RichTextDisplayEdit extends LightningElement {
    /**
     *
     * @type {MAJAX__Display_Entry__mdt}
     */
    @api entry;
    @api enableDebugging = false;
    @api refId = null;
    @track disabled = false;

    /**
     *
     * @type {MAJAX__Display_Entry__mdt}
     */
    @track updatedEntry = RtldDAO.newEntry();

    connectedCallback() {
        this.dao = new RtldDAO(this.enableDebugging);
        debug(this.enableDebugging, 'RichTextDisplayEdit.connectedCallback', this.entry);
        this.updatedEntry = this.entry;
    }

    /**
     *
     * @param {EntryEditorUpdateEvent} event
     * @listens EntryEditor#handleUpdate
     */
    handleEditorUpdate(event) {
        debug.event(this.enableDebugging, 'RichTextDisplayEdit.handleEditorUpdate', event);
        this.updatedEntry = event.detail;
    }

    handleCancelClick() {
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'edit',
            refId: this.refId,
        };

        this.dispatchEvent(new CustomEvent('cancel', { detail: obj }));
    }

    handleUpdateClick() {
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'update',
            last: this.entry,
            entry: this.updatedEntry,
            refId: this.refId,
        };

        debug(this.enableDebugging, '[RichTextDisplayEdit.handleUpdateClick]', obj);

        this.disabled = true;
        this.dispatchEvent(new CustomEvent('preupdate', { detail: obj }));

        const controller = this;

        this.dao.update(this.updatedEntry).then(status => {
            controller.dispatchEvent(new CustomEvent('postupdate', { detail: obj }));

            controller.disabled = false;
        });
    }

    handleHideClick() {
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'hide',
            entry: this.updatedEntry,
            refId: this.refId,
        };

        debug(this.enableDebugging, '[RichTextDisplayEdit.handleHide]', obj);

        this.disabled = true;
        this.dispatchEvent(new CustomEvent('prehide', { detail: obj }));

        const controller = this;

        this.dao.hide(this.updatedEntry.DeveloperName).then(status => {
            controller.dispatchEvent(new CustomEvent('posthide', { detail: obj }));

            controller.disabled = false;
        });
    }
}