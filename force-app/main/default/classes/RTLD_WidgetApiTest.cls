/**
 * Created by jmather on 2019-07-27.
 */
@IsTest
public with sharing class RTLD_WidgetApiTest {
    @IsTest
    static void TestRenderText() {
        String t = Label.Test_1;
        t = Label.Test_2;
        t = Label.Test_Important_Announcement;
        t = Label.Test_Important_Announcement_Content;
        System.assertNotEquals(null, t);

        String title = 'Foo';
        String content = 'Bar';

        Test.setMock(HttpCalloutMock.class, new TestMock());

        Test.startTest();

        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(RTLD_WidgetAPI.renderText(title, content, false), RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals(title, data.title);
        System.assertEquals(content, data.content);
    }

    @IsTest
    static void TestRenderTextError() {
        String title = 'Foo';
        String content = 'Bar';

        Test.setMock(HttpCalloutMock.class, new TestMock(true));

        Test.startTest();

        RTLD_RenderedData data = (RTLD_RenderedData) JSON.deserialize(RTLD_WidgetAPI.renderText(title, content, false), RTLD_RenderedData.class);

        Test.stopTest();

        System.assertEquals(Label.RTLD_Error_Title, data.title);
        System.assertEquals(Label.RTLD_Error_Description, data.content);
    }

    @IsTest
    static void TestGetEntry() {
        String developerName = 'Test';

        Test.setMock(HttpCalloutMock.class, new TestMock());

        Test.startTest();

        RTLD_Entry__mdt entry = (RTLD_Entry__mdt) JSON.deserialize(RTLD_WidgetAPI.getEntry(developerName, false), RTLD_Entry__mdt.class);

        Test.stopTest();

        System.assertEquals('<p>{!$Label.Test_Important_Announcement_Content}</p>', entry.Content__c);
        System.assertEquals('{!$Label.Test_Important_Announcement}', entry.Title__c);
    }

    class TestMock implements HttpCalloutMock {
        Boolean returnError;

        public TestMock() {
            this(false);
        }

        public TestMock(Boolean returnError) {
            this.returnError = returnError;
        }

        public HttpResponse respond(HttpRequest req) {
            String baseUrl = Url.getOrgDomainUrl().toExternalForm();
            String url = 'render?title=Foo&content=Bar&debug=false';
            System.assertEquals(true, req.getEndpoint().startsWith(baseUrl));
            System.assertEquals(true, req.getEndpoint().endsWith(url));
            System.assertEquals('GET', req.getMethod());

            return (returnError) ? returnErrorResponse() : returnSuccessResponse();
        }

        private HttpResponse returnSuccessResponse() {
            String response = '{"title":"Foo","content":"Bar"}';
            String encodedResponse = EncodingUtil.base64Encode(Blob.valueOf(response));

            String content = '<html><body><!--**********************--><!--******************************-->' + encodedResponse + '<!--********************--><!--****************************--></body></html>';
            HttpResponse resp = new HttpResponse();
            resp.setBody(content);
            resp.setStatusCode(200);
            return resp;
        }

        private HttpResponse returnErrorResponse() {
            HttpResponse resp = new HttpResponse();
            resp.setBody('Error!');
            resp.setStatusCode(500);
            return resp;
        }
    }
}