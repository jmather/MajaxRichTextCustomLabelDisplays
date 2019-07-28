import { LightningElement, api, track, wire } from 'lwc';
import callRenderText from '@salesforce/apex/WidgetAPI.renderText'
import callRenderDeveloperName from '@salesforce/apex/WidgetAPI.renderDeveloperName'

export default class RichTextDisplayWidget extends LightningElement {
    @api mode = 'developerName';
    @api developerName;
    @api title;
    @api content;
    @track loading = true;
    @track renderedTitle = '';
    @track renderedContent = '';

    @wire(callRenderText, { title: '$title', content: '$content' })
    handleRenderingText({ error, data }) {
        console.log('RichTextDisplayWidget.handleRenderingText title', this.title);
        console.log('RichTextDisplayWidget.handleRenderingText content', this.content);
        console.log('RichTextDisplayWidget.handleRenderingText data', JSON.stringify(data));

        this.loading = false;

        if (this.mode !== 'text') {
            return;
        }

        this.handleResponseData(data, error);
    }

    @wire(callRenderDeveloperName, { developerName: '$developerName' })
    handleRenderingDeveloperName({ error, data }) {
        console.log('RichTextDisplayWidget.handleRenderingDeveloperName developerName', this.developerName);
        console.log('RichTextDisplayWidget.handleRenderingDeveloperName data', JSON.stringify(data));

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