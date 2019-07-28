public without sharing class WidgetAPI {
    @AuraEnabled(Cacheable=true)
    public static String renderText(String title, String content) {
        System.debug('[WidgetAPI.renderText] title: ' + title);
        System.debug('[WidgetAPI.renderText] content: ' + content);
        String safeTitle = EncodingUtil.urlEncode(title, 'UTF-8');
        String safeContent = EncodingUtil.urlEncode(content, 'UTF-8');
        PageReference render = Page.Render;
        String url = render.getUrl() + '?title=' + safeTitle + '&content=' + safeContent;

        String result = JSON.serialize(parseRenderedText(url));
        System.debug('[WidgetAPI.renderText] result: ' + result);
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static String renderDeveloperName(String developerName) {
        System.debug('[WidgetAPI.renderDeveloperName] developerName: ' + developerName);
        PageReference render = Page.Render;
        String url = render.getUrl() + '?developerName=' + developerName;

        String result = JSON.serialize(parseRenderedText(url));
        System.debug('[WidgetAPI.renderDeveloperName] result: ' + result);
        return result;
    }

    @TestVisible
    private static RenderData parseRenderedText(String path) {
        String content = '';

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

        System.debug('[WidgetAPI.parseRenderedText] response: ' + content);

        String commentRegex = '\\<\\!--\\*+--\\>';
        String matchRegex = commentRegex + '(.*)' + commentRegex + commentRegex + '(.*)' + commentRegex;

        Pattern p = Pattern.compile(matchRegex);
        Matcher m = p.matcher(content);

        if (m.find()) {
            return new RenderData(m.group(1), m.group(2));
        }

        return new RenderData('Error', 'We encountered an error processing the output.');
    }

    public class RenderData {
        public String title;
        public String content;

        public RenderData(List<String> text) {
            if (text.isEmpty()) {
                this.title = '';
                this.content = '';
                return;
            }

            if (text.size() == 1) {
                this.title = '';
                this.content = text[0];
                return;
            }

            this.title = text[0];
            this.content = text[1];
        }

        public RenderData(String title, String content) {
            this.title = title;
            this.content = content;
        }
    }
}
