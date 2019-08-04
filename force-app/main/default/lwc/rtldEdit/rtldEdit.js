import { LightningElement, api, track } from 'lwc';
import debug from 'c/rtldDebug';
import { RtldDAO } from 'c/rtldDAO';

/**
 * @typedef {Object} RtldEditCancelEventDetails
 * @property {Boolean} enableDebugging
 * @property {String} action
 * @property {String} refId
 */

/**
 * @typedef {RtldEditCancelEventDetails} HideEventDetails
 * @property {MAJAX__RTLD_Entry__mdt} entry
 */

/**
 * @typedef {HideEventDetails} EditEventDetails
 * @property {MAJAX__RTLD_Entry__mdt} last
 */

/**
 * @typedef {Object} RtldEditCancelEvent
 * @property {RtldEditCancelEventDetails} detail
 */

/**
 * @typedef {Object} RtldHideEvent
 * @property {HideEventDetails} detail
 */

/**
 * @typedef {Object} RtldEditEvent
 * @property {EditEventDetails} detail
 */

/**
 * @event RtldEdit#cancel
 * @type {RtldEditCancelEvent}
 */

/**
 * @event RtldEdit#preupdate
 * @type {RtldEditEvent}
 */

/**
 * @event RtldEdit#postupdate
 * @type {RtldEditEvent}
 */

/**
 * @event RtldEdit#prehide
 * @type {RtldHideEvent}
 */

/**
 * @event RtldEdit#posthide
 * @type {RtldHideEvent}
 */

export default class RtldEdit extends LightningElement {
    /**
     *
     * @type {MAJAX__RTLD_Entry__mdt}
     */
    @api entry;
    @api enableDebugging = false;
    @api refId = null;
    @track disabled = false;

    /**
     *
     * @type {MAJAX__RTLD_Entry__mdt}
     */
    @track updatedEntry = RtldDAO.newEntry();

    connectedCallback() {
        this.dao = new RtldDAO(this.enableDebugging);
        debug(this.enableDebugging, 'RtldEdit.connectedCallback', this.entry);
        this.updatedEntry = this.entry;
    }

    /**
     *
     * @param {RtldEntryEditorUpdateEvent} event
     * @listens RtldEntryEditor#handleUpdate
     */
    handleEditorUpdate(event) {
        debug.event(this.enableDebugging, 'RtldEdit.handleEditorUpdate', event);
        this.updatedEntry = event.detail;
    }

    /**
     * @fires {RtldEditEvent#cancel}
     */
    handleCancelClick() {
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'edit',
            refId: this.refId,
        };

        this.dispatchEvent(new CustomEvent('cancel', { detail: obj }));
    }

    /**
     * @fires {RtldEditEvent#preupdate}
     * @fires {RtldEditEvent#postupdate}
     */
    handleUpdateClick() {
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'update',
            last: this.entry,
            entry: this.updatedEntry,
            refId: this.refId,
        };

        debug(this.enableDebugging, '[RtldEdit.handleUpdateClick]', obj);

        this.disabled = true;
        this.dispatchEvent(new CustomEvent('preupdate', { detail: obj }));

        const controller = this;

        this.dao.update(this.updatedEntry).then(status => {
            controller.dispatchEvent(new CustomEvent('postupdate', { detail: obj }));

            controller.disabled = false;
        });
    }

    /**
     * @fires {RtldEditEvent#prehide}
     * @fires {RtldEditEvent#posthide}
     */
    handleHideClick() {
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'hide',
            entry: this.updatedEntry,
            refId: this.refId,
        };

        debug(this.enableDebugging, '[RtldEdit.handleHide]', obj);

        this.disabled = true;
        this.dispatchEvent(new CustomEvent('prehide', { detail: obj }));

        const controller = this;

        this.dao.hide(this.updatedEntry.DeveloperName).then(status => {
            controller.dispatchEvent(new CustomEvent('posthide', { detail: obj }));

            controller.disabled = false;
        });
    }
}