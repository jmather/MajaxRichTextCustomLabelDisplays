import { LightningElement, api, track, wire } from 'lwc';
import callRenderText from '@salesforce/apex/WidgetAPI.renderText'
import callRenderDeveloperName from '@salesforce/apex/WidgetAPI.renderDeveloperName'
import debug from 'c/debug';

export default class RichTextDisplayWidget extends LightningElement {
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
        debug(this.enableDebugging, 'RichTextDisplayWidget.renderedCallback', data);
    }

    @wire(callRenderText, { title: '$title', content: '$content', enableDebug: '$enableDebugging' })
    handleRenderingText({ error, data }) {
        debug(this.enableDebugging, 'RichTextDisplayWidget.handleRenderingText title', this.title);
        debug(this.enableDebugging, 'RichTextDisplayWidget.handleRenderingText content', this.content);
        debug(this.enableDebugging, 'RichTextDisplayWidget.handleRenderingText data', JSON.stringify(data));

        if (this.mode !== 'text') {
            return;
        }

        this.loading = false;

        this.handleResponseData(data, error);
    }

    @wire(callRenderDeveloperName, { developerName: '$developerName', enableDebug: '$enableDebugging' })
    handleRenderingDeveloperName({ error, data }) {
        debug(this.enableDebugging, 'RichTextDisplayWidget.handleRenderingDeveloperName developerName', this.developerName);
        debug(this.enableDebugging, 'RichTextDisplayWidget.handleRenderingDeveloperName data', JSON.stringify(data));

        if (this.mode !== 'developerName') {
            return;
        }

        this.loading = false;

        this.handleResponseData(data, error);
    }

    handleResponseData(dataJson, error) {
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