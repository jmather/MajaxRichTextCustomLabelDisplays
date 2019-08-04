public without sharing class RTLD_WidgetAPI {
    @AuraEnabled(Cacheable=true)
    public static String getEntry(String developerName, Boolean enableDebug) {
        RTLD_Debug.enabled = (enableDebug != null) ? enableDebug : false;
        RTLD_Entry__mdt entry = RTLD_EntryDAO.getEntry(developerName);
        return JSON.serialize(entry);
    }

    @AuraEnabled(Cacheable=true)
    public static String renderText(String title, String content, Boolean enableDebug) {
        RTLD_Debug.enabled = (enableDebug != null) ? enableDebug : false;

        RTLD_Debug.log('[WidgetAPI.renderText] title: ' + title);
        RTLD_Debug.log('[WidgetAPI.renderText] content: ' + content);
        String safeTitle = EncodingUtil.urlEncode(title, 'UTF-8');
        String safeContent = EncodingUtil.urlEncode(content, 'UTF-8');
        PageReference render = Page.RTLD_Render;
        String url = render.getUrl() + '?title=' + safeTitle + '&content=' + safeContent + '&debug=' + enableDebug;

        String result = getRenderedTextFromUrl(url);
        RTLD_Debug.log('[WidgetAPI.renderText] result: ' + result);
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static String renderEntry(RTLD_Entry__mdt entry, Boolean enableDebug) {
        RTLD_Debug.enabled = (enableDebug != null) ? enableDebug : false;

        Map<String, Object> properties = entry.getPopulatedFieldsAsMap();
        for (String propName : properties.keySet()) {
            RTLD_Debug.log('[WidgetAPI.renderText] ' + propName + ': ' + properties.get(propName));
        }

        String safeTitle = EncodingUtil.urlEncode(entry.Title__c, 'UTF-8');
        String safeContent = EncodingUtil.urlEncode(entry.Content__c, 'UTF-8');
        PageReference render = Page.RTLD_Render;
        String url = render.getUrl() + '?title=' + safeTitle + '&content=' + safeContent + '&debug=' + enableDebug;

        String result = getRenderedTextFromUrl(url);
        RTLD_Debug.log('[WidgetAPI.renderText] result: ' + result);
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static String renderDeveloperName(String developerName, Boolean enableDebug) {
        RTLD_Debug.enabled = (enableDebug != null) ? enableDebug : false;

        RTLD_Debug.log('[WidgetAPI.renderDeveloperName] developerName: ' + developerName);
        PageReference render = Page.RTLD_Render;
        String url = render.getUrl() + '?developerName=' + developerName + '&debug=' + enableDebug;

        String result = getRenderedTextFromUrl(url);
        RTLD_Debug.log('[WidgetAPI.renderDeveloperName] result: ' + result);

        return result;
    }

    private static String getRenderedTextFromUrl(String path) {
        String response = getResponseFromUrl(path);
        String content = getContentFromResponse(response);
        RTLD_Debug.log('[WidgetAPI.getRenderedText] content: ' + content);

        if (content == null) {
            return JSON.serialize(new RTLD_RenderedData('Error', 'We encountered an error processing the output.'));
        }

        return content;
    }

    private static String getResponseFromUrl(String path) {
        RTLD_Debug.log('[WidgetAPI.getContentFromUrl] path: ' + path);
        String content;

        if (Test.isRunningTest()) {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            String baseUrl = Url.getOrgDomainUrl().toExternalForm();
            req.setEndpoint(baseUrl + path);
            Http h = new Http();
            HttpResponse resp = h.send(req);
            content = resp.getBody();
        } else {
            content = new PageReference(path).getContent().toString();
        }

        return content;
    }

    private static String getContentFromResponse(String response) {
        RTLD_Debug.log('[WidgetAPI.getResponseFromContent] response: ' + response);

        String commentRegex = '\\<\\!--\\*+--\\>';
        String matchRegex = commentRegex + commentRegex + '(.*)' + commentRegex + commentRegex;

        Pattern p = Pattern.compile(matchRegex);
        Matcher m = p.matcher(response);

        if (m.find()) {
            String content = m.group(1);
            return EncodingUtil.base64Decode(content).toString();
        }

        return null;
    }
}
