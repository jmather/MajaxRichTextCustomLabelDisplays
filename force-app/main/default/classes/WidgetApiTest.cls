/**
 * Created by jmather on 2019-07-27.
 */
@IsTest
public with sharing class WidgetApiTest {
    @IsTest
    static void TestRenderText() {
        String title = 'Foo';
        String content = 'Bar';

        Test.setMock(HttpCalloutMock.class, new TestMock());

        Test.startTest();

        WidgetAPI.RenderData data = (WidgetAPI.RenderData) JSON.deserialize(WidgetAPI.renderText(title, content), WidgetAPI.RenderData.class);

        Test.stopTest();

        System.assertEquals(title, data.title);
        System.assertEquals(content, data.content);
    }

    class TestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String baseUrl = Url.getOrgDomainUrl().toExternalForm();
            String url = baseUrl + '/apex/majax__render?title=Foo&content=Bar';
            System.assertEquals(url, req.getEndpoint());
            System.assertEquals('GET', req.getMethod());

            String content = '<html><body><!--*********-->Foo<!--*******--><!--*******-->Bar<!--*******--></body></html>';
            HttpResponse resp = new HttpResponse();
            resp.setBody(content);
            resp.setStatusCode(200);
            return resp;
        }
    }
}