import debug from 'c/debug';
import transactionHelper from 'c/transactionHelper';
import getEntries from '@salesforce/apex/AdminAPIv2.getEntries'
import createEntry from '@salesforce/apex/AdminAPIv2.createEntry'
import updateEntry from '@salesforce/apex/AdminAPIv2.updateEntry'
import hideEntry from '@salesforce/apex/AdminAPIv2.hideEntry'

/**
 * @enum { String }
 */
export const DisplayStyle = {
    CARD: 'Card',
    TILE: 'Tile',
};

/**
 * @typedef {Object} MAJAX__Display_Entry__mdt
 * @property {String} Id
 * @property {String} MasterLabel
 * @property {String} DeveloperName
 * @property {String} MAJAX__Title__c
 * @property {String} MAJAX__Content__c
 * @property {DisplayStyle} MAJAX__DisplayStyle__c
 * @property {Boolean} MAJAX__DisplayTitle__c
 * @property {String} MAJAX__URL__c
 * @property {String} MAJAX__Icon__c
 */

export class RtldDAO {
    /**
     *
     * @param {Boolean} enableDebugging
     */
    constructor(enableDebugging) {
        this.enableDebugging = enableDebugging;
    }

    /**
     *
     * @returns {MAJAX__Display_Entry__mdt}
     */
    static newEntry() {
        return {
            Id: null,
            MasterLabel: '',
            MAJAX__Title__c: '',
            MAJAX__Content__c: '',
            MAJAX__DisplayStyle__c: DisplayStyle.CARD,
            MAJAX__DisplayTitle__c: true,
            MAJAX__URL__c: null,
            MAJAX__Icon__c: null,
        }
    }

    /**
     *
     * @returns {Promise<MAJAX__Display_Entry__mdt[]>}
     */
    getAll() {
        return getEntries({ enableDebugging: this.enableDebugging }).then(entriesJson => {
            debug(this.enableDebugging, '[RtldDAO.getAll] entriesJson', entriesJson);
            const entries = JSON.parse(entriesJson);
            debug(this.enableDebugging, '[RtldDAO.getAll] entries', entries);
            return entries;
        });
    }

    /**
     *
     * @param {MAJAX__Display_Entry__mdt} entry
     * @returns {Promise<MAJAX__AsyncTransactionStatus>}
     */
    create(entry) {
        const payload = {
            entryJson: JSON.stringify(entry),
            enableDebugging: this.enableDebugging,
        };

        const ref = this;
        return transactionHelper(createEntry(payload)).then((status) => {
            debug(ref.enableDebugging, '[RtldDAO.create] status', status);
            return status;
        });
    }

    /**
     *
     * @param {MAJAX__Display_Entry__mdt} entry
     * @returns {Promise<MAJAX__AsyncTransactionStatus>}
     */
    update(entry) {
        const payload = {
            entryJson: JSON.stringify(entry),
            enableDebugging: this.enableDebugging,
        };

        const ref = this;
        return transactionHelper(updateEntry(payload)).then((status) => {
            debug(ref.enableDebugging, '[RtldDAO.update] status', status);
        });
    }

    /**
     *
     * @param {String} developerName
     * @returns {Promise<MAJAX__AsyncTransactionStatus>}
     */
    hide(developerName) {
        const payload = {
            developerName: developerName,
            enableDebugging: this.enableDebugging,
        };

        const ref = this;
        return transactionHelper(hideEntry(payload)).then((status) => {
            debug(ref.enableDebugging, '[RtldDAO.hide] status', status);
        });
    }
}
