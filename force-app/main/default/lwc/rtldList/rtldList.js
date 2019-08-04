import {api, LightningElement} from 'lwc';
import debug from 'c/debug';
import { RtldDAO } from 'c/rtldDAO';

export default class RtldList extends LightningElement {
    @api enableDebugging = false;
    @api entries;

    actions = [
        { label: 'Edit', name: 'edit' },
        { label: 'Hide', name: 'hide' },
    ];
    columns = [
        { label: 'Name', fieldName: 'MasterLabel', type: 'string' },
        { label: 'Title', fieldName: 'MAJAX__Title__c', type: 'string' },
        { label: 'Display Title?', fieldName: 'MAJAX__DisplayTitle__c', type: 'boolean' },
        { label: 'Display Style', fieldName: 'MAJAX__DisplayStyle__c', type: 'string' },
        { label: 'Has Icon?', cellAttributes:
                { iconName: { fieldName: 'MAJAX__Icon__c' }, iconPosition: 'right' }},
        {
            type: 'action',
            typeAttributes: { rowActions: this.actions },
        },
    ];

    connectedCallback() {
        this.dao = new RtldDAO(this.enableDebugging);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('row action', { actionName, row: JSON.parse(JSON.stringify(row)) });
        switch (actionName) {
            case 'hide':
                this._hide(row);
                break;
            case 'edit':
                this.dispatchEvent(new CustomEvent('edit', { detail: row }));
                break;
            default:
        }
    }

    /**
     *
     * @param {MAJAX__Display_Entry__mdt} entry
     * @private
     */
    _hide(entry) {
        const obj = {
            enableDebugging: this.enableDebugging,
            action: 'hide',
            entry,
            refId: entry.DeveloperName,
        };

        debug(this.enableDebugging, '[RtldList._hide]', obj);

        this.dispatchEvent(new CustomEvent('prehide', { detail: obj }));

        const controller = this;

        this.dao.hide(entry.DeveloperName).then(status => {
            controller.dispatchEvent(new CustomEvent('posthide', { detail: obj }));
        });
    }
}