import { LightningElement, api, track, wire } from 'lwc';
import callRenderText from '@salesforce/apex/WidgetAPI.renderText'
import callRenderDeveloperName from '@salesforce/apex/WidgetAPI.renderDeveloperName'

let enableDebugging = false;

export default class RichTextDisplayWidget extends LightningElement {
    @api mode = 'developerName';
    @api developerName;
    @api title;
    @api content;
    @api note;
    @api enableDebugging = false;
    @track loading = true;
    @track renderedTitle = '';
    @track renderedContent = '';

    static debug() {
        if (enableDebugging) {
            console.log.apply(console, arguments);
        }
    }

    connectedCallback() {
        enableDebugging = this.enableDebugging;
    }

    @wire(callRenderText, { title: '$title', content: '$content', enableDebug: '$enableDebugging' })
    handleRenderingText({ error, data }) {
        RichTextDisplayWidget.debug('RichTextDisplayWidget.handleRenderingText title', this.title);
        RichTextDisplayWidget.debug('RichTextDisplayWidget.handleRenderingText content', this.content);
        RichTextDisplayWidget.debug('RichTextDisplayWidget.handleRenderingText data', JSON.stringify(data));

        this.loading = false;

        if (this.mode !== 'text') {
            return;
        }

        this.handleResponseData(data, error);
    }

    @wire(callRenderDeveloperName, { developerName: '$developerName', enableDebug: '$enableDebugging' })
    handleRenderingDeveloperName({ error, data }) {
        RichTextDisplayWidget.debug('RichTextDisplayWidget.handleRenderingDeveloperName developerName', this.developerName);
        RichTextDisplayWidget.debug('RichTextDisplayWidget.handleRenderingDeveloperName data', JSON.stringify(data));

        this.loading = false;

        if (this.mode !== 'developerName') {
            return;
        }

        this.handleResponseData(data, error);
    }

    handleResponseData(dataJson, error) {
        var data;
        if (dataJson) {
            data = JSON.parse(dataJson);
            this.renderedTitle = data.title;
            this.renderedContent = data.content;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }
}