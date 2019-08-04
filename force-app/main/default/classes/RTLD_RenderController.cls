public without sharing class RTLD_RenderController {
    private String title = '';
    private String content = '';
    
    public RTLD_RenderController() {
        String content = ApexPages.currentPage().getParameters().get('content');
        String title = ApexPages.currentPage().getParameters().get('title');
        String developerName = ApexPages.currentPage().getParameters().get('developerName');
        RTLD_Debug.enabled = Boolean.valueOf(ApexPages.currentPage().getParameters().get('debug'));

        RTLD_Debug.log('[RTLD_RenderController] passed content: ' + content);
        RTLD_Debug.log('[RTLD_RenderController] passed title: ' + title);
        RTLD_Debug.log('[RTLD_RenderController] passed developerName: ' + developerName);
        RTLD_Debug.log('[RTLD_RenderController] passed debug: ' + RTLD_Debug.enabled);

        if (developerName != null && String.isBlank(developerName) == false) {
            setFromEntry(developerName);
        } else if (content != null && String.isBlank(content) == false || title != null && String.isBlank(title) == false) {
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
        if (content == null) {
            return '';
        }

        Component.Apex.OutputText output = new Component.Apex.OutputText();
        //output.value = '{0}';
        if (content.contains('{!')) {
	        output.expressions.value = content;
        } else {
            output.value = content;
        }
        return String.valueOf(output.value);
    }

    public String getRenderedTitle() {
        if (title == null) {
            return '';
        }

        Component.Apex.OutputText output = new Component.Apex.OutputText();
        //output.value = '{0}';
        if (title.contains('{!')) {
	        output.expressions.value = title;
        } else {
            output.value = title;
        }
        return String.valueOf(output.value);
    }

    private void setFromEntry(String developerName) {
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry(developerName);
        
        if (entry == null) {
            title = 'Error';
            content = 'A RTLD_Entry__mdt record with the DeveloperName "' + developerName + '" was not found.';
        }
        
        title = entry.Title__c;
        content = entry.Content__c;
    }
}
