import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { RtldDAO } from 'c/rtldDAO';
import debug from 'c/rtldDebug';

/**
 * @typedef {Object} Tab
 * @property {String} id
 * @property {String} label
 * @property {String} title
 * @property {Boolean} create
 * @property {Boolean} edit
 * @property {MAJAX__RTLD_Entry__mdt} entry
 */

export default class RtldManager extends LightningElement {
    /**
     * @type {Boolean}
     */
    @api enableDebugging;
    @track error;
    @track disabled = false;

    /**
     *
     * @type {MAJAX__RTLD_Entry__mdt[]}
     */
    @track entries = [];

    /**
     *
     * @type {Tab[]}
     */
    @track displayTabs = [];

    /**
     * @type {String}
     */
    @track activeTab;

    createdCount = 0;

    connectedCallback() {
        this.dao = new RtldDAO(this.enableDebugging);
        const controller = this;
        this.dao.getAll().then(entries => {
            debug(controller.enableDebugging, '[RtldManager.constructor] got entries', entries);
            controller.entries = entries;
        });
    }

    get getEntries() {
        return this.entries;
    }

    get getActiveTab() {
        return this.activeTab;
    }

    get getDisplayTabs() {
        return this.displayTabs;
    }

    handleCreateNew(event) {
        debug(this.enableDebugging, 'RtldManager.handleCreateNew fired');
        debug.event(this.enableDebugging, 'RtldManager.handleCreateNew', event);
        debug(this.enableDebugging, 'RtldManager.handleCreateNew event logged?');

        this._addTab(this._createNewTab());
    }

    /**
     *
     * @param {RtldListEditEvent} event
     * @listens {RtldList#handleRowAction}
     */
    handleListEdit(event) {
        debug.event(this.enableDebugging, 'RtldManager.handleEdit', event);

        if (this._hasTab(event.detail.DeveloperName)) {
            this._setActiveTab(event.detail.DeveloperName);
        } else {
            this._addTab(this._createEditTab(event.detail));
        }
    }

    handleActiveTabChange(event) {
        this.activeTab = event.target.value;
    }

    /**
     *
     * @returns {Tab}
     * @private
     */
    _createNewTab() {
        this.createdCount++;

        return {
            id: 'create_' + this.createdCount,
            label: 'Create New Entry #' + this.createdCount + ' *',
            title: 'Create New Entry #' + this.createdCount + ' (unsaved)',
            create: true,
        };
    }

    /**
     *
     * @param {MAJAX__RTLD_Entry__mdt|null} entry
     * @returns {Tab}
     * @private
     */
    _createEditTab(entry) {
        return {
            id: entry.DeveloperName,
            label: entry.MasterLabel,
            title: entry.MasterLabel,
            edit: true,
            entry,
        };
    }

    /**
     *
     * @param {Tab} tab
     * @private
     */
    _addTab(tab) {
        this.displayTabs.push(tab);
        this._setActiveTab(tab.id);
    }

    _hasTab(id) {
        for (let i = 0; i < this.displayTabs.length; i++) {
            if (this.displayTabs[i].id === id) {
                return i;
            }
        }

        return false;
    }

    /**
     *
     * @param {String} id
     * @private
     */
    _removeTab(id) {
        const tabIndex = this._hasTab(id);
        if (this.activeTab === id) {
            const nextTab = tabIndex - 1;
            if (nextTab < 0) {
                this.activeTab = null;
            } else {
                this.activeTab = this.displayTabs[nextTab].id;
            }
        }
        this.displayTabs = this.displayTabs.filter(tab => tab.id !== id);
    }

    /**
     *
     * @param {String} id
     * @param {Tab} tab
     * @private
     */
    _replaceTab(id, tab) {
        for (let i = 0; i < this.displayTabs.length; i++) {
            if (this.displayTabs[i].id === id) {
                this.displayTabs[i] = tab;
                break;
            }
        }

        if (this.activeTab === id) {
            this._setActiveTab(tab.id);
        }
    }

    _setActiveTab(id) {
        if (this.activeTab === id) {
            return;
        }

        // have to update this separately or else it misses it, somehow...
        const controller = this;
        setTimeout(() => { controller.activeTab = id; }, 0);
    }

    /**
     *
     * @param {RtldCancelCreateEvent|HideEventDetails} event
     * @listens RtldCreate#handleCreateClick
     * @listens RtldEdit#handleUpdateClick
     * @listens RtldEdit#handleHideClick
     */
    handleCancel(event) {
        debug.event(this.enableDebugging, 'RtldManager.handleCancel', event);
        this._removeTab(event.detail.refId)
    }

    /**
     *
     * @param {RtldCreateEvent|RtldHideEvent|RtldEditEvent} event
     * @listens RtldCreate#handleCreateClick
     * @listens RtldEdit#handleUpdateClick
     * @listens RtldEdit#handleHideClick
     * @listens {RtldList#_hide}
     */
    handlePreAction(event) {
        debug.event(this.enableDebugging, 'RtldManager.handlePreAction', event);
        this.disabled = true;
    }

    /**
     *
     * @param {RtldCreateEvent|RtldHideEvent|RtldEditEvent} event
     * @listens RtldCreate#handleCreateClick
     * @listens RtldEdit#handleUpdateClick
     * @listens RtldEdit#handleHideClick
     * @listens {RtldList#_hide}
     */
    handlePostAction(event) {
        const controller = this;

        debug.event(this.enableDebugging, 'RtldManager.handlePostAction', event);

        this.dao.getAll().then(entries => {
            controller.entries = entries;
            let actionDescription = null;

            switch(event.detail.action) {
                case 'create':
                    actionDescription = 'Created';
                    break;

                case 'update':
                    actionDescription = 'Updated';
                    break;

                default:
                    actionDescription = 'Deleted';
            }

            if (event.detail.action === 'hide') {
                controller._removeTab(event.detail.refId);
            } else {
                controller._replaceTab(event.detail.refId, controller._createEditTab(event.detail.entry));
            }

            controller.disabled = false;

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'The Rich Text Display has been successfully {0}.',
                messageData: [
                    actionDescription.toLowerCase(),
                ],
                variant: 'success',
            }));
        });
    }
}