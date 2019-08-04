import { LightningElement, track, api } from 'lwc';
import debug from 'c/rtldDebug';
import { RtldDAO } from 'c/rtldDAO';

/**
 * @typedef {Object} CreateCancelEventDetails
 * @property {Boolean} enableDebugging
 * @property {String} action
 * @property {String} refId
 */

/**
 * @typedef {CreateCancelEventDetails} RtldCreateEventDetails
 * @property {MAJAX__RTLD_Entry__mdt} entry
 */

/**
 * @typedef {Object} RtldCancelCreateEvent
 * @property {CreateCancelEventDetails} detail
 */

/**
 * @typedef {Object} RtldCreateEvent
 * @property {RtldCreateEventDetails} detail
 */

/**
 * @event RtldCreate#cancel
 * @type {RtldCancelCreateEvent}
 */

/**
 * @event RtldCreate#precreate
 * @type {RtldCreateEvent}
 */

/**
 * @event RtldCreate#postcreate
 * @type {RtldCreateEvent}
 */

export default class RtldCreate extends LightningElement {
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
     * @param {RtldEntryEditorUpdateEvent} event
     * @listens RtldEntryEditor#handleUpdate
     */
    handleEditorUpdate(event) {
        debug.event(this.enableDebugging, 'RtldCreate.handleEditorUpdate', event);
        this.entry = event.detail;
    }

    /**
     * @fires RtldCreate#cancel
     */
    handleCancelClick(event) {
        debug.event(this.enableDebugging, 'RtldCreate.handleCancel', event);
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'create',
            refId: this.refId,
        };
        this.dispatchEvent(new CustomEvent('cancel', { detail: obj }));
    }

    /**
     * @fires RtldCreateEvent#precreate
     * @fires RtldCreateEvent#postcreate
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