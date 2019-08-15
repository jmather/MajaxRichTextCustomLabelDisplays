import { LightningElement, api, track, wire } from 'lwc';
import callRenderText from '@salesforce/apex/RTLD_WidgetAPI.renderText';
import getEntry from '@salesforce/apex/RTLD_WidgetAPI.getEntry';
import debug from 'c/rtldDebug';

export default class RtldWidget extends LightningElement {
    @api developerName;
    @api enableDebugging = false;
    @track entry = null;

    renderedCallback() {
        debug(this.enableDebugging, 'RtldWidget.renderedCallback', { developerName: this.developerName });
    }

    /**
     *
     * @param error
     * @param {String} data
     */
    @wire(getEntry, { developerName: '$developerName', enableDebug: '$enableDebugging' })
    handleGetEntry({ error, data }) {
        debug(this.enableDebugging, 'RichTextDisplayWidget.handleGetEntry', { error, data });

        if (data) {
            /**
             *
             * @type {MAJAX__RTLD_Entry__mdt}
             */
            this.entry = JSON.parse(data);
            debug(this.enableDebugging, 'RichTextDisplayWidget.handleGetEntry got entry', this.entry);
        }
    }
}