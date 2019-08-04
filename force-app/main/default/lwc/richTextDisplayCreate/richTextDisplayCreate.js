import { LightningElement, track, api } from 'lwc';
import debug from 'c/debug';
import { RtldDAO } from 'c/rtldDAO';

/**
 * @typedef {Object} CreateCancelEventDetails
 * @property {Boolean} enableDebugging
 * @property {String} action
 * @property {String} refId
 */

/**
 * @typedef {CreateCancelEventDetails} CreateEventDetails
 * @property {MAJAX__Display_Entry__mdt} entry
 */

/**
 * @typedef {Object} RichTextDisplayCancelCreateEvent
 * @property {CreateEventDetails} detail
 */

/**
 * @typedef {Object} RichTextDisplayCreateEvent
 * @property {CreateEventDetails} detail
 */

/**
 * @event RichTextDisplayCreate#cancel
 * @type {RichTextDisplayCancelCreateEvent}
 */

/**
 * @event RichTextDisplayCreate#precreate
 * @type {RichTextDisplayCreateEvent}
 */

/**
 * @event RichTextDisplayCreate#postcreate
 * @type {RichTextDisplayCreateEvent}
 */

export default class RichTextDisplayCreate extends LightningElement {
    @api enableDebugging = false;
    @api refId = null;
    @track disabled = false;
    @track entry = RtldDAO.newEntry();

    connectedCallback() {
        this.dao = new RtldDAO(this.enableDebugging);
    }

    get getTitle() {
        return this.entry.MAJAX__Title__c;
    }

    get getContent() {
        return this.entry.MAJAX__Content__c;
    }

    /**
     *
     * @param {EntryEditorUpdateEvent} event
     * @listens EntryEditor#handleUpdate
     */
    handleEditorUpdate(event) {
        debug.event(this.enableDebugging, 'RichTextDisplayCreate.handleEditorUpdate', event);
        this.entry = event.detail;
    }

    /**
     * @fires RichTextDisplayCreate#cancel
     */
    handleCancelClick(event) {
        debug.event(this.enableDebugging, 'RichTextDisplayCreate.handleCancel', event);
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'create',
            refId: this.refId,
        };
        this.dispatchEvent(new CustomEvent('cancel', { detail: obj }));
    }

    /**
     * @fires RichTextDisplayCreateEvent#precreate
     * @fires RichTextDisplayCreateEvent#postcreate
     */
    handleCreateClick() {
        const obj = {
            enableDebugging: this.enableDebugging,
            entry: this.entry,
            action: 'create',
            refId: this.refId,
        };

        const controller = this;

        this.disabled = true;
        this.dispatchEvent(new CustomEvent('precreate', { detail: obj }));

        this.dao.create(this.entry).then(status => {
            obj.entry.DeveloperName = status.txnId;
            controller.dispatchEvent(new CustomEvent('postcreate', { detail: obj }));

            controller.entry = RtldDAO.newEntry();
            controller.disabled = false;
        });
    }
}