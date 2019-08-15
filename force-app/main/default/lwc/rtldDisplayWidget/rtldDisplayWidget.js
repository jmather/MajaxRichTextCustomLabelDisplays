import { LightningElement, api, track } from 'lwc';
import callRenderText from '@salesforce/apex/RTLD_WidgetAPI.renderText';
import debug from 'c/rtldDebug';

export default class RtldDisplayWidget extends LightningElement {
    /**
     *
     * @type {MAJAX__RTLD_Entry__mdt}
     */
    @api entry;
    @api enableDebugging = false;
    @track loading = true;
    @track response = null;
    @track renderedTitle = '';
    @track renderedContent = '';
    rawTitle;
    rawContent;

    get displayTile() {
        return this.loading === false && this.entry && this.entry.MAJAX__DisplayStyle__c === 'Tile';
    }

    get displayCardWithoutUrl() {
        return this.loading === false && this.entry && this.entry.MAJAX__DisplayStyle__c === 'Card' && this.hasUrl === false;
    }

    get displayCardWithUrl() {
        return this.loading === false && this.entry && this.entry.MAJAX__DisplayStyle__c === 'Card' && this.hasUrl;
    }

    get hasUrl() {
        return this.entry && !!this.entry.MAJAX__URL__c && this.entry.MAJAX__URL__c !== '';
    }

    get hasIcon() {
        return this.entry && !!this.entry.MAJAX__Icon__c && this.entry.MAJAX__Icon__c !== '';
    }

    get titleDisplay() {
        return (this.entry && this.entry.MAJAX__DisplayTitle__c) ? this.renderedTitle : null;
    }

    get urlDisplay() {
        return (this.hasUrl) ? this.entry.MAJAX__URL__c : null;
    }

    get contentDisplay() {
        return this.renderedContent;
    }

    get iconDisplay() {
        return (this.hasIcon) ? this.entry.MAJAX__Icon__c : null;
    }

    renderedCallback() {
        const data = {
            values: {
                loading: this.loading,
                entry: this.entry,
                rawTitle: this.rawTitle,
                rawContent: this.rawContent,
                renderedTitle: this.renderedTitle,
                renderedContent: this.renderedContent,
            },
            getters: {
                title: this.titleDisplay,
                content: this.contentDisplay,
                url: this.urlDisplay,
            },
            flags: {
                displayCardWithUrl: this.displayCardWithUrl,
                displayCardWithoutUrl: this.displayCardWithoutUrl,
                displayTile: this.displayTile,
                hasUrl: this.hasUrl,
            },
        };
        debug(this.enableDebugging, 'RtldDisplayWidget.renderedCallback', data);

        if (! this.entry) {
            if (this.rawTitle === undefined || this.rawContent === undefined) {
                this._render('', '');
            }

            return;
        }

        if (this.rawTitle === this.entry.MAJAX__Title__c && this.rawContent === this.entry.MAJAX__Content__c) {
            return;
        }

        this._render(this.entry.MAJAX__Title__c, this.entry.MAJAX__Content__c);
    }

    _render(title, content) {
        this.loading = true;

        this.rawTitle = title;
        this.rawContent = content;

        const payload = {
            title: this.rawTitle,
            content: this.rawContent,
            enableDebug: this.enableDebugging,
        };
        const controller = this;
        debug(controller.enableDebugging, 'RtldDisplayWidget._render request', payload);
        callRenderText(payload).then(response => {
            debug(controller.enableDebugging, 'RtldDisplayWidget._render response', response);

            controller.loading = false;

            if (response) {
                const data = JSON.parse(response);
                controller.renderedTitle = data.title;
                controller.renderedContent = data.content;
                controller.error = undefined;
            }
        });
    }
}