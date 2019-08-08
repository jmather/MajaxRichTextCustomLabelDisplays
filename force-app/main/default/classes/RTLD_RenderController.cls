public without sharing class RTLD_RenderController {
    private String title = '';
    private String content = '';
    
    public RTLD_RenderController() {
        String content = ApexPages.currentPage().getParameters().get('content');
        String title = ApexPages.currentPage().getParameters().get('title');
        RTLD_Debug.enabled = Boolean.valueOf(ApexPages.currentPage().getParameters().get('debug'));

        RTLD_Debug.log('[RTLD_RenderController] passed content: ' + content);
        RTLD_Debug.log('[RTLD_RenderController] passed title: ' + title);
        RTLD_Debug.log('[RTLD_RenderController] passed debug: ' + RTLD_Debug.enabled);

        if (content != null && String.isBlank(content) == false || title != null && String.isBlank(title) == false) {
            this.title = title;
            this.content = content;
        } else {
            this.title = 'Example Title';
            this.content = 'Example Content';
        }

        RTLD_Debug.log('[RTLD_RenderController] content: ' + this.content);
        RTLD_Debug.log('[RTLD_RenderController] title: ' + this.title);
    }

    public String getData() {
        RTLD_RenderedData data = new RTLD_RenderedData(getRenderedTitle(), getRenderedContent());
        return EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(data)));
    }
    
    public String getRenderedContent() {
        return getRenderedValue(content);
    }

    public String getRenderedTitle() {
        return getRenderedValue(title);
    }

    private String getRenderedValue(String value) {
        if (String.isEmpty(value)) {
            return '';
        }

        Component.Apex.OutputText output = new Component.Apex.OutputText();

        if (value.contains('{!') == false) {
            return value;
        }

        output.expressions.value = value;
        return String.valueOf(output.value);
    }
}
