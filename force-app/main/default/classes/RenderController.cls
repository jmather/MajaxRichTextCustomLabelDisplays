public without sharing class RenderController {
    private String title = '';
    private String content = '';
    
    public RenderController() {
        String content = ApexPages.currentPage().getParameters().get('content');
        String title = ApexPages.currentPage().getParameters().get('title');
        String developerName = ApexPages.currentPage().getParameters().get('developerName');
        Debug.enabled = Boolean.valueOf(ApexPages.currentPage().getParameters().get('debug'));

        Debug.log('[RenderController] passed content: ' + content);
        Debug.log('[RenderController] passed title: ' + title);
        Debug.log('[RenderController] passed developerName: ' + developerName);
        Debug.log('[RenderController] passed debug: ' + Debug.enabled);

        if (developerName != null && String.isBlank(developerName) == false) {
            setFromEntry(developerName);
        } else if (content != null && String.isBlank(content) == false) {
            this.title = title;
            this.content = content;
        } else {
            this.title = 'Example Title';
            this.content = 'Example Content';
        }

        Debug.log('[RenderController] content: ' + this.content);
        Debug.log('[RenderController] title: ' + this.title);
    }

    public String getData() {
        RenderedData data = new RenderedData(getRenderedTitle(), getRenderedContent());
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
        MAJAX__Display_Entry__mdt entry = EntryDAO.getEntry(developerName);
        
        if (entry == null) {
            title = 'Error';
            content = 'A MAJAX__Display_Entry__mdt record with the DeveloperName "' + developerName + '" was not found.';
        }
        
        title = entry.MAJAX__Title__c;
        content = entry.MAJAX__Content__c;
    }
}
