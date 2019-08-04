/**
 * Created by jmather on 2019-07-27.
 */
@IsTest
public with sharing class RTLD_WidgetApiTest {
    @IsTest
    static void TestRenderText() {
        String title = 'Foo';
        String content = 'Bar';

        Test.setMock(HttpCalloutMock.class, new TestMock());

        Test.startTest();

        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(RTLD_WidgetAPI.renderText(title, content, false), RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals(title, data.title);
        System.assertEquals(content, data.content);
    }

    class TestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String baseUrl = Url.getOrgDomainUrl().toExternalForm();
            String url = baseUrl + '/apex/render?title=Foo&content=Bar';
            System.assertEquals(url, req.getEndpoint());
            System.assertEquals('GET', req.getMethod());

            String content = '<html><body><!--**********************--><!--******************************-->eyJ0aXRsZSI6IiIsImNvbnRlbnQiOiJUZXN0IDIifQ==<!--********************--><!--****************************--></body></html>';
            HttpResponse resp = new HttpResponse();
            resp.setBody(content);
            resp.setStatusCode(200);
            return resp;
        }
    }
}