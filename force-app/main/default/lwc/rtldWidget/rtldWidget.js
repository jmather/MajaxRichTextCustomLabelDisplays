import { LightningElement, api, track, wire } from 'lwc';
import callRenderText from '@salesforce/apex/RTLD_WidgetAPI.renderText';
import getEntry from '@salesforce/apex/RTLD_WidgetAPI.getEntry';
import debug from 'c/rtldDebug';

export default class RtldWidget extends LightningElement {
    @api mode = 'developerName';
    @api developerName;
    @api title;
    @api content;
    @api note;
    @api displayTitle = false;
    @api displayStyle = 'Card';
    @api url = '';
    @api icon = '';
    @api enableDebugging = false;
    @track loading = true;
    @track renderedTitle = '';
    @track renderedContent = '';

    get displayTile() {
        return this.loading === false && this.displayStyle === 'Tile';
    }

    get displayCardWithoutUrl() {
        return this.loading === false && this.displayStyle === 'Card' && this.hasUrl === false;
    }

    get displayCardWithUrl() {
        return this.loading === false && this.displayStyle === 'Card' && this.hasUrl;
    }

    get hasUrl() {
        return !!this.url && this.url !== '';
    }

    get hasIcon() {
        return !!this.icon && this.icon !== '';
    }

    get titleDisplay() {
        return (this.displayTitle) ? this.renderedTitle : null;
    }

    get urlDisplay() {
        return (this.hasUrl) ? this.url : null;
    }

    get contentDisplay() {
        return this.renderedContent;
    }

    get iconDisplay() {
        return (this.hasIcon) ? this.icon : null;
    }

    renderedCallback() {
        const data = {
            values: {
                title: this.renderedTitle,
                content: this.renderedContent,
                displayTitle: this.displayTitle,
                displayStyle: this.displayStyle,
                url: this.url,
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
        debug(this.enableDebugging, 'RtldWidget.renderedCallback', data);
    }

    @wire(callRenderText, { title: '$title', content: '$content', enableDebug: '$enableDebugging' })
    handleRenderingText({ error, data }) {
        debug(this.enableDebugging, 'RtldWidget.handleRenderingText title', this.title);
        debug(this.enableDebugging, 'RtldWidget.handleRenderingText content', this.content);
        debug(this.enableDebugging, 'RtldWidget.handleRenderingText data', JSON.stringify(data));

        if (this.mode !== 'text') {
            return;
        }

        this.handleResponseData(data, error);
    }

    /**
     *
     * @param error
     * @param {String} data
     */
    @wire(getEntry, { developerName: '$developerName', enableDebug: '$enableDebugging' })
    handleGetEntry({ error, data }) {
        debug(this.enableDebugging, 'RichTextDisplayWidget.handleGetEntry', { error, data });
        if (this.mode !== 'developerName') {
            return;
        }

        if (data) {
            /**
             *
             * @type {MAJAX__RTLD_Entry__mdt}
             */
            const entry = JSON.parse(data);
            this.content = entry.MAJAX__Content__c;
            this.title = entry.MAJAX__Title__c;
            this.url = entry.MAJAX__URL__c;
            this.icon = entry.MAJAX__Icon__c;
            this.displayStyle = entry.MAJAX__DisplayStyle__c;
            this.displayTitle = entry.MAJAX__DisplayTitle__c;
            const controller = this;
            return callRenderText({ title: this.title, content: this.content, enableDebug: this.enableDebugging })
                .then((response) => controller.handleResponseData(response));
        }
    }

    handleResponseData(dataJson, error) {
        this.loading = false;
        if (dataJson) {
            const data = JSON.parse(dataJson);
            this.renderedTitle = data.title;
            this.renderedContent = data.content;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }
}