import {api, LightningElement, track} from 'lwc';
import { RtldDAO, DisplayStyle } from 'c/rtldDAO';
import debug from 'c/debug';

/**
 * @typedef {Object} EntryEditorUpdateEvent
 * @property {MAJAX__Display_Entry__mdt} detail
 */

export default class EntryEditor extends LightningElement {
    @api enableDebugging = false;
    @api disabled = false;
    @api entry = null;
    @api delayInterval = 250;
    @track updatedEntry = RtldDAO.newEntry();
    delayTimeout = null;

    displayStyleOptions = [
        { label: DisplayStyle.CARD, value: DisplayStyle.CARD },
        { label: DisplayStyle.TILE, value: DisplayStyle.TILE },
    ];

    connectedCallback() {
        debug(this.enableDebugging, 'EntryEditor.connectedCallback entry', this.entry);
        if (this.entry) {
            this.updatedEntry = JSON.parse(JSON.stringify(this.entry));
        }

        debug(this.enableDebugging, 'EntryEditor.connectedCallback updatedEntry', this.updatedEntry);
    }

    updateLabel(event) {
        event.preventDefault();
        this.updatedEntry.MasterLabel = event.detail.value;
        this.handleUpdate();
    }

    updateTitle(event) {
        event.preventDefault();
        this.updatedEntry.MAJAX__Title__c = event.detail.value;
        this.handleUpdate();
    }

    updateContent(event) {
        event.preventDefault();
        this.updatedEntry.MAJAX__Content__c = event.detail.value;
        this.handleUpdate();
    }

    updateDisplayStyle(event) {
        event.preventDefault();
        this.updatedEntry.MAJAX__DisplayStyle__c = event.detail.value;
        this.handleUpdate();
    }

    updateURL(event) {
        debug.event(this.enableDebugging, 'EntryEditor.updateURL', event);
        event.preventDefault();
        this.updatedEntry.MAJAX__URL__c = event.detail.value;
        this.handleUpdate();
    }

    updateDisplayTitle(event) {
        debug.event(this.enableDebugging, 'EntryEditor.updateDisplayTitle', event);
        event.preventDefault();
        this.updatedEntry.MAJAX__DisplayTitle__c = event.detail.checked;
        this.handleUpdate();
    }

    updateIcon(event) {
        debug.event(this.enableDebugging, 'EntryEditor.updateIcon', event);
        event.preventDefault();
        this.updatedEntry.MAJAX__Icon__c = event.detail.value;
        this.handleUpdate();
    }

    /**
     * @fires {EntryEditor#update}
     */
    handleUpdate() {
        if (this.delayTimeout !== null) {
            clearTimeout(this.delayTimeout);
        }

        const obj = this.updatedEntry;
        const controller = this;

        const dispatchUpdate = () => {
            debug(controller.enableDebugging, 'EntryEditor.handleUpdate', obj);
            controller.dispatchEvent(new CustomEvent('update', { detail: JSON.parse(JSON.stringify(obj)) }));
        };

        this.delayTimeout = setTimeout(dispatchUpdate, this.delayInterval);
    }

    /**
     * @event EntryEditor#update
     * @type {EntryEditorUpdateEvent}
     */
}