import { createElement } from 'lwc';
import RtldWidget from 'c/rtldWidget';
import { registerLdsTestWireAdapter } from '@salesforce/wire-service-jest-util';
import callRenderText from '@salesforce/apex/RTLD_WidgetAPI.renderText';
import getEntry from '@salesforce/apex/RTLD_WidgetAPI.getEntry';

const mockGetEntry = require('./data/getEntry.json');
const mockRenderText = require('./data/renderText.json');

const getEntryWireAdapter = registerLdsTestWireAdapter(getEntry);
const renderTextWireAdapter = registerLdsTestWireAdapter(callRenderText);

jest.mock(
    '@salesforce/apex/RTLD_WidgetAPI.renderText',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-rtldWidget', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    function flushPromises() {
        // eslint-disable-next-line no-undef
        return new Promise(resolve => setImmediate(resolve));
    }

    it('displays basic header and content', () => {
        callRenderText.mockResolvedValue(mockRenderText);

        // Create element
        const element = createElement('c-rtld-widget', {
            is: RtldWidget
        });

        document.body.appendChild(element);

        element.developerName = 'Test';
        // element.enableDebugging = true;

        getEntryWireAdapter.emit(mockGetEntry);

        // Return an immediate flushed promise (after the Apex call) to then
        // wait for any asynchronous DOM updates. Jest will automatically wait
        // for the Promise chain to complete before ending the test and fail
        // the test if the promise ends in the rejected state.
        return flushPromises().then(() => {
            const widgetHeader = element.shadowRoot.querySelector('lightning-card');
            expect(widgetHeader.title).toContain('foofoofoo');
            const widgetContent = element.shadowRoot.querySelector('lightning-formatted-rich-text');
            expect(widgetContent.value).toContain('barbarbar');
        });
    });
});
